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
        return this.internalInvoice;
    }
    set invoice(input) {
        this.internalInvoice = input;
        this.selectedLanguageOption = input.Record.PdfLanguage__c;
        this.renderTimesheetOption = input.Record.PdfRenderTimesheet__c;
        if (input.Record.OrganizationProfile__c) this.selectedProfileOption = input.Record.OrganizationProfile__c;
    }

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

    @api
    getSelectedOptions() {
        return {
            recordId : (this.invoice) ? this.invoice.Record.Id : undefined,
            profile : this.selectedProfileOption,
            language : this.selectedLanguageOption,
            timesheet : (typeof this.renderTimesheetOption !== 'undefined') ? this.renderTimesheetOption : this.invoice.Record.PdfRenderTimesheet__c
        };
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