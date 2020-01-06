/** @description
*   This controller deliberatly uses "without sharing" to validate access codes and return time entries,
*   so we do not need to compromise any modify/view all data permissions or org wide sharing settings
*   This class only exposes information to someone who posesses a valid access code */
public without sharing class TimeEntryApprovalController {
    
    /**
    *   @description
    *   Queries the database for a valid access code and returns true, if it found
    *   an access code AND the access code is valid.
    *
    *   @param  accessCode          The 12-character string
    *
    *   @return                     True, if the entered access code is valid
    */
    @AuraEnabled
    public static Boolean validateAccessCode(String accessCode) {
        List<AccessToken__c> ats = [SELECT Id FROM AccessToken__c WHERE Status__c = 'Active' AND Code__c = :String.escapeSingleQuotes(accessCode)];
        if (ats.isEmpty()) return false;
        return true;
    }

    /**
    *   @description
    *   Queries the database for a valid access code and returns the corresponding open and internally approved
    *   time entries of the access code's contact's parent account. If the access code is invalid, no data is returned
    *
    *   @param  accessCode          The 12-character string
    *
    *   @return                     List of Time Entries that belong to this access code's Account
    */
    @AuraEnabled(cacheable=true)
    public static List<TimeEntry__c> getTimeEntries(String accessCode) {
        List<Contact> cs = [SELECT AccountId FROM Contact WHERE Id IN (SELECT Contact__c FROM AccessToken__c WHERE Status__c = 'Active' AND Code__c = :String.escapeSingleQuotes(accessCode))];
        if (cs.isEmpty()) return new List<TimeEntry__c>();
        String accId = cs[0].AccountId;
        List<TimeEntry__c> tes = Database.query(TimeEntry.QUERY_STRING + ' WHERE Account__c = :accId AND Status__c = \'Approved\' AND IsInvoiced__c = false');
        return tes;
    }

    /**
    *   @description
    *   Queries the database for a valid access code and returns the corresponding contact with account information
    *
    *   @param  accessCode          The 12-character string
    *
    *   @return                     Contact object who owns the access code
    */
    @AuraEnabled
    public static Contact getContactData(String accessCode) {
        List<Contact> cs = [SELECT Name,Account.Name FROM Contact WHERE Id IN (SELECT Contact__c FROM AccessToken__c WHERE Status__c = 'Active' AND Code__c = :String.escapeSingleQuotes(accessCode)) LIMIT 1];
        if (cs.isEmpty()) return new Contact();
        return cs[0];
    }
}
