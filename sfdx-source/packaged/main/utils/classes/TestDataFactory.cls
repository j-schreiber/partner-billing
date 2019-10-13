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

    public static Account CreateAccount(Account template) {
        return (Account)mergeSObjects(template, CreateDefaultAccount());
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
