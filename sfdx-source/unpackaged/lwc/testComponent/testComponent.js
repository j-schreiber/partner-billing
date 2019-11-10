import { LightningElement, track } from 'lwc';

import getInvoices from '@salesforce/apex/BillingController.getInvoices';
import getOrganizationProfiles from '@salesforce/apex/InvoicePdfController.getOrganizationProfiles';

export default class TestComponent extends LightningElement {

    recordId = 'a061k000002cWnKAAU';

    @track invoices;
    @track organizationProfiles;
    @track isWorking = true;

    connectedCallback() {
        this.isWorking = true;
        this.getInvoiceData();
        this.getOrgProfiles();
        this.isWorking = false;
    }

    getInvoiceData() {
        getInvoices({
            status : 'Activated'
        })
        .then((result) => {
            this.invoices = result;
        })
        .catch(() => {
            this.invoices = [];
        })
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
    

}