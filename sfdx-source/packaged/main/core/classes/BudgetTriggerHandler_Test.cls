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

    @isTest
    static void undelete_HadTimeEntriesBeforeDelete_TimeEntrySumsCalculated() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Budget__c toUndelete = TestDataFactory.CreateBudget(new Budget__c(Account__c = a.Id));
        insert toUndelete;

        TimeEntry__c te = TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(
                Budget__c = toUndelete.Id,
                Account__c = a.Id,
                DailyRate__c = 1500.00,
                StartTime__c = Time.newInstance(8,0,0,0),
                EndTime__c = Time.newInstance(12,0,0,0),
                Status__c = 'Approved')
        );
        insert te;

        // ACTION
        Id undeleteId = toUndelete.Id;
        Database.DeleteResult dr = Database.delete(undeleteId);

        // update time entry, so budget will need recalculation after undelete
        te = [SELECT Id FROM TimeEntry__c WHERE Id = :te.Id];
        te.DailyRate__c = 1600.00;
        update te;
        
        // undelete budget, which will also restore lookup
        Database.UndeleteResult ur = Database.undelete(undeleteId, false);

        // VERIFY
        System.assertEquals(true, dr.isSuccess(), 'DeleteResult: ' + dr.getErrors());
        System.assertEquals(true, ur.isSuccess(), 'UndeleteResult: ' + ur.getErrors());
        Budget__c actualRecord = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c,(SELECT Id FROM TimeEntries__r) FROM Budget__c WHERE Id = :toUndelete.Id];
        System.assertEquals(1, actualRecord.TimeEntries__r.size(), 'TimeEntries__r.size()');
        System.assertEquals(800.0, actualRecord.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(0.0, actualRecord.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }
}
