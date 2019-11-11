import { LightningElement, track, wire } from 'lwc';

import getInvoicesWithoutPdfs from '@salesforce/apex/BillingController.getInvoicesWithoutPdfs';
import { refreshApex } from '@salesforce/apex';

import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_InvoicesPdfCreateHeader';

export default class InvoicePdfGenTable extends LightningElement {

    @track isWorking = false;

    LABELS = {
        CARD_TITLE
    }

    @wire(getInvoicesWithoutPdfs, {}) invoices;

    refreshData() {
        this.isWorking = true;
        refreshApex(this.invoices);
        this.isWorking = false;
    }

    createAllPdfs() {
        
    }

}