/** @Description
*   This controller provides a static interface for handling the Invoice PDF creation
*/
public class InvoicePdfController {

    /** @Description
    *   Creates the invoice pdf file (as displayed in iframed visualforce) and saves it as attachment to the
    *   invoice record. Every time the method is called, a new PDF is generated and saved as new attachment.
    *
    *   @param  invoiceId           The invoice id where the PDF is saved
    *   @param  orgProfileId        The organization profile that will be used to render footer/header
    *   @param  renderLanguage      The language that will be used to render all translatable labels
    *   @param  displayTimesheet    Option to display the invoice's timesheet
    *
    *   @return                     The created content version that holds the newly created PDF
    */
    @AuraEnabled
    public static ContentVersion savePdfToInvoice(Id invoiceId, String orgProfileId, String renderLanguage, Boolean displayTimesheet) {
        InvoicePrint inv = new InvoicePrint(invoiceId);
        PageReference pdfFile = inv.createPdf(orgProfileId, renderLanguage, displayTimesheet);
        return inv.saveToContentAttachments(pdfFile);
    }

    /** @Description
    *   Queries all available organization profiles for the user 
    *
    *   @return                 All Organization Profiles, default profile first
    */
    @AuraEnabled(cacheable=true)
    public static List<OrganizationProfile__c> getOrganizationProfiles() {
        return [SELECT Id,Name,IsDefault__c
                FROM OrganizationProfile__c ORDER BY IsDefault__c DESC];
    }

}
