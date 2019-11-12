import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import OPTION_LABEL_ORGPROFILE from '@salesforce/label/c.UI_Label_SelectOrgProfile';
import OPTION_LABEL_LANGUAGE from '@salesforce/label/c.UI_Label_SelectRenderLanguage';
import OPTION_LABEL_TIMESHEET from '@salesforce/label/c.UI_Label_ActivateTimesheet';

import LANGUAGE_FIELD from '@salesforce/schema/Invoice__c.PdfLanguage__c';

export default class pdfGenerationOptions extends LightningElement {

    // public properties
    @api
    get invoice() {
        return this.invoiceRecord;
    }
    set invoice(value) {
        this.invoiceRecord = value;
        this.selectedLanguageOption = value.PdfLanguage__c;
        this.renderTimesheetOption = value.PdfRenderTimesheet__c;
    }

    @api
    get orgProfiles() {
        return this.orgProfileOptions;
    }
    set orgProfiles(value) {
        this.orgProfileOptions = value;
        if (value && value.length >= 1) {
            this.selectedProfileOption = value[0].value;
        }
    }

    @api disabled = false;

    // private properties
    invoiceRecord;
    @track orgProfileOptions;
    @track languageOptions;
    selectedProfileOption = '';
    selectedLanguageOption = '';
    renderTimesheetOption = true;

    LABELS = {
        OPTION_LABEL_ORGPROFILE,
        OPTION_LABEL_LANGUAGE,
        OPTION_LABEL_TIMESHEET
    }

    @wire( getPicklistValues, { recordTypeId : '012000000000000AAA', fieldApiName : LANGUAGE_FIELD})
    getLanguagePicklistValues ({data}) {
        if (data) {
            this.languageOptions = Array.from(data.values);
        }
    }

    /**                             LIFE CYCLE HOOKS                           */

    connectedCallback() {
        this.sendSelectedOptions();
    }


    /**                             EVENT HANDLERS                            */

    handleProfileSelection(event) {
        this.selectedProfileOption = event.detail.value;
        this.sendSelectedOptions();
    }

    handleLanguageSelection(event) {
        this.selectedLanguageOption = event.detail.value;
        this.sendSelectedOptions();
    }

    handleTimesheetToggle(event) {
        this.renderTimesheetOption = Boolean(event.detail.checked);
        this.sendSelectedOptions();
    }


    /**                             HELPERS                                */

    sendSelectedOptions() {
        this.dispatchEvent(
            new CustomEvent(
                'optionchange', 
                { detail: {
                    recordId : this.invoiceRecord.Id,
                    profile : this.selectedProfileOption,
                    language : this.selectedLanguageOption,
                    timesheet : this.renderTimesheetOption
                }}
            )
        );
    }
}