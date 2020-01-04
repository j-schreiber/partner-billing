import { LightningElement, track, wire } from 'lwc';
export default class TestComponent extends LightningElement {

    @track accessCode;
    @track disableButton = true;

    enableButton(event) {
        this.disableButton = false;
    }
}