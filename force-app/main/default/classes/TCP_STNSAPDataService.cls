/*******************************************************************************************
 * Created by Madhu Javvaji on 01-Dec-22.
 * TCP_STNSAPDataService apex call from SF
********************************************************************************************/

public with sharing class TCP_STNSAPDataService {
    @TestVisible private static list<ZST_TCP_CUST_OUT__x> MocklistCustomers = new list<ZST_TCP_CUST_OUT__x>();
    @TestVisible private static list<ZST_TCP_PAYR_OUT__x> MocklistPayers = new list<ZST_TCP_PAYR_OUT__x>();
    //Account Record Type    
	public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    
    /***** Service 1 ----- TCP STNSAP SoldTo Data Queueable **********/  
    @AuraEnabled(cacheable=false)
    public static string fetchSTNSAPSoldTo(String saleAreasId){
        String lastCallDateFormat;
        String lastCallTimeFormat;
        String salesOrg;
        String distChnl;
		String division;
        String fullLoadVal;
        DateTime lastCallDateTime;
        List<TCP_Sales_Area__c> saList = new List<TCP_Sales_Area__c>();
        saList = [SELECT Name, Division__c, Sales_Org__c, Distribution_Channel__c, Id FROM TCP_Sales_Area__c where id=: saleAreasId LIMIT 1];
        system.debug('saList======>'+saList);          
        try {
            if(String.isNotBlank(saleAreasId) && saList.size()>0){
				for(TCP_Sales_Area__c saObj: saList){                        
                	salesOrg = saObj.Sales_Org__c;
                    system.debug('salesOrg===>'+salesOrg);
                	distChnl = saObj.Distribution_Channel__c;
					division = saObj.Division__c;
                    
                    list<TCP_STNSAP_1stService__c> fulloadData = TCP_STNSAP_1stService__c.getall().values();
                
                    if(!fulloadData.isEmpty()){
                         for(TCP_STNSAP_1stService__c temp : fulloadData){
                             if(temp.Sales_Area__c == salesOrg){
                                fullLoadVal = temp.Full_Load__c;
                                lastCallDateTime = temp.Last_call_timestamp__c;            
                             }         
                         }                   
                    }                  
               
                    if(lastCallDateTime != null){
                        lastCallDateFormat = String.valueOf(lastCallDateTime.year()).leftpad(2,'0') + String.valueOf(lastCallDateTime.month()).leftpad(2,'0') + String.valueOf(lastCallDateTime.Day()).leftpad(2,'0');    
                        lastCallTimeFormat = String.valueOf(lastCallDateTime.hour()).leftpad(2,'0') + String.valueOf(lastCallDateTime.minute()).leftpad(2,'0') + String.valueOf(lastCallDateTime.second()).leftpad(2,'0');
                    }else{
                        lastCallDateFormat = '';
                        lastCallTimeFormat = '';
                    }  
                
                    If (fullLoadVal == 'N'){
                        GenerateSTNSAPSoldToQueryString(salesOrg, distChnl, division, fullLoadVal, lastCallDateFormat, lastCallTimeFormat);                    
                    }else if(fullLoadVal == 'Y'){                    
                        GenerateSTNSAPSoldToQueryString(salesOrg, distChnl, division, fullLoadVal, '', '');                     	    
                    }
                }                
                                             
            } 
        } catch (Exception e) {
            system.debug('Exception occured+++'+e.getCause() +'message '+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('Fetch STNSAP SoldTo Exception',e.getMessage(),'TCP_STNSAPDataService','fetchSTNSAPSoldTo','Exception');
        }
        return null;
    }
    
    /***** Service 1 ----- TCP STNSAP SoldTo Query String  **********/   
    public static void GenerateSTNSAPSoldToQueryString( string salesorg, string distchnl, string division, string fullload, string datevalue, string timevalue){
    	
        String completeString = 'SELECT SOLD_TO__c, SALESORG__c, DIST_CHNL__c, DIVISION__c, NAME__c, PARTNER_FUNC__c, BILLING_BLK__c, ORDER_BLK__c, DELIVERY_BLK__c, INCO1__c, INCO2__c,  SHIP_COND__c,  STATE__c, STREET__c, CITY__c, COUNTRY__c, POST_CODE__c, ZDATE__c, ZTIME__c, FULL_LOAD__c, DELETION_FLAG__c, STATUS__c FROM ZST_TCP_CUST_OUT__x where ';
    	completeString = completeString+'SALESORG__c=\''+salesorg+'\''+' and '+'DIST_CHNL__c=\''+distchnl+'\''+' and '+'DIVISION__c=\''+division+'\''+' and '+'FULL_LOAD__c=\''+fullload+'\'';
        
        if ((String.isNotBlank(datevalue))  && (String.isNotBlank(timevalue))){
        	completeString = completeString+'and ZDATE__c=\''+datevalue+'\''+' and '+'ZTIME__c=\''+timevalue+'\'';    
        }        
        system.debug('completeString===>'+completeString);
        STNSAPSoldToData(completeString, salesorg);        
    }
    
    /***** Service 1 ----- TCP STNSAP SoldTo Data  **********/    
    @future
    public static void  STNSAPSoldToData(string completeString, string salesorg){
                
        ZST_TCP_CUST_OUT__x lstSoldTo = new ZST_TCP_CUST_OUT__x();
        list<ZST_TCP_CUST_OUT__x> listSoldTo = new list<ZST_TCP_CUST_OUT__x>();
        
        try{
            if(Test.isRunningTest()){
                ZST_TCP_CUST_OUT__x lstSoldTo1 = new ZST_TCP_CUST_OUT__x();
                list<ZST_TCP_CUST_OUT__x> listSoldTo1 = new list<ZST_TCP_CUST_OUT__x>();
                listSoldTo1.addAll(MocklistCustomers);
                listSoldTo=listSoldTo1;
                lstSoldTo = lstSoldTo1;
            }
            else{                
                listSoldTo = Database.query(completeString);                   
            }
            
            if(listSoldTo != null){
                TCP_STNSAPManagementProcessor.trackStatusSTNSAPSoldTo(listSoldTo);
                /*TCP_STNSAP_1stService__c updateCustSetting = TCP_STNSAP_1stService__c.getInstance(salesorg);
                if(updateCustSetting.Full_Load__c == 'Y'){
                	updateCustSetting.Full_Load__c = 'N'; 
                    update updateCustSetting;
                } */
            }
        }catch(Exception e){
            system.debug('Exception occured+++'+e.getCause() +'message '+e.getMessage()); 
            TCP_ExceptionLogClass.insertExceptionRecord('STNSAP SoldTo Exception',e.getMessage(),'TCP_STNSAPDataService','STNSAPSoldToData','Exception');
        }     
    }
    
    
    
    /****** Service 2----- TCP STNSAP SoldTo ShipTo Data Queueable **********/  
    
    @AuraEnabled(cacheable=false)
    //public static string fetchSTNSAPSoldToShipTo(list<string> soldToIds){      
    public static string fetchSTNSAPSoldToShipTo(String soldToId){          
 		String lastCallDateFormat;
        String lastCallTimeFormat;
        String salesOrg;
        String division;
        string distChnl;
        string fullLoadVal;
        DateTime lastCallDateTime;
        String soldToNumber;
    	list<account> accList = [SELECT id, AccountNumber, GSAP_Account_Number__c, Sales_Area__c, Sales_Area__r.Sales_Org__c, Sales_Area__r.Distribution_Channel__c, Sales_Area__r.Division__c FROM Account where id =: soldToId and recordtypeid =: tcpAccountRecTypeid and Customer_Type__c ='Sold To' and AccountNumber != null];
        system.debug('accList size====>'+accList.size());        
        Map<id, list<account>> accMap = new Map<id, list<account>>();
        integer count = 0;
        list<account> saAccNoList = new list<account>();
        List<TCP_Sales_Area__c> salesAreaData = new List<TCP_Sales_Area__c>();
        
        try{           
            if(String.isNotBlank(soldToId) && accList.size()>0){           
            //if(accList.size()>0){                
                //for(account accObj: accList){ 
                	soldToNumber =  accList[0].AccountNumber; 
                	salesOrg = accList[0].Sales_Area__r.Sales_Org__c;
                    division = accList[0].Sales_Area__r.Division__c;
                    distChnl = accList[0].Sales_Area__r.Distribution_Channel__c;
                	system.debug('soldToNumber===>'+soldToNumber);
                	system.debug('salesOrg===>'+ salesOrg);
                    
                    list<TCP_STNSAP_2ndService__c> fulloadData = TCP_STNSAP_2ndService__c.getall().values();                	               
                
                    if(!fulloadData.isEmpty()){
                         for(TCP_STNSAP_2ndService__c temp : fulloadData){
                             if(temp.Sales_Area__c == salesOrg){
                                fullLoadVal = temp.Full_Load__c;
                                lastCallDateTime = temp.Last_call_timestamp__c;            
                             }         
                         }                   
                    }
                    
                    if(lastCallDateTime != null){
                		lastCallDateFormat =  String.valueOf(lastCallDateTime.year()).leftpad(2,'0') + String.valueOf(lastCallDateTime.month()).leftpad(2,'0') + String.valueOf(lastCallDateTime.Day()).leftpad(2,'0');    
                		lastCallTimeFormat = String.valueOf(lastCallDateTime.hour()).leftpad(2,'0') + String.valueOf(lastCallDateTime.minute()).leftpad(2,'0') + String.valueOf(lastCallDateTime.second()).leftpad(2,'0');
                    }else{
                        lastCallDateFormat = '';
                        lastCallTimeFormat = '';
                    } 
                                        
                    If (fullLoadVal == 'N'){   
                        If ((String.isNotBlank(salesOrg)) || (String.isNotBlank(distChnl)) || (String.isNotBlank(division))){                            
                            GenerateSTNSAPSoldToShipToQueryString(soldToNumber, salesOrg, distChnl, division, 'N', lastCallDateFormat, lastCallTimeFormat);                        	
                        }                        
                    }else if(fullLoadVal == 'Y'){
                        If ((String.isNotBlank(salesOrg)) || (String.isNotBlank(distChnl)) || (String.isNotBlank(division))){
                            GenerateSTNSAPSoldToShipToQueryString(soldToNumber, salesOrg, distChnl, division, 'Y', '', '');                        	
                        }                                                
                    } 
               //}
            }
        } catch (Exception e) {
            system.debug('Exception occured+++'+e.getCause() +'message '+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('STNSAP SoldTo ShipTo Exception',e.getMessage(),'TCP_STNSAPDataService','fetchSTNSAPSoldToShipTo','Exception');
        }       
		return null;
	}    
    
    
    /***** Service 2 ----- TCP STNSAP SoldTo ShipTo Query String  **********/   
    public static void GenerateSTNSAPSoldToShipToQueryString( string soldtono, string salesorg, string distchnl, string division, string fullload, string datevalue, string timevalue){ //line for single soldto no
    	system.debug('soldtono====>'+soldtono); 
	       
		string completeString = 'SELECT  BILLING_BLK__c, CITY__c, COUNTRY__c, DELIVERY_BLK__c, DIST_CHNL__c, DIVISION__c, FULL_LOAD__c, INCO1__c, INCO2__c, NAME__c, ORDER_BLK__c, PARTNER_CNT__c, PARTNER_FUNC__c, PARTNER_NO__c, POST_CODE__c, SALESORG__c, SHIP_COND__c, SOLD_TO__c, STATUS__c, STREET__c, DELETION_FLAG__c, STATE__c FROM ZST_TCP_PAYR_OUT__x where ';
			
        completeString = completeString+'SOLD_TO__c=\''+soldtono+'\''+' and '+'SALESORG__c=\''+salesorg+'\''+' and '+'DIST_CHNL__c=\''+distchnl+'\''+' and '+'DIVISION__c=\''+division+'\''+' and '+'FULL_LOAD__c=\''+fullload+'\''; 
        
        if ((String.isNotBlank(datevalue))  && (String.isNotBlank(timevalue))){
        	completeString = completeString+'and ZDATE__c=\''+datevalue+'\''+' and '+'ZTIME__c=\''+timevalue+'\'';    
        } 
        
        system.debug('completeString=====>'+completeString);
        STNSAPSoldToShipToData(completeString, salesorg);         
    }

    /***** Service 2 ----- TCP STNSAP SoldTo ShipTo Data **********/
    @future
    public static void  STNSAPSoldToShipToData(string completeString, string salesorg){
        system.debug('completeString======>'+completeString);
        system.debug('salesorg======>'+salesorg);    
        
        ZST_TCP_PAYR_OUT__x lstSoldToShipTo = new ZST_TCP_PAYR_OUT__x();
        list<ZST_TCP_PAYR_OUT__x> listSoldToShipTo = new list<ZST_TCP_PAYR_OUT__x>();
        
        try{
            if(Test.isRunningTest()){
                ZST_TCP_PAYR_OUT__x lstSoldToShipTo1 = new ZST_TCP_PAYR_OUT__x();
                list<ZST_TCP_PAYR_OUT__x> listSoldToShipTo1 = new list<ZST_TCP_PAYR_OUT__x>();
                listSoldToShipTo1.addAll(MocklistPayers);
                listSoldToShipTo=listSoldToShipTo1;
                lstSoldToShipTo = lstSoldToShipTo1;
            }
            else{                
                listSoldToShipTo = Database.query(completeString); 
                system.debug('listSoldToShipTo======>'+listSoldToShipTo);
            }
            
            if(listSoldToShipTo != null){
                TCP_STNSAPManagementProcessor.trackStatusSTNSAPSoldToShipTo(listSoldToShipTo);
                /*TCP_STNSAP_2ndService__c updateCustSetting = TCP_STNSAP_2ndService__c.getInstance(salesorg);
                if(updateCustSetting.Full_Load__c == 'Y'){
                	updateCustSetting.Full_Load__c = 'N'; 
                    //updateCustSetting.Last_call_timestamp__c = lastdatetime;
                    update updateCustSetting;
                } */ 
            }
        }catch(Exception e){
            //TCP_STNSAPManagementProcessor.trackStatusSTNSAPSoldToShipTo(listSoldToShipTo);
            system.debug('Exception occured+++'+e.getCause() +'message '+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('STNSAP SoldTo ShipTo Data Exception',e.getMessage(),'TCP_STNSAPDataService','STNSAPSoldToShipToData','Exception');
        }
        
    }
    
    /***** Service 3 ----- TCP STNSAP Product and CMIR Data Queueable **********/  
    @AuraEnabled(cacheable=false)
    public static string fetchSTNSAPSoldToProductCMIR(String soldToId){
        String lastCallDateFormat;
        String lastCallTimeFormat;
        String fullLoadVal;
        DateTime lastCallDateTime;
        String accNumber;
        string partFun;
        String salesOrg;
        String distChnl;
        
        List<Account> accList = [SELECT id, AccountNumber, Partner_Function__c, GSAP_Account_Number__c, Sales_Area__c, Sales_Area__r.Sales_Org__c, Sales_Area__r.Distribution_Channel__c FROM Account where id =: soldToId and recordtypeid =:tcpAccountRecTypeid  and AccountNumber != null and (TCP_STNSAP_ExternalId1__c != null OR TCP_STNSAP_ExternalId2__c != null)];          
        system.debug('accList========>'+accList);
        try {
            if(String.isNotBlank(soldToId) && accList.size()>0){
				accNumber =  accList[0].AccountNumber;  
                partFun = accList[0].Partner_Function__c;
                salesOrg = accList[0].Sales_Area__r.Sales_Org__c;
                distChnl = accList[0].Sales_Area__r.Distribution_Channel__c;				
                
                
                list<TCP_STNSAP_3rdService__c> fulloadData = TCP_STNSAP_3rdService__c.getall().values();
                
                if(!fulloadData.isEmpty()){
                     for(TCP_STNSAP_3rdService__c temp : fulloadData){
                         if(temp.Sales_Area__c == salesOrg){
                            fullLoadVal = temp.Full_Load__c;
                            lastCallDateTime = temp.Last_call_timestamp__c;            
                         }         
                     }                   
                } 
				system.debug('lastCallDateTime=====>'+lastCallDateTime);
				if(lastCallDateTime != null){
                	lastCallDateFormat =  String.valueOf(lastCallDateTime.year()).leftpad(2,'0') + String.valueOf(lastCallDateTime.month()).leftpad(2,'0') + String.valueOf(lastCallDateTime.Day()).leftpad(2,'0');    
                	lastCallTimeFormat = String.valueOf(lastCallDateTime.hour()).leftpad(2,'0') + String.valueOf(lastCallDateTime.minute()).leftpad(2,'0') + String.valueOf(lastCallDateTime.second()).leftpad(2,'0');
                }else{
                	lastCallDateFormat = '';
                    lastCallTimeFormat = '';
                }              
                               
                If (fullLoadVal == 'N'){					
					GenerateSTNSAPProductCMIRQueryString(accNumber, partFun, salesOrg, distChnl, 'N', lastCallDateFormat,lastCallTimeFormat );                                        
                }else if(fullLoadVal == 'Y'){                    
                    GenerateSTNSAPProductCMIRQueryString(accNumber, partFun, salesOrg, distChnl, 'Y', '', '');                     	    
                }                
            }  
        } catch (Exception e) {
            system.debug('Exception occured+++'+e.getCause() +'message '+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('Fetch STNSAP SoldTo Exception',e.getMessage(),'TCP_STNSAPDataService','fetchSTNSAPSoldTo','Exception');
        }
        return null;
    }
    
    /***** Service 3 ----- TCP STNSAP Product CMIR Query String  **********/   
    
    public static void GenerateSTNSAPProductCMIRQueryString( string STNSAPSoldTo, string partFun, string salesorg, string distchnl, string fullload, string datevalue, string timevalue){  
        system.debug('datevalue===>'+datevalue);
        system.debug('timevalue===>'+timevalue);    
        
        string completeString = 'SELECT CUSTOMER__c, DIST_CHNL__c, FULL_LOAD__c, GROSS_WEIGHT__c, MATERIAL_DESCRIPTION__c, MATERIAL__c, NET_WEIGHT__c, PARTNER_FUNC__c, SALESORG__c, STATUS__c, UNIT_OF_MEASURE__c, ZDATE__c, ZTIME__c FROM ZST_TCP_PROD_OUT__x where ';
        completeString = completeString+'SALESORG__c=\''+salesorg+'\''+' and '+'DIST_CHNL__c=\''+distchnl+'\''+' and '+'CUSTOMER__c=\''+STNSAPSoldTo+'\''+' and '+'PARTNER_FUNC__c=\''+partFun+'\''+' and '+'FULL_LOAD__c=\''+fullload+'\'';
        
         
        if ((String.isNotBlank(datevalue))  && (String.isNotBlank(timevalue))){
        	completeString = completeString+'and ZDATE__c=\''+datevalue+'\''+' and '+'ZTIME__c=\''+timevalue+'\'';    
        }  
        
     
        
        system.debug('completeString=====>'+completeString);
        
        STNSAPProductCMIRData(completeString, STNSAPSoldTo, partFun, salesorg, distchnl);        
    }

    
    /***** Service 3 ----- TCP STNSAP Product and CMIR Data **********/        
    @future
    public static void  STNSAPProductCMIRData(string completeString, string soldToNum, string PartnerFun, string salesorg, string distChnl){
         system.debug('completeString=====>'+completeString);
        ZST_TCP_PROD_OUT__x lstProd = new ZST_TCP_PROD_OUT__x();
        list<ZST_TCP_PROD_OUT__x> listProd = new list<ZST_TCP_PROD_OUT__x>();
        
        try{
            if(Test.isRunningTest()){
                ZST_TCP_PROD_OUT__x lstProd1 = new ZST_TCP_PROD_OUT__x();
                list<ZST_TCP_PROD_OUT__x> listProd1 = new list<ZST_TCP_PROD_OUT__x>();
                lstProd = lstProd1;
            }
            else{                
                listProd = Database.query(completeString);                   
            }
            
            if(listProd != null){                
                TCP_STNSAPManagementProcessor.trackStatusSTNSAPProducts(listProd, soldToNum, PartnerFun, salesorg, distChnl);
                /*TCP_STNSAP_1stService__c updateCustSetting = TCP_STNSAP_1stService__c.getInstance(salesorg);
                if(updateCustSetting.Full_Load__c == 'Y'){
                	updateCustSetting.Full_Load__c = 'N'; 
                    update updateCustSetting;
                } */
            }
        }catch(Exception e){
            //TCP_STNSAPManagementProcessor.trackStatusSTNSAPProducts(listProd, soldToNum, PartnerFun, salesorg, distChnl);
            system.debug('Exception occured+++'+e.getCause() +'message '+e.getMessage()); 
            TCP_ExceptionLogClass.insertExceptionRecord('Product CMIR external Exception',e.getMessage(),'TCP_STNSAPDataService','STNSAPProductCMIRData','Exception');
        }     
    }
    
}