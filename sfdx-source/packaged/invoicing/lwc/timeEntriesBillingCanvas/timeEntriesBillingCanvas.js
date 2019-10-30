import { LightningElement, track } from 'lwc';

export default class TimeEntriesBillingCanvas extends LightningElement {

    @track activeFilters;

    updateTimeEntries(event) {
        console.log('Start Date: ' + event.detail.startDate);
        console.log('End Date: ' + event.detail.endDate);
        this.activeFilters = event.detail;
    }

}