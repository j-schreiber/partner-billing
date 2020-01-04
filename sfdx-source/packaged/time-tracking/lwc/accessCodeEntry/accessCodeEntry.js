import { LightningElement, track } from 'lwc';
import validateAccessCode from '@salesforce/apex/TimeEntryApprovalController.validateAccessCode';

const inputSuccessors = {
    inputCode1 : 'codeComponent2',
    inputCode2 : 'codeComponent3',
    inputCode3 : 'codeComponent3'
}

import TOKEN_STATUS_FIELD from '@salesforce/schema/AccessToken__c.Status__c';

export default class AccessCodeEntry extends LightningElement {
    @track userInput;
    @track isValid;
    @track hasLoaded;

    /**                         EVENT HANDLERS                       */

    handleCodeInput(event) {
        if (event.target.value.length === 4) {
            this.getSuccessor(event.target).focus();
        }
        this.userInput = this.getConsolidatedUserInput().toUpperCase();
        if (this.userInput.length === 12) {
            this.validateUserInput(this.userInput);
        }
    }

    /**                       GETTERS / SETTERS                    */


    /**                        PRIVATE HELPERS                      */

    getSuccessor(inputElement) {
        return this.template.querySelector('[data-id="' + inputSuccessors[String(inputElement.name)] + '"]');
    }

    getConsolidatedUserInput() {
        let inputFields = this.template.querySelectorAll('input');
        let fullCode = '';
        inputFields.forEach((field) =>{ fullCode += field.value; } )
        return fullCode;
    }

    validateUserInput(accessCode) {
        validateAccessCode({ accessCode : accessCode })
        .then((result) => {
            console.log('Is Valid: ' + result);
        })
        .catch((error) => {

        });
    }
}