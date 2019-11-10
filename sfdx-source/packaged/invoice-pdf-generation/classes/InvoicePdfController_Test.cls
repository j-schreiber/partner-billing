@isTest
public class InvoicePdfController_Test {

    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        Invoice__c defaultInvoice = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));
        insert defaultInvoice;

        insert TestDataFactory.CreateDefaultOrganizationProfile();
    }

    @isTest
    static void savePdfToInvoice_MinimalInput_AttachmentAdded() {
        // SETUP
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        OrganizationProfile__c orgProfile = [SELECT Id FROM OrganizationProfile__c LIMIT 1];

        // ACTION
        InvoicePdfController.savePdfToInvoice(record.Id, orgProfile.Id, '', null);

        // VERIFY
        System.assertEquals(0, [SELECT COUNT() FROM Attachment WHERE ParentId = :record.Id], 'COUNT() FROM Attachment');
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :record.Id], 'COUNT() FROM ContentDocumentLink');
    }

    @isTest
    static void getOrganizationProfiles_AllOrgProfilesReturned() {
        // SETUP
        List<OrganizationProfile__c> ops = new List<OrganizationProfile__c>();
        for (Integer i = 0; i < 5; i++) {
            ops.add(TestDataFactory.CreateOrganizationProfile(new OrganizationProfile__c(Name = 'Test Profile ' + i, IsDefault__c = false)));
        }
        insert ops;

        // ACTION
        List<OrganizationProfile__c> actualOps = InvoicePdfController.getOrganizationProfiles();

        // VERIFY
        System.assertEquals([SELECT COUNT() FROM OrganizationProfile__c], actualOps.size(), 'actualOps.size()');
        OrganizationProfile__c defaultProfile = [SELECT Id FROM OrganizationProfile__c WHERE IsDefault__c = true LIMIT 1];
        System.assertEquals(defaultProfile.Id, actualOps[0].Id, 'actualOps[0].Id');
    }
}
