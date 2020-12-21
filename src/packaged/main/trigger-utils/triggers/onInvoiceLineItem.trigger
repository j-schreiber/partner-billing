trigger onInvoiceLineItem on InvoiceLineItem__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new Dispatcher(InvoiceLineItem__c.getSObjectType()).executeHandlers();
}