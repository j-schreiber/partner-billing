import { LightningElement, api, track } from 'lwc';
import { cloneInvoiceLineItemRecord } from 'c/utilities';
export default class InvoiceLineItemDatatableRow extends LightningElement {
    rowdata;
    @api isDisabled = false;

    @track record;
    oldRecord = {};
    hasRendered = false;

    @api
    get lineItem() {
        return this.rowdata;
    }
    set lineItem(value) {
        this.rowdata = value;
        this.record = cloneInvoiceLineItemRecord(value);
    }

    /**                         LIFECYCLE HOOKS                             */

    disconnectedCallback() {
        this.dispatchRecalculate();
    }

    renderedCallback() {
        if (this.rowdata.IsNew && !this.hasRendered) {
            this.template.querySelectorAll('lightning-input').forEach( (input) => { input.classList.add('is-dirty'); });
            this.template.querySelectorAll('div.input-field-container').forEach( (input) => { input.classList.add('is-dirty'); });
            this.hasRendered = true;
        }
    }

    /**                                     COMPONENT PUBLIC API                                  */

    @api
    get Amount() {
        return (this.record.Price__c * this.record.Quantity__c * (1 - this.record.Discount__c / 100));
    }

    @api
    get GrossAmount() {
        return (this.Amount * (1 + this.record.Tax__c / 100));
    }

    @api
    reset() {
        this.oldRecord = {};
        if (this.rowdata.IsNew) {
            this.record = {Price__c : 0, Tax__c : 0, Discount__c : 0, Quantity__c : 0, Product__c : '', Description__c : ''};
            Object.keys(this.record).forEach ( (key) => this.dispatchRecordChange(key));
        } else {
            this.record = cloneInvoiceLineItemRecord(this.rowdata);
            this.dispatchRecordReset();
            this.template.querySelectorAll('lightning-input').forEach ((input) => { input.classList.remove('is-dirty'); } );
            this.template.querySelectorAll('div.input-field-container').forEach( (input) => { input.classList.remove('is-dirty'); });
        }
        this.dispatchRecalculate();
    }

    /**                         INTERNALLY UPDATE DATA                        */
    updateDescription(event) {
        this.record[event.currentTarget.name] = event.detail.value;
    }

    updateInternalData(event) {
        if (!isNaN(event.detail.value) && event.currentTarget.checkValidity()) {
            this.record[event.currentTarget.name] = Number(event.detail.value);
        }
    }

    updateProduct(event) {
        this.record[event.currentTarget.name] = (event.detail && event.detail.value.length === 0) ? '' : (event.detail.value)[0];
        this.evaluateRecordChange(event.currentTarget.name);
        this.setModificationStyle(this.isModified(event.currentTarget.name), this.template.querySelector('div.input-field-container'));
    }

    /**                         SEND UPDATES TO PARENT                           */

    handleFieldUpdate(event) {
        this.evaluateRecordChange(event.currentTarget.name);
        this.setModificationStyle(this.isModified(event.currentTarget.name), event.currentTarget);
    }

    isModified(fieldName) {
        return ((this.record[fieldName] !== this.rowdata.Record[fieldName]) && !(this.record[fieldName] === "" && !this.rowdata.Record[fieldName])) || this.rowdata.IsNew;
    }

    setModificationStyle(isModified, DOMNode) {
        isModified ? DOMNode.classList.add('is-dirty') : DOMNode.classList.remove('is-dirty');
    }

    /**                         ACTUAL EVENT DISPATCHERS                          */
    
    dispatchRecordDelete() {
        this.dispatchEvent(
            new CustomEvent('recorddelete', { detail : this.rowdata.ExtId })
        );
    }

    dispatchRecordReset() {
        this.dispatchEvent(
            new CustomEvent('recordreset', { detail : this.rowdata.ExtId })
        );
    }

    dispatchRecalculate() {
        this.dispatchEvent(new CustomEvent('recalculate'));
    }

    evaluateRecordChange(updatedField) {
        if (this.oldRecord[updatedField] !== this.record[updatedField]) {
            this.dispatchRecordChange(updatedField);
            this.dispatchRecalculate();
        }
        this.oldRecord[updatedField] = this.record[updatedField];
    }

    dispatchRecordChange(updatedField) {
        this.dispatchEvent(
            new CustomEvent('recordchange', {
                detail : {
                    extId : this.rowdata.ExtId,
                    recordId : this.rowdata.Record.Id,
                    field : updatedField,
                    originalValue : this.rowdata.Record[updatedField],
                    oldValue : this.oldRecord[updatedField],
                    newValue : this.record[updatedField]
                }
            })
        );
    }
}