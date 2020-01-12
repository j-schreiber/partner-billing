import { LightningElement, wire } from 'lwc';
import getTimeEntries from '@salesforce/apex/TimeEntryApprovalController.getTimeEntries';

export default class TestComponent extends LightningElement {

    @wire(getTimeEntries, { accessCode : 'ABCD1234EFGH' })
    timeEntries;

}