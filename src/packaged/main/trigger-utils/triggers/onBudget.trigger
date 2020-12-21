trigger onBudget on Budget__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new Dispatcher(Budget__c.getSObjectType()).executeHandlers();
}