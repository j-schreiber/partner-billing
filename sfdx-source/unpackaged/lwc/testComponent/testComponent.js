import { LightningElement, track } from 'lwc';

import getInvoice from '@salesforce/apex/InvoiceController.getInvoice';

export default class TestComponent extends LightningElement {

    recordId = 'a061k000002cWnKAAU';
    @track invoice;
    @track hasError = false;
    @track isWorking = true;

    connectedCallback() {
        this.getLineItemData();
    }

    getLineItemData() {
        this.isWorking = true;
        getInvoice({
            recordId : this.recordId
        })
        .then((result) => {
            this.invoice = result;
            this.isWorking = false;
        })
        .catch(() => {
            this.hasError = true;
            this.isWorking = false;
        })
    }

}