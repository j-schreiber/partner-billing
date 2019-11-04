import { LightningElement, api, track } from 'lwc';

export default class InvoiceLineItemDatatable extends LightningElement {
    @api lineitems;
    @api invoiceId;

    @track internalLineItems = [];

    lineItemTableRows;

    bubbleRecordChange(event) {
        this.dispatchEvent(
            new CustomEvent('recordchange', { detail : event.detail })
        );
    }

    renderedCallback() {
        this.lineItemTableRows = this.template.querySelectorAll('c-invoice-line-item-datatable-row');
    }

    connectedCallback() {
        this.internalLineItems.push(this.lineitems);
        //this.internalLineItems.push(this.NewLineItem);
        //console.log(JSON.stringify(this.internalLineItems));
    }

    get NewLineItem() {
        return {
            Record : {
                Invoice__c : this.invoiceId,
                Productname__c : "New",
                Id : '1'
            }
        };
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