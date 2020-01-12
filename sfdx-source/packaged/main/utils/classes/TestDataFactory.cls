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

    public static Contact CreateDefaultContact() {
        return new Contact(LastName = 'Tester',
                           FirstName = 'Test');
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
                              PdfLanguage__c = 'de_DE',
                              Date__c = Date.newInstance(2019, 10, 20));
    }

    public static InvoiceLineItem__c CreateDefaultInvoiceLineItem() {
        return new InvoiceLineItem__c(Description__c = 'This is a test line item!',
                                      Price__c = 1333.37,
                                      Quantity__c = 1.00,
                                      Tax__c = 19,
                                      Discount__c = 0,
                                      Unit__c = 'Each',
                                      ServiceDate__c = Date.newInstance(2019, 10, 20));
    }

    public static BankAccount__c CreateDefaultBankAccount() {
        return new BankAccount__c(Name = 'Test Business Bank Account',
                                  BankAccountOwner__c = 'Test Company',
                                  BankName__c = 'Testbank GmbH',
                                  IBAN__c = 'DE70100000000123456789',
                                  IsDefault__c = true);
    }

    public static OrganizationProfile__c CreateDefaultOrganizationProfile() {
        return new OrganizationProfile__c(Name = 'Default Testing Profile',
                                          OrganizationName__c = 'Test Company Ltd.',
                                          IsDefault__c = true,
                                          Street__c = 'Test Street 1',
                                          PostalCode__c = '80123',
                                          City__c = 'Munich',
                                          State__c = 'Bavaria',
                                          Country__c = 'Germany',
                                          Email__c = 'info@example.com',
                                          Phone__c = '+49 89 123-0',
                                          VATNumber__c = 'DE123456789');
    }

    public static User CreateDefaultUser() {
        return new User(Alias = 'testUser',
                        Email='testuser@example.com',
                        EmailEncodingKey='UTF-8',
                        LastName='Tester',
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US',
                        TimeZoneSidKey='America/Los_Angeles',
                        UserName='pb-test' + Integer.valueOf(Math.random() * 1000000) + '@example.com');
    }

    public static AccessToken__c CreateDefaultAccessToken() {
        return new AccessToken__c(Code__c = 'ABCD1234DCBA',
                                  Status__c = 'Active');
    }

    public static Product2 CreateDefaultProduct() {
        return new Product2(Name = 'Test Product',
                            IsActive = true,
                            Family = 'Other');
    }

    public static Account CreateAccount(Account template) {
        return (Account)mergeSObjects(template, CreateDefaultAccount());
    }

    public static Contact CreateContact(Contact template) {
        return (Contact)mergeSObjects(template, CreateDefaultContact());
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

    public static InvoiceLineItem__c CreateInvoiceLineItem(InvoiceLineItem__c template) {
        return (InvoiceLineItem__c)mergeSObjects(template, CreateDefaultInvoiceLineItem());
    }

    public static BankAccount__c CreateBankAccount(BankAccount__c template) {
        return (BankAccount__c)mergeSObjects(template, CreateDefaultBankAccount());
    }

    public static OrganizationProfile__c CreateOrganizationProfile(OrganizationProfile__c template) {
        return(OrganizationProfile__c)mergeSObjects(template, CreateDefaultOrganizationProfile());
    }

    public static Product2 CreateProduct(Product2 template) {
        return (Product2)mergeSObjects(template, CreateDefaultProduct());
    }

    public static User CreateUser(User template) {
        return (User)mergeSObjects(template, CreateDefaultUser());
    }

    public static AccessToken__c CreateAccessToken(AccessToken__c template) {
        return (AccessToken__c)mergeSObjects(template, CreateDefaultAccessToken());
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
