/** @Description
*   This is a generic LWC Controller for re-usable core components that are not part of one
*   of the larger features (like the billing run).
*/
public with sharing class LWCUtilityController {
    
    /** @Description
    *   Retrieves all mail templates from dedicated folder and returns as list
    *   
    *   @return             All mail Templates from dedicated folder
    */
    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getMailTemplates(){
        return [SELECT Id,Name,DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'Billing_Communication_Templates'];
    }

    /** @Description
    *   Retrieves all configured organization wide sender addresses and the current user sender address. 
    *   This method also includes non-confirmed addresses, so handle with care.
    *   
    *   @return             All org wide emails existing in this organization
    */
    @AuraEnabled(cacheable=true)
    public static List<SenderAddress> getSenderAddresses() {
        List<SenderAddress> addrs = new List<SenderAddress>();
        User currentUser = [SELECT Id,Name,Email FROM User WHERE Id = :UserInfo.getUserId()];
        addrs.add(new SenderAddress(currentUser));
        for (OrgWideEmailAddress owea : [SELECT Id,DisplayName,Address FROM OrgWideEmailAddress]) {
            addrs.add(new SenderAddress(owea));
        }
        return addrs;
    }

    /** @Description
    *   Searches Contacts for the search term. Performs SOSL.
    *
    *   @param searchTerm       Search term to look for
    *   @return                 Filtered Contacts
    */
    @AuraEnabled(cacheable=true)
    public static List<Contact> findBillingContacts(String searchTerm, String accId){

        if (searchTerm == '*' || String.isBlank(searchTerm) || searchTerm.length() == 1) {
            return [SELECT Id,Name,Email,Account.Name,Account.BillingCity FROM Contact WHERE IsBillingContact__c = true AND AccountId = :accId];
        }
        
        List<Contact> results = new List<Contact>();
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Contact(Id,Name,Email,Account.Name,Account.BillingCity WHERE (IsBillingContact__c = true) AND (AccountId = :accId))
            LIMIT 5
        ];

        if (!searchResults.isEmpty()) {
            for (SObject so : searchResults[0]) results.add((Contact)so);
        }

        return results;
    }

}
