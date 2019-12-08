import { createElement } from 'lwc';
import pdfGenOptions from 'c/pdfGenerationRecordPageOptions';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';

const GET_RECORD_ADAPTER = registerApexTestWireAdapter(getRecord);
const GET_PICKLISTVALUES_ADAPTER = registerApexTestWireAdapter(getPicklistValues);
const GET_ORGPROFILES_ADAPTER = registerApexTestWireAdapter(getOrganizationProfiles);

const INVOICE_FULL = require('./data/invoice-full.json');
const ORG_PROFILE_RECORDS = require('./data/org-profile-records.json');
const LANGUAGE_OPTIONS = require('./data/language-options.json');
//const PDF_SETTING_OPTIONS = require('./data/pdf-settings-options.json');

describe('c-pdf-generation-record-page-options', () => {

    describe('get wired data', () => {
    
        afterEach(() => { reset(); });
        
        test('no data emmited: options not displayed', () => {
            const element = createElement('c-pdf-generation-record-page-options', {
                is: pdfGenOptions 
            });
            element.recordId = INVOICE_FULL.id;
            document.body.appendChild(element);
            expect(element.isLoaded).toBe(false);
        });

        test('full valid invoice: all options initialized from invoice', () => {
        
            const element = createElement('c-pdf-generation-record-page-options', {
                is: pdfGenOptions 
            });
            element.recordId = INVOICE_FULL.id;
            document.body.appendChild(element);

            GET_RECORD_ADAPTER.emit(INVOICE_FULL);
            GET_ORGPROFILES_ADAPTER.emit(ORG_PROFILE_RECORDS);
            GET_PICKLISTVALUES_ADAPTER.emit(LANGUAGE_OPTIONS);

            expect(element.isLoaded).toBe(true);
            
        });
        
    });

    describe('select pdf render setting', () => {

        afterEach(() => { reset(); });

        test('user selection: record updated', async () => {

            const element = createElement('c-pdf-generation-record-page-options', {
                is: pdfGenOptions 
            });
            element.recordId = INVOICE_FULL.id;
            document.body.appendChild(element);

            let pdfSettingsPicklist = element.shadowRoot.querySelector('lightning-combobox[data-id="pdfSettingsInput"]');
            pdfSettingsPicklist.dispatchEvent(new CustomEvent('change', { detail : { value : 'Sync' }}));

            await Promise.resolve();
            expect(updateRecord).toHaveBeenCalledWith({ fields : { Id : INVOICE_FULL.id, PDFSyncSetting__c : 'Sync'}});
        });

        test('user selected sync: pdf options rendered', async () => {

            const element = createElement('c-pdf-generation-record-page-options', {
                is: pdfGenOptions 
            });
            element.recordId = INVOICE_FULL.id;
            GET_RECORD_ADAPTER.emit(INVOICE_FULL);
            GET_ORGPROFILES_ADAPTER.emit(ORG_PROFILE_RECORDS);
            GET_PICKLISTVALUES_ADAPTER.emit(LANGUAGE_OPTIONS);
            document.body.appendChild(element);

            let pdfSettingsPicklist = element.shadowRoot.querySelector('lightning-combobox[data-id="pdfSettingsInput"]');
            pdfSettingsPicklist.dispatchEvent(new CustomEvent('change', { detail : { value : 'Sync' }}));

            await Promise.resolve();

            let pdfOptions = element.shadowRoot.querySelector('c-pdf-generation-options');
            expect(pdfOptions).not.toBeNull();

            let msgBox = element.shadowRoot.querySelector('c-message-box');
            expect(msgBox.variant).toBe('success');
        });

        test('user selected delete: warning box rendered', async () => {

            const element = createElement('c-pdf-generation-record-page-options', {
                is: pdfGenOptions 
            });
            element.recordId = INVOICE_FULL.id;
            GET_RECORD_ADAPTER.emit(INVOICE_FULL);
            GET_ORGPROFILES_ADAPTER.emit(ORG_PROFILE_RECORDS);
            GET_PICKLISTVALUES_ADAPTER.emit(LANGUAGE_OPTIONS);
            document.body.appendChild(element);

            let pdfSettingsPicklist = element.shadowRoot.querySelector('lightning-combobox[data-id="pdfSettingsInput"]');
            pdfSettingsPicklist.dispatchEvent(new CustomEvent('change', { detail : { value : 'Delete' }}));

            await Promise.resolve();

            let pdfOptions = element.shadowRoot.querySelector('c-pdf-generation-options');
            expect(pdfOptions).toBeNull();

            let msgBox = element.shadowRoot.querySelector('c-message-box');
            expect(msgBox.variant).toBe('warning');
        });

        test('user selected deactivated: noting rendered', async () => {

            const element = createElement('c-pdf-generation-record-page-options', {
                is: pdfGenOptions 
            });
            element.recordId = INVOICE_FULL.id;
            GET_RECORD_ADAPTER.emit(INVOICE_FULL);
            GET_ORGPROFILES_ADAPTER.emit(ORG_PROFILE_RECORDS);
            GET_PICKLISTVALUES_ADAPTER.emit(LANGUAGE_OPTIONS);
            document.body.appendChild(element);

            let pdfSettingsPicklist = element.shadowRoot.querySelector('lightning-combobox[data-id="pdfSettingsInput"]');
            pdfSettingsPicklist.dispatchEvent(new CustomEvent('change', { detail : { value : 'Deactivated' }}));

            await Promise.resolve();

            let pdfOptions = element.shadowRoot.querySelector('c-pdf-generation-options');
            expect(pdfOptions).toBeNull();

            let msgBox = element.shadowRoot.querySelector('c-message-box');
            expect(msgBox).toBeNull();
        });

    });

    describe('select pdf option', () => {

        afterEach(() => { reset(); });

        test('select org profile: record updated with all options', async () => {

            const SELECTED_OPTIONS = {
                recordId : INVOICE_FULL.id,
                profile : '1234',
                language : 'en_US',
                timesheet : true
            }

            const element = createElement('c-pdf-generation-record-page-options', {
                is: pdfGenOptions 
            });
            element.recordId = INVOICE_FULL.id;
            GET_RECORD_ADAPTER.emit(INVOICE_FULL);
            GET_ORGPROFILES_ADAPTER.emit(ORG_PROFILE_RECORDS);
            GET_PICKLISTVALUES_ADAPTER.emit(LANGUAGE_OPTIONS);
            document.body.appendChild(element);

            let pdfSettingsPicklist = element.shadowRoot.querySelector('lightning-combobox[data-id="pdfSettingsInput"]');
            pdfSettingsPicklist.dispatchEvent(new CustomEvent('change', { detail : { value : 'Sync' }}));

            await Promise.resolve();

            let pdfOptions = element.shadowRoot.querySelector('c-pdf-generation-options');
            pdfOptions.dispatchEvent(new CustomEvent('optionchange', { detail : SELECTED_OPTIONS }));

            await Promise.resolve();
            expect(updateRecord).toHaveBeenLastCalledWith({ fields : {
                Id : SELECTED_OPTIONS.recordId,
                OrganizationProfile__c : '1234',
                PdfLanguage__c : 'en_US',
                PdfRenderTimesheet__c : true
            }});
        });
    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}