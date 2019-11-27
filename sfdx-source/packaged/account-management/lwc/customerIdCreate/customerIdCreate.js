import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getLatestCustomerId from '@salesforce/apex/AccountController.getLatestCustomerId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CUSTOMER_ID_FIELD from '@salesforce/schema/Account.CustomerId__c';
import CUSTOMER_ID_NUMBER_FIELD from '@salesforce/schema/Account.CustomerIdNumber__c';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_DataSaved';
import CARD_TITLE from '@salesforce/label/c.InvoicePdf_Label_CustomerId';
import ERROR_MESSAGE_DUPLICATE from '@salesforce/label/c.Message_CustomerIdGeneration_Duplicate';
import ERROR_MESSAGE_PATTERN from '@salesforce/label/c.Message_CustomerIdGeneration_InvalidId';
import BUTTON_LABEL_SAVE from '@salesforce/label/c.UI_Button_Label_Save';
import BUTTON_LABEL_GENERATE from '@salesforce/label/c.UI_Button_Label_Generate';

export default class CustomerIdCreate extends LightningElement {
    @api recordId;
    @track isWorking = false;
    @track newCustomerId;

    @wire(getRecord, { recordId: '$recordId', fields: [CUSTOMER_ID_FIELD, CUSTOMER_ID_NUMBER_FIELD] })
    account;

    LABELS = {
        CARD_TITLE,
        TOAST_TITLE_SUCCESS,
        ERROR_MESSAGE_DUPLICATE,
        ERROR_MESSAGE_PATTERN,
        BUTTON_LABEL_SAVE,
        BUTTON_LABEL_GENERATE
    }

    existingIds = new Set();

    @api
    get CustomerId() {
        if (this.account.data && getFieldValue(this.account.data, CUSTOMER_ID_NUMBER_FIELD) !== null) {
            return getFieldValue(this.account.data, CUSTOMER_ID_NUMBER_FIELD);
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
        this.setInputValidity('');
        if (!isNaN(event.detail.value) && event.currentTarget.checkValidity()) {
            if (this.existingIds.has(Number(event.detail.value))) {
                this.setInputValidity(this.LABELS.ERROR_MESSAGE_DUPLICATE);
            } else {
                this.newCustomerId = Number(event.detail.value);
            }
        } else {
            this.newCustomerId = undefined;
        }
    }

    createNextCustomerId() {
        this.isWorking = true;
        getLatestCustomerId()
        .then((result) => {
            this.newCustomerId = result === 0 ? 1000 : result + 1;
            this.template.querySelector('lightning-input').value = this.newCustomerId;
            this.setInputValidity('');
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
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_SUCCESS);
            this.isWorking = false;
        })
        .catch((error) => {
            let errMsg;
            if (error.body.output && error.body.output.errors && error.body.output.errors.length > 0 && error.body.output.errors[0].errorCode === 'DUPLICATE_VALUE') {
                errMsg = this.LABELS.ERROR_MESSAGE_DUPLICATE;
                this.existingIds.add(this.newCustomerId);
            } else {
                errMsg = error.body.message;
            }
            this.setInputValidity(errMsg);
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

    setInputValidity(msg) {
        this.template.querySelector('lightning-input').setCustomValidity(msg);
        this.template.querySelector('lightning-input').reportValidity();
    }
}