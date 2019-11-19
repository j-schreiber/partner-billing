import { createElement } from 'lwc';
import recordCard from 'c/invoiceCardRecord';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

import getInvoice from '@salesforce/apex/InvoiceController.getInvoice';
import commitInvoiceLineItems from '@salesforce/apex/InvoiceController.commitInvoiceLineItems';

const DRAFT_INVOICE = require('./data/draft-invoice.json');

jest.mock(
    '@salesforce/apex/InvoiceController.commitInvoiceLineItems',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);
const getInvoiceAdapter = registerApexTestWireAdapter(getInvoice);

const NEW_LINE_ITEM = {
    Discount__c:0,
    Invoice__c:DRAFT_INVOICE.Record.Id,
    Price__c:0,
    Quantity__c:0,
    Tax__c:0
}

describe('c-invoice-card-record', () => {

    describe('commit changes', () => {

        // reset DOM after each test
        afterEach(() => { reset(); });

        test('apex method called with cache', async () => {

            commitInvoiceLineItems.mockResolvedValue();

            const element = createElement('c-invoice-card-list', {
                is: recordCard
            });
            element.recordId = DRAFT_INVOICE.Record.Id;
            document.body.appendChild(element);

            // emit data from wire adapter & wait
            getInvoiceAdapter.emit(DRAFT_INVOICE);
            await Promise.resolve();

            let dataTable = element.shadowRoot.querySelector('c-invoice-line-item-datatable');
            dataTable.addRow();

            let commitBtn = element.shadowRoot.querySelector('lightning-button[data-id="commitChanges"]');
            commitBtn.click();
            
            expect(commitInvoiceLineItems).toHaveBeenCalled();
            expect(commitInvoiceLineItems).toHaveBeenCalledWith({
                lineItemsToDelete : [],
                lineItemsToUpsert: [
                    NEW_LINE_ITEM
                ],
                recordId: DRAFT_INVOICE.Record.Id
            });
            expect(element.getModifiedLineItems()).toStrictEqual([NEW_LINE_ITEM]);

        });

        test('cache reset after commit', async () => {

            commitInvoiceLineItems.mockResolvedValue();

            const element = createElement('c-invoice-card-list', {
                is: recordCard
            });
            element.recordId = DRAFT_INVOICE.Record.Id;
            document.body.appendChild(element);

            // emit data from wire adapter & wait
            getInvoiceAdapter.emit(DRAFT_INVOICE);
            await Promise.resolve();

            let dataTable = element.shadowRoot.querySelector('c-invoice-line-item-datatable');
            dataTable.addRow();

            let commitBtn = element.shadowRoot.querySelector('lightning-button[data-id="commitChanges"]');

            // click button first time & wait for response
            commitBtn.click();
            await Promise.resolve();
            
            // click second time
            commitBtn.click();

            expect(commitInvoiceLineItems).toHaveBeenCalledTimes(2);
            expect(commitInvoiceLineItems).toHaveBeenCalledWith({
                lineItemsToDelete : [],
                lineItemsToUpsert: [],
                recordId: DRAFT_INVOICE.Record.Id
            });
            expect(element.getModifiedLineItems()).toStrictEqual([]);

        });

    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}