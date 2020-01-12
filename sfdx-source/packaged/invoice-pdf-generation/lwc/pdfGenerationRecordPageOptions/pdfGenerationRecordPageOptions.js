import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { reduceDMLErrors } from 'c/utilities';
import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';

import PDF_SETTINGS_FIELD from '@salesforce/schema/Invoice__c.PDFSyncSetting__c';
import PDF_LANGUAGE_FIELD from '@salesforce/schema/Invoice__c.PdfLanguage__c';
import PDF_TIMESHEET_FIELD from '@salesforce/schema/Invoice__c.PdfRenderTimesheet__c';
import PDF_ORG_PROFILE_FIELD from '@salesforce/schema/Invoice__c.OrganizationProfile__c';

import EXPLANATION_MSG_DELETE from '@salesforce/label/c.Message_PdfSyncSelection_Delete';
import EXPLANATION_MSG_SYNC from '@salesforce/label/c.Message_PdfSyncSelection_Sync';
import CARD_TITLE from '@salesforce/label/c.UI_Title_SelectPdfSettings';
import TOAST_ERROR from '@salesforce/label/c.Toast_Title_GenericError';

export default class PdfGenerationRecordPageOptions extends LightningElement {
    @api recordId;

    LABELS = {
        EXPLANATION_MSG_DELETE,
        EXPLANATION_MSG_SYNC,
        CARD_TITLE,
        TOAST_ERROR
    }

    @track invoice;
    @wire(getRecord, { recordId: '$recordId', fields: [PDF_LANGUAGE_FIELD, PDF_TIMESHEET_FIELD, PDF_ORG_PROFILE_FIELD, PDF_SETTINGS_FIELD] })
    setDataFromInvoice ({data}) {
        if (data) {
            this.invoice = {};
            this.invoice.Record = {
                Id : data.id,
                PdfLanguage__c : data.fields.PdfLanguage__c.value,
                PdfRenderTimesheet__c : data.fields.PdfRenderTimesheet__c.value,
                OrganizationProfile__c : data.fields.OrganizationProfile__c.value
            }
            this.selectedSetting = data.fields.PDFSyncSetting__c.value;
        }
    }

    @track languageOptions;
    @wire( getPicklistValues, { recordTypeId : '012000000000000AAA', fieldApiName : PDF_LANGUAGE_FIELD})
    getLanguagePicklistValues (fieldOptions) {
        if (fieldOptions.data && fieldOptions.data.values) {
            this.languageOptions = Array.from(fieldOptions.data.values);
        } else {
            this.languageOptions = [];
        }
    }

    @track pdfSettingsOptions;
    @wire( getPicklistValues, { recordTypeId : '012000000000000AAA', fieldApiName : PDF_SETTINGS_FIELD})
    getPdfSettingPicklistValues (fieldOptions) {
        if (fieldOptions.data && fieldOptions.data.values) {
            this.pdfSettingsOptions = Array.from(fieldOptions.data.values);
        } else {
            this.pdfSettingsOptions = [];
        }
    }

    @track profileOptions;
    @wire (getOrganizationProfiles)
    wiredOrgProfiles({data}) {
        if (data) { 
            let arr = [];
            data.forEach( (entry) => { arr.push({ label : entry.Name, value : entry.Id }) });
            this.profileOptions = arr;
            if (this.profileOptions.length > 0) this.selectedProfile = this.profileOptions[0].value;
        } else {
            this.profileOptions = [];
        }
    }

    @track selectedSetting;

    /**                            GETTERS AND SETTERS                        */

    @api 
    get isLoaded() {
        return (this.invoice !== undefined && this.profileOptions !== undefined && this.languageOptions !== undefined);
    }

    /** @description
     *  Resets the component to default values
     * */
    @api
    reset() {
        this.template.querySelector('c-pdf-generation-options').reset();
    }

    get showSyncOptions() {
        return this.selectedSetting === 'Sync';
    }

    get showDeleteOptions() {
        return this.selectedSetting === 'Delete';
    }

    /**                              EVENT HANDLERS                             */

    handleOptionsChange(event) {
        let fields = {};
        fields.Id = this.recordId;
        fields[PDF_LANGUAGE_FIELD.fieldApiName] = String(event.detail.language);
        fields[PDF_TIMESHEET_FIELD.fieldApiName] = Boolean(event.detail.timesheet);
        fields[PDF_ORG_PROFILE_FIELD.fieldApiName] = String(event.detail.profile);
        updateRecord({ fields })
        .catch((error) => {
            this.reset();
            this.dispatchToast('error', this.LABELS.TOAST_ERROR, reduceDMLErrors(error));
        });
    }

    handleSettingsSelection(event) {
        this.selectedSetting = event.detail.value;
        let fields = {};
        fields.Id = this.recordId;
        fields[PDF_SETTINGS_FIELD.fieldApiName] = String(this.selectedSetting);
        updateRecord({ fields })
        .catch((error) => {
            this.dispatchToast('error', this.LABELS.TOAST_ERROR, error.body.message);
        });
    }

    dispatchToast(type, title, message) {
        let toast = new ShowToastEvent({
            title : title,
            message : message,
            variant : type
        });
        this.dispatchEvent(toast);
    }
}