public class InvoiceLineItemTriggerHandler implements ITriggerHandler  {

    /** @Description    Makes related invoices available in: before/after update, after insert, before delete */
    private Map<Id, Invoice__c> RelatedInvoices {
        private get {
            if (RelatedInvoices == null) {
                RelatedInvoices = new Map<Id, Invoice__c>();
                Set<Id> InvoiceIds = new Set<Id>();
                if (Trigger.new != null) {
                    for (InvoiceLineItem__c so : (List<InvoiceLineItem__c>)Trigger.new) InvoiceIds.add(so.Invoice__c);
                } else {
                    for (InvoiceLineItem__c so : (List<InvoiceLineItem__c>)Trigger.old) InvoiceIds.add(so.Invoice__c);
                }
                RelatedInvoices.putAll([SELECT Id,Status__c FROM Invoice__c WHERE Id IN :InvoiceIds]);
            }
            return RelatedInvoices;
        }
        private set;
    }

    /** @Description
    *   Execute implements the ITriggerHandler interface and is called once per execution context
    *   (before & after each). The implementation is responsible for dispatching the individual trigger
    *   scopes (insert, update, delete, etc) and setting order of execution for the functional blocks.
    */
    public void execute() {
        if (!Trigger.isExecuting) return;
        switch on Trigger.OperationType {
            when BEFORE_INSERT { 
                for (SObject so : Trigger.new) beforeInsert((InvoiceLineItem__c)so);
            }
            when BEFORE_UPDATE {
                for (SObject so : Trigger.new) beforeUpdate((InvoiceLineItem__c)so, (InvoiceLineItem__c)Trigger.oldMap.get(so.Id));
            }
            when BEFORE_DELETE {
                for (SObject so : Trigger.old) beforeDelete((InvoiceLineItem__c)so);
            }
        }
    }

    /** @Description
    *   The beforeInsert scope method only defines order of execution for the business
    *   methods it calls
    */
    public void beforeInsert(InvoiceLineItem__c newIli) {
        validateInsert(newIli);
    }

    /** @Description
    *   The beforeUpdate scope method only defines order of execution for the business
    *   methods it calls
    */
    public void beforeUpdate(InvoiceLineItem__c newIli, InvoiceLineItem__c oldIli) {
        validateModifications(newIli, oldIli);
    }

    /** @Description
    *   The beforeDelete scope method only defines order of execution for the business
    *   methods it calls
    */
    public void beforeDelete(InvoiceLineItem__c oldIli) {
        validateDelete(oldIli);
    }

    /**                                 PRIVATE METHODS                                  */

    public void validateInsert(InvoiceLineItem__c newIli) {
        Invoice inv = new Invoice(RelatedInvoices.get(newIli.Invoice__c));
        if (inv.IsLocked && !FeatureManagement.checkPermission('Modify_Activated_Invoices')) {
            newIli.addError(Label.Message_LineItemValidation_CanNotInsertWhenLocked);
        }
    }

    public void validateDelete(InvoiceLineItem__c oldIli) {
        Invoice inv = new Invoice(RelatedInvoices.get(oldIli.Invoice__c));
        if (inv.IsLocked && !FeatureManagement.checkPermission('Modify_Activated_Invoices')) {
            oldIli.addError(Label.Message_LineItemValidation_CanNotDeleteWhenLocked);
        }
    }

    public void validateModifications(InvoiceLineItem__c newIli, InvoiceLineItem__c oldIli) {
        Invoice inv = new Invoice(RelatedInvoices.get(newIli.Invoice__c));
        for (String fieldName : InvoiceLineItem.ACTIVATED_LOCKED_FIELDS) {
            if (newIli.get(fieldName) != oldIli.get(fieldName) && inv.IsLocked && !FeatureManagement.checkPermission('Modify_Activated_Invoices')) {
                newIli.addError(Label.Message_LineItemValidation_CanNotEditFieldsWhenLocked);
                break;
            }
        }
    }
}
