/** @Descirption
*   Implements static methods to be used in Lightning (LWC or Aura) for billing time entries
*/
public with sharing class BillingController {
    
    /** @Description
    *   This controller method receives an unordered list of time entries and creates
    *   one invoice per account from these entries. The invoices contain one line item per
    *   time entry
    *
    *   @param  timeEntries     Time Entries to be invoiced
    *
    *   @return                 Created list of invoices from time entries (one per account)
    */
    @AuraEnabled(cacheable=true)
    public static List<Invoice__c> createInvoicesFromTimeEntries(List<TimeEntry__c> timeEntries) {
        return new List<Invoice__c>();
    }

    /** @Description
    *   Method expects an organized list of time entries (only to the same account) and creates
    *   an invoice for this account.
    */
    private static Invoice__c createInvoiceFromTimeEntries(Id accountId, List<TimeEntry__c> timeEntries) {
        return new Invoice__c();
    }
}
