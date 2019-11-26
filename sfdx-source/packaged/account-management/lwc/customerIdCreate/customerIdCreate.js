import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import CUSTOMER_ID_FIELD from '@salesforce/schema/Account.CustomerId__c';

export default class CustomerIdCreate extends LightningElement {
    @api accountId;

    @wire(getRecord, { recordId: '$accountId', fields: [CUSTOMER_ID_FIELD] })
    account;

    get CustomerId() {
        return this.account.data ? this.account.data.fields.CustomerId__c.value : '';
    }

    get hasCustomerId() {
        return this.CustomerId.length > 0;
    }
}