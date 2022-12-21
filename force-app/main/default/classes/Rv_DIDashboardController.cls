public class Rv_DIDashboardController {
    
    @AuraEnabled(cacheable=true)
    public static DashoboardWrapper getATPPriceforDashboard(List<String> channel,List<String> MOT,String locType,String taxType,Boolean getProdDiffList){
        Set<String> myLocationsSet = new Set<String>();
        if(locType=='myLoc'){
            Id loggedInUserId = UserInfo.getUserId();
            User loggedInUser = [Select Id, Name, My_DE_Locations__c, My_AT_Locations__c from User 
                                 where Id =: loggedInUserId];
            List<String> myLocationList = new List<String>();
            List<String> myDELocationList = new List<String>();
            List<String> myATLocationList = new List<String>();
            String myDELocations = loggedInUser.My_DE_Locations__c;
            String myATLocations = loggedInUser.My_AT_Locations__c;
            if(myDELocations != null){
                myDELocationList = myDELocations.split(',');
            }        
            if(myATLocations != null){
                myATLocationList = myATLocations.split(',');
            }        
            myLocationList.addAll(myDELocationList);
            myLocationList.addAll(myATLocationList);
            for(String plantcode : myLocationList){
                myLocationsSet.add(plantcode);
            }
        }
        String recTypeId = Schema.SObjectType.Revolution_Dashboard__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
		List<Revolution_Dashboard__c> allLocAtpPrcLst=new List<Revolution_Dashboard__c>();
        String queryString ='SELECT ATP1_Live_AGO__c,ATP1_Live_IGO__c,ATP1_Live_MOGAS__c,BSP_AGO__c,'+
            		 ' BSP_GTL__c,BSP_IGO__c,BSP_MOGAS__c,Id,'+
                     'MOT__c,MRC_Name__c,Name,OTM_AGO__c,UniqueKey__c ,'+
                     'OTM_IGO__c,OTM_MOGAS__c,Plant_Code__c,Plant_Name__c,Plant_Name__r.Name,'+
                     'PSP_AGO__c,PSP_IGO__c,PSP_MOGAS__c,Sales_Channel__c,Shipping_Condition__c,'+
            		 'BSP_w_o_Tax_AGO__c,BSP_w_o_Tax_IGO__c,BSP_w_o_Tax_MOGAS__c,BSP_w_o_Tax_GTL__c,'+
            		 'PSP_w_o_Tax_AGO__c,PSP_w_o_Tax_IGO__c,PSP_w_o_Tax_MOGAS__c,'+
            		 'OTM_w_o_Tax_AGO__c,OTM_w_o_Tax_IGO__c,OTM_w_o_Tax_MOGAS__c,'+	
                     //Fix_260839_Lakshmi_20May2019 starts
            		 'Total_Tax_AGO__c,Total_Tax_IGO__c,Total_Tax_MOGAS__c,Total_Tax_GTL__c,'+
            		 //Fix_260839_Lakshmi_20May2019 ends
            	     'ATP2_Live_AGO__c,ATP2_Live_IGO__c,ATP2_Live_MOGAS__c,ATP3_Live_IGO__c,ATP3_Live_AGO__c,ATP3_Live_MOGAS__c'+
                     ' FROM Revolution_Dashboard__c '+
            		 ' where Sales_Channel__c IN :channel and MOT__c IN: MOT and RecordTypeId =\''+ ''+recTypeId+'\'';
        if(myLocationsSet.size()>0){
            queryString=queryString + ' and Plant_Code__c IN: myLocationsSet ';
        }
        queryString=queryString+' order by Plant_Name__r.Name';
        allLocAtpPrcLst = Database.query (queryString); 
        DashoboardWrapper dwrap = new DashoboardWrapper();
        dwrap.dashBoardList=allLocAtpPrcLst;
        dwrap.lastRefreshedAt=System.now();
        if(getProdDiffList){
            dwrap.contractStartDate= system.today();
        	dwrap.contractEndDate=system.today().addDays(14);
            dwrap.prdWrp=getProdDifferentialData();
            dwrap.prdLiveWrp=getProdDifferentialLiveData();
            dwrap.E5_Surcharge = Label.RV_Surcharge_E5;    //added by Dharam : PBI328
            dwrap.S98_Surcharge = Label.RV_Surcharge_98;  //added by Dharam : PBI328
            
        }
        return dwrap;
    }
    public static prodDiffLiveWrapper getProdDifferentialLiveData(){
        //START - Rahul Sharma | Date: 16-Jun-20 : Added 8:00 o'clock values vs Live values.  
        Set<String> leftQuoteSet1= new Set<String>{'ICE 16:30 yesterday $/to','ICE today 8:00 am $/to','ICE Price Live $/to'};
        Set<String> leftQuoteSet2= new Set<String>{Label.Rv_Eur_USD_fixing,Label.Rv_Eur_Usd_8am,Label.Rv_Live_Eur_Usd,Label.Rv_Live_Eur_Chf};
        Set<String> rightQuoteSet1= new Set<String>{'Eurobob 16:30 $/to','Brent 16:30 $/bbl','Brent today 8:00 am $/bbl','Brent Live $/bbl'};
        Set<String> rightQuoteSet2= new Set<String>{'CIF Gasoline 10p 16:30 $/to','RBOB 16:30 cnt/gal','RBOB today 8:00 am cnt/gal','RBOB live cnt/gal'};
        //END - Rahul Sharma | Date: 16-Jun-20 : Added 8:00 o'clock values vs Live values.  
        List<Product_Differential__c> leftPrdDifLivLst1= new List<Product_Differential__c>();
        List<Product_Differential__c> leftPrdDifLivLst2= new List<Product_Differential__c>();
        List<Product_Differential__c> rightPrdDifLivLst1= new List<Product_Differential__c>();
        List<Product_Differential__c> rightPrdDifLivLst2= new List<Product_Differential__c>();
        List<Product_Differential__c> prodDiffLst= new List<Product_Differential__c>();
        Map<string,Product_Differential__c> prdNameDiffMap= new Map<string,Product_Differential__c>();
       	Set<String> allQuotesSet= new Set<String>();
        allQuotesSet.addAll(leftQuoteSet1);
        allQuotesSet.addAll(leftQuoteSet2);
        allQuotesSet.addAll(rightQuoteSet1);
        allQuotesSet.addAll(rightQuoteSet2);
        allQuotesSet.add(Label.RV_AGO_IGO_Live_vs_8_00_o_clock_value);
        allQuotesSet.add(Label.RV_Mogas_Live_vs_8_00_o_clock_value);
        decimal agoIgoLiveVs8Am=0;
        decimal mogasLiveVs8Am=0;
        //START - Rahul Sharma | Date: 26-Jun-20 : Updated query order to keep correct 8:00 o'clock values 
        prodDiffLst=[Select id,Column__c,Display_Name__c,Frequency__c,Price__c,Name,Type__c,RecordTypeId from Product_Differential__c 
                     where Display_Name__c IN:allQuotesSet ORDER BY LastModifiedDate];
        //END - Rahul Sharma | Date: 26-Jun-20 : Updated query order to keep correct 8:00 o'clock values
        for(Product_Differential__c prd:prodDiffLst){
            prdNameDiffMap.put(prd.Display_Name__c, prd);
            if(prd.Display_Name__c ==Label.RV_AGO_IGO_Live_vs_8_00_o_clock_value){
                agoIgoLiveVs8Am=prd.Price__c;
            }
            if(prd.Display_Name__c ==Label.RV_Mogas_Live_vs_8_00_o_clock_value){
                mogasLiveVs8Am=prd.Price__c;
            }
        }
        
        for(string key:leftQuoteSet1){
            if(prdNameDiffMap.containsKey(key)){
                leftPrdDifLivLst1.add(prdNameDiffMap.get(key));
            }
        }
        for(string key:leftQuoteSet2){
            if(prdNameDiffMap.containsKey(key)){
                leftPrdDifLivLst2.add(prdNameDiffMap.get(key));
            }
        }
        for(string key:rightQuoteSet1){
            if(prdNameDiffMap.containsKey(key)){
                rightPrdDifLivLst1.add(prdNameDiffMap.get(key));
            }
        }
        for(string key:rightQuoteSet2){
            if(prdNameDiffMap.containsKey(key)){
                rightPrdDifLivLst2.add(prdNameDiffMap.get(key));
            }
        }
        prodDiffLiveWrapper prdDifLivWrp= new prodDiffLiveWrapper();
        prdDifLivWrp.leftProdDiffLiveLst1=leftPrdDifLivLst1;
        prdDifLivWrp.leftProdDiffLiveLst2=leftPrdDifLivLst2;
        prdDifLivWrp.rightProdDiffLiveLst1=rightPrdDifLivLst1;
        prdDifLivWrp.rightProdDiffLiveLst2=rightPrdDifLivLst2;
        prdDifLivWrp.agoIgoLiveVs8am=agoIgoLiveVs8Am;
        prdDifLivWrp.mogasLiveVs8am=mogasLiveVs8Am;
        return prdDifLivWrp;
    }
    public static prodDiffWrapper getProdDifferentialData(){
        List<Product_Differential__c> prodDiffLst= new List<Product_Differential__c>();
        String snapshotRecId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Snapshot').getRecordTypeId();
        prodDiffWrapper prdDifWrp= new prodDiffWrapper();
        List<ProductDifferentialDashboard__mdt> prodDiffMdtLst=[Select Id,MasterLabel,Plant_Code__c,Quote_Name1__c,
                                                               Quote_Name2__c,Quote_Name3__c,Quote_Name4__c,Quote_Type__c,
                                                               Type__c from ProductDifferentialDashboard__mdt
                                                               where Type__c= :'Product Differential' 
                                                               ];
        Set<String> prodDiffLabelSet= new Set<String>();
        for(ProductDifferentialDashboard__mdt pd:prodDiffMdtLst){
            prodDiffLabelSet.add(pd.MasterLabel);
        }
        // Record Type Snapshot
        prodDiffLst=[Select Id,Name,prev_Day_Cargo__c,prev_Day_Barge__c,Barges__c,Cargoes__c,Display_Name__c from Product_Differential__c 
                     where Display_Name__c IN:prodDiffLabelSet AND RecordTypeId=:snapshotRecId
                     and  CreatedDate=TODAY
                    ];
        /*
        if(prodDiffLst.size()<0){
            prodDiffLst=[Select Id,Name,prev_Day_Cargo__c,prev_Day_Barge__c,Barges__c,Cargoes__c from Product_Differential__c 
                     where Name IN:prodDiffLabelSet and  RecordTypeId=:snapshotRecId 
                       and  CreatedDate=:system.today().addDays(-1)
                        ];
        }
		*/
        Map<String,Integer> leftProdDiffMap= new Map<String,Integer>();
        leftProdDiffMap.put('HEL50ppm $/to',0);
        leftProdDiffMap.put('HEL 1000ppm $/to',1);
        leftProdDiffMap.put('DK $/to',2);

        Map<String,Integer> rightProdDiffMap= new Map<String,Integer>();
        rightProdDiffMap.put('AGO/IGO Diff. $/to',0);
        rightProdDiffMap.put(Label.Rv_BioB7_Eur_Cbm,1);
        rightProdDiffMap.put(Label.Rv_Bio_E5_Cbm,2);
        Map<string,Product_Differential__c> prdNameDiffMap= new Map<string,Product_Differential__c>();
        for(Product_Differential__c prd:prodDiffLst){
            prdNameDiffMap.put(prd.Name, prd);
        }
        List<Product_Differential__c> leftProdDiffLst= new List<Product_Differential__c>() ;
        List<Product_Differential__c> rightProdDiffLst= new List<Product_Differential__c>();
        for(string key:leftProdDiffMap.keyset()){
            if(prdNameDiffMap.containsKey(key)){
                leftProdDiffLst.add(prdNameDiffMap.get(key));
            }
        }
        for(string key:rightProdDiffMap.keyset()){
            if(prdNameDiffMap.containsKey(key)){
                rightProdDiffLst.add(prdNameDiffMap.get(key));
            }
        }
        prdDifWrp.rightProdDiffLst=rightProdDiffLst;
        prdDifWrp.leftProdDiffLst=leftProdDiffLst;
        return prdDifWrp;
    }
    @AuraEnabled
    public static RV_SHT_CreateController.searchWrapMRC getMaxContractEndDate(string dateInput){
      return RV_SHT_CreateController.getContarctEndDate(dateInput);
    }
    @AuraEnabled
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }
	@AuraEnabled(cacheable=true)
    public static List<Product_Differential__c> getLiveQuotes(String quoteNames){
        List<String> quoteNameList; 
        Map<String, Product_Differential__c> prodDiffMap = new Map<String, Product_Differential__c>();
        try{
            if(!String.isEmpty(quoteNames)){
                quoteNameList = quoteNames.split(',');
                for(Product_Differential__c prdDiff : [SELECT Id, 
                                                              Display_Name__c,
                                                              Column__c,
                                                              Price__c FROM Product_Differential__c WHERE Display_Name__c IN: quoteNameList /*AND 
                                                                                                          LastModifiedDate = TODAY*/ ORDER BY LastModifiedDate ASC LIMIT 50000]){
                    prodDiffMap.put(prdDiff.Display_Name__c, prdDiff);
                }
                //added by swarna for displying surcharge values on Sales Dashboard
                Product_Differential__c pd = new Product_Differential__c();
                pd.Display_Name__c = 'E5 Surcharge';
                pd.Price__c = Decimal.valueOf(Label.RV_Surcharge_E5);
                prodDiffMap.put(pd.Display_Name__c, pd);
                Product_Differential__c pd1 = new Product_Differential__c();
                pd1.Display_Name__c = 'S98 Surcharge';
                pd1.Price__c = Decimal.valueOf(Label.RV_Surcharge_98);
                prodDiffMap.put(pd1.Display_Name__c, pd1);
                Product_Differential__c pd2 = new Product_Differential__c();
                pd2.Display_Name__c = 'Currencies';
                prodDiffMap.put(pd2.Display_Name__c, pd2);
                //end by swarna
            }
            return prodDiffMap.values();
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class DashoboardWrapper{
        @AuraEnabled
        public List<Revolution_Dashboard__c> dashBoardList;
        @AuraEnabled
        public date contractStartDate;
        @AuraEnabled
        public date contractEndDate;
        @AuraEnabled
        public datetime lastRefreshedAt;
        @AuraEnabled
        public prodDiffWrapper prdWrp;
        @AuraEnabled
        public prodDiffLiveWrapper prdLiveWrp;
        @AuraEnabled
        public String E5_Surcharge;   // added by Dharam : PBI328
        @AuraEnabled
        public String S98_Surcharge;  //added by Dharam : PBI328
    }
    public class prodDiffWrapper{
        @AuraEnabled
         public List<Product_Differential__c> leftProdDiffLst;
        @AuraEnabled
         public List<Product_Differential__c> rightProdDiffLst;
    }
    public class prodDiffLiveWrapper{
        @AuraEnabled
         public List<Product_Differential__c> leftProdDiffLiveLst1;
         @AuraEnabled
         public List<Product_Differential__c> leftProdDiffLiveLst2;
         @AuraEnabled
         public List<Product_Differential__c> rightProdDiffLiveLst1;
         @AuraEnabled
         public List<Product_Differential__c> rightProdDiffLiveLst2;
         @AuraEnabled
         public decimal agoIgoLiveVs8am;
         @AuraEnabled
         public decimal mogasLiveVs8am;
    }

}