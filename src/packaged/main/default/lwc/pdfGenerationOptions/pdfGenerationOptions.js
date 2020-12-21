import { LightningElement, api, track } from 'lwc';

import OPTION_LABEL_ORGPROFILE from '@salesforce/label/c.UI_Label_SelectOrgProfile';
import OPTION_LABEL_LANGUAGE from '@salesforce/label/c.UI_Label_SelectRenderLanguage';
import OPTION_LABEL_TIMESHEET from '@salesforce/label/c.UI_Label_ActivateTimesheet';

export default class pdfGenerationOptions extends LightningElement {

    @api languageOptions = [];

    @api
    get orgProfileOptions() {
        return this.internalProfiles;
    }
    set orgProfileOptions(input) {
        if (input && input.length > 0) this.internalProfiles = input;
        if (input && input.length > 0 && !this.selectedProfileOption) this.selectedProfileOption = input[0].value;
    }
    @track internalProfiles = [];

    @api
    get invoice() {
        return this.originalInvoice;
    }
    set invoice(input) {
        this.originalInvoice = input;
        this.selectedLanguageOption = input.Record.PdfLanguage__c;
        this.renderTimesheetOption = input.Record.PdfRenderTimesheet__c;
        if (input.Record.OrganizationProfile__c) this.selectedProfileOption = input.Record.OrganizationProfile__c;
    }
    originalInvoice;

    @api disabled = false;

    selectedProfileOption;
    selectedLanguageOption;
    renderTimesheetOption;

    LABELS = {
        OPTION_LABEL_ORGPROFILE,
        OPTION_LABEL_LANGUAGE,
        OPTION_LABEL_TIMESHEET
    }

    /**                           PUBLIC COMPONENT API                           */  

    /** 
     * @description
     * Returns all selected options as a single object. The return includes manually set options and the initial defaults.
     *  
     * @returns
     * The currently selected options of the component, including the record id.
     * */
    @api
    getSelectedOptions() {
        return {
            recordId : (this.invoice) ? this.invoice.Record.Id : undefined,
            profile : this.selectedProfileOption,
            language : this.selectedLanguageOption,
            timesheet : (typeof this.renderTimesheetOption !== 'undefined') ? this.renderTimesheetOption : this.invoice.Record.PdfRenderTimesheet__c
        };
    }

    /** 
     * @description
     * Resets the component to default (both selections that are received from `getSelectedOptions()`
     * and input fields.)
     * */
    @api
    reset() {
        this.selectedLanguageOption = this.originalInvoice.Record.PdfLanguage__c;
        this.template.querySelector('lightning-combobox[data-id="languageInput"]').value = this.originalInvoice.Record.PdfLanguage__c;

        this.renderTimesheetOption = this.originalInvoice.Record.PdfRenderTimesheet__c;
        this.template.querySelector('lightning-input').checked = this.originalInvoice.Record.PdfRenderTimesheet__c;

        if (this.originalInvoice.Record.OrganizationProfile__c) {
            this.selectedProfileOption = this.originalInvoice.Record.OrganizationProfile__c;
            this.template.querySelector('lightning-combobox[data-id="orgProfileInput"]').value = this.originalInvoice.Record.OrganizationProfile__c;
        }
    }
    

    /**                             LIFE CYCLE HOOKS                           */


    /**                             EVENT HANDLERS                            */

    handleProfileSelection(event) {
        event.stopPropagation();
        this.selectedProfileOption = event.detail.value;
        this.sendSelectedOptions();
    }

    handleLanguageSelection(event) {
        event.stopPropagation();
        this.selectedLanguageOption = event.detail.value;
        this.sendSelectedOptions();
    }

    handleTimesheetToggle(event) {
        event.stopPropagation();
        this.renderTimesheetOption = Boolean(event.detail.checked);
        this.sendSelectedOptions();
    }


    /**                             HELPERS                                */

    sendSelectedOptions() {
        this.dispatchEvent(
            new CustomEvent(
                'optionchange', 
                { detail: {
                    recordId : this.invoice.Record.Id,
                    profile : this.selectedProfileOption,
                    language : this.selectedLanguageOption,
                    timesheet : this.renderTimesheetOption
                }}
            )
        );
    }

    get initialTimesheetOption() {
        return (this.invoice) ? this.invoice.Record.PdfRenderTimesheet__c : false;
    }
}