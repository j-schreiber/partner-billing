import { createElement } from 'lwc';
import codeLogin from 'c/accessCodeLogin';
import validateAccessCode from '@salesforce/apex/TimeEntryApprovalController.validateAccessCode';
import getCustomerAccountData from '@salesforce/apex/TimeEntryApprovalController.getCustomerAccountData';

import ERROR_ACCOUNT_NOT_ENABLED from '@salesforce/label/c.TimeSheetApproval_Error_AccountNotEnabled';

jest.mock(
    '@salesforce/apex/TimeEntryApprovalController.validateAccessCode',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/TimeEntryApprovalController.getCustomerAccountData',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

const ENABLED_ACCOUNT = require('./data/enabled-account.json');
const DISABLED_ACCOUNT = require('./data/disabled-account.json');
const INVALID_ID_EXCEPTION = require('./data/invalid-id-exception.json');

describe('c-access-code-login', () => {

    afterEach(() => { reset(); });
    
    test('access code validation: true', async () => {
    
        validateAccessCode.mockResolvedValue(true);
    
        const element = createElement('c-access-code-login', {
            is: codeLogin 
        });
        document.body.appendChild(element);
        const mockSuccessHandler = jest.fn();
        element.addEventListener('success', mockSuccessHandler);

        let loginButton = element.shadowRoot.querySelector('lightning-button');
        let codeInput = element.shadowRoot.querySelector('c-access-code-input');
        codeInput.getAccessCode = jest.fn(() => { return 'ABC' });
        loginButton.dispatchEvent(new CustomEvent('click'));

        await Promise.resolve();

        expect(validateAccessCode).toHaveBeenCalledWith({accessCode : 'ABC'});
        expect(mockSuccessHandler).toHaveBeenCalled();
        
    });

    test('access code validation: false', async () => {
    
        validateAccessCode.mockResolvedValue(false);
    
        const element = createElement('c-access-code-login', {
            is: codeLogin 
        });
        document.body.appendChild(element);
        const mockSuccessHandler = jest.fn();
        element.addEventListener('success', mockSuccessHandler);

        let loginButton = element.shadowRoot.querySelector('lightning-button');
        let codeInput = element.shadowRoot.querySelector('c-access-code-input');
        codeInput.getAccessCode = jest.fn(() => { return 'ABC'});
        loginButton.dispatchEvent(new CustomEvent('click'));

        await Promise.resolve();

        expect(validateAccessCode).toHaveBeenCalledWith({accessCode : 'ABC'});
        expect(mockSuccessHandler).not.toHaveBeenCalled();
        
    });

    test('customer id validation: is enabled', async () => {

        getCustomerAccountData.mockResolvedValue(ENABLED_ACCOUNT);
    
        const element = createElement('c-access-code-login', {
            is: codeLogin 
        });
        document.body.appendChild(element);

        let idInput = element.shadowRoot.querySelector('input[data-id="customerNumberInput"]');
        idInput.value = '1001';
        idInput.dispatchEvent(new CustomEvent('change'));

        await Promise.resolve();
        
        let codeInput = element.shadowRoot.querySelector('c-access-code-input');
        expect(codeInput.isDisabled).toBe(false);

        let errMsg = element.shadowRoot.querySelector('p.error-message');
        expect(errMsg).toBeNull();

    });

    test('customer id validation: is disabled', async () => {

        getCustomerAccountData.mockResolvedValue(DISABLED_ACCOUNT);
    
        const element = createElement('c-access-code-login', {
            is: codeLogin 
        });
        document.body.appendChild(element);

        let idInput = element.shadowRoot.querySelector('input[data-id="customerNumberInput"]');
        idInput.value = '1001';
        idInput.dispatchEvent(new CustomEvent('change'));

        await Promise.resolve();

        let codeInput = element.shadowRoot.querySelector('c-access-code-input');
        expect(codeInput.isDisabled).toBe(true);

        let errMsg = element.shadowRoot.querySelector('p.error-message');
        expect(errMsg.textContent).toBe(ERROR_ACCOUNT_NOT_ENABLED);

    });

    test('customer id validation: is invalid id', async () => {

        getCustomerAccountData.mockRejectedValue(INVALID_ID_EXCEPTION);
    
        const element = createElement('c-access-code-login', {
            is: codeLogin 
        });
        document.body.appendChild(element);

        let idInput = element.shadowRoot.querySelector('input[data-id="customerNumberInput"]');
        idInput.value = '1234';
        idInput.dispatchEvent(new CustomEvent('change'));

        await Promise.resolve();

        let codeInput = element.shadowRoot.querySelector('c-access-code-input');
        expect(codeInput.isDisabled).toBe(true);

        let errMsg = element.shadowRoot.querySelector('p.error-message');
        expect(errMsg.textContent).toBe(INVALID_ID_EXCEPTION.body.message);

    });
        
});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}

function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise(resolve => setImmediate(resolve));
}