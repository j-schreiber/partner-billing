import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import { getOrgProfiles } from 'c/utilities';

import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';
import savePdfToInvoice from '@salesforce/apex/InvoicePdfController.savePdfToInvoice';
import apexDeletePdf from '@salesforce/apex/InvoicePdfController.deletePdf';

import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';

export default class InvoicePdfGenTableRow extends NavigationMixin(LightningElement) {
    @api invoice;

    @track pdfContentVersionRecord;
    @track isWorking = false;
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

    handleOptionsChange(event) {
        this.invoicePdfOptions = event.detail;
    }

    viewPdf() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.pdfContentVersionRecord.Id,
                objectApiName: 'ContentVersion',
                actionName: 'view'
            }
        });
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
            this.pdfContentVersionRecord = data;
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

    @api
    deletePdf() {

        this.isWorking = true;

        apexDeletePdf({
            pdfId : this.pdfContentVersionRecord.ContentDocumentId
        })
        .then(() => {
            this.pdfContentVersionRecord = null;
            this.isWorking = false;
        })
        .catch(() => {
            this.isWorking = false;
        })
    }

}