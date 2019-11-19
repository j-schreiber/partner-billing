import { LightningElement, track, wire, api } from 'lwc';

import PLACEHOLDER_SEARCH_CONTACT from '@salesforce/label/c.UI_Placeholder_SelectBillingContact';
import findBillingContacts from '@salesforce/apex/LWCUtilityController.findBillingContacts';

export default class BillingContactLookup extends LightningElement {

    @api accountId;

    LABELS = {
        PLACEHOLDER_SEARCH_CONTACT
    }

    @track searchTerm;
    @track hasRendered = false;
    searchResultCache;

    renderedCallback() {
        if (!this.hasRendered) {
            this.searchTerm = '*';
            this.hasRendered = true;
        }
    }

    @wire(findBillingContacts, { searchTerm : '$searchTerm', accId : '$accountId' } )
    convertSearchResult (value) {
        let searchResults = [];
        if (value.data) {
            value.data.forEach( (item) => { 
                searchResults.push({
                    id : item.Id,
                    sObjectType : item.Contact,
                    icon: 'standard:contact',
                    title : item.Name,
                    subtitle : item.Account.Name + ': ' + item.Account.BillingCity
                });
            });
        }
        this.searchResultCache = searchResults;
        if (this.template.querySelector('c-lookup')) this.template.querySelector('c-lookup').setSearchResults(searchResults);
    }

    /**                                 PUBLIC COMPONENT API                                     */
    @api
    reset() {
        this.template.querySelector('c-lookup').selection = [];
        this.template.querySelector('c-lookup').setSearchResults(this.searchResultCache);
    }

    @api
    getSelectedContact() {
        if (this.template.querySelector('c-lookup').getSelection().length >= 1) {
            return this.template.querySelector('c-lookup').getSelection()[0];
        }
        return undefined;
    }


    /**                                 INTERNAL FUNCTIONS                                       */

    handleSearch(event) {
        if (this.searchTerm === event.detail.searchTerm) {
            this.template.querySelector('c-lookup').setSearchResults(this.searchResultCache);
        }
        this.searchTerm = event.detail.searchTerm;
    }

    handleSelectionChange(event) {
        event.stopPropagation();
        let cont = this.getSelectedContact();
        this.dispatchEvent(new CustomEvent('selectionchange', { detail : cont }));
    }

}
