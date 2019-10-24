trigger onTimeEntry on TimeEntry__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new Dispatcher(TimeEntry__c.getSObjectType()).executeHandlers();
}