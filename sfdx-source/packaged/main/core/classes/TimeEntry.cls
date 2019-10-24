/** @Description
*   This is the decorator object for the custom object InvoiceLineItem__c.
*/
public class TimeEntry {

    /** @Description    The decorated original SObject */
    public TimeEntry__c Record {public get; private set;}

    /** @Description    Create Decorator from original SObject record */
    public TimeEntry(TimeEntry__c originalRecord) {
        Record = originalRecord;
    }

    /** @Description
    *   Create an invoice line item decorator from this time entry that can be added
    *   to an existing invoice
    *
    *   @return                 Invoice line item that has been created from internal record
    */
    public InvoiceLineItem getInvoiceLineItem() {
        InvoiceLineItem__c lineItemRecord = new InvoiceLineItem__c(Price__c = Record.TotalAmount__c,
                                                                   Quantity__c = Record.Duration__c / 8,
                                                                   Description__c = Record.Description__c,
                                                                   ServiceDate__c = Record.Date__c,
                                                                   Product__c = Record.Product__c);
        return new InvoiceLineItem(lineItemRecord);
    }
}
