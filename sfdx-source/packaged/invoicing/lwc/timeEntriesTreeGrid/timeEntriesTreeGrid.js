import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTimeEntries from '@salesforce/apex/BillingController.getNonInvoicedTimeEntries';
import createInvoices from '@salesforce/apex/BillingController.createInvoicesFromTimeEntries';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_InvoicingRunSuccess';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';
import TOAST_TITLE_WARN from '@salesforce/label/c.Toast_Title_NoTimeEntriesSelected';
import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_FilterHeader';
import STARTDATE_PICKER_LABEL from '@salesforce/label/c.Invoicing_Label_ServiceDateStart';
import ENDDATE_PICKER_LABEL from '@salesforce/label/c.Invoicing_Label_ServiceDateEnd';

const COLUMN_DEFINITION = [
    { type: "text", fieldName: "AccountName", label: "Accountname" },
    { type: "text", fieldName: "ProductName", label: "Product" },
    { type: "text", fieldName: "Name", label: "Number" },
    { type: "date", fieldName: "ServiceDate", label: "Date" },
    { type: "date", fieldName: "StartTime", label: "Start Time", typeAttributes: { hour: "2-digit", minute: "2-digit" } },
    { type: "date", fieldName: "EndTime", label: "End Time", typeAttributes: { hour: "2-digit", minute: "2-digit" } },
    { type: "text", fieldName: "Duration", label: "Duration" },
    { type: "currency", fieldName: "DailyRate", label: "Daily Rate" },
    { type: "currency", fieldName: "TotalAmount", label: "Total Amount" }
];

export default class TimeEntriesTreeGrid extends LightningElement {

    @track gridData = [];
    @track isWorking = false;

    selectedOptions = {
        collapseTimeEntries : true,
        overrideServicePeriod : true
    };

    selectedFilters = {
        startDate: new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth() -1, 1)).toISOString().split("T")[0],
        endDate: new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth(), 0)).toISOString().split("T")[0],
    }

    columns = COLUMN_DEFINITION;

    LABELS = {
        CARD_TITLE,
        STARTDATE_PICKER_LABEL,
        ENDDATE_PICKER_LABEL,
        TOAST_TITLE_SUCCESS,
        TOAST_TITLE_ERROR,
        TOAST_TITLE_WARN
    }

    connectedCallback() {
        this.refreshData(this.selectedFilters);
    }

    handleStartDateChange(event) {
        this.selectedFilters.startDate = event.detail.value;
    }

    handleEndDateChange(event) {
        this.selectedFilters.endDate = event.detail.value;
    }

    handleSearchButtonClick() {
        this.refreshData(this.selectedFilters);
    }

    handleCollapseToggle(event) {
        this.selectedOptions.collapseTimeEntries = event.detail.checked
    }

    handleServicePeriodToggle(event) {
        this.selectedOptions.overrideServicePeriod = event.detail.checked
    }

    refreshData(filters) {

        this.isWorking = true;

        getTimeEntries({
            startDate : filters.startDate,
            endDate : filters.endDate
        })
        .then( (result) => {
            this.gridData = result;
            this.isWorking = false;
        })
        .catch( () => {
            this.gridDate = [];
            this.isWorking = false;
        });
    }

    startBillingCycle() {

        if (this.template.querySelector('lightning-datatable').getSelectedRows().length === 0) {
            let warnToast = new ShowToastEvent({
                title : this.LABELS.TOAST_TITLE_WARN,
                variant : 'warning'
            });
            this.dispatchEvent(warnToast);
            return;
        }

        this.isWorking = true;

        createInvoices({
            timeEntryIds: this.getSelectedIds(),
            options: this.selectedOptions,
            filters: this.selectedFilters,
        })
        .then(() => {
            let successToast = new ShowToastEvent({
                title : this.LABELS.TOAST_TITLE_SUCCESS,
                variant : 'success'
            });
            this.dispatchEvent(successToast);
            this.isWorking = false;
            this.refreshData(this.selectedFilters);
            this.dispatchEvent(new CustomEvent('stepcompleted'));
        })
        .catch(() => {
            this.isWorking = false;
        });
    }

    getSelectedIds() {
        let selectedIds = [];
        this.template.querySelector('lightning-datatable').getSelectedRows().forEach( (entry) => {selectedIds.push(entry.Id)} );
        return selectedIds;
    }

}