public class RE_PH_RPG {
    //Get Active Contract List
    Public Static Map<String,REV_Contract_Master__c> contractMap = RE_SOQLController.fetchPHActiveContracts('PH','Revolution PH');
    //Get RPG Pricing Input data
    public Static Map<String,RE_Pricing_Input__c> rpgMap = new Map<String,RE_Pricing_Input__c>();
    //Get Tier Input data
    public Static Map<String,RE_Pricing_Input__c> tierMap = new Map<String,RE_Pricing_Input__c>();
    
    //Midweek data generation boolean variables
    public static boolean midweekgen= false , datachanged = false;
    
    Public Static Map<String , Double > exciseTax = New Map<String , Double>();
    Public Static Map<String,RE_PH_OutputController.costDataWrapper> costdatalistvalues = new Map<String,RE_PH_OutputController.costDataWrapper>();
    //Public Static Map<String , Map< String , RT_Setting__c >> approvalscheme = new Map<String , Map< String , RT_Setting__c>>();
    
    //Morning CBU data
    public Static Map<String,RE_MY_CostPrice__c> morningCBUMap = new Map<String,RE_MY_CostPrice__c>();
    //Midweek Price check
    public Static Map<Id,RT_Price_Book__c> oldpricebookdata = new Map<Id,RT_Price_Book__c> ();
    public static datetime validTo = RE_PH_AspriedUC3.getValidTo();
    
    public Static Map<String,RE_Pricing_Input__c> fetchRPGdata(boolean isCBUjob){
       // Map<String,RE_Pricing_Input__c> rpgMap = new Map<String,RE_Pricing_Input__c>();
       List<RE_Pricing_Input__c> rpgData = new List<RE_Pricing_Input__c>();
        if(isCBUjob)
            rpgData = [SELECT id,RE_Plant__c,RE_PlantDesc__c,RE_Material__c,RE_FixedPrice__c,RE_Start_Date__c,RE_End_Date__c,RE_Type__c
                       FROM RE_Pricing_Input__c
                       WHERE RE_Type__c = 'RPG'
                       AND RE_Start_Date__c <= Today
                       AND RE_End_Date__c >= Today order by createddate desc];
        else 
            rpgData = [SELECT id,RE_Plant__c,RE_PlantDesc__c,RE_Material__c,RE_FixedPrice__c,RE_Start_Date__c,RE_End_Date__c,RE_Type__c
                       FROM RE_Pricing_Input__c
                       WHERE RE_Type__c = 'RPG'
                       AND RE_Start_Date__c <= Tomorrow
                       AND RE_End_Date__c >= Tomorrow order by createddate desc];
        
        for(RE_Pricing_Input__c rpg :rpgData){ 
            rpg.RE_Is_latest__c = false;
            if(!rpgMap.containskey(rpg.RE_Plant__c+'_'+rpg.RE_Material__c))
                rpgMap.put(rpg.RE_Plant__c+'_'+rpg.RE_Material__c,rpg);            
        }
        system.debug('list size-'+rpgData.size());
        if(!rpgData.isEmpty() && !midweekgen)
            update rpgData;
        return rpgMap;
    }
    
    public Static Map<String,RE_Pricing_Input__c> fetchTierdata(){
        for(RE_Pricing_Input__c rpgtier : [
            SELECT id,RE_ShipTo__c,RE_SoldTo__c,RE_Type__c,RE_Material__c,RE_Plant__c,RE_TierAmnt__c,RE_CurrentCnfgTierAmnt__c,RE_IsConfig__c,RE_IsDifferent__c
            FROM RE_Pricing_Input__c
            WHERE RE_Type__c = 'Tier' AND RE_Is_latest__c = true
            AND RE_IsConfig__c = True order by createddate desc
        ]){
            if(!tierMap.containsKey(rpgtier.RE_Plant__c+'_'+rpgtier.RE_Material__c+'_'+rpgtier.RE_ShipTo__c+'_'+rpgtier.RE_SoldTo__c))
                tierMap.put(rpgtier.RE_Plant__c+'_'+rpgtier.RE_Material__c+'_'+rpgtier.RE_ShipTo__c+'_'+rpgtier.RE_SoldTo__c,rpgtier);
           
        }
       system.debug('list size-'+tierMap.size());
        return tierMap;
    }
    
    public Static void calculateRPGContract(boolean isCBUjob){
         //If record is not approved : new record status will be Not Submitted
        List<String> approvedStatus = new List<String>{'Submitted STL','Support STL','Support PM'};
        //PH Excise Sales tax
        exciseTax = RE_PH_AspriedUC3.exciseTaxList();
        //Create CBU Map
        costdatalistvalues = RE_PH_AspriedUC3.phCBUdata(true);
        fetchTierdata();
        fetchRPGdata(isCBUjob);
        //Create Approval Scheme Map
        RE_PH_AspriedUC3.approvalscheme = RE_PH_AspriedUC3.approvalScheme();
        //Valid To (till next week monday)
        //datetime validTo = RE_PH_AspriedUC3.getValidTo();
        date firstDayOfMonth = RE_PH_AspriedUC3.firstDayOfMonth , lastdatofMonth = RE_PH_AspriedUC3.lastdatofMonth;
        boolean checkNotM_1data = true;
        List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
        
        Map<Id,RT_Price_Book__c> oldpricebook = new Map<Id,RT_Price_Book__c> ();
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
        List<REV_Contract_Master__c> contratsData = new List<REV_Contract_Master__c>();
        if(isCBUjob){
            for(RT_Price_Book__c pbdadta : [
                SELECT Id,RT_Country__c,RE_Contract_Master__c,RE_Price_support__c,RE_Custom_Opp_Approve__c,RE_ApprovalProcess__c,RE_Latest_price_dt__c,RE_Customer_Name__c,RT_Product__c,RT_Location__c,RE_Final_Price_Rebate__c,RE_Valid_From__c,RE_Valid_To__c ,RE_Is_Latest__c,RE_CBU_Last_offered__c,RE_CBU_valid_To__c,
                RE_D_1_UC3__c,RE_W_1_UC3__c,RE_M_1_UC3__c,RE_Backstop_Margin__c,RE_AutoCalRefAmnt__c,RE_AutoCalRefAmntAdj__c,RE_Excise_tax__c FROM RT_Price_Book__c where RE_Is_Latest__c = True AND RE_Contract_Master__r.RE_Calculation_Type__c = 'RPG' AND recordtypeId =:pricebookrectypeid order by RE_Latest_price_dt__c desc]){
                    pbdadta.RE_Is_Latest__c = false;
                    //pbdadta.RE_CBU_Last_offered__c = true;
                    pbdadta.RE_CBU_valid_To__c = system.today().addDays(-1);
                    if(!oldpricebook.containskey(pbdadta.RE_Contract_Master__c) && pbdadta.RE_Valid_To__c >= system.today() && pbdadta.RE_Valid_From__c <= system.today()){
                        oldpricebook.put(pbdadta.RE_Contract_Master__c,pbdadta);
                        pricebookList.add(pbdadta);
                    } 
                    if(pbdadta.RE_Valid_To__c < system.today())
                        pricebookList.add(pbdadta);
                    //if(!midweekgen)
                      //  pricebookList.add(pbdadta);                
                }
                contratsData=[ Select id ,RE_Sold_To_Number__c,RE_Ship_To_Number__c,RE_Material_Code__c,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,RT_Plant_Code__c,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,RE_Customer_Name__r.AccountNumber ,Country_Name__c,RE_Customer_Name__c,RT_Material_Desc__c,RT_Plant_Desc__c,RE_Secondary_Transport_Cost__c, RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name,RE_Aspired_Margin__c
                , RT_Plant_Desc__r.RE_Location_Code__c,RT_Material_Desc__r.RE_Material__c from REV_Contract_Master__c where  Country_Name__c = 'PH' AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today AND RE_Calculation_Type__c = 'RPG' AND Active__c = true ];
        }
        else {
                contratsData=[ Select id ,RE_Sold_To_Number__c,RE_Ship_To_Number__c,RE_Material_Code__c,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,RT_Plant_Code__c,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,RE_Customer_Name__r.AccountNumber ,Country_Name__c,RE_Customer_Name__c,RT_Material_Desc__c,RT_Plant_Desc__c,RE_Secondary_Transport_Cost__c, RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name,RE_Aspired_Margin__c
                , RT_Plant_Desc__r.RE_Location_Code__c,RT_Material_Desc__r.RE_Material__c from REV_Contract_Master__c where  Country_Name__c = 'PH' AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today AND RE_Calculation_Type__c = 'RPG' AND Active__c = true  AND RE_Reference_Period__c != 'M-1'];
        
        }
        
        if(isCBUjob || (!isCBUjob && RE_PH_AspriedUC3.generateMaindata)){
            for(REV_Contract_Master__c rpgCOntracts :contratsData){
                checkNotM_1data = true;
                RT_Price_Book__c pbdata = new RT_Price_Book__c();
                String keyProDepo = rpgCOntracts.RT_Material_Desc__r.Name+ '_' + rpgCOntracts.RT_Plant_Desc__r.Name;
                String rpgValueKey = rpgCOntracts.RT_Plant_Desc__r.RE_Location_Code__c + '_' +rpgCOntracts.RT_Material_Desc__r.RE_Material__c;
                String tiervalueKey = rpgCOntracts.RT_Plant_Code__c + '_' +rpgCOntracts.RE_Material_Code__c +'_'+rpgCOntracts.RE_Ship_To_Number__c+'_'+rpgCOntracts.RE_Sold_To_Number__c;                                    
                
                pbdata.recordtypeId = pricebookrectypeid;
                pbdata.RT_Country__c = rpgCOntracts.Country_Name__c;
                pbdata.RE_Contract_Master__c = rpgCOntracts.id;
                pbdata.RE_Customer_Name__c = rpgCOntracts.RE_Customer_Name__c;	
                pbdata.RT_Product__c = rpgCOntracts.RT_Material_Desc__c;
                pbdata.RT_Location__c = rpgCOntracts.RT_Plant_Desc__c;
                pbdata.RE_Is_Latest__c = True;
                pbdata.RE_Job_Counter__c = 0;  
                pbdata.RE_CBU_valid_from__c = system.today();
                pbdata.RE_AutoCalRefAmnt__c = rpgMap.containskey(rpgValueKey) ? double.valueof(rpgMap.get(rpgValueKey).RE_FixedPrice__c) : 0.0;
                pbdata.RE_AutoCalRefAmntAdj__c =  tierMap.containskey(tiervalueKey) ? double.valueof(tierMap.get(tiervalueKey).RE_TierAmnt__c) : 0.0; 
                
                    
                double Excisetax = exciseTax.containsKey(rpgCOntracts.RT_Material_Desc__r.RE_Product_Group__c) ? exciseTax.get(rpgCOntracts.RT_Material_Desc__r.RE_Product_Group__c) : 0.0;
                double reference_PeriodValue ;
                double secondTf = rpgCOntracts.RE_Secondary_Transport_Cost__c != null ? rpgCOntracts.RE_Secondary_Transport_Cost__c : 0.0;
                pbdata.RE_Transport_Charge__c = secondTf;
                String marginCheck = 'RE_W_1_UC3__c';

                if(costdatalistvalues.containsKey(keyProDepo)){
                    switch on rpgCOntracts.RE_Reference_Period__c {
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
                if( rpgCOntracts.RE_PS_valid_to__c != null && rpgCOntracts.RE_PS_valid_to__c >= date.today()){
                    pbdata.RE_Price_support__c = rpgCOntracts.RE_Price_support__c != null ? rpgCOntracts.RE_Price_support__c : 0.00;                           
                }
                
                //checks price book record valid till tomorrow
                if(oldpricebook.containsKey(rpgCOntracts.Id) && (oldpricebook.get(rpgCOntracts.Id).RE_AutoCalRefAmnt__c == pbdata.RE_AutoCalRefAmnt__c) && (oldpricebook.get(rpgCOntracts.Id).RE_AutoCalRefAmntAdj__c == pbdata.RE_AutoCalRefAmntAdj__c) ){
                   
                    pbdata.RE_Final_Price_Rebate__c = oldpricebook.get(rpgCOntracts.Id).RE_Final_Price_Rebate__c;
                    pbdata.RE_Valid_From__c = oldpricebook.get(rpgCOntracts.Id).RE_Valid_From__c;
                    pbdata.RE_Valid_To__c =  oldpricebook.get(rpgCOntracts.Id).RE_Valid_To__c;
                    pbdata.RE_Latest_price_dt__c = oldpricebook.get(rpgCOntracts.Id).RE_Latest_price_dt__c.addMinutes(1);
                    pbdata.RE_ApprovalProcess__c = oldpricebook.get(rpgCOntracts.Id).RE_ApprovalProcess__c;
                    pbdata.RE_Custom_Opp_Approve__c = oldpricebook.get(rpgCOntracts.Id).RE_Custom_Opp_Approve__c;
                    if(approvedStatus.contains(oldpricebook.get(rpgCOntracts.Id).RE_Custom_Opp_Approve__c))
                        pbdata.RE_Custom_Opp_Approve__c = 'Not Submitted';
                    pbdata.RE_Backstop_Margin__c = oldpricebook.get(rpgCOntracts.Id).RE_Backstop_Margin__c;
                    pbdata.RE_Excise_tax__c = oldpricebook.get(rpgCOntracts.Id).RE_Excise_tax__c;
                    if(RE_PH_AspriedUC3.generateMaindata && !isCBUjob && rpgCOntracts.RE_Reference_Period__c == 'M-1')
                        checkNotM_1data = false;
                }
                else{                    
                    pbdata.RE_Final_Price_Rebate__c = (pbdata.RE_AutoCalRefAmnt__c + pbdata.RE_AutoCalRefAmntAdj__c).setScale(6);
                    pbdata.RE_Excise_tax__c = Excisetax;
                    //follow RPG valid from and valid to same as they upload
                    pbdata.RE_Valid_From__c = rpgMap.containskey(rpgValueKey) ? rpgMap.get(rpgValueKey).RE_Start_Date__c : (isCBUjob ? System.today(): System.today().addDays(1));
                    pbdata.RE_Valid_To__c =   rpgMap.containskey(rpgValueKey) ? rpgMap.get(rpgValueKey).RE_End_Date__c  : date.valueOf(validTo);
                    pbdata.RE_Latest_price_dt__c = DateTime.now();
                    pbdata.RE_Custom_Opp_Approve__c = 'Auto Approved';
                    pbdata.RE_Backstop_Margin__c = RE_PH_AspriedUC3.backStopMargin.get(rpgCOntracts.RE_PH_Approval_Scheme__c);
                  
                    if(rpgCOntracts.RE_Reference_Period__c == 'M-1'){
                        pbdata.RE_Valid_From__c = firstDayOfMonth;
                        pbdata.RE_Valid_To__c = lastdatofMonth;
                    }

                  // if(midweekgen)
                    //    datachanged = true;
                }                                         
               
                pbdata.RE_D_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).D1Data != null ? costdatalistvalues.get(keyProDepo).D1Data : 0.0) : 0.0);
                pbdata.RE_W_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).W1Data != null ? costdatalistvalues.get(keyProDepo).W1Data : 0.0) : 0.0);
                pbdata.RE_M_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? ( costdatalistvalues.get(keyProDepo).M1Data != null ? costdatalistvalues.get(keyProDepo).M1Data : 0.0) : 0.0);
                pbdata.RE_WTD_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).WTDData != null ? costdatalistvalues.get(keyProDepo).WTDData : 0.0) : 0.0);
                pbdata.RE_MTD_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).MTDData != null ? costdatalistvalues.get(keyProDepo).MTDData : 0.0) : 0.0);
                
                pbdata.RE_Reference_Price__c = reference_PeriodValue;
                pbdata.RE_Reference_Period__c = marginCheck;    
                Double marginValue = double.valueof(pbdata.get(marginCheck));
                pbdata.RE_RefUC3_Price__c = marginValue;
                if(pbdata.RE_Final_Price_Rebate__c <= 0)
                    pbdata.RE_Custom_Opp_Approve__c = 'Rejected';
                //if( (!midweekgen || (midweekgen && datachanged)) && checkNotM_1data){
                if(checkNotM_1data){
                    pricebookList.add(pbdata);                   
                }
            }
        }
        Upsert pricebookList;     
    }
    @AuraEnabled
    public Static Map<String,string > midWeekRgpdatagene(){
        
        boolean gpcdata = RE_PH_GPC_Calc.midWeekgpcdatagene();
        boolean rpgdata = false;
        
        Map<String,string > message= new Map<String,string>();
        List<RE_Pricing_Input__c> rpgDatatoday = new List<RE_Pricing_Input__c>();
        List<RE_Pricing_Input__c> tierDatatoday = new List<RE_Pricing_Input__c>();
        rpgDatatoday = [SELECT RE_Plant__c,RE_PlantDesc__c,RE_Material__c,RE_FixedPrice__c,RE_Start_Date__c,RE_End_Date__c,RE_Type__c
                        FROM RE_Pricing_Input__c
                        WHERE RE_Type__c IN ('RPG') AND  RE_Is_latest__c = true ];
        tierDatatoday = [SELECT RE_Plant__c,RE_PlantDesc__c,RE_Material__c,RE_FixedPrice__c,RE_Start_Date__c,RE_End_Date__c,RE_Type__c
                        FROM RE_Pricing_Input__c
                        WHERE RE_Type__c IN ('Tier') AND RE_Is_latest__c = true ];
        
        if(rpgDatatoday.size() > 0 || !tierDatatoday.isEmpty()) {
            //send error message to UI 
            message.put('Error','false');  
            if(gpcdata)
                message.put('message','Custom opps MidWeek data generated for GPC and RPG, please refresh the page');
            else
               message.put('message','Custom opps MidWeek data generated for RPG, please refresh the page'); 
            //midweekgen = true;
            //calculateRPGContract(true);
            midweekRPG(); 
        } 
        else{
            message.put('Error','True');  
            if(gpcdata)
                message.put('message','Custom opps MidWeek data generated for GPC, please refresh the page');
            else 
                 message.put('message','No new records found in Pricing Input');
        }
        
        
        return message;  
    }

    public static void midweekRPG(){
        //PH Excise Sales tax
        exciseTax = RE_PH_AspriedUC3.exciseTaxList();
        //Create CBU Map
        costdatalistvalues = RE_PH_AspriedUC3.phCBUdata(true);
        midweekgen= true;
        //get tier
        fetchTierdata();
        fetchRPGdata(true);
        createOldPBdata();
         Map<String , List<RE_Pricing_Input__c>> midweekRPG = new Map<String , List<RE_Pricing_Input__c>>();
         Map<id,RE_Pricing_Input__c> processRPG = new Map<id,RE_Pricing_Input__c>();
        //get latest RPG values
        for(RE_Pricing_Input__c rpg :[SELECT id,RE_Plant__c,RE_PlantDesc__c,RE_Material__c,RE_FixedPrice__c,RE_Start_Date__c,RE_End_Date__c,RE_Type__c
        FROM RE_Pricing_Input__c
        WHERE RE_Type__c = 'RPG' AND RE_Is_latest__c = true] ){ 
            List<RE_Pricing_Input__c> temRPG = new List<RE_Pricing_Input__c>();
            if(midweekRPG.containskey(rpg.RE_Plant__c+'_'+rpg.RE_Material__c))              
                temRPG = midweekRPG.get(rpg.RE_Plant__c+'_'+rpg.RE_Material__c);

                temRPG.add(rpg);
                midweekRPG.put(rpg.RE_Plant__c+'_'+rpg.RE_Material__c,temRPG);                         
            }

        List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
        for(REV_Contract_Master__c rpgCOntracts :[ 
            Select id ,RE_Ship_To_Number__c,RE_Sold_To_Number__c,RE_Material_Code__c,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,RT_Plant_Code__c,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,RE_Customer_Name__r.AccountNumber ,Country_Name__c,RE_Customer_Name__c,RT_Material_Desc__c,RT_Plant_Desc__c,RE_Secondary_Transport_Cost__c, RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name,RE_Aspired_Margin__c
            , RT_Plant_Desc__r.RE_Location_Code__c,RT_Material_Desc__r.RE_Material__c from REV_Contract_Master__c where  Country_Name__c = 'PH' AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today AND RE_Calculation_Type__c = 'RPG' AND Active__c = true AND RE_Reference_Period__c != 'M-1'
        ] ){

            RT_Price_Book__c pbdata = new RT_Price_Book__c();
            String keyProDepo = rpgCOntracts.RT_Material_Desc__r.Name+ '_' + rpgCOntracts.RT_Plant_Desc__r.Name;
            String rpgValueKey = rpgCOntracts.RT_Plant_Desc__r.RE_Location_Code__c + '_' +rpgCOntracts.RT_Material_Desc__r.RE_Material__c;
            String tiervalueKey = rpgCOntracts.RT_Plant_Code__c + '_' +rpgCOntracts.RE_Material_Code__c +'_'+rpgCOntracts.RE_Ship_To_Number__c+'_'+rpgCOntracts.RE_Sold_To_Number__c;   
            
            pbdata.recordtypeId = pricebookrectypeid;
            pbdata.RT_Country__c = rpgCOntracts.Country_Name__c;
            pbdata.RE_Contract_Master__c = rpgCOntracts.id;
            pbdata.RE_Customer_Name__c = rpgCOntracts.RE_Customer_Name__c;	
            pbdata.RT_Product__c = rpgCOntracts.RT_Material_Desc__c;
            pbdata.RT_Location__c = rpgCOntracts.RT_Plant_Desc__c;
            pbdata.RE_Is_Latest__c = True;
            pbdata.RE_Job_Counter__c = 0;  
            pbdata.RE_CBU_valid_from__c = system.today();
                    
            //system.debug('data key'+rpgValueKey);
            //system.debug('data values'+midweekRPG);
            if( !midweekRPG.isEmpty() && midweekRPG.containsKey(rpgValueKey)){
                for(RE_Pricing_Input__c newRPGValues : midweekRPG.get(rpgValueKey)){
                    RT_Price_Book__c tempPdData = new RT_Price_Book__c();
                    tempPdData = updatePBdata(pbdata,newRPGValues,rpgCOntracts);
                   
                    pricebookList.add(tempPdData.clone(false, true, false, false));
                    
                    newRPGValues.RE_Is_latest__c = false;
                    
                    if(!processRPG.containskey(newRPGValues.id))
                        processRPG.put(newRPGValues.id,newRPGValues);
                }
            }
            else{
                RT_Price_Book__c newTierPD = new RT_Price_Book__c();
                
                if(rpgMap.containskey(rpgValueKey))
                    
                    newTierPD = updatePBdata(pbdata,rpgMap.get(rpgValueKey),rpgCOntracts);
                   
                if(oldpricebookdata.containsKey(rpgCOntracts.Id)  && newTierPD.RE_AutoCalRefAmnt__c != null && newTierPD.RE_AutoCalRefAmntAdj__c!= null && oldpricebookdata.get(rpgCOntracts.Id).RE_AutoCalRefAmnt__c != null &&
                    oldpricebookdata .get(rpgCOntracts.Id).RE_AutoCalRefAmntAdj__c != null && ((oldpricebookdata.get(rpgCOntracts.Id).RE_AutoCalRefAmnt__c != newTierPD.RE_AutoCalRefAmnt__c) || (oldpricebookdata .get(rpgCOntracts.Id).RE_AutoCalRefAmntAdj__c != newTierPD.RE_AutoCalRefAmntAdj__c))){
                    pricebookList.add(newTierPD);
                   
                }
            }
        }
        if(!processRPG.isEmpty())
            update processRPG.values();
        system.debug('size of records--'+pricebookList.size());
        if(!pricebookList.isEmpty())
            insert pricebookList;
    }

    public static RT_Price_Book__c updatePBdata(RT_Price_Book__c pbdata, RE_Pricing_Input__c rpg,REV_Contract_Master__c rpgCOntracts){

        double Excisetax = exciseTax.containsKey(rpgCOntracts.RT_Material_Desc__r.RE_Product_Group__c) ? exciseTax.get(rpgCOntracts.RT_Material_Desc__r.RE_Product_Group__c) : 0.0;
        double reference_PeriodValue ;
        double secondTf = rpgCOntracts.RE_Secondary_Transport_Cost__c != null ? rpgCOntracts.RE_Secondary_Transport_Cost__c : 0.0;
        pbdata.RE_Transport_Charge__c = secondTf;
        String keyProDepo = rpgCOntracts.RT_Material_Desc__r.Name+ '_' + rpgCOntracts.RT_Plant_Desc__r.Name;
        String rpgValueKey = rpgCOntracts.RT_Plant_Desc__r.RE_Location_Code__c + '_' +rpgCOntracts.RT_Material_Desc__r.RE_Material__c;
        String tiervalueKey = rpgCOntracts.RT_Plant_Code__c + '_' +rpgCOntracts.RE_Material_Code__c +'_'+rpgCOntracts.RE_Ship_To_Number__c+'_'+rpgCOntracts.RE_Sold_To_Number__c;  

        String marginCheck = 'RE_W_1_UC3__c';

        if(costdatalistvalues.containsKey(keyProDepo)){
            switch on rpgCOntracts.RE_Reference_Period__c {
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
            if( rpgCOntracts.RE_PS_valid_to__c != null && rpgCOntracts.RE_PS_valid_to__c >= date.today()){
                pbdata.RE_Price_support__c = rpgCOntracts.RE_Price_support__c != null ? rpgCOntracts.RE_Price_support__c : 0.00;                           
            }
           
       
        //datetime validTo = RE_PH_AspriedUC3.getValidTo();
        pbdata.RE_AutoCalRefAmnt__c = rpg.RE_FixedPrice__c != null ? double.valueof(rpg.RE_FixedPrice__c) : 0.0;
        pbdata.RE_AutoCalRefAmntAdj__c =  (tierMap.containskey(tiervalueKey) && tierMap.get(tiervalueKey).RE_TierAmnt__c != null) ? double.valueof(tierMap.get(tiervalueKey).RE_TierAmnt__c) : 0.0;         
        
        pbdata.RE_Final_Price_Rebate__c = (pbdata.RE_AutoCalRefAmnt__c + pbdata.RE_AutoCalRefAmntAdj__c).setScale(6);
        pbdata.RE_Excise_tax__c = Excisetax;
        //follow RPG valid from and valid to same as RPG data file
        pbdata.RE_Valid_From__c = rpg.RE_Start_Date__c != null ? rpg.RE_Start_Date__c :  System.today();
        pbdata.RE_Valid_To__c =   rpg.RE_End_Date__c != null ? rpg.RE_End_Date__c  : date.valueOf(validTo);
        pbdata.RE_Latest_price_dt__c = DateTime.now();
        pbdata.RE_Custom_Opp_Approve__c = 'Auto Approved';
        pbdata.RE_Backstop_Margin__c = RE_PH_AspriedUC3.backStopMargin.get(rpgCOntracts.RE_PH_Approval_Scheme__c);

        pbdata.RE_D_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).D1Data != null ? costdatalistvalues.get(keyProDepo).D1Data : 0.0) : 0.0);
        pbdata.RE_W_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).W1Data != null ? costdatalistvalues.get(keyProDepo).W1Data : 0.0) : 0.0);
        pbdata.RE_M_1_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? ( costdatalistvalues.get(keyProDepo).M1Data != null ? costdatalistvalues.get(keyProDepo).M1Data : 0.0) : 0.0);
        pbdata.RE_WTD_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).WTDData != null ? costdatalistvalues.get(keyProDepo).WTDData : 0.0) : 0.0);
        pbdata.RE_MTD_UC3__c = pbdata.RE_Price_support__c + pbdata.RE_Final_Price_Rebate__c - Excisetax - secondTf - (costdatalistvalues.containsKey(keyProDepo) ? (costdatalistvalues.get(keyProDepo).MTDData != null ? costdatalistvalues.get(keyProDepo).MTDData : 0.0) : 0.0);
        
        pbdata.RE_Reference_Price__c = reference_PeriodValue;
        pbdata.RE_Reference_Period__c = marginCheck;    
        Double marginValue = double.valueof(pbdata.get(marginCheck));
        pbdata.RE_RefUC3_Price__c = marginValue;
        if(pbdata.RE_Final_Price_Rebate__c <= 0)
            pbdata.RE_Custom_Opp_Approve__c = 'Rejected';
        

        return pbdata;
    }

    public static void createOldPBdata(){
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
        for(RT_Price_Book__c pbdadta : [
            SELECT Id,RT_Country__c,RE_Contract_Master__c,RE_Price_support__c,RE_Custom_Opp_Approve__c,RE_ApprovalProcess__c,RE_Latest_price_dt__c,RE_Customer_Name__c,RT_Product__c,RT_Location__c,RE_Final_Price_Rebate__c,RE_Valid_From__c,RE_Valid_To__c ,RE_Is_Latest__c,RE_CBU_Last_offered__c,RE_CBU_valid_To__c,
            RE_D_1_UC3__c,RE_W_1_UC3__c,RE_M_1_UC3__c,RE_Backstop_Margin__c,RE_AutoCalRefAmnt__c,RE_AutoCalRefAmntAdj__c,RE_Excise_tax__c FROM RT_Price_Book__c where RE_Valid_From__c  <= TODAY AND RE_Valid_To__c >= Today AND RE_Is_Latest__c = True AND RE_Contract_Master__r.RE_Calculation_Type__c = 'RPG' AND recordtypeId =:pricebookrectypeid order by RE_Latest_price_dt__c desc]){
               
                if(!oldpricebookdata.containskey(pbdadta.RE_Contract_Master__c)){
                    oldpricebookdata.put(pbdadta.RE_Contract_Master__c,pbdadta);
                }
            } 
    }
}