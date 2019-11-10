import { LightningElement, api, track } from 'lwc';

import PRODUCT_FIELD from '@salesforce/schema/InvoiceLineItem__c.Product__c';
export default class InvoiceLineItemDatatableRow extends LightningElement {
    @api rowdata;
    @api isDisabled = false;

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

    /**                         INTERNALLY UPDATE DATA                        */
    updateDescription(event) {
        this.record[event.currentTarget.name] = event.detail.value;
    }

    updateInternalData(event) {
        if (!isNaN(event.detail.value) && event.currentTarget.checkValidity()) {
            this.record[event.currentTarget.name] = Number(event.detail.value);
        }
    }

    updateProduct(event) {
        this.record[PRODUCT_FIELD.fieldApiName] = (event.detail.value.length === 0) ? '' : (event.detail.value)[0];
        this.dispatchRecordChange(PRODUCT_FIELD.fieldApiName);
        this.setModificationStyle(this.isModified(PRODUCT_FIELD.fieldApiName), event.currentTarget);
    }

    /**                         SEND UPDATES TO PARENT                           */

    dispatchUpdateEvent(event) {
        this.dispatchRecordChange(event.currentTarget.name);
        this.setModificationStyle(this.isModified(event.currentTarget.name), event.currentTarget);
    }

    isModified(fieldName) {
        return this.record[fieldName] !== this.rowdata.Record[fieldName];
    }

    setModificationStyle(isModified, DOMNode) {
        isModified ? DOMNode.classList.add('dirty-field') : DOMNode.classList.remove('dirty-field');
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