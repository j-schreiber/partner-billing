import { LightningElement, api } from 'lwc';
export default class InvoiceLineItemDatatable extends LightningElement {
    @api invoiceId;
    @api lineItems;
    @api isDisabled;

    @api getDeletedRows() {return this.deletedRows; }
    @api setDeletedRows(value) { this.deletedRows = value; }
    deletedRows;
    
    @api getModifiedRows() {}
}