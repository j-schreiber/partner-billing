import { createElement } from 'lwc';
import invoiceCard from 'c/invoiceCard';
import commitData from '@salesforce/apex/BillingController.commitInvoiceEditData';

// import mocked subscribers
const MOCK_VALID_INVOICE = require('./data/valid-invoice.json');

// create the function mock for the find subscriber apex method
jest.mock(
    '@salesforce/apex/BillingController.commitInvoiceEditData',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

jest.mock(
    './mocks/invoiceLineItemDatatable',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);
const dataTable = require('./mocks/invoiceLineItemDatatable');

describe('c-invoice-card', () => {
    
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
    
    test('render invoice card: all defaults set', () => {
        
        const element = createElement('c-invoice-card', {
            is: invoiceCard
        });
        element.invoice = MOCK_VALID_INVOICE;
        document.body.appendChild(element);

        expect(element.getModifiedFields()).toStrictEqual({});
        expect(element.getModifiedLineItems()).toStrictEqual([]);
        expect(element.getDeletedLineItems()).toStrictEqual([]);
        expect(element.isLocked()).toBe(false);

    });

    test('activate button clicked: all input elements read-only', () => {

        const element = createElement('c-invoice-card', {
            is: invoiceCard
        });
        element.invoice = MOCK_VALID_INVOICE;
        document.body.appendChild(element);

        let actBtn = element.shadowRoot.querySelector('lightning-button-stateful[data-id="activateButton"]');
        actBtn.click();

        expect(element.getModifiedFields()).toStrictEqual({ Id : MOCK_VALID_INVOICE.Record.Id, Status__c : 'Activated'});
        expect(element.isLocked()).toBe(true);

        // DOM updates
        return flushPromises().then(() => {
            element.shadowRoot.querySelectorAll('lightning-input').forEach ( (input) => expect(input.disabled).toBe(true));
            let dataTable = element.shadowRoot.querySelector('c-invoice-line-item-datatable');
            expect(dataTable.isDisabled).toBe(true);
        });

    });

    test('cancelled button clicked: all input elements read-only', () => {

        const element = createElement('c-invoice-card', {
            is: invoiceCard
        });
        element.invoice = MOCK_VALID_INVOICE;
        document.body.appendChild(element);

        let cnlBtn = element.shadowRoot.querySelector('lightning-button-stateful[data-id="cancelButton"]');
        cnlBtn.click();
        
        expect(element.getModifiedFields()).toStrictEqual({ Id : MOCK_VALID_INVOICE.Record.Id, Status__c : 'Cancelled'});
        expect(element.isLocked()).toBe(true);

        // DOM updates
        return flushPromises().then(() => {
            element.shadowRoot.querySelectorAll('lightning-input').forEach ( (input) => expect(input.disabled).toBe(true));
            let dataTable = element.shadowRoot.querySelector('c-invoice-line-item-datatable');
            expect(dataTable.isDisabled).toBe(true);
        });

    });

    test('update input fields: updates reflected in modified fields', () => {
        
        const element = createElement('c-invoice-card', {
            is: invoiceCard
        });
        element.invoice = MOCK_VALID_INVOICE;
        document.body.appendChild(element);

        let dateInput = element.shadowRoot.querySelector('lightning-input[data-id="inputDate"]');
        dateInput.value = '2019-11-14';
        dateInput.dispatchEvent(new CustomEvent('change', {detail : { value : '2019-11-14'}}));
        
        expect(element.getModifiedFields()).toStrictEqual({ Id : MOCK_VALID_INVOICE.Record.Id, Date__c : '2019-11-14'});

        let servicePeriodFromInput = element.shadowRoot.querySelector('lightning-input[data-id="inputServicePeriodFrom"]');
        servicePeriodFromInput.value = '2019-11-01';
        servicePeriodFromInput.dispatchEvent(new CustomEvent('change', {detail : { value : '2019-11-01'}}));

        expect(element.getModifiedFields()).toStrictEqual({ Id : MOCK_VALID_INVOICE.Record.Id, Date__c : '2019-11-14', ServicePeriodFrom__c : '2019-11-01'});

        let servicePeriodToInput = element.shadowRoot.querySelector('lightning-input[data-id="inputServicePeriodTo"]');
        servicePeriodToInput.value = '2019-11-30';
        servicePeriodToInput.dispatchEvent(new CustomEvent('change', {detail : { value : '2019-11-30'}}));

        expect(element.getModifiedFields()).toStrictEqual({ Id : MOCK_VALID_INVOICE.Record.Id, Date__c : '2019-11-14', ServicePeriodFrom__c : '2019-11-01', ServicePeriodTo__c : '2019-11-30'});

    });

    test('save button clicked without cached changes: apex not called', () => {

        commitData.mockResolvedValue({});
        
        const element = createElement('c-invoice-card', {
            is: invoiceCard
        });
        element.invoice = MOCK_VALID_INVOICE;
        document.body.appendChild(element);

        let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveButton"]');
        saveBtn.click();

        expect(commitData).not.toHaveBeenCalled();
    
    });

    test('save button clicked with cached changes on invoice: apex called with changes only', () => {

        commitData.mockResolvedValue({});
        
        const element = createElement('c-invoice-card', {
            is: invoiceCard
        });
        element.invoice = MOCK_VALID_INVOICE;
        document.body.appendChild(element);

        let dateInput = element.shadowRoot.querySelector('lightning-input[data-id="inputDate"]');
        dateInput.value = '2019-11-14';
        dateInput.dispatchEvent(new CustomEvent('change', {detail : { value : '2019-11-14'}}));

        let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveButton"]');
        saveBtn.click();

        expect(commitData).toHaveBeenCalled();
        expect(commitData).toHaveBeenCalledWith({
            invoices: [{ Id : MOCK_VALID_INVOICE.Record.Id, Date__c : '2019-11-14'}],
            upsertLineItems: [],
            deleteLineItemIds: []
        });
    
    });

    test('save button clicked with cached changes deleted line items: apex called with changes only', () => {

        commitData.mockResolvedValue({});
        
        const element = createElement('c-invoice-card', {
            is: invoiceCard
        });
        element.invoice = MOCK_VALID_INVOICE;
        document.body.appendChild(element);

        let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveButton"]');
        saveBtn.click();

        expect(commitData).toHaveBeenCalled();
        expect(commitData).toHaveBeenCalledWith({
            invoices: [],
            upsertLineItems: [],
            deleteLineItemIds: ['a052F000003tzKKQAY']
        });
    });


});