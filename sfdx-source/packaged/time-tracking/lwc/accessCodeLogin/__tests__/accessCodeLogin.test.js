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
const INVALID_ACCESS_CODE_EXCEPTION = require('./data/invalid-access-code-exception.json');

describe('c-access-code-login', () => {

    describe('access code validation', () => {

        afterEach(() => { reset(); });

        test('login clicked with no valid customer id => no callout', async () => {
    
            validateAccessCode.mockResolvedValue(true);
        
            const element = createElement('c-access-code-login', {
                is: codeLogin 
            });
            document.body.appendChild(element);
    
            let loginButton = element.shadowRoot.querySelector('lightning-button');
            loginButton.dispatchEvent(new CustomEvent('click'));
    
            await Promise.resolve();
    
            expect(validateAccessCode).not.toHaveBeenCalled();
            
        });

        test('login clicked with enabled customer for valid access code => success dispatched', async () => {
    
            validateAccessCode.mockResolvedValue(true);
            getCustomerAccountData.mockResolvedValue(ENABLED_ACCOUNT);
        
            const element = createElement('c-access-code-login', {
                is: codeLogin 
            });
            document.body.appendChild(element);
            const mockSuccessHandler = jest.fn();
            element.addEventListener('success', mockSuccessHandler);
    
            // valid customer id
            let idInput = element.shadowRoot.querySelector('input[data-id="customerNumberInput"]');
            idInput.value = '1001';
            idInput.dispatchEvent(new CustomEvent('change'));
            await Promise.resolve();
    
            let loginButton = element.shadowRoot.querySelector('lightning-button');
            let codeInput = element.shadowRoot.querySelector('c-access-code-input');
            codeInput.getAccessCode = jest.fn(() => { return 'ABC' });
            loginButton.dispatchEvent(new CustomEvent('click'));
    
            await Promise.resolve();
    
            expect(validateAccessCode).toHaveBeenCalledWith({accessCode : 'ABC'});
            expect(mockSuccessHandler).toHaveBeenCalled();
            
        });

        test('login clicked with enabled customer for invalid access code => error displayed', async () => {
    
            validateAccessCode.mockRejectedValue(INVALID_ACCESS_CODE_EXCEPTION);
            getCustomerAccountData.mockResolvedValue(ENABLED_ACCOUNT);

            const element = createElement('c-access-code-login', {
                is: codeLogin 
            });
            document.body.appendChild(element);
            const mockSuccessHandler = jest.fn();
            element.addEventListener('success', mockSuccessHandler);

            // customer id
            let idInput = element.shadowRoot.querySelector('input[data-id="customerNumberInput"]');
            idInput.value = '1001';
            idInput.dispatchEvent(new CustomEvent('change'));
            await Promise.resolve();
    
            let loginButton = element.shadowRoot.querySelector('lightning-button');
            let codeInput = element.shadowRoot.querySelector('c-access-code-input');
            codeInput.getAccessCode = jest.fn(() => { return 'ABC'});
            loginButton.dispatchEvent(new CustomEvent('click'));
    
            await Promise.resolve();
    
            expect(validateAccessCode).toHaveBeenCalledWith({accessCode : 'ABC'});
            expect(mockSuccessHandler).not.toHaveBeenCalled();

            let errMsg = element.shadowRoot.querySelector('p.error-message');
            expect(errMsg.textContent).toBe(INVALID_ACCESS_CODE_EXCEPTION.body.message);
            
        });

    });

    describe('customer id validation', () => {

        afterEach(() => { reset(); });

        test('is called with id for enabled account: activate access code input', async () => {

            getCustomerAccountData.mockResolvedValue(ENABLED_ACCOUNT);
        
            const element = createElement('c-access-code-login', {
                is: codeLogin 
            });
            document.body.appendChild(element);
    
            let idInput = element.shadowRoot.querySelector('input[data-id="customerNumberInput"]');
            idInput.value = '1001';
            idInput.dispatchEvent(new CustomEvent('change'));
    
            await Promise.resolve();

            expect(getCustomerAccountData).toHaveBeenCalledWith({customerId : '1001'});

            let codeInput = element.shadowRoot.querySelector('c-access-code-input');
            expect(codeInput.isDisabled).toBe(false);

            let errMsg = element.shadowRoot.querySelector('p.error-message');
            expect(errMsg).toBeNull();
    
        });
    
        test('is called with id for disabled account: disable access code input', async () => {
    
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
    
        test('is called with invalid id: disable access code input', async () => {
    
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
        
});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}