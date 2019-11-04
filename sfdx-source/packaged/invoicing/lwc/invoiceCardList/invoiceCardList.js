import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import updateInvoices from '@salesforce/apex/BillingController.updateInvoices';
import upsertInvoiceLineItems from '@salesforce/apex/BillingController.upsertInvoiceLineItems';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_InvoicesUpdated';

export default class InvoiceCardList extends LightningElement {
    @track invoiceData = [];
    @track dirtyInvoices = {};
    @track dirtyLineItems = {};
    @track isWorking = false;

    LABELS = {
        TOAST_TITLE_SUCCESS
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

    commitDirtyRecords() {

        this.isWorking = true;

        let invProm = updateInvoices({
            invoices: Object.values(this.dirtyInvoices)
        });

        let lineitemProm = upsertInvoiceLineItems({
            lineItems: Object.values(this.dirtyLineItems)
        });

        lineitemProm
            .then( () => {
                //console.log('Line Item Resolved');
                return invProm;
            })
            .then(() => {
                //console.log('Invoices Resolved');
                this.isWorking = false;
            })
            .catch((error) => {
                //console.log('Something went wrong: ' + JSON.stringify(error));
                this.isWorking = false;
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