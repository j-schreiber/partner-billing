@isTest
class InvoiceLineItemTriggerHandler_Test {
    
    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_DRAFT));
        insert i;
    }

    @isTest
    static void insert_DraftInvoice_NoSpecialPermissions_SaveSuccessful() {
        // SETUP
        User uNoPermissions = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(uNoPermissions, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        
        System.runAs(uNoPermissions) {
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');
            
            // SETUP
            Account a = TestDataFactory.CreateDefaultAccount();
            insert a;
            Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_DRAFT));
            insert i;
            InvoiceLineItem__c ili = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c=i.Id));

            // ACTION
            Database.SaveResult sr = Database.insert(ili, false);

            // VERIFY
            System.assertEquals(true, sr.isSuccess(), 'isSuccess()');
        }
    }

    @isTest
    static void insert_LockedInvoice_NoSpecialPermissions_SaveBlocked() {
        // SETUP
        User uNoPermissions = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(uNoPermissions, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        
        System.runAs(uNoPermissions) {
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');
            
            // SETUP
            Account a = TestDataFactory.CreateDefaultAccount();
            insert a;
            Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_ACTIVATED));
            insert i;
            InvoiceLineItem__c ili = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c=i.Id, Price__c = 0, Quantity__c = 0));

            // ACTION
            Database.SaveResult sr = Database.insert(ili, false);

            // VERIFY
            System.assertEquals(false, sr.isSuccess(), 'isSuccess()');
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, sr.getErrors()[0].getStatusCode(), 'sr.getErrors()[0].getStatusCode()');
            System.assertEquals(Label.Message_LineItemValidation_CanNotInsertWhenLocked, sr.getErrors()[0].getMessage(), 'sr.getErrors()[0].getMessage()');
        }
    }

    @isTest
    static void insert_LockedInvoice_HasSpecialPermissions_SaveSuccessful() {
        // SETUP
        User uHasPermissions = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(uHasPermissions, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess', 'PartnerBilling_Administrator'});

        
        System.runAs(uHasPermissions) {
            System.assertEquals(true, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');
            
            // SETUP
            Account a = TestDataFactory.CreateDefaultAccount();
            insert a;
            Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_ACTIVATED));
            insert i;
            InvoiceLineItem__c ili = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c=i.Id, Price__c = 0, Quantity__c = 0));

            // ACTION
            Database.SaveResult sr = Database.insert(ili, false);

            // VERIFY
            System.assertEquals(true, sr.isSuccess(), 'isSuccess()');
        }
    }

    @isTest
    static void delete_DraftInvoice_NoSpecialPermissions_DeleteSuccessful() {
        // SETUP
        User uNoPermissions = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(uNoPermissions, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        System.runAs(uNoPermissions) {
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');

            // SETUP
            Account a = TestDataFactory.CreateDefaultAccount();
            insert a;
            Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_DRAFT));
            insert i;
            InvoiceLineItem__c ili = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c=i.Id, Price__c = 0, Quantity__c = 0));
            insert ili;

            // ACTION
            Database.DeleteResult dr = Database.delete(ili, false);

            // VERIFY
            System.assertEquals(true, dr.isSuccess(), 'isSuccess()');
        }
    }

    @isTest
    static void delete_LockedInvoice_NoSpecialPermissions_DeleteBlocked() {
        // SETUP
        User uNoPermissions = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(uNoPermissions, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        System.runAs(uNoPermissions) {
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');

            // SETUP
            Account a = TestDataFactory.CreateDefaultAccount();
            insert a;
            Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_DRAFT));
            insert i;
            InvoiceLineItem__c ili = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c=i.Id, Price__c = 0, Quantity__c = 0));
            insert ili;
            i.Status__c = Constants.INVOICE_STATUS_ACTIVATED;
            update i;

            // ACTION
            Database.DeleteResult dr = Database.delete(ili, false);

            // VERIFY
            System.assertEquals(false, dr.isSuccess(), 'isSuccess()');
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, dr.getErrors()[0].getStatusCode(), 'dr.getErrors()[0].getStatusCode()');
            System.assertEquals(Label.Message_LineItemValidation_CanNotDeleteWhenLocked, dr.getErrors()[0].getMessage(), 'dr.getErrors()[0].getMessage()');
        }
    }

    @isTest
    static void delete_LockedInvoice_SpecialPermissions_DeleteSuccessful() {
        // SETUP
        User uHasPermissions = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(uHasPermissions, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess','PartnerBilling_Administrator'});

        System.runAs(uHasPermissions) {
            System.assertEquals(true, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');

            // SETUP
            Account a = TestDataFactory.CreateDefaultAccount();
            insert a;
            Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_DRAFT));
            insert i;
            InvoiceLineItem__c ili = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c=i.Id, Price__c = 0, Quantity__c = 0));
            insert ili;
            i.Status__c = Constants.INVOICE_STATUS_ACTIVATED;
            update i;

            // ACTION
            Database.DeleteResult dr = Database.delete(ili, false);

            // VERIFY
            System.assertEquals(true, dr.isSuccess(), 'isSuccess()');
        }
    }

    @isTest
    static void update_DraftInvoice_NoSpecialPermissions_SaveSuccessful() {
        // SETUP
        User uNoPermissions = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(uNoPermissions, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        
        System.runAs(uNoPermissions) {
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');
            
            // SETUP
            Account a = TestDataFactory.CreateDefaultAccount();
            insert a;
            Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_DRAFT));
            insert i;
            InvoiceLineItem__c ili = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c=i.Id, Price__c = 0, Quantity__c = 0));
            insert ili;

            // ACTION
            ili.Price__c = 100;
            ili.Quantity__c = 1;
            ili.Discount__c = 100;
            Database.SaveResult sr = Database.update(ili, false);

            // VERIFY
            System.assertEquals(true, sr.isSuccess(), 'isSuccess()');
        }
    }

    @isTest
    static void update_LockedInvoice_SpecialPermissions_UpdateSuccessful() {
        // SETUP
        User uHasPermissions = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(uHasPermissions, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess', 'PartnerBilling_Administrator'});
        
        System.runAs(uHasPermissions) {
            System.assertEquals(true, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');
            
            // SETUP
            Account a = TestDataFactory.CreateDefaultAccount();
            insert a;
            Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_DRAFT));
            insert i;
            InvoiceLineItem__c ili = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c=i.Id, Price__c = 0, Quantity__c = 0));
            insert ili;
            i.Status__c = Constants.INVOICE_STATUS_ACTIVATED;
            update i;

            // ACTION
            ili.Price__c = 100;
            ili.Quantity__c = 1;
            ili.Discount__c = 0;
            Database.SaveResult sr = Database.update(ili, false);

            // VERIFY
            System.assertEquals(true, sr.isSuccess(), 'isSuccess()');
        }
    }

    @isTest
    static void update_LockedInvoice_NoSpecialPermissions_UpdateBlocked() {
        // SETUP
        User uNoPermissions = TestDataFactory.CreateDefaultUser();
        TestPermissionFactory.setupPermissions(uNoPermissions, new List<String>{'PartnerBilling_Core_FullAccess','PartnerBilling_Invoicing_FullAccess'});

        
        System.runAs(uNoPermissions) {
            System.assertEquals(false, FeatureManagement.checkPermission('Modify_Activated_Invoices'), 'checkPermission(Modify_Activated_Invoices)');
            
            // SETUP
            Account a = TestDataFactory.CreateDefaultAccount();
            insert a;
            Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c=Constants.INVOICE_STATUS_DRAFT));
            insert i;
            InvoiceLineItem__c ili = TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(Invoice__c=i.Id, Price__c = 0, Quantity__c = 0));
            insert ili;
            i.Status__c = Constants.INVOICE_STATUS_ACTIVATED;
            update i;

            // ACTION
            ili.Price__c = 100;
            ili.Quantity__c = 1;
            ili.Discount__c = 100;
            Database.SaveResult sr = Database.update(ili, false);

            // VERIFY
            System.assertEquals(false, sr.isSuccess(), 'isSuccess()');
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, sr.getErrors()[0].getStatusCode(), 'sr.getErrors()[0].getStatusCode()');
            System.assertEquals(Label.Message_LineItemValidation_CanNotEditFieldsWhenLocked, sr.getErrors()[0].getMessage(), 'sr.getErrors()[0].getMessage()');
        }
    }
}
