import { LightningElement, api, track } from 'lwc';

export default class InvoiceLineItemDatatable extends LightningElement {

    @api invoiceId;
    
    @api
    get lineItems() {
        return this.originalLineItems;
    }
    set lineItems(value) {
        this.originalLineItems = value;
        this.internalLineItems = this.getLineItemMapByExtId(value);
        this.lineItemsList = this.getInternalLineItemsAsList();
    }
    originalLineItems;


    @api isDisabled = false;

    @track internalAmount;
    @track internalGrossAmount;
    @track lineItemsList;
    
    internalLineItems;
    modifiedRowRecords = new Map();
    deletedRowRecordIds = new Set();
    incremetor = 0;

    cacheRowChange(event) {
        if (!this.modifiedRowRecords.has(event.detail.extId)) this.modifiedRowRecords.set(event.detail.extId, {});
        let record = this.modifiedRowRecords.get(event.detail.extId);
        record[event.detail.field] = event.detail.newValue;
        record.Id = event.detail.recordId;
    }

    cacheRowDelete(event) {
        if (this.modifiedRowRecords.has(event.detail)) this.modifiedRowRecords.delete(event.detail);

        let recordId = this.internalLineItems.get(event.detail).Record.Id;
        if (recordId && recordId.length > 0) this.deletedRowRecordIds.add(this.internalLineItems.get(event.detail).Record.Id);

        this.internalLineItems.delete(event.detail);
        this.lineItemsList = this.getInternalLineItemsAsList();
    }

    resetRow(event) {
        if (this.modifiedRowRecords.has(event.detail)) this.modifiedRowRecords.delete(event.detail);
    }

    recalculateSums() {
        this.internalAmount = this.SumAmount;
        this.internalGrossAmount = this.SumGrossAmount;

        this.dispatchEvent(
            new CustomEvent(
                'recalculate',
                { detail : {
                    sumAmount : this.SumAmount, 
                    sumGrossAmount : this.SumGrossAmount
                }}
            )
        );
    }

    printModified() {
        let mod = this.modifiedRecords;
        let del = this.deletedRecords;
    }

    @api addRow() {
        var newItem = this.makeNewLineItem();
        this.internalLineItems.set(newItem.ExtId, newItem);
        this.modifiedRowRecords.set(newItem.ExtId, newItem.Record);
        this.lineItemsList = this.getInternalLineItemsAsList();
    }

    @api
    get modifiedRecords() {
        let arr = [];
        this.modifiedRowRecords.forEach( (value) => { arr.push(value); });
        console.log('Sending new/modified line items: ' + JSON.stringify(arr));
        return arr;
    }

    get deletedRecords() {
        let arr = [];
        for (let item of this.deletedRowRecordIds) { arr.push(item); }
        console.log('Sending delete ids: ' + JSON.stringify(arr));
        return arr;
    }

    @api 
    get SumAmount() {
        let sum = 0;
        this.template.querySelectorAll('c-invoice-line-item-datatable-row').forEach( (item) => {sum += item.Amount});
        return sum;
    }

    @api 
    get SumGrossAmount() {
        let sum = 0;
        this.template.querySelectorAll('c-invoice-line-item-datatable-row').forEach( (item) => {sum += item.GrossAmount});
        return sum;
    }

    get hasData() {
        return this.lineItemsList.length > 0;
    }

    @api
    reset() {
        this.template.querySelectorAll('c-invoice-line-item-datatable-row').forEach ( (row) => row.reset() );
        this.incremetor = 0;
        this.internalLineItems = this.getLineItemMapByExtId(this.originalLineItems);
        this.lineItemsList = this.getInternalLineItemsAsList();
        this.modifiedRowRecords = new Map();
        this.deletedRowRecordIds = new Set();
    }

    getInternalLineItemsAsList() {
        let arr = [];
        this.internalLineItems.forEach( (value) => { arr.push(value); });
        return arr;
    }

    makeNewLineItem() {
        return {
            Record : {
                Invoice__c : this.invoiceId,
                Discount__c : 0.00,
                Tax__c : 0.00,
                Quantity__c : 0.00,
                Price__c : 0.00
            },
            ExtId : this.nextLineItemId(),
            IsNew : true
        };
    }

    nextLineItemId() {
        return this.invoiceId +'-'+(this.incremetor++);
    }

    getLineItemMapByExtId(originalLineItems) {
        //console.log('Original Line Items: ' + JSON.stringify(originalLineItems));
        let map = new Map();
        originalLineItems.forEach(
            (item) => {
                //console.log(JSON.stringify(item));
                let newItem = {
                    Record : item.Record,
                    ExtId : this.nextLineItemId()
                }
                map.set(newItem.ExtId, newItem);
            }
        );
        return map;
    }

}