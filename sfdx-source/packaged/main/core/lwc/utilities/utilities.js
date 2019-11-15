const getOrgProfiles = (salesforceRecords) => {
    let profiles = [];
    salesforceRecords.forEach( (entry) => {
        profiles.push({
            label : entry.Name,
            value : entry.Id
        })
    });
    return profiles;
}

const cloneInvoiceRecord = (value) => {
    return {
        Id : value.Record.Id,
        Date__c : value.Record.Date__c,
        ServicePeriodTo__c : value.Record.ServicePeriodTo__c,
        ServicePeriodFrom__c : value.Record.ServicePeriodFrom__c,
        Account__r : { Name : value.Record.Account__r.Name },
        Status__c : value.Record.Status__c,
        Name : value.Record.Name,
        TotalAmount__c : value.Record.TotalAmount__c,
        TotalGrossAmount__c : value.Record.TotalGrossAmount__c,
        BillingStreet__c : value.Record.BillingStreet__c,
        BillingPostalCode__c : value.Record.BillingPostalCode__c,
        BillingCity__c : value.Record.BillingCity__c,
        BillingState__c : value.Record.BillingState__c,
        BillingCountry__c : value.Record.BillingCountry__c
    }
}

const cloneInvoiceLineItemRecord = (value) => {
    if (value.Record) {
        return {
            Id : value.Record.Id,
            Price__c : value.Record.Price__c,
            Product__c : value.Record.Product__c,
            Tax__c : value.Record.Tax__c,
            Quantity__c : value.Record.Quantity__c,
            Discount__c : value.Record.Discount__c,
            Description__c : value.Record.Description__c
        };
    }
    return {};
}

const getMapValuesAsList = (mapInput) => {
    let arr = [];
    mapInput.forEach( (value) => { arr.push(value); });
    return arr;
}

const getErrorsAsString = (errorInput) => {
    let error = '';
    if (errorInput && errorInput.body) {
        if (Array.isArray(errorInput.body)) {
            error = errorInput.body.map(e => e.message).join(', ');
        } else if (typeof errorInput.body.message === 'string') {
            error = errorInput.body.message;
        }
    }
    return error;
}

export { 
    getOrgProfiles,
    cloneInvoiceRecord,
    cloneInvoiceLineItemRecord,
    getMapValuesAsList,
    getErrorsAsString
};
