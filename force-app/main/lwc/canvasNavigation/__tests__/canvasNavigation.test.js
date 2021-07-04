import { createElement } from 'lwc';
import canvasNavigation from 'c/invoicingCanvasNavigation';

function reset() {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
}

describe('c-invoicing-canvas-navigation', () => {

    describe('rendering', () => {

        afterEach(() => { reset(); });
        
    });

});