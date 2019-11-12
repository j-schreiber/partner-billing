import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getMailTemplates from '@salesforce/apex/LWCUtilityController.getMailTemplates'

import PLACEHOLDER_BILLING_CONTACT from '@salesforce/label/c.UI_Placeholder_SelectBillingContact';
import PLACEHOLDER_MAIL_TEMPLATE from '@salesforce/label/c.UI_Placeholder_SelectMailTemplate';

export default class pdfSendOptions extends NavigationMixin(LightningElement) {
    @api invoice;
    @api pdfId;

    LABELS = {
        PLACEHOLDER_BILLING_CONTACT,
        PLACEHOLDER_MAIL_TEMPLATE
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
        return {
            templateId : this.selectedTemplate,
            contactId : this.selectedContact
        }
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
    }

    handleContactSearchInput(event) {
        this.selectedContact = event.detail.value;
    }
}