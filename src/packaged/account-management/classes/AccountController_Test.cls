@isTest
class AccountController_Test {

    @TestSetup
    static void makeData(){
        List<Account> accs = new List<Account>();
        accs.add(TestDataFactory.CreateAccount(new Account(Name='Test Company GmbH', CustomerId__c = '1')));
        accs.add(TestDataFactory.CreateAccount(new Account(Name='Special Test Company GmbH', CustomerId__c = '2')));
        insert accs;
    }

    @isTest
    static void getLatestCustomerId_NoAccounts_Returns0() {
        // SETUP
        delete [SELECT Id FROM Account];
        // ACTION
        Integer latestId = AccountController.getLatestCustomerId();
        // VERIFY
        System.assertEquals(0, latestId, 'getLatestCustomerId()');
    }

    @isTest
    static void getLatestCustomerId_AccountsWithSequentialIds_ReturnsHighestId() {
        // ACTION
        Integer latestId = AccountController.getLatestCustomerId();
        // VERIFY
        System.assertEquals(2, latestId, 'getLatestCustomerId()');
    }

    @isTest
    static void getLatestCustomerId_AccountsWithNonSequentialIds_ReturnsHighestId() {
        // SETUP
        insert TestDataFactory.CreateAccount(new Account(Name='Third Test Company GmbH', CustomerId__c = '10'));
        // ACTION
        Integer latestId = AccountController.getLatestCustomerId();
        // VERIFY
        System.assertEquals(10, latestId, 'getLatestCustomerId()');
    }

}
