import { LightningElement, track } from 'lwc';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';

export default class InvoicesTreeGrid extends LightningElement {

    @track invoiceData = [];

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
}