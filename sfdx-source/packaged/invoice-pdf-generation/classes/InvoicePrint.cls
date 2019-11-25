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
            List<String> titles = new List<String>();
            if (!IsLocked) titles.add(Label.InvoicePdf_Watermark_Draft);
            titles.addAll(new List<String>{Record.PdfLanguage__c, Record.Name, Record.Account__r.Name});
            PdfTitle = String.join(titles, '_');
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

    /** @Description    The ContentDocument record where the PDF Content Versions are stored */
    public ContentDocument PdfDocument {
        public get {
            if (PdfDocument == null) {
                List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Title = :PdfTitle];
                if (!docs.isEmpty()) PdfDocument = docs[0];
            }
            return PdfDocument;
        }
        public set;
    }

    public static final Map<String, RenderProperty> PdfRenderProperties = new Map<String, RenderProperty> {
        'Id' => new RenderProperty('Id', false),
        'orgProfileId' => new RenderProperty('Organization Profile Id', true),
        'lang' => new RenderProperty('Language', true),
        'displayTimesheet' => new RenderProperty('Display Timesheet', true)
    };

    public InvoicePrint(String recordId) {
        super(recordId);
    }

    public InvoicePrint(Invoice__c sObjRecord) {
        super(sObjRecord);
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
    public PageReference createPdf(String orgProfileId) {
        PageReference invoicePdfPage = createPdf();
        if (String.isNotBlank(orgProfileId)) invoicePdfPage.getParameters().put('orgProfileId', orgProfileId);
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
    public PageReference createPdf(String orgProfileId, String lang) {
        PageReference invoicePdfPage = createPdf(orgProfileId);
        if (String.isNotBlank(lang)) {
            invoicePdfPage.getParameters().put('lang', lang);
            Record.PdfLanguage__c = lang;
        }
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
    public PageReference createPdf(String orgProfileId, String lang, Boolean timesheet) {
        PageReference invoicePdfPage = createPdf(orgProfileId, lang);
        if (timesheet != null) {
            invoicePdfPage.getParameters().put('displayTimesheet', String.valueOf(timesheet));
            Record.PdfRenderTimesheet__c = timesheet;
        }
        return invoicePdfPage;
    }

    /** @Description
    *   Saves a Blob (presumably a PDF file) to the Salesforce CRM Content and creates a link
    *   for the content with this invoice. Subsequent calls to this method do not create new
    *   content files but only update the existing with a new version (based on title)
    *
    *   @param  fileToSave  File that will be saved as attachment
    */
    public ContentVersion saveToContentAttachments(PageReference pageRefToConvert) {
        ContentVersion newVersion = getNewContentVersion(pageRefToConvert);
        insert newVersion;
        newVersion = [SELECT Id,ContentDocumentId,IsLatest,Title,FileExtension,VersionNumber,ReasonForChange FROM ContentVersion WHERE Id = :newVersion.Id];
        Database.SaveResult linkSr = Database.insert(new ContentDocumentLink(LinkedEntityId=Record.Id, ContentDocumentId=PdfDocument.Id, ShareType='V'), false);
        return newVersion;
    }

    /**                                 PRIVATE AREA                                 */

    private ContentVersion getNewContentVersion(PageReference pageRefToConvert) {
        Blob convertedPdf = Test.isRunningTest() ? Blob.valueOf(String.valueOf(pageRefToConvert)) : pageRefToConvert.getContentAsPdf();
        ContentVersion ver = new ContentVersion(
            Title=PdfTitle,
            PathOnClient=PdfTitle+'.pdf',
            VersionData=convertedPdf,
            ReasonForChange=getReasonForChangeFromPageParameters(pageRefToConvert)
        );
        if (PdfDocument != null) ver.ContentDocumentId = PdfDocument.Id;
        return ver;
    }

    private String getReasonForChangeFromPageParameters(PageReference pageRefToConvert) {
        List<String> params = new List<String>();
        for (String param : pageRefToConvert.getParameters().keySet()) {
            if (PdfRenderProperties.containsKey(param) && PdfRenderProperties.get(param).Visible) {
                params.add(PdfRenderProperties.get(param).DisplayName + '=' + pageRefToConvert.getParameters().get(param));
            } 
        }
        return 'Rendered new PDF Version with: ' + String.join(params, ',');
    }

    public class RenderProperty {

        String DisplayName;
        Boolean Visible;

        public RenderProperty(String name, Boolean isVis) {
            DisplayName = name;
            Visible = isVis;
        }
    }

}
