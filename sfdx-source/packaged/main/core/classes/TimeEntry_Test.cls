@isTest
public class TimeEntry_Test {

    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.CreateDefaultAccount();
        insert a;

        Budget__c b = TestDataFactory.CreateBudget(new Budget__c(Account__c = a.Id));
        insert b;

        Invoice__c i = TestDataFactory.CreateInvoice(new Invoice__c(Account__c = a.Id));
        insert i;

        Product2 p = TestDataFactory.CreateDefaultProduct();
        insert p;
    }
    
    @isTest
    static void init_ValidRecord_AllDefaultsInitialized() {
        // SETUP
        Account a = [SELECT Id,Name FROM Account LIMIT 1];
        Budget__c b = [SELECT Id FROM Budget__c LIMIT 1];
        Invoice__c i = [SELECT Id FROM Invoice__c LIMIT 1];
        Product2 p = [SELECT Id,Name FROM Product2 LIMIT 1];

        TimeEntry__c te = TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(
                Account__c = a.Id,
                Budget__c = b.Id,
                Invoice__c = i.Id,
                Product__c = p.Id
            )
        );
        insert te;

        // ACTION
        te = Database.Query(TimeEntry.QUERY_STRING + ' LIMIT 1');
        TimeEntry objUnderTest = new TimeEntry(te);

        // VERIFY
        System.assertEquals(a.Name, objUnderTest.AccountName, 'AccountName');
        System.assertEquals(p.Name, objUnderTest.ProductName, 'ProductName');
        System.assertEquals(te.Name, objUnderTest.Name, 'Name');
        System.assertEquals(te.Id, objUnderTest.Id, 'Id');
        System.assertEquals(te.Duration__c + ' h', objUnderTest.Duration, 'Duration');
        System.assertEquals(te.StartTime__c, objUnderTest.StartTime, 'StartTime');
        System.assertEquals(te.EndTime__c, objUnderTest.EndTime, 'EndTime');
        System.assertEquals(te.TotalAmount__c, objUnderTest.TotalAmount, 'TotalAmount');
        System.assertEquals(te.DailyRate__c, objUnderTest.DailyRate, 'DailyRate');
        System.assertEquals(te.Date__c, objUnderTest.ServiceDate, 'ServiceDate');
        System.assertEquals(te.Description__c, objUnderTest.Description, 'Description');
    }
}
