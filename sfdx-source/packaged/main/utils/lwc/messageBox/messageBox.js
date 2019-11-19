import { LightningElement, api } from 'lwc';

export default class messageBox extends LightningElement {
    @api variant;
    @api message;

    /**                 GETTERS AND FORMATTERS                       */

    get iconName() {
        if (this.variant === 'error') {
            return 'utility:error';
        } else if (this.variant === 'success') {
            return 'utility:success';
        }
        return 'utility:info_alt';
    }

    get boxTheme() {
        let cssClasses = 'slds-p-around_medium message-box';
        if (this.variant === 'error') {
            cssClasses += ' box-theme_error';
        } else if (this.variant === 'success') {
            cssClasses += ' box-theme_success';
        } else if (this.variant === 'warning') {
            cssClasses += ' box-theme_warning';
        } else {
            cssClasses += ' box-theme_default';
        }
        return cssClasses;
    }
}