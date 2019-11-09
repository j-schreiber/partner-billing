import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import commitData from '@salesforce/apex/BillingController.commitInvoiceEditData';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_InvoicesUpdated';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';

export default class InvoiceCardList extends LightningElement {
    @track invoiceData = [];
    @track dirtyInvoices = new Map();
    @track dirtyLineItems = new Map();
    @track deletedLineItems = new Set();
    @track isWorking = false;

    LABELS = {
        TOAST_TITLE_SUCCESS,
        TOAST_TITLE_ERROR
    }

    connectedCallback() {
        this.queryInvoiceData();
    }

    /**                                         EVENT HANDLERS                                           */

    cacheUpdatedLineItem(event) {
        if (!this.dirtyLineItems.has(event.detail.extId)) this.dirtyLineItems.set(event.detail.extId, {});
        let record = this.dirtyLineItems.get(event.detail.extId);
        record[event.detail.field] = event.detail.newValue;
        record.Id = event.detail.recordId;
    }

    cacheDeletedLineItem(event) {
        if (this.dirtyLineItems.has(event.detail.extId)) this.dirtyLineItems.delete(event.detail.extId);
        if (event.detail.recordId && event.detail.recordId.length) this.deletedLineItems.add(event.detail.recordId);
    }

    cacheNewLineItem(event) {
        this.dirtyLineItems.set(event.detail.ExtId, event.detail.Record);
    }

    cacheUpdatedInvoice(event) {
        if (!this.dirtyInvoices.has(event.detail.recordId)) this.dirtyInvoices.set(event.detail.recordId, {});
        let record = this.dirtyInvoices.get(event.detail.recordId);
        record[event.detail.field] = event.detail.newValue;
        record.Id = event.detail.recordId;
    }


    /**                                         APEX CALLS                                           */

    commitDirtyRecords() {

        this.isWorking = true;

        commitData({
            invoices : this.invoiceUpdateList,
            upsertLineItems : this.upsertList,
            deleteLineItemIds : this.deleteList
        })
        .then( () => {
            this.revertAllChanges();
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_SUCCESS);
            this.isWorking = false;
        })
        .catch ( (error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_ERROR, error);
            this.isWorking = false;
        })
        
    }

    queryInvoiceData() {
        this.isWorking = true;
        getInvoices({
            status: 'Draft'
        })
        .then((result) => {
            this.invoiceData = result;
            this.isWorking = false;
        })
        .catch(() => {
            this.isWorking = false;
        })
    }


    /**                                         HELPERS                                          */

    get deleteList() {
        let arr = [];
        for (let item of this.deletedLineItems) { arr.push(item); }
        //console.log('Sending delete ids: ' + JSON.stringify(arr));
        return arr;
    }

    get upsertList() {
        let arr = [];
        this.dirtyLineItems.forEach( (value) => { arr.push(value); });
        //console.log('Sending new/modified line items: ' + JSON.stringify(arr));
        return arr;
    }

    get invoiceUpdateList() {
        let arr = [];
        this.dirtyInvoices.forEach( (value) => { arr.push(value); });
        //console.log('Sending invoices: ' + JSON.stringify(arr));
        return arr;
    }

    revertAllChanges() {
        this.invoiceData = [];
        this.dirtyInvoices = new Map();
        this.dirtyLineItems = new Map();
        this.deletedLineItems = new Set();
        this.queryInvoiceData();
    }

    dispatchToast(type, title, message) {
        let toast = new ShowToastEvent({
            title : title,
            message : message,
            variant : type
        });
        this.dispatchEvent(toast);
    }

}