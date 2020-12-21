/** @Description
*   Test Permission Factory provides setup methods to provide test-users with
*   permissions in this app. After methods from this class have been called, code usually
*   must run in `System.runAs()` scope to prevent MIXED DML errors.
*/
public class TestPermissionFactory {

    public static void setupPermissions(User testUser, List<String> permissionSets) {
        if (testUser.ProfileId == null) testUser.profileId = getStandardProfile().Id;
        if (testUser.Id == null) insert testUser;

        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN :permissionSets]) {
            assignments.add(new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id));
        }
        insert assignments;
    }

    public static Profile getStandardProfile() {
        Profile p = [SELECT Id,Name FROM Profile WHERE Name LIKE '%Standard%' LIMIT 1];
        return p;
    }
}
