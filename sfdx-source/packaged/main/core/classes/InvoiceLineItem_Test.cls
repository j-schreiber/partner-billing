@isTest
public class InvoiceLineItem_Test {

    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));
        insert i;
    }
    
    @isTest
    static void init_NonCommitedRecord_AllDefaultsInitialized() {
        // SETUP
        InvoiceLineItem__c ili = TestDataFactory.CreateDefaultInvoiceLineItem();
        // ACTION
        InvoiceLineItem objUnderTest = new InvoiceLineItem(ili);
        // VERIFY
        System.assertEquals(ili, objUnderTest.Record, 'Record');
        System.assertEquals(null, objUnderTest.Invoice, 'Invoice');
    }

    @isTest
    static void setInvoice_InvoiceCommited_LookupAndReferenceSet() {
        // SETUP
        Invoice__c i = [SELECT Id FROM Invoice__c LIMIT 1];
        Invoice inv = new Invoice(i.Id);
        InvoiceLineItem__c ili = TestDataFactory.CreateDefaultInvoiceLineItem();

        // ACTION
        InvoiceLineItem objUnderTest = new InvoiceLineItem(ili);
        objUnderTest.setInvoice(inv);

        // VERIFY
        System.assertEquals(inv, objUnderTest.Invoice, 'Invoice');
        System.assertEquals(i.Id, objUnderTest.Record.Invoice__c, 'Record.Invoice__c');
    }

    @isTest
    static void setInvoice_InvoiceNotCommited_OnlyReferenceSet() {
        // SETUP
        Invoice inv = new Invoice();
        InvoiceLineItem__c ili = TestDataFactory.CreateDefaultInvoiceLineItem();

        // ACTION
        InvoiceLineItem objUnderTest = new InvoiceLineItem(ili);
        objUnderTest.setInvoice(inv);

        // VERIFY
        System.assertEquals(inv, objUnderTest.Invoice, 'Invoice');
        System.assertEquals(null, objUnderTest.Record.Invoice__c, 'Record.Invoice__c');
    }

    @isTest
    static void updateRecord_ReadWriteFields_FieldsUpdated() {
        // SETUP
        InvoiceLineItem__c ili = TestDataFactory.CreateDefaultInvoiceLineItem();
        InvoiceLineItem objUnderTest = new InvoiceLineItem(ili);

        // ACTION
        objUnderTest.updateRecord(new InvoiceLineItem__c(Price__c = 0.00));

        // VERIFY
        System.assertEquals(0.00, objUnderTest.Record.Price__c, 'Record.Price__c');
        System.assertEquals(ili.Quantity__c, objUnderTest.Record.Quantity__c, 'Record.Quantity__c');
        System.assertEquals(ili.Description__c, objUnderTest.Record.Description__c, 'Record.Description__c');
    }
}
