// lwcComponentName.test.js
import { createElement } from 'lwc';
import treeGrid from 'c/timeEntriesTreeGrid';

import getNonInvoicedTimeEntries from '@salesforce/apex/BillingController.getNonInvoicedTimeEntries';

// create plain mocks for apex without functionality
jest.mock(
    '@salesforce/apex/BillingController.getNonInvoicedTimeEntries',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// import mock data
const APPROVED_TIME_ENTRIES = require('./data/approved-time-entries.json');

describe('c-time-entries-tree-grid', () => {
    
    // reset DOM after each test
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });
    
    /* Helper function to wait until the microtask queue is empty. This is needed for promise
       timing when calling imperative Apex. */
    function flushPromises() {
        // eslint-disable-next-line no-undef
        return new Promise(resolve => setImmediate(resolve));
    }
    
    test('connect time entries table: retrieve method called with filters', () => {

        // mock non-invoiced query with test data
        getNonInvoicedTimeEntries.mockResolvedValue(APPROVED_TIME_ENTRIES);
        
        // create time entries tree grid and add to DOM
        const element = createElement('c-time-entries-tree-grid', {
            is: treeGrid
        });
        document.body.appendChild(element);

        // set filters and refresh data
        element.filters = { startDate: '2019-01-01', endDate: '2019-02-28' };
        element.refreshData();

        return flushPromises().then(() => {
            // apex was called
            expect(getNonInvoicedTimeEntries).toHaveBeenCalledTimes(1);
            expect(getNonInvoicedTimeEntries).toHaveBeenCalledWith({ startDate: '2019-01-01', endDate: '2019-02-28' });
        });

    });

    test('update filters: retrieve method called with updated filters', () => {

        // mock non-invoiced query with test data
        getNonInvoicedTimeEntries.mockResolvedValue(APPROVED_TIME_ENTRIES);
        
        // create time entries tree grid and add to DOM
        const element = createElement('c-time-entries-tree-grid', {
            is: treeGrid
        });
        element.filters = { startDate: '2019-01-01', endDate: '2019-02-28' };
        document.body.appendChild(element);

        // update filters and cause refresh data
        element.filters = { startDate: '2019-03-01', endDate: '2019-03-31' };
        element.refreshData();

        return flushPromises().then(() => {
            expect(getNonInvoicedTimeEntries).toHaveBeenCalledTimes(1);
            expect(getNonInvoicedTimeEntries).toHaveBeenCalledWith({ startDate: '2019-03-01', endDate: '2019-03-31' });
        });

    });

});