public class InvoiceTriggerPdfGeneration implements Queueable {

    private List<InvoicePrint> Invoices = new List<InvoicePrint>();

    public InvoiceTriggerPdfGeneration(Set<Id> invoiceIds) {
        for (Invoice__c inv : Database.query(Invoice.QUERY_STRING + ' WHERE Id IN :invoiceIds')) {
            Invoices.add(new InvoicePrint(inv));
        }
    }
    
    public void execute(QueueableContext context) {
        
        Map<Id, OrganizationProfile__c> orgProfiles = new Map<Id, OrganizationProfile__c>(
            [SELECT Id,Name,OrganizationName__c,Street__c,PostalCode__c,City__c,State__c,Country__c,Email__c,Phone__c,VATNumber__c,IsDefault__c,
                    BankAccount__r.IBAN__c,BankAccount__r.BankName__c,BankAccount__r.BankNameFull__c,BankAccount__r.BankAccountOwner__c
            FROM OrganizationProfile__c]
        );

        for (InvoicePrint ip : Invoices) {
            PageReference invoicePdfPage = Page.InvoicePdf;
            // invoicePdfPage.OrgProfile = orgProfiles.get(ip.Record.OrganizationProfile__c);
        }
    }

}
