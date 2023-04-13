/*****************************************************************************
@Name:  RV_DiSearchController     
@===========================================================================
@Purpose: Controller class for rv_diCustomerFilterSection component.
@========================================================================================
@History                                                            
@--------- ------------ ----------------                                                          
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    05-Aug-2021         INITIAL DEVELOPMENT

******************************************************************************/
public with sharing class RV_DiSearchController{

    @AuraEnabled(cacheable = true)
    public static AccSearchWrapper searchRelatedMRCs(String acctId, String mrcHeadStr){
        String soldToNum;
        Set<String> mrcNoSet = new Set<String>();
        Set<String> shipToSet = new Set<String>();
        Set<String> motSet= new Set<String>();
        Map<String, String> plantIdVsNameMap = new Map<String, String>();
        Map<String, String> shipToIdVsNumberMap = new Map<String, String>();       
        Set<String> poTypeSet = new Set<String>();
        Set<String> productSet = new Set<String>();
        Set<String> salesOrgSet = new Set<String>();
        Map<String, List<String>> mrcVsMotListMap = new Map<String, List<String>>();
        Map<String, List<String>> mrcNoVsPlanListtMap = new Map<String, List<String>>();
        Map<String, List<String>> mrcNoVsPoTypeListMap = new Map<String, List<String>>();
        Map<String, List<String>> mrcNoVsShipToListMap = new Map<String, List<String>>();
        Map<String, List<String>> mrcNoVsProductListMap = new Map<String, List<String>>();
        Id recTypeId=Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId(); 
        AccSearchWrapper accwrp = new AccSearchWrapper();
        String query = 'SELECT MRC_Number__c, ' +
                              'Ship_to_Number__c, ' +
                              'Sales_Organization__c, ' +
                              'PO_Type__c, ' +
                              'MRC__c.Name, ' +
                              'Shipping_Condition__c, ' +
                              'Sold_To__r.Sold_To_Number__c, ' + 
                              'Ship_To__r.Ship_to_Number__c, ' + 
                              'Product__r.Level_1__c, ' +
                              'Product__r.Commodity_Grade_L2__c, ' +
                              'Plant__c, ' +
                              'Plant__r.Name  FROM MRC__c WHERE Active__c = true';
        if(!String.isEmpty(acctId) || !String.isEmpty(mrcHeadStr)){
            if(!String.isEmpty(acctId))
                query += ' AND Sold_To__c =: acctId';
            if(!String.isEmpty(mrcHeadStr))
                query += ' AND MRC_Number__c =: mrcHeadStr'; 
            query += ' AND RecordTypeId =: recTypeId ORDER BY Plant__r.Name LIMIT 50000';
            try{
                system.debug('query::'+query);
                List<MRC__c> mrcLst= Database.query(query);
                system.debug('mrcLst::'+mrcLst.size());
                Map<Decimal, Shipping_Condition_Mapping__mdt> shippingCondMap = getShippingConditionMap();
                if(mrcLst.size() > 0){
                    soldToNum = mrcLst[0].Sold_To__r.Sold_To_Number__c;
                    for(Mrc__c mr:mrcLst){
                        String mrcHead = mr.Name.split('-')[0];
                        mrcNoSet.add(mrcHead);
                        if(mr.PO_Type__c != null){
                            poTypeSet.add(mr.PO_Type__c);
                            mrcNoVsPoTypeListMap = populateStringMap(mrcHead, mr.PO_Type__c, mrcNoVsPoTypeListMap); 
                        }                           
                        if(mr.Shipping_Condition__c != null){
                            if(shippingCondMap.containsKey(mr.Shipping_Condition__c) && shippingCondMap.get(mr.Shipping_Condition__c).MOT__c != null){
                                motSet.add(shippingCondMap.get(mr.Shipping_Condition__c).MOT__c + '-' + mr.Shipping_Condition__c);
                                mrcVsMotListMap = populateStringMap(mrcHead, shippingCondMap.get(mr.Shipping_Condition__c).MOT__c + '-' + mr.Shipping_Condition__c, mrcVsMotListMap);
                            }
                            system.debug('mrcNoVsPoTypeListMap::'+mrcNoVsPoTypeListMap);
                            system.debug('mrcVsMotListMap::'+mrcVsMotListMap);
                        }
                        if(mr.Plant__c !=null){
                            
                            // plantIdVsNameMap.put(mr.Plant__c, mr.Plant__r.Name);
                            plantIdVsNameMap.put(mr.Plant__c+'-'+ mr.PO_Type__c, mr.Plant__r.Name );//by shivam for PBI 1748339
                            mrcNoVsPlanListtMap = populateStringMap(mrcHead, mr.Plant__c, mrcNoVsPlanListtMap); 
                        }  
                        if(mr.Ship_To__r.Ship_to_Number__c != null){
                            shipToSet.add(mr.Ship_To__r.Ship_to_Number__c);
                            mrcNoVsShipToListMap = populateStringMap(mrcHead, mr.Ship_To__r.Ship_to_Number__c, mrcNoVsShipToListMap); 
                            shipToIdVsNumberMap.put(mr.Ship_To__c,mr.Ship_To__r.Ship_to_Number__c);
                        }
                        if(mr.Product__r.Level_1__c != null){
                            productSet.add(mr.Product__r.Level_1__c);
                            mrcNoVsProductListMap = populateStringMap(mrcHead, mr.Product__r.Level_1__c, mrcNoVsProductListMap);
                        }
                        if(mr.Sales_Organization__c != null){
                            salesOrgSet.add(mr.Sales_Organization__c);
                            mrcNoVsProductListMap = populateStringMap(mrcHead, mr.Sales_Organization__c, mrcNoVsProductListMap);
                        }
                    }
                }
                accwrp.soldToNum = soldToNum;
                system.debug('mrcNoSet::'+mrcNoSet);
                accwrp.mrcNoList = new List<String>(mrcNoSet);
                accwrp.shipToList = new List<String>(shipToSet);
                accwrp.motList = new List<String>(motSet);
                accwrp.poTypeList = new List<String>(poTypeSet);
                accwrp.productList = new List<String>(productSet);
                accwrp.salesOrgList = new List<String>(salesOrgSet);
                accwrp.shipToIdVsNumberMap = shipToIdVsNumberMap;              
                accwrp.plantIdVsNameMap = plantIdVsNameMap;
                accwrp.mrcVsMotListMap = mrcVsMotListMap;
                accwrp.mrcNoVsPlanListtMap = mrcNoVsPlanListtMap;
                accwrp.mrcNoVsPoTypeListMap = mrcNoVsPoTypeListMap;
                accwrp.mrcNoVsShipToListMap = mrcNoVsShipToListMap;
                accwrp.mrcNoVsProductListMap = mrcNoVsProductListMap;
            }
            catch(Exception e){
                System.debug('searchDependentShipToMRC() >> Exception: '+e.getMessage() + ' Line Number: '+e.getLineNumber());
                throw new AuraHandledException(e.getMessage());
            }
            //END - Rahul Sharma | Date - 03-Feb-2021 | PBI-702438 : Updated method to search MRCs based on either Sold-To account Id or Ship-To number.
        }
        return accwrp;
    }

    public static Map<Decimal,Shipping_Condition_Mapping__mdt> getShippingConditionMap(){
        Map<Decimal,Shipping_Condition_Mapping__mdt> shippingCondMap = new Map<Decimal,Shipping_Condition_Mapping__mdt>();
        List<Shipping_Condition_Mapping__mdt> shippingLst=[SELECT Id,
                                                                  MOT__c,
                                                                  MoTKey__c,
                                                                  Shipping_Condition__c,
                                                                  Margin_Type__c FROM Shipping_Condition_Mapping__mdt];
        for(Shipping_Condition_Mapping__mdt scm:shippingLst){
            shippingCondMap.put(Integer.valueOf(scm.Shipping_Condition__c),scm);
        }
        return shippingCondMap;
    }

    public static Map<String, List<String>> populateStringMap(String key, String value, Map<String, List<String>> originMap){
        if(!originMap.isEmpty() && originMap.containsKey(key)){
            Set<String> valueSet = new Set<String>(originMap.get(key));
            valueSet.add(value);
            originMap.put(key, new List<String>(valueSet));
        }
        else{
            originMap.put(key, new List<String>{value});
        }
        return originMap;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> searchMrcHeader(String mrcHeadStr){
        Set<String> mrcHeadStrSet = new Set<String>();
        if(!String.isEmpty(mrcHeadStr)){
            mrcHeadStr = '%' + mrcHeadStr + '%';
            for(MRC__c mrc : [SELECT MRC_Number__c FROM MRC__c WHERE Active__c = true AND
                                                                     MRC_Number__c LIKE : mrcHeadStr]){
                mrcHeadStrSet.add(mrc.MRC_Number__c);
            }
        }
        return new List<String>(mrcHeadStrSet);
    }

   /* @AuraEnabled
    public static void saveCustomerFilter_old(String filterObjStr){
        System.debug('filterObj: '+filterObjStr);
        RV_Sales_Negotiator__c salesNegFilter;
        try{
            FilterDataWrapper filterWrp = (FilterDataWrapper)JSON.deserialize(filterObjStr, FilterDataWrapper.class);
            String filterKey = UserInfo.getUserId() + filterWrp.customerId;
            salesNegFilter = RV_Sales_Negotiator__c.getValues(filterKey);
            System.debug('filterKey: '+filterKey);
            if(salesNegFilter == null){
                salesNegFilter = new RV_Sales_Negotiator__c();
                salesNegFilter.Name = filterKey;
            }
            salesNegFilter.Customer_Id__c = filterWrp.customerId;
         //   salesNegFilter.Depot__c = filterWrp.depot;
            salesNegFilter.Energy_Tax__c = filterWrp.energyTax;
            salesNegFilter.MoT__c = filterWrp.mot;
            salesNegFilter.OLF_Only__c = Boolean.valueOf(filterWrp.olfOnly);
            salesNegFilter.PO_Type__c = filterWrp.poType;
            salesNegFilter.Product__c = filterWrp.product;
            //salesNegFilter.Retail_Mix__c = Boolean.valueOf(filterWrp.retailMix);
            salesNegFilter.Sales_Org__c = filterWrp.salesOrg;
            //salesNegFilter.Contract_Start_Date__c = Date.valueOf(filterWrp.startDate);
            //salesNegFilter.Contract_End_Date__c = Date.valueOf(filterWrp.endDate);
            upsert salesNegFilter;
        }
        catch(Exception e){
            System.debug('RV_DiSearchController >> saveCustomerFilter >> Exception: '+e.getMessage() + ' Trace: '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }*/
    
    @AuraEnabled
	public static String fetchSalesNavigator(String customerId, String salesNavigator, String mrcNo){
        string queryNegotiator;
        queryNegotiator = 'SELECT Id, Account_Name_Sold_To__c, Sales_Negotiator__c FROM RV_Customer_Sales_Negotiator_Filter__c  WHERE Sales_Negotiator__c =: salesNavigator ';
        if(!string.isBlank(customerId)){
            queryNegotiator = queryNegotiator + ' AND Account_Name_Sold_To__c =: customerId ';
        }else{
            queryNegotiator = queryNegotiator + ' AND MRC_Number__c =: mrcNo ';
        }
        queryNegotiator = queryNegotiator + ' WITH SECURITY_ENFORCED LIMIT 1 ';
        List<RV_Customer_Sales_Negotiator_Filter__c> salesNavigtr = Database.query(queryNegotiator);
            /*[SELECT Id, Account_Name_Sold_To__c, Sales_Negotiator__c FROM RV_Customer_Sales_Negotiator_Filter__c 
             WHERE Account_Name_Sold_To__c =: customerId AND Sales_Negotiator__c =: salesNavigator WITH SECURITY_ENFORCED LIMIT 1 ];*/
        if(salesNavigtr.size() > 0){
            return salesNavigtr[0].Id;
        }else{
            return null;
        }
    }

    @AuraEnabled	
    public static String fetchSalesNavigator(String customerId, String salesNavigator){
        List<RV_Customer_Sales_Negotiator_Filter__c> salesNavigtr = 
            [SELECT Id, Account_Name_Sold_To__c, Sales_Negotiator__c FROM RV_Customer_Sales_Negotiator_Filter__c 
             WHERE Account_Name_Sold_To__c =: customerId AND Sales_Negotiator__c =: salesNavigator WITH SECURITY_ENFORCED LIMIT 1 ];
        if(salesNavigtr.size() > 0){
            return salesNavigtr[0].Id;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static void saveCustomerFilter(String filterObjStr){
       System.debug('filterObj: '+filterObjStr);
        RV_Customer_Sales_Negotiator_Filter__c salesNegFilter;
       try{
            FilterDataWrapper filterWrp = (FilterDataWrapper)JSON.deserialize(filterObjStr, FilterDataWrapper.class);
            String filterKey = UserInfo.getUserId() ;
            if(!string.isEmpty(filterWrp.customerId)){
                filterKey = filterKey + filterWrp.customerId;
            }else{
                filterKey = filterKey + filterWrp.mrcNo;
            }
            
            String checkSalesNavigator =  fetchSalesNavigator(filterWrp.customerId,UserInfo.getUserId(),filterWrp.mrcNo);
            
            if(!String.isBlank(checkSalesNavigator)){
                salesNegFilter = new RV_Customer_Sales_Negotiator_Filter__c();
                salesNegFilter.id=checkSalesNavigator;
             }else{
                salesNegFilter = new RV_Customer_Sales_Negotiator_Filter__c();
             }
               System.debug('filterKey: '+filterKey+salesNegFilter);
               if(filterWrp.customerId!='' && filterWrp.customerId!=null ){
                   salesNegFilter.Account_Name_Sold_To__c = filterWrp.customerId; 
					salesNegFilter.MRC_Numbers__c = filterWrp.mrcNo;
               }else{
                salesNegFilter.MRC_Number__c = filterWrp.mrcNo;
               }
               salesNegFilter.DepotLong__c = filterWrp.depot;
                salesNegFilter.Energy_Tax__c = filterWrp.energyTax;
                //salesNegFilter.MoT__c = (filterWrp.mot).split('-')[0];
                salesNegFilter.Mode_Of_Transport__c	 = filterWrp.mot;
                salesNegFilter.OLF_MRC_Only__c = Boolean.valueOf(filterWrp.olfOnly);
                salesNegFilter.retailMix__c=Boolean.valueOf(filterWrp.retailMix);
                salesNegFilter.PO_Type__c = filterWrp.poType;
                salesNegFilter.Product__c = filterWrp.product;
           /*filterDataStr::{"customerId":"0012500001RIxDuAAL","shipToNum":"0011176945",
        "mrcNo":["0320078090","0321295798"],"mot":"Truck-10","energyTax":"Taxed","product":"AGO;MOGAS","retailMix":false,
        "poType":"TSFP","depot":"a0M25000009IoR6EAK","salesOrg":"DE01","olfOnly":false,"startDate":"2021-09-26",
        "endDate":"2021-09-27"}*/
                //if(!string.isBlank(filterWrp.mrcNo)){
                   // List<String> listMRCNo = new List<String>();
            //listMRCNo = (filterWrp.mrcNo).split(',');
            //salesNegFilter.MRC_Number__c = filterWrp.mrcNo;
                    //salesNegFilter.MRC_Name__c = [SELECT Id FROM MRC__c WHERE MRC_Number__c =: filterWrp.mrcNo LIMIT 1].Id;
                //}
               //salesNegFilter.MRC_Numbers__c = filterWrp.mrcNo;//ListToString(filterWrp.mrcNo);
                salesNegFilter.Sales_Org__c = filterWrp.salesOrg;
                salesNegFilter.Contract_Start_Date__c = Date.valueOf(filterWrp.startDate);
                salesNegFilter.Contract_End_Date__c = Date.valueOf(filterWrp.endDate);
                salesNegFilter.Ship_To_Number__c = filterWrp.shipToNum;
               /* commenting as multiple SHIP Tos available if(!string.isBlank(filterWrp.shipToNum)){
                    salesNegFilter.Ship_To_Name__c = [Select Id from account where ship_to_number__c =: filterWrp.shipToNum LIMIT 1].Id;
                }*/
                salesNegFilter.Sales_Negotiator__c = userInfo.getUserId();
                upsert salesNegFilter;
        }
        catch(Exception e){
            System.debug('RV_DiSearchController >> saveCustomerFilter >> Exception: '+e.getMessage() + ' Trace: '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String ListToString(List<String> aList) {
    String allstirng='';
    Boolean check = false;
    for (String s : aList) {
        if (check) allstirng += ',';            
        allstirng += s;
        check = true;
    }
    return allstirng;
  }

   @AuraEnabled
    public static List<RV_Customer_Sales_Negotiator_Filter__c>  getNegotiationsCustMrcData(string customerId, string mrcName ){
      system.debug('customerId:'+customerId);
      String userID = userinfo.getUserId(); 
      try {
          string query = 'SELECT Account_Name_Sold_To__c,Contract_End_Date__c,Contract_Start_Date__c,Depot__c,Energy_Tax__c,Id,Mode_Of_Transport__c,MRC_Name__c,Name,OLF_MRC_Only__c,retailMix__c,PO_Type__c,Product__c,Sales_Negotiator__c,Sales_Org__c,Ship_To_Name__c,depotLong__c,Ship_To_Number__c,Sold_To_Number__c,MRC_Number__c,MRC_Numbers__c FROM RV_Customer_Sales_Negotiator_Filter__c where Sales_Negotiator__c =:userID';
          //: userinfo.getUserId() ';
          //query +='\''+ userinfo.getUserId()+'\'';
          if(!String.isBLANK(customerId) && String.isBLANK(mrcName)){
              //edited by sampada.bhat
              query = query + ' And Account_Name_Sold_To__c =: customerId Limit 1';
          }else if(!String.isBLANK(mrcName) && String.isBLANK(customerId)){
            query = query + ' And MRC_Number__c =: mrcName Limit 1';
          }
          system.debug('query::'+query);
          List<RV_Customer_Sales_Negotiator_Filter__c>  salesNegotiation = Database.query(query);
              system.debug('salesNegotiation: in getsalesnegotiation:::'+ salesNegotiation);
              if(salesNegotiation.size() > 0){
                  return salesNegotiation;
              }else{
                  return null;
              }
         // }
         
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
  }
  
    @AuraEnabled
    public static List<RV_Customer_Sales_Negotiator_Filter__c>  getNegotiationsData(string customerId){
        system.debug('customerId:'+customerId);
        try {
            if(!String.isBLANK(customerId)){
                //edited by sampada.bhat
                List<RV_Customer_Sales_Negotiator_Filter__c> salesNegotiation = 
                    [SELECT Account_Name_Sold_To__c,Contract_End_Date__c,Contract_Start_Date__c,Depot__c,Energy_Tax__c,Id,
                     //MOT__c,
                     Mode_Of_Transport__c,MRC_Name__c,Name,OLF_MRC_Only__c,retailMix__c,PO_Type__c,Product__c,Sales_Negotiator__c,Sales_Org__c,Ship_To_Name__c,depotLong__c,
                     Ship_To_Number__c,Sold_To_Number__c,MRC_Number__c,MRC_Numbers__c FROM RV_Customer_Sales_Negotiator_Filter__c where 
                     Account_Name_Sold_To__c =: customerId AND Sales_Negotiator__c =: userinfo.getUserId() LIMIT 1];
               // system.debug('salesNegotiation:'+salesNegotiation[0].Mode_Of_Transport__c);
                system.debug('salesNegotiation: in getsalesnegotiation:::'+ salesNegotiation);
                if(salesNegotiation.size() > 0){
                    return salesNegotiation;
                }else{
                    return null;
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class AccSearchWrapper{
        @AuraEnabled
        public String soldToNum;
        @AuraEnabled
        public List<String> mrcNoList;
        @AuraEnabled
        public List<String> shipToList;
        @AuraEnabled
        public List<String> motList;
        @AuraEnabled
        public List<String> poTypeList;
        @AuraEnabled
        public List<String> productList;
        @AuraEnabled
        public List<String> salesOrgList;
        @AuraEnabled
        public Map<String, String> plantIdVsNameMap;
        @AuraEnabled
        public Map<String, String> shipToIdVsNumberMap;
        @AuraEnabled
        public Map<String, List<String>> mrcVsMotListMap;
        @AuraEnabled
        public Map<String, List<String>> mrcNoVsPlanListtMap;
        @AuraEnabled
        public Map<String, List<String>> mrcNoVsPoTypeListMap;
        @AuraEnabled
        public Map<String, List<String>> mrcNoVsShipToListMap;
        @AuraEnabled
        public Map<String, List<String>> mrcNoVsProductListMap;
    }

    public class FilterDataWrapper{
        public String  customerId;
        public String mot;
        public String energyTax;
        public String product;
        public Boolean retailMix;
        public String poType;
        public String depot;
        public String salesOrg;
        public Boolean olfOnly;
        public Date startDate;
        public Date endDate;
        public String mrcNo;
        public String shipToNum;
    }
}