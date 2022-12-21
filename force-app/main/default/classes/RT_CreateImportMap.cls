public class RT_CreateImportMap {
    /*
	Version : 0.0
	Author	: Soumyajit
	Date	: 17-Jun-2020
	Details	: Apex controller for Import Type Mapping
	*/
    public static String global_imprtTypeSOQL = 'select id'
                                             		+',name'
                                             		+',Description__c'
                                             		+',ObjectName__c'
                                             		+',ObjectAPIName__c'
                                             		+',HasCustomLogic__c'
        											+',ConsiderToday__c'
                                             		+',ApexClass__c'
                                             		+',ApexClassMethod__c'
        											+',RecordTypeFilter__c'
                                             		+',Active__c'
        											+',ApplicationName__c'
                                             		+',(select id'
                                                    +' 		,Order__c'
                                                    +' 		,SourceColumn__c'
                                                    +' 		,IsIdentifier__c'
        											+'      ,IsFixedValue__c'
                                                    +'		,FieldName__c'
                                                    +' 		,FieldAPIName__c'
        											+'      ,ReferenceTo__c'
                                                    +'      ,ReferenceToAPIName__c'
                                                    +'      ,ReferenceToFieldName__c'
                                                    +'      ,ReferenceToFieldAPIName__c'
                                                    +' from Import_Type_Mappings__r order by Order__c) '
                                             +' from RT_ImportType__c '
                                             +' where Active__c = true';
    
    //query import defination
    public static List<RT_ImportType__c> qryImportType(String param)
    {
        List<RT_ImportType__c> returnList = new List<RT_ImportType__c>();
        try{returnList = Database.query(global_imprtTypeSOQL + param);}
        catch(Exception e){System.debug(e);}
        System.debug('--returnList---'+returnList);
        return returnList;
    }
    
    //set importType Wrapper
    public static List<importTypeWrapper> setImportTypeWrapper(String param)
    {
        List<importTypeWrapper> importType = new List<importTypeWrapper>();
        System.debug('--in setImportTypeWrapper--'+param);
        RT_ImportType__c[] importTypeRslt = qryImportType(param);
        System.debug('--importTypeRslt---'+importTypeRslt);
        for(RT_ImportType__c it : importTypeRslt)
        {
            List<importTypeMapWrapper> FieldMap = new List<importTypeMapWrapper>();
            
            List<RT_ImportTypeMapping__c> importTypeMapRslt = new List<RT_ImportTypeMapping__c>();
            importTypeMapRslt = it.Import_Type_Mappings__r;
            System.debug('---importTypeMapRslt---'+importTypeMapRslt);
            for(RT_ImportTypeMapping__c itm : importTypeMapRslt)
            {
                importTypeMapWrapper itmw = new importTypeMapWrapper();
                itmw.OrderNum = itm.Order__c;
                itmw.SourceCol = itm.SourceColumn__c;
                itmw.Identifier = itm.IsIdentifier__c;
                itmw.IsFixedValue = itm.IsFixedValue__c;
                itmw.FieldName = itm.FieldName__c;
                itmw.FieldAPIName = itm.FieldAPIName__c;
                itmw.HasReference = false;
                if(itm.ReferenceToAPIName__c != '' && itm.ReferenceToAPIName__c != null)
                    itmw.HasReference = true;
                itmw.ReferenceTo = itm.ReferenceTo__c;
                itmw.ReferenceToAPIName = itm.ReferenceToAPIName__c;
                itmw.ReferenceToFieldName = itm.ReferenceToFieldName__c;
                itmw.ReferenceToFieldAPIName = itm.ReferenceToFieldAPIName__c;
                
                try{
                String fldType = String.valueOf(Schema.getGlobalDescribe().get(it.ObjectAPIName__c).getDescribe().fields.getMap().get(itm.FieldAPIName__c).getDescribe().getType());
                    if(fldType.equalsIgnoreCase('DATE'))
                        itmw.isDate = true;
                    if(fldType.equalsIgnoreCase('DATETIME'))
                        itmw.isDateTime = true;
                    if(fldType.equalsIgnoreCase('BOOLEAN'))
                        itmw.isBoolean = true;
                }
                catch(Exception e)
                    {System.debug(e);}
                
                FieldMap.add(itmw);
            }
            
            importTypeWrapper itw = new importTypeWrapper();
            itw.TypeID = it.id;
            itw.Name = it.name;
            itw.Description = it.Description__c;
            itw.ObjectName = it.ObjectName__c;
            itw.ObjectAPIName = it.ObjectAPIName__c;
            itw.HasCustomLogic = it.HasCustomLogic__c;
            itw.ConsiderToday = it.ConsiderToday__c;
            itw.ApexClassName = it.ApexClass__c;
            itw.ApexClassMethodName = it.ApexClassMethod__c;
            itw.RecordTypeFilter = it.RecordTypeFilter__c;
            itw.FieldMap = FieldMap;
            ImportType.add(itw);
        }
        System.debug('---importType---'+importType);
        return importType;
    }
    
    //get all object list
    @AuraEnabled
    public static List<ObjectWrapper> getObjectList(String SearchType, String ObjName)
    {
        if(SearchType == null || SearchType == '')
            SearchType = 'ALL';
        
        List<ObjectWrapper> objectLst = new List<ObjectWrapper>();
        
        if(SearchType.equalsIgnoreCase('ALL'))
        {
            Map<String, Schema.SObjectType> globalSchemaDesc = Schema.getGlobalDescribe();
            List<String> sortedObjLst = new List<String>();
            sortedObjLst.addAll(globalSchemaDesc.keySet());
            sortedObjLst.sort();
            
            for(String key : sortedObjLst)
            {
                Schema.SObjectType sObj = globalSchemaDesc.get(key);
                if(!String.valueOf(sObj).endsWithIgnoreCase('__e')
                   && !String.valueOf(sObj).endsWithIgnoreCase('__mdt')
                   && !String.valueOf(sObj).endsWithIgnoreCase('Event')
                   && !String.valueOf(sObj).endsWithIgnoreCase('History')
                   && !String.valueOf(sObj).endsWithIgnoreCase('Share')
                   && !String.valueOf(sObj).endsWithIgnoreCase('Feed')
                   && !(String.valueOf(sObj).countMatches('__') >1)
                   && !sObj.getDescribe().isCustomSetting()
                  )
                {
                    ObjectWrapper ow = new ObjectWrapper();
                    ow.label = sObj.getDescribe().getLabel();
                    ow.value = String.valueOf(sObj);
                    objectLst.add(ow);
                }
            }
        }
        else
        {
            Schema.SObjectType sObj = Schema.getGlobalDescribe().get(ObjName);
            if(sObj != null)
            {
                ObjectWrapper ow = new ObjectWrapper();
                ow.label = sObj.getDescribe().getLabel();
                ow.value = String.valueOf(sObj);
                objectLst.add(ow);
            }
        }
        
        return objectLst;
    }
    
    //get recordtype list
    @AuraEnabled
    public static List<RecordTypeWrapper> getRecordTypeList(String ObjName)
    {    
        List<RecordTypeWrapper> recordTypeLst = new List<RecordTypeWrapper>();
        
        RecordType[] rtQry = [SELECT Id, Name FROM RecordType where IsActive = true and SobjectType = :ObjName order by name];
       	for(RecordType rt : rtQry)
        {
            RecordTypeWrapper rw = new RecordTypeWrapper();
            rw.label = rt.name;
            rw.value = rt.id;
            recordTypeLst.add(rw);
        }
        
        return recordTypeLst;
    }
    
    //get application list
    @AuraEnabled
    public static List<AppWrapper> getAppList()
    {    
        List<AppWrapper> appLst = new List<AppWrapper>();
        System.debug('--Inside getAppList Method--');
        AppMenuItem[] appMenuList = [SELECT Label, name FROM AppMenuItem where IsAccessible = true and Type = 'TabSet' order by label];
       	System.debug('--appMenuList--'+appMenuList);
        for(AppMenuItem a : appMenuList)
        {
            if(!(a.name.equalsIgnoreCase('AppLauncher'))
              && !(a.name.equalsIgnoreCase('AllTabSet'))
               )
            {
                AppWrapper aw = new AppWrapper();
                aw.label = a.Label;
                aw.value = a.name;
                appLst.add(aw);
            }
        }
        
        return appLst;
    }
    
    //get callable apex list
    @AuraEnabled
    public static List<ApexWrapper> getApexList(String SearchType, String ApexName)
    {
        if(SearchType == null || SearchType == '')
            SearchType = 'ALL';
        
        String apexQry = 'SELECT Id, Name, body FROM ApexClass';
        if(!SearchType.equalsIgnoreCase('ALL'))
            apexQry += ' where Name = \'' + ApexName + '\'';
        apexQry += ' order by Name';
        
        List<ApexWrapper> apexLst = new List<ApexWrapper>();
        
        ApexClass[] apexCls = Database.query(apexQry);
        for(ApexClass ac : apexCls)
        {
            if(ac.body.containsIgnoreCase('implements') 
               && ac.body.containsIgnoreCase('Callable')
               && !ac.name.equalsIgnoreCase('RT_CreateImportMap')
               && !ac.name.equalsIgnoreCase('RT_ImportFiles')
               && !ac.name.equalsIgnoreCase('RT_CallableTest'))
            {
                ApexWrapper aw = new ApexWrapper();
                aw.value = ac.name;
                aw.label = ac.name;
                apexLst.add(aw);
            }
        }
        
        return apexLst;
    }
    
    //get field list for an object
    @AuraEnabled
    public static List<FieldWrapper> getFieldList(String ObjName)
    {
        List<FieldWrapper> fieldLst = new List<FieldWrapper>();
        
        if(Schema.getGlobalDescribe().containsKey(ObjName))
        {
            Map<String, Schema.SobjectField> schFieldMap = Schema.getGlobalDescribe().get(ObjName).getDescribe().fields.getMap();

            Map<String, String> sortFldMap = new Map<String, String>();
            List<String> sortedFldLst = new List<String>();
            for(String fieldAPIName : schFieldMap.keySet())
            {
                String fieldName = schFieldMap.get(fieldAPIName).getDescribe().getLabel();
                if(sortFldMap.containsKey(fieldName))
                    fieldName += '-' + fieldAPIName;
                
                sortFldMap.put(fieldName, fieldAPIName);
            }
            
            sortedFldLst.addAll(sortFldMap.keySet());
            sortedFldLst.sort();
            
            for(String fieldName: sortedFldLst)
            {
                String fieldAPIName = sortFldMap.get(fieldName);
                
                if(!schFieldMap.get(fieldAPIName).getDescribe().isAutoNumber()
                  && !schFieldMap.get(fieldAPIName).getDescribe().isCalculated()
                  )
                {
                    FieldWrapper fw = new FieldWrapper();
                    fw.label = schFieldMap.get(fieldAPIName).getDescribe().getLabel();
                    fw.value = fieldAPIName;
                    String fldType = String.valueOf(schFieldMap.get(fieldAPIName).getDescribe().getType());
                    if(fldType.equalsIgnoreCase('DATE'))
                        fw.isDate = true;
                    if(fldType.equalsIgnoreCase('DATETIME'))
                        fw.isDateTime = true;
                    if(fldType.equalsIgnoreCase('BOOLEAN'))
                        fw.isBoolean = true;
                    
                    for(Schema.SObjectType reference : schFieldMap.get(fieldAPIName).getDescribe().getReferenceTo()) {
                        fw.refObjValue = reference.getDescribe().getName();
                        fw.refObjlabel = reference.getDescribe().getLabel();
                        fw.refFldLst = getRefFieldList(fw.refObjValue);
                    }
                    
                    fieldLst.add(fw);
                }
            }
        }

        return fieldLst;
    }
    
    //get refrence field list for an object as lookup field
    @TestVisible
    static List<RefFieldWrapper> getRefFieldList(String ObjName)
    {
        List<RefFieldWrapper> fieldLst = new List<RefFieldWrapper>();
        
        if(Schema.getGlobalDescribe().containsKey(ObjName))
        {
            Map<String, Schema.SobjectField> schFieldMap = Schema.getGlobalDescribe().get(ObjName).getDescribe().fields.getMap();
            
            Map<String, String> sortFldMap = new Map<String, String>();
            List<String> sortedFldLst = new List<String>();
            for(String fieldAPIName : schFieldMap.keySet())
            {
                String fieldName = schFieldMap.get(fieldAPIName).getDescribe().getLabel();
                if(sortFldMap.containsKey(fieldName))
                    fieldName += '-' + fieldAPIName;
                
                sortFldMap.put(fieldName, fieldAPIName);
            }
            sortedFldLst.addAll(sortFldMap.keySet());
            sortedFldLst.sort();
            
            for(String fieldName: sortedFldLst)
            {
                RefFieldWrapper fw = new RefFieldWrapper();
                fw.label = fieldName;
                fw.value = sortFldMap.get(fieldName);             
                fieldLst.add(fw);
            }
        }

        return fieldLst;
    }
    
    //view mapping defination
    @AuraEnabled
    public static importTypeWrapper viewImportMapping(String TypeID)
    {
		importTypeWrapper importType = new importTypeWrapper();
		
        List<importTypeWrapper> ImportTypeLst = setImportTypeWrapper(' and id = \'' + TypeID + '\' order by name');
        System.debug('---ImportTypeLst====='+ImportTypeLst);
        for(importTypeWrapper itWrap : ImportTypeLst)
            importType = itWrap;
        
        System.debug('===importType'+importType);
		return importType;        
    }
    
    //delete mapping defination
    @AuraEnabled
    public static void delImportMapping(String TypeID)
    {
        RT_ImportType__c[] importTypeRslt = qryImportType(' and id = \'' + TypeID + '\' limit 1');
        
        if(importTypeRslt != null)
        {
            for(RT_ImportType__c rt :importTypeRslt)
            	rt.Active__c = false;
            update importTypeRslt;
        }       
    }
    
    //upsert mapping defination
    @AuraEnabled
    public static Boolean saveImportMapping(String inputWrap, String AppName)
    {
        Boolean status = false;
        
        //verify input wrapper
        System.debug(inputWrap);
        importTypeWrapper importType = new importTypeWrapper();
        try{importType= (importTypeWrapper) JSON.deserialize(inputWrap,importTypeWrapper.Class);}
        catch(Exception e){System.debug(e);}
        
        if(importType.Name != null)
        {
            RT_ImportType__c importTypeUpsert = new RT_ImportType__c();
            List<RT_ImportTypeMapping__c> importTypeMapInsert = new List<RT_ImportTypeMapping__c>();
            
            //check if mapping master exists
            if(importType.TypeID != null && importType.TypeID != '')
            {
               RT_ImportType__c[] importTypeRslt = qryImportType(' and id = \'' + importType.TypeID + '\' limit 1');
               if(importTypeRslt != new List<RT_ImportType__c>())
               {
                   importTypeUpsert = importTypeRslt[0];
                   if(importTypeUpsert.Import_Type_Mappings__r != null)
                   	delete importTypeUpsert.Import_Type_Mappings__r;
               }
            }
            
            //build & upsert mapping master
             importTypeUpsert.name = importType.Name;
             importTypeUpsert.Description__c = importType.Description;
             importTypeUpsert.ObjectName__c = importType.ObjectName;
             importTypeUpsert.ObjectAPIName__c = importType.ObjectAPIName;
             importTypeUpsert.HasCustomLogic__c = importType.HasCustomLogic;
             importTypeUpsert.ConsiderToday__c = importType.ConsiderToday;
             importTypeUpsert.ApexClass__c = importType.ApexClassName;
             importTypeUpsert.ApexClassMethod__c = importType.ApexClassMethodName;
             importTypeUpsert.RecordTypeFilter__c = importType.RecordTypeFilter;
             importTypeUpsert.Active__c = true;
             importTypeUpsert.ApplicationName__c = AppName;
            	
            try{
                upsert importTypeUpsert;
                
                //build & insert mapping child
                for(importTypeMapWrapper itm : importType.FieldMap)
                {
                    RT_ImportTypeMapping__c impMap = new RT_ImportTypeMapping__c();
                    impMap.ImportType__c = importTypeUpsert.id;
                    impMap.Order__c = itm.OrderNum;
                    impMap.SourceColumn__c = itm.SourceCol;
                    impMap.IsIdentifier__c = itm.Identifier; 
                    impMap.IsFixedValue__c = itm.IsFixedValue; 
                    impMap.FieldName__c = itm.FieldName;
                    impMap.FieldAPIName__c = itm.FieldAPIName;
                    impMap.ReferenceTo__c = itm.ReferenceTo;
                    impMap.ReferenceToAPIName__c = itm.ReferenceToAPIName;
                    impMap.ReferenceToFieldName__c = itm.ReferenceToFieldName;
                    impMap.ReferenceToFieldAPIName__c = itm.ReferenceToFieldAPIName;
                    importTypeMapInsert.add(impMap);
                }
                if(importTypeMapInsert.size()>0)
                    insert importTypeMapInsert;
                
                status = true;
            }
            catch(Exception e){System.debug(e);}
            
        }
        return status;
    }
    
    //Application list
    public class AppWrapper
    {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    
    //object list
    public class ObjectWrapper
    {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    
    //apex list
    public class ApexWrapper
    {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    
    //recordType list
    public class RecordTypeWrapper
    {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    
    public class RefFieldWrapper
    {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    
    //field list
    public class FieldWrapper
    {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
        @AuraEnabled
        public boolean isDate = false;
        @AuraEnabled
        public boolean isDateTime = false;
        @AuraEnabled
        public boolean isBoolean = false;
        @AuraEnabled
        public string refObjlabel;
        @AuraEnabled
        public string refObjValue;
        @AuraEnabled
        public List<RefFieldWrapper> refFldLst = new List<RefFieldWrapper>();
    }
    
    //import mapping wrapper
    public class importTypeMapWrapper
    {
        @AuraEnabled
        public Integer mapNum;
        @AuraEnabled
        public Decimal OrderNum;
        @AuraEnabled
        public String SourceCol;
        @AuraEnabled
        public Boolean Identifier = false;
        @AuraEnabled
        public Boolean IsFixedValue = false;
        @AuraEnabled
        public String FieldName;
        @AuraEnabled
        public String FieldAPIName;
        @AuraEnabled
        public Boolean HasReference;
        @AuraEnabled
        public String ReferenceTo;
        @AuraEnabled
        public String ReferenceToAPIName;
        @AuraEnabled
        public String ReferenceToFieldName;
        @AuraEnabled
        public String ReferenceToFieldAPIName;
        @AuraEnabled
        public boolean isDate = false;
        @AuraEnabled
        public boolean isDateTime = false;
        @AuraEnabled
        public boolean isBoolean = false;
    }
    
    //import master wrapper
    public class importTypeWrapper
    {
        @AuraEnabled
        public String TypeID;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public String ObjectName;
        @AuraEnabled
        public String ObjectAPIName;
        @AuraEnabled
        public Boolean HasCustomLogic = false;
        @AuraEnabled
        public Boolean ConsiderToday = false;
        @AuraEnabled
        public String ApexClassName;
        @AuraEnabled
        public String ApexClassMethodName;
        @AuraEnabled
        public String RecordTypeFilter;
        @AuraEnabled
        public List<importTypeMapWrapper> FieldMap = new List<importTypeMapWrapper>();
    }
}