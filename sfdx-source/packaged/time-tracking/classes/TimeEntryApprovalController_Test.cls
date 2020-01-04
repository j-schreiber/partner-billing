@isTest
class TimeEntryApprovalController_Test {

    @TestSetup
    static void makeData(){

        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

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
        Boolean isValid = TimeEntryApprovalController.validateAccessCode('ABCD');
        // VERIFY
        System.assertEquals(false, isValid, 'validateAccessCode(ABCD)');
    }

    @isTest
    static void validateAccessCode_RevokedCode_False() {
        // ACTION
        Boolean isValid = TimeEntryApprovalController.validateAccessCode('ABCD1234XYZ3');
        // VERIFY
        System.assertEquals(false, isValid, 'validateAccessCode(ABCD1234XYZ3)');
    }

}
