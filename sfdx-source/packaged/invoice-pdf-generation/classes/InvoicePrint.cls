public class InvoicePrint extends Invoice {

    /** @Description    Wraps the total taxes with currency formatting */
    public String TotalTaxesFormatted {
        public get {
            TotalTaxesFormatted = TotalTaxes.format() + ' €';
            return TotalTaxesFormatted;
        }
        private set;
    }

    public InvoicePrint(String recordId) {
        super(recordId);
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

    /**                                 PRIVATE AREA                                 */

    private String generateInvoicePdfName() {
        return Record.PdfLanguage__c + '_' + 
            Record.Name + '_' +
            Record.Account__r.Name + '_' +
            (Attachments.size() + 1) + '_' +
            '.pdf';
    }
}
