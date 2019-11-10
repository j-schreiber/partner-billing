@isTest
class BillingController_Test {

    private static final Integer BULK_NUMBER = 3;

    @TestSetup
    static void makeData(){

        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < BULK_NUMBER; i++) {
            accs.add(TestDataFactory.CreateAccount(new Account(Name='Test Company GmbH ' + i)));
        }
        insert accs;

        List<TimeEntry__c> tes = new List<TimeEntry__c>();
        for (Account a : accs) {
            tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=a.Id,DailyRate__c=1000, Description__c='Expensive Test Product')));
            tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=a.Id,DailyRate__c=750, Description__c='Middle Test Product')));
            tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c=a.Id,DailyRate__c=500, Description__c='Cheap Test Product')));
        }
        insert tes;

        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Account a : accs) {
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

    @isTest
    static void createInvoicesFromTimeEntries_MultipleAccounts_OneInvoicePerAccount() {
        // SETUP
        List<Id> timeEntryIds = new List<Id>(new Map<Id,TimeEntry__c>([SELECT Id FROM TimeEntry__c]).keySet());
        Map<String, Object> options = new Map<String, Object>{'collapseTimeEntries' => false, 'overrideServicePeriod' => false};
        Map<String, Object> filters = new Map<String, Object>{'startDate' => '2019-10-01', 'endDate' => '2019-10-31'};

        // ACTION
        List<Invoice> invoices = BillingController.createInvoicesFromTimeEntries(timeEntryIds, options, filters);

        // VERIFY
        System.assertEquals(BULK_NUMBER, invoices.size(), 'invoices.size()');
        for (Invoice inv : invoices) {
            System.assertEquals(System.today(), inv.Record.Date__c, 'inv.Record.Date__c');
            System.assertEquals('Draft', inv.Record.Status__c, 'inv.Record.Status__c');
            System.assertNotEquals(null, inv.Record.Account__c, 'inv.Record.Account__c');
            System.assertEquals(3, inv.TimeEntriesMap.size(), 'inv.TimeEntriesMap.size()');
            System.assertEquals(3, [SELECT COUNT() FROM InvoiceLineItem__c WHERE Invoice__c =:inv.Record.Id], 'COUNT() FROM InvoiceLineItem__c');
        }

        for (TimeEntry__c te : [SELECT Invoice__c FROM TimeEntry__c]) {
            System.assertNotEquals(null, te.Invoice__c, 'te.Invoice__c');
        }
    }

    @isTest
    static void createInvoicesFromTimeEntries_CollapseEntriesTrue_InvoiceWithCollapsedEntries() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        List<TimeEntry__c> tes = [SELECT Id FROM TimeEntry__c WHERE Account__c = :a.Id];
        for (TimeEntry__c te : tes) {
            te.Product__c = null;
            te.DailyRate__c = 666;
        }
        update tes;
        List<Id> timeEntryIds = new List<Id>(new Map<Id,TimeEntry__c>(tes).keySet());

        Map<String, Object> options = new Map<String, Object>{'collapseTimeEntries' => true, 'overrideServicePeriod' => false};
        Map<String, Object> filters = new Map<String, Object>{'startDate' => '2019-10-01', 'endDate' => '2019-10-31'};

         // ACTION
        List<Invoice> invoices = BillingController.createInvoicesFromTimeEntries(timeEntryIds, options, filters);

        // VERIFY
        System.assertEquals(1, invoices.size(), 'invoices.size()');
        System.assertEquals(1, [SELECT COUNT() FROM InvoiceLineItem__c WHERE Invoice__c =:invoices[0].Record.Id], 'COUNT() FROM InvoiceLineItem__c');
    }

    @isTest
    static void createInvoicesFromTimeEntries_OverrideServicePeriodTrue_ServicePeriodDateSetFromFilters() {
        // SETUP
        List<Id> timeEntryIds = new List<Id>(new Map<Id,TimeEntry__c>([SELECT Id FROM TimeEntry__c]).keySet());
        Map<String, Object> options = new Map<String, Object>{'collapseTimeEntries' => true, 'overrideServicePeriod' => true};
        Map<String, Object> filters = new Map<String, Object>{'startDate' => '2019-03-02', 'endDate' => '2019-05-31'};

         // ACTION
        List<Invoice> invoices = BillingController.createInvoicesFromTimeEntries(timeEntryIds, options, filters);

        // VERIFY
        List<Id> createdInvoiceIds = new List<Id>();
        for (Invoice inv : invoices) createdInvoiceIds.add(inv.Record.Id);
        System.assertEquals(BULK_NUMBER, createdInvoiceIds.size(), 'invoices.size()');

        for (Invoice__c inv : [SELECT Id,ServicePeriodFrom__c,ServicePeriodTo__c FROM Invoice__c WHERE Id IN :createdInvoiceIds]) {
            System.assertEquals(Date.newInstance(2019, 03, 02), inv.ServicePeriodFrom__c, 'ServicePeriodFrom__c');
            System.assertEquals(Date.newInstance(2019, 05, 31), inv.ServicePeriodTo__c, 'ServicePeriodTo__c');
        }
    }

    @isTest
    static void createInvoicesFromTimeEntries_OverrideServicePeriodFalse_ServicePeriodDateCalculatedFromTimeEntries() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        List<TimeEntry__c> tes = [SELECT Id FROM TimeEntry__c WHERE Account__c = :a.Id];
        tes[0].Date__c = Date.newInstance(2019,08,01);
        tes[1].Date__c = Date.newInstance(2019,08,15);
        tes[2].Date__c = Date.newInstance(2019,08,28);
        update tes;
        List<Id> timeEntryIds = new List<Id>(new Map<Id,TimeEntry__c>(tes).keySet());
        
        Map<String, Object> options = new Map<String, Object>{'collapseTimeEntries' => true, 'overrideServicePeriod' => false};
        Map<String, Object> filters = new Map<String, Object>{'startDate' => '2019-09-01', 'endDate' => '2019-10-31'};

         // ACTION
        List<Invoice> invoices = BillingController.createInvoicesFromTimeEntries(timeEntryIds, options, filters);

        // VERIFY
        Invoice__c inv = [SELECT Id,ServicePeriodFrom__c,ServicePeriodTo__c FROM Invoice__c WHERE Id = :invoices[0].Record.Id];
        System.assertEquals(Date.newInstance(2019,08,01), inv.ServicePeriodFrom__c, 'ServicePeriodFrom__c');
        System.assertEquals(Date.newInstance(2019,08,28), inv.ServicePeriodTo__c, 'ServicePeriodTo__c');
    }

    @isTest
    static void commitInvoiceEditData_InvoiceData_InvoiceUpdated() {
        // SETUP
        List<Invoice__c> invoices = [SELECT Id FROM Invoice__c WHERE Status__c = 'Draft'];
        System.assertEquals(BULK_NUMBER, invoices.size(), 'invoices.size()');
        for (Invoice__c i : invoices) {
            i.Date__c = Date.newInstance(2019, 05, 25);
            i.ServicePeriodFrom__c = Date.newInstance(2019, 04, 01);
            i.ServicePeriodTo__c = Date.newInstance(2019, 04, 30);
        }

        // ACTION
        BillingController.commitInvoiceEditData(invoices, new List<InvoiceLineItem__c>(), new List<Id>());

        // VERIFY
        for (Invoice__c i : [SELECT Id,Date__c,ServicePeriodFrom__c,ServicePeriodTo__c FROM Invoice__c WHERE Id IN :invoices]) {
            System.assertEquals(Date.newInstance(2019, 05, 25), i.Date__c, 'Date__c');
            System.assertEquals(Date.newInstance(2019, 04, 01), i.ServicePeriodFrom__c, 'ServicePeriodFrom__c');
            System.assertEquals(Date.newInstance(2019, 04, 30), i.ServicePeriodTo__c, 'ServicePeriodTo__c');
        }
    }

    @isTest
    static void commitInvoiceEditData_LineItemsToUpsert_LineItemsUpserted() {
        
    }

    @isTest
    static void commitInvoiceEditData_LineItemsToDelete_LineItemsDeleted() {
        
    }

    @isTest
    static void getInvoicesWithoutPdfs_NoPdfs_AllActivatedInvoices() {
        // ACTION
        List<Invoice> invs = BillingController.getInvoicesWithoutPdfs();
        // VERIFY
        System.assertEquals([SELECT COUNT() FROM Invoice__c WHERE Status__c='Activated'], invs.size(), 'invs.size()');
    }

    @isTest
    static void getInvoicesWithoutPdfs_InvoicesHavePdfs_OnlyActivatedInvoicesWithoutPdfs() {
        // SETUP
        Invoice__c Record = [SELECT Id,Name,PdfLanguage__c FROM Invoice__c LIMIT 1];
        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion existingVersion = new ContentVersion(Title='Test',PathOnClient='Test.pdf', VersionData=pdfMock);
        insert existingVersion;
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Title = 'Test' LIMIT 1];
        insert new ContentDocumentLink(LinkedEntityId=Record.Id, ContentDocumentId=contentDoc.Id, ShareType='V');

        // ACTION
        List<Invoice> invs = BillingController.getInvoicesWithoutPdfs();
        // VERIFY
        System.assertEquals([SELECT COUNT() FROM Invoice__c WHERE Status__c='Activated' AND Id != :Record.Id], invs.size(), 'invs.size()');
    }

    @isTest
    static void getNonInvoicedTimeEntries_NullDates_AllNonInvoicedEntries() {
        // SETUP
        List<TimeEntry__c> tesToUpdate = [SELECT Id,Description__c FROM TimeEntry__c];
        for (TimeEntry__c te : tesToUpdate) {
            te.Status__c = 'Approved';
        }

        // ACTION
        List<TimeEntry> tes = BillingController.getNonInvoicedTimeEntries(null, null);
        // VERIFY
        System.assertEquals([SELECT COUNT() FROM TimeEntry__c WHERE IsInvoiced__c = false AND Status__c = 'Approved'], tes.size(), 'tes.size()');
    }

    @isTest
    static void getNonInvoicedTimeEntries_ValidDates_AllNonInvoicedEntriesInTimePeriod() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        List<TimeEntry__c> tesToUpdate = [SELECT Id,Description__c FROM TimeEntry__c WHERE Account__c = :a.Id];
        for (TimeEntry__c te : tesToUpdate) {
            te.Date__c = Date.newInstance(2019, 09, 20);
            te.Status__c = 'Approved';
        }
        update tesToUpdate;

        // ACTION
        List<TimeEntry> tes = BillingController.getNonInvoicedTimeEntries(Date.newInstance(2019, 09, 20), Date.newInstance(2019, 09, 20));

        // VERIFY
        System.assertEquals(tesToUpdate.size(), tes.size(), 'tes.size()');
    }

}
