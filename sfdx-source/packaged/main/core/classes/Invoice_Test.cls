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
        // SETUP
        Invoice__c record = [SELECT Id,(SELECT Id FROM LineItems__r) FROM Invoice__c LIMIT 1];
        // ACTION
        Invoice objUnderTest = new Invoice(record.Id);
        // VERIFY
        System.assertEquals(record.Id, objUnderTest.Record.Id, 'Record.Id');
        System.assertEquals(record.LineItems__r.size(), objUnderTest.LineItems.size(), 'LineItems.size()');
        System.assertEquals(0, objUnderTest.Record.TimeEntries__r.size(), 'Record.TimeEntries__r.size()');
    }

    @isTest
    static void init_WithoutLineItems_AllDefaultsInitialized() {
        // SETUP
        delete [SELECT Id FROM InvoiceLineItem__c];
        Invoice__c record = [SELECT Id FROM Invoice__c LIMIT 1];
        // ACTION
        Invoice objUnderTest = new Invoice(record.Id);
        // VERIFY
        System.assertEquals(record.Id, objUnderTest.Record.Id, 'Record.Id');
        System.assertEquals(0, objUnderTest.LineItems.size(), 'LineItems.size()');
        System.assertEquals(0, objUnderTest.Record.TimeEntries__r.size(), 'Record.TimeEntries__r.size()');
    }

    @isTest
    static void init_WithTimeEntries_TimesheetInitialized() {
        // SETUP
        Invoice__c record = [SELECT Id,Account__c FROM Invoice__c LIMIT 1];

        List<TimeEntry__c> tes = new List<TimeEntry__c>();
        for (Integer i = 0; i < 10; i++) {
            tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Invoice__c = record.Id, Account__c = record.Account__c)));
        }
        insert tes;

        // ACTION
        Invoice objUnderTest = new Invoice(record.Id);
        
        // VERIFY
        System.assertEquals(record.Id, objUnderTest.Record.Id, 'Record.Id');
        System.assertEquals(tes.size(), objUnderTest.Record.TimeEntries__r.size(), 'Record.TimeEntries__r.size()');
    }

    @isTest
    static void init_InvalidId_EmptyInvoiceInitialized() {
        // ACTION
        Invoice actualObj = new Invoice('abc');
        // VERIFY
        System.assertEquals(new Invoice__c(), actualObj.Record, 'Invoice.Record');
        System.assertEquals(new List<InvoiceLineItem>(), actualObj.LineItems, 'Invoice.LineItems');
        System.assertEquals(new List<Attachment>(), actualObj.Attachments, 'Invoice.Attachments');
        System.assertEquals(0.0, actualObj.TotalTaxes, 'Invoice.TotalTaxes');
        System.assertEquals(0.0, actualObj.TotalTaxesPercentage, 'Invoice.TotalTaxesPercentage');
    }

    @isTest
    static void init_Null_EmptyInvoiceInitialized() {
        // SETUP
        String recordId;
        // ACTION
        Invoice actualObj = new Invoice(recordId);
        // VERIFY
        System.assertEquals(new Invoice__c(), actualObj.Record, 'Invoice.Record');
        System.assertEquals(new List<InvoiceLineItem>(), actualObj.LineItems, 'Invoice.LineItems');
        System.assertEquals(new List<Attachment>(), actualObj.Attachments, 'Invoice.Attachments');
    }

    @isTest
    static void init_BlankConstructor_EmptyInvoiceInitialized() {
        // ACTION
        Invoice actualObj = new Invoice();
        // VERIFY
        System.assertEquals(new Invoice__c(), actualObj.Record, 'Invoice.Record');
        System.assertEquals(new List<InvoiceLineItem>(), actualObj.LineItems, 'Invoice.LineItems');
        System.assertEquals(new List<Attachment>(), actualObj.Attachments, 'Invoice.Attachments');
    }

    @isTest
    static void addLineItemRecord_NewLineItem_NotAddedToPersistentLineItems() {
        // SETUP
        Invoice__c record = [SELECT Id,(SELECT Id FROM LineItems__r) FROM Invoice__c LIMIT 1];
        Invoice objUnderTest = new Invoice(record.Id);

        // ACTION
        InvoiceLineItem__c ili = TestDataFactory.CreateDefaultInvoiceLineItem();
        objUnderTest.addLineItemRecord(ili);

        // VERIFY
        System.assertEquals(record.LineItems__r.size(), objUnderTest.LineItems.size(), 'LineItems.size()');
        System.assertEquals(ili.Invoice__c, objUnderTest.Record.Id, 'Record.Id');
    }

    @isTest
    static void addLineItemRecord_ExistingLineItem_NotAddedToPersistentLineItems() {
        // SETUP
        Invoice__c record = [SELECT Id,(SELECT Id FROM LineItems__r) FROM Invoice__c LIMIT 1];
        InvoiceLineItem__c lineItemToUpdate = [SELECT Id,Price__c,Quantity__c FROM InvoiceLineItem__c WHERE Invoice__c = :record.Id LIMIT 1];
        Decimal originalQuantity = lineItemToUpdate.Quantity__c;
        Invoice objUnderTest = new Invoice(record.Id);

        // ACTION
        lineItemToUpdate.Quantity__c = 1298.98;
        objUnderTest.addLineItemRecord(lineItemToUpdate);

        // VERIFY
        System.assertEquals(record.LineItems__r.size(), objUnderTest.LineItems.size(), 'LineItems.size()');
        System.assertEquals(originalQuantity, objUnderTest.LineItemMap.get(lineItemToUpdate.Id).Record.Quantity__c, 'LineItemMap.get(lineItemToUpdate.Id).Recod.Quantity__c');
    }

    @isTest
    static void removeLineItemId_InvalidId_NoEffect() {
        // SETUP
        Invoice__c record = [SELECT Id,(SELECT Id FROM LineItems__r) FROM Invoice__c LIMIT 1];
        Invoice objUnderTest = new Invoice(record.Id);

        // ACTION
        Boolean actual = objUnderTest.removeLineItemId('a051k0000000000XXX');

        // VERIFY
        System.assertEquals(false, actual, 'return from removeLineItemId()');
    }

    @isTest
    static void removeLineItemId_ValidId_MarkedForDeletion() {
        // SETUP
        Invoice__c record = [SELECT Id,(SELECT Id FROM LineItems__r) FROM Invoice__c LIMIT 1];
        Invoice objUnderTest = new Invoice(record.Id);

        // ACTION
        Id toDeleteId = record.LineItems__r[0].Id;
        Boolean actual = objUnderTest.removeLineItemId(toDeleteId);

        // VERIFY
        System.assertEquals(true, actual, 'return from removeLineItemId()');
        System.assertEquals(true, objUnderTest.LineItemMap.containsKey(toDeleteId), 'LineItemMap.containsKey(toDeleteId)');
        System.assertEquals(record.LineItems__r.size(), objUnderTest.LineItems.size(), 'LineItems.size()');
    }

    @isTest
    static void commitAllChanges_HasNewLineItem_AddedToPersistentLineItems() {
        // SETUP
        Invoice__c record = [SELECT Id,(SELECT Id FROM LineItems__r) FROM Invoice__c LIMIT 1];
        Invoice objUnderTest = new Invoice(record.Id);
        InvoiceLineItem__c ili = TestDataFactory.CreateDefaultInvoiceLineItem();
        objUnderTest.addLineItemRecord(ili);

        // ACTION
        objUnderTest.commitAllChanges();

        // VERIFY
        System.assertEquals(record.LineItems__r.size() + 1, objUnderTest.LineItems.size(), 'LineItems.size()');
        System.assertNotEquals(null, ili.Id, 'ili.Record.Id');
    }

    @isTest
    static void commitAllChanges_ExistingNewLineItem_PersistentLineItemsUpdated() {
        // SETUP
        Invoice__c record = [SELECT Id,(SELECT Id FROM LineItems__r) FROM Invoice__c LIMIT 1];
        InvoiceLineItem__c lineItemToUpdate = [SELECT Id FROM InvoiceLineItem__c WHERE Invoice__c = :record.Id LIMIT 1];
        Invoice objUnderTest = new Invoice(record.Id);
        lineItemToUpdate.Quantity__c = 100;
        lineItemToUpdate.Price__c = 999.12;
        objUnderTest.addLineItemRecord(lineItemToUpdate);

        // ACTION
        objUnderTest.commitAllChanges();

        // VERIFY
        System.assertEquals(record.LineItems__r.size(), objUnderTest.LineItems.size(), 'LineItems.size()');
        System.assertEquals(lineItemToUpdate.Quantity__c, objUnderTest.LineItemMap.get(lineItemToUpdate.Id).Record.Quantity__c, 'LineItemMap.get(lineItemToUpdate.Id).Record.Quantity__c');
        System.assertEquals(lineItemToUpdate.Price__c, objUnderTest.LineItemMap.get(lineItemToUpdate.Id).Record.Price__c, 'LineItemMap.get(lineItemToUpdate.Id).Record.Price__c');
    }

    @isTest
    static void commitAllChanges_LineItemMarkedForDeletion_LineItemDeleted() {
        // SETUP
        Invoice__c record = [SELECT Id,(SELECT Id FROM LineItems__r) FROM Invoice__c LIMIT 1];
        Invoice objUnderTest = new Invoice(record.Id);
        Id toDeleteId = record.LineItems__r[0].Id;
        objUnderTest.removeLineItemId(toDeleteId);

        // ACTION
        objUnderTest.commitAllChanges();

        // VERIFY
        System.assertEquals(false, objUnderTest.LineItemMap.containsKey(toDeleteId), 'LineItemMap.containsKey(toDeleteId)');
        System.assertEquals(record.LineItems__r.size() - 1, objUnderTest.LineItems.size(), 'LineItems.size()');
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
