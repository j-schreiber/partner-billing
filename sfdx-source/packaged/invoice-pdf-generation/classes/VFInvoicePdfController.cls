public with sharing class VFInvoicePdfController {
    
    /** @Description    The fully initialized invoice object for this context */
    public static InvoicePrint InvoiceObject;

    /** @Description    The fully initialized org data for this context */
    public static Organization OrgData;

    /** @Description    
    *   Visualforce pseudo getter for invoice object. Initialized the decorator object
    *   from the invoice id page parameter.
    *
    *   @return         Lazy-init invoice object
    */
    public static InvoicePrint getInvoice() {
        if (InvoiceObject == null) {
            InvoiceObject = new InvoicePrint(ApexPages.currentPage().getParameters().get('Id'));
        }
        return InvoiceObject;
    }

    /** @Description
    *   Visualforce pseudo getter for organization data
    *
    *   @return         Lazy-init org data
    */
    public static Organization getOrganization() {
        if (OrgData == null) {
            OrgData = [SELECT Id,Name,Street,City,PostalCode,Country,State FROM Organization LIMIT 1];
        }
        return OrgData;
    }

}
