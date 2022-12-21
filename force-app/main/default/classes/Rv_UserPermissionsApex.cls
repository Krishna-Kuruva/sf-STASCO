public class Rv_UserPermissionsApex {

    public static String AppName;
    public static List<String> profileList = new List<String>();
    public static List<String> standardProfileList = new List<String>();
    public static String ProfileFilterLabel;
    public static String PermissionSetFilterLabel;
    public static String UserFilterLabel;
    public static String permSetFilter;
    public static String objectRemoveFilter;

    static void setGlobalVarFromMDT()
    {
        map<String,String> mdtMap = new map<String,String>();

        User_Permission_Dashboard__mdt[] upMDT = [select id, label,developername, value__c from User_Permission_Dashboard__mdt];
        for(User_Permission_Dashboard__mdt u : upMDT)
            mdtMap.put(u.developername, u.Value__c);

        AppName = mdtMap.containsKey('ApplicationName') ? mdtMap.get('ApplicationName') : '';
        if(mdtMap.containsKey('customProfileList'))
        {
            try{profileList = mdtMap.get('customProfileList').split(',');}catch(Exception e){}
        }
        if(mdtMap.containsKey('standardProfileList'))
        {
            try{standardProfileList = mdtMap.get('standardProfileList').split(',');
                profileList.addAll(standardProfileList);}catch(Exception e){}
        }
        ProfileFilterLabel = mdtMap.containsKey('ProfileFilterLabel') ? mdtMap.get('ProfileFilterLabel') : '';
        PermissionSetFilterLabel = mdtMap.containsKey('PermissionSetFilterLabel') ? mdtMap.get('PermissionSetFilterLabel') : '';
        UserFilterLabel = mdtMap.containsKey('UserFilterLabel') ? mdtMap.get('UserFilterLabel') : '';
        permSetFilter = mdtMap.containsKey('permmisonSetFilter') ? mdtMap.get('permmisonSetFilter') : '';
        objectRemoveFilter = mdtMap.containsKey('objectRemoveFilter') ? mdtMap.get('objectRemoveFilter') : '';
    }

    static boolean checkPermission()
    {
        Boolean hasPermission = false;

        if(Profile.sObjectType.getDescribe().isQueryable()
                && PermissionSet.sObjectType.getDescribe().isQueryable()
                && User_Permission_Dashboard__mdt.sObjectType.getDescribe().isQueryable()
                && User.sObjectType.getDescribe().isQueryable()
                && PermissionSetAssignment.sObjectType.getDescribe().isQueryable()
                && GroupMember.sObjectType.getDescribe().isQueryable()
                && AppTabMember.sObjectType.getDescribe().isQueryable()
                )
        {
            SetupEntityAccess[] SEA = [SELECT Id  FROM SetupEntityAccess
            WHERE ParentId in (SELECT PermissionSetId FROM PermissionSetAssignment
            where AssigneeID = :UserInfo.getUserId())
            AND SetupEntityId in (SELECT Id FROM ApexPage
            where name ='Rv_GetSessionIdVF'
            AND NamespacePrefix = null)];
            if(SEA.size()>0)
            {
                PermissionSetAssignment[] psa = [SELECT id FROM PermissionSetAssignment
                WHERE PermissionSet.PermissionsModifyAllData = true and
                PermissionSet.PermissionsModifyMetadata = true
                and AssigneeId = :UserInfo.getUserId()];
                if(psa.size()>0)
                    hasPermission = true;
                else
                        hasPermission = false;
            }
            else
                    hasPermission = false;
        }
        else
                hasPermission = false;

        return hasPermission;
    }

    @AuraEnabled(cacheable=true)
    public static PageInitWrapper getPageDetails(){
        PageInitWrapper returnPageInitWrapper = new PageInitWrapper();
        setGlobalVarFromMDT();

        returnPageInitWrapper.AppName = AppName;

        returnPageInitWrapper.HasAccess = checkPermission();

        returnPageInitWrapper.ProfileFilterLabel = ProfileFilterLabel;
        returnPageInitWrapper.PermissionSetFilterLabel = PermissionSetFilterLabel;
        returnPageInitWrapper.UserFilterLabel = UserFilterLabel;

        return returnPageInitWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static UserDetailWrapper getUserDetails(String SearchType, String SearchParam)
    {
        setGlobalVarFromMDT();
        UserDetailWrapper returnUserDetailWrapper = new UserDetailWrapper();
        List<UserWrapper> retrunUserWrapper = new List<UserWrapper>();
        String SearchQry = 'select id,name, username, email, profile.name, profileId from User'
                +' where isActive = true and profile.name in :profileList';

        if(SearchType.equals(ProfileFilterLabel))
            SearchQry += ' and profileId = :SearchParam';
        else if(SearchType.equals(PermissionSetFilterLabel))
        {
            PermissionSetAssignment[] psa = [select id, PermissionSetId, AssigneeId from PermissionSetAssignment
            where PermissionSetId= :SearchParam and PermissionSet.IsOwnedByProfile = false];
            if(psa.size()>0)
            {
                Set<ID> UserIdSet = new Set<ID>();
                for(PermissionSetAssignment p :psa)
                    UserIdSet.add(p.AssigneeId);
                SearchQry += ' and id in :UserIdSet';
            }
        }
        else if (SearchType.equals(UserFilterLabel))
            SearchQry += '';

        SearchQry += ' order by name';

        List<User> usrLst = Database.query(SearchQry);

        string LoggedInUsr = UserInfo.getUserId();
        for(User u : usrLst)
        {
            UserWrapper uw = new UserWrapper();
            uw.keyID = u.id;
            uw.Name = u.name;
            if(LoggedInUsr.equals(String.valueOf(u.Id)))
                uw.Name = uw.Name + ' ~[Me]~';
            uw.Username = u.username;
            uw.Email = u.email;
            uw.Profile = u.profile.name;
            uw.exportRow = new List<String>{uw.Name,uw.Username,uw.Email,uw.Profile};
            retrunUserWrapper.add(uw);
        }

        returnUserDetailWrapper.UserWrapperLst = retrunUserWrapper;

        if(!SearchType.equals(UserFilterLabel)){
            returnUserDetailWrapper.ObjectWrapperLst = getObjectDetails(SearchType, SearchParam,'');
            returnUserDetailWrapper.TabWrapperLst = getTabDetails(SearchType, SearchParam,'');
        }

        return returnUserDetailWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static UserGrpPermDetailWrapper getUserGrpPermDetails(String SearchType, String SearchParam)
    {
        setGlobalVarFromMDT();
        UserGrpPermDetailWrapper retrunUserGrpPermDetailWrapper = new UserGrpPermDetailWrapper();

        if(SearchType.equals(UserFilterLabel) && SearchParam.length()>0)
        {
            List<UserPermitWrapper> returnUserPermitWrapper = new List<UserPermitWrapper>();
            PermissionSetAssignment[] psa = [select id, PermissionSet.label, PermissionSet.description from PermissionSetAssignment
            where AssigneeId = :SearchParam and PermissionSet.IsOwnedByProfile = false];

            for(PermissionSetAssignment p: psa)
            {
                UserPermitWrapper upw = new UserPermitWrapper();
                upw.Name = p.PermissionSet.label;
                upw.Description = p.PermissionSet.description;
                upw.exportRow = new List<String>{upw.Name,upw.Description};
                returnUserPermitWrapper.add(upw);
            }
            if(psa.size()>0)
                retrunUserGrpPermDetailWrapper.HasPermSet = true;
            retrunUserGrpPermDetailWrapper.UserPermitWrapperLst = returnUserPermitWrapper;

            List<UserGrpWrapper> returnUserGrpWrapper = new List<UserGrpWrapper>();
            GroupMember[] gm = [SELECT Id, group.name FROM GroupMember
            where userOrGroupId = :SearchParam];
            for(GroupMember g: gm)
            {
                UserGrpWrapper ugw = new UserGrpWrapper();
                ugw.name = g.group.name;
                ugw.exportRow = new List<String>{ugw.name};
                returnUserGrpWrapper.add(ugw);
            }
            if(gm.size()>0)
                retrunUserGrpPermDetailWrapper.HasGrp = true;
            retrunUserGrpPermDetailWrapper.UserGrpWrapperLst = returnUserGrpWrapper;
        }

        return retrunUserGrpPermDetailWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProfileWrapper> getProfileDetails()
    {
        setGlobalVarFromMDT();
        List<ProfileWrapper> retrunProfileWrapper = new List<ProfileWrapper>();

        Profile[] profLst = [select id,name from profile
        where name in :profileList order by name];
        for(Profile p : profLst)
        {
            ProfileWrapper pw = new ProfileWrapper();
            pw.keyID = p.id;
            pw.Name = p.name;
            pw.Custom = standardProfileList.contains(p.name) ? false : true;
            pw.exportRow = new List<String>{pw.Name,((pw.Custom) ? 'Yes' : 'No')};

            retrunProfileWrapper.add(pw);
        }

        return retrunProfileWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<PermitWrapper> getPermissionDetails()
    {
        setGlobalVarFromMDT();
        List<PermitWrapper> retrunPermitWrapper = new List<PermitWrapper>();
        List<String> permSetFilterLst = new List<String>();

        try{permSetFilterLst = permSetFilter.split(',');} catch(Exception e){}

        permissionset[] permLst = [select id,label,description from permissionset
        where IsOwnedByProfile = false order by label];
        for(permissionset p : permLst)
        {
            Boolean includePerm = false;

            for(String filt:permSetFilterLst)
            {
                if(p.label.toUpperCase().startsWith(filt.toUpperCase()))
                    includePerm = true;
            }

            if(includePerm)
            {
                PermitWrapper pw = new PermitWrapper();
                pw.keyID = p.id;
                pw.Name = p.label;
                pw.Description = p.Description;
                pw.exportRow = new List<String>{pw.Name,pw.Description};
                retrunPermitWrapper.add(pw);
            }
        }

        return retrunPermitWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<ObjectWrapper> getObjectDetails(String SearchType, String SearchParam1, String SearchParam2)
    {
        setGlobalVarFromMDT();
        List<ObjectWrapper> retrunObjectWrapper = new List<ObjectWrapper>();
        Map<String,String> objectMap = new Map<String,String>();
        List<String> objectLst = new List<String>();

        List<String> objectRemoveFilterLst = new List<String>();
        try{objectRemoveFilterLst = objectRemoveFilter.split(',');} catch(Exception e){}

        Map<String, Schema.SObjectType> globalSchemaDesc = Schema.getGlobalDescribe();
        for(Schema.SObjectType sObj : Schema.getGlobalDescribe().values())
        {
            String sObjAPIName = String.valueOf(sObj);
            String sObjName = sObj.getDescribe().getLabel();
            Boolean includeObj = true;

            for(String filt: objectRemoveFilterLst)
            {
                if(sObjAPIName.toUpperCase().contains(filt.toUpperCase()))
                {includeObj = false; break;}
            }

            if ( includeObj)
            {
                objectLst.add(sObjName);
                objectMap.put(sObjName,sObjAPIName);
            }
        }

        if(objectLst.size()>0)
        {
            objectLst.sort();
            List<String> objAPILst = new List<String>();
            objAPILst.addall(objectMap.values());

            String SearchQry = 'SELECT Id,PermissionsCreate,PermissionsDelete,PermissionsEdit,PermissionsModifyAllRecords,'
                    +'PermissionsRead,PermissionsViewAllRecords,SobjectType FROM ObjectPermissions where SobjectType in :objAPILst';
            String SearchQry2 = SearchQry;

            if(SearchType.equals(ProfileFilterLabel))
                SearchQry += ' and ParentId in (select id from PermissionSet where ProfileId=:SearchParam1 and IsOwnedByProfile = true)';
            else if(SearchType.equals(PermissionSetFilterLabel))
                SearchQry += ' and ParentId = :SearchParam1';
            else if (SearchType.equals(UserFilterLabel))
                SearchQry += ' and ParentId in (SELECT PermissionSetId FROM PermissionSetAssignment where AssigneeID = :SearchParam1)';

            List<ObjectPermissions> objPermLst = Database.query(SearchQry);
            List<ObjectPermissions> objPermLst2 = new List<ObjectPermissions>();

            Map<String,ObjectPermissions> objPermMap = new Map<String,ObjectPermissions>();
            for(ObjectPermissions op : objPermLst)
                objPermMap.put(op.SobjectType,op);

            //Override PermissionSet permission with Profile permission
            if(SearchParam2.length()>0 && SearchType.equals(UserFilterLabel))
            {
                SearchQry2 += ' and ParentId in (select id from PermissionSet where Profile.Name=:SearchParam2 and IsOwnedByProfile = true)';
                objPermLst2 = Database.query(SearchQry2);
                Map<String,ObjectPermissions> objPermMap2 = new Map<String,ObjectPermissions>();
                for(ObjectPermissions op : objPermLst2)
                    objPermMap2.put(op.SobjectType,op);

                for(String key : objPermMap2.keySet())
                {
                    if(objPermMap.containsKey(key))
                    {
                        ObjectPermissions op = objPermMap.get(key);
                        ObjectPermissions op2 = objPermMap2.get(key);

                        if(op2.PermissionsRead && !op.PermissionsRead)
                            op.PermissionsRead = true;
                        if(op2.PermissionsCreate && !op.PermissionsCreate)
                            op.PermissionsCreate = true;
                        if(op2.PermissionsEdit && !op.PermissionsEdit)
                            op.PermissionsEdit = true;
                        if(op2.PermissionsDelete && !op.PermissionsDelete)
                            op.PermissionsDelete = true;
                        if(op2.PermissionsViewAllRecords && !op.PermissionsViewAllRecords)
                            op.PermissionsViewAllRecords = true;
                        if(op2.PermissionsModifyAllRecords && !op.PermissionsModifyAllRecords)
                            op.PermissionsModifyAllRecords = true;

                        objPermMap.put(key,op);
                    }
                    else
                            objPermMap.put(key,objPermMap2.get(key));
                }
            }

            for(String obj: objectLst)
            {
                ObjectWrapper ow = new ObjectWrapper();
                ow.Name = obj;
                ow.APIName = objectMap.get(obj);
                ow.Read = false;
                ow.Create = false;
                ow.Edit = false;
                ow.Del = false;
                ow.ViewAll = false;
                ow.ModifyAll = false;

                if(objPermMap.containsKey(ow.APIName))
                {
                    ow.Read = objPermMap.get(ow.APIName).PermissionsRead;
                    ow.Create = objPermMap.get(ow.APIName).PermissionsCreate;
                    ow.Edit = objPermMap.get(ow.APIName).PermissionsEdit;
                    ow.Del = objPermMap.get(ow.APIName).PermissionsDelete;
                    ow.ViewAll = objPermMap.get(ow.APIName).PermissionsViewAllRecords;
                    ow.ModifyAll = objPermMap.get(ow.APIName).PermissionsModifyAllRecords;
                }
                if(ow.Read || ow.Create || ow.Edit || ow.Del || ow.ViewAll || ow.ModifyAll)
                {
                    ow.exportRow = new List<String>{  ow.Name
                            ,((ow.Read) ? 'Yes' : 'No')
                            ,((ow.Create) ? 'Yes' : 'No')
                            ,((ow.Edit) ? 'Yes' : 'No')
                            ,((ow.Del) ? 'Yes' : 'No')
                            ,((ow.ViewAll) ? 'Yes' : 'No')
                            ,((ow.ModifyAll) ? 'Yes' : 'No')
                    };
                    retrunObjectWrapper.add(ow);
                }
            }
        }

        return retrunObjectWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldWrapper> getFieldDetails(string ObjName, String SearchType, String SearchParam1, String SearchParam2)
    {

        setGlobalVarFromMDT();
        List<FieldWrapper> retrunFieldWrapper = new List<FieldWrapper>();
        Map<String,String> fieldMap = new Map<String,String>();
        Map<String,Boolean> fieldAutoNumTypeMap = new Map<String,Boolean>();
        List<String> fieldtLst = new List<String>();

        if(Schema.getGlobalDescribe().containsKey(ObjName))
        {
            Map<String, Schema.SobjectField> schFieldMap = Schema.getGlobalDescribe().get(ObjName).getDescribe().fields.getMap();
            for(String fieldAPIName: schFieldMap.keySet())
            {
                String fieldName = schFieldMap.get(fieldAPIName).getDescribe().getLabel();
                Boolean fieldAutoNumType = schFieldMap.get(fieldAPIName).getDescribe().isAutoNumber();
                fieldtLst.add(fieldName);
                fieldMap.put(fieldName,fieldAPIName.toUpperCase());
                if(fieldAutoNumType)
                    fieldAutoNumTypeMap.put(fieldAPIName.toUpperCase(),fieldAutoNumType);
            }
        }

        if(fieldtLst.size()>0)
        {
            fieldtLst.sort();

            String SearchQry = 'SELECT Id,PermissionsRead,PermissionsEdit, Field'
                    +' FROM FieldPermissions where SobjectType =:ObjName';
            String SearchQry2 = SearchQry;

            if(SearchType.equals(ProfileFilterLabel))
                SearchQry += ' and ParentId in (select id from PermissionSet where ProfileId=:SearchParam1 and IsOwnedByProfile = true)';
            else if(SearchType.equals(PermissionSetFilterLabel))
                SearchQry += ' and ParentId = :SearchParam1';
            else if (SearchType.equals(UserFilterLabel))
                SearchQry += ' and ParentId in (SELECT PermissionSetId FROM PermissionSetAssignment where AssigneeID = :SearchParam1)';

            List<FieldPermissions> fldPermLst = Database.query(SearchQry);
            List<FieldPermissions> fldPermLst2 = new List<FieldPermissions>();

            Map<String,FieldPermissions> fldPermMap = new Map<String,FieldPermissions>();
            for(FieldPermissions fp : fldPermLst)
                fldPermMap.put(fp.Field.replace(ObjName+'.','').toUpperCase(),fp);

            //Override PermissionSet permission with Profile permission
            if(SearchParam2.length()>0 && SearchType.equals(UserFilterLabel))
            {
                SearchQry2 += ' and ParentId in (select id from PermissionSet where Profile.Name=:SearchParam2 and IsOwnedByProfile = true)';
                fldPermLst2 = Database.query(SearchQry2);
                Map<String,FieldPermissions> fldPermMap2 = new Map<String,FieldPermissions>();
                for(FieldPermissions fp : fldPermLst2)
                    fldPermMap2.put(fp.Field.replace(ObjName+'.','').toUpperCase(),fp);

                for(String key : fldPermMap2.keySet())
                {
                    if(fldPermMap.containsKey(key))
                    {
                        FieldPermissions fp = fldPermMap.get(key);
                        FieldPermissions fp2 = fldPermMap2.get(key);

                        if(fp2.PermissionsRead && !fp.PermissionsRead)
                            fp.PermissionsRead = true;
                        if(fp2.PermissionsEdit && !fp.PermissionsEdit)
                            fp.PermissionsEdit = true;

                        fldPermMap.put(key,fp);
                    }
                    else
                            fldPermMap.put(key,fldPermMap2.get(key));
                }
            }

            for(String fld: fieldtLst)
            {
                FieldWrapper fw = new FieldWrapper();
                fw.Name = fld;
                String fldAPIName = fieldMap.get(fld);
                fw.Read = false;
                fw.Edit = false;
                fw.SystemControlled = false;

                if(fldAPIName.endsWith('__C'))
                {
                    if(fldPermMap.containsKey(fldAPIName))
                    {
                        fw.Read = fldPermMap.get(fldAPIName).PermissionsRead;
                        fw.Edit = fldPermMap.get(fldAPIName).PermissionsEdit;
                        fw.SystemControlled = false;
                    }
                }
                else
                {
                    fw.Read = true;
                    if(!fieldAutoNumTypeMap.containsKey(fldAPIName) && fldAPIName.equals('NAME'))
                        fw.Edit = true;
                    else
                            fw.Edit = false;
                    fw.SystemControlled = true;
                }
                fw.exportRow = new List<String>{fw.Name
                        ,((fw.Read) ? 'Yes' : 'No')
                        ,((fw.Edit) ? 'Yes' : 'No')
                        ,((fw.SystemControlled) ? 'Yes' : 'No')
                };
                retrunFieldWrapper.add(fw);
            }
        }

        return retrunFieldWrapper;
    }

    public static String fetchUserSessionId()
    {
        String sessionId = '';

        PageReference reportPage = Page.Rv_GetSessionIdVF;
        String vfContent = '';
        if(Test.isRunningTest())
            vfContent = 'Start_Of_Session_Id'+ UserInfo.getSessionId() +'End_Of_Session_Id';
        else
                vfContent = reportPage.getContent().toString();
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endP = vfContent.indexOf('End_Of_Session_Id');
        sessionId = vfContent.substring(startP, endP);

        return sessionId;
    }

    static String getProfileAPIname (String profileName)
    {
        String profileAPIname = '';

        if(Test.isRunningTest())
        {
            profileAPIname = 'Admin';
        }
        else
        {
            try{
                HttpRequest req = new HttpRequest();
                req.setHeader('Authorization', 'Bearer ' + fetchUserSessionId());
                req.setHeader('Content-Type', 'application/json');
                String domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
                req.setEndpoint(domainUrl+'/services/data/v46.0/tooling/sobjects/Profile/'+profileName);
                req.setMethod('GET');
                Http h = new Http();
                HttpResponse res = h.send(req);
                Map<String, Object> prf = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                profileAPIname = JSON.serialize(prf.get('FullName')).replace('\"','');
            }
            catch(Exception e)
            {System.debug(e); profileAPIname = null;}
        }

        return profileAPIname;
    }

    @AuraEnabled(cacheable=true)
    public static List<TabWrapper> getTabDetails(String SearchType, String SearchParam1, String SearchParam2)
    {
        setGlobalVarFromMDT();
        List<TabWrapper> retrunTabWrapper = new List<TabWrapper>();

        AppTabMember[] tabLst = [SELECT TabDefinition.Label, TabDefinition.Name FROM AppTabMember
        WHERE AppDefinition.Label = :AppName];

        if(tabLst.size()>0)
        {
            String sessionId = fetchUserSessionId();
            Map<String,String> tabMap = new Map<String,String>();
            List<String> tabSorted = new List<String>();
            List<String> tabNames = new List<String>();
            Map<Integer,String> tabNumberedMap = new Map<Integer,String>();

            for(AppTabMember tab : tabLst)
            {
                tabMap.put(tab.TabDefinition.Label,tab.TabDefinition.Name);
                tabSorted.add(tab.TabDefinition.Label);
                tabNumberedMap.put(tabNumberedMap.size()+1,tab.TabDefinition.Name);
            }

            tabSorted.sort();
            Map<String,Boolean> tabPermMap = new Map<String,Boolean>();

            if(SearchType.equals(ProfileFilterLabel))
            {
                String profileAPIname = getProfileAPIname(SearchParam1);

                if(profileAPIname != null)
                {
                    try{
                        MetadataService.MetadataPort service = MetadataService.createService();
                        service.SessionHeader.sessionId = sessionId;

                        MetadataService.Profile ps =
                                (MetadataService.Profile) service.readMetadata('Profile',new String[] { profileAPIname }).getRecords()[0];
                        MetadataService.ProfileTabVisibility[] permTabs = ps.tabVisibilities;

                        for(MetadataService.ProfileTabVisibility c : permTabs)
                        {
                            if(tabPermMap.containsKey(c.tab))
                            {
                                if( !tabPermMap.get(c.tab) && (!c.visibility.equals('Hidden')))
                                    tabPermMap.put(c.tab,true);
                            }
                            else
                                    tabPermMap.put(c.tab,(!c.visibility.equals('Hidden'))? true : false);
                        }
                    }
                    catch(Exception e)
                    {System.debug('Profile Tabs' + e.getMessage());}
                }
            }
            else if(SearchType.equals(PermissionSetFilterLabel))
            {
                permissionset perm = [select id,name from permissionset where IsOwnedByProfile = false and id = :SearchParam1 limit 1];

                if(perm != null)
                {
                    try{
                        MetadataService.MetadataPort service = MetadataService.createService();
                        service.SessionHeader.sessionId = sessionId;

                        MetadataService.PermissionSet ps =
                                (MetadataService.PermissionSet) service.readMetadata('PermissionSet',
                                        new String[] { perm.name }).getRecords()[0];

                        MetadataService.PermissionSetTabSetting[] permTabs = ps.tabSettings;

                        for(MetadataService.PermissionSetTabSetting c : permTabs)
                        {
                            if(tabPermMap.containsKey(c.tab))
                            {
                                if( !tabPermMap.get(c.tab) && c.visibility.equals('Visible'))
                                    tabPermMap.put(c.tab,true);
                            }
                            else
                                    tabPermMap.put(c.tab,(c.visibility.equals('Visible'))? true : false);
                        }
                    }
                    catch(Exception e)
                    {System.debug('Permission Set Tabs' + e.getMessage());}
                }
            }
            else if (SearchType.equals(UserFilterLabel))
            {
                PermissionSetAssignment[] permSet = [SELECT PermissionSetId, permissionset.name
                FROM PermissionSetAssignment
                where AssigneeID = :SearchParam1 and permissionset.IsOwnedByProfile = false];
                if(permSet.size()>0)
                {
                    try{
                        List<String> permLst = new List<String>();
                        for( PermissionSetAssignment perm : permSet)
                            permLst.add(perm.permissionset.name);

                        MetadataService.MetadataPort service = MetadataService.createService();
                        service.SessionHeader.sessionId = sessionId;

                        MetadataService.PermissionSet[] psLst =
                                (MetadataService.PermissionSet[]) service.readMetadata('PermissionSet',permLst).getRecords();

                        for(MetadataService.PermissionSet ps :psLst)
                        {
                            MetadataService.PermissionSetTabSetting[] permTabs = ps.tabSettings;

                            for(MetadataService.PermissionSetTabSetting c : permTabs)
                            {
                                if(tabPermMap.containsKey(c.tab))
                                {
                                    if( !tabPermMap.get(c.tab) && c.visibility.equals('Visible'))
                                        tabPermMap.put(c.tab,true);
                                }
                                else
                                        tabPermMap.put(c.tab,(c.visibility.equals('Visible'))? true : false);
                            }
                        }
                    }
                    catch(Exception e)
                    {System.debug('Permission Set Tabs2' + e.getMessage());}
                }

                if(SearchParam2.length()>0)
                {
                    profile profId = [select id from profile where name = :SearchParam2 limit 1];
                    if(profId != null)
                    {
                        try{
                            String profileAPIname = getProfileAPIname(profId.id);

                            MetadataService.MetadataPort service = MetadataService.createService();
                            service.SessionHeader.sessionId = sessionId;

                            MetadataService.Profile ps =
                                    (MetadataService.Profile) service.readMetadata('Profile', new String[] { profileAPIname }).getRecords()[0];

                            List<MetadataService.ProfileTabVisibility> permTabs = new List<MetadataService.ProfileTabVisibility>();
                            permTabs = ps.tabVisibilities;

                            for(MetadataService.ProfileTabVisibility c : permTabs)
                            {
                                if(tabPermMap.containsKey(c.tab))
                                {
                                    if( !tabPermMap.get(c.tab) && (!c.visibility.equals('Hidden')))
                                        tabPermMap.put(c.tab,true);
                                }
                                else
                                        tabPermMap.put(c.tab,(!c.visibility.equals('Hidden'))? true : false);
                            }
                        }
                        catch(Exception e)
                        {System.debug('Profile Tabs2' + e.getMessage());}
                    }
                }
            }

            Map<String,String> tabDescriptionMap = new Map<String,String>();

            try{
                for(Integer i = 0; i<=tabNumberedMap.size()/10; i++)
                {
                    List<String> tabChunk = new List<String>();
                    for(Integer j = ((i*10)+1); j<=((i*10)+10); j++)
                    {
                        if(tabNumberedMap.containsKey(j))
                            tabChunk.add(tabNumberedMap.get(j));
                    }
                    if(tabChunk.size()>0)
                    {
                        MetadataService.MetadataPort service = MetadataService.createService();
                        service.SessionHeader.sessionId = sessionId;

                        List<MetadataService.CustomTab> custTab = (List<MetadataService.CustomTab>) service.readMetadata('CustomTab',
                                tabChunk).getRecords();
                        for(MetadataService.CustomTab ct : custTab)
                            tabDescriptionMap.put(ct.fullName,ct.Description);
                    }
                }

            }catch(Exception e){System.debug('CustomTab' + e.getMessage());}
			
            List<ObjectWrapper> objectWrapperLst = getObjectDetails(SearchType,SearchParam1,SearchParam2);
            //System.debug('-----objectWrapperLst-------'+objectWrapperLst);
            Map<String,ObjectWrapper> objWrapperMap = new Map<String,ObjectWrapper>();
            for(ObjectWrapper objWrpr: objectWrapperLst){
                //System.debug('-----objWrpr.Name-------'+objWrpr.Name);
                //System.debug('-----objWrpr.Read-------'+objWrpr.Read);
                objWrapperMap.put(objWrpr.Name, objWrpr);
            }
            
            for(String tab: tabSorted)
            {
                TabWrapper tw = new TabWrapper();
                tw.Name = tab;
                tw.Visible = false;
                tw.Description = '';
                tw.RelatedObject = '';

                if(tabDescriptionMap.containsKey(tabMap.get(tab)))
                {
                    String descr = tabDescriptionMap.get(tabMap.get(tab));
                    String fndStr = 'Related Object(s) : ';
                    if(descr != null)
                    {
                        if(descr.contains(fndStr))
                        {
                            String relatedObject = descr.mid(descr.indexOf(fndStr) + fndStr.length(), descr.length()- descr.indexOf(fndStr) - fndStr.length());
                            String RelatedObjecttemp = '';
                            //System.debug('------------'+relatedObject.split(','));
                            for(String relatedObjects : relatedObject.split(',')){
                                if(objWrapperMap.containskey(relatedObjects.trim())){
                                    if(objWrapperMap.get(relatedObjects.trim()).Read == true){
                                    	RelatedObjecttemp +=relatedObjects+';';
                                    }
                                    
                                }
                            }
                            String finalRelatedObject= '';
                            if(RelatedObjecttemp.endsWith(';')){
                                
                                finalRelatedObject = RelatedObjecttemp.removeEnd(';');
                                System.debug('-----finalRelatedObject-------'+finalRelatedObject);
                            }else{
                                finalRelatedObject = RelatedObjecttemp;
                            }
                            tw.RelatedObject = finalRelatedObject;
                            tw.Description = descr.remove(fndStr + tw.RelatedObject);
                        }
                        else
                                tw.Description = descr;
                    }
                }

                if(tabPermMap.containsKey(tabMap.get(tab)))
                    tw.Visible = tabPermMap.get(tabMap.get(tab));

                tw.exportRow = new List<String>{tw.Name
                        ,tw.Description
                        ,tw.RelatedObject
                        ,((tw.Visible) ? 'Yes' : 'No')
                };
                retrunTabWrapper.add(tw);
            }
        }

        return retrunTabWrapper;
    }

    public class ObjectWrapper
    {
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string APIName;
        @AuraEnabled
        public Boolean Read;
        @AuraEnabled
        public Boolean Create;
        @AuraEnabled
        public Boolean Edit;
        @AuraEnabled
        public Boolean Del;
        @AuraEnabled
        public Boolean ViewAll;
        @AuraEnabled
        public Boolean ModifyAll;
        @AuraEnabled
        public List<string> exportRow = new List<String>();
    }
    public class FieldWrapper
    {
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public Boolean Read;
        @AuraEnabled
        public Boolean Edit;
        @AuraEnabled
        public Boolean SystemControlled;
        @AuraEnabled
        public List<string> exportRow = new List<String>();
    }

    public class TabWrapper
    {
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string Description;
        @AuraEnabled
        public String RelatedObject;
        @AuraEnabled
        public Boolean Visible;
        @AuraEnabled
        public List<string> exportRow = new List<String>();
    }

    public class ProfileWrapper
    {
        @AuraEnabled
        public ID keyID;
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public boolean Custom;
        @AuraEnabled
        public List<string> exportRow = new List<String>();
    }

    public class PermitWrapper
    {
        @AuraEnabled
        public ID keyID;
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string Description;
        @AuraEnabled
        public List<string> exportRow = new List<String>();
    }

    public class UserPermitWrapper
    {
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string Description;
        @AuraEnabled
        public List<string> exportRow = new List<String>();
    }

    public class UserGrpWrapper
    {
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public List<string> exportRow = new List<String>();
    }

    public class UserWrapper
    {
        @AuraEnabled
        public ID keyID;
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string Username;
        @AuraEnabled
        public string Email;
        @AuraEnabled
        public string Profile;
        @AuraEnabled
        public List<string> exportRow = new List<String>();
    }

    public class UserDetailWrapper
    {
        @AuraEnabled
        public List<UserWrapper> UserWrapperLst;
        @AuraEnabled
        public List<ObjectWrapper> ObjectWrapperLst;
        @AuraEnabled
        public List<TabWrapper> TabWrapperLst;
    }

    public class UserGrpPermDetailWrapper
    {
        @AuraEnabled
        public boolean HasPermSet;
        @AuraEnabled
        public List<UserPermitWrapper> UserPermitWrapperLst;
        @AuraEnabled
        public boolean HasGrp;
        @AuraEnabled
        public List<UserGrpWrapper> UserGrpWrapperLst;
    }

    public class PageInitWrapper
    {
        @AuraEnabled
        public String AppName;
        @AuraEnabled
        public boolean HasAccess;
        @AuraEnabled
        public String ProfileFilterLabel;
        @AuraEnabled
        public String PermissionSetFilterLabel;
        @AuraEnabled
        public String UserFilterLabel;
    }
}