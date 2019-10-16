import { LightningElement, api } from 'lwc';

import BUTTON_LABEL_SAVE from '@salesforce/label/c.Button_Label_SaveToAttachments';

export default class InvoicePdfQuickAction extends LightningElement {
    @api invoiceId;

    LABELS = {
        BUTTON_LABEL_SAVE
    }

    get invoicePdfUrl() {
        return '/apex/InvoicePdf?Id=' + this.invoiceId;
    }
}