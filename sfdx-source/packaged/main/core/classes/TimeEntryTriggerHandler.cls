public without sharing class TimeEntryTriggerHandler implements ITriggerHandler {

    private Map<Id, Budget__c> relatedBudgets;

    public TimeEntryTriggerHandler() {
        Set<Id> recordIds = Trigger.newMap != null ? Trigger.newMap.keySet() : Trigger.oldMap.keySet();
        relatedBudgets = new Map<Id, Budget__c>([SELECT Id FROM Budget__c 
                                                WHERE Id IN (
                                                    SELECT Budget__c 
                                                    FROM TimeEntry__c WHERE Id IN :recordIds
                                                )]);
    }

    public void execute() {
        if (!Trigger.isExecuting) return;
        switch on Trigger.OperationType {
            when AFTER_INSERT { for (SObject so : Trigger.new) afterInsert((TimeEntry__c)so); }
            when AFTER_UPDATE { for (SObject so : Trigger.old) afterUpdate((TimeEntry__c)so, (TimeEntry__c)Trigger.newMap.get(so.Id)); }
            when AFTER_UNDELETE { for (SObject so : Trigger.new) afterUndelete((TimeEntry__c)so); }
            when BEFORE_DELETE { for (SObject so : Trigger.old) beforeDelete((TimeEntry__c)so); }
        }
    }

    public void afterInsert(SObject so) {

    }

    public void afterUpdate(SObject oldSo, SObject newSo) {
        
    }

    public void afterUndelete(SObject so) {
        
    }

    public void beforeDelete(SObject so) {
        
    }
}
