/** @Description
*   Test Data Factory provides static methods to create valid test data. All unit tests are
*   expected to always use creation methods from test data factory. If new validation rules or
*   integrity restrictions (required fields) appear, they are satisfied here.
*/
public class TestDataFactory {

    public static Account CreateDefaultAccount() {
        return new Account(Name = 'Test Company GmbH',
                           BillingStreet = 'Phantasiestr. 1',
                           BillingCity = 'München',
                           BillingPostalCode = '81827',
                           AccountSource = 'Testing');
    }

    public static Budget__c CreateDefaultBudget() {
        return new Budget__c(Name = 'Test Budget 2019',
                             Limit__c = 10000,
                             Status__c = 'Planned');
    }

    public static TimeEntry__c CreateDefaultTimeEntry() {
        return new TimeEntry__c(Status__c = 'New',
                                DailyRate__c = 1250.00,
                                Date__c = System.today(),
                                StartTime__c = Time.newInstance(7, 30, 0, 0),
                                EndTime__c = Time.newInstance(13, 0, 0, 0));
    }

    public static Invoice__c CreateDefaultInvoice() {
        return new Invoice__c(Status__c = 'Draft',
                              BillingStreet__c = 'Test Street 1',
                              BillingPostalCode__c = '10000',
                              BillingCity__c = 'Berlin',
                              BillingCountry__c = 'Deutschland',
                              BillingState__c = 'Berlin',
                              Date__c = System.today());
    }

    public static Account CreateAccount(Account template) {
        return (Account)mergeSObjects(template, CreateDefaultAccount());
    }

    public static Budget__c CreateBudget(Budget__c template) {
        return (Budget__c)mergeSObjects(template, CreateDefaultBudget());
    }

    public static TimeEntry__c CreateTimeEntry(TimeEntry__c template) {
        return (TimeEntry__c)mergeSObjects(template, CreateDefaultTimeEntry());
    }

    public static Invoice__c CreateInvoice(Invoice__c template) {
        return (Invoice__c)mergeSObjects(template, CreateDefaultInvoice());
    }

    private static SObject mergeSObjects(SObject masterRecord, SObject slaveRecord) {
        // clone with preserveId=false and deepClone=true
        SObject mergeResult = slaveRecord.clone(false, true);
        // override all fields in slave with populated fields from master
        for (String populatedField : masterRecord.getPopulatedFieldsAsMap().keySet()) {
            mergeResult.put(populatedField, masterRecord.get(populatedField));
        }
        return mergeResult;
    }
    
}
