public class RE_OutputDataFormation {
    Map<String, List<String>> locationproductMap = new Map<String, List<String>>();
    List<String> productList;
    List<sObject> outputList = new List<sObject>();
    Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('RE_MY_Output__c'.toLowerCase()).getDescribe().Fields.getMap();
    Map<String, Double> oldMarginalCostValueMap = new Map<String, Double>();
    Map<String, Double> oldLaidDownlCostValueMap = new Map<String, Double>();
    
    public RE_OutputDataFormation(String jobTyp){        
        if(jobTyp == 'Malaysia Output'){   
			Datetime lastdate;
			Decimal lastrun;		
            Map<Date, Decimal> jrmap = new Map<Date, Decimal>();			
			for(RE_Job_Run_Audit__c jradit : [
					SELECT RE_Run_Time__c, RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
					WHERE RE_Run_Time__c != Today
					AND RE_IsSuccess__c = True
					AND RE_Job_Type__c = 'Malaysia Output'
					AND CREATEDDATE = Last_N_Days : 15
					ORDER BY RE_Run_Time__c desc
				]){
				if(jrmap.isEmpty() || (jrmap.containsKey(jradit.RE_Run_Time__c.Date()) && jrmap.get(jradit.RE_Run_Time__c.Date()) < jradit.RE_Job_Run_Count__c)){   
					jrmap.put(jradit.RE_Run_Time__c.Date(), jradit.RE_Job_Run_Count__c);
					lastrun = jradit.RE_Job_Run_Count__c;
					lastdate = jradit.RE_Run_Time__c.Date();
				}            
			}
			System.debug('jrmap '+ jrmap);			
			for(RE_MY_CostPrice__c oldCostData : [
				SELECT RE_Pricing_Date__c,RE_Depot_Name__c,RE_Product_Name__c, RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c, 
				RE_Depot_Name__r.Name,RE_Product_Name__r.Name
				FROM RE_MY_CostPrice__c 
				WHERE RE_Pricing_Date__c =: lastdate
				AND RE_Job_Run_Count__c =: lastrun AND Recordtype.Name='Malaysia'
			]){
				oldMarginalCostValueMap.put(oldCostData.RE_Depot_Name__c+'-'+oldCostData.RE_Product_Name__c,oldCostData.RE_Costprice_Marginal_Cost__c);
				oldLaidDownlCostValueMap.put(oldCostData.RE_Depot_Name__c+'-'+oldCostData.RE_Product_Name__c,oldCostData.RE_Costprice_Laid_Down_Cost__c);
			}
            outputdatafill(jobTyp);
        }
		else if(jobTyp == 'Singapore Output'){
            Map<Date, Decimal> jrmapSG = new Map<Date, Decimal>();
			Datetime lastdateSG;
			Decimal lastrunSG;
			for(RE_Job_Run_Audit__c jradit : [
					SELECT RE_Run_Time__c, RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
					WHERE RE_Run_Time__c != Today
					AND RE_IsSuccess__c = True
					AND RE_Job_Type__c = 'Singapore Output'
					AND CREATEDDATE = Last_N_Days : 15
					ORDER BY RE_Run_Time__c desc
				]){
				if(jrmapSG.isEmpty() || (jrmapSG.containsKey(jradit.RE_Run_Time__c.Date()) && jrmapSG.get(jradit.RE_Run_Time__c.Date()) < jradit.RE_Job_Run_Count__c)){   
					jrmapSG.put(jradit.RE_Run_Time__c.Date(), jradit.RE_Job_Run_Count__c);
					lastrunSG = jradit.RE_Job_Run_Count__c;
					lastdateSG = jradit.RE_Run_Time__c.Date();
				}            
			}
			System.debug('jrmapSG '+ jrmapSG);
			
			for(RE_SG_CostPrice__c oldCostData : [
				SELECT RE_Pricing_Date__c,RE_Location_Name__c,RE_Product_Name__c, RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c, 
				RE_Location_Name__r.Name,RE_Product_Name__r.Name,RE_FX_Marginal_Cost__c,RE_FX_Laid_Down_Cost__c
				FROM RE_SG_CostPrice__c 
				WHERE RE_Pricing_Date__c =: lastdateSG
				AND RE_Job_Run_Count__c =: lastrunSG
                AND RE_IsMidday__c = False
			]){
				oldMarginalCostValueMap.put(oldCostData.RE_Location_Name__c+'-'+oldCostData.RE_Product_Name__c,oldCostData.RE_FX_Marginal_Cost__c);
				oldLaidDownlCostValueMap.put(oldCostData.RE_Location_Name__c+'-'+oldCostData.RE_Product_Name__c,oldCostData.RE_FX_Laid_Down_Cost__c);
			}
			outputsgddatafill(jobTyp);
	    }
        
        else if(jobTyp == 'SG Midday Output'){
            Map<Date, Decimal> jrmapSG = new Map<Date, Decimal>();
			Datetime lastdateSG;
			Decimal lastrunSG;
			for(RE_Job_Run_Audit__c jradit : [
					SELECT RE_Run_Time__c, RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
					WHERE RE_Run_Time__c != Today
					AND RE_IsSuccess__c = True
					AND RE_Job_Type__c = 'SG Midday Output'
					AND CREATEDDATE = Last_N_Days : 15
					ORDER BY RE_Run_Time__c desc
				]){
				if(jrmapSG.isEmpty() || (jrmapSG.containsKey(jradit.RE_Run_Time__c.Date()) && jrmapSG.get(jradit.RE_Run_Time__c.Date()) < jradit.RE_Job_Run_Count__c)){   
					jrmapSG.put(jradit.RE_Run_Time__c.Date(), jradit.RE_Job_Run_Count__c);
					lastrunSG = jradit.RE_Job_Run_Count__c;
					lastdateSG = jradit.RE_Run_Time__c.Date();
				}            
			}
			System.debug('jrmapSG '+ jrmapSG);
			
			for(RE_SG_CostPrice__c oldCostData : [
				SELECT RE_Pricing_Date__c,RE_Location_Name__c,RE_Product_Name__c, RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c, 
				RE_Location_Name__r.Name,RE_Product_Name__r.Name,RE_FX_Marginal_Cost__c,RE_FX_Laid_Down_Cost__c
				FROM RE_SG_CostPrice__c 
				WHERE RE_Pricing_Date__c =: lastdateSG
				AND RE_Job_Run_Count__c =: lastrunSG
                AND RE_IsMidday__c = True
			]){
				oldMarginalCostValueMap.put(oldCostData.RE_Location_Name__c+'-'+oldCostData.RE_Product_Name__c,oldCostData.RE_FX_Marginal_Cost__c);
				oldLaidDownlCostValueMap.put(oldCostData.RE_Location_Name__c+'-'+oldCostData.RE_Product_Name__c,oldCostData.RE_FX_Laid_Down_Cost__c);
			}
			outputsgddatafill(jobTyp);
	    }
		else if(jobTyp == 'Thailand Output'){   
			Datetime lastdate;
			Decimal lastrun;		
            Map<Date, Decimal> jrmap = new Map<Date, Decimal>();			
			for(RE_Job_Run_Audit__c jradit : [
					SELECT RE_Run_Time__c, RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
					WHERE RE_Run_Time__c != Today
					AND RE_IsSuccess__c = True
					AND RE_Job_Type__c = 'Thailand Output'
					AND CREATEDDATE = Last_N_Days : 15
					ORDER BY RE_Run_Time__c desc
				]){
				if(jrmap.isEmpty() || (jrmap.containsKey(jradit.RE_Run_Time__c.Date()) && jrmap.get(jradit.RE_Run_Time__c.Date()) < jradit.RE_Job_Run_Count__c)){   
					jrmap.put(jradit.RE_Run_Time__c.Date(), jradit.RE_Job_Run_Count__c);
					lastrun = jradit.RE_Job_Run_Count__c;
					lastdate = jradit.RE_Run_Time__c.Date();
				}            
			}
			System.debug('jrmap '+ jrmap);	
            System.debug('lastdate   '+lastdate+'    lastrun    '+lastrun);
			for(RE_MY_CostPrice__c oldCostData : [
				SELECT RE_Pricing_Date__c,RE_Depot_Name__c,RE_Product_Name__c, RE_Costprice_Laid_Down_Cost__c, 
				RE_Depot_Name__r.Name,RE_Product_Name__r.Name
				FROM RE_MY_CostPrice__c 
				WHERE RE_Pricing_Date__c =: lastdate
				AND RE_Job_Run_Count__c =: lastrun AND Recordtype.Name='Thailand'
			]){
				//oldMarginalCostValueMap.put(oldCostData.RE_Depot_Name__c+'-'+oldCostData.RE_Product_Name__c,oldCostData.RE_Costprice_Marginal_Cost__c);
				oldLaidDownlCostValueMap.put(oldCostData.RE_Depot_Name__c+'-'+oldCostData.RE_Product_Name__c,oldCostData.RE_Costprice_Laid_Down_Cost__c);
			}
            outputThailanddatafill(jobTyp);
        }
        System.debug('oldLaidDownlCostValueMap    '+oldLaidDownlCostValueMap);
	}
    
    public void outputdatafill(String jobTyp){
        Integer jobCount = 0;
        Integer maxRunCount = 0;
        List<RE_MY_Output__c> updatelatestdata = new List<RE_MY_Output__c>();
        List<RE_MY_Output__c> LatestDataToday = [SELECT RE_IsLatest__c FROM RE_MY_Output__c WHERE RE_IsLatest__c = True AND RE_Type__c =:jobTyp];
        if(!LatestDataToday.isEmpty()){
            for(RE_MY_Output__c outputdata : LatestDataToday){
                outputdata.RE_IsLatest__c = False;
                updatelatestdata.add(outputdata);
            }                
        }
        List<RE_MY_Output__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_MY_Output__c 
                                               WHERE RE_Pricing_Date__c = Today AND RE_Type__c =:jobTyp ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        Id rectypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        List<RE_MY_CostPrice__c> costingDataToday = [SELECT RE_Job_Run_Count__c FROM RE_MY_CostPrice__c 
                                                     WHERE recordtypeId = : rectypeId AND RE_Pricing_Date__c = Today ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        if(!costingDataToday.isEmpty())
            maxRunCount = Integer.valueOf(costingDataToday[0].RE_Job_Run_Count__c);
        if(!costDataToday.isEmpty())
            jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c) + 1;
        List<RE_MY_CostPrice__c> costingList = [
            SELECT RE_Pricing_Date__c,RE_Depot_Name__c,RE_Product_Name__c,RE_Depot_Name__r.Name,RE_Depot_Name__r.RE_Region_Name__c,
            RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c,RE_Product_Name__r.Name,RE_Country__r.Name
            FROM RE_MY_CostPrice__c 
            WHERE RE_Pricing_Date__c = Today            
            AND RE_Job_Run_Count__c =:maxRunCount  AND Recordtype.Name='Malaysia'
        ];
        for(RE_MY_CostPrice__c costdata : costingList){
            if(!locationproductMap.containsKey(costdata.RE_Depot_Name__c)){
                productList = new List<String>(); 
                productList.add(costdata.RE_Product_Name__c);
                locationproductMap.put(costdata.RE_Depot_Name__c, productList);				               
            }
            else{
                locationproductMap.get(costdata.RE_Depot_Name__c).add(costdata.RE_Product_Name__c);
            }            
        }
        for(String locationdata : locationproductMap.keySet()){
            RE_MY_Output__c opt = new RE_MY_Output__c();     
            for(String prodData : locationproductMap.get(locationdata)){
                for(RE_MY_CostPrice__c costdata : costingList){	
                    if(locationdata == costdata.RE_Depot_Name__c && prodData == costdata.RE_Product_Name__c){
                        String keyData = costdata.RE_Depot_Name__c+'-'+costdata.RE_Product_Name__c;
                        for (Schema.SObjectField ft : fMap.values()){                       
                            Schema.DescribeFieldResult fd = ft.getDescribe();
                            opt.RE_Type__c = jobTyp;
                            if(fd.getLabel().contains('Job Run Count'))
                                opt.put(ft,jobCount);	
                            if(fd.getLabel().contains('IsLatest'))
                                opt.put(ft,True);
                            if(fd.getLabel().contains('Pricing Date'))
                                opt.put(ft,System.Today());							
                            if(fd.getLabel().contains('Country'))
                                opt.put(ft,costdata.RE_Country__r.Name);
                            if(fd.getLabel().contains('Depot Name'))
                                opt.put(ft,costdata.RE_Depot_Name__r.Name);
                            if(fd.getLabel().contains('Region'))
                                opt.put(ft,costdata.RE_Depot_Name__r.RE_Region_Name__c);
                            if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('MC'))
                                opt.put(ft,costdata.RE_Costprice_Marginal_Cost__c);			
                            if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('LDC'))
                                opt.put(ft,costdata.RE_Costprice_Laid_Down_Cost__c);
                            
                            if(oldMarginalCostValueMap.containsKey(keyData)){                                
                                if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('MC') && fd.getLabel().contains('Diff'))
                                    opt.put(ft,costdata.RE_Costprice_Marginal_Cost__c - oldMarginalCostValueMap.get(keyData));
                            } 
                            else{
                                if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('MC') && fd.getLabel().contains('Diff'))
                                    opt.put(ft,0);
                            }
                            if(oldLaidDownlCostValueMap.containsKey(keyData)){
                                if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('LDC') && fd.getLabel().contains('Diff'))
                                    opt.put(ft,costdata.RE_Costprice_Laid_Down_Cost__c - oldLaidDownlCostValueMap.get(keyData)); 
                            }
                            else{
                                if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('LDC') && fd.getLabel().contains('Diff'))
                                    opt.put(ft,0); 
                            }
                        }
                        
                    }	
                }         		
            }
            System.debug('opt'+opt);
            outputList.add(opt); 
        }
        update updatelatestdata;
        insert outputList;    
    } 
    public void outputsgddatafill(String jobTyp){
        Integer jobCount = 0;
        Integer maxRunCount = 0;
        List<RE_MY_Output__c> updatelatestdata = new List<RE_MY_Output__c>();
        List<RE_SG_CostPrice__c> costingDataToday = new List<RE_SG_CostPrice__c>();
        List<RE_SG_CostPrice__c> costingList = new List<RE_SG_CostPrice__c>();
        List<RE_MY_Output__c> LatestDataToday = [SELECT RE_IsLatest__c FROM RE_MY_Output__c WHERE RE_IsLatest__c = True AND RE_Type__c =:jobTyp];
        if(!LatestDataToday.isEmpty()){
            for(RE_MY_Output__c outputdata : LatestDataToday){
                outputdata.RE_IsLatest__c = False;
                updatelatestdata.add(outputdata);
            }                
        }
        List<RE_MY_Output__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_MY_Output__c 
                                               WHERE RE_Pricing_Date__c = Today AND RE_Type__c =:jobTyp ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        if(jobTyp == 'Singapore Output')
        	costingDataToday = [SELECT RE_Job_Run_Count__c FROM RE_SG_CostPrice__c 
                                                     WHERE RE_Pricing_Date__c = Today AND RE_IsMidday__c = False ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        else if(jobTyp == 'SG Midday Output')
            costingDataToday = [SELECT RE_Job_Run_Count__c FROM RE_SG_CostPrice__c 
                                                     WHERE RE_Pricing_Date__c = Today AND RE_IsMidday__c = True ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        
        if(!costingDataToday.isEmpty())
            maxRunCount = Integer.valueOf(costingDataToday[0].RE_Job_Run_Count__c);
        if(!costDataToday.isEmpty())
            jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c) + 1;
        if(jobTyp == 'Singapore Output')
        	costingList = [
                SELECT RE_Pricing_Date__c,RE_Location_Name__c,RE_Product_Name__c,RE_Location_Name__r.Name,RE_Location_Name__r.RE_Region_Name__c,
                RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c,RE_Product_Name__r.Name,RE_FX_Laid_Down_Cost__c,RE_FX_Marginal_Cost__c
                FROM RE_SG_CostPrice__c 
                WHERE RE_Pricing_Date__c = Today            
                AND RE_Job_Run_Count__c =:maxRunCount
                AND RE_IsMidday__c = False
            ];
        else if(jobTyp == 'SG Midday Output')
            costingList = [
                SELECT RE_Pricing_Date__c,RE_Location_Name__c,RE_Product_Name__c,RE_Location_Name__r.Name,RE_Location_Name__r.RE_Region_Name__c,
                RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c,RE_Product_Name__r.Name,RE_FX_Laid_Down_Cost__c,RE_FX_Marginal_Cost__c
                FROM RE_SG_CostPrice__c 
                WHERE RE_Pricing_Date__c = Today            
                AND RE_Job_Run_Count__c =:maxRunCount
                AND RE_IsMidday__c = True
            ];
        for(RE_SG_CostPrice__c costdata : costingList){
            if(!locationproductMap.containsKey(costdata.RE_Location_Name__c)){
                productList = new List<String>(); 
                productList.add(costdata.RE_Product_Name__c);
                locationproductMap.put(costdata.RE_Location_Name__c, productList);				               
            }
            else{
                locationproductMap.get(costdata.RE_Location_Name__c).add(costdata.RE_Product_Name__c);
            }            
        }
        for(String locationdata : locationproductMap.keySet()){
            RE_MY_Output__c opt = new RE_MY_Output__c();     
            for(String prodData : locationproductMap.get(locationdata)){
                for(RE_SG_CostPrice__c costdata : costingList){	
                    if(locationdata == costdata.RE_Location_Name__c && prodData == costdata.RE_Product_Name__c){
                        String keyData = costdata.RE_Location_Name__c+'-'+costdata.RE_Product_Name__c;
                        for (Schema.SObjectField ft : fMap.values()){ 
                            Schema.DescribeFieldResult fd = ft.getDescribe();
                            opt.RE_Type__c = jobTyp;
                            if(fd.getLabel().contains('Job Run Count'))
                                opt.put(ft,jobCount);	
                            if(fd.getLabel().contains('IsLatest'))
                                opt.put(ft,True);
                            if(fd.getLabel().contains('Pricing Date'))
                                opt.put(ft,System.Today());							
                            if(fd.getLabel().contains('Country'))
                                opt.put(ft,'Singapore');                                    
                            if(fd.getLabel().contains('Depot Name'))
                                opt.put(ft,costdata.RE_Location_Name__r.Name);
                            if(fd.getLabel().contains('Region'))
                                opt.put(ft,costdata.RE_Location_Name__r.RE_Region_Name__c);
                            if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('MC'))
                                opt.put(ft,costdata.RE_FX_Marginal_Cost__c);			
                            if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('LDC'))
                                opt.put(ft,costdata.RE_FX_Laid_Down_Cost__c);                            
                            if(oldMarginalCostValueMap.containsKey(keyData)){                                
                                if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('MC') && fd.getLabel().contains('Diff'))
                                    opt.put(ft,costdata.RE_FX_Marginal_Cost__c - oldMarginalCostValueMap.get(keyData));
                            } 
                            else{
                                if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('MC') && fd.getLabel().contains('Diff'))
                                    opt.put(ft,0);
                            }
                            if(oldLaidDownlCostValueMap.containsKey(keyData)){
                                if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('LDC') && fd.getLabel().contains('Diff'))
                                    opt.put(ft,costdata.RE_FX_Laid_Down_Cost__c - oldLaidDownlCostValueMap.get(keyData)); 
                            }
                            else{
                                if(fd.getLabel().contains(costdata.RE_Product_Name__r.Name) && fd.getLabel().contains('LDC') && fd.getLabel().contains('Diff'))
                                    opt.put(ft,0); 
                            }
                        }                        
                    }	
                }         		
            }
            outputList.add(opt); 
        }
        update updatelatestdata;
        System.debug('outputList '+outputList);
        insert outputList;    
    }    
	
	public void outputThailanddatafill(String jobTyp){
        Integer jobCount = 0;
        Integer maxRunCount = 0;
		List<RE_MY_Output__c> updatelatestdata = new List<RE_MY_Output__c>();
		List<RE_MY_Output__c> LatestDataToday = [SELECT RE_IsLatest__c FROM RE_MY_Output__c WHERE RE_IsLatest__c = True AND RE_Type__c =:jobTyp];
        if(!LatestDataToday.isEmpty()){
            for(RE_MY_Output__c outputdata : LatestDataToday){
                outputdata.RE_IsLatest__c = False;
                updatelatestdata.add(outputdata);
            }                
        }
        List<RE_MY_Output__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_MY_Output__c 
                                               WHERE RE_Pricing_Date__c = Today AND RE_Type__c =:jobTyp ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        Id rectypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
        List<RE_MY_CostPrice__c> costingDataToday = [SELECT RE_Job_Run_Count__c FROM RE_MY_CostPrice__c 
                                                     WHERE recordtypeId = : rectypeId AND RE_Pricing_Date__c = Today ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        if(!costingDataToday.isEmpty())
            maxRunCount = Integer.valueOf(costingDataToday[0].RE_Job_Run_Count__c);
        if(!costDataToday.isEmpty())
            jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c) + 1;
        List<RE_MY_CostPrice__c> costingList = [
            SELECT RE_Pricing_Date__c,RE_Depot_Name__c,RE_Product_Name__c,RE_Product_Subgroup__c,RE_Depot_Name__r.Name,RE_Depot_Name__r.RE_Region_Name__c,
            RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c,RE_Product_Name__r.Name,RE_Country__r.Name
            FROM RE_MY_CostPrice__c 
            WHERE RE_Pricing_Date__c = Today            
            AND RE_Job_Run_Count__c =:maxRunCount AND Recordtype.Name='Thailand'
        ];
		for(RE_MY_CostPrice__c costdata : costingList){
            if(!locationproductMap.containsKey(costdata.RE_Depot_Name__c)){
                productList = new List<String>(); 
                productList.add(costdata.RE_Product_Subgroup__c);
                locationproductMap.put(costdata.RE_Depot_Name__c, productList);				               
            }
            else{
                locationproductMap.get(costdata.RE_Depot_Name__c).add(costdata.RE_Product_Subgroup__c);
            }            
        }
		for(String locationdata : locationproductMap.keySet()){
            RE_MY_Output__c opt = new RE_MY_Output__c();     
            for(String prodData : locationproductMap.get(locationdata)){
                for(RE_MY_CostPrice__c costdata : costingList){	
                    if(locationdata == costdata.RE_Depot_Name__c && prodData == costdata.RE_Product_Subgroup__c){
                        String keyData = costdata.RE_Depot_Name__c+'-'+costdata.RE_Product_Name__c;
                        for (Schema.SObjectField ft : fMap.values()){                       
                            Schema.DescribeFieldResult fd = ft.getDescribe();
                            opt.RE_Type__c = jobTyp;
                            opt.recordtypeId=Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;//'0120C00000077tO';
                            if(fd.getLabel().contains('Job Run Count'))
                                opt.put(ft,jobCount);	
                            if(fd.getLabel().contains('IsLatest'))
                                opt.put(ft,True);
                            if(fd.getLabel().contains('Pricing Date'))
                                opt.put(ft,System.Today());							
                            if(fd.getLabel().contains('Country'))
                                opt.put(ft,costdata.RE_Country__r.Name);
                            if(fd.getLabel().contains('Depot Name'))
                                opt.put(ft,costdata.RE_Depot_Name__r.Name);
                            if(fd.getLabel().contains('Region'))
                                opt.put(ft,costdata.RE_Depot_Name__r.RE_Region_Name__c);
                            String labelVals = fd.getLabel().replace(' LDC','');
                            labelVals	=	labelVals.replace(' DIFF','');
                            labelVals	=	labelVals.replace(' Diff','');
                            if(labelVals.equals(costdata.RE_Product_Subgroup__c) && fd.getLabel().contains('LDC'))
                                opt.put(ft,costdata.RE_Costprice_Laid_Down_Cost__c);
                            if(oldLaidDownlCostValueMap.containsKey(keyData)){
                                if(labelVals.equals(costdata.RE_Product_Subgroup__c) && (!fd.getLabel().contains('LDC') || fd.getLabel()=='Kerosene LDC Diff') && (fd.getLabel().contains('DIFF') || fd.getLabel().contains('Diff'))){
                                    
                                    
                                    opt.put(ft,costdata.RE_Costprice_Laid_Down_Cost__c - oldLaidDownlCostValueMap.get(keyData)); 
                                }
                            }
                            else{
                                if(labelVals.equals(costdata.RE_Product_Subgroup__c) && !fd.getLabel().contains('LDC') && fd.getLabel().contains('DIFF'))
                                    opt.put(ft,0); 

                            }
                        }
                        
                    }	
                }         		
            }
            outputList.add(opt); 
        }
        update updatelatestdata;
        insert outputList;    
		
	}
    
}