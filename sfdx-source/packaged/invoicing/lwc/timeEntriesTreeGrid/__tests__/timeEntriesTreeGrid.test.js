import { createElement } from 'lwc';
import treeGrid from 'c/timeEntriesTreeGrid';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

import getTimeEntries from '@salesforce/apex/BillingController.getNonInvoicedTimeEntries';
import createInvoices from '@salesforce/apex/BillingController.createInvoicesFromTimeEntries';

const getTimeEntriesAdapter = registerApexTestWireAdapter(getTimeEntries);

jest.mock(
    '@salesforce/apex/BillingController.createInvoicesFromTimeEntries',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// import mock data
const APPROVED_TIME_ENTRIES = require('./data/approved-time-entries.json');
const EMPTY_LIST = require('./data/empty-list.json');

const MOCK_SELECTED_ROWS = [
    {
        AccountName:"Colonial One",
        DailyRate:1250,
        Duration:"5.25 h",
        EndTime:63000000,
        Id:"a092a000001mjv4AAA",
        Name:"20191116-000020",
        ProductName:"Flight Maneuver Training: Beginner",
        ServiceDate:"2019-10-09",
        StartTime:44100000,
        TotalAmount:820.31
    },
    {
        AccountName:"Colonial One",
        DailyRate:1500,
        Duration:"5.25 h",
        EndTime:63000000,
        Id:"a092a000001mjv5AAA",
        Name:"20191116-000020",
        ProductName:"Flight Maneuver Training: Advanced",
        ServiceDate:"2019-10-09",
        StartTime:44100000,
        TotalAmount: 1000
    }
];

describe('c-time-entries-tree-grid', () => {
    
    // reset DOM after each test
    afterEach(() => { reset(); });

    describe('retrieve wired time entries', () => {

        afterEach(() => { reset(); });

        test('wire params: initial filters', async () => {

            // create time entries tree grid and add to DOM
            const element = createElement('c-time-entries-tree-grid', {
                is: treeGrid
            });
            document.body.appendChild(element);
    
            const WIRE_PARAM = {
                startDate : new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth() -1, 1)).toISOString().split("T")[0],          // start of last month, format: 2019-11-01
                endDate : new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth(), 0)).toISOString().split("T")[0]                // end of last month, format 2019-11-30
            }

            await Promise.resolve();
            
            expect(getTimeEntriesAdapter.getLastConfig()).toEqual(WIRE_PARAM);
    
        });
        
        test('wire params: manual filters', async () => {
    
            // create time entries tree grid and add to DOM
            const element = createElement('c-time-entries-tree-grid', {
                is: treeGrid
            });
            document.body.appendChild(element);
    
            let startDateInput = element.shadowRoot.querySelector('lightning-input[data-id="startDateInput"]');
            let endDateInput = element.shadowRoot.querySelector('lightning-input[data-id="endDateInput"]');
            
            startDateInput.value = '2019-03-01';
            endDateInput.value = '2019-03-31';
            startDateInput.dispatchEvent(new CustomEvent('change', { detail : { value : startDateInput.value }}));
            endDateInput.dispatchEvent(new CustomEvent('change', { detail : { value : endDateInput.value }}));
    
            await Promise.resolve();

            expect(getTimeEntriesAdapter.getLastConfig()).toEqual({ startDate: '2019-03-01', endDate: '2019-03-31' });
    
        });

        test('wire response: success with data', async () => {

            // create time entries tree grid and add to DOM
            const element = createElement('c-time-entries-tree-grid', {
                is: treeGrid
            });
            document.body.appendChild(element);
    
            getTimeEntriesAdapter.emit(APPROVED_TIME_ENTRIES);
    
            await Promise.resolve();

            let dataTable = element.shadowRoot.querySelector('lightning-datatable');
            expect(dataTable.data).toEqual(APPROVED_TIME_ENTRIES);
            expect(dataTable.data.length).toBe(APPROVED_TIME_ENTRIES.length);
            let errBox = element.shadowRoot.querySelector('c-message-box');
            expect(errBox).toBeNull();
    
        });

        test('wire response: success without data', async () => {

            // create time entries tree grid and add to DOM
            const element = createElement('c-time-entries-tree-grid', {
                is: treeGrid
            });
            document.body.appendChild(element);
    
            getTimeEntriesAdapter.emit(EMPTY_LIST);
    
            await Promise.resolve();
            
            let dataTable = element.shadowRoot.querySelector('lightning-datatable');
            expect(dataTable.data).toEqual(EMPTY_LIST);
            expect(dataTable.data.length).toBe(0);

            let msgBoxes = element.shadowRoot.querySelectorAll('c-message-box');
            expect(msgBoxes.length).toBe(1);
            expect(msgBoxes[0].variant).toBe('warning');
    
        });

        test('retrieve data from wire: error', async () => {

            const element = createElement('c-time-entries-tree-grid', {
                is: treeGrid
            });
            document.body.appendChild(element);
    
            getTimeEntriesAdapter.error();
    
            await Promise.resolve();
            
            let dataTable = element.shadowRoot.querySelector('lightning-datatable');
            expect(dataTable).toBeNull();
            let errBox = element.shadowRoot.querySelector('c-message-box');
            expect(errBox).not.toBeNull();
            expect(errBox.variant).toBe('error');
        });

    });


    describe('invoice time entries', () => {

        beforeEach(() => { reset(); })

        test('has selection: apex called with selected ids', async () => {

            createInvoices.mockResolvedValue();
    
            const element = createElement('c-time-entries-tree-grid', {
                is: treeGrid
            });
            document.body.appendChild(element);
            
            getTimeEntriesAdapter.emit(APPROVED_TIME_ENTRIES);
    
            // after DOM re-render
            await Promise.resolve();

            // mock user input by programmatically selecting rows
            let dataTable = element.shadowRoot.querySelector('lightning-datatable');
            dataTable.getSelectedRows = jest.fn(() => { return MOCK_SELECTED_ROWS; });
            let invButton = element.shadowRoot.querySelector('lightning-button[data-id="invoiceButton"]');
            invButton.click();

            expect(createInvoices).toHaveBeenCalledWith({
                filters: {
                    endDate: "2019-10-31",
                    startDate: "2019-10-01"
                },
                options: {
                    collapseTimeEntries: true,
                    overrideServicePeriod: true
                },
                timeEntryIds: [
                    "a092a000001mjv4AAA",
                    "a092a000001mjv5AAA"
                ]
            });
            
        });

        test('has no selection: apex not called', async () => {

            const element = createElement('c-time-entries-tree-grid', {
                is: treeGrid
            });
            document.body.appendChild(element);
            getTimeEntriesAdapter.emit(APPROVED_TIME_ENTRIES);

            // wait for DOM re-render, so data table actually exists
            await flushPromises();

            // mock "no selection" for data table
            let dataTable = element.shadowRoot.querySelector('lightning-datatable');
            dataTable.getSelectedRows = jest.fn(() => { return []; });

            // click invoicing brand button
            let invButton = element.shadowRoot.querySelector('lightning-button[data-id="invoiceButton"]');
            invButton.click();
            
            expect(createInvoices).not.toHaveBeenCalled();
        
        });
    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}

// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex.
function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise(resolve => setImmediate(resolve));
}