import { LightningElement, api, track } from 'lwc';
import { cloneInvoiceRecord, cloneInvoiceLineItemRecord } from 'c/utilities';

const PICK_VAL_DRAFT = 'Draft';
const PICK_VAL_ACTIVATED = 'Activated';
const PICK_VAL_CANCELLED = 'Cancelled';

import STATUS_FIELD from '@salesforce/schema/Invoice__c.Status__c';

export default class InvoiceCard extends LightningElement {

    oldRecord = {};
    rowdata;

    @track record;
    @track readonly = false;

    @track TotalAmount = 0;
    @track TotalGrossAmount = 0;

    @api
    get invoiceWrapper() {
        return this.rowdata;
    }
    set invoiceWrapper(value) {
        this.rowdata = value;
        this.TotalAmount = value.Record.TotalAmount__c;
        this.TotalGrossAmount = value.Record.TotalGrossAmount__c;
        this.record = cloneInvoiceRecord(this.rowdata);
    }


    /**                             EVENT LISTENERS                              */

    handleDataInput(event) {
        if (event.currentTarget.checkValidity()) {
            this.record[event.currentTarget.name] = event.detail.value;
            this.dispatchRecordChange(event.currentTarget.name);
            this.setModificationStyle(this.isModified(event.currentTarget.name), event.currentTarget);
        }
    }

    recalculateSums(event) {
        this.TotalAmount = event.detail.sumAmount;
        this.TotalGrossAmount = event.detail.sumGrossAmount;
    }

    handleActivateButtonClick() {
        this.isActivated ? this.record.Status__c = PICK_VAL_DRAFT : this.record.Status__c = PICK_VAL_ACTIVATED;
        this.readonly = this.isReadOnly;
        this.dispatchRecordChange(STATUS_FIELD.fieldApiName);
    }

    handleCancelButtonClick() {
        this.isCancelled ? this.record.Status__c = PICK_VAL_DRAFT : this.record.Status__c = PICK_VAL_CANCELLED;
        this.readonly = this.isReadOnly;
        this.dispatchRecordChange(STATUS_FIELD.fieldApiName);
    }

    addLineItem() {
        this.template.querySelector('c-invoice-line-item-datatable').addRow();
    }

    /**                             HELPER METHODS                                */

    isModified(fieldName) {
        return this.record[fieldName] !== this.rowdata.Record[fieldName];
    }

    setModificationStyle(isModified, DOMNode) {
        isModified ? DOMNode.classList.add('is-dirty') : DOMNode.classList.remove('is-dirty');
    }

    /**                             GETTERS                              */

    get isActivated() {
        return this.record.Status__c === PICK_VAL_ACTIVATED;
    }

    get isCancelled() {
        return this.record.Status__c === PICK_VAL_CANCELLED;
    }

    get isReadOnly() {
        let isReadOnly = this.record.Status__c !== PICK_VAL_DRAFT;
        return isReadOnly;
    }

    get invoiceTitle() {
        return this.record.Account__r.Name+ ' - ' + this.record.Name;
    }

    get TotalTaxes() {
        return this.TotalGrossAmount - this.TotalAmount;
    }

    dispatchRecordChange(updatedField) {
        if (this.oldRecord[updatedField] !== this.record[updatedField]) {
            this.dispatchEvent(
                new CustomEvent('recordchange', {
                    detail : {
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
    reset() {
        this.record = cloneInvoiceRecord(this.rowdata);
        this.template.querySelectorAll('lightning-input').forEach( (input) => { input.classList.remove('is-dirty'); });
        this.template.querySelector('c-invoice-line-item-datatable').reset();
    }
}