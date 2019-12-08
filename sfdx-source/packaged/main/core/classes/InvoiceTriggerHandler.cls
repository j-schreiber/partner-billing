public with sharing class InvoiceTriggerHandler implements ITriggerHandler {

    private List<TimeEntry__c> TimeEntriesToUpdate = new List<TimeEntry__c>();
    private List<ContentDocument> DocumentsToDelete = new List<ContentDocument>();

    /** @Description    All time entries (time sheets), mapped by invoice id. Lazy init. */
    private Map<Id, List<TimeEntry__c>> TimeEntries {
        private get {
            if (TimeEntries == null) {
                TimeEntries = new Map<Id, List<TimeEntry__c>>();
                if (Trigger.isUpdate) {
                    for (Invoice__c inv : [SELECT Id,(SELECT Id FROM TimeEntries__r) FROM Invoice__c WHERE Id IN :Trigger.oldMap.keySet()]) {
                        TimeEntries.put(inv.Id, inv.TimeEntries__r);
                    }
                }
            }
            return TimeEntries;
        }
        private set;
    }

    /** @Description    All related parent accounts to invoices. Lazy init. */
    private Map<Id, Account> Accounts {
        private get {
            if (Accounts == null) {
                // extract account ids from invoice and load accounts
                Set<Id> AccountIds = new Set<Id>();
                if (Trigger.new != null) {
                    for (Invoice__c inv : (List<Invoice__c>)Trigger.new) AccountIds.add(inv.Account__c);
                }
                Accounts = new Map<Id, Account>([SELECT Id,Name,BillingAddress FROM Account WHERE Id IN :AccountIds]);
            }
            return Accounts;
        }
        private set;
    }

    /** @Description    All org profiles that are available for the current user */
    private Map<Id, OrganizationProfile__c> OrganizationProfiles {
        private get {
            if (OrganizationProfiles == null) {
                OrganizationProfiles = new Map<Id, OrganizationProfile__c>(
                    [SELECT Id,Name,IsDefault__c
                    FROM OrganizationProfile__c ORDER BY IsDefault__c DESC]
                );
            }
            return OrganizationProfiles;
        }
        private set;
    }

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

    public InvoiceTriggerHandler() { }

    /** @Description
    *   Implementation of ITriggerHandler interface. Entry point to execute all trigger logic.
    *   This method solves trigger context and bulkification and dispatches to more specific functions
    *   to implement the individually needed logic.
    */
    public void execute() {
        if (!Trigger.isExecuting) return;
        switch on Trigger.OperationType {
            when BEFORE_INSERT { for (SObject so : Trigger.new) beforeInsert((Invoice__c)so); }
            when AFTER_UPDATE { for (SObject so : Trigger.new) afterUpdate((Invoice__c)so, (Invoice__c)(Trigger.oldMap.get(so.Id))); }
            when BEFORE_UPDATE { for (SObject so : Trigger.new) beforeUpdate((Invoice__c)so, (Invoice__c)(Trigger.oldMap.get(so.Id))); }
        }
        commitRelatedRecords();
    }

    /** @Description
    *   The beforeInsert scope method only defines order of execution for the business
    *   methods it calls
    */
    public void beforeInsert(Invoice__c newSo) {
        copyBillingAddressFromAccount(newSo);
        prefillDefaultOrgProfileId(newSo);
    }

    /** @Description
    *   All functionality that runs in after update scope. Order of execution is defined here.
    */
    public void afterUpdate(Invoice__c newSo, Invoice__c oldSo) {
        removeTimesheetFromCancelledInvoice(newSo);
        removeDocumentsFromDeleteConfiguredInvoice(newSo);
    }

    /** @Description
    *   All functionality that runs in before update scope. Order of execution is defined here.
    */
    public void beforeUpdate(Invoice__c newSo, Invoice__c oldSo) {
        validateModifications(new Invoice(newSo), new Invoice(oldSo));
    }

    /** @Description
    *   Commit all related records that have been cached
    */
    public void commitRelatedRecords() {
        Database.update(TimeEntriesToUpdate, true);
        Database.delete(DocumentsToDelete, true);
    }

    /**                                 PRIVATE METHODS                                      */

    private void copyBillingAddressFromAccount(Invoice__c newInvoice) {
        if (Accounts.containsKey(newInvoice.Account__c) && Accounts.get(newInvoice.Account__c).BillingAddress != null) {
            Address addr = Accounts.get(newInvoice.Account__c).BillingAddress;
            newInvoice.BillingStreet__c = String.isNotBlank(newInvoice.BillingStreet__c) ? newInvoice.BillingStreet__c : addr.getStreet();
            newInvoice.BillingPostalCode__c = String.isNotBlank(newInvoice.BillingPostalCode__c) ? newInvoice.BillingPostalCode__c : addr.getPostalCode();
            newInvoice.BillingCity__c = String.isNotBlank(newInvoice.BillingCity__c) ? newInvoice.BillingCity__c : addr.getCity();
            newInvoice.BillingCountry__c = String.isNotBlank(newInvoice.BillingCountry__c) ? newInvoice.BillingCountry__c : addr.getCountry();
            newInvoice.BillingState__c = String.isNotBlank(newInvoice.BillingState__c) ? newInvoice.BillingState__c : addr.getState();
        }
    }

    private void removeTimesheetFromCancelledInvoice(Invoice__c inv) {
        if (inv.Status__c == Constants.INVOICE_STATUS_CANCELLED) {
            for (TimeEntry__c te : TimeEntries.get(inv.Id)) {
                te.Invoice__c = null;
            }
            TimeEntriesToUpdate.addAll(TimeEntries.get(inv.Id));
        }
    }

    private void validateModifications(Invoice newInvoice, Invoice oldInvoice) {
        for (String fieldName : Invoice.ACTIVATED_LOCKED_FIELDS) {
            if (newInvoice.Record.get(fieldName) != oldInvoice.Record.get(fieldName) && oldInvoice.IsLocked) {
                if (!FeatureManagement.checkPermission('Modify_Activated_Invoices')) {
                    newInvoice.Record.addError(Label.Message_InvoiceValidation_CanNotEditLockedField);
                    break;
                }
            }
        }
    }

    private void prefillDefaultOrgProfileId(Invoice__c newRecord) {
        if (!OrganizationProfiles.isEmpty()) {
            newRecord.OrganizationProfile__c = OrganizationProfiles.values()[0].Id;
        }
    }

    private void removeDocumentsFromDeleteConfiguredInvoice(Invoice__c newRecord) {
        if (newRecord.PDFSyncSetting__c == Constants.INVOICE_PDF_SETTING_DELETE) {
            for (ContentDocumentLink cdl : Documents.get(newRecord.Id)) {
                DocumentsToDelete.add(cdl.ContentDocument);
            }
        }
    }
}
