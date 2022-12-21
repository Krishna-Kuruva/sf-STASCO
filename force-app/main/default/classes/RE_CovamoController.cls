public with sharing class RE_CovamoController { 
    
    public static List<Rev_Covamo_Detail__c> delCovDetails = new List<Rev_Covamo_Detail__c>();
    /*public static Decimal getFxRate = [SELECT Id,RE_Forex_Rate__c,RE_Trade_Type__c,RE_Tracker__c,RE_Pricing_Date__c From RE_FX_Rates__c WHERE RE_Forex_Name__c = 'MYR/USD' AND RE_Trade_Type__c = 'Exchange Rate' AND RE_Tracker__c = 'D' ORDER BY RE_Pricing_Date__c DESC LIMIT 1].RE_Forex_Rate__c;*/
	
	public static Covamo_Admin_Setup__c cmmdtRef = [SELECT NAME,Base_Unit__c,Local_Currency__c,Analysis_Period_Setting__c,Conversion_SI__c,Corporate_income_tax_payable__c,Corporate_income_tax_rate__c,Days_Per_year__c,Inflation_Rate__c,Integrity_check__c,VAT_Duties_payable_receivable__c,VAT_Rate__c,Weighted_Average_Cost_of_Capital__c,RE_Excise_Duties_in_local_currency__c,Exchange_Rate__c,BDF__c,Cost_Below_C5__c,Cost_Between_C3_C5__c,Payables__c,Receivables__c,Stocks_Days__c,Temperature_Gain__c,VAT_Payment_Days__c FROM Covamo_Admin_Setup__c WHERE NAME = 'Malaysia' LIMIT 1];
    
    @AuraEnabled
    public static String getCovamo_HeaderValueset(String recordId){
        Rev_Covamo_Header__c obj= [Select id,Contract_Name__c,Customer_Name__c,Valuation_Start_Year__c,Valuation_End_Year__c,RE_Valuation_Start_Year__c,RE_Valuation_End_Year__c,Local_Currency__c,Base_Unit__c,Inflation_Rate__c,Weighted_Avearge_Percentage__c,VAT_Percentage__c,Payment_Days__c,Income_Tax_Payable_Days__c,Income_Tax_Payable_Percentage__c,CreatedDate,Created_Date__c,Exchange_Rate__c from Rev_Covamo_Header__c where id=:recordId];
        
        return JSON.serialize(obj);
    }
    @AuraEnabled//a3H0C0000006HyoUAE
    public static List<covemoWrapper>  getCovamo_DetailsValueset(String recordId){
        //Rev_Covamo_Detail__c obj= (Rev_Covamo_Detail__c)JSON.deserialize(covDetails, Rev_Covamo_Detail__c.class);
        List<covemoWrapper> wrps = new List<covemoWrapper>();
        for(Rev_Covamo_Detail__c obj :[Select id, Product_Name__c,Rev_Covamo_Header__c,RE_Product__c,Volume__c,MOPS__c,Market_Premium__c,Freight__c,Oil_Loss__c,Additives__c,Biofuel__c,Hedging_Cost__c,Breakbulk_Cost__c,Miscellaneous_Cost__c,Purchase_Margin__c,Primary_Transport__c,Handling_Cost__c,Secondary_Transport__c,Transportation_Margin__c,Temperature_Gain__c,Expected_Premium_Price_Out__c,Distillation_Premium__c,Total_Sales_Margin__c,Amortization_Per_Unit__c,Unit_C3__c,Target_Unit_C3__c,Cost_Between_C3_C5__c,Cost_Below_C5__c,Stocks_Days__c,Receivables_Days__c,Payables_Days__c,BDF__c,Excise_Fee__c,Type__c,recordtype.Name,recordtypeid,Fixed_Premium__c from Rev_Covamo_Detail__c where Rev_Covamo_Header__c=:recordId]){
            wrps.add(new covemoWrapper(obj));
        }
        return wrps;
    }
    /*Fatch Product Information*/
    @AuraEnabled
    public static List<re_product__c> fetchProductValues(){
        List<re_product__c> products = new List<re_product__c>();
        products = [select id, name,RE_Country__c,RE_Country_Code__c from RE_Product__c WHERE RE_Country__r.Name = 'Malaysia'];
        return products;
    }
    
    @AuraEnabled
        public static String fetchRecordTypeValues(String typename){
       RecordType rcType = new RecordType();
        
        rcType = [select Id,name from RecordType where name=:typename LIMIT 1];
        System.debug(typename+'   '+rcType);
        return JSON.serialize(rcType);
    }
    
    @AuraEnabled
    public static String getCovamo_HeaderFieldataset(){
        Rev_Covamo_Header__c obj= new Rev_Covamo_Header__c();
        //RE_FX_Rates__c fxrate =[SELECT Id,RE_Forex_Rate__c, RE_Pricing_Date__c, RE_Trade_Type__c, RE_Tracker__c, RE_Country__c, RE_Base_Unit__c FROM RE_FX_Rates__c where RE_Conversion_Unit__c= 'MYR' AND RE_Trade_Type__c ='Exchange Rate' AND RE_Tracker__c = 'D' LIMIT 1]; //createddate=today and 
        /*Covamo_Model__mdt cmmdtRef = [SELECT MasterLabel,Analysis_Period_Setting__c,Conversion_SI__c,Corporate_income_tax_payable__c,Corporate_income_tax_rate__c,Days_Per_year__c,Inflation_Rate__c,Integrity_check__c,VAT_Duties_payable_receivable__c,VAT_Rate__c,Weighted_Average_Cost_of_Capital__c,RE_Excise_Duties_in_local_currency__c FROM Covamo_Model__mdt WHERE MasterLabel = 'Malaysia'];*/
        obj.Analysis_Period_Setting__c          =   cmmdtRef.Analysis_Period_Setting__c;
        obj.Valuation_Start_Year__c             =   System.today();
        obj.Valuation_End_Year__c               =   System.today().addYears(2);
        obj.RE_Valuation_Start_Year__c             =   String.valueOf(System.today().year());
        obj.RE_Valuation_End_Year__c               =   String.valueOf(System.today().addYears(2).year());
        obj.Exchange_Rate__c                    =   cmmdtRef.Exchange_Rate__c;//fxrate.RE_Forex_Rate__c;
        obj.Inflation_Rate__c                   =   cmmdtRef.Inflation_Rate__c;
        obj.Weighted_Avearge_Percentage__c      =   cmmdtRef.Weighted_Average_Cost_of_Capital__c;
        obj.VAT_Percentage__c                   =   cmmdtRef.VAT_Rate__c;
        obj.VAT_Duties_payable_receivable__c    =   cmmdtRef.VAT_Duties_payable_receivable__c;
        obj.Local_Currency__c                   =   cmmdtRef.Local_Currency__c;
        obj.Base_Unit__c    =   cmmdtRef.Base_Unit__c;
      //  obj.Conversion_SI__c                  =   cmmdtRef.Conversion_SI__c;
        obj.Income_Tax_Payable_Days__c          =   cmmdtRef.Corporate_income_tax_payable__c;
        obj.Income_Tax_Payable_Percentage__c    =   cmmdtRef.Corporate_income_tax_rate__c;
        obj.Payment_Days__c						=	cmmdtRef.VAT_Payment_Days__c;
		
       // obj.Days_Per_year__c                  =   cmmdtRef.Days_Per_year__c;
        obj.Status__c                         	=   'In-Draft';
        return JSON.serialize(obj);
    }
    
    /*Save Covamo record*/    
    @AuraEnabled
    public static string saveCovamo_HeaderFieldataset(String covHeader, String covDetails,List<String> delList){
        
        List<Rev_Covamo_Detail__c> comDetails = new List<Rev_Covamo_Detail__c>();
        List<Id> deleteList = new List<Id>();
        System.debug(delList);
        deleteList  =   delList;
        if(covHeader != '' && covDetails != ''){
            Rev_Covamo_Header__c obj= (Rev_Covamo_Header__c)JSON.deserialize(covHeader, Rev_Covamo_Header__c.class);
            System.debug('obj'+obj);
            List<covemoWrapper> wrapobjs= (List<covemoWrapper>)JSON.deserialize(covDetails, List<covemoWrapper>.class);
            List<covemoWrapper> wrps = new List<covemoWrapper>();
                           
            Rev_Covamo_Header__c headerRef = new Rev_Covamo_Header__c();
            headerRef   =     obj;
            
            Upsert obj;
           List<String> covamoTypes = new List<String>();
            for(covemoWrapper ob: wrapobjs){
                Rev_Covamo_Detail__c obRef = new Rev_Covamo_Detail__c();
                obRef = ob.comHeader;
                obRef.Rev_Covamo_Header__c = obj.Id;
                comDetails.add(obRef);
                covamoTypes.add(obRef.Type__c);
            }
            System.debug(comDetails);
            Upsert comDetails;
            List<String> covdt =  new List<String>();
			//Date dt= Date.newInstance(Integer.valueOf(obj.RE_Valuation_Start_Year__c), System.today().Month(), System.today().day());
			Integer yearDiff = (Integer.valueOf(obj.RE_Valuation_End_Year__c) - Integer.valueOf(obj.RE_Valuation_Start_Year__c)) ;
           // Integer yearDiff = Integer.valueOf(obj.RE_Valuation_End_Year__c) - Integer.valueOf(obj.RE_Valuation_Start_Year__c);//(obj.Valuation_End_Year__c).Year() - (obj.Valuation_Start_Year__c).Year();
            for(Integer i=0;i<= yearDiff; i++){
                //covdt.add((obj.Valuation_Start_Year__c).addYears(i));
				covdt.add(String.valueOf(Integer.valueOf(obj.RE_Valuation_Start_Year__c) + i));
            }
            System.debug('covamoTypes    '+covamoTypes); 
            System.debug([Select Id,Type__c from Rev_Covamo_FS__c where Rev_Covamo_Header__c=:obj.Id AND Type__c NOT IN: covamoTypes]);
            /*Calculate Financial Summary*/
            for(Rev_Covamo_FS__c delcovfs:[Select Id,Type__c from Rev_Covamo_FS__c where Rev_Covamo_Header__c=:obj.Id AND Type__c NOT IN: covamoTypes]){
                deleteList.add(delcovfs.Id);
            }
            System.debug(deleteList);
            for(Rev_Covamo_Yearly_FS__c delyearlyFS : [Select Id,Year__c,Type__c from Rev_Covamo_Yearly_FS__c where Rev_Covamo_Header__c=:obj.Id AND (Year__c NOT IN: covdt OR Type__c NOT IN: covamoTypes)]){
                deleteList.add(delyearlyFS.Id);
            }
            System.debug(deleteList);
            if(!deleteList.isEmpty()){
                System.debug(deleteList);
                Database.delete(deleteList);
            }
            //List<sObject> deleteList = new List<sObject>();
            list<RE_Covamo_FS_Base__c> fsBase = [Select Id,Year__c,Type__c,Product__c from RE_Covamo_FS_Base__c where Covamo_Header__c=:obj.Id];
            Database.delete(fsBase);
            list<Rev_Covamo_Yearly_FS__c> yearlyFS = [Select Id,Year__c,Type__c from Rev_Covamo_Yearly_FS__c where Rev_Covamo_Header__c=:obj.Id];
           // Database.delete(fsBase);
            list<RE_Covamo_FS_Products__c> fsProd = [Select Id from RE_Covamo_FS_Products__c where RE_Covamo_FS__c IN (Select Id from Rev_Covamo_FS__c where Rev_Covamo_Header__c=:obj.Id)];
            Database.delete(fsProd);
            list<Rev_Covamo_FS__c> covfs = [Select Id,Type__c from Rev_Covamo_FS__c where Rev_Covamo_Header__c=:obj.Id];
           // Database.delete(covfsvals);
            calculateFinancialSummary(obj,comDetails,yearlyFS,covfs);
            return obj.Id;
        }        //list<RE_Covamo_FS_Base__c>,list<Rev_Covamo_Yearly_FS__c>,list<RE_Covamo_FS_Products__c> list<Rev_Covamo_FS__c>
        return null;
    }
    
    @AuraEnabled
    public static String covemoDetailInitialization(String product, String productId, String recordType, String recordTypeId, Decimal volume, Decimal freight, Decimal oilLoss, Decimal breakupBulkCost, Decimal handlingCost, Decimal transportCost,String covHeader,Decimal mops,Decimal marketpremium){
        System.debug('values'+volume+product+freight+oilLoss+breakupBulkCost+handlingCost+transportCost);
      //  RE_SOQLController soqldataset = new RE_SOQLController();
      // Map<String, Double> sqldata = soqldataset.fetchLatestMidFxData();
       String PdodName  = [select id,RE_MY_Product__c,RE_MY_Market_Premium_Quote__c,RE_MY_HCV_Quote__c from RE_Malaysian_Formula_Table__mdt where RE_MY_Product__c=:product LIMIT 1].RE_MY_HCV_Quote__c;//RE_MY_Market_Premium_Quote__c;//(product == 'MOGAS 95' || product== 'MOGAS 97') ? product : 
      
        Rev_Covamo_Header__c obj= (Rev_Covamo_Header__c)JSON.deserialize(covHeader, Rev_Covamo_Header__c.class);
        /*
       Decimal MopsVals = [SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c
            FROM RE_Market_Quotes__c
            WHERE RE_Tracker__c IN ('D')
            AND RE_Quote_Type__c IN ('Settlement','Market Premium')
            AND RE_Quote_Name__c =:PdodName LIMIT 1].RE_Price__c;*/
        
        //Covamo_Model__mdt cmmdtRefs = [SELECT MasterLabel,RE_Excise_Duties_in_local_currency__c FROM Covamo_Model__mdt WHERE MasterLabel = 'Malaysia'];
        Map<String, Double> fxrate = new Map<String, Double>();
        fxrate.put('MYR-USD',obj.Exchange_Rate__c);
        RE_unitConversion unitconv = new RE_unitConversion();
        Rev_Covamo_Detail__c comDetails = new Rev_Covamo_Detail__c();
        //settingDefaut Values
        System.debug('marketpremium   '+marketpremium+'		mops    '+mops);
        comDetails.Volume__c    =   volume;//50000;//MYR/LTR
        
        if(!Test.isRunningTest()){
        comDetails.MOPS__c=(mops * (unitconv.unitConversionMultiplier('USD/BBL','USD/LTR','Malaysia',product,fxrate))).setScale(4);//mops for selected Prods
        System.debug('MOPS__c---'+comDetails.MOPS__c);
        }else{
            comDetails.MOPS__c = -0.108;
        }
            comDetails.Market_Premium__c=(marketpremium/100).setScale(4);
        comDetails.Freight__c=  -freight.setScale(4);//1;
        comDetails.Oil_Loss__c= -(oilLoss/100).setScale(4);//-0.036;  //Hydrocarbon Gain/Loss
        //omDetails.Additives__c    =1;
        comDetails.Breakbulk_Cost__c=   -(breakupBulkCost/100).setScale(4);//1;
       // comDetails.Hedging_Cost__c=1;
        //comDetails.Biofuel__c=1;
        comDetails.Handling_Cost__c=    -(handlingCost/100).setScale(4);//-0.036;
        comDetails.Primary_Transport__c=  -(transportCost/100).setScale(4);//-0.023;
        /*
        comDetails.Target_Unit_C3__c=0.08;*/
        comDetails.Stocks_Days__c=cmmdtRef.Stocks_Days__c;
        comDetails.Receivables_Days__c=	cmmdtRef.Receivables__c;
        comDetails.BDF__c	=	cmmdtRef.BDF__c;
       	comDetails.Cost_Below_C5__c	=	cmmdtRef.Cost_Below_C5__c.setScale(4);
        comDetails.Cost_Between_C3_C5__c	=	cmmdtRef.Cost_Between_C3_C5__c.setScale(4);
        comDetails.Payables_Days__c	=	cmmdtRef.Payables__c;
        comDetails.Temperature_Gain__c	=	cmmdtRef.Temperature_Gain__c.setScale(4);
            
        comDetails.Excise_Fee__c	=	cmmdtRef.RE_Excise_Duties_in_local_currency__c.setScale(4);
        comDetails.Product_Name__c=product;
        comDetails.RE_Product__c=productId;
        comDetails.RecordTypeId=recordTypeId;
        comDetails.Type__c=recordType;
        
        System.debug('comDetails'+JSON.serialize(comDetails));
        return JSON.serialize(comDetails);
    }
    // Save new Covamo Details in Detail COvamo List
    @AuraEnabled
    public static List<covemoWrapper> saveCovamo_detailsset(String covDetails,String wrapData){
        Rev_Covamo_Detail__c obj= (Rev_Covamo_Detail__c)JSON.deserialize(covDetails, Rev_Covamo_Detail__c.class);
        List<covemoWrapper> wrps = new List<covemoWrapper>();
        if(wrapData != ''){
             System.debug('i am in');
            List<covemoWrapper> wrapobjs= (List<covemoWrapper>)JSON.deserialize(wrapData, List<covemoWrapper>.class);
            if(wrapobjs.size() !=0){
                wrps = wrapobjs;
            }
        }
        System.debug('obj   '+obj);
        wrps.add(new covemoWrapper(obj));
       System.debug('wrps   '+wrps);
        return wrps;      
    }
    //  Update Covamo Details in Detail Covamo List
    @AuraEnabled
    public static List<covemoWrapper> saveUpdatedCovamo_detailsset(String covDetails,String wrapData,Integer indexset){
        Rev_Covamo_Detail__c obj= (Rev_Covamo_Detail__c)JSON.deserialize(covDetails, Rev_Covamo_Detail__c.class);
        
        System.debug(wrapData);
        List<covemoWrapper> wrps = new List<covemoWrapper>();
       System.debug('indexset  '+indexset);
            List<covemoWrapper> wrapobjs= (List<covemoWrapper>)JSON.deserialize(wrapData, List<covemoWrapper>.class);
         System.debug(wrapobjs.size());   
            //wrps = wrapobjs;
        Integer i=0;
        for(covemoWrapper ob: wrapobjs){
            
            if(i == indexset){
                 wrps.add(new covemoWrapper(obj));
            }else{
                wrps.add(ob);
            }
            i++;
        }
        
       // wrps.add(indexset,new covemoWrapper(obj));
        System.debug(wrps);
        return wrps;      
    }
    
     @AuraEnabled
    public static covemoDeleteItemsWrapper deleteCovamo_detailsset(String wrapData,Integer indexset, List<String> delList){
        
        List<covemoWrapper> wrps = new List<covemoWrapper>();
        List<String> delwrps = new List<String>();
        delwrps = delList;
        List<covemoWrapper> wrapobjs= (List<covemoWrapper>)JSON.deserialize(wrapData, List<covemoWrapper>.class);
        Integer i=0;
        
        for(covemoWrapper ob: wrapobjs){
            
            if(i == indexset){
                 //wrps.add(new covemoWrapper(obj));
                if(ob.comHeader.Id != null){
                    //delCovDetails.add(new Rev_Covamo_Detail__c(Id=ob.comHeader.Id));
                    delwrps.add(ob.comHeader.Id);
                }
            }else{
                wrps.add(ob);
            }
            i++;
        }
        
        return new covemoDeleteItemsWrapper(wrps,delwrps);
    }
    public class covemoWrapper{
        @AuraEnabled
        public Rev_Covamo_Detail__c comHeader { get; set; }
        public covemoWrapper(){}
        public covemoWrapper(Rev_Covamo_Detail__c comHeader){
            this.comHeader=comHeader;
        }
    }
    public class covemoDeleteItemsWrapper{
        @AuraEnabled
        public List<covemoWrapper> coms { get; set; }
        @AuraEnabled
        public List<Id> delcoms { get; set; }
        public covemoDeleteItemsWrapper(){}
        public covemoDeleteItemsWrapper(List<covemoWrapper> coms,List<String> delcoms){
            this.coms=coms;
            this.delcoms=delcoms;
        }
    }
    @AuraEnabled (cacheable=true)
    public static String getRev_Covamo_Header(){
        List<Rev_Covamo_Header__c> records = [select Id,Name,Customer_Name__c,Status__c,CreatedBy.Name,CreatedDate,Created_Date__c,Contract_Name__c,RE_Valuation_Start_Year__c,RE_Valuation_End_Year__c,Inflation_Rate__c,Weighted_Avearge_Percentage__c from Rev_Covamo_Header__c ORDER BY Createddate DESC LIMIT 50000];
        return JSON.serialize(records);
    }
    @AuraEnabled 
    public static List<covHeaderWrapper> searchRev_Covamo_Header(String searchText){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl'+baseUrl);
        String searchKeyword = '%'+searchText+'%';
        System.debug('searchKeyword'+searchKeyword+searchText);
        List<Rev_Covamo_Header__c> records = [select Id,Name,Customer_Name__c,Status__c,CreatedBy.Name,CreatedDate,Created_Date__c,Contract_Name__c,RE_Valuation_Start_Year__c,RE_Valuation_End_Year__c,Inflation_Rate__c,Weighted_Avearge_Percentage__c from Rev_Covamo_Header__c where Name Like:searchKeyword OR Customer_Name__c Like:searchKeyword OR Status__c Like:searchKeyword OR Contract_Name__c Like:searchKeyword OR RE_Valuation_Start_Year__c Like:searchKeyword OR RE_Valuation_End_Year__c Like:searchKeyword ORDER BY createddate DESC LIMIT 50000];
        System.debug('records'+records);
        
        List<covHeaderWrapper> covWrapList = new List<covHeaderWrapper>();
        Boolean isAMshow= getCovamoHeaderQueueUsers();
        for(Integer i=0;i<records.size();i++){
            covHeaderWrapper covWrap = new covHeaderWrapper();
            if(records[i].Status__c == 'In-Draft'){
                covWrap.url = baseUrl+'/lightning/r/Rev_Covamo_Header__c/'+records[i].id+'/edit';
            }else{
                covWrap.url = '';
            }
            covWrap.showdiscard	=	!isAMshow && records[i].Status__c!= 'Discard' ;
            covWrap.covHeaderData = records[i];
            covWrapList.add(covWrap);
        }  
        System.debug('covWrapList---'+covWrapList);
        return covWrapList;

    }
    public static void getFinancialBase(Rev_Covamo_Header__c objHeader, List<Rev_Covamo_Detail__c> wrpsDetails,Map<String,String> yearlyFSMap){
        System.debug('wrpsDetails ====>'+wrpsDetails);
		
		//Date dt= Date.newInstance(Integer.valueOf(objHeader.RE_Valuation_Start_Year__c), System.today().Month(), System.today().day());
		Integer yearDiff = Integer.valueOf(objHeader.RE_Valuation_End_Year__c) - Integer.valueOf(objHeader.RE_Valuation_Start_Year__c);
        //Integer yearDiff = (dt.addYears(Integer.valueOf(objHeader.RE_Valuation_End_Year__c) - Integer.valueOf(objHeader.RE_Valuation_Start_Year__c))).Year() ;//(objHeader.Valuation_End_Year__c).Year() - (objHeader.Valuation_Start_Year__c).Year();
        //Decimal stock_opening_balance = 0;
        
        Decimal [] arr= new Decimal[30];      
        Decimal [] arrNPV= new Decimal[30];  
        for(Integer i=0;i<30;i++){
            
            if(i== 0){
                
                //System.debug(1 + ((2/100) * 0.5));
                arr[i] = 1 + ((objHeader.Inflation_Rate__c / 100) * 0.5);
                arrNPV[i]   =   1 + (objHeader.Weighted_Avearge_Percentage__c/100);
            }else{
                Decimal rate = 1 + (objHeader.Inflation_Rate__c/100);
                Decimal NPVCal = 1 + (objHeader.Weighted_Avearge_Percentage__c/100);
                Decimal finalMultiplier = 1.00;
                Decimal NPVMultiplier = 1.00;
                
                for(Integer j=0;j<=i;j++){
                    if(j<i){
                    	finalMultiplier = finalMultiplier * rate;
                    }
                    NPVMultiplier   =   NPVMultiplier * NPVCal;
                }
                arr[i] =    arr[0] * finalMultiplier;
                arrNPV[i]   =   NPVMultiplier;
            }
        }
        System.debug('arr '+arr);
        System.debug('arrNPV   '+arrNPV);
        Decimal exchange_Rate = objHeader.Exchange_Rate__c;
        objHeader.VAT_Duties_payable_receivable__c = objHeader.Payment_Days__c;
        Integer Days_per_year_SI = Integer.valueOf(cmmdtRef.Days_Per_year__c);//365;
        Integer Conversion_SI = Integer.valueOf(cmmdtRef.Conversion_SI__c);//1000;
        System.debug('Conversion_SI--->'+Conversion_SI);
        
              
        List<RE_Covamo_FS_Base__c> covamo_baseRef = new List<RE_Covamo_FS_Base__c>();
        Integer is = 0;
        for(Rev_Covamo_Detail__c covs : wrpsDetails){
            
            Decimal stock_opening_balance = 0.0000;
            Decimal receivables_fuel_openingbalance = 0.0000;
            Decimal receivables_exise_fuel_opening_balance = 0.0000;
            Decimal receivables_vat_fuel_opening_balance = 0.0000;
            Decimal payables_fuel_opening_balance = 0.0000;
            Decimal payables_exise_fuel_opening_balance = 0.0000;
            Decimal payables_vat_fuel_opening_balance = 0.0000;
            Decimal BDF_Opening_Balance = 0.0000;
            Decimal Total_Income_Tax_Opening_Balance = 0.0000;
            for(Integer i=0;i<= yearDiff + 1; i++){
                //covs.Excise_Fee__c = 0.40 ;
                //covs.BDF__c = 2.0000;
               //covs.Payables_Days__c =  is==0 ? 30 : 0;
                
          
                RE_Covamo_FS_Base__c obj = new RE_Covamo_FS_Base__c();
                obj.Covamo_Header__c            =   objHeader.Id;
                obj.Volume__c = (i!= yearDiff + 1) ? covs.Volume__c : 0000;     //  Volume
                obj.Type__c = covs.Type__c;         //  Type
                obj.Year__c = String.valueOf(Integer.valueOf(objHeader.RE_Valuation_Start_Year__c) + i);//(objHeader.Valuation_Start_Year__c).addYears(i);
                obj.Product__c = covs.RE_Product__c;
                obj.RE_BDF_Amortization__c =(i!= yearDiff + 1) ? (-1 * (covs.BDF__c/(yearDiff+1)).setScale(4)) : 0.0;   // Amortization
                obj.Stocks_Opening_Balance__c =stock_opening_balance;
                String keyValset = String.valueOf(obj.Year__c + obj.Type__c+obj.Product__c);
                
                /*------Stock Starts------*/
                //Stock In
                Decimal B_Inpt_P1_purchase_margin_SI        = -covs.MOPS__c * exchange_Rate + covs.Purchase_Margin__c;
                Decimal B_Calc_P1_purchase_margin_total_SI  = B_Inpt_P1_purchase_margin_SI * (1 / exchange_Rate);
                System.debug('check values----'+B_Calc_P1_purchase_margin_total_SI+','+covs.Volume__c+','+Conversion_SI);
                Decimal stock_in = (i!= yearDiff + 1) ? (-((B_Calc_P1_purchase_margin_total_SI * covs.Volume__c)/Conversion_SI)) : 0.00;
                obj.Stocks_Invoiced__c = stock_in;
                //Stock Out
				System.debug(Days_per_year_SI+'    '+covs.Stocks_Days__c+'       '+stock_in);
                 Decimal stock_out = (((Days_per_year_SI - covs.Stocks_Days__c) / Days_per_year_SI) * stock_in);
				if(i==0){
					stock_out = stock_out;
                     System.debug('1===='+stock_out);
				}else
				if(i>0 && i<= yearDiff){
					stock_out = stock_out + stock_opening_balance;System.debug('2===='+stock_out);
				}
				else if(i== yearDiff+1){
					stock_out = stock_opening_balance;// + stock_in;
                    System.debug('3===='+stock_out);
					
				}
				
				
                /*if(i>0 && i< yearDiff){
                    stock_out = stock_out + stock_opening_balance;
                }
                if(i== yearDiff){
                    stock_out = stock_opening_balance + stock_in;
                }*/
                 obj.Stocks_Received__c = stock_out;
                //Stocks Movement
                Decimal stocks_movement = stock_in - stock_out;
                obj.Stocks_Movement__c = stocks_movement;
                 //Stocks Closing Balance
                Decimal stocks_closing_balance = stock_opening_balance + stocks_movement;
                obj.Stocks_Closing_Balance__c = stocks_closing_balance;
                //stock_opening_balance = stocks_closing_balance;
                
           /*------Stock Ends------*/
                
           /*------Receivables Fuel Invoiced Starts------*/
                
                obj.Receivables_Fuel_Opening_Balance__c = receivables_fuel_openingbalance;
                Decimal B_Inpt_P1_sale_margin_SI = covs.MOPS__c * exchange_Rate + covs.Total_Sales_Margin__c;                
                Decimal B_Calc_P1_sale_margin_total_SI = B_Inpt_P1_sale_margin_SI * (1/exchange_Rate);  
                Decimal B_Inpt_duties_product_1_SI =covs.Excise_Fee__c * (1/exchange_Rate);
				//Receivables Fuel IN
                Decimal  RF_In = (i!= yearDiff + 1) ? (((B_Calc_P1_sale_margin_total_SI+(B_Inpt_duties_product_1_SI))*(1 + (objHeader.VAT_Percentage__c/100)) *  covs.Volume__c)/Conversion_SI) : 0.00;
                obj.Receivables_Fuel_Invoiced__c = RF_In;
                //Receivables Fuel Out
                 Decimal RF_out = ((Days_per_year_SI - covs.Receivables_Days__c) / Days_per_year_SI) * RF_In;
                if(i==0){
					RF_out = RF_out;
				}else if(i>0 && i<= yearDiff){
                    RF_out = RF_out + receivables_fuel_openingbalance;
                }else if(i== yearDiff + 1){
                    RF_out = receivables_fuel_openingbalance;// + RF_In;
                }
                obj.Receivables_Fuel_Received__c    = RF_out;
                //Receivables Fuel Movement
                Decimal RF_movement = RF_In - RF_out;
                obj.Receivables_Fuel_Movement__c = RF_movement;
                
                 //Receivables Fuel Closing Balance
                Decimal RF_closing_balance = receivables_fuel_openingbalance + RF_movement;
                obj.Receivables_Fuel_Closing_Balance__c = RF_closing_balance;
                //receivables_fuel_openingbalance = RF_closing_balance;
                
           /*------Receivables Fuel Invoiced Ends------*/
           /*------Receivables Exise fuel Opening Balance Start------*/
                obj.Receivables_Exise_fuel_Opening_Balance__c = receivables_exise_fuel_opening_balance;
                //Receivables Fuel IN
                Decimal  RE_In = (i!= yearDiff + 1) ? ((B_Inpt_duties_product_1_SI * covs.Volume__c)/Conversion_SI) : 0.00;
                obj.Receivables_Exise_fuel_Invoiced__c = RE_In;
                //Receivables Fuel Out
                Decimal RE_out = ((Days_per_year_SI - objHeader.VAT_Duties_payable_receivable__c) / Days_per_year_SI) * RE_In;
                if(i==0){
					RE_out = RE_out;
				}else if(i>0 && i<= yearDiff){
                    RE_out = RE_out + receivables_exise_fuel_opening_balance;
                }else  if(i== yearDiff + 1){
                    RE_out = receivables_exise_fuel_opening_balance;// + RE_In;
                }
                obj.Receivables_Exise_fuel_Received__c  =    RE_out;              
                //Receivables Fuel Movement
                Decimal RE_movement = RE_In - RE_out;
                obj.Receivables_Exise_fuel_Movement__c  =   RE_movement;
                //Receivables Fuel Closing Balance
                Decimal RE_closing_balance = receivables_exise_fuel_opening_balance + RE_movement;
                obj.Receivables_Exise_fuel_Closing_Balance__c = RE_closing_balance;
                //receivables_exise_fuel_opening_balance = RE_closing_balance;
                
           /*------Receivables Exise fuel Opening Balance Ends------*/
           
           /*------Receivables VAT fuel Opening Balance Start------*/
                obj.Receivables_VAT_fuel_Opening_Balance__c = receivables_vat_fuel_opening_balance;
                //Receivables Fuel IN
                Decimal  RVF_In = (i!= yearDiff + 1) ? (((-(B_Calc_P1_purchase_margin_total_SI+(-B_Inpt_duties_product_1_SI)) * (objHeader.VAT_Percentage__c/100) * covs.Volume__c)/Conversion_SI)) : 0.00;
                obj.Receivables_VAT_fuel_Invoiced__c = RVF_In;
                //Receivables Fuel Out
                Decimal RVF_out = (((Days_per_year_SI - objHeader.VAT_Duties_payable_receivable__c) / Days_per_year_SI) * RVF_In);
                if(i==0){
					RVF_out = RVF_out;
				}else if(i>0 && i<= yearDiff){
                    RVF_out = RVF_out + receivables_vat_fuel_opening_balance;
                }else if(i== yearDiff + 1){
                    RVF_out = receivables_vat_fuel_opening_balance;// + RVF_In;
                }
                obj.Receivables_VAT_fuel_Received__c = RVF_out;
                //Receivables Fuel Movement
                Decimal RVF_movement = RVF_In - RVF_out;
                obj.Receivables_VAT_fuel_Movement__c = RVF_movement;
                 //Receivables Fuel Closing Balance
                Decimal RVF_closing_balance = receivables_vat_fuel_opening_balance + RVF_movement;
                obj.Receivables_VAT_fuel_Closing_Balance__c = RVF_closing_balance;
                //receivables_vat_fuel_opening_balance = RVF_closing_balance;
                    
           /*------Receivables VAT fuel Opening BalanceEnds------*/
           /*------Payables Fuel Opening Balance Opening Balance Start------*/
                obj.Payables_Fuel_Opening_Balance__c = payables_fuel_opening_balance;
                //Payables Fuel Invoiced IN
                Decimal  PFI_In = (i!= yearDiff + 1) ? (((-(B_Calc_P1_purchase_margin_total_SI + (-B_Inpt_duties_product_1_SI)) * (1 + (objHeader.VAT_Percentage__c/100)) * covs.Volume__c)/Conversion_SI)) : 0.00;
                obj.Payables_Fuel_Invoiced__c = PFI_In;
                //Receivables Fuel Out
                Decimal PFI_out = (((Days_per_year_SI - covs.Payables_Days__c) / Days_per_year_SI) * PFI_In);
               
                if(i==0){
					PFI_out = PFI_out;
				}else if(i>0 && i<= yearDiff){
                    PFI_out = PFI_out + payables_fuel_opening_balance;
                }else if(i== yearDiff + 1){
                    PFI_out = payables_fuel_opening_balance;// + PFI_In;
                }
                obj.Payables_Fuel_Received__c = PFI_out;
                //Receivables Fuel Movement
                Decimal PFI_movement = PFI_In - PFI_out;
                obj.Payables_Fuel_Movement__c = PFI_movement;
                 //Receivables Fuel Closing Balance
                Decimal PFI_closing_balance = payables_fuel_opening_balance + PFI_movement;
                obj.Payables_Fuel_Closing_Balance__c = PFI_closing_balance;
                //payables_fuel_opening_balance = PFI_closing_balance;
           /*------Payables Fuel Opening Balance Ends------*/
           /*------Payables Fuel Opening Balance Starts------*/
                obj.Payables_Exise_fuel_Opening_Balance__c = payables_exise_fuel_opening_balance;
                //Payables Exise fuel Invoiced IN                
                Decimal  PEF_In = RE_In;
                obj.Payables_Exise_fuel_Invoiced__c = PEF_In;
                //Payables Exise fuel Invoiced Out
                Decimal  PEF_out = RE_out;
                obj.Payables_Exise_fuel_Received__c = PEF_out;
                //Payables Exise fuel Invoiced Moment
                Decimal PEF_movement = PEF_In - PEF_out;
                obj.Payables_Exise_fuel_Movement__c = PEF_movement;
                //Payables Exise fuel Invoiced CB
                Decimal PEF_closing_balance = RE_closing_balance;
                obj.Payables_Exise_fuel_Closing_Balance__c = PEF_closing_balance;
               // payables_exise_fuel_opening_balance = PEF_closing_balance;

           /*------Payables Fuel Opening Balance Ends------*/
           /*------Payables VAT fuel Opening Balance Starts------*/
                obj.Payables_VAT_fuel_Opening_Balance__c = payables_vat_fuel_opening_balance;
                 //Payables Fuel IN
                Decimal  PVF_In = (i!= yearDiff + 1) ? (((B_Calc_P1_sale_margin_total_SI+(B_Inpt_duties_product_1_SI)) * (objHeader.VAT_Percentage__c/100) *  covs.Volume__c)/Conversion_SI) : 0.00;
                obj.Payables_VAT_fuel_Invoiced__c = PVF_In;
                //Payables Fuel Out
                 Decimal PVF_out = ((Days_per_year_SI - covs.Receivables_Days__c) / Days_per_year_SI) * PVF_In;
                if(i==0){
					PVF_out = PVF_out;
				}else if(i>0 && i<= yearDiff){
                    PVF_out = PVF_out + payables_vat_fuel_opening_balance;
                }else if(i== yearDiff + 1){
                    PVF_out = payables_vat_fuel_opening_balance;// + PVF_In;
                }
                obj.Payables_VAT_fuel_Received__c = PVF_out;
                //Payables Fuel Movement
                Decimal PVF_movement = PVF_In - PVF_out;
                obj.Payables_VAT_fuel_Movement__c = PVF_movement;
                 //Payables Fuel Closing Balance
                Decimal PVF_closing_balance = payables_vat_fuel_opening_balance + PVF_movement;
                obj.Payables_VAT_fuel_Closing_Balance__c = PVF_closing_balance;
                //payables_vat_fuel_opening_balance = PVF_closing_balance;
           /*------Payables VAT fuel Opening Balance Ends------*/
           /*BDF_Opening_Balance__c*/
                obj.BDF_Opening_Balance__c = BDF_Opening_Balance.setScale(4);
                
                if(i==0){
                    obj.BDF_Closing_Balance__c = (obj.BDF_Opening_Balance__c + covs.BDF__c +obj.RE_BDF_Amortization__c).setScale(4);
                }else{
                    obj.BDF_Closing_Balance__c = (obj.BDF_Opening_Balance__c + obj.RE_BDF_Amortization__c).setScale(4);
                }
                
                //obj.BDF_Closing_Balance__c = obj.BDF_Opening_Balance__c + covs.BDF__c +obj.RE_BDF_Amortization__c;
               
           /**/    
                            /* C3 Margin  start*/
                //B_IS_Transportation_SI
                Decimal B_IS_Transportation_SI = ((covs.Transportation_Margin__c * (1 / exchange_Rate)) * covs.Volume__c)/Conversion_SI;
                decimal B_IS_Gross_Margin_SI = ((B_Calc_P1_purchase_margin_total_SI * covs.Volume__c)/Conversion_SI) + ((covs.Volume__c /Conversion_SI) * B_Calc_P1_sale_margin_total_SI);
                obj.RE_C3_Margin__c = (i!= yearDiff + 1) ? (B_IS_Gross_Margin_SI + B_IS_Transportation_SI + obj.RE_BDF_Amortization__c) : 0.00;
                
             /* C3 Margin  End*/
             /*C5 Cash Contribution  start*/
                obj.RE_C5_Cash_Contribution__c  =  (i!= yearDiff + 1) ? (obj.RE_C3_Margin__c +((covs.Cost_Between_C3_C5__c + covs.Cost_Below_C5__c) * (covs.Volume__c / (Conversion_SI * exchange_Rate)))) : 0.0 ;
             /*C5 Cash Contribution  End*/
             /* C10 NIBIAT CCS start */ 
                
                obj.RE_C10_NIBIAT_CCS__c    = (i!= yearDiff + 1) ? (obj.RE_C5_Cash_Contribution__c * (1 + (- objHeader.Income_Tax_Payable_Percentage__c/100))) : 0.0;
             /* C10 NIBIAT CCS End */
                
           /*Total_Income_Tax_Opening_Balance start*/
                obj.Total_Income_Tax_Opening_Balance__c = Total_Income_Tax_Opening_Balance;
                 //Payables Fuel IN
                Decimal  IT_In = (i!= yearDiff + 1) ? (-obj.RE_C5_Cash_Contribution__c * ((- objHeader.Income_Tax_Payable_Percentage__c/100))) : 0.00;
                obj.Total_Income_Tax_Receive_Balance__c = IT_In;
                //Payables Fuel Out
                 Decimal IT_out = ((Days_per_year_SI - objHeader.Income_Tax_Payable_Days__c) / Days_per_year_SI) * IT_In;
                if(i==0){
					IT_out = IT_out;
				}else if(i>0 && i<= yearDiff){
                    IT_out = IT_out + Total_Income_Tax_Opening_Balance;
                }else if(i== yearDiff + 1){
                    IT_out = Total_Income_Tax_Opening_Balance;// + IT_In;
                }
                obj.Total_Income_Tax_Receive_OUT_Balance__c = IT_out;
                //Payables Fuel Movement
                Decimal IT_movement = IT_In - IT_out;
                obj.Total_Income_Tax_Receive_Moment_Balance__c = IT_movement;
                 //Payables Fuel Closing Balance
                Decimal Total_Income_Tax_Closing_Balance = Total_Income_Tax_Opening_Balance + IT_movement;
                obj.Total_Income_Tax_Receive_Closing_Balance__c = Total_Income_Tax_Closing_Balance;
           /*Total_Income_Tax_Opening_Balance End*/   
           /*Total_Capital_Employed__c Start*/
                obj.Total_Capital_Employed__c = (stocks_closing_balance + RF_closing_balance + RE_closing_balance + RVF_closing_balance) - ( PFI_closing_balance +PEF_closing_balance +PVF_closing_balance + Total_Income_Tax_Closing_Balance ) + obj.BDF_Closing_Balance__c; 
           /*Total_Capital_Employed__c End*/
           /*Working Capital*/
               obj.Total_Closing_Balance_WORKING_CAPITAL__c=  (stocks_closing_balance + RF_closing_balance + RE_closing_balance + RVF_closing_balance )
                                                               - 
                                                              (+ PFI_closing_balance +PEF_closing_balance +PVF_closing_balance )+(-Total_Income_Tax_Closing_Balance) + obj.BDF_Closing_Balance__c;
               obj.Total_Opening_Balance_WORKING_CAPITAL__c = (stock_opening_balance + receivables_fuel_openingbalance + receivables_exise_fuel_opening_balance + receivables_vat_fuel_opening_balance)
                                                                -
                                                               (+payables_fuel_opening_balance +payables_exise_fuel_opening_balance +payables_vat_fuel_opening_balance)+(-Total_Income_Tax_Opening_Balance) + BDF_Opening_Balance;
                
                obj.Total_Movement_WORKING_CAPITAL__c = (-(obj.Total_Closing_Balance_WORKING_CAPITAL__c - obj.Total_Opening_Balance_WORKING_CAPITAL__c));
				System.debug('obj.Total_Movement_WORKING_CAPITAL__c		'+(obj.Total_Movement_WORKING_CAPITAL__c).setScale(4));

				System.debug('obj.Total_Movement_WORKING_CAPITAL__c		'+(obj.Total_Movement_WORKING_CAPITAL__c));
                stock_opening_balance = stocks_closing_balance;
                receivables_fuel_openingbalance = RF_closing_balance;
                receivables_exise_fuel_opening_balance = RE_closing_balance;
                receivables_vat_fuel_opening_balance = RVF_closing_balance;             
                payables_fuel_opening_balance = PFI_closing_balance;                               
                payables_exise_fuel_opening_balance = PEF_closing_balance;                                             
                payables_vat_fuel_opening_balance = PVF_closing_balance;    
                BDF_Opening_Balance =   obj.BDF_Closing_Balance__c;
                Total_Income_Tax_Opening_Balance    =Total_Income_Tax_Closing_Balance;
                covamo_baseRef.add(obj);
            }
            
            is++;
        }
        upsert covamo_baseRef;
        
        List<Rev_Covamo_Yearly_FS__c> covamoYFS = new List<Rev_Covamo_Yearly_FS__c>();
        Map<String,Rev_Covamo_Yearly_FS__c> covamoFSMap = new Map<String,Rev_Covamo_Yearly_FS__c>();
        Integer arrayCount= 0;
        Map<String,Double> roacheMap=new Map<String,Double>();
        
        for(RE_Covamo_FS_Base__c covBaseRef : covamo_baseRef){
            
            String keyVal = ''+covBaseRef.Year__c + covBaseRef.Type__c;
            Double nib = 0.00;
        	Double capemp = 0.00;
            for(String fbs:covamoFSMap.keySet()){
                if(covBaseRef.Type__c == covamoFSMap.get(fbs).Type__c){
                    nib	=	nib + covamoFSMap.get(fbs).C10_NIBIAT_CCS__c;
                    capemp	= capemp + covamoFSMap.get(fbs).Capital_Employed__c;
                }
            }
            if(covamoFSMap.containsKey(keyVal)){
                System.debug('seemesh  1');
                Integer arrayCountset = arrayCount - (yearDiff + 1);
                Rev_Covamo_Yearly_FS__c coBase = covamoFSMap.get(keyVal);
                Rev_Covamo_Yearly_FS__c obj = new Rev_Covamo_Yearly_FS__c();
                obj.Rev_Covamo_Header__c    =   objHeader.Id;
                
                //String keyValset = ''+obj.Year__c + obj.Type__c;
                if(yearlyFSMap.containskey(keyVal)){
                   obj.Id = yearlyFSMap.get(keyVal);
                }
                obj.Year__c =   covBaseRef.Year__c;
                obj.Type__c =   covBaseRef.Type__c;
                obj.Volume__c = coBase.Volume__c + covBaseRef.Volume__c;
                obj.BDF_Amortization__c = (coBase.BDF_Amortization__c + covBaseRef.RE_BDF_Amortization__c).setScale(2);
                obj.C3_Margin__c = (coBase.C3_Margin__c + covBaseRef.RE_C3_Margin__c).setScale(2);
                obj.C5_Cash_Contribution__c = (coBase.C5_Cash_Contribution__c + covBaseRef.RE_C5_Cash_Contribution__c).setScale(2);
                obj.C10_NIBIAT_CCS__c = (coBase.C10_NIBIAT_CCS__c + covBaseRef.RE_C10_NIBIAT_CCS__c).setScale(2);
                obj.Working_Capital_Movements__c = ((coBase.Working_Capital_Movements__c + covBaseRef.Total_Movement_WORKING_CAPITAL__c)).setScale(2);
                obj.Net_Cash_Flow__c = (obj.C10_NIBIAT_CCS__c + obj.Working_Capital_Movements__c).setScale(2);
                //obj.Net_Cash_Flow_RT_W_O_Inflation__c   =   (coBase.Net_Cash_Flow_RT_W_O_Inflation__c + (obj.Net_Cash_Flow__c / arr[arrayCount])).setScale(2);
                //System.debug('---->'+(obj.Net_Cash_Flow__c/ arr[arrayCountset]).setScale(2)+'    '+obj.Net_Cash_Flow__c+'     '+arr[arrayCountset]+'     '+arrayCountset);
                obj.Net_Cash_Flow_RT_W_O_Inflation__c   =   (obj.Net_Cash_Flow__c/ arr[arrayCountset]).setScale(2);
                //obj.VIR_Denominator__c  =   (coBase.VIR_Denominator__c + (obj.Working_Capital_Movements__c / arr[arrayCount])).setScale(2);
                obj.VIR_Denominator__c  =   (obj.Working_Capital_Movements__c / arr[arrayCountset]).setScale(2);
                obj.NPV__c              = 	((obj.Net_Cash_Flow_RT_W_O_Inflation__c / arrNPV[arrayCountset])* Math.sqrt(1 + (objHeader.Weighted_Avearge_Percentage__c/100))).setScale(2);
                obj.Capital_Employed__c = (coBase.Capital_Employed__c + covBaseRef.Total_Capital_Employed__c).setScale(2);
                obj.VIR_DENOMINATOR_NPV__c  = ((obj.VIR_Denominator__c/ arrNPV[arrayCountset]) * Math.sqrt(1 + (objHeader.Weighted_Avearge_Percentage__c/100))).setScale(2);
                //obj.VIR__c  =   (obj.NPV__c/obj.VIR_DENOMINATOR_NPV__c);
                //obj.Average_ROACE__c    =   obj.Capital_Employed__c.setScale(2) != 0.00 ? ((obj.C10_NIBIAT_CCS__c/obj.Capital_Employed__c).setScale(4)) : null;//-1.85;
                //obj.Average_ROACE__c    =   obj.Capital_Employed__c.setScale(2) != 0.00 ? (((((obj.C10_NIBIAT_CCS__c+nib)/(obj.Capital_Employed__c+capemp)).setScale(4)).setScale(2))*100) : null;//-1.85;
                covamoFSMap.put(keyVal, obj); 
                Integer yearDiffvals = yearDiff !=0 ? yearDiff : 1;
                if(obj.Capital_Employed__c.setScale(2) == 0.00){
                roacheMap.put(covBaseRef.Type__c,(((obj.C10_NIBIAT_CCS__c+nib)/yearDiffvals)/((obj.Capital_Employed__c+capemp)/yearDiffvals)));
            	}
            }else{
                Rev_Covamo_Yearly_FS__c obj = new Rev_Covamo_Yearly_FS__c();
                obj.Rev_Covamo_Header__c    =   objHeader.Id;
                if(yearlyFSMap.containskey(keyVal)){
                   obj.Id = yearlyFSMap.get(keyVal);
                }
                obj.Year__c =   covBaseRef.Year__c;
                obj.Type__c =   covBaseRef.Type__c;
                obj.Volume__c = covBaseRef.Volume__c;
                obj.BDF_Amortization__c = covBaseRef.RE_BDF_Amortization__c.setScale(2);
                obj.C3_Margin__c = covBaseRef.RE_C3_Margin__c.setScale(2);
                obj.C5_Cash_Contribution__c = covBaseRef.RE_C5_Cash_Contribution__c.setScale(2);
                obj.C10_NIBIAT_CCS__c = covBaseRef.RE_C10_NIBIAT_CCS__c.setScale(2);
                obj.Working_Capital_Movements__c = covBaseRef.Total_Movement_WORKING_CAPITAL__c.setScale(2);
                obj.Net_Cash_Flow__c = (covBaseRef.Total_Movement_WORKING_CAPITAL__c + covBaseRef.RE_C10_NIBIAT_CCS__c).setScale(2);
               // System.debug('NPV cash flow  '+obj.Net_Cash_Flow__c +'   '+arr[arrayCount]+'    '+((obj.Net_Cash_Flow__c / arr[arrayCount]).setScale(2)));
                obj.Net_Cash_Flow_RT_W_O_Inflation__c   =   (obj.Net_Cash_Flow__c / arr[arrayCount]).setScale(2);
                obj.VIR_Denominator__c  =   (obj.Working_Capital_Movements__c / arr[arrayCount]).setScale(2);
               // System.debug(obj.Net_Cash_Flow_RT_W_O_Inflation__c+'    vvvvvvv         '+arrNPV[arrayCount]);
                obj.NPV__c              = ((obj.Net_Cash_Flow_RT_W_O_Inflation__c / arrNPV[arrayCount])* Math.sqrt(1 + (objHeader.Weighted_Avearge_Percentage__c/100))).setScale(2);
                obj.Capital_Employed__c = (covBaseRef.Total_Capital_Employed__c).setScale(2);  
//System.debug('obj.VIR_Denominator__c    '+obj.VIR_Denominator__c);				
                obj.VIR_DENOMINATOR_NPV__c  =   ((obj.VIR_Denominator__c/ arrNPV[arrayCount]) * Math.sqrt(1 + (objHeader.Weighted_Avearge_Percentage__c/100))).setScale(2);
                //obj.VIR__c  =  (obj.NPV__c/obj.VIR_DENOMINATOR_NPV__c) ;
               
                //obj.Average_ROACE__c    =   obj.Capital_Employed__c.setScale(2) != 0.00 ? ((((((obj.C10_NIBIAT_CCS__c+nib)/2)/((obj.Capital_Employed__c+capemp)/2)).setScale(4)).setScale(2))*100) : 0.00;//null;//-1.85;
                covamoFSMap.put(keyVal, obj);
                Integer yearDiffvals = yearDiff !=0 ? yearDiff : 1;
                if(obj.Capital_Employed__c.setScale(2) == 0.00){
                roacheMap.put(covBaseRef.Type__c,(((obj.C10_NIBIAT_CCS__c+nib)/yearDiffvals)/((obj.Capital_Employed__c+capemp)/yearDiffvals)));
            	}
            }
            
            arrayCount ++;
        }
        for(String covs : covamoFSMap.keyset()){
            Rev_Covamo_Yearly_FS__c obj = new Rev_Covamo_Yearly_FS__c();
            obj = covamoFSMap.get(covs);
            if(obj.Capital_Employed__c.setScale(2) != 0.00){
                obj.Average_ROACE__c=roacheMap.get(obj.Type__c);
            }else{
                obj.Average_ROACE__c=0.00;
            }
            covamoYFS.add(obj);
        }
        
        
        upsert covamoYFS;
       /*
        List<Rev_Covamo_FS__c> covamoFS = new List<Rev_Covamo_FS__c>();
        for(AggregateResult objref: [select type__c,sum(volume__c) Vol,sum(C3_Margin__c) Margin,sum(C10_NIBIAT_CCS__c) NIBIAT from Rev_Covamo_Yearly_FS__c group by type__c]){
            if(objref.get('type__c') == 'Offer'){
                covamoFS.add(new Rev_Covamo_FS__c(Type__c = String.valueOf(objref.get('type__c')),Product_Volume__c=Integer.valueOf(objref.get('Vol')),C3_Margin__c =  Decimal.valueOf(String.valueOf(objref.get('Margin'))),NIBIAT__c=Decimal.valueOf(String.valueOf(objref.get('NIBIAT')))));                
            }if(objref.get('type__c') == 'Backstop'){
                covamoFS.add(new Rev_Covamo_FS__c(Type__c = String.valueOf(objref.get('type__c')),Product_Volume__c=Integer.valueOf(objref.get('Vol')),C3_Margin__c =  Decimal.valueOf(String.valueOf(objref.get('Margin'))),NIBIAT__c=Decimal.valueOf(String.valueOf(objref.get('NIBIAT')))));                

            }
        }
        System.debug(covamoFS.size()+'   '+covamoFS);
        insert covamoFS;*/
        
    }
    @AuraEnabled
    public static String FinanceDataSet(String recordId){
        System.debug('recordId   '+recordId);
        List<FinanceProductFSWrapper> fsProds = new List<FinanceProductFSWrapper>();
        List<Rev_Covamo_Yearly_FS__c> fsYearFs = [select id, Year__c, Type__c, volume__c, BDF_Amortization__c, C3_Margin__c, C5_Cash_Contribution__c, C10_NIBIAT_CCS__c, Working_Capital_Movements__c,Net_Cash_Flow__c,Net_Cash_Flow_RT_W_O_Inflation__c,VIR_Denominator__c,Capital_Employed__c,VIR_DENOMINATOR_NPV__c,NPV__C,VIR__c,Average_ROACE__c from Rev_Covamo_Yearly_FS__c Where Rev_Covamo_Header__c=:recordId ORDER BY Year__c ASC];
       // List<Rev_Covamo_FS__c> fsFs = [select id, Type__c, Product_Volume__c, C3_Margin__c,NIBIAT__c from Rev_Covamo_FS__c];
        for(Rev_Covamo_FS__c fsFs : [select id,Type__c,Product_Volume__c,C3_Margin__c,NIBIAT__c,NPV__c,Product_Premium_Price__c,ROACE__c,Unit_C3__c,VIR__c,VIR_DENOMINATOR_NPV__c,Total_C5_Cash_Contribution__c,(select id,RE_Product__r.Name,Expected_Premium_Price_Out__c from Covamo_FS_Products__r) from Rev_Covamo_FS__c  Where Rev_Covamo_Header__c=:recordId]){
           //System.debug(fsFs.Covamo_FS_Products__r);
            list<RE_Covamo_FS_Products__c> prods = new List<RE_Covamo_FS_Products__c>();
            prods = fsFs.Covamo_FS_Products__r;
            fsProds.add(new FinanceProductFSWrapper(fsFs,prods));
        }
        
        FinanceWrapper obj= new FinanceWrapper(fsProds,fsYearFs);
        return JSON.serialize(obj);
    }
    class FinanceWrapper{
        @AuraEnabled
        public List<FinanceProductFSWrapper> covamoFS {get;set;}
        @AuraEnabled
        public List<Rev_Covamo_Yearly_FS__c> covamoYearlyFS {get;set;}
        
        public FinanceWrapper(){}
        public FinanceWrapper(List<FinanceProductFSWrapper> covamoFS,List<Rev_Covamo_Yearly_FS__c> covamoYearlyFS){
            this.covamoFS = covamoFS;
            this.covamoYearlyFS = covamoYearlyFS;
        }
        //@AuraEnabled
        
    }
    class FinanceProductFSWrapper{
        @AuraEnabled
        public Rev_Covamo_FS__c covamoFS {get;set;}
        @AuraEnabled
        public List<RE_Covamo_FS_Products__c> covamoProds {get;set;}
        
        public FinanceProductFSWrapper(){}
        public FinanceProductFSWrapper(Rev_Covamo_FS__c covamoFS,List<RE_Covamo_FS_Products__c> covamoProds){
            this.covamoFS = covamoFS;
            this.covamoProds = covamoProds;
        }
               
    }
    @AuraEnabled
    public static String calculateFinancialSummary(Rev_Covamo_Header__c covHeader, List<Rev_Covamo_Detail__c> covDetails,list<Rev_Covamo_Yearly_FS__c> yearlyFS,list<Rev_Covamo_FS__c> covfs){
        Map<String,String> yearlyFSMap  = new Map<String,String>();
        Map<String,String> covfsMap = new Map<String,String>();
        
       System.debug('yearlyFS 748 =====>'+yearlyFS);
        for(Rev_Covamo_Yearly_FS__c bs: yearlyFS){
            String keyVal = ''+bs.Year__c + bs.Type__c;
            yearlyFSMap.put(keyVal,bs.Id);
        }
        
        for(Rev_Covamo_FS__c bs: covfs){
            String keyVal = ''+ bs.Type__c;
            covfsMap.put(keyVal,bs.Id);
        }
        
        // //list<RE_Covamo_FS_Base__c>,list<Rev_Covamo_Yearly_FS__c>,list<RE_Covamo_FS_Products__c> list<Rev_Covamo_FS__c>
        List<Rev_Covamo_Detail__c> comDetails = new List<Rev_Covamo_Detail__c>();
        Decimal volumsOfr=0;
        Decimal volumsBacks=0;
        if(covHeader != null && covDetails != null){
            //Rev_Covamo_Header__c obj= (Rev_Covamo_Header__c)JSON.deserialize(covHeader, Rev_Covamo_Header__c.class);
           
            //List<covemoWrapper> wrapobjs= (List<covemoWrapper>)JSON.deserialize(covDetails, List<covemoWrapper>.class);
            List<Rev_Covamo_Detail__c> wrpsOffer = new List<Rev_Covamo_Detail__c>();
            List<Rev_Covamo_Detail__c> wrpsBackstop = new List<Rev_Covamo_Detail__c>();
            
			//Date dt= Date.newInstance(Integer.valueOf(covHeader.RE_Valuation_Start_Year__c), System.today().Month(), System.today().day());
			Integer yearDiff = (Integer.valueOf(covHeader.RE_Valuation_End_Year__c) - Integer.valueOf(covHeader.RE_Valuation_Start_Year__c));//).Year(); 
          
            //Integer yearDiff = Integer.valueOf(covHeader.RE_Valuation_End_Year__c) - Integer.valueOf(covHeader.RE_Valuation_Start_Year__c);//(covHeader.Valuation_End_Year__c).Year() - (covHeader.Valuation_Start_Year__c).Year();
            
            for(Rev_Covamo_Detail__c cowrapp : covDetails){
                Rev_Covamo_Detail__c coDetails = new Rev_Covamo_Detail__c();
                coDetails = cowrapp;
                if(coDetails.Type__c == 'Offer'){
                    wrpsOffer.add(coDetails);
                }
                if(coDetails.Type__c == 'Backstop'){
                    wrpsBackstop.add(coDetails);
                }
            }
            if(wrpsOffer.size() != 0){
                System.debug('covHeader ======>'+covHeader);
                System.debug('wrpsOffer 784 ======>'+wrpsOffer);
                System.debug('yearlyFSMap ======>'+yearlyFSMap);
              getFinancialBase(covHeader,wrpsOffer,yearlyFSMap);
            }
            if(wrpsBackstop.size() != 0){
             getFinancialBase(covHeader,wrpsBackstop,yearlyFSMap);
            }
             List<Rev_Covamo_FS__c> covamoFS = new List<Rev_Covamo_FS__c>();
            Integer offCounts = 0;
            Integer backstopCounts = 0;
            for(AggregateResult objref: [select type__c,Count(Id) counts from Rev_Covamo_Yearly_FS__c where Rev_Covamo_Header__c=:covHeader.Id and Average_ROACE__c!=0.00 AND Average_ROACE__c != null group by type__c]){
                if(objref.get('type__c') == 'Offer')
                    offCounts	=	Integer.valueOf(objref.get('counts'));
                if(objref.get('type__c') == 'Backstop')
                    backstopCounts   =	Integer.valueOf(objref.get('counts')); 
            }
        for(AggregateResult objref: [select type__c,sum(volume__c) Vol,sum(C3_Margin__c) Margin,sum(C10_NIBIAT_CCS__c) NIBIAT, sum(NPV__C)NPV, sum(VIR_DENOMINATOR_NPV__c)VIR,SUM(Average_ROACE__c)ROACHE,SUM(C5_Cash_Contribution__c) C5Cash from Rev_Covamo_Yearly_FS__c where Rev_Covamo_Header__c=:covHeader.Id group by type__c]){
            Decimal unit_c3 = Decimal.valueOf(String.valueOf(objref.get('Margin')));//Unit_C3__c
            unit_c3 =   (unit_c3/(Integer.valueOf(objref.get('Vol')))) * cmmdtRef.Conversion_SI__c;
            String idVals=null;
            if(covfsMap.containskey(String.valueOf(objref.get('type__c')))){
               idVals = covfsMap.get(String.valueOf(objref.get('type__c')));
            }
            Decimal roaches= (offCounts != 0 ? (Decimal.valueOf(((((Double.valueOf(objref.get('ROACHE'))))/offCounts))*100)).setScale(2) : 0.00);
            
            if(objref.get('type__c') == 'Offer'){
                covamoFS.add(new Rev_Covamo_FS__c(Id=idVals,Unit_C3__c =unit_c3.setScale(2), Type__c = String.valueOf(objref.get('type__c')),Product_Volume__c=Integer.valueOf(objref.get('Vol')),C3_Margin__c  =  (Decimal.valueOf(String.valueOf(objref.get('Margin')))).setScale(2),NIBIAT__c=(Decimal.valueOf(String.valueOf(objref.get('NIBIAT')))).setScale(2),Rev_Covamo_Header__c = covHeader.Id,NPV__c=(Decimal.valueOf(String.valueOf(objref.get('NPV')))).setScale(2) ,VIR_DENOMINATOR_NPV__c = (Decimal.valueOf(String.valueOf(objref.get('VIR')))).setScale(2),
                                                  VIR__c=(Decimal.valueOf(String.valueOf(objref.get('VIR'))) !=0.00 ? (Math.abs((Decimal.valueOf(String.valueOf(objref.get('NPV')))/Decimal.valueOf(String.valueOf(objref.get('VIR')))).setScale(2))) : 0.00),ROACE__c=roaches, Total_C5_Cash_Contribution__c=(Decimal.valueOf(String.valueOf(objref.get('C5Cash')))).setScale(2)));                
            }if(objref.get('type__c') == 'Backstop'){
               covamoFS.add(new Rev_Covamo_FS__c(Id=idVals,Unit_C3__c =unit_c3.setScale(2),Type__c = String.valueOf(objref.get('type__c')),Product_Volume__c=Integer.valueOf(objref.get('Vol')),C3_Margin__c   =  (Decimal.valueOf(String.valueOf(objref.get('Margin')))).setScale(2),NIBIAT__c=(Decimal.valueOf(String.valueOf(objref.get('NIBIAT')))).setScale(2),Rev_Covamo_Header__c = covHeader.Id,NPV__c=(Decimal.valueOf(String.valueOf(objref.get('NPV')))).setScale(2) , VIR_DENOMINATOR_NPV__c =(Decimal.valueOf(String.valueOf(objref.get('VIR')))).setScale(2), VIR__c=Math.abs((Decimal.valueOf(String.valueOf(objref.get('NPV')))/Decimal.valueOf(String.valueOf(objref.get('VIR')))).setScale(2)),ROACE__c =roaches, Total_C5_Cash_Contribution__c=(Decimal.valueOf(String.valueOf(objref.get('C5Cash')))).setScale(2)));                

            }
        }
        system.debug('seemesh '+covamoFS);
        upsert covamoFS;
        Map<String,String> prodMap = new Map<String,String>();
        for(Rev_Covamo_FS__c fs:covamoFS){            
            prodMap.put(fs.Type__c,fs.Id);
        }
        
        if(wrpsOffer.size() != 0){
            insertProducts_FS(wrpsOffer,prodMap.get('Offer'));
        }
        if(wrpsBackstop.size() != 0){
            insertProducts_FS(wrpsBackstop,prodMap.get('Backstop'));
        }
        
            RE_Covamo_FS_Products__c objProd = new RE_Covamo_FS_Products__c();
            
            for(Rev_Covamo_Detail__c ofr: wrpsOffer){
                
                for(Integer i=0;i<= yearDiff; i++){
                    volumsOfr = volumsOfr + ofr.Volume__c ;
                }
                objProd.RE_Product__c           =   ofr.RE_Product__c;
                objProd.RE_Product_Volume__c    =   ofr.Volume__c;
                
            }
            //Insert 
            for(Rev_Covamo_Detail__c ofr: wrpsBackstop){
                
                for(Integer i=0;i<= yearDiff; i++){
                    volumsBacks = volumsBacks + ofr.Volume__c ;
                }
            }
            
        }
        
        financialWrapper finObj = new financialWrapper(volumsOfr,volumsBacks);
        return JSON.serialize(finObj);
    }
    public class financialWrapper{
        @AuraEnabled
        public Decimal Offer { get; set; }
        @AuraEnabled
        public Decimal Backstop { get; set; }
        public financialWrapper(Decimal Offer,Decimal Backstop){
            this.Offer = Offer;
            this.Backstop = Backstop;
        }
    }
    public static void insertProducts_FS(List<Rev_Covamo_Detail__c> fs, String parentIdVals){
        List<RE_Covamo_FS_Products__c> objProd = new List<RE_Covamo_FS_Products__c>();
            
        for(Rev_Covamo_Detail__c ofr: fs){
            /*
            for(Integer i=0;i<= yearDiff; i++){
                volumsOfr = volumsOfr + ofr.Volume__c ;
            }*/
            
            objProd.add(new RE_Covamo_FS_Products__c(RE_Product__c=ofr.RE_Product__c,RE_Product_Volume__c=ofr.Volume__c,RE_Covamo_FS__c=parentIdVals,Expected_Premium_Price_Out__c = (ofr.Expected_Premium_Price_Out__c).setScale(2)));
        }
        
        Database.insert(objProd);
}
    @AuraEnabled
    public static Boolean getCovHeaderRecordTypeName(String recordID){
        System.debug('recordID'+recordID);
        rev_covamo_header__c covHeader = new rev_covamo_header__c ();
        covHeader = [select id,status__c from rev_covamo_header__c where id=:recordID];
        return (covHeader.status__c == 'In-Draft' ? true : false); 
    }
    @AuraEnabled
    public static Boolean getCovamoHeaderQueueUsers(){
        String userId = UserInfo.getUserId();
        Id queueId = [Select Id from Group where type='Queue' and Name='Covamo Header Edit'].Id;
        System.debug('userId'+userId);
        System.debug('queueId'+queueId);
        List<GroupMember> usersInQueue = new List<GroupMember>();
        usersInQueue = [Select Id,UserOrGroupId From GroupMember where GroupId =:queueId];
        Set<Id> userIdsInQueue = new Set<Id>();
        for(Integer i=0;i<usersInQueue.size();i++){
            userIdsInQueue.add(usersInQueue[i].UserOrGroupId);
        }
        System.debug('usersInQueue'+userIdsInQueue);
        if(userIdsInQueue.contains(userId)){
            System.debug('inside if');
        }else{
            System.debug('inside else');
        }
        return (userIdsInQueue.contains(userId) ? true : false); 
    }
        @AuraEnabled
    public static List<re_product__c> fetchValues(){
        List<re_product__c> products = new List<re_product__c>();
        products = [select id, name from re_product__c];
        return products;
    }
    @AuraEnabled
    public static List<RE_Depot_Pricing_Backbone__c> fetchLocations(String productId){
        List<RE_Depot_Pricing_Backbone__c> locationList = new List<RE_Depot_Pricing_Backbone__c>();
        locationList = [select Id,Name,RE_Depot_Name__c,RE_Depot_Name__r.Name,RE_Product_Name__c,RE_Product_Name__r.Name from RE_Depot_Pricing_Backbone__c where RE_Product_Name__c =:productId];
        return locationList;
    }
    @AuraEnabled
    public static List<RE_MY_CostPrice__c> myCostings(String productLocation, String product){
        
        List<prodLocWrapper> locations = (List<prodLocWrapper>) JSON.deserialize(productLocation, List<prodLocWrapper>.class);
        System.debug('productLocation'+locations+product);
        List<RE_MY_CostPrice__c> costs = new List<RE_MY_CostPrice__c>();
        List<String> depots = new List<String>();
        for(Integer i=0;i<locations.size();i++){
            depots.add(locations[i].Location);
        }
            costs = [select id,name,RE_MR_Freight_Cost__c,RE_Oil_Loss__c,RE_Storage_Handling_Cost__c,RE_Breakbulk_Premium__c,RE_Primary_Transport_Cost__c,RE_Depot_Name__r.Name,RE_Product_Name__r.Name,Covamo_MOPS__c,RE_Market_Premium__c,Master_Covamo__c from RE_MY_CostPrice__c where RE_Depot_Name__r.Name In: depots AND RE_Product_Name__r.Name=:product AND recordtype.name='Covamo Malaysia' order by CreatedDate desc limit 50000];
        System.debug('costs'+costs);
        return costs;
    }
    public class prodLocWrapper{
        @AuraEnabled
        public String Location;
        @AuraEnabled
        public String Volume;
    } 
    @AuraEnabled
    public static Covamo_Admin_Setup__c getCovamoMetadata(){
        Covamo_Admin_Setup__c covamoMetadata = new Covamo_Admin_Setup__c();
        covamoMetadata = [select id, Name, Covamo_Detail_ReportId__c, Covamo_FS_ReportId__c, Covamo_Header_ReportId__c, Covamo_Yearly_FS_ReportId__c from Covamo_Admin_Setup__c where  Name = 'Malaysia' LIMIT 1];
    	return covamoMetadata;
    }
    @AuraEnabled
    public static List<covHeaderWrapper> getCovHeaderDetails(){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl'+baseUrl);
        List<Rev_Covamo_Header__c> records = [select Id,Name,Customer_Name__c,Status__c,CreatedBy.Name,CreatedDate,Created_Date__c,Contract_Name__c,Valuation_Start_Year__c,Valuation_End_Year__c,RE_Valuation_Start_Year__c,RE_Valuation_End_Year__c,Inflation_Rate__c,Weighted_Avearge_Percentage__c from Rev_Covamo_Header__c WHERE Status__c='In-Draft' ORDER BY Createddate DESC  LIMIT 50000];
        
        List<covHeaderWrapper> covWrapList = new List<covHeaderWrapper>();
        Boolean isAMshow= getCovamoHeaderQueueUsers();
        for(Integer i=0;i<records.size();i++){
            covHeaderWrapper covWrap = new covHeaderWrapper();
            if(records[i].Status__c == 'In-Draft'){
                covWrap.url = baseUrl+'/lightning/r/Rev_Covamo_Header__c/'+records[i].id+'/edit';
            }else{
                covWrap.url = '';
            }
            covWrap.showdiscard	=	!isAMshow && records[i].Status__c!= 'Discard' ;
            covWrap.covHeaderData = records[i];
            covWrapList.add(covWrap);
        }  
        System.debug('covWrapList---'+covWrapList);
        return covWrapList;
        
    }
    public class covHeaderWrapper{
        @AuraEnabled
        public String url;
        @AuraEnabled
        public Boolean showdiscard;
        @AuraEnabled
        public Rev_Covamo_Header__c covHeaderData;
    }
	 @AuraEnabled(cacheable= true)
    public static List<fetchvalueWrapper> fetchPicklistValue(sObject objInfo, string picklistFieldApi)
    {    
        // fetching picklist values
        schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();
        map<String,Schema.SObjectField> fieldmap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldmap.get(picklistFieldApi).getDescribe().getPicklistValues();
        list<fetchvalueWrapper> objWrapper = new list<fetchvalueWrapper>();
        for(schema.PicklistEntry a: values)
        {
            fetchvalueWrapper ofetchvalueWrapper = new fetchvalueWrapper();
            ofetchvalueWrapper.label = a.getLabel();
            ofetchvalueWrapper.value = a.getValue(); 
            objWrapper.add(ofetchvalueWrapper);
        }
        return objWrapper;
    }
    
    public class fetchvalueWrapper{
        @AuraEnabled public string label {get;set;}
        @AuraEnabled public string value {get;set;}
    }
    
    @AuraEnabled(cacheable= true)
    public static Map<String,list<fetchvalueWrapper>> fetchPicklistArrayValues(String objName, List<String> pickFields){
        Map<String,list<fetchvalueWrapper>> objDataWrapperMap = new map<String,list<fetchvalueWrapper>>();
        if(pickFields.size()>0)
        {
            for(integer i=0;i<pickFields.size();i++)
            {
                List<fetchvalueWrapper> fetchDataWrapperList = new List<fetchvalueWrapper>();
                SObject actObj = (SObject)(Type.forName('Schema.'+ objName).newInstance());  
                fetchDataWrapperList = fetchPicklistValue(actObj,pickFields[i]);
                objDataWrapperMap.put(pickFields[i],fetchDataWrapperList);             
            }          
        }
        System.debug('objDataWrapperMap--'+objDataWrapperMap);
        return objDataWrapperMap;
    }
}