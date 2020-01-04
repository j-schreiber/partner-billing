import { LightningElement, track } from 'lwc';

export default class ExternalTimeEntryApproval extends LightningElement {
    @track isAuthorized = false;
    @track isLoading = false;

    /**                         EVENT HANDLERS                       */

    authorizeAccessCode() {
        this.isAuthorized = true;
        this.isLoading = true;
    }

    /**                            HELPERS                           */

    
}