public class RT_PriceOutputController
{
	/*
	Version : 0.0
	Author	: Soumyajit
	Date	: 09-Jul-2020
	Details	: Turkey Price Output Controller
	*/
    static String global_whereCond = ' and PriceDate__c = TODAY';
    static String global_sorting = ' order by SoldToName__r.name, DepotAbbreviatedName__c, ProductName__r.name';
    
    @AuraEnabled
    public static pageWrapper getPageData()
    {
        pageWrapper returnWrap = new pageWrapper();
        
        List<AsyncApexJob> runJob = new List<AsyncApexJob>();
        runJob = [SELECT Id FROM AsyncApexJob where ApexClass.name = :RT_Util.logicRunClassName 
                  and Status in ('Queued','Holding','Preparing','Processing')];
        
        if(runJob != new List<AsyncApexJob>())
            returnWrap.isLogicRunning = true;
        
        if(!returnWrap.isLogicRunning)
        {
            filterWrapper fwSoldToALL = new filterWrapper();
            fwSoldToALL.label = 'All Resellers';
            fwSoldToALL.value = 'ALL';
            returnWrap.soldToList.add(fwSoldToALL);
                    
            Account[] accLst = [select id, name from Account 
                                where RT_Active__c = true and recordtypeid = :RT_Util.accRecTypeId
                                and RT_AccountGroup__c = :RT_Util.soldToType
                                and type = :RT_Util.accountType
                                //and RT_Exception__c = :RT_Util.includeExceptionAccount
                                order by name];
            for(Account a: accLst)
            {
                filterWrapper fwSoldTo = new filterWrapper();
                fwSoldTo.label = a.name;
                fwSoldTo.value = a.id;
                returnWrap.soldToList.add(fwSoldTo); 
            }
            
            filterWrapper fwPlantALL = new filterWrapper();
            fwPlantALL.value = 'ALL';
            fwPlantALL.label = 'All Terminals';
            returnWrap.plantList.add(fwPlantALL);
            
            RE_Location__c[] plantLst = [select id, Name, RE_LOCATION_CODE__C,RE_ABBREVIATED_NAME__C from RE_Location__c
                                         where RT_Active__c = true and recordtypeid = :RT_Util.locRecTypeId 
                                         and RT_Location_Type__c = :RT_Util.depotLocType
                                         and RE_ABBREVIATED_NAME__C != null
                                         //and RT_Import_Terminal__c = :RT_Util.restrictToImportTerminal
                                         order by RE_ABBREVIATED_NAME__C, RE_LOCATION_CODE__C];
            for(RE_Location__c l: plantLst)
            {
                filterWrapper fwPlant = new filterWrapper();
                fwPlant.label = l.RE_ABBREVIATED_NAME__C + '[' + l.RE_LOCATION_CODE__C + ']';
                fwPlant.value = l.id;
                returnWrap.plantList.add(fwPlant);  
            }
            
            filterWrapper fwMaterialALL = new filterWrapper();
            fwMaterialALL.value = 'ALL';
            fwMaterialALL.label = 'All Grades';
            returnWrap.materialList.add(fwMaterialALL);
            
            RE_Product__c[] prodLst = [select id, Name 
                                       from RE_Product__c
                                       where Active__c = true and recordtypeid = :RT_Util.prodRecTypeId 
                                       and RT_Product_Type__c = :RT_Util.gradeProdType
                                      order by name];
            for(RE_Product__c p : prodLst)
            {
                filterWrapper fwMaterial = new filterWrapper();
                fwMaterial.label = p.name;
                fwMaterial.value = p.id;
                returnWrap.materialList.add(fwMaterial);
            }
            
            returnWrap.dailyAdjustment = RT_Util.getDailyAdjustment();
            returnWrap.priceData = calculatePriceWithUpsert();
            returnWrap.outputReportID = getReportID().get(RT_Util.outputReportName);
            returnWrap.exportReportID = getReportID().get(RT_Util.exportReportName);
        }
        
        return returnWrap;
    }
    
    @AuraEnabled
    public static void runPriceLogic()
    {
        try{
            delete [select id from RT_PriceOutput__c where PriceDate__c = today];
        }catch(exception e)
        {
            System.debug(e.getMessage());
        }
        Database.executeBatch((Database.Batchable<sObject>)Type.forName(RT_Util.logicRunClassName).newInstance());
    }

    @TestVisible
    static map<String,ID> getReportID()
    {
        map<String,ID> returnMap = new map<String,ID>();
        List<String> reportNames = new List<String>{RT_Util.outputReportName, RT_Util.exportReportName};

        Report[] rep = [SELECT Id,name FROM Report
                    where name in :reportNames and FolderName = :RT_Util.reportFolderName];
        for(Report r : rep)
            returnMap.put(r.name,r.id);

        return returnMap;

    }
    
    @TestVisible
    static void setDailyAdjustment(Decimal value)
    {
        RT_Setting__c dailyAdjust = new RT_Setting__c();
        try{
		dailyAdjust = [select id, name, value__c from RT_Setting__c 
                       where name = :RT_Util.dailyAdjustmentRecordName and recordtypeid = :RT_Util.codeSettRecTypeId 
                       and Type__c = :RT_Util.dailyAdjystmentType 
                       and Country__c = :RT_Util.countryName limit 1];
        }catch(Exception e){System.debug(e);}
        
        if(dailyAdjust != new RT_Setting__c())
        {
            dailyAdjust.Value__c = String.valueof(value);
            try{
                    update dailyAdjust;
                }catch(Exception e){System.debug(e);}
        }
    }
    
    public static List<RT_Util.priceWrapper> calculatePriceWithUpsert()
    {
        List<RT_Util.priceWrapper> returnWrap = new List<RT_Util.priceWrapper>();
        
        List<RT_PriceOutput__c> existPriceList = RT_Util.queryPriceData(global_whereCond + global_sorting);
        if(existPriceList.size()>0)
        {
            map<id, RT_PriceOutput__c> existPriceMap = new map<id, RT_PriceOutput__c>();
            for(RT_PriceOutput__c p: existPriceList)
                existPriceMap.put(p.id,p);
            
            returnWrap = RT_Util.buildPriceWrapper(existPriceList);
            
            List<RT_PriceOutput__c> newPriceList = RT_Util.buildPriceList(returnWrap);
            
            if(newPriceList.size()>0)
            {
                List<RT_PriceOutput__c> updPriceList = new List<RT_PriceOutput__c>();
                
                for(RT_PriceOutput__c p: newPriceList)
                {
                    if(existPriceMap.containskey(p.id))
                    {
                        if(existPriceMap.get(p.id).CF_IMM__c != p.CF_IMM__c
                          || existPriceMap.get(p.id).TotalPostDiscountPrice__c != p.TotalPostDiscountPrice__c)
                            updPriceList.add(p);
                    }
                }
                
                if(updPriceList.size()>0)
                {
                    try{
                        update updPriceList;
                    }catch(exception e){System.debug(e);}
                }
                
            }
        }
        
        return returnWrap;
    }
    
    @AuraEnabled
    public static List<RT_Util.priceWrapper> savePriceChange(String changeType, String priceId, String value)
    {
        List<RT_Util.priceWrapper> returnWrap = new List<RT_Util.priceWrapper>();
        
        if(priceId != '' && priceId != null)
        {
            List<RT_Util.priceWrapper> existPriceWrap = RT_Util.buildPriceWrapper(RT_Util.queryPriceData(' and id = \'' + priceId + '\'' + global_whereCond));
            if(existPriceWrap.size()>0)
            {
                for(RT_Util.priceWrapper pw: existPriceWrap)
                {
                                        
                        if(changeType.equalsIgnoreCase('amount'))
                        {
                            pw.status = 'Edited';
                            pw.amount = Decimal.valueOf(value);
                            pw.submitterID = UserInfo.getUserId();
                        }
                        if(changeType.equalsIgnoreCase('adjustment'))
                        {
                            pw.status = 'Edited';
                            pw.adjustment = Decimal.valueOf(value);
                            pw.submitterID = UserInfo.getUserId();
                        }
                    	if(changeType.equalsIgnoreCase('approve'))
                        {
                            pw.status = 'Approved';
                            pw.approverID = UserInfo.getUserId();
                        }
                    	if(changeType.equalsIgnoreCase('reject'))
                        {
                            pw.status = 'Rejected';
                            pw.approverID = UserInfo.getUserId();
                        }
                }
                
                List<RT_PriceOutput__c> updateList = RT_Util.buildPriceList(existPriceWrap);
                if(updateList.size()>0)
                {
                        try{
                            update updateList;
                        }catch(Exception e){System.debug(e);}
                }
                returnWrap = calculatePriceWithUpsert();
            }
        }
        return returnWrap;
    }

    @AuraEnabled
    public static List<RT_Util.priceWrapper> saveDailyAdjustment(String dailyAdjust)
    {
        List<RT_Util.priceWrapper> returnWrap = new List<RT_Util.priceWrapper>();

        List<RT_Util.priceWrapper> existPriceWrap = RT_Util.buildPriceWrapper(RT_Util.queryPriceData(global_whereCond));
        
            if(existPriceWrap.size()>0)
            {
                List<RT_Util.priceWrapper> updatePriceWrap = new List<RT_Util.priceWrapper>();
                for(RT_Util.priceWrapper pw: existPriceWrap)
                {
                    if(!pw.hideAdjustment)
                    {
                        //if(pw.status.equalsIgnoreCase('Edited') || pw.status.equalsIgnoreCase('New'))
                        //{
                            pw.status = 'Edited';
                            pw.adjustment = Decimal.valueOf(dailyAdjust);
                            pw.submitterID = UserInfo.getUserId();
                            updatePriceWrap.add(pw);
                        //}
                    }
                }
                
                if(updatePriceWrap.size() > 0)
                {
                    List<RT_PriceOutput__c> updateList = RT_Util.buildPriceList(updatePriceWrap);
                    try{
                            update updateList;
                        }catch(Exception e){System.debug(e);}
                
                	setDailyAdjustment(Decimal.valueOf(dailyAdjust));
                
                 	
                }
            }
        
        returnWrap = calculatePriceWithUpsert();
        
        return returnWrap;
    }
 
	@AuraEnabled
    public static List<RT_Util.priceWrapper> approveRejectAll(String changeType)
    {
        List<RT_Util.priceWrapper> returnWrap = new List<RT_Util.priceWrapper>();
        
        List<RT_Util.priceWrapper> existPriceWrap = RT_Util.buildPriceWrapper(RT_Util.queryPriceData(global_whereCond));
        
            if(existPriceWrap.size()>0)
            {
                for(RT_Util.priceWrapper pw: existPriceWrap)
                {
                        if(changeType.equalsIgnoreCase('approve'))
                        {
                            pw.status = 'Approved';
                            pw.approverID = UserInfo.getUserId();
                        }
                        if(changeType.equalsIgnoreCase('reject'))
                        {
                            pw.status = 'Rejected';
                            pw.approverID = UserInfo.getUserId();
                        }
                }
                
                List<RT_PriceOutput__c> updateList = RT_Util.buildPriceList(existPriceWrap);
                if(updateList.size() > 0)
                {
                    try{
                            update updateList;
                        }catch(Exception e){System.debug(e);}
                
                 	returnWrap = calculatePriceWithUpsert();
                }
            }
        
        return returnWrap;
    }
    
    @AuraEnabled
    public static List<RT_Util.priceWrapper> matchAll()
    {
        List<RT_Util.priceWrapper> returnWrap = new List<RT_Util.priceWrapper>();
        
        List<RT_Util.priceWrapper> existPriceWrap = RT_Util.buildPriceWrapper(RT_Util.queryPriceData(global_whereCond));
        
            if(existPriceWrap.size()>0)
            {
                List<RT_Util.priceWrapper> updatePriceWrap = new List<RT_Util.priceWrapper>();
                for(RT_Util.priceWrapper pw: existPriceWrap)
                {
                        if(pw.cfMargin.setScale(2) > RT_Util.marginPercentage.setScale(2) && pw.amount != pw.suggestedAmount)
                        {
                            System.debug('update Amount='+pw.suggestedAmount + ' for '+ pw.keyVal);
                            pw.amount = pw.suggestedAmount;
                            pw.status = 'Edited';
                            pw.submitterID = UserInfo.getUserId();
                            updatePriceWrap.add(pw);
                        }
                }

				System.debug('updatePriceWrap='+ updatePriceWrap.size());
                
                if(updatePriceWrap.size()>0)
                {
                    List<RT_PriceOutput__c> updateList = RT_Util.buildPriceList(updatePriceWrap);
                    if(updateList.size() > 0)
                    {
                        try{
                                update updateList;
                            }catch(Exception e){System.debug(e);}
                        
                    }
                }
            }
        
        returnWrap = calculatePriceWithUpsert();
        
        return returnWrap;
    }
    
    @AuraEnabled
    public static List<RT_Util.priceWrapper> submitForReview()
    {
        List<RT_Util.priceWrapper> returnWrap = new List<RT_Util.priceWrapper>();
        
        List<RT_PriceOutput__c> updPriceLst = new List<RT_PriceOutput__c>();
        
        List<RT_Util.priceWrapper> existPriceWrap = RT_Util.buildPriceWrapper(RT_Util.queryPriceData(global_whereCond));
        
        if(existPriceWrap.size()>0)
            {
                List<RT_Util.priceWrapper> updatePriceWrap = new List<RT_Util.priceWrapper>();
                for(RT_Util.priceWrapper pw: existPriceWrap)
                {
                        if(pw.status.equalsIgnoreCase('Edited') || pw.status.equalsIgnoreCase('New'))
                        {
                            pw.status = 'In Review';
                            pw.submitterID = UserInfo.getUserId();
                            updatePriceWrap.add(pw);
                        }
                }
                
                if(updatePriceWrap.size()>0)
                 {
                     List<RT_PriceOutput__c> updateList = RT_Util.buildPriceList(updatePriceWrap);
                    try{
                            update updateList;
                        }catch(Exception e){System.debug(e);}
                 }
                
            }
        returnWrap = calculatePriceWithUpsert();
        
        return returnWrap;
    }
    
    public class filterWrapper
    {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    
    public class pageWrapper
    {
        @AuraEnabled
        public List<filterWrapper> soldToList = new List<filterWrapper>();
        @AuraEnabled
        public List<filterWrapper> plantList = new List<filterWrapper>();
        @AuraEnabled
        public List<filterWrapper> materialList = new List<filterWrapper>();
        @AuraEnabled
        public List<RT_Util.priceWrapper> priceData = new List<RT_Util.priceWrapper>();
        @AuraEnabled
        public Decimal dailyAdjustment = 0;
        @AuraEnabled
        public ID outputReportID;
        @AuraEnabled
        public ID exportReportID;
        @AuraEnabled
        public Boolean isLogicRunning = false;
        @AuraEnabled
        public Decimal marginPercentage = RT_Util.marginPercentage;
    }
}