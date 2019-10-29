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
                List<OrganizationProfile__c> profiles = [SELECT Id,Name,OrganizationName__c,Street__c,PostalCode__c,City__c,State__c,Country__c,Email__c,Phone__c,VATNumber__c,IsDefault__c,
                                                         BankAccount__r.IBAN__c,BankAccount__r.BankName__c,BankAccount__r.BankNameFull__c,BankAccount__r.BankAccountOwner__c
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
                BankAccount = OrgProfile.BankAccount__r == null ? new BankAccount__c() : OrgProfile.BankAccount__r;
            }
            return BankAccount;
        }
        public set;
    }

    /** @Description    Language property from page parameters */
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

    /** @Description    Render timesheet control property from page parameters */
    public Boolean DisplayTimesheet {
        public get {
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('displayTimesheet'))) {
                DisplayTimesheet = ApexPages.currentPage().getParameters().get('displayTimesheet') == 'true';
            } else {
                DisplayTimesheet = Invoice.Record.PdfRenderTimesheet__c;
            }
            return DisplayTimesheet;
        }
        private set;
    }

}
