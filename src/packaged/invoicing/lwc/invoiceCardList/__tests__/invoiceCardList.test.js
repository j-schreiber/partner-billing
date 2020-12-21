import { createElement } from 'lwc';
import cardList from 'c/invoiceCardList';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import commitData from '@salesforce/apex/BillingController.commitInvoiceEditData';

import MESSAGE_NO_RECORDS from '@salesforce/label/c.Message_Invoicing_DraftInvoicesCompleted';

const DRAFT_INVOICES = require('./data/draft-invoices.json');
const EMPTY_LIST = require('./data/empty-list.json');

const getInvoicesAdapter = registerApexTestWireAdapter(getInvoices);

jest.mock(
    '@salesforce/apex/BillingController.commitInvoiceEditData',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

describe('c-invoice-card-list', () => {

    describe('retrieve data from wire', () => {

        // reset DOM after each test
        afterEach(() => { reset(); });

        test('success with data', async () => {

            const element = createElement('c-invoice-card-list', {
                is: cardList
            });
            document.body.appendChild(element);

            // emit data from wire adapter
            getInvoicesAdapter.emit(DRAFT_INVOICES);

            await Promise.resolve();

            let invoiceCards = element.shadowRoot.querySelectorAll('c-invoice-card');
            expect(invoiceCards.length).toBe(DRAFT_INVOICES.length);

            let msgBoxes = element.shadowRoot.querySelectorAll('c-message-box');
            expect(msgBoxes.length).toBe(0);

        });

        test('success without data: display warning box', async () => {

            const element = createElement('c-invoice-card-list', {
                is: cardList
            });
            document.body.appendChild(element);

            // emit data from wire adapter
            getInvoicesAdapter.emit(EMPTY_LIST);

            await Promise.resolve();
            
            let invoiceCards = element.shadowRoot.querySelectorAll('c-invoice-card');
            expect(invoiceCards.length).toBe(0);

            let msgBoxes = element.shadowRoot.querySelectorAll('c-message-box');
            expect(msgBoxes.length).toBe(1);
            expect(msgBoxes[0].variant).toBe('success');
            expect(msgBoxes[0].message).toBe(MESSAGE_NO_RECORDS);

        });

        test('error: display error box', async () => {

            const element = createElement('c-invoice-card-list', {
                is: cardList
            });
            document.body.appendChild(element);

            // emit data from wire adapter
            getInvoicesAdapter.error();

            await Promise.resolve();
            let invoiceCards = element.shadowRoot.querySelectorAll('c-invoice-card');
            expect(invoiceCards.length).toBe(0);
            
            let msgBoxes = element.shadowRoot.querySelectorAll('c-message-box');
            expect(msgBoxes.length).toBe(1);
            expect(msgBoxes[0].variant).toBe('error');

        });
    });

    describe('commit all changes', () => {

        afterEach(() => { reset(); });

        test('commit without cached changes: apex called with empty data', async () => {

            commitData.mockResolvedValue();

            const element = createElement('c-invoice-card-list', {
                is: cardList
            });
            document.body.appendChild(element);
            getInvoicesAdapter.emit(DRAFT_INVOICES);

            await Promise.resolve();

            let commitBtn = element.shadowRoot.querySelector('lightning-button[data-id="commitAllChangesButton"]');
            commitBtn.click();

            expect(commitData).toHaveBeenCalledWith({
                invoices : [],
                deleteLineItemIds : [],
                upsertLineItems : []
            });

        });

        test('commit with cached changes on invoice: apex called', async () => {

            commitData.mockResolvedValue();

            const MOCK_MODS = {
                Id : '1',
                Status__c : 'Activated',
                Date__c : '2019-11-29'
            }

            const element = createElement('c-invoice-card-list', {
                is: cardList
            });
            document.body.appendChild(element);
            getInvoicesAdapter.emit(DRAFT_INVOICES);

            await Promise.resolve();
            
            // mock modifications in invoice card
            let invoiceCards = element.shadowRoot.querySelectorAll('c-invoice-card');
            invoiceCards[0].getModifiedFields = jest.fn().mockReturnValue(MOCK_MODS);

            let commitBtn = element.shadowRoot.querySelector('lightning-button[data-id="commitAllChangesButton"]');
            commitBtn.click();

            expect(commitData).toHaveBeenCalledWith({
                invoices : [MOCK_MODS],
                deleteLineItemIds : [],
                upsertLineItems : []
            });
        });

        test('commit with cached changes on non-activated invoice: reset called after commit', async () => {

            commitData.mockResolvedValue();

            const MOCK_MODS = {
                Id : '1',
                Status__c : 'Activated'
            }

            const element = createElement('c-invoice-card-list', {
                is: cardList
            });
            document.body.appendChild(element);
            getInvoicesAdapter.emit(DRAFT_INVOICES);

            await Promise.resolve();
            
            // mock modifications in invoice card
            let invoiceCards = element.shadowRoot.querySelectorAll('c-invoice-card');
            invoiceCards.forEach ((card) => { card.reset = jest.fn(); });
            invoiceCards[0].isLocked = jest.fn().mockReturnValue(true);
            invoiceCards[1].isLocked = jest.fn().mockReturnValue(false);
            invoiceCards[0].getModifiedFields = jest.fn().mockReturnValue(MOCK_MODS);

            let commitBtn = element.shadowRoot.querySelector('lightning-button[data-id="commitAllChangesButton"]');
            commitBtn.click();

            expect(commitData).toHaveBeenCalledWith({
                invoices : [MOCK_MODS],
                deleteLineItemIds : [],
                upsertLineItems : []
            });
            
            await Promise.resolve();

            expect(invoiceCards[0].isLocked).toHaveBeenCalled();
            expect(invoiceCards[0].reset).not.toHaveBeenCalled();
            
            expect(invoiceCards[1].isLocked).toHaveBeenCalled();
            expect(invoiceCards[1].reset).toHaveBeenCalled();
            

        });

    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}