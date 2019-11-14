@isTest
class SenderAddress_Test {
    
    @isTest
    static void init_User_AllDefaultsInitialized() {
        // SETUP
        User u = [SELECT Id,Email,Name FROM User WHERE Id = :UserInfo.getUserId()];
        // ACTION
        SenderAddress sa = new SenderAddress(u);
        // VERIFY
        System.assertEquals(u.Email, sa.Email, 'Email');
        System.assertEquals(u.Name, sa.Name, 'Name');
        System.assertEquals(u.Id, sa.SenderId, 'SenderId');
        System.assertEquals('User', sa.Type, 'Type');
    }

    @isTest
    static void init_OrgWideEmail_AllDefaultsInitialized() {
        // SETUP
        OrgWideEmailAddress owea = new OrgWideEmailAddress(DisplayName='Test Org Wide', Address='info@example.de');
        // ACTION
        SenderAddress sa = new SenderAddress(owea);
        // VERIFY
        System.assertEquals(owea.Address, sa.Email, 'Email');
        System.assertEquals(owea.DisplayName, sa.Name, 'Name');
        System.assertEquals('OrgWideAddress', sa.Type, 'Type');
    }
}
