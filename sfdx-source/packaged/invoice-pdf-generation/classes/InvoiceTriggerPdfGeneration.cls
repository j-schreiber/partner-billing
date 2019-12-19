public class InvoiceTriggerPdfGeneration implements Queueable,Database.AllowsCallouts {

    private List<InvoicePrint> Invoices = new List<InvoicePrint>();

    public InvoiceTriggerPdfGeneration(Set<Id> invoiceIds) {
        for (Invoice__c inv : Database.query(Invoice.QUERY_STRING + ' WHERE Id IN :invoiceIds')) {
            Invoices.add(new InvoicePrint(inv));
        }
    }
    
    public void execute(QueueableContext context) {

        // create pdfs and insert
        Map<Id, ContentVersion> pdfFilesByInvoiceId = new Map<Id, ContentVersion>();
        for (InvoicePrint InvPrint : Invoices) {
            PageReference invoicePdfPage = InvPrint.createPdf();
            pdfFilesByInvoiceId.put(InvPrint.Record.Id, InvPrint.getPdfFileContentVersion(invoicePdfPage));
        }
        Database.SaveResult[] cvSrs = Database.insert(pdfFilesByInvoiceId.values(), false);

        // extract created content version ids
        Set<Id> contentVersionIds = new Set<Id>();
        for (Database.SaveResult sr : cvSrs) {
            System.debug(sr);
            contentVersionIds.add(sr.getId());
        }

        // attach pdfs as document to invoice, if the whole documents are new
        Map<Id, ContentVersion> pdfFiles = new Map<Id, ContentVersion>([SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds]);
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
        for (InvoicePrint InvPrint : Invoices) {
            Id cvId = pdfFilesByInvoiceId.get(InvPrint.Record.Id).Id;
            docLinks.add(new ContentDocumentLink(LinkedEntityId=InvPrint.Record.Id, ContentDocumentId=pdfFiles.get(cvId).ContentDocumentId, ShareType='V'));
        }
        Database.SaveResult[] docLinkSrs = Database.insert(docLinks, false);
    }

}
