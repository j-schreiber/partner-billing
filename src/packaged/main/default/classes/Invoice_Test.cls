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

        List<Product2> products = new List<Product2>();
        products.add(TestDataFactory.CreateProduct(new Product2(Name = 'Test Product Consulting')));
        products.add(TestDataFactory.CreateProduct(new Product2(Name = 'Test Product Dev')));
        insert products;
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
        System.assertEquals(false, objUnderTest.IsLocked, 'Invoice.IsLocked');
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
    static void init_WithDocument_AttachmentsInitialized() {
        // SETUP
        Invoice__c record = [SELECT Id,(SELECT Id FROM LineItems__r) FROM Invoice__c LIMIT 1];

        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion newVersion = new ContentVersion(Title='Test', PathOnClient='Test.pdf', VersionData=pdfMock);
        insert newVersion;
        newVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :newVersion.Id];
        insert new ContentDocumentLink(ContentDocumentId=newVersion.ContentDocumentId, LinkedEntityId=record.Id, ShareType='V');

        // ACTION
        Invoice objUnderTest = new Invoice(record.Id);
        
        // VERIFY
        System.assertEquals(1, objUnderTest.Attachments.size(), 'Attachments.size()');
        System.assertEquals(newVersion.ContentDocumentId, objUnderTest.Attachments.get(0).Id, 'Attachments.get(0).Id');
    }

    @isTest
    static void init_InvalidId_EmptyInvoiceInitialized() {
        // ACTION
        Invoice actualObj = new Invoice('abc');
        // VERIFY
        System.assertEquals(new Invoice__c(), actualObj.Record, 'Invoice.Record');
        System.assertEquals(new List<InvoiceLineItem>(), actualObj.LineItems, 'Invoice.LineItems');
        System.assertEquals(new List<ContentDocument>(), actualObj.Attachments, 'Invoice.Attachments');
        System.assertEquals(0.0, actualObj.TotalTaxes, 'Invoice.TotalTaxes');
        System.assertEquals(0.0, actualObj.TotalTaxesPercentage, 'Invoice.TotalTaxesPercentage');
    }

    @isTest
    static void init_Null_EmptyInvoiceInitialized() {
        // SETUP
        String recordId;
        // ACTION
        Invoice objUnderTest = new Invoice(recordId);
        // VERIFY
        System.assertEquals(new Invoice__c(), objUnderTest.Record, 'Invoice.Record');
        System.assertEquals(new List<InvoiceLineItem>(), objUnderTest.LineItems, 'Invoice.LineItems');
        System.assertEquals(new List<ContentDocument>(), objUnderTest.Attachments, 'Invoice.Attachments');
        System.assertEquals(false, objUnderTest.IsLocked, 'Invoice.IsLocked');
    }

    @isTest
    static void init_BlankConstructor_EmptyInvoiceInitialized() {
        // ACTION
        Invoice objUnderTest = new Invoice();
        // VERIFY
        System.assertEquals(new Invoice__c(), objUnderTest.Record, 'Invoice.Record');
        System.assertEquals(new List<InvoiceLineItem>(), objUnderTest.LineItems, 'Invoice.LineItems');
        System.assertEquals(new List<ContentDocument>(), objUnderTest.Attachments, 'Invoice.Attachments');
        System.assertEquals(false, objUnderTest.IsLocked, 'Invoice.IsLocked');
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
        InvoiceLineItem__c lineItemToUpdate = [SELECT Id,Price__c,Quantity__c,Invoice__c FROM InvoiceLineItem__c WHERE Invoice__c = :record.Id LIMIT 1];
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

    @isTest
    static void addTimeEntries_Collapse_CollapsableEntries_CombinedLineItemsCreated() {
        // SETUP
        Invoice__c record = [SELECT Id,Account__c FROM Invoice__c LIMIT 1];
        Product2 consultingProd = [SELECT Id FROM Product2 WHERE Name LIKE '%Consulting%' LIMIT 1];
        Product2 devProd = [SELECT Id FROM Product2 WHERE Name LIKE '%Dev%' LIMIT 1];
        List<TimeEntry__c> collapsableEntries = new List<TimeEntry__c>();
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=consultingProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(12, 0, 0, 0),DailyRate__c=1250.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=consultingProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(13, 0, 0, 0),DailyRate__c=1250.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=consultingProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(14, 0, 0, 0),DailyRate__c=1250.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=devProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(11, 0, 0, 0),DailyRate__c=650.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=devProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(11, 0, 0, 0),DailyRate__c=650.00)));
        insert collapsableEntries;
        collapsableEntries = Database.Query(TimeEntry.QUERY_STRING);

        // ACTION
        Invoice objUnderTest = new Invoice(record.Id);
        List<InvoiceLineItem__c> newIlis = objUnderTest.addTimeEntries(true, collapsableEntries);

        // VERIFY
        System.assertEquals(2, newIlis.size(), 'newIlis.size()');
        System.assertEquals(collapsableEntries.size(), objUnderTest.TimeEntriesMap.size(), 'objUnderTest.TimeEntryMap.size()');

        Decimal consultingQuantity = 0;
        Decimal devQuantity = 0;
        for (TimeEntry__c te : collapsableEntries) {
            if (te.Product__c == consultingProd.Id) consultingQuantity += (te.Duration__c / 8);
            if (te.Product__c == devProd.Id) devQuantity += (te.Duration__c / 8);
            System.assertEquals(record.Id, te.Invoice__c, 'te.Invoice__c');
        }

        System.assertEquals(1250.00, newIlis[0].Price__c, 'newIlis[0].Price__c');
        System.assertEquals(consultingProd.Id, newIlis[0].Product__c, 'newIlis[0].Product__c');
        System.assertEquals(consultingQuantity, newIlis[0].Quantity__c, 'newIlis[0].Quantity__c');
        System.assertEquals(record.Id, newIlis[0].Invoice__c, 'newIlis[0].Invoice__c');

        System.assertEquals(650.00, newIlis[1].Price__c, 'newIlis[1].Price__c');
        System.assertEquals(devProd.Id, newIlis[1].Product__c, 'newIlis[1].Product__c');
        System.assertEquals(devQuantity, newIlis[1].Quantity__c, 'newIlis[1].Quantity__c');
        System.assertEquals(record.Id, newIlis[1].Invoice__c, 'newIlis[1].Invoice__c');
    }

    @isTest
    static void addTimeEntries_NoCollapse_CollapsableEntries_DistinctLineItemsCreated() {
        // SETUP
        Invoice__c record = [SELECT Id,Account__c FROM Invoice__c LIMIT 1];
        Product2 consultingProd = [SELECT Id FROM Product2 WHERE Name LIKE '%Consulting%' LIMIT 1];
        Product2 devProd = [SELECT Id FROM Product2 WHERE Name LIKE '%Dev%' LIMIT 1];
        List<TimeEntry__c> collapsableEntries = new List<TimeEntry__c>();
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=consultingProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(12, 0, 0, 0),DailyRate__c=1250.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=consultingProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(13, 0, 0, 0),DailyRate__c=1250.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=consultingProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(14, 0, 0, 0),DailyRate__c=1250.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=devProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(11, 0, 0, 0),DailyRate__c=650.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=devProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(11, 0, 0, 0),DailyRate__c=650.00)));
        insert collapsableEntries;
        collapsableEntries = Database.Query(TimeEntry.QUERY_STRING);

        // ACTION
        Invoice objUnderTest = new Invoice(record.Id);
        List<InvoiceLineItem__c> newIlis = objUnderTest.addTimeEntries(false, collapsableEntries);

        // VERIFY
        System.assertEquals(collapsableEntries.size(), newIlis.size(), 'newIlis.size()');
        for (Integer i = 0; i < newIlis.size(); i++) {
            System.assertEquals(collapsableEntries[i].Duration__c / 8, newIlis[i].Quantity__c, 'newIlis[i].Quantity__c');
            System.assertEquals(collapsableEntries[i].DailyRate__c, newIlis[i].Price__c, 'newIlis[i].Price__c');
            System.assertEquals(collapsableEntries[i].Product__c, newIlis[i].Product__c, 'newIlis[i].Product__c');
        }
    }

    @isTest
    static void addTimeEntries_Collapse_NonCollapsableEntries_DistinctLineItemsCreated() {
        // SETUP
        Invoice__c record = [SELECT Id,Account__c FROM Invoice__c LIMIT 1];
        Product2 consultingProd = [SELECT Id FROM Product2 WHERE Name LIKE '%Consulting%' LIMIT 1];
        Product2 devProd = [SELECT Id FROM Product2 WHERE Name LIKE '%Dev%' LIMIT 1];
        List<TimeEntry__c> collapsableEntries = new List<TimeEntry__c>();
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=consultingProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(12, 0, 0, 0),DailyRate__c=1250.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=consultingProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(13, 0, 0, 0),DailyRate__c=1350.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=consultingProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(14, 0, 0, 0),DailyRate__c=1450.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=devProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(11, 0, 0, 0),DailyRate__c=650.00)));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c, Product__c=devProd.Id, Status__c='Approved', EndTime__c=Time.newInstance(11, 0, 0, 0),DailyRate__c=750.00)));
        insert collapsableEntries;
        collapsableEntries = Database.Query(TimeEntry.QUERY_STRING);

        // ACTION
        Invoice objUnderTest = new Invoice(record.Id);
        List<InvoiceLineItem__c> newIlis = objUnderTest.addTimeEntries(true, collapsableEntries);

        // VERIFY
        System.assertEquals(collapsableEntries.size(), newIlis.size(), 'newIlis.size()');
        for (Integer i = 0; i < newIlis.size(); i++) {
            System.assertEquals(collapsableEntries[i].Duration__c / 8, newIlis[i].Quantity__c, 'newIlis[i].Quantity__c');
            System.assertEquals(collapsableEntries[i].DailyRate__c, newIlis[i].Price__c, 'newIlis[i].Price__c');
            System.assertEquals(collapsableEntries[i].Product__c, newIlis[i].Product__c, 'newIlis[i].Product__c');
        }
    }

    @isTest
    static void getTimesheetServicePeriod_NoTimeSheet_Null() {
        // SETUP
        Invoice objUnderTest = new Invoice();
        // ACTION
        Invoice.ServicePeriod actual = objUnderTest.getTimeSheetServicePeriod();
        // VERIFY
        System.assertEquals(null, actual.startDate, 'ServicePeriod.startDate');
        System.assertEquals(null, actual.endDate, 'ServicePeriod.endDate');
    }

    @isTest
    static void getTimesheetServicePeriod_SingleTimeEntry_ServiceDateIsServicePeriod() {
        // SETUP
        Invoice__c record = [SELECT Id,Account__c FROM Invoice__c LIMIT 1];
        List<TimeEntry__c> collapsableEntries = new List<TimeEntry__c>();
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c,Invoice__c=record.Id,Date__c=Date.newInstance(2019,11,02))));
        collapsableEntries.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=record.Account__c,Invoice__c=record.Id,Date__c=Date.newInstance(2019,11,30))));
        insert collapsableEntries;

        Invoice objUnderTest = new Invoice(record.Id);

        // ACTION
        Invoice.ServicePeriod actual = objUnderTest.getTimeSheetServicePeriod();

        // VERIFY
        System.assertEquals(Date.newInstance(2019,11,02), actual.startDate, 'ServicePeriod.startDate');
        System.assertEquals(Date.newInstance(2019,11,30), actual.endDate, 'ServicePeriod.endDate');
    }

    @isTest
    static void setServicePeriod_EmptyDates_OverwriteDatesWithStartEndOfCurrentMonth() {
        // SETUP
        Invoice objUnderTest = new Invoice();
        Invoice.ServicePeriod sp = new Invoice.ServicePeriod();
        
        // ACTION
        objUnderTest.setServicePeriod(sp);

        // VERIFY
        System.assertEquals(Date.newInstance(System.today().year(), System.today().month() + 1, 1).addDays(-1), objUnderTest.Record.ServicePeriodTo__c, 'Record.ServicePeriodTo__c');
        System.assertEquals(Date.newInstance(System.today().year(), System.today().month(), 1), objUnderTest.Record.ServicePeriodFrom__c, 'Record.ServicePeriodFrom__c');
    }

    @isTest
    static void setServicePeriod_ValidDates_SetDatesFromServicePeriod() {
        
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

    @isTest
    static void getIsLocked_ActivatedInvoice_True() {
        // SETUP
        Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Status__c = Constants.INVOICE_STATUS_ACTIVATED));
        // ACTION
        Invoice objUnderTest = new Invoice(i);
        // VERIFY
        System.assertEquals(true, objUnderTest.IsLocked, 'IsLocked');
    }
}
