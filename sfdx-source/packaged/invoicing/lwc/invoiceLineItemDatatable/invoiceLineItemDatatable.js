import { LightningElement, api, track } from 'lwc';
import { getMapValuesAsList } from 'c/utilities';

export default class InvoiceLineItemDatatable extends LightningElement {

    @api invoiceId;
    
    @api
    get lineItems() {
        return this.originalLineItems;
    }
    set lineItems(value) {
        this.originalLineItems = value;
        this.internalLineItems = this.getLineItemMapByExtId(value);
        this.lineItemsList = getMapValuesAsList(this.internalLineItems);
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

    /**                                     PUBLIC COMPONENT API                                     */

    @api 
    addRow() {
        var newItem = this.makeNewLineItem();
        this.internalLineItems.set(newItem.ExtId, newItem);
        this.modifiedRowRecords.set(newItem.ExtId, newItem.Record);
        this.lineItemsList = getMapValuesAsList(this.internalLineItems);
    }

    @api
    getModifiedRows() {
        let arr = [];
        this.modifiedRowRecords.forEach( (value) => { arr.push(value); });
        return arr;
    }

    @api
    getDeletedRows() {
        let arr = [];
        this.deletedRowRecordIds.forEach( (value) => { arr.push(value); });
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

    @api
    reset() {
        this.template.querySelectorAll('c-invoice-line-item-datatable-row').forEach ( (row) => row.reset() );
        this.incremetor = 0;
        this.internalLineItems = this.getLineItemMapByExtId(this.originalLineItems);
        this.lineItemsList = getMapValuesAsList(this.internalLineItems);
        this.modifiedRowRecords = new Map();
        this.deletedRowRecordIds = new Set();
    }


    /**                                     INTERNAL FUNCTIONS                                 */

    cacheRowChange(event) {
        if (!this.modifiedRowRecords.has(event.detail.extId)) this.modifiedRowRecords.set(event.detail.extId, {});
        let record = this.modifiedRowRecords.get(event.detail.extId);
        record[event.detail.field] = event.detail.newValue;
        record.Id = event.detail.recordId;
    }

    cacheRowDelete(event) {
        if (this.modifiedRowRecords.has(event.detail)) this.modifiedRowRecords.delete(event.detail);

        let recordId = this.internalLineItems.get(event.detail).Record.Id;
        if (recordId && recordId.length > 0) this.deletedRowRecordIds.add(recordId);

        this.internalLineItems.delete(event.detail);
        this.lineItemsList = getMapValuesAsList(this.internalLineItems);
    }

    resetRow(event) {
        if (this.modifiedRowRecords.has(event.detail)) this.modifiedRowRecords.delete(event.detail);
    }

    recalculateSums(event) {
        event.stopPropagation();
        
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

    get hasData() {
        return this.lineItemsList.length > 0;
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