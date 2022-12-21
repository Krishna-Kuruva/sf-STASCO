/*************************************************************************************
@Name:  RE_customOppController         
@=================================================================================
@Purpose: This class process the PriceBook data based on CustmerType(Reseller / Direct) assign value 
to wrapper class (RE_customerOppWrapper) which is used in LWC to display data(RE_customerOppWrapper).
@=================================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                                                 
@2.0 - Vijaykumar S    ```````````````    15-Feb-2021              
*************************************************************************************/
public class RE_customOppController {   
    public static List<String> approvedStatus = new List<String>{'Approved','Auto Approved','Ready to Upload','Uploaded','Failed','Upload not allowed'};
    static string  filterCondition=[Select id, RE_Customer_Opps_team__c from user where id=:UserInfo.getUserId()].RE_Customer_Opps_team__c;
    public static Map<string ,RE_CustomOpps_ReportConfiguration__c> reportdetails=new Map<String,RE_CustomOpps_ReportConfiguration__c>();
    public static List<RT_Price_Book__c> priceBookdataDateFilter=new List<RT_Price_Book__c>();
    public static boolean checkdatefilter=false , CheckRetry = false;
    public Static string filterDate='' , filterView='' , customerTypeEmail = ''; 
    
    //Approval Process declaration
    Public Static Map<String , Map< String , RT_Setting__c >> approvalscheme = new Map<String , Map< String , RT_Setting__c>>();
    Public static Map<String , Double> backStopMargin = new Map<String,Double>();
    
    @AuraEnabled(cacheable=false)
    public static RE_customerOppWrapper.getcustomerOppdata getallData(string datefilter, boolean isMidDay){
        Map<String,String> accessInfo=getAccessInfo(filterCondition);
        date cubDate;
        date midDayDate; 
        //reseller filter picklist values
        List<RE_customerOppWrapper.picklistdata> resellerPlant= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> resellerMaterial= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> resellercustomer= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> resellerAMcode= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> resellerSoldTo= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> resellerCalMod= new List<RE_customerOppWrapper.picklistdata>();
        
        
        //direct filter picklist values
        List<RE_customerOppWrapper.picklistdata> directPlant= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> DirectMaterial= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> directcustomer= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> directAMcode= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> directSoldTo= new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> directCalMod= new List<RE_customerOppWrapper.picklistdata>();
        //Reseller and Direct PriceBook data
        list<RE_customerOppWrapper.pricebookdata> resellerdata =new list<RE_customerOppWrapper.pricebookdata>();
        list<RE_customerOppWrapper.pricebookdata> directdata =new list<RE_customerOppWrapper.pricebookdata>();
        
        //Picklist and PriceBook data 
        RE_customerOppWrapper.resellerlist resellerAlldata= new RE_customerOppWrapper.resellerlist();
        RE_customerOppWrapper.directlist directAlldata=new RE_customerOppWrapper.directlist();
        
        //final data of PriceBook , picklist details of Reseller and Direct
        RE_customerOppWrapper.getcustomerOppdata customOppdata=new RE_customerOppWrapper.getcustomerOppdata();
        list<RT_Price_Book__c> oppsAlldata = new list<RT_Price_Book__c>();
        if(checkdatefilter)
            oppsAlldata=priceBookdataDateFilter;
        else
            oppsAlldata =getpricebookdata(accessInfo.get('FilterCondition'),isMidDay);
        
        //to find unique values for Reseller filters 
        set<string> plantRes=new set<string>();
        set<string> matRes=new set<string>();
        set<string> customerNameRes=new set<string>();
        set<string> soldToRes=new set<string>();
        set<string> amCodeRes=new set<string>();
        set<string> ClaRes=new set<string>();
        
        //PBI 1420266 start
        set<string> customerResSet=new set<string>();
        set<string> customerDirSet=new set<string>();
        //PBI 1420266 ends
        
        //to find unique values for Direct filters 
        set<string> plantDir=new set<string>();
        set<string> matDir=new set<string>();
        set<string> customerNameDir=new set<string>();
        set<string> soldToDir=new set<string>();
        set<string> amCodeDir=new set<string>();
        set<string> ClaDir=new set<string>();
        
        //initial picklist values
        RE_customerOppWrapper.picklistdata temallSelected=new RE_customerOppWrapper.picklistdata();
        temallSelected.label='All';
        temallSelected.value='All';
        //initial picklist value to All for Reseller filter        
        resellerSoldTo.add(temallSelected);  
        resellerCalMod.add(temallSelected);
        
        //initial picklist value to All for Direct filter        
        directSoldTo.add(temallSelected);
        directCalMod.add(temallSelected);
        
        
        for(RT_Price_Book__c updatewrapper:oppsAlldata){
            
            cubDate =updatewrapper.RE_CBU_output_date__c;
            midDayDate =updatewrapper.RE_MidDay_output_date__c;
            //this variable holds the Price book list temporarily and finally add to the main list 
            RE_customerOppWrapper.pricebookdata tempOppdata =new RE_customerOppWrapper.pricebookdata();
            
            //temporary variables for picklist values
            RE_customerOppWrapper.picklistdata temPlant=new RE_customerOppWrapper.picklistdata();
            RE_customerOppWrapper.picklistdata temMaterial=new RE_customerOppWrapper.picklistdata();
            RE_customerOppWrapper.picklistdata temcustomer=new RE_customerOppWrapper.picklistdata();
            RE_customerOppWrapper.picklistdata temSlodTo=new RE_customerOppWrapper.picklistdata();
            RE_customerOppWrapper.picklistdata temAMcode=new RE_customerOppWrapper.picklistdata();  
            RE_customerOppWrapper.picklistdata temCalculationMod=new RE_customerOppWrapper.picklistdata();
            
            //add plant to picklist value            
            temPlant.label=updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c;
            temPlant.value=updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c;
            //add Material to picklist value
            temMaterial.label=updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c;            
            temMaterial.value=updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c;
            //add Customer to picklist value
            /*temcustomer.label=updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.name;
            temcustomer.value=updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.id;*/
            temcustomer.label = (updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c =='Ship To' ?
                                        updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.name : 
                                        updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.name);
            temcustomer.value =  (updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c =='Ship To' ?
                                        updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.Id : 
                                     updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.Id);  
            string custId = (updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c =='Ship To' ?
                                        updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.Id : 
                                     updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.Id);
            //add Sold to picklist value
            temSlodTo.label=string.valueOf(updatewrapper.RE_Sold_To_Number__c);
            temSlodTo.value=string.valueOf(updatewrapper.RE_Sold_To_Number__c);
            //add AMcode to picklist value
            temAMcode.label=updatewrapper.RE_AM_Code__c;
            temAMcode.value=updatewrapper.RE_AM_Code__c;
            //add Final Price calculation model 
            temCalculationMod.label=updatewrapper.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name;
            temCalculationMod.value=updatewrapper.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name;
            
            //get the map data for pricebook data
            tempOppdata=getMapOfPriceBookdata(updatewrapper,accessInfo); 
            
            if(updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.type =='Reseller'){
                //check plant is added to picklist
                if(!plantRes.contains(updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c)){
                    resellerPlant.add(temPlant);
                    plantRes.add(updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c);
                }                
                //check Material is added to picklist
                if(!matRes.contains(updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c)){
                    resellerMaterial.add(temMaterial);
                    matRes.add(updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c);
                }
                //check customer name added to picklist
                if(!customerNameRes.contains(custId)){
                    resellercustomer.add(temcustomer);
                    customerNameRes.add(custId);        
                    
                    //PBI 1420266 start
                    if(temcustomer.label != null)
                    customerResSet.add(temcustomer.label);
                    //PBI 1420266 ends
                }
                //check soldTo name added to picklist
                if(!soldToRes.contains(string.valueOf(updatewrapper.RE_Sold_To_Number__c))){
                    resellerSoldTo.add(temSlodTo); 
                    soldToRes.add(string.valueOf(updatewrapper.RE_Sold_To_Number__c)); 
                }                
                //check AM code name added to picklist
                if(!amCodeRes.contains(updatewrapper.RE_AM_Code__c) && updatewrapper.RE_AM_Code__c != null){
                    resellerAMcode.add(temAMcode);
                    amCodeRes.add(updatewrapper.RE_AM_Code__c);                    
                }
                //check AM code name added to picklist
                if(!ClaRes.contains(updatewrapper.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name)){
                    resellerCalMod.add(temCalculationMod);
                    ClaRes.add(updatewrapper.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name);                    
                }
                
                
                resellerdata.add(tempOppdata);  
            }
            else{
                System.debug('Direct data called---');
                //check plant is added to picklist
                if(!plantDir.contains(updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c)){
                    directPlant.add(temPlant);
                    plantDir.add(updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c);                    
                }
                //check Material is added to picklist
                if(!matDir.contains(updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c)){
                    DirectMaterial.add(temMaterial);
                    matDir.add(updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c);                        
                }
                //check customer name added to picklist
                if(!customerNameDir.contains(custId)){
                    directcustomer.add(temcustomer);
                    customerNameDir.add(custId);       
                    
                    //PBI 1420266 start
                    if(temcustomer.label != null)
					customerDirSet.add(temcustomer.label);  
                    //PBI 1420266 ends
                }
                //check soldTo name added to picklist
                if(!soldToDir.contains(string.valueOf(updatewrapper.RE_Sold_To_Number__c))){
                    directSoldTo.add(temSlodTo); 
                    soldToDir.add(string.valueOf(updatewrapper.RE_Sold_To_Number__c)); 
                }                
                //check AM code name added to picklist
                if(!amCodeDir.contains(updatewrapper.RE_AM_Code__c)  && updatewrapper.RE_AM_Code__c != null){
                    directAMcode.add(temAMcode);
                    amCodeDir.add(updatewrapper.RE_AM_Code__c);                    
                }
                //check AM code name added to picklist
                if(!ClaDir.contains(updatewrapper.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name)){
                    directCalMod.add(temCalculationMod);
                    ClaDir.add(updatewrapper.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name);                    
                }
                directdata.add(tempOppdata); 
            }   
        }
        
        //adding all Reseller data to final wrapper class
        //PBI 1420266 start
        resellerAlldata.customerList=customerResSet;
		resellerAlldata.locationList=plantRes;
		resellerAlldata.MaterialList=matRes;
		resellerAlldata.AMCodeList=amCodeRes;
        //PBI 1420266 ends
        
        resellerAlldata.Material=resellerMaterial;
        resellerAlldata.plant=resellerPlant;
        resellerAlldata.customerName=resellercustomer;
        resellerAlldata.soldTo=resellerSoldTo;
        resellerAlldata.amCode=resellerAMcode;
        resellerAlldata.resellerdata=resellerdata;
        resellerAlldata.CalMod=resellerCalMod;
        
        
        //adding all Direct data to final wrapper class
        //PBI 1420266 start
        directAlldata.customerList=customerDirSet;
		directAlldata.locationList=plantDir;
		directAlldata.MaterialList=matDir;
		directAlldata.AMCodeList=amCodeDir;
        //PBI 1420266 ends
        
        directAlldata.Material=DirectMaterial;
        directAlldata.plant=directPlant;
        directAlldata.customerName=directcustomer;
        directAlldata.soldTo=directSoldTo;
        directAlldata.amCode=directAMcode;
        directAlldata.directdata=directdata; 
        directAlldata.CalMod=directCalMod;
        
        //adding Reseller and Direct to main wrapper class
        customOppdata.direct=directAlldata;
        customOppdata.reseller=resellerAlldata;
        //customOppdata.isApprover= (filterCondition != null ? filterCondition : 'ViewOnly');
        customOppdata.isApprover = Boolean.valueOf(accessInfo.get('is_Approver'));
        customOppdata.midpublishDate=midDayDate;
        customOppdata.cubpublishDate=cubDate;
        customOppdata.controlFunction = Boolean.valueOf(accessInfo.get('viewOnly'));
        
        
        system.debug('RE_customerOppWrapper.getcustomerOppdata >>>  final data--'+customOppdata);
        return customOppdata;
    }
    
    //add the pricebook data to wrapper class
    public static RE_customerOppWrapper.pricebookdata getMapOfPriceBookdata(RT_Price_Book__c tmpReseller,Map<String,string> accessInfo){
        //Mapping Approve Status to short Name
        Map<String, String> approveStatus = new Map<String, String>{'Not Submitted' => 'NS', 'Submitted PM' => 'SB' ,'Support STL' => 'SS', 'Support PM' => 'SP' ,'Approved' =>'AP' ,'Rejected' => 'RJ','Auto Approved' => 'AA' ,'Ready to Upload' => 'RU', 'Uploaded' => 'UP' , 'Failed' => 'FA', 'Upload not allowed' => 'UN'};
            
            RE_customerOppWrapper.pricebookdata tempOppdata =new RE_customerOppWrapper.pricebookdata();
        List<String> fieldsToEdit= new List<String>();
        fieldsToEdit=tmpReseller.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.RE_Editable_Field__c.split(';');
        
        tempOppdata.id=tmpReseller.id;
        //Ship To customer Name 
        tempOppdata.customerName=tmpReseller.RE_Contract_Master__r.RE_Customer_Name__r.name;
        tempOppdata.customerNameId='/'+tmpReseller.RE_Contract_Master__r.RE_Customer_Name__r.id;
        //Sold To customer Name
        tempOppdata.customerNameSoldTo=(tmpReseller.RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c =='Ship To' ?
                                        tmpReseller.RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.name : 
                                        tmpReseller.RE_Contract_Master__r.RE_Customer_Name__r.name);
        tempOppdata.customerSoldToID=(tmpReseller.RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c =='Ship To' ?
                                      '/'+tmpReseller.RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.Id : 
                                      '/'+tmpReseller.RE_Contract_Master__r.RE_Customer_Name__r.Id);     
        
        tempOppdata.product = tmpReseller.RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c;
        tempOppdata.productCode = tmpReseller.RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c;
        tempOppdata.Location = tmpReseller.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c;
        tempOppdata.locationCode = tmpReseller.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c;
        tempOppdata.amCode = tmpReseller.RE_AM_Code__c;
        tempOppdata.salesOrg = tmpReseller.RE_Sales_Org__c;
        tempOppdata.transportCharge = string.valueOf(tmpReseller.RE_Transport_Charge__c != null ? tmpReseller.RE_Transport_Charge__c : 0.00);
        tempOppdata.serviceSurChg = string.valueOf(tmpReseller.RE_Service_SurChg__c != null ? tmpReseller.RE_Service_SurChg__c : 0.00);
        tempOppdata.tptMode = tmpReseller.RE_Contract_Master__r.RE_Transport_Mode__c;
        tempOppdata.units = tmpReseller.RE_Unit__c;
        tempOppdata.listPrice = string.valueOf(tmpReseller.RE_List_Price__c != null ? tmpReseller.RE_List_Price__c : 0.00);
        tempOppdata.tieredDiscount = string.valueOf(tmpReseller.RE_Std_Disc__c != null ? tmpReseller.RE_Std_Disc__c : 0.00);
        tempOppdata.finalPrice = string.valueOf(tmpReseller.RE_Final_Price_Rebate__c != null ? tmpReseller.RE_Final_Price_Rebate__c : 0.00);
        tempOppdata.finalPriceOld = string.valueOf(tmpReseller.RE_Final_Price_Rebate__c != null ? tmpReseller.RE_Final_Price_Rebate__c : 0.00);        
        tempOppdata.discount = string.valueOf(tmpReseller.RE_Discount__c != null ? tmpReseller.RE_Discount__c : 0.00);
        tempOppdata.tempDiscount = string.valueOf(tmpReseller.RE_Temp_Discount__c != null ? tmpReseller.RE_Temp_Discount__c : 0.00);
        tempOppdata.soldTo = string.valueOf(tmpReseller.RE_Sold_To_Number__c);
        tempOppdata.shipTo = string.valueOf(tmpReseller.RE_Ship_To_Number__c);
        tempOppdata.midDayPrice = string.valueOf(tmpReseller.RE_MIDday_Price__c != null ? tmpReseller.RE_MIDday_Price__c : 0.00);
        tempOppdata.fcMarginInd = string.valueOf(tmpReseller.RE_Margin_above_AfterNoon_Indication__c != null ? tmpReseller.RE_Margin_above_AfterNoon_Indication__c: 0.00 );
        tempOppdata.cbuMC = string.valueOf(tmpReseller.RE_CBU_MC__c != null ? tmpReseller.RE_CBU_MC__c  : 0.00);
        tempOppdata.MarginaboveCBUMC = string.valueOf(tmpReseller.RE_Margin_above_CBU_MC__c != null ? tmpReseller.RE_Margin_above_CBU_MC__c : 0.00);
        tempOppdata.startDate = tmpReseller.RE_Valid_From__c;
        tempOppdata.startDateOld = tmpReseller.RE_Valid_From__c;
        tempOppdata.endDate = tmpReseller.RE_Valid_To__c;
        tempOppdata.endDateOld = tmpReseller.RE_Valid_To__c;
        tempOppdata.directValidFrom = tmpReseller.RE_Direct_Valid_From__c;
        tempOppdata.directValidTo = tmpReseller.RE_Direct_Valid_To__c;
        tempOppdata.approveStatus = approveStatus.get(tmpReseller.RE_Custom_Opp_Approve__c);
        tempOppdata.listPriceTier = (tmpReseller.RE_Contract_Master__r.List_Price_Tier__c != null ? tmpReseller.RE_Contract_Master__r.List_Price_Tier__r.Value__c : '0.00');
        if(tmpReseller.RE_CBU_Last_offered__c)
            tempOppdata.recordMode = false;
        else
            tempOppdata.recordMode = Boolean.valueOf(accessInfo.get(tmpReseller.RE_Custom_Opp_Approve__c));
        tempOppdata.trackDateEdit = tempOppdata.recordMode;
        tempOppdata.inlineEdit = false;
        tempOppdata.approvedBy = tmpReseller.RE_Approved_By__r.name;
        tempOppdata.pricingLevel = string.valueOf(tmpReseller.RE_Pricing_Level__c != null ? tmpReseller.RE_Pricing_Level__c : 0);
        tempOppdata.pricingLevelOld = string.valueOf(tmpReseller.RE_Pricing_Level__c != null ? tmpReseller.RE_Pricing_Level__c : 0);
        tempOppdata.isChecked = false;
        //tempOppdata.checkBoxController = (filterCondition == 'Customer Opps Team' ? (tmpReseller.RE_Custom_Opp_Approve__c=='Not Submitted' ? true:false) : true);
         if(tmpReseller.RE_CBU_Last_offered__c)
            tempOppdata.checkBoxController = false;
        else
        	tempOppdata.checkBoxController = Boolean.valueOf( accessInfo.get('is_Approver') == 'true' ? accessInfo.get(tmpReseller.RE_Custom_Opp_Approve__c) : (tmpReseller.RE_Custom_Opp_Approve__c=='Not Submitted' ? 'true' : 'false') );
        tempOppdata.submittedBy = tmpReseller.RE_Submitter__r.name;
        tempOppdata.contractID = tmpReseller.RE_Contract_Master__c;   
        tempOppdata.customerID = tmpReseller.RE_Customer_Name__c;
        tempOppdata.fields = tmpReseller.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.RE_Editable_Field__c;
        tempOppdata.marginAboveLDC = string.valueOf(tmpReseller.RE_Margin_on_LDC__c != null ? tmpReseller.RE_Margin_on_LDC__c : 0.00);
        tempOppdata.marginAboveMC = string.valueOf(tmpReseller.RE_Margin_on_MC__c != null ? tmpReseller.RE_Margin_on_MC__c :0.00);   
        tempOppdata.forecastMarginAboveLDC = string.valueOf(tmpReseller.RE_Forecast_Margin_on_LDC__c != null ? tmpReseller.RE_Forecast_Margin_on_LDC__c : 0.00);
        tempOppdata.forecastMarginAboveMC = string.valueOf(tmpReseller.RE_Forecast_Margin_on_MC__c != null ? tmpReseller.RE_Forecast_Margin_on_MC__c : 0.00);
        tempOppdata.dfoaCharges = string.valueOf(tmpReseller.RE_DFOA_Charges__c != null ? tmpReseller.RE_DFOA_Charges__c : 0.00);
        tempOppdata.rebate = string.valueOf(tmpReseller.RE_Rebate__c != null ? tmpReseller.RE_Rebate__c : 0.00);
        tempOppdata.bdf = string.valueOf(tmpReseller.RE_BDF__c != null ? tmpReseller.RE_BDF__c : 0.00);
        tempOppdata.RE_CBU_LDC =string.valueOf(tmpReseller.RE_CBU_LDC__c != null ? tmpReseller.RE_CBU_LDC__c : 0.00);
        tempOppdata.RE_Afternoon_Indication = string.valueOf(tmpReseller.RE_Afternoon_Indication__c != null ? tmpReseller.RE_Afternoon_Indication__c : 0.00);
        tempOppdata.calculationLogic = tmpReseller.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name;
        tempOppdata.InlineEdit = false;
        //checks which filed to provide edit permission Final price or price level
        tempOppdata.finalPriceEdit = fieldsToEdit.contains('RE_Final_Price_Rebate__c');
        tempOppdata.priceLevelEdit = fieldsToEdit.contains('RE_Pricing_Level__c');
        tempOppdata.validDateEdited = false;
        tempOppdata.approverComments = (tmpReseller.RE_Approver_Comments__c != null ? tmpReseller.RE_Approver_Comments__c:'');
        tempOppdata.submitterComments = (tmpReseller.RE_Submitter_Comments__c != null ? tmpReseller.RE_Submitter_Comments__c:'');
        tempOppdata.submitterCommentsOld = (tmpReseller.RE_Submitter_Comments__c != null ? tmpReseller.RE_Submitter_Comments__c:'');
        tempOppdata.lastModifiedBy= tmpReseller.LastModifiedBy.Name;
        tempOppdata.yesterdayFinalPrice=string.valueOf(tmpReseller.RE_Yesterday_Final_Price__c);
        tempOppdata.avatarCssClass='slds-avatar__initials slds-icon-standard-account '+ approveStatus.get(tmpReseller.RE_Custom_Opp_Approve__c);
        tempOppdata.cbuMCforFinalPrice =String.valueof(tmpReseller.RE_CBU_MC_for_Final_Price__c != null ? tmpReseller.RE_CBU_MC_for_Final_Price__c : 0.0);
        tempOppdata.cbuLDCforFinalPrice =String.valueof(tmpReseller.RE_CBU_LDC_for_Final_Price__c != null ? tmpReseller.RE_CBU_LDC_for_Final_Price__c : 0.0);

        return tempOppdata;
    }
    
    //This method will return access information of LWC
    public static Map<String,String> getAccessInfo(String userinfo){
        Map<String,String> accessInfo= new Map<String,String>();
        List<String> accessContains = new List<String>();
        Schema.DescribeFieldResult fieldResult = RT_Price_Book__c.RE_Custom_Opp_Approve__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        //User access to records in CO dashboard is stored in a custom setting based on user login access will be defined 
        RE_Customer_Opps__c accessinformation = RE_Customer_Opps__c.getValues(userinfo);
        if(accessinformation != null && accessinformation.RE_User_Access_Control__c != null){
            accessContains = accessinformation.RE_User_Access_Control__c.split(';');
            accessInfo.put('FilterCondition',accessinformation.RE_Condition__c);
            accessInfo.put('emailIds',accessinformation.Email_ID__c);
            accessInfo.put('is_Approver',string.valueOf(accessinformation.RE_Is_Approver__c));
            accessInfo.put('viewOnly',string.valueOf(accessinformation.RE_View_Only__c));
            Map<String,String> emailtemplate= new Map<String,String>();
            if(accessinformation.RE_Email_Templates__c != null){
                for(String templateName : accessinformation.RE_Email_Templates__c.split(';')){
                    List<String> emailAction = new List<String>();
                    emailAction = templateName.split(':');
                    if(emailAction.size() > 1)
                        emailtemplate.put(emailAction[0],emailAction[1]);
                }
            accessInfo.putall(emailtemplate);
            }
        }
        
        for( Schema.PicklistEntry pickListVal : ple)
        {
            if(accessinformation != null){
                accessInfo.put(pickListVal.getLabel(),string.valueOf(accessContains.contains(pickListVal.getLabel())));                
            }
            else{
                accessInfo.put(pickListVal.getLabel(),'false');  
                accessInfo.put('FilterCondition',''); 
                accessInfo.put('emailIds','');
                accessInfo.put('is_Approver','false');
                accessInfo.put('viewOnly','true');
            }            
        }    
           
        return  accessInfo;
    }   
       
    //Recalculate pricebook data
    @AuraEnabled
    public Static RE_customerOppWrapper.getcustomerOppdata convertToPriceBook(List<RE_customerOppWrapper.pricebookdata> wrapPBDataList, boolean isMidDay , String curDashboardDate ,string customerType){
        system.debug('RE_customOppController.convertToPriceBook >>>>'+wrapPBDataList);
        approvalscheme = approvalScheme('MY');
         
        List<RT_Price_Book__c> updatePBdata= new List<RT_Price_Book__c>();
        
        string filter = '  RE_Contract_Master__r.RE_Customer_Name__r.type = \''+ customerType +'\' AND  RE_Valid_From__c  <= '+ curDashboardDate +' AND RE_Valid_To__c >= '+curDashboardDate+' ';
        
        //convert wrapper of Reseller / Direct customer data to pricebook object type to recalculate the cost price.
        //Map<id,RT_Price_Book__c> finaldata =new Map<Id,RT_Price_Book__c>(getpricebookdata(filterCondcur,isMidDay));
        Map<id,RT_Price_Book__c> finaldata =new Map<Id,RT_Price_Book__c>(getpricebookdata(filter,isMidDay));
        
        //system.debug('data---'+finaldata);
        for(RE_customerOppWrapper.pricebookdata wrappbdata : wrapPBDataList){
            if( wrappbdata.startDate != wrappbdata.startDateOld || wrappbdata.endDate != wrappbdata.endDateOld  || wrappbdata.finalPrice != wrappbdata.finalPriceOld ){
                if(date.valueOf(wrappbdata.endDate) >= date.valueOf(wrappbdata.startDate)){
                    RT_Price_Book__c newPrBook = new RT_Price_Book__c();
                    newPrBook = finaldata.get(wrappbdata.Id).clone(false, true, false, false);
                    newPrBook.Id= null;
                    newPrBook.RE_Frequency_record__c= false;
                    newPrBook.RE_Job_Counter__c = (finaldata.get(wrappbdata.Id).RE_Job_Counter__c != null ? finaldata.get(wrappbdata.Id).RE_Job_Counter__c + 1 : 0);
                    if(finaldata.containsKey(wrappbdata.Id)){
                        newPrBook.RE_Latest_price_dt__c = DateTime.now();
                        newPrBook.RE_Final_Price_Rebate__c=Decimal.ValueOf(wrappbdata.finalPrice == null ? '0' : wrappbdata.finalPrice);
                        newPrBook.RE_Valid_From__c = wrappbdata.startDate ;
                        newPrBook.RE_Valid_To__c  = wrappbdata.endDate;
                        newPrBook.RE_Submitter_Comments__c = wrappbdata.submitterComments;
                         
                        if(newPrBook.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name == 'Direct Final Price Adjustment' || newPrBook.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name == 'Direct Price Level Adjustment' || 
                           newPrBook.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct without transport charge) - 1 week' || newPrBook.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct without transport charge) - 2 days validity')
                            newPrBook.RE_Discount__c = (newPrBook.RE_List_Price__c - newPrBook.RE_Final_Price_Rebate__c).setScale(2);                
                        
                        if(newPrBook.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - 1 week' || newPrBook.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name == 'Direct As Reseller Price Adjustment (with transport charge)'
                           || newPrBook.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name == 'Price Level (Direct with transport charge) - Eff Sat to Fri')
                            newPrBook.RE_Discount__c = (newPrBook.RE_List_Price__c - newPrBook.RE_Final_Price_Rebate__c + (newPrBook.RE_Transport_Charge__c != null ? newPrBook.RE_Transport_Charge__c:0)).setScale(2);                
                        
                        
                        if(wrappbdata.validDateEdited == true && newPrBook.RE_Custom_Opp_Approve__c != 'Not Submitted' && newPrBook.RE_Custom_Opp_Approve__c != 'Rejected')
                            newPrBook.RE_Custom_Opp_Approve__c = 'Auto Approved';
                        
                        if(wrappbdata.validDateEdited == true && newPrBook.RE_Custom_Opp_Approve__c == 'Not Submitted' && newPrBook.RE_Custom_Opp_Approve__c == 'Rejected')
                            newPrBook.RE_Custom_Opp_Approve__c = 'Not Submitted';
                        
                        if(newPrBook.RE_Final_Price_Rebate__c != Decimal.ValueOf(wrappbdata.finalPriceOld == null ? '0' : wrappbdata.finalPriceOld) )
                            newPrBook.RE_Custom_Opp_Approve__c ='Not Submitted';
                        
                        finaldata.get(wrappbdata.Id).RE_Job_Counter__c = (finaldata.get(wrappbdata.Id).RE_Job_Counter__c != null ? finaldata.get(wrappbdata.Id).RE_Job_Counter__c + 0.1 : 0.1);
                        updatePBdata.add(finaldata.get(wrappbdata.Id));
                        /*if(!finaldata.get(wrappbdata.Id).RE_Frequency_record__c && finaldata.get(wrappbdata.Id).RE_Valid_From__c == wrappbdata.startDate && finaldata.get(wrappbdata.Id).RE_Valid_To__c == wrappbdata.endDate ){                    
                            finaldata.get(wrappbdata.Id).RE_Is_Latest__c = false;
                            updatePBdata.add(finaldata.get(wrappbdata.Id));
                        } */ 
                    } 
                    
                    updatePBdata.add(updateApprovalScheme(newPrBook , newPrBook.RE_Contract_Master__r.RE_PH_Approval_Scheme__c , getMarginForApproval(newPrBook,isMidDay)));
                }
            }
            else if(finaldata.containsKey(wrappbdata.Id)){
                finaldata.get(wrappbdata.Id).RE_Submitter_Comments__c = wrappbdata.submitterComments;
                 updatePBdata.add(finaldata.get(wrappbdata.Id));
            }
            
        } 
        
        upsert updatePBdata;
        
        
        RE_customerOppWrapper.getcustomerOppdata  recalculatOppdata=getFilteredDate(curDashboardDate,isMidDay,customerType);
        return recalculatOppdata;
    }   
  
    
    //This method will fetch todays Price Book data
    public static List<RT_Price_Book__c> getpricebookdata(String filtercondition,boolean isMidDay){
        string QueryStr='select Id,RE_First_Calculated_Value__c,RecordTypeId,RE_CBU_MC_for_Final_Price__c,RE_CBU_LDC_for_Final_Price__c,RE_CBU_Last_offered__c,RE_Latest_price_dt__c,RE_Validation_1_Value__c,RE_Rebate__c,RE_BDF__c,RE_Validation_2_Value__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.name,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.RE_Editable_Field__c,RE_Customer_Name__r.Type,RE_Contract_Master__r.RE_Customer_Name__r.id,RE_Contract_Master__r.RE_Customer_Name__r.name,RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name,RE_Approver_Comments__c,RE_CBU_output_date__c,';
        QueryStr = QueryStr+'RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.id,RE_Contract_Master__r.RE_PH_Approval_Scheme__c,RE_Contract_Master__r.RT_Plant_Desc__r.Name,RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c, RE_Contract_Master__r.RT_Plant_Desc__r.RE_Region_Name__c ,RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approve__c,RE_Valid_From__c,RE_Valid_To__c,RE_Approved_By__c,RE_Approved_By__r.name,RE_Contract_Master__r.RE_Transport_Mode__c,RE_First_Price__c,RE_CBU_valid_To__c,RE_CBU_valid_from__c,';
        QueryStr = QueryStr+'RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c ,RE_UoM__c,RE_Quantity__c,RE_Contract_Master__r.List_Price_Tier__r.Value__c,RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c,RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c,RE_Contract_Master__r.RT_Material_Desc__r.Name,RE_AM_Code__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approved_Value__c,RE_Submitter_Comments__c,RE_Margin_on_LDC__c,RE_ApprovalProcess__c,';
        QueryStr = QueryStr+'RE_Pricing_Level__c,RE_Service_SurChg__c, LastModifiedBy.Name,RE_Unit__c,RE_List_Price__c,RE_Std_Disc__c,RE_Final_Price_Rebate__c,RE_Discount__c,RE_Sold_To_Number__c,RE_Contract_Master__r.RE_Pricing_Levels__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Operator__c,RE_Submitter__c,RE_Submitter__r.name,RE_Margin_above_CBU_MC__c,RE_CBU_LDC__c,RE_Afternoon_Indication__c,RE_Margin_on_MC__c,RE_Temp_Discount__c,RE_Job_Counter__c,RE_Direct_Valid_From__c,RE_Direct_Valid_To__c,';
        QueryStr = QueryStr+'RE_Ship_To_Number__c,RE_MIDday_Price__c,RE_Frequency_record__c,RE_CBU_MC__c,RE_Start_date__c,RE_End_date__c,RE_Custom_Opp_Approve__c,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.RE_Output_Pricing_Condition__c,RE_Margin_above_AfterNoon_Indication__c,RE_Forecast_Margin_on_LDC__c,RE_Forecast_Margin_on_MC__c,RE_DFOA_Charges__c,RE_MidDay_output_date__c,RE_Is_Latest__c,RE_Is_CBU__c,RT_Product__c,RT_Location__c,RT_Country__c,';
        QueryStr = QueryStr+'RE_Contract_Master__c ,RE_Transport_Charge__c,RE_Yesterday_Final_Price__c,RE_Customer_Name__c,RE_Contract_Master__r.RE_Customer_Name__r.type,RE_Sales_Org__c,RE_Customer_Group__c,RE_Material_Code__c,RT_Location_Code__c,RT_Product__r.RE_Material__c  from RT_Price_Book__c where RT_Country__c =\'MY\' AND RE_Is_Latest__c = True  ';
        QueryStr = QueryStr+(isMidDay  ? ' AND RE_Is_CBU__c  = True ' : 'AND RE_Is_CBU__c  = False ');
        QueryStr = QueryStr+((filtercondition != '' && filtercondition != null && filtercondition != 'null' ) ? ' AND '+filtercondition:'');
        QueryStr = QueryStr+' order by RE_Latest_price_dt__c asc ';
        system.debug('RE_customOppController.getpricebookdata>>>'+QueryStr);
        return Database.query(QueryStr);        
    }
    //SOQL for get CBU data where CBU date is less than today
    public static List<RT_Price_Book__c> getpricebookOlddata(String filtercondition,boolean isMidDay){
        string QueryStr='select Id,RE_First_Calculated_Value__c,RecordTypeId,RE_CBU_MC_for_Final_Price__c,RE_CBU_LDC_for_Final_Price__c,RE_Latest_price_dt__c,RE_CBU_Last_offered__c,RE_Validation_1_Value__c,RE_Rebate__c,RE_BDF__c,RE_Validation_2_Value__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.name,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.RE_Editable_Field__c,RE_Customer_Name__r.Type,RE_Contract_Master__r.RE_Customer_Name__r.id,RE_Contract_Master__r.RE_Customer_Name__r.name,RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name,RE_Approver_Comments__c,RE_CBU_output_date__c,';
        QueryStr = QueryStr+'RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.id,RE_Contract_Master__r.RE_PH_Approval_Scheme__c,RE_Contract_Master__r.RT_Plant_Desc__r.Name,RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c, RE_Contract_Master__r.RT_Plant_Desc__r.RE_Region_Name__c ,RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approve__c,RE_Valid_From__c,RE_Valid_To__c,RE_Approved_By__c,RE_Approved_By__r.name,RE_Contract_Master__r.RE_Transport_Mode__c,RE_First_Price__c,RE_CBU_valid_To__c,RE_CBU_valid_from__c,';
        QueryStr = QueryStr+'RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c ,RE_Quantity__c,RE_Contract_Master__r.List_Price_Tier__r.Value__c,RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c,RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c,RE_Contract_Master__r.RT_Material_Desc__r.Name,RE_AM_Code__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approved_Value__c,RE_Submitter_Comments__c,RE_Margin_on_LDC__c,RE_ApprovalProcess__c,';
        QueryStr = QueryStr+'RE_Pricing_Level__c,RE_Service_SurChg__c, LastModifiedBy.Name,RE_UoM__c,RE_Unit__c,RE_List_Price__c,RE_Std_Disc__c,RE_Final_Price_Rebate__c,RE_Discount__c,RE_Sold_To_Number__c,RE_Contract_Master__r.RE_Pricing_Levels__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Operator__c,RE_Submitter__c,RE_Submitter__r.name,RE_Margin_above_CBU_MC__c,RE_CBU_LDC__c,RE_Afternoon_Indication__c,RE_Margin_on_MC__c,RE_Temp_Discount__c,RE_Job_Counter__c,RE_Direct_Valid_From__c,RE_Direct_Valid_To__c,';
        QueryStr = QueryStr+'RE_Ship_To_Number__c,RE_MIDday_Price__c,RE_Frequency_record__c,RE_CBU_MC__c,RE_Start_date__c,RE_End_date__c,RE_Custom_Opp_Approve__c,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.RE_Output_Pricing_Condition__c,RE_Margin_above_AfterNoon_Indication__c,RE_Forecast_Margin_on_LDC__c,RE_Forecast_Margin_on_MC__c,RE_DFOA_Charges__c,RE_MidDay_output_date__c,RE_Is_Latest__c,RE_Is_CBU__c,RT_Product__c,RT_Location__c,RT_Country__c,';
        QueryStr = QueryStr+'RE_Contract_Master__c ,RE_Transport_Charge__c,RE_Yesterday_Final_Price__c,RE_Customer_Name__c,RE_Contract_Master__r.RE_Customer_Name__r.type,RE_Sales_Org__c,RE_Customer_Group__c,RE_Material_Code__c,RT_Location_Code__c,RT_Product__r.RE_Material__c  from RT_Price_Book__c where RT_Country__c =\'MY\' AND RE_CBU_Last_offered__c = True  ';
        QueryStr = QueryStr+' AND RE_Is_CBU__c  = True ';
        QueryStr = QueryStr+(filtercondition != '' && filtercondition != null ? ' AND '+filtercondition:'');
        QueryStr = QueryStr+' order by RE_Latest_price_dt__c asc ';
        system.debug('RE_customOppController.getpricebookOlddata>>>'+QueryStr);
        return Database.query(QueryStr);        
    }
    @AuraEnabled
    public static RE_customerOppWrapper.getcustomerOppdata  getFilteredDate(string datefilter,boolean isMidDay,string customerType){ 
        system.debug('datefilter--'+datefilter);
        Map<String,String> accessInfo=getAccessInfo(filterCondition);
        Map<Id,RT_Price_Book__c> Pricebookedited = new Map<Id,RT_Price_Book__c> ();
        Map<Id,RT_Price_Book__c> freqPricebook = new Map<Id,RT_Price_Book__c> ();
        List<Id> latestPriceBookContr = new List<Id>();
        checkdatefilter= true;
        
        List<RE_Job_Run_Audit__c> jra= new List<RE_Job_Run_Audit__c>();
        jra =[select id,RE_IsSuccess__c,RE_Exception__c from RE_Job_Run_Audit__c where createddate=Today AND RE_IsSuccess__c=True AND RE_Job_Type__c='CustomerOps Output'  limit 1];
        if( (jra.size() != 0 && !isMidDay) || isMidDay ){
            //List<REV_Contract_Master__c> contractList = RE_SOQLController.fetchActiveContracts('Reseller');
            //List<REV_Contract_Master__c> contractListDirect = RE_SOQLController.fetchActiveContracts('Direct');
            List<RT_Price_Book__c> disPlayPrice = new List<RT_Price_Book__c>();
            //contractList.addAll(contractListDirect);
            List<REV_Contract_Master__c> contractList = [Select Id from REV_Contract_Master__c where  Country_Name__c = 'MY' and  Active__c = True ];
            string filterCond = ' RE_Contract_Master__r.RE_Customer_Name__r.type = \''+ customerType +'\' AND ';
            
            List<RE_Job_Run_Audit__c> jraCBU= new List<RE_Job_Run_Audit__c>();
            jraCBU =[select id,RE_IsSuccess__c,RE_Exception__c,createddate from RE_Job_Run_Audit__c where RE_IsSuccess__c=True AND RE_Job_Type__c='MY Customer Opps CBU'  order by createddate desc limit 1];
            
            DateTime  selectedDate = date.valueOf(datefilter);
            DateTime  jobRunDate = date.valueOf(datefilter);
            if(jraCBU.size() > 0){
                TimeZone tz = UserInfo.getTimeZone();
                string myDate = jraCBU[0].createddate.format('yyyy-MM-dd',tz.getId());
                jobRunDate = date.valueOf(myDate);  
            }         
            if(jraCBU.size() > 0 && selectedDate.date() < jobRunDate.date()){
                filterCond = ' RE_Custom_Opp_Approve__c =:approvedStatus  AND ' +filterCond +' RE_CBU_valid_from__c <= '+ datefilter + ' AND RE_CBU_valid_To__c >= '+datefilter+' ' + ' AND RE_Valid_From__c  <= '+ datefilter +' AND RE_Valid_To__c >= '+datefilter+' '+( (accessInfo.get('FilterCondition') == null || accessInfo.get('FilterCondition') == '')? '': ' AND '+ accessInfo.get('FilterCondition'));           
                disPlayPrice = getpricebookOlddata(filterCond,isMidDay);
            }
            else{
                filterCond = filterCond + ' RE_Valid_From__c  <= '+ datefilter +' AND RE_Valid_To__c >= '+datefilter+' '+( (accessInfo.get('FilterCondition') == null || accessInfo.get('FilterCondition') == '') ? '': ' AND '+ accessInfo.get('FilterCondition'));
                disPlayPrice = getpricebookdata(filterCond,isMidDay);
            } 
            
            for( RT_Price_Book__c PriceBookMap : disPlayPrice){
                //system.debug('PriceBookMap--'+PriceBookMap.RE_Frequency_record__c);
                if( PriceBookMap.RE_Frequency_record__c == false)
                    Pricebookedited.put(PriceBookMap.RE_Contract_Master__c,PriceBookMap);
                if(PriceBookMap.RE_Frequency_record__c == True)
                    freqPricebook.put(PriceBookMap.RE_Contract_Master__c,PriceBookMap);            
            }
            if(!Pricebookedited.isEmpty() || !freqPricebook.isEmpty()){
                for(REV_Contract_Master__c contractdata : contractList){               
                    if(Pricebookedited.containsKey(contractdata.Id) && !latestPriceBookContr.contains(contractdata.Id)){
                        priceBookdataDateFilter.add(Pricebookedited.get(contractdata.Id));
                        latestPriceBookContr.add(contractdata.Id);
                    }
                    else{ 
                        if(freqPricebook.containsKey(contractdata.Id) && !latestPriceBookContr.contains(contractdata.Id)){
                            priceBookdataDateFilter.add(freqPricebook.get(contractdata.Id));
                            latestPriceBookContr.add(contractdata.Id);
                        }
                    }
                }
            }
        }
        return getallData(datefilter,isMidDay);
    }
    
    //Record will submitted for approval based on condition
    @AuraEnabled
    public static RE_customerOppWrapper.getcustomerOppdata submitforApproval(List<string> recordsTOsubmit,boolean isMidDay,string dateFilter , string customerType){
        filterDate = dateFilter;
        filterView = isMidDay ? 'CBU' : 'MidDay';
        customerTypeEmail = customerType;
        RE_customerOppWrapper.getcustomerOppdata  submitOppdata=new RE_customerOppWrapper.getcustomerOppdata();
        List<RT_Price_Book__c> submitPriceBook=new List<RT_Price_Book__c>();
        List<Id> submittedRecordID= new List<Id>(); 
         List<String> tomail = new List<String>();
        Map<String,String> accessInfoApp1=getAccessInfo(filterCondition);
        try{
            submitPriceBook=[Select Id,RE_Submitter__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approve__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Operator__c,
                             RE_Customer_Name__r.RE_Auto_Approved_Value__c ,RE_ApprovalProcess__r.RE_User_Name__r.email,RE_ApprovalProcess__r.RE_Delegate_Approver__r.email from RT_Price_Book__c where id=: recordsTOsubmit];
            for(RT_Price_Book__c tempupdate: submitPriceBook){
                submittedRecordID.add(tempupdate.id);
                tempupdate.RE_Submitter__c=UserInfo.getUserId();
                //checks whether record need to be AutoApprove
                if(tempupdate.RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approve__c && tempupdate.RE_Contract_Master__r.RE_Customer_Name__r.RE_Operator__c != null && tempupdate.RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approved_Value__c != null)
                    tempupdate.RE_Custom_Opp_Approve__c=checkAutoApprove(tempupdate);                
                else
                    tempupdate.RE_Custom_Opp_Approve__c='Submitted PM';
                
                if(tempupdate.RE_ApprovalProcess__c != null && tempupdate.RE_ApprovalProcess__r.RE_User_Name__c != null){
                    if(!tomail.contains(tempupdate.RE_ApprovalProcess__r.RE_User_Name__r.email))
                        tomail.add(tempupdate.RE_ApprovalProcess__r.RE_User_Name__r.email);
                        system.debug('inside email te-'+tempupdate.RE_ApprovalProcess__r.RE_User_Name__r.email);
                }
            }
            if(!submitPriceBook.isEmpty()){
                update submitPriceBook;  
                triggerApprovalProcess(submittedRecordID);
                submitOppdata = getFilteredDate(dateFilter,isMidDay,customerType);
                submitOppdata.status='true';
                //trigger email to Sales Team Lead 
               
                if(accessInfoApp1.get('emailIds') != null && accessInfoApp1.get('emailIds') != '' )
                    tomail.addAll(accessInfoApp1.get('emailIds').split(';'));
                if(!tomail.contains(UserInfo.getUserEmail()))
                    tomail.add(UserInfo.getUserEmail());
                List<String> listOfusercond = new List<String>();
                //listOfusercond.add(filterCondition);
                
                //listOfusercond.add('Sales Team Lead');    
                listOfusercond.add('Pricing Manager');           
                tomail.addAll(getUserList(listOfusercond,tomail));    
                system.debug('email list--'+tomail);         
                if(accessInfoApp1.containsKey('Submit'))
                    sendEmail(accessInfoApp1.get('Submit'),tomail);               
                
            }
            else{
                submitOppdata.status='false';
                submitOppdata.message='Records already submitted / Approved';
            }
        }catch(Exception e){
            system.debug('RE_customOppController.submitforApproval >>>'+e);
            
            submitOppdata.status='false';
            submitOppdata.message=string.valueOf(e);
        }
        return submitOppdata;
        
    }   
    
     public static void triggerApprovalProcess(List<Id> ids){
         
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        
        for(Id rId : ids){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(rId);            
            requests.add(req);
        }
         System.debug('requests--->'+requests);
         Approval.ProcessResult[] processResults = Approval.process(requests);
         System.debug('processResults-->'+processResults);
    }
    //Auto Approve condition for the Price Book records
    public static string checkAutoApprove(RT_Price_Book__c priceBookdata){
        string approvestatus='Submitted';
        if(priceBookdata.RE_Contract_Master__r.RE_Customer_Name__r.RE_Operator__c == 'Equals' && priceBookdata.RE_Margin_on_MC__c == priceBookdata.RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approved_Value__c)
            approvestatus='Auto Approved';
        if(priceBookdata.RE_Contract_Master__r.RE_Customer_Name__r.RE_Operator__c == 'Greater than' && priceBookdata.RE_Margin_on_MC__c > priceBookdata.RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approved_Value__c)
            approvestatus='Auto Approved';
        if(priceBookdata.RE_Contract_Master__r.RE_Customer_Name__r.RE_Operator__c == 'Lesser than' && priceBookdata.RE_Margin_on_MC__c < priceBookdata.RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approved_Value__c)
            approvestatus='Auto Approved';
        
        return approvestatus;
    }
    //Approve or Rejects the Price Book records
    @AuraEnabled
    public static RE_customerOppWrapper.getcustomerOppdata approveReject(List<string> ids,string action,List<RE_customerOppWrapper.pricebookdata> wrapPBDataList,boolean isMidDay,string dateFilter ,String customerType){
        system.debug('-commentsIDMap--'+wrapPBDataList);
        filterDate = dateFilter;
        filterView = isMidDay ? 'CBU' : 'MidDay';
        customerTypeEmail = customerType;
        
        RE_customerOppWrapper.getcustomerOppdata  submitOppdata=new RE_customerOppWrapper.getcustomerOppdata();
        Map<String ,String> commentsIDMap = new Map<String ,String>();
        //update comments
        for(RE_customerOppWrapper.pricebookdata wrappbdata : wrapPBDataList){
            if(ids.contains(wrappbdata.Id))
                commentsIDMap.put(wrappbdata.Id,wrappbdata.approverComments);
        }
        boolean status=false;
        Map<String,String> accessInfosubmitter=getAccessInfo(filterCondition);
        boolean checkNegativeMargin = false;
        boolean checkPMemailTrigger = false;
        List<String> submitterEmail = new List<String>();
        List<RT_Price_Book__c> actionUpdate=new List<RT_Price_Book__c>();
        if(!ids.isEmpty()){
            try{
                actionUpdate=[select id ,RE_Approved_By__c,RE_Forecast_Margin_on_MC__c,RE_Margin_on_MC__c, RE_ApprovalProcess__r.RE_Delegate_Approver__c,RE_ApprovalProcess__r.RE_Delegate_Approver__r.email,
                              RE_ApprovalProcess__r.RE_User_Name__c , RE_ApprovalProcess__r.RE_User_Name__r.email,RE_Approver_Comments__c,RE_Submitter__r.Email,RE_Custom_Opp_Approve__c from RT_Price_Book__c where id =: ids];
                for(RT_Price_Book__c tempUpdate:actionUpdate){
                    tempUpdate.RE_Approved_By__c=UserInfo.getUserId();
                    tempUpdate.RE_Approver_Comments__c=(commentsIDMap.containskey(tempUpdate.id) ? commentsIDMap.get(tempUpdate.id) : '');
                    if(tempUpdate.RE_Submitter__r.Email != null && !submitterEmail.contains(tempUpdate.RE_Submitter__r.Email))
                        submitterEmail.add(tempUpdate.RE_Submitter__r.Email);
                    //checks if Maging is negative
                    if(tempUpdate.RE_ApprovalProcess__r.RE_Delegate_Approver__c != null){
                        checkNegativeMargin = true;
                        if(!submitterEmail.contains(tempUpdate.RE_ApprovalProcess__r.RE_Delegate_Approver__r.email))
                            submitterEmail.add(tempUpdate.RE_ApprovalProcess__r.RE_Delegate_Approver__r.email);
                    }
                } 
                //Based on User login, Approve or Reject email will be triggered
                List<String> listOfusercond = new List<String>();
                listOfusercond.add(filterCondition);
                if(filterCondition == 'Sales Team Lead')
                    listOfusercond.add('Pricing Manager');
                if(filterCondition == 'Pricing Manager' && checkNegativeMargin && action == 'Approved'){
                    listOfusercond.add('Business manager');
                    checkPMemailTrigger = true;
                }                    
                
                if(!actionUpdate.isEmpty()){
                    update actionUpdate;
                    bulkApproveReject(ids,action);
                    status=true;
                    if(action == 'Approved'){
                        List<String> tomail = new List<String>();
                        if(accessInfosubmitter.get('emailIds') != null && accessInfosubmitter.get('emailIds') != '' )
                            tomail = (accessInfosubmitter.get('emailIds').split(';'));
                        if(!tomail.contains(UserInfo.getUserEmail()))
                            tomail.add(UserInfo.getUserEmail());
                        tomail.addAll(submitterEmail);
                        tomail.addAll(getUserList(listOfusercond,tomail));
                        if(accessInfosubmitter.containsKey('Approve') && !checkPMemailTrigger)
                            sendEmail(accessInfosubmitter.get('Approve'),tomail); 
                        if(accessInfosubmitter.containsKey('Submit') && checkPMemailTrigger)
                            sendEmail(accessInfosubmitter.get('Submit'),tomail); 
                        
                    }
                    else{                        
                        List<String> tomail = new List<String>();
                        if(accessInfosubmitter.get('emailIds') != null && accessInfosubmitter.get('emailIds') != '' )
                            tomail = (accessInfosubmitter.get('emailIds').split(';'));
                        if(!tomail.contains(UserInfo.getUserEmail()))
                            tomail.add(UserInfo.getUserEmail());
                        tomail.addAll(submitterEmail);
                        if(accessInfosubmitter.containsKey('Reject'))
                            sendEmail(accessInfosubmitter.get('Reject'),tomail);                         
                    }                    
                    submitOppdata = getFilteredDate(dateFilter,isMidDay,customerType);
                    submitOppdata.status='true';
                }
            }
            catch(Exception ex){
                system.debug('RE_customOppController.approveReject >>>'+ex);
                submitOppdata.status='false';
                submitOppdata.message=string.valueOf(ex);
            }
        }    
        return submitOppdata;
    }
    
    //Return the User list where email need to trigger based on condition.
    public static List<String> getUserList(List<String> listOfusercond , List<String> userList){
        List<String> tomail = new List<String>();
        List<String> delegateuser = getDelegateUser('MY');
            
        for(user userEmail : [SELECT Id,email, RE_Customer_Opps_team__c FROM User where RE_Customer_Opps_team__c IN:listOfusercond AND email IN:delegateuser ]){
            if( !userList.contains(userEmail.email))
                tomail.add(userEmail.email);            
        }
        return tomail;
    }
    
    //Get delegate approver
    public static List<String> getDelegateUser(string country ){
        List<String> deleGateEmailID = new List<String>();
        for(RT_Setting__c delegateList : [SELECT Id, Name, RecordTypeId, Active__c, Country__c,   RE_End_Date__c, RE_Start_Date__c, RE_Delegate_Approver__r.email FROM RT_Setting__c where recordtype.name = 'User leave plan' AND RE_Start_Date__c <= today and RE_End_Date__c >= today and Country__c =: country])
            deleGateEmailID.add(delegateList.RE_Delegate_Approver__r.email);
        
        return deleGateEmailID;
    } 
        
    public static void bulkApproveReject(List<String> ids, string Actiontype){
                
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :ids ];
        
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            req.setAction((Actiontype == 'Approved' ? 'Approve': 'Reject'));
            req.setComments('No Comment.');
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
        system.debug('RE_customOppController.bulkApproveReject >>');
    }
    
    //insert record in GSAP object and Update price Book record status as Ready to Upload
    @AuraEnabled
    public static RE_customerOppWrapper.returnResult exportReport(string datefilter,boolean isMidDay,boolean retryOrexport){
        RE_customerOppWrapper.returnResult resultdata=new RE_customerOppWrapper.returnResult();
         Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('MY Price Book').getRecordTypeId();
        Id ReportFolderID;
        string additionalFilter = '';
        CheckRetry = retryOrexport;
        List<RT_Price_Book__c> updatePriceBook=new List<RT_Price_Book__c>();
        List<Fixed_Price_Staging_Table__c> reportGSAPdata=new List<Fixed_Price_Staging_Table__c>();
        RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
        try{   
            //Report format for GSAP upload
            Map<String,Map<String,Map<String , String>>> reportDataMap= new Map<String,Map<String,Map<String , String>>>();
            reportDataMap=reportConfiguration();
            //To get latest records
            /*if(retryOrexport)
            	additionalFilter = 'RE_Custom_Opp_Approve__c IN (\'Approved\',\'Auto Approved\')';
            else
                additionalFilter = 'RE_Custom_Opp_Approve__c IN (\'Failed\',\'Ready to Upload\')'; */
            
            updatePriceBook = getExportRecords(datefilter,isMidDay,additionalFilter);
            system.debug('export data---'+updatePriceBook);
            integer sequenceNumber=0;
            for(RT_Price_Book__c tempPriceBook : updatePriceBook){
                //check GSAP upload is enabled
                if(RE_GSAP_Upload__c.getValues('Malaysia') != null && RE_GSAP_Upload__c.getValues('Malaysia').RE_GSAP_Upload__c)
                    tempPriceBook.RE_Custom_Opp_Approve__c = 'Ready to Upload';
                else
                     tempPriceBook.RE_Custom_Opp_Approve__c = 'Upload not allowed';
                
                Map<String,String> reportConditionType=reportDataMap.get(tempPriceBook.RE_Customer_Name__r.Type).get(tempPriceBook.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Region_Name__c);
                
                for(String condition :reportConditionType.keyset()){
                    sequenceNumber =sequenceNumber+1;
                    reportGSAPdata.add(priceBookToGSAPtable(tempPriceBook,reportConditionType.get(condition),sequenceNumber));
                }                
            } 
			//insert data to GSAP upload object
            if(!updatePriceBook.isEmpty()){
                for(Fixed_Price_Staging_Table__c oldGSAPdata: [select id,RE_Is_latest__c from Fixed_Price_Staging_Table__c where RE_Is_latest__c=true AND createddate=today AND RE_Is_CBU__c  =: isMidDay  AND REV_Price_Book__r.recordTypeId =: pricebookrectypeid]){
                    oldGSAPdata.RE_Is_latest__c=false;
                    reportGSAPdata.add(oldGSAPdata);
                }
                if(!reportGSAPdata.isEmpty()){
                    
                    upsert reportGSAPdata; 
                    if(RE_GSAP_Upload__c.getValues('Malaysia') != null && RE_GSAP_Upload__c.getValues('Malaysia').RE_GSAP_Upload__c){
                        List<Id> fixPriceIds = new List<Id>();
                        for(Fixed_Price_Staging_Table__c tempdata: reportGSAPdata){
                            if(tempdata.RE_Is_latest__c)
                                fixPriceIds.add(tempdata.Id);
                        } 
                        RE_Job_Run_Audit__c[] TodaysExport = [select id ,RE_Job_Run_Count__c from RE_Job_Run_Audit__c where RE_Job_Type__c='MY Export Report' AND createdDate=today];

                        //Insert a job to Monitor GSAP interface
                        // RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
                        insertJob.RE_Run_Type__c='Manual';
                        insertJob.RE_Job_Type__c = 'MY Export Report';
                        insertJob.RE_User__c=UserInfo.getUserId();
                        insertJob.RE_Run_Time__c=DateTime.now();
                        insertJob.RE_Job_Run_Count__c = (TodaysExport.size() > 0 ? TodaysExport[0].RE_Job_Run_Count__c + 1 : 0);
                        insertJob.RE_Job_Status__c = 'Processing';
                        insertJob.RE_Country_Name__c = 'MY';
                        insert insertJob;
                        //Using Bacth class data will be send to GSAP system
                        FixedPriceDataInsertBatch fdp = new FixedPriceDataInsertBatch( fixPriceIds,0 ,'Malaysia' , insertJob);
                        Database.executebatch(fdp,200);
                    }
                } 
                
                if(!updatePriceBook.isEmpty())
                    //update updatePriceBook; 
                {
                    RE_PriceBookBatchUpdate updatePB = New RE_PriceBookBatchUpdate(updatePriceBook, insertJob);
                    Database.executeBatch(updatePB);                      
                }             
            }
            ReportFolderID =[SELECT Id, DeveloperName,Name,Type FROM Folder WHERE Name = 'RE MY Customer Opps' And  Type = 'Report' limit 1].id;
            resultdata.resultdata=ReportFolderID; 
            resultdata.status='true';
        }
        catch(exception ex){
            resultdata.status='false';
            resultdata.message=string.valueOf(ex);
            system.debug('exportReport ---ex--'+ex);
             system.debug('---getStackTraceString '+ex.getStackTraceString());            
        }
        return  resultdata;
    }
    //Based on the user login ,data will be return and same data will be send to GSAP system. 
    public static List<RT_Price_Book__c> getExportRecords(string datefilter,boolean isMidDay , string AddtionalFilter){
        List<String> ExportStatus = new List<String>{'Approved','Auto Approved'};
        List<String> retryStatus = new List<String>{'Ready to Upload','Failed'};
        Map<String,String> accessInfo=getAccessInfo(filterCondition);
        Map<Id,RT_Price_Book__c> Pricebookedited = new Map<Id,RT_Price_Book__c> ();
        Map<Id,RT_Price_Book__c> freqPricebook = new Map<Id,RT_Price_Book__c> ();
        List<RT_Price_Book__c> exportRecords = new List<RT_Price_Book__c>();
        List<Id> latestPriceBookContr = new List<Id>();             
        
        List<REV_Contract_Master__c> contractList = RE_SOQLController.fetchActiveContracts('Reseller');
        List<REV_Contract_Master__c> contractListDirect = RE_SOQLController.fetchActiveContracts('Direct');
        contractList.addAll(contractListDirect);
        string filterCond= ' '+ AddtionalFilter+'  RE_Valid_From__c  <= '+ datefilter +' AND RE_Valid_To__c >= '+datefilter+' '+(accessInfo.get('FilterCondition') == null ? '': accessInfo.get('FilterCondition'));
       
        for( RT_Price_Book__c PriceBookMap : getpricebookdata(filterCond,isMidDay)){           
            /*if( PriceBookMap.RE_Frequency_record__c == false)
                Pricebookedited.put(PriceBookMap.RE_Contract_Master__c,PriceBookMap);
            if(PriceBookMap.RE_Frequency_record__c == True)*/
                freqPricebook.put(PriceBookMap.RE_Contract_Master__c,PriceBookMap);            
        }
        /*if(!Pricebookedited.isEmpty() ||!freqPricebook.isEmpty()){
            for(REV_Contract_Master__c contractdata : contractList){               
                if(Pricebookedited.containsKey(contractdata.Id) && !latestPriceBookContr.contains(contractdata.Id)){
                    exportRecords.add(Pricebookedited.get(contractdata.Id));
                    latestPriceBookContr.add(contractdata.Id);
                }
                else{ 
                    if(freqPricebook.containsKey(contractdata.Id) && !latestPriceBookContr.contains(contractdata.Id)){
                        exportRecords.add(freqPricebook.get(contractdata.Id));
                        latestPriceBookContr.add(contractdata.Id);
                    }
                }
            }
        }  */
        if(!freqPricebook.isEmpty()){
            for(REV_Contract_Master__c contractdata : contractList){               
                if(freqPricebook.containsKey(contractdata.Id)){
                    if( (ExportStatus.contains(freqPricebook.get(contractdata.Id).RE_Custom_Opp_Approve__c) && CheckRetry ) 
                        || (retryStatus.contains(freqPricebook.get(contractdata.Id).RE_Custom_Opp_Approve__c) && !CheckRetry ) ){                            
                            exportRecords.add(freqPricebook.get(contractdata.Id));   
                        }                 
                }               
            }
        } 
        
        return exportRecords;
    }
    //Data format for GSAP interface, which is stored in Fixed_Price_Staging_Table__c object
    public static Fixed_Price_Staging_Table__c priceBookToGSAPtable(RT_Price_Book__c priceBook , String condition,integer SeqNum){
        RE_CustomOpps_ReportConfiguration__c reportcolumn =reportdetails.get(condition);
        Fixed_Price_Staging_Table__c gsaprecord=new Fixed_Price_Staging_Table__c();
        gsaprecord.Customer_Name__c =priceBook.RE_Contract_Master__r.RE_Customer_Name__r.name;
        gsaprecord.RE_Sequence_No__c=SeqNum;
        gsaprecord.RE_Is_CBU__c=priceBook.RE_Is_CBU__c;
        gsaprecord.RE_Currency_Unit__c=reportcolumn.RE_Unit__c;
        gsaprecord.RE_Is_latest__c=TRUE;
        gsaprecord.RE_Pricing_Condition__c=priceBook.RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name;
        gsaprecord.RE_Report_Type__c=reportcolumn.RE_Condition_Type__c;
        gsaprecord.REV_Price_Book__c=priceBook.Id;
        gsaprecord.RE_Valid_End_date__c=string.valueOf(priceBook.RE_Valid_To__c.year())+ (priceBook.RE_Valid_To__c.month() < 10 ? '0'+string.valueOf(priceBook.RE_Valid_To__c.month()) : string.valueOf(priceBook.RE_Valid_To__c.month())) +(priceBook.RE_Valid_To__c.day() <10 ? '0'+string.valueOf(priceBook.RE_Valid_To__c.day()) : string.valueOf(priceBook.RE_Valid_To__c.day()));
        gsaprecord.RE_Valid_start_date__c=string.valueOf(priceBook.RE_Valid_From__c.year())+ (priceBook.RE_Valid_From__c.month() < 10 ? '0'+string.valueOf(priceBook.RE_Valid_From__c.month()) : string.valueOf(priceBook.RE_Valid_From__c.month())) +(priceBook.RE_Valid_From__c.day() <10 ? '0'+string.valueOf(priceBook.RE_Valid_From__c.day()) : string.valueOf(priceBook.RE_Valid_From__c.day()));
        gsaprecord.RE_Cond_Usage_Table__c=reportcolumn.RE_Condition_Usage_Table__c;
        gsaprecord.RE_Cond_table_no__c=reportcolumn.RE_Condition_Table__c;
        gsaprecord.RE_Application__c=reportcolumn.RE_Application__c;
        gsaprecord.RE_Scale_Type__c=reportcolumn.RE_Scale_Type__c;
        gsaprecord.RE_Calculation_type__c=reportcolumn.RE_Calculation_Type__c;
        gsaprecord.RE_Value__c=string.valueOf(priceBook.get(reportcolumn.RE_Data_Type__c));
        gsaprecord.RE_Uom__c=reportcolumn.RE_UoM__c;
        gsaprecord.RE_Quantity__c=reportcolumn.RE_Quantity__c;  
        string varkeySt=reportcolumn.RE_Varkey__c;
        string finalVarKey='';
        String[] arrCond = varkeySt.split('\\+');
        for(String tempData : arrCond){ 
            if(tempData.isNumeric())
                finalVarKey=finalVarKey+tempData;
            else
                finalVarKey=finalVarKey+ priceBook.get(tempData);
        }
        gsaprecord.RE_Varkey__c = finalVarKey;
        
        return gsaprecord;
        
    } 
    //example : {Direct={Peninsular={YD04=a3x0C0000005rLNQAY}}, Reseller={Peninsular={YD03=a3x0C0000005rLKQAY, YD07=a3x0C0000005rLHQAY, YP01=a3x0C0000005rLEQAY}}
    public static Map<String,Map<String,Map<String , String>>> reportConfiguration(){
        Map<String,Map<String,Map<String , String>>> reportDataMap= new Map<String,Map<String,Map<String , String>>>();
        for(RE_CustomOpps_ReportConfiguration__c reportInfo:RE_CustomOpps_ReportConfiguration__c.getall().values()){
            system.debug(reportInfo.RE_Country_Name__c+'--reportInfo-'+ reportInfo.RE_Is_Active__c);
            if(reportInfo.RE_Is_Active__c && reportInfo.RE_Country_Name__c == 'Malaysia'){
                reportdetails.put(reportInfo.id,reportInfo);
                Map<String , String> Condition_TypeID= new  Map<String , String>();
                Map<String,Map<String , String>> regionConditon= new Map<String,Map<String , String>>();
                Map<String,Map<String,Map<String , String>>> reportTemp= new Map<String,Map<String,Map<String , String>>>();
                
                
                if(reportDataMap.containsKey(reportInfo.RE_Customer_Type__c)){ 
                    if(reportDataMap.get(reportInfo.RE_Customer_Type__c).containsKey(reportInfo.RE_Region__c)){            
                        Condition_TypeID=reportDataMap.get(reportInfo.RE_Customer_Type__c).get(reportInfo.RE_Region__c);            
                        Condition_TypeID.put(reportInfo.RE_Condition_Type__c,reportInfo.id);
                        regionConditon=reportDataMap.get(reportInfo.RE_Customer_Type__c);
                        regionConditon.put(reportInfo.RE_Region__c,Condition_TypeID);
                        reportDataMap.put(reportInfo.RE_Customer_Type__c,regionConditon);
                    }
                    else{
                        Condition_TypeID.put(reportInfo.RE_Condition_Type__c,reportInfo.id);
                        regionConditon=reportDataMap.get(reportInfo.RE_Customer_Type__c);
                        regionConditon.put(reportInfo.RE_Region__c,Condition_TypeID);
                        reportDataMap.put(reportInfo.RE_Customer_Type__c,regionConditon);            
                    }
                }
                else{
                    Condition_TypeID.put(reportInfo.RE_Condition_Type__c,reportInfo.id);
                    regionConditon.put(reportInfo.RE_Region__c,Condition_TypeID);
                    reportDataMap.put(reportInfo.RE_Customer_Type__c,regionConditon);
                }
                
                system.debug('---'+reportDataMap);
            }
        }
        return reportDataMap;
        
    }
    
    //Map of Direct and reseller customer
    public static RE_customerOppWrapper.getcustomerOppdata getMapPriceBook( List<RT_Price_Book__c> recalculatedvalues){
        Map<String,String> accessInfo=getAccessInfo(filterCondition);
        
        RE_customerOppWrapper.getcustomerOppdata  recalculatOppdata=new RE_customerOppWrapper.getcustomerOppdata();
        RE_customerOppWrapper.resellerlist resellerAlldata= new RE_customerOppWrapper.resellerlist();
        RE_customerOppWrapper.directlist directAlldata=new RE_customerOppWrapper.directlist();
        
        list<RE_customerOppWrapper.pricebookdata> resellerdata =new list<RE_customerOppWrapper.pricebookdata>();
        list<RE_customerOppWrapper.pricebookdata> directdata =new list<RE_customerOppWrapper.pricebookdata>();
        
        for(RT_Price_Book__c updatewrapper:recalculatedvalues){
            RE_customerOppWrapper.pricebookdata tempOppdata =new RE_customerOppWrapper.pricebookdata();
            tempOppdata=getMapOfPriceBookdata(updatewrapper,accessInfo); 
            if(updatewrapper.RE_Contract_Master__r.RE_Customer_Name__r.type =='Reseller'){
                resellerdata.add(tempOppdata);                 
            }
            else{
                directdata.add(tempOppdata);                
            }
        }
        resellerAlldata.resellerdata=resellerdata;
        directAlldata.directdata=directdata;   
        
        //adding Reseller and Direct to main wrapper class
        recalculatOppdata.direct=directAlldata;
        recalculatOppdata.reseller=resellerAlldata;
        
        return recalculatOppdata;
    }
    
    @AuraEnabled
    public static Map<String , String> checkNewContractData(){
        Map<String , String> returnMsg= new Map<String,String>();
        Id AccrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution MY').getRecordTypeId();
        
        List<Account> acclist= [SELECT Id FROM Account WHERE RT_Active__c = True AND recordtypeId = : AccrectypeId];
        List<Id> contractData = new List<Id>(new Map<Id, REV_Contract_Master__c>([Select Id from REV_Contract_Master__c where createddate=today AND Active__c = True  AND RE_Customer_Name__c IN: acclist AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today]).keySet());
        
        boolean newContractCreated= false;
        system.debug('--'+contractData);
        if(contractData.size() > 0){
            for(RT_Price_Book__c pbdadta : [select id ,RE_Contract_Master__c from RT_Price_Book__c where RE_Contract_Master__c IN : contractData ]){
                if(contractData.contains(pbdadta.RE_Contract_Master__c))
                    contractData.remove(contractData.indexOf(pbdadta.RE_Contract_Master__c));
                
            }
            
            if(contractData.size() > 0){
                //Insert a job to create custom opps data for Newly created data
                RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
                insertJob.RE_Run_Type__c='Manual';
                insertJob.RE_Job_Type__c = 'New Contract Pricing Output';
                insertJob.RE_User__c=UserInfo.getUserId();
                insertJob.RE_Run_Time__c=DateTime.now();                
                insertJob.RE_Country_Name__c = 'MY';
                try{
                    insert insertJob;
                }                
                catch(Exception e){
                    returnMsg.put('error','true');
                    returnMsg.put('message',JSON.serialize(e));
                }
                newContractCreated=true;
                returnMsg.put('error','false');
                returnMsg.put('message','Update Customer Opps is triggered, Pls refresh the page after 2mins');
                //list of contratc IDs need  send to create new price Book data
            }               
        } 
        if(!newContractCreated){
            returnMsg.put('error','true');
            returnMsg.put('message','No new contracted created');
        }
        
        return returnMsg;
    }
    
    public static void sendEmail(String emailtemplate,List<String> userIds){
        system.debug('inside email trigger--'+emailtemplate);
        // Pick a dummy Contact
        Contact c = [select id, Email from Contact where email <> null limit 1];
        string filtertoUser = ' <br> Filters to view records: <br> Customer Type : '+ customerTypeEmail +' <br> Dashboard View : '+ filterView + ' <br> Date : '+ filterDate + '  ';
        // Construct the list of emails we want to send
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId( [select id from EmailTemplate where Name=:emailtemplate].id );
        msg.setWhatId( [select id from Account limit 1].id );
        msg.setTargetObjectId(c.id);
        msg.setToAddresses(userIds);
        
        lstMsgs.add(msg);
        
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        //if(![SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox)
        Messaging.sendEmail(lstMsgs);
        
        Database.rollback(sp);
        
        // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
        // contents to a new SingleEmailMessage. Then send those new messages.
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : lstMsgs) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            filtertoUser =  email.getHTMLBody() + filtertoUser;
            emailToSend.setHTMLBody(filtertoUser);
            emailToSend.setSubject(email.getSubject());
            lstMsgsToSend.add(emailToSend);
        }
        //if(![SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox)
        Messaging.sendEmail(lstMsgsToSend);
    }
    
    @AuraEnabled(cacheable=true)
    public static boolean exportButtonContr(){
        boolean exContrl;
        RE_Job_Run_Audit__c[] TodaysExport = [select id ,RE_Job_Run_Count__c from RE_Job_Run_Audit__c where RE_Job_Type__c='MY Export Report' AND createdDate=today AND RE_Job_Status__c = 'Processing'];
        exContrl = (TodaysExport.size() > 0 ? true : false);        
        
        return exContrl;
    }
    
    @AuraEnabled
    public static  Map<String , String> refreshCBU(){
        Map<String , String> returnMsg= new Map<String,String>();

        //Check holiday or Sunday / Monday (There is no CBU on Sunday, Monday and day after public holiday)
        List<String> holidaysDate= new List<String>();
        //for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) ])
        for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'MY Holiday Calendar' ])
            holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
        Datetime currentDay = (DateTime)System.today();
        Datetime D_1 = currentDay.adddays(-1);
        String dayOfWeek = currentDay.format('EEEE');
        boolean checkNotHoliday = true;
        if( dayOfWeek == 'Monday' || dayOfWeek == 'Sunday' || holidaysDate.contains(string.valueof(D_1)))
            checkNotHoliday = false;
        
        try{
            if(checkNotHoliday){
                RE_MY_CustOpsCalculationController.updateLatestCBU();
                returnMsg.put('Error','false');
                returnMsg.put('message','Lasted CBU updated');
            }
            else{
                returnMsg.put('Error','true');
                if(holidaysDate.contains(string.valueof(D_1)))
                    returnMsg.put('message','There will be no CBU on Holidays');
                else
                    returnMsg.put('message','Sunday and Monday will be no CBU');
            }
        }
        catch(exception ex){
            returnMsg.put('Error','true');
            returnMsg.put('message',' '+ex);
        }
        
        return returnMsg;
    }
    
    //Approval process Scheme
     public static Map<String , Map< String , RT_Setting__c >> approvalScheme(String Country){ 
        Map<String , Map< String , RT_Setting__c >> approvalschemedata = new Map<String , Map< String , RT_Setting__c>>();
        for(RT_Setting__c temApproval : [SELECT Id,Name,RE_Approval_Status__c, RE_Approver_Role_1__c, RE_Approver_Role_2__c, RE_Max_Margin__c, RE_Min_Margin__c, 
                                         RE_User_Name__c, RE_User_Name__r.Name, RE_Delegate_Approver__c,RE_Delegate_Approver__r.Name FROM RT_Setting__c where recordType.Name = 'RE Approval Process' AND Country__c =:Country]){
            
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
    
    //check margin for price
      public static RT_Price_Book__c updateApprovalScheme(RT_Price_Book__c checkmargin , string scheme , Decimal marginValues){
        Map< String , RT_Setting__c> approvalSchemes = new Map< String , RT_Setting__c>();	
        
        if(approvalscheme.containsKey(scheme)){
            
            approvalSchemes = approvalscheme.get(scheme);
            
            for(String idkey : approvalSchemes.keySet()){               
                
                double max = approvalSchemes.get(idkey).RE_Max_Margin__c;
                double min = approvalSchemes.get(idkey).RE_Min_Margin__c;  
               
                if(max >= 0){                    
                    if(min <= marginValues &&  marginValues <= max){   
                        checkmargin.RE_ApprovalProcess__c = idkey;
                        checkmargin.RE_Custom_Opp_Approve__c = approvalSchemes.get(idkey).RE_Approval_Status__c;
                        break;
                    }
                }
                else{                    
                    if(max <= marginValues  &&  marginValues <= min){    
                        checkmargin.RE_ApprovalProcess__c = idkey;
                        checkmargin.RE_Custom_Opp_Approve__c = approvalSchemes.get(idkey).RE_Approval_Status__c;
                        break;
                    }
                }                
            } 
        }
          
        return checkmargin;            
    }  
    
    public static Decimal getMarginForApproval(RT_Price_Book__c marginCal,boolean isMidDay){
        Decimal margin = (marginCal.RE_Final_Price_Rebate__c != null ? marginCal.RE_Final_Price_Rebate__c : 0) - (marginCal.RE_BDF__c != null ? marginCal.RE_BDF__c : 0) - (marginCal.RE_DFOA_Charges__c != null ? marginCal.RE_DFOA_Charges__c : 0) - (marginCal.RE_Rebate__c != null ? marginCal.RE_Rebate__c : 0) - (marginCal.RE_CBU_MC__c != null ? marginCal.RE_CBU_MC__c : 0);
        if(isMidDay)
            return (margin).setScale(2);
        else
             return (margin - (marginCal.RE_Afternoon_Indication__c != null ? marginCal.RE_Afternoon_Indication__c : 0)).setScale(2) ;
    }
}