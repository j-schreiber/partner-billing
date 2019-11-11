import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getInvoicesWithPdfs from '@salesforce/apex/BillingController.getInvoicesWithPdfs';

import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_InvoicesPdfSendTitle';

export default class UnvoicePdfSendTable extends LightningElement {

    @wire(getInvoicesWithPdfs, {})
    invoices;

    @track isWorking = false;

    LABELS = {
        CARD_TITLE
    }

    refreshData() {
        refreshApex(this.invoices);
    }

}