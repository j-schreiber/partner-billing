public without sharing class TimeEntryTriggerHandler implements ITriggerHandler {

    private Map<Id, Budget__c> relatedBudgets;

    public TimeEntryTriggerHandler() {
        // finding all budgets that are affected by this operation
        Set<Id> budgetIds = new Set<Id>();
        if (Trigger.new != null) budgetIds.addAll(ListUtils.extractIdsFromSObjectList(Trigger.new, TimeEntry__c.Budget__c));
        if (Trigger.old != null) budgetIds.addAll(ListUtils.extractIdsFromSObjectList(Trigger.old, TimeEntry__c.Budget__c));
        relatedBudgets = new Map<Id, Budget__c>([SELECT Id FROM Budget__c WHERE Id IN :budgetIds]);

    }

    /** @Description
    *   Execute implements the ITriggerHandler interface and is called once per execution context
    *   (before & after each). The implementation is responsible for dispatching the individual trigger
    *   scopes (insert, update, delete, etc) and setting order of execution for the functional blocks.
    */
    public void execute() {
        if (!Trigger.isExecuting) return;
        switch on Trigger.OperationType {
            when AFTER_INSERT { recalculateRelatedBudgets(); }
            when AFTER_UPDATE { recalculateRelatedBudgets(); }
            when AFTER_UNDELETE { recalculateRelatedBudgets(); }
            when BEFORE_DELETE { for (SObject so : Trigger.old) beforeDelete((TimeEntry__c)so); }
            when AFTER_DELETE { recalculateRelatedBudgets(); }
        }
    }

    private void recalculateRelatedBudgets() {
        update relatedBudgets.values();
    }

    private void beforeDelete(TimeEntry__c so) {
        if (so.IsInvoiced__c) so.addError(Label.ValidationError_CanNotDeleteInvoicedTimeEntry);
    }

}
