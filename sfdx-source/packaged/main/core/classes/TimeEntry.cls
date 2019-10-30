/** @Description
*   This is the decorator object for the custom object TimeEntry__c.
*/
public class TimeEntry {

    /** @Description    The decorated original SObject */
    public TimeEntry__c Record {public get; private set;}

    @AuraEnabled
    public String AccountName {
        public get { return Record.Account__r.Name; }
    }

    @AuraEnabled
    public String Name {
        public get { return Record.Name; }
    }

    @AuraEnabled
    public Id Id {
        public get { return Record.Id; }
    }

    /** @Description    Formatted duration */
    @AuraEnabled
    public String Duration {
        public get { return Record.Duration__c + ' h'; }
    }

    @AuraEnabled
    public Time StartTime {
        public get { return Record.StartTime__c; }
    }

    @AuraEnabled
    public Time EndTime {
        public get { return Record.EndTime__c; }
    }

    @AuraEnabled
    public Decimal TotalAmount {
        public get { return Record.TotalAmount__c; }
    }

    @AuraEnabled
    public Decimal DailyRate {
        public get { return Record.DailyRate__c; }
    }

    @AuraEnabled
    public Date ServiceDate {
        public get { return Record.Date__c; }
    }

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
