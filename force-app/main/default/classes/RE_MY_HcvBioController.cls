public class RE_MY_HcvBioController{

    public RE_UtilitywrapperController.lineitemwraapper hcfDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapper> hcfList,Map<String,Double> curConvMap,
                                              Boolean bioValue, List<RE_Market_Quotes__c> latestmarketquotes,List<RE_Bio_Quotes__c> latestBioQuotes){        
        RE_unitConversion conv = new RE_unitConversion();
		if(!bioValue){
			List<formulaWrapper> formulaWrapList = new List<formulaWrapper>();
			for(RE_MY_FormulaFetchController.formulaWrapper hcformula : hcfList){
				formulaWrapper formwrap = new formulaWrapper();  
				Double mopsVal = 0;
				for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){       
					if(hcformula.hcfObj.RE_MY_HCV_Quote__c == mopsQuote.RE_Quote_Name__c){                    
						Double conversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,hcformula.finalUnit,hcformula.country,
                                                                           hcformula.hcfObj.RE_MY_Product__c,curConvMap);
                        mopsVal = mopsQuote.RE_Price__c * conversionmultiplier;
					}
				}
				formwrap.MOPSval = mopsVal;
				formwrap.MOPSpercentage = hcformula.hcfObj.RE_MY_HCV_Quote_Percentage__c != null ? hcformula.hcfObj.RE_MY_HCV_Quote_Percentage__c/100 : 0;
				formwrap.FixedSurcharge = hcformula.hcfObj.RE_MY_HCV_Surcharges__c == null ? 0 : hcformula.hcfObj.RE_MY_HCV_Surcharges__c;
				formwrap.depoId = hcformula.depoId;
                formwrap.location = hcformula.location;
                formwrap.product = hcformula.product;
				formulaWrapList.add(formwrap);
			}
			return hcfCalculation(formulaWrapList);
		}
        else{
			List<bioformulaWrapper> bioformulaWrapList = new List<bioformulaWrapper>();
			for(RE_MY_FormulaFetchController.formulaWrapper hcformula : hcfList){
				bioformulaWrapper formwrap = new bioformulaWrapper();  
				formwrap.BioQuotepercentage = hcformula.hcfObj.RE_MY_Bio_Quote_Percentage__c == null ? 0 : hcformula.hcfObj.RE_MY_Bio_Quote_Percentage__c/100;
				for(RE_Bio_Quotes__c bioquote : latestBioQuotes){            
					if(hcformula.hcfObj.RE_MY_Bio_Quote_1__c != null && 
					   hcformula.hcfObj.RE_MY_Bio_Quote_1__c == bioquote.RE_Bio_Quotes_Name__c){
							Double conversionmultiplier = conv.unitConversionMultiplier(bioquote.RE_Bio_RateUnit__c,hcformula.finalUnit,hcformula.country,
                                                                           'Biofuel',curConvMap);
							formwrap.BioQuoteval = conversionmultiplier * bioquote.RE_Price__c;
					   }			     
					if(hcformula.hcfObj.RE_MY_Bio_Quote_2__c != null && 
					   hcformula.hcfObj.RE_MY_Bio_Quote_2__c == bioquote.RE_Bio_Quotes_Name__c && 
					   hcformula.hcfObj.RE_MY_Region__c == bioquote.RE_Region__c){
							Double conversionmultiplier = conv.unitConversionMultiplier(bioquote.RE_Bio_RateUnit__c,hcformula.finalUnit,hcformula.country,
                                                                           'Biofuel',curConvMap);
							formwrap.BioPremiumval = conversionmultiplier * bioquote.RE_Price__c;
					   }				 
					if(hcformula.hcfObj.RE_MY_Bio_Quote_3__c != null && 
					   hcformula.hcfObj.RE_MY_Bio_Quote_3__c == bioquote.RE_Bio_Quotes_Name__c && 
					   hcformula.hcfObj.RE_MY_Region__c == bioquote.RE_Region__c){
							Double conversionmultiplier = conv.unitConversionMultiplier(bioquote.RE_Bio_RateUnit__c,hcformula.finalUnit,hcformula.country,
                                                                           'Biofuel',curConvMap);
							formwrap.GreenPalmval = conversionmultiplier * bioquote.RE_Price__c;
					   }                
				}
				if(hcformula.hcfObj.RE_MY_Bio_Quote_1__c == null )
					formwrap.BioQuoteval = 0;
				if(hcformula.hcfObj.RE_MY_Bio_Quote_2__c == null )
					formwrap.BioPremiumval = 0;
				if(hcformula.hcfObj.RE_MY_Bio_Quote_3__c == null )
					formwrap.GreenPalmval = 0; 
				formwrap.depoId = hcformula.depoId;
                formwrap.location = hcformula.location;
                formwrap.product = hcformula.product;
				bioformulaWrapList.add(formwrap);
			}
			return bioCostCalculation(bioformulaWrapList);
		}           
    }
    
    public RE_UtilitywrapperController.lineitemwraapper hcfCalculation(List<formulaWrapper> formulaWrapList){        
        String location;
        String product;
        Map<Id, Double> hcValue = new Map<Id, Double>();        
		RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        try{
            for(formulaWrapper wrapperdata : formulaWrapList){             
                Id depoId = wrapperdata.depoId; 
                location = wrapperdata.location;
                product = wrapperdata.product;
                Double finalPrice = (wrapperdata.MOPSpercentage * wrapperdata.MOPSval)	+ wrapperdata.FixedSurcharge;                
                hcValue.put(depoId,finalPrice);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = hcValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at HCV Calculation for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;    
    }
    
    public RE_UtilitywrapperController.lineitemwraapper bioCostCalculation(List<bioformulaWrapper> bioformulaWrapList){
        String location;
        String product;
        Map<Id, Double> bioValueMap = new Map<Id, Double> ();  
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        try{
            for(bioformulaWrapper wrapperdata : bioformulaWrapList){
                Id depoId = wrapperdata.depoId;  
                location = wrapperdata.location;
                product = wrapperdata.product;
                Double finalPrice = (wrapperdata.BioQuotepercentage * (wrapperdata.BioQuoteval+ wrapperdata.BioPremiumval+ wrapperdata.GreenPalmval));                                
                bioValueMap.put(depoId,finalPrice);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = bioValueMap;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at Bio Calculation for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;         
    }
    //HCV Calculation for Philippines
    public RE_UtilitywrapperController.lineitemwraapper PHhcfDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapperTH> fetchPHDepoPricingList ,Map<String,Double> curConvMap,
                                               List<RE_Market_Quotes__c> latestmarketquotes, Map<String,RE_Product__c> proddataMap){        
        RE_unitConversion conv = new RE_unitConversion();
		
			List<formulaWrapper> formulaWrapList = new List<formulaWrapper>();
			for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : fetchPHDepoPricingList){
				formulaWrapper formwrap = new formulaWrapper();  
				Double mopsVal = 0;
				for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){       
					if(dpbData.hcfObj.RE_TH_HCV_Quote1__c == mopsQuote.RE_Quote_Name__c && proddataMap.containskey(dpbData.hcfObj.RE_Product_Name__r.Name)){                    
						Double conversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,dpbData.hcfObj.RE_Final_Price_Unit__c,dpbData.country, proddataMap.get(dpbData.hcfObj.RE_Product_Name__r.Name).RE_Product_Group__c,curConvMap);
                        mopsVal = mopsQuote.RE_Price__c * conversionmultiplier;
                        //System.debug('conversionmultiplierhcv--'+conversionmultiplier);
                        //System.debug('mopsQuote.RE_Rate_Unit__chcv--'+mopsQuote.RE_Rate_Unit__c);
                        //System.debug('dpbData.hcfObj.RE_Final_Price_Unit__c--'+dpbData.hcfObj.RE_Final_Price_Unit__c);
					}
				}
				formwrap.MOPSval = mopsVal;
				formwrap.MOPSpercentage = dpbData.hcfObj.RE_TH_HCV_Quote1_Percent__c != null ? dpbData.hcfObj.RE_TH_HCV_Quote1_Percent__c/100 : 0;
                formwrap.FixedSurcharge = 0;
			    formwrap.depoId = dpbData.hcfObj.Id;
                formwrap.location = dpbData.hcfObj.RE_Depot_Name__c;
                formwrap.product = dpbData.hcfObj.RE_Product_Name__c;
				formulaWrapList.add(formwrap);
			}
    
		    return hcfCalculation(formulaWrapList);  
    }
    
    //Bio Cost Calculation for Philippines
    public RE_UtilitywrapperController.lineitemwraapper PHbioCostCalculation(List<RE_MY_FormulaFetchController.formulaWrapperTH> fetchPHDepoPricingList,Map<String,Double> curConvMap, List<RE_Market_Quotes__c> latestmarketquotes,Map<String,RE_Product__c> proddataMap){
        RE_unitConversion conv = new RE_unitConversion();
        List<bioformulaWrapperPH> bioformulaWrapList = new List<bioformulaWrapperPH>();
        for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : fetchPHDepoPricingList){
            bioformulaWrapperPH formwrapbio = new bioformulaWrapperPH();  
            formwrapbio.BioQuotepercentage = dpbData.hcfObj.RE_PH_Bio_Percent__c == null ? 0 : dpbData.hcfObj.RE_PH_Bio_Percent__c/100;
            Double bioFixed = dpbData.hcfObj.RE_PH_BIO_Fixed__c != null ? dpbData.hcfObj.RE_PH_BIO_Fixed__c : 0;
            
            for(RE_Market_Quotes__c bioquote : latestmarketquotes){            
                if(dpbData.hcfObj.RE_PH_BIO_1__c != null && 
                   dpbData.hcfObj.RE_PH_BIO_1__c == bioquote.RE_Quote_Name__c &&  proddataMap.containskey(dpbData.product)){
                      // Double conversionmultiplier = conv.unitConversionMultiplier(bioquote.RE_Rate_Unit__c,dpbData.hcfObj.RE_Final_Price_Unit__c,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap); //Need clarification on Biofuel
                       formwrapbio.BioQuoteval1 =   bioquote.RE_Price__c ;  //changed
                   }			     
                if(dpbData.hcfObj.RE_PH_BIO_2__c != null && 
                   dpbData.hcfObj.RE_PH_BIO_2__c == bioquote.RE_Quote_Name__c && proddataMap.containskey(dpbData.product)){
                      // Double conversionmultiplier = conv.unitConversionMultiplier(bioquote.RE_Rate_Unit__c,dpbData.hcfObj.RE_Final_Price_Unit__c,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);//Need clarification on Biofuel
                       
                       formwrapbio.BioQuoteval2 =  bioquote.RE_Price__c * (curConvMap.containsKey('PHP-USD') ? curConvMap.get('PHP-USD') : 0.0); //PHP-USD
                   }				 
                if(dpbData.hcfObj.RE_PH_BIO_3__c != null && 
                   dpbData.hcfObj.RE_PH_BIO_3__c == bioquote.RE_Quote_Name__c && proddataMap.containskey(dpbData.product)){
                      // Double conversionmultiplier = conv.unitConversionMultiplier(bioquote.RE_Rate_Unit__c,dpbData.hcfObj.RE_Final_Price_Unit__c,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);//Need clarification on Biofuel
                     //  formwrapbio.BioQuoteval3 = conversionmultiplier * bioquote.RE_Price__c;  // divide by 1000 *0.87= PHP/L15   
                         formwrapbio.BioQuoteval3 = (bioquote.RE_Price__c /1000) *0.87 ;
                   } 					 
            }
            
            Double conversionmultiplier = 0;
            if(dpbData.hcfObj.RE_PH_BIO_Fixed_Unit__c != null && proddataMap.containskey(dpbData.product)){
                conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_BIO_Fixed_Unit__c,dpbData.finalUnit ,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
            }
            
            formwrapbio.BioQuotevalFixed = bioFixed * conversionmultiplier;     
               
            if(dpbData.hcfObj.RE_PH_BIO_1__c == null )
                formwrapbio.BioQuoteval1 = 0;
            if(dpbData.hcfObj.RE_PH_BIO_2__c == null )
                formwrapbio.BioQuoteval2 = 0;
            if(dpbData.hcfObj.RE_PH_BIO_3__c == null )
                formwrapbio.BioQuoteval3 = 0; 
            
            formwrapbio.depoId = dpbData.hcfObj.Id;
            formwrapbio.location = dpbData.location;
            formwrapbio.product = dpbData.product;
            bioformulaWrapList.add(formwrapbio);
        }
        return bioCostCalculationPH(bioformulaWrapList);
    }	
					 
    public RE_UtilitywrapperController.lineitemwraapper bioCostCalculationPH(List<bioformulaWrapperPH> bioformulaWrapList){
        String location;
        String product;
        Map<Id, Double> bioValueMap = new Map<Id, Double> ();  
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        try{
            for(bioformulaWrapperPH wrapperdata : bioformulaWrapList){
                Id depoId = wrapperdata.depoId;  
                location = wrapperdata.location;
                product = wrapperdata.product;
                Double finalPrice = (wrapperdata.BioQuotepercentage * (wrapperdata.BioQuoteval1+ wrapperdata.BioQuoteval2+ wrapperdata.BioQuoteval3 + wrapperdata.BioQuotevalFixed));                                
                bioValueMap.put(depoId,finalPrice);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = bioValueMap;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at Bio Calculation for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;         
    }
	                                               
    public class formulaWrapper{
        public Double MOPSval;
        public Double MOPSpercentage;
		public Double FixedSurcharge;
        public String location;
        public String product;
        public Id depoId;
    }
    
	public class bioformulaWrapper{
		public Double BioQuoteval;
        public Double BioPremiumval;
        public Double GreenPalmval;
        public Double BioQuotepercentage;
        public String location;
        public String product;
		public Id depoId;
	}
  
    public class bioformulaWrapperPH{
		public Double BioQuoteval1;
        public Double BioQuoteval2;
		public Double BioQuoteval3;
		public Double BioQuotevalFixed;
	    public Double BioQuotepercentage;
        public String location;
        public String product;
		public Id depoId;
	}
}