import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

import CUSTOMER_STATUS_FIELD from '@salesforce/schema/TimeEntry__c.CustomerApprovalStatus__c';

export default class TimeEntryApprovalDataTableRow extends LightningElement {

    @api timeEntry;
    @track localApprovalStatus;

    /**                             EVENT HANDLERS                        */

    userAcceptsTimeEntry() {
        this.localApprovalStatus = 'Accepted';
        let fields = {};
        fields[CUSTOMER_STATUS_FIELD.fieldApiName] = this.localApprovalStatus;
        this.updateTimeEntry(fields);
    }

    userRejectsTimeEntry() {
        this.localApprovalStatus = 'Rejected';
        let fields = {};
        fields[CUSTOMER_STATUS_FIELD.fieldApiName] = this.localApprovalStatus;
        this.updateTimeEntry(fields);
    }

    /**                         GETTERS / SETTERS                        */

    get Budget() {
        return this.timeEntry && this.timeEntry.Budget__r ? this.timeEntry.Budget__r.Name : undefined;
    }

    get Product() {
        return this.timeEntry && this.timeEntry.Product__r ? this.timeEntry.Product__r.Name : undefined;
    }

    get Resource() {
        return this.timeEntry && this.timeEntry.Resource__r ? this.timeEntry.Resource__r.Name : undefined;
    }

    get isAccepted() {
        return this.localApprovalStatus ? this.localApprovalStatus === 'Accepted' : this.timeEntry[CUSTOMER_STATUS_FIELD.fieldApiName] === 'Accepted';
    }

    get isRejected() {
        return this.localApprovalStatus ? this.localApprovalStatus === 'Rejected' : this.timeEntry[CUSTOMER_STATUS_FIELD.fieldApiName] === 'Rejected';
    }

    get acceptButtonVariant() {
        return this.isAccepted ? 'success' : 'neutral';
    }

    get rejectButtonVariant() {
        return this.isRejected ? 'destructive' : 'neutral';
    }

    updateTimeEntry(fields) {
        fields.Id = this.timeEntry.Id;
        updateRecord({ fields })
        .then(() => {
            this.dispatchToast('success', 'Updated!');
        })
        .catch((error) => {
            this.dispatchToast('error', 'Not Updated!', error.body.message);
        });
    }

    dispatchToast(type, title, message) {
        let toast = new ShowToastEvent({
            title : title,
            message : message,
            variant : type
        });
        this.dispatchEvent(toast);
    }

}