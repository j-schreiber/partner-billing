import { createElement } from 'lwc';
import cardList from 'c/invoiceCardList';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import getInvoices from '@salesforce/apex/BillingController.getInvoices';

const MOCK_WIRE_SUCCESS = require('./data/invoiceList.json');
const getInvoicesAdapter = registerApexTestWireAdapter(getInvoices);

describe('c-invoice-card-list', () => {

    // reset DOM after each test
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    test('render list: data from wire', () => {

        const element = createElement('c-invoice-card-list', {
            is: cardList
        });
        document.body.appendChild(element);

        // emit data from wire adapter
        getInvoicesAdapter.emit(MOCK_WIRE_SUCCESS);

        return Promise.resolve().then(() => {
            let invoiceCards = element.shadowRoot.querySelectorAll('c-invoice-card');
            expect(invoiceCards.length).toBe(1);

            let wireError = element.shadowRoot.querySelector('c-message-box');
            expect(wireError).toBeNull();
        });

    });

    test('render list: error from wire', () => {

        const element = createElement('c-invoice-card-list', {
            is: cardList
        });
        document.body.appendChild(element);

        // emit data from wire adapter
        getInvoicesAdapter.error();

        return Promise.resolve().then(() => {
            let invoiceCards = element.shadowRoot.querySelectorAll('c-invoice-card');
            expect(invoiceCards.length).toBe(0);

            let wireError = element.shadowRoot.querySelector('c-message-box');
            expect(wireError).not.toBeNull();
        });
    });

});
