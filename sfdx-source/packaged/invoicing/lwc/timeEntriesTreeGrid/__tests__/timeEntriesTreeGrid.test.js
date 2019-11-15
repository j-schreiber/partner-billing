import { createElement } from 'lwc';
import treeGrid from 'c/timeEntriesTreeGrid';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import getTimeEntries from '@salesforce/apex/BillingController.getNonInvoicedTimeEntries';

const getTimeEntriesAdapter = registerApexTestWireAdapter(getTimeEntries);

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
    
    test('retrieve data from wire: init with default filters', () => {

        // create time entries tree grid and add to DOM
        const element = createElement('c-time-entries-tree-grid', {
            is: treeGrid
        });
        document.body.appendChild(element);

        const WIRE_PARAM = {
            startDate : new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth() -1, 1)).toISOString().split("T")[0],          // start of last month, format: 2019-11-01
            endDate : new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth(), 0)).toISOString().split("T")[0]                // end of last month, format 2019-11-30
        }
        return Promise.resolve().then(() => {
            expect(getTimeEntriesAdapter.getLastConfig()).toEqual(WIRE_PARAM);
        });

    });
    test('retrieve data from wire: manually set filters', () => {

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

        return Promise.resolve().then(() => {
            expect(getTimeEntriesAdapter.getLastConfig()).toEqual(
                { startDate : '2019-03-01', endDate : '2019-03-31' }
            );
        });

    });

    test('retrieve data from wire: success', () => {

        // create time entries tree grid and add to DOM
        const element = createElement('c-time-entries-tree-grid', {
            is: treeGrid
        });
        document.body.appendChild(element);

        getTimeEntriesAdapter.emit(APPROVED_TIME_ENTRIES);

        return Promise.resolve().then(() => {
            let dataTable = element.shadowRoot.querySelector('lightning-datatable');
            expect(dataTable.data).toEqual(APPROVED_TIME_ENTRIES);

            let errBox = element.shadowRoot.querySelector('c-message-box');
            expect(errBox).toBeNull();
        });

    });

    test('retrieve data from wire: error', () => {

        const element = createElement('c-time-entries-tree-grid', {
            is: treeGrid
        });
        document.body.appendChild(element);

        getTimeEntriesAdapter.error();

        return Promise.resolve().then(() => {
            let dataTable = element.shadowRoot.querySelector('lightning-datatable');
            expect(dataTable).toBeNull();

            let errBox = element.shadowRoot.querySelector('c-message-box');
            expect(errBox).not.toBeNull();
            expect(errBox.variant).toBe('error');
        });
    });

});