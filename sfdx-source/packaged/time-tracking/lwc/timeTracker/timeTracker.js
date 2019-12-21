import { LightningElement, track, wire } from 'lwc';
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord
} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CARD_TITLE from '@salesforce/label/c.TimeTracking_Title_TrackingWidget';

import TIME_ENTRY_OBJECT from '@salesforce/schema/TimeEntry__c';

export default class TimeTracker extends LightningElement {

    LABELS = {
        CARD_TITLE
    }

    @wire(getRecordCreateDefaults, { objectApiName : TIME_ENTRY_OBJECT})
    timeEntryDefaults;

    @track isRecording = false;

    /**                                 EVENT HANDLING                                  */

    startRecording() {
        this.insertNewTimeEntry();
        this.isRecording = true;
    }

    /**                                GETTERS & SETTERS                                 */

    get isRecording() {
        return this.isRecording;
    }

    /**                                     HELPERS                                      */

    insertNewTimeEntry() {
        let newTimeEntry = this.createNewTimeEntry();
        newTimeEntry.fields.Account__c = '0011D00000fEWljQAG';
        newTimeEntry.fields.DailyRate__c = 500.66;
        newTimeEntry.fields.StartTime__c =  new Date(Date.now()).toLocaleTimeString();
        console.log(JSON.stringify(newTimeEntry));

        createRecord(newTimeEntry)
        .then(() => {
            this.dispatchToast('success', 'Successfully created record!');
        })
        .catch((error) => {
            this.dispatchToast('error', 'Could not create record!', error.body.message);
        });
    }

    createNewTimeEntry() {

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

}