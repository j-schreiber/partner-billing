import { LightningElement, api, track } from 'lwc';
import { cloneInvoiceRecord } from 'c/utilities';

const PICK_VAL_DRAFT = 'Draft';
const PICK_VAL_ACTIVATED = 'Activated';
const PICK_VAL_CANCELLED = 'Cancelled';

export default class InvoiceCard extends LightningElement {

    oldRecord = {};
    rowdata;

    @track record = {};
    @track readonly = false;

    @track TotalAmount = 0;
    @track TotalGrossAmount = 0;

    @api
    get invoice() {
        return this.rowdata;
    }
    set invoice(value) {
        this.rowdata = value;
        this.TotalAmount = value.Record.TotalAmount__c;
        this.TotalGrossAmount = value.Record.TotalGrossAmount__c;
        this.record = cloneInvoiceRecord(this.rowdata);
    }

    /**                             PUBLIC COMPONENT API                         */

    @api
    reset() {
        this.record = cloneInvoiceRecord(this.rowdata);
        this.TotalAmount = this.rowdata.Record.TotalAmount__c;
        this.TotalGrossAmount = this.rowdata.Record.TotalGrossAmount__c;

        this.template.querySelectorAll('lightning-input').forEach( (input) => { input.classList.remove('is-dirty'); });
        this.template.querySelector('c-invoice-line-item-datatable').reset();
    }

    @api
    getModifiedFields() {
        let inv = {};
        Object.keys(this.record).forEach ( (key) => {
            if (this.record[key] !== this.rowdata.Record[key] && key.endsWith('__c')) {
                inv[key] = this.record[key];
            }
        });
        if (Object.keys(inv).length > 0) inv.Id = this.record.Id;
        return inv;
    }

    @api
    getModifiedLineItems() {
        return this.template.querySelector('c-invoice-line-item-datatable').getModifiedRows();
    }

    @api
    getDeletedLineItems() {
        return this.template.querySelector('c-invoice-line-item-datatable').getDeletedRows();
    }

    /**                             EVENT LISTENERS                              */

    handleDataInput(event) {
        if (event.currentTarget.checkValidity()) {
            this.record[event.currentTarget.name] = event.detail.value;
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
    }

    handleCancelButtonClick() {
        this.isCancelled ? this.record.Status__c = PICK_VAL_DRAFT : this.record.Status__c = PICK_VAL_CANCELLED;
        this.readonly = this.isReadOnly;
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

}