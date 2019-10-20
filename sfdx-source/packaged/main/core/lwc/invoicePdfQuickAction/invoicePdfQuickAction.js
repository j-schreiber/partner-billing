import { LightningElement, api, track } from 'lwc';
import savePdfToInvoice from '@salesforce/apex/InvoicePdfController.savePdfToInvoice';

import BUTTON_LABEL_SAVE from '@salesforce/label/c.Button_Label_SaveToAttachments';

export default class InvoicePdfQuickAction extends LightningElement {
    @api invoiceId;
    @track isWorking = false;

    LABELS = {
        BUTTON_LABEL_SAVE
    }

    get invoicePdfUrl() {
        return '/apex/InvoicePdf?Id=' + this.invoiceId;
    }

    savePdf() {
        this.isWorking = true;

        //console.log('Saving ...');
        
        savePdfToInvoice({
            invoiceId : this.invoiceId
        })
        .then( () => {
            // function body to handle SUCCESS
            //console.log('Success ...');
            this.dispatchEvent(new CustomEvent('savesuccess'));
            this.isWorking = false;
        })
        .catch( () => {
            // function body to handle ERRORS
            this.isWorking = false;
        })
    }
}