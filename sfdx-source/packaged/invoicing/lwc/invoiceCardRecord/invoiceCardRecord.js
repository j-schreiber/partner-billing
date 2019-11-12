import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvoice from '@salesforce/apex/InvoiceController.getInvoice';
import commitInvoiceLineItems from '@salesforce/apex/InvoiceController.commitInvoiceLineItems';

import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';
import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_LineItemsUpdated';
export default class InvoiceCardRecord extends LightningElement {
    @api recordId;

    @wire(getInvoice, { recordId : '$recordId' })
    invoice;

    @track isWorking = true;

    LABELS = {
        TOAST_TITLE_ERROR,
        TOAST_TITLE_SUCCESS
    }

    addLineItem() {
        this.template.querySelector('c-invoice-line-item-datatable').addRow();
    }

    commitLineItems() {
        this.isWorking = true;
        commitInvoiceLineItems({
            recordId : this.recordId,
            lineItemsToUpsert : this.getModifiedLineItems(),
            lineItemsToDelete : this.getDeletedLineItems()
        })
        .then( () => {
            updateRecord({ fields: { Id: this.recordId } });
            this.dispatchToast('success', TOAST_TITLE_SUCCESS);
            this.isWorking = false;
        })
        .catch( (error) => {
            this.dispatchToast('error', TOAST_TITLE_ERROR, error.body.message);
            this.hasError = true;
            this.isWorking = false;
        });
    }

    @api
    reset() {
        refreshApex(this.wiredInvoice);
        this.template.querySelector('c-invoice-line-item-datatable').reset();
    }

    getModifiedLineItems() {
        return this.template.querySelector('c-invoice-line-item-datatable').getModifiedRows();
    }

    getDeletedLineItems() {
        return this.template.querySelector('c-invoice-line-item-datatable').getDeletedRows();
    }

    dispatchToast(toastVariant, toastTitle, toastMessage) {
        let toast = new ShowToastEvent({
            title : toastTitle,
            message : toastMessage,
            variant : toastVariant
        });
        this.dispatchEvent(toast);
    }

}