@isTest
class TimeEntryApprovalController_Test {

    @TestSetup
    static void makeData(){

        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        List<TimeEntry__c> tes = new List<TimeEntry__c>();
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, Status__c='Approved')));
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, Status__c='Approved')));
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id)));
        insert tes;

        Contact c = TestDataFactory.CreateContact(new Contact(AccountId = a.Id));
        insert c;

        List<AccessToken__c> ats = new List<AccessToken__c>();
        ats.add(TestDataFactory.CreateAccessToken(new AccessToken__c(Contact__c=c.Id, Code__c='ABCD1234XYZ1', Status__c='Active')));
        ats.add(TestDataFactory.CreateAccessToken(new AccessToken__c(Contact__c=c.Id, Code__c='ABCD1234XYZ2', Status__c='Active')));
        ats.add(TestDataFactory.CreateAccessToken(new AccessToken__c(Contact__c=c.Id, Code__c='ABCD1234XYZ3', Status__c='Revoked')));
        insert ats;
    }
    
    @isTest
    static void validateAccessCode_ValidCode_True() {
        // ACTION
        Boolean isValid = TimeEntryApprovalController.validateAccessCode('ABCD1234XYZ1');
        // VERIFY
        System.assertEquals(true, isValid, 'validateAccessCode(ABCD1234XYZ1)');
    }

    @isTest
    static void validateAccessCode_NonExistingCode_False() {
        // ACTION
        try {
            Boolean isValid = TimeEntryApprovalController.validateAccessCode('ABCD');
            System.assert(false, 'Expected AuraHandledException');
        } catch (Exception e) {
            // VERIFY
            System.assertEquals('System.AuraHandledException', e.getTypeName(), 'e.getTypeName()');
        }
    }

    @isTest
    static void validateAccessCode_RevokedCode_False() {
        // ACTION
        try {
            Boolean isValid = TimeEntryApprovalController.validateAccessCode('ABCD1234XYZ3');
            System.assert(false, 'Expected AuraHandledException');
        } catch (Exception e) {
            // VERIFY
            System.assertEquals('System.AuraHandledException', e.getTypeName(), 'e.getTypeName()');
        }
    }

    @isTest
    static void getTimeEntries_InvalidAccessCode_EmptyList() {
        // ACTION
        List<TimeEntry__c> tes = TimeEntryApprovalController.getTimeEntries('ABCD1234XYZ3');
        // VERIFY
        System.assertEquals(0, tes.size(), 'size()');
    }

    @isTest
    static void getTimeEntries_ValidAccessCode_ApprovedTimeEntriesInList() {
        // ACTION
        List<TimeEntry__c> tes = TimeEntryApprovalController.getTimeEntries('ABCD1234XYZ1');
        // VERIFY
        System.assertEquals(2, tes.size(), 'size()');
    }

}
