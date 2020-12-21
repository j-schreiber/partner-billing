public class SenderAddress {

    public enum SenderType { OrgWideAddress, User}

    public static String TYPE_ORG_WIDE_ADDRESS = 'OrgWideAddress';
    public static String TYPE_USER = 'User';

    @AuraEnabled public Id SenderId {public get; public set; }
    @AuraEnabled public String Type {public get; public set; }
    @AuraEnabled public String Email {public get; public set; }
    @AuraEnabled public String Name {public get; public set; }

    public SenderAddress(OrgWideEmailAddress owea) {
        SenderId = owea.Id;
        Type = SenderAddress.TYPE_ORG_WIDE_ADDRESS;
        Email = owea.Address;
        Name = owea.DisplayName;
    }

    public SenderAddress(User u) {
        SenderId = u.Id;
        Type = SenderAddress.TYPE_USER;
        Email = u.Email;
        Name = u.Name;
    }

    public SenderAddress() {}

}
