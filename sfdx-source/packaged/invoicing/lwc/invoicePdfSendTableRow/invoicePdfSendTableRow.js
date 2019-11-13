import { LightningElement, track, api } from 'lwc';

export default class InvoicePdfSendTableRow extends LightningElement {
    
    @api
    get invoice() {
        return this.internalInvoice;
    }
    set invoice(value) {
        this.internalInvoice = value;
        this.pdfIsValid = value.Attachments.length === 1;
        if (value.Attachments.length === 1) this.pdfRecordId = value.Attachments[0].Id;
    }

    @track pdfIsValid = false;
    @track internalInvoice;
    @track selectedOptions;

    pdfRecordId;

    handleOptionsChange(event) {
        this.selectedOptions = event.detail;
    }

    get selectionIncomplete() {
        return !(this.selectedOptions && this.selectedOptions.contactId && this.selectedOptions.templateId);
    }

}