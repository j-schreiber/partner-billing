import { createElement } from 'lwc';
import myComponent from 'c/timeTracker';
import imperativeApexMethod from '@salesforce/apex/ClassName.methodName';

jest.mock(
    '@salesforce/apex/ClassName.methodName',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-my-component', () => {

    describe('get wired data', () => {
    
        afterEach(() => { reset(); });
        
        test('apex method test', () => {
        
            imperativeApexMethod.mockResolvedValue('arbitrary');
        
            const element = createElement('c-my-component', {
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