@isTest(SeeAllData = False)
public class RE_PH_CustomerOppsTest {
    
     private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"TotalItems":"1","Status":"01","SHTItems":[{"SfItemShtNo":"SHT - 146960","SfHeaderShtNo":"1-122815","SapMrcItemNo":"101323","SalesPrice":"20.00","RejectionReason":"","QuantityUom":"CBM","Quantity":"10.00","PriceInd":"F","MaterialNo":"400002410","ItemCount":"1","DealCreationTime":"92815","DealCreationDate":"20210212","CurrencyKey":"EUR","CondUnit":"L15","CondType":"YP23","CondPUnt":"100"}],"SfHeaderShtNo":"1-122815","SapSalesContNo":"","SapMrcNo":"320076181-","SalesOrg":"DE01","POType":"TSFP","MsgTxt":"","InstanceURL":"T","ContStartDate":"20210212","ContEndDate":"20210225","Action":"C"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static testmethod void testRE_PH_CustOpsAspriedUC3(){
        testdatacreate();
        //createstgingdata();
          test.startTest();
        RE_PH_ExecuteAutomateJob exajb = new RE_PH_ExecuteAutomateJob();
        exajb.execute(null);         
          
        RE_PH_WeekMonthScheduler wm1 = new RE_PH_WeekMonthScheduler();
        wm1.execute(null);
       test.stopTest();         
        RE_PH_AspriedUC3.createAspriedUC3(true);
        RE_PH_AspriedUC3.createAspriedUC3(false); 
        RE_PH_AspriedUC3.createAspriedUC3(true);
        RE_PH_RPG.midWeekRgpdatagene();
        RE_PH_GPC_Calc.midWeekgpcdatagene();  
        //RE_PH_AspriedUC3.generateM_1Data();
        
    }
    
    public static testmethod void testRE_PH_CustOpsRPGC3(){
        testdatacreate();
        //createstgingdata();
        test.startTest();       
        RE_PH_ExecuteAutomateJob exajb = new RE_PH_ExecuteAutomateJob();
        exajb.execute(null);         
        
        RE_PH_WeekMonthScheduler wm1 = new RE_PH_WeekMonthScheduler();
        wm1.execute(null);
        test.stopTest();         
        RE_PHCustomerDashboard.checkNewContractData();
        RE_PH_AspriedUC3.newContractDataGen();
        RE_PH_RPG.calculateRPGContract(true);
        RE_PH_RPG.calculateRPGContract(false);
        RE_PH_RPG.calculateRPGContract(true);   
        //RE_PH_RPG.updatePBdata
    }
     public static testmethod void testRE_PH_CustOpsGPCuC3(){
        testdatacreate();
        //createstgingdata();
        test.startTest();
        RE_PH_ExecuteAutomateJob exajb = new RE_PH_ExecuteAutomateJob();
        exajb.execute(null);         
        
        RE_PH_WeekMonthScheduler wm1 = new RE_PH_WeekMonthScheduler();
        wm1.execute(null);
        test.stopTest();         
        
        RE_PH_GPC_Calc.creategpc(true);
        RE_PH_GPC_Calc.creategpc(false);    
         RE_PH_CustomerOppsScheduler schdetest = new RE_PH_CustomerOppsScheduler();
         String sch = '0 15 9 * * ? *';
         System.schedule('PH customer Opps test', sch, schdetest);
         RE_PHCustomerOppsM_1Scheduler schM_1 = new RE_PHCustomerOppsM_1Scheduler();         
         System.schedule('PH customer Opps M-1', sch, schM_1);
         
    }
    
    public static testmethod void testRE_DailyPHdata(){
        testdatacreate();
        
        test.startTest();
        RE_Job_Run_Audit__c insertJob = new RE_Job_Run_Audit__c();
        insertJob.RE_Run_Type__c='Automate';
        insertJob.RE_Job_Type__c = 'PH Customer Opps CBU';
        insertJob.RE_User__c=UserInfo.getUserId();
        insertJob.RE_Run_Time__c=DateTime.now();
        insertJob.RE_Job_Run_Count__c = 0;
        insert insertJob;
         
        RE_PH_AspriedUC3.generateDailyPHdata( insertJob);
        RE_Job_Run_Audit__c jrNewPhContract = new RE_Job_Run_Audit__c();
        jrNewPhContract.RE_Run_Time__c = System.now();
        jrNewPhContract.RE_Run_Type__c = 'Automate';
        jrNewPhContract.RE_Job_Type__c = 'New Contract PH Pricing Output';
        jrNewPhContract.RE_User__c = UserInfo.getUserId();
        jrNewPhContract.RE_Job_Run_Count__c = 0;
        
        insert jrNewPhContract;
        test.stopTest();
        RE_PH_AspriedUC3.generateM_1Data();
    }
    public static testmethod void testRE_PHCustomerDashboard(){
        
        testdatacreate();  
        List <REV_Contract_Master__c> contractDtata = new List<REV_Contract_Master__c>();
        contractDtata = RE_PHCustomerDashboard.getNewContracts();
        List<RE_Pricing_Input__c> pricingDatatoday = new List<RE_Pricing_Input__c>();
        pricingDatatoday = [SELECT RE_Plant__c,RE_PlantDesc__c,RE_Material__c,RE_GPCAmnt__c,RE_FixedPrice__c,RE_Start_Date__c,RE_End_Date__c,RE_Type__c
                        FROM RE_Pricing_Input__c ];
        Test.setMock(HttpCalloutMock.class, new RestMock()); 
        test.startTest();
        RE_PH_ExecuteAutomateJob exajb = new RE_PH_ExecuteAutomateJob();
        exajb.execute(null);         
        
        RE_PH_WeekMonthScheduler wm1 = new RE_PH_WeekMonthScheduler();
        wm1.execute(null);
        test.stopTest(); 
        //RE_PHCustomerDashboard.checkNewContractData();
        //RE_PH_AspriedUC3.newContractDataGen();
        RE_PH_AspriedUC3.createAspriedUC3(true);
        RE_PH_RPG.calculateRPGContract(true);
        RE_PH_GPC_Calc.creategpc(true);
        Date dt = System.today(); 
        list<Id> priceBookId = new List<Id>(); 
        Map<id,RT_Price_Book__c> finaldata =new Map<Id,RT_Price_Book__c>(RE_PHCustomerDashboard.getPHpricebookdata(''));
        //List<Id> IdsValues = new list<id>(finaldata.keySet()); 
        List<Id> IdsValues = new List<Id>();
            
        
        RE_PHCustomerDashboard.getFilteredDate(Datetime.now().format('yyyy-MM-dd'),'','');
        list<RE_customerOppWrapper.pricebookdata> listOfData = RE_PHCustomerDashboard.createWrapper(finaldata.values());
        for(RE_customerOppWrapper.pricebookdata wrappbdata : listOfData){
            wrappbdata.finalPrice = '2' ;
            system.debug('--status--'+wrappbdata.approveStatus);
            if(wrappbdata.approveStatus == 'NS')
                IdsValues.add(wrappbdata.id);
        }
        
        RE_PHCustomerDashboard.savePricebook(listOfData, '',IdsValues,Datetime.now().format('yyyy-MM-dd'));
        
        RE_PHCustomerDashboard.submitforApproval(IdsValues);
        RE_PHCustomerDashboard.approveReject(IdsValues , 'Approve');
        RE_PHCustomerDashboard.fetchuserdata();
        RE_PHCustomerDashboard.generateCustomOppdataData();
        RE_PHCustomerDashboard.exportReport(Datetime.now().format('yyyy-MM-dd'),true,'');
        RE_PHCustomerDashboard.exportButtonContr();
        if(!contractDtata.isEmpty() && !pricingDatatoday.isEmpty()){
            RE_PH_RPG.updatePBdata(finaldata.values()[0],pricingDatatoday[0],contractDtata[0]);
            RE_PH_GPC_Calc.updatePBdata(finaldata.values()[0],pricingDatatoday[0],contractDtata[0]);
        }
       
    }
    public static void testdatacreate(){
        //Country Data
        List<Country__c> count = new List<Country__c>();
        Country__c country = RE_UtilityClass.getCountryCode('Philippines');
        count.add(country);       
        
        
        //Location Data
        List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn = RE_UtilityClass.getLocation('PH NMIF','P11','Philippines');
        RE_Location__c loctn1 = RE_UtilityClass.getLocation('PH Anibong','P12','Philippines');
        location.add(loctn);
        location.add(loctn1);
        
        //Product Data
        List<RE_Product__c> prod = new List<RE_Product__c>();
        RE_Product__c product = RE_UtilityClass.getProduct('Kerosene','Philippines','PHP/LTR');
        product.RE_Product_Group__c = 'KERO';
        product.RE_Material__c = '400008602';
        RE_Product__c product1 = RE_UtilityClass.getProduct('LSFO','Philippines','PHP/LTR');
        product.RE_Product_Group__c = 'KERO';
        product.RE_Material__c = '400008601';
        prod.add(product);
        prod.add(product1);
        update prod;
        
        //Fetch Custom Setting Data For Rate
        RE_UtilityClass.fetchRateUnitData();
        
        //Fetch Custom Setting Data For Volume
        RE_UtilityClass.fetchVolumeConversionData();
        
        //Market Quote Data
        List<RE_Market_Quotes__c> mQuotes = new List<RE_Market_Quotes__c>();
        RE_Market_Quotes__c createMQ1  = RE_UtilityClass.getMarketQuotes(3.6560,'USD/BBL','BBL','Kero Premium','D');
        createMQ1.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(3.6560,'USD/BBL','BBL','Small Lot Premium','D');
        createMQ2.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Kero','D');
        createMQ3.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ4  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','MOGAS 92','D');
        createMQ4.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ5  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Gasoil 0.001% S','D');
        createMQ5.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ6  = RE_UtilityClass.getMarketQuotes(357.4658,'USD/TON','TON','Marine FuelOil 180','D');
        createMQ6.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ7  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','ETHANOL','D');
        createMQ7.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ8  = RE_UtilityClass.getMarketQuotes(5.4658,'USD/TON','TON','UCAP RBD CNO','D');
        createMQ8.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ9  = RE_UtilityClass.getMarketQuotes(4.4658,'USD/BBL','BBL','FREIGHT S2P01','D');
        createMQ9.RE_Quote_Type__c = 'Freight';
        mQuotes.add(createMQ1);
        mQuotes.add(createMQ2);
        mQuotes.add(createMQ3);  
        mQuotes.add(createMQ4);
        mQuotes.add(createMQ5);
        mQuotes.add(createMQ6);  
        mQuotes.add(createMQ7);
        mQuotes.add(createMQ8);
        mQuotes.add(createMQ9);  
		update mQuotes;
        
        RE_PH_ExecuteAutomateJob wm2 = new RE_PH_ExecuteAutomateJob();
        wm2.execute(null);
        
        //Forex Rate Data
        List<RE_FX_Rates__c> fRates = new List<RE_FX_Rates__c>();
        RE_FX_Rates__c FXrate2 = RE_UtilityClass.createFXRecordsYday('PHP/USD',43.720,'USD','PHP','Philippines');
        RE_FX_Rates__c FXrate3 = RE_UtilityClass.createFXRecords('PHP/USD',4.3720,'USD','PHP','Philippines','D');
        RE_FX_Rates__c FXrate4 = RE_UtilityClass.createFXRecords('PHP/USD',467.32,'USD','SGD CTS','Philippines','D');
        
        //Depot Pricing Backbone data
        List<RE_Depot_Pricing_Backbone__c> dPricing1 = new List<RE_Depot_Pricing_Backbone__c>();
        RE_Depot_Pricing_Backbone__c dP4 = RE_UtilityClass.createDPBPH('Philippines','PH NMIF','Kerosene','PHP/LTR'); //Blen=50
        dp4.RE_Final_Price_Unit__c = 'PHP/LTR';
        dp4.RE_TH_HCV_Quote1__c = 'Kero';
        dp4.RE_PH_BIO_2__c = 'ETHANOL';
        dp4.RE_PH_BIO_3__c = 'UCAP RBD CNO';
        dp4.RE_TH_HCV_Quote1_Percent__c = 100;
        dp4.RE_Primary_Transport_Cost__c = 15.5;
        dp4.RE_Primary_Transport_Unit__c = 'PHP/LTR';
        dp4.RE_Insurance_Percentage__c = 100;
        dp4.RE_PH_Blend_Percentage__c = 50;
        dp4.RE_PH_Premium__c = 'Kero Premium';
        dp4.RE_Fixed_Premium__c = 65;
        dp4.RE_Primary_Transport_Cost__c = 15.5;
        dp4.RE_PH_Freight_Quote__c = 'FREIGHT S2P01';
        dp4.RE_PH_Bio_Percent__c = 100;
        dp4.RE_PH_BIO_Fixed__c = 45;
        dp4.RE_PH_Freight_Shifting_Cost__c = 15.5;
        dp4.RE_PH_Demurrage__c = 15.5;
        dp4.RE_PH_FLC_Service_Fee__c = 28.23;
        dp4.RE_PH_PT_Percentage__c = 50;
        dp4.RE_PH_MISC_Brokerage_Fee__c = 30;
        dp4.RE_PH_MISC_Hosehandling_Cost__c = 65;
        dp4.RE_PH_MISC_Port_Charges__c = 15.5;
        dp4.RE_PH_MISC_PQ_Cost__c = 23.34;
        dp4.RE_PH_MISC_Shifting_Cost__c = 10.34;
        dp4.RE_PH_MISC_Waterfront_Operations_Cost__c = 67;
        dp4.RE_PH_Terminal_Cost__c = 65;
        dp4.RE_PH_Wharfage_Cost__c = 15.5;
        dp4.RE_PH_Fuel_Marking_Factor__c = 10;
        dp4.RE_PH_MISC_Fuel_Marking_Fee__c = 17;
        dp4.RE_PH_Ocean_Cost__c = 15.5;
        dp4.RE_PH_S_H__c = 30;
        dp4.RE_PH_Wharfage_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Fuel_Marking_Fee_Unit__c = 'PHP/LTR';
        dp4.RE_Fixed_Premium_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Freight_Charges_Unit__c = 'PHP/LTR';
        dp4.RE_PH_BIO_Fixed_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Freight_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Demurrage_Unit__c = 'PHP/LTR';
        dp4.RE_PH_FLC_Service_Fee_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Brokerage_Fee_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Hosehandling_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Port_Charges_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_PQ_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Waterfront_Operations_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Terminal_Cost_Unit__c = 'PHP/LTR';
        System.debug('dPricing1--4'+dPricing1);
        System.debug('dp4--'+dp4.Id);
        dPricing1.add(dp4);
        
        RE_Depot_Pricing_Backbone__c dP2 = new RE_Depot_Pricing_Backbone__c();
        dP2 = RE_UtilityClass.createDPBPH('Philippines','PH Anibong','LSFO','PHP/LTR');//Blen=100
        dp2.RE_Final_Price_Unit__c = 'PHP/LTR';
        dp2.RE_Depot_Name__c = null;
        dp2.RE_TH_HCV_Quote1__c = 'Kero';
        dp2.RE_TH_HCV_Quote1_Percent__c = 100;
        dp2.RE_Primary_Transport_Cost__c = 15.5;
        dp2.RE_Primary_Transport_Unit__c = 'PHP/LTR';
        dp2.RE_Insurance_Percentage__c = 100;
        dp2.RE_PH_Blend_Percentage__c = 50;
        dp2.RE_PH_Premium__c = 'Kero Premium';
        dp2.RE_Fixed_Premium__c = 65;
        dp2.RE_Primary_Transport_Cost__c = 15.5;
        dp2.RE_PH_Freight_Quote__c = 'FREIGHT S2P01';
        dp2.RE_PH_Bio_Percent__c = 100;
        dp2.RE_PH_BIO_Fixed__c = 45;
        dp2.RE_PH_Freight_Shifting_Cost__c = 15.5;
        dp2.RE_PH_Demurrage__c = 15.5;
        dp2.RE_PH_FLC_Service_Fee__c = 28.23;
        dp2.RE_PH_PT_Percentage__c = 100;
        dp2.RE_PH_MISC_Brokerage_Fee__c = 30;
        dp2.RE_PH_MISC_Hosehandling_Cost__c = 65;
        dp2.RE_PH_MISC_Port_Charges__c = 15.5;
        dp2.RE_PH_MISC_PQ_Cost__c = 23.34;
        dp2.RE_PH_MISC_Shifting_Cost__c = 10.34;
        dp2.RE_PH_MISC_Waterfront_Operations_Cost__c = 67;
        dp2.RE_PH_Terminal_Cost__c = 65;
        dp2.RE_PH_Wharfage_Cost__c = 15.5;
        dp2.RE_PH_Fuel_Marking_Factor__c = 10;
        dp2.RE_PH_MISC_Fuel_Marking_Fee__c = 17;
        dp2.RE_PH_Ocean_Cost__c = 15.5;
        dp2.RE_PH_S_H__c = 23.34;
        dp2.RE_PH_Wharfage_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Fuel_Marking_Fee_Unit__c = 'PHP/LTR';
        dp2.RE_Fixed_Premium_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Freight_Charges_Unit__c = 'PHP/LTR';
        dp2.RE_PH_BIO_Fixed_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Freight_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Demurrage_Unit__c = 'PHP/LTR';
        dp2.RE_PH_FLC_Service_Fee_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Brokerage_Fee_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Hosehandling_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Port_Charges_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_PQ_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Waterfront_Operations_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Terminal_Cost_Unit__c = 'PHP/LTR';
        System.debug('dPricing1--2'+dPricing1);
        System.debug('dp2--'+dp2.Id);
        dPricing1.add(dP2);
        
        RE_Depot_Pricing_Backbone__c dP3 = new RE_Depot_Pricing_Backbone__c();
        dP3 = RE_UtilityClass.createDPBPH('Philippines','PH NMIF','Kerosene','PHP/LTR');//Blen=50
        dp3.RE_Final_Price_Unit__c = 'PHP/LTR';
        dp3.RE_TH_HCV_Quote1__c = 'Kero';
        dp3.RE_TH_HCV_Quote1_Percent__c = 100;
        dp3.RE_Primary_Transport_Cost__c = 15.5;
        dp3.RE_Primary_Transport_Unit__c = 'PHP/LTR';
        dp3.RE_Insurance_Percentage__c = 100;
        dp3.RE_PH_Blend_Percentage__c = 50;
        dp3.RE_PH_Premium__c = 'Kero Premium';
        dp3.RE_Fixed_Premium__c = 65;
        dp3.RE_Primary_Transport_Cost__c = 15.5;
        dp3.RE_PH_Freight_Quote__c = 'FREIGHT S2P01';
        dp3.RE_PH_Bio_Percent__c = 100;
        dp3.RE_PH_BIO_Fixed__c = 45;
        dp3.RE_PH_Freight_Shifting_Cost__c = 15.5;
        dp3.RE_PH_Demurrage__c = 15.5;
        dp3.RE_PH_FLC_Service_Fee__c = 28.23;
        dp3.RE_PH_PT_Percentage__c = 50;
        dp3.RE_PH_MISC_Brokerage_Fee__c = 30;
        dp3.RE_PH_MISC_Hosehandling_Cost__c = 65;
        dp3.RE_PH_MISC_Port_Charges__c = 15.5;
        dp3.RE_PH_MISC_PQ_Cost__c = 23.34;
        dp3.RE_PH_MISC_Shifting_Cost__c = 10.34;
        dp3.RE_PH_MISC_Waterfront_Operations_Cost__c = 67;
        dp3.RE_PH_Terminal_Cost__c = 65;
        dp3.RE_PH_Wharfage_Cost__c = 15.5;
        dp3.RE_PH_Fuel_Marking_Factor__c = 10;
        dp3.RE_PH_MISC_Fuel_Marking_Fee__c = 17;
        dp3.RE_PH_Ocean_Cost__c = 15.5;
        dp3.RE_PH_S_H__c = 23.34;
        dp3.RE_PH_Wharfage_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Fuel_Marking_Fee_Unit__c = 'PHP/LTR';
        dp3.RE_Fixed_Premium_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Freight_Charges_Unit__c = 'PHP/LTR';
        dp3.RE_PH_BIO_Fixed_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Freight_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Demurrage_Unit__c = 'PHP/LTR';
        dp3.RE_PH_FLC_Service_Fee_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Brokerage_Fee_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Hosehandling_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Port_Charges_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_PQ_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Waterfront_Operations_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Terminal_Cost_Unit__c = 'PHP/LTR';
        System.debug('dPricing1--3'+dPricing1);
        System.debug('dp3--'+dp3.Id);
        dPricing1.add(dP3);
        
        System.debug('dPricing1--'+dPricing1);
        update dPricing1;
        
        RE_PH_ExecuteAutomateJob exajb = new RE_PH_ExecuteAutomateJob();
        RE_Job_Run_Audit__c jrAuditTH = new RE_Job_Run_Audit__c();
        jrAuditTH.RE_Run_Time__c = System.now();
        jrAuditTH.RE_Run_Type__c = 'Automate';
        jrAuditTH.RE_Job_Type__c = 'New Contract PH Pricing Output';
        jrAuditTH.RE_User__c = UserInfo.getUserId();
        jrAuditTH.RE_Job_Run_Count__c = 0;
        
        //insert jrAuditTH;
        
        
          //create customer 
        List <Account> customer = new List<Account>();
        Id accountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution PH').getRecordTypeId();
        customer.add(RE_UtilityClass.createcustomer('Direct Sold To','Sold To','123456','Direct','',accountRecordType));
        customer.add(RE_UtilityClass.createcustomer('Direct Ship To','Ship To','12345699','Direct',customer[0].id,accountRecordType));
        
        customer.add(RE_UtilityClass.createcustomer('Direct Sold To','Sold To','123456','Direct','',accountRecordType));
        customer.add(RE_UtilityClass.createcustomer('Direct Ship To','Ship To','12345699','Direct',customer[2].id,accountRecordType));
        
        customer.add(RE_UtilityClass.createcustomer('Direct Sold To','Sold To','123456','Direct','',accountRecordType));
        customer.add(RE_UtilityClass.createcustomer('Direct Ship To','Ship To','12345699','Direct',customer[4].id,accountRecordType));
        
        List<REV_Contract_Master__c> contracts = new List<REV_Contract_Master__c>();
        contracts.add(new REV_Contract_Master__c(RE_Customer_Name__c = customer[1].id,RE_Calculation_Type__c = 'GPC' ,RT_Plant_Desc__c = location[0].id, Country_Name__c = 'PH',RT_CONDITION_TABLE_ID__c='603',
                                                 RT_Material_Desc__c = prod[0].id, Active__c = true,RT_Valid_From__c= system.today(),RT_Valid_To__c = system.today().addMonths(3),
                                                 RE_Reference_Period__c = 'D-1' , RE_PH_Approval_Scheme__c='Margin_OCLS_CF_AGO_Other Sector',RE_Prev_Week_Price__c=23.78 ,RE_Secondary_Transport_Cost__c = 0.2));
         contracts.add(new REV_Contract_Master__c(RE_Customer_Name__c = customer[3].id,RE_Calculation_Type__c = 'RPG' ,RT_Plant_Desc__c = location[0].id, Country_Name__c = 'PH',RT_CONDITION_TABLE_ID__c='604',
                                                 RT_Material_Desc__c = prod[1].id, Active__c = true,RT_Valid_From__c= system.today(),RT_Valid_To__c = system.today().addMonths(3),
                                                 RE_Reference_Period__c = 'M-1' , RE_PH_Approval_Scheme__c='Margin_OCLS_CF_AGO_Other Sector',RE_Prev_Week_Price__c=23.78,RE_Secondary_Transport_Cost__c = 0.2));
         contracts.add(new REV_Contract_Master__c(RE_Customer_Name__c = customer[5].id,RE_Calculation_Type__c = 'Aspired Margin' ,RT_Plant_Desc__c = location[1].id, Country_Name__c = 'PH',RT_CONDITION_TABLE_ID__c='610',
                                                 RT_Material_Desc__c = prod[0].id, Active__c = true,RT_Valid_From__c= system.today(),RT_Valid_To__c = system.today().addMonths(3),
                                                 RE_Reference_Period__c = 'W-1' , RE_PH_Approval_Scheme__c='Margin_OCLS_CF_AGO_Other Sector',RE_Prev_Week_Price__c=23.78,RE_Secondary_Transport_Cost__c = 0.2));
         contracts.add(new REV_Contract_Master__c(RE_Customer_Name__c = customer[5].id,RE_Calculation_Type__c = 'Manual' ,RT_Plant_Desc__c = location[1].id, Country_Name__c = 'PH',RT_CONDITION_TABLE_ID__c='611',
                                                 RT_Material_Desc__c = prod[1].id, Active__c = true,RT_Valid_From__c= system.today(),RT_Valid_To__c = system.today().addMonths(3),
                                                 RE_Reference_Period__c = 'M-1' , RE_PH_Approval_Scheme__c='Margin_OCLS_CF_AGO_Other Sector',RE_Prev_Week_Price__c=23.78,RE_Secondary_Transport_Cost__c = 0.2));
         contracts.add(new REV_Contract_Master__c(RE_Customer_Name__c = customer[5].id,RE_Calculation_Type__c = 'RPG' ,RT_Plant_Desc__c = location[1].id, Country_Name__c = 'PH',RT_CONDITION_TABLE_ID__c='611',
                                                 RT_Material_Desc__c = prod[1].id, Active__c = true,RT_Valid_From__c= system.today(),RT_Valid_To__c = system.today().addMonths(3),
                                                 RE_Reference_Period__c = 'W-1' , RE_PH_Approval_Scheme__c='Margin_OCLS_CF_AGO_Other Sector',RE_Prev_Week_Price__c=23.78,RE_Secondary_Transport_Cost__c = 0.2));
        
        
        insert contracts;
        
        Id ApprovalRecordType = Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByDeveloperName().get('RE_Approval_Process').getRecordTypeId();
        List<RT_Setting__c> phApprovalProcess = new List<RT_Setting__c>();
        phApprovalProcess.add(new RT_Setting__c ( Name = 'Margin_OCLS_CF_AGO_Other Sector',RE_User_Name__c = UserInfo.getUserId() , RE_Approver_Role_1__c= 'STL' , 
        											RE_Approver_Role_2__c = 'T&S Pricing Manager' ,RE_Delegate_Approver__c= UserInfo.getUserId() ,RE_Max_Margin__c =1000 ,
        											RE_Min_Margin__c =1.55 ,RecordTypeId = ApprovalRecordType ,RE_Approval_Status__c ='Auto Approved', Country__c = 'PH'));
        phApprovalProcess.add(new RT_Setting__c ( Name = 'Margin_OCLS_CF_AGO_Other Sector',RE_User_Name__c = UserInfo.getUserId() , RE_Approver_Role_1__c= 'STL' , Country__c = 'PH', 
        											RE_Max_Margin__c =0.85 ,RE_Min_Margin__c =0.40 ,RecordTypeId = ApprovalRecordType ,RE_Approval_Status__c ='Not Submitted'));
        phApprovalProcess.add(new RT_Setting__c ( Name = 'Margin_OCLS_CF_AGO_Other Sector',RE_User_Name__c = UserInfo.getUserId() , RE_Approver_Role_1__c= 'STL' ,  Country__c = 'PH',
        											RE_Approver_Role_2__c = 'T&S Pricing Manager' ,RE_Delegate_Approver__c= UserInfo.getUserId() ,RE_Max_Margin__c =0.45 ,
        											RE_Min_Margin__c =0.00 ,RecordTypeId = ApprovalRecordType ,RE_Approval_Status__c ='Not Submitted'));
        phApprovalProcess.add(new RT_Setting__c ( Name = 'Margin_OCLS_CF_AGO_Other Sector',RE_User_Name__c = UserInfo.getUserId() , RE_Approver_Role_1__c= 'STL' , Country__c = 'PH', 
        											RE_Approver_Role_2__c = 'T&S Pricing Manager' ,RE_Delegate_Approver__c= UserInfo.getUserId() ,RE_Max_Margin__c =0.00 ,
        											RE_Min_Margin__c =-1000 ,RecordTypeId = ApprovalRecordType ,RE_Approval_Status__c ='Rejected'));
        
        insert phApprovalProcess;
        
        RE_GSAP_Upload__c gsapMalaysia = new RE_GSAP_Upload__c();
        gsapMalaysia.Name = 'Philippines';
        gsapMalaysia.RE_GSAP_Upload__c = true;
        
        insert gsapMalaysia;
        
         List<RE_Pricing_Input_STG__c> stglist = new List<RE_Pricing_Input_STG__c>();
        Id gpcrectypeId = Schema.SObjectType.RE_Pricing_Input_STG__c.getRecordTypeInfosByName().get('GPC_Data').getRecordTypeId() ;
        Id rpgrectypeId = Schema.SObjectType.RE_Pricing_Input_STG__c.getRecordTypeInfosByName().get('RPG_Data').getRecordTypeId() ;
        Id tierrectypeId = Schema.SObjectType.RE_Pricing_Input_STG__c.getRecordTypeInfosByName().get('Tier_Data').getRecordTypeId() ;
        RE_Pricing_Input_STG__c stg1 = new RE_Pricing_Input_STG__c(recordtypeID = gpcrectypeId,RE_Material__c = '12323123',
                                                                   RE_GPCAmnt__c = 2,RE_Start_Date__c= System.today(),RE_End_Date__c = System.today(),RE_Is_Processed__c = false);
        RE_Pricing_Input_STG__c stg2 = new RE_Pricing_Input_STG__c(recordtypeID = tierrectypeId,RE_Material__c = '12323123',RE_ShipTo__c='2112122',RE_SoldTo__c='232333',RE_Is_Processed__c = false,
                                                                   RE_Plant__c = 'p102',RE_TierAmnt__c= '1',RE_CurrentCnfgTierAmnt__c = '2',RE_IsConfig__c = true,RE_IsDifferent__c = true);
        RE_Pricing_Input_STG__c stg3 = new RE_Pricing_Input_STG__c(recordtypeID = rpgrectypeId,RE_Material__c = '12323123',RE_PlantDesc__c='fdfdsfd',RE_Is_Processed__c = false,
                                                                   RE_FixedPrice__c='56',RE_Plant__c = 'p102',RE_Start_Date__c= System.today(),RE_End_Date__c = System.today());
        stglist.add(stg1);
        stglist.add(stg2);
        stglist.add(stg3);
        insert stglist;
        RE_PricingInputScheduler pis = new RE_PricingInputScheduler();
        pis.execute(null);
        
         List<RE_CustomOpps_ReportConfiguration__c> reportConfig = new List<RE_CustomOpps_ReportConfiguration__c>();
        reportConfig.add(new RE_CustomOpps_ReportConfiguration__c (Name = 'PHCRC-001' , RE_Is_Active__c= true,RE_Country_Name__c = 'Philippines',RE_Data_Type__c = 'RE_Final_Price_Rebate__c',
                                                                  RE_Application__c='V',RE_Calculation_Type__c='C',RE_Condition_Table__c='603',RE_Varkey__c='PH01+000000000',RE_Quantity__c = '100'));
        reportConfig.add(new RE_CustomOpps_ReportConfiguration__c (Name = 'PHCRC-002' , RE_Is_Active__c= true,RE_Country_Name__c = 'Philippines',RE_Data_Type__c = 'RE_Final_Price_Rebate__c',
                                                                  RE_Application__c='V',RE_Calculation_Type__c='C',RE_Condition_Table__c='604',RE_Varkey__c='PH01+000000000',RE_Quantity__c = '100'));
        reportConfig.add(new RE_CustomOpps_ReportConfiguration__c (Name = 'PHCRC-003' , RE_Is_Active__c= true,RE_Country_Name__c = 'Philippines',RE_Data_Type__c = 'RE_Final_Price_Rebate__c',
                                                                  RE_Application__c='V',RE_Calculation_Type__c='C',RE_Condition_Table__c='610',RE_Varkey__c='PH01+000000000',RE_Quantity__c = '100'));
        reportConfig.add(new RE_CustomOpps_ReportConfiguration__c (Name = 'PHCRC-004' , RE_Is_Active__c= true,RE_Country_Name__c = 'Philippines',RE_Data_Type__c = 'RE_Final_Price_Rebate__c',
                                                                  RE_Application__c='V',RE_Calculation_Type__c='C',RE_Condition_Table__c='611',RE_Varkey__c='PH01+000000000',RE_Quantity__c = '100'));
        insert reportConfig;
        
        List<RE_Pricing_Input__c> prcingInput = new List<RE_Pricing_Input__c>();
        prcingInput.add(new RE_Pricing_Input__c(RE_Start_Date__c = system.today() ,RE_End_Date__c = system.today() ,RE_Type__c = 'GPC' ,RE_Material__c ='400008602' ,RE_Plant__c = 'P11' ,RE_GPCAmnt__c = 1.23));
        prcingInput.add(new RE_Pricing_Input__c(RE_Start_Date__c = system.today() ,RE_End_Date__c = system.today() ,RE_Type__c = 'RPG' ,RE_Material__c ='400008602' ,RE_Plant__c = 'P11' ,RE_GPCAmnt__c = 49));
        insert  prcingInput;   
        
       
    }
}