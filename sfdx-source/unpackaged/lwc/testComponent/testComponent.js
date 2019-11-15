import { LightningElement, track, wire } from 'lwc';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';

export default class TestComponent extends LightningElement {

    recordId = 'a061k000002cWnKAAU';

    @wire(getInvoices, { status : 'Draft' })
    invoices;

    @track organizationProfiles;
    @track isWorking = true;

    connectedCallback() {
        this.isWorking = true;
        this.getOrgProfiles();
        this.isWorking = false;
    }


    getOrgProfiles() {

        getOrganizationProfiles({})
        .then( (data) => {
            let profiles = [];
            data.forEach( (entry) => {
                profiles.push({
                    label : entry.Name,
                    value : entry.Id
                })
            });
            this.organizationProfiles = profiles;            
        })
        .catch( () => {
            this.organizationProfiles = [];
        });
    }

    handleOptionsChange(event) {
        console.log(JSON.stringify(event.detail));
    }

    get loadCompleted() {
        return this.invoices && this.organizationProfiles;
    }

    get Invoice() {
        return this.invoices.data[0];
    }
    

}