import { LightningElement, track, wire } from 'lwc';
export default class TestComponent extends LightningElement {

    @track now = new Date(Date.now()).toLocaleTimeString();
    initTime = new Date(Date.now()).toLocaleTimeString();
    
    startTimer() {
        this.now = new Date(Date.now()).toLocaleTimeString();

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setInterval(() => {
            this.now = new Date(Date.now()).toLocaleTimeString();
        }, 500);
    }
}