import { createElement } from 'lwc';
import myComponent from 'c/customerIdCreate';
import { getRecord } from 'lightning/uiRecordApi';
import getLatestCustomerId from '@salesforce/apex/AccountController.getLatestCustomerId';

import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

const getRecordWireAdapter = registerLdsTestWireAdapter(getRecord);

const ACCOUNT_WITH_ID = require('./data/account-with-id.json');
const ACCOUNT_WITHOUT_ID = require('./data/account-without-id.json');

jest.mock(
    '@salesforce/apex/AccountController.getLatestCustomerId',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-customer-id-create', () => {

    describe('initialization', () => {
    
        afterEach(() => { reset(); });
        
        test('record without customer id: functionality enabled', () => {
        
            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
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
                expect(inputField.value).toBe('1001');
                expect(inputField.disabled).toBe(true);

                let createBtn = element.shadowRoot.querySelector('lightning-button[data-id="createNewIdButton"]');
                expect(createBtn).toBeNull();
            });

        });
        
    });

    describe('create new id', () => {
    
        afterEach(() => { reset(); });
        
        test('create id button click: one increment above last id', () => {
            
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
                expect(inputField.disabled).toBe(true);

                let createBtn = element.shadowRoot.querySelector('lightning-button[data-id="createNewIdButton"]');
                expect(createBtn).toBeNull();

                let saveBtn = element.shadowRoot.querySelector('lightning-button[data-id="saveNewIdButton"]');
                expect(saveBtn).not.toBeNull();
            });
            
        });

        test('id create request: functionality disabled after id', () => {
        
            const element = createElement('c-customer-id-create', {
                is: myComponent 
            });
            document.body.appendChild(element);
            
        });
        
    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}