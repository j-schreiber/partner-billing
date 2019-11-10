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

export { getOrgProfiles };
