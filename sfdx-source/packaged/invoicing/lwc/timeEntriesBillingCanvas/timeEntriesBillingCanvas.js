import { LightningElement, track } from 'lwc';

export default class TimeEntriesBillingCanvas extends LightningElement {

    @track activeFilters = {};

    updateTimeEntries(event) {
        this.activeFilters = event.detail;
        //this.template.querySelector('c-time-entries-tree-grid').filters = event.detail;
        //this.template.querySelector('c-time-entries-tree-grid').refreshData();
    }

}