public with sharing class InvoiceTriggerHandlerPdf implements ITriggerHandler {
    
    private List<ContentDocument> DocumentsToDelete = new List<ContentDocument>();
    private Set<Id> RerenderDocumentsQueue = new Set<Id>();

    /** @Description    All content document links mapped by invoice id */
    private Map<Id, List<ContentDocumentLink>> Documents {
        private get {
            if (Documents == null) {
                Documents = new Map<Id, List<ContentDocumentLink>>();
                if (Trigger.isUpdate) {
                    for (Invoice__c inv : [SELECT Id,(SELECT Id,ContentDocumentId,ContentDocument.Title FROM ContentDocumentLinks) FROM Invoice__c WHERE Id IN :Trigger.oldMap.keySet()]) {
                        Documents.put(inv.Id, inv.ContentDocumentLinks);
                    }
                }
            }
            return Documents;
        }
        private set;
    }

    /** @Description
    *   Implementation of ITriggerHandler interface. Entry point to execute all trigger logic.
    *   This method solves trigger context and bulkification and dispatches to more specific functions
    *   to implement the individually needed logic.
    */
    public void execute() {
        if (!Trigger.isExecuting) return;
        switch on Trigger.OperationType {
            when AFTER_UPDATE { 
                for (SObject so : Trigger.new) {
                    removeDocumentsFromDeleteConfiguredInvoice((Invoice__c)so);
                    generateNewDocumentVersionForSyncConfiguredInvoice((Invoice__c)so, (Invoice__c)(Trigger.oldMap.get(so.Id)));
                } 
            }
        }
        commitRelatedRecords();
        queueFutureJobs();
    }

    /** @Description
    *   Commit all related records that have been cached
    */
    public void commitRelatedRecords() {
        Database.delete(DocumentsToDelete, true);
    }

    /** @Description
    *   Queues async future jobs
    */
    public void queueFutureJobs() {
        if (!RerenderDocumentsQueue.isEmpty()) {
            System.enqueueJob(new InvoiceTriggerPdfGeneration(RerenderDocumentsQueue));
        }
    }

    private void removeDocumentsFromDeleteConfiguredInvoice(Invoice__c newRecord) {
        if (newRecord.PDFSyncSetting__c == Constants.INVOICE_PDF_SETTING_DELETE) {
            for (ContentDocumentLink cdl : Documents.get(newRecord.Id)) {
                DocumentsToDelete.add(cdl.ContentDocument);
            }
        }
    }

    private void generateNewDocumentVersionForSyncConfiguredInvoice(Invoice__c newRecord, Invoice__c oldRecord) {
        if (newRecord.PDFSyncSetting__c == Constants.INVOICE_PDF_SETTING_SYNC && hasActivatedFieldModified(newRecord, oldRecord)) {
            RerenderDocumentsQueue.add(newRecord.Id);
        }
    }

    private Boolean hasActivatedFieldModified(Invoice__c newRecord, Invoice__c oldRecord) {
        Set<String> modifiedFields = SObjectUtils.getModifiedFields(newRecord, oldRecord);
        for (String field : modifiedFields) {
            if (Invoice.ACTIVATED_LOCKED_FIELDS.contains(field)) return true;
        }
        return false;
    }

}
