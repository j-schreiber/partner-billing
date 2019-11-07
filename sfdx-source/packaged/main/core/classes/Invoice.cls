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
    public List<InvoiceLineItem> LineItems {
        public get { return LineItemMap.values(); }
    }

    @AuraEnabled
    public Boolean hasLineItems {
        public get { return !LineItems.isEmpty(); }
    }

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
                '(SELECT Id,Name,Amount__c,GrossAmount__c,Description__c,Price__c,Quantity__c,ServiceDate__c,Tax__c,Unit__c,Product__c,Product__r.Name,Productname__c,Discount__c,CurrencyIsoCode FROM LineItems__r),'+
                '(SELECT Id,Name FROM Attachments),'+
                '(SELECT Id,Name,Date__c,StartTime__c,EndTime__c,Duration__c,Status__c,TotalAmount__c,Description__c,ResourceName__c FROM TimeEntries__r ORDER BY Date__c,Name ASC)'+
        ' FROM Invoice__c';

    /** @Description    All line items (with decorator object) for this invoice mapped by record id */
    public Map<Id, InvoiceLineItem> LineItemMap {public get; private set;}

    /** @Description    All time entries (with decorator object) for this invoice mapped by record id */
    public Map<Id, TimeEntry> TimeEntriesMap {
        public get {
            if (TimeEntriesMap == null) {
                TimeEntriesMap = new Map<Id, TimeEntry>();
                for (TimeEntry__c te : Record.TimeEntries__r) TimeEntriesMap.put(te.Id, new TimeEntry(te));
            }
            return TimeEntriesMap;
        }
        private set;
    }

    /** @Description    New line item records that will be added to the invoice */
    private List<InvoiceLineItem__c> newLineItemRecords;

    /** @Description    Existing/persistent line item records that have been updated */
    private Map<Id, InvoiceLineItem__c> dirtyLineItemRecords;

    /** @Description    Line item ids that will be deleted */
    private Set<Id> deleteLineItemIds;

    /** @Description    Initialize an empty and new invoice */
    public Invoice() {
        Record = new Invoice__c();
        LineItemMap = new Map<Id, InvoiceLineItem>();
        newLineItemRecords = new List<InvoiceLineItem__c>();
        dirtyLineItemRecords = new Map<Id, InvoiceLineItem__c>();
        deleteLineItemIds = new Set<Id>();
        Attachments = new List<Attachment>();
    }

    /** @Description    Initialize the object by invoice id */
    public Invoice(String recordId) {
        try {
            this(Database.query(Invoice.QUERY_STRING + ' WHERE Id = :recordId'));
        } catch (Exception e) {
            this();
        }
    }

    /** @Description    Initialize the object with the fully queried record */
    public Invoice(Invoice__c originalRecord) {
        Record = originalRecord;
        Attachments = Record.Attachments;
        newLineItemRecords = new List<InvoiceLineItem__c>();
        deleteLineItemIds = new Set<Id>();
        dirtyLineItemRecords = new Map<Id, InvoiceLineItem__c>();

        // get line items from related records
        LineItemMap = new Map<Id, InvoiceLineItem>();
        if (originalRecord.LineItems__r != null) {
            for (InvoiceLineItem__c ili : originalRecord.LineItems__r) LineItemMap.put(ili.Id, new InvoiceLineItem(ili));
        }
    }

    /** @Description
    *   Add new line item (or line-item tree) to the invoice or replaces an
    *   existing line item with an updated version.
    *
    *   @param  lineItem    The new line item or line item tree to add
    */
    public void addLineItemRecord(InvoiceLineItem__c toAdd) {
        if (LineItemMap.containsKey(toAdd.Id)) {
            dirtyLineItemRecords.put(toAdd.Id, toAdd);
        } else {
            new InvoiceLineItem(toAdd).setInvoice(this);
            newLineItemRecords.add(toAdd);
        }
    }

    /** @Description
    *   Marks the requested line item record from the invoice for deletion, if it exists and cleans
    *   all child records in the process, if this line item was parent in a hierarchy (not yet implemented)
    *
    *   @param  lineItemId  The line item id to remove
    *
    *   @return             True, if at least one line item was marked for deletion
    */
    public Boolean removeLineItemId(Id lineItemId) {
        if (LineItemMap.containsKey(lineItemId)) {
            deleteLineItemIds.add(lineItemId);
            dirtyLineItemRecords.remove(lineItemId);
            return true;
        }
        return false;
    }

    /** @Description
    *   Adds the new time entries to the internal timesheet, calculates line items and adds them
    *   to internal cache. Time Entries are updated to invoice but not DML is performed.
    *
    *   @param  collapseEntries         True: collapse similar entries to one line item
    *   @param  newTimeEntries          List of time entries that will be added to invoice's time sheet
    *
    *   @return                         The List of calculated invoice line items that were added to cache
    */
    public List<InvoiceLineItem__c> addTimeEntries(Boolean collapseEntries, List<TimeEntry__c> newTimeEntries) {
        Map<String, InvoiceLineItem__c> newRecords = new Map<String, InvoiceLineItem__c>();

        for (TimeEntry__c te : newTimeEntries) {

            te.Invoice__c = Record.Id;
            TimeEntriesMap.put(te.Id, new TimeEntry(te));

            String key = collapseEntries ? te.DailyRate__c +'-'+ te.Product__c : te.Id;
            if (!newRecords.containsKey(key)) newRecords.put(key, new InvoiceLineItem__c(Product__c=te.Product__c,Price__c=te.DailyRate__c,Quantity__c=0.00));
            newRecords.get(key).Quantity__c += te.Duration__c / 8;

        }

        newLineItemRecords.addAll(newRecords.values());
        return newRecords.values();
    }

    /** @Description
    *   Commits all changes made to the record or related records.
    */
    public CommitResult commitAllChanges() {

        CommitResult cr = new CommitResult();

        cr.InvoiceResult = Database.upsert(Record, false);

        cr.AttachmentResults = Database.upsert(Attachments, false);
        
        List<InvoiceLineItem__c> ilisToUpsert = new List<InvoiceLineItem__c>();
        ilisToUpsert.addAll(dirtyLineItemRecords.values());
        ilisToUpsert.addAll(newLineItemRecords);
        cr.LineItemResults = Database.upsert(ilisToUpsert, false);
        for (Id lineitemId : dirtyLineItemRecords.keySet()) LineItemMap.get(lineitemId).updateRecord(dirtyLineItemRecords.get(lineItemId));
        for (InvoiceLineItem__c ili : newLineItemRecords) LineItemMap.put(ili.Id, new InvoiceLineItem(ili));
        dirtyLineItemRecords.clear();
        newLineItemRecords.clear();

        cr.DeleteLineItemResults = Database.delete(new List<Id>(deleteLineItemIds));
        for (Id deletedId : deleteLineItemIds) LineItemMap.remove(deletedId);
        deleteLineItemIds.clear();

        return cr;
    }

    public class CommitResult {
        public Database.UpsertResult InvoiceResult;
        public Database.UpsertResult[] AttachmentResults;
        public Database.UpsertResult[] LineItemResults;
        public Database.DeleteResult[] DeleteLineItemResults;
    }

}
