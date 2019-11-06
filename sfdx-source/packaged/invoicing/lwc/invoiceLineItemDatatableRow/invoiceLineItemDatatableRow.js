import { LightningElement, api, track } from 'lwc';

import PRICE_FIELD from '@salesforce/schema/InvoiceLineItem__c.Price__c';
import QUANTITY_FIELD from '@salesforce/schema/InvoiceLineItem__c.Quantity__c';
import PRODUCT_FIELD from '@salesforce/schema/InvoiceLineItem__c.Product__c';
import TAX_FIELD from '@salesforce/schema/InvoiceLineItem__c.Tax__c';
import DISCOUNT_FIELD from '@salesforce/schema/InvoiceLineItem__c.Discount__c';
import DESCRIPTION_FIELD from '@salesforce/schema/InvoiceLineItem__c.Description__c';

export default class InvoiceLineItemDatatableRow extends LightningElement {
    @api rowdata;
    @track record;
    oldRecord = {};

    /**                         LIFECYCLE HOOKS                             */
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

    disconnectedCallback() {
        this.dispatchRecalculate();
    }

    renderedCallback() {
        //console.log('Row rendered!' + JSON.stringify(this.record));   
    }

    /**                         INTERNALLY UPDATE DATA                        */
    updatePrice(event) {
        if (!isNaN(event.detail.value) && event.detail.value >= 0) {
            this.record.Price__c = Number(event.detail.value);
        }
    }

    updateDiscount(event) {
        if (!isNaN(event.detail.value) && event.detail.value >= 0 && event.detail.value <= 100) {
            this.record.Discount__c = Number(event.detail.value);
        }
    }

    updateTax(event) {
        if (!isNaN(event.detail.value) && event.detail.value >= 0) {
            this.record.Tax__c = Number(event.detail.value);
        }
    }

    updateQuantity(event) {
        if (!isNaN(event.detail.value) && event.detail.value >= 0) {
            this.record.Quantity__c = Number(event.detail.value);
        }
    }

    updateDescription(event) {
        this.record.Description__c = event.detail.value;
    }

    updateProduct(event) {
        this.record.Product__c = (event.detail.value)[0];
        this.dispatchRecordChange(PRODUCT_FIELD.fieldApiName);
    }

    /**                         SEND UPDATES TO PARENT                           */
    sendPriceUpdate() {
        this.dispatchRecordChange(PRICE_FIELD.fieldApiName);
    }

    sendDiscountUpdate() {
        this.dispatchRecordChange(DISCOUNT_FIELD.fieldApiName);
    }

    sendTaxUpdate() {
        this.dispatchRecordChange(TAX_FIELD.fieldApiName);
    }

    sendQuantityUpdate() {
        this.dispatchRecordChange(QUANTITY_FIELD.fieldApiName);
    }

    sendDescriptionUpdate() {
        this.dispatchRecordChange(DESCRIPTION_FIELD.fieldApiName);
    }

    /**                         ACTUAL EVENT DISPATCHERS                          */
    dispatchRecordDelete() {
        this.dispatchEvent(
            new CustomEvent('recorddelete', { detail : this.rowdata.ExtId })
        );
    }

    dispatchRecalculate() {
        this.dispatchEvent(new CustomEvent('recalculate'));
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
            this.dispatchRecalculate();
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