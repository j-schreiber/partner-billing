/** @Description
*   This is the decorator object for the custom object Invoice__c that implements
*   functionality to create Invoices with Invoice Line Items
*
*/
public class Invoice {

    /** @Description    The decorated original SObject */
    public Invoice__c Record {public get; private set;}

    /** @Description    The invoice line items */
    public List<InvoiceLineItem> LineItems {public get; private set;}

    public Invoice(Invoice__c originalRecord) {
        Record = originalRecord;
        LineItems = new List<InvoiceLineItem>();

        if (originalRecord.LineItems__r != null) {
            for (InvoiceLineItem__c ili : originalRecord.LineItems__r) LineItems.add(new InvoiceLineItem(ili));
        }
    }
}
