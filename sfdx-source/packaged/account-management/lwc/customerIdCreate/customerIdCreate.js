import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getLatestCustomerId from '@salesforce/apex/AccountController.getLatestCustomerId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CUSTOMER_ID_FIELD from '@salesforce/schema/Account.CustomerId__c';
import CUSTOMER_ID_NUMBER_FIELD from '@salesforce/schema/Account.CustomerIdNumber__c';

export default class CustomerIdCreate extends LightningElement {
    @api accountId;
    @track isWorking = false;
    @track newCustomerId;

    @wire(getRecord, { recordId: '$accountId', fields: [CUSTOMER_ID_FIELD, CUSTOMER_ID_NUMBER_FIELD] })
    account;

    get CustomerId() {
        if (this.account.data && this.account.data.fields.CustomerId__c.value !== null) {
            return this.account.data.fields.CustomerId__c.value;
        } else if (this.newCustomerId) {
            return this.newCustomerId;
        }
        return undefined;
    }

    get hasCustomerId() {
        if (this.newCustomerId) {
            return true;
        } else if (this.account.data) {
            return this.account.data.fields.CustomerId__c.value !== null;
        }
        return false;
    }

    get disableCreateButton() {
        return this.hasCustomerId || this.isWorking;
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
        fields.Id = this.accountId;
        fields[CUSTOMER_ID_FIELD.fieldApiName] = String(this.newCustomerId);

        updateRecord({ fields })
        .then(() => {
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