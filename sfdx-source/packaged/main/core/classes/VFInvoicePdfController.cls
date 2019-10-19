public with sharing class VFInvoicePdfController {
    
    /** @Description    The fully initialized invoice object for this context */
    public static Invoice InvoiceObject;

    public static Invoice getInvoice() {
        if (InvoiceObject == null) {
            InvoiceObject = new Invoice(ApexPages.currentPage().getParameters().get('Id'));
        }
        return InvoiceObject;
    }

}
