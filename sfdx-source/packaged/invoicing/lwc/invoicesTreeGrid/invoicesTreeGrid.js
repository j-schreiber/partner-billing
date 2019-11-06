import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import updateInvoices from '@salesforce/apex/BillingController.updateInvoices';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_InvoicesUpdated';

export default class InvoicesTreeGrid extends LightningElement {

    @track invoiceData = [];
    @track dirtyInvoices = {};
    @track isWorking = false;

    lineItemColumns = [
        {
            type: 'text',
            fieldName: 'Id',
            label: 'Name'
        },
        {
            type: 'text',
            fieldName: 'Productname__c',
            label: 'Product'
        },
        {
            type: 'date',
            fieldName: 'ServiceDate__c',
            label: 'Service Date'
        },
        {
            type: 'number',
            fieldName: 'Quantity__c',
            label: 'Quantity'
        },
        {
            type: 'currency',
            fieldName: 'Price__c',
            label: 'Price per Unit'
        },
        {
            type: 'currency',
            fieldName: 'Amount__c',
            label: 'Amount (Net)'
        },
        {
            type: 'currency',
            fieldName: 'GrossAmount__c',
            label: 'Amount (Gross)'
        }
    ]

    LABELS = {
        TOAST_TITLE_SUCCESS
    }
    
    connectedCallback() {

        this.isWorking = true;

        getInvoices({
            status: 'Draft'
        })
        .then((result) => {
            this.invoiceData = result;
            this.isWorking = false;
        })
        .catch(() => {
            this.isWorking = false;
        })
    }

    cacheUpdatedRecord(event) {
        let changedRecord = event.detail;
        this.dirtyInvoices[changedRecord.Id] = changedRecord;
    }

    updateDirtyInvoices() {

        this.isWorking = true;

        updateInvoices({
            invoices: Object.values(this.dirtyInvoices)
        })
        .then(() => {
            let successToast = new ShowToastEvent({
                title : this.LABELS.TOAST_TITLE_SUCCESS,
                variant : 'success'
            });
            this.dispatchEvent(successToast);
            this.isWorking = false;
            this.dispatchEvent(new CustomEvent('stepcompleted'));
        })
        .catch(() => {
            // error toast
            this.isWorking = false;
        })

    }
}