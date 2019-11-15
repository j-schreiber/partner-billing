import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { cloneInvoiceRecord } from 'c/utilities';

import commitData from '@salesforce/apex/BillingController.commitInvoiceEditData';
import refreshInvoices from '@salesforce/apex/BillingController.refreshInvoices';

import BUTTON_LABEL_SAVE from '@salesforce/label/c.UI_Button_Label_Save';
import BUTTON_LABEL_NEWITEM from '@salesforce/label/c.UI_Button_Label_NewLineItem';
import BUTTON_TEXT_REFRESH from '@salesforce/label/c.UI_Button_Label_ResetAll';
import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_DataSaved';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';
import TOAST_TITLE_WARNING from '@salesforce/label/c.UI_Toast_Title_NoChanges';

const PICK_VAL_DRAFT = 'Draft';
const PICK_VAL_ACTIVATED = 'Activated';
const PICK_VAL_CANCELLED = 'Cancelled';

export default class InvoiceCard extends LightningElement {

    oldRecord = {};
    rowdata;

    @track record = {};
    @track readOnly = false;
    @track isWorking = false;

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

    LABELS = {
        BUTTON_LABEL_SAVE,
        BUTTON_LABEL_NEWITEM,
        BUTTON_TEXT_REFRESH,
        TOAST_TITLE_SUCCESS,
        TOAST_TITLE_ERROR,
        TOAST_TITLE_WARNING
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

    @api 
    isModified() {
        let modifiedSoFar = false;
        if (Object.keys(this.getModifiedFields()).length > 0) modifiedSoFar = true;
        if (this.getModifiedLineItems().length > 0) modifiedSoFar = true;
        if (this.getDeletedLineItems().length > 0) modifiedSoFar = true;
        return modifiedSoFar;
    }

    @api
    isLocked() {
        return this.readOnly;
    }

    @api
    saveChanges() {

        if (!this.isModified()) {
            this.dispatchToast('warning', this.LABELS.TOAST_TITLE_WARNING);
            return;
        }

        this.isWorking = true;

        let invoiceList = [];
        let mods = this.getModifiedFields();
        if (Object.keys(mods).length > 0) invoiceList.push(mods);

        commitData({
            invoices : invoiceList,
            upsertLineItems : this.getModifiedLineItems(),
            deleteLineItemIds : this.getDeletedLineItems()
        })
        .then( () => {
            return refreshInvoices({
                invoiceIds : [this.record.Id]
            });
        })
        .then( (crispNewData) => {
            let recordMap = JSON.parse(JSON.stringify(crispNewData));
            this.rowdata = recordMap[this.rowdata.Record.Id];
            this.reset();
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_SUCCESS);
            this.isWorking = false;
        })
        .catch ( (error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_ERROR, error.body.message);
            this.isWorking = false;
        });
    }

    /**                             EVENT LISTENERS                              */

    handleDataInput(event) {
        //if (event.currentTarget.checkValidity()) {
            this.record[event.currentTarget.name] = event.detail.value;
            this.setModificationStyle(this.fieldIsModified(event.currentTarget.name), event.currentTarget);
        //}
    }

    recalculateSums(event) {
        this.TotalAmount = event.detail.sumAmount;
        this.TotalGrossAmount = event.detail.sumGrossAmount;
    }

    handleActivateButtonClick() {
        this.isActivated ? this.record.Status__c = PICK_VAL_DRAFT : this.record.Status__c = PICK_VAL_ACTIVATED;
        this.readOnly = this.evaluateLockFromStatus(this.record.Status__c);
    }

    handleCancelButtonClick() {
        this.isCancelled ? this.record.Status__c = PICK_VAL_DRAFT : this.record.Status__c = PICK_VAL_CANCELLED;
        this.readOnly = this.evaluateLockFromStatus(this.record.Status__c);
    }

    addLineItem() {
        this.template.querySelector('c-invoice-line-item-datatable').addRow();
    }

    /**                             HELPER METHODS                                */

    fieldIsModified(fieldName) {
        return this.record[fieldName] !== this.rowdata.Record[fieldName];
    }

    setModificationStyle(isModified, DOMNode) {
        isModified ? DOMNode.classList.add('is-dirty') : DOMNode.classList.remove('is-dirty');
    }

    dispatchToast(type, title, message) {
        let toast = new ShowToastEvent({
            title : title,
            message : message,
            variant : type
        });
        this.dispatchEvent(toast);
    }

    evaluateLockFromStatus(status) {
        return status !== PICK_VAL_DRAFT;
    }

    /**                             GETTERS                              */

    get isActivated() {
        return this.record.Status__c === PICK_VAL_ACTIVATED;
    }

    get isCancelled() {
        return this.record.Status__c === PICK_VAL_CANCELLED;
    }

    get invoiceTitle() {
        return this.record.Account__r.Name+ ' - ' + this.record.Name;
    }

    get TotalTaxes() {
        return this.TotalGrossAmount - this.TotalAmount;
    }

}