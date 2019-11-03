/** @Description
*   This is the decorator object for the custom object Invoice__c that implements
*   functionality to create Invoices with Invoice Line Items, create PDFs and handle Attachments
*/
public virtual class Invoice {

    /** @Description    The decorated original SObject */
    @AuraEnabled
    public Invoice__c Record {public get; private set;}

    /** @Description    The invoice line items */
    @AuraEnabled
    public List<InvoiceLineItem> LineItems {public get; private set;}

    /** @Description    Attachments for this invoice */
    public List<Attachment> Attachments;

    /** @Description    Calculated total taxes */
    public Decimal TotalTaxes {
        public get {
            if (Record.TotalGrossAmount__c == null || Record.TotalAmount__c == null) {
                TotalTaxes = 0;
            } else {
                TotalTaxes = Record.TotalGrossAmount__c - Record.TotalAmount__c;
            }
            return TotalTaxes;
        }
        private set;
    }

    /** @Description    Calculated total taxes percentage */
    public Decimal TotalTaxesPercentage {
        public get {
            if (Record.TotalAmount__c == null) {
                TotalTaxesPercentage = 0;
            } else {
                TotalTaxesPercentage = TotalTaxes.divide(Record.TotalAmount__c, 4);
            }
            return TotalTaxesPercentage;
        }
        private set;
    }

    public static final String QUERY_STRING =
        'SELECT Id,Name,Date__c,Status__c,TotalAmount__c,TotalGrossAmount__c,BillingStreet__c,BillingCity__c,BillingPostalCode__c,BillingCountry__c,BillingState__c,PdfLanguage__c,PdfRenderTimesheet__c,' +
                'Account__r.Name,Account__r.CustomerId__c,ServicePeriodFrom__c,ServicePeriodTo__c,' +
                'Account__r.Owner.Name,Account__r.Owner.Phone,Account__r.Owner.Email,'+
                '(SELECT Id,Amount__c,GrossAmount__c,Description__c,Price__c,Quantity__c,ServiceDate__c,Tax__c,Unit__c,Product__r.Name,Productname__c,Discount__c FROM LineItems__r),'+
                '(SELECT Id,Name FROM Attachments),'+
                '(SELECT Id,Name,Date__c,StartTime__c,EndTime__c,Duration__c,Status__c,TotalAmount__c,Description__c,ResourceName__c FROM TimeEntries__r ORDER BY Date__c,Name ASC)'+
        ' FROM Invoice__c';

    /** @Description    Initialize the object by invoice id */
    public Invoice(String recordId) {
        try {
            this(Database.query(Invoice.QUERY_STRING + ' WHERE Id = :recordId'));
        } catch (Exception e) {
            Record = new Invoice__c();
            LineItems = new List<InvoiceLineItem>();
            Attachments = new List<Attachment>();
        }
    }

    /** @Description    Initialize the object with the fully queried record */
    public Invoice(Invoice__c originalRecord) {
        Record = originalRecord;
        Attachments = Record.Attachments;

        // get line items from related records
        LineItems = new List<InvoiceLineItem>();
        if (originalRecord.LineItems__r != null) {
            for (InvoiceLineItem__c ili : originalRecord.LineItems__r) LineItems.add(new InvoiceLineItem(ili));
        }
    }

    /** @Description
    *   Commits all changes made to the record or related records.
    */
    public void commitAllChanges() {
        upsert Attachments;
    }


}
