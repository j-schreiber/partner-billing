@isTest
public class SObjectUtils_Test {

    @isTest
    static void getModifiedFields_NoModifications_EmptySet() {
        // SETUP
        Account originalAccount = TestDataFactory.CreateDefaultAccount();
        insert originalAccount;

        // ACTION
        originalAccount = [SELECT Id,Name,BillingStreet,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Id = :originalAccount.Id];
        Account modifiedAccount = [SELECT Id,Name,BillingStreet,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Id = :originalAccount.Id];
        Set<String> modifiedFields = SObjectUtils.getModifiedFields(modifiedAccount, originalAccount);

        // VERIFY
        System.assertEquals(new Set<String>(), modifiedFields, 'getModifiedFields()');
    }

    @isTest
    static void getModifiedFields_MultipleModifiedFields_AllFieldsIdentified() {
        // SETUP
        Account originalAccount = TestDataFactory.CreateDefaultAccount();
        insert originalAccount;

        // ACTION
        originalAccount = [SELECT Id,Name,BillingStreet,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Id = :originalAccount.Id];
        Account modifiedAccount = [SELECT Id,Name,BillingStreet,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Id = :originalAccount.Id];
        modifiedAccount.Name = 'New Name';
        modifiedAccount.BillingCity = 'Test City';

        // VERIFY
        System.assertEquals(new Set<String>{'Name', 'BillingCity'}, SObjectUtils.getModifiedFields(modifiedAccount, originalAccount), 'getModifiedFields(modified, original)');
        System.assertEquals(new Set<String>{'Name', 'BillingCity'}, SObjectUtils.getModifiedFields(originalAccount, modifiedAccount), 'getModifiedFields(original, modified)');
    }
}
