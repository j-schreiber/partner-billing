public without sharing class BudgetTriggerHandler implements ITriggerHandler {

    /** @Description    Organizes the lists of Time Entries by Budget id */
    private Map<Id, List<TimeEntry__c>> budgetTimeEntries = new Map<Id, List<TimeEntry__c>>();

    public BudgetTriggerHandler() {
        // load time entries in update and undelete context only
        if (Trigger.isExecuting && (Trigger.isUpdate || Trigger.isUndelete)) {
            for (Budget__c b : [SELECT Id, (SELECT Id,DailyRate__c,Date__c,Status__c,TotalAmount__c,Duration__c,IsInvoiced__c FROM TimeEntries__r) 
                                FROM Budget__c WHERE Id IN :Trigger.newMap.keySet()]) {
                budgetTimeEntries.put(b.Id, b.TimeEntries__r);
            }
        }
    }

    /** @Description
    *   Implementation of ITriggerHandler interface. Entry point to execute all trigger logic.
    *   This method solves trigger context and bulkification and dispatches to more specific functions
    *   to implement the individually needed logic.
    */
    public void execute() {
        if (!Trigger.isExecuting) return;
        switch on Trigger.OperationType {
            when BEFORE_INSERT { for (SObject so : Trigger.new) beforeInsert((Budget__c)so); }
            when BEFORE_UPDATE { for (SObject so : Trigger.old) beforeUpdate((Budget__c)so, (Budget__c)Trigger.newMap.get(so.Id)); }
            when AFTER_UNDELETE {
                List<Budget__c> budgetsToUndelete = [SELECT Id FROM Budget__c WHERE Id IN :Trigger.newMap.keySet() FOR UPDATE];
                for (Budget__c b : budgetsToUndelete) afterUndelete(b);
                update budgetsToUndelete;
            }
        }
    }

    public void beforeUpdate(Budget__c oldSo, Budget__c newSo) {
        updateTotalAmountInvoiced(newSo);
        updateTotalAmountLogged(newSo);
    }

    public void beforeInsert(Budget__c newSo) {
        newSo.TotalAmountInvoiced__c = 0;
        newSo.TotalAmountLogged__c = 0;
    }

    public void afterUndelete(Budget__c newSo) {
        updateTotalAmountInvoiced(newSo);
        updateTotalAmountLogged(newSo);
    }

    private void updateTotalAmountLogged(Budget__c newSo) {
        newSo.TotalAmountLogged__c = ListUtils.summarizeSObjectListField(
            budgetTimeEntries.get(newSo.Id), 
            TimeEntry__c.TotalAmount__c,
            ListUtils.SummarizeOperation.SUM
        );
    }

    private void updateTotalAmountInvoiced(Budget__c newSo) {
        List<TimeEntry__c> invoicedTimeEntries = new List<TimeEntry__c>();
        for (TimeEntry__c te : budgetTimeEntries.get(newSo.Id)) {
            if (te.IsInvoiced__c) invoicedTimeEntries.add(te);
        }

        newSo.TotalAmountInvoiced__c = ListUtils.summarizeSObjectListField(
            invoicedTimeEntries,
            TimeEntry__c.TotalAmount__c,
            ListUtils.SummarizeOperation.SUM
        );      
    }
}
