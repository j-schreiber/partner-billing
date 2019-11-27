@isTest
public class InvoicePrint_Test {

    @TestSetup
    static void makeData(){
        insert TestDataFactory.CreateDefaultOrganizationProfile();

        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        Invoice__c defaultInvoice = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));
        insert defaultInvoice;

        List<InvoiceLineItem__c> ilis = new List<InvoiceLineItem__c>();
        for (Integer i = 0; i < 10; i++) {
            ilis.add(TestDataFactory.CreateInvoiceLineItem(
                new InvoiceLineItem__c(Invoice__c = defaultInvoice.Id))
            );
        }
        insert ilis;
    }

    @isTest
    static void createPdf_NoParams_MinimalPageReference() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);

        // ACTION
        PageReference invoicePdfPage = invObj.createPdf();

        // VERIFY
        System.assertEquals(record.Id, invoicePdfPage.getParameters().get('Id'), 'getParameters().get(Id)');
    }

    @isTest
    static void createPdf_OrgProfile_AllParamsInPageReference() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        OrganizationProfile__c orgProfile = [SELECT Id FROM OrganizationProfile__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);

        // ACTION
        PageReference invoicePdfPage = invObj.createPdf(orgProfile.Id);

        // VERIFY
        System.assertEquals(record.Id, invoicePdfPage.getParameters().get('Id'), 'getParameters().get(Id)');
        System.assertEquals(orgProfile.Id, invoicePdfPage.getParameters().get('orgProfileId'), 'getParameters().get(orgProfileId)');
    }

    @isTest
    static void createPdf_OrgProfile_Language_AllParamsInPageReference() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        OrganizationProfile__c orgProfile = [SELECT Id FROM OrganizationProfile__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);

        // ACTION
        PageReference invoicePdfPage = invObj.createPdf(orgProfile.Id, 'de_DE');

        // VERIFY
        System.assertEquals(record.Id, invoicePdfPage.getParameters().get('Id'), 'getParameters().get(Id)');
        System.assertEquals(orgProfile.Id, invoicePdfPage.getParameters().get('orgProfileId'), 'getParameters().get(orgProfileId)');
        System.assertEquals('de_DE', invoicePdfPage.getParameters().get('lang'), 'getParameters().get(de_DE)');
        System.assertEquals('de_DE', invObj.Record.PdfLanguage__c, 'Invoice.Record.PdfLanguage__c');
    }

    @isTest
    static void createPdf_OrgProfile_Language_TimesheetTrue_AllParamsInPageReference() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        OrganizationProfile__c orgProfile = [SELECT Id FROM OrganizationProfile__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);

        // ACTION
        PageReference invoicePdfPage = invObj.createPdf(orgProfile.Id, 'de_DE', true);

        // VERIFY
        System.assertEquals(record.Id, invoicePdfPage.getParameters().get('Id'), 'getParameters().get(Id)');
        System.assertEquals(orgProfile.Id, invoicePdfPage.getParameters().get('orgProfileId'), 'getParameters().get(orgProfileId)');
        System.assertEquals('true', invoicePdfPage.getParameters().get('displayTimesheet'), 'getParameters().get(displayTimesheet)');
        System.assertEquals('de_DE', invoicePdfPage.getParameters().get('lang'), 'getParameters().get(de_DE)');
        System.assertEquals('de_DE', invObj.Record.PdfLanguage__c, 'Invoice.Record.PdfLanguage__c');
    }

    @isTest
    static void createPdf_OrgProfileBlank_Language_TimesheetTrue_OnlyNonEmptyParamsInPageReference() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);

        // ACTION
        PageReference invoicePdfPage = invObj.createPdf(null, 'de_DE', true);

        // VERIFY
        System.assertEquals(record.Id, invoicePdfPage.getParameters().get('Id'), 'getParameters().get(Id)');
        System.assertEquals('true', invoicePdfPage.getParameters().get('displayTimesheet'), 'getParameters().get(displayTimesheet)');
        System.assertEquals('de_DE', invoicePdfPage.getParameters().get('lang'), 'getParameters().get(de_DE)');
        System.assertEquals('de_DE', invObj.Record.PdfLanguage__c, 'Invoice.Record.PdfLanguage__c');

        // ACTION
        invoicePdfPage = invObj.createPdf('', 'de_DE', true);

        // VERIFY
        System.assertEquals(record.Id, invoicePdfPage.getParameters().get('Id'), 'getParameters().get(Id)');
        System.assertEquals('true', invoicePdfPage.getParameters().get('displayTimesheet'), 'getParameters().get(displayTimesheet)');
        System.assertEquals('de_DE', invoicePdfPage.getParameters().get('lang'), 'getParameters().get(de_DE)');
        System.assertEquals('de_DE', invObj.Record.PdfLanguage__c, 'Invoice.Record.PdfLanguage__c');
    }

    @isTest
    static void getPdfTitle_DefaultInput_FullName() {
        // SETUP
        Invoice__c record = [SELECT Id,Name,Account__r.Name,PdfLanguage__c FROM Invoice__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);
        // ACTION
        String pdfTitle = invObj.PdfTitle;
        // VERIFY
        System.assert(pdfTitle.contains(record.Name), 'contains(record.Name)');
        System.assert(pdfTitle.contains(record.PdfLanguage__c), 'contains(record.PdfLanguage__c)');
        System.assert(pdfTitle.contains(record.Account__r.Name), 'contains(record.Account__r.Name)');
    }

    @isTest
    static void getPdfTitle_DraftInvoice_HasDraftInTitle() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_DRAFT));
        insert i;
        InvoicePrint objUnderTest = new InvoicePrint(i.Id);

        // VERIFY
        System.assert(objUnderTest.PdfTitle.startsWith(Label.InvoicePdf_Watermark_Draft), 'startsWith(DRAFT): ' + objUnderTest.PdfTitle);
    }

    @isTest
    static void getPdfTitle_ActivatedInvoice_NoDraftInTitle() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_ACTIVATED));
        insert i;
        InvoicePrint objUnderTest = new InvoicePrint(i.Id);

        // VERIFY
        System.assertEquals(false, objUnderTest.PdfTitle.contains(Label.InvoicePdf_Watermark_Draft), 'contains(DRAFT): ' + objUnderTest.PdfTitle);
    }

    @isTest
    static void getFormattedTotalTaxes_DefaultInput_FormatterPopulated() {
        // SETUP
        Invoice__c record = [SELECT Id,Name,Account__r.Name,PdfLanguage__c FROM Invoice__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);
        // VERIFY
        System.assertEquals(invObj.TotalTaxes, invObj.TotalTaxesFormatted.Currency__c, 'TotalTaxesFormatted.Currency__c');
    }

    @isTest
    static void getDisplayTimesheet_HasTimeEntries_True() {
        // SETUP
        Invoice__c record = [SELECT Id,Account__c FROM Invoice__c LIMIT 1];

        List<TimeEntry__c> tes = new List<TimeEntry__c>();
        for (Integer i = 0; i < 10; i++) {
            tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Invoice__c = record.Id, Account__c = record.Account__c)));
        }
        insert tes;

        // ACTION
        InvoicePrint objUnderTest = new InvoicePrint(record.Id);

        // VERIFY
        objUnderTest.Record.PdfRenderTimesheet__c = true;
        System.assertEquals(true, objUnderTest.DisplayTimesheet, 'RenderTimesheet = true; DisplayTimesheet');
        objUnderTest.Record.PdfRenderTimesheet__c = false;
        System.assertEquals(false, objUnderTest.DisplayTimesheet, 'RenderTimesheet = false; DisplayTimesheet');
    }

    @isTest
    static void getDisplayTimesheet_NoTimeEntries_False() {
        // SETUP
        Invoice__c record = [SELECT Id,Account__c FROM Invoice__c LIMIT 1];

        // ACTION
        InvoicePrint objUnderTest = new InvoicePrint(record.Id);

        // VERIFY
        objUnderTest.Record.PdfRenderTimesheet__c = true;
        System.assertEquals(false, objUnderTest.DisplayTimesheet, 'RenderTimesheet = true; DisplayTimesheet');
        objUnderTest.Record.PdfRenderTimesheet__c = false;
        System.assertEquals(false, objUnderTest.DisplayTimesheet, 'RenderTimesheet = false; DisplayTimesheet');
    }

    @isTest
    static void saveToContentAttachments_NoVersionExist_ContentCreatedAndLinked() {
        // SETUP
        Invoice__c record = [SELECT Id,Name,PdfLanguage__c FROM Invoice__c LIMIT 1];
        InvoicePrint objUnderTest = new InvoicePrint(record.Id);

        // ACTION
        ContentVersion createdVersion = objUnderTest.saveToContentAttachments(Page.InvoicePdf);

        // VERIFY
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocument], 'COUNT() FROM ContentDocument');
        ContentDocument createdContentDoc = [SELECT Id,Description,FileType,Title FROM ContentDocument LIMIT 1];
        System.assertEquals(objUnderTest.PdfTitle, createdContentDoc.Title, 'createdContentDoc.Title');
        System.assertEquals('PDF', createdContentDoc.FileType, 'createdContentDoc.FileType');

        System.assertEquals(1, [SELECT COUNT() FROM ContentVersion WHERE ContentDocumentId = :createdContentDoc.Id], 'COUNT() FROM ContentVersion');
        System.assertEquals(objUnderTest.PdfTitle, createdVersion.Title, 'Version.Title');
        System.assertEquals(true, createdVersion.IsLatest, 'Version.IsLatest');
        System.assertEquals('1', createdVersion.VersionNumber, 'Version.VersionNumber');

        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :record.Id], 'COUNT() FROM ContentDocumentLink');
        ContentDocumentLink createdLink = [SELECT Id,ContentDocumentId,ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :record.Id];
        System.assertEquals('V', createdLink.ShareType, 'Link.ShareType');
        System.assertEquals(createdContentDoc.Id, createdLink.ContentDocumentId, 'Link.ContentDocumentId');
    }

    @isTest
    static void saveToContentAttachments_VersionExist_NewVersionCreatedAndLinked() {
        // SETUP
        Invoice__c record = [SELECT Id,Name,PdfLanguage__c FROM Invoice__c LIMIT 1];
        InvoicePrint objUnderTest = new InvoicePrint(record.Id);
        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion existingVersion = new ContentVersion(Title=objUnderTest.PdfTitle,PathOnClient=objUnderTest.PdfTitle+'.pdf', VersionData=pdfMock);
        insert existingVersion;

        // ACTION
        ContentVersion createdVersion = objUnderTest.saveToContentAttachments(Page.InvoicePdf);

        // VERIFY
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocument], 'COUNT() FROM ContentDocument');
        ContentDocument createdContentDoc = [SELECT Id,Description,FileType,Title FROM ContentDocument LIMIT 1];
        System.assertEquals(objUnderTest.PdfTitle, createdContentDoc.Title, 'createdContentDoc.Title');
        System.assertEquals('PDF', createdContentDoc.FileType, 'createdContentDoc.FileType');

        System.assertEquals(2, [SELECT COUNT() FROM ContentVersion WHERE ContentDocumentId = :createdContentDoc.Id], 'COUNT() FROM ContentVersion');
        System.assertEquals(objUnderTest.PdfTitle, createdVersion.Title, 'Version.Title');
        System.assertEquals(true, createdVersion.IsLatest, 'Version.IsLatest');
        System.assertEquals('2', createdVersion.VersionNumber, 'Version.VersionNumber');

        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :record.Id], 'COUNT() FROM ContentDocumentLink');
        ContentDocumentLink createdLink = [SELECT Id,ContentDocumentId,ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :record.Id];
        System.assertEquals('V', createdLink.ShareType, 'Link.ShareType');
        System.assertEquals(createdContentDoc.Id, createdLink.ContentDocumentId, 'Link.ContentDocumentId');
    }

    @isTest
    static void saveToContentAttachments_LinkExists_OnlyNewVersionCreated() {
        // SETUP
        Invoice__c record = [SELECT Id,Name,PdfLanguage__c FROM Invoice__c LIMIT 1];
        InvoicePrint objUnderTest = new InvoicePrint(record.Id);
        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion existingVersion = new ContentVersion(Title=objUnderTest.PdfTitle,PathOnClient=objUnderTest.PdfTitle+'.pdf', VersionData=pdfMock);
        insert existingVersion;
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Title = :objUnderTest.PdfTitle LIMIT 1];
        insert new ContentDocumentLink(LinkedEntityId=Record.Id, ContentDocumentId=contentDoc.Id, ShareType='V');

        // ACTION
        ContentVersion createdVersion = objUnderTest.saveToContentAttachments(Page.InvoicePdf);

        // VERIFY
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :record.Id], 'COUNT() FROM ContentDocumentLink');
        ContentDocumentLink createdLink = [SELECT Id,ContentDocumentId,ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :record.Id];
        System.assertEquals('V', createdLink.ShareType, 'Link.ShareType');
        System.assertEquals(contentDoc.Id, createdLink.ContentDocumentId, 'Link.ContentDocumentId');
    }

    @isTest
    static void saveToContentAttachments_WithPageParameter_PdfCreateParamsInReasonForChange() {
        // SETUP
        Invoice__c record = [SELECT Id,Name,PdfLanguage__c FROM Invoice__c LIMIT 1];
        InvoicePrint objUnderTest = new InvoicePrint(record.Id);

        PageReference invoicePdfPage = Page.InvoicePdf;
        invoicePdfPage.getParameters().put('Id', Record.Id);
        invoicePdfPage.getParameters().put('orgProfileId', 'testId');
        invoicePdfPage.getParameters().put('lang', 'de_DE');
        invoicePdfPage.getParameters().put('displayTimesheet', 'true');

        // ACTION
        ContentVersion createdVersion = objUnderTest.saveToContentAttachments(invoicePdfPage);

        // VERIFY
        System.assertEquals(true, createdVersion.ReasonForChange.contains('Language=de_DE'), 'contains(Language=de_DE)');
        System.assertEquals(true, createdVersion.ReasonForChange.contains('Organization Profile Id=testId'), 'contains(Organization Profile=testId)');
        System.assertEquals(true, createdVersion.ReasonForChange.contains('Display Timesheet=true'), 'contains(Display Timesheet=true)');
    }

}
