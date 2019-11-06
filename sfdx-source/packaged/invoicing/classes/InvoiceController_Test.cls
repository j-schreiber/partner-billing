@isTest
public class InvoiceController_Test {

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
    static void getInvoice_ValidId_InitializedDecorator() {
        // SETUP
        Invoice__c inv = [SELECT Id FROM Invoice__c LIMIT 1];
        // ACTION
        Invoice actual = InvoiceController.getInvoice(inv.Id);
        // VERIFY
        System.assertEquals(inv.Id, actual.Record.Id, 'Record.Id');
    }

    @isTest
    static void commitInvoiceLineItems_OnlyInsert_AllLineItemsUpdated() {
        // SETUP
        Invoice__c inv = [SELECT Id FROM Invoice__c LIMIT 1];
        List<InvoiceLineItem__c> ilisToUpsert = new List<InvoiceLineItem__c>();
        ilisToUpsert.add(TestDataFactory.CreateDefaultInvoiceLineItem());

        // ACTION
        InvoiceController.commitInvoiceLineItems(inv.Id, ilisToUpsert, new List<Id>());

        // VERIFY
        System.assertEquals(1, [SELECT COUNT() FROM InvoiceLineItem__c WHERE Invoice__c = :inv.Id], 'COUNT() FROM InvoiceLineItem__c');
    }

    @isTest
    static void commitInvoiceLineItems_UpdateAndInsert_AllLineItemsUpserted() {
        // SETUP
        Invoice__c inv = [SELECT Id FROM Invoice__c LIMIT 1];
        List<InvoiceLineItem__c> ilisToUpsert = new List<InvoiceLineItem__c>();
        InvoiceLineItem__c toUpdate = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c = inv.Id));
        insert toUpdate;

        InvoiceLineItem__c toInsert = TestDataFactory.CreateDefaultInvoiceLineItem();

        ilisToUpsert.add(toUpdate);
        ilisToUpsert.add(toInsert);

        // ACTION
        InvoiceController.commitInvoiceLineItems(inv.Id, ilisToUpsert, new List<Id>());

        // VERIFY
        System.assertEquals(2, [SELECT COUNT() FROM InvoiceLineItem__c WHERE Invoice__c = :inv.Id], 'COUNT() FROM InvoiceLineItem__c');
    }

    @isTest
    static void commitInvoiceLineItems_OnlyDelete_AllLineItemsDeleted() {
        // SETUP
        Invoice__c inv = [SELECT Id FROM Invoice__c LIMIT 1];
        List<InvoiceLineItem__c> ilisToUpsert = new List<InvoiceLineItem__c>();
        InvoiceLineItem__c toDelete = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c = inv.Id));
        insert toDelete;

        // ACTION
        InvoiceController.commitInvoiceLineItems(inv.Id, new List<InvoiceLineItem__c>(), new List<Id>{toDelete.Id});

        // VERIFY
        System.assertEquals(0, [SELECT COUNT() FROM InvoiceLineItem__c WHERE Invoice__c = :inv.Id], 'COUNT() FROM InvoiceLineItem__c');
    }

    @isTest
    static void commitInvoiceLineItems_UpdateAndDelete_AllLineItemsDeleted() {
        // SETUP
        Invoice__c inv = [SELECT Id FROM Invoice__c LIMIT 1];
        List<InvoiceLineItem__c> ilisToUpsert = new List<InvoiceLineItem__c>();
        InvoiceLineItem__c toDelete = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c = inv.Id));
        InvoiceLineItem__c toUpdate = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c = inv.Id));
        insert toDelete;

        // ACTION
        InvoiceController.commitInvoiceLineItems(inv.Id, new List<InvoiceLineItem__c>{toUpdate}, new List<Id>{toDelete.Id});

        // VERIFY
        System.assertEquals(1, [SELECT COUNT() FROM InvoiceLineItem__c WHERE Invoice__c = :inv.Id], 'COUNT() FROM InvoiceLineItem__c');
    }
}
