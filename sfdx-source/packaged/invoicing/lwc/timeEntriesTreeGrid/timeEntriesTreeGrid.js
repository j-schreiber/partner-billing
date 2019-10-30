import { LightningElement, api, track } from 'lwc';
import getTimeEntries from '@salesforce/apex/BillingController.getNonInvoicedTimeEntries'

const COLUMN_DEFINITION = [
    {
        type: 'text',
        fieldName: 'AccountName',
        label: 'Accountname'
    },
    {
        type: 'text',
        fieldName: 'Name',
        label: 'Number'
    },
    {
        type: 'date',
        fieldName: 'ServiceDate',
        label: 'Date'
    },
    {
        type: 'date',
        fieldName: 'StartTime',
        label: 'Start Time',
        typeAttributes: {
            hour: "2-digit",
            minute: "2-digit"
        }
    },
    {
        type: 'date',
        fieldName: 'EndTime',
        label: 'End Time',
        typeAttributes: {
            hour: "2-digit",
            minute: "2-digit"
        }
    },
    {
        type: 'text',
        fieldName: 'Duration',
        label: 'Duration'
    },
    {
        type: 'currency',
        fieldName: 'DailyRate',
        label: 'Daily Rate'
    },
    {
        type: 'currency',
        fieldName: 'TotalAmount',
        label: 'Total Amount'
    }
]

export default class TimeEntriesTreeGrid extends LightningElement {

    @api filters;
    @track gridData;
    @track columns = COLUMN_DEFINITION;


    connectedCallback() {
        this.filters = {};

        getTimeEntries({
            startDate : this.filters.startDate,
            endDate : this.filters.endDate
        })
        .then( (result) => {
            this.gridData = result;
        })
        .catch( () => {
            this.gridDate = [];
        });
    }

}