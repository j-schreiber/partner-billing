import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import commitData from '@salesforce/apex/BillingController.commitInvoiceEditData';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_InvoicesUpdated';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';
import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_InvoicesReviewHeader';

export default class InvoiceCardList extends LightningElement {

    @track isWorking = false;

    LABELS = {
        TOAST_TITLE_SUCCESS,
        TOAST_TITLE_ERROR,
        CARD_TITLE
    }

    @wire(getInvoices, { status: 'Draft' })
    invoices;

    /**                                         EVENT HANDLERS                                           */

    refreshData() {
        this.dirtyInvoices = new Map();
        this.dirtyLineItems = new Map();
        this.deletedLineItems = new Set();

        this.template.querySelectorAll('c-invoice-card').forEach( (card) => {
            if (!card.isLocked()) card.reset();
        });

        return refreshApex(this.invoices);
    }


    /**                                         APEX CALLS                                           */

    commitDirtyRecords() {

        this.isWorking = true;

        commitData({
            invoices : this.getUpdatedInvoiceRecords(),
            upsertLineItems : this.getUpdatedAndNewLineItemRecords(),
            deleteLineItemIds : this.getDeletedLineItemRecordIds()
        })
        .then( () => {
            this.refreshData();
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_SUCCESS);
            this.isWorking = false;
        })
        .catch ( (error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_ERROR, error.body.message);
            this.isWorking = false;
        })
        
    }

    /**                                         HELPERS                                          */

    getUpdatedAndNewLineItemRecords() {
        let arr = [];
        this.template.querySelectorAll('c-invoice-card').forEach ( (card) => {
            card.getModifiedLineItems().forEach( (lineItem) => arr.push(lineItem));
        })
        return arr;
    }

    getDeletedLineItemRecordIds() {
        let arr = [];
        this.template.querySelectorAll('c-invoice-card').forEach ( (card) => {
            card.getDeletedLineItems().forEach( (id) => arr.push(id));
        })
        return arr;
    }

    getUpdatedInvoiceRecords() {
        let arr = [];
        this.template.querySelectorAll('c-invoice-card').forEach ( (card) => {
            let modifiedInv = card.getModifiedFields();
            if (modifiedInv && Object.keys(modifiedInv).length > 0) arr.push(modifiedInv);
        })
        return arr;
    }
    /*
    printCache() {
        console.log('Invoice modifications: ' + JSON.stringify(this.getUpdatedInvoiceRecords()));
        console.log('All modified Line Items: ' + JSON.stringify(this.getUpdatedAndNewLineItemRecords()));
        console.log('Deleted Line Item Ids: ' + JSON.stringify(this.getDeletedLineItemRecordIds()));
    }
    */
    dispatchToast(type, title, message) {
        let toast = new ShowToastEvent({
            title : title,
            message : message,
            variant : type
        });
        this.dispatchEvent(toast);
    }

}