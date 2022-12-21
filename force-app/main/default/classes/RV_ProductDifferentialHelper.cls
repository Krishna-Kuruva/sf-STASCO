/***********************************************************************************
 * Created By   : Dhriti Krishna Ghosh Moulick
 * Created Date : 06/09/2018
 * Description  : This Helper will execute and calculate the live vs 8 am field value
 * Last Modified By:
 * Last Modified Date :
 * *********************************************************************************/
public class RV_ProductDifferentialHelper {
    public static final String AGOQuoteName             = 'ICE Price Live $/to';//AGO IGO(ICE LGO Low Sulfur Gasoil)
    public static final String MOGAS1QuoteName          = 'Brent Crude'; //MOGAS(ICE LCO Brent Crude Oil)
    public static final String MOGAS2QuoteName          = 'NYMEX RBOB (unleaded gasoline) LIVE';//MOGAS (NYMEX RBOB Gasoline)
    public static final String euroUSDCurrency          = 'EU/USD Currency';
    public static final String chfUSDCurrency           = 'CHF/USD Currency';
    //public static final String AGOIGOLive               = 'AGO / IGO Live vs 8:00 €/100l';  //Rahul | Date-27-Aug-20 : Depricated
    //public static final String MOGASLive                = 'Mogas Live vs 8:00 €/100l';  //Rahul | Date-27-Aug-20 : Depricated
    public static final String liveEuroCHF              = 'Live €/CHF';
    //public static final String ago8am 		            = 'Wesseling AGO 8am Today';    //Rahul | Date-27-Aug-20 : Depricated
    //public static final String mogas8am                 = 'Wesseling Mogas 8am Today';  //Rahul | Date-27-Aug-20 : Depricated
    //public static final String agoWesselingLive         = 'Wesseling AGO Live'; //Rahul | Date-27-Aug-20 : Depricated
    //public static final String mogasWesselingLive       = 'Wesseling MOGAS Live';   //Rahul | Date-27-Aug-20 : Depricated
    //START - Rahul Sharma | Date - 20-Aug-20 : Adding new variables for live and 8 AM HCV values calculation.
    public static final String agoIgoHcv8AM             = 'Wesseling AGO/IGO HCV 8 AM';
    public static final String mogasHcv8AM              = 'Wesseling MOGAS HCV 8 AM';
    public static final String agoIgoHcvLive            = 'Wesseling AGO/IGO HCV Live';
    public static final String mogasHcvLive             = 'Wesseling MOGAS HCV Live';
    public static final String agoIgoLiveVs8AM          = 'AGO/IGO Live vs 8:00 €/100l';
    public static final String mogasLiveVs8AM           = 'MOGAS Live vs 8:00 €/100l';
    //END - Rahul Sharma | Date - 20-Aug-20 : Adding new variables for live and 8 AM HCV values calculation.
    public static Boolean recursion = true; 
    private static Boolean isRecursive = false;
    public static void onBeforeInsert(List<Product_Differential__c> prdctDiffLst){
        //liveVs8AM(prdctDiffLst);
        Set<String> liveVs8AMSet = new Set<String>{agoIgoHcvLive, mogasHcvLive, agoIgoLiveVs8AM, mogasLiveVs8AM, agoIgoHcv8AM, mogasHcv8AM};
        List<Product_Differential__c> filteredPrdctDiffLst=new List<Product_Differential__c>();
        for(Product_Differential__c prd :prdctDiffLst){
            if(!liveVs8AMSet.contains(prd.Display_Name__c)){
                filteredPrdctDiffLst.add(prd);
            }
        }  
        if(filteredPrdctDiffLst.size() > 0){
           liveVs8AM(prdctDiffLst); 
           calculateLiveVs8amHCV(prdctDiffLst);
        }
    }
    public static void onBeforeUpdate(List<Product_Differential__c> prdctDiffLst){
        //START - Rahul Sharma | Date - 26-Aug-20 : Replaced variables (AGOIGOLive, MOGASLive)  and added new variables for live vs 8 AM HCV values calculation.
        Set<String> liveVs8AMSet = new Set<String>{agoIgoHcvLive, mogasHcvLive, agoIgoLiveVs8AM, mogasLiveVs8AM, agoIgoHcv8AM, mogasHcv8AM};
        //END - Rahul Sharma | Date - 26-Aug-20 : Replaced variables (AGOIGOLive, MOGASLive) and added new variables for live vs 8 AM HCV values calculation.
        List<Product_Differential__c> filteredPrdctDiffLst=new List<Product_Differential__c>();
        for(Product_Differential__c prd :prdctDiffLst){
            if(!liveVs8AMSet.contains(prd.Display_Name__c)){
                filteredPrdctDiffLst.add(prd);
            }
        }  
        if(filteredPrdctDiffLst.size()>0){
           liveVs8AM(filteredPrdctDiffLst); 
           calculateLiveVs8amHCV(prdctDiffLst);
        }
       
    }
    
    public static void onAfterUpdate(List<Product_Differential__c> prdctDiffLst,
                                     Map<Id,Product_Differential__c> prodDiffOldMap,
                                     Map<Id,Product_Differential__c> prodDiffNewMap){
        Set<String> AllQuoteSet = new Set<String>{'ICE 16:30 yesterday $/to','ICE today 8:00 am $/to','ICE Price Live $/to',
                                                '€/$ fixing','€/$ today 8:00','Live €/$','Live €/CHF','Eurobob 16:30 $/to','Brent 16:30 $/bbl','Brent Live $/bbl',
                                                //START - Rahul Sharma | Date - 24-Aug-20 : Adding new variables for live and 8 AM HCV values. Removed String: 'AGO / IGO Live vs 8:00 €/100l','Mogas Live vs 8:00 €/100l'.
                                                'CIF Gasoline 10p 16:30 $/to','RBOB 16:30 cnt/gal','RBOB live cnt/gal', agoIgoLiveVs8AM, mogasLiveVs8AM};
                                                //END - Rahul Sharma | Date - 24-Aug-20 : Adding new variables for live and 8 AM HCV values. Removed String: 'AGO / IGO Live vs 8:00 €/100l','Mogas Live vs 8:00 €/100l'.         
        System.debug('RV_ProductDifferentialHelper >> onAfterUpdate() >> AllQuoteSet: '+AllQuoteSet);                                                  
        for(Product_Differential__c prd:prdctDiffLst){
            System.debug('RV_ProductDifferentialHelper >> onAfterUpdate() >> Product Differential Name: ' + prd.Display_Name__c); 
            if(AllQuoteSet.contains(prd.Display_Name__c)){
                System.debug('1');
                if(prd.Frequency__c != null && prd.Frequency__c == 'Live'){
                    System.debug('2');
                    if((prodDiffNewMap.get(prd.Id) <> prodDiffOldMap.get(prd.Id))){ 
                        System.debug('3');
                        if((prodDiffNewMap.get(prd.Id)).Price__c <> (prodDiffOldMap.get(prd.Id)).Price__c){
                            System.debug('Publish Event');
                            Rv_FutureDiffChange__e prdDiff = new Rv_FutureDiffChange__e();
                            prdDiff.Quote_Name__c=prd.Display_Name__c;
                            prdDiff.Value__c=prd.Price__c;
                            prdDiff.Column__c=prd.Column__c;
                            Database.SaveResult srPrd = EventBus.publish(prdDiff);
                            if(srPrd.isSuccess()){ 
                                System.debug('Rv_FutureDiffChange__e -Successfully published event.'); 
                            }else{ 
                                for(Database.Error errPrd : srPrd.getErrors()) { 
                                    System.debug('Error returned from Rv_FutureDiffChange__e: ' + errPrd.getStatusCode() + ' - ' + errPrd.getMessage()); 
                                }
                            }
                        }
                    }
                }   
            }                
        }                                       
    }
    
    
    
    /*********************** Live vs 8 AM data *********************************/
    public static void liveVs8AM(List<Product_Differential__c> prdctDiffLst){
        if(recursion == true){
        System.debug('prdctDiffLst===>'+prdctDiffLst);
        Map<String,Product_Differential__c> mapOfPrdctDiffMap = fetchProducDiffMap();
        List<Product_Differential__c> agoIgoMog8amLstToUpd= new List<Product_Differential__c>();
        String dashboardRecId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
        //START - Rahul Sharma | Date - 25-Aug-20 : Removed variables from the set; AGOIGOLive, MOGASLive, ago8am,mogas8am,agoWesselingLive,mogasWesselingLive.
        Set<String> liveVs8AMSet = new Set<String>{liveEuroCHF,euroUSDCurrency,chfUSDCurrency};
        //END - Rahul Sharma | Date - 25-Aug-20 : Removed variables from the set; AGOIGOLive, MOGASLive, ago8am,mogas8am,agoWesselingLive,mogasWesselingLive.     
        List<Product_Differential__c> prdctDiffLiveVs8AMLst = [select id,Name,Price__c,RecordTypeID from Product_Differential__c where 
                                                                   Name in:liveVs8AMSet AND RecordTypeId=:dashboardRecId];
        //START - Rahul Sharma | Date - 25-Aug-20 : Commented old method updateAgoMogasVsLiveValue() with calculateLiveVs8amHCV() to calculate delta values based on HCV.
        //updateAgoMogasVsLiveValue(prdctDiffLst);
        //END - Rahul Sharma | Date - 25-Aug-20 : Commented old method updateAgoMogasVsLiveValue() with calculateLiveVs8amHCV() to calculate delta values based on HCV.
        Map<String,Product_Differential__c> prdctDiffMap = new Map<String,Product_Differential__c>();
        for(Product_Differential__c prctDff : prdctDiffLiveVs8AMLst){
            prdctDiffMap.put(prctDff.Name, prctDff);
        }
        Map<Id,Product_Differential__c> productDiff8AMLst = new Map<Id,Product_Differential__c>();
        for(Product_Differential__c prdctDiff : prdctDiffLst){
            if(prdctDiff.RecordTypeId == dashboardRecId){
                Product_Differential__c prctDiff = new Product_Differential__c();
                if(prdctDiff.Name == euroUSDCurrency ){
                    prctDiff.Name = liveEuroCHF;
                    prctDiff.Display_Name__c = prctDiff.Name;
                    prctDiff.Column__c = 'Left2';
                    prctDiff.Frequency__c = 'Live'; 
                    if(prdctDiffMap.containskey(prctDiff.Name)){
                        prctDiff.Id = prdctDiffMap.get(prctDiff.Name).Id;
                    }
                    prctDiff.RecordTypeID = dashboardRecId;
                    if(prdctDiffMap.containskey(chfUSDCurrency)){
                        prctDiff.Price__c = prdctDiff.Price__c /prdctDiffMap.get(chfUSDCurrency).Price__c;
                    }
                    productDiff8AMLst.put(prctDiff.Id,prctDiff);
                }
                else if(prdctDiff.Name == chfUSDCurrency){
                    prctDiff.Name = liveEuroCHF;
                    prctDiff.Display_Name__c = prctDiff.Name;
                    prctDiff.Column__c = 'Left2';
                    prctDiff.Frequency__c = 'Live';
                    if(prdctDiffMap.containskey(prctDiff.Name)){
                        prctDiff.Id = prdctDiffMap.get(prctDiff.Name).Id;
                    }
                    prctDiff.RecordTypeID = dashboardRecId;
                    if(prdctDiffMap.containskey(euroUSDCurrency)){
                        prctDiff.Price__c = prdctDiffMap.get(euroUSDCurrency).Price__c / prdctDiff.Price__c;
                    }
                    productDiff8AMLst.put(prctDiff.Id,prctDiff);
                }
                else if(mapOfPrdctDiffMap.containskey(prdctDiff.Display_Name__c)){
                    prctDiff.RecordTypeID = dashboardRecId;
                    decimal agoIgoCon=Decimal.valueOf(Label.Conversion_Euro_100L_AGO_IGO);
                    Decimal euroUSDPrice=0;
                    if(prdctDiff.Display_Name__c == AGOQuoteName){
                        prctDiff.Name = agoIgoLiveVs8AM;
                        prctDiff.Display_Name__c = prctDiff.Name;
                        if(prdctDiffMap.containskey(prctDiff.Name)){
                            prctDiff.Id = prdctDiffMap.get(prctDiff.Name).Id;
                        }
                        if(prdctDiffMap.containskey(euroUSDCurrency)){                     
                            euroUSDPrice = prdctDiffMap.get(euroUSDCurrency).Price__c;
                            prctDiff.Price__c = ((prdctDiff.Price__c - mapOfPrdctDiffMap.get(prdctDiff.Display_Name__c).Price__c)*euroUSDPrice)/agoIgoCon;
                        }
                        productDiff8AMLst.put(prctDiff.Id,prctDiff);
                    }    	
                }
            }
        }
            //START - Rahul Sharma | Date - 25-Aug-20 : Commenting logic to calculate Wesseling product differentials as the new logic requires HCV calculation for Live v/s 8 AM values
            /*
            //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit starts
            Map<Id,Product_Differential__c> WesslingLiveProductDiffLst = WesslingLiveProductDifferentail();
            System.debug('-------WesslingLiveProductDiffLst Size----'+WesslingLiveProductDiffLst.size());
            System.debug('-------WesslingLiveProductDiffLst----'+WesslingLiveProductDiffLst);
            if(!WesslingLiveProductDiffLst.isEmpty())
            	productDiff8AMLst.putall(WesslingLiveProductDiffLst);
            //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit ends
            */
            //END - Rahul Sharma | Date - 25-Aug-20 : Commenting logic to calculate Wesseling product differentials as the new logic requires HCV calculation for Live v/s 8 AM values
            System.debug('-------productDiff8AMLst Size----'+productDiff8AMLst.size());
        	System.debug('-------productDiff8AMLst----'+productDiff8AMLst);
       
            if(!productDiff8AMLst.isEmpty()){
                Schema.SObjectField f = Product_Differential__c.Fields.Id;            
                //Fix_Exception_18jun2019_Soumyajit starts                
                Map<Id,Product_Differential__c> prdctDiffUpsert = new Map<Id,Product_Differential__c>();
                prdctDiffUpsert.putAll(productDiff8AMLst);
                
                for(Product_Differential__c prdctDiffTriggered : prdctDiffLst)
                {
                    if(productDiff8AMLst.containsKey(prdctDiffTriggered.id))
                    {
                        System.debug('This is a triggered ProductDiff: ' 
                                     + prdctDiffTriggered.id
                                     + 'is having new Price='
                                     +productDiff8AMLst.get(prdctDiffTriggered.id).Price__c);
                        
                        if(productDiff8AMLst.get(prdctDiffTriggered.id).Name != null)
                        	prdctDiffTriggered.Name=productDiff8AMLst.get(prdctDiffTriggered.id).Name;
                        
                        if(productDiff8AMLst.get(prdctDiffTriggered.id).Display_Name__c != null)
                        	prdctDiffTriggered.Display_Name__c=productDiff8AMLst.get(prdctDiffTriggered.id).Display_Name__c;

                        if(productDiff8AMLst.get(prdctDiffTriggered.id).Price__c != null)
                        	prdctDiffTriggered.Price__c=productDiff8AMLst.get(prdctDiffTriggered.id).Price__c;
                        
                        if(productDiff8AMLst.get(prdctDiffTriggered.id).Frequency__c != null)
                        	prdctDiffTriggered.Frequency__c=productDiff8AMLst.get(prdctDiffTriggered.id).Frequency__c;
                        
                        if(productDiff8AMLst.get(prdctDiffTriggered.id).Column__c != null)
                        	prdctDiffTriggered.Column__c=productDiff8AMLst.get(prdctDiffTriggered.id).Column__c;
                
                        prdctDiffUpsert.remove(prdctDiffTriggered.id);
                    }
                }
                
                system.debug('prdctDiffUpsert size= ' + prdctDiffUpsert.size());
                
                if(!prdctDiffUpsert.isEmpty())
                {
                    system.debug('About to upsert with ' + prdctDiffUpsert);
                    
                    Database.UpsertResult[] cr = Database.upsert(prdctDiffUpsert.values(),f, false);    
                //Fix_Exception_18jun2019_Soumyajit ends
                
                system.debug('Success ------->' + cr);
                
                //Fix_Exception_04Sep2019_Soumyajit starts
                List<RV_Exception__c> excpList = new List<RV_Exception__c>();
                Integer selfRefCounter = 0;
                //Fix_Exception_04Sep2019_Soumyajit ends
                    
                for (Database.UpsertResult  sr : cr) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully uoserted Product Differential(Live Vs 8 AM) Snapshot: ' + sr.getId());
                    }
                    else {
                        //Fix_Exception_04Sep2019_Soumyajit starts
                        /*for(Database.Error err : sr.getErrors()) {
                            RV_ClassException.getInstance();
                            RV_ClassException.insertExceptionRecord(String.valueof(err.getStatusCode()), err.getMessage(), 'ProductDifferentialHelper', 'liveVs8AM','Exception');
                        }*/
                        
                        for(Database.Error err : sr.getErrors()) {
                            if(!String.valueof(err.getStatusCode()).equals('SELF_REFERENCE_FROM_TRIGGER'))
                            {
                                RV_Exception__c rvExcep = new RV_Exception__c();
                                rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                                rvExcep.getMessage__c = err.getMessage();
                                rvExcep.Apex_Class__c = 'ProductDifferentialHelper';
                                rvExcep.Method_Name__c = 'liveVs8AM';
                                rvExcep.Type__c = 'Exception';
                                excpList.add(rvExcep);
                            }
                            else
                                selfRefCounter++; 
                        }
                        //Fix_Exception_04Sep2019_Soumyajit ends
                    }
                }                  
                    //Fix_Exception_04Sep2019_Soumyajit starts
                    if(selfRefCounter >0)
                        {
                            	RV_Exception__c rvExcep = new RV_Exception__c();
                                rvExcep.Status_Code__c = 'SELF_REFERENCE_FROM_TRIGGER';
                                rvExcep.getMessage__c = 'SELF_REFERENCE_FROM_TRIGGER ' + selfRefCounter + ' Time(s)';
                                rvExcep.Apex_Class__c = 'ProductDifferentialHelper';
                                rvExcep.Method_Name__c = 'liveVs8AM';
                                rvExcep.Type__c = 'Exception';
                                excpList.add(rvExcep);
                        }
                    
                    RV_ClassException.insertExceptionRecord(excpList);	
                    //Fix_Exception_04Sep2019_Soumyajit ends
                    
                } //Fix_Exception_18jun2019_Soumyajit
            }      
        }
        recursion = false;
    }
    //START - Rahul Sharma | Date - 26-Aug-20 : Commented method.
    /*
    public static void updateAgoMogasVsLiveValue(List<Product_Differential__c> prdctDiffLst){
       Map<String,Decimal> agoIgoMogasLiveVs8amValueMap = getAgoIgoMogasLiveVs8am(prdctDiffLst);
       List<Product_Differential__c> prdToBeUpdated = new List<Product_Differential__c>();
       List<Product_Differential__c> prdAgoMogasUpdated = new List<Product_Differential__c>();                                  
       Set<String> liveVs8AMSet = new Set<String>{AGOIGOLive,MOGASLive}; 
       String dashboardRecId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
       prdToBeUpdated=[Select Id,Name,Price__c from Product_Differential__c where
                       Name in:liveVs8AMSet AND RecordTypeId=:dashboardRecId] ; 
                                         
       for(Product_Differential__c prd:prdToBeUpdated){
           system.debug('prd.Name===>'+prd.Name);
           if(prd.Name==AGOIGOLive){
               if(agoIgoMogasLiveVs8amValueMap.containsKey(prd.Name)){
                  prd.Price__c= agoIgoMogasLiveVs8amValueMap.get(prd.Name);
                  prdAgoMogasUpdated.add(prd);
               } 
           } 
           if(prd.Name==MOGASLive){
               if(agoIgoMogasLiveVs8amValueMap.containsKey(prd.Name)){
                  prd.Price__c= agoIgoMogasLiveVs8amValueMap.get(prd.Name);
                  prdAgoMogasUpdated.add(prd);
               } 
           }
          
       } 
       system.debug('prdAgoMogasUpdated==>'+prdAgoMogasUpdated); 
       //update prdAgoMogasUpdated;
       List<RV_Exception__c> excpList = new List<RV_Exception__c>();
       Database.SaveResult[] updateResult = Database.update(prdAgoMogasUpdated, false);
       for (Database.SaveResult r : updateResult)
       {
           if (!r.isSuccess())
           {
               for (Database.Error err : r.getErrors())
               {
                   System.debug(err.getMessage());
                   RV_Exception__c rvExcep = new RV_Exception__c();
                   rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                   rvExcep.getMessage__c = err.getMessage();
                   rvExcep.Apex_Class__c = 'ProductDifferentialHelper';
                   rvExcep.Method_Name__c = 'updateAgoMogasVsLiveValue';
                   rvExcep.Type__c = 'Exception';
                   excpList.add(rvExcep); 
               }
           }
       }
       if(excpList.size()>0)
           RV_ClassException.insertExceptionRecord(excpList);
    }

    public static Map<String,Decimal> getAgoIgoMogasLiveVs8am (List<Product_Differential__c> prdctDiffLstTriggered){
        Set<String> prdNameSet= new Set<String>{ago8am,mogas8am,agoWesselingLive,mogasWesselingLive};
        Set<String> prdNameSetToQuery= new Set<String>();
        Set<String> prdNameTrgrdSet= new Set<String>();
        for(Product_Differential__c prd :prdctDiffLstTriggered){
            prdNameTrgrdSet.add(prd.Name);
        }
        for(string prdName :prdNameSet){
            if(!prdNameTrgrdSet.contains(prdName)){
                prdNameSetToQuery.add(prdName);
            }
        }
        System.debug('prdNameSetToQuery==>'+prdNameSetToQuery);
        List<Product_Differential__c> prdctDiffLiveVs8AMLst= new List<Product_Differential__c>();
         String dashboardRecId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
        if(prdNameSetToQuery.size()>0){
           prdctDiffLiveVs8AMLst=[select id,Name,Price__c,RecordTypeID from Product_Differential__c where 
                                 Name in:prdNameSetToQuery AND RecordTypeId=:dashboardRecId]; 
        } 
        System.debug('prdctDiffLiveVs8AMLst==>'+prdctDiffLiveVs8AMLst);
        Map<String,Decimal> agoMogasLiveVs8amValueMap = new Map<String,Decimal>();
        Map<String,Decimal> agoMogasLiveAnd8amValueMap = new Map<String,Decimal>();
        List<Product_Differential__c> prdctDiffLst= new List<Product_Differential__c>();
        Map<String,Product_Differential__c> dispNamePrdDiffMap= new Map<String,Product_Differential__c>();
        for(Product_Differential__c prd :prdctDiffLstTriggered){
            dispNamePrdDiffMap.put(prd.Name, prd);
        }
        prdctDiffLst.addAll(prdctDiffLstTriggered);
        prdctDiffLst.addAll(prdctDiffLiveVs8AMLst);
        system.debug('prdctDiffLst==>'+prdctDiffLst);
        for(Product_Differential__c prd : prdctDiffLst){
            if(prdNameSet.contains(prd.Name)){
                if(dispNamePrdDiffMap.containsKey(prd.Name)){
                   agoMogasLiveAnd8amValueMap.put(prd.Name,dispNamePrdDiffMap.get(prd.Name).Price__c);  
                }else{
                    agoMogasLiveAnd8amValueMap.put(prd.Name,prd.Price__c); 
                }
                
            } 
        }
        system.debug('agoMogasLiveAnd8amValueMap==>'+agoMogasLiveAnd8amValueMap);
        for(Product_Differential__c prd : prdctDiffLst){
            if(prdNameSet.contains(prd.Name)){
                if(prd.Name == ago8am || prd.Name == agoWesselingLive){
                    decimal AGOIGOLiveValue=0;
                    if(prd.Name == ago8am){
                        //if(prd.Price__c != null)
                        if(prd.Price__c != null && agoMogasLiveAnd8amValueMap.containskey(agoWesselingLive)) //Fix_Exception_18jun2019_Soumyajit
                        AGOIGOLiveValue=agoMogasLiveAnd8amValueMap.get(agoWesselingLive)-prd.Price__c;
                        system.debug('AGOIGOLiveValue==>'+AGOIGOLiveValue);
                        agoMogasLiveVs8amValueMap.put(AGOIGOLive,AGOIGOLiveValue);
                    }
                    if(prd.Name == agoWesselingLive){
                        //if(prd.Price__c != null)
                        if(prd.Price__c != null && agoMogasLiveAnd8amValueMap.containskey(ago8am)) //Fix_Exception_18jun2019_Soumyajit
                            AGOIGOLiveValue=prd.Price__c-agoMogasLiveAnd8amValueMap.get(ago8am);
                        system.debug('AGOIGOLiveValue 1==>'+AGOIGOLiveValue);
                            agoMogasLiveVs8amValueMap.put(AGOIGOLive,AGOIGOLiveValue);
                    }
                }
                else if(prd.Name == mogas8am || prd.Name == mogasWesselingLive){
                    decimal MOGASLiveValue=0;
                    if(prd.Name == mogas8am){
                        //if(prd.Price__c != null)
                        if(prd.Price__c != null && agoMogasLiveAnd8amValueMap.containskey(mogasWesselingLive)) //Fix_Exception_18jun2019_Soumyajit
                        MOGASLiveValue=agoMogasLiveAnd8amValueMap.get(mogasWesselingLive)-prd.Price__c;
                        agoMogasLiveVs8amValueMap.put(MOGASLive,MOGASLiveValue);
                    }
                     if(prd.Name == mogasWesselingLive){
                        //if(prd.Price__c != null)
                        if(prd.Price__c != null && agoMogasLiveAnd8amValueMap.containskey(mogas8am)) //Fix_Exception_18jun2019_Soumyajit
                        MOGASLiveValue=prd.Price__c-agoMogasLiveAnd8amValueMap.get(mogas8am);
                        agoMogasLiveVs8amValueMap.put(MOGASLive,MOGASLiveValue);
                    }
                }
            }
        }
        system.debug('agoMogasLiveVs8amValueMap==>'+agoMogasLiveVs8amValueMap);
        return agoMogasLiveVs8amValueMap;
    }
    */
    //END - Rahul Sharma | Date - 26-Aug-20 : Commented method.

    /*********************** Fetch Product Differential *********************************/
    public static Map<String,Product_Differential__c> fetchProducDiffMap(){
        Set<String> livePriceSet = new Set<String>{AGOQuoteName,MOGAS1QuoteName,MOGAS2QuoteName};
        String snapShotRecId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Snapshot').getRecordTypeId();
		System.debug('-------snapShotRecId----'+snapShotRecId);
        System.debug('-------livePriceSet----'+livePriceSet);
        List<Product_Differential__c> productDiff8AM = [select id,Name,Display_Name__c ,Price__c,CreatedDate  from Product_Differential__c
                                                        where RecordTypeID =:snapShotRecId AND 
                                                        Display_Name__c in:livePriceSet AND (CreatedDate = TODAY OR 
                                                        CreatedDate = YESTERDAY)]; // fETCHING 8 AM snapshot Live price either created OR Tomorrow
        System.debug('-------productDiff8AM----'+productDiff8AM);
        Map<String,Product_Differential__c> mapOfPrdctDiffMap = new Map<String,Product_Differential__c>();
        if(!productDiff8AM.isEmpty()){
            for(Product_Differential__c prdct : productDiff8AM){
                System.debug('-------prdcts----'+prdct.Name);
                if(livePriceSet.contains(prdct.Display_Name__c)){
                    DateTime dT = prdct.CreatedDate;
					Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
					System.debug('-------myDate----'+myDate);
                    if(myDate == System.today()){
                        System.debug('-------prdct----'+prdct);
                        mapOfPrdctDiffMap.put(prdct.Display_Name__c, prdct);
                    }else if(myDate == System.today().addDays(-1)){
                        mapOfPrdctDiffMap.put(prdct.Display_Name__c, prdct);
                    }
                }
            }
        }
        return mapOfPrdctDiffMap;
    }

    //START - Rahul Sharma | Date - 26-Aug-20 : Commented method.
    /*
    //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit starts
    public static Map<Id,Product_Differential__c> WesslingLiveProductDifferentail()
    { 
        Map<Id,Product_Differential__c> returnProdDiff = new Map<Id,Product_Differential__c>();
        Set<String> dummyMRCSet = new Set<String>{	 System.label.Rv_Wesseling_AGO_MRC_Dashboard
													,System.label.Rv_Wesseling_MOGAS_MRC_Dashboard
												};
		Set<String> MaterialSet= new  Set<String>{'400001685','400002410','400001637','400001986'};
        Set<String> prdDiffNameSet= new Set<String>{'Wesseling AGO Live','Wesseling MOGAS Live'};
            
        MRC__c[] dummyMRCList = [Select Id, Ship_to_Name__c, Shipping_Condition__c, Sales_Organization__c,Material_Description__c,
                                 Plant__r.Name,Product__r.Name, Sold_To__c, Plant__c, Plant_Code__c,Valid_From_Date__c,PO_Type__c,Handling_Type__c,
                                 Valid_To_Date__c, Name, Product__c,Mode_Of_Transport__c from MRC__c where  name in :dummyMRCSet];    										
        Map<Id,MRC__c> DummyMRCMap = new Map<Id,MRC__c>(dummyMRCList);										
        Map<String, MRC__c> mrcNumberMrcMap = new Map<String, MRC__c>();
           
        if(!DummyMRCMap.isEmpty())
        {
        	for(MRC__c mrc : DummyMRCMap.values())
            {
            	if(MaterialSet.contains(mrc.Product__r.Name))
                	mrcNumberMrcMap.put(mrc.Name, mrc);  
            }
        }
        
        if(!mrcNumberMrcMap.isEmpty())
        {
            RV_SPCalculationController.salesPriceCalAndAuditWrap sp = RV_SPCalculationController.getCalulatedSp(mrcNumberMrcMap.values()
                                                                                                                , Date.Today()
                                                                                                                , Date.Today().addDays(14));
            
            Map<String,Decimal> QuoateNameValueMap= new  Map<String,Decimal>();
            
            for(RV_SPCalculationController.salesPriceWrap wrp : sp.salesPriceWrpLst)
            {
                //AGO
                if(wrp.mrcNo == System.label.Rv_Wesseling_AGO_MRC_Dashboard)
                    QuoateNameValueMap.put('Wesseling AGO Live',wrp.MSP);
            
                //Mogas
                if(wrp.mrcNo == System.label.Rv_Wesseling_MOGAS_MRC_Dashboard)
                    QuoateNameValueMap.put('Wesseling MOGAS Live',wrp.MSP);
            }
            
            String dashboardRecId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();	//Fix_Exception_04Sep2019_Soumyajit
            List<Product_Differential__c> prdDiffLst=[Select Id,Name,Price__C from Product_Differential__c 
                                                      where Display_Name__c IN :prdDiffNameSet AND RecordTypeId=:dashboardRecId //Name IN :prdDiffNameSet	//Fix_Exception_04Sep2019_Soumyajit
                                                     ];
            
            if(prdDiffLst.size()>0)
            {
                for(Product_Differential__c prd :prdDiffLst)
                {
                    if(QuoateNameValueMap.containsKey(prd.Name))
                    {
                        prd.Price__c=QuoateNameValueMap.get(prd.Name);
                        returnProdDiff.put(prd.id,prd);
                    } 
                }
            }
        }
        
        return returnProdDiff;
    }
    //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit ends
    */
    //END - Rahul Sharma | Date - 26-Aug-20 : Commented method.

    /*Method Name   : calculateLiveVs8amHCV
     *Date          : 12-Aug-20
     *Developer     : Rahul Sharma
     *Description   : Calculate Live v/s 8 AM HCV Values
     */
    public static void calculateLiveVs8amHCV(List<Product_Differential__c> prdDiffTriggeredList){
        if(isRecursive == false){
            Map<String, Decimal> prdNameVsPriceMap = new Map<String, Decimal>();
            Map<String, MRC__c> mrcNumberMrcMap = new Map<String, MRC__c>();
            Map<String, Decimal> mrcNameVsHcvMap = new Map<String, Decimal>();
            List<RV_Exception__c> excpList = new List<RV_Exception__c>();
            Map<String, Product_Differential__c> prodDiffUpsertMap = new Map<String, Product_Differential__c>();
            Map<String, Product_Differential__c> prodNameVsProdDiff8AmMap = new Map<String, Product_Differential__c>();
            Set<String> dummyMRCSet = new Set<String>{System.label.Rv_Wesseling_AGO_MRC_Dashboard, System.label.Rv_Wesseling_MOGAS_MRC_Dashboard};
            //Set<String> materialSet = new  Set<String>{'000000000400001685','000000000400002410','000000000400001637','000000000400001986','000000000400003805','000000000400002484'}; //400003805 & 400002484 added by Dharmendra
            String customLabel = Label.RV_MaterialName;
            List<String> matNameLst = customLabel.split(',');
            Set<String> materialSet = new Set<String>(matNameLst);
            Set<String> prdDiffDashboardQuerySet = new Set<String>{agoIgoHcvLive, mogasHcvLive, agoIgoLiveVs8AM, mogasLiveVs8AM};
            List<Product_Differential__c> prdDiffLst = new List<Product_Differential__c>();
            String dashboardRecTypeId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByDeveloperName().get('Dashboard').getRecordTypeId();
            prdDiffLst = [SELECT Id,
                                Name,
                                Price__c,
                                Display_Name__c FROM Product_Differential__c WHERE Display_Name__c IN :prdDiffDashboardQuerySet AND 
                                                                                    RecordTypeId=:dashboardRecTypeId];
            for(MRC__c mrc : [SELECT Id,
                                    Ship_to_Name__c,
                                    Shipping_Condition__c, 
                                    Sales_Organization__c,
                                    Material_Description__c,
                                    Plant__r.Name,
                                    Product__r.Name, 
                                    Sold_To__c, Plant__c, 
                                    Plant_Code__c,
                                    Valid_From_Date__c,
                                    PO_Type__c,
                                    Handling_Type__c,
                                    Valid_To_Date__c, Name, 
                                    Product__c,
                                    Mode_Of_Transport__c FROM MRC__c WHERE  Name IN : dummyMRCSet]){
                if(materialSet.contains(mrc.Product__r.Name))
                    mrcNumberMrcMap.put(mrc.Name, mrc);  
            }  																		
            //Get Live HCV values in Euro/100L
            mrcNameVsHcvMap = getLiveHCV(mrcNumberMrcMap.values(), Date.today(), Date.today().addDays(14));
            System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> mrcNameVsHcvMap: '+mrcNameVsHcvMap);
            //Get 8 AM HCV values (Euro/100L)
            prodNameVsProdDiff8AmMap = get8AmHCV();
            System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >>  HCV 8 AM Map: '+prodNameVsProdDiff8AmMap);
            if(!mrcNameVsHcvMap.isEmpty()){
                if(!prdDiffLst.isEmpty()){
                    Map<String, Product_Differential__c> prdNameVsPrdDiffMap = new Map<String, Product_Differential__c>();
                    for(Product_Differential__c prdDiff : prdDiffLst){
                        if(prdDiffDashboardQuerySet.contains(prdDiff.Display_Name__c)){
                            prdNameVsPrdDiffMap.put(prdDiff.Display_Name__c, prdDiff);
                        }
                    }
                    System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> prdNameVsPrdDiffMap.keySet(): ' + prdNameVsPrdDiffMap.keySet());
                    System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> prodNameVsProdDiff8AmMap.keySet(): ' + prodNameVsProdDiff8AmMap.keySet());
                    System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> prdDiffDashboardQuerySet: ' + prdDiffDashboardQuerySet);
                    for(String prdDiffName : prdDiffDashboardQuerySet){
                        Decimal hcvLive = 0;
                        Decimal hcv8AM = 0;
                        Product_Differential__c prdctDiff = new Product_Differential__c();
                        if(prdNameVsPrdDiffMap.containsKey(prdDiffName)){
                            System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> ' + prdDiffName + ' contains in prdNameVsPrdDiffMap. Inside if.');
                            prdctDiff = prdNameVsPrdDiffMap.get(prdDiffName);
                            if(prdctDiff.Display_Name__c == agoIgoHcvLive){
                                //AGO/IGO HCV Live
                                prdctDiff.Price__c = mrcNameVsHcvMap.get(System.label.Rv_Wesseling_AGO_MRC_Dashboard) != null ? mrcNameVsHcvMap.get(System.label.Rv_Wesseling_AGO_MRC_Dashboard) : 0;
                                System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> AGO/IGO HCV Live: ' + prdctDiff.Price__c);
                            }
                            else if(prdctDiff.Display_Name__c == mogasHcvLive){
                                //MOGAS HCV Live
                                prdctDiff.Price__c = mrcNameVsHcvMap.get(System.label.Rv_Wesseling_MOGAS_MRC_Dashboard) != null ? mrcNameVsHcvMap.get(System.label.Rv_Wesseling_MOGAS_MRC_Dashboard) : 0;
                                System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> MOGAS HCV Live: ' + prdctDiff.Price__c);
                            }
                            else if(prdctDiff.Display_Name__c == agoIgoLiveVs8AM){
                                //AGO/IGO Live v/s 8 AM
                                System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> AGO/IGO Live v/s 8 AM');
                                if(prodNameVsProdDiff8AmMap.containskey(agoIgoHcv8AM)){
                                    hcvLive = mrcNameVsHcvMap.get(System.label.Rv_Wesseling_AGO_MRC_Dashboard) != null ? mrcNameVsHcvMap.get(System.label.Rv_Wesseling_AGO_MRC_Dashboard) : 0;
                                    hcv8AM = prodNameVsProdDiff8AmMap.get(agoIgoHcv8AM).Price__c != null ? prodNameVsProdDiff8AmMap.get(agoIgoHcv8AM).Price__c : 0;
                                    prdctDiff.Price__c = hcvLive - hcv8AM;
                                    System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> AGO/IGO Live v/s 8 AM Value: ' + prdctDiff.Price__c);
                                }
                                else{
                                    System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> AGO/IGO Live v/s 8 AM else. Value: ' + 0);
                                    prdctDiff.Price__c = 0;
                                }
                            }
                            else if(prdctDiff.Display_Name__c == mogasLiveVs8AM){
                                //MOGAS Live v/s 8 AM
                                System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> MOGAS Live v/s 8 AM');
                                if(prodNameVsProdDiff8AmMap.containskey(mogasHcv8AM)){
                                    hcvLive = mrcNameVsHcvMap.get(System.label.Rv_Wesseling_MOGAS_MRC_Dashboard) != null ? mrcNameVsHcvMap.get(System.label.Rv_Wesseling_MOGAS_MRC_Dashboard) : 0;
                                    hcv8AM = prodNameVsProdDiff8AmMap.get(mogasHcv8AM).Price__c != null ? prodNameVsProdDiff8AmMap.get(mogasHcv8AM).Price__c : 0;
                                    prdctDiff.Price__c = hcvLive - hcv8AM;
                                    System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> MOGAS Live v/s 8 AM Value: ' + prdctDiff.Price__c);
                                }
                                else{
                                    System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> MOGAS Live v/s 8 AM else. Value: ' + 0);
                                    prdctDiff.Price__c = 0;
                                }
                            }
                        }
                        else{
                            System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> ' + prdDiffName + ' doesn\'tcontains in prdNameVsPrdDiffMap. Inside else.');
                            System.debug('Create missing records');
                            //Create missing records
                            prdctDiff.Name = prdDiffName;
                            prdctDiff.Display_Name__c = prdDiffName;
                            prdctDiff.RecordTypeId = dashboardRecTypeId;
                            //AGO/IGO HCV Live
                            if(prdDiffName == agoIgoHcvLive){
                                prdctDiff.Price__c = mrcNameVsHcvMap.get(System.label.Rv_Wesseling_AGO_MRC_Dashboard) != null ? mrcNameVsHcvMap.get(System.label.Rv_Wesseling_AGO_MRC_Dashboard) : 0; 
                            }
                            //MOGAS HCV Live
                            else if(prdDiffName == mogasHcvLive){
                                prdctDiff.Price__c = mrcNameVsHcvMap.get(System.label.Rv_Wesseling_MOGAS_MRC_Dashboard) != null ? mrcNameVsHcvMap.get(System.label.Rv_Wesseling_MOGAS_MRC_Dashboard) : 0; 
                            }
                            //AGO/IGO Live v/s HCV
                            else if(prdDiffName == agoIgoLiveVs8AM){
                                if(prodNameVsProdDiff8AmMap.containskey(agoIgoHcv8AM)){
                                    hcvLive = mrcNameVsHcvMap.get(System.label.Rv_Wesseling_AGO_MRC_Dashboard) != null ? mrcNameVsHcvMap.get(System.label.Rv_Wesseling_AGO_MRC_Dashboard) : 0; 
                                    hcv8AM = prodNameVsProdDiff8AmMap.get(agoIgoHcv8AM).Price__c != null ? prodNameVsProdDiff8AmMap.get(agoIgoHcv8AM).Price__c : 0;
                                    prdctDiff.Price__c = hcvLive - hcv8AM;
                                    prdctDiff.Frequency__c = 'Live';
                                    prdctDiff.Type__c = 'Live';
                                    prdctDiff.Column__c = 'Left1';
                                }
                                else{
                                    prdctDiff.Price__c = 0;
                                    prdctDiff.Frequency__c = 'Live';
                                    prdctDiff.Type__c = 'Live';
                                    prdctDiff.Column__c = 'Left1';
                                }
                            }
                            //MOGAS Live v/s HCV
                            else if(prdDiffName == mogasLiveVs8AM){
                                if(prodNameVsProdDiff8AmMap.containskey(mogasHcv8AM)){
                                    hcvLive = mrcNameVsHcvMap.get(System.label.Rv_Wesseling_MOGAS_MRC_Dashboard) != null ? mrcNameVsHcvMap.get(System.label.Rv_Wesseling_MOGAS_MRC_Dashboard) : 0; 
                                    hcv8AM = prodNameVsProdDiff8AmMap.get(mogasHcv8AM).Price__c != null ? prodNameVsProdDiff8AmMap.get(mogasHcv8AM).Price__c : 0;
                                    prdctDiff.Price__c = hcvLive - hcv8AM;
                                    prdctDiff.Frequency__c = 'Live';
                                    prdctDiff.Type__c = 'Live';
                                    prdctDiff.Column__c = 'Left1';
                                }
                                else{
                                    prdctDiff.Price__c = 0;
                                    prdctDiff.Frequency__c = 'Live';
                                    prdctDiff.Type__c = 'Live';
                                    prdctDiff.Column__c = 'Left1';
                                }
                            }
                        }
                        prodDiffUpsertMap.put(prdDiffName, prdctDiff);
                    }
                }
                else{
                    //Create new HCV live records
                    for(String mrcNo : mrcNameVsHcvMap.keySet()){
                        Product_Differential__c prdDiff = new Product_Differential__c();
                        if(mrcNo == System.label.Rv_Wesseling_AGO_MRC_Dashboard){
                            prdDiff.Name = agoIgoHcvLive;
                            prdDiff.Display_Name__c = agoIgoHcvLive;
                            prdDiff.Price__c = mrcNameVsHcvMap.get(mrcNo);
                        }
                        else if(mrcNo == System.label.Rv_Wesseling_MOGAS_MRC_Dashboard){
                            prdDiff.Name = mogasHcvLive;
                            prdDiff.Display_Name__c = mogasHcvLive;
                            prdDiff.Price__c = mrcNameVsHcvMap.get(mrcNo);
                        }
                        prdDiff.RecordTypeId = dashboardRecTypeId;
                        prodDiffUpsertMap.put(prdDiff.Display_Name__c, prdDiff);
                    }
                }
                System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> prodDiffUpsertMap: '+prodDiffUpsertMap);
                System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> prdDiffTriggeredList: '+prdDiffTriggeredList);
                //Insert New Records
                Schema.SObjectField f = Product_Differential__c.Fields.Id; 
                Database.UpsertResult[] upsertResult = Database.upsert(prodDiffUpsertMap.values(), f, false);
                Integer selfRefCounter = 0;
                for (Database.UpsertResult r : upsertResult){
                    if (!r.isSuccess()){
                        for (Database.Error err : r.getErrors()){
                            if(!String.valueof(err.getStatusCode()).equals('SELF_REFERENCE_FROM_TRIGGER')){
                                System.debug('RV_ProductDifferentialHelper >> calculateLiveVs8amHCV() >> Error: ' + err.getMessage());
                                RV_Exception__c rvExcep = new RV_Exception__c();
                                rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                                rvExcep.getMessage__c = err.getMessage();
                                rvExcep.Apex_Class__c = 'ProductDifferentialHelper';
                                rvExcep.Method_Name__c = 'calculateLiveVs8amHCV';
                                rvExcep.Type__c = 'Exception';
                                excpList.add(rvExcep); 
                            }
                            else
                                selfRefCounter++;
                        }
                    }
                }
                if(selfRefCounter >0){
                    RV_Exception__c rvExcep = new RV_Exception__c();
                    rvExcep.Status_Code__c = 'SELF_REFERENCE_FROM_TRIGGER';
                    rvExcep.getMessage__c = 'SELF_REFERENCE_FROM_TRIGGER ' + selfRefCounter + ' Time(s)';
                    rvExcep.Apex_Class__c = 'ProductDifferentialHelper';
                    rvExcep.Method_Name__c = 'calculateLiveVs8amHCV';
                    rvExcep.Type__c = 'Exception';
                    excpList.add(rvExcep);
                }
            }
            else{
                //Log Exception
                RV_Exception__c rvExcep = new RV_Exception__c();
                rvExcep.Status_Code__c = 'LIVE_HCV_NOT_FOUND';
                rvExcep.getMessage__c = 'Live HCV values not found.';
                rvExcep.Apex_Class__c = 'ProductDifferentialHelper';
                rvExcep.Method_Name__c = 'calculateLiveVs8amHCV';
                rvExcep.Type__c = 'Info';
                excpList.add(rvExcep); 
            }
            if(excpList.size()>0)
                    RV_ClassException.insertExceptionRecord(excpList);
            isRecursive = true;
        }
    }

    /*Method Name   : getLiveHCV
     *Date          : 12-Aug-20
     *Developer     : Rahul Sharma
     *Description   : Get Live HCV Values
     */
    public static Map<String, Decimal> getLiveHCV(List<MRC__c> mrcList, Date contractStartDate, Date contractEndDate){
        Map<String, Decimal> mrcNameVsHcvMap = new Map<String, Decimal>();
        Set<String> plantStdGrdUnqSet= new Set<String>();
        Map<String,MRC__c> mrcNameVsNoMap = new  Map<String,MRC__c>();
        List<Freight_Rate__c>  backBoneAmvList= new List<Freight_Rate__c>();
        Map<String,String> backBoneAmvGardeMap = new Map<String,String>();
        Map<String,String> prdLabelVsNameMap = new Map<String,String>();
        Map<String,Mrc__c> plantGradeMrcNameVsMrcMap= new Map<String,Mrc__c>();
        Map<String,List<Freight_Rate__c>> mrcVsBackBoneAmvMap = new Map<String,List<Freight_Rate__c>>();
        Map<String,List<Freight_Rate__c>> plantGradeVsBackBoneAmvMap= new Map<String,List<Freight_Rate__c>>();
        List<RV_SHT_Calculation_Util.PriceDataWrap> hcvWrapList = new List<RV_SHT_Calculation_Util.PriceDataWrap>();
        List<RV_SHT_Calculation_Util.PriceDataWrap> hcvWrapReturnList = new List<RV_SHT_Calculation_Util.PriceDataWrap>();
        Map<String, RV_SHT_Calculation_Util.ReturnWrap> plantGradeHCVMap= new Map<string,RV_SHT_Calculation_Util.ReturnWrap>();

        for(Product_Name_Mapping__mdt productMdt: [SELECT ID,
                                                          MasterLabel,
                                                          DeveloperName,
                                                          Product_Name__c,
                                                          Margin_Mapping__c,
                                                          Bio_AMV_Grade_Name__c FROM Product_Name_Mapping__mdt]){
            backBoneAmvGardeMap.put(productMdt.MasterLabel, productMdt.Bio_AMV_Grade_Name__c);
            prdLabelVsNameMap.put(productMdt.MasterLabel, productMdt.Product_Name__c); 
        }
        for(MRC__c mrc : mrcList){
            mrcNameVsNoMap.put(mrc.Name, mrc);
            plantGradeMrcNameVsMrcMap.put(mrc.Plant_Code__c + backBoneAmvGardeMap.get(mrc.Material_Description__c)  + mrc.Name, mrc);
            plantStdGrdUnqSet.add(mrc.Plant_Code__c + prdLabelVsNameMap.get(mrc.Material_Description__c));
        }
        backBoneAmvList = [SELECT Id,
                                  Destination__c,
                                  Destination_Code__c,
                                  Standard_Grade__c,
                                  Source__c,
                                  Source_Code__c,
                                  Bio_Split__c,
                                  Name,
                                  Backbone_Route_Name__c,
                                  Mode_Of_Transport__c,
                                  Freight_rate_EUR_mt__c,
                                  Supplier__c,
                                  Route_Utilization__c,
                                  Supply_Type__c,
                                  PlantGradeUnq__c,
                                  Alt_Type__c,
                                  SubGrade_3P__c,
                                  Quote_Region_Source__c,
                                  Valid_From__c,Valid_To__c,
                                  Third_Party__c,
                                  Freight_Percentage__c,
                                  Marker__c FROM Freight_Rate__c WHERE PlantGradeUnq__c IN :plantStdGrdUnqSet AND
                                                                       Valid_From__c <= :contractStartDate AND 
                                                                       Valid_To__c >=:contractStartDate];
        for(Freight_Rate__c backBoneAMV  : backBoneAmvList){
            if(plantGradeVsBackBoneAmvMap.containsKey(backBoneAMV.Destination_Code__c + backBoneAMV.SubGrade_3P__c)){
                List<Freight_Rate__c> backBoneAMVLst = plantGradeVsBackBoneAmvMap.get(backBoneAMV.Destination_Code__c + backBoneAMV.SubGrade_3P__c);
                backBoneAMVLst.add(backBoneAMV);
                plantGradeVsbackBoneAMVMap.put(backBoneAMV.Destination_Code__c + backBoneAMV.SubGrade_3P__c, backBoneAMVLst);
                System.debug('RV_ProductDifferentialHelper >> getLiveHCV() >> plantGradeVsBackBoneAmvMap'+plantGradeVsBackBoneAmvMap);
            }
            else{
                plantGradeVsBackBoneAmvMap.put(backBoneAMV.Destination_Code__c + backBoneAMV.SubGrade_3P__c, new List<Freight_Rate__c>{backBoneAMV});              
                System.debug('RV_ProductDifferentialHelper >> getLiveHCV() >> plantGradeVsBackBoneAmvMap' + plantGradeVsBackBoneAmvMap);
            }
        }
        for(String key :plantGradeMrcNameVsMrcMap.keySet()){
            String newkey=key.removeEnd((plantGradeMrcNameVsMrcMap.get(key).Name));
            if(plantGradeVsBackBoneAmvMap.containsKey(newkey)){
                mrcVsBackBoneAmvMap.put((plantGradeMrcNameVsMrcMap.get(key)).Name, plantGradeVsBackBoneAmvMap.get(newkey));
            }
        }

        for(string mrc:mrcVsBackBoneAmvMap.keyset()){
            List<Freight_Rate__c> freightRateLst=mrcVsBackBoneAmvMap.get(mrc);
            for(Freight_Rate__c freightRate : freightRateLst){
                RV_SHT_Calculation_Util.PriceDataWrap priceDataWrap = new RV_SHT_Calculation_Util.PriceDataWrap();
                String salesOrg = mrcNameVsNoMap.get(mrc).Sales_Organization__c;
                priceDataWrap.MRCNumber = mrc;
                priceDataWrap.plantCode = freightRate.Destination_Code__c;
                priceDataWrap.altType = freightRate.Alt_Type__c;
                priceDataWrap.salesOrg = salesOrg;
                priceDataWrap.routeName = freightRate.Backbone_Route_Name__c;
                priceDataWrap.isThirdParty  = freightRate.Third_Party__c;
                priceDataWrap.grade = backBoneAmvGardeMap.get(mrcNameVsNoMap.get(mrc).Material_Description__c);
                priceDataWrap.locationType  =  freightRate.Quote_Region_Source__c;
                hcvWrapList.add(priceDataWrap); 
            }
        }
        if(!hcvWrapList.isEmpty()){
            RV_SHT_Calculation_Util shtCalcUtil = new RV_SHT_Calculation_Util();
            hcvWrapReturnList =  shtCalcUtil.getFinalHCV(hcvWrapList, contractStartDate, contractEndDate);
            for(RV_SHT_Calculation_Util.PriceDataWrap hcvReturnWrap : hcvWrapReturnList){
                if(hcvReturnWrap.ReturnWrap != null){
                    if(hcvReturnWrap.isThirdParty){
                        plantGradeHCVMap.put(hcvReturnWrap.salesOrg+'_' + hcvReturnWrap.routeName, hcvReturnWrap.ReturnWrap);
                    }
                    else{
                        plantGradeHCVMap.put(hcvReturnWrap.routeName, hcvReturnWrap.ReturnWrap);
                    }                   
                }
                else{
                    System.debug('RV_ProductDifferentialHelper >> getLiveHCV() >> hcvReturnWrap.ReturnWrap is null');
                }               
            }
            for(String key : mrcVsBackBoneAmvMap.keySet()){
                List<Freight_Rate__c> bavLst= mrcVsBackBoneAmvMap.get(key);
                Decimal finalBavVal = 0;
                for(Freight_Rate__c bav :bavLst){                    
                    if((backBoneAmvGardeMap.get(mrcNameVsNoMap.get(key).Material_Description__c) == bav.SubGrade_3P__c) && (mrcNameVsNoMap.get(key).Plant_Code__c == bav.Destination_Code__c)){                                      
                        Decimal hcv  = 0;
                        String salesOrgRouteName = mrcNameVsNoMap.get(key).Sales_Organization__c + '_' + bav.Backbone_Route_Name__c;
                        System.debug('RV_ProductDifferentialHelper >> getLiveHCV() >> salesOrgRouteName: ' + salesOrgRouteName);
                        if(bav.Third_Party__c){
                            if(plantGradeHCVMap.containsKey(salesOrgRouteName) && (plantGradeHCVMap.get(salesOrgRouteName).finalHCVValue != null)){
                                   hcv = (plantGradeHCVMap.get(salesOrgRouteName)).finalHCVValue;
                            }
                        }
                        else{
                            if(plantGradeHCVMap.containsKey(bav.Backbone_Route_Name__c) && (plantGradeHCVMap.get(bav.Backbone_Route_Name__c).finalHCVValue != null)){
                                   hcv=(plantGradeHCVMap.get(bav.Backbone_Route_Name__c)).finalHCVValue;
                            }
                        }                                                    
                        Decimal bavValue=0;
                        Decimal landedBAMVValue=0;
                        if(bav.Route_Utilization__c !=null){
                            landedBAMVValue = hcv;
                            System.debug('RV_ProductDifferentialHelper >> getLiveHCV() >> bav.Route_Utilization__c' + bav.Route_Utilization__c);
                            bavValue = bav.Route_Utilization__c * landedBAMVValue;
                            System.debug('RV_ProductDifferentialHelper >> getLiveHCV() >> bavValue'+bavValue);
                            if(bavValue != 0){
                                bavValue = bavValue/100;
                            }      
                            else{
                                bavValue = 0;
                            }
                        System.debug(bav.Mode_Of_Transport__c+' has bioAmv Mode_Of_Transport__c==>: '+bavValue);
                        }                    
                        finalBavVal = finalBavVal + bavValue;                      
                    }
                }
                System.debug('RV_ProductDifferentialHelper >> getLiveHCV() >> finalBavVal: '+finalBavVal);
                Decimal totalLandedCostEuro100L = 0;
                Decimal agoIgoCon  = Decimal.valueOf(Label.Conversion_Euro_100L_AGO_IGO);
                Decimal mogasCon =  Decimal.valueOf(Label.Conversion_Euro_100L_MOGAS);
                String standardGrade = prdLabelVsNameMap.get(mrcNameVsNoMap.get(key).Material_Description__c);
                //Conversion For Euro/MT to Euro/100L
                if(standardGrade == 'ULG95 E5'){
                    totalLandedCostEuro100L = finalBavVal/mogasCon;
                }
                else{
                    totalLandedCostEuro100L = finalBavVal/agoIgoCon;
                }
                mrcNameVsHcvMap.put(key, totalLandedCostEuro100L);  
            }
        }
        else{
            //hcvWrapList is null
        }
        System.debug('RV_ProductDifferentialHelper >> getLiveHCV() >> mrcNameVsHcvMap: '+mrcNameVsHcvMap);
        return mrcNameVsHcvMap;
    }

    /*Method Name   : get8AmHCV
     *Date          : 17-Aug-20
     *Developer     : Rahul Sharma
     *Description   : get HCV 8 AM HCV Values
     */
    private static Map<String, Product_Differential__c> get8AmHCV(){
        Set<String> agoIgoHcv8amSet = new Set<String>{agoIgoHcv8AM, mogasHcv8AM};
        Map<String, Product_Differential__c> prodNameVsProdDiffMap = new Map<String, Product_Differential__c>();
        String snapshotRecTypeId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByDeveloperName().get('Snapshot').getRecordTypeId();
        for(Product_Differential__c prd : [SELECT Id,
                                                  Name,
                                                  Display_Name__c ,
                                                  Price__c,
                                                  CreatedDate FROM Product_Differential__c WHERE RecordTypeID =: snapshotRecTypeId AND 
                                                                                                 Name IN : agoIgoHcv8amSet AND 
                                                                                                 CreatedDate = TODAY  ORDER BY CreatedDate ASC]){
            prodNameVsProdDiffMap.put(prd.Display_Name__c, prd);
        }
        return prodNameVsProdDiffMap;
    }
}