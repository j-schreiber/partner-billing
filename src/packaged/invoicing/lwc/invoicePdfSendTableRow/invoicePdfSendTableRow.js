import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import sendDocumentToContact from '@salesforce/apex/BillingController.sendDocumentToContact';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_EmailSendSuccess';
import TOAST_TITLE_FAILURE from '@salesforce/label/c.Toast_Title_EmailSendFailure';

export default class InvoicePdfSendTableRow extends NavigationMixin(LightningElement) {
    
    @api
    get invoice() {
        return this.internalInvoice;
    }
    set invoice(value) {
        this.internalInvoice = value;
        this.pdfIsValid = value.Attachments.length === 1;
        this.emailMessages = value.Record.Tasks;
        if (value.Attachments.length === 1) this.pdfRecordId = value.Attachments[0].Id;
    }

    @track pdfIsValid = false;
    @track internalInvoice;
    @track selectedOptions;
    @track isWorking = false;
    @track emailMessages;

    pdfRecordId;

    LABELS = {
        TOAST_TITLE_FAILURE,
        TOAST_TITLE_SUCCESS
    }

    handleOptionsChange(event) {
        this.selectedOptions = event.detail;
    }

    get sendButtonDisabled() {
        return (!(this.selectedOptions && this.selectedOptions.contactId && this.selectedOptions.templateId && this.selectedOptions.sender)) || this.isWorking;
    }

    get hasEmailMessages() {
        return this.emailMessages && this.emailMessages.length > 0;
    }

    get numberOfEmailMessages() {
        return '( ' +this.emailMessages.length+ ' )'
    }

    openTasksRelatedList() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId : this.internalInvoice.Record.Id,
                objectApiName : 'Invoice__c',
                actionName: 'view'
            }
        })
        .then(url => window.open(url));
    }

    sendPdf() {
        this.isWorking = true;
        sendDocumentToContact({
            contactId : this.selectedOptions.contactId,
            templateId : this.selectedOptions.templateId,
            documentId : this.pdfRecordId,
            invoiceId : this.internalInvoice.Record.Id,
            sender: this.selectedOptions.sender
        })
        .then( (emails) => {
            this.emailMessages = emails;
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_SUCCESS);
            this.isWorking = false;
        })
        .catch( (error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_FAILURE, error.body.message);
            this.isWorking = false;
        })
    }

    dispatchToast(toastVariant, toastTitle, toastMessage) {
        let toast = new ShowToastEvent({
            title : toastTitle,
            message : toastMessage,
            variant : toastVariant
        });
        this.dispatchEvent(toast);
    }

}