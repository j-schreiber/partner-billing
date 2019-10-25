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

    public OrganizationProfile__c OrgProfile {
        public get {
            if (OrgProfile == null) {
                String orgProfileId = ApexPages.currentPage().getParameters().get('orgProfileId');
                List<OrganizationProfile__c> profiles = [SELECT Id,Name,OrganizationName__c,Street__c,PostalCode__c,City__c,State__c,Country__c,Email__c,Phone__c,VATNumber__c,IsDefault__c
                                                         FROM OrganizationProfile__c
                                                         WHERE Id = :orgProfileId OR (IsDefault__c = true AND Id != :orgProfileId)
                                                         ORDER BY IsDefault__c ASC];
                OrgProfile = profiles.isEmpty() ? new OrganizationProfile__c() : profiles[0];
            }
            return OrgProfile;
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
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('lang'))) {
                Language = ApexPages.currentPage().getParameters().get('lang');
            } else {
                Language = Invoice.Record.PdfLanguage__c;
            }
            return Language;
        }
        public set;
    }

}
