import { createElement } from 'lwc';
import myComponent from 'c/customerIdCreate';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getLatestCustomerId from '@salesforce/apex/AccountController.getLatestCustomerId';

import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

import ERROR_DUPLICATE from '@salesforce/label/c.Message_CustomerIdGeneration_Duplicate';

const getRecordWireAdapter = registerLdsTestWireAdapter(getRecord);

const ACCOUNT_WITH_ID = require('./data/account-with-id.json');
const ACCOUNT_WITHOUT_ID = require('./data/account-without-id.json');
const DUPLICATE_ERROR = require('./data/duplicate-error-message.json');

jest.mock(
    '@salesforce/apex/AccountController.getLatestCustomerId',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

describe('c-customer-id-create', () => {

    describe('initialization', () => {
    
        afterEach(() => { reset(); });
        
        test('record without customer id: functionality enabled', () => {
        
            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            element.recordId = '0011D00000epwpNQAQ';
            document.body.appendChild(element);

            getRecordWireAdapter.emit(ACCOUNT_WITHOUT_ID);

            return Promise.resolve().then(() => {
                let inputField = element.shadowRoot.querySelector('lightning-input');
                expect(inputField.value).toBeUndefined();
                expect(inputField.disabled).toBe(false);

                let createBtn = element.shadowRoot.querySelector('lightning-button[data-id="createNewIdButton"]');
                expect(createBtn.disabled).toBe(false);
            });
            
        });

        test('record with customer id: functionality disabled', () => {
        
            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            document.body.appendChild(element);

            getRecordWireAdapter.emit(ACCOUNT_WITH_ID);
            
            return Promise.resolve().then(() => {
                let inputField = element.shadowRoot.querySelector('lightning-input');
                expect(inputField.value).toBe(1001);
                expect(inputField.disabled).toBe(true);

                let createBtn = element.shadowRoot.querySelector('lightning-button[data-id="createNewIdButton"]');
                expect(createBtn).toBeNull();
            });

        });
        
    });

    describe('create new id', () => {
    
        afterEach(() => { reset(); });
        
        test('generate id button click: one increment above last id', () => {
            
            getLatestCustomerId.mockResolvedValue(1234);
            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            document.body.appendChild(element);

            getRecordWireAdapter.emit(ACCOUNT_WITHOUT_ID);

            return Promise.resolve().then(() => {
                element.shadowRoot.querySelector('lightning-button[data-id="createNewIdButton"]').click();
                expect(getLatestCustomerId).toHaveBeenCalled();
                return Promise.resolve();
            })
            .then(() => {
                let inputField = element.shadowRoot.querySelector('lightning-input');
                expect(inputField.value).toBe(1235);
                expect(inputField.disabled).toBe(false);

                let createBtn = element.shadowRoot.querySelector('lightning-button[data-id="createNewIdButton"]');
                expect(createBtn).not.toBeNull();

                let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]');
                expect(saveBtn).not.toBeNull();
            });
            
        });

        test('manually enter valid id: save button appears', () => {
        
            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            document.body.appendChild(element);

            let inputField = element.shadowRoot.querySelector('lightning-input');
            inputField.checkValidity = jest.fn(() => { return true; });
            inputField.dispatchEvent(new CustomEvent('change', { detail : { value : '1005' }}));

            return Promise.resolve().then(() => {
                let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]');
                expect(saveBtn).not.toBeNull();
            });
            
        });

        test('manually enter invalid id: value reset to undefined', () => {
        
            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            document.body.appendChild(element);

            let inputField = element.shadowRoot.querySelector('lightning-input');

            // mock validity checker: returnes true for first change and false for second
            inputField.checkValidity = jest.fn()
                .mockReturnValueOnce(true)
                .mockReturnValueOnce(false);

            inputField.dispatchEvent(new CustomEvent('change', { detail : { value : '1005' }}));
            inputField.dispatchEvent(new CustomEvent('change', { detail : { value : '100' }}));
            expect(element.CustomerId).toBeUndefined();

            return Promise.resolve().then(() => {
                let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]');
                expect(saveBtn).toBeNull();
            });
            
        });
        
    });

    describe('save new id', () => {

        afterEach(() => { reset(); });

        test('save with generated id: update record called with generated id', () => {
            
            getLatestCustomerId.mockResolvedValue(1234);
            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            element.recordId = '0011D00000epwpNQAQ';
            document.body.appendChild(element);
            getRecordWireAdapter.emit(ACCOUNT_WITHOUT_ID);
            
            return Promise.resolve().then(() => {
                // get new customer id
                element.shadowRoot.querySelector('lightning-button[data-id="createNewIdButton"]').click();
                return Promise.resolve();
            })
            .then(() => {
                // get save button and click
                element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]').click();
                expect(updateRecord).toHaveBeenCalled();
                expect(updateRecord).toHaveBeenCalledWith({ fields: { CustomerId__c: "1235", Id : '0011D00000epwpNQAQ'}});
            });
            
        });

        test('save with custom id: updated record called with custom id', () => {

            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            element.recordId = '0011D00000epwpNQAQ';
            document.body.appendChild(element);

            let inputField = element.shadowRoot.querySelector('lightning-input');

            // mock validity checker: returnes true for first change and false for second
            inputField.checkValidity = jest.fn().mockReturnValue(true)
            inputField.dispatchEvent(new CustomEvent('change', { detail : { value : '1005' }}));

            return Promise.resolve().then(() => {
                // click save button
                element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]').click();
                expect(updateRecord).toHaveBeenCalled();
                expect(updateRecord).toHaveBeenCalledWith({ fields: { CustomerId__c: "1005", Id : '0011D00000epwpNQAQ'}});
            });
        });

        test('save button click: button disabled after commit', () => {

            getLatestCustomerId.mockResolvedValue(167);
            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            element.recordId = '0011D00000epwpNQAQ';
            document.body.appendChild(element);
            getRecordWireAdapter.emit(ACCOUNT_WITHOUT_ID);
            
            return Promise.resolve().then(() => {
                // get new customer id
                element.shadowRoot.querySelector('lightning-button[data-id="createNewIdButton"]').click();
                return Promise.resolve();
            })
            .then(() => {
                // get save button and click
                let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]');
                expect(saveBtn.disabled).toBe(false);
                saveBtn.click();
                // resolve async updateRecord
                return Promise.resolve();
            })
            .then(() => {
                // emit new data from get record, now with id
                getRecordWireAdapter.emit(ACCOUNT_WITH_ID);
                // resolve async getRecord
                return Promise.resolve();
            })
            .then(() => { 
                // buttones disappeared because of successful save
                expect(element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]')).toBeNull();
                expect(element.shadowRoot.querySelector('lightning-button[data-id="createNewIdButton"]')).toBeNull();
                expect(element.shadowRoot.querySelector('lightning-input').disabled).toBe(true);
            });
        });

        test('save with invalid duplicate id: error displayed on field', () => {

            const SET_VALIDITY_MOCK = jest.fn();
            updateRecord.mockRejectedValue(DUPLICATE_ERROR);

            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            element.recordId = '0011D00000epwpNQAQ';
            document.body.appendChild(element);

            // mock validity checker: returnes true
            let inputField = element.shadowRoot.querySelector('lightning-input');
            inputField.checkValidity = jest.fn().mockReturnValue(true);
            inputField.setCustomValidity = SET_VALIDITY_MOCK;
            inputField.dispatchEvent(new CustomEvent('change', { detail : { value : '1005' }}));

            return Promise.resolve().then(() => {
                element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]').click();
                expect(updateRecord).toHaveBeenCalled();
                return Promise.resolve();
            })
            .then(() => {
                expect(SET_VALIDITY_MOCK).toHaveBeenCalledWith(ERROR_DUPLICATE);
            });
        });

        test('save with invalid duplicate id: invalid id stored after field updates', () => {

            updateRecord.mockRejectedValue(DUPLICATE_ERROR);

            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            element.recordId = '0011D00000epwpNQAQ';
            document.body.appendChild(element);

            // mock validity checker: returnes true
            let inputField = element.shadowRoot.querySelector('lightning-input');
            inputField.checkValidity = jest.fn().mockReturnValue(true);
            inputField.setCustomValidity = jest.fn();
            inputField.dispatchEvent(new CustomEvent('change', { detail : { value : '1005' }}));

            return Promise.resolve().then(() => {
                element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]').click();
                expect(updateRecord).toHaveBeenCalled();
                return Promise.resolve();
            })
            .then(() => {
                // this will clear the custom error message
                inputField.dispatchEvent(new CustomEvent('change', { detail : { value : '1000' }}));
                expect(inputField.setCustomValidity).toHaveBeenLastCalledWith('');
                // this will add the original duplicate error message again
                inputField.dispatchEvent(new CustomEvent('change', { detail : { value : '1005' }}));
                expect(inputField.setCustomValidity).toHaveBeenLastCalledWith(ERROR_DUPLICATE);
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