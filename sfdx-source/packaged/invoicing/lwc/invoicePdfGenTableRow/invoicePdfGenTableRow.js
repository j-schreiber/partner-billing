import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import { getOrgProfiles } from 'c/utilities';

import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';
import savePdfToInvoice from '@salesforce/apex/InvoicePdfController.savePdfToInvoice';
import apexDeletePdf from '@salesforce/apex/InvoicePdfController.deletePdf';

import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';

import LANGUAGE_FIELD from '@salesforce/schema/Invoice__c.PdfLanguage__c';

export default class InvoicePdfGenTableRow extends NavigationMixin(LightningElement) {

    @api
    get invoice() {
        return this.internalInvoice;
    }
    set invoice(value) {
        this.internalInvoice = value;
        if (value.Attachments.length > 0) this.pdfRecordId = value.Attachments[0].Id;
    }

    @track internalInvoice;
    @track isWorking = false;
    @track pdfRecordId;
    invoicePdfOptions = {};

    LABELS = {
        TOAST_TITLE_ERROR
    }

    @track orgProfiles;
    @wire (getOrganizationProfiles, {})
    wiredOrgProfiles(value) {
        if (value.data) { 
            this.orgProfiles = getOrgProfiles(value.data);
        } else {
            this.orgProfiles = [];
        }
    }

    @wire( getPicklistValues, { recordTypeId : '012000000000000AAA', fieldApiName : LANGUAGE_FIELD})
    getLanguagePicklistValues ({data}) {
        if (data) {
            this.languageOptions = Array.from(data.values);
        }
    }

    /**                             PUBLIC COMPONENT API                             */

    @api
    getSelectedOptions() {
        return this.invoicePdfOptions;
    }

    @api
    createPdf() {
        this.isWorking = true;
        savePdfToInvoice({
            invoiceId : this.invoicePdfOptions.recordId,
            orgProfileId : this.invoicePdfOptions.profile,
            renderLanguage : this.invoicePdfOptions.language,
            displayTimesheet: this.invoicePdfOptions.timesheet
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
        apexDeletePdf({
            pdfId : this.pdfRecordId
        })
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

    handleOptionsChange(event) {
        this.invoicePdfOptions = event.detail;
    }

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