import { createElement } from 'lwc';
import timeTrackerWidget from 'c/timeTracker';

import getUnfinishedTimeEntries from '@salesforce/apex/TimeTrackingController.getUnfinishedTimeEntries';

jest.mock(
    '@salesforce/apex/TimeTrackingController.getUnfinishedTimeEntries',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-time-tracker', () => {

    describe('get wired data', () => {
    
        afterEach(() => { reset(); });
        
        test('test 1', () => {
        
            const element = createElement('c-time-tracker', {
                is: timeTrackerWidget 
            });
            document.body.appendChild(element);
            
        });
        
    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}