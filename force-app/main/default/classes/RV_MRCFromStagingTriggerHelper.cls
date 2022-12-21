/*
 * Created by Dharmendra.Singh2 on 2-Jan-2021.
 * RV_MRCFromStagingTrigger
 */
 
global class RV_MRCFromStagingTriggerHelper {
    //public static List<String> errorStringList = new List<String>();
    public static List<RV_Exception__c> rvExceptionList = new List<RV_Exception__c>();
    public static List<MRC__c> noninsertableMRCLists = new List<MRC__c>();
    public Static String mrcEmailHeader = '';
    //This method will be called from trigger with the list of staging item list, when a new staging item will be inserted
    public static void MRCFromStaging(List<RV_MRC_Item_Staging__c> itemList){
        System.debug('---class called---'+itemList+'--size--'+itemList.size());
        Set<Id> headerIdSet = new Set<Id>();
        Set<String> accNumSet = new Set<String>();
        Set<String> locCodeSet = new Set<String>();
        Set<String> prCodeSet = new Set<String>();
        List<MRC__c> mrcReturnList = new List<MRC__c>();
        List<String> mrcNameList = new List<String>();
        List<MRC__c> mrcDataList = new List<MRC__c>();
        List<RV_MRC_Header_Staging__c> MRCHeaderStaging = new List<RV_MRC_Header_Staging__c>();
        Map<String, Id> AllIdsMap = new Map<String, Id>();
        Map<RV_MRC_Header_Staging__c, List<RV_MRC_Item_Staging__c>> MRCHeaderItemListMap = new Map<RV_MRC_Header_Staging__c, List<RV_MRC_Item_Staging__c>>();
        
        for(RV_MRC_Item_Staging__c mrcItem : itemList){
            headerIdSet.add(mrcItem.Master_Reference_Contract_number__c);
            if(mrcItem.Plant__c !=null){
                locCodeSet.add(mrcItem.Plant__c);
            }
            if(mrcItem.Material_Number__c != null){
                prCodeSet.add(String.valueOf(mrcItem.Material_Number__c));
            }  
        }
        //Fetch all MRC Header from Staging
        MRCHeaderStaging = [SELECT Action_Indicator__c,CreatedById,CreatedDate,Description__c,Distribution_Channel__c,
                            Division__c,Id,Name,OwnerId,Sales_Document_type__c,Sales_Organization__c,
                            Shipping_Condition_Description__c,Shipping_Condition__c,Ship_To_Name__c,
                            Ship_To_PO_type__c,Ship_To_Primary_Sales_Repr_Name__c,Ship_To_Primary_Sales_Repr__c,
                            Ship_To_Sales_Group_Description__c,Ship_To_Sales_Group__c,Ship_To__c,
                            Sold_To_Deletion_Flag_at_All_Areas__c,Sold_To_Deletion_Flag_at_Sales_Area__c,
                            Sold_To_Name__c,Sold_To_National_Account_Partner_Name__c,
                            Sold_To_National_Account_Partner__c,Sold_To_Primary_Sales_Repr_Name__c,
                            Sold_To_Primary_Sales_Repr__c,Sold_To_Sales_Group_Description__c,Sold_To_Sales_Group__c,
                            Sold_To__c,SystemModstamp,Valid_From__c,Valid_To__c, Customer_Credit_Limit__c
                            FROM RV_MRC_Header_Staging__c
                            WHERE Id IN : headerIdSet
                           ];
        System.debug('---MRCHeaderStaging---'+MRCHeaderStaging);
        //System.debug('---accList---'+accList);
        if(MRCHeaderStaging.size() > 0){
            for(RV_MRC_Header_Staging__c mheader : MRCHeaderStaging ){
                accNumSet.add(mheader.Sold_To__c);
                accNumSet.add(mheader.Ship_To__c);
            }
        }
        
        List<Account> accList = [SELECT Id, Sold_To_Number__c, Ship_to_Number__c FROM Account WHERE Sold_To_Number__c IN : accNumSet OR Ship_to_Number__c IN : accNumSet ];
        List<Product_Catalogue__c> materialList = [SELECT Id, Name FROM Product_Catalogue__c WHERE Name IN : prCodeSet ];
        List<Location__c> locList = [SELECT Id, Plant_Code__c FROM Location__c WHERE Plant_Code__c IN : locCodeSet ];
        
        if(accList != null){
            for(Account acc : accList){
                if(!AllIdsMap.containsKey(acc.Sold_To_Number__c) && acc.Sold_To_Number__c !=null){
                    AllIdsMap.put(acc.Sold_To_Number__c, acc.Id);
                }
                if(!AllIdsMap.containsKey(acc.Ship_to_Number__c) && acc.Ship_to_Number__c !=null){
                    AllIdsMap.put(acc.Ship_to_Number__c, acc.Id);
                }
            }    
        }
        System.debug('--------materialList------'+materialList);
        if(materialList != null){
            for(Product_Catalogue__c mat : materialList){
                System.debug('--------mat------'+mat.Name);
                if(!AllIdsMap.containsKey(mat.Name)){
                    AllIdsMap.put(mat.Name, mat.Id);
                }
            } 
        }
        System.debug('--------mat------'+AllIdsMap);
        if(locList != null){
            for(Location__c loc : locList){
                if(!AllIdsMap.containsKey(loc.Plant_Code__c)){
                    AllIdsMap.put(loc.Plant_Code__c, loc.Id);
                }
            }  
        }
        
        //create a map of Header and its staging items list
        if(MRCHeaderStaging != null){
            for(RV_MRC_Header_Staging__c hdrStagng : MRCHeaderStaging){
                System.debug('---line 35---');
                for(RV_MRC_Item_Staging__c itemStagng : itemList){
                    System.debug('---line 38-----');
                    if(hdrStagng.Id == itemStagng.Master_Reference_Contract_number__c){
                        System.debug('---line 40---');
                        if(!MRCHeaderItemListMap.containsKey(hdrStagng)){
                            MRCHeaderItemListMap.put(hdrStagng, new List<RV_MRC_Item_Staging__c>());
                            MRCHeaderItemListMap.get(hdrStagng).add(itemStagng);
                        }else{
                            MRCHeaderItemListMap.get(hdrStagng).add(itemStagng);
                        }
                    }
                }
            }
        }
        System.debug('---MRCHeaderItemListMap---'+MRCHeaderItemListMap);
        System.debug('---MRCHeaderItemListMap size---'+MRCHeaderItemListMap.values().size());
        System.debug('---MRCHeaderItemListMap Keyset---'+MRCHeaderItemListMap.keySet());
        
        //Call createMRC method to insert the records from staging
        
        if(MRCHeaderItemListMap != null){
            mrcReturnList = createMRC(MRCHeaderItemListMap, AllIdsMap); 
        }
        for(MRC__c mrcs : mrcReturnList){
            mrcNameList.add(mrcs.Name);
        }   
        mrcDataList =  [SELECT Id, Name, Contract__c, Item_No_XLS__c FROM MRC__c WHERE Name IN : mrcNameList];
        
        if(mrcReturnList.size() > 0 && mrcDataList.size() > 0){
            for(MRC__c mrcQ : mrcReturnList){
                for(MRC__c mrcr : mrcDataList ){
                    if(mrcQ.Name == mrcr.Name){
                        mrcQ.Id = mrcr.Id;
                    }
                }
            }
        }
        
        System.debug('---mrcReturnList---'+mrcReturnList);
        if(mrcReturnList.size() > 0){
            upsertMRCList(mrcReturnList);
        }
    }
    public static void upsertMRCList(List<MRC__c> MRCList){
        
        Set<MRC__c> insertMRCList = new Set<MRC__c>(MRCList);
        insertMRCList.removeAll(noninsertableMRCLists);
        List<MRC__c> mrcListForInsert = new List<MRC__c>(insertMRCList); 
        System.debug('---rvExceptionList----'+rvExceptionList);
        try{
            System.debug('------before upsert---');
            if(mrcListForInsert.size() > 0){
                Database.UpsertResult[] srList = Database.upsert(mrcListForInsert , false); 
                for(Integer i=0;i<srList.size();i++){
                    if (!srList.get(i).isSuccess()){
                        // DML operation failed
                        for(Database.Error err : srList.get(i).getErrors()) {
                            RV_Exception__c rvException = new RV_Exception__c();
                            if(err.getFields().size() > 0){
                                rvException.getFields__c = err.getFields().get(0);
                            }
                            rvException.getMessage__c = err.getMessage();
                            rvException.Apex_Class__c = 'RV_MRCFromStagingTriggerHelper';
                            rvException.Method_Name__c = 'upsertMRCList';
                            rvException.Rv_Item_Number__c=mrcListForInsert.get(i).Item_No_XLS__c;
                            rvExceptionList.add(rvException);
                        }  
                    } 
                }
            }
            if(rvExceptionList.size()>0){
                RV_ClassException.insertExceptionRecord(rvExceptionList);
                sendEmail();
            }
        }catch(Exception e){
            System.debug('-------catch-------'+e);
        }
    }
    //**********In this method we are passing map of header and its related items map and will fetch values from this and
    //assign to MRC object fields
    public static List<MRC__c> createMRC(Map<RV_MRC_Header_Staging__c, List<RV_MRC_Item_Staging__c>> MRCHeaderItemMap, Map<String, Id> AllIdMap){
        List<MRC__c> mrcList = new List<MRC__c>();
        
        // Account acc = new Account();
        Account soldToAcc = new Account();
        Account shipToAcc = new Account();
        Map<String, Account> shipSoldAccountMap = new Map<String, Account>();
        List<String> shipSoldList = new List<String>();
        System.debug('---MRCHeaderItemMap---'+MRCHeaderItemMap);
        String mrcRecordTypeID = Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        //  System.debug('---mrcRecordTypeID---'+mrcRecordTypeID);
        System.debug('---MRCHeaderItemMap.keySet()---'+MRCHeaderItemMap.keySet());
        System.debug('---AllIdMap---'+AllIdMap);
        
        
        for(RV_MRC_Header_Staging__c acctt : MRCHeaderItemMap.keySet()){
            if(!shipSoldList.contains(acctt.Sold_To__c) ){
                shipSoldList.add(acctt.Sold_To__c);
            }
            if(!shipSoldList.contains(acctt.Ship_To__c)){
                shipSoldList.add(acctt.Ship_To__c);
            }
            
        }
        //Query Accounts based on Ship to Or Sold To numbers
        List<Account> accntList = [SELECT Customer_Type__c,Id, 
                                   Sold_To_Number__c, Ship_to_Number__c,RV_Sold_To_Deletion_Flag_at_Sales_Area__c, Name 
                                   FROM Account WHERE Sold_To_Number__c IN: shipSoldList
                                   OR Ship_to_Number__c IN: shipSoldList ];
        System.debug('---accntList---'+accntList);
        System.debug('---6-'+accntList.size());
        Set<String> shipSoldNo = new Set<String>();
        for(Account ssnumber: accntList){
            shipSoldNo.add(ssnumber.Sold_To_Number__c);
            if(!shipSoldNo.contains(ssnumber.Ship_to_Number__c)){
                shipSoldNo.add(ssnumber.Ship_to_Number__c);
            }
        }
        System.debug('---shipSoldList---'+shipSoldList);
        
        for(Account accn : accntList){
            if(!shipSoldAccountMap.containsKey(accn.Sold_To_Number__c + accn.Customer_Type__c) && accn.Customer_Type__c == 'Sold To'){
                shipSoldAccountMap.put(accn.Sold_To_Number__c + accn.Customer_Type__c, accn) ;
            }else if(!shipSoldAccountMap.containsKey(accn.Ship_To_Number__c + accn.Customer_Type__c) && accn.Customer_Type__c == 'Ship To'){
                shipSoldAccountMap.put(accn.Ship_To_Number__c + accn.Customer_Type__c, accn) ;
            }
        }
        System.debug('---shipSoldAccountMap---'+shipSoldAccountMap);
        
        for(RV_MRC_Header_Staging__c mrcHeader : MRCHeaderItemMap.keySet()){
            System.debug('---mrcHeader---'+mrcHeader);
            System.debug('---MRCHeaderItemMap Size---'+MRCHeaderItemMap.get(mrcHeader).size());
            mrcEmailHeader = mrcHeader.Name;
            if(mrcHeader.Sold_To__c != null ){
                system.debug('--line 178--'); 
                //calling method to get account ID
                soldToAcc = createAccount(mrcHeader, 'Sold To', shipSoldAccountMap);
                if(!shipSoldAccountMap.containsKey(soldToAcc.Sold_To_Number__c + soldToAcc.Customer_Type__c)){
                    shipSoldAccountMap.put(soldToAcc.Sold_To_Number__c + 'Sold To', soldToAcc) ;
                }  
            }
            if(mrcHeader.Ship_To__c != null){
                system.debug('--line 194--');
                //calling method to get account ID
                shipToAcc = createAccount(mrcHeader, 'Ship To',shipSoldAccountMap);
                if(!shipSoldAccountMap.containsKey(shipToAcc.Ship_to_Number__c + shipToAcc.Customer_Type__c)){
                    shipSoldAccountMap.put(shipToAcc.Ship_to_Number__c + 'Ship To', shipToAcc) ;
                } 
            }
            
            for(RV_MRC_Item_Staging__c mrcItem : MRCHeaderItemMap.get(mrcHeader)){
                System.debug('---mrcItem---'+mrcItem);
                MRC__c mrc  = new MRC__c();
                mrc.Name                    = mrcHeader.Name+'-'+mrcItem.Name;
                mrc.Sales_Doc_Type__c       = mrcHeader.Sales_Document_Type__c;
                mrc.Ship_to_party_PO_type__c= mrcHeader.Ship_To_PO_type__c;
                mrc.Sales_Organization__c   = mrcHeader.Sales_Organization__c;
                if(mrcHeader.Distribution_Channel__c != null){
                    mrc.Distribution_Channel__c = Decimal.valueOf(mrcHeader.Distribution_Channel__c);
                }
                if(mrcHeader.Division__c !=null){
                    mrc.Division__c = Decimal.valueOf(mrcHeader.Division__c);  
                }
                if(mrcHeader.Valid_From__c != null){
                    mrc.Valid_From_Date__c      = convertStrToDate(mrcHeader.Valid_From__c);
                }
                if(mrcHeader.Valid_To__c != null){
                    mrc.Valid_To_Date__c        = convertStrToDate(mrcHeader.Valid_To__c); 
                }
                if(soldToAcc != null){
                    mrc.Sold_To__c = soldToAcc.Id;
                    mrc.Sold_To_Number__c = soldToAcc.Sold_To_Number__c;
                }
                if(shipToAcc != null){
                    mrc.Ship_To__c = shipToAcc.Id;
                    mrc.Ship_To_Number__c = shipToAcc.Ship_to_Number__c;
                    //mrc.Ship_to_Name__c = shipToAcc.Name;
                }
                if(mrcHeader.Shipping_Condition__c != null){
                    mrc.Shipping_Condition__c   = Decimal.valueOf(mrcHeader.Shipping_Condition__c);
                }
                mrc.Contract_Description__c = mrcHeader.Description__c;
                mrc.Payment_Term__c         = mrcItem.Payment_Terms__c;
                mrc.Contract__c             = mrcHeader.name;
                mrc.Handling_Type__c        = mrcItem.Handling_Type__c;
                mrc.PO_Type__c              = mrcHeader.Ship_To_PO_type__c;
                mrc.Item_No_XLS__c          = mrcItem.Name;
                if(mrcItem.Mode_of_Transport__c != null){
                    mrc.Mode_Of_Transport__c    = Decimal.valueOf(mrcItem.Mode_of_Transport__c);
                }
                if(AllIdMap.get(mrcItem.Plant__c) != null && AllIdMap.containsKey(mrcItem.Plant__c)){
                    mrc.Plant__c = AllIdMap.get(mrcItem.Plant__c);
                    mrc.Plant_Description__c = mrcItem.Plant_Name__c;
                }
                String matNum = '';
                if(mrcItem.Material_Number__c != null){
                    matNum = String.valueOf(mrcItem.Material_Number__c) ;
                }
                System.debug('---matNum---'+matNum);
                System.debug('---AllIdMap---'+AllIdMap);
                if(AllIdMap.get(matNum) != null && AllIdMap.containsKey(matNum)){
                    mrc.Product__c = AllIdMap.get(matNum); 
                }
                mrc.RecordTypeId            = mrcRecordTypeID;
                mrc.Rejection_Reasons__c    = mrcItem.Reason_for_Rejection_Message__c;
                mrc.RV_Rejection_Code__c    = mrcItem.Reason_for_Rejection_Code__c;
                mrc.Sales_Doc_Type__c       = mrcHeader.Sales_Document_type__c;
                
                mrc.Sales_Organization__c   = mrcHeader.Sales_Organization__c;
                
                if(mrcHeader.Shipping_Condition__c != null){
                    mrc.Shipping_Condition__c   = Decimal.valueOf(mrcHeader.Shipping_Condition__c); 
                }
                mrc.RV_Condition_group_2_Description__c = mrcItem.Condition_group_2_Description__c;
                mrc.RV_Invoicing_date__c                    = mrcItem.Invoicing_date__c;
                mrc.RV_Incoterms_Part1__c                   = mrcItem.Incoterms_Part1__c;
                mrc.RV_Shipping_Condition_Description__c    = mrcHeader.Shipping_Condition_Description__c;
                mrc.RV_Invoicing_dates_Description__c       = mrcItem.Invoicing_dates_Description__c;
                mrc.RV_Payment_Method__c                    = mrcItem.Payment_Method__c;
                mrc.RV_Payment_Method_Description__c        = mrcItem.Payment_Method_Description__c;
                mrc.RV_Incoterms_Part2__c                   = mrcItem.Incoterms_Part2__c;
                mrc.RV_Rejection_Code__c                    = mrcItem.Reason_for_Rejection_Code__c;
                mrc.RV_Payment_Terms_Description__c         = mrcItem.Payment_Terms_Description__c;
                mrc.RV_Condition_group_2__c                 = mrcItem.Condition_group_2__c;
                dataValidation(mrc, mrcHeader, mrcItem);
                mrcList.add(mrc); 
            }
        }
        System.debug('---plantcodes---'+mrcList);
        return mrcList;
    }
    
    public static void dataValidation(MRC__c mrc, RV_MRC_Header_Staging__c mrcHeader, RV_MRC_Item_Staging__c mrcItem ){
        String errMsg='';
        String fieldNames = '';
        if(mrc.Name == null){
            errMsg +='Master Reference Contract number is blank in MRC__c, ';
            fieldNames +='Sales_Doc_Type__c, ';
        }
        if(mrc.Sales_Doc_Type__c == null){
            errMsg +='Sales Doc is blank in MRC__c, ';
            fieldNames +='Sales_Doc_Type__c, ';
        }
        if(mrc.Sales_Organization__c == null){
            errMsg +='Sales Org is blank in MRC__c, ';
            fieldNames +='Sales_Organization__c, ';
        }
        if(mrc.PO_Type__c == null){
            errMsg +='PO Type is blank in MRC__c, ';
            fieldNames +='PO_Type__c, ';
        }
        if(mrc.Distribution_Channel__c == null){
            errMsg +='Distribution channel is blank in MRC__c, ';
            fieldNames +='Distribution_Channel__c, ';
        }
        if(mrc.Division__c == null){
            errMsg +='Division is blank in MRC__c, ';
            fieldNames +='Division__c, ';
        }
        if(mrc.Valid_From_Date__c == null){
            errMsg +='Valid from date is blank in MRC__c, ';
            fieldNames +='Valid_From_Date__c, ';
        }
        if(mrc.Sold_To__c == null){
            errMsg +='Sold to is blank in MRC__c, ';
            fieldNames +='Sold_To__c, ';
        }
        if(mrcHeader.Sold_To_Name__c == null){
            errMsg +='Sold to is blank in RV_MRC_Header_Staging__c, ';
            fieldNames +='Sold_To_Name__c, ';
        }
        if(mrc.Ship_To__c == null){
            errMsg +='Ship to is blank in MRC__c, ';
            fieldNames +='Ship_To__c, ';
        }
        if(mrcHeader.Ship_to_Name__c == null){
            errMsg +='Ship-To Name is blank in RV_MRC_Header_Staging__c, ';
            fieldNames +='Ship_to_Name__c, ';
        }
        if(mrc.Shipping_Condition__c == null){
            errMsg +='Shipping condition is blank in MRC__c, ';
            fieldNames +='Shipping_Condition__c, ';
        }
        if(mrc.Plant__c == null){
            errMsg +='Invalid plant number in MRC__c, ';
            fieldNames +='Plant__c, ';
        }
        if(mrc.Product__c == null){
            errMsg +='Invalid material number in MRC__c, ';
            fieldNames +='Product__c, ';
        }
        if(mrc.Handling_Type__c == null){
            errMsg +='Handling Type is blank in MRC__c, ';
            fieldNames +='Handling_Type__c, ';
        }
        if(String.isNotBlank(errMsg)){
            noninsertableMRCLists.add(mrc);
            RV_Exception__c rvException = new RV_Exception__c();
            rvException.getFields__c = fieldNames;
            rvException.getMessage__c = errMsg;
            rvException.Apex_Class__c = 'RV_MRCFromStagingTriggerHelper';
            rvException.Method_Name__c = 'upsertMRCList';
            rvException.Rv_Item_Number__c = mrc.Item_No_XLS__c;
            rvExceptionList.add(rvException);
        }   
    }
    
    public static Date convertStrToDate(String dateString){
        Date dateObj;
        String dateStr;
        if(dateString != null){
            dateStr = dateString.trim(); 
        }
        if(dateStr.contains('/')){
            List<String> dateParts = dateStr.split('/');
            if(Integer.valueOf(dateParts[2]) > 3999){
                dateParts[2] = '3999';
            }
            dateObj = Date.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[0]));
            
        }else if(dateStr.contains('-')){
            List<String> dateParts = dateStr.split('-');
            if(Integer.valueOf(dateParts[0]) > 3999){
                dateParts[0] = '3999';
            }
            dateObj = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
            
        }
        return dateObj;
    }
    
    public static Account createAccount(RV_MRC_Header_Staging__c mrcHdr, String custType, Map<String,Account> map1){
        System.debug('---custType----'+custType);
        System.debug('---map1----'+map1);
        System.debug('---value 1----'+mrcHdr.Sold_To__c + custType);
        System.debug('---value 3----'+mrcHdr.Ship_To__c + custType);
        Account accToInsert = new Account();
        Account existingAcc = new Account();
        String soldToRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        String shipToRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution Ship-To Account').getRecordTypeId();
        System.debug('--soldToRecordTypeID--'+soldToRecordTypeID);
        System.debug('--shipToRecordTypeID--'+shipToRecordTypeID);
        if(custType == 'Sold To' && !map1.containsKey(mrcHdr.Sold_To__c + custType)){
            System.debug('--for insert 1 sold to--');
            accToInsert.Customer_Type__c = 'Sold To';
            accToInsert.Name = mrcHdr.Sold_To_Name__c;
            accToInsert.Sold_To_Number__c = mrcHdr.Sold_To__c;
            accToInsert.RecordTypeId = soldToRecordTypeID;
            accToInsert.RV_Sold_To_Deletion_Flag_at_All_Areas__c = mrcHdr.Sold_To_Deletion_Flag_at_All_Areas__c;
            //System.debug('---value---'+!accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c.contains(mrcHdr.Sales_Organization__c));
            if(mrcHdr.Sold_To_Deletion_Flag_at_Sales_Area__c == 'X' || mrcHdr.Sold_To_Deletion_Flag_at_Sales_Area__c == 'x'){
                if(accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c == NULL ){
                    accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c = mrcHdr.Sales_Organization__c;
                }else if(!accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c.contains(mrcHdr.Sales_Organization__c)){
                    accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c = accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c +';'+  mrcHdr.Sales_Organization__c ;
                }
            }else if(mrcHdr.Sold_To_Deletion_Flag_at_Sales_Area__c != null){
                accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c = accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c +';'+  mrcHdr.Sales_Organization__c;
            }
            if(mrcHdr.Sales_Organization__c =='AT01'){
                accToInsert.Rv_AT01_National_Account_Partner__c = mrcHdr.Sold_To_National_Account_Partner__c;
                accToInsert.Rv_AT01_National_Account_Partner_Name__c = mrcHdr.Sold_To_National_Account_Partner_Name__c;
                accToInsert.Rv_AT01_Primary_Sales_Repr__c = mrcHdr.Sold_To_Primary_Sales_Repr__c;
                accToInsert.Rv_AT01_Primary_Sales_Repr_Name__c = mrcHdr.Sold_To_Primary_Sales_Repr_Name__c;
                accToInsert.Rv_AT01_Sales_Group__c = mrcHdr.Sold_To_Sales_Group__c;
                accToInsert.Rv_AT01_Sales_Group_Description__c = mrcHdr.Sold_To_Sales_Group_Description__c;
                if(mrcHdr.Customer_Credit_Limit__c != null){
                    accToInsert.Rv_AT01_Customer_Credit_Limit__c = Decimal.valueOf(mrcHdr.Customer_Credit_Limit__c);
                }
            } else if(mrcHdr.Sales_Organization__c =='DE01'){
                accToInsert.Rv_DE01_National_Account_Partner__c = mrcHdr.Sold_To_National_Account_Partner__c;
                accToInsert.Rv_DE01_National_Account_Partner_Name__c = mrcHdr.Sold_To_National_Account_Partner_Name__c;
                accToInsert.Rv_DE01_Primary_Sales_Repr__c = mrcHdr.Sold_To_Primary_Sales_Repr__c;
                accToInsert.Rv_DE01_Primary_Sales_Repr_Name__c = mrcHdr.Sold_To_Primary_Sales_Repr_Name__c;
                accToInsert.Rv_DE01_Sales_Group__c = mrcHdr.Sold_To_Sales_Group__c;
                accToInsert.Rv_DE01_Sales_Group_Description__c = mrcHdr.Sold_To_Sales_Group_Description__c;
                if(mrcHdr.Customer_Credit_Limit__c != null){
                    accToInsert.DE01_Customer_Credit_Limit__c = Decimal.valueOf(mrcHdr.Customer_Credit_Limit__c);
                }
            }
            accToInsert.Has_MRC__c = true;
            
        }
        else if(custType == 'Ship To' && !map1.containsKey(mrcHdr.Ship_To__c + custType)){
            System.debug('--for insert 3 ship to--');
            accToInsert.Customer_Type__c = 'Ship To';
            accToInsert.Name = mrcHdr.Ship_To_Name__c;
            accToInsert.Ship_To_Number__c = mrcHdr.Ship_To__c; 
            accToInsert.RecordTypeId = shipToRecordTypeID;
            if(mrcHdr.Sales_Organization__c =='AT01'){
                accToInsert.Rv_AT01_Sales_Group__c = mrcHdr.Ship_To_Sales_Group__c;
                accToInsert.Rv_AT01_Sales_Group_Description__c = mrcHdr.Ship_To_Sales_Group_Description__c;
                accToInsert.Rv_AT01_Primary_Sales_Repr__c = mrcHdr.Ship_To_Primary_Sales_Repr__c;
                accToInsert.Rv_AT01_Primary_Sales_Repr_Name__c = mrcHdr.Ship_To_Primary_Sales_Repr_Name__c;
            }else if(mrcHdr.Sales_Organization__c =='DE01'){
                accToInsert.Rv_DE01_Sales_Group__c = mrcHdr.Ship_To_Sales_Group__c;
                accToInsert.Rv_DE01_Sales_Group_Description__c = mrcHdr.Ship_To_Sales_Group_Description__c;
                accToInsert.Rv_DE01_Primary_Sales_Repr__c = mrcHdr.Ship_To_Primary_Sales_Repr__c;
                accToInsert.Rv_DE01_Primary_Sales_Repr_Name__c = mrcHdr.Ship_To_Primary_Sales_Repr_Name__c;
            }
            accToInsert.ParentId = map1.get(mrcHdr.Sold_To__c+'Sold To').Id;
            accToInsert.Has_MRC__c = true;
            accToInsert.Sold_To_Number__c = mrcHdr.Sold_To__c;
        }
        else{
            if(custType == 'Sold To'){
                existingAcc = map1.get(mrcHdr.Sold_To__c + custType);
                System.debug('--existingAcc--'+existingAcc);
                accToInsert.Id = existingAcc.Id;
                accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c = existingAcc.RV_Sold_To_Deletion_Flag_at_Sales_Area__c;
                accToInsert.Name = mrcHdr.Sold_To_Name__c;
                accToInsert.Sold_To_Number__c = mrcHdr.Sold_To__c;
                //System.debug('---value---'+!accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c.contains(mrcHdr.Sales_Organization__c));
                //START - Rahul Sharma | Date - 24-Feb-21 | Bug-748170 : Fixed deletion flags not updated on MRC update.
                accToInsert.RV_Sold_To_Deletion_Flag_at_All_Areas__c = mrcHdr.Sold_To_Deletion_Flag_at_All_Areas__c;
                if(mrcHdr.Sold_To_Deletion_Flag_at_Sales_Area__c == 'X' || mrcHdr.Sold_To_Deletion_Flag_at_Sales_Area__c == 'x'){
                    if(accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c == NULL ){
                        accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c = mrcHdr.Sales_Organization__c;
                    }else if(!accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c.contains(mrcHdr.Sales_Organization__c)){
                        accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c = accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c +';'+ mrcHdr.Sales_Organization__c ;
                    }
                }else if(mrcHdr.Sold_To_Deletion_Flag_at_Sales_Area__c != null){
                    accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c = accToInsert.RV_Sold_To_Deletion_Flag_at_Sales_Area__c +';'+  mrcHdr.Sales_Organization__c;
                }
                //END - Rahul Sharma | Date - 24-Feb-21 | Bug-748170 : Fixed deletion flags not updated on MRC update.
                if(mrcHdr.Sales_Organization__c =='AT01'){
                    accToInsert.Rv_AT01_National_Account_Partner__c = mrcHdr.Sold_To_National_Account_Partner__c;
                    accToInsert.Rv_AT01_National_Account_Partner_Name__c = mrcHdr.Sold_To_National_Account_Partner_Name__c;
                    accToInsert.Rv_AT01_Primary_Sales_Repr__c = mrcHdr.Sold_To_Primary_Sales_Repr__c;
                    accToInsert.Rv_AT01_Primary_Sales_Repr_Name__c = mrcHdr.Sold_To_Primary_Sales_Repr_Name__c;
                    accToInsert.Rv_AT01_Sales_Group__c = mrcHdr.Sold_To_Sales_Group__c;
                    accToInsert.Rv_AT01_Sales_Group_Description__c = mrcHdr.Sold_To_Sales_Group_Description__c;
                    if(mrcHdr.Customer_Credit_Limit__c != null){
                        accToInsert.Rv_AT01_Customer_Credit_Limit__c = Decimal.valueOf(mrcHdr.Customer_Credit_Limit__c);
                    } 
                }
                else if(mrcHdr.Sales_Organization__c =='DE01'){
                    accToInsert.Rv_DE01_National_Account_Partner__c = mrcHdr.Sold_To_National_Account_Partner__c;
                    accToInsert.Rv_DE01_National_Account_Partner_Name__c = mrcHdr.Sold_To_National_Account_Partner_Name__c;
                    accToInsert.Rv_DE01_Primary_Sales_Repr__c = mrcHdr.Sold_To_Primary_Sales_Repr__c;
                    accToInsert.Rv_DE01_Primary_Sales_Repr_Name__c = mrcHdr.Sold_To_Primary_Sales_Repr_Name__c;
                    accToInsert.Rv_DE01_Sales_Group__c = mrcHdr.Sold_To_Sales_Group__c;
                    accToInsert.Rv_DE01_Sales_Group_Description__c = mrcHdr.Sold_To_Sales_Group_Description__c;
                    if(mrcHdr.Customer_Credit_Limit__c != null){
                        accToInsert.DE01_Customer_Credit_Limit__c = Decimal.valueOf(mrcHdr.Customer_Credit_Limit__c);
                    } 
                }
                accToInsert.Has_MRC__c = true;  
            }
            if(custType == 'Ship To'){
                existingAcc = map1.get(mrcHdr.Ship_To__c + custType);
                System.debug('--existingAcc--'+existingAcc);
                accToInsert.Id = existingAcc.Id;
                accToInsert.Name = mrcHdr.Ship_To_Name__c;
                accToInsert.Has_MRC__c = true;
                accToInsert.Ship_To_Number__c = mrcHdr.Ship_To__c;
                if(mrcHdr.Sales_Organization__c =='AT01'){
                    accToInsert.Rv_AT01_Sales_Group__c = mrcHdr.Ship_To_Sales_Group__c;
                    accToInsert.Rv_AT01_Sales_Group_Description__c = mrcHdr.Ship_To_Sales_Group_Description__c;
                    accToInsert.Rv_AT01_Primary_Sales_Repr__c = mrcHdr.Ship_To_Primary_Sales_Repr__c;
                    accToInsert.Rv_AT01_Primary_Sales_Repr_Name__c = mrcHdr.Ship_To_Primary_Sales_Repr_Name__c;
                }
                else if(mrcHdr.Sales_Organization__c =='DE01'){
                    accToInsert.Rv_DE01_Sales_Group__c = mrcHdr.Ship_To_Sales_Group__c;
                    accToInsert.Rv_DE01_Sales_Group_Description__c = mrcHdr.Ship_To_Sales_Group_Description__c;
                    accToInsert.Rv_DE01_Primary_Sales_Repr__c = mrcHdr.Ship_To_Primary_Sales_Repr__c;
                    accToInsert.Rv_DE01_Primary_Sales_Repr_Name__c = mrcHdr.Ship_To_Primary_Sales_Repr_Name__c;
                }
                if(map1.get(mrcHdr.Sold_To__c+'Sold To') != null){
                    accToInsert.ParentId = map1.get(mrcHdr.Sold_To__c+'Sold To').Id;
                    accToInsert.Sold_To_Number__c = mrcHdr.Sold_To__c;
                }
            }
        }
        System.debug('---accToInsert----'+accToInsert);
        if(accToInsert!= null){
            upsert accToInsert;
        }
        return accToInsert; 
    }
    public static void sendEmail(){
        List<Messaging.SingleEmailMessage> singleMessageLst = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = Label.RV_MRCErrorRecepients.split(';');
        String excpmsg = '';
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = toAddresses;
        message.setReplyTo('noreply@salesforce.com');
        message.setSubject('MRC Upload Error - ' +mrcEmailHeader);
        // message.ccaddresses = ccEmailAddress;
        singleMessageLst.add(message);
        for(RV_Exception__c rvException:rvExceptionList){
            excpmsg += 'Line Item: '+rvException.Rv_Item_Number__c+' rejected. '+'Error : '+rvException.getMessage__c + '<br/>';
        }
        String body = 'Hi,' + '<br/><br/>' + 
            'A error has occured during upload of MRC ' +mrcEmailHeader +'. It has failed in salesforce with below error.' +'<br/><br/>' +
            'Message from Salesforce: '+
            '<br/>'+excpmsg+'<br/>'+
            'Please take appropriate action to re-upload the MRC.'+'<br/><br/>'+
            'This is an auto generated email, Please do not reply.'+'<br/><br/><br/>'+
            'Thanks,'+'<br/>'+
            'Revolution Team';
        message.setHtmlBody(body); 
        If(singleMessageLst.size() > 0 && !Test.isRunningTest()){
            System.debug('------singleMessageLst----'+singleMessageLst);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(singleMessageLst);
            System.debug('------results----'+results);
            
        }
        
    }
    
}