@isTest
public class BudgetTriggerHandler_Test {

    @TestSetup
    static void makeData(){
        insert TestDataFactory.CreateDefaultAccount();
    }
    
    /**                             TIME ENTRY STATISTICS                  
    *   - all tests only work on real DB operations, because of caching
    *   - sum for total amount logged
    *   - sum for total amount invoiced
    */

    @isTest
    static void insert_NewBudget_TimeEntrySumsZeroed() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Budget__c toInsert = TestDataFactory.CreateBudget(new Budget__c(Account__c = a.Id));
        // ACTION
        Database.SaveResult sr = Database.insert(toInsert, false);
        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Budget__c actualRecord = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c FROM Budget__c WHERE Id = :toInsert.Id];
        System.assertEquals(0.0, actualRecord.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(0.0, actualRecord.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }

    @isTest
    static void insert_OverrideSumsInNewBudget_TimeEntrySumsCalculated() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Budget__c toInsert = TestDataFactory.CreateBudget(new Budget__c(Account__c = a.Id, TotalAmountLogged__c = 100.00, TotalAmountInvoiced__c = 85.23));
        // ACTION
        Database.SaveResult sr = Database.insert(toInsert, false);
        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Budget__c actualRecord = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c FROM Budget__c WHERE Id = :toInsert.Id];
        System.assertEquals(0.0, actualRecord.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(0.0, actualRecord.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }

    @isTest
    static void update_NoTimeEntries_TimeEntrySumsCalculated() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Budget__c toUpdate = TestDataFactory.CreateBudget(new Budget__c(Account__c = a.Id));
        insert toUpdate;

        // ACTION
        toUpdate.TotalAmountLogged__c = 100.00;
        toUpdate.TotalAmountInvoiced__c = 75.00;
        Database.SaveResult sr = Database.update(toUpdate, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Budget__c actualRecord = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c FROM Budget__c WHERE Id = :toUpdate.Id];
        System.assertEquals(0.0, actualRecord.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(0.0, actualRecord.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }
}
