import { LightningElement, track } from 'lwc';

import CARD_TITLE from '@salesforce/label/c.Invoicing_Label_FilterHeader';
import STARTDATE_PICKER_LABEL from '@salesforce/label/c.Invoicing_Label_ServiceDateStart';
import ENDDATE_PICKER_LABEL from '@salesforce/label/c.Invoicing_Label_ServiceDateEnd';
export default class TimeEntriesFilterHeader extends LightningElement {

    @track selectedFilters = {
        startDate: new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth() -1, 1)).toISOString(),
        endDate: new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth(), 0)).toISOString(),
    }

    LABELS = {
        CARD_TITLE,
        STARTDATE_PICKER_LABEL,
        ENDDATE_PICKER_LABEL
    }

    handleStartDateChange(event) {
        this.selectedFilters.startDate = event.detail.value;
        this.dispatchFilterUpdate();
    }

    handleEndDateChange(event) {
        this.selectedFilters.endDate = event.detail.value;
        this.dispatchFilterUpdate();
    }

    connectedCallback() {
        this.dispatchFilterUpdate();
    }

    dispatchFilterUpdate() {
        this.dispatchEvent(
            new CustomEvent(
                'filterupdate', { detail : this.selectedFilters }
            )
        );
    }
}