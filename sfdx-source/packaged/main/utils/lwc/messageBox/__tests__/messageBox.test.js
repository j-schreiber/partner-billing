import { createElement } from 'lwc';
import messageBox from 'c/messageBox';

describe('c-message-box', () => {
    
    // reset DOM after each test
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    test('render message box: success', () => {

        const element = createElement('c-message-box', {
            is: messageBox
        });
        element.variant = 'success';
        document.body.appendChild(element);

        const box = element.shadowRoot.querySelector('.message-box');
        expect(box.classList).toContain('box-theme_success');

    });

    test('render message box: warning', () => {

        const element = createElement('c-message-box', {
            is: messageBox
        });
        element.variant = 'warning';
        document.body.appendChild(element);

        const box = element.shadowRoot.querySelector('.message-box');
        expect(box.classList).toContain('box-theme_warning');

    });

    test('render message box: error', () => {

        const element = createElement('c-message-box', {
            is: messageBox
        });
        element.variant = 'error';
        document.body.appendChild(element);

        const box = element.shadowRoot.querySelector('.message-box');
        expect(box.classList).toContain('box-theme_error');

    });

    test('render message box: default', () => {

        const element = createElement('c-message-box', {
            is: messageBox
        });
        document.body.appendChild(element);

        const box = element.shadowRoot.querySelector('.message-box');
        expect(box.classList).toContain('box-theme_default');

    });

    test('display text in message box: normal text', () => {

        const element = createElement('c-message-box', {
            is: messageBox
        });
        element.message = 'This is my message';
        document.body.appendChild(element);

        const box = element.shadowRoot.querySelector('p');
        expect(box.textContent).toBe('This is my message');

    });

});