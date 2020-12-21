import { LightningElement } from 'lwc';

export default class TestInputComponent extends LightningElement {

    get divClass() {
        return 'is-dirty';
    }
}