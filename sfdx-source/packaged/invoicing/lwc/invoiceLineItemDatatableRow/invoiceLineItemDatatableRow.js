import { LightningElement, api, track } from 'lwc';

export default class InvoiceLineItemDatatableRow extends LightningElement {
    @api rowdata;
    @track record;
    oldRecord = {};

    connectedCallback() {
        this.record = {
            Id : this.rowdata.Record.Id,
            Price__c : this.rowdata.Record.Price__c,
            Product__c : this.rowdata.Record.Product__c,
            Tax__c : this.rowdata.Record.Tax__c,
            Quantity__c : this.rowdata.Record.Quantity__c,
            Discount__c : this.rowdata.Record.Discount__c,
            Description__c : this.rowdata.Record.Description__c
        }
    }

    renderedCallback() {
        
    }

    /**                         INTERNALLY UPDATE DATA                        */
    updatePrice(event) {
        if (event.detail.value >= 0) {
            this.record.Price__c = event.detail.value;
        }
    }

    updateDiscount(event) {
        if (event.detail.value >= 0 && event.detail.value <= 100) {
            this.record.Discount__c = event.detail.value;
        }
    }

    updateTax(event) {
        if (event.detail.value >= 0) {
            this.record.Tax__c = event.detail.value;
        }
    }

    updateQuantity(event) {
        if (event.detail.value >= 0) {
            this.record.Quantity__c = event.detail.value;
        }
    }

    updateDescription(event) {
        this.record.Description__c = event.detail.value;
    }

    updateProduct(event) {
        this.record.Product__c = event.detail.value;
        this.dispatchRecordChange('Product__c');
    }

    /**                         SEND UPDATES TO PARENT                           */
    sendPriceUpdate() {
        this.dispatchRecordChange('Price__c');
    }

    sendDiscountUpdate() {
        this.dispatchRecordChange('Discount__c');
    }

    sendTaxUpdate() {
        this.dispatchRecordChange('Tax__c');
    }

    sendQuantityUpdate() {
        this.dispatchRecordChange('Quantity__c');
    }

    sendDescriptionUpdate() {
        this.dispatchRecordChange('Description__c');
    }

    /**                         ACTUAL EVENT DISPATCHERS                          */
    dispatchRecordDelete() {
        this.dispatchEvent(
            new CustomEvent('recorddelete', { detail : this.rowdata.ExtId })
        );
    }

    dispatchRecordChange(updatedField) {
        if (this.oldRecord[updatedField] !== this.record[updatedField]) {
            this.dispatchEvent(
                new CustomEvent('recordchange', {
                    detail : {
                        extId : this.rowdata.ExtId,
                        recordId : this.rowdata.Record.Id,
                        field : updatedField,
                        originalValue : this.rowdata.Record[updatedField],
                        oldValue : this.oldRecord[updatedField],
                        newValue : this.record[updatedField]
                    }
                })
            );
        }
        this.oldRecord[updatedField] = this.record[updatedField];
    }

    @api
    get Amount() {
        return (this.record.Price__c * this.record.Quantity__c * (1 - this.record.Discount__c / 100));
    }

    @api
    get GrossAmount() {
        return (this.Amount * (1 + this.record.Tax__c / 100));
    }
}