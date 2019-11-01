import { LightningElement } from 'lwc';

export default class TimeEntriesBillingCanvas extends LightningElement {

    updateTimeEntries(event) {
        const timeEntriesGrid = this.template.querySelector('c-time-entries-tree-grid');
        timeEntriesGrid.filters = event.detail;
    }

}