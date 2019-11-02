import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTimeEntries from '@salesforce/apex/BillingController.getNonInvoicedTimeEntries';
import createInvoices from '@salesforce/apex/BillingController.createInvoicesFromTimeEntries';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_InvoicingRunSuccess';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';

const COLUMN_DEFINITION = [
    {
        type: 'text',
        fieldName: 'AccountName',
        label: 'Accountname'
    },
    {
        type: 'text',
        fieldName: 'ProductName',
        label: 'Product'
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

    @api
    get filters() {
        return this.activeFilters;
    }
    set filters(value) {
        this.activeFilters = value;
        this.refreshData(this.activeFilters);
    }

    @track activeFilters;
    @track gridData;
    @track columns = COLUMN_DEFINITION;
    @track isWorking = false;

    @track selectedOptions = {
        collapseTimeEntries : true,
        overrideServicePeriod : true
    };

    LABELS = {
        TOAST_TITLE_SUCCESS,
        TOAST_TITLE_ERROR
    }

    refreshData(filters) {

        getTimeEntries({
            startDate : filters.startDate,
            endDate : filters.endDate
        })
        .then( (result) => {
            this.gridData = result;
        })
        .catch( () => {
            this.gridDate = [];
        });
    }

    handleCollapseToggle(event) {
        this.selectedOptions.collapseTimeEntries = event.detail.checked
    }

    handleServicePeriodToggle(event) {
        this.selectedOptions.overrideServicePeriod = event.detail.checked
    }

    startBillingCycle() {

        this.isWorking = true;

        createInvoices({
            timeEntryIds: this.getSelectedIds(),
            options: this.selectedOptions,
            filters: this.activeFilters,
        })
        .then(() => {
            let successToast = new ShowToastEvent({
                title : this.LABELS.TOAST_TITLE_SUCCESS,
                variant : 'success'
            });
            this.dispatchEvent(successToast);
            this.isWorking = false;
            this.refreshData(this.activeFilters);
            this.dispatchEvent(new CustomEvent('stepcompleted'));
        })
        .catch(() => {
            this.isWorking = false;
        });
    }

    getSelectedIds() {
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        let selectedIds = [];
        selectedRows.forEach( (entry) => {selectedIds.push(entry.Id)} );
        return selectedIds;
    }

}