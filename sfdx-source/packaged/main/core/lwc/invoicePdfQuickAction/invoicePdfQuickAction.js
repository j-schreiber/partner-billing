import { LightningElement, api } from 'lwc';

export default class InvoicePdfQuickAction extends LightningElement {
    @api invoiceId;

    get invoicePdfUrl() {
        return '/apex/InvoicePdf?Id=' + this.invoiceId;
    }
}