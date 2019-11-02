import { LightningElement, track } from 'lwc';

export default class TimeEntriesBillingCanvas extends LightningElement {

    @track processStage = 1;

    updateTimeEntries(event) {
        const timeEntriesGrid = this.template.querySelector('c-time-entries-tree-grid');
        timeEntriesGrid.filters = event.detail;
    }

    get processIndicatorStage() {
        return this.processStage.toString();
    }

    get displayTimeEntrySelection() {
        return this.processStage === 1;
    }

    get displayInvoicesPreview() {
        return this.processStage === 2;
    }

    increaseProcessStage() {
        if (this.processStage < 5) this.processStage++;
    }

    decreaseProcessStage() {
        if (this.processStage > 1) this.processStage--;
    }

}