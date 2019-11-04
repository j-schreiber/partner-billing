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
    @track dirtyLineItems = {};
    @track deletedLineItems = {};
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
        let changedRecord = event.detail;
        this.dirtyLineItems[changedRecord.Id] = changedRecord;
    }

    cacheDeletedLineItem(event) {
        let deletedRecord = event.detail;
        this.deletedLineItems[deletedRecord.Id] = deletedRecord;
        delete this.dirtyLineItems[deletedRecord.Id];
    }

    commitDirtyRecords() {

        this.isWorking = true;

        deleteInvoiceLineItems({
            lineItems: Object.values(this.deletedLineItems)
        })
        .then(() => {
            upsertInvoiceLineItems({
                lineItems: Object.values(this.dirtyLineItems)
            })
            .then(() => {
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
        });
    }

    revertDirtyInvoices() {
        this.invoiceData = [];
        this.dirtyInvoices = {};
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