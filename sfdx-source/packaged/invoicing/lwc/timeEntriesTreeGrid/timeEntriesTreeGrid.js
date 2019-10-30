import { LightningElement, api, track } from 'lwc';
import getTimeEntries from '@salesforce/apex/BillingController.getNonInvoicedTimeEntries'

const COLUMN_DEFINITION = [
    {
        type: 'text',
        fieldName: 'Account__r.Name',
        label: 'Accountname'
    },
    {
        type: 'text',
        fieldName: 'Name',
        label: 'Number'
    },
    {
        type: 'date',
        fieldName: 'Date__c',
        label: 'Date'
    },
    {
        type: 'date',
        fieldName: 'StartTime__c',
        label: 'Start Time'
    },
    {
        type: 'date',
        fieldName: 'EndTime__c',
        label: 'End Time'
    },
    {
        type: 'number',
        fieldName: 'Duration__c',
        label: 'Duration'
    },
    {
        type: 'currency',
        fieldName: 'TotalAmount__c',
        label: 'Amount'
    }
]

export default class TimeEntriesTreeGrid extends LightningElement {

    @api filters;
    @track gridData;
    @track columns = COLUMN_DEFINITION;


    connectedCallback() {
        this.filters = {};
    }

    renderedCallback() {

        getTimeEntries({

        })
        .then( (result) => {
            this.gridData = result;
        })
        .catch( () => {
            this.gridDate = [];
        });
    }

}