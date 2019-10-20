public with sharing class InvoiceTriggerHandler implements ITriggerHandler {

    private Map<Id, Account> Accounts;

    public InvoiceTriggerHandler() {
        if (!Trigger.isExecuting) return;

        // extract account ids from invoice and load accounts
        Set<Id> AccountIds = new Set<Id>();
        if (Trigger.new != null) {
            for (Invoice__c inv : (List<Invoice__c>)Trigger.new) AccountIds.add(inv.Account__c);
        }
        Accounts = new Map<Id, Account>([SELECT Id,Name,BillingAddress FROM Account WHERE Id IN :AccountIds]);
    }

    /** @Description
    *   Implementation of ITriggerHandler interface. Entry point to execute all trigger logic.
    *   This method solves trigger context and bulkification and dispatches to more specific functions
    *   to implement the individually needed logic.
    */
    public void execute() {
        if (!Trigger.isExecuting) return;
        switch on Trigger.OperationType {
            when BEFORE_INSERT { for (SObject so : Trigger.new) beforeInsert((Invoice__c)so); }
        }
    }

    /** @Description
    *   The beforeInsert scope method only defines order of execution for the business
    *   methods it calls
    */
    public void beforeInsert(Invoice__c newSo) {
        copyBillingAddressFromAccount(newSo);
    }

    private void copyBillingAddressFromAccount(Invoice__c newInvoice) {
        if (Accounts.get(newInvoice.Account__c).BillingAddress != null) {
            Address addr = Accounts.get(newInvoice.Account__c).BillingAddress;
            newInvoice.BillingStreet__c = String.isNotBlank(newInvoice.BillingStreet__c) ? newInvoice.BillingStreet__c : addr.getStreet();
            newInvoice.BillingPostalCode__c = String.isNotBlank(newInvoice.BillingPostalCode__c) ? newInvoice.BillingPostalCode__c : addr.getPostalCode();
            newInvoice.BillingCity__c = String.isNotBlank(newInvoice.BillingCity__c) ? newInvoice.BillingCity__c : addr.getCity();
            newInvoice.BillingCountry__c = String.isNotBlank(newInvoice.BillingCountry__c) ? newInvoice.BillingCountry__c : addr.getCountry();
            newInvoice.BillingState__c = String.isNotBlank(newInvoice.BillingState__c) ? newInvoice.BillingState__c : addr.getState();
        }
    }
}
