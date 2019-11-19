import { createElement } from 'lwc';
import pdfGenTable from 'c/invoicePdfGenTable';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

const getInvoicesAdapter = registerApexTestWireAdapter(getInvoices);
const getOrgProfilesAdapter = registerApexTestWireAdapter(getOrganizationProfiles);
const getLanguageOptionsAdapter = registerApexTestWireAdapter(getPicklistValues);

const ACTIVATED_INVOICES = require('./data/activated-invoices.json');
const EMPTY_LIST = require('./data/empty-list.json');

describe('c-invoice-pdf-gen-table', () => {

    describe('get wired data', () => {

        afterEach(() => { reset(); });

        test('success with data: table rendered', async () => {

            const element = createElement('c-invoice-pdf-gen-table', {
                is: pdfGenTable 
            });
            document.body.appendChild(element);

            getInvoicesAdapter.emit(ACTIVATED_INVOICES);
            getOrgProfilesAdapter.emit([]);
            getLanguageOptionsAdapter.emit([]);
            await Promise.resolve();

            let msgBoxes = element.shadowRoot.querySelectorAll('c-message-box');
            expect(msgBoxes.length).toBe(0);

            let rows = element.shadowRoot.querySelectorAll('c-invoice-pdf-gen-table-row');
            expect(rows.length).toBe(ACTIVATED_INVOICES.length);


        });

        test('success without data: table empty and warning message box', async () => {

            const element = createElement('c-invoice-pdf-gen-table', {
                is: pdfGenTable 
            });
            document.body.appendChild(element);

            getInvoicesAdapter.emit(EMPTY_LIST);
            await Promise.resolve();

            let msgBoxes = element.shadowRoot.querySelectorAll('c-message-box');
            expect(msgBoxes.length).toBe(1);
            expect(msgBoxes[0].variant).toBe('warning');

            let rows = element.shadowRoot.querySelectorAll('c-invoice-pdf-gen-table-row');
            expect(rows.length).toBe(0);

        });

        test('error without data: no table and error message box', async () => {

            const element = createElement('c-invoice-pdf-gen-table', {
                is: pdfGenTable 
            });
            document.body.appendChild(element);

            getInvoicesAdapter.error();
            await Promise.resolve();

            let msgBoxes = element.shadowRoot.querySelectorAll('c-message-box');
            expect(msgBoxes.length).toBe(1);
            expect(msgBoxes[0].variant).toBe('error');
        });

    });

    describe('mass actions', () => {

        afterEach(() => { reset(); });

        test('create pdfs for all', async () => {

            const element = createElement('c-invoice-pdf-gen-table', {
                is: pdfGenTable 
            });
            document.body.appendChild(element);

            getInvoicesAdapter.emit(ACTIVATED_INVOICES);
            getOrgProfilesAdapter.emit([]);
            getLanguageOptionsAdapter.emit([]);
            await Promise.resolve();

            let rows = element.shadowRoot.querySelectorAll('c-invoice-pdf-gen-table-row');
            const CreatePdfMock = jest.fn();
            rows.forEach((row) => {row.createPdf = CreatePdfMock});

            let createPdfsBtn = element.shadowRoot.querySelector('lightning-button[data-id="createAllPdfs"]');
            createPdfsBtn.click();

            expect(CreatePdfMock).toHaveBeenCalledTimes(ACTIVATED_INVOICES.length);

        });

        test ('refresh data', () => {

        });

    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}