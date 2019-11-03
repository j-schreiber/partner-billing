import { LightningElement, api } from 'lwc';

export default class InvoiceLineItemDatatable extends LightningElement {
    @api lineitems;

    connectedCallback() {
        console.log(JSON.stringify(this.lineitems));
    }
}