// lwcComponentName.test.js
import { createElement } from 'lwc';
import treeGrid from 'c/timeEntriesTreeGrid';

import getTimeEntries from '@salesforce/apex/BillingController.getNonInvoicedTimeEntries';

// create plain mocks for apex without functionality
jest.mock(
    '@salesforce/apex/InvoicePdfController.getNonInvoicedTimeEntries',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

const APPROVED_TIME_ENTRIES = require('./data/approved-time-entries.json');

describe('c-time-entries-tree-grid', () => {
    
    // reset DOM after each test
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });
    
    /* Helper function to wait until the microtask queue is empty. This is needed for promise
       timing when calling imperative Apex. */
    function flushPromises() {
        // eslint-disable-next-line no-undef
        return new Promise(resolve => setImmediate(resolve));
    }
    
    test('render time entries table: retrieve method called with date', () => {

        // mock non-invoiced query with test data
        getTimeEntries.mockResolvedValue(APPROVED_TIME_ENTRIES);
        
        // create time entries tree grid and add to DOM
        const element = createElement('c-time-entries-tree-grid', {
            is: treeGrid
        });
        document.body.appendChild(element);

        return flushPromises().then(() => {

            // apex was called
            expect(getTimeEntries).toHaveBeenCalled();
        });

    });

});