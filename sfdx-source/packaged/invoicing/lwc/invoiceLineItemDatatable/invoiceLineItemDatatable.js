import { LightningElement, api } from 'lwc';

export default class InvoiceLineItemDatatable extends LightningElement {
    @api lineitems;

    bubbleRecordChange(event) {
        this.dispatchEvent(
            new CustomEvent('recordchange', { detail : event.detail })
        );
    }
}