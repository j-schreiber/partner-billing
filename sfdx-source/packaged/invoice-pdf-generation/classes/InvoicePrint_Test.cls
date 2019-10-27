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
    static void createPdf_WithLineItems_PdfBlobCreated() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);
        // VERIFY
        System.assertNotEquals(null, invObj.createPdf(), 'createPdf()');
    }

    @isTest
    static void createPdf_ValidOrgProfileId_WithLineItems_PdfBlobCreated() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        OrganizationProfile__c orgProfile = [SELECT Id FROM OrganizationProfile__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);
        // VERIFY
        System.assertNotEquals(null, invObj.createPdf(orgProfile.Id), 'createPdf(orgProfile.Id)');
    }

    @isTest
    static void createPdf_ValidOrgProfileId_Language_WithLineItems_AllParamsInPageReference() {
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
    static void getFormattedTotalTaxes_DefaultInput_FormatterPopulated() {
        // SETUP
        Invoice__c record = [SELECT Id,Name,Account__r.Name,PdfLanguage__c FROM Invoice__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);
        // VERIFY
        System.assertEquals(invObj.TotalTaxes, invObj.TotalTaxesFormatted.Currency__c, 'TotalTaxesFormatted.Currency__c');
    }

    @isTest
    static void saveFileAsAttachment_ValidPdf_AttachmentAdded() {
        // SETUP
        Invoice__c record = [SELECT Id,Name,PdfLanguage__c FROM Invoice__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);
        // ACTION
        Blob pdfMock = Blob.valueOf('Teststring');
        invObj.addFileToAttachments(pdfMock);
        // VERIFY
        System.assertEquals(1, invObj.Attachments.size(), 'invObj.Attachments.size()');
        System.assertEquals(pdfMock, invObj.Attachments[0].Body, 'invObj.Attachments[0].Body');
        System.assertEquals(true, invObj.Attachments[0].Name.contains(record.Name), 'contains(record.Name)');
        System.assertEquals(true, invObj.Attachments[0].Name.contains(record.PdfLanguage__c), 'contains(record.PdfLanguage__c)');
    }

    @isTest
    static void commitAllChanges_HasAttachment_AttachmentSaved() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        InvoicePrint invObj = new InvoicePrint(record.Id);
        // ACTION
        Blob pdfMock = Blob.valueOf('Teststring');
        invObj.addFileToAttachments(pdfMock);
        invObj.commitAllChanges();
        // VERIFY
        System.assertEquals(1, invObj.Attachments.size(), 'invObj.Attachments.size()');
        System.assertEquals(1, [SELECT COUNT() FROM Attachment WHERE ParentId = :record.Id], 'COUNT()');
    }

}
