import { LightningElement, api, track, wire } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';
import savePdfToInvoice from '@salesforce/apex/InvoicePdfController.savePdfToInvoice';

import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';

import LANGUAGE_FIELD from '@salesforce/schema/Invoice__c.PdfLanguage__c';

export default class InvoicePdfGenTableRow extends NavigationMixin(LightningElement) {

    @api invoice;

    @track isWorking = false;
    @track pdfRecordId;

    invoicePdfOptions = {};

    LABELS = {
        TOAST_TITLE_ERROR
    }

    @track profileOptions;
    @wire (getOrganizationProfiles, {})
    wiredOrgProfiles(records) {
        if (records.data) { 
            let arr = [];
            records.data.forEach( (entry) => { arr.push({ label : entry.Name, value : entry.Id }) });
            this.profileOptions = arr;
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

    /**                             LIFE CYCLE HOOKS                           */

    connectedCallback() {
        if (this.invoice && this.invoice.Attachments && this.invoice.Attachments.length > 0) {
            this.pdfRecordId = this.invoice.Attachments[0].Id;
        }
    }

    /**                             PUBLIC COMPONENT API                             */

    @api
    getSelectedOptions() {
        return this.template.querySelector('c-pdf-generation-options').getSelectedOptions();
    }

    @api
    createPdf() {
        this.isWorking = true;
        savePdfToInvoice({
            invoiceId : this.getSelectedOptions().recordId,
            orgProfileId : this.getSelectedOptions().profile,
            renderLanguage : this.getSelectedOptions().language,
            displayTimesheet: this.getSelectedOptions().timesheet
        })
        .then( (data) => {
            this.pdfRecordId = data.ContentDocumentId;
            this.isWorking = false;
        })
        .catch( (error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_ERROR, error.body.message);
            this.isWorking = false;
        });
    }

    @api
    deletePdf() {
        this.isWorking = true;
        deleteRecord(this.pdfRecordId)
        .then( () => {
            this.pdfRecordId = null;
            this.isWorking = false;
        })
        .catch( (error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_ERROR, error.body.message);
            this.isWorking = false;
        });
    }

    /**                            PRIVATE COMPONENT FUNCTIONALITY                         */

    viewPdf() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: this.pdfRecordId
            }
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