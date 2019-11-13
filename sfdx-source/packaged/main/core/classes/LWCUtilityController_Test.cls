@isTest
public class LWCUtilityController_Test {

    @TestSetup
    static void makeData(){
        List<Account> accs = new List<Account>();
        accs.add(TestDataFactory.CreateAccount(new Account(Name = 'Test Company A Ltd.')));
        accs.add(TestDataFactory.CreateAccount(new Account(Name = 'Test Company B Ltd.')));
        insert accs;

        List<Contact> cs = new List<Contact>();
        cs.add(TestDataFactory.CreateContact(new Contact(AccountId = accs[0].Id, LastName = 'Tester A', FirstName = 'Albert', IsBillingContact__c = true)));
        cs.add(TestDataFactory.CreateContact(new Contact(AccountId = accs[0].Id, LastName = 'Tester B', FirstName = 'Bertram', IsBillingContact__c = true)));
        cs.add(TestDataFactory.CreateContact(new Contact(AccountId = accs[0].Id, LastName = 'Tester C', FirstName = 'Charlie', IsBillingContact__c = false)));
        cs.add(TestDataFactory.CreateContact(new Contact(AccountId = accs[0].Id, LastName = 'Tester D', FirstName = 'Dieter', IsBillingContact__c = false)));
        cs.add(TestDataFactory.CreateContact(new Contact(AccountId = accs[1].Id, LastName = 'Tester E', FirstName = 'Engelbert', IsBillingContact__c = true)));
        cs.add(TestDataFactory.CreateContact(new Contact(AccountId = accs[1].Id, LastName = 'Tester F', FirstName = 'Frank', IsBillingContact__c = true)));
        cs.add(TestDataFactory.CreateContact(new Contact(AccountId = accs[1].Id, LastName = 'Tester G', FirstName = 'Gustav', IsBillingContact__c = false)));
        cs.add(TestDataFactory.CreateContact(new Contact(AccountId = accs[1].Id, LastName = 'Tester H', FirstName = 'Hubert', IsBillingContact__c = false)));
        insert cs;
    }
    
    @isTest
    static void getMailTemplates_ZeroTemplates_EmptyList() {

    }

    @isTest
    static void getMailTemplates_TemplatesInFolder_AllTemplatesReturned() {
        
    }

    @isTest
    static void findBillingContacts_EmptySearchString_AllBillingContactsToAccountReturned() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];

        // ACTION
        Map<Id,Contact> searchResultsEmpty = new Map<Id, Contact>(LWCUtilityController.findBillingContacts('', a.Id));
        Map<Id,Contact> searchResultsNull = new Map<Id, Contact>(LWCUtilityController.findBillingContacts(null, a.Id));
        Map<Id,Contact> searchResults1Char = new Map<Id, Contact>(LWCUtilityController.findBillingContacts('Z', a.Id));

        // VERIFY
        Map<Id, Contact> expectedContacts = new Map<Id, Contact>([SELECT Id FROM Contact WHERE IsBillingContact__c = true AND AccountId = :a.Id]);
        System.assertEquals(expectedContacts.keySet(), searchResultsEmpty.keySet(), 'searchResultsEmpty.keySet()');
        System.assertEquals(expectedContacts.keySet(), searchResultsNull.keySet(), 'searchResultsNull.keySet()');
        System.assertEquals(expectedContacts.keySet(), searchResults1Char.keySet(), 'searchResults1Char.keySet()');

        Map<String, Object> populatedFields = searchResultsEmpty.values()[0].getPopulatedFieldsAsMap();
        System.assertEquals(new Set<String>{'Id', 'Name','Account', 'AccountId'}, populatedFields.keySet(), 'populatedFields.keySet()');
    }

    @isTest
    static void findBillingContacts_WildcardSearchString_AllBillingContactsToAccountReturned() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        // ACTION
        Map<Id,Contact> searchResults = new Map<Id, Contact>(LWCUtilityController.findBillingContacts('*', a.Id));
        // VERIFY
        Map<Id, Contact> expectedContacts = new Map<Id, Contact>([SELECT Id FROM Contact WHERE IsBillingContact__c = true AND AccountId = :a.Id]);
        System.assertEquals(expectedContacts.keySet(), searchResults.keySet(), 'searchResults.keySet()');
    }

    @isTest
    static void findBillingContacts_ValidSearchString_FilteredBillingContactsToAccountReturned() {
        // SETUP
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Company A Ltd.' LIMIT 1];
        // ACTION
        Map<Id,Contact> searchResults = new Map<Id, Contact>(LWCUtilityController.findBillingContacts('Albert', a.Id));
        // VERIFY
        List<List<SObject>> expectedContacts = [FIND 'Albert' IN ALL FIELDS RETURNING Contact(Id WHERE IsBillingContact__c = true AND AccountId = :a.Id)];
        System.assertEquals(expectedContacts[0].size(), searchResults.size(), 'searchResults.size()');
    }
}
