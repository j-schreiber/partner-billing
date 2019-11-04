import { LightningElement, api, track } from 'lwc';

const PICK_VAL_DRAFT = 'Draft';
const PICK_VAL_ACTIVATED = 'Activated';
const PICK_VAL_CANCELLED = 'Cancelled';

export default class InvoiceCard extends LightningElement {
    @api rowdata;
    @track invoiceRecord;
    @track lineItemTable;


    connectedCallback() {
        this.invoiceRecord = {
            Id : this.rowdata.Record.Id,
            ServicePeriodTo__c : this.rowdata.Record.ServicePeriodTo__c,
            ServicePeriodFrom__c : this.rowdata.Record.ServicePeriodFrom__c,
        }
    }

    renderedCallback() {
        this.lineItemTable = this.template.querySelector('c-invoice-line-item-datatable');
    }

    handleDateInput(event) {
        this.invoiceRecord.Date__c = event.detail.value;
        this.dispatchUpdateEvent();
    }

    handleServicePeriodFromInput(event) {
        this.invoiceRecord.ServicePeriodFrom__c = event.detail.value;
        this.dispatchUpdateEvent();
    }

    handleServicePeriodToInput(event) {
        this.invoiceRecord.ServicePeriodTo__c = event.detail.value;
        this.dispatchUpdateEvent();
    }

    handleActivateButtonClick() {
        this.isActivated ? this.invoiceRecord.Status__c = PICK_VAL_DRAFT : this.invoiceRecord.Status__c = PICK_VAL_ACTIVATED;
        this.dispatchUpdateEvent();
    }

    handleCancelButtonClick() {
        this.isCancelled ? this.invoiceRecord.Status__c = PICK_VAL_DRAFT : this.invoiceRecord.Status__c = PICK_VAL_CANCELLED;
        this.dispatchUpdateEvent();
    }

    get isActivated() {
        return this.invoiceRecord.Status__c === PICK_VAL_ACTIVATED;
    }

    get isCancelled() {
        return this.invoiceRecord.Status__c === PICK_VAL_CANCELLED;
    }

    get invoiceTitle() {
        return this.rowdata.Record.Account__r.Name+ ' - ' + this.rowdata.Record.Name;
    }

    get TotalAmount() {
        return this.lineItemTable ? this.lineItemTable.SumAmount : this.rowdata.Record.TotalAmount__c;
    }

    get TotalGrossAmount() {
        return this.lineItemTable ? this.lineItemTable.SumGrossAmount : this.rowdata.Record.TotalGrossAmount__c;
    }

    get TotalTaxes() {
        return this.TotalGrossAmount - this.TotalAmount;
    }

    dispatchUpdateEvent() {
        this.dispatchEvent(
            new CustomEvent('invoicechange', { detail : this.invoiceRecord })
        );
    }

    bubbleLineItemChange(event) {
        this.dispatchEvent(
            new CustomEvent('lineitemchange', { detail : event.detail })
        );
    }
}