/** @Description
*   This is the decorator object for the custom object InvoiceLineItem__c.
*/
public class InvoiceLineItem {

    /** @Description    The decorated original SObject */
    @AuraEnabled
    public InvoiceLineItem__c Record {public get; private set;}

    /** @Description    Reference to the parent invoice of this line item */
    public Invoice Invoice {
        public get; 
        public set {
            Record.Invoice__c = Value.Record.Id;
        }
    }

    /** @Description    Create Decorator from original SObject record */
    public InvoiceLineItem(InvoiceLineItem__c originalRecord) {
        Record = originalRecord;
    }

}
