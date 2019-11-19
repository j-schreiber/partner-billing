import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getInvoicesWithPdfs from '@salesforce/apex/BillingController.getInvoicesWithPdfs';

import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_InvoicesPdfSendTitle';
import MESSAGE_NO_RECORDS from '@salesforce/label/c.Message_Invoicing_NoPdfSendInvoices';

export default class UnvoicePdfSendTable extends LightningElement {

    @wire(getInvoicesWithPdfs, {})
    invoices;

    @track isWorking = false;

    LABELS = {
        CARD_TITLE,
        MESSAGE_NO_RECORDS
    }

    @api
    refresh() {
        refreshApex(this.invoices);
    }

    connectedCallback() {
        if (this.invoices.data) {
            refreshApex(this.invoices);
        }
    }

    get hasNoRecords() {
        return (this.invoices.data && this.invoices.data.length === 0);
    }

}