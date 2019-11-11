import { LightningElement, track, wire } from 'lwc';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import { refreshApex } from '@salesforce/apex';

import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_InvoicesPdfCreateHeader';

export default class InvoicePdfGenTable extends LightningElement {

    @track isWorking = false;

    LABELS = {
        CARD_TITLE
    }

    @wire(getInvoices, { status: 'Activated' })
    invoices;

    refreshData() {
        refreshApex(this.invoices);
    }

    createAllPdfs() {
        
    }

}