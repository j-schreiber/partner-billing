@isTest
public class InvoiceTriggerHandlerPdf_Test {

    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateAccount(
            new Account(BillingStreet = 'Teststraße 1', BillingPostalCode = '80336', BillingCity = 'München', BillingCountryCode = 'DE')
        );
        insert a;

        List<OrganizationProfile__c> orgProfiles = new List<OrganizationProfile__c>();
        orgProfiles.add(TestDataFactory.CreateDefaultOrganizationProfile());
        orgProfiles.add(TestDataFactory.CreateOrganizationProfile(new OrganizationProfile__c(IsDefault__c = false, Name = 'Test Profile #1')));
        orgProfiles.add(TestDataFactory.CreateOrganizationProfile(new OrganizationProfile__c(IsDefault__c = false, Name = 'Test Profile #2')));
        insert orgProfiles;
    }
    
    @isTest
    static void update_ModifyLockedField_PdfSettingDelete_DocumentsDeleted() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];

        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, PDFSyncSetting__c = Constants.INVOICE_PDF_SETTING_DELETE));
        insert inv;

        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion existingVersion = new ContentVersion(Title='Test',PathOnClient='Test.pdf', VersionData=pdfMock);
        insert existingVersion;

        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Title = 'Test' LIMIT 1];
        insert new ContentDocumentLink(LinkedEntityId=inv.Id, ContentDocumentId=contentDoc.Id, ShareType='V');

        // ACTION
        inv.Date__c = System.today();
        inv.BillingCountry__c = 'England';
        Database.SaveResult sr = Database.update(inv, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocument], 'COUNT() FROM ContentDocument');
    }

    @isTest
    static void update_ModifySettingToDeactivated_PdfSettingDelete_DocumentsPersist() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];

        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, PDFSyncSetting__c = Constants.INVOICE_PDF_SETTING_DELETE));
        insert inv;

        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion existingVersion = new ContentVersion(Title='Test',PathOnClient='Test.pdf', VersionData=pdfMock);
        insert existingVersion;

        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Title = 'Test' LIMIT 1];
        insert new ContentDocumentLink(LinkedEntityId=inv.Id, ContentDocumentId=contentDoc.Id, ShareType='V');

        // ACTION
        inv.PDFSyncSetting__c = Constants.INVOICE_PDF_SETTING_DEACTIVATED;
        Database.SaveResult sr = Database.update(inv, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocument], 'COUNT() FROM ContentDocument');
    }

    @isTest
    static void update_ModifyLockedField_PdfSettingDeactivated_DocumentsPersist() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];

        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, PDFSyncSetting__c = Constants.INVOICE_PDF_SETTING_DEACTIVATED));
        insert inv;

        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion existingVersion = new ContentVersion(Title='Test',PathOnClient='Test.pdf', VersionData=pdfMock);
        insert existingVersion;

        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Title = 'Test' LIMIT 1];
        insert new ContentDocumentLink(LinkedEntityId=inv.Id, ContentDocumentId=contentDoc.Id, ShareType='V');

        // ACTION
        inv.Date__c = System.today();
        inv.BillingCountry__c = 'England';
        Database.SaveResult sr = Database.update(inv, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocument], 'COUNT() FROM ContentDocument');
    }

    @isTest
    static void update_PdfSettingIsSync_UpdateTrackedField_NewDocumentVersionRendered() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];

        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, PDFSyncSetting__c = Constants.INVOICE_PDF_SETTING_SYNC));
        insert inv;

        // ACTION
        Test.startTest();
        inv.Date__c = System.today();
        inv.BillingCountry__c = 'England';
        Database.SaveResult sr = Database.update(inv, false);
        Test.stopTest();

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocument], 'COUNT() FROM ContentDocument');
    }

    @isTest
    static void update_PdfSettingIsSync_TooManyRecords_DMLError() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];

        List<Invoice__c> invs = new List<Invoice__c>();
        for (Integer i = 0; i<11; i++) {
            invs.add(TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, PDFSyncSetting__c = Constants.INVOICE_PDF_SETTING_SYNC)));
        }
        insert invs;
        
        // ACTION
        Test.startTest();
        for (Invoice__c inv : invs) {
            inv.Date__c = System.today();
            inv.BillingCountry__c = 'England';
        }
        Database.SaveResult[] srs = Database.update(invs, false);
        Test.stopTest();

        // VERIFY
        for (Integer i = 0; i<10; i++) System.assertEquals(true, srs[i].isSuccess(), srs[i].getErrors());
        System.assertEquals(false, srs[10].isSuccess(), 'srs[10].isSuccess()');
        System.assertEquals(System.Label.Message_InvoiceValidation_SyncUpdateLimit, srs[10].getErrors()[0].getMessage(), 'srs[10].getErrors()[0].getMessage()');
    }
}
