import { createElement } from 'lwc';
import timer from 'c/durationTimer';

describe('c-duration-timer', () => {

    describe('init timer', () => {
    
        afterEach(() => { reset(); });
        
        test('locale time strings', () => {
        
            const element = createElement('c-duration-timer', {
                is: timer 
            });
            element.startTimeString = '13:30:45';
            element.endTimeString = '13:32:50';
            document.body.appendChild(element);

            /** VERIFY */
            expect(element.duration).toBe('00:02:05');
            let clock = element.shadowRoot.querySelector('.clock');
            expect(clock.textContent).toBe('00:02:05');
            
        });
        
    });

});

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}