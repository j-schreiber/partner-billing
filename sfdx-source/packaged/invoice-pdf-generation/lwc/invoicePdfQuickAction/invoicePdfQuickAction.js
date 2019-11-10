import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

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

    @track organizationProfiles;
    @track invoice;

    @wire(getRecord, { recordId: '$invoiceId', fields: [LANGUAGE_FIELD, RENDER_TIMESHEET_FIELD] })
    setDataFromInvoice ({data}) {
        if (data) {
            this.invoice = {
                Id : data.id,
                PdfLanguage__c : data.fields.PdfLanguage__c.value,
                PdfRenderTimesheet__c : data.fields.PdfRenderTimesheet__c.value
            }
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

    connectedCallback() {
        this.isWorking = true;
        this.getOrgProfiles();
        this.isWorking = false;
    }

    get invoicePdfUrl() {
        return '/apex/InvoicePdf?Id='+ this.invoiceId +
            '&orgProfileId=' + this.selectedProfile +
            '&lang=' + this.selectedLanguage +
            '&displayTimesheet=' + this.displayTimesheet;
    }

    get loadingCompleted() {
        return this.organizationProfiles && this.invoice;
    }

    handleOptionsChange(event) {
        this.selectedProfile = event.detail.profile;
        this.selectedLanguage = event.detail.language;
        this.displayTimesheet = event.detail.timesheet;
    }

    getOrgProfiles() {

        getOrganizationProfiles({})
        .then( (data) => {
            let profiles = [];
            data.forEach( (entry) => {
                profiles.push({
                    label : entry.Name,
                    value : entry.Id
                })
            });
            this.organizationProfiles = profiles;            
        })
        .catch( () => {
            this.organizationProfiles = [];
        });
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
            let successToast = new ShowToastEvent({
                title : this.LABELS.TOAST_TITLE_SUCCESS,
                variant : 'success'
            });
            this.dispatchEvent(successToast);
            this.dispatchEvent(new CustomEvent('savesuccess'));
            this.isWorking = false;
        })
        .catch( (error) => {
            let errorToast = new ShowToastEvent({
                title : this.LABELS.TOAST_TITLE_ERROR,
                variant : 'error',
                message : error.body.message
            });
            this.dispatchEvent(errorToast);
            this.isWorking = false;
        })
    }
}