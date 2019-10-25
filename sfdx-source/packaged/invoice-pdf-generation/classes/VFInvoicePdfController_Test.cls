@isTest
public class VFInvoicePdfController_Test {

    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        Invoice__c defaultInvoice = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));
        insert defaultInvoice;

        insert TestDataFactory.CreateDefaultOrganizationProfile();
    }
    
    @isTest
    static void getInvoice_NullId_EmptyInvoice() {
        // SETUP
        Test.setCurrentPage(Page.InvoicePdf);
        // VERIFY
        System.assertNotEquals(null, new VFInvoicePdfController().Invoice, 'Invoice');
        System.assertEquals(new Invoice__c(), new VFInvoicePdfController().Invoice.Record, 'Invoice.Record');
    }

    @isTest
    static void getInvoice_EmptyId_EmptyInvoice() {
        // SETUP
        Test.setCurrentPage(Page.InvoicePdf);
        ApexPages.currentPage().getParameters().put('Id', '');
        // VERIFY
        System.assertNotEquals(null, new VFInvoicePdfController().Invoice, 'Invoice');
        System.assertEquals(new Invoice__c(), new VFInvoicePdfController().Invoice.Record, 'Invoice.Record');
    }

    @isTest
    static void getInvoice_ValidId_EmptyInvoice() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        Test.setCurrentPage(Page.InvoicePdf);
        ApexPages.currentPage().getParameters().put('Id', record.Id);

        // VERIFY
        System.assertEquals(record.Id, new VFInvoicePdfController().Invoice.Record.Id, 'Invoice.Record.Id');
    }

    @isTest
    static void getRenderAs_ValueFromPageParam() {
        // SETUP
        Test.setCurrentPage(Page.InvoicePdf);
        ApexPages.currentPage().getParameters().put('renderAs', 'pdf');
        // VERIFY
        System.assertEquals('pdf', new VFInvoicePdfController().renderAs, 'renderAs');
    }

    @isTest
    static void getBankAccount_NoBankAccount_EmptyBankAccount() {
        // VERIFY
        System.assertEquals(new BankAccount__c(), new VFInvoicePdfController().BankAccount, 'BankAccount');
    }

    @isTest
    static void getBankAccount_HasDefaultBankAccount_DefaultBankAccount() {
        // SETUP
        BankAccount__c defaultBA = TestDataFactory.CreateBankAccount(new BankAccount__c(IsDefault__c = true));
        BankAccount__c otherBA = TestDataFactory.CreateBankAccount(new BankAccount__c(IsDefault__c = false, IBAN__c = 'DE000000000000000'));
        insert new List<BankAccount__c>{defaultBA, otherBA};
        // VERIFY
        System.assertEquals(defaultBA.Id, new VFInvoicePdfController().BankAccount.Id, 'BankAccount.Id');
        System.assertEquals(defaultBA.BankAccountOwner__c, new VFInvoicePdfController().BankAccount.BankAccountOwner__c, 'BankAccount.BankAccountOwner__c');
        System.assertEquals(defaultBA.BankName__c, new VFInvoicePdfController().BankAccount.BankName__c, 'BankAccount.BankName__c');
        System.assertEquals(defaultBA.IBAN__c, new VFInvoicePdfController().BankAccount.IBAN__c, 'BankAccount.IBAN__c');
    }

    @isTest
    static void getLanguage_NoParam_ValueFromInvoiceReturned() {
        // SETUP
        Invoice__c record = [SELECT Id,PdfLanguage__c FROM Invoice__c LIMIT 1];
        record.PdfLanguage__c = 'en_DE';
        update record;
        Test.setCurrentPage(Page.InvoicePdf);
        ApexPages.currentPage().getParameters().put('Id', record.Id);
        
        // VERIFY
        System.assertEquals('en_DE', new VFInvoicePdfController().Language, 'Language');
    }

    @isTest
    static void getOrgProfile_NoParam_NoDefaultProfileExists_EmptyProfileGenerated() {
        // SETUP
        delete [SELECT Id FROM OrganizationProfile__c];
        Test.setCurrentPage(Page.InvoicePdf);

        // ACTION
        OrganizationProfile__c op = new VFInvoicePdfController().OrgProfile;

        // VERIFY
        System.assertEquals(new OrganizationProfile__c(), op, 'OrgProfile');
    }

    @isTest
    static void getOrgProfile_NoParam_DefaultProfileExists_DefaultProfileReturned() {
        // SETUP
        Test.setCurrentPage(Page.InvoicePdf);
        // ACTION
        OrganizationProfile__c op = new VFInvoicePdfController().OrgProfile;
        // VERIFY
        OrganizationProfile__c expectedProfile = [SELECT Id FROM OrganizationProfile__c LIMIT 1];
        System.assertEquals(expectedProfile.Id, op.Id, 'OrgProfile');
    }

    @isTest
    static void getOrgProfile_InvalidParam_DefaultProfileExists_DefaultProfileReturned() {
        // SETUP
        Test.setCurrentPage(Page.InvoicePdf);
        ApexPages.currentPage().getParameters().put('orgProfileId', 'test-id');
        // ACTION
        OrganizationProfile__c op = new VFInvoicePdfController().OrgProfile;
        // VERIFY
        OrganizationProfile__c expectedProfile = [SELECT Id FROM OrganizationProfile__c LIMIT 1];
        System.assertEquals(expectedProfile.Id, op.Id, 'OrgProfile');
    }

    @isTest
    static void getOrgProfile_ValidParam_DefaultProfileExists_RequestedProfileReturned() {
        // SETUP
        OrganizationProfile__c newProfile = TestDataFactory.CreateOrganizationProfile(
            new OrganizationProfile__c(IsDefault__c = false, OrganizationName__c = 'Other Company GmbH')
        );
        insert newProfile;

        Test.setCurrentPage(Page.InvoicePdf);
        ApexPages.currentPage().getParameters().put('orgProfileId', newProfile.Id);

        // ACTION
        OrganizationProfile__c op = new VFInvoicePdfController().OrgProfile;

        // VERIFY
        System.assertEquals(newProfile.Id, op.Id, 'OrgProfile');
    }
}
