import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

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

    @track isWorking = false;

    selectedOptions = {
        collapseTimeEntries : true,
        overrideServicePeriod : true
    };

    @track filterStartDate = new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth() -1, 1)).toISOString().split("T")[0];
    @track filterEndDate = new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth(), 0)).toISOString().split("T")[0];

    @wire(getTimeEntries, { startDate : '$filterStartDate', endDate : '$filterEndDate'})
    timeEntries;

    columns = COLUMN_DEFINITION;

    LABELS = {
        CARD_TITLE,
        STARTDATE_PICKER_LABEL,
        ENDDATE_PICKER_LABEL,
        TOAST_TITLE_SUCCESS,
        TOAST_TITLE_ERROR,
        TOAST_TITLE_WARN
    }

    handleStartDateChange(event) {
        this.filterStartDate = event.detail.value;
    }

    handleEndDateChange(event) {
        this.filterEndDate = event.detail.value;
    }

    refreshData() {
        this.isWorking = true;
        refreshApex(this.timeEntries);
        this.isWorking = false;
    }

    handleCollapseToggle(event) {
        this.selectedOptions.collapseTimeEntries = event.detail.checked
    }

    handleServicePeriodToggle(event) {
        this.selectedOptions.overrideServicePeriod = event.detail.checked
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
            filters: { startDate : this.filterStartDate, endDate : this.filterEndDate},
        })
        .then(() => {
            let successToast = new ShowToastEvent({
                title : this.LABELS.TOAST_TITLE_SUCCESS,
                variant : 'success'
            });
            this.dispatchEvent(successToast);
            refreshApex(this.timeEntries);
            this.isWorking = false;
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