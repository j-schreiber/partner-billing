import { LightningElement, track } from 'lwc';

export default class TimeEntriesFilterHeader extends LightningElement {

    @track selectedFilters = {
        startDate: '2019-10-01',
        endDate: '2019-10-31'
    }

    handleStartDateChange(event) {
        this.selectedFilters.startDate = event.detail.value;
        this.dispatchFilterUpdate();
    }

    handleEndDateChange(event) {
        this.selectedFilters.endDate = event.detail.value;
        this.dispatchFilterUpdate();
    }

    renderedCallback() {
        this.dispatchFilterUpdate();
    }

    dispatchFilterUpdate() {
        this.dispatchEvent(
            new CustomEvent(
                'filterupdate', {
                    detail : this.selectedFilters
                })
        );
    }
}