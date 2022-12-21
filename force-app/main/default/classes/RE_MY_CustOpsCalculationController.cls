public class RE_MY_CustOpsCalculationController {                    
    RE_SOQLController soqldata = new RE_SOQLController();
    //Get Active Contract List reseller
    Public Static List<REV_Contract_Master__c> contractList = RE_SOQLController.fetchActiveContracts('Reseller');
    //Get Active Contract List Direct
    Public Static List<REV_Contract_Master__c> contractListDirect = RE_SOQLController.fetchActiveContracts('Direct'); 
    
    //Get Malaysia MOA data
    public Static List<RE_MOA__c> moaList = RE_SOQLController.fetchAMVoutputdata();
    public Static Map<String,RE_MOA__c> todayMOAMap = new Map<String,RE_MOA__c>();
    public Static Map<String,RE_MOA__c> CBUDateMOAMap = new Map<String,RE_MOA__c>();
    public Static map<String ,RT_Setting__c> IntradayPricing = new map<String ,RT_Setting__c>();
    public Static Map<String,Double> resllerlistpriceMap = new Map<String,Double>();
    
    //Direct List price from MOA object
    public Static Map<String , RE_MOA__c> directListCurrentWeek = RE_MY_AMVCalculationController.getMOAmap(true);
    public Static Map<String , RE_MOA__c> directListNextWeek = RE_MY_AMVCalculationController.getMOAmap(false);
    
    //yesterday final price
    public Static Map<string,decimal> yesterdayPrice= new  Map<string,decimal>();
    //Morning CBU data
    public Static Map<String,RE_MY_CostPrice__c> morningCBUMap = new Map<String,RE_MY_CostPrice__c>();
    //Afternoon Indiaction
    public Static Double afternoonIndication;
    public Static Map<String,Double> afternoonIndicationMap = New Map<String,Double>();
    
    //Malaysia Holiday list
    public static List<String> holidaysDate= new List<String>(myHolidaylist());
    
    //Records which exculed while updating CBU values
    public static  List<String> recordStatus = new List<String>{'Not Submitted','Support PM','Submitted PM','Rejected'};
    
    public Static integer resllerFreqnumber;
    public Static boolean generateDirectPB = false;
    Public Static String ErrorMsg='';
    Public Static date validFromFqTwo,ValidTofqTwo , validFromWed , validTowed;    
    
    //Creating Map of List Price, MC and LDC
    public Static void createListPrice(){
        //Todays List price for reseller customer (data from Landing page AMV )
        for(RE_MOA__c moadata : moaList){
            todayMOAMap.put(moadata.RE_Depot_Name__r.Name+'_'+moadata.RE_Product__r.Name, moadata);
        }
        //Addtional cost and Relevant product map
        for(RT_Setting__c intraDay : RE_SOQLController.fetchIntraDayprcing()){        
            IntradayPricing.put(intraDay.RE_Location__r.name + '_'+ intraDay.RE_Product__r.Name + '_' + intraDay.RE_Sales_Org__c ,intraDay);
        }
       
    }
    
    //Generate daily customer opps record.
    Public static void generateDailyData(RE_Job_Run_Audit__c jra){
        try{
            afternoonIndication = RE_SOQLController.fetchAfternoonIndication();
            afternoonIndicationMap = RE_SOQLController.fetchAfternoonIndicationMap();
            createListPrice();
            //created valid from and valid to for tomorrow records 
            getResellerfrequency();
            //Generate records for Reseller customer
            generateReseller(contractList);
            //Generate records for Direct customer
            generateDirectdata(contractListDirect);
            
            //Direct customer with two days frequency
            checkTwodaysFreq();
            //Direct as Reseller customer Daily record generation
            generateDirectDaily(contractListDirect);
            //Generate frequency record for Direct customer
            if(generateDirectPB)
                genDirectdataOnFreqday();
            
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
    //Generate customer opps record when new customer is added.
    Public static void newPriceBookToMidDay(RE_Job_Run_Audit__c jra){        
        try{
            afternoonIndication = RE_SOQLController.fetchAfternoonIndication();
            afternoonIndicationMap = RE_SOQLController.fetchAfternoonIndicationMap();
            getResellerfrequency();
            createListPrice();
            //Get Reseller new contracts
            List<REV_Contract_Master__c> newcontractListreseller = RE_SOQLController.fetchNewContracts('Reseller');
            if(newcontractListreseller.size() > 0)
                generateReseller(newcontractListreseller);
            //Get Direct new contracts
            List<REV_Contract_Master__c> newcontractListDirect = RE_SOQLController.fetchNewContracts('Direct'); 
            if(newcontractListDirect.size() > 0){
                //For 4 type of calculation logic
                generateDirectdata(newcontractListDirect);
                //For daily data generation calculation logic
                generateDirectDaily(contractListDirect);
            }            
            jra.RE_IsSuccess__c = True;
            jra.RE_Exception__c = '';
            update jra;
        }
        catch(Exception e){
            system.debug('---getStackTraceString '+e.getStackTraceString());            
            system.debug('---getCause '+e);
            jra.RE_IsSuccess__c = false;
            jra.RE_Exception__c = ''+e.getMessage() + '\n'+e.getStackTraceString();
            update jra;
        }         
    }
    //This method is used to generate daily record for Resller customer. 
    public static void generateReseller( List<REV_Contract_Master__c> contractListResller){
        
        List<String> approvedStatus = new List<String>{'Approved','Auto Approved','Ready to Upload','Uploaded','Failed','Upload not allowed'};
        //stores MidDay new Pricebook record for today
        List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
        //CBU Pricebook records valid for today
        Map<Id,RT_Price_Book__c> oldpricebook = new Map<Id,RT_Price_Book__c> ();
        //Stores MidDay records got created from CBU
        Map<Id,RT_Price_Book__c> newpricebook = new Map<Id,RT_Price_Book__c> ();
        //Latest Price valid for tomorrow
        List<Id> latestPriceBookContr = new List<Id>();
        
        Map<string,decimal> cbuprice= new  Map<string,decimal>();
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('MY Price Book').getRecordTypeId();
        for(RT_Price_Book__c pbdadta : [
            SELECT RE_Contract_Master__c,Id,RE_Latest_price_dt__c,RE_CBU_MC_for_Final_Price__c,RE_CBU_LDC_for_Final_Price__c,RE_Is_CBU__c,RE_Ship_To_Number__c,RE_Custom_Opp_Approve__c,RT_Product__r.Name, RT_Country__c,RE_Customer_Name__c,RE_Rebate__c,RE_BDF__c, RT_Product__c,RT_Location__c,RE_Service_SurChg__c,RE_Margin_on_LDC__c,RE_First_Calculated_Value__c,RE_Validation_1_Value__c,
            RE_Std_Disc__c,RE_Valid_From__c, RE_Valid_To__c, RE_List_Price__c,RE_Final_Price_Rebate__c,RE_Discount__c,RE_Transport_Charge__c,RE_Pricing_Level__c,RE_Validation_2_Value__c,
            RE_Margin_on_MC__c,RE_Forecast_Margin_on_LDC__c,RE_Forecast_Margin_on_MC__c,RE_DFOA_Charges__c,RE_First_Price__c,RE_Job_Counter__c
            FROM RT_Price_Book__c 
            where RE_Is_Latest__c = True AND RE_Contract_Master__r.RE_Customer_Name__r.type = 'Reseller'
            AND RE_Valid_To__c > Today AND RE_Valid_From__c <= Tomorrow AND RE_Custom_Opp_Approve__c =:approvedStatus AND recordtypeId =:pricebookrectypeid order by RE_Latest_price_dt__c desc]){
                if(!latestPriceBookContr.contains(pbdadta.RE_Contract_Master__c) ){
                    oldpricebook.put(pbdadta.RE_Contract_Master__c,pbdadta);
                    latestPriceBookContr.add(pbdadta.RE_Contract_Master__c);
                }                
            }  
        for(RT_Price_Book__c pbdataCBU : [Select Id,RE_Is_Latest__c,RE_Ship_To_Number__c,RE_Is_CBU__c,RE_Final_Price_Rebate__c,RT_Location__r.Name,RT_Product__r.Name,RE_CBU_MC__c from RT_Price_Book__c where RE_Contract_Master__r.RE_Customer_Name__r.type ='Reseller' AND RE_Is_Latest__c = True AND RE_Is_CBU__c = True AND RT_Country__c ='MY']){
            cbuprice.put(pbdataCBU.RE_Ship_To_Number__c + '_' + pbdataCBU.RT_Product__r.Name,pbdataCBU.RE_Final_Price_Rebate__c); 
        }
        
        Double standdisc,listPriceTier;
        
        for(REV_Contract_Master__c contractdata : contractListResller){
            System.debug('RE_MY_CustOpsCalculationController.generateReseller>>>'+contractdata.Id);
            string key = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name;
            string intradyPricekey = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name +'_'+contractdata.RE_Sales_Org__r.Value__c;
            string relevantKey = (IntradayPricing.containsKey(intradyPricekey) ? IntradayPricing.get(intradyPricekey).RE_Location__r.name + '_' + IntradayPricing.get(intradyPricekey).RE_Relevant_Product__c : '');
            double intradayPrice = double.valueOf( (IntradayPricing.containsKey(intradyPricekey) ? (IntradayPricing.get(intradyPricekey).Value__c != null ? IntradayPricing.get(intradyPricekey).Value__c : '0' ): '0'));
            RT_Price_Book__c pbdata = new RT_Price_Book__c();
            pbdata.recordtypeId = pricebookrectypeid;
            pbdata.RE_Is_CBU__c  = False;
            pbdata.RE_Is_Latest__c = True;
            pbdata.RE_Job_Counter__c = 0;
            pbdata.RE_Frequency_record__c=false;
           
            pbdata.RE_CBU_MC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_MC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_MC_Morning__c : 0);
                
            pbdata.RE_CBU_LDC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_LDC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_LDC_Morning__c : 0);
            
            pbdata.RE_Afternoon_Indication__c = afternoonIndicationMap.containsKey(key) ? afternoonIndicationMap.get(key) : (afternoonIndicationMap.containsKey(relevantKey) ? afternoonIndicationMap.get(relevantKey) : 0);
            //pbdata.RE_Afternoon_Indication__c = afternoonIndication;
            standdisc = (contractdata.RE_Standard_Discount__c != null) ? contractdata.RE_Standard_Discount__c : 0;   
            listPriceTier = double.valueOf(contractdata.List_Price_Tier__r.Value__c != null ? contractdata.List_Price_Tier__r.Value__c : '0.0');            
            pbdata.RE_CBU_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).createddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).createddate : system.today()).addHours(8));
            pbdata.RE_MidDay_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).lastmodifieddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).lastmodifieddate : system.today()).addHours(8));
			
            pbdata.RE_Transport_Charge__c = contractdata.RE_Transport_Charges__c !=null ? contractdata.RE_Transport_Charges__c : 0;
            pbdata.RE_Service_SurChg__c = contractdata.RE_Service_SurChg__c != null ? contractdata.RE_Service_SurChg__c : 0;
            pbdata.RE_DFOA_Charges__c = contractdata.RE_DFOA_Charges__c != null ? contractdata.RE_DFOA_Charges__c : 0;
            pbdata.RE_Pricing_Level__c  = contractdata.RE_Pricing_Levels__c != null ? contractdata.RE_Pricing_Levels__c : 0;
            pbdata.RE_Rebate__c=contractdata.RE_Rebate__c != null ? contractdata.RE_Rebate__c : 0;
            pbdata.RE_BDF__c=contractdata.RE_BDF__c != null ? contractdata.RE_BDF__c : 0;
            pbdata.RE_UoM__c='L';
            pbdata.RE_Unit__c='MYR';
            pbdata.RE_Quantity__c=100;
            if(cbuprice.containsKey(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name))
                pbdata.RE_Yesterday_Final_Price__c=cbuprice.get(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name);
            pbdata.RE_MIDday_Price__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_Final_PSP__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_Final_PSP__c : 0);
            
            //checks price book record valid till tomorrow
            if(oldpricebook.containsKey(contractdata.Id)){
                pbdata.RT_Country__c = oldpricebook.get(contractdata.Id).RT_Country__c;	
                pbdata.RE_Contract_Master__c = oldpricebook.get(contractdata.Id).RE_Contract_Master__c;	
                pbdata.RE_Customer_Name__c = oldpricebook.get(contractdata.Id).RE_Customer_Name__c;	
                pbdata.RT_Product__c = oldpricebook.get(contractdata.Id).RT_Product__c;	
                pbdata.RT_Location__c = oldpricebook.get(contractdata.Id).RT_Location__c;	
                pbdata.RE_Std_Disc__c = standdisc;	
                pbdata.RE_Latest_price_dt__c = oldpricebook.get(contractdata.Id).RE_Latest_price_dt__c.addMinutes(1);
                pbdata.RE_Valid_From__c = System.today().addDays(1);
                Date systemToday = system.today().addDays( 1 );
                Date ValidEndDate=oldpricebook.get(contractdata.Id).RE_Valid_To__c;
                Integer noOfDays = systemToday.daysBetween( ValidEndDate );
                if(noOfDays <= resllerFreqnumber)                    
                    pbdata.RE_Valid_To__c = system.today().addDays( resllerFreqnumber );
                else 
                    pbdata.RE_Valid_To__c = oldpricebook.get(contractdata.Id).RE_Valid_To__c;
                
                pbdata.RE_List_Price__c = oldpricebook.get(contractdata.Id).RE_List_Price__c;
                pbdata.RE_Final_Price_Rebate__c = oldpricebook.get(contractdata.Id).RE_First_Price__c;
                pbdata.RE_Discount__c = oldpricebook.get(contractdata.Id).RE_Discount__c;
                pbdata.RE_First_Price__c = pbdata.RE_Final_Price_Rebate__c;     
                pbdata.RE_Custom_Opp_Approve__c = oldpricebook.get(contractdata.Id).RE_Custom_Opp_Approve__c;  
                    pbdata.RE_CBU_MC_for_Final_Price__c = oldpricebook.get(contractdata.Id).RE_CBU_MC_for_Final_Price__c != null ? oldpricebook.get(contractdata.Id).RE_CBU_MC_for_Final_Price__c : 0.00;
                    pbdata.RE_CBU_LDC_for_Final_Price__c = oldpricebook.get(contractdata.Id).RE_CBU_LDC_for_Final_Price__c != null ? oldpricebook.get(contractdata.Id).RE_CBU_LDC_for_Final_Price__c : 0.00;
            }
            else {   
                double finalPrice;
                pbdata.RE_CBU_MC_for_Final_Price__c = pbdata.RE_CBU_MC__c;
                pbdata.RE_CBU_LDC_for_Final_Price__c = pbdata.RE_CBU_LDC__c;
                pbdata.RT_Country__c = contractdata.Country_Name__c;
                pbdata.RE_Latest_price_dt__c = DateTime.now();
                pbdata.RE_Contract_Master__c = contractdata.Id;
                pbdata.RE_Customer_Name__c = contractdata.RE_Customer_Name__c;
                pbdata.RT_Product__c = contractdata.RT_Material_Desc__c;
                pbdata.RT_Location__c = contractdata.RT_Plant_Desc__c;
                pbdata.RE_Std_Disc__c = standdisc;
                pbdata.RE_Valid_From__c = System.today().addDays(1);
                pbdata.RE_Valid_To__c =  System.today().addDays(resllerFreqnumber);
                pbdata.RE_Custom_Opp_Approve__c ='Auto Approved';
                pbdata.RE_Frequency_record__c=true;
                if(contractdata.RE_Custom_Ops_Calculation__r.Name == 'Tier Discount (Reseller)'){                    
                    pbdata.RE_List_Price__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_Final_PSP__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_Final_PSP__c : 0);
                    pbdata.RE_List_Price__c = (pbdata.RE_List_Price__c +intradayPrice+listPriceTier);
                    
                    finalPrice = pbdata.RE_List_Price__c - standdisc + (pbdata.RE_Transport_Charge__c != null ? pbdata.RE_Transport_Charge__c : 0) + (pbdata.RE_Service_SurChg__c != null ? pbdata.RE_Service_SurChg__c : 0);
                    pbdata.RE_Final_Price_Rebate__c = (contractdata.RE_Round_Up__c ? roundUpcustom(finalPrice) : finalPrice);
                } 
                pbdata.RE_First_Price__c = pbdata.RE_Final_Price_Rebate__c;
            }
                        
            pricebookList.add(pbdata);
        }
        if(!pricebookList.isEmpty()){            
            insert pricebookList;                            
        }
    }
    //This method is used to generate daily record for Direct customer
    public static void generateDirectdata(List<REV_Contract_Master__c> contractListDir){
        frequencyForTwoDays();
        frequencyForWedsDays();
        List<String> approvedStatus = new List<String>{'Approved','Auto Approved','Ready to Upload','Uploaded','Failed','Upload not allowed'};
            List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
        Map<Id,RT_Price_Book__c> cbuPricebook = new Map<Id,RT_Price_Book__c> ();
        Map<Id,RT_Price_Book__c> freqPricebook = new Map<Id,RT_Price_Book__c> ();
        Map<string,decimal> cbuprice= new  Map<string,decimal>();
        //Latest Price valid for tomorrow
        List<Id> latestPriceBookContr = new List<Id>();
        date todayDate = System.today();
        date weekStart = todayDate.toStartofWeek();
        date weekEnd=weekStart.addDays(6);
        Datetime currentDay = (DateTime)System.today();
        String dayOfWeek = currentDay.format('EEEE');
        
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('MY Price Book').getRecordTypeId();
        for(RT_Price_Book__c pbdadta : [
            SELECT RE_Contract_Master__c,Id,RE_Frequency_record__c ,RE_CBU_MC_for_Final_Price__c,RE_CBU_LDC_for_Final_Price__c,RE_Latest_price_dt__c,RE_Is_CBU__c,RE_Ship_To_Number__c,RT_Product__r.Name, RT_Country__c,RE_Customer_Name__c,RE_Rebate__c,RE_BDF__c, RT_Product__c,RT_Location__c,RE_Service_SurChg__c,RE_Margin_on_LDC__c,RE_First_Calculated_Value__c,RE_Validation_1_Value__c,
            RE_Std_Disc__c,RE_Valid_From__c, RE_Valid_To__c, RE_List_Price__c,RE_Final_Price_Rebate__c,RE_Discount__c,RE_Transport_Charge__c,RE_Pricing_Level__c,RE_Validation_2_Value__c,
            RE_Margin_on_MC__c,RE_Forecast_Margin_on_LDC__c,RE_Forecast_Margin_on_MC__c,RE_DFOA_Charges__c,RE_First_Price__c,RE_Job_Counter__c,RE_Custom_Opp_Approve__c
            FROM RT_Price_Book__c where RE_Is_Latest__c = True  AND RE_Valid_To__c > Today AND RE_Valid_From__c <= Tomorrow
            AND RE_Contract_Master__r.RE_Customer_Name__r.type = 'Direct' AND RE_Custom_Opp_Approve__c =:approvedStatus AND recordtypeId =:pricebookrectypeid order by RE_Latest_price_dt__c desc]){
                if(pbdadta.RE_Frequency_record__c == false && !latestPriceBookContr.contains(pbdadta.RE_Contract_Master__c) ){
                    cbuPricebook.put(pbdadta.RE_Contract_Master__c,pbdadta);
                    latestPriceBookContr.add(pbdadta.RE_Contract_Master__c);
                }
                if(pbdadta.RE_Is_CBU__c == false && pbdadta.RE_Frequency_record__c == true )
                    freqPricebook.put(pbdadta.RE_Contract_Master__c,pbdadta);
            }
        for(RT_Price_Book__c pbdataCBU : [Select Id,RE_Is_Latest__c,RE_Ship_To_Number__c,RE_Is_CBU__c,RE_Final_Price_Rebate__c,RT_Location__r.Name,RT_Product__r.Name,RE_CBU_MC__c from RT_Price_Book__c where RE_Is_Latest__c = True AND RE_Is_CBU__c = True AND RE_Contract_Master__r.RE_Customer_Name__r.type = 'Direct' AND RE_Frequency_record__c=false AND RT_Country__c ='MY' ]){
            cbuprice.put(pbdataCBU.RE_Ship_To_Number__c + '_' + pbdataCBU.RT_Product__r.Name,pbdataCBU.RE_Final_Price_Rebate__c); 
        }
                
        Double standdisc;
        for(REV_Contract_Master__c contractdata : contractListDir){  
            if(contractdata.RE_Custom_Ops_Calculation__r.Name != 'Direct As Reseller Price Adjustment (with transport charge)'){
            System.debug('RE_MY_CustOpsCalculationController.generateDirectdata>>'+contractdata.id);
            string key = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name;
            string intradyPricekey = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name +'_'+contractdata.RE_Sales_Org__r.Value__c;
            string relevantKey = (IntradayPricing.containsKey(intradyPricekey) ? IntradayPricing.get(intradyPricekey).RE_Location__r.name + '_' + IntradayPricing.get(intradyPricekey).RE_Relevant_Product__c : '');
            double intradayPrice = double.valueOf( (IntradayPricing.containsKey(intradyPricekey) ? (IntradayPricing.get(intradyPricekey).Value__c != null ? IntradayPricing.get(intradyPricekey).Value__c : '0' ): '0'));
            RT_Price_Book__c pbdata = new RT_Price_Book__c();
            pbdata.recordtypeId = pricebookrectypeid;
            pbdata.RE_Is_CBU__c  = False;
            pbdata.RE_Is_Latest__c = True;
            pbdata.RE_Job_Counter__c = 0;
            pbdata.RE_Frequency_record__c=false;
            pbdata.RE_CBU_MC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_MC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_MC_Morning__c : 0);
                
            pbdata.RE_CBU_LDC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_LDC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_LDC_Morning__c : 0);
            
            pbdata.RE_Afternoon_Indication__c = afternoonIndicationMap.containsKey(key) ? afternoonIndicationMap.get(key) : (afternoonIndicationMap.containsKey(relevantKey) ? afternoonIndicationMap.get(relevantKey) : 0);
            //pbdata.RE_Afternoon_Indication__c = afternoonIndication;
            double AftIndication = pbdata.RE_Afternoon_Indication__c;
            standdisc = (contractdata.RE_Standard_Discount__c != null) ? contractdata.RE_Standard_Discount__c : 0;   
            pbdata.RE_CBU_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).createddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).createddate : system.today()).addHours(8));
            pbdata.RE_MidDay_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).lastmodifieddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).lastmodifieddate : system.today()).addHours(8));
            pbdata.RE_Transport_Charge__c = contractdata.RE_Transport_Charges__c !=null ? contractdata.RE_Transport_Charges__c : 0;
            pbdata.RE_Service_SurChg__c = contractdata.RE_Service_SurChg__c != null ? contractdata.RE_Service_SurChg__c : 0;
            pbdata.RE_DFOA_Charges__c = contractdata.RE_DFOA_Charges__c != null ? contractdata.RE_DFOA_Charges__c : 0;
            pbdata.RE_Pricing_Level__c  = contractdata.RE_Pricing_Levels__c != null ? contractdata.RE_Pricing_Levels__c : 0;
            pbdata.RE_Rebate__c=contractdata.RE_Rebate__c != null ? contractdata.RE_Rebate__c : 0;
            pbdata.RE_BDF__c=contractdata.RE_BDF__c != null ? contractdata.RE_BDF__c : 0;   
            pbdata.RE_UoM__c='L';
            pbdata.RE_Unit__c='MYR';
            pbdata.RE_Quantity__c=100;
            if(cbuprice.containsKey(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name))
                pbdata.RE_Yesterday_Final_Price__c=cbuprice.get(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name);
            pbdata.RE_MIDday_Price__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_Final_PSP__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_Final_PSP__c : 0);
            
            if(cbuPricebook.containsKey(contractdata.Id) || freqPricebook.containsKey(contractdata.Id)){
                boolean containsInCBU=cbuPricebook.containsKey(contractdata.Id);
                pbdata.RT_Country__c = (containsInCBU ? cbuPricebook.get(contractdata.Id).RT_Country__c : freqPricebook.get(contractdata.Id).RT_Country__c);	
                pbdata.RE_Contract_Master__c = (containsInCBU ? cbuPricebook.get(contractdata.Id).RE_Contract_Master__c : freqPricebook.get(contractdata.Id).RE_Contract_Master__c);	
                pbdata.RE_Customer_Name__c =  (containsInCBU ? cbuPricebook.get(contractdata.Id).RE_Customer_Name__c : freqPricebook.get(contractdata.Id).RE_Customer_Name__c);	
                pbdata.RT_Product__c = (containsInCBU ? cbuPricebook.get(contractdata.Id).RT_Product__c : freqPricebook.get(contractdata.Id).RT_Product__c);	
                pbdata.RT_Location__c =  (containsInCBU ? cbuPricebook.get(contractdata.Id).RT_Location__c : freqPricebook.get(contractdata.Id).RT_Location__c);	
                pbdata.RE_Std_Disc__c = standdisc;	
                pbdata.RE_Latest_price_dt__c = (containsInCBU ?cbuPricebook.get(contractdata.Id).RE_Latest_price_dt__c.addMinutes(1) :freqPricebook.get(contractdata.Id).RE_Latest_price_dt__c.addMinutes(1)) ;
                pbdata.RE_Valid_From__c = (containsInCBU ? cbuPricebook.get(contractdata.Id).RE_Valid_From__c : freqPricebook.get(contractdata.Id).RE_Valid_From__c);
                pbdata.RE_Valid_To__c = (containsInCBU ? cbuPricebook.get(contractdata.Id).RE_Valid_To__c : freqPricebook.get(contractdata.Id).RE_Valid_To__c);
                pbdata.RE_List_Price__c = (containsInCBU ? cbuPricebook.get(contractdata.Id).RE_List_Price__c : freqPricebook.get(contractdata.Id).RE_List_Price__c);
                pbdata.RE_Custom_Opp_Approve__c =  (containsInCBU ? cbuPricebook.get(contractdata.Id).RE_Custom_Opp_Approve__c : freqPricebook.get(contractdata.Id).RE_Custom_Opp_Approve__c);
                pbdata.RE_Direct_Valid_From__c = pbdata.RE_Valid_From__c;
                pbdata.RE_Direct_Valid_To__c = pbdata.RE_Valid_To__c;
                pbdata.RE_Final_Price_Rebate__c =  (containsInCBU ? cbuPricebook.get(contractdata.Id).RE_Final_Price_Rebate__c : freqPricebook.get(contractdata.Id).RE_Final_Price_Rebate__c);
                pbdata.RE_Discount__c = (containsInCBU ? cbuPricebook.get(contractdata.Id).RE_Discount__c :  freqPricebook.get(contractdata.Id).RE_Discount__c);
                pbdata.RE_First_Price__c = pbdata.RE_Final_Price_Rebate__c;   
                        pbdata.RE_CBU_MC_for_Final_Price__c = (containsInCBU ? (cbuPricebook.get(contractdata.Id).RE_CBU_MC_for_Final_Price__c != null ? cbuPricebook.get(contractdata.Id).RE_CBU_MC_for_Final_Price__c : 0.00 ) :
                                                               (freqPricebook.get(contractdata.Id).RE_CBU_MC_for_Final_Price__c != null ? freqPricebook.get(contractdata.Id).RE_CBU_MC_for_Final_Price__c : 0.00 ));
                        pbdata.RE_CBU_LDC_for_Final_Price__c = (containsInCBU ? (cbuPricebook.get(contractdata.Id).RE_CBU_LDC_for_Final_Price__c != null ? cbuPricebook.get(contractdata.Id).RE_CBU_LDC_for_Final_Price__c : 0.00 ) :
                        										(freqPricebook.get(contractdata.Id).RE_CBU_LDC_for_Final_Price__c != null ? freqPricebook.get(contractdata.Id).RE_CBU_LDC_for_Final_Price__c : 0.00 ));
            }
            else{ 
                double finalPrice;
                    pbdata.RE_CBU_MC_for_Final_Price__c = pbdata.RE_CBU_MC__c;
                    pbdata.RE_CBU_LDC_for_Final_Price__c = pbdata.RE_CBU_LDC__c;
                pbdata.RE_Latest_price_dt__c = DateTime.now();
                pbdata.RT_Country__c = contractdata.Country_Name__c;	
                pbdata.RE_Contract_Master__c = contractdata.Id;
                pbdata.RE_Customer_Name__c = contractdata.RE_Customer_Name__c;
                pbdata.RT_Product__c = contractdata.RT_Material_Desc__c;
                pbdata.RT_Location__c = contractdata.RT_Plant_Desc__c;
                pbdata.RE_Std_Disc__c = standdisc;
                if(contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct without transport charge) - 2 days validity'){
                    pbdata.RE_Valid_From__c = validFromFqTwo;
                    pbdata.RE_Valid_To__c =  ValidTofqTwo;
                }
                    else if (contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - Eff Sat to Fri'){
                        pbdata.RE_Valid_From__c = validFromWed;
                        pbdata.RE_Valid_To__c =  validTowed;
                    }
                else{
                    pbdata.RE_Valid_From__c = (dayOfWeek !='Sunday' ? System.today().addDays(1) : System.today());
                    pbdata.RE_Valid_To__c =  weekEnd;
                }
                
                pbdata.RE_Direct_Valid_From__c = pbdata.RE_Valid_From__c;
                pbdata.RE_Direct_Valid_To__c = pbdata.RE_Valid_To__c;
                pbdata.RE_Custom_Opp_Approve__c ='Auto Approved'; 
                
                if(contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct without transport charge) - 1 week' || contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct without transport charge) - 2 days validity'
                       || contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - 1 week' || contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - Eff Sat to Fri'){  
                        pbdata.RE_List_Price__c = directListCurrentWeek.containsKey(contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name) ? 
                           directListCurrentWeek.get( contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name).RE_Final_PSP__c : 0;
                       
                       pbdata.RE_Pricing_Level__c = contractdata.RE_Pricing_Levels__c != null ? contractdata.RE_Pricing_Levels__c : 0;
                       
                       decimal dfoacharges=(pbdata.RE_DFOA_Charges__c != null ? pbdata.RE_DFOA_Charges__c : 0);
                       decimal transChanges = (pbdata.RE_Transport_Charge__c != null ? pbdata.RE_Transport_Charge__c : 0);
                           boolean checkModel = false;
                           if(contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - 1 week' || contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - Eff Sat to Fri')
                               checkModel = true;
                           decimal priceForCondition =   (checkModel ? transChanges : dfoacharges);
                                              
                       pbdata.RE_Validation_1_Value__c= (pbdata.RE_MIDday_Price__c != null ? pbdata.RE_MIDday_Price__c : 0 ) + priceForCondition + 1 + intradayPrice;
                       pbdata.RE_Validation_2_Value__c= (pbdata.RE_CBU_LDC__c != null ? pbdata.RE_CBU_LDC__c : 0 ) + priceForCondition + (AftIndication != null ? AftIndication :0) + (pbdata.RE_Pricing_Level__c != null ? pbdata.RE_Pricing_Level__c:0 ) + intradayPrice ;
                       if (pbdata.RE_Validation_1_Value__c >  pbdata.RE_Validation_2_Value__c)
                           pbdata.RE_Final_Price_Rebate__c = contractdata.RE_Round_Up__c ? roundUpcustom(pbdata.RE_Validation_1_Value__c) : pbdata.RE_Validation_1_Value__c;
                       else
                           pbdata.RE_Final_Price_Rebate__c = contractdata.RE_Round_Up__c ? roundUpcustom(pbdata.RE_Validation_2_Value__c) : pbdata.RE_Validation_2_Value__c;   
                       
                           decimal transportChr =   (checkModel ? transChanges : 0.0);
                       pbdata.RE_Discount__c = (pbdata.RE_List_Price__c-  pbdata.RE_Final_Price_Rebate__c + transportChr).setScale(2);
                       
                   }    
                pbdata.RE_First_Price__c = pbdata.RE_Final_Price_Rebate__c;
                pbdata.RE_Frequency_record__c = True;               
            }  
            pricebookList.add(pbdata);
            } 
        } 
        if(!pricebookList.isEmpty())           
            insert pricebookList;  
    }
    //This method is used to generate Next week record for Direct customer.Every friday this record will be Generated.
    public static void genDirectdataOnFreqday( ){
        List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
        Map<string,decimal> cbuprice= new  Map<string,decimal>();        
        date todayDate = System.today();
        date weekStart = todayDate.toStartofWeek();
        date nextweekSt=weekStart.addDays(7);
        date nextweekEnd=nextweekSt.addDays(6);
        Datetime currentDay = (DateTime)System.today();
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('MY Price Book').getRecordTypeId();
        
        for(RT_Price_Book__c pbdataCBU : [Select Id,RE_Is_Latest__c,RE_Ship_To_Number__c,RE_Is_CBU__c,RE_Final_Price_Rebate__c,RT_Location__r.Name,RT_Product__r.Name,RE_CBU_MC__c from RT_Price_Book__c where RE_Is_Latest__c = True AND RE_Is_CBU__c = True AND RE_Contract_Master__r.RE_Customer_Name__r.type = 'Direct' AND RE_Frequency_record__c=false AND RT_Country__c ='MY']){
            cbuprice.put(pbdataCBU.RE_Ship_To_Number__c + '_' + pbdataCBU.RT_Product__r.Name,pbdataCBU.RE_Final_Price_Rebate__c); 
        }
        
        
        //Double afternoonIndication = RE_SOQLController.fetchAfternoonIndication();
        
        Double standdisc;
        for(REV_Contract_Master__c contractdata : contractListDirect){  
            if(contractdata.RE_Custom_Ops_Calculation__r.Name != 'Price Level (Direct without transport charge) - 2 days validity' && contractdata.RE_Custom_Ops_Calculation__r.Name!= 'Price Level (Direct with transport charge) - Eff Sat to Fri' && 
               contractdata.RE_Custom_Ops_Calculation__r.Name != 'Direct As Reseller Price Adjustment (with transport charge)'){
                string key = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name;
                string intradyPricekey = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name +'_'+contractdata.RE_Sales_Org__r.Value__c;
                string relevantKey = (IntradayPricing.containsKey(intradyPricekey) ? IntradayPricing.get(intradyPricekey).RE_Location__r.name + '_' + IntradayPricing.get(intradyPricekey).RE_Relevant_Product__c : '');
                double intradayPrice = double.valueOf( (IntradayPricing.containsKey(intradyPricekey) ? (IntradayPricing.get(intradyPricekey).Value__c != null ? IntradayPricing.get(intradyPricekey).Value__c : '0' ): '0'));
                System.debug('RE_MY_CustOpsCalculationController.genDirectdataOnFreqday>>>'+contractdata.id);
                double finalPrice;
                RT_Price_Book__c pbdata = new RT_Price_Book__c();
                pbdata.recordtypeId = pricebookrectypeid;
                pbdata.RE_Is_CBU__c  = False;
                pbdata.RE_Is_Latest__c = True;
                pbdata.RE_Job_Counter__c = 0;
                pbdata.RE_Frequency_record__c=false;
                pbdata.RE_CBU_MC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_MC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_MC_Morning__c : 0);
                pbdata.RE_CBU_LDC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_LDC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_LDC_Morning__c : 0);
                //pbdata.RE_Afternoon_Indication__c = afternoonIndication;
                pbdata.RE_Afternoon_Indication__c = afternoonIndicationMap.containsKey(key) ? afternoonIndicationMap.get(key) : (afternoonIndicationMap.containsKey(relevantKey) ? afternoonIndicationMap.get(relevantKey) : 0);
                double AftIndication = pbdata.RE_Afternoon_Indication__c;
                standdisc = (contractdata.RE_Standard_Discount__c != null) ? contractdata.RE_Standard_Discount__c : 0;   
                pbdata.RE_CBU_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).createddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).createddate : system.today()).addHours(8));
				pbdata.RE_MidDay_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).lastmodifieddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).lastmodifieddate : system.today()).addHours(8));
                pbdata.RE_Transport_Charge__c = contractdata.RE_Transport_Charges__c !=null ? contractdata.RE_Transport_Charges__c : 0;
                pbdata.RE_Service_SurChg__c = contractdata.RE_Service_SurChg__c != null ? contractdata.RE_Service_SurChg__c : 0;
                pbdata.RE_DFOA_Charges__c = contractdata.RE_DFOA_Charges__c != null ? contractdata.RE_DFOA_Charges__c : 0;
                pbdata.RE_Pricing_Level__c  = contractdata.RE_Pricing_Levels__c != null ? contractdata.RE_Pricing_Levels__c : 0;
                pbdata.RE_Rebate__c=contractdata.RE_Rebate__c != null ? contractdata.RE_Rebate__c : 0;
                pbdata.RE_BDF__c=contractdata.RE_BDF__c != null ? contractdata.RE_BDF__c : 0;   
                pbdata.RE_UoM__c='L';
                pbdata.RE_Unit__c='MYR';
                pbdata.RE_Quantity__c=100;
                if(cbuprice.containsKey(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name))
                    pbdata.RE_Yesterday_Final_Price__c=cbuprice.get(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name);
                pbdata.RE_MIDday_Price__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_Final_PSP__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_Final_PSP__c : 0);
                    
                pbdata.RT_Country__c = contractdata.Country_Name__c;	
                pbdata.RE_Latest_price_dt__c = DateTime.now();
                pbdata.RE_Contract_Master__c = contractdata.Id;
                pbdata.RE_Customer_Name__c = contractdata.RE_Customer_Name__c;
                pbdata.RT_Product__c = contractdata.RT_Material_Desc__c;
                pbdata.RT_Location__c = contractdata.RT_Plant_Desc__c;
                pbdata.RE_Std_Disc__c = standdisc;
                pbdata.RE_Valid_From__c = nextweekSt;
                pbdata.RE_Valid_To__c =  nextweekEnd;
                pbdata.RE_Direct_Valid_From__c = pbdata.RE_Valid_From__c;
                pbdata.RE_Direct_Valid_To__c = pbdata.RE_Valid_To__c;
                pbdata.RE_Custom_Opp_Approve__c ='Auto Approved';
                pbdata.RE_CBU_MC_for_Final_Price__c = pbdata.RE_CBU_MC__c;
                pbdata.RE_CBU_LDC_for_Final_Price__c = pbdata.RE_CBU_LDC__c;
                
                if(contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct without transport charge) - 1 week' || contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct without transport charge) - 2 days validity'
                   || contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - 1 week' ){    
                       
                       pbdata.RE_List_Price__c = directListNextWeek.containsKey(contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name) ? 
                           directListNextWeek.get( contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name).RE_Final_PSP__c : 0;             
                       pbdata.RE_Pricing_Level__c = contractdata.RE_Pricing_Levels__c != null ? contractdata.RE_Pricing_Levels__c : 0;
                       decimal dfoacharges=(pbdata.RE_DFOA_Charges__c != null ? pbdata.RE_DFOA_Charges__c : 0);
                       decimal transChanges = (pbdata.RE_Transport_Charge__c != null ? pbdata.RE_Transport_Charge__c : 0);
                       
                       decimal priceForCondition =   (contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - 1 week' ? transChanges : dfoacharges);
                       
                       pbdata.RE_Validation_1_Value__c= (pbdata.RE_MIDday_Price__c != null ? pbdata.RE_MIDday_Price__c : 0 ) + priceForCondition + 1 + intradayPrice;
                       pbdata.RE_Validation_2_Value__c= (pbdata.RE_CBU_LDC__c != null ? pbdata.RE_CBU_LDC__c : 0 ) + priceForCondition + (AftIndication != null ? AftIndication :0) + (pbdata.RE_Pricing_Level__c != null ? pbdata.RE_Pricing_Level__c:0 ) + intradayPrice ;
                       
                       if (pbdata.RE_Validation_1_Value__c >  pbdata.RE_Validation_2_Value__c)
                           pbdata.RE_Final_Price_Rebate__c = contractdata.RE_Round_Up__c ? roundUpcustom(pbdata.RE_Validation_1_Value__c) : pbdata.RE_Validation_1_Value__c;
                       else
                           pbdata.RE_Final_Price_Rebate__c = contractdata.RE_Round_Up__c ? roundUpcustom(pbdata.RE_Validation_2_Value__c) : pbdata.RE_Validation_2_Value__c;                
                       decimal transportChr =   (contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - 1 week' ? transChanges : 0.0);
                       pbdata.RE_Discount__c = (pbdata.RE_List_Price__c-  pbdata.RE_Final_Price_Rebate__c + transportChr).setScale(2);
                   }                   
                
                pbdata.RE_First_Price__c = pbdata.RE_Final_Price_Rebate__c;
                pbdata.RE_Frequency_record__c = True; 
                
                pricebookList.add(pbdata);
            }   
        }
        if(!pricebookList.isEmpty())           
            insert pricebookList;        
        
    }
    
    //Todays CBU data
    public Static void todayCBU(){
        for(RE_MY_CostPrice__c myCBU : [SELECT RE_Depot_Name__r.Name,RE_Product_Name__r.Name,RE_IsLatest__c,RE_Costprice_Marginal_Cost__c,
                                        CreatedDate,RE_Country__c,RE_Depot_Name__c,RE_Product_Name__c,RE_Costprice_Laid_Down_Cost__c,RE_Depot_Name__r.RE_Region_Name__c
                                        FROM RE_MY_CostPrice__c  WHERE RE_IsLatest__c = true AND  CreatedDate = today AND RE_Depot_Name__c!=null AND
                                        RE_Product_Name__c!=null AND RE_Costprice_Marginal_Cost__c!=null AND RE_Country__r.name = 'Malaysia']){
                                            morningCBUMap.put(myCBU.RE_Depot_Name__r.Name+'_'+myCBU.RE_Product_Name__r.Name,myCBU);   
                                        }
    }
    //Update MidDay data to CBU data
    public static void todayCBUcustomOppsgenerate( ){
        createListPrice();
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        jrAudit.RE_Run_Time__c = System.now();
        jrAudit.RE_Run_Type__c = 'Automate';
        jrAudit.RE_Job_Type__c = 'MY Customer Opps CBU';
        jrAudit.RE_User__c = UserInfo.getUserId();
        jrAudit.RE_Job_Run_Count__c = 0;
        
        insert jrAudit;
        
        todayCBU();
        List<String> approvedStatus = new List<String>{'Approved','Auto Approved','Ready to Upload','Uploaded','Failed','Upload not allowed'};
            boolean colneRecord = false;
        List<RT_Price_Book__c> oldCBUvlaues = new List<RT_Price_Book__c>();
        List<Id> contractids = new List<Id>();
        String WhereCondition =' RE_Is_CBU__c = True ';
        
        //Update RE_Is_Latest__c = false for yesterdays CBU Records and clone the record which is valid for Today 
        for(RT_Price_Book__c oldCbu : getDirectpricebookdata(WhereCondition)){
            oldCbu.RE_Is_Latest__c = false;
            oldCbu.RE_CBU_Last_offered__c = true;
            oldCbu.RE_CBU_valid_To__c = system.today().addDays(-1);
            boolean checkValidfrom = oldCbu.RE_Valid_From__c > system.today();
            if(checkValidfrom)
                colneRecord = true;
            
            if( !checkValidfrom && approvedStatus.contains(oldCbu.RE_Custom_Opp_Approve__c) ){
               
                if(oldCbu.RE_Valid_From__c <= system.today().addDays(-1) && oldCbu.RE_Valid_To__c >= system.today().addDays(-1) && !contractids.contains(oldCbu.RE_Contract_Master__c)){
                    yesterdayPrice.put(oldCbu.RE_Ship_To_Number__c + '_' + oldCbu.RT_Product__r.Name,oldCbu.RE_Final_Price_Rebate__c);
                    contractids.add(oldCbu.RE_Contract_Master__c);
                }
                
                if(oldCbu.RE_Valid_From__c <= system.today() && oldCbu.RE_Valid_To__c >= system.today() && oldCbu.RE_Latest_price_dt__c >= oldCbu.RE_CBU_valid_from__c )
                    colneRecord = true;
            }
            oldCBUvlaues.add(oldCbu);  
            if(colneRecord){
                colneRecord= false;
                RT_Price_Book__c newpriceBook = new RT_Price_Book__c();
                newpriceBook = oldCbu.clone(false, true, false, false);
                newpriceBook.id= null;
                newpriceBook.RE_Frequency_record__c = false;
                newpriceBook.RE_CBU_Last_offered__c = false;
                newpriceBook.RE_Is_Latest__c = true;
                newpriceBook.RE_CBU_valid_To__c = null;
                newpriceBook.RE_CBU_valid_from__c = system.today();
                newpriceBook.RE_Is_CBU__c = true;
                newpriceBook.RE_Yesterday_Final_Price__c = newpriceBook.RE_Final_Price_Rebate__c;
                
                string curentProdkey = newpriceBook.RT_Location__r.Name+'_'+newpriceBook.RT_Product__r.Name+'_' +newpriceBook.RE_Sales_Org__c;
                string relevantKey = (IntradayPricing.containsKey(curentProdkey) ? IntradayPricing.get(curentProdkey).RE_Location__r.name + '_' + IntradayPricing.get(curentProdkey).RE_Relevant_Product__c : '');
                
                if(morningCBUMap.containskey(newpriceBook.RT_Location__r.Name + '_' + newpriceBook.RT_Product__r.Name)){
                    newpriceBook.RE_CBU_output_date__c = Date.valueof(morningCBUMap.get(newpriceBook.RT_Location__r.Name + '_' + newpriceBook.RT_Product__r.Name).createddate.addHours(8));
                    newpriceBook.RE_CBU_MC__c = morningCBUMap.get(newpriceBook.RT_Location__r.Name + '_' + newpriceBook.RT_Product__r.Name).RE_Costprice_Marginal_Cost__c;
                    newpriceBook.RE_CBU_LDC__c = morningCBUMap.get(newpriceBook.RT_Location__r.Name + '_' + newpriceBook.RT_Product__r.Name).RE_Costprice_Laid_Down_Cost__c;                    
                }
                else{
                    if(morningCBUMap.containsKey(relevantKey)){
                        newpriceBook.RE_CBU_output_date__c = Date.valueof(morningCBUMap.get(relevantKey).createddate.addHours(8));
                        newpriceBook.RE_CBU_MC__c = morningCBUMap.get(relevantKey).RE_Costprice_Marginal_Cost__c;
                        newpriceBook.RE_CBU_LDC__c = morningCBUMap.get(relevantKey).RE_Costprice_Laid_Down_Cost__c;                        
                    }                     
                }  
                oldCBUvlaues.add(newpriceBook);
            }            
        }
        try{
            System.debug('Start todayCBUcustomOppsgenerate Method upsert oldCBUvlaues- DML Rows ::: '+Limits.getDMLRows()+'  CPU Limit ::: '+Limits.getCpuTime());
            if(!oldCBUvlaues.isEmpty())
                upsert oldCBUvlaues;
            System.debug('End todayCBUcustomOppsgenerate Method upsert oldCBUvlaues- DML Rows ::: '+Limits.getDMLRows()+'  CPU Limit ::: '+Limits.getCpuTime());    
            todayCBUreseller();
            System.debug('End todayCBUreseller Method Class DML Rows ::: '+Limits.getDMLRows()+'  CPU Limit ::: '+Limits.getCpuTime());
            todayCBUdirect();
            System.debug('End todayCBUdirect Method Class DML Rows ::: '+Limits.getDMLRows()+'  CPU Limit ::: '+Limits.getCpuTime());
            
            jrAudit.RE_IsSuccess__c = true;
            
            update jrAudit;            
        }
        catch(exception ex){            
            system.debug('RE_MY_CustOpsCalculationController.todayCBUcustomOppsgenerate >>'+ex);            
            jrAudit.RE_Exception__c= 'RE_MY_CustOpsCalculationController.todayCBUcustomOppsgenerate >> \n'+string.valueOf(ex);
            
            Update jrAudit;
        }        
    }    
    //Update CBU values for Reseller customer for yesterdays MidDay record.
    public Static void todayCBUreseller(){
        List<RT_Price_Book__c> todaysCBUvalues = new List<RT_Price_Book__c>();
        date frequencyDate = System.today().addDays(getfrequencyTo());
        for(RT_Price_Book__c resellerMidDay :[Select Id, RE_Is_Latest__c, RE_CBU_valid_from__c, RE_Custom_Opp_Approve__c,RE_CBU_valid_To__c, RE_Ship_To_Number__c, RE_Is_CBU__c, RE_Final_Price_Rebate__c,
                                              RT_Location__r.Name,RE_Sales_Org__c, RT_Product__r.Name,RE_CBU_MC__c from RT_Price_Book__c where RE_Is_Latest__c = True AND RE_Is_CBU__c = False AND 
                                              RE_Contract_Master__r.RE_Customer_Name__r.type ='Reseller' AND  RT_Country__c ='MY' AND RE_Valid_To__c >= TODAY   AND RE_Valid_From__c <= :frequencyDate] ){
                                                  
                                                  resellerMidDay.RE_CBU_valid_from__c = system.today();
                                                   resellerMidDay.RE_Is_CBU__c = True;
                                                  if(recordStatus.contains(resellerMidDay.RE_Custom_Opp_Approve__c)){
                                                      resellerMidDay.RE_Is_Latest__c = false;
                                                      resellerMidDay.RE_Is_CBU__c = false;
                                                  }                                              
                                                  string curentProdkey = resellerMidDay.RT_Location__r.Name+'_'+resellerMidDay.RT_Product__r.Name +'_' +resellerMidDay.RE_Sales_Org__c;
                                                  string relevantKey = (IntradayPricing.containsKey(curentProdkey) ? IntradayPricing.get(curentProdkey).RE_Location__r.name + '_' + IntradayPricing.get(curentProdkey).RE_Relevant_Product__c : '');
                                                  
                                                  if(morningCBUMap.containskey(resellerMidDay.RT_Location__r.Name + '_' + resellerMidDay.RT_Product__r.Name)){
                                                      resellerMidDay.RE_CBU_output_date__c = Date.valueof(morningCBUMap.get(resellerMidDay.RT_Location__r.Name + '_' + resellerMidDay.RT_Product__r.Name).createddate.addHours(8));
                                                      resellerMidDay.RE_CBU_MC__c = morningCBUMap.get(resellerMidDay.RT_Location__r.Name + '_' + resellerMidDay.RT_Product__r.Name).RE_Costprice_Marginal_Cost__c;
                                                      resellerMidDay.RE_CBU_LDC__c = morningCBUMap.get(resellerMidDay.RT_Location__r.Name + '_' + resellerMidDay.RT_Product__r.Name).RE_Costprice_Laid_Down_Cost__c;
                                                      if(yesterdayPrice.containsKey(resellerMidDay.RE_Ship_To_Number__c + '_' + resellerMidDay.RT_Product__r.Name))
                                                          resellerMidDay.RE_Yesterday_Final_Price__c=yesterdayPrice.get(resellerMidDay.RE_Ship_To_Number__c + '_' + resellerMidDay.RT_Product__r.Name);
                                                      //todaysCBUvalues.add(resellerMidDay);
                                                  }
                                                  else{
                                                      if(morningCBUMap.containsKey(relevantKey)){
                                                          resellerMidDay.RE_CBU_output_date__c = Date.valueof(morningCBUMap.get(relevantKey).createddate.addHours(8));
                                                          resellerMidDay.RE_CBU_MC__c = morningCBUMap.get(relevantKey).RE_Costprice_Marginal_Cost__c;
                                                          resellerMidDay.RE_CBU_LDC__c = morningCBUMap.get(relevantKey).RE_Costprice_Laid_Down_Cost__c;
                                                          //resellerMidDay.RE_Is_CBU__c = True;
                                                          if(yesterdayPrice.containsKey(resellerMidDay.RE_Ship_To_Number__c + '_' + resellerMidDay.RT_Product__r.Name))
                                                              resellerMidDay.RE_Yesterday_Final_Price__c=yesterdayPrice.get(resellerMidDay.RE_Ship_To_Number__c + '_' + resellerMidDay.RT_Product__r.Name);
                                                          //todaysCBUvalues.add(resellerMidDay);
                                                      }  
                                                  }
                                                  todaysCBUvalues.add(resellerMidDay);
                                              }
        
        if(!todaysCBUvalues.isEmpty())
            update todaysCBUvalues;       
        
    }
    //Update CBU values for Direct customer for Yesterdays MidDay record.
    public Static void todayCBUdirect(){
        List<RT_Price_Book__c> todaysCBUvalues = new List<RT_Price_Book__c>();
        DateTime todaysDate = System.today().addDays(getfrequencyTo());
        String frequencyDate = todaysDate.format('yyyy-MM-dd');
        String WhereCondition =' RE_Contract_Master__r.RE_Customer_Name__r.type =\'Direct\' AND RE_Valid_To__c >= TODAY  AND RE_Is_CBU__c  = False  AND RE_Valid_From__c <='+ frequencyDate +' ';
        List<Id> nonFrqPriceBook = new List<Id>();
        Map<String,RT_Price_Book__c> FrqPriceBook = new Map<String,RT_Price_Book__c>();
        List<RT_Price_Book__c> listOfCBU = new List<RT_Price_Book__c>();
        List<RT_Price_Book__c> listOfCBUFreq = new List<RT_Price_Book__c>();
        List<id> conNotToCBU = new List<Id>();
        //Seperate map for frequency record.
        for(RT_Price_Book__c DirectMidDay :getDirectpricebookdata(WhereCondition)){
            if(DirectMidDay.RE_Frequency_record__c){
                FrqPriceBook.put(DirectMidDay.RE_Contract_Master__c ,DirectMidDay );
                listOfCBUFreq.add(DirectMidDay);
            }
            else{
                if(recordStatus.contains(DirectMidDay.RE_Custom_Opp_Approve__c)){
                    DirectMidDay.RE_Is_Latest__c = false;
                    todaysCBUvalues.add(DirectMidDay);  
                    conNotToCBU.add(DirectMidDay.RE_Contract_Master__c);
                }                   
                else{
                    if((DirectMidDay.RE_Valid_From__c <= system.today()))
                        nonFrqPriceBook.add(DirectMidDay.RE_Contract_Master__c );
                    listOfCBU.add(DirectMidDay);
                }
            }
        }
       
        for(RT_Price_Book__c DirectMidDayfrequency :listOfCBUFreq ){
            if(DirectMidDayfrequency.RE_Valid_From__c > system.today() )
                listOfCBU.add(DirectMidDayfrequency);
            else{
                //if(!nonFrqPriceBook.containsKey(DirectMidDayfrequency.RE_Contract_Master__c))
                if(conNotToCBU.contains(DirectMidDayfrequency.RE_Contract_Master__c) || !nonFrqPriceBook.contains(DirectMidDayfrequency.RE_Contract_Master__c) )
                    listOfCBU.add(DirectMidDayfrequency);
            }            
        }
        //Update CBU values
        for(RT_Price_Book__c DirectMidDay :listOfCBU ){
            
            RT_Price_Book__c newfuturepbdata = new RT_Price_Book__c ();
            if(DirectMidDay.RE_Frequency_record__c){
                newfuturepbdata = DirectMidDay.clone(false, true, false, false);
                newfuturepbdata.id= null;
                newfuturepbdata.RE_Frequency_record__c = false;
            }
            else 
                newfuturepbdata = DirectMidDay;
            
            newfuturepbdata.RE_CBU_valid_from__c = system.today();
            newfuturepbdata.RE_Is_CBU__c = True;            
            string curentProdkey = newfuturepbdata.RT_Location__r.Name+'_'+newfuturepbdata.RT_Product__r.Name+'_' +newfuturepbdata.RE_Sales_Org__c;
            string relevantKey = (IntradayPricing.containsKey(curentProdkey) ? IntradayPricing.get(curentProdkey).RE_Location__r.name + '_' + IntradayPricing.get(curentProdkey).RE_Relevant_Product__c : '');
            
            
            if(morningCBUMap.containskey(newfuturepbdata.RT_Location__r.Name + '_' + newfuturepbdata.RT_Product__r.Name)){
                newfuturepbdata.RE_CBU_output_date__c = Date.valueof(morningCBUMap.get(newfuturepbdata.RT_Location__r.Name + '_' + newfuturepbdata.RT_Product__r.Name).createddate.addHours(8));
                newfuturepbdata.RE_CBU_MC__c = morningCBUMap.get(newfuturepbdata.RT_Location__r.Name + '_' + newfuturepbdata.RT_Product__r.Name).RE_Costprice_Marginal_Cost__c;
                newfuturepbdata.RE_CBU_LDC__c = morningCBUMap.get(newfuturepbdata.RT_Location__r.Name + '_' + newfuturepbdata.RT_Product__r.Name).RE_Costprice_Laid_Down_Cost__c;
                if(yesterdayPrice.containsKey(newfuturepbdata.RE_Ship_To_Number__c + '_' + newfuturepbdata.RT_Product__r.Name))
                    newfuturepbdata.RE_Yesterday_Final_Price__c=yesterdayPrice.get(newfuturepbdata.RE_Ship_To_Number__c + '_' + newfuturepbdata.RT_Product__r.Name);
                
            }
            else{
                if(morningCBUMap.containsKey(relevantKey)){
                    newfuturepbdata.RE_CBU_output_date__c = Date.valueof(morningCBUMap.get(relevantKey).createddate.addHours(8));
                    newfuturepbdata.RE_CBU_MC__c = morningCBUMap.get(relevantKey).RE_Costprice_Marginal_Cost__c;
                    newfuturepbdata.RE_CBU_LDC__c = morningCBUMap.get(relevantKey).RE_Costprice_Laid_Down_Cost__c;
                    //newfuturepbdata.RE_Is_CBU__c = True;
                    if(yesterdayPrice.containsKey(newfuturepbdata.RE_Ship_To_Number__c + '_' + newfuturepbdata.RT_Product__r.Name))
                        newfuturepbdata.RE_Yesterday_Final_Price__c=yesterdayPrice.get(newfuturepbdata.RE_Ship_To_Number__c + '_' + newfuturepbdata.RT_Product__r.Name);
                    //todaysCBUvalues.add(newfuturepbdata);
                }  
            }
            todaysCBUvalues.add(newfuturepbdata);
        }
        
        if(!todaysCBUvalues.isEmpty())
            upsert todaysCBUvalues;
    }
    
    public static List<RT_Price_Book__c> getDirectpricebookdata(String filtercondition){
        string QueryStr='select Id,RE_First_Calculated_Value__c,RE_CBU_MC_for_Final_Price__c,RE_CBU_LDC_for_Final_Price__c,RecordTypeId,RT_Location__r.Name,RE_Latest_price_dt__c,RT_Product__r.Name ,RE_Validation_1_Value__c,RE_Rebate__c,RE_BDF__c,RE_Validation_2_Value__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.name,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.RE_Editable_Field__c,RE_Customer_Name__r.Type,RE_Contract_Master__r.RE_Customer_Name__r.id,RE_Contract_Master__r.RE_Customer_Name__r.name,RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name,RE_Approver_Comments__c,RE_CBU_output_date__c,';
        QueryStr=QueryStr+'RE_Contract_Master__r.List_Price_Tier__r.Value__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.id,RE_Quantity__c,RE_Contract_Master__r.RT_Plant_Desc__r.Name,RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c, RE_Contract_Master__r.RT_Plant_Desc__r.RE_Region_Name__c ,RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approve__c,RE_Valid_From__c,RE_Valid_To__c,RE_Approved_By__c,RE_Approved_By__r.name,RE_Contract_Master__r.RE_Transport_Mode__c,RE_First_Price__c,RE_CBU_valid_To__c,RE_CBU_valid_from__c,RE_Direct_Valid_From__c,RE_Direct_Valid_To__c,';
        QueryStr=QueryStr+'RE_Contract_Master__r.RE_Standard_Discount__c,RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c ,RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c,RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c,RE_Contract_Master__r.RT_Material_Desc__r.Name,RE_AM_Code__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approved_Value__c,RE_Submitter_Comments__c,RE_Margin_on_LDC__c,';
        QueryStr=QueryStr+'RE_Contract_Master__r.RE_PH_Approval_Scheme__c ,RE_Contract_Master__r.RE_Round_Up__c,RE_Pricing_Level__c,RE_Service_SurChg__c, LastModifiedBy.Name,RE_UoM__c,RE_Unit__c,RE_List_Price__c,RE_Std_Disc__c,RE_Final_Price_Rebate__c,RE_Discount__c,RE_Sold_To_Number__c,RE_Contract_Master__r.RE_Pricing_Levels__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Operator__c,RE_Submitter__c,RE_Submitter__r.name,RE_Margin_above_CBU_MC__c,RE_CBU_LDC__c,RE_Afternoon_Indication__c,RE_Margin_on_MC__c,RE_Temp_Discount__c,RE_Job_Counter__c,';
        QueryStr=QueryStr+'RE_Ship_To_Number__c,RE_MIDday_Price__c,RE_Frequency_record__c,RE_CBU_MC__c,RE_Start_date__c,RE_End_date__c,RE_Custom_Opp_Approve__c,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.RE_Output_Pricing_Condition__c,RE_Margin_above_AfterNoon_Indication__c,RE_Forecast_Margin_on_LDC__c,RE_Forecast_Margin_on_MC__c,RE_DFOA_Charges__c,RE_MidDay_output_date__c,RE_Is_Latest__c,RE_Is_CBU__c,RT_Product__c,RT_Location__c,RT_Country__c,';
        QueryStr=QueryStr+'RE_Contract_Master__c ,RE_CBU_Last_offered__c,RE_Transport_Charge__c,RE_Yesterday_Final_Price__c,RE_Customer_Name__c,RE_Contract_Master__r.RE_Customer_Name__r.type,RE_Sales_Org__c,RE_Customer_Group__c,RE_Material_Code__c,RT_Location_Code__c,RT_Product__r.RE_Material__c  from RT_Price_Book__c where RT_Country__c =\'MY\' AND RE_Is_Latest__c = True  ';
        //QueryStr=QueryStr+' AND RE_Is_CBU__c  = False ';
        QueryStr=QueryStr+(filtercondition != '' && filtercondition != null ? ' AND '+filtercondition:'');
        QueryStr=QueryStr+' order by RE_Latest_price_dt__c desc ';
        system.debug('RE_customOppController.getDirectpricebookdata>>>'+QueryStr);
        return Database.query(QueryStr);
        
    }
    
    //generate frequency data for 2 days pricing
    public static void checkTwodaysFreq(){
        boolean genfreqency = false, genMonfreqency = false, listPriceNextWeek = false,wedfeqdata = false;
        date freqValidFrom,freqValidTo,monFreqValidFrom,monFreqValidTo , wedFreValidFrom, wedFrevalidTo;
        
        //List<String> holidaysDate= new List<String>();
        Datetime currentDay = (DateTime)System.today();
        Datetime D_1 = currentDay.adddays(1);
        Datetime D_2 = currentDay.adddays(2);
        Datetime D_3 = currentDay.adddays(3);
        
        String dayOfWeek = currentDay.format('EEEE');
        String D_1dayOfWeek = D_1.format('EEEE');
        String D_2dayOfWeek = D_2.format('EEEE');
        
        //Malaysia Holiday Map
        //for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'MY Holiday Calendar'])
        //holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
        
        
        if(dayOfWeek == 'Friday' || (dayOfWeek == 'Thursday' && holidaysDate.contains(string.valueof(D_1))))
        { 
            genfreqency = true;
            listPriceNextWeek = true;
            freqValidFrom = (dayOfWeek == 'Thursday' ? date.valueOf(currentDay.adddays(4)) : date.valueOf(currentDay.adddays(3)));
            freqValidTo = (dayOfWeek == 'Thursday' ? date.valueOf(currentDay.adddays(5)) : date.valueOf(currentDay.adddays(4)));
        }
        if(dayOfWeek == 'Monday' || (dayOfWeek == 'Friday' && holidaysDate.contains(string.valueof(D_3))))
        { 
            if(dayOfWeek == 'Monday'){
                genfreqency = true;
                freqValidFrom = date.valueOf(currentDay.adddays(2));
                freqValidTo = date.valueOf(currentDay.adddays(3));
            }
            if(dayOfWeek == 'Friday'){
                genMonfreqency = true;
                monFreqValidFrom = date.valueOf(currentDay.adddays(5));
                monFreqValidTo = date.valueOf(currentDay.adddays(6));
            }
            
        }
        if(dayOfWeek == 'Wednesday' || (dayOfWeek == 'Tuesday' && holidaysDate.contains(string.valueof(D_1))))
        { 
            genfreqency = true;
            wedfeqdata = true;
            freqValidFrom = (dayOfWeek == 'Tuesday' ? date.valueOf(currentDay.adddays(3)) : date.valueOf(currentDay.adddays(2)));
            freqValidTo = (dayOfWeek == 'Tuesday' ? date.valueOf(currentDay.adddays(5)) : date.valueOf(currentDay.adddays(4)));
            // data generation Wednesday validfrom Saturday to Firday
            wedFreValidFrom = (dayOfWeek == 'Tuesday' ? date.valueOf(currentDay.adddays(4)) : date.valueOf(currentDay.adddays(3)));
            wedFrevalidTo =  (dayOfWeek == 'Tuesday' ? date.valueOf(currentDay.adddays(10)) : date.valueOf(currentDay.adddays(9)));
        }
        
        if(Test.isRunningTest()){
            genfreqency = true;
        }
        if(genfreqency || wedfeqdata){
            List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
            Map<string,decimal> cbuprice= new  Map<string,decimal>(); 
            Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('MY Price Book').getRecordTypeId();
            
            for(RT_Price_Book__c pbdataCBU : [Select Id,RE_Is_Latest__c,RE_Ship_To_Number__c,RE_Is_CBU__c,RE_Final_Price_Rebate__c,RT_Location__r.Name,RT_Product__r.Name,RE_CBU_MC__c from RT_Price_Book__c where RE_Is_Latest__c = True AND RE_Is_CBU__c = True AND RE_Contract_Master__r.RE_Customer_Name__r.type = 'Direct' AND RE_Frequency_record__c=false AND  RT_Country__c ='MY']){
                cbuprice.put(pbdataCBU.RE_Ship_To_Number__c + '_' + pbdataCBU.RT_Product__r.Name,pbdataCBU.RE_Final_Price_Rebate__c); 
            }
            
            //Double afternoonIndication = RE_SOQLController.fetchAfternoonIndication();
            Double standdisc;
            
            for(REV_Contract_Master__c contractdata : contractListDirect){  
                if( (contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct without transport charge) - 2 days validity' && genfreqency)
                   || (contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - Eff Sat to Fri' && wedfeqdata)){
                    
                    string key = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name;
                    string intradyPricekey = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name +'_'+contractdata.RE_Sales_Org__r.Value__c;
                    string relevantKey = (IntradayPricing.containsKey(intradyPricekey) ? IntradayPricing.get(intradyPricekey).RE_Location__r.name + '_' + IntradayPricing.get(intradyPricekey).RE_Relevant_Product__c : '');
                    double intradayPrice = double.valueOf( (IntradayPricing.containsKey(intradyPricekey) ? (IntradayPricing.get(intradyPricekey).Value__c != null ? IntradayPricing.get(intradyPricekey).Value__c : '0' ): '0'));
                    RT_Price_Book__c pbdata = new RT_Price_Book__c();
                    pbdata.recordtypeId = pricebookrectypeid;
                    pbdata.RE_Is_CBU__c  = False;
                    pbdata.RE_Is_Latest__c = True;
                    pbdata.RE_Job_Counter__c = 0;
                    pbdata.RE_CBU_MC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_MC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_MC_Morning__c : 0);
                    pbdata.RE_CBU_LDC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_LDC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_LDC_Morning__c : 0);
                   // pbdata.RE_Afternoon_Indication__c = afternoonIndication;
                    pbdata.RE_Afternoon_Indication__c = afternoonIndicationMap.containsKey(key) ? afternoonIndicationMap.get(key) : (afternoonIndicationMap.containsKey(relevantKey) ? afternoonIndicationMap.get(relevantKey) : 0);
                	double AftIndication = pbdata.RE_Afternoon_Indication__c;
                    standdisc = (contractdata.RE_Standard_Discount__c != null) ? contractdata.RE_Standard_Discount__c : 0;   
                    pbdata.RE_CBU_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).createddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).createddate : system.today()).addHours(8));
                    pbdata.RE_MidDay_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).lastmodifieddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).lastmodifieddate : system.today()).addHours(8));
                    pbdata.RE_Transport_Charge__c = contractdata.RE_Transport_Charges__c !=null ? contractdata.RE_Transport_Charges__c : 0;
                    pbdata.RE_Service_SurChg__c = contractdata.RE_Service_SurChg__c != null ? contractdata.RE_Service_SurChg__c : 0;
                    pbdata.RE_DFOA_Charges__c = contractdata.RE_DFOA_Charges__c != null ? contractdata.RE_DFOA_Charges__c : 0;
                    pbdata.RE_Pricing_Level__c  = contractdata.RE_Pricing_Levels__c != null ? contractdata.RE_Pricing_Levels__c : 0;
                    pbdata.RE_Rebate__c=contractdata.RE_Rebate__c != null ? contractdata.RE_Rebate__c : 0;
                    pbdata.RE_BDF__c=contractdata.RE_BDF__c != null ? contractdata.RE_BDF__c : 0;   
                    pbdata.RE_UoM__c='L';
                    pbdata.RE_Unit__c='MYR';
                    pbdata.RE_Quantity__c=100;
                    if(cbuprice.containsKey(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name))
                        pbdata.RE_Yesterday_Final_Price__c=cbuprice.get(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name);
                    pbdata.RE_MIDday_Price__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_Final_PSP__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_Final_PSP__c : 0);
                    
                    pbdata.RT_Country__c = contractdata.Country_Name__c;	
                    pbdata.RE_Latest_price_dt__c = DateTime.now();
                    pbdata.RE_Contract_Master__c = contractdata.Id;
                    pbdata.RE_Customer_Name__c = contractdata.RE_Customer_Name__c;
                    pbdata.RT_Product__c = contractdata.RT_Material_Desc__c;
                    pbdata.RT_Location__c = contractdata.RT_Plant_Desc__c;
                    pbdata.RE_Std_Disc__c = standdisc;
                       pbdata.RE_CBU_MC_for_Final_Price__c = pbdata.RE_CBU_MC__c;
                       pbdata.RE_CBU_LDC_for_Final_Price__c = pbdata.RE_CBU_LDC__c;
                    pbdata.RE_Valid_From__c = freqValidFrom;
                    pbdata.RE_Valid_To__c =  freqValidTo;
                       if(contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - Eff Sat to Fri'){
                           pbdata.RE_Valid_From__c = wedFreValidFrom;
                           pbdata.RE_Valid_To__c =  wedFrevalidTo;
                       }
                    pbdata.RE_Direct_Valid_From__c = pbdata.RE_Valid_From__c;
                    pbdata.RE_Direct_Valid_To__c = pbdata.RE_Valid_To__c;
                    pbdata.RE_Custom_Opp_Approve__c ='Auto Approved';
                    
                    if(listPriceNextWeek){
                         pbdata.RE_List_Price__c = directListNextWeek.containsKey(contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name) ? 
                            directListNextWeek.get( contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name).RE_Final_PSP__c : 0;                        
                    }
                    else{
                        pbdata.RE_List_Price__c = directListCurrentWeek.containsKey(contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name) ? 
                            directListCurrentWeek.get( contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name).RE_Final_PSP__c : 0;                        
                    }
                    
                    pbdata.RE_Pricing_Level__c = contractdata.RE_Pricing_Levels__c != null ? contractdata.RE_Pricing_Levels__c : 0;
                    decimal dfoacharges=(pbdata.RE_DFOA_Charges__c != null ? pbdata.RE_DFOA_Charges__c : 0);
                    pbdata.RE_Validation_1_Value__c= (pbdata.RE_MIDday_Price__c != null ? pbdata.RE_MIDday_Price__c : 0 ) + dfoacharges + 1 + intradayPrice;
                    pbdata.RE_Validation_2_Value__c= (pbdata.RE_CBU_LDC__c != null ? pbdata.RE_CBU_LDC__c : 0 ) + dfoacharges + (AftIndication != null ? AftIndication :0) + (pbdata.RE_Pricing_Level__c != null ? pbdata.RE_Pricing_Level__c:0 ) + intradayPrice;
                    if (pbdata.RE_Validation_1_Value__c >  pbdata.RE_Validation_2_Value__c)
                        pbdata.RE_Final_Price_Rebate__c = contractdata.RE_Round_Up__c ?  roundUpcustom(pbdata.RE_Validation_1_Value__c) : pbdata.RE_Validation_1_Value__c;
                    else
                        pbdata.RE_Final_Price_Rebate__c = contractdata.RE_Round_Up__c ?  roundUpcustom(pbdata.RE_Validation_2_Value__c) : pbdata.RE_Validation_2_Value__c;                
                    pbdata.RE_Discount__c = (pbdata.RE_List_Price__c-  pbdata.RE_Final_Price_Rebate__c).setScale(2);                    
                    
                       if(contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - Eff Sat to Fri' && wedfeqdata)
                           pbdata.RE_Discount__c = (pbdata.RE_Discount__c +  pbdata.RE_Transport_Charge__c).setScale(2);                    
                    
                    pbdata.RE_First_Price__c = pbdata.RE_Final_Price_Rebate__c;
                    pbdata.RE_Frequency_record__c = True; 
                    
                    pricebookList.add(pbdata);
                       if(genMonfreqency && contractdata.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct without transport charge) - 2 days validity' ){
                        RT_Price_Book__c mondayData = new RT_Price_Book__c();
                        mondayData = pbdata.clone(false, true, false, false);
                        mondayData.id= null;
                        mondayData.RE_Valid_From__c = monFreqValidFrom;
                        mondayData.RE_Valid_To__c =  monFreqValidTo; 
                        pricebookList.add(mondayData);
                    }                    
                }
                
                
            }
            if(!pricebookList.isEmpty())
                insert pricebookList;              
            
        } 
    }
    
    //
    //This Method will return Valid from and Valid to for 2 days frequency
    public static void frequencyForTwoDays(){
        
        Datetime currentDay = (DateTime)System.today();
        
        String dayOfWeek = currentDay.format('EEEE');
        if(dayOfWeek == 'Monday' || dayOfWeek == 'Wednesday'){
            validFromFqTwo = date.valueOf(currentDay.adddays(1));
            ValidTofqTwo = date.valueOf(currentDay.adddays(1));
        }
        if(dayOfWeek == 'Tuesday' || dayOfWeek == 'Thursday' || dayOfWeek == 'Friday'){
            validFromFqTwo = date.valueOf(currentDay.adddays(1));
            if(dayOfWeek == 'Tuesday' || dayOfWeek == 'Friday')
                ValidTofqTwo = date.valueOf(currentDay.adddays(2));
            else
                ValidTofqTwo = date.valueOf(currentDay.adddays(3));
        }
    }   
    
    //This Method will return Valid from and Valid to for wednesday data generation model
    public static void frequencyForWedsDays(){
        
        Date validTo = system.today().toStartofWeek().adddays(4);
        Datetime currentDay = (DateTime)System.today();        
        String dayOfWeek = currentDay.format('EEEE');
        validFromWed = date.valueOf(currentDay.adddays(1));
        if(dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday' && dayOfWeek != 'Friday')            
            validTowed = validTo;
       	else
            validTowed = validTo.addDays(7);
        
    }
    
    //This method will return till what day records show in the CBU dashboard 
    public static integer getfrequencyTo(){
        integer Freqnumber=0;
        //List<String> holidaysDate= new List<String>();
        Datetime currentDay = (DateTime)System.today();
        Datetime D_1 = currentDay.adddays(1);
        Datetime D_2 = currentDay.adddays(2);
        Datetime D_3 = currentDay.adddays(3);
        
        String dayOfWeek = currentDay.format('EEEE');
        String D_1dayOfWeek = D_1.format('EEEE');
        String D_2dayOfWeek = D_2.format('EEEE');
        
        //for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'MY Holiday Calendar' ])
        // holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
        
        if((dayOfWeek == 'Tuesday' || dayOfWeek == 'Wednesday' || dayOfWeek == 'Thursday') && holidaysDate.contains(string.valueof(currentDay)))
            Freqnumber=1;
        if(dayOfWeek == 'Friday' && holidaysDate.contains(string.valueof(currentDay) ))
            Freqnumber=3;
        if(dayOfWeek == 'Saturday' )
            Freqnumber=2;
        if(dayOfWeek == 'Saturday' && holidaysDate.contains(string.valueof(D_2) ))
            Freqnumber=3;
        
        return Freqnumber;
    }    
    //This method will update Reseller valid from and Valid to.
    public static void getResellerfrequency(){
        resllerFreqnumber=1;
        //List<String> holidaysDate= new List<String>();
        Datetime currentDay = (DateTime)System.today();
        Datetime D_1 = currentDay.adddays(1);
        Datetime D_2 = currentDay.adddays(2);
        Datetime D_3 = currentDay.adddays(3);
        
        String dayOfWeek = currentDay.format('EEEE');
        String D_1dayOfWeek = D_1.format('EEEE');
        String D_2dayOfWeek = D_2.format('EEEE');
        
        //for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'MY Holiday Calendar' ])
        //holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
        
        
        if(dayOfWeek == 'Friday' || (dayOfWeek == 'Thursday' && holidaysDate.contains(string.valueof(D_1))) ||  (dayOfWeek == 'Wednesday' && holidaysDate.contains(string.valueof(D_1)) && holidaysDate.contains(string.valueof(D_2)))) 
            generateDirectPB = true;
        
        if(dayOfWeek == 'Friday')
            resllerFreqnumber=3;
        
        if(dayOfWeek == 'Friday' && holidaysDate.contains(string.valueof(D_3)))
            resllerFreqnumber=4;
        
        if(holidaysDate.contains(string.valueof(D_1))  && (D_1dayOfWeek != 'Saturday' && D_1dayOfWeek != 'Sunday')){
            resllerFreqnumber=2;
            
            if(holidaysDate.contains(string.valueof(D_2))  && (D_2dayOfWeek != 'Saturday' && D_2dayOfWeek != 'Sunday'))
                resllerFreqnumber=3;
            if(dayOfWeek == 'Thursday')
                resllerFreqnumber = 4; 
            if(DayOfWeek == 'Wednesday' && holidaysDate.contains(string.valueof(D_2)))
                resllerFreqnumber = 5;        
        }
        
    }
    
    //Custom Round Up 
    //0.01 - 0.49 > round up to 0.50
    //0.50 - 0.50 = remain as it is
    //0.51 - 0.99 > round up to whole number
    public static decimal roundUpcustom (decimal finalPrice){
        decimal finalValue = finalPrice;
        Integer integerFinalPrice = Integer.valueOf(finalPrice);
        decimal decimalValue = finalPrice - integerFinalPrice;
        
        if(decimalValue <= 0.5 && decimalValue != 0)
            finalValue= integerFinalPrice +0.5;
        if(decimalValue > 0.5 && decimalValue != 0) 
            finalValue= integerFinalPrice +1;
        
        return finalValue;
    }
    
    //Refresh CBU values in CO dashboard(CBU view)
    public static void updateLatestCBU(){
        createListPrice();
        todayCBU();
        List<RT_Price_Book__c> todaysCBUvalues = new List<RT_Price_Book__c>();
        for(RT_Price_Book__c resellerMidDay :[Select Id, RE_Is_Latest__c, RE_CBU_valid_from__c, RE_CBU_valid_To__c, RE_Ship_To_Number__c, RE_Is_CBU__c, RE_Final_Price_Rebate__c,
                                              RT_Location__r.Name,RE_Sales_Org__c,RE_CBU_LDC__c, RT_Product__r.Name,RE_CBU_MC__c from RT_Price_Book__c where RE_Is_Latest__c = True AND RE_Is_CBU__c = True AND 
                                              RT_Country__c ='MY' ] ){
                                                  
                                                  string curentProdkey = resellerMidDay.RT_Location__r.Name+'_'+resellerMidDay.RT_Product__r.Name +'_' +resellerMidDay.RE_Sales_Org__c;
                                                  string relevantKey = (IntradayPricing.containsKey(curentProdkey) ? IntradayPricing.get(curentProdkey).RE_Location__r.name + '_' + IntradayPricing.get(curentProdkey).RE_Relevant_Product__c : '');
                                                  
                                                  if(morningCBUMap.containskey(resellerMidDay.RT_Location__r.Name + '_' + resellerMidDay.RT_Product__r.Name)){
                                                      resellerMidDay.RE_CBU_MC__c = morningCBUMap.get(resellerMidDay.RT_Location__r.Name + '_' + resellerMidDay.RT_Product__r.Name).RE_Costprice_Marginal_Cost__c;
                                                      resellerMidDay.RE_CBU_LDC__c = morningCBUMap.get(resellerMidDay.RT_Location__r.Name + '_' + resellerMidDay.RT_Product__r.Name).RE_Costprice_Laid_Down_Cost__c;
                                                      
                                                  }
                                                  else{
                                                      if(morningCBUMap.containsKey(relevantKey)){
                                                          resellerMidDay.RE_CBU_MC__c = morningCBUMap.get(relevantKey).RE_Costprice_Marginal_Cost__c;
                                                          resellerMidDay.RE_CBU_LDC__c = morningCBUMap.get(relevantKey).RE_Costprice_Laid_Down_Cost__c;
                                                      }  
                                                  }
                                                  todaysCBUvalues.add(resellerMidDay);
                                              }
        
        if(!todaysCBUvalues.isEmpty())
            update todaysCBUvalues;
    }
    
    //create map for Malaysia holiday list
    public static List<String> myHolidaylist(){
        List<String> holidaysDateList= new List<String>();
        //for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) ])
        
        for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'MY Holiday Calendar' ])
            holidaysDateList.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
        
        return holidaysDateList;
    }
    
    
    //Direct customer Opps daily data generation 
    public static void generateDirectDaily( List<REV_Contract_Master__c> contractListDir){
        List<String> approvedStatus = new List<String>{'Approved','Auto Approved','Ready to Upload','Uploaded','Failed','Upload not allowed'};
            //stores MidDay new Pricebook record for today
            List<RT_Price_Book__c> pricebookList = new List<RT_Price_Book__c>();
        //CBU Pricebook records valid for today
        Map<Id,RT_Price_Book__c> oldpricebook = new Map<Id,RT_Price_Book__c> (); 
        //last offered price
        Map<string,decimal> cbuprice= new  Map<string,decimal>();
        Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('MY Price Book').getRecordTypeId();
        for(RT_Price_Book__c pbdadta : [
            SELECT RE_Contract_Master__c,Id,RE_Latest_price_dt__c,RE_CBU_MC_for_Final_Price__c,RE_CBU_LDC_for_Final_Price__c,RE_Is_CBU__c,RE_Ship_To_Number__c,RE_Custom_Opp_Approve__c,RT_Product__r.Name, RT_Country__c,RE_Customer_Name__c,RE_Rebate__c,RE_BDF__c, RT_Product__c,RT_Location__c,RE_Service_SurChg__c,RE_Margin_on_LDC__c,RE_First_Calculated_Value__c,RE_Validation_1_Value__c,
            RE_Std_Disc__c,RE_Valid_From__c, RE_Valid_To__c, RE_List_Price__c,RE_Final_Price_Rebate__c,RE_Discount__c,RE_Transport_Charge__c,RE_Pricing_Level__c,RE_Validation_2_Value__c,
            RE_Margin_on_MC__c,RE_Forecast_Margin_on_LDC__c,RE_Forecast_Margin_on_MC__c,RE_DFOA_Charges__c,RE_First_Price__c,RE_Job_Counter__c
            FROM RT_Price_Book__c 
            where RE_Is_Latest__c = True AND RE_Contract_Master__r.RE_Customer_Name__r.type = 'Direct' AND RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name = 'Direct As Reseller Price Adjustment (with transport charge)'   
            AND RE_Valid_To__c > Today AND RE_Valid_From__c <= Tomorrow AND RE_Custom_Opp_Approve__c =:approvedStatus AND recordtypeId =:pricebookrectypeid order by RE_Latest_price_dt__c desc]){
                if(!oldpricebook.containskey(pbdadta.RE_Contract_Master__c) ){
                    oldpricebook.put(pbdadta.RE_Contract_Master__c,pbdadta);                    
                }                
            }  
        for(RT_Price_Book__c pbdataCBU : [Select Id,RE_Is_Latest__c,RE_Ship_To_Number__c,RE_Is_CBU__c,RE_Final_Price_Rebate__c,RT_Location__r.Name,RT_Product__r.Name,RE_CBU_MC__c from RT_Price_Book__c where RE_Contract_Master__r.RE_Customer_Name__r.type ='Direct'  AND RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name = 'Direct As Reseller Price Adjustment (with transport charge)' AND RE_Is_Latest__c = True AND RE_Is_CBU__c = True]){
            cbuprice.put(pbdataCBU.RE_Ship_To_Number__c + '_' + pbdataCBU.RT_Product__r.Name,pbdataCBU.RE_Final_Price_Rebate__c); 
        }
        Double standdisc;
        for(REV_Contract_Master__c contractdata : contractListDir){
            if(contractdata.RE_Custom_Ops_Calculation__r.Name == 'Direct As Reseller Price Adjustment (with transport charge)'){
                string key = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name;
                string intradyPricekey = contractdata.RT_Plant_Desc__r.Name+'_'+contractdata.RT_Material_Desc__r.Name +'_'+contractdata.RE_Sales_Org__r.Value__c;
                string relevantKey = (IntradayPricing.containsKey(intradyPricekey) ? IntradayPricing.get(intradyPricekey).RE_Location__r.name + '_' + IntradayPricing.get(intradyPricekey).RE_Relevant_Product__c : '');
                double intradayPrice = double.valueOf( (IntradayPricing.containsKey(intradyPricekey) ? (IntradayPricing.get(intradyPricekey).Value__c != null ? IntradayPricing.get(intradyPricekey).Value__c : '0' ): '0'));
                RT_Price_Book__c pbdata = new RT_Price_Book__c();
                pbdata.recordtypeId = pricebookrectypeid;
                pbdata.RE_Is_CBU__c  = False;
                pbdata.RE_Is_Latest__c = True;
                pbdata.RE_Job_Counter__c = 0;
                pbdata.RE_Frequency_record__c=false;
                pbdata.RE_CBU_MC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_MC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_MC_Morning__c : 0);
                    
                    pbdata.RE_CBU_LDC__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_LDC_Morning__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_LDC_Morning__c : 0);
                        
                        pbdata.RE_Afternoon_Indication__c = afternoonIndicationMap.containsKey(key) ? afternoonIndicationMap.get(key) : (afternoonIndicationMap.containsKey(relevantKey) ? afternoonIndicationMap.get(relevantKey) : 0);
                            double AftIndication = pbdata.RE_Afternoon_Indication__c;
                standdisc = (contractdata.RE_Standard_Discount__c != null) ? contractdata.RE_Standard_Discount__c : 0; 
                pbdata.RE_CBU_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).createddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).createddate : system.today()).addHours(8));
                pbdata.RE_MidDay_output_date__c = Date.valueOf(todayMOAMap.containsKey(key) ? todayMOAMap.get(key).lastmodifieddate : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).lastmodifieddate : system.today()).addHours(8));
                pbdata.RE_Transport_Charge__c = contractdata.RE_Transport_Charges__c !=null ? contractdata.RE_Transport_Charges__c : 0;
                pbdata.RE_Service_SurChg__c = contractdata.RE_Service_SurChg__c != null ? contractdata.RE_Service_SurChg__c : 0;
                pbdata.RE_DFOA_Charges__c = contractdata.RE_DFOA_Charges__c != null ? contractdata.RE_DFOA_Charges__c : 0;
                pbdata.RE_Pricing_Level__c  = contractdata.RE_Pricing_Levels__c != null ? contractdata.RE_Pricing_Levels__c : 0;
                pbdata.RE_Rebate__c=contractdata.RE_Rebate__c != null ? contractdata.RE_Rebate__c : 0;
                pbdata.RE_BDF__c=contractdata.RE_BDF__c != null ? contractdata.RE_BDF__c : 0;   
                pbdata.RE_UoM__c='L';
                pbdata.RE_Unit__c='MYR';
                pbdata.RE_Quantity__c=100;
                if(cbuprice.containsKey(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name))
                    pbdata.RE_Yesterday_Final_Price__c=cbuprice.get(contractdata.RE_Customer_Name__r.AccountNumber + '_' + contractdata.RT_Material_Desc__r.Name);
                pbdata.RE_MIDday_Price__c = todayMOAMap.containsKey(key) ? todayMOAMap.get(key).RE_Final_PSP__c : (todayMOAMap.containsKey(relevantKey) ? todayMOAMap.get(relevantKey).RE_Final_PSP__c : 0);
                    
                    //checks price book record valid till tomorrow
                    if(oldpricebook.containsKey(contractdata.Id)){
                        pbdata.RT_Country__c = oldpricebook.get(contractdata.Id).RT_Country__c;	
                        pbdata.RE_Contract_Master__c = oldpricebook.get(contractdata.Id).RE_Contract_Master__c;	
                        pbdata.RE_Customer_Name__c = oldpricebook.get(contractdata.Id).RE_Customer_Name__c;	
                        pbdata.RT_Product__c = oldpricebook.get(contractdata.Id).RT_Product__c;	
                        pbdata.RT_Location__c = oldpricebook.get(contractdata.Id).RT_Location__c;	
                        pbdata.RE_Std_Disc__c = standdisc;	
                        pbdata.RE_Latest_price_dt__c = oldpricebook.get(contractdata.Id).RE_Latest_price_dt__c.addMinutes(1);
                        pbdata.RE_Valid_From__c = System.today().addDays(1);
                        Date systemToday = system.today().addDays( 1 );
                        Date ValidEndDate=oldpricebook.get(contractdata.Id).RE_Valid_To__c;
                        Integer noOfDays = systemToday.daysBetween( ValidEndDate );
                        if(noOfDays <= resllerFreqnumber)                    
                            pbdata.RE_Valid_To__c = system.today().addDays( resllerFreqnumber );
                        else 
                            pbdata.RE_Valid_To__c = oldpricebook.get(contractdata.Id).RE_Valid_To__c;
                        
                        pbdata.RE_List_Price__c = oldpricebook.get(contractdata.Id).RE_List_Price__c;
                        pbdata.RE_Final_Price_Rebate__c = oldpricebook.get(contractdata.Id).RE_First_Price__c;
                        pbdata.RE_Discount__c = oldpricebook.get(contractdata.Id).RE_Discount__c;
                        pbdata.RE_First_Price__c = pbdata.RE_Final_Price_Rebate__c;     
                        pbdata.RE_Custom_Opp_Approve__c = oldpricebook.get(contractdata.Id).RE_Custom_Opp_Approve__c; 
                        pbdata.RE_Direct_Valid_From__c = pbdata.RE_Valid_From__c;
                        pbdata.RE_Direct_Valid_To__c = pbdata.RE_Valid_To__c;
                        pbdata.RE_CBU_MC_for_Final_Price__c = oldpricebook.get(contractdata.Id).RE_CBU_MC_for_Final_Price__c != null ? oldpricebook.get(contractdata.Id).RE_CBU_MC_for_Final_Price__c : 0.00;
                        pbdata.RE_CBU_LDC_for_Final_Price__c = oldpricebook.get(contractdata.Id).RE_CBU_LDC_for_Final_Price__c != null ? oldpricebook.get(contractdata.Id).RE_CBU_LDC_for_Final_Price__c : 0.00;
                    }
                else{                    
                    double finalPrice;
                    pbdata.RE_CBU_MC_for_Final_Price__c = pbdata.RE_CBU_MC__c;
                    pbdata.RE_CBU_LDC_for_Final_Price__c = pbdata.RE_CBU_LDC__c;
                    pbdata.RT_Country__c = contractdata.Country_Name__c;
                    pbdata.RE_Latest_price_dt__c = DateTime.now();
                    pbdata.RE_Contract_Master__c = contractdata.Id;
                    pbdata.RE_Customer_Name__c = contractdata.RE_Customer_Name__c;
                    pbdata.RT_Product__c = contractdata.RT_Material_Desc__c;
                    pbdata.RT_Location__c = contractdata.RT_Plant_Desc__c;
                    pbdata.RE_Std_Disc__c = standdisc;
                    pbdata.RE_Valid_From__c = System.today().addDays(1);
                    pbdata.RE_Valid_To__c =  System.today().addDays(resllerFreqnumber);
                    pbdata.RE_Direct_Valid_From__c = pbdata.RE_Valid_From__c;
                    pbdata.RE_Direct_Valid_To__c = pbdata.RE_Valid_To__c;
                    pbdata.RE_Custom_Opp_Approve__c ='Auto Approved';
                    pbdata.RE_Frequency_record__c = true;
                    
                    pbdata.RE_List_Price__c =  directListCurrentWeek.containsKey(contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name) ? 
                        directListCurrentWeek.get( contractdata.RE_Sales_Org__r.Value__c+'_'+contractdata.RT_Material_Desc__r.Name).RE_Final_PSP__c : 0;                     
                    
                    finalPrice = pbdata.RE_MIDday_Price__c + pbdata.RE_Transport_Charge__c + pbdata.RE_Pricing_Level__c + intradayPrice ;
                    pbdata.RE_Final_Price_Rebate__c = (contractdata.RE_Round_Up__c ? roundUpcustom(finalPrice) : finalPrice);                    
                    pbdata.RE_First_Price__c = pbdata.RE_Final_Price_Rebate__c;
                    pbdata.RE_Discount__c = (pbdata.RE_List_Price__c-  pbdata.RE_Final_Price_Rebate__c + pbdata.RE_Transport_Charge__c).setScale(2);
                }
                pricebookList.add(pbdata);                
            }
        }
        
        if(!pricebookList.isEmpty())           
            insert pricebookList;  
    }
}