public class RE_PH_GPC_Calc {
    Public Static Map<String , Double > exciseTax = New Map<String , Double>();
    Public Static Map<String , RE_Pricing_Input__c > gcpAdviseInputMap = New Map<String , RE_Pricing_Input__c>();
    Public Static Map<String , Double>  prevWeekPriceMap = New Map<String , Double>();   
    Public Static Map<String,RE_PH_OutputController.costDataWrapper> costdatalist = new Map<String,RE_PH_OutputController.costDataWrapper>();
    //Midweek Price check
    public Static Map<string,RT_Price_Book__c> oldpricebookGPCdata = new Map<string,RT_Price_Book__c> ();
    //Midweek data generation boolean variables
    public static boolean midweekgen= false , datachanged = false;
    public static datetime validTo = RE_PH_AspriedUC3.getValidTo();
    
    //fetching gcp advise
    public Static void gcpPricingInput(boolean isCBU) {
        List<RE_Pricing_Input__c> gpcData = new List<RE_Pricing_Input__c>();
        if(isCBU)
        gpcData = [Select id ,RE_GPCAmnt__c,RE_Start_Date__c,RE_End_Date__c, RE_Material__c from RE_Pricing_Input__c
                                                      where RE_Start_Date__c <= Today AND RE_End_Date__c >= Today AND RE_Type__c = 'GPC'];        
        else
        gpcData = [Select id ,RE_GPCAmnt__c,RE_Start_Date__c,RE_End_Date__c, RE_Material__c from RE_Pricing_Input__c
                                                      where RE_Start_Date__c <= Tomorrow AND RE_End_Date__c >= Tomorrow AND RE_Type__c = 'GPC'];   

        for(RE_Pricing_Input__c gpc :gpcData){ 
            gpc.RE_Is_latest__c = false;
            gcpAdviseInputMap.put(gpc.RE_Material__c, gpc);        
        }
        
        if(!gpcData.isEmpty() && !midweekgen)
            update gpcData;
    }
    //fetching previous week's net price 
    public Static void getnetpriceInput() {
        //List<RT_Price_Book__c> pricebbookList = New List<RT_Price_Book__c>();
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
        Map<Id,RT_Price_Book__c> latestpricebook = new Map<Id,RT_Price_Book__c> ();
        for(RT_Price_Book__c gpcPricebook :
            [Select id ,RE_Final_Price_Rebate__c,RE_Contract_Master__c,RE_Sold_To_Number__c,RE_Ship_To_Number__c,RT_Location__r.Name, RE_Material_Code__c from RT_Price_Book__c
             where RE_Valid_To__c <= TODAY AND RE_Is_Latest__c = True AND RE_Contract_Master__r.RE_Calculation_Type__c = 'GPC' AND recordtypeId =:pricebookrectypeid order by RE_Latest_price_dt__c desc] ){
                 
                 String keypriceBook = gpcPricebook.RE_Sold_To_Number__c+'_'+gpcPricebook.RE_Ship_To_Number__c+'_'+gpcPricebook.RE_Material_Code__c+'_'+gpcPricebook.RT_Location__r.Name;
                 //checking for duplicate records on Monday
                 if(!latestpricebook.containsKey(gpcPricebook.RE_Contract_Master__c)){
                     latestpricebook.put(gpcPricebook.RE_Contract_Master__c,gpcPricebook);
                     // double netPrice = gpcPricebook.RE_Final_Price_Rebate__c+ gcpAdviseInputMap.get(gpcPricebook.RE_Material_Code__c);
                     prevWeekPriceMap.put(keypriceBook,gpcPricebook.RE_Final_Price_Rebate__c);
                     //System.debug('prevWeekPriceMap--'+prevWeekPriceMap);
                 }                 
             }
    }
    public static void creategpc(boolean isCBUjob){
        //If record is not approved : new record status will be Not Submitted
        List<String> approvedStatus = new List<String>{'Submitted STL','Support STL','Support PM'};
        //PH Excise Sales tax
        exciseTax = RE_PH_AspriedUC3.exciseTaxList();
        //Create CBU Map
        costdatalist = RE_PH_AspriedUC3.phCBUdata(true);
        //Create Approval Scheme Map
        RE_PH_AspriedUC3.approvalscheme = RE_PH_AspriedUC3.approvalScheme();
        //Valid To (till next week monday)
        //datetime validTo = RE_PH_AspriedUC3.getValidTo();
        date firstDayOfMonth = RE_PH_AspriedUC3.firstDayOfMonth , lastdatofMonth = RE_PH_AspriedUC3.lastdatofMonth;
        boolean checkNotM_1data = true;
        
        // Fetching the GPC Amnt
        gcpPricingInput(isCBUjob);
        // Fetching the net price
        getnetpriceInput(); 
        //Latest Price valid for tomorrow
        Map<Id,RT_Price_Book__c> oldpricebook = new Map<Id,RT_Price_Book__c> ();
        List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
        List<RT_Price_Book__c> pricebookList2 = new List<RT_Price_Book__c>();
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
        List<REV_Contract_Master__c> contratsData = new List<REV_Contract_Master__c>();
        
        if(isCBUjob){
            for(RT_Price_Book__c pbdadta : [
                SELECT Id,RT_Country__c,RE_Contract_Master__c,RE_AutoCalRefAmnt__c,RE_Price_support__c,RE_Latest_price_dt__c,RE_Customer_Name__c,RT_Product__c,RE_ApprovalProcess__c,RE_Custom_Opp_Approve__c,RT_Location__c,RE_Final_Price_Rebate__c,
                RE_Valid_From__c,RE_Valid_To__c ,RE_Is_Latest__c,RE_CBU_Last_offered__c,RE_CBU_valid_To__c, RE_D_1_UC3__c,RE_W_1_UC3__c,RE_M_1_UC3__c,RE_Backstop_Margin__c,RE_Excise_tax__c,RE_AutoCalRefAmntAdj__c
                FROM RT_Price_Book__c where RE_Is_Latest__c = True  AND recordtypeId =:pricebookrectypeid AND RE_Contract_Master__r.RE_Calculation_Type__c = 'GPC' order by RE_Latest_price_dt__c desc]){
                    pbdadta.RE_Is_Latest__c = false;
                    pbdadta.RE_CBU_valid_To__c = system.today().addDays(-1);
                    if(!oldpricebook.containskey(pbdadta.RE_Contract_Master__c)  && pbdadta.RE_Valid_To__c >= system.today() && pbdadta.RE_Valid_From__c <= system.today() ){  
                        oldpricebook.put(pbdadta.RE_Contract_Master__c,pbdadta);
                        pricebookList2.add(pbdadta);
                    } 
                    if(pbdadta.RE_Valid_To__c < system.today())
                        pricebookList2.add(pbdadta);
                    //if(!midweekgen)
                        //pricebookList2.add(pbdadta);
                }

                contratsData =  [Select id ,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,Country_Name__c,RE_Prev_Week_Price__c,RE_Customer_Name__c,RE_Material_Code__c,
                 RE_Ship_To_Number__c,RE_Sold_To_Number__c,RT_Material_Desc__c,RT_Plant_Desc__c,RE_Secondary_Transport_Cost__c,
                 RE_Rebate__c, RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name from REV_Contract_Master__c
                 where  Country_Name__c = 'PH' AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today AND RE_Calculation_Type__c = 'GPC'];
        }
        else {
                 contratsData =  [Select id ,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,Country_Name__c,RE_Prev_Week_Price__c,RE_Customer_Name__c,RE_Material_Code__c,
                 RE_Ship_To_Number__c,RE_Sold_To_Number__c,RT_Material_Desc__c,RT_Plant_Desc__c,RE_Secondary_Transport_Cost__c,
                 RE_Rebate__c, RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name from REV_Contract_Master__c
                 where  Country_Name__c = 'PH' AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today AND RE_Calculation_Type__c = 'GPC'AND RE_Reference_Period__c != 'M-1'];
        }
        system.debug('---size--'+pricebookList2.size());
		Update pricebookList2;         
        if(isCBUjob || (!isCBUjob && RE_PH_AspriedUC3.generateMaindata)){
            for(REV_Contract_Master__c gpcUC3 : contratsData ){
                     RT_Price_Book__c pbdata = new RT_Price_Book__c();
                     String keyContract = gpcUC3.RE_Sold_To_Number__c+'_'+gpcUC3.RE_Ship_To_Number__c+ '_' +gpcUC3.RE_Material_Code__c+ '_' + gpcUC3.RT_Plant_Desc__r.Name;
                     String keyCostPrice = gpcUC3.RT_Material_Desc__r.Name+ '_' + gpcUC3.RT_Plant_Desc__r.Name;        
                     checkNotM_1data = true;
                     //if(netPriceMap.containsKey(keyContract)){
                     pbdata.recordtypeId = pricebookrectypeid;
                     pbdata.RT_Country__c = gpcUC3.Country_Name__c;
                     pbdata.RE_Contract_Master__c = gpcUC3.id;
                     pbdata.RE_Customer_Name__c = gpcUC3.RE_Customer_Name__c;	
                     pbdata.RT_Product__c = gpcUC3.RT_Material_Desc__c;
                     pbdata.RT_Location__c = gpcUC3.RT_Plant_Desc__c;
                     pbdata.RE_Rebate__c = gpcUC3.RE_Rebate__c != null ? gpcUC3.RE_Rebate__c : 0.0  ;
                     pbdata.RE_Is_Latest__c = True;
                     pbdata.RE_Job_Counter__c = 0;  
                     pbdata.RE_CBU_valid_from__c = system.today();
                     pbdata.RE_AutoCalRefAmnt__c = prevWeekPriceMap.containsKey(keyContract) ? prevWeekPriceMap.get(keyContract) : (gpcUC3.RE_Prev_Week_Price__c > 0 ? gpcUC3.RE_Prev_Week_Price__c : 0.0) ;
                     pbdata.RE_AutoCalRefAmntAdj__c= gcpAdviseInputMap.containsKey(gpcUC3.RE_Material_Code__c) ? gcpAdviseInputMap.get(gpcUC3.RE_Material_Code__c).RE_GPCAmnt__c : 0.0;                                   
                     //pbdata.RE_Final_Price_Rebate__c = netPriceMap.containsKey(keyContract) ? netPriceMap.get(keyContract) : 0.0 ;
                     pbdata.RE_Transport_Charge__c = gpcUC3.RE_Secondary_Transport_Cost__c != null ? gpcUC3.RE_Secondary_Transport_Cost__c : 0.0;
                     double Excisetax = exciseTax.containsKey(gpcUC3.RT_Material_Desc__r.RE_Product_Group__c) ? exciseTax.get(gpcUC3.RT_Material_Desc__r.RE_Product_Group__c) : 0.0;
                     double reference_PeriodValue ;
                     String marginCheck = 'RE_W_1_UC3__c';
                     
                     if(costdatalist.containsKey(keyCostPrice)){
                         switch on gpcUC3.RE_Reference_Period__c {
                             when 'D-1' {
                                 reference_PeriodValue = costdatalist.get(keyCostPrice).D1Data;
                                 marginCheck = 'RE_D_1_UC3__c';
                             }
                             when 'W-1' {		
                                 reference_PeriodValue = costdatalist.get(keyCostPrice).W1Data;
                                 marginCheck = 'RE_W_1_UC3__c';
                             }
                             when 'M-1' {		
                                 reference_PeriodValue = costdatalist.get(keyCostPrice).M1Data;
                                 marginCheck = 'RE_M_1_UC3__c';
                             }
                             when 'WTD' {		
                                 reference_PeriodValue = costdatalist.get(keyCostPrice).WTDData;
                                 marginCheck = 'RE_WTD_UC3__c';
                             }
                             when 'MTD' {		
                                 reference_PeriodValue = costdatalist.get(keyCostPrice).MTDData;
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
                         if( gpcUC3.RE_PS_valid_to__c != null && gpcUC3.RE_PS_valid_to__c >= date.today()){
                             pbdata.RE_Price_support__c = gpcUC3.RE_Price_support__c != null ? gpcUC3.RE_Price_support__c : 0.00;                           
                         }
                     //checks price book record valid till tomorrow
                     if(oldpricebook.containsKey(gpcUC3.Id) && pbdata.RE_AutoCalRefAmntAdj__c == oldpricebook.get(gpcUC3.Id).RE_AutoCalRefAmntAdj__c ){
                         System.debug('oldprice--'+oldpricebook.get(gpcUC3.Id).RE_Final_Price_Rebate__c);
                         pbdata.RE_Final_Price_Rebate__c = oldpricebook.get(gpcUC3.Id).RE_Final_Price_Rebate__c;
                         pbdata.RE_AutoCalRefAmnt__c = oldpricebook.get(gpcUC3.Id).RE_AutoCalRefAmnt__c;
                         pbdata.RE_Valid_From__c = oldpricebook.get(gpcUC3.Id).RE_Valid_From__c;
                         pbdata.RE_Valid_To__c =  oldpricebook.get(gpcUC3.Id).RE_Valid_To__c;
                         pbdata.RE_Latest_price_dt__c = oldpricebook.get(gpcUC3.Id).RE_Latest_price_dt__c.addMinutes(1);
                         pbdata.RE_ApprovalProcess__c = oldpricebook.get(gpcUC3.Id).RE_ApprovalProcess__c;
                         pbdata.RE_Custom_Opp_Approve__c = oldpricebook.get(gpcUC3.Id).RE_Custom_Opp_Approve__c;
                         if(approvedStatus.contains(oldpricebook.get(gpcUC3.Id).RE_Custom_Opp_Approve__c))
                             pbdata.RE_Custom_Opp_Approve__c = 'Not Submitted';
                         pbdata.RE_Backstop_Margin__c = oldpricebook.get(gpcUC3.Id).RE_Backstop_Margin__c;
                         pbdata.RE_Excise_tax__c = oldpricebook.get(gpcUC3.Id).RE_Excise_tax__c;
                        // pbdata.RE_Price_support__c = oldpricebook.get(gpcUC3.Id).RE_Price_support__c != null ? oldpricebook.get(gpcUC3.Id).RE_Price_support__c : 0.00;
                        if(RE_PH_AspriedUC3.generateMaindata && !isCBUjob && gpcUC3.RE_Reference_Period__c == 'M-1')
                            checkNotM_1data = false;
                    }
                     else{
                        
                         pbdata.RE_Excise_tax__c = Excisetax;
                         pbdata.RE_Final_Price_Rebate__c = (pbdata.RE_AutoCalRefAmntAdj__c + pbdata.RE_AutoCalRefAmnt__c).setScale(6) ;
                         pbdata.RE_Valid_From__c = gcpAdviseInputMap.containskey(gpcUC3.RE_Material_Code__c) ? gcpAdviseInputMap.get(gpcUC3.RE_Material_Code__c).RE_Start_Date__c : (isCBUjob ? System.today(): System.today().addDays(1));
                         pbdata.RE_Valid_To__c =   gcpAdviseInputMap.containskey(gpcUC3.RE_Material_Code__c) ? gcpAdviseInputMap.get(gpcUC3.RE_Material_Code__c).RE_End_Date__c  : date.valueOf(validTo);
                         pbdata.RE_Latest_price_dt__c = DateTime.now();
                         pbdata.RE_Backstop_Margin__c = RE_PH_AspriedUC3.backStopMargin.get(gpcUC3.RE_PH_Approval_Scheme__c);
                         
                        if(gpcUC3.RE_Reference_Period__c == 'M-1'){
                            pbdata.RE_Valid_From__c = firstDayOfMonth;
                            pbdata.RE_Valid_To__c = lastdatofMonth;
                        }
                        
                         //if(midweekgen)
                             //datachanged = true;
                         
                     }
                     pbdata.RE_D_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - pbdata.RE_Transport_Charge__c - (costdatalist.containsKey(keyCostPrice) ?  (costdatalist.get(keyCostPrice).D1Data != null ? costdatalist.get(keyCostPrice).D1Data : 0.0) : 0.0);
                     pbdata.RE_W_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - pbdata.RE_Transport_Charge__c - (costdatalist.containsKey(keyCostPrice) ? (costdatalist.get(keyCostPrice).W1Data != null ? costdatalist.get(keyCostPrice).W1Data : 0.0) : 0.0);
                     pbdata.RE_M_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - pbdata.RE_Transport_Charge__c - (costdatalist.containsKey(keyCostPrice) ? (costdatalist.get(keyCostPrice).M1Data != null ? costdatalist.get(keyCostPrice).M1Data : 0.0): 0.0);
                     pbdata.RE_WTD_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - pbdata.RE_Transport_Charge__c - (costdatalist.containsKey(keyCostPrice) ? (costdatalist.get(keyCostPrice).WTDData != null ? costdatalist.get(keyCostPrice).WTDData : 0.0) : 0.0);
                     pbdata.RE_MTD_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - pbdata.RE_Transport_Charge__c - (costdatalist.containsKey(keyCostPrice) ? (costdatalist.get(keyCostPrice).MTDData != null ? costdatalist.get(keyCostPrice).MTDData : 0.0) : 0.0);
                     pbdata.RE_Reference_Price__c = reference_PeriodValue;
                     pbdata.RE_Reference_Period__c = marginCheck;
                     Double marginValue = double.valueof(pbdata.get(marginCheck)); 
                     pbdata.RE_RefUC3_Price__c = marginValue;
                     if(pbdata.RE_Final_Price_Rebate__c <= 0)
                        pbdata.RE_Custom_Opp_Approve__c = 'Rejected';
                     //if( (!midweekgen && !oldpricebook.containsKey(gpcUC3.Id)) || (midweekgen && datachanged))
                     if( !oldpricebook.containsKey(gpcUC3.Id)){                                        
                         pricebookList.add(RE_PH_AspriedUC3.updateApprovalScheme(pbdata , gpcUC3.RE_PH_Approval_Scheme__c ,marginValue)); 
                         //datachanged= false;
                     }
                     else{
                        if(checkNotM_1data)
                            pricebookList.add(pbdata);                                                              
                     }
                     
                 }
        }
        //System.debug('pricebookList--'+pricebookList);
        Upsert pricebookList;  
    }
    
     @AuraEnabled
    public Static boolean midWeekgpcdatagene(){
        
        boolean recordCount;
        List<RE_Pricing_Input__c> gpcDatatoday = new List<RE_Pricing_Input__c>();
        gpcDatatoday = [SELECT RE_Plant__c,RE_PlantDesc__c,RE_Material__c,RE_FixedPrice__c,RE_Start_Date__c,RE_End_Date__c,RE_Type__c
                        FROM RE_Pricing_Input__c
                        WHERE RE_Is_latest__c = true
                        AND RE_Type__c = 'GPC' ];
        
        if(gpcDatatoday.size() > 0) {           
            //midweekgen = true;
            //creategpc(true); 
            midweekGPC();
            recordCount = true;
        } 
        else{
          recordCount = false;
        }
        
        return recordCount;  
    }

    public static void midweekGPC(){
        midweekgen = true;
        //If record is not approved : new record status will be Not Submitted
        List<String> approvedStatus = new List<String>{'Submitted STL','Support STL','Support PM'};
        //PH Excise Sales tax
        exciseTax = RE_PH_AspriedUC3.exciseTaxList();
        //Create CBU Map
        costdatalist = RE_PH_AspriedUC3.phCBUdata(true);
        //Create Approval Scheme Map
        RE_PH_AspriedUC3.approvalscheme = RE_PH_AspriedUC3.approvalScheme();
        // Fetching the GPC Amnt
        gcpPricingInput(true);
        // Fetching the net price
        getnetpriceInput(); 
        //created oldGPC values
        createOldGPCpbData();

        Map<String , List<RE_Pricing_Input__c>> midweekGPC = new Map<String , List<RE_Pricing_Input__c>>();
        Map<id,RE_Pricing_Input__c> procesGPC = new map<id,RE_Pricing_Input__c>();
        //get latest GPC values
        for(RE_Pricing_Input__c gpc :[SELECT id,RE_GPCAmnt__c,RE_Plant__c,RE_PlantDesc__c,RE_Material__c,RE_FixedPrice__c,RE_Start_Date__c,RE_End_Date__c,RE_Type__c
        FROM RE_Pricing_Input__c
        WHERE RE_Type__c = 'GPC' AND RE_Is_latest__c = true] ){ 
           List<RE_Pricing_Input__c> temGPC = new List<RE_Pricing_Input__c>();
          
           if(midweekGPC.containskey(gpc.RE_Material__c))              
                temGPC = midweekGPC.get(gpc.RE_Material__c);

                temGPC.add(gpc);
               midweekGPC.put(gpc.RE_Material__c,temGPC);                         
           }

          

        List<RT_Price_Book__c> pricebookListMidWeek = new List<RT_Price_Book__c>();
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
        for(REV_Contract_Master__c gpcUC3 :[ 
           Select id ,RE_Ship_To_Number__c,RE_Sold_To_Number__c,RE_Rebate__c,RE_Material_Code__c,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,RT_Plant_Code__c,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,RE_Customer_Name__r.AccountNumber ,Country_Name__c,RE_Customer_Name__c,RT_Material_Desc__c,RT_Plant_Desc__c,RE_Secondary_Transport_Cost__c, RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name,RE_Aspired_Margin__c
           , RT_Plant_Desc__r.RE_Location_Code__c,RT_Material_Desc__r.RE_Material__c,RE_Prev_Week_Price__c from REV_Contract_Master__c where  Country_Name__c = 'PH' AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today AND RE_Calculation_Type__c = 'GPC' AND Active__c = true AND RE_Reference_Period__c != 'M-1' 
        ] ){
            RT_Price_Book__c pbdata = new RT_Price_Book__c();
            String keyContract = gpcUC3.RE_Sold_To_Number__c+'_'+gpcUC3.RE_Ship_To_Number__c+ '_' +gpcUC3.RE_Material_Code__c+ '_' + gpcUC3.RT_Plant_Desc__r.Name;
            String keyCostPrice = gpcUC3.RT_Material_Desc__r.Name+ '_' + gpcUC3.RT_Plant_Desc__r.Name; 
            pbdata.recordtypeId = pricebookrectypeid;
            pbdata.RT_Country__c = gpcUC3.Country_Name__c;
            pbdata.RE_Contract_Master__c = gpcUC3.id;
            pbdata.RE_Customer_Name__c = gpcUC3.RE_Customer_Name__c;	
            pbdata.RT_Product__c = gpcUC3.RT_Material_Desc__c;
            pbdata.RT_Location__c = gpcUC3.RT_Plant_Desc__c;
            pbdata.RE_Rebate__c = gpcUC3.RE_Rebate__c != null ? gpcUC3.RE_Rebate__c : 0.0  ;
            pbdata.RE_Is_Latest__c = True;
            pbdata.RE_Job_Counter__c = 0;  
            pbdata.RE_CBU_valid_from__c = system.today();

            if( !midweekGPC.isEmpty() && midweekGPC.containsKey(gpcUC3.RE_Material_Code__c)){
                for(RE_Pricing_Input__c newGPCValues : midweekGPC.get(gpcUC3.RE_Material_Code__c)){
                    
                    RT_Price_Book__c tempPdData = new RT_Price_Book__c();
                    tempPdData = updatePBdata(pbdata,newGPCValues,gpcUC3);
                   
                    pricebookListMidWeek.add(tempPdData.clone(false, true, false, false));
                    newGPCValues.RE_Is_latest__c = false;
                    if(!procesGPC.containsKey(newGPCValues.id))
                        procesGPC.put(newGPCValues.id,newGPCValues);
                }
            }
          
        }
        system.debug('pd data'+pricebookListMidWeek);
        if(!procesGPC.isEmpty())
            update procesGPC.values();
        if(!pricebookListMidWeek.isEmpty())
            insert pricebookListMidWeek;       
        
    }

    public static RT_Price_Book__c updatePBdata(RT_Price_Book__c pbdata, RE_Pricing_Input__c gpc,REV_Contract_Master__c gpcCOntracts){
        double Excisetax = exciseTax.containsKey(gpcCOntracts.RT_Material_Desc__r.RE_Product_Group__c) ? exciseTax.get(gpcCOntracts.RT_Material_Desc__r.RE_Product_Group__c) : 0.0;
        double reference_PeriodValue ;
        double secondTf = gpcCOntracts.RE_Secondary_Transport_Cost__c != null ? gpcCOntracts.RE_Secondary_Transport_Cost__c : 0.0;

        String keyContract = gpcCOntracts.RE_Sold_To_Number__c+'_'+gpcCOntracts.RE_Ship_To_Number__c+ '_' +gpcCOntracts.RE_Material_Code__c+ '_' + gpcCOntracts.RT_Plant_Desc__r.Name;
        String keyCostPrice = gpcCOntracts.RT_Material_Desc__r.Name+ '_' + gpcCOntracts.RT_Plant_Desc__r.Name;

        String marginCheck = 'RE_W_1_UC3__c';
                     
        if(costdatalist.containsKey(keyCostPrice)){
            switch on gpcCOntracts.RE_Reference_Period__c {
                when 'D-1' {
                    reference_PeriodValue = costdatalist.get(keyCostPrice).D1Data;
                    marginCheck = 'RE_D_1_UC3__c';
                }
                when 'W-1' {		
                    reference_PeriodValue = costdatalist.get(keyCostPrice).W1Data;
                    marginCheck = 'RE_W_1_UC3__c';
                }
                when 'M-1' {		
                    reference_PeriodValue = costdatalist.get(keyCostPrice).M1Data;
                    marginCheck = 'RE_M_1_UC3__c';
                }
                when 'WTD' {		
                    reference_PeriodValue = costdatalist.get(keyCostPrice).WTDData;
                    marginCheck = 'RE_WTD_UC3__c';
                }
                when 'MTD' {		
                    reference_PeriodValue = costdatalist.get(keyCostPrice).MTDData;
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
            //datetime validTo = RE_PH_AspriedUC3.getValidTo();
            pbdata.RE_Price_support__c =  0.00;
            if( gpcCOntracts.RE_PS_valid_to__c != null && gpcCOntracts.RE_PS_valid_to__c >= date.today()){
                pbdata.RE_Price_support__c = gpcCOntracts.RE_Price_support__c != null ? gpcCOntracts.RE_Price_support__c : 0.00;                           
            }

            pbdata.RE_AutoCalRefAmnt__c = oldpricebookGPCdata.containsKey(keyContract) ? oldpricebookGPCdata.get(keyContract).RE_Final_Price_Rebate__c : (gpcCOntracts.RE_Prev_Week_Price__c > 0 ? gpcCOntracts.RE_Prev_Week_Price__c : 0.0) ;
            pbdata.RE_AutoCalRefAmntAdj__c = gpc.RE_GPCAmnt__c != null ? gpc.RE_GPCAmnt__c : 0.0; 

            pbdata.RE_Final_Price_Rebate__c = (pbdata.RE_AutoCalRefAmnt__c + pbdata.RE_AutoCalRefAmntAdj__c).setScale(6);
            pbdata.RE_Excise_tax__c = Excisetax;
            //follow RPG valid from and valid to same as RPG data file
            pbdata.RE_Valid_From__c = gpc.RE_Start_Date__c != null ? gpc.RE_Start_Date__c :  System.today();
            pbdata.RE_Valid_To__c =   gpc.RE_End_Date__c != null ? gpc.RE_End_Date__c  : date.valueOf(validTo);
            pbdata.RE_Latest_price_dt__c = DateTime.now();
            pbdata.RE_Custom_Opp_Approve__c = 'Auto Approved';
            pbdata.RE_Backstop_Margin__c = RE_PH_AspriedUC3.backStopMargin.get(gpcCOntracts.RE_PH_Approval_Scheme__c);

            pbdata.RE_D_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalist.containsKey(keyCostPrice) ? (costdatalist.get(keyCostPrice).D1Data != null ? costdatalist.get(keyCostPrice).D1Data : 0.0) : 0.0);
            pbdata.RE_W_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalist.containsKey(keyCostPrice) ? (costdatalist.get(keyCostPrice).W1Data != null ? costdatalist.get(keyCostPrice).W1Data : 0.0) : 0.0);
            pbdata.RE_M_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalist.containsKey(keyCostPrice) ? (costdatalist.get(keyCostPrice).M1Data != null ? costdatalist.get(keyCostPrice).M1Data : 0.0) : 0.0);
            pbdata.RE_WTD_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalist.containsKey(keyCostPrice) ? (costdatalist.get(keyCostPrice).WTDData != null ? costdatalist.get(keyCostPrice).WTDData : 0.0) : 0.0);
            pbdata.RE_MTD_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalist.containsKey(keyCostPrice) ? (costdatalist.get(keyCostPrice).MTDData != null ? costdatalist.get(keyCostPrice).MTDData : 0.0) : 0.0);
            
            pbdata.RE_Reference_Price__c = reference_PeriodValue;
            pbdata.RE_Reference_Period__c = marginCheck;    
            Double marginValue = double.valueof(pbdata.get(marginCheck));
            pbdata.RE_RefUC3_Price__c = marginValue;
            if(pbdata.RE_Final_Price_Rebate__c <= 0)
                pbdata.RE_Custom_Opp_Approve__c = 'Rejected';
            //check Approval status
            return RE_PH_AspriedUC3.updateApprovalScheme(pbdata , gpcCOntracts.RE_PH_Approval_Scheme__c ,marginValue);
        
    }

    public static void createOldGPCpbData(){
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
        for(RT_Price_Book__c pbdadta : [
            SELECT Id,RT_Country__c,RE_Sold_To_Number__c,RE_Ship_To_Number__c,RE_Material_Code__c,RT_Location__r.Name,RE_Contract_Master__c,RE_Price_support__c,RE_Custom_Opp_Approve__c,RE_ApprovalProcess__c,RE_Latest_price_dt__c,RE_Customer_Name__c,RT_Product__c,RT_Location__c,RE_Final_Price_Rebate__c,RE_Valid_From__c,RE_Valid_To__c ,RE_Is_Latest__c,RE_CBU_Last_offered__c,RE_CBU_valid_To__c,
            RE_D_1_UC3__c,RE_W_1_UC3__c,RE_M_1_UC3__c,RE_Backstop_Margin__c,RE_AutoCalRefAmnt__c,RE_AutoCalRefAmntAdj__c,RE_Excise_tax__c FROM RT_Price_Book__c where RE_Is_Latest__c = True AND RE_Contract_Master__r.RE_Calculation_Type__c = 'GPC' AND recordtypeId =:pricebookrectypeid order by RE_Latest_price_dt__c desc]){
                String keypriceBook = pbdadta.RE_Sold_To_Number__c+'_'+pbdadta.RE_Ship_To_Number__c+'_'+pbdadta.RE_Material_Code__c+'_'+pbdadta.RT_Location__r.Name;
                if(!oldpricebookGPCdata.containskey(keypriceBook) && pbdadta.RE_Valid_To__c >= system.today() && pbdadta.RE_Valid_From__c <= system.today()){
                    oldpricebookGPCdata.put(keypriceBook,pbdadta);
                }
            } 
    }
}