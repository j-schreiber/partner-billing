import { LightningElement, api } from 'lwc';

export default class InvoiceLineItemDatatable extends LightningElement {
    @api lineitems;
    lineItems;

    bubbleRecordChange(event) {
        this.dispatchEvent(
            new CustomEvent('recordchange', { detail : event.detail })
        );
    }

    renderedCallback() {
        this.lineItems = this.template.querySelectorAll('c-invoice-line-item-datatable-row');
    }

    @api
    get SumAmount() {
        let sum = 0;
        this.lineItems.forEach( (item) => {sum += item.Amount});
        return sum;
    }

    @api
    get SumGrossAmount() {
        let sum = 0;
        this.lineItems.forEach( (item) => {sum += item.GrossAmount});
        return sum;
    }
}