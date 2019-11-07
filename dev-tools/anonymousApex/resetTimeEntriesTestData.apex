Integer BULK_NUMBER = 7;

delete [SELECT Id FROM TimeEntry__c WHERE IsInvoiced__c = false];

List<TimeEntry__c> tes = new List<TimeEntry__c>();

Product2 devProduct = [SELECT Id FROM Product2 WHERE Name LIKE '%Implementierung%'];
Product2 consultingProduct = [SELECT Id FROM Product2 WHERE Name LIKE '%Beratung%'];

for (Account a : [SELECT Id FROM Account]) {
    for (Integer i = 0; i < BULK_NUMBER; i++) {
        tes.add(TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(Account__c=a.Id,Status__c='Approved',DailyRate__c=1250,StartTime__c=getStartTime(),EndTime__c=getEndTime(),Date__c=getDate(),Product__c=consultingProduct.Id)
        ));
        tes.add(TestDataFactory.CreateTimeEntry(
            new TimeEntry__c(Account__c=a.Id,Status__c='Approved',DailyRate__c=650,StartTime__c=getStartTime(),EndTime__c=getEndTime(),Date__c=getDate(),Product__c=devProduct.Id)
        ));
    }
}

insert tes;

public Time getStartTime() {
    return Time.newInstance(6, 0, 0, 0).addMinutes(Integer.valueOf(Math.random() * 120));
}

public Time getEndTime() {
    return Time.newInstance(15, 0, 0, 0).addMinutes(Integer.valueOf(Math.random() * 240));
}

public Date getDate() {
    return Date.newInstance(2019, System.today().month() - 1, 1).addDays(Integer.valueOf(Math.random() * 30));
}