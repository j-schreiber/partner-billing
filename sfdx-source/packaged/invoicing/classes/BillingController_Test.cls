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
        }

        for (TimeEntry__c te : [SELECT Invoice__c FROM TimeEntry__c]) {
            System.assertNotEquals(null, te.Invoice__c, 'te.Invoice__c');
        }
    }
}
