@isTest
class BillingController_Test {

    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Integer i = 0; i < 5; i++) {
            invoices.add(TestDataFactory.CreateInvoice(new Invoice__c(Status__c = 'Draft', Account__c = a.Id)));
            invoices.add(TestDataFactory.CreateInvoice(new Invoice__c(Status__c = 'Activated', Account__c = a.Id)));
        }
        insert invoices;
    }

    @isTest
    static void getInvoices_StatusActivated_AllActivatedInvoices() {
        // ACTION
        List<Invoice> actualInvoices = BillingController.getInvoices('Activated');
        // VERIFY
        System.assertEquals([SELECT COUNT() FROM Invoice__c WHERE Status__c = 'Activated'], actualInvoices.size(), 'size()');
        for (Invoice inv : actualInvoices) System.assertEquals('Activated', inv.Record.Status__c);
    }

    @isTest
    static void getInvoices_StatusDraft_AllDraftInvoices() {
        // ACTION
        List<Invoice> actualInvoices = BillingController.getInvoices('Draft');
        // VERIFY
        System.assertEquals([SELECT COUNT() FROM Invoice__c WHERE Status__c = 'Draft'], actualInvoices.size(), 'size()');
        for (Invoice inv : actualInvoices) System.assertEquals('Draft', inv.Record.Status__c);
    }

    @isTest
    static void getInvoices_InvalidStatus_EmptyList() {
        // ACTION
        List<Invoice> actualInvoices = BillingController.getInvoices('Yolo');
        // VERIFY
        System.assertEquals(0, actualInvoices.size(), 'size()');
    }
}
