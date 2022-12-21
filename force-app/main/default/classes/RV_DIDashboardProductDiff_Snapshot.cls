/***********************************************************************************
 * Created By   : Dhriti Krishna Ghosh Moulick
 * Created Date : 04/09/2018
 * Description  : 1.This batch will run every morning 8 am, fetch the product differential with
 * 				  record type dashboard and create the snapshot of same with snapshot record type.
 * 				  2. Create product Differential records with following fields : a.Cargo, b.prev Day,c.Barge,d.prev Day Data.
 * 				     a.Cargo - Price Difference of Quote Name
 * 					 b.Barge - Price Difference of Quote Name
 * 					 c.prev Day Cargo - Cargo Value Today - Cargo Value Yesterday
 * 					 d.prev Day Barge - Barge Value Today - Barge Value Yesterday
 * Last Modified By:
 * Last Modified Date :
 * *********************************************************************************/
global class RV_DIDashboardProductDiff_Snapshot implements Database.Batchable<sObject>{
    public static String snapShotRecId;
    //START - Rahul Sharma | Date - 16-Jun-20 :  Added LCO, LGO and RBOB quotes
    public static final String iceLgoQuoteName = Label.RV_ICE_LGO_Quote_Name;
    public static final String  iceLcoQuoteName = Label.RV_ICE_LCO_Quote_Name;
    public static final String iceRbobQuoteName = Label.RV_ICE_RBOB_Quote_Name;
    //END - Rahul Sharma | Date - 16-Jun-20 :  Added LCO, LGO and RBOB quotes
    
	global Database.QueryLocator start(Database.BatchableContext BC){
        String recTypeId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
		String query = 'Select Id,Name,Barges__c,Cargoes__c,Price__c from Product_Differential__c '+
            		   'where RecordTypeId =\''+ ''+recTypeId+'\''; // fetching records from product differential with record Type Dashboard
        System.debug('-------'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Product_Differential__c> prdctDiffLst){
        
        /**************Snapshot Logic ********************/
        snapShotRecId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Snapshot').getRecordTypeId();
		List<Product_Differential__c> rdSnapshotList = new List<Product_Differential__c>();  
        for(Product_Differential__c sObj : prdctDiffLst){
            Product_Differential__c rd = new Product_Differential__c();//(Product_Differential__c)sObj;
            //START - Rahul Sharma | Date - 16-Jun-20 :  Updated logic to save 8:00 am values for Live Euro to USD, ICE Price Live USD/to, Brent Live USD/bbl and RBOB live cnt/gal records
            //if(sObj.Name == RV_ProductDifferentialHelper.AGOQuoteName){
            if(sObj.Name == iceLgoQuoteName){
                sObj.Display_Name__c = Label.RV_ICE_Today_8_00_0_clock;
                sObj.Frequency__c = 'Daily';
                sObj.Column__c = 'Left1';
            //}else if(sObj.Name == RV_ProductDifferentialHelper.MOGAS1QuoteName){
            }else if(sObj.Name == iceLcoQuoteName){
				sObj.Display_Name__c = Label.RV_Brent_today_8_00_o_clock;   
                sObj.Frequency__c = 'Daily';
                sObj.Column__c = 'Right1';
            //}else if(sObj.Name == RV_ProductDifferentialHelper.MOGAS2QuoteName){
            }else if(sObj.Name == iceRbobQuoteName){
                sObj.Display_Name__c = Label.RV_RBOB_today_8_00_o_clock;
                sObj.Frequency__c = 'Daily';
                sObj.Column__c = 'Right2';
            //END - Rahul Sharma | Date - 16-Jun-20 :  Updated logic to save 8:00 am values for Live Euro to USD, ICE Price Live USD/to, Brent Live USD/bbl and RBOB live cnt/gal records
            }else if(sObj.Name == RV_ProductDifferentialHelper.euroUSDCurrency){
                sObj.Display_Name__c = Label.RV_Euro_to_USD_Value;
                sObj.Frequency__c = 'Daily';
                sObj.Column__c = 'Left2';
            }
            //START - Rahul Sharma | Date - 20-Aug-20 :  Added 8 am values for AGO and MOGAS HCV
            else if(sObj.Name == RV_ProductDifferentialHelper.agoIgoHcvLive){
                sObj.Name = RV_ProductDifferentialHelper.agoIgoHcv8AM;
                sObj.Display_Name__c = RV_ProductDifferentialHelper.agoIgoHcv8AM;
                sObj.Frequency__c = 'Daily';
            }
            else if(sObj.Name == RV_ProductDifferentialHelper.mogasHcvLive){
                sObj.Name = RV_ProductDifferentialHelper.mogasHcv8AM;
                sObj.Display_Name__c = RV_ProductDifferentialHelper.mogasHcv8AM;
                sObj.Frequency__c = 'Daily';
            }
            //END - Rahul Sharma | Date - 20-Aug-20 :  Added 8 am values for AGO and MOGAS HCV
            rd = sObj.clone(false,false,false,false);
            rd.RecordTypeId = snapShotRecId;
            rdSnapshotList.add(rd);
        }
        System.debug('-------rdSnapshotList----'+rdSnapshotList);
        /************** Product Differential Logic ********************/
        List<ProductDifferentialDashboard__mdt> prodctDiffmetadataLst = [select id,Plant_Code__c,Quote_Name1__c,Quote_Type__c,
                                                                         Quote_Name2__c,Quote_Name3__c,Quote_Name4__c,
                                                                         MasterLabel,DeveloperName,Type__c from 
                                                                         ProductDifferentialDashboard__mdt]; // Fetch All the product Differential Name from metadata
        Map<String,List<ProductDifferentialDashboard__mdt>> prctDiffName = new Map<String,List<ProductDifferentialDashboard__mdt>>();
        Set<String> quoteName = new Set<String>();
        for(ProductDifferentialDashboard__mdt quote : prodctDiffmetadataLst){ // fetching quote name from custom metadata
            if(quote.Type__c == 'Product Differential'){
                if(!prctDiffName.containsKey(quote.MasterLabel)){
                	prctDiffName.put(quote.MasterLabel, new List<ProductDifferentialDashboard__mdt>{quote});
            	}else{
                    List<ProductDifferentialDashboard__mdt> marginDtaLst = prctDiffName.get(quote.MasterLabel);
                    marginDtaLst.add(quote);
                    prctDiffName.put(quote.MasterLabel,marginDtaLst);
            	}
            }else if(quote.Type__c == 'Quote Name'){
                quoteName.add(quote.Quote_Name1__c);
            }
        } 
         System.debug('-------prctDiffName----'+prctDiffName);
         System.debug('-------quoteName----'+quoteName);
        List<Product_Differential__c> prodctDiffLst = [select Id, Name,RecordTypeId, Cargoes__c, prev_Day_Barge__c, 
                                                       Barges__c, prev_Day_Cargo__c, Price__c FROM Product_Differential__c
                                                       where CreatedDate = YESTERDAY AND RecordTypeId=:snapShotRecId AND
                                                       Name in:prctDiffName.keyset()]; // Fetch yesterdays Product
        												//differential with Record Type Snapshot
        Map<String,Product_Differential__c> productDiffMap = new Map<String,Product_Differential__c>();
        for(Product_Differential__c prdctDiff : prodctDiffLst){
            productDiffMap.put(prdctDiff.Name, prdctDiff); // Map of Product Differential Name as key and values
        }
        System.debug('-------productDiffMap----'+productDiffMap);
        // Fetch  Quote Name woth RT Dashboard used for calculation for production differential barge and cargo
        String recTypeId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
        List<Product_Differential__c> prodctDiffQuoteLst = [select Id,Name,Display_Name__c, RecordTypeId, Cargoes__c, prev_Day_Barge__c, 
                                                       Barges__c, prev_Day_Cargo__c, Price__c FROM Product_Differential__c
                                                       where RecordTypeId=:recTypeId AND Display_Name__c in:quoteName]; 
        Map<String,Product_Differential__c> productDiffMapQuote = new Map<String,Product_Differential__c>();
        for(Product_Differential__c prdctDiff : prodctDiffQuoteLst){
            productDiffMapQuote.put(prdctDiff.Display_Name__c, prdctDiff); // Map of Product Differential Name as key and values
        }
        System.debug('-------productDiffMapQuote----'+productDiffMapQuote);
        //Fetching BIO AMV Record
        Set<String> plantCodeSet = new Set<String>{'D228','D229'};
        List<Bio_AMVs__c> bioAMVLst = [SELECT id,Plant_Code__c,AGO_B7_m_Prompt__c,ULG_95_E5_m_Prompt__c from Bio_AMVs__c 
                                       where Plant_Code__c in:plantCodeSet];
        Map<String,Bio_AMVs__c> bioAMVMap = new Map<String,Bio_AMVs__c>();
        for(Bio_AMVs__c bioAMV : bioAMVLst){
            bioAMVMap.put(bioAMV.Plant_Code__c,bioAMV);
        }
        System.debug('-------bioAMVMap----'+bioAMVMap);
        if(!prctDiffName.isEmpty()){
            for(String prdctDiff : prctDiffName.keyset()){
				Product_Differential__c rd = new Product_Differential__c();
                rd.Name = prdctDiff;
                rd.Display_Name__c = prdctDiff;
                rd.RecordTypeID = snapShotRecId;
                if(prctDiffName.containskey(prdctDiff)){
                    List<ProductDifferentialDashboard__mdt> prdctDiffLsts = prctDiffName.get(prdctDiff);
                    for(ProductDifferentialDashboard__mdt prdctDif : prdctDiffLsts){
                            Decimal quote1Price = 0;
                            Decimal quote2Price = 0;
                            Decimal quote3Price = 0;
                            Decimal quote4Price = 0;
                            if(productDiffMapQuote.containskey(prdctDif.Quote_Name1__c)){
                                quote1Price =  productDiffMapQuote.get(prdctDif.Quote_Name1__c).price__c;
                            }
                       	    if(productDiffMapQuote.containskey(prdctDif.Quote_Name2__c)){
                            	quote2Price =  productDiffMapQuote.get(prdctDif.Quote_Name2__c).price__c;
                        	}
                        	if(productDiffMapQuote.containskey(prdctDif.Quote_Name3__c)){
                            	quote3Price =  productDiffMapQuote.get(prdctDif.Quote_Name3__c).price__c;
                        	}
                        	if(productDiffMapQuote.containskey(prdctDif.Quote_Name4__c)){
                            	quote4Price =  productDiffMapQuote.get(prdctDif.Quote_Name4__c).price__c;
                            }
                            if(prdctDiff == Label.RV_HEL_50ppm_USD_Ton){
                                if(prdctDif.Quote_Type__c == 'Barge'){
                                    rd.Barges__c = quote1Price - quote2Price;
                                }
                                if(prdctDif.Quote_Type__c == 'Cargo'){
                                    rd.Cargoes__c = quote1Price + (quote2Price - quote3Price ) - quote4Price;
                                }
                                
                            }
                            if(prdctDiff == Label.RV_HEL_1000ppm_USD_Ton){
                                if(prdctDif.Quote_Type__c == 'Barge'){
                                    rd.Barges__c = quote1Price - quote2Price;
                                }
                            }
                            if(prdctDiff == Label.RV_DK_USE_Ton){
                                if(prdctDif.Quote_Type__c == 'Barge'){
                                    rd.Barges__c = quote1Price - quote2Price;
                                }
                                if(prdctDif.Quote_Type__c == 'Cargo'){
                                    rd.Cargoes__c = quote1Price - quote2Price;
                                }
                            }
                            if(prdctDiff == Label.RV_AGO_IGO_Diff_USD_Ton){
                                rd.Barges__c  = (quote1Price - quote2Price) - 
                                                (quote3Price - quote4Price);
                            }
                            if(prdctDiff == 'OK (Eurobob)'){
                            }
                            if(prdctDiff == 'OK (98 RON)'){
                            }
                            if(prdctDiff == 'Mogas Diff D-1 (Brent / RBOB)'){
                            }
                            if(prdctDiff == Label.RV_Bio_B7_CBM){
                                if(prdctDif.Quote_Type__c == 'Barge'){
                                    rd.Barges__c = bioAMVMap.get(prdctDif.Plant_Code__c).AGO_B7_m_Prompt__c; 
                                }
                                if(prdctDif.Quote_Type__c == 'Cargo'){
                                    rd.Cargoes__c = bioAMVMap.get(prdctDif.Plant_Code__c).AGO_B7_m_Prompt__c; 
                                }
                            }
                            if(prdctDiff == Label.RV_Bio_E5_CBM){
                                if(prdctDif.Quote_Type__c == 'Barge'){
                                    rd.Barges__c = bioAMVMap.get(prdctDif.Plant_Code__c).ULG_95_E5_m_Prompt__c; 
                                }
                                if(prdctDif.Quote_Type__c == 'Cargo'){
                                    rd.Cargoes__c = bioAMVMap.get(prdctDif.Plant_Code__c).ULG_95_E5_m_Prompt__c; 
                                }
                        	}
                    }
                    if(productDiffMap.containsKey(rd.Name)){ // Yesterday's Quote Name
                        System.debug('-------rd.Barges__c----'+rd.Barges__c);
                        System.debug('-------rd.Cargoes__c----'+rd.Cargoes__c);
                        if(rd.Barges__c == null)rd.Barges__c=0;
                        if(rd.Cargoes__c == null)rd.Cargoes__c=0;
                        if(productDiffMap.get(rd.Name).Barges__c == null)productDiffMap.get(rd.Name).Barges__c=0;
                        if(productDiffMap.get(rd.Name).Cargoes__c == null)productDiffMap.get(rd.Name).Cargoes__c=0;
                        rd.prev_Day_Barge__c = rd.Barges__c - productDiffMap.get(rd.Name).Barges__c;
                        rd.prev_Day_Cargo__c = rd.Cargoes__c -productDiffMap.get(rd.Name).Cargoes__c;
                    }
                    rdSnapshotList.add(rd); // Todays Product Differential Data(Product Differential Name,Barges,prev Day Barge,Cargoes, Prev Day Cargo)
                }
            }
        }
        System.debug('-------rdSnapshotList----'+rdSnapshotList);
        if(!rdSnapshotList.isEmpty()){
                Database.SaveResult  [] cr = Database.insert(rdSnapshotList, false);
                system.debug('Success ------->' + cr);
                for (Database.SaveResult  sr : cr) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted Product Differential Snapshot: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            RV_ClassException.getInstance();
                            RV_ClassException.insertExceptionRecord(String.valueof(err.getStatusCode()), err.getMessage(), 'RV_DIDashboardProductDiff_Snapshot', 'execute','Exception');
                        }
                    }
                }
        }
    }
    global void finish(Database.BatchableContext BC){
    }
}