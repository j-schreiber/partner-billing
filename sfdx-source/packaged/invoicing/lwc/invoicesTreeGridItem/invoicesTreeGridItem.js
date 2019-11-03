import { LightningElement, api, track } from 'lwc';

const PICK_VAL_DRAFT = 'Draft';
const PICK_VAL_ACTIVATED = 'Activated';
const PICK_VAL_CANCELLED = 'Cancelled';

export default class InvoicesTreeGridItem extends LightningElement {
    @api rowdata;
    @track invoiceRecord;

    connectedCallback() {
        this.invoiceRecord = {
            Id : this.rowdata.Record.Id,
            ServicePeriodTo__c : this.rowdata.Record.ServicePeriodTo__c,
            ServicePeriodFrom__c : this.rowdata.Record.ServicePeriodFrom__c,
        }
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

    dispatchUpdateEvent() {
        this.dispatchEvent(
            new CustomEvent('recordchange', { detail : this.invoiceRecord })
        );
    }
}