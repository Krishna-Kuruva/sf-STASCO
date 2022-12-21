/**************************************************************************************************
* Name: RE_CND_PricingInputStaging
* Object: RE_Market_Quotes__c & RE_MY_CostPrice__c
* Purpose: Competitor and Live OPIS Spot ticker for Revolution Canada
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-08-19
* Modify History: 
* 2021-08-19		Abhilash		Created
**************************************************************************************************/
public class RE_CND_PricingInputStaging {
    
    // Processing the Competitor imported records into RE_Market_Quotes__c and update RE_MY_CostPrice__c Object 
    public static void processCompetitorData(List<RE_Pricing_Input_STG__c> inputList)
    {
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        
        try
        {
            RE_JobControls__c jb;
            //RE_JobControls__c checks active methods
            jb = [SELECT Active__c FROM RE_JobControls__c WHERE Class_Name__c =: 'RE_CND_PricingInputStaging' AND Method_Name__c =: 'processCompetitorData' AND Country__c =:'Canada'];
            if(jb.Active__c)
            {
                Map<String,String> productGroupMapping = New Map<String,String>();
                Map<String,String> rackMapping = New Map<String,String>();                
                Map<String,Date> reqCompDate = New Map<String,Date>();
                Map<String,Decimal> reqCompPrice = New Map<String,Decimal>();
                Map<String,String> reqCompUnitRate = New Map<String,String>();
                Map<Date,Date> moveDateMap = New Map<Date,Date>();
                Map<String,Decimal> compRecords = New Map<String,Decimal>();
                Map<String,Double> fxRateMap = New Map<String,Double>();
                Id cndMQCompetrRecdTypId = Schema.SObjectType.RE_Market_Quotes__c.getRecordTypeInfosByDeveloperName().get('Canada_Competitor').getRecordTypeId();
                Id cndCostPriceRecdTypId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
                List<RE_Market_Quotes__c> competrMQ = New List<RE_Market_Quotes__c>();
                List<RE_Market_Quotes__c> competrMQFinalLst = New List<RE_Market_Quotes__c>();
                List<RE_MY_CostPrice__c> competrCP = New List<RE_MY_CostPrice__c>();
                Map<Id,RE_MY_CostPrice__c> cpMap = New Map<Id,RE_MY_CostPrice__c>();
                List<RV_Exception__c> excpList = new List<RV_Exception__c>();   
                List<RE_Pricing_Input_STG__c> pstgLst = New List<RE_Pricing_Input_STG__c>();
                List<RE_MY_CostPrice__c> maxCostPriceDate = New List<RE_MY_CostPrice__c>();
                Date maxCostPriceDt;  
                Decimal supplier1Price = 0.00;
                Decimal supplier2Price = 0.00;
                Decimal supplier3Price = 0.00;
                Decimal supplier4Price = 0.00;
                String supplier1Name, supplier2Name, supplier3Name, supplier4Name;                         
                String defutCurrcy,unitMeasure;
                
                jrAudit.RE_Run_Time__c = system.now();
                jrAudit.RE_Run_Type__c = 'Manual';
                jrAudit.RE_Job_Type__c = 'Canada Competitor Data Processing';
                jrAudit.RE_User__c = UserInfo.getUserId();
                jrAudit.RE_Job_Run_Count__c = 1;
                jrAudit.RE_Job_Status__c = 'Processing';
                jrAudit.RE_Country_Name__c='CA';
                insert jrAudit; 
                
                for(RE_Field_Value_Mappings__c fvm : RE_Field_Value_Mappings__c.getall().values())
                {
                    // All the active Product Groups for Competitor
                    if((fvm.Country_Name__c == 'Canada') && (fvm.Purpose__c == 'Competitor Data Import')
                      && (fvm.Object_Name__c == 'RE_MY_CostPrice__c') && (fvm.Field_Name__c == 'RE_CND_Product_Group__c')
                      && (fvm.Is_Active__c == TRUE) && (fvm.Mapping_Field_Value__c != 'NA to Shell'))
                    {
                        productGroupMapping.put(fvm.Source_Field_Value__c.toLowercase(),fvm.Mapping_Field_Value__c);                    
                    }
                    
                    // All the active Racks for Competitor
                    if((fvm.Country_Name__c == 'Canada') && (fvm.Purpose__c == 'Competitor Data Import')
                      && (fvm.Object_Name__c == 'RE_MY_CostPrice__c') && (fvm.Field_Name__c == 'RE_CND_Rack__c')
                      && (fvm.Is_Active__c == TRUE))
                    {
                         rackMapping.put(fvm.Source_Field_Value__c.toLowercase(),fvm.Mapping_Field_Value__c);
                    }
                    
                    // All the active Suppliers
                    if((fvm.Country_Name__c == 'Canada') && (fvm.Purpose__c == 'Competitor Data Import')
                      && (fvm.Object_Name__c == 'RE_MY_CostPrice__c') && (fvm.Is_Active__c == TRUE)
                      && ((fvm.Field_Name__c == 'RE_CND_Supplier1_Price__c') || (fvm.Field_Name__c == 'RE_CND_Supplier2_Price__c') 
                          || (fvm.Field_Name__c == 'RE_CND_Supplier3_Price__c') || (fvm.Field_Name__c == 'RE_CND_Supplier4_Price__c')))
                    {
                        if(fvm.Source_Field_Value__c.toLowercase() == 'supplier1')
                            supplier1Name = fvm.Mapping_Field_Value__c.toLowercase();
                        else if(fvm.Source_Field_Value__c.toLowercase() == 'supplier2')
                            supplier2Name = fvm.Mapping_Field_Value__c.toLowercase();
                        else if(fvm.Source_Field_Value__c.toLowercase() == 'supplier3')
                            supplier3Name = fvm.Mapping_Field_Value__c.toLowercase();  
                        else if(fvm.Source_Field_Value__c.toLowercase() == 'supplier4')
                            supplier4Name = fvm.Mapping_Field_Value__c.toLowercase();
                    }              
                }
                
                // Get latest Cost price Date
                maxCostPriceDate = [SELECT RE_CND_Effective_To_Date__c FROM RE_MY_CostPrice__c 
                                    WHERE RecordTypeId =: cndCostPriceRecdTypId AND RE_Status__c NOT IN ('Redundant')
                                    AND RE_IsLatest__c =: TRUE
                                    ORDER BY RE_CND_Effective_To_Date__c DESC LIMIT 1];       
                
            	if(maxCostPriceDate.Size() > 0)
                {
                    for(RE_MY_CostPrice__c mxPrcngToDt: maxCostPriceDate)
                    {
                        maxCostPriceDt = mxPrcngToDt.RE_CND_Effective_To_Date__c;
                    }  
                }
                else
                    maxCostPriceDt = system.today(); 
        
                system.debug('maxCostPriceDt-->'+maxCostPriceDt);
                
                // Check and create data into Market Quotes
                for(RE_Pricing_Input_STG__c inputComprtr : inputList)
                {
                    if((productGroupMapping.containsKey(inputComprtr.RE_CND_Product_Group__c.toLowercase())) && (rackMapping.containsKey(inputComprtr.RE_CND_City_Name__c.toLowercase())))
                    {
                        if(!compRecords.containsKey(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c))
                        {
                            RE_Market_Quotes__c mQComptr = New RE_Market_Quotes__c();
                            mQComptr.RecordTypeId = cndMQCompetrRecdTypId;
                            mQComptr.RE_Country_Name__c = 'CA';
                            mQComptr.RE_CND_Daily_Racks_Raw_Date__c = inputComprtr.RE_CND_Daily_Racks_Raw_Date__c;
                            mQComptr.RE_CND_Rack_Code__c = inputComprtr.RE_CND_City_Code__c;
                            mQComptr.RE_CND_Rack__c = rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase());
                            mQComptr.RE_CND_Supplier__c = inputComprtr.RE_CND_Supplier_Name__c;
                            mQComptr.RE_CND_Brand_Indicator__c = inputComprtr.RE_CND_Brand_Indicator__c;
                            mQComptr.RE_CND_Product_Group__c = productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase());
                            mQComptr.RE_Price__c = inputComprtr.RE_Price__c;
                            mQComptr.RE_CND_Move_Date__c = inputComprtr.RE_Pricing_Date__c;                           
                            defutCurrcy = (inputComprtr.RE_Default_Currency__c == null) ? 'CAD CTS' : inputComprtr.RE_Default_Currency__c;
                            unitMeasure = (inputComprtr.RE_Unit_of_Measure__c == null) ? 'LTR' : inputComprtr.RE_Unit_of_Measure__c;
                            mQComptr.RE_Rate_Unit__c =  defutCurrcy + '/' + unitMeasure;

                            competrMQ.add(mQComptr);
                            compRecords.put(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Price__c);
                                                      
                            if((inputComprtr.RE_CND_Supplier_Name__c.toLowercase() == supplier1Name) || (inputComprtr.RE_CND_Supplier_Name__c.toLowercase() == supplier2Name) || (inputComprtr.RE_CND_Supplier_Name__c.toLowercase() == supplier3Name) || (inputComprtr.RE_CND_Supplier_Name__c.toLowercase() == supplier4Name))
                            {
                                reqCompDate.put(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Pricing_Date__c);
                                reqCompPrice.put(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Price__c);
                                reqCompUnitRate.put(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Default_Currency__c.toLowercase() + '/' + inputComprtr.RE_Unit_of_Measure__c.toLowercase());
                                                      
                                moveDateMap.put(inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Pricing_Date__c);
                             }                            
                        }
                        else
                        {                            
                            if(compRecords.get(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c) > inputComprtr.RE_Price__c)
                            {                                
                                // Remove same record with higher price record from map
                                compRecords.remove(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c);
                                                                                       
                                RE_Market_Quotes__c mQComptr = New RE_Market_Quotes__c();
                                mQComptr.RecordTypeId = cndMQCompetrRecdTypId;
                                mQComptr.RE_Country_Name__c = 'CA';
                                mQComptr.RE_CND_Daily_Racks_Raw_Date__c = inputComprtr.RE_CND_Daily_Racks_Raw_Date__c;
                                mQComptr.RE_CND_Rack_Code__c = inputComprtr.RE_CND_City_Code__c;
                                mQComptr.RE_CND_Rack__c = rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase());
                                mQComptr.RE_CND_Supplier__c = inputComprtr.RE_CND_Supplier_Name__c;
                                mQComptr.RE_CND_Brand_Indicator__c = inputComprtr.RE_CND_Brand_Indicator__c;
                                mQComptr.RE_CND_Product_Group__c = productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase());
                                mQComptr.RE_Price__c = inputComprtr.RE_Price__c;
                                mQComptr.RE_CND_Move_Date__c = inputComprtr.RE_Pricing_Date__c;
                                mQComptr.RE_Rate_Unit__c = inputComprtr.RE_Default_Currency__c + '/' + inputComprtr.RE_Unit_of_Measure__c;

                                competrMQ.add(mQComptr);
                                compRecords.put(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Price__c);
                                                        
                                if((inputComprtr.RE_CND_Supplier_Name__c.toLowercase() == supplier1Name) || (inputComprtr.RE_CND_Supplier_Name__c.toLowercase() == supplier2Name) || (inputComprtr.RE_CND_Supplier_Name__c.toLowercase() == supplier3Name) || (inputComprtr.RE_CND_Supplier_Name__c.toLowercase() == supplier4Name))
                                {
                                    reqCompDate.put(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Pricing_Date__c);
                                    reqCompUnitRate.put(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Default_Currency__c.toLowercase() + '/' + inputComprtr.RE_Unit_of_Measure__c.toLowercase());
                                    
                                    // Remove same record with higher price record from map
                                    reqCompPrice.remove(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c);
                                    reqCompPrice.put(rackMapping.get(inputComprtr.RE_CND_City_Name__c.toLowercase())+productGroupMapping.get(inputComprtr.RE_CND_Product_Group__c.toLowercase())+inputComprtr.RE_CND_Supplier_Name__c.toLowercase()+inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Price__c);
                                                                
                                    moveDateMap.put(inputComprtr.RE_Pricing_Date__c,inputComprtr.RE_Pricing_Date__c);
                                } 
                            }                                
                        }
                        
                        // Change the processed status in RE_Pricing_Input_STG__c 
                        RE_Pricing_Input_STG__c pstg = New RE_Pricing_Input_STG__c();
                        pstg.Id = inputComprtr.Id;
                        pstg.RE_Is_Processed__c = TRUE;
                        pstgLst.add(pstg);
                    }
                }
                
                //Remove higher price for the same rack, group with same price date
                for(RE_Market_Quotes__c remvDuplc : competrMQ)
                {
                    if((compRecords.containsKey(remvDuplc.RE_CND_Rack__c+remvDuplc.RE_CND_Product_Group__c+remvDuplc.RE_CND_Supplier__c.toLowercase()+remvDuplc.RE_CND_Move_Date__c))
                       && ((compRecords.get(remvDuplc.RE_CND_Rack__c+remvDuplc.RE_CND_Product_Group__c+remvDuplc.RE_CND_Supplier__c.toLowercase()+remvDuplc.RE_CND_Move_Date__c)) == remvDuplc.RE_Price__c))
                    {
                        RE_Market_Quotes__c mQComptr = New RE_Market_Quotes__c();
                        mQComptr.RecordTypeId = cndMQCompetrRecdTypId;
                        mQComptr.RE_Country_Name__c = 'CA';
                        mQComptr.RE_CND_Daily_Racks_Raw_Date__c = remvDuplc.RE_CND_Daily_Racks_Raw_Date__c;
                        mQComptr.RE_CND_Rack_Code__c = remvDuplc.RE_CND_Rack_Code__c;
                        mQComptr.RE_CND_Rack__c = remvDuplc.RE_CND_Rack__c;
                        mQComptr.RE_CND_Supplier__c = remvDuplc.RE_CND_Supplier__c;
                        mQComptr.RE_CND_Brand_Indicator__c = remvDuplc.RE_CND_Brand_Indicator__c;
                        mQComptr.RE_CND_Product_Group__c = remvDuplc.RE_CND_Product_Group__c;
                        mQComptr.RE_Price__c = remvDuplc.RE_Price__c;                        
                        mQComptr.RE_CND_Move_Date__c = remvDuplc.RE_CND_Move_Date__c;
                        mQComptr.RE_Rate_Unit__c = remvDuplc.RE_Rate_Unit__c;
                       
                        competrMQFinalLst.add(mQComptr);                         
                    }
                }
                
                
                // Check and update Competitor data into Cost Price only for Unbranded records
                for(Date reqDt: moveDateMap.keyset())
                {            
                    system.debug('reqDt-->'+reqDt);
                    for(RE_MY_CostPrice__c costprce: [SELECT Id, RE_CND_Rack__c, RE_CND_Product_Group__c, RE_CND_Effective_From_Date__c, RE_CND_Effective_To_Date__c, 
                                                      RE_Fx_Rate__c, RE_Costprice_Unit__c, RE_Product_Name__r.RE_Product_Group__c,
                                                      RE_CND_Supplier1_Price__c, RE_CND_Supplier2_Price__c, RE_CND_Supplier3_Price__c, RE_CND_Supplier4_Price__c
                                                      FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                                      AND RE_CND_Effective_From_Date__c <=: reqDt AND RE_CND_Effective_To_Date__c >=: reqDt
                                                      AND RE_CND_Group__c =: 'Unbranded' AND RE_IsLatest__c =: TRUE AND RE_Status__c NOT IN ('Redundant')])
                    { 
                        supplier1Price = 0.00;
                        supplier2Price = 0.00;
                        supplier3Price = 0.00;
                        supplier4Price = 0.00;
                                        
                        if((reqCompDate.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt)) &&
                           (reqCompPrice.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt)))
                        {
                            if((reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt) == reqDt) &&
                               ((costprce.RE_CND_Supplier1_Price__c == null) || (costprce.RE_CND_Supplier1_Price__c == 0)))
                            {
                                supplier1Price = reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt);
                            }
                            else if((reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt) == reqDt) &&
                                    (reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt) == maxCostPriceDt) &&
                                    (reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt) < costprce.RE_CND_Supplier1_Price__c))
                            {
                                supplier1Price = reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt);   
                            }
                 
                        }
                       
                          
                        if((reqCompDate.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt)) &&
                           (reqCompPrice.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt)))
                        {
                            if((reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt) == reqDt) && 
                               ((costprce.RE_CND_Supplier2_Price__c == null) || (costprce.RE_CND_Supplier2_Price__c == 0)))
                            { 
                                 supplier2Price = reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt);
                            }
                            else if((reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt) == reqDt) && 
                                    (reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt) == maxCostPriceDt) &&
                                    (reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt) < costprce.RE_CND_Supplier2_Price__c))
                            {
                               supplier2Price = reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt);                           
                            }
                            
                        }
                       		
						
						if((reqCompDate.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt))
                           && (reqCompPrice.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt)))
                        {
                            
                            if((reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt) == reqDt) &&
                               ((costprce.RE_CND_Supplier3_Price__c == null) || (costprce.RE_CND_Supplier3_Price__c == 0)))
                            {
                                supplier3Price = reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt);
                            }	
                            else if((reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt) == reqDt) &&
							(reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt) == maxCostPriceDt)
                            && (reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt) < costprce.RE_CND_Supplier3_Price__c))
                            {
                             	supplier3Price = reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt);                            
                            }
                    
                        }
						
						                        
                        if((reqCompDate.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt)) && 
                           (reqCompPrice.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt)))
                        {
                            if((reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt) == reqDt) &&
                               ((costprce.RE_CND_Supplier4_Price__c == null) || (costprce.RE_CND_Supplier4_Price__c == 0)))
                            {
                                supplier4Price = reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt);
                            }
                            else if((reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt) == reqDt) && 
                                    (reqCompDate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt) == maxCostPriceDt) &&
                                    (reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt) < costprce.RE_CND_Supplier4_Price__c))
                            {
                                supplier4Price = reqCompPrice.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt);                            
                            }
                        }  
                       
                        
                        if(supplier1Price > 0 || supplier2Price > 0 || supplier3Price > 0 || supplier4Price > 0)
                        {
                            RE_unitConversion unitConv = New RE_unitConversion();
                            
                            // Check and convert unit rate for Supplier 1
                            if((reqCompUnitRate.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt))
                               && (reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt) != costprce.RE_Costprice_Unit__c))
                            {
								  fxRateMap.put(RE_unitConversion.unitBreakUp(costprce.RE_Costprice_Unit__c)[0]+'-'+RE_unitConversion.unitBreakUp(reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt))[0],costprce.RE_Fx_Rate__c);
                                  supplier1Price = supplier1Price *  unitConv.unitConversionMultiplier(reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier1Name+reqDt),costprce.RE_Costprice_Unit__c,'Canada',costprce.RE_Product_Name__r.RE_Product_Group__c,fxRateMap);
                            }
                            
                            // Check and convert unit rate for Supplier 2
                            if((reqCompUnitRate.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt))
                               && (reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt) != costprce.RE_Costprice_Unit__c))
                            {
								  fxRateMap.put(RE_unitConversion.unitBreakUp(costprce.RE_Costprice_Unit__c)[0]+'-'+RE_unitConversion.unitBreakUp(reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt))[0],costprce.RE_Fx_Rate__c);
                                  supplier2Price = supplier2Price *  unitConv.unitConversionMultiplier(reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier2Name+reqDt),costprce.RE_Costprice_Unit__c,'Canada',costprce.RE_Product_Name__r.RE_Product_Group__c,fxRateMap);
                            }
                            
                            // Check and convert unit rate for Supplier 3
                            if((reqCompUnitRate.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt))
                               && (reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt) != costprce.RE_Costprice_Unit__c))
                            {
                                fxRateMap.put(RE_unitConversion.unitBreakUp(costprce.RE_Costprice_Unit__c)[0]+'-'+RE_unitConversion.unitBreakUp(reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt))[0],costprce.RE_Fx_Rate__c);
                                  supplier3Price = supplier3Price *  unitConv.unitConversionMultiplier(reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier3Name+reqDt),costprce.RE_Costprice_Unit__c,'Canada',costprce.RE_Product_Name__r.RE_Product_Group__c,fxRateMap);
                            }
                            
                            // Check and convert unit rate for Supplier 4
                            if((reqCompUnitRate.containsKey(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt))
                               && (reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt) != costprce.RE_Costprice_Unit__c))
                            {
								  fxRateMap.put(RE_unitConversion.unitBreakUp(costprce.RE_Costprice_Unit__c)[0]+'-'+RE_unitConversion.unitBreakUp(reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt))[0],costprce.RE_Fx_Rate__c);
                                  supplier4Price = supplier4Price *  unitConv.unitConversionMultiplier(reqCompUnitRate.get(costprce.RE_CND_Rack__c+costprce.RE_CND_Product_Group__c+supplier4Name+reqDt),costprce.RE_Costprice_Unit__c,'Canada',costprce.RE_Product_Name__r.RE_Product_Group__c,fxRateMap);
                            }                            
                            
                            if(cpMap.size() >0)
                            {
                                if(cpMap.containsKey(costprce.Id))
                                {
                                    RE_MY_CostPrice__c cp = cpMap.get(costprce.Id);
                                    
                                   if(supplier1Price!=0)
                                   {
                                      if(supplier1Price < cp.RE_CND_Supplier1_Price__c )
                                      {
                                   		cp.RE_CND_Supplier1_Price__c = supplier1Price; 
                                          
                                      }
                                        if(cp.RE_CND_Supplier1_Price__c ==0 && supplier1Price!=0)
                                       {
                                          cp.RE_CND_Supplier1_Price__c = supplier1Price; 
                                       }
                                   }
                                    
                                                                   
                                    
                                    if(supplier2Price!=0)
                                   {
                                      if(supplier2Price < cp.RE_CND_Supplier2_Price__c )
                                      {
                                   		cp.RE_CND_Supplier2_Price__c = supplier2Price; 
                                      }
                                        if(cp.RE_CND_Supplier2_Price__c ==0 && supplier2Price!=0)
                                       {
                                          cp.RE_CND_Supplier2_Price__c = supplier2Price; 
                                       }
                                   }
                                    
                                    
                                    if(supplier3Price!=0)
                                   {
                                      if(supplier3Price < cp.RE_CND_Supplier3_Price__c )
                                      {
                                   		cp.RE_CND_Supplier3_Price__c = supplier3Price; 
                                      }
                                       
                                       if(cp.RE_CND_Supplier3_Price__c ==0 && supplier3Price!=0)
                                       {
                                          cp.RE_CND_Supplier3_Price__c = supplier3Price;
                                       }
                                   }
                                    
                                    if(supplier4Price!=0)
                                   {
                                      if(supplier4Price < cp.RE_CND_Supplier4_Price__c )
                                      {
                                   		cp.RE_CND_Supplier4_Price__c = supplier4Price;
                                      }
                                        if(cp.RE_CND_Supplier4_Price__c ==0 && supplier4Price!=0)
                                       {
                                          cp.RE_CND_Supplier4_Price__c = supplier4Price;
                                       }
                                   }
                                  
                                }
                                else
                                {
                                   RE_MY_CostPrice__c cp = New RE_MY_CostPrice__c();
                            		cp.Id = costprce.Id;
                           			 if(supplier1Price != 0)
                                	{
                                    cp.RE_CND_Supplier1_Price__c = supplier1Price;  
                                	}
                                    else
                                    cp.RE_CND_Supplier1_Price__c=costprce.RE_CND_Supplier1_Price__c;
                                    
                                 	if(supplier2Price != 0)
                                	{
                                  	cp.RE_CND_Supplier2_Price__c = supplier2Price;
                                	}
                                    else
                                    cp.RE_CND_Supplier2_Price__c=costprce.RE_CND_Supplier2_Price__c;
                                    
                                 	if(supplier3Price != 0)
                                	{
                                  	cp.RE_CND_Supplier3_Price__c = supplier3Price;
                                	}
                                    else
                                    cp.RE_CND_Supplier3_Price__c=costprce.RE_CND_Supplier3_Price__c;
                                    
                                 	if(supplier4Price != 0)
                                	{
                                   	cp.RE_CND_Supplier4_Price__c = supplier4Price;
                                	}
                               		else
                                    cp.RE_CND_Supplier4_Price__c=costprce.RE_CND_Supplier4_Price__c;
                               		cpMap.put(costprce.Id,cp) ; 
                                }
                            }    
                            else
                            {
                                RE_MY_CostPrice__c cp = New RE_MY_CostPrice__c();
                            	cp.Id = costprce.Id;
                                if(supplier1Price != 0)
                                {
                                    cp.RE_CND_Supplier1_Price__c = supplier1Price;  
                                }
                                else
                                    cp.RE_CND_Supplier1_Price__c=costprce.RE_CND_Supplier1_Price__c;
                                
                                 if(supplier2Price != 0)
                                {
                                  cp.RE_CND_Supplier2_Price__c = supplier2Price;
                                }
                                else
                                   cp.RE_CND_Supplier2_Price__c=costprce.RE_CND_Supplier2_Price__c;
                                
                                 if(supplier3Price != 0)
                                {
                                  cp.RE_CND_Supplier3_Price__c = supplier3Price;
                                }
                                else
                                    cp.RE_CND_Supplier3_Price__c=costprce.RE_CND_Supplier3_Price__c;
                                
                                 if(supplier4Price != 0)
                                {
                                   cp.RE_CND_Supplier4_Price__c = supplier4Price;
                                }
                                else
                                    cp.RE_CND_Supplier4_Price__c=costprce.RE_CND_Supplier4_Price__c;
                               	cpMap.put(costprce.Id,cp) ;
                            }
                           
                           // competrCP.add(cp);
                        }          
                    }
                }
                
                // Insert Competitor data into Market Quotes  
                if(competrMQFinalLst.size() > 0)
                {
                    Database.SaveResult[] mqList = Database.insert(competrMQFinalLst, false);
                    for (Database.SaveResult mq : mqList) {                                  
                        if(!mq.isSuccess()) 
                            // Operation failed, so get all errors 
                            for(Database.Error err : mq.getErrors()) {
                                RV_Exception__c rvExcep = new RV_Exception__c();
                                rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                                rvExcep.getMessage__c = jrAudit.Id+':'+err.getMessage();
                                rvExcep.Apex_Class__c = 'RE_CND_PricingInputStaging';
                                rvExcep.getFields__c = JSON.serialize(err.getFields());
                                rvExcep.Method_Name__c = 'processCompetitorData';
                                rvExcep.Type__c = 'Exception';
                                excpList.add(rvExcep);
                            }                        
                    }                    
                }           

                // update Competitor price into Cost Price
                if(cpMap.Size() > 0)
                {
                    // Remove duplicate records
                    /*Set<RE_MY_CostPrice__c> myUniqueset = new Set<RE_MY_CostPrice__c>();
                    List<RE_MY_CostPrice__c> uniqueResult = new List<RE_MY_CostPrice__c>();
                    myUniqueset.addAll(competrCP);
                    uniqueResult.addAll(myUniqueset);*/
                    
                   List<RE_MY_CostPrice__c> uniqueResult  = cpMap.values();
                    
                    Database.SaveResult[] updateCompetrCP = Database.update(uniqueResult, false);
                    Boolean updateCompetrCPSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_PricingInputStaging','processCompetitorData-UpdateCostpricng',updateCompetrCP,false, jrAudit);                                                                                                   
                }                   
                
                // Mark RE_Pricing_Input_STG__c has processed
                if(pstgLst.Size() > 0)
                {
                    Database.SaveResult[] updatePstgLst = Database.update(pstgLst, false);
                    Boolean updatePrncStgSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_PricingInputStaging','processCompetitorData-UpdatePrcngStg',updatePstgLst,false, jrAudit);                                                                                                                       
                }
                
                if(excpList.size()>0){                
                    RV_ClassException.insertExceptionRecord(excpList); 
                    String otherComment='Refer RV_Exception__c record for more details with jobAudit :'+jrAudit.Id;
                    RE_CND_Utility.updateJobAuditPartialSuccess(jrAudit,'DML Exception while processing the Competitor Data',otherComment);                
                }
                else if (jrAudit.RE_Job_Status__c == 'Processing')
                {
                    jrAudit.RE_Job_Status__c = 'Completed';               
                    update jrAudit;
                }  
            }      
        }
        Catch(Exception ex)
        {     
            System.debug('processCompetitorData-->'+ex.getMessage());
            System.debug('processCompetitorData-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('processCompetitorData',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_PricingInputStaging','processCompetitorData','Exception');            
            RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex);
        }         
    }
    
    // Processing the Live OPIS Spot Ticker imported records into RE_Market_Quotes__c Object   
    public static void processingLiveOPISSpotTicker(List<RE_Pricing_Input_STG__c> inputList)
    {     
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        
        try
        {
            RE_JobControls__c jb;
            
            //RE_JobControls__c checks active methods
            jb = [SELECT Active__c FROM RE_JobControls__c WHERE Class_Name__c =: 'RE_CND_PricingInputStaging' AND Method_Name__c =: 'processingLiveOPISSpotTicker' AND Country__c =:'Canada'];
            if(jb.Active__c)
            {              
                List<RE_Market_Quotes__c> mqLst = New List<RE_Market_Quotes__c>();
                List<RE_Pricing_Input_STG__c> pstgLst = New List<RE_Pricing_Input_STG__c>();
                List<RV_Exception__c> excpList = new List<RV_Exception__c>();
                String[] validtyMonthLst;
                Map<String,String> monthName = New Map<String,String>();
                
                Id opisSptTickrMQRecordTypeId = Schema.SObjectType.RE_Market_Quotes__c.getRecordTypeInfosByDeveloperName().get('Canada_OPIS_Spot_Ticker').getRecordTypeId();
          
                jrAudit.RE_Run_Time__c = system.now();
                jrAudit.RE_Run_Type__c = 'Manual';
                jrAudit.RE_Job_Type__c = 'Canada Live OPIS Spot Ticker Processing';
                jrAudit.RE_User__c = UserInfo.getUserId();
                jrAudit.RE_Job_Run_Count__c = 1;
                jrAudit.RE_Job_Status__c = 'Processing';
                jrAudit.RE_Country_Name__c='CA';
                insert jrAudit;               
          
                monthName.put('jan','Jan');
                monthName.put('feb','Feb');
                monthName.put('mar','Mar');
                monthName.put('apr','Apr');
                monthName.put('may','May');
                monthName.put('jun','Jun');
                monthName.put('jul','Jul');
                monthName.put('aug','Aug');
                monthName.put('sep','Sep');
                monthName.put('oct','Oct');
                monthName.put('nov','Nov');
                monthName.put('dec','Dec');
                    
                // Get any Live OPIS Spot Ticker records to be processed
                for(RE_Pricing_Input_STG__c pricngStg: inputList)
                {                
                    // Prepare RE_Market_Quotes__c records against each RE_Pricing_Input_STG__c
                    RE_Market_Quotes__c mq = New RE_Market_Quotes__c();
                    mq.RecordTypeId = opisSptTickrMQRecordTypeId;
                    mq.RE_Country_Name__c = 'CA';
                    mq.RE_Quote_Name__c = pricngStg.RE_CND_Quote_Name__c;                        
                    mq.RE_Price__c = pricngStg.RE_Price__c;
                    mq.RE_CND_Validity_Date__c = pricngStg.RE_Pricing_Date__c;
                 
                    if(!String.isBlank(pricngStg.RE_Validity_Month__c))
                    {                    
                        validtyMonthLst = pricngStg.RE_Validity_Month__c.trim().split('\\-');
                        
                        if(validtyMonthLst[0] != pricngStg.RE_Validity_Month__c.trim() && validtyMonthLst[0].IsNumeric() 
                           && monthName.containsKey(validtyMonthLst[1].toLowerCase().trim()))
                        		mq.RE_Validity_Month__c =	monthName.get(validtyMonthLst[1].toLowerCase().trim()) + '-' + validtyMonthLst[0];
                        else if(validtyMonthLst[0] != pricngStg.RE_Validity_Month__c.trim() && validtyMonthLst[1].IsNumeric() 
                           && monthName.containsKey(validtyMonthLst[0].toLowerCase().trim()))
                                mq.RE_Validity_Month__c =	monthName.get(validtyMonthLst[0].toLowerCase().trim()) + '-' + validtyMonthLst[1];
                        else
                            mq.RE_Validity_Month__c = null;
                    }
                    else
                        mq.RE_Validity_Month__c = pricngStg.RE_Validity_Month__c;

                    mq.RE_Rate_Unit__c = pricngStg.RE_Default_Currency__c + '/' + pricngStg.RE_Unit_of_Measure__c;
                    mq.RE_Default_Per_Unit__c = pricngStg.RE_Default_Per_Unit__c;
                    mq.RE_Quote_Type__c = pricngStg.RE_Quote_Type__c;
                    mq.RE_Quote_Source__c = pricngStg.RE_Quote_Source__c;
                    mq.RE_Is_Processed__c = FALSE;                   
                    mqLst.add(mq);
                    
                    // Change the processed status in RE_Pricing_Input_STG__c 
                    RE_Pricing_Input_STG__c pstg = New RE_Pricing_Input_STG__c();
                    pstg.Id = pricngStg.Id;
                    pstg.RE_Is_Processed__c = TRUE;
                    pstgLst.add(pstg);
                }
                                
                if(mqLst.Size() > 0)
                {
                    Database.SaveResult[] cpList = Database.insert(mqLst, false);
                    for (Database.SaveResult cp : cpList) {
                        if (!cp.isSuccess()) 
                        {
                            // Operation failed, so get all errors 
                            for(Database.Error err : cp.getErrors()) {
                                RV_Exception__c rvExcep = new RV_Exception__c();
                                rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                                rvExcep.getMessage__c = jrAudit.Id+':'+err.getMessage();
                                rvExcep.Apex_Class__c = 'RE_CND_PricingInputStaging';
                                rvExcep.getFields__c = JSON.serialize(err.getFields());
                                rvExcep.Method_Name__c = 'processingLiveOPISSpotTicker';
                                rvExcep.Type__c = 'Exception';
                                excpList.add(rvExcep);
                            }                        
                        }                    
                    }
                    
                    // Mark RE_Pricing_Input_STG__c has processed
                    if(pstgLst.Size() > 0)
                    {
                       Database.SaveResult[] updatePstgLst = Database.update(pstgLst, false);
                       Boolean updatePrncStgSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_PricingInputStaging','processingLiveOPISSpotTicker-UpdatePrcngStg',updatePstgLst,false, jrAudit);                                                                                                                                               
                    }
                    
                    if(excpList.size()>0){                
                        RV_ClassException.insertExceptionRecord(excpList); 
                        String otherComment='Refer RV_Exception__c record for more details with jobAudit :'+jrAudit.Id;
                        RE_CND_Utility.updateJobAuditPartialSuccess(jrAudit,'DML Exception while processing the Live OPIS Spot Ticker',otherComment);                
                    }
                    else if (jrAudit.RE_Job_Status__c == 'Processing')
                    {
                        jrAudit.RE_Job_Status__c = 'Completed';               
                        update jrAudit;
                    }                       
                }        			         
            }
        }
        Catch(Exception ex)
        {          
            System.debug('processingLiveOPISSpotTicker-->'+ex.getMessage());
            System.debug('processingLiveOPISSpotTicker-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('processingLiveOPISSpotTicker',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_PricingInputStaging','processingLiveOPISSpotTicker','Exception');            
            RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex);
        }        
    }    
    
}