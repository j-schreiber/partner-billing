import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getMailTemplates from '@salesforce/apex/LWCUtilityController.getMailTemplates';
import getSenderAddresses from '@salesforce/apex/LWCUtilityController.getSenderAddresses';

import LABEL_BILLING_CONTACT from '@salesforce/label/c.UI_Label_SelectBillingContact';
import LABEL_MAIL_TEMPLATE from '@salesforce/label/c.UI_Label_SelectMailTemplate';
import LABEL_SENDER_ADDRESS from '@salesforce/label/c.UI_Label_SelectSenderAddress';
import BUTTON_TEXT_RESET from '@salesforce/label/c.UI_Button_Label_ResetAll';

export default class pdfSendOptions extends NavigationMixin(LightningElement) {
    @api invoice;
    @api pdfId;

    LABELS = {
        LABEL_BILLING_CONTACT,
        LABEL_MAIL_TEMPLATE,
        LABEL_SENDER_ADDRESS,
        BUTTON_TEXT_RESET,
        PLACEHOLDER_MAIL_TEMPLATE : '- ' + LABEL_MAIL_TEMPLATE + ' -',
        PLACEHOLDER_SENDER_ADDRESS : '- ' + LABEL_SENDER_ADDRESS + ' -',
    }

    @wire(getMailTemplates, {})
    extractMailTemplates (value) {
        if (value.data) {

            let arr = [];
            value.data.forEach( (item) => { arr.push( { label : item.Name, value : item.Id })});
            this.mailTemplateOptions = arr;

            if (this.mailTemplateOptions.length > 0) {
                this.selectedTemplate = this.mailTemplateOptions[0].value;
                this.dispatchChangeEvent();
            }

        } else {
            this.mailTemplateOptions = [];
        }
    }
    @track mailTemplateOptions;

    @wire(getSenderAddresses, {})
    extractSenderAddresses (value) {
        if (value.data) {

            let arr = [];
            value.data.forEach( (item) => { 
                arr.push( { label : (item.Name+': '+item.Email), value : item.SenderId });
                this.senderAddressMap.set(item.SenderId, item);
            });
            this.senderAddressOptions = arr;

            if (this.senderAddressOptions.length > 0) {
                this.selectedSenderAddress = this.senderAddressOptions[0].value;
                this.dispatchChangeEvent();
            }

        } else {
            this.senderAddressOptions = [];
        }

    }
    @track senderAddressOptions;
    senderAddressMap = new Map();

    @track selectedTemplate;
    selectedContact;
    @track selectedSenderAddress;

    /**                                     PUBLIC COMPONENT API                                     */
    
    @api
    getOptions() {
        let contId = this.selectedContact ? this.selectedContact.id : undefined;
        return {
            templateId : this.selectedTemplate,
            contactId : contId,
            sender : this.senderAddressMap.get(this.selectedSenderAddress)
        }
    }

    @api
    reset() {
        this.template.querySelector('c-billing-contact-lookup').reset();
        this.selectedTemplate = undefined;
        this.selectedContact = undefined;
        this.selectedSenderAddress = undefined;
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

    handleAddressSelection(event) {
        event.stopPropagation();
        this.selectedSenderAddress = event.detail.value;
        this.dispatchChangeEvent();
    }

    /**                                     HELPERS                                      */
    
    dispatchChangeEvent() {
        this.dispatchEvent(new CustomEvent('optionschange', { detail : this.getOptions() }));
    }
}