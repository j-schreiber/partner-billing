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
    *   @param  options         Structured invoicing options
    *   @param  filters         Active filters that were used to retrieve this time entries
    *
    *   @return                 Created list of invoices from time entries (one per account)
    */
    @AuraEnabled(cacheable=true)
    public static List<Invoice__c> createInvoicesFromTimeEntries(List<Id> timeEntryIds, Map<String, Object> options, Map<String, Object> filters) {
        System.debug('Options: ' + options);
        System.debug('Ids: ' + timeEntryIds);
        System.debug('Filters: ' + filters);
        return new List<Invoice__c>();
    }

    /** @Description
    *   Method expects an organized list of time entries (only to the same account) and creates
    *   an invoice for this account.
    */
    private static Invoice__c createInvoiceFromTimeEntries(Id accountId, List<TimeEntry__c> timeEntries) {
        return new Invoice__c();
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
}
