public with sharing class VFInvoicePdfController {
    
    /** @Description    The fully initialized invoice object for this context */
    public InvoicePrint Invoice {
        public get {
            if (Invoice == null) {
                Invoice = new InvoicePrint(ApexPages.currentPage().getParameters().get('Id'));
            }
            return Invoice;
        }
        private set;
    }

    /** @Description    The fully initialized org data for this context */
    public OrganizationInfo Company {
        public get {
            if (Company == null) {
                Company = new OrganizationInfo();
            }
            return Company;
        }
        private set;
    }

    /** @Description    Render As Property from Page Parameters */
    public String renderAs {
        public get {
            renderAs = ApexPages.currentPage().getParameters().get('renderAs');
            return renderAs;
        }
        public set;
    }

    /** @Description    Get default bank account */
    public BankAccount__c BankAccount {
        public get {
            if (BankAccount == null) {
                List<BankAccount__c> baccs = [SELECT Id,BankName__c,IBAN__c,BankAccountOwner__c FROM BankAccount__c WHERE IsDefault__c = true];
                BankAccount = baccs.isEmpty() ? new BankAccount__c() : baccs[0];
            }
            return BankAccount;
        }
        public set;
    }

    /** @Description    Language Property from Page Parameters */
    public String Language {
        public get {
            Language = Invoice.Record.PdfLanguage__c;
            return Language;
        }
        public set;
    }

}
