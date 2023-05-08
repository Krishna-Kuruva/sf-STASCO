/*******************************************************************************************
 * Created by Madhu Javvaji on 01-Dec-22.
 * TCP_STNSAPManagementProcessor apex call from SF
********************************************************************************************/


public with sharing class TCP_STNSAPManagementProcessor {
    
	//get Account Record Type    
	public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    
    /********** STNSAP SoldTo service 1 *****************/    
    public static void trackStatusSTNSAPSoldTo(list<ZST_TCP_CUST_OUT__x> getSoldToResp){
        string salesorg;
        list<Account> finalUpsertSoldToAccountList =  new list<Account>();   
        Map<String,TCP_Sales_Area__c> salesAreaMap = new Map<String,TCP_Sales_Area__c>();
        List<TCP_Sales_Area__c> salesAreaData = new List<TCP_Sales_Area__c>();
        try{
        	salesAreaData = [SELECT Id, Sales_Org__c, Distribution_Channel__c, Division__c, Name, Sales_Region__c FROM TCP_Sales_Area__c];
                    
            if (salesAreaData != null){
                for(TCP_Sales_Area__c sArea : salesAreaData){
                    String key = sArea.Sales_Org__c + sArea.Distribution_Channel__c + sArea.Division__c;                
                    salesAreaMap.put(key,sArea);                    
                }    
            }
            
            for (ZST_TCP_CUST_OUT__x SoldToRecs : getSoldToResp){
                system.debug('SoldToRecs.SALESORG__c===>'+SoldToRecs.SALESORG__c);
                salesOrg = SoldToRecs.SALESORG__c;
                string soldToExternalId1 = SoldToRecs.SOLD_TO__c + SoldToRecs.SALESORG__c + SoldToRecs.DIST_CHNL__c + SoldToRecs.DIVISION__c;
                String salesAreaKey=SoldToRecs.SALESORG__c + SoldToRecs.DIST_CHNL__c + SoldToRecs.DIVISION__c;             
                TCP_Sales_Area__c salesArea =  salesAreaMap.get(salesAreaKey);
                
                Account finalAccountsData = new Account();
                
                finalAccountsData.Sales_Area__c = salesArea.Id;
                finalAccountsData.Partner_Function__c = SoldToRecs.PARTNER_FUNC__c;
                if(SoldToRecs.PARTNER_FUNC__c == 'SP'){
                    finalAccountsData.Customer_Type__c = 'Sold To';    
                }else if (SoldToRecs.PARTNER_FUNC__c == 'SH'){
                    finalAccountsData.Customer_Type__c = 'Ship To';    
                }else if (SoldToRecs.PARTNER_FUNC__c == 'BP'){
                    finalAccountsData.Customer_Type__c = 'Bill To';    
                }else if (SoldToRecs.PARTNER_FUNC__c == 'PY'){
                    finalAccountsData.Customer_Type__c = 'Payer';    
                }                
                finalAccountsData.AccountNumber = SoldToRecs.SOLD_TO__c;  
                finalAccountsData.Name = SoldToRecs.NAME__c; 
                finalAccountsData.ShippingStreet = SoldToRecs.STREET__c;
                finalAccountsData.ShippingCity = SoldToRecs.CITY__c;
                finalAccountsData.ShippingState = SoldToRecs.STATE__c ; 
                finalAccountsData.ShippingCountry =  SoldToRecs.COUNTRY__c;
                finalAccountsData.ShippingPostalCode = SoldToRecs.POST_CODE__c;
                finalAccountsData.Billing_Block__c = SoldToRecs.BILLING_BLK__c;
                finalAccountsData.Delivery_Block__c = SoldToRecs.DELIVERY_BLK__c; 
                finalAccountsData.Order_Block__c = SoldToRecs.ORDER_BLK__c;
                finalAccountsData.Incoterms1__c = SoldToRecs.INCO1__c;
                finalAccountsData.Incoterms2__c = SoldToRecs.INCO2__c;
                finalAccountsData.Mode_of_Transport__c = SoldToRecs.SHIP_COND__c;
                finalAccountsData.Active__c = !(SoldToRecs.DELETION_FLAG__c);
                finalAccountsData.TCP_STNSAP_Status__c = SoldToRecs.STATUS__c;
                finalAccountsData.RecordTypeId =  tcpAccountRecTypeid;
                finalAccountsData.TCP_STNSAP_ExternalId1__c = soldToExternalId1;
                //finalAccountsData.TCP_Sales_Area_text__c = SoldToRecs.SALESORG__c;
                finalAccountsData.TCP_Sales_Area_text__c = salesArea.Sales_Region__c;
                finalUpsertSoldToAccountList.add(finalAccountsData);    
                system.debug('finalUpsertSoldToAccountList====>'+finalUpsertSoldToAccountList);
            } 
            upsert finalUpsertSoldToAccountList TCP_STNSAP_ExternalId1__c ; 
            TCP_STNSAP_1stService__c updateCustSetting = TCP_STNSAP_1stService__c.getInstance(salesorg);
                if(updateCustSetting.Full_Load__c == 'Y'){
                	updateCustSetting.Full_Load__c = 'N'; 
                    update updateCustSetting;
                }
        }catch (Exception e) {
         	system.debug('Exception occured+++'+e.getCause() +'message '+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('Track status STNSAP SoldTo Exception',e.getMessage(),'TCP_STNSAPManagementProcessor','trackStatusSTNSAPSoldTo','Exception');            
        }        
    }
    
    
    /********** STNSAP SoldToShipTo service 2 *****************/    
    public static void trackStatusSTNSAPSoldToShipTo(list<ZST_TCP_PAYR_OUT__x> getSoldToShipToResp){            	    
    	
        system.debug('getSoldToShipToResp====>'+getSoldToShipToResp);
        integer size = getSoldToShipToResp.size();  
        system.debug('size======>'+size);
        
        //List<TCP_STNSAPSoldToShipToWrapper> wrapSoldToShipToList = new List<TCP_STNSAPSoldToShipToWrapper>();
        List<TCP_Sales_Area__c> salesAreaData = new List<TCP_Sales_Area__c>();
        List<Account> accountParentId = new List<Account>();
        list<Account> finalUpsertAccountList =  new list<Account>();       
    	
        try{
        	salesAreaData = [SELECT Id, Sales_Org__c, Distribution_Channel__c, Division__c, Name, Sales_Region__c FROM TCP_Sales_Area__c];
                        
            Map<String,TCP_Sales_Area__c> salesAreaMap = new Map<String,TCP_Sales_Area__c>();
            
            if (salesAreaData != null){
                for(TCP_Sales_Area__c sArea : salesAreaData){
                    String key = sArea.Sales_Org__c + sArea.Distribution_Channel__c + sArea.Division__c;                
                    salesAreaMap.put(key,sArea);
                }    
            }
            
            accountParentId = [SELECT Id, Name, AccountNumber,Customer_Type__c,ParentId,Partner_Function__c,TCP_STNSAP_ExternalId1__c FROM Account where Customer_Type__c = 'Sold To' AND TCP_STNSAP_ExternalId1__c != null];
            Map<String, Account> accMap = new Map<String, Account>();
            
            if(accountParentId != null){
                for(Account acc : accountParentId){
                    accMap.put(acc.TCP_STNSAP_ExternalId1__c, acc); 
                }    
            }
     
            for (ZST_TCP_PAYR_OUT__x SoldToShipToRecs : getSoldToShipToResp){ 
                string soldToExternalId1 = SoldToShipToRecs.SOLD_TO__c + SoldToShipToRecs.SALESORG__c + SoldToShipToRecs.DIST_CHNL__c + SoldToShipToRecs.DIVISION__c;
                string shipToBillToPayerExternalId2 = SoldToShipToRecs.SOLD_TO__c + SoldToShipToRecs.SALESORG__c + SoldToShipToRecs.DIST_CHNL__c + SoldToShipToRecs.DIVISION__c + SoldToShipToRecs.PARTNER_NO__c + SoldToShipToRecs.PARTNER_FUNC__c;
                string salesAreaKey=SoldToShipToRecs.SALESORG__c + SoldToShipToRecs.DIST_CHNL__c + SoldToShipToRecs.DIVISION__c;             
                TCP_Sales_Area__c salesArea =  salesAreaMap.get(salesAreaKey);
                Account AccSoldToExtId = accMap.get(soldToExternalId1);
                                
                Account finalAccountsData = new Account(); 
                finalAccountsData.AccountNumber = SoldToShipToRecs.PARTNER_NO__c;    
                finalAccountsData.Sales_Area__c = salesArea.Id;
                finalAccountsData.Name = SoldToShipToRecs.NAME__c; 
                //finalAccountsData.TCP_Sales_Area_text__c = SoldToShipToRecs.SALESORG__c;
                finalAccountsData.TCP_Sales_Area_text__c = salesArea.Sales_Region__c;
                finalAccountsData.Partner_Function__c = SoldToShipToRecs.PARTNER_FUNC__c;  
                finalAccountsData.Partner_Counter__c = String.valueOf(SoldToShipToRecs.PARTNER_CNT__c).leftpad(3,'0');			 
                finalAccountsData.Billing_Block__c = SoldToShipToRecs.BILLING_BLK__c;
                finalAccountsData.Delivery_Block__c = SoldToShipToRecs.DELIVERY_BLK__c; 
                finalAccountsData.Order_Block__c = SoldToShipToRecs.ORDER_BLK__c; 
                finalAccountsData.ShippingStreet = SoldToShipToRecs.STREET__c;
                finalAccountsData.ShippingCity = SoldToShipToRecs.CITY__c;
                finalAccountsData.ShippingState = SoldToShipToRecs.STATE__c ; 
                finalAccountsData.ShippingCountry =  SoldToShipToRecs.COUNTRY__c;
                finalAccountsData.ShippingPostalCode = SoldToShipToRecs.POST_CODE__c;
                finalAccountsData.AccountNumber = SoldToShipToRecs.PARTNER_NO__c;
                finalAccountsData.Incoterms1__c = SoldToShipToRecs.INCO1__c;
                finalAccountsData.Incoterms2__c = SoldToShipToRecs.INCO2__c;
                finalAccountsData.ParentId = AccSoldToExtId.Id;
                finalAccountsData.Mode_of_Transport__c = SoldToShipToRecs.SHIP_COND__c;
                finalAccountsData.RecordTypeId =  tcpAccountRecTypeid;
                if(SoldToShipToRecs.PARTNER_FUNC__c == 'SP'){
                    finalAccountsData.Customer_Type__c = 'Sold To';    
                }else if (SoldToShipToRecs.PARTNER_FUNC__c == 'SH'){
                    finalAccountsData.Customer_Type__c = 'Ship To';    
                }else if (SoldToShipToRecs.PARTNER_FUNC__c == 'BP'){
                    finalAccountsData.Customer_Type__c = 'Bill To';    
                }else if (SoldToShipToRecs.PARTNER_FUNC__c == 'PY'){
                    finalAccountsData.Customer_Type__c = 'Payer';    
                } 
                finalAccountsData.TCP_STNSAP_ExternalId2__c = shipToBillToPayerExternalId2;
                finalAccountsData.Active__c = !(SoldToShipToRecs.DELETION_FLAG__c);
                finalAccountsData.TCP_STNSAP_Status__c = SoldToShipToRecs.STATUS__c;
                
                finalUpsertAccountList.add(finalAccountsData);
                system.debug('finalUpsertAccountList======>'+finalUpsertAccountList);            
            }
            upsert finalUpsertAccountList TCP_STNSAP_ExternalId2__c ;    
        }catch (Exception e) {
            system.debug('Exception occured+++'+e.getCause() +'message '+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('Track status STNSAP SoldTo ShipTo Exception',e.getMessage(),'TCP_STNSAPManagementProcessor','trackStatusSTNSAPSoldToShipTo','Exception');            
        }     
    }
    
    /********** STNSAP Product CMIR service 3 *****************/    
    //public static void trackStatusSTNSAPProducts(list<ZST_TCP_PROD_OUT__x> getProdsResp, string salesorg, string distChnl, string customerNo, string PartnerFun){
    public static void trackStatusSTNSAPProducts(list<ZST_TCP_PROD_OUT__x> getProdsResp, string SoldToNumber, string PartnerFunction, string salesorg, string distChnl){    
                
        List<Account> accountIds = new List<Account>();
        
        try{        	
        	accountIds = [SELECT id, Name, AccountNumber, ParentId, Customer_Type__c, Partner_Function__c, TCP_STNSAP_ExternalId2__c, Sales_Area__c   FROM Account where recordtypeid =: tcpAccountRecTypeid  and Partner_Function__c =: PartnerFunction  and AccountNumber =: SoldToNumber and  (TCP_STNSAP_ExternalId1__c != null OR TCP_STNSAP_ExternalId2__c != null) and Sales_Area__c != null and Active__c = TRUE];
            system.debug('accountIds===>'+accountIds);
            system.debug('accountIds size====>'+accountIds.size());
            string ProdSalesLineExtID = salesorg + distChnl;           
            List<String> CMIRExtIDList = new List<String>();
                
            TCP_Products_Sales_Line__c psl = new TCP_Products_Sales_Line__c();
            psl.Sales_Org__c = salesorg;
            psl.Distribution_Channel__c = distChnl;
            psl.STNSAP_ProdSL_ExternalId__c = ProdSalesLineExtID;
            psl.Active__c = true;                
            upsert psl STNSAP_ProdSL_ExternalId__c;
            
            //holds list of ProductSalesLine
            List<SObject> lstProductSalesLine = new List<SObject>(); 
            
            //holds list of Product
            List<product2> lstProduct = new List<product2>();
            
            //holds list of ProductCustomer
            List<TCP_Product_Customer__c> lstProductCustomer = new List<TCP_Product_Customer__c>(); 
            
            //final list for insertion
            SObject[] sobjList = new List<SObject>(); 
            String strInsertError = '';
            
            //holds PSL Id and PSL External Id in a Map
            Map<String,String> productSalesLineMap = new Map<String,String>();
            
            //holds Prd Id and Prd External Id in a Map
            Map<String,String> productMap = new Map<String,String>();
            
            Map<String, TCP_Product_Customer__c> prodCustMap = new Map<String, TCP_Product_Customer__c>();
            
            for (ZST_TCP_PROD_OUT__x CustomerProductRecs : getProdsResp){               
                Product2  prd = new Product2();
                prd.ProductCode = CustomerProductRecs.MATERIAL__c;
                prd.Name = CustomerProductRecs.MATERIAL_DESCRIPTION__c;
                prd.Unit_of_Measure__c = CustomerProductRecs.UNIT_OF_MEASURE__c;
                prd.Gross_Weight__c = CustomerProductRecs.GROSS_WEIGHT__c;
                prd.Net_Weight__c = CustomerProductRecs.NET_WEIGHT__c;            
                prd.Products_Sales_Line__c = psl.Id;
                prd.IsActive = true;
                prd.TCP_STNSAP_Prod_ExternalId__c = CustomerProductRecs.MATERIAL__c + ProdSalesLineExtID; //8000034ROTOD
                lstProduct.add(prd);
    
                TCP_Product_Customer__c CMIR =  new TCP_Product_Customer__c();
                CMIR.Active__c = true;
                CMIR.Partner_Function__c = CustomerProductRecs.PARTNER_FUNC__c; 
                //CMIR.TCP_STNSAP_CMIR_ExternalId__c = CustomerProductRecs.CUSTOMER__c + CustomerProductRecs.MATERIAL__c;//670198000034
                //CMIRExtID = CustomerProductRecs.CUSTOMER__c + CustomerProductRecs.MATERIAL__c;  //670198000034
                CMIRExtIDList.add(CustomerProductRecs.CUSTOMER__c); //67019
                prodCustMap.put(prd.TCP_STNSAP_Prod_ExternalId__c,CMIR);               
            }
            if(lstProduct.size()>0){                
                upsert lstProduct TCP_STNSAP_Prod_ExternalId__c;
            }
            Integer ind = 0;
            for(Product2 prod : lstProduct){ 
                if(prodCustMap.containsKey(prod.TCP_STNSAP_Prod_ExternalId__c)){
                    for(Account acc : accountIds){
                        TCP_Product_Customer__c CMIR = prodCustMap.get(prod.TCP_STNSAP_Prod_ExternalId__c);
                        TCP_Product_Customer__c CMIR2 =  new TCP_Product_Customer__c();
                        CMIR2.Account__c = acc.Id;
                        CMIR2.Product__c = prod.Id;
                        CMIR2.Active__c = true;                        
                        CMIR2.Partner_Function__c = CMIR.Partner_Function__c;
                        CMIR2.TCP_STNSAP_CMIR_ExternalId__c = CMIRExtIDList[ind] + prod.TCP_STNSAP_Prod_ExternalId__c + acc.Id;                        
                        lstProductCustomer.add(CMIR2);                        
                    }                    
                }
                ind++;
            }
            if(lstProductCustomer.size()>0){                
                upsert lstProductCustomer TCP_STNSAP_CMIR_ExternalId__c;
            }                
        }catch (Exception e) {
        	system.debug('Exception occured+++'+e.getCause() +'message '+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('Track status STNSAP CMIR Exception',e.getMessage(),'TCP_STNSAPManagementProcessorSingle','trackStatusSTNSAPCMIR','Exception');         
        }               
    }
}