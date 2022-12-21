public class RV_MRCDataUploadController {
    static List<MRC__c> mrcUpdateList = new List<MRC__c>();
    static List<MRC__c> mrcInsertList = new List<MRC__c>();
    
    @AuraEnabled
    public static List<ErrorWrapper> saveMRCData(String fileName, String base64Data, String contentType) {
        List<MRCWrapper> wrapList = new List<MRCWrapper>();
        List<ErrorWrapper> errList = new List<ErrorWrapper>();
        List<ErrorWrapper> errListObj = new List<ErrorWrapper>();
        MRCWrapper wrap;
        ErrorWrapper errObj;

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        //Decodes a string in application/x-www-form-urlencoded format using a specific encoding scheme, for example “UTF-8.”
        
        String nameFile = blobToString( EncodingUtil.base64Decode(base64Data),'ISO-8859-1');
        String[] filelines = safeSplit(nameFile,'\n');
        integer length=0;
        
        Map<String,MRC__c> mrcObjMap = new Map<String,MRC__c>();
        String recTypeId = Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        for(MRC__c mrc : [select id,Name,Contract__c,Distribution_Channel__c,Division__c,Handling_Type__c,Ship_to_party_PO_type__c,
                          Item_No_XLS__c,Material_No_XLS__c ,Sold_To_Number_XLS__c,Plant_Code_XLS__c,PO_Type__c,
                          Sales_Document__c,Sales_Organization__c,Mode_Of_Transport__c,Sales_Doc_Type__c,
                          Sold_To_Number__c,Ship_to_Name__c,Ship_to_Number__c,PO_Number__c,Plant_Description__c,
                          Shipping_Condition__c,Valid_From_Date__c,Valid_To_Date__c FROM MRC__c where 
                          RecordTypeId =:recTypeId]){
                              mrcObjMap.put(mrc.Name , mrc);
                          }
        String accrecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        String accShipTorecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution Ship-To Account').getRecordTypeId();//566937MRC Upload - Fix 
        
        Map<String,Account> accObjMap = new Map<String,Account>();
        for(Account acc :[Select Id, Sold_To_Number__c from Account where RecordTypeId =:accrecTypeId]){
            accObjMap.put(acc.Sold_To_Number__c, acc);
        }
        
        Map<String,Account> accShipToObjMap = new Map<String,Account>();//566937MRC Upload - Fix 
        for(Account acc :[Select Id, Ship_to_Number__c from Account where RecordTypeId =:accShipTorecTypeId]){
            accShipToObjMap.put(acc.Ship_to_Number__c , acc);
        }
        
        Map<String,Location__c> locationMap = new Map<String,Location__c>();
        for(Location__c loc : [Select Id, Plant_Code__c from Location__c]){
            locationMap.put(loc.Plant_Code__c,loc);
        }
        Map<String,Product_Catalogue__c> materialMap = new Map<String,Product_Catalogue__c>();
        for(Product_Catalogue__c prd : [Select Id ,Name from Product_Catalogue__c]){
            materialMap.put(prd.Name,prd);
        }
        for (Integer i=1;i<filelines.size()-1;i++){ 
            String[] inputvalues = new String[]{};
                
                inputvalues = filelines[i].split(',');
            length = inputvalues.size(); 
            String ErrorMsg='';
            if((inputvalues[11] != null && inputvalues[11] != '' && 
                inputvalues[13] != null && inputvalues[13] != '' &&
                inputvalues[21] != null && inputvalues[21] != '') ||
               inputvalues[22].trim() == 'not valid') { // 
                   
                   if(!locationMap.containskey(inputvalues[10].trim()) && inputvalues[22].trim() == 'valid'){
                       
                       errObj = new ErrorWrapper();
                       Integer j= i+1;
                       errObj.id = 'CSV Row Number '+j+' and MRC number '+inputvalues[1]+'-'+inputvalues[2];
                       
                       //errObj.errorMsg ='Plant is missing/Correct this CSV row before upload';
                       ErrorMsg=ErrorMsg +' Plant is missing.';
                       // errListObj.add(errObj);
                   }
                   if(!materialMap.containskey(inputvalues[12].replaceFirst('^0+', '').trim()) && inputvalues[22].trim() == 'valid'){
                      
                       errObj = new ErrorWrapper();
                       Integer j= i+1;
                       errObj.id = 'CSV Row Number '+j+' and MRC number '+inputvalues[1]+'-'+inputvalues[2];
                       ErrorMsg=ErrorMsg +' Material is missing.';
                       // errObj.errorMsg ='Material  is missing/Correct this CSV row before upload';
                       // errListObj.add(errObj);        
                   }
				   if(!accShipToObjMap.containskey(inputvalues[14].replaceFirst('^0+', '').trim()) && inputvalues[22].trim() == 'valid'){//566937MRC Upload - Fix 
                       errObj = new ErrorWrapper();
                       Integer j= i+1;
                       errObj.id = 'CSV Row Number '+j+' and MRC number '+inputvalues[1]+'-'+inputvalues[2];
                       ErrorMsg=ErrorMsg +' ShipTo is missing.';
                       // errObj.errorMsg ='SoldTo is missing/Correct this CSV row before upload';
                       // errListObj.add(errObj);        
                   }                   
                   if(!accObjMap.containskey(inputvalues[20].replaceFirst('^0+', '').trim()) && inputvalues[22].trim() == 'valid'){
                       errObj = new ErrorWrapper();
                       Integer j= i+1;
                       errObj.id = 'CSV Row Number '+j+' and MRC number '+inputvalues[1]+'-'+inputvalues[2];
                       ErrorMsg=ErrorMsg +' SoldTo is missing.';
                       // errObj.errorMsg ='SoldTo is missing/Correct this CSV row before upload';
                       // errListObj.add(errObj);        
                   }
                   else{
                       wrap = new MRCWrapper();
                       wrap.rowNumber = i+'';
                       wrap.contract = inputvalues[1];
                       wrap.item = inputvalues[2];
                       wrap.salesOrg = inputvalues[3];
                       wrap.poNumber = inputvalues[4]; 
                       wrap.distChannel = inputvalues[5];
                       wrap.division = inputvalues[6];
                       wrap.salesDoc = inputvalues[7];
                       wrap.validFrom = inputvalues[8];
                       wrap.validTo = inputvalues[9];
                       wrap.plant = inputvalues[10];
                       wrap.plantName = inputvalues[11];
                       wrap.material = inputvalues[12].replaceFirst('^0+', '').trim();
                       wrap.materialName = inputvalues[13];
                       wrap.shipTo = inputvalues[14].replaceFirst('^0+', '').trim();
                       wrap.shipToName = inputvalues[15];
                       wrap.handlingType = inputvalues[16];
                       wrap.shippingCondition = inputvalues[17];
                       wrap.mot = inputvalues[18];    
                       wrap.purchaseOrder = inputvalues[19];
                       wrap.soldTo = inputvalues[20].replaceFirst('^0+', '').trim();
                       wrap.soldToName = inputvalues[21];
                       wrap.validInvalidString = inputvalues[22];
                       wrapList.add(wrap);
                   }
                   if(ErrorMsg.length() >1){
                       ErrorMsg = ErrorMsg + 'Correct this CSV row before upload';
                   }
                   
                   
                   }else if(inputvalues[22] =='valid'){            
                   errObj = new ErrorWrapper();
                   Integer j= i+1;
                   errObj.id = 'CSV Row Number '+j+' and MRC number '+inputvalues[1]+'-'+inputvalues[2];
                   
                   // ='Material , Plant or SoldTo is missing/Correct this CSV row before upload';
                   ErrorMsg=ErrorMsg+' Error while Uploading MRC.Please contact support.';
                   //errListObj.add(errObj);
               }
            if(ErrorMsg.length() >1){
                errObj.errorMsg = ErrorMsg;
                errListObj.add(errObj);  
            }
        }
        if(!wrapList.isEmpty()){
            try{
                errList = checkMRCDataforUpload(wrapList,mrcObjMap,recTypeId);
                }catch(Exception e){
                errObj = new ErrorWrapper();
                errObj.id = '-';
                errObj.errorMsg ='Exception Occured'+e.getMessage();
                errListObj.add(errObj);    
            }
            errListObj.addAll(errList);
        }
        
        if(!errListObj.isEmpty())
            return errListObj; 
        else
            return null;
    }
    
    public static List<ErrorWrapper> checkMRCDataforUpload(List<MRCWrapper> wrapList, Map<String,MRC__c> mrcObjMap,
                                                           Id recTypeId){
                                                               // system.debug('-----wrapListSIZE--------'+wrapList.size());
                                                               List<ErrorWrapper> errorList = new List<ErrorWrapper>();
                                                               List<ErrorWrapper> errInsList = new List<ErrorWrapper>();
                                                               List<ErrorWrapper> errUpdtList = new List<ErrorWrapper>();
                                                               
                                                               List<MRC__c> lstTemp;
                                                               List<MRC__c> lstUpdtTemp;
                                                               MRC__c mrcRecord;
                                                               MRC__c newmrcRecord;
                                                               ErrorWrapper errObj;
                                                               Integer x = 1000;
                                                               
                                                               Set<String> staticMRCName = new Set<String>{'Term Trigger MOGAS-','Term Trigger IGO-','Term Trigger AGO-',
                                                                   'Spot Trigger MOGAS-','Spot Trigger IGO-','Spot Trigger AGO-',
                                                                   'FestPreis Kompakt-'};
                                                                       System.debug('---------'+mrcObjMap.keyset());                                                
                                                               for(MRCWrapper wraperObj : wrapList){
                                                                   if(mrcObjMap.containsKey(wraperObj.contract+'-'+wraperObj.item)) {
                                                                       if(wraperObj.validInvalidString.trim() == 'not valid'){
                                                                           if(!staticMRCName.contains(wraperObj.contract+'-'+wraperObj.item)){
                                                                               mrcRecord = new MRC__c();
                                                                               mrcRecord = mrcObjMap.get(wraperObj.contract+'-'+wraperObj.item);
                                                                               mrcRecord.Valid_To_Date__c  = system.today().addDays(-1);
                                                                               mrcUpdateList.add(mrcRecord);
                                                                           }else{
                                                                               mrcRecord = new MRC__c();		
                                                                               mrcRecord = mrcObjMap.get(wraperObj.contract+'-'+wraperObj.item);		
                                                                               mrcRecord.Valid_To_Date__c  = Date.newInstance(3999, 12, 31);		
                                                                               mrcUpdateList.add(mrcRecord);
                                                                           }
                                                                       }else if(wraperObj.validInvalidString.trim() == 'valid'){
                                                                           mrcRecord  = new MRC__c();
                                                                           mrcRecord = mrcObjMap.get(wraperObj.contract+'-'+wraperObj.item);
                                                                           mrcRecord = copyValues(mrcRecord,wraperObj);
                                                                           mrcUpdateList.add(mrcRecord);
                                                                       }
                                                                       
                                                                   }else{
                                                                       if(wraperObj.validInvalidString.trim() == 'not valid'){
                                                                           if(staticMRCName.contains(wraperObj.contract)){
                                                                               mrcRecord = new MRC__c();
                                                                               mrcRecord.Name = wraperObj.contract+'-'+wraperObj.item;
                                                                               mrcRecord.RecordTypeId = recTypeId;
                                                                               mrcRecord = copyValues(mrcRecord,wraperObj);
                                                                               mrcInsertList.add(mrcRecord);
                                                                           }
                                                                       }else if(wraperObj.validInvalidString.trim() == 'valid'){
                                                                           mrcRecord = new MRC__c();
                                                                           mrcRecord.Name = wraperObj.contract+'-'+wraperObj.item;
                                                                           mrcRecord.RecordTypeId = recTypeId;
                                                                           mrcRecord = copyValues(mrcRecord,wraperObj);
                                                                           mrcInsertList.add(mrcRecord);
                                                                       }
                                                                   }
                                                               }
                                                               system.debug('------------------INSERT-------****-----------'+mrcInsertList.size());
                                                               system.debug('------------------UPDATE----------------------'+mrcUpdateList.size());
                                                               System.enqueueJob(new RV_MRCDataUploadInsertQueuable(mrcInsertList));
                                                               
                                                               System.enqueueJob(new RV_MRCDataUploadUpdateQueuable(mrcUpdateList));
                                                               return errorList;
                                                           }
    
    public static MRC__c copyValues(MRC__c mrcRecord, MRCWrapper wraperObj){
        mrcRecord.Sales_Organization__c = wraperObj.salesOrg;
        mrcRecord.PO_Type__c = wraperObj.poNumber; 
        
        if(wraperObj.division != null && wraperObj.division != '')
            mrcRecord.Division__c = Decimal.valueOf(wraperObj.division.trim());
        if(wraperObj.salesDoc != null && wraperObj.salesDoc != '')
            mrcRecord.Sales_Doc_Type__c = wraperObj.salesDoc.trim();
        if(wraperObj.distChannel != null && wraperObj.distChannel != '')
            mrcRecord.Distribution_Channel__c = Decimal.valueOf(wraperObj.distChannel.trim());
        if(wraperObj.validFrom != null && wraperObj.validFrom != '')
            mrcRecord.Valid_From_Date__c= convertStrToDate(wraperObj.validFrom);
        if(wraperObj.validTo != null && wraperObj.validTo != '')
            mrcRecord.Valid_To_Date__c= convertStrToDate(wraperObj.validTo);
        if(wraperObj.contract != null && wraperObj.contract != '')
            mrcRecord.Contract__c = wraperObj.contract;
        if(wraperObj.item != null && wraperObj.item != '')
            mrcRecord.Item_No_XLS__c = wraperObj.item;
        if(wraperObj.plant != null && wraperObj.plant != '')
            mrcRecord.Plant_Code_XLS__c = wraperObj.plant;
        if(wraperObj.plantName != null && wraperObj.plantName != '')
            mrcRecord.Plant_Description__c = wraperObj.plantName;
        if(wraperObj.material != null && wraperObj.material != '')
            mrcRecord.Material_No_XLS__c = wraperObj.material;
        if(wraperObj.shipToName != null && wraperObj.shipToName != '')
            mrcRecord.Ship_to_Name__c = wraperObj.shipToName;
        if(wraperObj.shipTo != null && wraperObj.shipTo != '')
            mrcRecord.Ship_to_Number__c = wraperObj.shipTo;
        if(wraperObj.handlingType != null && wraperObj.handlingType != '')
            mrcRecord.Handling_Type__c = wraperObj.handlingType;
        if(wraperObj.shippingCondition != null && wraperObj.shippingCondition != '')
            mrcRecord.Shipping_Condition__c = Decimal.valueOf(wraperObj.shippingCondition.trim());
        if(wraperObj.mot != null && wraperObj.mot != '' && wraperObj.mot != '""')
            mrcRecord.Mode_Of_Transport__c = Decimal.valueOf(wraperObj.mot.trim());
        mrcRecord.Sold_To_Number_XLS__c = wraperObj.soldTo;
        mrcRecord.Sold_To_Number__c = wraperObj.soldTo;
        return mrcRecord;
    }
    public static Date convertStrToDate(String dateStr){
        Date dateObj;
        ErrorWrapper errObj;
        dateStr = dateStr.trim();
        if(dateStr.contains('-')){
            List<String> dateParts = dateStr.split('-');
            if(dateParts[0].contains('9999')){
                dateParts[0] = '3999';
            }
            dateObj = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
            
        }else{
            String year = dateStr.subString(0,4);
            if(Integer.valueOf(year) > 3999){
                year = '3999';
            }
            String month = dateStr.subString(4,6);
            String day = dateStr.subString(6,8);
            dateObj = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
            
        }
        return dateObj;
    }
    
    
    public class ErrorWrapper{
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String errorMsg{get;set;}
    }
    
    public class MRCWrapper{
        public String rowNumber{get;set;}
        public String salesOrg{get;set;}
        public String poNumber{get;set;}
        public String distChannel{get;set;}
        public String division{get;set;}
        public String salesDoc{get;set;}
        public String contract{get;set;}
        public String item{get;set;}
        public String validFrom{get;set;}
        public String validTo{get;set;}
        public String plantName{get;set;}
        public String plant{get;set;}
        public String material{get;set;}
        public String materialName{get;set;}
        public String soldTo{get;set;}
        public String soldToName{get;set;}
        public String shipTo{get;set;}
        public String shipToName{get;set;}
        public String handlingType{get;set;}
        public String shippingCondition{get;set;}
        public String mot{get;set;}
        public String purchaseOrder{get;set;}
        public String validInvalidString{get;set;}
    }
    public static String blobToString(Blob input, String inCharset){ 
        String hex = EncodingUtil.convertToHex(input); 
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
    private static List<String> safeSplit(String inStr, String delim){
        Integer regexFindLimit = 1000;
        Integer regexFindCount = 0;
        List<String> output = new List<String>();
        Matcher m = Pattern.compile(delim).matcher(inStr);
        Integer lastEnd = 0;
        while(!m.hitEnd())
        {
            while(regexFindCount < regexFindLimit && !m.hitEnd())
            {
                if(m.find())
                {
                    output.add(inStr.substring(lastEnd, m.start()));  
                    lastEnd = m.end();
                }
                else
                {
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
}