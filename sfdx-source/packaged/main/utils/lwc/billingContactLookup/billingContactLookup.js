import { LightningElement, track, wire, api } from 'lwc';

import PLACEHOLDER_SEARCH_CONTACT from '@salesforce/label/c.UI_Placeholder_SelectBillingContact';
import findBillingContacts from '@salesforce/apex/LWCUtilityController.findBillingContacts';

export default class BillingContactLookup extends LightningElement {

    @api accountId;

    LABELS = {
        PLACEHOLDER_SEARCH_CONTACT
    }

    @track searchTerm;
    @track selectedId;
    @track hasRendered = false;

    renderedCallback() {
        if (!this.hasRendered) {
            this.searchTerm = '*';
            this.hasRendered = true;
        }
    }

    @wire(findBillingContacts, { searchTerm : '$searchTerm', accId : '$accountId' } )
    convertSearchResult (value) {
        let searchResults = [];
        console.log('Retrieved: ' + JSON.stringify(value));
        if (value.data) {
            value.data.forEach( (item) => { 
                console.log(JSON.stringify(item));
                searchResults.push({
                    id : item.Id,
                    sObjectType : item.Contact,
                    icon: 'standard:contact',
                    title : item.Name,
                    subtitle : item.Account.Name + ': ' + item.Account.BillingCity
                });
            });
        }
        if (this.template.querySelector('c-lookup')) this.template.querySelector('c-lookup').setSearchResults(searchResults);
    }

    handleSearch(event) {
        this.searchTerm = event.detail.searchTerm;
    }

}
