@isTest
public class InvoiceTriggerHandler_Test {

    @isTest
    static void insert_BlankInvoice_DmlException() {
        // SETUP
        Invoice__c inv = new Invoice__c();

        // ACTION
        Database.SaveResult sr = Database.insert(inv, false);

        // VERIFY
        System.assertEquals(false, sr.isSuccess(), 'isSuccess()');
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, sr.getErrors()[0].getStatusCode(), 'getErrors()[0].getStatusCode()');
        System.assertEquals('Account__c', sr.getErrors()[0].getFields()[0], 'getErrors()[0].getFields()[0]');
    }
    
    @isTest
    static void insert_NoBillingAddressInAccount_NoBillingAddresInInvoice_EmptyValues() {
        // SETUP
        Account a = TestDataFactory.CreateAccount(new Account(BillingStreet = null, BillingPostalCode = null, BillingCity = null, BillingCountryCode = null, BillingStateCode = null));
        insert a;
        Invoice__c inv = new Invoice__c(Account__c = a.Id, Status__c = 'Draft');

        // ACTION
        Database.SaveResult sr = Database.insert(inv, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Invoice__c actualInv = [SELECT Id,BillingStreet__c,BillingPostalCode__c,BillingCity__c,BillingCountry__c,BillingState__c FROM Invoice__c WHERE Id =:inv.Id];
        System.assertEquals(null, actualInv.BillingStreet__c, 'BillingStreet__c');
        System.assertEquals(null, actualInv.BillingPostalCode__c, 'BillingPostalCode__c');
        System.assertEquals(null, actualInv.BillingCity__c, 'BillingCity__c');
        System.assertEquals(null, actualInv.BillingCountry__c, 'BillingCountry__c');
        System.assertEquals(null, actualInv.BillingState__c, 'BillingState__c');
    }

    @isTest
    static void insert_ValidBillingAddressInAccount_NoBillingAddressInInvoice_AllValuesCopied() {
        // SETUP
        Account a = TestDataFactory.CreateAccount(
            new Account(BillingStreet = 'Teststraße 1', BillingPostalCode = '80336', BillingCity = 'München', BillingCountryCode = 'DE')
        );
        insert a;
        Invoice__c inv = new Invoice__c(Account__c = a.Id, Status__c = 'Draft');

        // ACTION
        Database.SaveResult sr = Database.insert(inv, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Invoice__c actualInv = [SELECT Id,BillingStreet__c,BillingPostalCode__c,BillingCity__c,BillingCountry__c,BillingState__c FROM Invoice__c WHERE Id =:inv.Id];
        a = [SELECT Id,BillingStreet,BillingPostalCode,BillingCity,BillingCountry FROM Account WHERE Id = :a.Id];
        System.assertEquals(a.BillingStreet, actualInv.BillingStreet__c, 'BillingStreet__c');
        System.assertEquals(a.BillingPostalCode, actualInv.BillingPostalCode__c, 'BillingPostalCode__c');
        System.assertEquals(a.BillingCity, actualInv.BillingCity__c, 'BillingCity__c');
        System.assertEquals(a.BillingCountry, actualInv.BillingCountry__c, 'BillingCountry__c');
    }

    @isTest
    static void insert_ValidBillingAddressInAccount_BillingAddressInInvoice_KeepOriginalValues() {
        // SETUP
        Account a = TestDataFactory.CreateAccount(
            new Account(BillingStreet = 'Teststraße 1', BillingPostalCode = '80336', BillingCity = 'München', BillingCountryCode = 'DE')
        );
        insert a;

        Invoice__c inv = new Invoice__c(
            Account__c = a.Id,
            Status__c = 'Draft',
            BillingStreet__c='Rechnungsstraße 1',
            BillingPostalCode__c='81667',
            BillingCity__c='Augsburg',
            BillingCountry__c='Deutschland'
        );

        // ACTION
        Database.SaveResult sr = Database.insert(inv, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Invoice__c actualInv = [SELECT Id,BillingStreet__c,BillingPostalCode__c,BillingCity__c,BillingCountry__c,BillingState__c FROM Invoice__c WHERE Id =:inv.Id];
        a = [SELECT Id,BillingStreet,BillingPostalCode,BillingCity,BillingCountry FROM Account WHERE Id = :a.Id];
        System.assertEquals('Rechnungsstraße 1', actualInv.BillingStreet__c, 'BillingStreet__c');
        System.assertEquals('81667', actualInv.BillingPostalCode__c, 'BillingPostalCode__c');
        System.assertEquals('Augsburg', actualInv.BillingCity__c, 'BillingCity__c');
        System.assertEquals('Deutschland', actualInv.BillingCountry__c, 'BillingCountry__c');
    }
}
