import { LightningElement, api } from 'lwc';

export default class InvoiceLineItemDatatable extends LightningElement {
    @api lineitems;

    lineItemTableRows;

    bubbleRecordChange(event) {
        this.dispatchEvent(
            new CustomEvent('recordchange', { detail : event.detail })
        );
    }

    bubbleRecordDelete(event) {
        this.dispatchEvent(
            new CustomEvent('recorddelete', { detail : event.detail })
        );
    }

    renderedCallback() {
        this.lineItemTableRows = this.template.querySelectorAll('c-invoice-line-item-datatable-row');
    }

    @api
    get SumAmount() {
        let sum = 0;
        this.lineItemTableRows.forEach( (item) => {sum += item.Amount});
        return sum;
    }

    @api
    get SumGrossAmount() {
        let sum = 0;
        this.lineItemTableRows.forEach( (item) => {sum += item.GrossAmount});
        return sum;
    }
}