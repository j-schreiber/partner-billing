import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getErrorsAsString } from 'c/utilities';

import getTimeEntries from '@salesforce/apex/BillingController.getNonInvoicedTimeEntries';
import createInvoices from '@salesforce/apex/BillingController.createInvoicesFromTimeEntries';

import TOAST_TITLE_SUCCESS from '@salesforce/label/c.Toast_Title_InvoicingRunSuccess';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';
import TOAST_TITLE_WARN from '@salesforce/label/c.Toast_Title_NoTimeEntriesSelected';
import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_FilterHeader';
import MESSAGE_NO_RECORDS from '@salesforce/label/c.Message_Generic_NoRecordsFound';
import STARTDATE_PICKER_LABEL from '@salesforce/label/c.Invoicing_Label_ServiceDateStart';
import ENDDATE_PICKER_LABEL from '@salesforce/label/c.Invoicing_Label_ServiceDateEnd';

const COLUMN_DEFINITION = [
    { type: "text", fieldName: "AccountName", label: "Accountname" },
    { type: "text", fieldName: "Name", label: "Number", initialWidth: 140 },
    { type: "date", fieldName: "ServiceDate", label: "Date" },
    { type: "date", fieldName: "StartTime", label: "Start Time", typeAttributes: { hour: "2-digit", minute: "2-digit" }, initialWidth : 100 },
    { type: "date", fieldName: "EndTime", label: "End Time", typeAttributes: { hour: "2-digit", minute: "2-digit" }, initialWidth : 100 },
    { type: "text", fieldName: "Duration", label: "Duration", initialWidth : 100 },
    { type: "currency", fieldName: "DailyRate", label: "Daily Rate" },
    { type: "currency", fieldName: "TotalAmount", label: "Total Amount" },
    { type: "text", fieldName: "CustomerApprovalStatus", label: "Customer Approval" },
    { type: "text", fieldName: "ProductName", label: "Product", initialWidth : 200 },
    { type: "text", fieldName: "Description", label: "Description", initialWidth : 300 },
];

export default class TimeEntriesTreeGrid extends LightningElement {

    @track isWorking = false;
    @track hasSelection = false;

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
        TOAST_TITLE_WARN,
        MESSAGE_NO_RECORDS
    }

    /**                                     PUBLIC COMPONENT API                                     */

    @api
    getSelectedIds() {
        let selectedIds = [];
        this.template.querySelector('lightning-datatable').getSelectedRows().forEach( (entry) => {selectedIds.push(entry.Id)} );
        return selectedIds;
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

    invoiceSelectedTimeEntries() {

        if (this.template.querySelector('lightning-datatable').getSelectedRows().length === 0) {
            this.dispatchToast('warning', this.LABELS.TOAST_TITLE_WARN);
            return;
        }

        this.isWorking = true;

        createInvoices({
            timeEntryIds: this.getSelectedIds(),
            options: this.selectedOptions,
            filters: { startDate : this.filterStartDate, endDate : this.filterEndDate},
        })
        .then(() => {
            refreshApex(this.timeEntries);
            this.isWorking = false;
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_SUCCESS);
            this.dispatchEvent(new CustomEvent('stepcompleted'));
        })
        .catch(() => {
            this.isWorking = false;
        });
    }

    dispatchToast(type, title, message) {
        let toast = new ShowToastEvent({
            title : title,
            message : message,
            variant : type
        });
        this.dispatchEvent(toast);
    }

    get wireErrors() {
        if (this.timeEntries.error) {
            return getErrorsAsString(this.timeEntries.error);
        }
        return '';
    }

    get hasNoRecords() {
        return (this.timeEntries.data && this.timeEntries.data.length === 0);
    }

}