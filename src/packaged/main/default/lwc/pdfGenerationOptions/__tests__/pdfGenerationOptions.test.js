import { createElement } from 'lwc';
import pdfOptions from 'c/pdfGenerationOptions';

const LANGUAGE_OPTIONS = require('./data/language-options.json');
const PROFILE_OPTIONS = require('./data/org-profile-options.json');
const INVOICE = require('./data/invoice.json');
const INVOICE_WITH_ORG = require('./data/invoice-with-orgprofile.json');

describe('c-pdf-generation-options', () => {

    describe('initialization', () => {
    
        afterEach(() => { reset(); });
        
        test('with empty options: successfully rendered', () => {
        
            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.languageOptions = [];
            element.orgProfileOptions = [];
            element.invoice = INVOICE;
            document.body.appendChild(element);

            let orgOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="orgProfileInput"]');
            let langOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="languageInput"]');
            let timesheetToggle = element.shadowRoot.querySelector('lightning-input');

            expect(orgOptions.options.length).toBe(0);
            expect(langOptions.options.length).toBe(0);
            expect(timesheetToggle.checked).toBe(true);
            
        });

        test('with undefined options: successfully rendered', () => {

            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.invoice = INVOICE;
            document.body.appendChild(element);

            let orgOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="orgProfileInput"]');
            let langOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="languageInput"]');

            expect(orgOptions.options.length).toBe(0);
            expect(langOptions.options.length).toBe(0);

        });
        
        test('with valid options: successfully rendered', () => {
            
            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.languageOptions = LANGUAGE_OPTIONS;
            element.orgProfileOptions = PROFILE_OPTIONS;
            element.invoice = INVOICE;
            document.body.appendChild(element);

            let orgOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="orgProfileInput"]');
            let langOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="languageInput"]');
            let timesheetToggle = element.shadowRoot.querySelector('lightning-input');

            expect(orgOptions.options.length).toBe(PROFILE_OPTIONS.length);
            expect(langOptions.options.length).toBe(LANGUAGE_OPTIONS.length);
            expect(timesheetToggle.checked).toBe(true);

        });

        test('with valid options: defaults initialized in fields', () => {

            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.languageOptions = LANGUAGE_OPTIONS;
            element.orgProfileOptions = PROFILE_OPTIONS;
            element.invoice = INVOICE;
            document.body.appendChild(element);

            let orgOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="orgProfileInput"]');
            let langOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="languageInput"]');
            let timesheetToggle = element.shadowRoot.querySelector('lightning-input');

            expect(orgOptions.value).toBe(PROFILE_OPTIONS[0].value);
            expect(langOptions.value).toBe(INVOICE.Record.PdfLanguage__c);
            expect(timesheetToggle.checked).toBe(INVOICE.Record.PdfRenderTimesheet__c);

        });

        test('invoice has org profile: select profile from invoice as option', () => {

            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.languageOptions = LANGUAGE_OPTIONS;
            element.orgProfileOptions = PROFILE_OPTIONS;
            element.invoice = INVOICE_WITH_ORG;
            document.body.appendChild(element);

            let orgOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="orgProfileInput"]');
            expect(orgOptions.value).toBe(INVOICE_WITH_ORG.Record.OrganizationProfile__c);
        });
        
    });

    describe('get selected options', () => {
    
        afterEach(() => { reset(); });
        
        test('no options selected: get defaults', () => {
        
            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.languageOptions = LANGUAGE_OPTIONS;
            element.orgProfileOptions = PROFILE_OPTIONS;
            element.invoice = INVOICE;
            document.body.appendChild(element);

            const selectedOptions = element.getSelectedOptions();

            expect(selectedOptions.recordId).toBe(INVOICE.Record.Id);
            expect(selectedOptions.profile).toBe(PROFILE_OPTIONS[0].value);
            expect(selectedOptions.language).toBe(INVOICE.Record.PdfLanguage__c);
            expect(selectedOptions.timesheet).toBe(INVOICE.Record.PdfRenderTimesheet__c);
            
        });

        test('no options available: get undefined', () => {

            let INVOICE_NO_LANG = INVOICE;
            INVOICE_NO_LANG.Record.PdfLanguage__c = undefined;

            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.languageOptions = [];
            element.orgProfileOptions = [];
            element.invoice = INVOICE_NO_LANG;
            document.body.appendChild(element);

            const selectedOptions = element.getSelectedOptions();

            expect(selectedOptions.recordId).toBe(INVOICE.Record.Id);
            expect(selectedOptions.profile).toBe(undefined);
            expect(selectedOptions.language).toBe(undefined);
            expect(selectedOptions.timesheet).toBe(INVOICE.Record.PdfRenderTimesheet__c);

        });
        
        test('has options selected: override defaults form invoice record', () => {
            
            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.languageOptions = LANGUAGE_OPTIONS;
            element.orgProfileOptions = PROFILE_OPTIONS;
            element.invoice = INVOICE;
            document.body.appendChild(element);

            let orgOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="orgProfileInput"]');
            let langOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="languageInput"]');
            let timesheetToggle = element.shadowRoot.querySelector('lightning-input');
            orgOptions.dispatchEvent(new CustomEvent('change', { detail : { value : 'a07210000055nHyAAI'}}));
            langOptions.dispatchEvent(new CustomEvent('change', { detail : { value : 'en_US'}}));
            timesheetToggle.dispatchEvent(new CustomEvent('change', { detail : { checked : false }}));

            const selectedOptions = element.getSelectedOptions();

            expect(selectedOptions.recordId).toBe(INVOICE.Record.Id);
            expect(selectedOptions.profile).toBe('a07210000055nHyAAI');
            expect(selectedOptions.language).toBe('en_US');
            expect(selectedOptions.timesheet).toBe(false);

        });
        
    });

    describe('reset component', () => {

        afterEach(() => { reset(); });

        test('call reset: original values for input fields restored', async () => {
        
            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.languageOptions = LANGUAGE_OPTIONS;
            element.orgProfileOptions = PROFILE_OPTIONS;
            element.invoice = INVOICE_WITH_ORG;
            document.body.appendChild(element);

            let orgOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="orgProfileInput"]');
            let langOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="languageInput"]');
            let timesheetToggle = element.shadowRoot.querySelector('lightning-input');
            orgOptions.value = '1234';
            langOptions.value = 'ab_CD';
            timesheetToggle.checked = false;

            element.reset();
            await Promise.resolve();

            expect(element.shadowRoot.querySelector('lightning-combobox[data-id="orgProfileInput"]').value).toBe(INVOICE_WITH_ORG.Record.OrganizationProfile__c);
            expect(element.shadowRoot.querySelector('lightning-combobox[data-id="languageInput"]').value).toBe(INVOICE_WITH_ORG.Record.PdfLanguage__c);
            expect(element.shadowRoot.querySelector('lightning-input').checked).toBe(true);
            
        });

        test('call reset: original values for internal variables restored', async () => {
        
            const element = createElement('c-pdf-generation-options', {
                is: pdfOptions 
            });
            element.languageOptions = LANGUAGE_OPTIONS;
            element.orgProfileOptions = PROFILE_OPTIONS;
            element.invoice = INVOICE_WITH_ORG;
            document.body.appendChild(element);

            let orgOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="orgProfileInput"]');
            let langOptions = element.shadowRoot.querySelector('lightning-combobox[data-id="languageInput"]');
            let timesheetToggle = element.shadowRoot.querySelector('lightning-input');
            orgOptions.value = '1234';
            langOptions.value = 'ab_CD';
            timesheetToggle.checked = false;

            element.reset();
            await Promise.resolve();

            const selectedOptions = element.getSelectedOptions();
            expect(selectedOptions.recordId).toBe(INVOICE_WITH_ORG.Record.Id);
            expect(selectedOptions.profile).toBe(INVOICE_WITH_ORG.Record.OrganizationProfile__c);
            expect(selectedOptions.language).toBe(INVOICE_WITH_ORG.Record.PdfLanguage__c);
            expect(selectedOptions.timesheet).toBe(INVOICE_WITH_ORG.Record.PdfRenderTimesheet__c);
        });

    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}