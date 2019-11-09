import { LightningElement, track, api } from 'lwc';

export default class TestComponent extends LightningElement {

    @track originalRecord = {
        myField : 'Original Value',
        mySecondField : ''
    }
    
    newRecord = {};
    oldRecord = {};

    handleChange(event) {
        let fieldName = 'myField';
        console.log('Modified Field: ' + JSON.stringify(event.currentTarget.name));
        this.newRecord[event.currentTarget.name] = event.detail.value;
        if (this.isModified(event.currentTarget.name)) event.currentTarget.classList.add('dirty-field');
        if (!this.isModified(event.currentTarget.name)) event.currentTarget.classList.remove('dirty-field');
    }

    isModified(fieldName) {
        return this.newRecord[fieldName] !== this.originalRecord[fieldName];
    }

}