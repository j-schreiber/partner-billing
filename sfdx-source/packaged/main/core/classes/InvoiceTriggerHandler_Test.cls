@isTest
public class InvoiceTriggerHandler_Test {

    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateAccount(
            new Account(BillingStreet = 'Teststraße 1', BillingPostalCode = '80336', BillingCity = 'München', BillingCountryCode = 'DE')
        );
        insert a;

        List<OrganizationProfile__c> orgProfiles = new List<OrganizationProfile__c>();
        orgProfiles.add(TestDataFactory.CreateDefaultOrganizationProfile());
        orgProfiles.add(TestDataFactory.CreateOrganizationProfile(new OrganizationProfile__c(IsDefault__c = false, Name = 'Test Profile #1')));
        orgProfiles.add(TestDataFactory.CreateOrganizationProfile(new OrganizationProfile__c(IsDefault__c = false, Name = 'Test Profile #2')));
        insert orgProfiles;
    }

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
    static void insert_NewBlankInvoices_NoUnnecessaryQueryExecutions() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        List<Invoice__c> invs = new List<Invoice__c>();
        for (Integer i = 0; i < 10; i++) invs.add(TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id)));

        // ACTION
        Test.startTest();
        Database.SaveResult[] srs = Database.insert(invs, false);

        // VERIFY
        // Accounts and Org Profiles have been queried
        System.assertEquals(2, Limits.getQueries(), 'getQueries()');
        Test.stopTest();
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
        Account a = [SELECT Id FROM Account LIMIT 1];
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
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(
            Account__c = a.Id,BillingStreet__c='Rechnungsstraße 1',BillingPostalCode__c='81667',BillingCity__c='Augsburg',BillingCountry__c='Deutschland')
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

    @isTest
    static void insert_OrgProfilesExist_DefaultProfileAdded() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));

        // ACTION
        Database.SaveResult sr = Database.insert(inv, false);

        // VERIFY
        Invoice__c actualInv = [SELECT Id,OrganizationProfile__c FROM Invoice__c WHERE Id = :inv.Id];
        OrganizationProfile__c expectedProfile = [SELECT Id FROM OrganizationProfile__c WHERE IsDefault__c = true];
        System.assertEquals(expectedProfile.Id, actualInv.OrganizationProfile__c, 'OrganizationProfile__c');
    }

    @isTest
    static void insert_NoOrgProfilesExist_NoOperation() {
        // SETUP
        delete [SELECT Id FROM OrganizationProfile__c];
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));

        // ACTION
        Database.SaveResult sr = Database.insert(inv, false);

        // VERIFY
        Invoice__c actualInv = [SELECT Id,OrganizationProfile__c FROM Invoice__c WHERE Id = :inv.Id];
        System.assertEquals(null, actualInv.OrganizationProfile__c, 'OrganizationProfile__c');
    }

    @isTest
    static void update_InvoiceWithTimeEntries_StatusToCancelled_AllTimeEntriesRemoved() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));
        insert inv;

        List<TimeEntry__c> tes = new List<TimeEntry__c>();
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, Invoice__c = inv.Id)));
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, Invoice__c = inv.Id)));
        tes.add(TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, Invoice__c = inv.Id)));
        insert tes;

        // ACTION
        inv.Status__c = Constants.INVOICE_STATUS_CANCELLED;
        update inv;

        // VERIFY
        System.assertEquals(0, [SELECT COUNT() FROM TimeEntry__c WHERE Invoice__c = :inv.Id], 'COUNT() WHERE Invoice__c');
        System.assertEquals(tes.size(), [SELECT COUNT() FROM TimeEntry__c], 'COUNT()');
    }

    @isTest
    static void update_InvoiceWithoutTimeEntries_StatusToCancelled_NoSideEffects() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));
        insert inv;

        // ACTION
        inv.Status__c = Constants.INVOICE_STATUS_CANCELLED;
        update inv;

        // VERIFY
        System.assertEquals(0, [SELECT COUNT() FROM TimeEntry__c WHERE Invoice__c = :inv.Id], 'COUNT() WHERE Invoice__c');
    }

    @isTest
    static void update_DraftInvoice_UpdateStatusToActivated_NoSpecialPermission_SaveSuccessful() {
        // SETUP
        User userWithoutPermission = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(userWithoutPermission, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        System.runAs(userWithoutPermission) {

            // VERIFY PERMISSION
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');

            // ACTION
            Account a = TestDataFactory.CreateAccount(new Account(Name='Permission Testing GmbH', BillingCity='Permcity'));
            insert a;

            Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c = Constants.INVOICE_STATUS_DRAFT));
            insert inv;

            // Status__c = Activated
            inv.Status__c = Constants.INVOICE_STATUS_ACTIVATED;
            Database.SaveResult sr = Database.update(inv, false);
            System.assertEquals(true, sr.isSuccess(), 'sr.isSuccess(): ' + sr.getErrors());
        }
    }

    @isTest
    static void update_ActivatedInvoice_ModifyLockedField_NoSpecialPermission_RecordLocked() {
        // SETUP
        User userWithoutPermission = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(userWithoutPermission, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        System.runAs(userWithoutPermission) {

            // VERIFY PERMISSION
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');

            // ACTION
            Account a = TestDataFactory.CreateAccount(new Account(Name='Permission Testing GmbH', BillingCity='Permcity'));
            insert a;

            Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c = Constants.INVOICE_STATUS_ACTIVATED));
            insert inv;

            // Date__c
            inv.Date__c = Date.newInstance(2019, 11, 24);
            Database.SaveResult sr = Database.update(inv, false);
            System.assertEquals(false, sr.isSuccess(), 'sr.isSuccess()');
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, sr.getErrors()[0].getStatusCode(), 'sr.getErrors()[0].getStatusCode()');
            System.assertEquals(Label.Message_InvoiceValidation_CanNotEditLockedField, sr.getErrors()[0].getMessage(), 'sr.getErrors()[0].getMessage()');
        }
    }

    @isTest
    static void update_ActivatedInvoice_ModifyLockedField_HasSpecialPermission_SaveSuccessful() {
         // SETUP
        User userWithPermission = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(userWithPermission, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess', 'PartnerBilling_Administrator'});

        System.runAs(userWithPermission) {

            // VERIFY PERMISSION
            System.assertEquals(true, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');

            // ACTION
            Account a = TestDataFactory.CreateAccount(new Account(Name='Permission Testing GmbH', BillingCity='Permcity'));
            insert a;

            Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c = Constants.INVOICE_STATUS_ACTIVATED));
            insert inv;

            // Date__c
            inv.Date__c = Date.newInstance(2019, 11, 24);
            Database.SaveResult sr = Database.update(inv, false);
            System.assertEquals(true, sr.isSuccess(), 'sr.isSuccess(): ' + sr.getErrors());
        }
    }

    @isTest
    static void update_CancelledInvoice_ModifyLockedField_NoSpecialPermission_RecordLocked() {
        // SETUP
        User userWithoutPermission = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(userWithoutPermission, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        System.runAs(userWithoutPermission) {

            // VERIFY PERMISSION
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');

            // ACTION
            Account a = TestDataFactory.CreateAccount(new Account(Name='Permission Testing GmbH', BillingCity='Permcity'));
            insert a;

            Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c = Constants.INVOICE_STATUS_CANCELLED));
            insert inv;

            // Date__c
            inv.Date__c = Date.newInstance(2019, 11, 24);
            Database.SaveResult sr = Database.update(inv, false);
            System.assertEquals(false, sr.isSuccess(), 'sr.isSuccess()');
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, sr.getErrors()[0].getStatusCode(), 'sr.getErrors()[0].getStatusCode()');
            System.assertEquals(Label.Message_InvoiceValidation_CanNotEditLockedField, sr.getErrors()[0].getMessage(), 'sr.getErrors()[0].getMessage()');
        }
    }

    @isTest
    static void update_DraftInvoice_ModifyLockedField_NoSpecialPermission_SaveSuccessful() {
        // SETUP
        User userWithoutPermission = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(userWithoutPermission, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        System.runAs(userWithoutPermission) {

            // VERIFY PERMISSION
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');

            // ACTION
            Account a = TestDataFactory.CreateAccount(new Account(Name='Permission Testing GmbH', BillingCity='Permcity'));
            insert a;

            Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c = Constants.INVOICE_STATUS_DRAFT));
            insert inv;

            // Date__c
            inv.Date__c = Date.newInstance(2019, 11, 24);
            Database.SaveResult sr = Database.update(inv, false);
            System.assertEquals(true, sr.isSuccess(), 'sr.isSuccess(): ' + sr.getErrors());
        }
    }

    @isTest
    static void update_ModifyLockedField_PdfSettingDelete_DocumentsDeleted() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];

        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, PDFSyncSettings__c = Constants.INVOICE_PDF_SETTING_DELETE));
        insert inv;

        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion existingVersion = new ContentVersion(Title='Test',PathOnClient='Test.pdf', VersionData=pdfMock);
        insert existingVersion;

        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Title = 'Test' LIMIT 1];
        insert new ContentDocumentLink(LinkedEntityId=inv.Id, ContentDocumentId=contentDoc.Id, ShareType='V');

        // ACTION
        inv.Date__c = System.today();
        inv.BillingCountry__c = 'England';
        Database.SaveResult sr = Database.update(inv, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocument], 'COUNT() FROM ContentDocument');
    }

    @isTest
    static void update_ModifySettingToDeactivated_PdfSettingDelete_DocumentsPersist() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];

        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, PDFSyncSettings__c = Constants.INVOICE_PDF_SETTING_DELETE));
        insert inv;

        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion existingVersion = new ContentVersion(Title='Test',PathOnClient='Test.pdf', VersionData=pdfMock);
        insert existingVersion;

        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Title = 'Test' LIMIT 1];
        insert new ContentDocumentLink(LinkedEntityId=inv.Id, ContentDocumentId=contentDoc.Id, ShareType='V');

        // ACTION
        inv.PDFSyncSettings__c = Constants.INVOICE_PDF_SETTING_DEACTIVATED;
        Database.SaveResult sr = Database.update(inv, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocument], 'COUNT() FROM ContentDocument');
    }

    @isTest
    static void update_ModifyLockedField_PdfSettingDeactivated_DocumentsPersist() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];

        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, PDFSyncSettings__c = Constants.INVOICE_PDF_SETTING_DEACTIVATED));
        insert inv;

        Blob pdfMock = Blob.valueOf('Teststring');
        ContentVersion existingVersion = new ContentVersion(Title='Test',PathOnClient='Test.pdf', VersionData=pdfMock);
        insert existingVersion;

        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Title = 'Test' LIMIT 1];
        insert new ContentDocumentLink(LinkedEntityId=inv.Id, ContentDocumentId=contentDoc.Id, ShareType='V');

        // ACTION
        inv.Date__c = System.today();
        inv.BillingCountry__c = 'England';
        Database.SaveResult sr = Database.update(inv, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocument], 'COUNT() FROM ContentDocument');
    }

}
