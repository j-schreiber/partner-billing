@isTest
public class TimeEntryTriggerHandler_Test {
    
    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        Budget__c b = TestDataFactory.CreateBudget(new Budget__c(Account__c = a.Id));
        insert b;

        Invoice__c inv = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));
        insert inv;
    }

    @isTest
    static void insert_NewTimeEntry_BudgetSummaryRecalculated() {
        // SETUP
        Budget__c b = [SELECT Id,Account__c FROM Budget__c LIMIT 1];
        TimeEntry__c toInsert = TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(
                Budget__c = b.Id,
                Account__c = b.Account__c,
                DailyRate__c = 1500.00,
                StartTime__c = Time.newInstance(8,0,0,0),
                EndTime__c = Time.newInstance(12,0,0,0),
                Status__c = 'New')
        );

        // ACTION
        Database.SaveResult sr = Database.insert(toInsert, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Budget__c newBudget = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c FROM Budget__c WHERE Id = :b.Id];
        System.assertEquals(750.00, newBudget.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(0, newBudget.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }

    @isTest
    static void insert_InvoicedTimeEntry_BudgetSummaryRecalculated() {
        // SETUP
        Budget__c b = [SELECT Id,Account__c FROM Budget__c LIMIT 1];
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];

        TimeEntry__c toInsert = TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(
                Budget__c = b.Id,
                Account__c = b.Account__c,
                Invoice__c = invoice.Id,
                DailyRate__c = 1500.00,
                StartTime__c = Time.newInstance(8,0,0,0),
                EndTime__c = Time.newInstance(12,0,0,0),
                Status__c = 'Approved')
        );

        // ACTION
        Database.SaveResult sr = Database.insert(toInsert, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Budget__c newBudget = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c FROM Budget__c WHERE Id = :b.Id];
        System.assertEquals(750.00, newBudget.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(750.00, newBudget.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }

    @isTest
    static void update_ChangeTotalAmount_BudgetSummaryRecalculated() {
        // SETUP
        Budget__c b = [SELECT Id,Account__c FROM Budget__c LIMIT 1];
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];

        TimeEntry__c toUpdate = TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(
                Budget__c = b.Id,
                Account__c = b.Account__c,
                DailyRate__c = 1500.00,
                StartTime__c = Time.newInstance(8,0,0,0),
                EndTime__c = Time.newInstance(12,0,0,0),
                Status__c = 'New')
        );
        insert toUpdate;

        // ACTION
        toUpdate.EndTime__c = Time.newInstance(13,0,0,0);
        toUpdate.DailyRate__c = 1600;
        update toUpdate;

        toUpdate.Invoice__c = invoice.Id;

        Database.SaveResult sr = Database.update(toUpdate, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        Budget__c newBudget = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c FROM Budget__c WHERE Id = :b.Id];
        System.assertEquals(1000.00, newBudget.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(1000.00, newBudget.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }

    @isTest
    static void update_NoInvoiceRelated_UpdateSucceeds() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        TimeEntry__c teUnderTest = TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id));
        insert teUnderTest;

        // ACTION
        teUnderTest.Status__c = 'Approved';
        teUnderTest.StartTime__c = Time.newInstance(8,0,0,0);
        teUnderTest.EndTime__c = Time.newInstance(13,30,0,0);
        Database.SaveResult sr = Database.update(teUnderTest, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
    }

    @isTest
    static void update_AuditableFields_InvoiceRelated_UpdateBlocked() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];

        TimeEntry__c teUnderTest = TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, Invoice__c = invoice.Id));
        insert teUnderTest;

        // ACTION
        teUnderTest.Status__c = 'Approved';
        teUnderTest.StartTime__c = Time.newInstance(8,0,0,0);
        teUnderTest.EndTime__c = Time.newInstance(13,30,0,0);
        Database.SaveResult sr = Database.update(teUnderTest, false);

        // VERIFY
        System.assertEquals(false, sr.isSuccess(), sr.getErrors());
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, sr.getErrors()[0].getStatusCode(), 'sr.getErrors()[0].getStatusCode()');
    }

    @isTest
    static void update_NonAuditableFields_InvoiceRelated_UpdateSuccessfull() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];

        TimeEntry__c teUnderTest = TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, Invoice__c = invoice.Id));
        insert teUnderTest;

        // ACTION
        teUnderTest.Status__c = 'Approved';
        teUnderTest.Description__c = 'Random Text';
        Database.SaveResult sr = Database.update(teUnderTest, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), sr.getErrors());
        //System.assertEquals()
    }

    @isTest
    static void update_InvoiceRelated_RemoveInvoice_UpdateBlocked() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];

        TimeEntry__c teUnderTest = TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, Invoice__c = invoice.Id));
        insert teUnderTest;

        // ACTION
        teUnderTest.Invoice__c = null;
        Database.SaveResult sr = Database.update(teUnderTest, false);

        // VERIFY
        System.assertEquals(false, sr.isSuccess(), sr.getErrors());
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, sr.getErrors()[0].getStatusCode(), 'sr.getErrors()[0].getStatusCode()');
        System.assertEquals(Label.Message_TimeEntryValidation_CanNotRemoveInvoice, sr.getErrors()[0].getMessage(), 'sr.getErrors()[0].getMessage()');
    }

    @isTest
    static void update_CancelledInvoiceRelated_RemoveInvoice_UpdateAllowed() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c invoice = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c = Constants.INVOICE_STATUS_CANCELLED));
        insert invoice;

        TimeEntry__c teUnderTest = TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id, Invoice__c = invoice.Id));
        insert teUnderTest;

        // ACTION
        teUnderTest.Invoice__c = null;
        Database.SaveResult sr = Database.update(teUnderTest, false);

        // VERIFY
        System.assertEquals(true, sr.isSuccess(), 'isSuccess()' + sr.getErrors());
        TimeEntry__c actualTe = [SELECT Id,Invoice__c FROM TimeEntry__c WHERE Id = : teUnderTest.Id];
        System.assertEquals(null, actualTe.Invoice__c, 'TimeEntry__c.Invoice__c');
    }

    @isTest
    static void delete_ValidTimeEntry_BudgetSummaryRecalculated() {
        // SETUP
        Budget__c b = [SELECT Id,Account__c FROM Budget__c LIMIT 1];
        TimeEntry__c toDelete = TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(
                Budget__c = b.Id,
                Account__c = b.Account__c,
                DailyRate__c = 1500.00,
                StartTime__c = Time.newInstance(8,0,0,0),
                EndTime__c = Time.newInstance(12,0,0,0),
                Status__c = 'New')
        );
        insert toDelete;

        // ACTION
        Database.DeleteResult dr = Database.delete(toDelete, false);

        // VERIFY
        System.assertEquals(true, dr.isSuccess(), dr.getErrors());
        Budget__c newBudget = [SELECT Id,TotalAmountLogged__c,TotalAmountInvoiced__c FROM Budget__c WHERE Id = :b.Id];
        System.assertEquals(0.00, newBudget.TotalAmountLogged__c, 'TotalAmountLogged__c');
        System.assertEquals(0.00, newBudget.TotalAmountInvoiced__c, 'TotalAmountInvoiced__c');
    }

    @isTest
    static void delete_InvoicedTimeEntry_DeleteBlocked() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];
        TimeEntry__c teUnderTest = TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id,Invoice__c = invoice.Id));
        insert teUnderTest;

        // ACTION
        Database.DeleteResult dr = Database.delete(teUnderTest, false);

        // VERIFY
        System.assertEquals(false, dr.isSuccess(), 'DeleteResult.isSuccess()');
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, dr.getErrors()[0].getStatusCode(), 'dr.getErrors()[0].getStatusCode()');
        System.assertEquals(Label.Message_TimeEntryValidation_CanNotDeleteRecord, dr.getErrors()[0].getMessage(), 'dr.getErrors()[0].getMessage()');
    }

    @isTest
    static void delete_InvoicedTimeEntry_CancelledInvoice_DeleteAllowed() {
        // SETUP
        Account a = [SELECT Id FROM Account LIMIT 1];
        Invoice__c invoice = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id, Status__c = Constants.INVOICE_STATUS_CANCELLED));

        TimeEntry__c teUnderTest = TestDataFactory.CreateTimeEntry(new TimeEntry__c(Account__c = a.Id,Invoice__c = invoice.Id));
        insert teUnderTest;

        // ACTION
        Database.DeleteResult dr = Database.delete(teUnderTest, false);

        // VERIFY
        System.assertEquals(true, dr.isSuccess(), 'isSuccess(): ' + dr.getErrors());
    }
}
