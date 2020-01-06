import { createElement } from 'lwc';
import codeLogin from 'c/accessCodeLogin';
import validateAccessCode from '@salesforce/apex/TimeEntryApprovalController.validateAccessCode';


jest.mock(
    '@salesforce/apex/TimeEntryApprovalController.validateAccessCode',
    () => { return { default: jest.fn() }; },
    { virtual: true }
);

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
        
});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}