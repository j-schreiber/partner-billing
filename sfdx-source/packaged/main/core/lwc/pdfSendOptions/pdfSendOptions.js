import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getMailTemplates from '@salesforce/apex/LWCUtilityController.getMailTemplates'

import PLACEHOLDER_BILLING_CONTACT from '@salesforce/label/c.UI_Placeholder_SelectBillingContact';
import PLACEHOLDER_MAIL_TEMPLATE from '@salesforce/label/c.UI_Placeholder_SelectMailTemplate';
import BUTTON_TEXT_RESET from '@salesforce/label/c.UI_Button_Label_ResetAll';

export default class pdfSendOptions extends NavigationMixin(LightningElement) {
    @api invoice;
    @api pdfId;

    LABELS = {
        PLACEHOLDER_BILLING_CONTACT,
        PLACEHOLDER_MAIL_TEMPLATE,
        BUTTON_TEXT_RESET
    }

    @wire(getMailTemplates, {})
    extractMailTemplates (value) {
        if (value.data) {
            let arr = [];
            value.data.forEach( (item) => { arr.push( { label : item.Name, value : item.Id })});
            this.mailTemplateOptions = arr;
        }
    }
    @track mailTemplateOptions;

    selectedTemplate;
    selectedContact;

    /**                                     PUBLIC COMPONENT API                                     */
    
    @api
    getOptions() {
        let contId = this.selectedContact ? this.selectedContact.id : undefined;
        return {
            templateId : this.selectedTemplate,
            contactId : contId
        }
    }

    @api
    reset() {
        this.template.querySelector('c-billing-contact-lookup').reset();
        this.template.querySelector('lightning-combobox').value = '';
        this.selectedTemplate = undefined;
        this.selectedContact = undefined;
        this.dispatchChangeEvent();
    }

    /**                                     EVENT HANDLERS                                            */

    viewPdf() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: this.pdfId
            }
        });
    }

    handleTemplateSelection(event) {
        this.selectedTemplate = event.detail.value;
        this.dispatchChangeEvent();
    }

    handleSelectionChange(event) {
        event.stopPropagation();
        this.selectedContact = event.detail;
        this.dispatchChangeEvent();
    }

    /**                                     HELPERS                                      */
    
    dispatchChangeEvent() {
        this.dispatchEvent(new CustomEvent('optionschange', { detail : this.getOptions() }));
    }
}