@isTest
public class RT_ImportFilesTest {
	/*
	Version : 0.0
	Author	: Soumyajit
	Date	: 17-Jun-2020
	Details	: Test Class for RT_CreateImportMap & RT_ImportFiles
	*/
    public static String appName = 'ImportTypeTestApp';
    
    static void setupData()
    {
        List<RT_CreateImportMap.RecordTypeWrapper> recTypes = RT_CreateImportMap.getRecordTypeList('Account');
        List<RT_CreateImportMap.ObjectWrapper> ow = RT_CreateImportMap.getObjectList('', '');
        ow = RT_CreateImportMap.getObjectList('THIS', 'Account');
        List<RT_CreateImportMap.ApexWrapper> aw = RT_CreateImportMap.getApexList('', '');
        aw = RT_CreateImportMap.getApexList('THIS', '');
        List<RT_CreateImportMap.FieldWrapper> fwLst = RT_CreateImportMap.getFieldList(ow[0].value);

        //Identifier Col
        RT_CreateImportMap.importTypeMapWrapper fld1 = new RT_CreateImportMap.importTypeMapWrapper();
        fld1.mapNum = 1 ;
        fld1.OrderNum = 1;
        fld1.SourceCol = 'Account Number';
        fld1.Identifier = true;
        fld1.FieldName = 'Account Number';
        fld1.FieldAPIName = 'AccountNumber';
        
        //Non-Nullable Col
        RT_CreateImportMap.importTypeMapWrapper fld2 = new RT_CreateImportMap.importTypeMapWrapper();
        fld2.mapNum = 2 ;
        fld2.OrderNum = 2;
        fld2.SourceCol = 'Name';
        fld2.FieldName = 'Name';
        fld2.FieldAPIName = 'Name';
        
        //Reference Col
        RT_CreateImportMap.importTypeMapWrapper fld3 = new RT_CreateImportMap.importTypeMapWrapper();
        fld3.mapNum = 3 ;
        fld3.OrderNum = 3;
        fld3.SourceCol = 'Parent Account';
        fld3.FieldName = 'Parent Account';
        fld3.FieldAPIName = 'ParentId';
        fld3.HasReference = true;
        fld3.ReferenceTo = 'Account';
        fld3.ReferenceToAPIName = 'Account';
        fld3.ReferenceToFieldName = 'Account Number';
        fld3.ReferenceToFieldAPIName = 'AccountNumber';
        
        //Fixed Col
        RT_CreateImportMap.importTypeMapWrapper fld4 = new RT_CreateImportMap.importTypeMapWrapper();
        fld4.mapNum = 4 ;
        fld4.OrderNum = 4;
        fld4.IsFixedValue = true;
        fld4.SourceCol = UserInfo.getUserId();
        fld4.FieldName = 'Owner';
        fld4.FieldAPIName = 'OwnerId';
        fld4.HasReference = true;
        fld4.ReferenceTo = 'User';
        fld4.ReferenceToAPIName = 'User';
        fld4.ReferenceToFieldName = 'ID';
        fld4.ReferenceToFieldAPIName = 'ID';
        
        //Standard Mapping Type
        RT_CreateImportMap.importTypeWrapper obj = new RT_CreateImportMap.importTypeWrapper();
        obj.Name = 'TestAccImport';
        obj.ObjectName = ow[0].label;
        obj.ObjectAPIName = ow[0].value;
        obj.ConsiderToday = true;
        obj.HasCustomLogic = false;
        if(recTypes.size()>0)
            obj.RecordTypeFilter = recTypes[0].value;
        obj.FieldMap = new List<RT_CreateImportMap.importTypeMapWrapper> {fld1,fld2,fld3,fld4};
            
        RT_CreateImportMap.saveImportMapping(JSON.serialize(obj),appName);
        
        //Custom Mapping Type
        RT_CreateImportMap.importTypeWrapper obj2 = new RT_CreateImportMap.importTypeWrapper();
        obj2 = obj;
        obj2.Name = 'Test2';
        obj2.HasCustomLogic = true;
        obj2.ApexClassName = 'RT_CallableTest';
        obj2.ApexClassMethodName = 'execute';
            
        RT_CreateImportMap.saveImportMapping(JSON.serialize(obj2),appName);
        
        //Create Parent Account
        Account acc = new Account();
        acc.AccountNumber = '999999991';
        acc.Name = 'TestAccount1';
        acc.OwnerId = UserInfo.getUserId();
        if(recTypes.size()>0)
            acc.RecordTypeId = recTypes[0].value;
        insert acc;
        
    }
    
    @isTest
    static void doTest()
    {
        RT_ImportFiles.getAppList();
       	setupData();
       
        RT_ImportFiles.pageWrapper pw = RT_ImportFiles.getPageDetails(appName);
        RT_CreateImportMap.importTypeWrapper obj = pw.ImportType[0];
        obj = RT_CreateImportMap.viewImportMapping(obj.TypeID);
        
        RT_CreateImportMap.saveImportMapping(JSON.serialize(obj),appName); //Update
        
        //header row
        List<RT_ImportFiles.fileHeaderColWrapper> headerRow = new List<RT_ImportFiles.fileHeaderColWrapper>();
        RT_ImportFiles.fileHeaderColWrapper head1 = new RT_ImportFiles.fileHeaderColWrapper();
        head1.value = 'Account Number';
        headerRow.add(head1);
        RT_ImportFiles.fileHeaderColWrapper head2 = new RT_ImportFiles.fileHeaderColWrapper();
        head2.value = 'Name';
        headerRow.add(head2);
        RT_ImportFiles.fileHeaderColWrapper head3 = new RT_ImportFiles.fileHeaderColWrapper();
        head3.value = 'Parent Account';
        headerRow.add(head3);
        
        List<RT_ImportFiles.fileBodyRowWrapper> dataRow = new List<RT_ImportFiles.fileBodyRowWrapper>();
        
        //success row
        RT_ImportFiles.fileBodyRowWrapper body1 = new RT_ImportFiles.fileBodyRowWrapper();
        List<RT_ImportFiles.fileBodyColWrapper> bodyRowCol11 = new List<RT_ImportFiles.fileBodyColWrapper>();
        RT_ImportFiles.fileBodyColWrapper bodyCol11 = new RT_ImportFiles.fileBodyColWrapper();
        bodyCol11.value = '999999992';
        bodyRowCol11.add(bodyCol11);
        RT_ImportFiles.fileBodyColWrapper bodyCol12 = new RT_ImportFiles.fileBodyColWrapper();
		bodyCol12.value = 'TestAccount2';
        bodyRowCol11.add(bodyCol12);
        RT_ImportFiles.fileBodyColWrapper bodyCol13 = new RT_ImportFiles.fileBodyColWrapper();
		bodyCol13.value = '999999991';
        bodyRowCol11.add(bodyCol13);
        body1.rowCol = bodyRowCol11;
        dataRow.add(body1);
        
        //reject row
        RT_ImportFiles.fileBodyRowWrapper body2 = new RT_ImportFiles.fileBodyRowWrapper();
        List<RT_ImportFiles.fileBodyColWrapper> bodyRowCol21 = new List<RT_ImportFiles.fileBodyColWrapper>();
        RT_ImportFiles.fileBodyColWrapper bodyCol21 = new RT_ImportFiles.fileBodyColWrapper();
        bodyCol21.value = '999999991';
        bodyRowCol21.add(bodyCol21);
        RT_ImportFiles.fileBodyColWrapper bodyCol22 = new RT_ImportFiles.fileBodyColWrapper();
		bodyCol22.value = '';
        bodyRowCol21.add(bodyCol22);
        RT_ImportFiles.fileBodyColWrapper bodyCol23 = new RT_ImportFiles.fileBodyColWrapper();
		bodyCol23.value = '';
        bodyRowCol11.add(bodyCol23);
        body2.rowCol = bodyRowCol21;
        dataRow.add(body2);
        
        //Call Standard Import
        String base64Data = RT_ImportFiles.createCSVstring(headerRow, dataRow);
        RT_ImportFiles.fileWrapper flWrap = RT_ImportFiles.uploadFile('NOW'
                                                                    ,JSON.serialize(obj)
                                                                    ,'test.csv'
                                                                    ,EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(base64Data)), 'UTF-8')
                                                                   );
        
        RT_ImportFiles.upsertFile(flWrap.ImportType.TypeID, flWrap.LogID,'test.csv');
        RT_ImportFiles.cancelSave(flWrap.LogID);
        
        Test.startTest();
        //Call Custom Import
        RT_CreateImportMap.importTypeWrapper obj2 = pw.ImportType[1];
        obj2 = RT_CreateImportMap.viewImportMapping(obj2.TypeID);
        RT_ImportFiles.fileWrapper flWrap2 = RT_ImportFiles.uploadFile('QUEUE'
                                                                    ,JSON.serialize(obj2)
                                                                    ,'test.csv'
                                                                    ,EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(base64Data)), 'UTF-8')
                                                                   );
        RT_ImportFiles.upsertFile(flWrap2.ImportType.TypeID, flWrap2.LogID,'test.csv');
        
        RT_ImportFilesQueueable q = new RT_ImportFilesQueueable(flWrap2.ImportType.TypeID, flWrap2.LogID, 'test.csv', new map<Integer,String>(), true, flWrap2.fileLines);
        q.createSplitFiles(flWrap2.LogID);
        
        RT_CreateImportMap.delImportMapping(obj2.TypeID);	//Delete
        
         RT_ImportFiles.fileWrapper flWrap3 = RT_ImportFiles.uploadFile('Scheduled'
                                                                    ,JSON.serialize(obj2)
                                                                    ,'test.csv'
                                                                    ,EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(base64Data)), 'UTF-8')
                                                                   );
        RT_ImportFiles.upsertFile(flWrap3.ImportType.TypeID, flWrap3.LogID,'test.csv');
        String scheduledString = Label.RV_ImportWizardSchedule;
        List<String> scheduledStrings = scheduledString.split('-');
        System.debug('---scheduledStrings---'+scheduledStrings);
        String hour = scheduledStrings[0];
        String min  = scheduledStrings[1];
        String ss 	= scheduledStrings[2];
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        System.schedule('Scheduled import wizard job - Split '+flWrap3.LogID,nextFireTime,new RT_ImportFileSchedulable(flWrap3.ImportType.TypeID, flWrap3.LogID, 'test.csv', new map<Integer,String>(), true, flWrap3.fileLines));
        RT_ImportLog__c importLog = [SELECT ErrorCount__c,Id,ImportStatus__c,ImportType__c,Rv_Scheduled__c,SuccessCount__c 
                                     FROM RT_ImportLog__c
                                    WHERE Id = : flWrap3.LogID];
        importLog.ImportStatus__c = 'Cancelled';
        update importLog;
        Test.stopTest();
        
        RT_ImportFiles.getRecentUploads();
    }
}