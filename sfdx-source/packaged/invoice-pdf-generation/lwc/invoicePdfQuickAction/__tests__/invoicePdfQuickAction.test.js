import { createElement } from 'lwc';
import invoicePdf from 'c/invoicePdfQuickAction';

import savePdfToInvoice from '@salesforce/apex/InvoicePdfController.savePdfToInvoice';
import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';

// create plain mocks for apex without functionality
jest.mock(
    '@salesforce/apex/InvoicePdfController.getOrganizationProfiles',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/InvoicePdfController.savePdfToInvoice',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-invoice-pdf-quick-action', () => {
    
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
    
    test('render pdf quick action: all defaults set', () => {
      
    });

});