import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getErrorsAsString } from 'c/utilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';

import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_InvoicesPdfCreateHeader';
import MESSAGE_NO_RECORDS from '@salesforce/label/c.Message_Invoicing_NoActivatedInvoices';

export default class InvoicePdfGenTable extends LightningElement {

    @track isWorking = false;

    LABELS = {
        CARD_TITLE,
        MESSAGE_NO_RECORDS
    }

    @wire(getInvoices, { status: 'Activated' })
    invoices;

    @api
    refresh() {
        refreshApex(this.invoices);
    }

    connectedCallback() {
        if (this.invoices.data) {
            refreshApex(this.invoices);
        }
    }

    createAllPdfs() {
        let rows = this.template.querySelectorAll('c-invoice-pdf-gen-table-row');
        if (rows.length === 0) {
            this.dispatchToast('warning', 'bla');
            return;
        }
        rows.forEach( (row) => { row.createPdf(); });
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

    dispatchToast(toastVariant, toastTitle, toastMessage) {
        let toast = new ShowToastEvent({
            title : toastTitle,
            message : toastMessage,
            variant : toastVariant
        });
        this.dispatchEvent(toast);
    }

}