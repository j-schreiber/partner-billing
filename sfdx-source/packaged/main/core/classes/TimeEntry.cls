/** @Description
*   This is the decorator object for the custom object TimeEntry__c.
*/
public class TimeEntry {

    /** @Description    The decorated original SObject */
    public TimeEntry__c Record {public get; private set;}

    @AuraEnabled
    public String AccountName {
        public get { return Record.Account__r.Name; }
    }

    @AuraEnabled
    public String ProductName {
        public get { return Record.Product__r.Name; }
    }

    @AuraEnabled
    public String Name {
        public get { return Record.Name; }
    }

    @AuraEnabled
    public Id Id {
        public get { return Record.Id; }
    }

    /** @Description    Formatted duration */
    @AuraEnabled
    public String Duration {
        public get { return Record.Duration__c + ' h'; }
    }

    @AuraEnabled
    public Time StartTime {
        public get { return Record.StartTime__c; }
    }

    @AuraEnabled
    public Time EndTime {
        public get { return Record.EndTime__c; }
    }

    @AuraEnabled
    public Decimal TotalAmount {
        public get { return Record.TotalAmount__c; }
    }

    @AuraEnabled
    public Decimal DailyRate {
        public get { return Record.DailyRate__c; }
    }

    @AuraEnabled
    public Date ServiceDate {
        public get { return Record.Date__c; }
    }

    public static final string QUERY_STRING = 'SELECT Id,Name,StartTime__c,EndTime__c,Duration__c,Date__c,DailyRate__c,Account__c,Budget__c,Product__c,Status__c,Invoice__c,Description__c FROM TimeEntry__c';

    /** @Description    Create Decorator from original SObject record */
    public TimeEntry(TimeEntry__c originalRecord) {
        Record = originalRecord;
    }

}
