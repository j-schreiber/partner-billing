import { LightningElement, api, track } from 'lwc';

const PICK_VAL_DRAFT = 'Draft';
const PICK_VAL_ACTIVATED = 'Activated';
const PICK_VAL_CANCELLED = 'Cancelled';
/*
import DATE_FIELD from '@salesforce/schema/Invoice__c.Date__c';
import PERIOD_STARTED_FIELD from '@salesforce/schema/Invoice__c.ServicePeriodFrom__c';
import PERIOD_ENDED_FIELD from '@salesforce/schema/Invoice__c.ServicePeriodTo__c'; */
import STATUS_FIELD from '@salesforce/schema/Invoice__c.Status__c';

export default class InvoiceCard extends LightningElement {

    record;
    oldRecord = {};
    rowdata;

    @track internalLineItems = [];
    @track readonly = false;

    @track TotalAmount = 0;
    @track TotalGrossAmount = 0;

    // used to construct the next line item id
    incremetor = 0;

    @api
    get invoiceWrapper() {
        return this.rowdata;
    }
    set invoiceWrapper(value) {
        this.rowdata = value;
        this.TotalAmount = value.Record.TotalAmount__c;
        this.TotalGrossAmount = value.Record.TotalGrossAmount__c;

        this.record = {
            Id : value.Record.Id,
            Date__c : value.Record.Date__c,
            ServicePeriodTo__c : value.Record.ServicePeriodTo__c,
            ServicePeriodFrom__c : value.Record.ServicePeriodFrom__c,
            Account__r : { Name : value.Record.Account__r.Name },
            Status__c : value.Record.Status__c,
            Name : value.Record.Name,
            TotalAmount__c : value.Record.TotalAmount__c,
            TotalGrossAmount__c : value.Record.TotalGrossAmount__c
        }

        value.LineItems.forEach(
            (item) => {
                // clone the line item object from apex
                let newItem = {
                    Record : {
                        Id : item.Record.Id,
                        Price__c : item.Record.Price__c,
                        Discount__c : item.Record.Discount__c,
                        Tax__c : item.Record.Tax__c,
                        Quantity__c : item.Record.Quantity__c,
                        Product__c : item.Record.Product__c,
                        Productname__c : item.Record.Productname__c,
                        Description__c : item.Record.Description__c
                    },
                    ExtId : this.nextLineItemId()
                }
                // add to internal list, so we can modify
                this.internalLineItems.push(newItem);
            }
        );
    }


    /**                             EVENT LISTENERS                              */

    handleDataInput(event) {
        if (event.currentTarget.checkValidity()) {
            this.record[event.currentTarget.name] = event.detail.value;
        }
    }

    dispatchUpdateEvent(event) {
        this.dispatchRecordChange(event.currentTarget.name);
        this.setModificationStyle(this.isModified(event.currentTarget.name), event.currentTarget);
    }

    recalculateSums(event) {
        this.TotalAmount = event.detail.sumAmount;
        this.TotalGrossAmount = event.detail.sumGrossAmount;
    }

    handleActivateButtonClick() {
        this.isActivated ? this.record.Status__c = PICK_VAL_DRAFT : this.record.Status__c = PICK_VAL_ACTIVATED;
        this.readonly = this.getIsReadOnly();
        this.dispatchRecordChange(STATUS_FIELD.fieldApiName);
    }

    handleCancelButtonClick() {
        this.isCancelled ? this.record.Status__c = PICK_VAL_DRAFT : this.record.Status__c = PICK_VAL_CANCELLED;
        this.readonly = this.getIsReadOnly();
        this.dispatchRecordChange(STATUS_FIELD.fieldApiName);
    }

    /**                             HELPER METHODS                                */

    isModified(fieldName) {
        return this.record[fieldName] !== this.rowdata.Record[fieldName];
    }

    setModificationStyle(isModified, DOMNode) {
        isModified ? DOMNode.classList.add('is-dirty') : DOMNode.classList.remove('is-dirty');
    }

    addLineItem() {
        var newItem = this.NewLineItem;
        this.internalLineItems.push(newItem);

        this.dispatchEvent(
            new CustomEvent('lineitemcreate', { detail : newItem })
        );
    }

    get isActivated() {
        return this.record.Status__c === PICK_VAL_ACTIVATED;
    }

    get isCancelled() {
        return this.record.Status__c === PICK_VAL_CANCELLED;
    }

    getIsReadOnly() {
        let isReadOnly = this.record.Status__c !== PICK_VAL_DRAFT;
        return isReadOnly;
    }

    get invoiceTitle() {
        return this.record.Account__r.Name+ ' - ' + this.record.Name;
    }

    get TotalTaxes() {
        return this.TotalGrossAmount - this.TotalAmount;
    }

    get NewLineItem() {
        return {
            Record : {
                Invoice__c : this.record.Id,
                Discount__c : 0.00,
                Tax__c : 0.00,
                Quantity__c : 0.00,
                Price__c : 0.00
            },
            ExtId : this.nextLineItemId()
        };
    }

    bubbleLineItemChange(event) {
        this.dispatchEvent(
            new CustomEvent('lineitemchange', { detail : event.detail })
        );
    }

    bubbleLineItemDelete(extId, recordId) {
        this.dispatchEvent(
            new CustomEvent('lineitemdelete', { detail : {extId : extId, recordId : recordId} })
        );
    }

    removeLineItem(event) {

        let newLineItems = this.internalLineItems.filter((value) => {
            if (value.ExtId !== event.detail) {
                return true;
            }
            this.bubbleLineItemDelete(event.detail, value.Record.Id);
            return false;
        });

        this.internalLineItems = newLineItems;
    }

    nextLineItemId() {
        return this.record.Id +'-'+(this.incremetor++);
    }

    dispatchRecordChange(updatedField) {
        if (this.oldRecord[updatedField] !== this.record[updatedField]) {
            this.dispatchEvent(
                new CustomEvent('recordchange', {
                    detail : {
                        recordId : this.rowdata.Record.Id,
                        field : updatedField,
                        originalValue : this.rowdata.Record[updatedField],
                        oldValue : this.oldRecord[updatedField],
                        newValue : this.record[updatedField]
                    }
                })
            );
        }
        this.oldRecord[updatedField] = this.record[updatedField];
    }
}