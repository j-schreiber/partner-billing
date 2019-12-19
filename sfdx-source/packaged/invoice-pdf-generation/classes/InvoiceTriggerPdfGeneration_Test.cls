@isTest
public class InvoiceTriggerPdfGeneration_Test {

    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateAccount(
            new Account(BillingStreet = 'Teststraße 1', BillingPostalCode = '80336', BillingCity = 'München', BillingCountryCode = 'DE')
        );
        insert a;

        BankAccount__c ba = TestDataFactory.CreateDefaultBankAccount();
        insert ba;

        OrganizationProfile__c op = TestDataFactory.CreateOrganizationProfile(new OrganizationProfile__c(BankAccount__c = ba.Id));
        insert op;
    }
    
    @isTest
    static void enqueue_SingleInvoiceId_NewPdfDocumentRendered() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        OrganizationProfile__c op = [SELECT Id FROM OrganizationProfile__c LIMIT 1];
        Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, OrganizationProfile__c = op.Id));
        insert i;

        // ACTION
        InvoiceTriggerPdfGeneration job = new InvoiceTriggerPdfGeneration(new Set<Id>{i.Id});
        job.execute(null);

        // VERIFY
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :i.Id], 'COUNT() FROM ContentDocumentLink');
    }

    @isTest
    static void enqueue_BatchInvoiceIds_NewPdfDocumentsRendered() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        OrganizationProfile__c op = [SELECT Id FROM OrganizationProfile__c LIMIT 1];
        List<Invoice__c> invs = new List<Invoice__c>();
        for (Integer i = 0; i < 10; i++) {
            invs.add(TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, OrganizationProfile__c = op.Id)));
        }
        insert invs;

        Set<Id> invIds = new Set<Id>();
        for (Invoice__c inv : invs) invIds.add(inv.Id);

        // ACTION
        InvoiceTriggerPdfGeneration job = new InvoiceTriggerPdfGeneration(invIds);
        job.execute(null);

        // VERIFY
        System.assertEquals(invs.size(), [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId IN :invIds], 'COUNT() FROM ContentDocumentLink');
    }

    @isTest
    static void enqueue_BatchInvoiceIdsWithContentDocuments_NewPdfDocumentVersionsRendered() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        OrganizationProfile__c op = [SELECT Id FROM OrganizationProfile__c LIMIT 1];
        List<Invoice__c> invs = new List<Invoice__c>();
        for (Integer i = 0; i < 10; i++) {
            invs.add(TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, OrganizationProfile__c = op.Id)));
        }
        insert invs;

        Set<Id> invIds = new Set<Id>();
        for (Invoice__c inv : invs) invIds.add(inv.Id);

        // ACTION
        InvoiceTriggerPdfGeneration job = new InvoiceTriggerPdfGeneration(invIds);
        job.execute(null);
        job.execute(null);

        // VERIFY
        System.assertEquals(invs.size() * 2, [SELECT COUNT() FROM ContentVersion], 'COUNT() FROM ContentVersion');
    }
    
}
