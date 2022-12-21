public class RE_PH_AspriedUC3 {
    
    Public Static Map<String , Double > exciseTax = New Map<String , Double>();
    Public Static Map<String,RE_PH_OutputController.costDataWrapper> costdatalistvalues = new Map<String,RE_PH_OutputController.costDataWrapper>();
    Public Static Map<String , Map< String , RT_Setting__c >> approvalscheme = new Map<String , Map< String , RT_Setting__c>>();
    public static boolean generateMaindata = false;
    Public static Map<String , Double> backStopMargin = new Map<String,Double>();
    public static date firstDayOfMonth,lastdatofMonth; 
    
    //Creating Map of Excise Tax (Sales tax)
    public Static Map<String , Double > exciseTaxList(){
        Map<String , Double > exciseTaxvalues = New Map<String , Double>();
        for( RE_Sales_Tax__c prodtax: [SELECT Id, RE_Product_Type__c, RE_Region__c, RE_Tax_Value__c FROM RE_Sales_Tax__c where RE_Region__c = 'Philippines']){
            exciseTaxvalues.put(prodtax.RE_Product_Type__c , prodtax.RE_Tax_Value__c);
        }        
        return exciseTaxvalues;
    }
    
    //PH CBU Data
    public Static Map<String,RE_PH_OutputController.costDataWrapper> phCBUdata(boolean isEGcost){   
        Map<String,RE_PH_OutputController.costDataWrapper> costdatalist = new Map<String,RE_PH_OutputController.costDataWrapper>();
        for(RE_MY_CostPrice__c costdata : [
            SELECT RE_Product_Name__r.RE_Material__c, RE_Product_Name__r.Name,RE_Product_Name__r.RE_PH_Index__c,RE_Costprice_Laid_Down_Cost__c,
            id, RE_Type__c,RE_Data__c, RE_Effective_Date__c, RE_Costprice_Marginal_Cost__c,RE_Depot_Name__r.Name
            FROM RE_MY_CostPrice__c 
        	WHERE RE_IsLatest__c = True AND RecordType.Name = 'Philippines' AND RE_PH_Is_Blend__c = False AND  RE_Depot_Name__c != null AND RE_Type__c IN ('D-1','D-2','M-1','M-2','W-1','W-2','WTD','MTD')
        	ORDER By RE_Product_Name__c	DESC]){
                String keyProDepo = costdata.RE_Product_Name__r.Name + '_' + costdata.RE_Depot_Name__r.Name;
                //system.debug('--key--'+keyProDepo);
            if(!costdatalist.containsKey(keyProDepo)){
                RE_PH_OutputController.costDataWrapper ldcdata = new RE_PH_OutputController.costDataWrapper();
                ldcdata.product = costdata.RE_Product_Name__r.Name;
                ldcdata.productcode = costdata.RE_Product_Name__r.RE_Material__c;
                ldcdata.index = Integer.valueof(costdata.RE_Product_Name__r.RE_PH_Index__c);
                if(costdata.RE_Type__c == 'M-1'){
                    ldcdata.M1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    ldcdata.M1tpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }                                
                if(costdata.RE_Type__c == 'M-2'){           
                    ldcdata.M2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-1'){           
                    ldcdata.W1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    ldcdata.W1tpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-2'){           
                    ldcdata.W2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'D-1'){           
                    ldcdata.D1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    ldcdata.D1tpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'D-2'){            
                    ldcdata.D2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c; 
                }
                if(costdata.RE_Type__c == 'MTD'){          
                    ldcdata.MTDData = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    ldcdata.MTDtpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'WTD'){         
                    ldcdata.WTDData = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    ldcdata.WTDtpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                costdatalist.put(keyProDepo,ldcdata);         
            }
            else{
                if(costdata.RE_Type__c == 'M-1'){           
                    costdatalist.get(keyProDepo).M1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    costdatalist.get(keyProDepo).M1tpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'M-2'){
                    costdatalist.get(keyProDepo).M2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-1'){           
                    costdatalist.get(keyProDepo).W1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    costdatalist.get(keyProDepo).W1tpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-2'){            
                    costdatalist.get(keyProDepo).W2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'D-1'){            
                    costdatalist.get(keyProDepo).D1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    costdatalist.get(keyProDepo).D1tpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'D-2'){           
                    costdatalist.get(keyProDepo).D2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'MTD'){
                    costdatalist.get(keyProDepo).MTDData = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    costdatalist.get(keyProDepo).MTDtpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'WTD'){        
                    costdatalist.get(keyProDepo).WTDData = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                    costdatalist.get(keyProDepo).WTDtpData = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdatalist.get(keyProDepo).W1Data != null && costdatalist.get(keyProDepo).W2Data != null)
                    costdatalist.get(keyProDepo).W1VSW2Data = costdatalist.get(keyProDepo).W1Data - 
                    costdatalist.get(keyProDepo).W2Data;
                if(costdatalist.get(keyProDepo).D1Data != null && costdatalist.get(keyProDepo).M1Data != null)
                    costdatalist.get(keyProDepo).D1VSM1Data = costdatalist.get(keyProDepo).D1Data - 
                    costdatalist.get(keyProDepo).M1Data;
                if(costdatalist.get(keyProDepo).D1Data != null && costdatalist.get(keyProDepo).W1Data != null)
                    costdatalist.get(keyProDepo).D1VSW1Data = costdatalist.get(keyProDepo).D1Data - 
                    costdatalist.get(keyProDepo).W1Data; 
                if(costdatalist.get(keyProDepo).D1Data != null && costdatalist.get(keyProDepo).D2Data != null)
                    costdatalist.get(keyProDepo).D1VSD2Data = costdatalist.get(keyProDepo).D1Data - 
                    costdatalist.get(keyProDepo).D2Data; 
                if(costdatalist.get(keyProDepo).D1Data != null && costdatalist.get(keyProDepo).WTDData != null)
                    costdatalist.get(keyProDepo).D1VSWTDData = costdatalist.get(keyProDepo).D1Data - 
                    costdatalist.get(keyProDepo).WTDData;  
                if(costdatalist.get(keyProDepo).W1Data != null && costdatalist.get(keyProDepo).WTDData != null)
                    costdatalist.get(keyProDepo).WTDVSW1Data = costdatalist.get(keyProDepo).WTDData - 
                    costdatalist.get(keyProDepo).W1Data;  
            }
        }
        //Cache.Org.put('costList', costdatalist.values());
       system.debug('===costdatalist=='+costdatalist);
        return costdatalist;
    
    }
    //Generate daily customer opps record.
    Public static void generateDailyPHdata(RE_Job_Run_Audit__c jra){
        try{  
            //Create Monday records for next one week
            RE_PH_AspriedUC3.getValidTo();
            if(RE_PH_AspriedUC3.generateMaindata){
                RE_PH_AspriedUC3.createAspriedUC3(false);
                RE_PH_RPG.calculateRPGContract(false);
                RE_PH_GPC_Calc.creategpc(false);            
            }
            
            jra.RE_IsSuccess__c = True;
            jra.RE_Exception__c = '';
            jra.RE_Job_Status__c = 'Completed';
            update jra;
        }
        catch(Exception e){            
            system.debug('---getStackTraceString '+e.getStackTraceString());            
            system.debug('---getCause '+e);
            jra.RE_IsSuccess__c = false;
            jra.RE_Job_Status__c = 'Failed';
            jra.RE_Exception__c = ''+e.getMessage() + '\n ' + e.getStackTraceString();
            update jra;
        }   
    }
    
    public static void createAspriedUC3(boolean isCBUjob){
        //If record is not approved : new record status will be Not Submitted
        List<String> approvedStatus = new List<String>{'Submitted STL','Support STL','Support PM'};
        //PH Excise Sales tax
        exciseTax = exciseTaxList();
        //Create CBU Map
        costdatalistvalues = phCBUdata(true);
        //Create Approval Scheme Map
        approvalscheme = approvalScheme();
        //Valid To (till next week monday)
        datetime validTo = getValidTo();
        boolean checkNotM_1data = true;
        List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
        
        Map<Id,RT_Price_Book__c> oldpricebook = new Map<Id,RT_Price_Book__c> ();
        //Latest Price valid for tomorrow
        List<Id> latestPriceBookContr = new List<Id>();
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
        List<REV_Contract_Master__c> contratsData = new List<REV_Contract_Master__c>();
        if(isCBUjob){
            for(RT_Price_Book__c pbdadta : [
                SELECT Id,RT_Country__c,RE_Contract_Master__c,RE_Price_support__c,RE_Custom_Opp_Approve__c,RE_ApprovalProcess__c,RE_Latest_price_dt__c,RE_Customer_Name__c,RE_Contract_Master__r.RE_Calculation_Type__c,RT_Product__c,RT_Location__c,RE_Final_Price_Rebate__c,RE_Valid_From__c,RE_Valid_To__c ,RE_Is_Latest__c,RE_CBU_Last_offered__c,RE_CBU_valid_To__c,
                RE_D_1_UC3__c,RE_W_1_UC3__c,RE_M_1_UC3__c,RE_Backstop_Margin__c,RE_Excise_tax__c FROM RT_Price_Book__c where RE_Is_Latest__c = True AND RE_Contract_Master__r.RE_Calculation_Type__c IN ('Aspired Margin','Manual') AND recordtypeId =:pricebookrectypeid order by RE_Latest_price_dt__c desc]){
                    pbdadta.RE_Is_Latest__c = false;
                    //pbdadta.RE_CBU_Last_offered__c = true;
                    pbdadta.RE_CBU_valid_To__c = system.today().addDays(-1);
                    if(!latestPriceBookContr.contains(pbdadta.RE_Contract_Master__c) && pbdadta.RE_Valid_To__c >= system.today() && pbdadta.RE_Valid_From__c <= system.today()){
                        oldpricebook.put(pbdadta.RE_Contract_Master__c,pbdadta);
                        latestPriceBookContr.add(pbdadta.RE_Contract_Master__c);
                        pricebookList.add(pbdadta);
                    }
                    if(pbdadta.RE_Valid_To__c < system.today()) 
                        pricebookList.add(pbdadta);
                }

                contratsData=[Select id ,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,Country_Name__c,RE_Customer_Name__c,RT_Material_Desc__c,RE_Calculation_Type__c,RT_Plant_Desc__c,RE_Secondary_Transport_Cost__c, RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name,RE_Aspired_Margin__c from REV_Contract_Master__c
                where  Country_Name__c = 'PH' AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today AND RE_Calculation_Type__c IN ('Aspired Margin','Manual')];
        }
        else{
                contratsData=[Select id ,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,Country_Name__c,RE_Customer_Name__c,RT_Material_Desc__c,RE_Calculation_Type__c,RT_Plant_Desc__c,RE_Secondary_Transport_Cost__c, RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name,RE_Aspired_Margin__c from REV_Contract_Master__c
                where  Country_Name__c = 'PH' AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today AND RE_Calculation_Type__c IN ('Aspired Margin','Manual') AND   RE_Reference_Period__c != 'M-1'];
        }
        
             
        if(isCBUjob || (!isCBUjob && generateMaindata)){
            for(REV_Contract_Master__c aspriedUC3con :contratsData  ){
                                                           checkNotM_1data= true;
                                                           RT_Price_Book__c pbdata = new RT_Price_Book__c();
                                                           String keyProDepo = aspriedUC3con.RT_Material_Desc__r.Name+ '_' + aspriedUC3con.RT_Plant_Desc__r.Name;
                                                           pbdata.recordtypeId = pricebookrectypeid;
                                                           pbdata.RT_Country__c = aspriedUC3con.Country_Name__c;
                                                           pbdata.RE_Contract_Master__c = aspriedUC3con.id;
                                                           pbdata.RE_Customer_Name__c = aspriedUC3con.RE_Customer_Name__c;	
                                                           pbdata.RT_Product__c = aspriedUC3con.RT_Material_Desc__c;
                                                           pbdata.RT_Location__c = aspriedUC3con.RT_Plant_Desc__c;
                                                           pbdata.RE_Is_Latest__c = True;
                                                           pbdata.RE_Job_Counter__c = 0;  
                                                           pbdata.RE_CBU_valid_from__c = system.today();
                                                           pbdata.RE_AutoCalRefAmnt__c  = aspriedUC3con.RE_Aspired_Margin__c;
                                                           double Excisetax = exciseTax.containsKey(aspriedUC3con.RT_Material_Desc__r.RE_Product_Group__c) ? exciseTax.get(aspriedUC3con.RT_Material_Desc__r.RE_Product_Group__c) : 0.0;
                                                           double reference_PeriodValue ;
                                                           double secondTf = aspriedUC3con.RE_Secondary_Transport_Cost__c != null ? aspriedUC3con.RE_Secondary_Transport_Cost__c : 0.0;
                                                           pbdata.RE_Transport_Charge__c = secondTf;
                                                           double aspMargin = aspriedUC3con.RE_Aspired_Margin__c != null ? aspriedUC3con.RE_Aspired_Margin__c : 0.0;
                                                           String marginCheck = 'RE_W_1_UC3__c';
                                                           
                                                           if(costdatalistvalues.containsKey(keyProDepo)){
                                                               switch on aspriedUC3con.RE_Reference_Period__c {
                                                                   when 'D-1' {		
                                                                       reference_PeriodValue = costdatalistvalues.get(keyProDepo).D1Data;
                                                                       marginCheck = 'RE_D_1_UC3__c';
                                                                   }
                                                                   when 'W-1' {		
                                                                       reference_PeriodValue = costdatalistvalues.get(keyProDepo).W1Data;
                                                                       marginCheck = 'RE_W_1_UC3__c';
                                                                   }
                                                                   when 'M-1' {		
                                                                       reference_PeriodValue = costdatalistvalues.get(keyProDepo).M1Data;
                                                                       marginCheck = 'RE_M_1_UC3__c';
                                                                   }
                                                                   when 'WTD' {		
                                                                       reference_PeriodValue = costdatalistvalues.get(keyProDepo).WTDData;
                                                                       marginCheck = 'RE_WTD_UC3__c';
                                                                   }
                                                                   when 'MTD' {		
                                                                       reference_PeriodValue = costdatalistvalues.get(keyProDepo).MTDData;
                                                                       marginCheck = 'RE_MTD_UC3__c';
                                                                   }
                                                                   when null {                        
                                                                       reference_PeriodValue = 0.0;
                                                                       marginCheck = 'RE_W_1_UC3__c';
                                                                   }
                                                               }               
                                                           }
                                                           else 
                                                               reference_PeriodValue = 0.0;                
                                                           pbdata.RE_Price_support__c = 0.00;
                                                           if( aspriedUC3con.RE_PS_valid_to__c != null && aspriedUC3con.RE_PS_valid_to__c >= date.today()){
                                                               pbdata.RE_Price_support__c = aspriedUC3con.RE_Price_support__c != null ? aspriedUC3con.RE_Price_support__c : 0.00;                           
                                                           }
                                                           
                                                           //checks price book record valid till tomorrow
                                                           if(oldpricebook.containsKey(aspriedUC3con.Id)){
                                                               pbdata.RE_Final_Price_Rebate__c = oldpricebook.get(aspriedUC3con.Id).RE_Final_Price_Rebate__c;
                                                               pbdata.RE_Valid_From__c = oldpricebook.get(aspriedUC3con.Id).RE_Valid_From__c;
                                                               pbdata.RE_Valid_To__c =  oldpricebook.get(aspriedUC3con.Id).RE_Valid_To__c;
                                                               pbdata.RE_Latest_price_dt__c = oldpricebook.get(aspriedUC3con.Id).RE_Latest_price_dt__c.addMinutes(1);
                                                               pbdata.RE_ApprovalProcess__c = oldpricebook.get(aspriedUC3con.Id).RE_ApprovalProcess__c;
                                                               pbdata.RE_Custom_Opp_Approve__c = oldpricebook.get(aspriedUC3con.Id).RE_Custom_Opp_Approve__c;
                                                               if(approvedStatus.contains(oldpricebook.get(aspriedUC3con.Id).RE_Custom_Opp_Approve__c))
                                                                   pbdata.RE_Custom_Opp_Approve__c = 'Not Submitted';
                                                               pbdata.RE_Backstop_Margin__c = oldpricebook.get(aspriedUC3con.Id).RE_Backstop_Margin__c;
                                                               pbdata.RE_Excise_tax__c = oldpricebook.get(aspriedUC3con.Id).RE_Excise_tax__c;
                                                               // pbdata.RE_Price_support__c = oldpricebook.get(aspriedUC3con.Id).RE_Price_support__c != null ? oldpricebook.get(aspriedUC3con.Id).RE_Price_support__c : 0.00;
                                                               if(generateMaindata && !isCBUjob && aspriedUC3con.RE_Reference_Period__c == 'M-1')
                                                                   checkNotM_1data = false;
                                                           }
                                                           else{
                                                               pbdata.RE_Final_Price_Rebate__c = decimal.valueOf(reference_PeriodValue + Excisetax + secondTf + aspMargin).setScale(6);
                                                               pbdata.RE_Excise_tax__c = Excisetax;
                                                               pbdata.RE_Valid_From__c = isCBUjob ? System.today(): System.today().addDays(1);
                                                               pbdata.RE_Valid_To__c =   date.valueOf(validTo);
                                                               pbdata.RE_Latest_price_dt__c = DateTime.now();
                                                               pbdata.RE_Backstop_Margin__c = backStopMargin.get(aspriedUC3con.RE_PH_Approval_Scheme__c);
                                                              
                                                               if(aspriedUC3con.RE_Calculation_Type__c == 'Manual')
                                                                   pbdata.RE_Final_Price_Rebate__c = 0; 

                                                                if(aspriedUC3con.RE_Reference_Period__c == 'M-1'){
                                                                       pbdata.RE_Valid_From__c = firstDayOfMonth;
                                                                       pbdata.RE_Valid_To__c = lastdatofMonth;
                                                                   }
                                                                       
                                                               
                                                           }                                         
                                                           
                                                           pbdata.RE_D_1_UC3__c =   pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).D1Data != null ? costdatalistvalues.get(keyProDepo).D1Data : 0.0) : 0.0);
                                                           pbdata.RE_W_1_UC3__c =   pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).W1Data != null ? costdatalistvalues.get(keyProDepo).W1Data : 0.0) : 0.0);
                                                           pbdata.RE_M_1_UC3__c =   pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? ( costdatalistvalues.get(keyProDepo).M1Data != null ? costdatalistvalues.get(keyProDepo).M1Data : 0.0) : 0.0);
                                                           pbdata.RE_WTD_UC3__c =   pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).WTDData != null ? costdatalistvalues.get(keyProDepo).WTDData : 0.0) : 0.0);
                                                           pbdata.RE_MTD_UC3__c =   pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).MTDData != null ? costdatalistvalues.get(keyProDepo).MTDData : 0.0) : 0.0);
                                                           pbdata.RE_Reference_Price__c = reference_PeriodValue;
                                                           pbdata.RE_Reference_Period__c = marginCheck;                                          
                                                           Double marginValue = double.valueof(pbdata.get(marginCheck));
                                                           pbdata.RE_RefUC3_Price__c = marginValue;                                           
                                                           if(!oldpricebook.containsKey(aspriedUC3con.Id)) {
                                                               pbdata.RE_Custom_Opp_Approve__c = 'Auto Approved';
                                                               if(aspriedUC3con.RE_Calculation_Type__c != 'Manual')
                                                                   pricebookList.add(updateApprovalScheme(pbdata , aspriedUC3con.RE_PH_Approval_Scheme__c ,marginValue )); 
                                                               else
                                                                   pricebookList.add(pbdata);
                                                           }
                                                           else{
                                                               if(checkNotM_1data)
                                                                   pricebookList.add(pbdata);                                                              
                                                              
                                                           }

                                                           if(pbdata.RE_Final_Price_Rebate__c <= 0)
                                                                pbdata.RE_Custom_Opp_Approve__c = 'Rejected';
                                                           
                                                           
                                                       }
        }
        Upsert pricebookList;      
    }  
    
    public static Map<String , Map< String , RT_Setting__c >> approvalScheme(){ 
        Map<String , Map< String , RT_Setting__c >> approvalschemedata = new Map<String , Map< String , RT_Setting__c>>();
        for(RT_Setting__c temApproval : [SELECT Id,Name,RE_Approval_Status__c, RE_Approver_Role_1__c, RE_Approver_Role_2__c, RE_Max_Margin__c, RE_Min_Margin__c, 
                                         RE_User_Name__c, RE_User_Name__r.Name, RE_Delegate_Approver__c,RE_Delegate_Approver__r.Name FROM RT_Setting__c where recordType.Name = 'RE Approval Process' AND Country__c = 'PH']){
            
            Map< String , RT_Setting__c> oldValues = new Map< String , RT_Setting__c>();
            //backStopMargin
            if(temApproval.RE_Approval_Status__c == 'Auto Approved' )
                backStopMargin.put(temApproval.name,temApproval.RE_Min_Margin__c);
                
            if(approvalschemedata.containskey(temApproval.name))
                oldValues = approvalschemedata.get(temApproval.name);
            oldValues.put(temApproval.id,temApproval );
            approvalschemedata.put(temApproval.name ,oldValues);	            
        }
        
        return approvalschemedata;
    }
    
    public static RT_Price_Book__c updateApprovalScheme(RT_Price_Book__c checkmargin , string scheme , double marginValues){
        Map< String , RT_Setting__c> approvalSchemes = new Map< String , RT_Setting__c>();	
        
        if(approvalscheme.containsKey(scheme)){
            approvalSchemes = approvalscheme.get(scheme);
            
            for(String idkey : approvalSchemes.keySet()){               
                
                double max = approvalSchemes.get(idkey).RE_Max_Margin__c;
                double min = approvalSchemes.get(idkey).RE_Min_Margin__c;            
                
                //if(marginValues <= max && marginValues >= min){
                if(max >= 0){                    
                    if(min <= marginValues &&  marginValues <= max){
                        
                        checkmargin.RE_ApprovalProcess__c = idkey;
                       // checkmargin.RE_Custom_Opp_Approve__c = checkmargin.RE_Contract_Master__r.RE_Calculation_Type__c == 'RPG' ? 'Not Submitted' :  approvalSchemes.get(idkey).RE_Approval_Status__c;                        
                        checkmargin.RE_Custom_Opp_Approve__c = approvalSchemes.get(idkey).RE_Approval_Status__c;
                        break;
                    }
                }
                else{
                    
                    if(max <= marginValues  &&  marginValues <= min){
                        
                        checkmargin.RE_ApprovalProcess__c = idkey;
                        //checkmargin.RE_Custom_Opp_Approve__c =   checkmargin.RE_Contract_Master__r.RE_Calculation_Type__c == 'RPG' ? 'Not Submitted' : approvalSchemes.get(idkey).RE_Approval_Status__c;
                        checkmargin.RE_Custom_Opp_Approve__c = approvalSchemes.get(idkey).RE_Approval_Status__c;
                        break;
                    }
                }
                
            }          
            
        }
        return checkmargin;            
    }  
    
    public static Datetime getValidTo(){
        List<String> holidaysDate= new List<String>();
        Datetime currentDay = (DateTime)System.today();
        String dayOfWeek = currentDay.format('EEEE');
        Datetime D_1 = currentDay.adddays(-1);
        
        date myDate = date.today();
        date weekStart = myDate.toStartofWeek();
        Datetime nextweekStart = (Datetime)weekStart.addDays(7);
        Datetime nextWeekD_1 = (Datetime)weekStart.addDays(8);
        
        firstDayOfMonth = System.today().toStartOfMonth();
        lastdatofMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);        
        
        for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'PH Holiday Calendar' ])
            holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
        
        
        if( (dayOfWeek == 'Monday' && !holidaysDate.contains(string.valueof(currentDay))) ||  (dayOfWeek == 'Tuesday' && holidaysDate.contains(string.valueof(D_1))))
            generateMaindata = true;
            
        if(holidaysDate.contains(string.valueof(nextweekStart)))
            return nextWeekD_1;
        else
            return nextweekStart;
    }
    
    public static void allContractDataGen(List<REV_Contract_Master__c> contractData){
        List<String> newCintractId = new List<String>();
        RE_Job_Run_Audit__c newContractJob = [select id , RE_IsSuccess__c,RE_Exception__c,RE_Job_Status__c from RE_Job_Run_Audit__c where RE_Job_Type__c = 'New Contract PH Pricing Output' order by createddate desc  limit 1];
        try{
            //PH Excise Sales tax
            exciseTax = exciseTaxList();
            //Create CBU Map
            costdatalistvalues = phCBUdata(true);
            //Create Approval Scheme Map
            approvalscheme = approvalScheme();
            //Valid To (till next week monday)
            datetime validTo = getValidTo();
            
            //Get RPG Pricing Input data
            Map<String,RE_Pricing_Input__c> rpgMap = RE_PH_RPG.fetchRPGdata(true);
            //Get Tier Input data
            Map<String,RE_Pricing_Input__c> tierMap = RE_PH_RPG.fetchTierdata();
            //Get GPC amount
            Map<String , RE_Pricing_Input__c > gcpAdviseInputMap = New Map<String , RE_Pricing_Input__c>();
            for(RE_Pricing_Input__c gcpInputPricing :[Select id ,RE_GPCAmnt__c,RE_Start_Date__c,RE_End_Date__c, RE_Material__c from RE_Pricing_Input__c
                                                    where RE_Start_Date__c <= Today AND RE_End_Date__c >= Today AND RE_Type__c = 'GPC'] )     
                gcpAdviseInputMap.put(gcpInputPricing.RE_Material__c, gcpInputPricing);
            
            
            List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
            Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
            
            for(REV_Contract_Master__c newContract :contractData){
                system.debug('--inside contract master--');
                RT_Price_Book__c pbdata = new RT_Price_Book__c();
                String keyProDepo = newContract.RT_Material_Desc__r.Name+ '_' + newContract.RT_Plant_Desc__r.Name;
                String keyContract = newContract.RE_Ship_To_Number__c+ '_' +newContract.RE_Material_Code__c+ '_' + newContract.RT_Plant_Desc__r.Name;
                String rpgValueKey = newContract.RT_Plant_Desc__r.RE_Location_Code__c + '_' +newContract.RT_Material_Desc__r.RE_Material__c;
                String tiervalueKey = newContract.RT_Plant_Code__c + '_' +newContract.RE_Material_Code__c +'_'+newContract.RE_Ship_To_Number__c; 
                pbdata.recordtypeId = pricebookrectypeid;
                pbdata.RT_Country__c = newContract.Country_Name__c;
                pbdata.RE_Contract_Master__c = newContract.id;
                pbdata.RE_Customer_Name__c = newContract.RE_Customer_Name__c;	
                pbdata.RT_Product__c = newContract.RT_Material_Desc__c;
                pbdata.RT_Location__c = newContract.RT_Plant_Desc__c;
                pbdata.RE_Is_Latest__c = True;
                pbdata.RE_Job_Counter__c = 0;  
                pbdata.RE_CBU_valid_from__c = system.today();                
                double Excisetax = exciseTax.containsKey(newContract.RT_Material_Desc__r.RE_Product_Group__c) ? exciseTax.get(newContract.RT_Material_Desc__r.RE_Product_Group__c) : 0.0;
                double reference_PeriodValue ;
                double secondTf = newContract.RE_Secondary_Transport_Cost__c != null ? newContract.RE_Secondary_Transport_Cost__c : 0.0;
                pbdata.RE_Transport_Charge__c = secondTf;
                double aspMargin = newContract.RE_Aspired_Margin__c != null ? newContract.RE_Aspired_Margin__c : 0.0;
                String marginCheck = 'RE_W_1_UC3__c';
                
                
                if(costdatalistvalues.containsKey(keyProDepo)){
                    switch on newContract.RE_Reference_Period__c {
                        when 'D-1' {
                            reference_PeriodValue = costdatalistvalues.get(keyProDepo).D1Data;
                            marginCheck = 'RE_D_1_UC3__c';
                        }
                        when 'W-1' {		
                            reference_PeriodValue = costdatalistvalues.get(keyProDepo).W1Data;
                            marginCheck = 'RE_W_1_UC3__c';
                        }
                        when 'M-1' {		
                            reference_PeriodValue = costdatalistvalues.get(keyProDepo).M1Data;
                            marginCheck = 'RE_M_1_UC3__c';
                        }
                        when 'WTD' {		
                            reference_PeriodValue = costdatalistvalues.get(keyProDepo).WTDData;
                            marginCheck = 'RE_WTD_UC3__c';
                        }
                        when 'MTD' {		
                            reference_PeriodValue = costdatalistvalues.get(keyProDepo).MTDData;
                            marginCheck = 'RE_MTD_UC3__c';
                        }
                        when null {                        
                            reference_PeriodValue = 0.0;
                            marginCheck = 'RE_W_1_UC3__c';
                        }
                    }               
                }
                else 
                    reference_PeriodValue = 0.0;   
                
                pbdata.RE_Price_support__c =  0.00;
                if( newContract.RE_PS_valid_to__c != null && newContract.RE_PS_valid_to__c >= date.today()){
                    pbdata.RE_Price_support__c = newContract.RE_Price_support__c != null ? newContract.RE_Price_support__c : 0.00;                           
                }     
                
                //For Aspried Margin
                if(newContract.RE_Calculation_Type__c == 'Aspired Margin'  ){
                    pbdata.RE_AutoCalRefAmnt__c  = newContract.RE_Aspired_Margin__c;
                    pbdata.RE_Final_Price_Rebate__c = decimal.valueOf(reference_PeriodValue + Excisetax + secondTf + aspMargin).setScale(6);
                    pbdata.RE_Valid_From__c = System.today();
                    pbdata.RE_Valid_To__c =   date.valueOf(validTo);
                    
                }
                //For RPG
                if(newContract.RE_Calculation_Type__c == 'RPG'){
                    pbdata.RE_AutoCalRefAmnt__c = rpgMap.containskey(rpgValueKey) ? double.valueof(rpgMap.get(rpgValueKey).RE_FixedPrice__c) : 0.0;
                    pbdata.RE_AutoCalRefAmntAdj__c =  tierMap.containskey(tiervalueKey) ? double.valueof(tierMap.get(tiervalueKey).RE_TierAmnt__c) : 0.0; 
                    pbdata.RE_Final_Price_Rebate__c = (pbdata.RE_AutoCalRefAmnt__c + pbdata.RE_AutoCalRefAmntAdj__c).setScale(6);
                    pbdata.RE_Valid_From__c = rpgMap.containskey(rpgValueKey) ? rpgMap.get(rpgValueKey).RE_Start_Date__c :  System.today();
                    pbdata.RE_Valid_To__c =   rpgMap.containskey(rpgValueKey) ? rpgMap.get(rpgValueKey).RE_End_Date__c  : date.valueOf(validTo);
                }
                //For GPC
                if(newContract.RE_Calculation_Type__c == 'GPC'){
                    pbdata.RE_AutoCalRefAmnt__c = (newContract.RE_Prev_Week_Price__c != null ? newContract.RE_Prev_Week_Price__c : 0.0) ;
                    pbdata.RE_AutoCalRefAmntAdj__c= gcpAdviseInputMap.containsKey(newContract.RE_Material_Code__c) ? gcpAdviseInputMap.get(newContract.RE_Material_Code__c).RE_GPCAmnt__c : 0.0;   
                    pbdata.RE_Final_Price_Rebate__c = (pbdata.RE_AutoCalRefAmntAdj__c + pbdata.RE_AutoCalRefAmnt__c).setScale(6) ;  
                    pbdata.RE_Valid_From__c = gcpAdviseInputMap.containskey(newContract.RE_Material_Code__c) ? gcpAdviseInputMap.get(newContract.RE_Material_Code__c).RE_Start_Date__c :  System.today();
                    pbdata.RE_Valid_To__c =   gcpAdviseInputMap.containskey(newContract.RE_Material_Code__c) ? gcpAdviseInputMap.get(newContract.RE_Material_Code__c).RE_End_Date__c  : date.valueOf(validTo);                              
                }  
                if(newContract.RE_Calculation_Type__c == 'Manual'){
                    pbdata.RE_Final_Price_Rebate__c = 0;
                    pbdata.RE_Valid_From__c = System.today();
                    pbdata.RE_Valid_To__c =   date.valueOf(validTo);                   
                }
                if(newContract.RE_Reference_Period__c == 'M-1'){
                    pbdata.RE_Valid_From__c = firstDayOfMonth;
                    pbdata.RE_Valid_To__c =   lastdatofMonth;
                }
                
                pbdata.RE_Excise_tax__c = Excisetax;
                pbdata.RE_Latest_price_dt__c = DateTime.now();
                pbdata.RE_Backstop_Margin__c = RE_PH_AspriedUC3.backStopMargin.get(newContract.RE_PH_Approval_Scheme__c);
                pbdata.RE_D_1_UC3__c =  pbdata.RE_Price_support__c  + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).D1Data != null ? costdatalistvalues.get(keyProDepo).D1Data : 0.0) : 0.0);
                pbdata.RE_W_1_UC3__c =  pbdata.RE_Price_support__c  + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).W1Data != null ? costdatalistvalues.get(keyProDepo).W1Data : 0.0) : 0.0);
                pbdata.RE_M_1_UC3__c =  pbdata.RE_Price_support__c  + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? ( costdatalistvalues.get(keyProDepo).M1Data != null ? costdatalistvalues.get(keyProDepo).M1Data : 0.0) : 0.0);
                pbdata.RE_WTD_UC3__c =  pbdata.RE_Price_support__c  + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).WTDData != null ? costdatalistvalues.get(keyProDepo).WTDData : 0.0) : 0.0);
                pbdata.RE_MTD_UC3__c =  pbdata.RE_Price_support__c  + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).MTDData != null ? costdatalistvalues.get(keyProDepo).MTDData : 0.0) : 0.0);
                pbdata.RE_Reference_Price__c = reference_PeriodValue;
                pbdata.RE_Reference_Period__c = marginCheck;                                          
                Double marginValue = double.valueof(pbdata.get(marginCheck));
                pbdata.RE_RefUC3_Price__c = marginValue;     
                pbdata.RE_Custom_Opp_Approve__c = 'Auto Approved';
                if(pbdata.RE_Final_Price_Rebate__c <= 0)
                    pbdata.RE_Custom_Opp_Approve__c = 'Rejected';
                if(newContract.RE_Calculation_Type__c != 'Manual' && newContract.RE_Calculation_Type__c != 'RPG')
                    pricebookList.add(updateApprovalScheme(pbdata , newContract.RE_PH_Approval_Scheme__c ,marginValue )); 
                else 
                    pricebookList.add(pbdata);
                
               

            }
            system.debug('--PB size--'+pricebookList.size());
            if(!pricebookList.isempty())
                insert pricebookList;  
            
            newContractJob.RE_IsSuccess__c = True;
            newContractJob.RE_Exception__c = '';
            newContractJob.RE_Job_Status__c = 'Completed';
            update newContractJob;
                             
        }catch(Exception ex){
            newContractJob.RE_IsSuccess__c = false;
            newContractJob.RE_Job_Status__c = 'Failed';
            newContractJob.RE_Exception__c = ''+ex.getMessage() + '\n ' + ex.getStackTraceString();
            update newContractJob;
        } 
    } 
    
    public static void newContractdataGen(){
        allContractDataGen(RE_PHCustomerDashboard.getNewContracts());
    }
    
    public static void generateM_1Data(){
        Id AccrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution PH').getRecordTypeId();
        
        List<Account> acclist= [SELECT Id FROM Account WHERE RT_Active__c = True AND recordtypeId = : AccrectypeId];
        List< REV_Contract_Master__c> contractData = new List< REV_Contract_Master__c>([
        Select id ,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,Country_Name__c,RE_Customer_Name__c,RT_Material_Desc__c,RE_Secondary_Transport_Cost__c,
        RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name,RE_Aspired_Margin__c,RE_Prev_Week_Price__c,RE_Material_Code__c ,RE_Ship_To_Number__c,RE_Sold_To_Number__c,RE_Rebate__c,
        RE_Customer_Name__r.AccountNumber ,RT_Plant_Desc__r.RE_Location_Code__c,RT_Material_Desc__r.RE_Material__c ,RE_Calculation_Type__c,RT_Plant_Desc__c,RT_Plant_Code__c from REV_Contract_Master__c
        where Active__c = True  AND RE_Customer_Name__c IN: acclist AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today AND  RE_Reference_Period__c = 'M-1']);

        allContractDataGen(contractData);
        
    }

}