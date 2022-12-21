/************************************************************************************** 
@Name:  RE_PHCustomerDashboard        
@=================================================================================
@Purpose: This class process the PriceBook data and assign value to wrapper class (RE_customerOppWrapper) 
which is used in LWC to display data(re_ph_CODashboardParent).
@=================================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                                                 
@1- Souvik / Vijaykumar S     ```````````5-Aug-2021              
*************************************************************************************/
public class RE_PHCustomerDashboard {
    public static string  filterCondition=[Select id, RE_Customer_Opps_team__c from user where id=:UserInfo.getUserId()].RE_Customer_Opps_team__c;
    public static Map<string ,RE_CustomOpps_ReportConfiguration__c> reportdetails=new Map<String,RE_CustomOpps_ReportConfiguration__c>();
    //Mapping Approve Status to short Name
    public static Map<String, String> approveStatus = new Map<String, String>{'Not Submitted' => 'NS', 'Submitted STL' => 'SB' ,'Support STL' => 'SS', 'Support PM' => 'SP' ,'Approved' =>'AP' ,'Rejected' => 'RJ','Auto Approved' => 'AA' ,'Ready to Upload' => 'RU', 'Uploaded' => 'UP' , 'Failed' => 'FA', 'Upload not allowed' => 'UN'};
    Public Static Map<String,RE_PH_OutputController.costDataWrapper> costdatalistvalues = RE_PH_AspriedUC3.phCBUdata(true);
    public static List<Id> priceBookId = new List<Id>();
    Public Static Map<String , Double > exciseTax = RE_PH_AspriedUC3.exciseTaxList();
    public static boolean CheckRetry = false;
    
    @AuraEnabled(cacheable=false)
    public static RE_customerOppWrapper.getcustomerOppdata getallData(List<RT_Price_Book__c> creatwrapper){
        Map<String,String> accessInfo=getAccessInfo(filterCondition);
        date cubDate;
        //filter picklist values
        List<RE_customerOppWrapper.picklistdata> Plant = new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> Material = new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> customer = new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> AMcode = new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> SoldTo = new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> CalMod = new List<RE_customerOppWrapper.picklistdata>();
        List<RE_customerOppWrapper.picklistdata> status = new List<RE_customerOppWrapper.picklistdata>();
        
        //Main PriceBook data
        list<RE_customerOppWrapper.pricebookdata> maindata =new list<RE_customerOppWrapper.pricebookdata>();
        
        //Picklist and PriceBook data 
        RE_customerOppWrapper.resellerlist customerAlldata= new RE_customerOppWrapper.resellerlist();
        
        //final data of PriceBook , picklist details of customer opps
        RE_customerOppWrapper.getcustomerOppdata customOppdata = new RE_customerOppWrapper.getcustomerOppdata();
        
        //to find unique values for Reseller filters 
        set<string> plantRes=new set<string>();
        set<string> matRes=new set<string>();
        set<string> customerNameRes=new set<string>();
        set<string> soldToRes=new set<string>();
        set<string> amCodeRes=new set<string>();
        set<string> ClaRes=new set<string>();
        set<string> statusRes=new set<string>();
        
        //initial picklist values
        RE_customerOppWrapper.picklistdata temallSelected=new RE_customerOppWrapper.picklistdata();
        temallSelected.label='All';
        temallSelected.value='All';
        //initial picklist value to All for Reseller filter        
        Plant.add(temallSelected);
        Material.add(temallSelected);
        //resellercustomer.add(temallSelected);
        AMcode.add(temallSelected);
        SoldTo.add(temallSelected);  
        CalMod.add(temallSelected);
        status.add(temallSelected);
        
        
        for(RT_Price_Book__c updatewrapper:creatwrapper){            
            cubDate =updatewrapper.RE_CBU_valid_from__c;
            //this variable holds the Price book list temporarily and finally add to the main list 
            RE_customerOppWrapper.pricebookdata tempOppdata =new RE_customerOppWrapper.pricebookdata();
            
            //temporary variables for picklist values
            RE_customerOppWrapper.picklistdata temPlant=new RE_customerOppWrapper.picklistdata();
            RE_customerOppWrapper.picklistdata temMaterial=new RE_customerOppWrapper.picklistdata();
            RE_customerOppWrapper.picklistdata temcustomer=new RE_customerOppWrapper.picklistdata();
            RE_customerOppWrapper.picklistdata temSlodTo=new RE_customerOppWrapper.picklistdata();
            RE_customerOppWrapper.picklistdata temAMcode=new RE_customerOppWrapper.picklistdata();  
            RE_customerOppWrapper.picklistdata temCalculationMod=new RE_customerOppWrapper.picklistdata();
            RE_customerOppWrapper.picklistdata temStatus=new RE_customerOppWrapper.picklistdata();
            
            
            //add plant to picklist value            
            temPlant.label=updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.Name;
            temPlant.value=updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c;
            
            //add Material to picklist value
            temMaterial.label=updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.Name;            
            temMaterial.value=updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c;
            
            //add Customer to picklist value            
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
            temCalculationMod.label=updatewrapper.RE_Contract_Master__r.RE_Calculation_Type__c;
            temCalculationMod.value=updatewrapper.RE_Contract_Master__r.RE_Calculation_Type__c;
            
            //Add status of the record
            temStatus.label = updatewrapper.RE_Custom_Opp_Approve__c;
            temStatus.value = approveStatus.get(updatewrapper.RE_Custom_Opp_Approve__c);
            
            //get the map data for pricebook data
            tempOppdata=getMapOfPriceBookdata(updatewrapper,accessInfo); 
            
            //check plant is added to picklist
            if(!plantRes.contains(updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c)){
                Plant.add(temPlant);
                plantRes.add(updatewrapper.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c);
            }                
            //check Material is added to picklist
            if(!matRes.contains(updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c)){
                Material.add(temMaterial);
                matRes.add(updatewrapper.RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c);
            }
            //check customer name added to picklist
            if(!customerNameRes.contains(custId)){
                customer.add(temcustomer);
                customerNameRes.add(custId);                    
            }
            //check soldTo name added to picklist
            if(!soldToRes.contains(string.valueOf(updatewrapper.RE_Sold_To_Number__c))){
                SoldTo.add(temSlodTo); 
                soldToRes.add(string.valueOf(updatewrapper.RE_Sold_To_Number__c)); 
            }                
            //check AM code name added to picklist
            if(!amCodeRes.contains(updatewrapper.RE_AM_Code__c) && updatewrapper.RE_AM_Code__c != null){
                AMcode.add(temAMcode);
                amCodeRes.add(updatewrapper.RE_AM_Code__c);                    
            }
            //check AM code name added to picklist
            if(!ClaRes.contains(updatewrapper.RE_Contract_Master__r.RE_Calculation_Type__c)){
                CalMod.add(temCalculationMod);
                ClaRes.add(updatewrapper.RE_Contract_Master__r.RE_Calculation_Type__c);                    
            }       
            
            //Check status added to picklist
            if(!statusRes.contains(updatewrapper.RE_Custom_Opp_Approve__c)){
                status.add(temStatus);
                statusRes.add(updatewrapper.RE_Custom_Opp_Approve__c);
            }
            
            maindata.add(tempOppdata);  
        }
        
        //adding all Picklist data to final wrapper class
        customerAlldata.Material = Material;
        customerAlldata.plant = Plant;
        customerAlldata.customerName = customer;
        customerAlldata.soldTo = SoldTo;
        customerAlldata.amCode = AMcode;
        customerAlldata.resellerdata = maindata;
        customerAlldata.CalMod = CalMod;
        customerAlldata.status = status;
        //adding Customer information to main warapper       
        customOppdata.reseller=customerAlldata;
        //customOppdata.isApprover= (filterCondition != null ? filterCondition : 'ViewOnly');
        customOppdata.isApprover = Boolean.valueOf(accessInfo.get('is_Approver'));
        customOppdata.cubpublishDate=cubDate;
        customOppdata.controlFunction = Boolean.valueOf(accessInfo.get('viewOnly'));
        
        
        system.debug('RE_customerOppWrapper.getcustomerOppdata >>>  final data--'+customOppdata);
        return customOppdata;
    }
    
    //SOQL for get CBU data where CBU date is less than today
    public static List<RT_Price_Book__c> getPHpricebookdata(String filtercondition){
        string QueryStr = 'select Id,RecordTypeId,RE_Latest_price_dt__c,RE_Price_support__c,RE_Excise_tax__c,RE_CBU_Last_offered__c,RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.name,RE_Customer_Name__r.Type,RE_Contract_Master__r.RE_Customer_Name__r.id,RE_Contract_Master__r.RE_Customer_Name__r.name,RE_Contract_Master__r.RE_Customer_Name__r.RE_Address__c,RE_Contract_Master__r.RT_Plant_Desc__r.RE_Abbreviated_Name__c,RE_Contract_Master__r.RE_Custom_Ops_Calculation__r.Name,RE_Approver_Comments__c,RE_CBU_output_date__c,';
        QueryStr = QueryStr+'RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.id,RE_Contract_Master__r.RE_Price_support__c,RE_Contract_Master__r.RE_PS_valid_from__c,RE_Contract_Master__r.RE_PS_valid_to__c,RE_Contract_Master__r.RT_Plant_Desc__r.Name,RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c, RE_Contract_Master__r.RT_Plant_Desc__r.RE_Region_Name__c ,RE_Contract_Master__r.RE_Customer_Name__r.RE_Auto_Approve__c,RE_Valid_From__c,RE_Valid_To__c,RE_Approved_By__c,RE_Approved_By__r.name,RE_Contract_Master__r.RE_Transport_Mode__c,RE_CBU_valid_To__c,RE_CBU_valid_from__c,';
        QueryStr = QueryStr+'RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c ,RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Group__c,RE_Contract_Master__r.RT_Material_Desc__r.RE_Product_Short_Name__c,RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c,RE_Contract_Master__r.RT_Material_Desc__r.Name,RE_AM_Code__c,RE_Submitter_Comments__c,RE_Backstop_Margin__c , RE_Contract_Master__r.RE_PH_Approval_Scheme__c,RE_Reference_Period__c,';
        QueryStr = QueryStr+'RE_Service_SurChg__c, LastModifiedBy.Name,RE_List_Price__c,RE_Std_Disc__c,RE_Final_Price_Rebate__c,RE_Discount__c,RE_Sold_To_Number__c,RE_Submitter__c,RE_Submitter__r.name,RE_CBU_LDC__c,RE_Job_Counter__c,RE_D_1_UC3__c,RE_M_1_UC3__c,RE_MTD_UC3__c,RE_W_1_UC3__c,RE_WTD_UC3__c,RE_ApprovalProcess__r.RE_Delegate_Approver__r.Email,RE_ApprovalProcess__r.RE_User_Name__r.Email,RE_Contract_Master__r.RT_CONDITION_TABLE_ID__c,RE_Distribution_Channel__c,';
        QueryStr = QueryStr+'RE_Ship_To_Number__c,RE_CBU_MC__c,RE_Custom_Opp_Approve__c,RE_Is_Latest__c,RT_Product__c,RT_Location__c,RT_Country__c,RE_Reference_Price__c,RE_RefUC3_Price__c ,RE_ApprovalProcess__c ,RE_ApprovalProcess__r.Name , RE_ApprovalProcess__r.RE_Approval_Status__c ,RE_ApprovalProcess__r.RE_Approver_Role_1__c  ,RE_ApprovalProcess__r.RE_Approver_Role_2__c ,RE_ApprovalProcess__r.RE_Delegate_Approver__r.Name,RE_ApprovalProcess__r.RE_User_Name__r.Name,';
        QueryStr = QueryStr+'RE_Contract_Master__c ,RE_Transport_Charge__c,RE_Yesterday_Final_Price__c,RE_Customer_Name__c,RE_Contract_Master__r.RE_Customer_Name__r.type,RE_Sales_Org__c,RE_Customer_Group__c,RE_Material_Code__c,RT_Location_Code__c,RT_Product__r.RE_Material__c,RE_AutoCalRefAmnt__c,RE_AutoCalRefAmntAdj__c,RE_Contract_Master__r.RE_Calculation_Type__c,RE_Contract_Master__r.RE_Reference_Period__c  from RT_Price_Book__c where RT_Country__c =\'PH\'   ';
        QueryStr = QueryStr+(filtercondition != '' && filtercondition != null ? ' AND '+filtercondition:'');
        QueryStr = QueryStr+' order by RE_Latest_price_dt__c desc ';
        system.debug('RE_customOppController.getpricebookOlddata>>>'+QueryStr);
        return Database.query(QueryStr);        
    }
    
    //add the pricebook data to wrapper class
    public static RE_customerOppWrapper.pricebookdata getMapOfPriceBookdata(RT_Price_Book__c tmppbdata,Map<String,string> accessInfo){
        
        RE_customerOppWrapper.pricebookdata tempOppdata =new RE_customerOppWrapper.pricebookdata();
        
        string keyCBU = tmppbdata.RE_Contract_Master__r.RT_Material_Desc__r.Name + '_' +tmppbdata.RE_Contract_Master__r.RT_Plant_Desc__r.Name ;
        system.debug('---key--'+keyCBU);
        
        tempOppdata.id=tmppbdata.id;
        //Ship To customer Name 
        tempOppdata.customerName=tmppbdata.RE_Contract_Master__r.RE_Customer_Name__r.name;
        tempOppdata.customerNameId='/'+tmppbdata.RE_Contract_Master__r.RE_Customer_Name__r.id;
        //Sold To customer Name
        tempOppdata.customerNameSoldTo=(tmppbdata.RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c =='Ship To' ?
                                        tmppbdata.RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.name : 
                                        tmppbdata.RE_Contract_Master__r.RE_Customer_Name__r.name);
        tempOppdata.customerSoldToID=(tmppbdata.RE_Contract_Master__r.RE_Customer_Name__r.Customer_Type__c =='Ship To' ?
                                      '/'+tmppbdata.RE_Contract_Master__r.RE_Customer_Name__r.RE_Parent_Customer__r.Id : 
                                      '/'+tmppbdata.RE_Contract_Master__r.RE_Customer_Name__r.Id);     
        
        tempOppdata.product = tmppbdata.RE_Contract_Master__r.RT_Material_Desc__r.Name;
        tempOppdata.productCode = tmppbdata.RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c;
        tempOppdata.exciseTax = tmppbdata.RE_Excise_tax__c != null ? String.valueof(tmppbdata.RE_Excise_tax__c) : '0.0';
        tempOppdata.Location = tmppbdata.RE_Contract_Master__r.RT_Plant_Desc__r.Name;
        tempOppdata.locationCode = tmppbdata.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c;
        tempOppdata.amCode = tmppbdata.RE_AM_Code__c;
        tempOppdata.salesOrg = tmppbdata.RE_Sales_Org__c;
        tempOppdata.transportCharge = string.valueOf(tmppbdata.RE_Transport_Charge__c != null ? tmppbdata.RE_Transport_Charge__c : 0.00);
        tempOppdata.tptMode = tmppbdata.RE_Contract_Master__r.RE_Transport_Mode__c;
        tempOppdata.listPrice = string.valueOf(tmppbdata.RE_List_Price__c != null ? tmppbdata.RE_List_Price__c : 0.00);
        tempOppdata.tieredDiscount = string.valueOf(tmppbdata.RE_Std_Disc__c != null ? tmppbdata.RE_Std_Disc__c : 0.00);
        tempOppdata.finalPrice = string.valueOf(tmppbdata.RE_Final_Price_Rebate__c != null ? tmppbdata.RE_Final_Price_Rebate__c : 0.00);
        //tempOppdata.finalPrice = string.valueOf(40);
        tempOppdata.finalPriceOld = string.valueOf(tmppbdata.RE_Final_Price_Rebate__c != null ? tmppbdata.RE_Final_Price_Rebate__c : 0.00); 
        //tempOppdata.finalPriceOld =  '0.00';        
        tempOppdata.discount = string.valueOf(tmppbdata.RE_Discount__c != null ? tmppbdata.RE_Discount__c : 0.00);
        tempOppdata.soldTo = string.valueOf(tmppbdata.RE_Sold_To_Number__c);
        tempOppdata.shipTo = string.valueOf(tmppbdata.RE_Ship_To_Number__c);
        tempOppdata.shipToAddress = string.valueOf(tmppbdata.RE_Contract_Master__r.RE_Customer_Name__r.RE_Address__c);
        tempOppdata.cbuMC = string.valueOf(tmppbdata.RE_CBU_MC__c != null ? tmppbdata.RE_CBU_MC__c  : 0.00);
        tempOppdata.startDate = tmppbdata.RE_Valid_From__c;
        tempOppdata.startDateOld = tmppbdata.RE_Valid_From__c;
        tempOppdata.endDate = tmppbdata.RE_Valid_To__c;
        tempOppdata.endDateOld = tmppbdata.RE_Valid_To__c ;
        tempOppdata.approveStatus = approveStatus.get(tmppbdata.RE_Custom_Opp_Approve__c);
        tempOppdata.approveStatusFull = tmppbdata.RE_Custom_Opp_Approve__c;
        if(tmppbdata.RE_CBU_Last_offered__c)
            tempOppdata.recordMode = false;
        else
            tempOppdata.recordMode = Boolean.valueOf(accessInfo.get(tmppbdata.RE_Custom_Opp_Approve__c));
        tempOppdata.inlineEdit = false;
        tempOppdata.approvedBy = tmppbdata.RE_Approved_By__r.name;
        tempOppdata.isChecked = false;
        //tempOppdata.checkBoxController = (filterCondition == 'Customer Opps Team' ? (tmppbdata.RE_Custom_Opp_Approve__c=='Not Submitted' ? true:false) : true);
        if(tmppbdata.RE_CBU_Last_offered__c)
            tempOppdata.checkBoxController = false;
        else
            tempOppdata.checkBoxController = Boolean.valueOf( accessInfo.get('is_Approver') == 'true' ? accessInfo.get(tmppbdata.RE_Custom_Opp_Approve__c) : (tmppbdata.RE_Custom_Opp_Approve__c=='Not Submitted' ? 'true' : 'false') );
        tempOppdata.submittedBy = tmppbdata.RE_Submitter__r.name;
        tempOppdata.contractID = tmppbdata.RE_Contract_Master__c;   
        tempOppdata.customerID = tmppbdata.RE_Customer_Name__c;
        tempOppdata.RE_CBU_LDC = string.valueOf(tmppbdata.RE_CBU_LDC__c != null ? tmppbdata.RE_CBU_LDC__c : 0.00);
        tempOppdata.InlineEdit = false;
        tempOppdata.approverComments = (tmppbdata.RE_Approver_Comments__c != null ? tmppbdata.RE_Approver_Comments__c:'');
        tempOppdata.submitterComments = (tmppbdata.RE_Submitter_Comments__c != null ? tmppbdata.RE_Submitter_Comments__c:'');
        tempOppdata.submitterCommentsOld = (tmppbdata.RE_Submitter_Comments__c != null ? tmppbdata.RE_Submitter_Comments__c:'');
        tempOppdata.lastModifiedBy= tmppbdata.LastModifiedBy.Name;
        tempOppdata.yesterdayFinalPrice=string.valueOf(tmppbdata.RE_Yesterday_Final_Price__c);
        tempOppdata.avatarCssClass='slds-avatar__initials slds-icon-standard-account '+ approveStatus.get(tmppbdata.RE_Custom_Opp_Approve__c);
        tempOppdata.autocalcrefamnt = tmppbdata.RE_AutoCalRefAmnt__c != null ? string.valueOf( tmppbdata.RE_AutoCalRefAmnt__c) : '';
        tempOppdata.autocalcrefamntadj = tmppbdata.RE_AutoCalRefAmntAdj__c != null ? string.valueOf( tmppbdata.RE_AutoCalRefAmntAdj__c) : '';
        tempOppdata.calcmethod = tmppbdata.RE_Contract_Master__r.RE_Calculation_Type__c != null ? tmppbdata.RE_Contract_Master__r.RE_Calculation_Type__c : '';
        tempOppdata.refperiod = tmppbdata.RE_Contract_Master__r.RE_Reference_Period__c != null ? tmppbdata.RE_Contract_Master__r.RE_Reference_Period__c : '';
        tempOppdata.refperiodOld = tmppbdata.RE_Contract_Master__r.RE_Reference_Period__c != null ? tmppbdata.RE_Contract_Master__r.RE_Reference_Period__c : '';
        tempOppdata.refprice = tmppbdata.RE_Reference_Price__c != null ? string.valueOf( tmppbdata.RE_Reference_Price__c ) : '';
        tempOppdata.refuc3 = tmppbdata.RE_RefUC3_Price__c != null ? string.valueOf( tmppbdata.RE_RefUC3_Price__c) : '';
        tempOppdata.backStopMargin = string.valueOf(tmppbdata.RE_Backstop_Margin__c);
        tempOppdata.approvalScheme = tmppbdata.RE_Contract_Master__r.RE_PH_Approval_Scheme__c;
        tempOppdata.approverRole = '';
        tempOppdata.approverName = '';
        tempOppdata.priceSupport = string.valueOf(tmppbdata.RE_Price_support__c != null ? tmppbdata.RE_Price_support__c : 0.00);
        tempOppdata.priceSupportOld = string.valueOf(tmppbdata.RE_Price_support__c != null ? tmppbdata.RE_Price_support__c : 0.00);
        tempOppdata.psStartDate = tmppbdata.RE_Contract_Master__r.RE_PS_valid_from__c;
        tempOppdata.psStartDateOld = tmppbdata.RE_Contract_Master__r.RE_PS_valid_from__c;
        tempOppdata.psEndDate = tmppbdata.RE_Contract_Master__r.RE_PS_valid_to__c < date.today() ? null : tmppbdata.RE_Contract_Master__r.RE_PS_valid_to__c;
        tempOppdata.psEndDateOld = tmppbdata.RE_Contract_Master__r.RE_PS_valid_to__c < date.today() ? null : tmppbdata.RE_Contract_Master__r.RE_PS_valid_to__c;

        System.debug('-tmppbdata.RE_ApprovalProcess__r.RE_Approval_Status__c--'+tmppbdata.RE_ApprovalProcess__r.RE_Approval_Status__c);
        if(tmppbdata.RE_ApprovalProcess__c != null && tmppbdata.RE_ApprovalProcess__r.RE_Approval_Status__c == 'Not Submitted'){
            if(tmppbdata.RE_Custom_Opp_Approve__c == 'Submitted STL' || tmppbdata.RE_Custom_Opp_Approve__c == 'Not Submitted'){
                tempOppdata.approverRole = tmppbdata.RE_ApprovalProcess__r.RE_Approver_Role_1__c;
                tempOppdata.approverName = tmppbdata.RE_ApprovalProcess__r.RE_User_Name__r.Name ;
            }
            else if(tmppbdata.RE_Custom_Opp_Approve__c == 'Support STL'){
                tempOppdata.approverRole = tmppbdata.RE_ApprovalProcess__r.RE_Approver_Role_2__c ;
                tempOppdata.approverName = tmppbdata.RE_ApprovalProcess__r.RE_Delegate_Approver__r.Name ;
            }
        }
        
        
        //UC3 margins values        
        tempOppdata.uc3M_1 = tmppbdata.RE_M_1_UC3__c != null ? string.valueOf( tmppbdata.RE_M_1_UC3__c) : '0.0';
        tempOppdata.uc3MTD = tmppbdata.RE_MTD_UC3__c != null ? string.valueOf( tmppbdata.RE_MTD_UC3__c) : '0.0';
        tempOppdata.uc3WTD = tmppbdata.RE_WTD_UC3__c != null ? string.valueOf( tmppbdata.RE_WTD_UC3__c) : '0.0';
        tempOppdata.uc3D_1 = tmppbdata.RE_D_1_UC3__c != null ? string.valueOf( tmppbdata.RE_D_1_UC3__c) : '0.0';
        tempOppdata.uc3W_1 = tmppbdata.RE_W_1_UC3__c != null ? string.valueOf( tmppbdata.RE_W_1_UC3__c) : '0.0';
        
        system.debug('---CBU data --'+costdatalistvalues.get(keyCBU) );
        //CBU values 
        if(costdatalistvalues.containsKey(keyCBU)){            
            tempOppdata.tpM_1 = costdatalistvalues.get(keyCBU).M1tpData != null ?  String.valueof(costdatalistvalues.get(keyCBU).M1tpData) : '0.0';
            tempOppdata.tpMTD = costdatalistvalues.get(keyCBU).MTDtpData != null ?  String.valueof(costdatalistvalues.get(keyCBU).MTDtpData) : '0.0';
            tempOppdata.tpWTD = costdatalistvalues.get(keyCBU).WTDtpData != null ?  String.valueof(costdatalistvalues.get(keyCBU).WTDtpData) : '0.0';
            tempOppdata.tpD_1 = costdatalistvalues.get(keyCBU).D1tpData != null ?  String.valueof(costdatalistvalues.get(keyCBU).D1tpData) : '0.0';
            tempOppdata.tpW_1 = costdatalistvalues.get(keyCBU).W1tpData != null ?  String.valueof(costdatalistvalues.get(keyCBU).W1tpData) : '0.0';
            tempOppdata.exgM_1 = costdatalistvalues.get(keyCBU).M1Data != null ?  String.valueof(costdatalistvalues.get(keyCBU).M1Data) : '0.0';
            tempOppdata.exgMTD = costdatalistvalues.get(keyCBU).MTDData != null ?  String.valueof(costdatalistvalues.get(keyCBU).MTDData) : '0.0';
            tempOppdata.exgWTD = costdatalistvalues.get(keyCBU).WTDData != null ?  String.valueof(costdatalistvalues.get(keyCBU).WTDData) : '0.0';
            tempOppdata.exgD_1 = costdatalistvalues.get(keyCBU).D1Data != null ?  String.valueof(costdatalistvalues.get(keyCBU).D1Data) : '0.0';
            tempOppdata.exgW_1 = costdatalistvalues.get(keyCBU).W1Data != null ?  String.valueof(costdatalistvalues.get(keyCBU).W1Data) : '0.0';          
            tempOppdata.d_1vsD_2 = costdatalistvalues.get(keyCBU).D1VSD2Data != null ?  String.valueof(costdatalistvalues.get(keyCBU).D1VSD2Data) : '0.0';
            tempOppdata.d_1vsWTD = costdatalistvalues.get(keyCBU).D1VSWTDData != null ?  String.valueof(costdatalistvalues.get(keyCBU).D1VSWTDData) : '0.0';
            tempOppdata.d_1vsW_1 = costdatalistvalues.get(keyCBU).D1VSW1Data != null ?  String.valueof(costdatalistvalues.get(keyCBU).D1VSW1Data) : '0.0';
            tempOppdata.d_1vsMTD = String.valueof (decimal.valueof(tempOppdata.exgD_1) - decimal.valueof(tempOppdata.exgMTD));
            tempOppdata.d_1vsM_1 = costdatalistvalues.get(keyCBU).D1VSM1Data != null ?  String.valueof(costdatalistvalues.get(keyCBU).D1VSM1Data) : '0.0';
            tempOppdata.wtdvsW_1 = costdatalistvalues.get(keyCBU).WTDVSW1Data != null ?  String.valueof(costdatalistvalues.get(keyCBU).WTDVSW1Data) : '0.0';
            tempOppdata.w_1vsW_2 = costdatalistvalues.get(keyCBU).W1VSW2Data != null ?  String.valueof(costdatalistvalues.get(keyCBU).W1VSW2Data) : '0.0';
            tempOppdata.mtdvsM_1 = String.valueof(decimal.valueof(tempOppdata.exgMTD) - decimal.valueof(tempOppdata.exgM_1));
        }
        else{
             tempOppdata.tpM_1 = '0.0';
            tempOppdata.tpMTD = '0.0';
            tempOppdata.tpWTD = '0.0';
            tempOppdata.tpD_1 = '0.0';
            tempOppdata.tpW_1 = '0.0';
            tempOppdata.exgM_1 = '0.0';
            tempOppdata.exgMTD = '0.0';
            tempOppdata.exgWTD = '0.0';
            tempOppdata.exgD_1 = '0.0';
            tempOppdata.exgW_1 = '0.0';          
            tempOppdata.d_1vsD_2 = '0.0';
            tempOppdata.d_1vsWTD = '0.0';
            tempOppdata.d_1vsW_1 = '0.0';
            tempOppdata.d_1vsMTD = String.valueof (decimal.valueof(tempOppdata.exgD_1) - decimal.valueof(tempOppdata.exgMTD));
            tempOppdata.d_1vsM_1 = '0.0';
            tempOppdata.wtdvsW_1 = '0.0';
            tempOppdata.w_1vsW_2 = '0.0';
            tempOppdata.mtdvsM_1 = String.valueof(decimal.valueof(tempOppdata.exgMTD) - decimal.valueof(tempOppdata.exgM_1));
        }
        
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
    
    @AuraEnabled
    public static RE_customerOppWrapper.getcustomerOppdata  getFilteredDate(string datefilter,string CalculationModel, String userfilter){ 
        Map<Id,RT_Price_Book__c> Pricebookedited = new Map<Id,RT_Price_Book__c> ();
        List<REV_Contract_Master__c> contractList = RE_SOQLController.fetchPHActiveContracts('PH','Revolution PH').values();
        Map<Id ,REV_Contract_Master__c > checkContracts = New Map<Id ,REV_Contract_Master__c >(contractList);
        List<RT_Price_Book__c> disPlayPrice = new List<RT_Price_Book__c>();
        
        string filterCond = ' RE_Contract_Master__r.RE_Account_Manager__c = \''+ userfilter + '\' AND';
        //string filterCond ='';
        DateTime  selectedDate = date.valueOf(datefilter);
        DateTime  jobRunDate = date.valueOf(datefilter);
        
        if( selectedDate.date() < System.today() ){
            filterCond = filterCond +' RE_CBU_valid_from__c <= '+ datefilter + ' AND RE_CBU_valid_To__c >= '+datefilter+' ' + ' AND RE_Valid_From__c  <= '+ datefilter +' AND RE_Valid_To__c >= '+datefilter;           
        }
        else{
            filterCond = filterCond + ' RE_Valid_From__c  <= '+ datefilter +' AND RE_Valid_To__c >= '+datefilter +' AND RE_Is_Latest__c = true ';
        }   
        disPlayPrice = getPHpricebookdata(filterCond);
        
        
        if(!disPlayPrice.isEmpty()){
            for(RT_Price_Book__c checkLatest : disPlayPrice){       
                if( !Pricebookedited.containskey(checkLatest.RE_Contract_Master__c) && checkContracts.containskey(checkLatest.RE_Contract_Master__c)){
                    Pricebookedited.put(checkLatest.RE_Contract_Master__c ,checkLatest );
                }
            }
        }
        
        return getallData(Pricebookedited.values());
    }
    
    //Save the new tranctional data
    @AuraEnabled
    public Static list<RE_customerOppWrapper.pricebookdata>  savePricebook(List<RE_customerOppWrapper.pricebookdata> wrapPBDataList, string customerType , List<Id> idChanged,string datefilter){
        RE_PH_AspriedUC3.approvalscheme = RE_PH_AspriedUC3.approvalScheme();
        system.debug('RE_customOppController.convertToPriceBook >>>>'+wrapPBDataList);
        List<String> approvedStatus = new List<String>{'Approved','Auto Approved','Ready to Upload','Uploaded','Failed','Upload not allowed'};
        priceBookId.clear();
        priceBookId = idChanged;
        Map<id,RT_Price_Book__c> finaldata =new Map<Id,RT_Price_Book__c>(getPHpricebookdata(' id =: priceBookId'));
        List<RT_Price_Book__c> updatedValues = new List<RT_Price_Book__c>();
        List<REV_Contract_Master__c> contractdata = new List<REV_Contract_Master__c>();
        Map<Id,RE_customerOppWrapper.pricebookdata> contractdataMap = new Map<Id,RE_customerOppWrapper.pricebookdata>();
        
        system.debug('---data --' +finaldata);
        for(RE_customerOppWrapper.pricebookdata wrappbdata : wrapPBDataList){
            if( (wrappbdata.finalPrice != wrappbdata.finalPriceOld || wrappbdata.refperiod != wrappbdata.refperiodOld ||  wrappbdata.startDate != wrappbdata.startDateOld || wrappbdata.endDate != wrappbdata.endDateOld || 
                 wrappbdata.priceSupport != wrappbdata.priceSupportOld  || wrappbdata.psEndDate != wrappbdata.psEndDateOld) && finaldata.containsKey(wrappbdata.Id)){
                     system.debug('inide if '+ wrappbdata.priceSupport);
                     system.debug('inide if '+ wrappbdata.priceSupportOld);    
                     RT_Price_Book__c newPrBook = new RT_Price_Book__c();
                     newPrBook = finaldata.get(wrappbdata.Id).clone(false, true, false, false);
                     newPrBook.Id= null;
                     newPrBook.RE_Job_Counter__c = (finaldata.get(wrappbdata.Id).RE_Job_Counter__c != null ? finaldata.get(wrappbdata.Id).RE_Job_Counter__c + 1 : 0);
                     newPrBook.RE_Latest_price_dt__c = DateTime.now();
                     newPrBook.RE_Final_Price_Rebate__c=Decimal.ValueOf(wrappbdata.finalPrice == null ? '0' : wrappbdata.finalPrice);                
                     //newPrBook.RE_Valid_From__c = date.valueOf(datefilter);
                     newPrBook.RE_Valid_From__c = wrappbdata.startDate;                
                     newPrBook.RE_Valid_To__c = wrappbdata.endDate;
                     newPrBook.RE_Submitter_Comments__c = wrappbdata.submitterComments;     
                     //newPrBook.RE_Price_support__c =  Decimal.ValueOf(wrappbdata.priceSupport);
                     if( wrappbdata.psEndDate != null && wrappbdata.psEndDate >= date.today()){
                         newPrBook.RE_Price_support__c = wrappbdata.priceSupport != null ? decimal.valueof(wrappbdata.priceSupport) : 0.00;                           
                     }
                     if(wrappbdata.calcmethod == 'Aspired Margin' & wrappbdata.priceSupport != wrappbdata.priceSupportOld ){
                         newPrBook.RE_Final_Price_Rebate__c = newPrBook.RE_Final_Price_Rebate__c - newPrBook.RE_Price_support__c;
                     }
                     else if(wrappbdata.calcmethod == 'Aspired Margin' & wrappbdata.finalPrice != wrappbdata.finalPriceOld){
                         newPrBook.RE_D_1_UC3__c =  Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgD_1);
                         newPrBook.RE_W_1_UC3__c =  Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgW_1);
                         newPrBook.RE_M_1_UC3__c =  Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgM_1);
                         newPrBook.RE_WTD_UC3__c =  Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgWTD);
                         newPrBook.RE_MTD_UC3__c =  Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgMTD);
                     	 
                     }
                     else{
                         newPrBook.RE_D_1_UC3__c = Decimal.ValueOf(wrappbdata.priceSupport) + Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgD_1);
                         newPrBook.RE_W_1_UC3__c = Decimal.ValueOf(wrappbdata.priceSupport) + Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgW_1);
                         newPrBook.RE_M_1_UC3__c = Decimal.ValueOf(wrappbdata.priceSupport) + Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgM_1);
                         newPrBook.RE_WTD_UC3__c = Decimal.ValueOf(wrappbdata.priceSupport) + Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgWTD);
                         newPrBook.RE_MTD_UC3__c = Decimal.ValueOf(wrappbdata.priceSupport) + Decimal.ValueOf(wrappbdata.finalPrice) - Decimal.ValueOf(wrappbdata.exciseTax) - Decimal.ValueOf(wrappbdata.transportCharge) - Decimal.ValueOf(wrappbdata.exgMTD);
                     }
                     String marginCheck = newPrBook.RE_Reference_Period__c;
                     newPrBook.RE_RefUC3_Price__c = double.valueof(newPrBook.get(marginCheck));
                     //updatedValues.add(RE_PH_AspriedUC3.updateApprovalScheme(newPrBook ,  newPrBook.RE_Contract_Master__r.RE_PH_Approval_Scheme__c ,marginValue )); 
                     if(wrappbdata.refperiod != wrappbdata.refperiodOld || wrappbdata.priceSupport != wrappbdata.priceSupportOld ||
                        wrappbdata.psEndDate != wrappbdata.psEndDateOld ){
                            contractdataMap.put(wrappbdata.contractID,wrappbdata);
                            if(wrappbdata.refperiod =='M-1'){
                                newPrBook.RE_Reference_Period__c = 'RE_M_1_UC3__c';
                                newPrBook.RE_RefUC3_Price__c = newPrBook.RE_M_1_UC3__c;
                                newPrBook.RE_Reference_Price__c = Decimal.valueof(wrappbdata.exgM_1);
                            }
                            if(wrappbdata.refperiod =='D-1'){
                                newPrBook.RE_Reference_Period__c = 'RE_D_1_UC3__c';
                                newPrBook.RE_RefUC3_Price__c = newPrBook.RE_D_1_UC3__c;
                                newPrBook.RE_Reference_Price__c = Decimal.valueof(wrappbdata.exgD_1);
                            }
                            if(wrappbdata.refperiod =='W-1'){
                                newPrBook.RE_Reference_Period__c = 'RE_W_1_UC3__c';
                                newPrBook.RE_RefUC3_Price__c = newPrBook.RE_W_1_UC3__c;
                                newPrBook.RE_Reference_Price__c = Decimal.valueof(wrappbdata.exgW_1);
                            }
                        }
                    Double marginValue = newPrBook.RE_RefUC3_Price__c;
                     if(wrappbdata.finalPrice != wrappbdata.finalPriceOld || wrappbdata.priceSupport != wrappbdata.priceSupportOld || wrappbdata.refperiod != wrappbdata.refperiodOld)
                         updatedValues.add(RE_PH_AspriedUC3.updateApprovalScheme(newPrBook ,  newPrBook.RE_Contract_Master__r.RE_PH_Approval_Scheme__c ,marginValue )); 
                     else { //if record in UP status 
                            if(approvedStatus.contains(wrappbdata.approveStatusFull))
                                newPrBook.RE_Custom_Opp_Approve__c = 'Auto Approved'; 
                            updatedValues.add(newPrBook);
                        }
                 }
            else if(finaldata.containsKey(wrappbdata.Id) && wrappbdata.submitterComments != wrappbdata.submitterCommentsOld){
                finaldata.get(wrappbdata.Id).RE_Submitter_Comments__c = wrappbdata.submitterComments;
                updatedValues.add(finaldata.get(wrappbdata.Id));
            }
        }
        if(!contractdataMap.isEmpty()){
            for(REV_Contract_Master__c con : [Select Id, RE_Reference_Period__c,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c  from REV_Contract_Master__c where Id IN: contractdataMap.Keyset()]){
                if(contractdataMap.containsKey(con.Id)){
                    system.debug('contract update');
                    con.RE_Reference_Period__c = contractdataMap.get(con.Id).refperiod;
                    con.RE_Price_support__c = decimal.valueof(contractdataMap.get(con.Id).priceSupport);
                    con.RE_PS_valid_from__c = contractdataMap.get(con.Id).psStartDate;
                    con.RE_PS_valid_to__c = contractdataMap.get(con.Id).psEndDate;                    
                    
                    contractdata.add(con);
                }
            }
        }
        if(!contractdata.isEmpty())
            update contractdata;
        if(!updatedValues.isEmpty())
            upsert updatedValues;
        priceBookId.clear();
        
        for(RT_Price_Book__c tempId : updatedValues)
            priceBookId.add(tempId.id);         
        
        return createWrapper(getPHpricebookdata(' id =: priceBookId'));
    } 
    
    public static list<RE_customerOppWrapper.pricebookdata> createWrapper(List<RT_Price_Book__c> pdData){
        Map<String,String> accessInfo=getAccessInfo(filterCondition);
        list<RE_customerOppWrapper.pricebookdata> wrapperData  = new  list<RE_customerOppWrapper.pricebookdata>();
        for(RT_Price_Book__c tempData : pdData)
            wrapperData.add(getMapOfPriceBookdata(tempData,accessInfo));
        return wrapperData;
    }    
    
    @AuraEnabled
    public static list<RE_customerOppWrapper.pricebookdata> submitforApproval(List<string> recordsTOsubmit){
        system.debug('--data for approval process'+recordsTOsubmit);
        priceBookId.clear();
        priceBookId = recordsTOsubmit;
        List<RT_Price_Book__c> submitApprovalProcess = getPHpricebookdata(' id =: priceBookId'); 
        
        for(RT_Price_Book__c ApprovalProcess : submitApprovalProcess){
            ApprovalProcess.RE_Custom_Opp_Approve__c='Submitted STL';
        }
        if(!submitApprovalProcess.isEmpty()){
            update submitApprovalProcess;  
            RE_customOppController.triggerApprovalProcess(recordsTOsubmit);
        }
        createEmailBody(submitApprovalProcess);
        return createWrapper(submitApprovalProcess);
    }
    
     //Approve or Rejects the Price Book records
    @AuraEnabled
    public static list<RE_customerOppWrapper.pricebookdata> approveReject(List<string> recordsTOApRj ,string action){
        system.debug('---data --for approval--'+recordsTOApRj);
        priceBookId.clear();
        priceBookId = recordsTOApRj;
        RE_customOppController.bulkApproveReject(recordsTOApRj,action);
        List<RT_Price_Book__c> submitApprovalProcess = getPHpricebookdata(' id =: priceBookId'); 
        return createWrapper(submitApprovalProcess);
    }
    
    
   public Static void createEmailBody(List<RT_Price_Book__c> pricebookrecords){
       Map<String,String> accessInfosubmitter=getAccessInfo(filterCondition);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<String> sendToSTL = new Set<String>();
        Set<String> sendToPM = new Set<String>();
        String htmlsub = 'Approval Request Submitted by '+UserInfo.getName()+' on '+Datetime.now().format('dd-MMM-yyyy-HH:MM:SS');
        String htmlbody = 'Please approve following prices for validity date '+ Datetime.now().format('dd-MMM-yyyy');
       	String PlantName;
       	String CustomerName;
       	String MaterialDesc;
       	String NetPrice;
       	String UC3W_1;
       	String UC3D_1;
       	String UC3M_1;
       	String Remarks;
       	String refperiod;
        htmlbody = htmlbody+ '</br></br></br></br><table border="1" class="ql-table-blob" style="border-collapse: collapse"><tr><th  style="padding: 3px; text-align: center;">PlantName</th><th style="padding: 3px; text-align: center;" >CustomerName</th><th style="padding: 3px; text-align: center;">MaterialDesc</th><th style="padding: 3px; text-align: center;">NetPrice</th><th style="padding: 3px; text-align: center;">UC3 W-1</th><th style="padding: 3px; text-align: center;">UC3 D-1</th><th  style="padding: 3px; text-align: center;">UC3 M-1</th><th  style="padding: 3px; text-align: center;">Remarks</th><th  style="padding: 3px; text-align: center;">ReferencePeriod</th></tr>';
		String htmlbodystl = htmlbody;
       	String htmlbodyPM = htmlbody;
        for(RT_Price_Book__c pbdata : pricebookrecords){
            system.debug('-pbdata.RE_Custom_Opp_Approve__c--'+pbdata.RE_Custom_Opp_Approve__c);
            if(pbdata.RE_Custom_Opp_Approve__c=='Submitted STL'){
                system.debug('-pbdata.RE_Custom_Opp_Approve__c--inside--'+pbdata.RE_ApprovalProcess__r.RE_Delegate_Approver__r.Email );
                if(pbdata.RE_ApprovalProcess__r.RE_Delegate_Approver__r.Email != null){
                    system.debug('-pbdata.RE_Custom_Opp_Approve__c--inside if');
                    PlantName = pbdata.RE_Contract_Master__r.RT_Plant_Desc__r.Name == null ? '' : pbdata.RE_Contract_Master__r.RT_Plant_Desc__r.Name;
                    CustomerName = pbdata.RE_Contract_Master__r.RE_Customer_Name__r.name == null ? '' : pbdata.RE_Contract_Master__r.RE_Customer_Name__r.name;
                    MaterialDesc = pbdata.RE_Contract_Master__r.RT_Material_Desc__r.Name == null ? '' : pbdata.RE_Contract_Master__r.RT_Material_Desc__r.Name;
                    NetPrice = String.valueof(pbdata.RE_Final_Price_Rebate__c != null ? String.valueof(pbdata.RE_Final_Price_Rebate__c.setscale(4)) : '');
                    UC3W_1 = String.valueof(pbdata.RE_W_1_UC3__c != null ? String.valueof(pbdata.RE_W_1_UC3__c.setscale(4)) : '');
                    UC3D_1 = String.valueof(pbdata.RE_D_1_UC3__c != null ? String.valueof(pbdata.RE_D_1_UC3__c.setscale(4)) : '');
                    UC3M_1 = String.valueof(pbdata.RE_M_1_UC3__c != null ? String.valueof(pbdata.RE_M_1_UC3__c.setscale(4)) : '');
                    Remarks = pbdata.RE_Submitter_Comments__c == null ? '' : pbdata.RE_Submitter_Comments__c;
                    refperiod = pbdata.RE_Reference_Period__c.substring(3, 4)+'-1';
                    htmlbodyPM = htmlbodyPM + '<tr><td  style="padding: 3px; text-align: center;">' + PlantName + '</td><td  style="padding: 3px; text-align: center;">' + CustomerName + '</td><td style="padding: 3px; text-align: center;">' + MaterialDesc + '</td><td style="padding: 3px; text-align: center;" >' + NetPrice + '</td><td style="padding: 3px; text-align: center;" >' + UC3W_1 + '</td><td style="padding: 3px; text-align: center;">' + UC3D_1 + '</td><td  style="padding: 3px; text-align: center;">' + UC3M_1 + '</td><td style="padding: 3px; text-align: center;">' + Remarks +' </td><td style="padding: 3px; text-align: center;">' + refperiod + '</td></tr>';
                    sendToPM.add(pbdata.RE_ApprovalProcess__r.RE_Delegate_Approver__r.Email);
                    sendToPM.add(pbdata.RE_ApprovalProcess__r.RE_User_Name__r.Email);
                }
                else{
                    system.debug('-pbdata.RE_Custom_Opp_Approve__c--inside else');
                    PlantName = pbdata.RE_Contract_Master__r.RT_Plant_Desc__r.Name == null ? '' : pbdata.RE_Contract_Master__r.RT_Plant_Desc__r.Name;
                    CustomerName = pbdata.RE_Contract_Master__r.RE_Customer_Name__r.name == null ? '' : pbdata.RE_Contract_Master__r.RE_Customer_Name__r.name;
                    MaterialDesc = pbdata.RE_Contract_Master__r.RT_Material_Desc__r.Name == null ? '' : pbdata.RE_Contract_Master__r.RT_Material_Desc__r.Name;
                    NetPrice = String.valueof(pbdata.RE_Final_Price_Rebate__c != null ? String.valueof(pbdata.RE_Final_Price_Rebate__c.setscale(4)) : '');
                    UC3W_1 = String.valueof(pbdata.RE_W_1_UC3__c != null ? String.valueof(pbdata.RE_W_1_UC3__c.setscale(4)) : '');
                    UC3D_1 = String.valueof(pbdata.RE_D_1_UC3__c != null ? String.valueof(pbdata.RE_D_1_UC3__c.setscale(4)) : '');
                    UC3M_1 = String.valueof(pbdata.RE_M_1_UC3__c != null ? String.valueof(pbdata.RE_M_1_UC3__c.setscale(4)) : '');
                    Remarks = pbdata.RE_Submitter_Comments__c == null ? '' : pbdata.RE_Submitter_Comments__c;
                    refperiod = pbdata.RE_Reference_Period__c.substring(3, 4)+'-1';
                    htmlbodySTL = htmlbodySTL + '<tr><td  style="padding: 3px; text-align: center;">' + PlantName + '</td><td  style="padding: 3px; text-align: center;">' + CustomerName + '</td><td style="padding: 3px; text-align: center;">' + MaterialDesc + '</td><td style="padding: 3px; text-align: center;" >' + NetPrice + '</td><td style="padding: 3px; text-align: center;" >' + UC3W_1 + '</td><td style="padding: 3px; text-align: center;">' + UC3D_1 + '</td><td  style="padding: 3px; text-align: center;">' + UC3M_1 + '</td><td style="padding: 3px; text-align: center;">' + Remarks +' </td><td style="padding: 3px; text-align: center;">' + refperiod + '</td></tr>';
                    sendToSTL.add(pbdata.RE_ApprovalProcess__r.RE_User_Name__r.Email);
                }       
            }
        }

       if(!sendToPM.isEmpty()){
           htmlbodyPM += '</table>';
           Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
           sendToPM.add(UserInfo.getuseremail());
           List<String> tomail = new List<String>();
           if(accessInfosubmitter.get('emailIds') != null && accessInfosubmitter.get('emailIds') != '' )
               tomail = (accessInfosubmitter.get('emailIds').split(';'));
           //sendToPM.add('Eva.Babasa@shell.com');
           sendToPM.addAll(tomail);           
           message.setToAddresses(new List<String>(sendToPM));
           message.setSaveAsActivity(false);
           message.setSubject(htmlsub);
           message.setHtmlBody(htmlbodyPM);
           message.setSenderDisplayName('Customer Opps Team');
           mails.add(message); 
       }
 
       if(!sendToSTL.isEmpty()){
           htmlbodySTL += '</table>';
           Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
           sendToSTL.add(UserInfo.getuseremail());
           List<String> tomail = new List<String>();
           if(accessInfosubmitter.get('emailIds') != null && accessInfosubmitter.get('emailIds') != '' )
               tomail = (accessInfosubmitter.get('emailIds').split(';'));
           //sendToPM.add('Eva.Babasa@shell.com');
           sendToSTL.addAll(tomail);  
           //sendToPM.add('Eva.Babasa@shell.com');
           message.setToAddresses(new List<String>(sendToSTL));
           message.setSaveAsActivity(false);
           message.setSubject(htmlsub);
           message.setHtmlBody(htmlbodySTL);
           message.setSenderDisplayName('Customer Opps Team');
           mails.add(message);
       }
       Messaging.sendEmail(mails);
    }
        
    
     @AuraEnabled(cacheable=true)
    public static RE_customerOppWrapper.getuserdata fetchuserdata(){
        RE_customerOppWrapper.getuserdata finaluserdata = new RE_customerOppWrapper.getuserdata();
        Map<String, RE_customerOppWrapper.picklistdata> userlist = new Map<String, RE_customerOppWrapper.picklistdata>();
        String username ;
         Id pricebookrectypeid = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('PH Price Book').getRecordTypeId();
        User userId =  [Select Id,RE_Customer_Opps_team__c from User where Id =: userInfo.getUserId()];
        if(userId.RE_Customer_Opps_team__c == 'PH Customer Operation'){
            for(RT_Price_Book__c contractdata : [SELECT RE_Contract_Master__r.RE_Account_Manager__c FROM RT_Price_Book__c WHERE recordtypeId =:pricebookrectypeid 
                                                 AND RE_Valid_From__c <= Today AND RE_Valid_To__c >= Today ORDER BY RE_Contract_Master__r.RE_Account_Manager__c ]){
                if(!userlist.containsKey(contractdata.RE_Contract_Master__r.RE_Account_Manager__c)){
                    RE_customerOppWrapper.picklistdata amdata = new RE_customerOppWrapper.picklistdata();
                    amdata.label = contractdata.RE_Contract_Master__r.RE_Account_Manager__c;
                    amdata.value = contractdata.RE_Contract_Master__r.RE_Account_Manager__c;
                    userlist.put(contractdata.RE_Contract_Master__r.RE_Account_Manager__c,amdata);
                }
            }
        }
        else{
            username = userInfo.getFirstName()+'.'+userInfo.getLastName();
            RE_customerOppWrapper.picklistdata userown = new RE_customerOppWrapper.picklistdata();
            userown.label = username;
            userown.value = username;
            userlist.put(username,userown);
            for(RT_Setting__c delegatuser : 
                [SELECT Name, Active__c, RE_Delegate_Approver__c, RE_User_Name__c FROM RT_Setting__c 
                 where RecordType.Name = 'PH Code Value Mapping' and Type__c = 'PH Delegated User'
                 AND Active__c = True AND RE_Delegate_Approver__c = :userId.Id ORDER BY Name
                ]){
                    RE_customerOppWrapper.picklistdata userdata = new RE_customerOppWrapper.picklistdata();
                    userdata.label = delegatuser.Name;
                    userdata.value = delegatuser.Name;
                    userlist.put(delegatuser.Name,userdata);
                }
        }        
        finaluserdata.userList = userlist.values();
        finaluserdata.isApprover = Boolean.valueOf(getAccessInfo(userId.RE_Customer_Opps_team__c).get('is_Approver'));
        return finaluserdata;
    }
    
     @AuraEnabled
    public Static Map<String,string > generateCustomOppdataData(){
        Map<String,string > message= new Map<String,string>();
        List<RE_Job_Run_Audit__c> custJobcount=new List<RE_Job_Run_Audit__c>();
        //checks customs opps data is created or not
        custJobcount=[select id ,RE_Job_Status__c from RE_Job_Run_Audit__c where RE_Job_Type__c='PH Customer Opps' AND createdDate=today AND RE_IsSuccess__c=true AND (RE_Job_Status__c = 'Completed' OR RE_Job_Status__c = 'Processing')];
        if(custJobcount.size() > 0) {
            //send error message to UI 
            message.put('Error','true');
            if(custJobcount[0].RE_Job_Status__c == 'Completed')
                message.put('message','Custom opps data has been generated already, please check with Admin');
            else 
                message.put('message','Custom opps data still processing, Please refresh page after 2mins');
        } 
        else{
            //Check holiday Saturday or Sunday (There is no CBU on  Saturday / Sunday and public holiday)
            List<String> holidaysDate= new List<String>();
            for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'PH Holiday Calendar' ])
                holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
            
            Datetime currentDay = (DateTime)System.today();
            String dayOfWeek = currentDay.format('EEEE');
            Datetime D_1 = currentDay.adddays(-1);
        
            boolean checkNotHoliday = false;
            if( (dayOfWeek == 'Monday' && !holidaysDate.contains(string.valueof(currentDay))) ||  (dayOfWeek == 'Tuesday' && holidaysDate.contains(string.valueof(D_1))))
                checkNotHoliday = true;
            
            //Insert a job to create custom opps data
            RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
            insertJob.RE_Run_Type__c='Manual';
            insertJob.RE_Job_Type__c = 'PH Customer Opps';
            insertJob.RE_User__c=UserInfo.getUserId();
            insertJob.RE_Run_Time__c=DateTime.now();
            insertJob.RE_Job_Run_Count__c = 0;
            insertJob.RE_Job_Status__c = 'Processing';
            
            if(checkNotHoliday){
                insert insertJob;
                message.put('Error','false');
                message.put('message','Job Triggered Successfully');
            }
            else{
                message.put('Error','true');
                string errormessage;
                if(holidaysDate.contains(string.valueof(currentDay)))
                    errormessage = 'Customer Opps data will not be generate due to Public holiday';
                else
                    errormessage = 'Customer Opps weekly data can be generated only on Monday';
                message.put('message',errormessage);
            }
        }  
        
        return message;
    }
    
    	//insert record in GSAP object and Update price Book record status as Ready to Upload
    @AuraEnabled
    public static RE_customerOppWrapper.returnResult exportReport(string datefilter,boolean retryOrexport, String selectedUser){
        RE_customerOppWrapper.returnResult resultdata=new RE_customerOppWrapper.returnResult();
        Id ReportFolderID;
        string additionalFilter = 'RE_Contract_Master__r.RE_Account_Manager__c  =\''+ selectedUser + '\' AND ';
        CheckRetry = retryOrexport;
        List<RT_Price_Book__c> updatePriceBook=new List<RT_Price_Book__c>();
        List<Fixed_Price_Staging_Table__c> reportGSAPdata=new List<Fixed_Price_Staging_Table__c>();
        try{   
            //Report format for GSAP upload
            Map<String,String> reportDataMap= new Map<String , String>();
            reportDataMap=reportConfiguration();
            
            updatePriceBook = getExportRecords(datefilter,additionalFilter);
            system.debug('udate size---'+updatePriceBook.size());
            //updatePriceBook.clear(); 
            integer sequenceNumber=0;
            for(RT_Price_Book__c tempPriceBook : updatePriceBook){
                //check GSAP upload is enabled
                if(RE_GSAP_Upload__c.getValues('Philippines') != null && RE_GSAP_Upload__c.getValues('Philippines').RE_GSAP_Upload__c)
                    tempPriceBook.RE_Custom_Opp_Approve__c = 'Ready to Upload';
                else
                     tempPriceBook.RE_Custom_Opp_Approve__c = 'Upload not allowed';
				
                if(reportDataMap.containskey(tempPriceBook.RE_Contract_Master__r.RT_CONDITION_TABLE_ID__c)){
                    sequenceNumber =sequenceNumber+1;
                    reportGSAPdata.add(priceBookToGSAPtable(tempPriceBook,reportDataMap.get(tempPriceBook.RE_Contract_Master__r.RT_CONDITION_TABLE_ID__c),sequenceNumber));
                }		            
            } 
			//insert data to GSAP upload object
            if(!updatePriceBook.isEmpty()){
                for(Fixed_Price_Staging_Table__c oldGSAPdata: [select id,RE_Is_latest__c from Fixed_Price_Staging_Table__c where RE_Is_latest__c=true AND createddate=today AND RE_Country_Name__c = 'PH']){
                    oldGSAPdata.RE_Is_latest__c=false;
                    reportGSAPdata.add(oldGSAPdata);
                }
                if(!reportGSAPdata.isEmpty()){
                    
                    upsert reportGSAPdata; 
                    if(RE_GSAP_Upload__c.getValues('Philippines') != null && RE_GSAP_Upload__c.getValues('Philippines').RE_GSAP_Upload__c){
                        List<Id> fixPriceIds = new List<Id>();
                        for(Fixed_Price_Staging_Table__c tempdata: reportGSAPdata){
                            if(tempdata.RE_Is_latest__c)
                                fixPriceIds.add(tempdata.Id);
                        } 
                        RE_Job_Run_Audit__c[] TodaysExport = [select id ,RE_Job_Run_Count__c from RE_Job_Run_Audit__c where RE_Job_Type__c='PH Export Report' AND createdDate=today];

                        //Insert a job to Monitor GSAP interface
                        RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
                        insertJob.RE_Run_Type__c='Manual';
                        insertJob.RE_Job_Type__c = 'PH Export Report';
                        insertJob.RE_User__c=UserInfo.getUserId();
                        insertJob.RE_Run_Time__c=DateTime.now();
                        insertJob.RE_Job_Run_Count__c = (TodaysExport.size() > 0 ? TodaysExport[0].RE_Job_Run_Count__c + 1 : 0);
                        insertJob.RE_Job_Status__c = 'Processing';
                        insertJob.RE_Country_Name__c = 'PH';
                        insert insertJob;
                        //Using Bacth class data will be send to GSAP system
                        FixedPriceDataInsertBatch fdp = new FixedPriceDataInsertBatch( fixPriceIds,0 ,'Philippines' , insertJob);
                        Database.executebatch(fdp,200);
                    }
                } 
                
                if(!updatePriceBook.isEmpty())
                    update updatePriceBook;              
            }
            ReportFolderID =[SELECT Id, DeveloperName,Name,Type FROM Folder WHERE Name = 'RE PH Customer Opps' And  Type = 'Report' limit 1].id;
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
    public static List<RT_Price_Book__c> getExportRecords(string datefilter, string AddtionalFilter){
        List<String> ExportStatus = new List<String>{'Approved','Auto Approved'};
        List<String> retryStatus = new List<String>{'Ready to Upload','Failed','Upload not allowed'};
        Map<String,String> accessInfo=getAccessInfo(filterCondition);
        Map<Id,RT_Price_Book__c> freqPricebook = new Map<Id,RT_Price_Book__c> ();
        List<RT_Price_Book__c> exportRecords = new List<RT_Price_Book__c>();
        List<Id> latestPriceBookContr = new List<Id>();             
        
        List<REV_Contract_Master__c> contractList = RE_SOQLController.fetchPHActiveContracts('PH','Revolution PH').values();
        string filterCond= ' '+ AddtionalFilter+'  RE_Valid_From__c  <= '+ datefilter +' AND RE_Valid_To__c >= '+datefilter+'  AND RE_Is_Latest__c = true  '+(accessInfo.get('FilterCondition') == null ? '': accessInfo.get('FilterCondition'));
       
        for( RT_Price_Book__c PriceBookMap : getPHpricebookdata(filterCond)){    
            if(!freqPricebook.containskey(PriceBookMap.RE_Contract_Master__c))
                freqPricebook.put(PriceBookMap.RE_Contract_Master__c,PriceBookMap);         
        }
        
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
		gsaprecord.RE_Country_Name__c = 'PH';
        gsaprecord.Customer_Name__c =priceBook.RE_Contract_Master__r.RE_Customer_Name__r.name;
        gsaprecord.RE_Sequence_No__c=SeqNum;
        gsaprecord.RE_Currency_Unit__c=reportcolumn.RE_Unit__c;
        gsaprecord.RE_Is_latest__c=TRUE;
        gsaprecord.RE_Pricing_Condition__c=priceBook.RE_Contract_Master__r.RE_Calculation_Type__c;
        gsaprecord.RE_Report_Type__c=reportcolumn.RE_Condition_Type__c;
        gsaprecord.REV_Price_Book__c=priceBook.Id;
        gsaprecord.RE_Valid_End_date__c=string.valueOf(priceBook.RE_Valid_To__c.year())+ (priceBook.RE_Valid_To__c.month() < 10 ? '0'+string.valueOf(priceBook.RE_Valid_To__c.month()) : string.valueOf(priceBook.RE_Valid_To__c.month())) +(priceBook.RE_Valid_To__c.day() <10 ? '0'+string.valueOf(priceBook.RE_Valid_To__c.day()) : string.valueOf(priceBook.RE_Valid_To__c.day()));
        gsaprecord.RE_Valid_start_date__c=string.valueOf(priceBook.RE_Valid_From__c.year())+ (priceBook.RE_Valid_From__c.month() < 10 ? '0'+string.valueOf(priceBook.RE_Valid_From__c.month()) : string.valueOf(priceBook.RE_Valid_From__c.month())) +(priceBook.RE_Valid_From__c.day() <10 ? '0'+string.valueOf(priceBook.RE_Valid_From__c.day()) : string.valueOf(priceBook.RE_Valid_From__c.day()));
        gsaprecord.RE_Cond_Usage_Table__c=reportcolumn.RE_Condition_Usage_Table__c;
        gsaprecord.RE_Cond_table_no__c=reportcolumn.RE_Condition_Table__c;
        gsaprecord.RE_Application__c=reportcolumn.RE_Application__c;
        gsaprecord.RE_Scale_Type__c=reportcolumn.RE_Scale_Type__c;
        gsaprecord.RE_Calculation_type__c=reportcolumn.RE_Calculation_Type__c;
        gsaprecord.RE_Value__c= string.valueOf(decimal.valueof(string.valueOf(priceBook.get(reportcolumn.RE_Data_Type__c))) * decimal.valueof(reportcolumn.RE_Quantity__c)) ;
        gsaprecord.RE_Uom__c=reportcolumn.RE_UoM__c;
        gsaprecord.RE_Quantity__c=reportcolumn.RE_Quantity__c;  
        string varkeySt=reportcolumn.RE_Varkey__c;
        string finalVarKey='';
        String[] arrCond = varkeySt.split('\\+');
        for(String tempData : arrCond){ 
            if(!tempData.contains('__c'))
                finalVarKey=finalVarKey+tempData;
            else
                finalVarKey=finalVarKey+ priceBook.get(tempData);
        }
        gsaprecord.RE_Varkey__c = finalVarKey;
        
        return gsaprecord;
        
    } 
    
    public static Map<String,String> reportConfiguration(){
        Map<String,String> reportDataMap= new Map<String,String>();
        for(RE_CustomOpps_ReportConfiguration__c reportInfo:RE_CustomOpps_ReportConfiguration__c.getall().values()){
            if(reportInfo.RE_Is_Active__c && reportInfo.RE_Country_Name__c == 'Philippines'){
                reportdetails.put(reportInfo.id,reportInfo);
				reportDataMap.put(reportInfo.RE_Condition_Table__c,reportInfo.id);
                system.debug('---'+reportDataMap);
            }
        }
        return reportDataMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static boolean exportButtonContr(){
        boolean exContrl;
        RE_Job_Run_Audit__c[] TodaysExport = [select id ,RE_Job_Run_Count__c from RE_Job_Run_Audit__c where RE_Job_Type__c='PH Export Report' AND createdDate=today AND RE_Job_Status__c = 'Processing'];
        exContrl = (TodaysExport.size() > 0 ? true : false);        
        
        return exContrl;
    }
    @AuraEnabled
    public static Map<String , String> checkNewContractData(){
        Map<String , String> returnMsg= new Map<String,String>();        
        List<REV_Contract_Master__c> contractData =  getNewContracts();
        boolean newContractCreated= false;
            if(contractData.size() > 0){
                //Insert a job to create custom opps data for Newly created data
                RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
                insertJob.RE_Run_Type__c='Manual';
                insertJob.RE_Job_Type__c = 'New Contract PH Pricing Output';
                insertJob.RE_User__c=UserInfo.getUserId();
                insertJob.RE_Run_Time__c=DateTime.now();                
                insertJob.RE_Country_Name__c = 'PH';
                try{
                    insert insertJob;
                    //RE_PH_AspriedUC3.newContractDataGen();
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
       
        if(!newContractCreated){
            returnMsg.put('error','true');
            returnMsg.put('message','No new contracted created');
        }
        
        return returnMsg;

    }

    public static List<REV_Contract_Master__c> getNewContracts(){
         Id AccrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution PH').getRecordTypeId();
        
        List<Account> acclist= [SELECT Id FROM Account WHERE RT_Active__c = True AND recordtypeId = : AccrectypeId];
        Map<Id, REV_Contract_Master__c> contractData = new Map<Id, REV_Contract_Master__c>([
        Select id ,RE_Price_support__c,RE_PS_valid_from__c,RE_PS_valid_to__c,RE_PH_Approval_Scheme__c ,RE_Reference_Period__c,Country_Name__c,RE_Customer_Name__c,RT_Material_Desc__c,RE_Secondary_Transport_Cost__c,
        RT_Plant_Desc__r.Name,RT_Material_Desc__r.RE_Product_Group__c,RT_Material_Desc__r.Name,RE_Aspired_Margin__c,RE_Prev_Week_Price__c,RE_Material_Code__c ,RE_Ship_To_Number__c,RE_Sold_To_Number__c,RE_Rebate__c,
        RE_Customer_Name__r.AccountNumber ,RT_Plant_Desc__r.RE_Location_Code__c,RT_Material_Desc__r.RE_Material__c ,RE_Calculation_Type__c,RT_Plant_Desc__c,RT_Plant_Code__c from REV_Contract_Master__c
        where createddate=today AND Active__c = True  AND RE_Customer_Name__c IN: acclist AND RT_Valid_From__c <= Today AND RT_Valid_To__c >= Today]);
        
        boolean newContractCreated= false;
        system.debug('--'+contractData);
        if(contractData.size() > 0){
            for(RT_Price_Book__c pbdadta : [select id ,RE_Contract_Master__c from RT_Price_Book__c where RE_Contract_Master__c IN : contractData.keySet() ]){
                if(contractData.containsKey(pbdadta.RE_Contract_Master__c))
                    contractData.remove(pbdadta.RE_Contract_Master__c);
                
            }
        }

        return contractData.values();
    }
}