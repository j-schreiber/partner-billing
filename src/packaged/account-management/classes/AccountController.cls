public with sharing class AccountController {

    /** @Description
    *   Evaluates all Accounts and retrieves the highest customer id number from all accounts.
    *   This method does not evaluate potential gaps between non-sequential numbers.
    *
    *   @return         Highest Customer Id from all Accounts.
    */
    @AuraEnabled
    public static Integer getLatestCustomerId() {
        Integer i = Integer.valueOf([SELECT MAX(CustomerIdNumber__c)lastCustomerId FROM Account][0].get('lastCustomerId'));
        return i != null ? i : 0;
    }
}
