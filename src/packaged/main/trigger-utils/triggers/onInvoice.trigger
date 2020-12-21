trigger onInvoice on Invoice__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new Dispatcher(Invoice__c.getSObjectType()).executeHandlers();
}