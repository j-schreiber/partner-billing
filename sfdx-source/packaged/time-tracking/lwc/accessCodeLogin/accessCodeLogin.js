import { LightningElement, track } from 'lwc';
import validateAccessCode from '@salesforce/apex/TimeEntryApprovalController.validateAccessCode';

export default class AccessCodeLogin extends LightningElement {

    @track isVerified = false;
    @track isAuthorized = false;
    @track isCompleted = false;

    /**                         EVENT HANDLERS                       */

    handleUserInput(event) {
        this.isCompleted = event.detail.value.length === 12;
    }

    login() {
        let codeInput = this.template.querySelector('c-access-code-input');
        validateAccessCode({ accessCode : codeInput.getAccessCode() })
        .then((result) => {
            this.isVerified = true;
            if (result === true) {
                this.isAuthorized = true;
                this.dispatchEvent(new CustomEvent('success', { detail : { accessCode : this.userInput }}));
            } else {
                this.isAuthorized = false;
            }
        })
        .catch(() => {
            this.isVerified = true;
            this.isAuthorized = false;
        });
    }

    /**                         GETTERS / SETTERS                       */

    get disableLogin() {
        return !this.isCompleted;
    }

}