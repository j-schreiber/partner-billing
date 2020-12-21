import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getErrorsAsString } from 'c/utilities';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import commitData from '@salesforce/apex/BillingController.commitInvoiceEditData';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_InvoicesUpdated';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';
import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_InvoicesReviewHeader';
import BUTTON_LABEL_SAVE_ALL from '@salesforce/label/c.UI_Button_Label_SaveAll';
import BUTTON_TEXT_REFRESH from '@salesforce/label/c.UI_Button_Label_ResetAll';
import MESSAGE_NO_RECORDS from '@salesforce/label/c.Message_Invoicing_DraftInvoicesCompleted';

export default class InvoiceCardList extends LightningElement {

    @track isWorking = false;

    LABELS = {
        TOAST_TITLE_SUCCESS,
        TOAST_TITLE_ERROR,
        CARD_TITLE,
        BUTTON_LABEL_SAVE_ALL,
        BUTTON_TEXT_REFRESH,
        MESSAGE_NO_RECORDS
    }

    @wire(getInvoices, { status: 'Draft' })
    invoices;

    /**                                         LIFECYCLE HOOKS                                       */

    connectedCallback() {
        if (this.invoices.data) {
            refreshApex(this.invoices);
        }
    }

    /**                                         EVENT HANDLERS                                           */

    @api
    refresh() {
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
            this.refresh();
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_SUCCESS);
            this.isWorking = false;
        })
        .catch( (error) => {
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

    dispatchToast(type, title, message) {
        let toast = new ShowToastEvent({
            title : title,
            message : message,
            variant : type
        });
        this.dispatchEvent(toast);
    }

    get wireErrors() {
        if (this.invoices.error) {
            return getErrorsAsString(this.invoices.error);
        }
        return '';
    }

    get hasNoRecords() {
        return (this.invoices.data && this.invoices.data.length === 0);
    }

}