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
    @AuraEnabled
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
    *   Retrieves all invoices for the specified filter certeria
    *
    *   @param  status          Filtered status value for invoices
    *
    *   @return                 List of Invoices that match criteria
    */
    @AuraEnabled
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
        for (Invoice__c inv : invoices) System.debug('Updating: ' + inv);
        for (InvoiceLineItem__c ili : upsertLineItems) System.debug('Upserting: ' + ili);
        for (Id i : deleteLineItemIds) System.debug('Deleting: ' + i);

        Database.update(invoices, true);
        Database.upsert(upsertLineItems, false);
        Database.delete(deleteLineItemIds, false);
    }

    /** @Description
    *   Updates invoice records
    *
    *   @param  invoices        Dirty invoices to update
    */
    @AuraEnabled
    public static void updateInvoices(List<Invoice__c> invoices) {
        for (Invoice__c inv : invoices) System.debug('Updating: ' + inv);
    }

    /** @Description
    *   Upsert invoice line items records. This method updates existing and
    *   inserts new records.
    *
    *   @param  lineItems       Dirty invoice line items to update
    */
    @AuraEnabled
    public static void upsertInvoiceLineItems(List<InvoiceLineItem__c> lineItems) {
        for (InvoiceLineItem__c ili : lineItems) System.debug('Upserting: ' + ili);
    }

    /** @Description
    *   Delete line items in array
    *
    *   @param  lineItems       Dirty invoice line items to delete
    */
    @AuraEnabled
    public static void deleteInvoiceLineItems(List<Id> lineItemIds) {
        for (Id i : lineItemIds) System.debug('Deleting: ' + i);
    }
}
