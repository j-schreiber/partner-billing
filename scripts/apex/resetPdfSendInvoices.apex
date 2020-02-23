/**
*   Use this code to reset all Activated invoices in the database that have a PDF generated but do not have any Time Entries.
*   Invoices with time entries can not be deleted, because invoiced time entries can not be deleted.
*   Such invoices will be used in process stage 3 (Send PDFs) of billing run. 
*
*   Execute the code with the following command to save logs
*   sfdx force:apex:execute -f .\dev-tools\anonymousApex\resetPdfSendInvoices.apex > .\dev-tools\anonymousApex\logs\resetPdfSendInvoices.log
*/

/** Adjust to increase the number of invoices generated per account */
Integer INVOICES_COUNT = 2;

/** Set FALSE if you do not want to clean invoices */
Boolean deleteInvoices = true;

/** Set FALSE if you do not want to clean documents */
Boolean deleteDocuments = true;

/**     Change here to add new products or remove products */
Product2 devProduct = [SELECT Id FROM Product2 WHERE Name LIKE '%Implementierung%'];
Product2 consultingProduct = [SELECT Id FROM Product2 WHERE Name LIKE '%Beratung%'];

if (deleteInvoices) {
    List<Id> invoiceIdsWithPdfs = new List<Id>();
    for (ContentDocument cd : [SELECT Id,(SELECT LinkedEntityId FROM ContentDocumentLinks WHERE LinkedEntity.Type = 'Invoice__c') FROM ContentDocument]) {
        if (!cd.ContentDocumentLinks.isEmpty()) {
            for (ContentDocumentLink cdl : cd.ContentDocumentLinks) invoiceIdsWithPdfs.add(cdl.LinkedEntityId);
        }
    }
    delete [SELECT Id FROM Invoice__c WHERE Status__c = 'Activated' AND Id IN :invoiceIdsWithPdfs AND Id NOT IN (SELECT Invoice__c FROM TimeEntry__c)];
}

if (deleteDocuments) {
    delete [SELECT Id FROM ContentDocument];
}

List<Invoice__c> invoices = new List<Invoice__c>();
for (Account a : [SELECT Id FROM Account]) {
    for (Integer invCount = 0; invCount < INVOICES_COUNT; invCount++) {
        invoices.add(TestDataFactory.CreateInvoice(new Invoice__c(Status__c='Activated', Account__c=a.Id,Date__c=System.today())));
    }
}
insert invoices;

List<InvoiceLineItem__c> ilis = new List<InvoiceLineItem__c>();
for (Invoice__c invoice : invoices) {
    ilis.add(TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(
        Price__c=1249.99,
        Quantity__c = (Math.random() * 5.0).setScale(3),
        Invoice__c=invoice.Id,
        Tax__c=19,
        Discount__c=0,
        Product__c=devProduct.Id,
        ServiceDate__c=getRandomDateFromLast30Days()))
    );
    ilis.add(TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(
        Price__c=555.55,
        Quantity__c = (Math.random() * 5.0).setScale(3),
        Invoice__c=invoice.Id,
        Tax__c=19,
        Discount__c=0,
        Product__c=consultingProduct.Id,
        ServiceDate__c=getRandomDateFromLast30Days()))
    );
    ilis.add(TestDataFactory.CreateInvoiceLineItem(new InvoiceLineItem__c(
        Price__c=700.00,
        Quantity__c = (Math.random() * 2.0).setScale(3),
        Invoice__c=invoice.Id,
        Tax__c=7,
        Discount__c=50,
        Description__c='Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.',
        ServiceDate__c=getRandomDateFromLast30Days()))
    );
}
insert ilis;

for (Invoice__c invoice : Database.query(Invoice.QUERY_STRING + ' WHERE Id IN :invoices')) {
    InvoicePrint inv = new InvoicePrint(invoice);
    PageReference pdfFile = inv.createPdf();
    System.debug(pdfFile);
    inv.saveToContentAttachments(pdfFile);
}

public Date getRandomDateFromLast30Days() {
    return System.today().addDays(- Integer.valueOf(Math.random() * 30));
}
