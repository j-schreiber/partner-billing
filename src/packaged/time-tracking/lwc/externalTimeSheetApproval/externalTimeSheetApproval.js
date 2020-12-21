import { LightningElement, track } from 'lwc';
import getTimeEntries from '@salesforce/apex/TimeEntryApprovalController.getTimeEntries';
import getContactData from '@salesforce/apex/TimeEntryApprovalController.getContactData';

import TITLE from '@salesforce/label/c.TimeSheetApproval_Title_AccountData';

export default class ExternalTimeSheetApproval extends LightningElement {

    @track isAuthorized = false;
    @track isLoadingTimeEntries = false;
    @track isLoadingContactData = false;

    timeEntries;
    contactData;

    /**                         EVENT HANDLERS                       */

    authorizeAccessCode(event) {
        this.isAuthorized = true;
        this.loadTimeEntries(event.detail.accessCode);
        this.loadContactData(event.detail.accessCode);
    }

    /**                       GETTERS / SETTERS                           */

    get PageTitle() {
        return TITLE.replace('{!Account}', this.contactData.Account.Name).replace('{!Contact}', this.contactData.Name);
    }

    /**                            HELPERS                           */

    loadTimeEntries(code) {
        this.isLoadingTimeEntries = true;
        getTimeEntries({ accessCode : code })
        .then((result) => {
            this.timeEntries = result;
            this.isLoadingTimeEntries = false;
        })
        .catch(() => {
            this.isLoadingTimeEntries = false;
        });
    }

    loadContactData(code) {
        this.isLoadingContactData = true;
        getContactData({ accessCode : code })
        .then((result) => {
            this.contactData = result;
            this.isLoadingContactData = false;
        })
        .catch(() => {
            this.isLoadingContactData = false;
        });
    }
}