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
    *   Searches Contacts for the search term. Performs SOSL.
    *
    *   @param searchTerm       Search term to look for
    *   @return                 Filtered Contacts
    */
    @AuraEnabled(cacheable=true)
    public static List<Contact> findBillingContacts(String searchTerm, String accId){

        if (searchTerm == '*' || String.isBlank(searchTerm) || searchTerm.length() == 1) {
            return [SELECT Id,Name,Account.Name,Account.BillingCity FROM Contact WHERE IsBillingContact__c = true AND AccountId = :accId];
        }
        
        List<Contact> results = new List<Contact>();
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Contact(Id, Name, Account.Name, Account.BillingCity WHERE (IsBillingContact__c = true) AND (AccountId = :accId))
            LIMIT 5
        ];

        if (!searchResults.isEmpty()) {
            for (SObject so : searchResults[0]) results.add((Contact)so);
        }

        return results;
    }

}
