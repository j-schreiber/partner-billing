import { LightningElement, track, wire } from 'lwc';
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    getRecord,
    updateRecord,
    deleteRecord,
    getFieldValue
} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceDMLErrors } from 'c/utilities';

import getUnfinishedTimeEntries from '@salesforce/apex/TimeTrackingController.getUnfinishedTimeEntries';

import CARD_TITLE from '@salesforce/label/c.TimeTracking_Title_TrackingWidget';
import TOAST_TITLE_ERROR from '@salesforce/label/c.Toast_Title_GenericError';
import TOAST_TITLE_STARTED_SUCCESS from '@salesforce/label/c.TimeTracking_Toast_RecordingStarted';
import TOAST_TITLE_STOPPED_SUCCESS from '@salesforce/label/c.TimeTracking_Toast_RecordingStopped';
import TOAST_TITLE_STOPPED_ERROR from '@salesforce/label/c.TimeTracking_Toast_CanNotStopRecording';
import TOAST_TITLE_RECORDING_ABORTED from '@salesforce/label/c.TimeTracking_RecordingAborted';

import TIME_ENTRY_OBJECT from '@salesforce/schema/TimeEntry__c';
import TIME_ENTRY_ACCOUNT_FIELD from '@salesforce/schema/TimeEntry__c.Account__c';
import TIME_ENTRY_RESOURCE_FIELD from '@salesforce/schema/TimeEntry__c.Resource__c';
import TIME_ENTRY_PRODUCT_FIELD from '@salesforce/schema/TimeEntry__c.Product__c';
import TIME_ENTRY_BUDGET_FIELD from '@salesforce/schema/TimeEntry__c.Budget__c';
import TIME_ENTRY_STATUS_FIELD from '@salesforce/schema/TimeEntry__c.Status__c';
import TIME_ENTRY_STARTTIME_FIELD from '@salesforce/schema/TimeEntry__c.StartTime__c';
import TIME_ENTRY_ENDTIME_FIELD from '@salesforce/schema/TimeEntry__c.EndTime__c';
import TIME_ENTRY_DAILYRATE_FIELD from '@salesforce/schema/TimeEntry__c.DailyRate__c';
import TIME_ENTRY_DATE_FIELD from '@salesforce/schema/TimeEntry__c.Date__c';
import TIME_ENTRY_DESCRIPTION_FIELD from '@salesforce/schema/TimeEntry__c.Description__c';


export default class TimeTracker extends LightningElement {

    LABELS = {
        CARD_TITLE,
        TOAST_TITLE_ERROR,
        TOAST_TITLE_STARTED_SUCCESS,
        TOAST_TITLE_STOPPED_SUCCESS,
        TOAST_TITLE_STOPPED_ERROR,
        TOAST_TITLE_RECORDING_ABORTED
    }

    @wire(getRecordCreateDefaults, { objectApiName : TIME_ENTRY_OBJECT})
    timeEntryDefaults;

    @wire(getRecord, {
        recordId: '$activeTimeEntryId', 
        fields : [
            TIME_ENTRY_ACCOUNT_FIELD,
            TIME_ENTRY_RESOURCE_FIELD,
            TIME_ENTRY_PRODUCT_FIELD,
            TIME_ENTRY_BUDGET_FIELD,
            TIME_ENTRY_STATUS_FIELD,
            TIME_ENTRY_STARTTIME_FIELD,
            TIME_ENTRY_ENDTIME_FIELD,
            TIME_ENTRY_DAILYRATE_FIELD,
            TIME_ENTRY_DATE_FIELD,
            TIME_ENTRY_DESCRIPTION_FIELD
        ]})
    getTimeEntryRecord({data}) {
        this.activeTimeEntry = data;
        if (this.activeTimeEntry) this.isLoading = false;
    }

    @track isRecording = false;
    @track isLoading = true;
    @track isWorking = false;
    @track activeTimeEntryId;
    @track activeTimeEntry;
    @track currentTime = new Date(Date.now()).toLocaleTimeString();

    /**                                LIFECYCLE METHODS                                */

    connectedCallback() {
        getUnfinishedTimeEntries()
        .then((data) => {
            if (data && data.length >= 1) {
                this.isRecording = Boolean(data.length >= 1);
                this.activeTimeEntryId = data[0].Id
            }
            if (!this.isRecording) {
                this.isLoading = false;
            }
        });

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setInterval(() => {
            this.currentTime = new Date().toLocaleTimeString() + '.000Z';
        }, 1000);

    }

    /**                                 EVENT HANDLING                                  */

    startRecording() {
        this.isWorking = true;
        let newTimeEntry = this.createTimeEntryForInsert();
        newTimeEntry.fields.DailyRate__c = 650.00;
        newTimeEntry.fields.StartTime__c = new Date(Date.now()).toLocaleTimeString();
        newTimeEntry.fields.Account__c = this.template.querySelector('[data-id="InputAccount__c"]').value

        createRecord(newTimeEntry)
        .then((newRecord) => {
            this.isRecording = true;
            this.isWorking = false;
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_STARTED_SUCCESS);
            this.activeTimeEntry = newRecord;
            this.activeTimeEntryId = newRecord.id;
        })
        .catch((error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_ERROR, reduceDMLErrors(error));
            this.isRecording = false;
            this.isWorking = false;
        });
    }

    stopRecording() {
        this.isWorking = true;
        let updateTimeEntry = this.createTimeEntryRecordInputForField(TIME_ENTRY_ENDTIME_FIELD.fieldApiName, new Date(Date.now()).toLocaleTimeString());
        updateRecord(updateTimeEntry)
        .then((updatedRecord) => {
            this.dispatchToast('success', this.LABELS.TOAST_TITLE_STOPPED_SUCCESS);
            this.updateActiveTimeEntry(updatedRecord);
            this.isWorking = false;
        })
        .catch((error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_STOPPED_ERROR, reduceDMLErrors(error));
            this.isWorking = false;
        });
    }

    deleteRecording() {
        this.isWorking = true;
        deleteRecord(this.activeTimeEntryId)
        .then(() => {
            this.dispatchToast('warning', this.LABELS.TOAST_TITLE_RECORDING_ABORTED);
            this.activeTimeEntryId = undefined;
            this.activeTimeEntry = undefined;
            this.isRecording = false;
            this.isWorking = false;
        })
        .catch((error) => {
            this.dispatchToast('error', this.LABELS.TOAST_TITLE_ERROR, reduceDMLErrors(error));
            this.isWorking = false;
        });
    }

    updateRecordLookup(event) {
        this.isWorking = true;
        let timeEntryUpdate = this.createTimeEntryRecordInputForField(
            event.currentTarget.fieldName,
            (event.detail && event.detail.value.length === 0) ? '' : (event.detail.value)[0]
        );
        this.updateTimeEntryRecord(timeEntryUpdate);
    }

    updateRecordValue(event) {
        this.isWorking = true;
        let timeEntryUpdate = this.createTimeEntryRecordInputForField(event.currentTarget.name, event.currentTarget.value);
        this.updateTimeEntryRecord(timeEntryUpdate);
    }

    /**                                GETTERS & SETTERS                                 */

    get isReady() {
        return !this.isRecording && !this.isLoading;
    }

    get isFullyLoaded() {
        return this.isRecording && !this.isLoading;
    }

    get AccountId() {
        return getFieldValue(this.activeTimeEntry, TIME_ENTRY_ACCOUNT_FIELD);
    }

    get DailyRate() {
        return getFieldValue(this.activeTimeEntry, TIME_ENTRY_DAILYRATE_FIELD);
    }

    get Description() {
        return getFieldValue(this.activeTimeEntry, TIME_ENTRY_DESCRIPTION_FIELD);
    }

    get startTime() {
        return getFieldValue(this.activeTimeEntry, TIME_ENTRY_STARTTIME_FIELD);
    }

    /**                                     HELPERS                                      */

    createTimeEntryRecordInputForField(fieldName, fieldValue) {
        let recordInput = {
            fields : {
                Id : this.activeTimeEntryId
            }
        }
        recordInput.fields[fieldName] = fieldValue;
        return recordInput;
    }

    createTimeEntryForInsert() {

        if (!this.timeEntryDefaults.data) {
            return undefined;
        }

        return generateRecordInputForCreate(
            this.timeEntryDefaults.data.record,
            this.timeEntryDefaults.data.objectInfos[TIME_ENTRY_OBJECT.objectApiName]
        );
    }

    dispatchToast(variant, title, message) {
        let toast = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(toast);
    }

    updateActiveTimeEntry(updatedRecord) {
        if (updatedRecord.fields.EndTime__c.value !== null) {
            this.isRecording = false;
            this.activeTimeEntry = undefined;
            this.activeTimeEntryId = undefined;
        } else {
            this.activeTimeEntry = updatedRecord;
        }
    }

    updateTimeEntryRecord(recordInput) {
        updateRecord(recordInput)
        .then((updatedRecord) => {
            this.updateActiveTimeEntry(updatedRecord);
            this.isWorking = false;
        });
    }

}