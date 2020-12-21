/** @Description
*   Static UI API for time tracking functionality */
public with sharing class TimeTrackingController {

    /** @Description
    *   Retrieves List of non-ended / unfinished time entries (Ids only) for the current user.
    *   The Time Entries are ordered by created date (most recent first)
    *
    *   @return             List of unfinished Time Entries.
    */
    @AuraEnabled(cacheable=true)
    public static List<TimeEntry__c> getUnfinishedTimeEntries(){
        return [SELECT Id
                FROM TimeEntry__c WHERE OwnerId = :UserInfo.getUserId() AND EndTime__c = null
                ORDER BY CreatedDate DESC];
    }

}
