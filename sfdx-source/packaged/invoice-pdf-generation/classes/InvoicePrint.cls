public class InvoicePrint extends Invoice {

    /** @Description    Uses Formatter-SObject Pattern to return calculated taxes */
    public Formatter__c TotalTaxesFormatted {
        public get {
            TotalTaxesFormatted = new Formatter__c(Currency__c = TotalTaxes);
            return TotalTaxesFormatted;
        }
        private set;
    }

    /** @Description    Generated PDF title from language, name and related parent account */
    public String PdfTitle {
        public get {
            PdfTitle = Record.PdfLanguage__c + '_' + Record.Name + '_' +
                Record.Account__r.Name + '_' + (Attachments.size() + 1);
            return PdfTitle;
        }
        private set;
    }

    /** @Description    Calculates if the invoice has a valid and non empty time sheet that should be displayed */
    public Boolean DisplayTimesheet {
        public get {
            DisplayTimesheet = Record.PdfRenderTimesheet__c && !Record.TimeEntries__r.isEmpty();
            return DisplayTimesheet;
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
    *   @return             Initialized visualforce PDF renderer page
    */
    public PageReference createPdf() {
        PageReference invoicePdfPage = Page.InvoicePdf;
        invoicePdfPage.getParameters().put('Id', Record.Id);
        return invoicePdfPage;
    }

    /** @Description
    *   Creates a PDF from the InvoicePDF visualforce page with the selected organization profile id
    *   and returns the Blob.
    *
    *   @param  orgProfileId    The organization profile id that will be used to render header/footer
    *
    *   @return                 Initialized visualforce PDF renderer page
    */
    public PageReference createPdf(Id orgProfileId) {
        PageReference invoicePdfPage = createPdf();
        invoicePdfPage.getParameters().put('orgProfileId', orgProfileId);
        return invoicePdfPage;
    }

    /** @Description
    *   Creates a PDF from the InvoicePDF visualforce page with the selected organization profile id
    *   and overwrites the invoice's language.
    *
    *   @param  orgProfileId    The organization profile id that will be used to render header/footer
    *   @param  lang            Language value to overwrite the records language
    *
    *   @return                 Initialized visualforce PDF renderer page
    */
    public PageReference createPdf(Id orgProfileId, String lang) {
        PageReference invoicePdfPage = createPdf(orgProfileId);
        invoicePdfPage.getParameters().put('lang', lang);
        Record.PdfLanguage__c = lang;
        return invoicePdfPage;
    }

    /** @Description
    *   Creates a PDF from the InvoicePDF visualforce page with the selected organization profile id
    *   and overwrites the invoice's language and the display timesheet option.
    *
    *   @param  orgProfileId    The organization profile id that will be used to render header/footer
    *   @param  lang            Language value to overwrite the records language
    *   @param  timesheet       Controls render option of embedded timesheet
    *
    *   @return                 Initialized visualforce PDF renderer page
    */
    public PageReference createPdf(Id orgProfileId, String lang, Boolean timesheet) {
        PageReference invoicePdfPage = createPdf(orgProfileId, lang);
        invoicePdfPage.getParameters().put('displayTimesheet', String.valueOf(timesheet));
        Record.PdfRenderTimesheet__c = timesheet;
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

}
