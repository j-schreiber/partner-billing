import { createElement } from 'lwc';
import tableRow from 'c/invoicePdfGenTableRow';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';
import savePdfToInvoice from '@salesforce/apex/InvoicePdfController.savePdfToInvoice';
import apexDeletePdf from '@salesforce/apex/InvoicePdfController.deletePdf';

import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

const getPicklistValAdapter = registerApexTestWireAdapter(getPicklistValues);
const getOrgProfilesAdapter = registerApexTestWireAdapter(getOrganizationProfiles);

const ORG_PROFILE_OPTIONS = require('./data/org-profiles.json');
const LANG_OPTIONS = require('./data/language-options.json');
const INVOICE_NO_PDF = require('./data/invoice-without-pdf.json');
const INVOICE_PDF = require('./data/invoice-with-pdf.json');

jest.mock(
    '@salesforce/apex/InvoicePdfController.savePdfToInvoice',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/InvoicePdfController.deletePdf',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-invoice-pdf-gen-table-row', () => {

    describe('setup', () => {
    
        afterEach(() => { reset(); });
        
        test('no data: empty row rendered', () => {
        
            const element = createElement('c-my-component', {
                is: tableRow 
            });
            document.body.appendChild(element);

            getPicklistValAdapter.emit(LANG_OPTIONS);
            getOrgProfilesAdapter.emit(ORG_PROFILE_OPTIONS);

            return Promise.resolve()
            .then(() => {

            });
            
        });
        
        test('valid invoice without pdf: full row rendered', async () => {
            
            const element = createElement('c-my-component', {
                is: tableRow 
            });
            element.invoice = INVOICE_NO_PDF;
            document.body.appendChild(element);

            getPicklistValAdapter.emit(LANG_OPTIONS);
            getOrgProfilesAdapter.emit(ORG_PROFILE_OPTIONS);

            return Promise.resolve()
            .then(() => {

                let tableCells = element.shadowRoot.querySelectorAll('td');
                expect(tableCells.length).toBe(4);

            });

        });

        test('valid invoice with pdf: full row rendered', async () => {
            
            const element = createElement('c-my-component', {
                is: tableRow 
            });
            element.invoice = INVOICE_PDF;
            document.body.appendChild(element);

            getPicklistValAdapter.emit(LANG_OPTIONS);
            getOrgProfilesAdapter.emit(ORG_PROFILE_OPTIONS);

            return Promise.resolve()
            .then(() => {

                let tableCells = element.shadowRoot.querySelectorAll('td');
                expect(tableCells.length).toBe(4);

            });

        });
        
    });

    describe('generate pdf', () => {

        afterEach(() => { reset(); });

        test('no options selected: generate disabled', () => {

        });

        test('pdf exists: generate disabled', () => {

        });

        test('options selected: ', () => {

        });
    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}