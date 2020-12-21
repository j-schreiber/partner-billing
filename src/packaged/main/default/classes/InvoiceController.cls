public with sharing class InvoiceController {
    
    /** @Description
    *   Used for record page context to fully initialize an invoice
    *   based on record id. If the record id is invalid, an empty invoice is returned
    *
    *   @param  invoiceId    The record id, presumably from page context
    *
    *   @return             Initialized invoice decorator
    */
    @AuraEnabled(cacheable=true)
    public static Invoice getInvoice(Id invoiceId){
        return new Invoice(invoiceId);
    }

    /** @Description
    *   Used for record page context to commit a single invoice
    *
    *   @param  recordId            The record id for the invoice
    *   @param  lineItemsToUpsert   Mix of commited line items to update and new line items to insert
    *   @param  lineItemsToDelete   Ids of commited line items to delete
    */
    @AuraEnabled
    public static void commitInvoiceLineItems(Id recordId, List<InvoiceLineItem__c> lineItemsToUpsert, List<Id> lineItemsToDelete) {
        Invoice inv = getInvoice(recordId);
        for (InvoiceLineItem__c toUpsert : lineItemsToUpsert) inv.addLineItemRecord(toUpsert);
        for (Id toDelete : lineItemsToDelete) inv.removeLineItemId(toDelete);
        Invoice.CommitResult commitResults = inv.commitAllChanges();

        for (Database.UpsertResult ur : commitResults.LineItemResults) {
            if (!ur.isSuccess()) throw new AuraHandledException(JSON.serialize(ur.getErrors()));
        }
    }
    
}
