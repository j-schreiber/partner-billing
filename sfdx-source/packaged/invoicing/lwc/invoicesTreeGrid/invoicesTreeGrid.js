import { LightningElement, track } from 'lwc';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import updateInvoices from '@salesforce/apex/BillingController.updateInvoices';

export default class InvoicesTreeGrid extends LightningElement {

    @track invoiceData = [];
    @track dirtyInvoices = {};

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
    
    connectedCallback() {

        getInvoices({
            status: 'Draft'
        })
        .then((result) => {
            this.invoiceData = result;
        })
        .catch(() => {

        })
    }

    cacheUpdatedRecord(event) {
        let changedRecord = event.detail;
        console.log('Record: ' + JSON.stringify(changedRecord));
        this.dirtyInvoices[changedRecord.Id] = changedRecord;
        console.log('Dirty Invoices: ' + JSON.stringify(this.dirtyInvoices));
    }

    updateInvoices() {

        updateInvoices({
            invoices: this.dirtyInvoices
        })
        .then(() => {
            // success toast
        })
        .catch(() => {
            // error toast
        })

    }
}