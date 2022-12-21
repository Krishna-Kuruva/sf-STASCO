public class RE_MY_RecoverySalesTaxController { 
    public Map<String, String> prodMap = new Map<String, String>();    
    public RE_MY_RecoverySalesTaxController(){}
    //Constructor to fetch latest Sales Tax data
    public RE_MY_RecoverySalesTaxController(List<RE_Product__c> productlist){
        List<RE_Sales_Tax__c> salestaxdata = RE_SOQLController.fetchsalesTaxData();
        for(RE_Product__c proddata : productlist){                       
            if(proddata.RE_Product_Subgroup__c != null){
                prodMap.put(proddata.Id, proddata.RE_Product_Subgroup__c);
            }                    
    	}
    }
    
    //Preparing formula data and adding to wrapper list
    public RE_UtilitywrapperController.lineitemwraapper recoverySalesTaxPreparation(List<RE_Depot_Pricing_Backbone__c> depotpricinglist,
                                                                                    Map<String, Double> curConvMap){		        
        String location;
        String product;        
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        Map<Id, Double> rSTCalculation = new Map<Id, Double>();
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){          
                Double salesVal = 0;
                String taxUnit =  '';
                location = dpbData.RE_Depot_Name__r.Name;
                product = dpbData.RE_Product_Name__r.Name;
                for(RE_Sales_Tax__c salesdata : RE_SOQLController.fetchsalesTaxData()){
                    List<String> regionlist = salesdata.RE_Region__c.split(';');                    
                    if(prodMap.get(dpbData.RE_Product_Name__c) == salesdata.RE_Product_Type__c && 
					regionlist.contains(dpbData.RE_Depot_Name__r.RE_Region_Name__c)){                        
						taxUnit = salesdata.RE_Tax_Unit__c;
						salesVal = salesdata.RE_Tax_Value__c;
						break;
				    }                                      
                }
                if(salesVal != 0 && taxUnit != ''){
                    List<String> baseparts = RE_unitConversion.unitBreakUp(taxUnit);
                    Double conversionmultiplier = conv.unitConversionMultiplier(taxUnit,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                                               dpbData.RE_Product_Name__r.Name,curConvMap);                    
                    salesVal = salesVal * conversionmultiplier;                    
                }  
                rSTCalculation.put(dpbData.Id,salesVal);  
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = rSTCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_RecoverySalesTaxController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    
    //Preparing formula data and adding to wrapper list
    public RE_UtilitywrapperController.lineitemwraapper recoverySalesTaxTHPreparation(List<RE_Depot_Pricing_Backbone__c> depotpricinglist,
                                                                                    Map<String, Double> curConvMap,List<RE_Product__c> prodlist){		        
        String location;
        String product;        
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        Map<Id, Double> rSTCalculation = new Map<Id, Double>();
        RE_unitConversion conv = new RE_unitConversion();
        Map<String,RE_Product__c> prodMaps = new Map<String,RE_Product__c>();
        for(RE_Product__c prod : prodlist){
            prodMaps.put(prod.Name,prod);
        }
                                                                                        
        try{
            for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){          
                Double salesVal_1 = 0;
                Double salesVal_2 = 0;
                Double salesVal_3 = 0;
                Double salesVal_4 = 0;
                Double salesVal_5 = 0;
                String taxUnit =  '';
                location = dpbData.RE_Depot_Name__r.Name;
                product = dpbData.RE_Product_Name__r.Name;
                
                if(prodMaps.containsKey(product)){
                    RE_Product__c	prodRef = prodMaps.get(product);
                    salesVal_1 = prodRef.RE_TH_Sales_Tax_Duty_1__c != null ? prodRef.RE_TH_Sales_Tax_Duty_1__c : salesVal_1;
                    salesVal_2 = prodRef.RE_TH_Sales_Tax_Duty_2__c != null ? prodRef.RE_TH_Sales_Tax_Duty_2__c : salesVal_2;
                    salesVal_3 = prodRef.RE_TH_Sales_Tax_Duty_3__c != null ? prodRef.RE_TH_Sales_Tax_Duty_3__c : salesVal_3;
                    salesVal_4 = prodRef.RE_TH_Sales_Tax_Duty_4__c	 != null ? prodRef.RE_TH_Sales_Tax_Duty_4__c : salesVal_4;
                }
                salesVal_5 = dpbData.RE_TH_Sales_Tax_Duty_5__c != null ? dpbData.RE_TH_Sales_Tax_Duty_5__c : salesVal_5;

               // if(taxUnit != ''){
                   // List<String> baseparts = RE_unitConversion.unitBreakUp(taxUnit);
                   // Double conversionmultiplier = conv.unitConversionMultiplier(taxUnit,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                              //                 dpbData.RE_Product_Name__r.Name,curConvMap);                    
                    if(salesVal_1 != 0)
                    salesVal_1 = salesVal_1 ;//* conversionmultiplier;   
                    if(salesVal_2 != 0)
                    salesVal_2 = salesVal_2 ;//* conversionmultiplier;   
                    if(salesVal_3 != 0)
                    salesVal_3 = salesVal_3 ;//* conversionmultiplier;   
                    if(salesVal_4 != 0)
                    salesVal_4 = salesVal_4;// * conversionmultiplier;   
                    if(salesVal_5 != 0)
                    salesVal_5 = salesVal_5 ;//* conversionmultiplier;   
               // }  
                rSTCalculation.put(dpbData.Id,(salesVal_1 + salesVal_2 + salesVal_3 + salesVal_4 + salesVal_5));  
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = rSTCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_RecoverySalesTaxController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    //Preparing PH formula data and adding to wrapper list
   
    public RE_UtilitywrapperController.lineitemwraapper SalesTaxPHPreparation(List<RE_Depot_Pricing_Backbone__c> depotpricinglist,
                                                                                    Map<String, Double> curConvMap,List<RE_Product__c> prodlist){		        
        String location;
        String product;        
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        Map<Id, Double> rSTCalculation = new Map<Id, Double>();
        RE_unitConversion conv = new RE_unitConversion();
        Map<String,RE_Product__c> prodMaps = new Map<String,RE_Product__c>();
        //Map<String,RE_Sales_Tax__c> salesTaxList = RE_SOQLController.fetchsalesTaxData();
		List<RE_Sales_Tax__c> salesTaxList = RE_SOQLController.fetchsalesTaxData();
        for(RE_Product__c prod : prodlist){
            prodMaps.put(prod.Name,prod);
        }
                                                                                        
        try{
            for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){          
                Double salesVal = 0;
                String taxUnit =  '';
                location = dpbData.RE_Depot_Name__r.Name;
                product = dpbData.RE_Product_Name__r.Name;
                
                if(prodMaps.containsKey(product)){
				
                    String	prodgrp = prodMaps.get(product).RE_Product_Group__c;
					String	prodcntry = prodMaps.get(product).RE_Country__r.Name;
                    for(RE_Sales_Tax__c salesdata : salesTaxList){
                                       
                    if( prodgrp == salesdata.RE_Product_Type__c && prodcntry == salesdata.RE_Region__c)
					{                        
						taxUnit = salesdata.RE_Tax_Unit__c;
						salesVal = salesdata.RE_Tax_Value__c;
						break;
				    }   
                }
				if(salesVal != 0 && taxUnit != ''){
                    List<String> baseparts = RE_unitConversion.unitBreakUp(taxUnit);
                    Double conversionmultiplier = conv.unitConversionMultiplier(taxUnit,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                                               prodgrp,curConvMap);                    
                    salesVal = salesVal * conversionmultiplier;                    
                }  
                rSTCalculation.put(dpbData.Id,salesVal);
              }
               
                
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = rSTCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at SalesTaxPHPreparation for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
}