@isTest
class TimeTrackingController_Test {

    @TestSetup
    static void makeData(){
        insert TestDataFactory.CreateDefaultAccount();
    }

    @isTest
    static void getUnfinishedTimeEntries_NoTimeEntries_EmptyList() {
        // ACTION
        List<TimeEntry__c> tes = TimeTrackingController.getUnfinishedTimeEntries();
        // VERIFY
        System.assertEquals(0, tes.size(), 'tes.size()');
    }

    @isTest
    static void getUnfinishedTimeEntries_NoUnfinishedTimeEntries_EmptyList() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        List<TimeEntry__c> tes = new List<TimeEntry__c>();
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, EndTime__c = Time.newInstance(18, 0, 0, 0))));
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, EndTime__c = Time.newInstance(18, 0, 0, 0))));
        insert tes;
        // ACTION
        List<TimeEntry__c> actualTes = TimeTrackingController.getUnfinishedTimeEntries();
        // VERIFY
        System.assertEquals(0, actualTes.size(), 'actualTes.size()');
    }

    @isTest
    static void getUnfinishedTimeEntries_WithUnfinishedTimeEntries_OnlyUnfinishedTimeEntries() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        List<TimeEntry__c> tes = new List<TimeEntry__c>();
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, EndTime__c = Time.newInstance(18, 0, 0, 0))));
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, EndTime__c = null)));
        insert tes;
        // ACTION
        List<TimeEntry__c> actualTes = TimeTrackingController.getUnfinishedTimeEntries();
        // VERIFY
        System.assertEquals(1, actualTes.size(), 'actualTes.size()');
    }
    
}
