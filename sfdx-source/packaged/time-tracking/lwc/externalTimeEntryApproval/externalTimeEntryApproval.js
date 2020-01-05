import { LightningElement, track } from 'lwc';

export default class ExternalTimeEntryApproval extends LightningElement {
    @track isAuthorized = false;
    @track isLoading = false;

    /**                         EVENT HANDLERS                       */

    authorizeAccessCode(event) {
        this.isAuthorized = true;
        console.log(JSON.stringify(event));
        this.loadTimeEntries();
    }

    /**                            HELPERS                           */

    loadTimeEntries() {
        this.isLoading = true;
        // stuff
    }
}