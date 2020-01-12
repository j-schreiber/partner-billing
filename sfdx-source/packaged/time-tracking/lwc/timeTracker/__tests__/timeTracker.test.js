import { createElement } from 'lwc';
import timeTrackerWidget from 'c/timeTracker';

import getUnfinishedTimeEntries from '@salesforce/apex/TimeTrackingController.getUnfinishedTimeEntries';

jest.mock(
    '@salesforce/apex/TimeTrackingController.getUnfinishedTimeEntries',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

const EMPTY_LIST = require('./data/empty-list.json');
const OPEN_TIME_ENTRIES = require('./data/open-time-entries.json');

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
        
    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}