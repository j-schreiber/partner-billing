import { createElement } from 'lwc';
import timeTrackerWidget from 'c/timeTracker';
import {
    getRecordCreateDefaults,
    getRecord
} from 'lightning/uiRecordApi';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

import getUnfinishedTimeEntries from '@salesforce/apex/TimeTrackingController.getUnfinishedTimeEntries';

jest.mock(
    '@salesforce/apex/TimeTrackingController.getUnfinishedTimeEntries',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

const getRecordWireAdapter = registerLdsTestWireAdapter(getRecord);
const getRecordCreateDefaultsWireAdapter = registerLdsTestWireAdapter(getRecordCreateDefaults);

const EMPTY_LIST = require('./data/empty-list.json');
const OPEN_TIME_ENTRIES = require('./data/open-time-entries.json');
const EXISTING_TIME_ENTRY = require('./data/existing-record.json');

describe('c-time-tracker', () => {

    describe('initialization', () => {
    
        afterEach(() => { reset(); });

        test('no open time entries => starts blank', async () => {

            getUnfinishedTimeEntries.mockResolvedValue(EMPTY_LIST);
        
            const element = createElement('c-time-tracker', {
                is: timeTrackerWidget 
            });
            document.body.appendChild(element);

            await Promise.resolve();

            let clock = element.shadowRoot.querySelector('c-duration-timer');
            expect(clock).toBeNull();

            let accountInput = element.shadowRoot.querySelector('lightning-input-field[data-id="InputAccount__c"]');
            expect(accountInput.disabled).toBe(false);

            let startRecordingButton = element.shadowRoot.querySelector('lightning-button-icon[data-id="startRecordingButton"]');
            expect(startRecordingButton).not.toBeNull();
            
        });

        test('has open time entries => continues existing time entry', async () => {

            getUnfinishedTimeEntries.mockResolvedValue(OPEN_TIME_ENTRIES);
        
            const element = createElement('c-time-tracker', {
                is: timeTrackerWidget 
            });
            document.body.appendChild(element);

            await Promise.resolve();

            let clock = element.shadowRoot.querySelector('c-duration-timer');
            expect(clock).not.toBeNull();

            let accountInput = element.shadowRoot.querySelector('lightning-input-field[data-id="InputAccount__c"]');
            expect(accountInput.disabled).toBe(true);
            
        });

        test('open time entry fully loaded => full functionality available for time entry', async () => {

            getUnfinishedTimeEntries.mockResolvedValue(OPEN_TIME_ENTRIES);
        
            const element = createElement('c-time-tracker', {
                is: timeTrackerWidget 
            });
            document.body.appendChild(element);
            await Promise.resolve();

            getRecordWireAdapter.emit(EXISTING_TIME_ENTRY);
            await Promise.resolve();

            let dailyRateInput = element.shadowRoot.querySelector('lightning-input[data-id="InputDailyRate__c"]');
            expect(dailyRateInput.value).toBe(EXISTING_TIME_ENTRY.fields.DailyRate__c.value);

            let descriptionInput = element.shadowRoot.querySelector('lightning-textarea[data-id="InputDescription__c"]');
            expect(descriptionInput.value).toBe(EXISTING_TIME_ENTRY.fields.Description__c.value);

            let submitButton = element.shadowRoot.querySelector('lightning-button[data-id="submitTimeEntryButton"]');
            expect(submitButton).not.toBeNull();

            let deleteButton = element.shadowRoot.querySelector('lightning-button-icon[data-id="deleteTimeEntryButton"]');
            expect(deleteButton).not.toBeNull();

        });
        
    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}