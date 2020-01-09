import { LightningElement, track } from 'lwc';
import validateAccessCode from '@salesforce/apex/TimeEntryApprovalController.validateAccessCode';
import getCustomerAccountData from '@salesforce/apex/TimeEntryApprovalController.getCustomerAccountData';

import TEXT_WELCOME from '@salesforce/label/c.UI_Label_Welcome';
import TEXT_INTRO from '@salesforce/label/c.TimeSheetApproval_Label_Intro';
import PLACEHOLDER_CUSTOMER_NUMBER from '@salesforce/label/c.Generic_Prompt_EnterCustomerId';
import ERROR_INVALID_CUSTOMER_ID from '@salesforce/label/c.TimeSheetApproval_Error_CustomerIdInvalid';
import ERROR_ACCOUNT_NOT_ENABLED from '@salesforce/label/c.TimeSheetApproval_Error_AccountNotEnabled';
export default class AccessCodeLogin extends LightningElement {

    @track isVerified = false;
    @track isAuthorized = false;
    @track isCompleted = false;

    @track isValidCustomerId = false;
    @track isTimesheetEnabled = false;

    @track errorMessage;

    LABELS = {
        TEXT_INTRO,
        TEXT_WELCOME,
        PLACEHOLDER_CUSTOMER_NUMBER,
        ERROR_INVALID_CUSTOMER_ID,
        ERROR_ACCOUNT_NOT_ENABLED
    }

    /**                         EVENT HANDLERS                       */

    handleUserInput(event) {
        this.isCompleted = event.detail.value.length === 12;
        this.isAuthorized = false;
        this.isVerified = false;
    }

    handleCustomerIdInput() {
        let customerId = this.template.querySelector('input[data-id="customerNumberInput"]').value;
        getCustomerAccountData({ customerId : customerId})
        .then((account) => {
            this.isValidCustomerId = true;
            this.isTimesheetEnabled = account.IsTimeSheetApprovalEnabled__c;
            this.errorMessage = this.isTimesheetEnabled ? undefined : this.LABELS.ERROR_ACCOUNT_NOT_ENABLED
        })
        .catch((error) => {
            this.isValidCustomerId = false;
            this.isTimesheetEnabled = false;
            this.errorMessage = error.body.message;
        });
    }

    login() {
        let codeInput = this.template.querySelector('c-access-code-input');
        validateAccessCode({ accessCode : codeInput.getAccessCode() })
        .then((result) => {
            this.isVerified = true;
            if (result === true) {
                this.isAuthorized = true;
                this.dispatchEvent(new CustomEvent('success', { detail : { accessCode : codeInput.getAccessCode() }}));
            } else {
                this.isAuthorized = false;
            }
        })
        .catch((error) => {
            this.isVerified = true;
            this.isAuthorized = false;
            this.errorMessage = error.body.message;
        });
    }

    /**                         GETTERS / SETTERS                       */

    get disableLogin() {
        return !this.isCompleted;
    }

    get disableAccessCodeInput() {
        return !this.isTimesheetEnabled;
    }

}