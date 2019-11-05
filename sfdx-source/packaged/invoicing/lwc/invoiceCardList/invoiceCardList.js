import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import updateInvoices from '@salesforce/apex/BillingController.updateInvoices';
import upsertInvoiceLineItems from '@salesforce/apex/BillingController.upsertInvoiceLineItems';
import deleteInvoiceLineItems from '@salesforce/apex/BillingController.deleteInvoiceLineItems';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_InvoicesUpdated';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';

export default class InvoiceCardList extends LightningElement {
    @track invoiceData = [];
    @track dirtyInvoices = {};
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

    cacheUpdatedInvoice(event) {
        let changedRecord = event.detail;
        this.dirtyInvoices[changedRecord.Id] = changedRecord;
    }

    cacheUpdatedLineItem(event) {
        //console.log('Getting upsert: ' + JSON.stringify(event));
        if (!this.dirtyLineItems.has(event.detail.extId)) this.dirtyLineItems.set(event.detail.extId, {});
        let record = this.dirtyLineItems.get(event.detail.extId);
        record[event.detail.field] = event.detail.newValue;
        record.Id = event.detail.recordId;
    }

    cacheDeletedLineItem(event) {
        //console.log('Getting delete: ' + JSON.stringify(event.detail));
        if (this.dirtyLineItems.has(event.detail)) this.dirtyLineItems.delete(event.detail);
        if (event.detail.recordId && event.detail.recordId.length) this.deletedLineItems.add(event.detail.recordId);
    }

    commitDirtyRecords() {

        this.isWorking = true;

        deleteInvoiceLineItems({
            lineItemIds: this.lineItemIdsToDelete()
        })
        .then(() => {
            this.deletedLineItems = new Set();
            upsertInvoiceLineItems({
                lineItems: this.lineItemsToUpsert()
            })
            .then(() => {
                this.dirtyLineItems = new Map();
                updateInvoices({
                    invoices: Object.values(this.dirtyInvoices)
                }).then(() => {
                    let successToast = new ShowToastEvent({
                        title : this.LABELS.TOAST_TITLE_SUCCESS,
                        variant : 'success'
                    });
                    this.dispatchEvent(successToast);
                    this.isWorking = false;
                });
            });
        })
        .catch(() => {
            this.dispatchErrorToast('Deleting Line Items Failed');
        });
    }

    dispatchErrorToast(title, message) {
        let errorToast = new ShowToastEvent({
            title : title,
            message : message,
            variant : 'error'
        });
        this.dispatchEvent(errorToast);
    }

    lineItemIdsToDelete() {
        let arr = [];
        for (let item of this.deletedLineItems) { arr.push(item); }
        return arr;
    }

    lineItemsToUpsert() {
        let arr = [];
        this.dirtyLineItems.forEach( (value) => { arr.push(value); });
        return arr;
    }

    revertAllChanges() {
        this.invoiceData = [];
        this.dirtyInvoices = {};
        this.dirtyLineItems = new Map();
        this.deletedLineItems = new Set();
        this.queryInvoiceData();
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
}