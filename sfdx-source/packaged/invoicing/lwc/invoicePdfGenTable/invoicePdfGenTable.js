import { LightningElement, track } from 'lwc';

import getInvoicesWithoutPdfs from '@salesforce/apex/BillingController.getInvoicesWithoutPdfs';

import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_InvoicesPdfCreateHeader';

export default class InvoicePdfGenTable extends LightningElement {

    @track invoices;

    LABELS = {
        CARD_TITLE
    }

    connectedCallback() {
        this.getInvoices();
    }

    createAllPdfs() {
        
    }

    getInvoices() {
        getInvoicesWithoutPdfs({})
        .then((data) => {
            this.invoices = data;
        })
        .catch(() => {

        })
    }
}