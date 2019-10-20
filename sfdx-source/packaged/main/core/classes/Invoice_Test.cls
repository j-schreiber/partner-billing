@isTest
public class Invoice_Test {

    @TestSetup
    static void makeData(){
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
    static void init_WithLineItems_AllDefaultsInitialized() {

    }

    @isTest
    static void init_WithoutLineItems_AllDefaultsInitialized() {
        
    }

    @isTest
    static void createPdf_WithLineItems_PdfBlobCreated() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        Invoice invObj = new Invoice(record.Id);
        // VERIFY
        System.assertNotEquals(null, invObj.createPdf(), 'createPdf()');
    }

    @isTest
    static void saveFileAsAttachment_ValidPdf_AttachmentAdded() {
        // SETUP
        Invoice__c record = [SELECT Id,Name FROM Invoice__c LIMIT 1];
        Invoice invObj = new Invoice(record.Id);
        // ACTION
        Blob pdfMock = Blob.valueOf('Teststring');
        invObj.addFileToAttachments(pdfMock);
        // VERIFY
        System.assertEquals(1, invObj.Attachments.size(), 'invObj.Attachments.size()');
        System.assertEquals(pdfMock, invObj.Attachments[0].Body, 'invObj.Attachments[0].Body');
        System.assertEquals(true, invObj.Attachments[0].Name.contains(record.Name), 'contains(record.Name)');
    }

    @isTest
    static void commitAllChanges_HasAttachment_AttachmentSaved() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        Invoice invObj = new Invoice(record.Id);
        // ACTION
        Blob pdfMock = Blob.valueOf('Teststring');
        invObj.addFileToAttachments(pdfMock);
        invObj.commitAllChanges();
        // VERIFY
        System.assertEquals(1, invObj.Attachments.size(), 'invObj.Attachments.size()');
        System.assertEquals(1, [SELECT COUNT() FROM Attachment WHERE ParentId = :record.Id], 'COUNT()');
    }

    /**                             GETTER & SETTER
    *   - calculated taxes based on invoice net/gross
    *
    *
    */
    
    @isTest
    static void getTaxes_MixedPercentagesInLineItems_CorrectlyCalculated() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c defaultInvoice = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));
        insert defaultInvoice;

        List<InvoiceLineItem__c> ilis = new List<InvoiceLineItem__c>();
        ilis.add(TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c = defaultInvoice.Id, Tax__c=10, Price__c=750, Quantity__c=1)));
        ilis.add(TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c = defaultInvoice.Id, Tax__c=20, Price__c=750, Quantity__c=1)));
        ilis.add(TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c = defaultInvoice.Id, Tax__c=19, Price__c=1250, Quantity__c=3)));
        insert ilis;

        // ACTION
        Invoice invObj = new Invoice(defaultInvoice.Id);

        // VERIFY
        System.assertEquals(5250, invObj.Record.TotalAmount__c, 'Record.Amount__c');
        System.assertEquals(6187.50, invObj.Record.TotalGrossAmount__c, 'Record.GrossAmount__c');
        System.assertEquals(937.50, invObj.TotalTaxes, 'TotalTaxes');
        System.assertEquals(0.1786, invObj.TotalTaxesPercentage, 'TotalTaxesPercentage');
    }
}
