/******************************************************************************************************************
className           :    RE_CND_saveRecordQueue
Description         :    Queuable class to save bulk records after adjustment
Author              :    Aasiya Siraj
Date				:	 21-JUNE-2022 
*******************************************************************************************************************/
public class RE_CND_saveRecordQueue implements Queueable{
    
    private String updatedRecords ;
    private Date datefilter;
    private RE_Job_Run_Audit__c jrAudit;
    
    public RE_CND_saveRecordQueue(String updatedRecords,Date datefilter,RE_Job_Run_Audit__c jrAudit)
    {
        this.updatedRecords=updatedRecords;
        this.datefilter=datefilter;
        this.jrAudit=jrAudit;
    }
    
     public void execute(QueueableContext context) 
    {
        System.debug('execute method called--');
        try{
        Boolean isRecordUpdated=false;
        Boolean hasFutureRecord=false;
       // List<RE_MY_CostPrice__c> cpListToUpsert	=	new List<RE_MY_CostPrice__c> ();
        //List<RT_Price_Book__c> pbListToUpsert	=	new List<RT_Price_Book__c> ();
        
        List<RE_MY_CostPrice__c> cpListToInsert	=	new List<RE_MY_CostPrice__c> ();
        List<RT_Price_Book__c> pbListToInsert	=	new List<RT_Price_Book__c> ();
        
        List<RE_MY_CostPrice__c> cpListToUpdate	=	new List<RE_MY_CostPrice__c> ();
        List<RT_Price_Book__c> pbListToUpdate	=	new List<RT_Price_Book__c> ();
        
        
        List<String> moaRacks=new List<String>{'Belleville', 'Ottawa','Kingston','Sarnia','London','Sault Ste Marie','Thunder Bay','Kamloops'};
            
        Map<String,String> diffMap=new Map<String,String>{'Ottawa-Gasoline'=>'Toronto-Gasoline','Thunder Bay-Gasoline'=>'Edmonton-Gasoline','Kamloops-Gasoline'=>'Edmonton-Gasoline',
                'Ottawa-Gas Oil'=>'Toronto-Gas Oil','Thunder Bay-Gas Oil'=>'Edmonton-Gas Oil','Kamloops-Gas Oil'=>'Edmonton-Gas Oil'};
                    
        Id costPriceRecordTypeId 	= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id pricebookRecordTypeId 	= Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
        Id cadMOARecordTypeId 		= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
        
        
         Map<Id,RE_CND_RackDetail_Controller.saveWrapper> cpMap = new Map<Id,RE_CND_RackDetail_Controller.saveWrapper>();
            Map<Id,RE_CND_RackDetail_Controller.saveWrapper> pbMap = new Map<Id,RE_CND_RackDetail_Controller.saveWrapper>();
            Date effectiveTo ;
            Map<String,Decimal> MOAMap =new Map<String,Decimal>();
            Map<String,Decimal> oldAdjustMap =new Map<String,Decimal>();
            Map<String,RE_MOA__c> moaDetailMap = new Map<String,RE_MOA__c>();
            List<RE_MOA__c> moaToUpdate = new List<RE_MOA__c>();
        	Boolean isBothEmpty=false;
            List<RE_CND_RackDetail_Controller.saveWrapper> saveWrap = (List<RE_CND_RackDetail_Controller.saveWrapper>)JSON.deserialize(updatedRecords, List<RE_CND_RackDetail_Controller.saveWrapper>.class);
            
        	System.debug('before futur CP--');
            List<RE_MY_CostPrice__c> futureCP =[SELECT Id FROM RE_MY_CostPrice__c WHERE RE_CND_Effective_From_Date__c <= TOMORROW AND RE_CND_Effective_To_Date__c >= TOMORROW 
                                                AND  RecordTypeId=:costPriceRecordTypeId AND RE_IsLatest__c=TRUE];
            System.debug('after futur CP--');
            if(futureCP.size()>0 &&  datefilter==System.today())
            {hasFutureRecord =true;  }
            else
            {hasFutureRecord =false;  }
            
        	System.debug('hasFutureRecord--'+hasFutureRecord);
            if(hasFutureRecord==false)
            {
            	for( RE_CND_RackDetail_Controller.saveWrapper sw : saveWrap)
            	{
                if(sw.custType=='Branded'||sw.custType=='Unbranded')
                {
                    cpMap.put(sw.recordId,sw);
                }
                else if(sw.custType=='SFJ')
                {
                    pbMap.put(sw.recordId,sw);
                }
            	}   
            }   
            if(cpMap.size() > 0)
            {
                System.debug('cpMap size > 0');
                for(RE_MY_CostPrice__c cp:[SELECT Id,RE_CND_Rack__c,RE_CND_Final_Value__c,RE_Initial_Version__c,RE_CND_Differential_Basis__c,RE_Costprice_Unit__c,
                                           RE_CND_Product_Group__c,RE_CND_Adjustment_Value__c,RE_Product_Name__c,RE_Depot_Name__c,RE_IsLatest__c,RE_Pricing_Date__c,
                                           RE_CND_Brand_Discount__c,RE_CND_Plant_Differential__c,RE_CND_Brand_Fee__c,RE_CND_Product_Differential__c,RE_Fx_Rate__c,
                                           RE_CND_Old_Base_Value__c,RE_CND_Net_Move_Value__c,RE_CND_Market_Move__c,RE_CND_New_Base_Value__c,RE_Submitter_Comments__c,
                                           RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c,RE_CND_Pricing_Basis__c,RE_Product_Codes__c,RE_Depot_Code__c , 
                                           //RE_CND_Parent_Rack__c,RE_CND_Parent_Rack_Group__c,
                                           RE_CND_Special_Adjustment__c,RE_Comments__c,RE_Product_Name__r.RE_Product_Classification_L0__c,RE_CND_Supplier4_Price__c,
                                           RE_CND_Supplier1_Price__c,RE_CND_Supplier2_Price__c,RE_CND_Supplier3_Price__c,RE_CND_NewRack_Or_NewBAPP_File__c,
                                           RE_CND_CanadianDailyRack7Day_DEX__c,RE_CND_CanadianDailyRack_DEX__c,RE_CND_PA__c,RE_CND_PA_Product_code__c,
                                           RE_CND_DEX_product_code__c,RE_CND_DEX_Products__c,RE_CND_DEX_loc_code__c,RE_CND_PA_loc_code__c,RE_Requested_Date__c,
                                           RE_CND_Required_in_Rack_Prices__c,RE_CND_Rack_Prices_Location__c,RE_CND_Rack_Prices_Product__c,RE_CND_Req_in_DailyRackChange_Notifi__c,
                                           RE_CND_CanadianDailyRack_Location__c,RE_CND_Required_CanadianDailyRack7Day__c,RE_CND_Required_CanadianDailyRack__c,
                                           RE_Status__c ,RE_CND_Is_Base_Product__c,RE_CND_Group__c,RE_CND_Location_Abbreviated_Name__c,RE_CND_Product_Name__c,
                                           RE_CND_Required_in_OPIS_Comparison__c,RE_CND_Reference_Rack__c,RE_CND_Rack_Basis_Differential__c,
                                           RE_CND_Is_only_applicable_to_SFJ__c ,RE_CND_Notify_Users__c 
                                           FROM RE_MY_CostPrice__c WHERE Id IN : cpMap.keySet() AND RE_IsLatest__c=TRUE])
                {
                    Decimal adjusBefore=cp.RE_CND_Adjustment_Value__c;
                    
                    if(cp.RE_Status__c=='Draft'||cp.RE_Status__c=='Ready to Upload')
                    {
                        //update existing record
                        RE_CND_RackDetail_Controller.saveWrapper sWrap=cpMap.get(cp.Id);
                        cp.RE_CND_Adjustment_Value__c=sWrap.Adjustment+cp.RE_CND_Adjustment_Value__c;
                        cp.RE_CND_Final_Value__c=sWrap.finalValue;
                        cp.RE_Submitter_Comments__c=sWrap.Comment;
                        cp.RE_Status__c='Ready to Upload';
                        cpListToUpdate.add(cp);
                    }
                    else
                    {
                        //update old islatest false and  create new version
                        cp.RE_IsLatest__c=false;
                        cpListToUpdate.add(cp);
                        
                        RE_CND_RackDetail_Controller.saveWrapper sWrap=cpMap.get(cp.Id);
                        RE_MY_CostPrice__c cpNew = new RE_MY_CostPrice__c();
                        //ADD DEX INFO;
                        cpNew.RE_CND_Notify_Users__c					=	cp.RE_CND_Notify_Users__c;
                        cpNew.RE_CND_Required_CanadianDailyRack__c		=	cp.RE_CND_Required_CanadianDailyRack__c;
                        cpNew.RE_CND_Required_CanadianDailyRack7Day__c	=	cp.RE_CND_Required_CanadianDailyRack7Day__c;
                        cpNew.RE_CND_CanadianDailyRack_Location__c		=	cp.RE_CND_CanadianDailyRack_Location__c;
                        cpNew.RE_CND_PA_loc_code__c						=	cp.RE_CND_PA_loc_code__c;
                        cpNew.RE_CND_DEX_loc_code__c					=	cp.RE_CND_DEX_loc_code__c;
                        cpNew.RE_CND_DEX_Products__c					=	cp.RE_CND_DEX_Products__c;
                        cpNew.RE_CND_DEX_product_code__c				=	cp.RE_CND_DEX_product_code__c;
                        cpNew.RE_CND_PA_Product_code__c					=	cp.RE_CND_PA_Product_code__c;
                        cpNew.RE_CND_PA__c								=	cp.RE_CND_PA__c;
                        cpNew.RE_CND_CanadianDailyRack_DEX__c			=	cp.RE_CND_CanadianDailyRack_DEX__c;
                        cpNew.RE_CND_CanadianDailyRack7Day_DEX__c		=	cp.RE_CND_CanadianDailyRack7Day_DEX__c;
                        cpNew.RE_CND_NewRack_Or_NewBAPP_File__c			=	cp.RE_CND_NewRack_Or_NewBAPP_File__c;
                        cpNew.RE_CND_Required_in_Rack_Prices__c 		= 	cp.RE_CND_Required_in_Rack_Prices__c;
                        cpNew.RE_CND_Rack_Prices_Location__c 			= 	cp.RE_CND_Rack_Prices_Location__c;
                        cpNew.RE_CND_Rack_Prices_Product__c 			= 	cp.RE_CND_Rack_Prices_Product__c;
                        cpNew.RE_CND_Req_in_DailyRackChange_Notifi__c 	= 	cp.RE_CND_Req_in_DailyRackChange_Notifi__c;
                        cpNew.RE_CND_Reference_Rack__c 					= 	cp.RE_CND_Reference_Rack__c;
                        cpNew.RE_CND_Rack_Basis_Differential__c 		= 	cp.RE_CND_Rack_Basis_Differential__c;
                        
                        cpNew.RecordTypeId=costPriceRecordTypeId;
                        cpNew.RE_CND_Adjustment_Value__c=sWrap.Adjustment+cp.RE_CND_Adjustment_Value__c;
                        cpNew.RE_CND_Market_Move__c=cp.RE_CND_Market_Move__c;
                        cpNew.RE_Depot_Name__c=cp.RE_Depot_Name__c;
                        cpNew.RE_CND_New_Base_Value__c=cp.RE_CND_New_Base_Value__c;
                        cpNew.RE_CND_Final_Value__c=sWrap.finalValue;
                        cpNew.RE_Initial_Version__c=cp.RE_Initial_Version__c;
                        cpNew.RE_Fx_Rate__c=cp.RE_Fx_Rate__c;
                        cpNew.RE_Costprice_Unit__c=cp.RE_Costprice_Unit__c;
                        cpNew.RE_Status__c='Ready to Upload';
                        cpNew.RE_Submitter_Comments__c=sWrap.Comment;
                        cpNew.RE_IsLatest__c=true;
                        cpNew.RE_Pricing_Date__c=System.Now();
                        cpNew.RE_CND_Effective_From_Date__c=cp.RE_CND_Effective_From_Date__c;
                        cpNew.RE_CND_Effective_To_Date__c=cp.RE_CND_Effective_To_Date__c;
                        cpNew.RE_Requested_Date__c=cp.RE_Requested_Date__c;
                        cpNew.RE_CND_Rack__c=cp.RE_CND_Rack__c;
                        cpNew.RE_Product_Name__c=cp.RE_Product_Name__c;
                        cpNew.RE_CND_Product_Group__c=cp.RE_CND_Product_Group__c;
                        cpNew.RE_CND_Old_Base_Value__c=cp.RE_CND_Old_Base_Value__c;
                        cpNew.RE_CND_Differential_Basis__c=cp.RE_CND_Differential_Basis__c;
                        cpNew.RE_CND_Pricing_Basis__c=cp.RE_CND_Pricing_Basis__c;
                        cpNew.RE_CND_Group__c=cp.RE_CND_Group__c;
                        // cpNew.RE_CND_Parent_Rack__c=cp.RE_CND_Parent_Rack__c;
                        //cpNew.RE_CND_Parent_Rack_Group__c=cp.RE_CND_Parent_Rack_Group__c;
                        cpNew.RE_CND_Is_Base_Product__c=cp.RE_CND_Is_Base_Product__c;
                        cpNew.RE_CND_Required_in_OPIS_Comparison__c=cp.RE_CND_Required_in_OPIS_Comparison__c;
                        cpNew.RE_CND_Brand_Discount__c=cp.RE_CND_Brand_Discount__c;
                        cpNew.RE_CND_Plant_Differential__c=cp.RE_CND_Plant_Differential__c;
                        cpNew.RE_CND_Brand_Fee__c=cp.RE_CND_Brand_Fee__c;
                        cpNew.RE_CND_Product_Differential__c=cp.RE_CND_Product_Differential__c;
                        cpNew.RE_CND_Special_Adjustment__c=cp.RE_CND_Special_Adjustment__c;
                        cpNew.RE_Comments__c=cp.RE_Comments__c;
                        cpNew.RE_CND_Supplier1_Price__c=cp.RE_CND_Supplier1_Price__c;
                        cpNew.RE_CND_Supplier2_Price__c=cp.RE_CND_Supplier2_Price__c;
                        cpNew.RE_CND_Supplier3_Price__c=cp.RE_CND_Supplier3_Price__c;
                        cpNew.RE_CND_Supplier4_Price__c=cp.RE_CND_Supplier4_Price__c;
                        cpNew.RE_CND_Is_only_applicable_to_SFJ__c = cp.RE_CND_Is_only_applicable_to_SFJ__c;
                        cpListToInsert.add(cpNew);
                    }
                    
                    effectiveTo=cp.RE_CND_Effective_To_Date__c;
                    if(cp.RE_CND_Is_Base_Product__c ||(moaRacks.contains(cp.RE_CND_Rack__c) && (cp.RE_CND_Product_Group__c=='RUG'||cp.RE_CND_Product_Group__c=='ULSD')))
                    {
                        MOAMap.put(cp.RE_CND_Rack__c+'-'+cp.RE_Product_Name__r.RE_Product_Classification_L0__c,cpMap.get(cp.Id).Adjustment);
                        oldAdjustMap.put(cp.RE_CND_Rack__c+'-'+cp.RE_Product_Name__r.RE_Product_Classification_L0__c,adjusBefore);
                    }
                    
                    //System.debug('MOAMap--'+MOAMap);
                    
                }
                System.debug('after CP loop--');
            }
            if(pbMap.size() > 0)
            {
                System.debug('pbMap size > 0');
                for(RT_Price_Book__c pb : [SELECT id,RE_CND_Rack__c, RE_CND_Product_Group__c,RE_CND_Adjustment_Value__c,RE_CND_Customer_Name__r.AccountNumber ,RT_Product__c,
                                           RE_CND_Customer_Name__c,RE_CND_Net_Move_Value__c,RE_Initial_Version__c,RT_Sold_to_Name__c,RE_Final_Price_Unit__c,RE_Fx_Rate__c,
                                           RE_CND_Old_Base_Value__c, RE_CND_New_Base_Value__c,RE_CND_Market_Move__c,RE_Submitter_Comments__c,RE_CND_Final_Value__c, RT_Effective_Date__c,
                                           RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c,RE_CND_Pricing_Basis__c,RT_Product_Code__c,RT_Location_Code__c,
                                           RE_Is_Latest__c,RE_Pricing_Date__c,RE_Custom_Opp_Approve__c, RE_CND_Product_Name__c,RE_CND_Customer_Name__r.Name, RE_CND_ShipTo_Number__c
                                           FROM RT_Price_Book__c WHERE  Id IN : pbMap.keySet() AND RE_Is_Latest__c=TRUE])
                {
                    if(pb.RE_Custom_Opp_Approve__c=='Draft')
                    {
                        //update existing record
                        RE_CND_RackDetail_Controller.saveWrapper sWrap=pbMap.get(pb.Id);
                       // pb.RE_CND_Adjustment_Value__c=sWrap.Adjustment+pb.RE_CND_Adjustment_Value__c;
                        pb.RE_CND_Adjustment_Value__c=sWrap.Adjustment;
                        pb.RE_CND_Final_Value__c=sWrap.finalValue;
                        pb.RE_Submitter_Comments__c=sWrap.Comment;
                        pb.RE_Custom_Opp_Approve__c='Ready to Upload';
                        pbListToUpdate.add(pb);
                    }
                    else if(pb.RE_Custom_Opp_Approve__c=='Ready to Upload')
                    {
                        //update existing record
                        RE_CND_RackDetail_Controller.saveWrapper sWrap=pbMap.get(pb.Id);
                        pb.RE_CND_Adjustment_Value__c=sWrap.Adjustment+pb.RE_CND_Adjustment_Value__c; 
                        pb.RE_CND_Final_Value__c=sWrap.finalValue;
                        pb.RE_Submitter_Comments__c=sWrap.Comment;
                        pb.RE_Custom_Opp_Approve__c='Ready to Upload';
                        pbListToUpdate.add(pb);
                    }

                    else
                    {
                        //update old islatest false and  create new version
                        pb.RE_Is_Latest__c=false;
                        pbListToUpdate.add(pb);
                        
                        RE_CND_RackDetail_Controller.saveWrapper sWrap=pbMap.get(pb.Id);
                        RT_Price_Book__c pbNew = new RT_Price_Book__c();
                        pbNew.RecordTypeId=pricebookRecordTypeId;
                        pbNew.RE_CND_Adjustment_Value__c=sWrap.Adjustment+pb.RE_CND_Adjustment_Value__c;
                        pbNew.RE_CND_New_Base_Value__c=pb.RE_CND_New_Base_Value__c;
                        pbNew.RE_CND_Final_Value__c=sWrap.finalValue;
                        pbNew.RE_Initial_Version__c=pb.RE_Initial_Version__c;
                        pbNew.RE_Custom_Opp_Approve__c='Ready to Upload';
                        pbNew.RE_Fx_Rate__c	=pb.RE_Fx_Rate__c;
                        pbNew.RE_Final_Price_Unit__c		=	pb.RE_Final_Price_Unit__c;
                        pbNew.RE_Submitter_Comments__c		=	sWrap.Comment;
                        pbNew.RE_Is_Latest__c				=	true;
                        pbNew.RE_CND_Product_Group__c		=	pb.RE_CND_Product_Group__c;
                        pbNew.RE_CND_Pricing_Basis__c		=	pb.RE_CND_Pricing_Basis__c;
                        pbNew.RT_Product__c					=	pb.RT_Product__c;  
                        pbNew.RE_CND_Old_Base_Value__c		=	pb.RE_CND_Old_Base_Value__c;
                        pbNew.RE_CND_Market_Move__c			=	pb.RE_CND_Market_Move__c;
                        pbNew.RE_CND_Effective_From_Date__c	=	pb.RE_CND_Effective_From_Date__c;
                        pbNew.RE_CND_Effective_To_Date__c	=	pb.RE_CND_Effective_To_Date__c;
                        pbNew.RE_Pricing_Date__c	=	System.now();
                        pbNew.RT_Sold_to_Name__c	=	pb.RT_Sold_to_Name__c;
                        pbNew.RT_Effective_Date__c	=	pb.RT_Effective_Date__c;
                        pbNew.RE_CND_Customer_Name__c =	pb.RE_CND_Customer_Name__c;
                        pbNew.RE_CND_Rack__c = pb.RE_CND_Rack__c;
                        pbNew.RE_CND_ShipTo_Number__c = pb.RE_CND_Customer_Name__r.AccountNumber;
                        pbListToInsert.add(pbNew);
                    }
                }
            }
             System.debug('After PB loop--');          
            
            if(MOAMap.size()>0)
            {
                System.debug('MOAMap > 0');
                for(RE_MOA__c moa:[SELECT id,RE_CND_Today_s_Price__c,RE_CND_Competitive_Adj__c,  RE_CND_Difference__c,   RE_CND_Group__c,  RE_CND_Market_Move__c, 
                                   RE_CND_Net_Move__c, RE_CND_New_End_Price__c,RE_AM_Comments__c,  RE_CND_Rack__c FROM RE_MOA__c 
                                   WHERE RecordTypeId =: cadMOARecordTypeId AND RE_CND_Effective_To_Date__c =: effectiveTo
                                   AND RE_IsLatest__c =: TRUE])
                {
                    moaDetailMap.put(moa.RE_CND_Rack__c+'-'+moa.RE_CND_Group__c,moa);
                }
                System.debug('moaDetailMap--'+moaDetailMap);
                
                for(String key:MOAMap.keySet())
                {
                   System.debug('before updateMOA---');
                    //Decimal prevAdjust=oldAdjustMap.get(key);
                    Decimal prevAdjust = (oldAdjustMap.get(key) == null) ? 0.00 : oldAdjustMap.get(key);  
                    String comment='Adjusment made on Base product on CA Dashboard';
                    RE_MOA__c moa1=RE_CND_RackDetail_Controller.updateMOA(MOAMap.get(key),moaDetailMap.get(key),comment,false,moaDetailMap.get(key).RE_CND_New_End_Price__c,prevAdjust);
                    moaToUpdate.add(moa1); 
                     System.debug('After updateMOA---');
                }
                
                System.debug('before handleUpdateResult---');
                Database.SaveResult[] updateMOA= Database.update(moaToUpdate, false);
                Boolean isError= RE_CND_Utility.handleUpdateResult('RE_CND_RackDetail_Controller','saveRecord',updateMOA,false,jrAudit);
                System.debug('after handleUpdateResult---');
            }
            
            if(MOAMap.size()>0)
            {
                System.debug('MOAMap > 0');
                List<RE_MOA__c> diffMOAListToUpdate = new List<RE_MOA__c>();
                Map<String,RE_MOA__c> diffPriceMap = new Map<String,RE_MOA__c>();
                for(RE_MOA__c moa:[SELECT id,RE_CND_Difference__c,   RE_CND_Group__c, RE_CND_New_End_Price__c, RE_CND_Rack__c FROM RE_MOA__c 
                                   WHERE RecordTypeId =: cadMOARecordTypeId AND RE_CND_Effective_To_Date__c =: effectiveTo
                                   AND RE_IsLatest__c =: TRUE])
                {
                    diffPriceMap.put(moa.RE_CND_Rack__c+'-'+moa.RE_CND_Group__c,moa);
                    System.debug('diffPriceMap--'+diffPriceMap);
                }
                
                for(String diffRack :diffMap.keySet())
                {
                    System.debug('diffRack--'+diffRack+'--value--'+diffPriceMap.get(diffRack));
                    RE_MOA__c diffMOAToUpdate = diffPriceMap.get(diffRack);
                    System.debug('diffMOAToUpdate--'+diffMOAToUpdate);
                    diffMOAToUpdate.RE_CND_Difference__c= diffMOAToUpdate.RE_CND_New_End_Price__c-diffPriceMap.get(diffMap.get(diffRack)).RE_CND_New_End_Price__c;
                    diffMOAListToUpdate.add(diffMOAToUpdate);
                }
                
                System.debug('before updateMOADiff---');
                if(diffMOAListToUpdate !=null)
                {
                    Database.SaveResult[] updateMOADiff= Database.update(diffMOAListToUpdate, false);
                    Boolean isError= RE_CND_Utility.handleUpdateResult('RE_CND_RackDetail_Controller','saveRecord',updateMOADiff,false,jrAudit);  
                }
                System.debug('after updateMOADiff---');
            }
            
             if(cpListToInsert.size() >0 )
            {
                System.debug('cpListToInsert not null ---size--'+cpListToInsert.size());
                Database.SaveResult[] cpInsertStatus=Database.insert(cpListToInsert, false);
                Set<Id> cpInserted=RE_CND_Utility.handleInsert('RE_CND_saveRecordQueue','insertCP',cpInsertStatus,jrAudit);
                //RE_CND_BatchUpsert bu = new RE_CND_BatchUpsert(cpListToUpsert,pbListToUpsert, jrAudit);
                //Database.executebatch(bu,50);
            }
        
        	
            if(pbListToInsert.size() >0)
            {
              	System.debug('pbListToInsert not null ---size--'+pbListToInsert.size());
                Database.SaveResult[] pbInsertStatus=Database.insert(pbListToInsert, false);
                Set<Id> pbInserted=RE_CND_Utility.handleInsert('RE_CND_saveRecordQueue','insertPB',pbInsertStatus,jrAudit);
                //RE_CND_PBBatchUpsert bu = new RE_CND_PBBatchUpsert(pbListToUpsert, jrAudit);
                //Database.executebatch(bu,200);
             } 
        
        	if(cpListToUpdate.size() >0 )
            {
                Database.SaveResult[] cpUpdateStatus=Database.update(cpListToUpdate, false);
                Boolean iscpError=RE_CND_Utility.handleUpdateResult('RE_CND_saveRecordQueue','insertCP',cpUpdateStatus,false,jrAudit);
                //RE_CND_BatchUpsert bu = new RE_CND_BatchUpsert(cpListToUpsert,pbListToUpsert, jrAudit);
                //Database.executebatch(bu,50);
            }
        
        	
            if(pbListToUpdate.size() >0)
            {
                Database.SaveResult[] pbUpdateStatus=Database.update(pbListToUpdate, false);
                Boolean ispbError=RE_CND_Utility.handleUpdateResult('RE_CND_saveRecordQueue','insertPB',pbUpdateStatus,false,jrAudit);
                //RE_CND_PBBatchUpsert bu = new RE_CND_PBBatchUpsert(pbListToUpsert, jrAudit);
                //Database.executebatch(bu,200);
             } 

        			if(hasFutureRecord)
            		{
                        System.debug('saveRecordQueue--case1');
                		jrAudit.RE_IsSuccess__c=false;
                		jrAudit.Other_Comments__c='Future records exist. Changes not allowed.';
            		}
            		else
                	{
             			if(cpListToInsert.size()==0 && pbListToInsert.size()==0 && cpListToUpdate.size()==0 && pbListToUpdate.size()==0)
             			{
                            System.debug('saveRecordQueue--case2');
                    		isRecordUpdated=true;
                			jrAudit.RE_IsSuccess__c=false;
                			jrAudit.Other_Comments__c='Record status changed by Others/from Other window. Please refresh the screen to get the latest data';
                		}
                		else
                		{
                            System.debug('saveRecordQueue--case3');
                 			jrAudit.RE_IsSuccess__c=true;
                 			jrAudit.Other_Comments__c='Records saved successfully!!';  
                		}
            		}
                    if(jrAudit.RE_Job_Status__c=='Processing')
                    {  jrAudit.RE_Job_Status__c='Completed'; }
                    update jrAudit;
                
        
           /* if(cpListToUpsert.size() >0 )
            {
                System.debug('cpListToUpsert not null ---size--'+cpListToUpsert.size());
                RE_CND_BatchUpsert bu = new RE_CND_BatchUpsert(cpListToUpsert,pbListToUpsert, jrAudit);
                Database.executebatch(bu,50);
            }
        	else
        	{
              if(pbListToUpsert.size() >0)
              {
                System.debug('pbListToUpsert not null ---size--'+pbListToUpsert.size());
                RE_CND_PBBatchUpsert bu = new RE_CND_PBBatchUpsert(pbListToUpsert, jrAudit);
                Database.executebatch(bu,200);
              }
              else
                {
                     if(hasFutureRecord)
            		{
                        System.debug('saveRecordQueue--case1');
                		jrAudit.RE_IsSuccess__c=false;
                		jrAudit.Other_Comments__c='Future records exist. Changes not allowed.';
            		}
            		else
                	{
             			if(cpListToUpsert.size()==0 && pbListToUpsert.size()==0)
             			{
                            System.debug('saveRecordQueue--case2');
                    		isRecordUpdated=true;
                			jrAudit.RE_IsSuccess__c=false;
                			jrAudit.Other_Comments__c='Record status changed by Others/from Other window. Please refresh the screen to get the latest data';
                		}
                		else
                		{
                            System.debug('saveRecordQueue--case3');
                 			jrAudit.RE_IsSuccess__c=true;
                 			jrAudit.Other_Comments__c='Records saved successfully!!';  
                		}
            		}
                    if(jrAudit.RE_Job_Status__c=='Processing')
                    {  jrAudit.RE_Job_Status__c='Completed'; }
                    update jrAudit;
                }
            }
            */
            }catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            if(	jrAudit!= NULL)
            {
                RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex); 
            }
            RV_ClassException.insertExceptionRecord('saveRecord',ex.getMessage()+ex.getLineNumber(),'RE_CND_saveRecordQueue','execute','Exception');
        }
          }
           
    

}