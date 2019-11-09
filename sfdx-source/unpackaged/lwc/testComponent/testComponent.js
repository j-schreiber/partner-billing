import { LightningElement, track, api } from 'lwc';

export default class TestComponent extends LightningElement {

    @track originalRecord = {
        myField : 'Original Value',
        mySecondField : '',
        Product__c : ''
    }
    
    newRecord = {};
    oldRecord = {};

    handleChange(event) {
        console.log('Modified Field: ' + JSON.stringify(event.currentTarget.name));
        this.newRecord[event.currentTarget.name] = event.detail.value;
        this.dispatchUpdateEvent(event);
    }

    updateProduct(event) {
        console.log('Modified Field: ' + JSON.stringify(event.currentTarget.name));
        this.newRecord[event.currentTarget.name] = (event.detail.value.length === 0) ? '' : (event.detail.value)[0];
        this.dispatchUpdateEvent(event);
    }

    isModified(fieldName) {
        return this.newRecord[fieldName] !== this.originalRecord[fieldName];
    }

    dispatchUpdateEvent(event) {
        //this.dispatchRecordChange(event.currentTarget.name);
        if (this.isModified(event.currentTarget.name)) event.currentTarget.classList.add('dirty-field');
        if (!this.isModified(event.currentTarget.name)) event.currentTarget.classList.remove('dirty-field');
    }

}