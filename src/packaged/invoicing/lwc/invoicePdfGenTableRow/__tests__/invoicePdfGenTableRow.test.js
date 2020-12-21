import { createElement } from 'lwc';
import tableRow from 'c/invoicePdfGenTableRow';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';
import savePdfToInvoice from '@salesforce/apex/InvoicePdfController.savePdfToInvoice';

import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

const getPicklistValAdapter = registerApexTestWireAdapter(getPicklistValues);
const getOrgProfilesAdapter = registerApexTestWireAdapter(getOrganizationProfiles);

const ORG_PROFILE_RECORDS = require('./data/org-profile-records.json');
const LANG_OPTIONS = require('./data/language-picklist-values.json');
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

    describe('initialization', () => {
    
        afterEach(() => { reset(); });
        
        test('no data from wire: successfully rendered', () => {
        
            const element = createElement('c-my-component', {
                is: tableRow 
            });
            element.invoice = INVOICE_NO_PDF;
            document.body.appendChild(element);

            getPicklistValAdapter.emit({});
            getOrgProfilesAdapter.emit([]);

            return Promise.resolve()
            .then(() => {

                let pdfOptions = element.shadowRoot.querySelector('c-pdf-generation-options');
                expect(pdfOptions.orgProfileOptions.length).toBe(0);
                expect(pdfOptions.languageOptions.length).toBe(0);

            });
            
        });
        
        test('full data from wire: successfully rendered', () => {
            
            const element = createElement('c-my-component', {
                is: tableRow 
            });
            element.invoice = INVOICE_NO_PDF;
            document.body.appendChild(element);

            getPicklistValAdapter.emit(LANG_OPTIONS);
            getOrgProfilesAdapter.emit(ORG_PROFILE_RECORDS);

            return Promise.resolve().then(() => {
                let pdfOptions = element.shadowRoot.querySelector('c-pdf-generation-options');
                expect(pdfOptions.orgProfileOptions.length).toBe(ORG_PROFILE_RECORDS.length);
                expect(pdfOptions.languageOptions.length).toBe(LANG_OPTIONS.values.length);

                let tableCells = element.shadowRoot.querySelectorAll('td');
                expect(tableCells.length).toBe(6);
            });

        });

        test('invoice with pdf: view and delete buttons rendered', () => {
            
            const element = createElement('c-my-component', {
                is: tableRow 
            });
            element.invoice = INVOICE_PDF;
            document.body.appendChild(element);

            getPicklistValAdapter.emit({});
            getOrgProfilesAdapter.emit([]);

            const viewButton = element.shadowRoot.querySelector('lightning-button[data-id="viewPdfButton"]');
            expect(viewButton).not.toBeNull();

            const delButton = element.shadowRoot.querySelector('lightning-button[data-id="deletePdfButton"]');
            expect(delButton).not.toBeNull();

            const genButton = element.shadowRoot.querySelector('lightning-button[data-id="generatePdfButton"]');
            expect(genButton).toBeNull();

        });

        test('invoice without pdf: generate button rendered', () => {
            
            const element = createElement('c-my-component', {
                is: tableRow 
            });
            element.invoice = INVOICE_NO_PDF;
            document.body.appendChild(element);

            getPicklistValAdapter.emit({});
            getOrgProfilesAdapter.emit([]);

            const viewButton = element.shadowRoot.querySelector('lightning-button[data-id="viewPdfButton"]');
            expect(viewButton).toBeNull();

            const delButton = element.shadowRoot.querySelector('lightning-button[data-id="deletePdfButton"]');
            expect(delButton).toBeNull();

            const genButton = element.shadowRoot.querySelector('lightning-button[data-id="generatePdfButton"]');
            expect(genButton).not.toBeNull();

        });
        
    });

    describe('generate pdf', () => {

        afterEach(() => { reset(); });

        test('no options selected: apex called without values', () => {

            const MOCK_OPTIONS = {
                recordId : '1',
                timesheet : false
            }

            savePdfToInvoice.mockResolvedValue({ContentDocumentId : '06921000000VW05AAG', Id : '1'});

            const element = createElement('c-my-component', {
                is: tableRow 
            });
            element.invoice = INVOICE_NO_PDF;
            document.body.appendChild(element);

            getPicklistValAdapter.emit({});
            getOrgProfilesAdapter.emit([]);

            return Promise.resolve().then(() => {
                let pdfOptions = element.shadowRoot.querySelector('c-pdf-generation-options');
                pdfOptions.getSelectedOptions = jest.fn(() => { return MOCK_OPTIONS; });

                const genButton = element.shadowRoot.querySelector('lightning-button[data-id="generatePdfButton"]');
                genButton.click();

                expect(savePdfToInvoice).toHaveBeenCalledWith({
                    invoiceId : MOCK_OPTIONS.recordId,
                    displayTimesheet : MOCK_OPTIONS.timesheet
                });
            });
        });

        test('all options selected: apex called with values', () => {

            const MOCK_OPTIONS = {
                recordId : '1',
                timesheet : false,
                profile : 'a07210000055nHyAAI',
                language : 'de_DE'
            }

            savePdfToInvoice.mockResolvedValue({ContentDocumentId : '06921000000VW05AAG', Id : '1'});

            const element = createElement('c-my-component', {
                is: tableRow 
            });
            element.invoice = INVOICE_NO_PDF;
            document.body.appendChild(element);

            getPicklistValAdapter.emit({});
            getOrgProfilesAdapter.emit([]);

            return Promise.resolve().then(() => {
                let pdfOptions = element.shadowRoot.querySelector('c-pdf-generation-options');
                pdfOptions.getSelectedOptions = jest.fn(() => { return MOCK_OPTIONS; });

                const genButton = element.shadowRoot.querySelector('lightning-button[data-id="generatePdfButton"]');
                genButton.click();

                expect(savePdfToInvoice).toHaveBeenCalledWith({
                    invoiceId : MOCK_OPTIONS.recordId,
                    displayTimesheet : MOCK_OPTIONS.timesheet,
                    orgProfileId : MOCK_OPTIONS.profile,
                    renderLanguage : MOCK_OPTIONS.language
                });
            });
        });
    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}