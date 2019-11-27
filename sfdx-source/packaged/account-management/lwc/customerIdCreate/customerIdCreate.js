import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getLatestCustomerId from '@salesforce/apex/AccountController.getLatestCustomerId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CUSTOMER_ID_FIELD from '@salesforce/schema/Account.CustomerId__c';
import CUSTOMER_ID_NUMBER_FIELD from '@salesforce/schema/Account.CustomerIdNumber__c';

export default class CustomerIdCreate extends LightningElement {
    @api recordId;
    @track isWorking = false;
    @track newCustomerId;

    @wire(getRecord, { recordId: '$recordId', fields: [CUSTOMER_ID_FIELD, CUSTOMER_ID_NUMBER_FIELD] })
    account;

    @api
    get CustomerId() {
        if (this.account.data && getFieldValue(this.account.data, CUSTOMER_ID_NUMBER_FIELD) !== null) {
            return getFieldValue(this.account.data, CUSTOMER_ID_NUMBER_FIELD);
        } else if (this.newCustomerId) {
            return this.newCustomerId;
        }
        return undefined;
    }

    get hasCustomerId() {
        if (this.account.data) {
            return getFieldValue(this.account.data, CUSTOMER_ID_FIELD) !== null;
        }
        return false;
    }

    get disableActions() {
        return this.hasCustomerId || this.isWorking;
    }

    handleCustomerIdInput(event) {
        if (!isNaN(event.detail.value) && event.currentTarget.checkValidity()) {
            this.newCustomerId = Number(event.detail.value);
        } else {
            this.newCustomerId = undefined;
        }
    }

    createNextCustomerId() {
        this.isWorking = true;
        getLatestCustomerId()
        .then((result) => {
            this.newCustomerId = result === 0 ? 1000 : result + 1;
            this.isWorking = false;
        })
        .catch(() => {
            this.isWorking = false;
        });
    }

    saveNewCustomerId() {
        this.isWorking = true;

        let fields = {};
        fields.Id = this.recordId;
        fields[CUSTOMER_ID_FIELD.fieldApiName] = String(this.newCustomerId);

        updateRecord({ fields })
        .then(() => {
            refreshApex(this.account);
            this.newCustomerId = undefined;
            this.dispatchToast('success', 'Saved!');
            this.isWorking = false;
        })
        .catch((error) => {
            this.dispatchToast('error', 'Error!', error.body.message);
            this.isWorking = false;
        })
    }

    dispatchToast(type, title, message) {
        let toast = new ShowToastEvent({
            title : title,
            message : message,
            variant : type
        });
        this.dispatchEvent(toast);
    }
}