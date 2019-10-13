@isTest
public class TimeEntryTriggerHandler_Test {
    
    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        Budget__c b = TestDataFactory.CreateBudget(new Budget__c(Account__c = a.Id));
        insert b;   
    }

    @isTest
    static void insert_NewTimeEntry_BudgetSummaryRecalculated() {
        // SETUP
        Budget__c b = [SELECT Id,Account__c FROM Budget__c LIMIT 1];
        TimeEntry__c toInsert = TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(
                Budget__c = b.Id,
                Account__c = b.Account__c,
                DailyRate__c = 1500.00,
                StartTime__c = Time.newInstance(8,0,0,0),
                EndTime__c = Time.newInstance(12,0,0,0),
                Status__c = 'New')
        );

        // ACTION
        Database.SaveResult sr = Database.insert(toInsert, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Budget__c newBudget = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c FROM Budget__c WHERE Id = :b.Id];
        System.assertEquals(750.00, newBudget.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(0, newBudget.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }

    @isTest
    static void insert_InvoicedTimeEntry_BudgetSummaryRecalculated() {
        // SETUP
        Budget__c b = [SELECT Id,Account__c FROM Budget__c LIMIT 1];
        TimeEntry__c toInsert = TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(
                Budget__c = b.Id,
                Account__c = b.Account__c,
                DailyRate__c = 1500.00,
                StartTime__c = Time.newInstance(8,0,0,0),
                EndTime__c = Time.newInstance(12,0,0,0),
                Status__c = 'Invoiced')
        );

        // ACTION
        Database.SaveResult sr = Database.insert(toInsert, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Budget__c newBudget = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c FROM Budget__c WHERE Id = :b.Id];
        System.assertEquals(750.00, newBudget.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(750.00, newBudget.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }

    @isTest
    static void update_ChangeTotalAmount_BudgetSummaryRecalculated() {
        
    }

    @isTest
    static void delete_ValidTimeEntry_BudgetSummaryRecalculated() {
        
    }
}
