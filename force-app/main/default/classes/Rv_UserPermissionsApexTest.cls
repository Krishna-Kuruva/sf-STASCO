@isTest
public class Rv_UserPermissionsApexTest {

    @isTest
    static void doTest()
    {
        
        Profile prof = [select id,name from profile where name = 'System Administrator' limit 1];
        permissionset perm = [select id,label,description from permissionset where IsOwnedByProfile = false and label = 'RV_DI' limit 1];
        
        permissionset perm1 = [select id,label,description from permissionset where IsOwnedByProfile = false and label = 'RV_OLF' limit 1];
        
        User testUser = new user(alias = 'test123', email='test_user_rv@noemail.com', 
                                 emailencodingkey='UTF-8', firstName='Nahush', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_IN', profileid = prof.Id, country='India',
                                 timezonesidkey='Asia/Kolkata', username='test_user_rv@noemail.com'); 
        insert testUser;       
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = perm1.Id);
        
        System.Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        Test.startTest();
        
        Rv_UserPermissionsApex.PageInitWrapper pw = Rv_UserPermissionsApex.getPageDetails();
        
        Rv_UserPermissionsApex.getUserDetails(pw.ProfileFilterLabel,prof.id);
        Rv_UserPermissionsApex.getUserDetails(pw.PermissionSetFilterLabel,perm.id);
        Rv_UserPermissionsApex.getUserDetails(pw.UserFilterLabel,UserInfo.getUserId());
        
        Rv_UserPermissionsApex.getUserGrpPermDetails(pw.UserFilterLabel,testUser.id);
        Rv_UserPermissionsApex.getProfileDetails();
        Rv_UserPermissionsApex.getPermissionDetails();
        
        Test.stopTest();
    }
    
    @isTest
    static void testFieldTabDetails(){
        test.startTest();
        Profile prof = [select id,name from profile where name = 'System Administrator' limit 1];
        permissionset perm = [select id,label,description from permissionset where IsOwnedByProfile = false and label = 'RV_DI' limit 1];
        Rv_UserPermissionsApex.PageInitWrapper pw = Rv_UserPermissionsApex.getPageDetails();
        
        User testUser = new user(alias = 'test123', email='test_user_rv@noemail.com', 
                                 emailencodingkey='UTF-8', firstName='Nahush', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_IN', profileid = prof.Id, country='India',
                                 timezonesidkey='Asia/Kolkata', username='test_user_rv@noemail.com'); 
        insert testUser;
        Group grp = new Group();
        grp.name = 'User Permission Group';
        grp.Type = 'Regular'; 
        insert grp; 
        
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = testUser.id;
        grpMem1.GroupId = grp.Id;
        insert grpMem1;
        
        Rv_UserPermissionsApex.getUserGrpPermDetails(pw.UserFilterLabel,testUser.id);
        
        Rv_UserPermissionsApex.getFieldDetails('Account', pw.ProfileFilterLabel,prof.id, '');
        Rv_UserPermissionsApex.getFieldDetails('Account', pw.PermissionSetFilterLabel,perm.id,'');
        Rv_UserPermissionsApex.getFieldDetails('Account', pw.UserFilterLabel,UserInfo.getUserId(), prof.name);
        
        
        Rv_UserPermissionsApex.getTabDetails(pw.ProfileFilterLabel,prof.id, '');
        Rv_UserPermissionsApex.getTabDetails(pw.PermissionSetFilterLabel,perm.id,'');
        Rv_UserPermissionsApex.getTabDetails(pw.UserFilterLabel,UserInfo.getUserId(), prof.name);
        test.stopTest();
        
    }
    @isTest
    static void testObjectDetails(){
        test.startTest();
        Profile prof = [select id,name from profile where name = 'System Administrator' limit 1];
        permissionset perm = [select id,label,description from permissionset where IsOwnedByProfile = false and label = 'RV_DI' limit 1];
        Rv_UserPermissionsApex.PageInitWrapper pw = Rv_UserPermissionsApex.getPageDetails();
        
        Rv_UserPermissionsApex.getObjectDetails(pw.ProfileFilterLabel,prof.id, '');
        Rv_UserPermissionsApex.getObjectDetails(pw.PermissionSetFilterLabel,perm.id,'');
        Rv_UserPermissionsApex.getObjectDetails(pw.UserFilterLabel,UserInfo.getUserId(), prof.name); 
        test.stopTest();
    }
}