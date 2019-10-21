/** @Description
*   This controller provides a static interface for handling the Invoice PDF creation
*/
public class InvoicePdfController {

    /** @Description
    *   Creates the invoice pdf file (embedded visualforce) and saves it as attachment to the
    *   invoice record. Every time the method is called, a new PDF is generated and saved as new attachment.
    *
    *   @param  invoiceId   The invoice id where the PDF is saved
    */
    @AuraEnabled
    public static void savePdfToInvoice(Id invoiceId){
        Invoice inv = new Invoice(invoiceId);
        Blob pdfFile = inv.createPdf();
        inv.addFileToAttachments(pdfFile);
        inv.commitAllChanges();
    }

}
