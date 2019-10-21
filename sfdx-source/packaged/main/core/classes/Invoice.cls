/** @Description
*   This is the decorator object for the custom object Invoice__c that implements
*   functionality to create Invoices with Invoice Line Items, create PDFs and handle Attachments
*
*/
public virtual class Invoice {

    /** @Description    The decorated original SObject */
    public Invoice__c Record {public get; private set;}

    /** @Description    The invoice line items */
    public List<InvoiceLineItem> LineItems {public get; private set;}

    /** @Description    Attachments for this invoice */
    public List<Attachment> Attachments;

    /** @Description    Calculated total taxes */
    public Decimal TotalTaxes {
        public get {
            TotalTaxes = Record.TotalGrossAmount__c - Record.TotalAmount__c;
            return TotalTaxes;
        }
        private set;
    }

    /** @Description    Calculated total taxes percentage */
    public Decimal TotalTaxesPercentage {
        public get {
            TotalTaxesPercentage = TotalTaxes.divide(Record.TotalAmount__c, 4);
            return TotalTaxesPercentage;
        }
        private set;
    }

    /** @Description    Initialize the object by invoice id */
    public Invoice(Id recordId) {
        this([
            SELECT Id,Name,Date__c,Status__c,TotalAmount__c,TotalGrossAmount__c,BillingStreet__c,BillingCity__c,BillingPostalCode__c,BillingCountry__c,BillingState__c,PdfLanguage__c,PdfRenderTimesheet__c,
            Account__r.Name,Account__r.CustomerId__c,
            Account__r.Owner.Name,Account__r.Owner.Phone,Account__r.Owner.Email,
            (
                SELECT Id,Amount__c,GrossAmount__c,Description__c,Price__c,Quantity__c,ServiceDate__c,Tax__c,Unit__c,Product__r.Name,Productname__c FROM LineItems__r
            ),
            (
                SELECT Id,Name FROM Attachments
            )
            FROM Invoice__c WHERE Id = :recordId
        ]);
    }

    /** @Description    Initialize the object with the fully queried record */
    public Invoice(Invoice__c originalRecord) {
        Record = originalRecord;
        Attachments = Record.Attachments;

        // get line items from related records
        LineItems = new List<InvoiceLineItem>();
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

    /** @Description
    *   Saves a Blob (presumably a PDF file) to the internal attachments of the invoice.
    *   This method only caches the file and does not commit the attachments.
    *
    *   @param  fileToSave  File that will be saved as attachment
    */
    public void addFileToAttachments(Blob fileToSave) {
        Attachment att = new Attachment(Body = fileToSave,
                                        Name = generateInvoicePdfName(),
                                        ParentId = Record.Id);
        Attachments.add(att);        
    }

    /** @Description
    *   Commits all changes made to the record or related records.
    */
    public void commitAllChanges() {
        upsert Attachments;
    }


    /**                                 PRIVATE AREA                                 */

    private String generateInvoicePdfName() {
        return System.now().format('YYYY-MM-dd') + '_' + 
            Record.Name + '_' +
            Record.Account__r.Name + '_' +
            (Attachments.size() + 1) + '_' +
            '.pdf';
    }
}
