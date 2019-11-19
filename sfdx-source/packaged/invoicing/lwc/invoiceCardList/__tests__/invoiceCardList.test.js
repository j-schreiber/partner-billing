import { createElement } from 'lwc';
import cardList from 'c/invoiceCardList';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import getInvoices from '@salesforce/apex/BillingController.getInvoices';

import MESSAGE_NO_RECORDS from '@salesforce/label/c.Message_Invoicing_DraftInvoicesCompleted';

const DRAFT_INVOICES = require('./data/draft-invoices.json');
const EMPTY_LIST = require('./data/empty-list.json');

const getInvoicesAdapter = registerApexTestWireAdapter(getInvoices);

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

        test('success without data', async () => {

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

        test('error', async () => {

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

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}