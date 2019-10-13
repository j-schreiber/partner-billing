@isTest
public class ListUtils_Test {
    
    @isTest
    static void summarizeListField_Sum_ValidField_SumCalculated() {
        // SETUP: List of Accounts with Annual Revenue
        List<Account> accs = new List<Account>();
        accs.add(TestDataFactory.CreateAccount(new Account(AnnualRevenue = 1000.00)));
        accs.add(TestDataFactory.CreateAccount(new Account(AnnualRevenue = 1500.23)));

        // ACTION
        Decimal actualResult = ListUtils.summarizeSObjectListField(accs, Account.AnnualRevenue, ListUtils.SummarizeOperation.SUM);

        // VERIFY
        System.assertEquals(2500.23, actualResult, 'actualResult');
    }

    @isTest
    static void summarizeListField_Sum_TextField_ZeroCalculated() {
        // SETUP: List of Accounts with Annual Revenue
        List<Account> accs = new List<Account>();
        accs.add(TestDataFactory.CreateAccount(new Account(AnnualRevenue = 1000.00)));
        accs.add(TestDataFactory.CreateAccount(new Account(AnnualRevenue = 1500.23)));

        // ACTION
        Decimal actualResult = ListUtils.summarizeSObjectListField(accs, Account.Name, ListUtils.SummarizeOperation.SUM);

        // VERIFY
        System.assertEquals(0, actualResult, 'actualResult');
    }

    @isTest
    static void summarizeListField_Sum_ListIsNull_ZeroCalculated() {
        // ACTION
        Decimal actualResult = ListUtils.summarizeSObjectListField(null, Account.Name, ListUtils.SummarizeOperation.SUM);

        // VERIFY
        System.assertEquals(0, actualResult, 'actualResult');
    }

    @isTest
    static void summarizeListField_Sum_EmptyList_ZeroCalculated() {
        // ACTION
        Decimal actualResult = ListUtils.summarizeSObjectListField(new List<Account>(), Account.Name, ListUtils.SummarizeOperation.SUM);

        // VERIFY
        System.assertEquals(0, actualResult, 'actualResult');
    }

    @isTest
    static void summarizeListField_Sum_InvalidFieldToken_ZeroCalculated() {
        // ACTION
        Decimal actualResult = ListUtils.summarizeSObjectListField(new List<Contact>(), Account.Name, ListUtils.SummarizeOperation.SUM);

        // VERIFY
        System.assertEquals(0, actualResult, 'actualResult');
    }
}
