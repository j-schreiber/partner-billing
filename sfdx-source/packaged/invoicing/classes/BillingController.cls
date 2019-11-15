/** @Descirption
*   Implements static methods to be used in Lightning (LWC or Aura) for billing time entries
*/
public with sharing class BillingController {
    
    /** @Description
    *   This controller method receives an unordered list of time entries and creates
    *   one invoice per account from these entries. The invoices contain one line item per
    *   time entry
    *
    *   @param  timeEntryIds    Time Entry Ids from selection to be invoiced
    *   @param  options         Structured invoicing options (collapseTimeEntries; overrideServicePeriod)
    *   @param  filters         Active filters that were used to retrieve this time entries (endDate; startDate)
    *
    *   @return                 Created list of invoices from time entries (one per account)
    */
    @AuraEnabled
    public static List<Invoice> createInvoicesFromTimeEntries(List<Id> timeEntryIds, Map<String, Object> options, Map<String, Object> filters) {

        Map<Id, Invoice> newInvoices = new Map<Id, Invoice>();
        List<InvoiceLineItem__c> newLineItemRecords = new List<InvoiceLineItem__c>();
        List<Invoice__c> newInvoiceRecords = new List<Invoice__c>();
        List<TimeEntry__c> dirtyTimeEntries = new List<TimeEntry__c>();

        List<Account> accounts = [SELECT Id,(SELECT Id,DailyRate__c,Product__c,Duration__c,Date__c FROM TimeEntries__r WHERE Id IN :timeEntryIds)
                                FROM Account 
                                WHERE Id IN (SELECT Account__c FROM TimeEntry__c WHERE Id IN :timeEntryIds)];

        Boolean collapseEntries = (Boolean)options.get('collapseTimeEntries');
        Boolean overrideServicePeriod = (Boolean)options.get('overrideServicePeriod');
        Invoice.ServicePeriod filterSP = new Invoice.ServicePeriod(filters);

        for (Account a : accounts) {
            Invoice inv = new Invoice();
            inv.Record.Account__c = a.Id;
            inv.Record.Date__c = System.today();
            inv.Record.Status__c = 'Draft';
            newInvoices.put(a.Id, inv);
            newInvoiceRecords.add(inv.Record);
        }
        Database.insert(newInvoiceRecords);

        for (Account a : accounts) { 
            newLineItemRecords.addAll(newInvoices.get(a.Id).addTimeEntries(collapseEntries, a.TimeEntries__r));
            dirtyTimeEntries.addAll(a.TimeEntries__r);
        }
        Database.insert(newLineItemRecords);   
        Database.update(dirtyTimeEntries);

        for (Invoice inv : newInvoices.values()) {
            Invoice.ServicePeriod timesheetSP = inv.getTimeSheetServicePeriod();
            inv.setServicePeriod(overrideServicePeriod ? filterSP : timesheetSP);
        }
        Database.update(newInvoiceRecords);

        return newInvoices.values();
    }

    /** @Description
    *   Gets non-invoiced time entries for the specified filter criteria
    *
    *   @param  startDate       Minimum Date
    *   @param  endDate         Maximum Date
    *
    *   @return                 List of Time Entries
    */
    @AuraEnabled(cacheable=true)
    public static List<TimeEntry> getNonInvoicedTimeEntries(Date startDate, Date endDate) {
        List<TimeEntry> results = new List<TimeEntry>();
        for (TimeEntry__c te : [SELECT Id,Name,Account__r.Name,Date__c,StartTime__c,EndTime__c,Duration__c,DailyRate__c,TotalAmount__c,Product__r.Name
                                FROM TimeEntry__c 
                                WHERE IsInvoiced__c = false AND Status__c = 'Approved' AND (Date__c >= :startDate AND Date__c <= :endDate)
                                ORDER BY Account__c,Date__c])
            results.add(new TimeEntry(te));
        return results;
    }

    /** @Description
    *   Get Invoices filtered by a specific status
    *
    *   @param  status          Requested status value
    *
    *   @return                 List of Invoices that match criteria
    */
    @AuraEnabled(cacheable=true)
    public static List<Invoice> getInvoices(String status) {
        List<Invoice> results = new List<Invoice>();
        for (Invoice__c inv : Database.query(Invoice.QUERY_STRING + ' WHERE Status__c = :status ORDER BY Date__c')) {
            results.add(new Invoice(inv));
        }
        return results;
    }

    /** @Description
    *   This method commits all data for the invoice-edit view panel. Marked line items
    *   are deleted, new/modified line items are upserted and invoices are updated
    *
    *   @param  invoices            Dirty invoices to update
    *   @param  upsertLineItems     Dirty invoice line items to update or insert
    *   @param  deleteLineItemIds   Ids for line items to delete
    */
    @AuraEnabled
    public static void commitInvoiceEditData(List<Invoice__c> invoices, List<InvoiceLineItem__c> upsertLineItems, List<Id> deleteLineItemIds) {

        Database.SaveResult[] invoiceSrs = Database.update(invoices, false);
        Database.UpsertResult[] ilisUrs = Database.upsert(upsertLineItems, false);
        Database.DeleteResult[] ilisDrs = Database.delete(deleteLineItemIds, false);

        List<String> errors = new List<String>();
        for (Database.SaveResult sr : invoiceSrs) {
            if (!sr.isSuccess()) errors.addAll(extractDatabaseErrorsAsStringList(sr.getErrors()));
        }
        for (Database.UpsertResult ur : ilisUrs) {
            if (!ur.isSuccess()) errors.addAll(extractDatabaseErrorsAsStringList(ur.getErrors())); 
        }
        for (Database.DeleteResult dr : ilisDrs) {
            if (!dr.isSuccess()) errors.addAll(extractDatabaseErrorsAsStringList(dr.getErrors())); 
        }
        if (!errors.isEmpty()) {
            String errMsg = String.join(errors, '\\n');
            AuraHandledException auraExp = new AuraHandledException(errMsg);
            auraExp.setMessage(errMsg);
            throw auraExp; 
        }
    }

    /** @Description
    *   Retrieves invoices by their record ids. Always returns the fully loaded invoice
    *   and disables cache, so the client controller always receives the newest data.
    *
    *   @param  invoiceIds          Ids of invoices that will be refreshed
    *
    *   @return                     Reloaded invoices
    */
    @AuraEnabled
    public static Map<Id, Invoice> refreshInvoices(List<String> invoiceIds) {
        Map<Id, Invoice> results = new Map<Id, Invoice>();
        for (Invoice__c inv : Database.query(Invoice.QUERY_STRING + ' WHERE Id IN :invoiceIds')) {
            results.put(inv.Id, new Invoice(inv));
        }
        return results;
    }

    /** @Description
    *   Get all invoices that are Activated but do not have at least one attachment.
    *
    *   @return                 Active invoices without content documents
    */
    @AuraEnabled(cacheable=true)
    public static List<Invoice> getInvoicesWithoutPdfs() {
        List<Invoice> results = new List<Invoice>();
        for (Invoice__c inv : Database.query(Invoice.QUERY_STRING + ' WHERE Status__c = \'Activated\' ORDER BY Date__c')) {
            if (inv.ContentDocumentLinks.isEmpty()) results.add(new Invoice(inv));
        }
        return results;
    }

    /** @Description
    *   Get all invoices that are Activated and do have at least one attachment.
    *
    *   @return                 Active invoices with content documents
    */
    @AuraEnabled(cacheable=true)
    public static List<Invoice> getInvoicesWithPdfs() {
        List<Invoice> results = new List<Invoice>();
        for (Invoice__c inv : Database.query(Invoice.QUERY_STRING + ' WHERE Status__c = \'Activated\' ORDER BY Date__c')) {
            if (!inv.ContentDocumentLinks.isEmpty()) results.add(new Invoice(inv));
        }
        return results;
    }

    /** @Description
    *   Send the latest version of the selected document to the selected contact using the
    *   selected mail template. The document is attached to the email using standard configuration
    *
    *   @param  contactId   Mail recipient (Contact)
    *   @param  templateId  Template to use (EmailTemplate)
    *   @param  documentId  Document (ContentDocument) that will be attached
    *   @param  invoiceId   The invoice record
    *   @param  sender      Selected sender (User or OrgWideEmailAddress)
    *
    *   @return             All Emails that are attached to the invoice.
    */
    @AuraEnabled
    public static List<Task> sendDocumentToContact(String contactId, String templateId, String documentId, String invoiceId, SenderAddress sender) {

        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :documentId AND IsLatest = true];

        Messaging.SingleEmailMessage Message = new Messaging.SingleEmailMessage();
        Message.setTemplateId(templateId);
        Message.setTargetObjectId(contactId);
        Message.setTreatTargetObjectAsRecipient(true);
        Message.setWhatId(invoiceId);
        Message.setEntityAttachments(new List<Id>{cv.Id});
        if (sender.Type == SenderAddress.TYPE_ORG_WIDE_ADDRESS) {
            Message.setOrgWideEmailAddressId(sender.senderId);
        }

        List<Messaging.SendEmailResult> sers = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{Message}, false);
        if (!sers[0].isSuccess()) {
            String errMsg = convertSendEmailErrorsToString(sers[0].getErrors());
            AuraHandledException auraExp = new AuraHandledException(errMsg);
            auraExp.setMessage(errMsg);
            throw auraExp;
        }

        return [SELECT Id,Subject FROM Task WHERE WhatId = :invoiceId];
    }

    /**                                         PRIVATE ZONE                                 */

    private static String convertSendEmailErrorsToString(List<Messaging.SendEmailError> serrs) {
        String t = '';
        for (Messaging.SendEmailError serr : serrs) {
            t = t + 'Status Code: '+ serr.getStatusCode() + '\n';
            t = t + 'Details: '+ serr.getMessage() + '\n';
        }
        return t;
    }

    private static List<String> extractDatabaseErrorsAsStringList(Database.Error[] dbErrs) {
        List<String> errs = new List<String>();
        for (Database.Error err : dbErrs) errs.add(err.getStatusCode() + ': ' + err.getMessage());
        return errs;
    }

}
