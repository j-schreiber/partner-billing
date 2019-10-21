import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import savePdfToInvoice from '@salesforce/apex/InvoicePdfController.savePdfToInvoice';

import BUTTON_LABEL_SAVE from '@salesforce/label/c.Button_Label_SaveToAttachments';
import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_PdfSaveSuccess';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';

export default class InvoicePdfQuickAction extends LightningElement {
    @api invoiceId;
    @track isWorking = false;

    LABELS = {
        BUTTON_LABEL_SAVE,
        TOAST_TITLE_SUCCESS,
        TOAST_TITLE_ERROR
    }

    get invoicePdfUrl() {
        return '/apex/InvoicePdf?Id=' + this.invoiceId;
    }

    savePdf() {
        this.isWorking = true;
        
        savePdfToInvoice({
            invoiceId : this.invoiceId
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