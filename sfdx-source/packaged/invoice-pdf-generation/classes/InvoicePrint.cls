public class InvoicePrint extends Invoice {

    /** @Description    Wraps the total taxes with currency formatting */
    public String TotalTaxesFormatted {
        public get {
            TotalTaxesFormatted = TotalTaxes.format() + ' €';
            return TotalTaxesFormatted;
        }
        private set;
    }

    public String PdfTitle {
        public get {
            PdfTitle = Record.PdfLanguage__c + '_' + Record.Name + '_' +
                Record.Account__r.Name + '_' + (Attachments.size() + 1);
            return PdfTitle;
        }
        private set;
    }

    public InvoicePrint(String recordId) {
        super(recordId);
    }

    /** @Description
    *   Creates a PDF from the InvoicePDF visualforce page and returns the Blob. Method
    *   does not set the organization profile and uses visualforce page's default behavior.
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
    *   Creates a PDF from the InvoicePDF visualforce page with the selected organization profile id
    *   and returns the Blob.
    *
    *   @param  orgProfileId    The organization profile id that will be used to render header/footer
    *
    *   @return                 The created Pdf (from invoice visualforce page)
    */
    public Blob createPdf(Id orgProfileId) {
        PageReference invoicePdfPage = Page.InvoicePdf;
        invoicePdfPage.getParameters().put('Id', Record.Id);
        invoicePdfPage.getParameters().put('orgProfileId', orgProfileId);
        // Apex tests do not support PDF generation, therefore we "mock" a Blob
        return Test.isRunningTest() ? Blob.valueOf('TestPDF') : invoicePdfPage.getContentAsPdf();
    }

    /** @Description
    *   Creates a PDF from the InvoicePDF visualforce page with the selected organization profile id
    *   and overwrites the invoice's language.
    *
    *   @param  orgProfileId    The organization profile id that will be used to render header/footer
    *   @param  renderLanguage  Language value to overwrite the records language
    *
    *   @return                 The created Pdf (from invoice visualforce page)
    */
    public PageReference createPdf(Id orgProfileId, String renderLanguage) {
        PageReference invoicePdfPage = Page.InvoicePdf;
        invoicePdfPage.getParameters().put('Id', Record.Id);
        invoicePdfPage.getParameters().put('orgProfileId', orgProfileId);
        invoicePdfPage.getParameters().put('lang', renderLanguage);
        Record.PdfLanguage__c = renderLanguage;
        return invoicePdfPage;
    }

    /** @Description
    *   Saves a Blob (presumably a PDF file) to the internal attachments of the invoice.
    *   This method only caches the file and does not commit the attachments.
    *
    *   @param  fileToSave  File that will be saved as attachment
    */
    public void addFileToAttachments(Blob fileToSave) {
        Attachment att = new Attachment(Body = fileToSave,
                                        Name = PdfTitle + '.pdf',
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
