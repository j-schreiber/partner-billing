import { LightningElement, api, track } from 'lwc';

export default class InvoiceLineItemDatatable extends LightningElement {
    @api lineitems = [];
    @api isDisabled = false;

    @track internalAmount;
    @track internalGrossAmount;

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

    recalculateSums() {
        this.internalAmount = this.SumAmount;
        this.internalGrossAmount = this.SumGrossAmount;

        this.dispatchEvent(
            new CustomEvent(
                'recalculate',
                { detail : {
                    sumAmount : this.SumAmount, 
                    sumGrossAmount : this.SumGrossAmount
                }}
            )
        );
    }

    @api get SumAmount() {
        let sum = 0;
        this.template.querySelectorAll('c-invoice-line-item-datatable-row').forEach( (item) => {sum += item.Amount});
        return sum;
    }

    @api get SumGrossAmount() {
        let sum = 0;
        this.template.querySelectorAll('c-invoice-line-item-datatable-row').forEach( (item) => {sum += item.GrossAmount});
        return sum;
    }
}