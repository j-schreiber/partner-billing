import { LightningElement, track, api } from 'lwc';

const inputSuccessors = {
    inputCode1 : 'codeComponent2',
    inputCode2 : 'codeComponent3',
    inputCode3 : 'codeComponent3'
}

export default class AccessCodeInput extends LightningElement {

    @track userInput;
    @api isDisabled;

    /**                         EVENT HANDLERS                       */

    handleCodeInput(event) {
        event.stopPropagation();
        if (event.target.value.length === 4) {
            this.getSuccessor(event.target).focus();
        }
        this.userInput = this.getConsolidatedUserInput().toUpperCase();
        this.dispatchEvent(new CustomEvent('change', { detail : { value : this.userInput }}));
    }

    /**                       GETTERS / SETTERS                    */

    @api
    getAccessCode() {
        return this.userInput;
    }

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

}