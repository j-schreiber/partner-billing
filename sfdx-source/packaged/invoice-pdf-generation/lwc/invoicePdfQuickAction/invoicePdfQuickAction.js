import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import savePdfToInvoice from '@salesforce/apex/InvoicePdfController.savePdfToInvoice';
import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';

import LANGUAGE_FIELD from '@salesforce/schema/Invoice__c.PdfLanguage__c';
import RENDER_TIMESHEET_FIELD from '@salesforce/schema/Invoice__c.PdfRenderTimesheet__c';

import BUTTON_LABEL_SAVE from '@salesforce/label/c.Button_Label_SaveToAttachments';
import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_PdfSaveSuccess';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';

export default class InvoicePdfQuickAction extends LightningElement {
    @api invoiceId;
    @track isWorking = false;

    @track invoice;
    @wire(getRecord, { recordId: '$invoiceId', fields: [LANGUAGE_FIELD, RENDER_TIMESHEET_FIELD] })
    setDataFromInvoice ({data}) {
        if (data) {
            this.invoice = {};
            this.invoice.Record = {
                Id : data.id,
                PdfLanguage__c : data.fields.PdfLanguage__c.value,
                PdfRenderTimesheet__c : data.fields.PdfRenderTimesheet__c.value
            }
            this.selectedLanguage = data.fields.PdfLanguage__c.value;
            this.displayTimesheet = data.fields.PdfRenderTimesheet__c.value;
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

    @track languageOptions;
    @wire( getPicklistValues, { recordTypeId : '012000000000000AAA', fieldApiName : LANGUAGE_FIELD})
    getLanguagePicklistValues (fieldOptions) {
        if (fieldOptions.data && fieldOptions.data.values) {
            this.languageOptions = Array.from(fieldOptions.data.values);
        } else {
            this.languageOptions = [];
        }
    }

    @track selectedProfile;
    @track selectedLanguage;
    @track displayTimesheet;

    LABELS = {
        BUTTON_LABEL_SAVE,
        TOAST_TITLE_SUCCESS,
        TOAST_TITLE_ERROR
    }

    /**                            GETTERS AND SETTERS                        */

    get invoicePdfUrl() {
        return '/apex/InvoicePdf?Id='+ this.invoiceId +
            '&orgProfileId=' + this.selectedProfile +
            '&lang=' + this.selectedLanguage +
            '&displayTimesheet=' + this.displayTimesheet;
    }

    get loadingCompleted() {
        return this.profileOptions && this.invoice && this.languageOptions;
    }

    handleOptionsChange(event) {
        this.selectedProfile = event.detail.profile;
        this.selectedLanguage = event.detail.language;
        this.displayTimesheet = event.detail.timesheet;
    }

    savePdf() {
        this.isWorking = true;
        
        savePdfToInvoice({
            invoiceId : this.invoiceId,
            orgProfileId : this.selectedProfile,
            renderLanguage : this.selectedLanguage,
            displayTimesheet: this.displayTimesheet
        })
        .then( () => {
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_SUCCESS);
            this.dispatchEvent(new CustomEvent('savesuccess'));
            this.isWorking = false;
        })
        .catch( (error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_ERROR, error.body.message);
            this.isWorking = false;
        })
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