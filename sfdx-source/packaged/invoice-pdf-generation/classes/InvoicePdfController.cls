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
    */
    @AuraEnabled
    public static void savePdfToInvoice(Id invoiceId, Id orgProfileId, String renderLanguage, Boolean displayTimesheet) {
        InvoicePrint inv = new InvoicePrint(invoiceId);
        PageReference pdfFile = inv.createPdf(orgProfileId, renderLanguage, displayTimesheet);
        Blob convertedPdf = Test.isRunningTest() ? Blob.valueOf(String.valueOf(pdfFile)) : pdfFile.getContentAsPdf();
        inv.addFileToAttachments(convertedPdf);
        inv.commitAllChanges();
    }

    /** @Description
    *   Queries all available organization profiles for the user 
    *
    *   @return                 All Organization Profiles, default profile first
    */
    @AuraEnabled
    public static List<OrganizationProfile__c> getOrganizationProfiles() {
        return [SELECT Id,Name,IsDefault__c
                FROM OrganizationProfile__c ORDER BY IsDefault__c DESC];
    }

}
