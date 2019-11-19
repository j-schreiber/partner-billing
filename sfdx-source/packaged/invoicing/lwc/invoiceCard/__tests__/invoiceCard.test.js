import { createElement } from 'lwc';
import invoiceCard from 'c/invoiceCard';
import commitData from '@salesforce/apex/BillingController.commitInvoiceEditData';
import refreshInvoices from '@salesforce/apex/BillingController.refreshInvoices';

// import mocked subscribers
const MOCK_VALID_INVOICE = require('./data/valid-invoice.json');
const MOCK_UPDATED_INVOICE = require('./data/updated-invoice.json');

// mock the apex method
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
    '@salesforce/apex/BillingController.refreshInvoices',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}

describe('c-invoice-card', () => {

    describe('rendering', () => {

        afterEach(() => { reset(); });

        test('with data: successfully renders', () => {
        
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
    
        test('without data: successfully renders', () => {
            
            const element = createElement('c-invoice-card', {
                is: invoiceCard
            });
            document.body.appendChild(element);
    
            expect(element.getModifiedFields()).toStrictEqual({});
            expect(element.getModifiedLineItems()).toStrictEqual([]);
            expect(element.getDeletedLineItems()).toStrictEqual([]);
            expect(element.isLocked()).toBe(false);
    
        });

    });

    describe('save', () => {

        afterEach(() => { reset(); });

        test('no cached changes: no apex call', () => {

            const element = createElement('c-invoice-card', {
                is: invoiceCard
            });
            element.invoice = MOCK_VALID_INVOICE;
            document.body.appendChild(element);
    
            let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveButton"]');
            saveBtn.click();
    
            expect(commitData).not.toHaveBeenCalled();
        
        });
    
        test('cached changes on invoice: apex call with changes only', () => {
    
            commitData.mockResolvedValue({});
            refreshInvoices.mockResolvedValue(MOCK_UPDATED_INVOICE);
            
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
            
            // wait for re-rendering promise to be resolved
            return Promise.resolve().then(() => {
                saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveButton"]');
                expect(saveBtn.disabled).toBe(true);
    
                dateInput = element.shadowRoot.querySelector('lightning-input[data-id="inputDate"]');
                expect(dateInput.classList).toContain('is-dirty');
            });
        
        });
    
        test('cached changes on deleted line items: apex call with changes only', async () => {
    
            commitData.mockResolvedValue();
            refreshInvoices.mockResolvedValue(MOCK_UPDATED_INVOICE);
            
            const element = createElement('c-invoice-card', {
                is: invoiceCard
            });
            element.invoice = MOCK_VALID_INVOICE;
            document.body.appendChild(element);

            let dataTable = element.shadowRoot.querySelector('c-invoice-line-item-datatable');
            dataTable.getDeletedRows = jest.fn().mockImplementation(() => { return ['a052F000003tzKKQAY']; });

            let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveButton"]');
            saveBtn.click();
            
            expect(commitData).toHaveBeenCalled();
            expect(commitData).toHaveBeenCalledWith({
                invoices: [],
                upsertLineItems: [],
                deleteLineItemIds: ['a052F000003tzKKQAY']
            });

            await Promise.resolve();
            
        });

        test('cached changes on modified line items: apex call with changes only', async () => {
    
            commitData.mockResolvedValue();
            refreshInvoices.mockResolvedValue(MOCK_UPDATED_INVOICE);

            const MOCK_MODIFIED_ITEMS = [
                { Id : 'a052F000003tzKKQAY', Price__c : 1234, Discount__c : 99.99 },
                { Product__c : '1', Price__c : 1000, Discount__c : 0, Tax__c : 0 }
            ];
            
            const element = createElement('c-invoice-card', {
                is: invoiceCard
            });
            element.invoice = MOCK_VALID_INVOICE;
            document.body.appendChild(element);

            let dataTable = element.shadowRoot.querySelector('c-invoice-line-item-datatable');
            dataTable.getModifiedRows = jest.fn(() => { return MOCK_MODIFIED_ITEMS; });

            let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveButton"]');
            saveBtn.click();
            
            expect(commitData).toHaveBeenCalled();
            expect(commitData).toHaveBeenCalledWith({
                invoices: [],
                upsertLineItems: MOCK_MODIFIED_ITEMS,
                deleteLineItemIds: []
            });

            await Promise.resolve();
            
        });
    
        test('data refreshed after commit', async () => {
    
            commitData.mockResolvedValue({});
            refreshInvoices.mockResolvedValue(MOCK_UPDATED_INVOICE);
            
            const element = createElement('c-invoice-card', {
                is: invoiceCard
            });
            element.invoice = MOCK_VALID_INVOICE;
            document.body.appendChild(element);
    
            let dateInput = element.shadowRoot.querySelector('lightning-input[data-id="inputDate"]');
            dateInput.value = '2019-10-04';
            dateInput.dispatchEvent(new CustomEvent('change', {detail : { value : '2019-10-04'}}));
    
            let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveButton"]');
            saveBtn.click();
    
            // commit data is called immediately
            expect(commitData).toHaveBeenCalledWith({
                invoices: [{ Id : MOCK_VALID_INVOICE.Record.Id, Date__c : '2019-10-04'}],
                upsertLineItems: [],
                deleteLineItemIds: []
            });
    
            // refresh invoices is called after resolve of commit data
            await Promise.resolve();
            expect(refreshInvoices).toHaveBeenCalledWith({
                invoiceIds: [MOCK_VALID_INVOICE.Record.Id]
            });

            await Promise.resolve();
            expect(element.isModified()).toBe(false);

            await Promise.resolve();
            saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveButton"]');
            expect(saveBtn.disabled).toBe(false);
            dateInput = element.shadowRoot.querySelector('lightning-input[data-id="inputDate"]');
            expect(dateInput.classList).not.toContain('is-dirty');
        });

    });

    describe('reset', () => {

        afterEach(() => { reset(); });

        test('is not locked: all modified fields reset', () => {

            const element = createElement('c-invoice-card', {
                is: invoiceCard
            });
            element.invoice = MOCK_VALID_INVOICE;
            document.body.appendChild(element);

            let dateInput = element.shadowRoot.querySelector('lightning-input[data-id="inputDate"]');
            dateInput.value = '2019-11-14';
            dateInput.dispatchEvent(new CustomEvent('change', {detail : { value : '2019-11-14'}}));
            
            expect(element.isLocked()).toBe(false);
            element.reset();
            expect(element.getModifiedFields()).toStrictEqual({});

        });

        test('is locked: no fields reset', () => {

            const element = createElement('c-invoice-card', {
                is: invoiceCard
            });
            element.invoice = MOCK_VALID_INVOICE;
            document.body.appendChild(element);

            let dateInput = element.shadowRoot.querySelector('lightning-input[data-id="inputDate"]');
            dateInput.value = '2019-11-14';
            dateInput.dispatchEvent(new CustomEvent('change', {detail : { value : '2019-11-14'}}));

            // this will lock the invoice
            let actBtn = element.shadowRoot.querySelector('lightning-button-stateful[data-id="activateButton"]');
            actBtn.click();
            
            expect(element.isLocked()).toBe(true);
            element.reset();
            expect(element.getModifiedFields()).toStrictEqual({ Id : MOCK_VALID_INVOICE.Record.Id, Date__c : '2019-11-14', Status__c : 'Activated'});

        });

    });

    describe('status buttons', () => {

        afterEach(() => { reset(); });

        test('activate: all input elements read-only', async () => {

            commitData.mockResolvedValue({});

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
            await Promise.resolve();

            element.shadowRoot.querySelectorAll('lightning-input').forEach((input) => expect(input.disabled).toBe(true));
            element.shadowRoot.querySelectorAll('lightning-input-address').forEach((input) => expect(input.disabled).toBe(true));
            let dataTable = element.shadowRoot.querySelector('c-invoice-line-item-datatable');
            expect(dataTable.isDisabled).toBe(true);
    
        });
    
        test('cancelled: all input elements read-only', () => {
    
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
            return Promise.resolve().then(() => {
                element.shadowRoot.querySelectorAll('lightning-input').forEach ( (input) => expect(input.disabled).toBe(true));
                element.shadowRoot.querySelectorAll('lightning-input-address').forEach ( (input) => expect(input.disabled).toBe(true));
                let dataTable = element.shadowRoot.querySelector('c-invoice-line-item-datatable');
                expect(dataTable.isDisabled).toBe(true);
            });
    
        });
    });

    describe('modify data', () => {

        afterEach(() => { reset(); });
        
        test('modifications cached', () => {
            
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
    });

});