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

    /** @Description    Attachments for this invoice */
    public List<Attachment> Attachments;

    /** @Description    Initialize the object by invoice id */
    public Invoice(Id recordId) {
        this([
            SELECT Id,Name,Date__c,Status__c,TotalAmount__c,TotalGrossAmount__c,BillingStreet__c,BillingCity__c,BillingPostalCode__c,BillingCountry__c,BillingState__c,
            Account__r.Name,
            (
                SELECT Id,Amount__c,GrossAmount__c,Description__c,Price__c,Quantity__c,ServiceDate__c,Tax__c,Unit__c FROM LineItems__r
            ),
            (SELECT Id FROM Attachments)
            FROM Invoice__c WHERE Id = :recordId
        ]);
    }

    /** @Description    Initialize the object with the fully queried record */
    public Invoice(Invoice__c originalRecord) {
        Record = originalRecord;
        LineItems = new List<InvoiceLineItem>();
        Attachments = Record.Attachments;

        if (originalRecord.LineItems__r != null) {
            for (InvoiceLineItem__c ili : originalRecord.LineItems__r) LineItems.add(new InvoiceLineItem(ili));
        }
    }

    /** @Description
    *   Creates a PDF from the InvoicePDF visualforce page and returns the Blob
    *
    *   @return             The created Pdf (from invoice visualforce page)
    */
    public Blob createPdf() {
        PageReference invoicePdfPage = Page.InvoicePdf;
        invoicePdfPage.getParameters().put('Id', Record.Id);
        // Apex tests do not support PDF generation, therefore we "mock" a Blob
        return Test.isRunningTest() ? Blob.valueOf('TestPDF') : invoicePdfPage.getContentAsPdf();
    }

    public void addFileToAttachments(Blob fileToSave) {
        Attachment att = new Attachment(Body = fileToSave,
                                        Name = generateInvoicePdfName(),
                                        ParentId = Record.Id);
        Attachments.add(att);        
    }

    public void commitAllChanges() {
        upsert Attachments;
    }

    private String generateInvoicePdfName() {
        return System.now().format('YYYY-MM-dd') + '_' + 
            Record.Name + '_' +
            Record.Account__r.Name + '_' +
            (Attachments.size() + 1) + '_' +
            '.pdf';
    }
}
