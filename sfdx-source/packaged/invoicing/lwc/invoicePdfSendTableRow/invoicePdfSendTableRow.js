import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class InvoicePdfSendTableRow extends NavigationMixin(LightningElement) {
    
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

    pdfRecordId;

    viewPdf() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: this.pdfRecordId
            }
        });
    }
}