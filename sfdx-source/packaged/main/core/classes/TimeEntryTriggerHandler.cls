public without sharing class TimeEntryTriggerHandler implements ITriggerHandler {

    private Map<Id, Budget__c> relatedBudgets {
        private get {
            if (relatedBudgets == null) {
                Set<Id> budgetIds = new Set<Id>();
                if (Trigger.new != null) budgetIds.addAll(ListUtils.extractIdsFromSObjectList(Trigger.new, TimeEntry__c.Budget__c));
                if (Trigger.old != null) budgetIds.addAll(ListUtils.extractIdsFromSObjectList(Trigger.old, TimeEntry__c.Budget__c));
                relatedBudgets = new Map<Id, Budget__c>([SELECT Id FROM Budget__c WHERE Id IN :budgetIds]);
            }
            return relatedBudgets;
        }
        private set;
    }

    /** @Description    Makes related invoices available in: before/after update, after insert, before delete */
    private Map<Id, Invoice__c> RelatedInvoices {
        private get {
            if (RelatedInvoices == null) {
                RelatedInvoices = new Map<Id, Invoice__c>();
                Set<Id> EntryIds = new Set<Id>();
                if (Trigger.newMap != null) EntryIds.addAll(Trigger.newMap.keySet());
                if (Trigger.oldMap != null) EntryIds.addAll(Trigger.oldMap.keySet());
                RelatedInvoices.putAll([SELECT Id,Status__c FROM Invoice__c WHERE Id IN (SELECT Invoice__c FROM TimeEntry__c WHERE Id IN :EntryIds)]);
            }
            return RelatedInvoices;
        }
        private set;
    }

    public TimeEntryTriggerHandler() { }

    /** @Description
    *   Execute implements the ITriggerHandler interface and is called once per execution context
    *   (before & after each). The implementation is responsible for dispatching the individual trigger
    *   scopes (insert, update, delete, etc) and setting order of execution for the functional blocks.
    */
    public void execute() {
        if (!Trigger.isExecuting) return;
        switch on Trigger.OperationType {
            when AFTER_INSERT { 
                recalculateRelatedBudgets(); 
            }
            when BEFORE_UPDATE {
                for (SObject so : Trigger.new) beforeUpdate((TimeEntry__c)so, (TimeEntry__c)Trigger.oldMap.get(so.Id));
            }
            when AFTER_UPDATE { 
                recalculateRelatedBudgets();
            }
            when AFTER_UNDELETE {
                recalculateRelatedBudgets();
            }
            when BEFORE_DELETE {
                for (SObject so : Trigger.old) beforeDelete((TimeEntry__c)so);
            }
            when AFTER_DELETE {
                recalculateRelatedBudgets();
            }
        }
    }

    private void recalculateRelatedBudgets() {
        update relatedBudgets.values();
    }

    private void beforeDelete(TimeEntry__c oldEntry) {
        if (oldEntry.IsInvoiced__c && RelatedInvoices.containsKey(oldEntry.Invoice__c) && RelatedInvoices.get(oldEntry.Invoice__c).Status__c != Constants.INVOICE_STATUS_CANCELLED) {
            oldEntry.addError(Label.Message_TimeEntryValidation_CanNotDeleteRecord);
        }
    }

    private void beforeUpdate(TimeEntry__c newEntry, TimeEntry__c oldEntry) {
        if (RelatedInvoices.containsKey(oldEntry.Invoice__c)
            && RelatedInvoices.get(oldEntry.Invoice__c).Status__c != Constants.INVOICE_STATUS_CANCELLED
            && (isChanged('Invoice__c', newEntry, oldEntry) && oldEntry.Invoice__c != null)) 
        {
            newEntry.addError(Label.Message_TimeEntryValidation_CanNotRemoveInvoice);
        }
    }

    private Boolean isChanged(String fieldName, TimeEntry__c newEntry, TimeEntry__c oldEntry) {
        return newEntry.get(fieldName) != oldEntry.get(fieldName);
    }

}
