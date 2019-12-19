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

    /** @Description    Retrieves the Org-Profile that will be used to render the PDF. 
                        First, selects profile from params, then profile from invoice record, then default profile */
    public OrganizationProfile__c OrgProfile {
        public get {
            if (OrgProfile == null) {

                Map<String, OrganizationProfile__c> orgProfiles = new Map<String, OrganizationProfile__c>(
                    [SELECT Id,Name,OrganizationName__c,Street__c,PostalCode__c,City__c,State__c,Country__c,Email__c,Phone__c,VATNumber__c,IsDefault__c,
                    BankAccount__r.IBAN__c,BankAccount__r.BankName__c,BankAccount__r.BankNameFull__c,BankAccount__r.BankAccountOwner__c
                    FROM OrganizationProfile__c
                    ORDER BY IsDefault__c DESC]
                );
                
                if (String.isNotBlank(ApexPages.currentPage().getParameters().get('orgProfileId')) && orgProfiles.containsKey(ApexPages.currentPage().getParameters().get('orgProfileId'))) {
                    OrgProfile = orgProfiles.get(ApexPages.currentPage().getParameters().get('orgProfileId'));
                } else if (String.isNotBlank(Invoice.Record.OrganizationProfile__c) && orgProfiles.containsKey(Invoice.Record.OrganizationProfile__c)) {
                    OrgProfile = orgProfiles.get(Invoice.Record.OrganizationProfile__c);
                } else if (!orgProfiles.isEmpty()) {
                    OrgProfile = orgProfiles.values()[0];
                } else {
                    OrgProfile = new OrganizationProfile__c();
                }

            }
            return OrgProfile;
        }
        public set;
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
                DisplayTimesheet = ApexPages.currentPage().getParameters().get('displayTimesheet') == 'true' && !Invoice.Record.TimeEntries__r.isEmpty();
            } else {
                DisplayTimesheet = Invoice.DisplayTimesheet;
            }
            return DisplayTimesheet;
        }
        private set;
    }

}
