public class RT_ImportFiles {
    /*
	Version : 0.0
	Author	: Soumyajit
	Date	: 17-Jun-2020
	Details	: Apex controller for Import Wizard
	*/
    public static final String defaultSuccessFileName = 'Success.csv';
    public static final String defaultErrorFileName = 'Error.csv';
    public static String global_SuccessFileName = defaultSuccessFileName;
    public static String global_ErrorFileName = defaultErrorFileName;
    static final Integer global_uploadNowLimit = 100;
    static final Integer global_previewLimit = 10;
    public static final Integer global_splitFileLimit = 400;
    public static map<Integer,String> global_splitFileNameMap = new map<Integer,String>();
    
    @AuraEnabled
    public static List<RT_CreateImportMap.AppWrapper> getAppList()
    {
        System.debug('--in getAppList--');
        return RT_CreateImportMap.getAppList();
    }
    
    //initiate page wrapper
    @AuraEnabled
    public static pageWrapper getPageDetails(String appName)
    {
        pageWrapper returnWrap = new pageWrapper();
		System.debug('--in getPageDetails--');
        //query saved mappings
        returnWrap.ImportFilterList = getAllImportList(appName);
        returnWrap.ImportType = RT_CreateImportMap.setImportTypeWrapper(' and ApplicationName__c = \'' + appName + '\' order by name');
        returnWrap.uploadNowLimit = global_uploadNowLimit;
        returnWrap.previewLimit = global_previewLimit;
        
        return returnWrap;
    }
    
    @AuraEnabled
    public static List<importFilterWrapper> getAllImportList(String appName)
    {
        List<importFilterWrapper> ImportFilterList = new List<importFilterWrapper>{new importFilterWrapper()};
        
        RT_ImportType__c[] importTypeRslt = RT_CreateImportMap.qryImportType(' and ApplicationName__c = \'' + appName + '\' order by name');
        for(RT_ImportType__c it : importTypeRslt)
        {
            importFilterWrapper ul = new importFilterWrapper();
            ul.value = it.name;
            ul.label = it.name;
            ImportFilterList.add(ul);
        }
        
        return ImportFilterList;
    }
    
    //upload file
    @AuraEnabled
    public static fileWrapper uploadFile( String uploadType
                                         ,String importType
        							     ,String fileName
                                         ,String base64Data
                                       )
    {
        fileWrapper returnWrap = new fileWrapper();
        String scheduledString = Label.RV_ImportWizardSchedule;
        List<String> scheduledStrings = scheduledString.split('-');
        System.debug('---scheduledStrings---'+scheduledStrings);
        /*
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1); 
        String ss = String.valueOf(Datetime.now().second());
        */
        String hour = scheduledStrings[0];
        String min  = scheduledStrings[1];
        String ss 	= scheduledStrings[2];
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        RT_CreateImportMap.importTypeWrapper importTypeWrap = new RT_CreateImportMap.importTypeWrapper();
        try{
            importTypeWrap= (RT_CreateImportMap.importTypeWrapper) JSON.deserialize( importType ,RT_CreateImportMap.importTypeWrapper.Class);
        }
        catch(Exception e){System.debug(e);}
        System.debug('---importTypeWrap---'+importTypeWrap);		//Dharam
       	
        if(importTypeWrap != new RT_CreateImportMap.importTypeWrapper())
        {
            
            returnWrap = readFile(uploadType,fileName,base64Data,true,importTypeWrap.TypeID);
            returnWrap.ImportType = importTypeWrap;
            
            if(uploadType.equalsIgnoreCase('NOW'))
            {
                if(!returnWrap.ImportStatus.equalsIgnoreCase('Error'))
                    returnWrap = setFileWrapper(returnWrap,true);
                System.debug('---returnWrap---'+returnWrap);	
            }
            else if(uploadType.equalsIgnoreCase('QUEUE'))
            {
                if(returnWrap.isSplitUpload)
                    System.enqueueJob(new RT_ImportFilesQueueable(importTypeWrap.TypeID, returnWrap.LogID, fileName, new map<Integer,String>(), true, returnWrap.fileLines));
                else
                    System.enqueueJob(new RT_ImportFilesQueueable(importTypeWrap.TypeID, returnWrap.LogID, fileName, new map<Integer,String>(), false, new List<String>()));

            }
            else
            {
                //logic to schedule upload
             //   RT_ImportFileSchedulable job = new RT_ImportFileSchedulable();
                if(returnWrap.isSplitUpload)
                 //   new RT_ImportFileSchedulable(importTypeWrap.TypeID, returnWrap.LogID, fileName, new map<Integer,String>(), true, returnWrap.fileLines);
                	System.schedule('Scheduled import wizard job - Split '+returnWrap.LogID,nextFireTime,new RT_ImportFileSchedulable(importTypeWrap.TypeID, returnWrap.LogID, fileName, new map<Integer,String>(), true, returnWrap.fileLines));
                    else
                   // new RT_ImportFileSchedulable(importTypeWrap.TypeID, returnWrap.LogID, fileName, new map<Integer,String>(), false, new List<String>());
					System.schedule('Scheduled import wizard job '+returnWrap.LogID,nextFireTime,new RT_ImportFileSchedulable(importTypeWrap.TypeID, returnWrap.LogID, fileName, new map<Integer,String>(), false, new List<String>()));
            }
        }
        System.debug('---importTypeWrap---'+returnWrap);		//Dharam
        return returnWrap;
    }
    
    @TestVisible
    static fileWrapper readFile (String uploadType
                                 ,String fileName
                                 ,String base64Data
                                 ,Boolean createLog
                                 ,String TypeID)
    {
        fileWrapper returnWrap = new fileWrapper();
        
        //Decoding file to readable format
        System.debug('Call blobToString');
        System.debug(Limits.getHeapSize());
        String fileContent = blobToString( EncodingUtil.base64Decode(EncodingUtil.urlDecode(base64Data, 'UTF-8')),'ISO-8859-1');
        base64Data = '';	//Clear Heap
        System.debug('Call safeSplit');
        System.debug(Limits.getHeapSize());
        String[] fileLines = safeSplit(fileContent,'\n');
        map<Integer,String> acceptedFileLines = new map<Integer,String>();
        Integer lineCounter = 0;
        
        for(String line : fileLines)
        {
        	if(line.trim() != '')
            {
                acceptedFileLines.put(lineCounter,line);
                lineCounter++;
            }
        }        
        
        fileLines.clear(); //Clear Heap
        
         returnWrap.fileLines = acceptedFileLines.values();
			logWrapper log = new logWrapper();   //added by DHARAM
            if(createLog)
            {
                //logWrapper log = new logWrapper();
                log.TypeID = TypeID;
                //log.TotalRecords = lineCounter;
                log.addFile = true;
                log.fileName = fileName;
                log.fileContent = fileContent;
                System.debug('---log----'+log);
                if(uploadType.equalsIgnoreCase('NOW'))
                {
                    if(lineCounter>global_uploadNowLimit)
                    {
                        log.ImportStatus = 'Error';
                        log.errMsg = 'File is having more than ' + global_uploadNowLimit + ' records for \'Upload Now\' option';
                    }
                    else
                        log.ImportStatus = 'Draft';
                    	log.emailReady = True;
                        log = saveLog(log);
                        returnWrap.ImportType.TypeID = TypeID;
                        returnWrap.LogID = log.LogID;
                        returnWrap.ImportStatus = log.ImportStatus;
                }
                else if(uploadType.equalsIgnoreCase('QUEUE'))
                {
                    log.ImportStatus = 'In Queue';
                    log = saveLog(log);
                    returnWrap.ImportType.TypeID = TypeID;
                    returnWrap.LogID = log.LogID;
                    returnWrap.ImportStatus = log.ImportStatus;
                }
                else
                {
                    log.ImportStatus = 'Scheduled';
                    log.Scheduled = True;
                    log = saveLog(log);
                    returnWrap.ImportType.TypeID = TypeID;
                    returnWrap.LogID = log.LogID;
                    returnWrap.ImportStatus = log.ImportStatus; 
                }
                    
            }
        
        if(lineCounter > global_splitFileLimit && createLog && returnWrap.LogID != null){
            returnWrap.isSplitUpload = true;
        	log.splitUpload = True;
            log = saveLog(log);
        }   
        acceptedFileLines.clear();	//Clear Heap
        System.debug('---returnWrap---'+returnWrap);
        return returnWrap;
    }
    
    //get the file and convert to input wrapper
    public static fileWrapper setFileWrapper(fileWrapper returnWrap
                                             ,Boolean forPreview) 
    {
        List<String> fileLines = returnWrap.fileLines;
        map<Integer,String> savedFieldMap = new map<Integer,String>();
        map<Integer,String> foundFieldMap = new map<Integer,String>();
        
        if(returnWrap.ImportType != null)
        {
            for(RT_CreateImportMap.importTypeMapWrapper itmw : returnWrap.ImportType.FieldMap)
            {
                if(!itmw.IsFixedValue)
                	savedFieldMap.put(Integer.valueOf(itmw.OrderNum), itmw.SourceCol);
            }
        }
        
        System.debug(savedFieldMap);
        
        //Build input file wrapper
        //Set Header Row
        fileHeaderColWrapper headRNum = new fileHeaderColWrapper();
        headRNum.value = 'Row Number';
        returnWrap.headerRow.add(headRNum);
        
        List<String> firstDataRow = new List<String>();
        firstDataRow = fileLines[0].split(',');
        Integer headeColNum = 0;

        for(String col: firstDataRow)
        {
            headeColNum++;
            
            if(headeColNum ==1)
            {
                col = col.replace('ï»¿', '');
                col = col.replace('Ã¯Â»Â¿', '');
            }
            
            col = col.replace('\r', '');
            col = col.replace('\n', '');
            
            fileHeaderColWrapper head = new fileHeaderColWrapper();
            head.value = col;
            
            if(savedFieldMap.containsKey(headeColNum))
            {
                if(savedFieldMap.get(headeColNum).equalsIgnoreCase(col))
                {
                    head.FieldMapFound = true;
                    foundFieldMap.put(headeColNum,col);
                }
            }
            
            returnWrap.headerRow.add(head);
        }
        
        System.debug(foundFieldMap);
        
        //Set Body Row
        List<fileBodyRowWrapper> returnBodyWrap = new List<fileBodyRowWrapper>();
        for (Integer i=1;i<fileLines.size();i++)
        { 
            fileBodyRowWrapper row = new fileBodyRowWrapper();
            row.rowKey = String.valueOf(i+1);
            
            List<fileBodyColWrapper> rowCol = new List<fileBodyColWrapper>();
            
            fileBodyColWrapper colRNum = new fileBodyColWrapper();
            colRNum.value = String.valueOf(i+1);
            rowCol.add(colRNum);
            
            List<String> dataRow = new List<String>();
            if(fileLines[i] != '' && fileLines[i] != null && fileLines[i] != ' ')
            {
                dataRow = fileLines[i].split(',');
                Integer bodyColNum = 0;
                for(String dataCol: dataRow)
                {
                    
                    dataCol = dataCol.replace('\r', '');
            		dataCol = dataCol.replace('\n', '');
                    
                    bodyColNum++;
                    fileBodyColWrapper col = new fileBodyColWrapper();
                    col.value = dataCol;
                    
                    // added && foundFieldMap.size() == savedFieldMap.size() to below if condition_Dharam
                    if(foundFieldMap.containsKey(bodyColNum) && foundFieldMap.size() == savedFieldMap.size())
                    {	
                        col.FieldMapFound = true;
                    }else{
                        col.FieldMapFound = false;
                    }
                    
                    rowCol.add(col);
                }
                
                row.rowCol = rowCol;
                returnBodyWrap.add(row);
            }
            
            if(forPreview && i==global_previewLimit)
                break;
        }
        
        returnWrap.bodyRow = returnBodyWrap;
        System.debug('---returnWrap Dharam---'+returnWrap);
        return returnWrap;
    }
    
    //cancel save file
    @AuraEnabled
    public static void cancelSave(String LogID) 
    {     
        if(LogID != null)
        {
            logWrapper log = new logWrapper();
            log.LogID = LogID;
            log.ImportStatus = 'Cancelled';
            log.addFile = false;
            log = saveLog(log);
        }
    }
    
    //save file into salsforce
    @AuraEnabled
    public static resultWrapper upsertFile(String TypeID, String LogID, String fileName) 
    {
        resultWrapper returnResult = new resultWrapper();
        resultFileWrapper result = new resultFileWrapper();
		
        fileWrapper inputFileWrapper = new fileWrapper();
        logWrapper log = new logWrapper();
        
        System.debug('TypeID='+TypeID);
        System.debug('LogID='+LogID);
        System.debug('fileName=' + fileName);
        
        if(TypeID != null && LogID != null)
        {
            log.TypeID = TypeID;
            log.LogID = LogID;
            log.ImportStatus = 'In Progress';
            log.addFile = false;
            log = saveLog(log);

            String fileContent = readLogFile(ID.valueOf(LogID), fileName);
            inputFileWrapper = readFile('',fileName,fileContent, false, TypeID);
            inputFileWrapper.importType = RT_CreateImportMap.viewImportMapping(TypeID);
            inputFileWrapper = setFileWrapper(inputFileWrapper,false);
            inputFileWrapper.LogID = LogID;
        }
        System.debug('--inputFileWrapper--=' + inputFileWrapper);
        returnResult.LogID = LogID;
        System.debug('--returnResult.LogID--=' + returnResult.LogID);
        if(inputFileWrapper != new fileWrapper())
        {
            //filter and send mapped columns only
            fileWrapper inputNewFileWrapper = new fileWrapper();
            inputNewFileWrapper = inputFileWrapper;
            System.debug('--inputNewFileWrapper--=' + inputNewFileWrapper);
            List<fileHeaderColWrapper> newHeaderRow = new List<fileHeaderColWrapper>();
            for(fileHeaderColWrapper fh : inputFileWrapper.headerRow)
            {
                if(fh.FieldMapFound) 
                    newHeaderRow.add(fh);
            }
            inputNewFileWrapper.headerRow = newHeaderRow;
            System.debug('--newHeaderRow--=' + newHeaderRow);
            System.debug('--inputNewFileWrapper.headerRow--=' + inputNewFileWrapper.headerRow);
            System.debug('--inputNewFileWrapper.bodyRow--=' + inputNewFileWrapper.bodyRow);
            for(fileBodyRowWrapper fb : inputNewFileWrapper.bodyRow)
            {
                List<fileBodyColWrapper> newBodyCol = new List<fileBodyColWrapper>();
                for(fileBodyColWrapper fbc: fb.rowCol)
                {
                    if(fbc.FieldMapFound) 
                        newBodyCol.add(fbc);
                }
                fb.rowCol = newBodyCol;
            }
            
            //build result file headers
            
                result.successHeaderRow.addAll(inputNewFileWrapper.headerRow);
                result.errorHeaderRow.addAll(inputNewFileWrapper.headerRow);
            System.debug('--result success--'+result.successHeaderRow);		//Dharam
            System.debug('--result Error--'+result.errorHeaderRow);		//Dharam
            System.debug('--inputNewFileWrapper--'+inputNewFileWrapper);		//Dharam
            //mapping to follow custom implementation
            if(inputNewFileWrapper.ImportType.HasCustomLogic 
               && inputNewFileWrapper.ImportType.ApexClassName != null
              && inputNewFileWrapper.ImportType.ApexClassMethodName != null)
            {
                try{
                    System.debug('Calling Custom Class');
                    
                    //find callable class and call
                    Type className = Type.forName(inputNewFileWrapper.ImportType.ApexClassName);
                    Callable extension = (Callable) className.newInstance();
                    
                    result = (resultFileWrapper) extension.call(inputNewFileWrapper.ImportType.ApexClassMethodName
                                                                , new Map<String, Object> {
                                                                	inputNewFileWrapper.ImportType.ApexClassMethodName => inputNewFileWrapper}
                                                               );
                    returnResult.status = true;
            		returnResult.statusMsg = 'File Has Been Sent for Custom Insert';
                }
                catch(Exception e)
                {
                    System.debug(e);
                    returnResult.status = false;
            		returnResult.statusMsg = e.getMessage();
                    result.errorBodyRow.addAll(inputNewFileWrapper.bodyRow);
                    returnResult.errorString = createCSVstring(result.errorHeaderRow, result.errorBodyRow);
                }
                
                //Save Logs
                if(TypeID != null && LogID != null && result != null)
                {
                    log.TypeID = TypeID;
                    log.LogID = LogID;
                    log.ImportStatus = 'Completed';
                    //log.SuccessCount = 0;
                    //log.ErrorCount = 0;
                    System.debug('----result----'+result);
                    System.debug('----returnResult----'+returnResult);
                    if(result.successBodyRow != null)
                    {
                        //log.SuccessCount = result.successBodyRow.size();
                        log.addFile = true;
                        log.fileName = returnResult.successFileName;
                        log.fileContent = returnResult.successString;
                        log = saveLog(log);
                    }
                    
                    if(result.errorBodyRow != null)
                    {
                        //log.ErrorCount = result.errorBodyRow.size();
                        log.addFile = true;
                        log.fileName = returnResult.errorFileName;
                        log.fileContent = returnResult.errorString;
                        log = saveLog(log);
                    }
                }
                
            }
            //mapping to follow standard upsert
            else if ( !inputNewFileWrapper.ImportType.HasCustomLogic 
               && inputNewFileWrapper.ImportType.ObjectAPIName != null
              && inputNewFileWrapper.ImportType.FieldMap != null)
            {
                System.debug('Going for Standard Import');
                try{
                returnResult = doStandardImport(inputNewFileWrapper);
                }
                catch(exception e)
                {
                    System.debug(e.getStackTraceString());
                        log.ImportStatus = 'Error';
                        log.addFile = false;
                        log.errMsg = e.getMessage();
                        log = RT_ImportFiles.saveLog(log);
                }
            }
            //else reject all
            else
            {
                System.debug('Inside Else');
                returnResult.status = false;
            	returnResult.statusMsg = 'Insert Mapping Not Found';
                result.errorBodyRow.addAll(inputNewFileWrapper.bodyRow);
                returnResult.errorString = createCSVstring(result.errorHeaderRow, result.errorBodyRow);
                
                //Save Logs
                if(TypeID != null && LogID != null && result != null)
                {
                    log.TypeID = TypeID;
                    log.LogID = LogID;
                    log.ImportStatus = 'Completed';
                    //log.SuccessCount = 0;
                    //log.ErrorCount = 0;
                    
                    if(result.errorBodyRow != null)
                    {
                        //log.ErrorCount = result.errorBodyRow.size();
                        log.addFile = true;
                        log.fileName = returnResult.errorFileName;
                        log.fileContent = returnResult.errorString;
                        log = saveLog(log);
                    }
                }
            }
        }
        System.debug('---returnResult---'+returnResult);
        return returnResult;
    }
    
    //Standard import Logic
    static resultWrapper doStandardImport(fileWrapper inputNewFileWrapper)
    {
        resultWrapper returnResult = new resultWrapper();
        resultFileWrapper result = new resultFileWrapper();
        
            result.successHeaderRow.addAll(inputNewFileWrapper.headerRow);
            result.errorHeaderRow.addAll(inputNewFileWrapper.headerRow);
        
        ID TypeID = inputNewFileWrapper.ImportType.TypeID;
        ID LogID = inputNewFileWrapper.LogID;
        logWrapper log = new logWrapper();
        returnResult.LogID = LogID;
        
        try{
                    //get object name & fields
                    String objAPIName = inputNewFileWrapper.ImportType.ObjectAPIName;
                    SObjectType objType = Schema.getGlobalDescribe().get(objAPIName);
                    Map<String, Schema.SobjectField> objFldMap = Schema.getGlobalDescribe().get(objAPIName).getDescribe().fields.getMap();
                        
                    map<Integer,String> fieldNameMap = new map<Integer,String>();
            		map<String,List<String>> refFieldNameMap = new map<String,List<String>>();
                    List<String> identifierLst = new List<String>();
            		map<String,String> fixedInputMap = new map<String,String>();
                    for(Integer i=0; i < inputNewFileWrapper.ImportType.FieldMap.size(); i++)
                    {
                        String fldAPIName = inputNewFileWrapper.ImportType.FieldMap[i].FieldAPIName;
                        String fldType = String.valueOf(objFldMap.get(fldAPIName).getDescribe().getType());
                        fieldNameMap.put(i, fldAPIName);
                        
                        if(inputNewFileWrapper.ImportType.FieldMap[i].HasReference)
                            refFieldNameMap.put(fldAPIName, new List<String>{inputNewFileWrapper.ImportType.FieldMap[i].ReferenceToAPIName
                                											,inputNewFileWrapper.ImportType.FieldMap[i].ReferenceToFieldAPIName}
                                               );
                        
                        if(inputNewFileWrapper.ImportType.FieldMap[i].Identifier)
                            identifierLst.add(fldAPIName);
                        
                        if(inputNewFileWrapper.ImportType.FieldMap[i].IsFixedValue)
                            fixedInputMap.put(fldAPIName,inputNewFileWrapper.ImportType.FieldMap[i].SourceCol);
                    }
                    
                    //Set Reference Column Field Values for query
                    map<String,map<String,refDataWrapper>> refValueMap = new map<String,map<String,refDataWrapper>>();
            		if(refFieldNameMap.size()>0)
                    {
                        for(Integer rowNum = 0; rowNum < inputNewFileWrapper.bodyRow.size(); rowNum++)
                        {
                            fileBodyRowWrapper rowValue = inputNewFileWrapper.bodyRow[rowNum];
                            
                            for(Integer colNum = 0; colNum < rowValue.rowCol.size(); colNum++)
                            {
                                String colValue = rowValue.rowCol[colNum].value;
                                if(colValue != null && colValue!='')
                                {
                                    String fieldAPIName = fieldNameMap.get(colNum);
                                    if(refFieldNameMap.containsKey(fieldAPIName))
                                    {
                                        String refObjAPIName = refFieldNameMap.get(fieldAPIName)[0];
                                        String refFldAPIName = refFieldNameMap.get(fieldAPIName)[1];
                                        String refFldType = String.valueOf(Schema.getGlobalDescribe().get(refObjAPIName).getDescribe().fields.getMap()
                                                                        .get(refFldAPIName).getDescribe().getType());
                                        
                                        Object convColValue = getConvertedValue(refFldType, colValue);
                                        
                                        refDataWrapper rw = new refDataWrapper();
                                        rw.objName = refObjAPIName;
                                        rw.fldName = refFldAPIName;
                                        rw.valMap.put(convColValue,null);
                                        
                                        String key = rw.objName+'-'+rw.fldName;
                                        map<String,refDataWrapper> valMapWrap = new map<String,refDataWrapper>();
                                        if(refValueMap.containsKey(fieldAPIName))
                                        {
                                            valMapWrap = refValueMap.get(fieldAPIName);
     
                                            if(valMapWrap.containsKey(key))
                                            {
                                               rw = valMapWrap.get(key);
                                               rw.valMap.put(convColValue,null);
                                            }
                                        }
                                        valMapWrap.put(key, rw);
                                        refValueMap.put(fieldAPIName,valMapWrap);
                                    }             
                                }
                             }
                         }
                    }
            
            		if(refValueMap.size()>0)
                        refValueMap = getReferenceMap(refValueMap);
            
            		map<sObject,fileBodyRowWrapper> inputBodyMap= new map<sObject,fileBodyRowWrapper>();
                    List<sObject> dmlLst = new List<sObject>();
                    map<String,List<Object>> identifierMap = new map<String,List<Object>>();
            
                    //start iteration for each row
                    for(Integer rowNum = 0; rowNum < inputNewFileWrapper.bodyRow.size(); rowNum++)
                    {
                        Boolean recordFound = false;
                        SObject sObj = objType.newsObject();
                        List<String> errMsg = new List<String>();
                        fileBodyRowWrapper rowValue = inputNewFileWrapper.bodyRow[rowNum];
                        
                        //start iteration for each column
                        for(Integer colNum = 0; colNum < rowValue.rowCol.size(); colNum++)
                        {
                            String colValue = rowValue.rowCol[colNum].value;
                            
                            //if column found in mapping, save value for upsert
                            if(fieldNameMap.containsKey(colNum))
                            {
                                try
                                {
                                    if(colValue != null && colValue!='')
                                    {
                                        String fieldAPIName = fieldNameMap.get(colNum);
                                        String fldType = String.valueOf(objFldMap.get(fieldAPIName).getDescribe().getType());
                                        Object convColValue = getConvertedValue(fldType, colValue);
                                        
                                        if(refValueMap.containsKey(fieldAPIName) && refFieldNameMap.containsKey(fieldAPIName))
                                        {
                                            //System.debug(refValueMap.get(fieldAPIName));
                                            String wrapKey = refFieldNameMap.get(fieldAPIName)[0] + '-' + refFieldNameMap.get(fieldAPIName)[1];
                                            if(refValueMap.get(fieldAPIName).containsKey(wrapKey))
                                            {
                                                if(refValueMap.get(fieldAPIName).get(wrapKey).valMap.containsKey(convColValue))
                                                {
                                                    if(refValueMap.get(fieldAPIName).get(wrapKey).valMap.get(convColValue) != null)
                                                    	convColValue = refValueMap.get(fieldAPIName).get(wrapKey).valMap.get(convColValue);
                                                    else
                                                		{errMsg.add(colValue + ' is not found in ' + wrapKey);break;}
                                                }
                                                else
                                                {errMsg.add(colValue + ' is not found in ' + wrapKey);break;}
                                            }
                                            else
                                            	{errMsg.add(colValue + ' is not found in ' + wrapKey);break;}
                                        }
                                        
                                        sObj.put(fieldAPIName,convColValue);
                                        
                                            if(identifierLst.contains(fieldAPIName))
                                            {
                                                if(identifierMap.containsKey(fieldAPIName))
                                                {
                                                    List<Object> valueLst = identifierMap.get(fieldAPIName);
                                                    if(!valueLst.contains(convColValue))
                                                        valueLst.add(convColValue);
                                                    identifierMap.put(fieldAPIName, valueLst);
                                                }
                                                else
                                                	identifierMap.put(fieldAPIName, new List<Object>{convColValue});
                                            }
                                    }
                                    
                                    if(!recordFound)
                                        recordFound = true;
                                 }
                                 catch(Exception e)
                                 {
                                     System.debug(e);
                                     System.debug(e.getStackTraceString());
                                     System.debug(e.getLineNumber());
                                     recordFound = false;
                                     errMsg.add(e.getMessage());
                                 }
                             }  
                        }
                        
                        //if row found in mapping, go for dml
                        if(recordFound && errMsg.isEmpty())
                        {
                            inputBodyMap.put(sObj,rowValue);
                            
                            if(inputNewFileWrapper.ImportType.RecordTypeFilter != '' && inputNewFileWrapper.ImportType.RecordTypeFilter != null)
                                sObj.put('RecordTypeId',ID.ValueOf(inputNewFileWrapper.ImportType.RecordTypeFilter));
                            
                            for(String fieldAPIName : fixedInputMap.keyset())
                            {
                                String fixedColValue = fixedInputMap.get(fieldAPIName);
                                String fldType = String.valueOf(objFldMap.get(fieldAPIName).getDescribe().getType());
                                Object convColValue = getConvertedValue(fldType, fixedColValue);
                                sObj.put(fieldAPIName,convColValue);
                                
                                if(identifierLst.contains(fieldAPIName))
                                {
                                    if(identifierMap.containsKey(fieldAPIName))
                                    {
                                        List<Object> valueLst = identifierMap.get(fieldAPIName);
                                        if(!valueLst.contains(convColValue))
                                            valueLst.add(convColValue);
                                        identifierMap.put(fieldAPIName, valueLst);
                                    }
                                    else
                                        identifierMap.put(fieldAPIName, new List<Object>{convColValue});
                                }
                            }
                            
                            dmlLst.add(sObj);
                        }
                        //else reject row
                        else
                        {
                            String allErrMsg = '';
                            for(String err : errMsg)
                                allErrMsg += (err + ';');
                            
                            fileBodyColWrapper errCol = new fileBodyColWrapper();
                            errCol.value = allErrMsg;
                            rowValue.rowCol.add(errCol);
                            result.errorBodyRow.add(rowValue);
                        }
                           
                    }
                    
            		map<ID,String> successMap = new map<ID,String>();
            
                    if(dmlLst.size()>0)
                    {
                        //get existing records
                        map<String,sObject> existLstMap= new map<String,sObject>();
                        if(identifierMap.size()>0)
                        {
                            String objQry = 'select id';
                            for(Integer key :fieldNameMap.keySet())
                                if(fieldNameMap.get(key) != 'Id'){
                                    objQry += (',' + fieldNameMap.get(key));
                                }
                                
                            objQry += ' from ' + objAPIName;
                            objQry += ' where ';
                            
                            Integer fldIndex = 0;
                            for(String fld : identifierMap.keySet())
                            {
                                Boolean addColon = false;
                                String fldType = String.valueOf(objFldMap.get(fld).getDescribe().getType());
                                if(fldType.equalsIgnoreCase('STRING') 
                                   || fldType.equalsIgnoreCase('ID') 
                                   || fldType.equalsIgnoreCase('REFERENCE')
                                   || fldType.equalsIgnoreCase('PICKLIST')
                                   || fldType.equalsIgnoreCase('MULTIPICKLIST')
                                   || fldType.equalsIgnoreCase('EMAIL')
                                   || fldType.equalsIgnoreCase('PHONE')
                                   || fldType.equalsIgnoreCase('URL')
                                  )
                                    addColon = true;
                                
                                objQry += fld + ' in (' ;
                                for(Integer i=0;i <identifierMap.get(fld).size(); i++)
                                {
                                    if(addColon) objQry += '\'';
                                    if(!String.valueof(identifierMap.get(fld)[i]).equalsIgnorecase('null'))
                                    	objQry += identifierMap.get(fld)[i];
                                    if(addColon) objQry += '\'';
                                    if((i != identifierMap.get(fld).size()-1))
                                        objQry += ', ';
                                }                                
                                objQry += ') ';
                                
                                if(fldIndex < identifierMap.size()-1)
                                    objQry += ' and ';
                                
                                fldIndex++;
                            }
                            if(inputNewFileWrapper.importType.ConsiderToday)
                            	objQry += ' and lastmodifieddate = today' ;
                            
                            System.debug('---objQry---'+objQry);
                            
                            List<sObject> existLst = new List<sObject>();
                            existLst = Database.query(objQry);
                            if(existLst.size()>0)
                            {
                                for(Sobject data : existLst)
                                {
                                    String key = '';
                                    for(String ident : identifierLst)
                                        key += String.valueOf(data.get(ident));
                                    existLstMap.put(key, data);
                                }
                            }
                        }

                        List<sObject> insertLst = new List<sObject>();
                    	List<sObject> updateLst = new List<sObject>();
                        map<String,sObject> updateMap = new map<String,sObject>();
                        
                        //seggregrate insert update list
                        for(sObject sobj : dmlLst)
                        {
                            if(identifierMap.size() > 0 && existLstMap.size()>0)
                            {
                                String keyField = '';
                                
                                for(String fld : identifierMap.keySet())
                                    keyField += sobj.get(fld);
                                
                                if(keyField.length()>0 && existLstMap.containsKey(keyField))
                                {
                                    SObject sObjExist = existLstMap.get(keyField);
                                    for(Integer i=0; i < inputNewFileWrapper.ImportType.FieldMap.size(); i++)
                                    {
                                        if(!inputNewFileWrapper.ImportType.FieldMap[i].Identifier)
                                        {
                                            String fldAPIName = inputNewFileWrapper.ImportType.FieldMap[i].FieldAPIName;
                                            sObjExist.put(fldAPIName,sObj.get(fldAPIName));
                                        }
                                    }
                                   
                                    if(!updateMap.containsKey(String.valueof(sObjExist.get('ID'))))
                                    	updateMap.put(String.valueof(sObjExist.get('ID')),sObjExist);
                                    else
                                    {
                                        fileBodyRowWrapper rowValue = new fileBodyRowWrapper();
                                        fileBodyColWrapper errCol = new fileBodyColWrapper();
                                        errCol.value = 'Update : Duplicate Row In File For ID = ' + String.valueof(sObjExist.get('ID'));
                                        rowValue.rowCol.add(errCol);
                                        result.errorBodyRow.add(rowValue);
                                    }
                                }
                                else
                                {
                                    if(!insertLst.contains(sObj))
                                    	insertLst.add(sObj);
                                    else
                                    {
                                        fileBodyRowWrapper rowValue = new fileBodyRowWrapper();
                                        fileBodyColWrapper errCol = new fileBodyColWrapper();
                                        errCol.value = 'Insert : Duplicate Row In File';
                                        rowValue.rowCol.add(errCol);
                                        result.errorBodyRow.add(rowValue);
                                    }
                                }
                            }
                            else
                            {
                                if(!insertLst.contains(sObj))
                                	insertLst.add(sObj);
                                else
                                    {
                                        fileBodyRowWrapper rowValue = new fileBodyRowWrapper();
                                        fileBodyColWrapper errCol = new fileBodyColWrapper();
                                        errCol.value = 'Insert : Duplicate Row In File';
                                        rowValue.rowCol.add(errCol);
                                        result.errorBodyRow.add(rowValue);
                                    }
                            }
                        }
                        
                        if(updateMap.size()>0)
                    		updateLst.addAll(updateMap.values());
                        
                        //perform dml
                        map<String,List<Database.SaveResult>> dmlResult = new map<String,List<Database.SaveResult>>();
                        if(insertLst.size()>0)
                            dmlResult.put('INSERT',Database.insert(insertLst,false));
                        
                        if(updateLst.size()>0)
                            dmlResult.put('UPDATE',Database.update(updateLst,false));
                        
                        //check dml results
                        if(dmlResult.size()>0)
                        {
                            for(String key : dmlResult.keySet())
                            {
                                Integer index = 0;
                                for (Database.SaveResult sr : dmlResult.get(key))
                                {
                                    if (sr.isSuccess())
                                    {
                                        successMap.put(sr.getId(),key);
                                    }
                                    else
                                    {
                                        for(Database.Error err : sr.getErrors()) 
                                        {
                                            fileBodyRowWrapper rowValue = new fileBodyRowWrapper();
                                            
                                            if(key.equals('INSERT'))
                                            {
                                                if(insertLst.size()>index)
                                                {
                                                    if(inputBodyMap.containsKey(insertLst[index]))
                                                        rowValue = inputBodyMap.get(insertLst[index]);
                                                }
                                            }
                                            
                                            if(key.equals('UPDATE'))
                                            {
                                                if(updateLst.size()>index)
                                                {
                                                    if(inputBodyMap.containsKey(updateLst[index]))
                                                        rowValue = inputBodyMap.get(updateLst[index]);
                                                }
                                            }
                                            fileBodyColWrapper errCol = new fileBodyColWrapper();
                                            errCol.value = key + ' : ' + err.getStatusCode() +': ' + err.getFields() +': ' + err.getMessage();
                                            rowValue.rowCol.add(errCol);
                                            result.errorBodyRow.add(rowValue);
                                        }
                                    }
                                    index++;
                                }
                            }
                        }
                    }
                    
                    //success records found
                    system.debug('--success count--'+successMap.size());
                    if(successMap.size()>0)
                    {
                        result.successHeaderRow.clear();
                        String objQry = 'select ';
                        
                        for(Integer i=0; i < inputNewFileWrapper.ImportType.FieldMap.size(); i++)
                        {
                            String fldAPIName = inputNewFileWrapper.ImportType.FieldMap[i].FieldAPIName;
                            
                            if(i!=0)
                                objQry += ',';
                            objQry += fldAPIName;
                            
                                fileHeaderColWrapper sourceCol = new fileHeaderColWrapper();
                                sourceCol.value=inputNewFileWrapper.ImportType.FieldMap[i].SourceCol;
                                if(inputNewFileWrapper.ImportType.FieldMap[i].IsFixedValue)
                                    sourceCol.value= inputNewFileWrapper.ImportType.FieldMap[i].FieldName;
                                result.successHeaderRow.add(sourceCol);
                        }
                        
                            fileHeaderColWrapper idCol = new fileHeaderColWrapper();
                            idCol.value='ID';
                            result.successHeaderRow.add(idCol);
                            fileHeaderColWrapper operCol = new fileHeaderColWrapper();
                            operCol.value='OPERATION';
                            result.successHeaderRow.add(operCol);
                        
                        objQry += ' from ' + objAPIName + ' where ID in (';
                        
                        Integer keyCnt = 0;
                        for(ID keyID : successMap.keySet())
                        {
                            objQry += '\'';
                            objQry += keyID;
                            objQry += '\'';
                            if(keyCnt != successMap.size()-1) objQry += ', ';
                            keyCnt++;
                        }
                        
                        objQry += ')';
                        
                        System.debug('successQry ' +objQry);
                        List<sObject> qryLst = new List<sObject>();
                        qryLst = Database.query(objQry);
                        
                        if(qryLst.size()>0)
                        {
                            for(Sobject data : qryLst)
                            {
                                fileBodyRowWrapper rowValue = new fileBodyRowWrapper();
                                for(Integer i=0; i < inputNewFileWrapper.ImportType.FieldMap.size(); i++)
                                {
                                    String fieldAPIName = inputNewFileWrapper.ImportType.FieldMap[i].FieldAPIName;

                                    fileBodyColWrapper valCol = new fileBodyColWrapper();
                                    valCol.value = String.valueOf(data.get(fieldAPIName));
                                    
									if(refValueMap.containsKey(fieldAPIName) && refFieldNameMap.containsKey(fieldAPIName))
                                    {
                                        String wrapKey = refFieldNameMap.get(fieldAPIName)[0] + '-' + refFieldNameMap.get(fieldAPIName)[1];
                                        if(refValueMap.get(fieldAPIName).containsKey(wrapKey))
                                        {
                                            for(Object key : refValueMap.get(fieldAPIName).get(wrapKey).valMap.keySet())
                                            {
                                                if(String.valueOf(refValueMap.get(fieldAPIName).get(wrapKey).valMap.get(key)) == 
                                                  String.valueOf(data.get(fieldAPIName)))
                                                {valCol.value = String.valueOf(key);break;}
                                            }
                                        }
                                    }
                                    rowValue.rowCol.add(valCol);
                                        
                                }
                            
                                 ID keyID = ID.valueOf(String.valueOf(data.get('ID')));
                                 fileBodyColWrapper idColumn = new fileBodyColWrapper();
                                 idColumn.value = String.valueOf(keyID);
                                 rowValue.rowCol.add(idColumn);
                                 fileBodyColWrapper operateColumn = new fileBodyColWrapper();
                                 operateColumn.value = successMap.get(keyID);
                                 rowValue.rowCol.add(operateColumn);
                                 result.successBodyRow.add(rowValue);
                            }
                        }
                        
                        returnResult.status = true;
                        returnResult.statusMsg = 'Records Have Been Saved Successfully';
                    }
            
                    //error records found
                    System.debug('--error count--'+result.errorBodyRow.size());
                    if(result.errorBodyRow.size()>0)
                    {
                            fileHeaderColWrapper errCol = new fileHeaderColWrapper();
                            errCol.value='ERROR';
                            result.errorHeaderRow.add(errCol);
                        
                        returnResult.status = false;
                        returnResult.statusMsg = 'Some Record(s) Errored Out. Please Refer Error Log File';
                    }

                    //build output
                	returnResult.successString = createCSVstring(result.successHeaderRow, result.successBodyRow);
            		returnResult.errorString = createCSVstring(result.errorHeaderRow, result.errorBodyRow);
                }
                catch(Exception e)
                {
                    //System.debug(e);
                   // System.debug(e.getStackTraceString());
                    returnResult.status = false;
            		returnResult.statusMsg = e.getMessage();
                    result.errorBodyRow.addAll(inputNewFileWrapper.bodyRow);
                    returnResult.errorString = createCSVstring(result.errorHeaderRow, result.errorBodyRow);
                }
        
        if(TypeID != null && LogID != null && result != null)
        {
            log.TypeID = TypeID;
            log.LogID = LogID;
            log.ImportStatus = 'Completed';
            log.SuccessCount = 0;		//Dharam : uncommented
            log.ErrorCount = 0;			//Dharam : uncommented
            
            if(result.successBodyRow != null)
            {
            	log.SuccessCount = result.successBodyRow.size();	//Dharam : uncommented
                log.addFile = true;
                log.fileName = returnResult.successFileName;
                log.fileContent = returnResult.successString;
                if(result.errorBodyRow != null){
                    log.ImportStatus = 'In Progress';
                }
                log = saveLog(log);
            }
            
            if(result.errorBodyRow != null)
            {
                log.ErrorCount = result.errorBodyRow.size();	//Dharam : uncommented
                log.addFile = true;
                log.fileName = returnResult.errorFileName;
                log.fileContent = returnResult.errorString;
                log.ImportStatus = 'Completed';
                log = saveLog(log);
            }
        }
        
        return returnResult;
    }
    
    class refDataWrapper
    {
        String objName;
        String fldName;
        map<Object,ID> valMap = new map<Object,ID>();
    }
    
    @TestVisible
    static map<String,map<String,refDataWrapper>> getReferenceMap(map<String,map<String,refDataWrapper>> refValueMap)
    {
        map<String,map<String,refDataWrapper>> returnWrap = new map<String,map<String,refDataWrapper>>();
        
        for(String mainKey : refValueMap.keySet())
        {
            map<String,refDataWrapper> refFldMap = refValueMap.get(mainKey);
            
            for(String key : refFldMap.keySet())
            {
                String objName = refFldMap.get(key).objName;
                String fldName = refFldMap.get(key).fldName;
                map<Object,ID> valMap = refFldMap.get(key).valMap;
                
                if(valMap.size()>0)
                {
                    Map<String, Schema.SobjectField> objFldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
                    String fldType = String.valueOf(objFldMap.get(fldName).getDescribe().getType());
                    Boolean addColon = false;
                    if(fldType.equalsIgnoreCase('STRING') 
                                   || fldType.equalsIgnoreCase('ID') 
                                   || fldType.equalsIgnoreCase('REFERENCE')
                                   || fldType.equalsIgnoreCase('PICKLIST')
                                   || fldType.equalsIgnoreCase('MULTIPICKLIST')
                                   || fldType.equalsIgnoreCase('EMAIL')
                                   || fldType.equalsIgnoreCase('PHONE')
                                   || fldType.equalsIgnoreCase('URL')
                      )
                        addColon = true;
                    
                    String objQry;
                    if (!fldName.equalsIgnoreCase('Id')) {
                        objQry = 'select id, ' + fldName + ' from ' + objName + ' where ' + fldName + ' in (';
                        Integer i=0;
                        for(Object valKey : valMap.keySet())
                        {
                            if(addColon) objQry += '\'';
                            objQry += valKey;
                            if(addColon) objQry += '\'';
                            if((i != valMap.size()-1)) objQry += ', ';
                            
                            i++;
                        }
                        
                        objQry += ') ';
                    }else {
                        objQry = 'select ' + fldName + ' from ' + objName + ' where ' + fldName + ' in (';
                        Integer i=0;
                        for(Object valKey : valMap.keySet())
                        {
                            if(addColon) objQry += '\'';
                            objQry += valKey;
                            if(addColon) objQry += '\'';
                            if((i != valMap.size()-1)) objQry += ', ';
                            
                            i++;
                        }
                        
                        objQry += ') ';
                    }
                    
                    /*query design updated to avoid query duplication issue_Dharam */
                    
                    System.debug('ref qry=' +objQry);
                    List<sObject> qryLst = new List<sObject>();
                    qryLst = Database.query(objQry);
                    
                    System.debug('ref qry result=' + qryLst);
                    
                    if(qryLst.size()>0)
                    {
                        for(Sobject data : qryLst)
                        {
                            Object valKey = data.get(fldName);
                            if(valMap.containsKey(valKey))
                                valMap.put(valKey,ID.valueOf(String.valueOf(data.get('ID'))));
                        }
                    }
                }
                
                refFldMap.get(key).valMap = valMap;
                refValueMap.put(mainKey,refFldMap);
            }
            
        }
        return refValueMap;
    }
        
    
    //get converted value for field
    @TestVisible
    static object getConvertedValue(String inputType, String inputValue)
    {
        Object convValue;
        
        Switch on inputType.toUpperCase()
        {
            when 'ID' {convValue = ID.valueOf(inputValue);}
            when 'DOUBLE' {convValue = DECIMAL.valueOf(inputValue);}
            when 'PERCENT' {convValue = DECIMAL.valueOf(inputValue);}
            when 'CURRENCY' {convValue = DECIMAL.valueOf(inputValue);}
            when 'DATE' {convValue = DATE.valueOf(inputValue);}
            when 'DATETIME' {convValue = DATETIME.valueOf(inputValue);}
            when 'TIME' {convValue = DATETIME.valueOf(inputValue);}
            when 'BOOLEAN' {convValue = BOOLEAN.valueOf(inputValue);}
            when 'PHONE' {convValue = String.valueOf(inputValue);}
            when 'URL' {convValue = String.valueOf(inputValue);}
            when 'STRING' {convValue = String.valueOf(inputValue);}
            when 'TEXTAREA' {convValue = String.valueOf(inputValue);}
            when 'PICKLIST' {convValue = String.valueOf(inputValue);}
            when 'MULTIPICKLIST' {convValue = String.valueOf(inputValue);}
            when 'EMAIL' {convValue = String.valueOf(inputValue);}
            when else {convValue = String.valueOf(inputValue);}
        }

        return convValue;
    }
    
    //create csv file string
    @TestVisible
    Static String createCSVstring ( List<fileHeaderColWrapper> headerRow
                                  ,List<fileBodyRowWrapper> dataRow)
    {
        String csvString = '';

        if(headerRow != new List<fileHeaderColWrapper>())
        {
            for(Integer i=0; i < headerRow.size(); i++)
            {
                if(i!=0)
                    csvString += ',';
                csvString += headerRow[i].value.replace('\r','');
            }
        }
        
        if(dataRow != new List<fileBodyRowWrapper>())
        {
            csvString += '\n';
            for(Integer i=0; i<dataRow.size(); i++)
            {
                for(Integer j=0; j < dataRow[i].rowCol.size(); j++)
                {
                     if(j!=0)
                        csvString += ',';
                     if(dataRow[i].rowCol[j].value != null)
                     	csvString += dataRow[i].rowCol[j].value.replace('\r','');
                }
                if(i != dataRow.size() -1)
                    csvString += '\n';
            }
        }
        
        return csvString;
    }
    
    //Log Object Wrapper
    public class logWrapper
    {
        @AuraEnabled
        public ID TypeID;
        @AuraEnabled
        public String TypeName;
        @AuraEnabled
        public ID LogID;
        @AuraEnabled
        public String LogName;
        @AuraEnabled
        public String LogLinkName;
        @AuraEnabled
        public String ImportStatus = 'Draft';
        @AuraEnabled
        public Boolean Scheduled = False;
        @AuraEnabled
        public Boolean emailReady = False; //added by Dharmendra
        @AuraEnabled
        public Boolean splitUpload = False;
        @AuraEnabled
        public Decimal TotalRecords;
        @AuraEnabled
        public Decimal SuccessCount;
        @AuraEnabled
        public Decimal ErrorCount;
        @AuraEnabled
        public String StartTime = '';
        @AuraEnabled
        public String EndTime = '';
        public Boolean addFile;
        public String fileName;
        public String fileContent;
        @AuraEnabled
        public String errMsg = '';
    }
    
    //get recent logs
    @AuraEnabled
    public static List<logWrapper> getRecentUploads()
    {
        List<logWrapper> returnWrap = new List<logWrapper>();
        
        RT_ImportLog__c[] recentLogs = [select id
                                        	,name
                                            ,ImportStatus__c
                                            ,ImportType__c
                                        	,ImportType__r.name
                                            //,TotalRecords__c
                                            ,SuccessCount__c
                                            ,ErrorCount__c
                                        	,CreatedDate
                                        	,LastModifiedDate
                                        ,ErrorMessage__c
                                       from RT_ImportLog__c
                                        order by CreatedDate desc
                                       limit 5];
        for(RT_ImportLog__c log : recentLogs)
        {
            logWrapper lWrap = new logWrapper();
            lWrap.TypeID = log.ImportType__c;
            lWrap.TypeName = log.ImportType__r.name;
            lWrap.LogID = log.id;
            lWrap.LogName = log.name;
            lWrap.LogLinkName = '/'+ log.id;
            lWrap.ImportStatus = log.ImportStatus__c;
            lWrap.SuccessCount = log.SuccessCount__c;
            lWrap.ErrorCount = log.ErrorCount__c;
            //lWrap.TotalRecords = (log.TotalRecords__c != null) ? log.TotalRecords__c : 0 ;
            //lWrap.SuccessCount = (log.SuccessCount__c != null) ? log.SuccessCount__c :0;
            //lWrap.ErrorCount = (log.ErrorCount__c != null) ? log.ErrorCount__c :0;
            lWrap.StartTime = String.valueof(log.CreatedDate.format('yyyy-MM-dd HH:mm:ss'));
            if(log.ImportStatus__c.equalsIgnoreCase('Completed') || log.ImportStatus__c.equalsIgnoreCase('Cancelled')){
                lWrap.EndTime = String.valueof(log.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss'));
            	//lWrap.uploadCompleted = True;
            }	
            lWrap.errMsg = log.ErrorMessage__c;
            returnWrap.add(lWrap);
        }
                
        return returnWrap;
    }
    
    //upsert Log
    public static logWrapper saveLog(logWrapper logWrap)
    {
        RT_ImportLog__c Log = new RT_ImportLog__c();
        System.debug('--inside saveLog'+logWrap);
        if(logWrap.LogID != null)
        {
            RT_ImportLog__c[] updateLog = [select id
                                            ,ImportStatus__c
                                            ,ImportType__c
                                            ,TotalRecords__c
                                            ,SuccessCount__c
                                            ,ErrorCount__c 
                                            ,Rv_Scheduled__c
                                           ,ErrorMessage__c
                                     from RT_ImportLog__c
                                    where id = :logWrap.LogID
                                    limit 1];
            if(updateLog.size()>0)
                Log = updateLog[0];
        }
        //Dharam
        if(Log.SuccessCount__c == null)
            Log.SuccessCount__c=0;
        if(Log.ErrorCount__c == null)
            Log.ErrorCount__c=0;
        Log.ImportType__c = (logWrap.TypeID != null) ? logWrap.TypeID : Log.ImportType__c;
        Log.ImportStatus__c = (logWrap.ImportStatus != null) ? logWrap.ImportStatus : Log.ImportStatus__c;
        Log.TotalRecords__c = (logWrap.TotalRecords != null) ? logWrap.TotalRecords : ((log.TotalRecords__c != null) ? log.TotalRecords__c : 0);
        //Log.SuccessCount__c = (logWrap.SuccessCount != null) ? logWrap.SuccessCount : ((log.SuccessCount__c != null) ? log.SuccessCount__c :0);
        //Log.ErrorCount__c = (logWrap.ErrorCount != null) ? logWrap.ErrorCount : ((log.ErrorCount__c != null) ? log.ErrorCount__c :0);
        System.debug('--Log Success Count in Parameter--'+logWrap.SuccessCount);
       // System.debug('--Log Error Count in Parameter--'+logWrap.ErrorCount);
        System.debug('--Log Success Database--'+Log.SuccessCount__c);
        System.debug('--Log Error Database--'+Log.ErrorCount__c);
      //  System.debug('--logWrap.fileName--'+logWrap.fileName);
        if(logWrap.SuccessCount!=null && logWrap.fileName.contains('Success')){
            System.debug('--line 1277--');
            Log.SuccessCount__c = Log.SuccessCount__c + logWrap.SuccessCount;
            System.debug('--Log Success Count1--'+Log.SuccessCount__c);	
        }
        
        if(logWrap.ErrorCount!=null && logWrap.fileName.contains('Error')){
            System.debug('--line 1282--');
            System.debug('--Log Error Count--'+logWrap.ErrorCount);
            Log.ErrorCount__c = Log.ErrorCount__c + logWrap.ErrorCount;
        }
         System.debug('--Log Error Count1--'+Log.ErrorCount__c);	
        //String standardMsg = ('Success Count = '+ Log.SuccessCount__c) + ('; Error Count = '+ Log.ErrorCount__c + ';');
        Log.ErrorMessage__c = (logWrap.errMsg != null && logWrap.errMsg != '') ? logWrap.errMsg : '';
        System.debug('--logWrap.ImportStatus--'+logWrap.ImportStatus);
        if(logWrap.ImportStatus == 'Scheduled'){
            Log.Rv_Scheduled__c	= logWrap.Scheduled;
        }
        System.debug('--Log.Rv_Scheduled__c--'+Log.Rv_Scheduled__c);
        log.Email_Ready__c = logWrap.emailReady;
        if(logWrap.splitUpload){
            log.Is_Split_upload__c = logWrap.splitUpload;
        }
        System.debug('--logWrap.uploadCompleted--'+logWrap.emailReady);
        try{
            upsert Log;

            LogWrap.LogID = Log.id;
            
            if(logWrap.addFile)
            	saveLogFile(LogWrap.LogID,LogWrap.fileName, LogWrap.fileContent);
            
        }catch(Exception e){System.debug(e);}
        
        return logWrap;
    }
    
    //attach Log file
    @TestVisible
    static void saveLogFile(ID LogID, String fileName, String fileContent)
    {
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(fileContent);
        attachment.Name = fileName;
        attachment.ParentId = LogID;
        
        try{
        insert attachment;
        }catch(Exception e){System.debug(e);}
    }
    
    public static String readLogFile(ID LogID, String fileName)
    {
        String fileContent;
        try{
            Attachment attach = [select id,body from Attachment 
                                     where ParentId = :LogID and Name = :fileName
                                    limit 1];
            if(attach != null)
                fileContent = EncodingUtil.urlEncode(EncodingUtil.base64Encode(attach.body), 'UTF-8');
        }
        Catch(Exception e)
        {System.debug(e);}
        
        return fileContent;
    }
    
    //convert file content to readable
    public static String blobToString(Blob input, String inCharset){ 
        String hex = EncodingUtil.convertToHex(input); 
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
    
    public static List<String> safeSplit(String inStr, String delim) {
        Integer regexFindLimit = 1000;
        Integer regexFindCount = 0;
        List<String> output = new List<String>();
        Matcher m = Pattern.compile(delim).matcher(inStr);
        Integer lastEnd = 0;
        while (!m.hitEnd()) {
            while (regexFindCount < regexFindLimit && !m.hitEnd()) {
                if (m.find()) {
                    output.add(inStr.substring(lastEnd, m.start()));
                    lastEnd = m.end();
                } else {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }
                regexFindCount++;
            }
            m.reset(inStr);
            m.region(lastEnd, m.regionEnd());
            regexFindCount = 0;
        }
        return output;
    }
    
    //file header row wrapper
    public class fileHeaderColWrapper
    {
        @AuraEnabled
        public String value = '';
        @AuraEnabled
        public Boolean FieldMapFound = false;
    }
    
    //file body column wrapper
    public class fileBodyColWrapper
    {
        @AuraEnabled
        public String value = '';
        @AuraEnabled
        public Boolean FieldMapFound = false;
    }
    
    //file body row wrapper
    public class fileBodyRowWrapper
    {
        @AuraEnabled
        public String rowKey = '';
        @AuraEnabled
        public List<fileBodyColWrapper> rowCol = new List<fileBodyColWrapper>();
    }
    
    //file wrapper
    public class fileWrapper
    {
        @AuraEnabled
        public RT_CreateImportMap.importTypeWrapper ImportType = new RT_CreateImportMap.importTypeWrapper();
        @AuraEnabled
        public ID LogID;
        @AuraEnabled
        public List<fileHeaderColWrapper> headerRow = new List<fileHeaderColWrapper>();
        @AuraEnabled
        public List<fileBodyRowWrapper> bodyRow = new List<fileBodyRowWrapper>();
        public List<String> fileLines = new List<String>();
        @AuraEnabled
        public String ImportStatus = '';
        public boolean isSplitUpload = false;
    }
    
    //result wrapper
    public class resultWrapper
    {
        @AuraEnabled
        public ID LogID;
        @AuraEnabled
        public Boolean status = true;
        @AuraEnabled
        public String statusMsg = '';
        @AuraEnabled
        public String successString = '';
        @AuraEnabled
        public String successFileName = global_SuccessFileName;
        @AuraEnabled
        public String errorString = '';
        @AuraEnabled
        public String errorFileName = global_ErrorFileName;
    }
    
    //result file wrapper
    public class resultFileWrapper
    {
        @AuraEnabled
        public List<fileHeaderColWrapper> successHeaderRow = new List<fileHeaderColWrapper>();
        @AuraEnabled
        public List<fileBodyRowWrapper> successBodyRow = new List<fileBodyRowWrapper>();
        @AuraEnabled
        public List<fileHeaderColWrapper> errorHeaderRow = new List<fileHeaderColWrapper>();
        @AuraEnabled
        public List<fileBodyRowWrapper> errorBodyRow = new List<fileBodyRowWrapper>();
    }
    
    //import filter List
    public class importFilterWrapper
    {
        @AuraEnabled
        public String value = '--None--';
        @AuraEnabled
        public String label = '--None--';
    }
    
    //UI Wrapper
    public class pageWrapper
    {
        @AuraEnabled
        public List<importFilterWrapper> ImportFilterList = new List<importFilterWrapper>();
        @AuraEnabled
        public List<RT_CreateImportMap.importTypeWrapper> ImportType = new List<RT_CreateImportMap.importTypeWrapper>();
        @AuraEnabled
        public Integer uploadNowLimit = 500;
        @AuraEnabled
        public Integer previewLimit = 10;
    }
}