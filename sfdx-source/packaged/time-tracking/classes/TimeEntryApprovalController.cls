public with sharing class TimeEntryApprovalController {
    
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
        List<AccessToken__c> ats = [SELECT Id,Status__c FROM AccessToken__c WHERE Status__c = 'Active' AND Code__c = :String.escapeSingleQuotes(accessCode)];
        if (ats.isEmpty()) return false;
        return ats[0].Status__c == 'Active';
    }
}
