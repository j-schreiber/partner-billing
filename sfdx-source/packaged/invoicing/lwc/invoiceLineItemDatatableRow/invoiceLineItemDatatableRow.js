import { LightningElement, api, track } from 'lwc';

export default class InvoiceLineItemDatatableRow extends LightningElement {
    @api rowdata;
    @track record;

    connectedCallback() {
        this.record = {
            Id : this.rowdata.Record.Id,
            Price__c : this.rowdata.Record.Price__c,
            Tax__c : this.rowdata.Record.Tax__c,
            Quantity__c : this.rowdata.Record.Quantity__c,
            Discount__c : this.rowdata.Record.Discount__c
        }
    }

    updatePrice(event) {
        this.record.Price__c = event.detail.value;
        this.dispatchUpdateEvent();
    }

    updateDiscount(event) {
        this.record.Discount__c = event.detail.value;
        this.dispatchUpdateEvent();
    }

    updateTax(event) {
        this.record.Tax__c = event.detail.value;
        this.dispatchUpdateEvent();
    }

    updateQuantity(event) {
        this.record.Quantity__c = event.detail.value;
        this.dispatchUpdateEvent();
    }

    dispatchUpdateEvent() {
        this.dispatchEvent(
            new CustomEvent('recordchange', { detail : this.record })
        );
    }

    @api
    get Amount() {
        return (this.record.Price__c * this.record.Quantity__c * ((100 - this.record.Discount__c) / 100));
    }

    @api
    get GrossAmount() {
        return (this.Amount * ((1 + this.record.Tax__c / 100)));
    }
}