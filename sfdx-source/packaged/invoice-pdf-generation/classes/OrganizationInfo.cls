/** @Description
*   Singleton pattern to expose company data from custom metadata
*/
public class OrganizationInfo {

    public String Email {public get; private set;}
    public String Phone {public get; private set;}
    public String Name {public get; private set;}
    public String VATNumber {public get; private set;}

    public String Street {public get; private set;}
    public String PostalCode {public get; private set;}
    public String City {public get; private set;}
    public String Country {public get; private set;}

    public OrganizationInfo() {

        Map<String, String> data = new Map<String, String>();
        for (CompanyData__mdt cd : [SELECT DeveloperName,Label,Value__c FROM CompanyData__mdt]) data.put(cd.DeveloperName, cd.Value__c);
        
        Name = data.get('NAME');
        Phone = data.get('PHONE');
        Email = data.get('EMAIL');
        Street = data.get('STREET');
        PostalCode = data.get('POSTAL_CODE');
        City = data.get('CITY');
        Country = data.get('COUNTRY');
        VATNumber = data.get('VAT_NUMBER');
    }

}