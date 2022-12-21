public class RE_TH_HCVController {   
    public RE_UtilitywrapperController.lineitemwraapper hcfDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapperTH> hcfList,Map<String,Double> curConvMap,List<RE_Market_Quotes__c> latestmarketquotes,List<RE_Product__c> prodlist,Map<String, String> quoteMapes){        
        RE_unitConversion conv = new RE_unitConversion();        
        List<formulaWrapper> formulaWrapList = new List<formulaWrapper>();
        MAP<String,formulaWrapper> formulaFOAWrapMAP = new Map<String,formulaWrapper>();
        Map<String, String> bioquoteMapes = new  Map<String, String> ();   
        bioquoteMapes.putALL(quoteMapes);        
        for(RE_ExternalQuoteMapping__c   quoteMapping : RE_ExternalQuoteMapping__c.getall().values())
            quoteMapes.put(quoteMapping.External_Quotation_Number__c, quoteMapping.RE_Quote_Name__c);                
        Map<String,RE_Product__c> prodMap = new Map<String,RE_Product__c>();
        for(RE_Product__c prod : prodlist)
            prodMap.put(prod.Name,prod);        
        for(RE_MY_FormulaFetchController.formulaWrapperTH hcformula : hcfList){
            formulaWrapper formwrap = new formulaWrapper();  
            Double mopsVal1 = 0;
            Double mopsVal2 = 0;            
            String TH_HCV_Quote1;
            String TH_HCV_Quote2;
            Double mopsValQ1 = 0;
            Double mopsValQ2 = 0;
            //String prodVals = prodMap.get(hcformula.product).RE_TH_TP_Premium__c!=null ? prodMap.get(hcformula.product).RE_TH_TP_Premium__c : '0';
            //Double finalTPPrice = (prodVals != 'EX REF PRICE' && prodVals != 'Actual Purchasing Price' && prodVals != 'Slow moving Price') ? (Double.valueOf(prodVals)) : 0.00;
            Double TH_15_to_30_factor   =   (hcformula.hcfObj.TH_15_to_30_factor__c != null &&  hcformula.hcfObj.TH_15_to_30_factor__c != 0.00) ? hcformula.hcfObj.TH_15_to_30_factor__c : 1;
            Boolean isFixedMops = false;
            if(quoteMapes.containsKey(hcformula.hcfObj.RE_TH_HCV_Quote1__c)){
                TH_HCV_Quote1   =   quoteMapes.get(hcformula.hcfObj.RE_TH_HCV_Quote1__c);
            }
            if(quoteMapes.containsKey(hcformula.hcfObj.RE_TH_HCV_Quote2__c)){
                TH_HCV_Quote2   =   quoteMapes.get(hcformula.hcfObj.RE_TH_HCV_Quote2__c);
            }
            isFixedMops     =   (hcformula.hcfObj.RE_TH_HCV_Quote1__c == 'FIX Price') ? true : false;            
            if(!isFixedMops){
                for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){
                    if(TH_HCV_Quote1 == mopsQuote.RE_Quote_Name__c){  
                        Double finalTPPrice1;
                        if(hcformula.hcfObj.RE_IsTPFormula__c == 'Deem' && hcformula.hcfObj.RE_Deem_Value__c != null && hcformula.hcfObj.RE_Deem_Unit__c != null && hcformula.hcfObj.RE_Insurance_Percentage__c != null && hcformula.hcfObj.RE_Loss_Percentage__c != null){
                            Double deemVal = hcformula.hcfObj.RE_Deem_Value__c * conv.unitConversionMultiplier(hcformula.hcfObj.RE_Deem_Unit__c,mopsQuote.RE_Rate_Unit__c,hcformula.country,hcformula.product,curConvMap);
                            Double insuranceVal = (deemVal + mopsQuote.RE_Price__c) * hcformula.hcfObj.RE_Insurance_Percentage__c /100;
                            Double lossVal = (deemVal + insuranceVal + mopsQuote.RE_Price__c) * hcformula.hcfObj.RE_Loss_Percentage__c /100;
                            finalTPPrice1 =  deemVal + insuranceVal + lossVal;
                        }
                      else if(hcformula.hcfObj.RE_IsTPFormula__c == 'Prem' && hcformula.hcfObj.RE_TH_Gantry_charge_Unit__c != null && hcformula.hcfObj.RE_TH_Gantry_Charge__c != null && hcformula.hcfObj.RE_TH_QP__c != null && hcformula.hcfObj.RE_TH_QP_Unit__c != null && hcformula.hcfObj.RE_TH_SP_Adt__c != null && hcformula.hcfObj.RE_TH_SP_Adt_Unit__c != null ){
                           Double qpVal = hcformula.hcfObj.RE_TH_QP__c ;	   
		                   Double spAdtVal = hcformula.hcfObj.RE_TH_SP_Adt__c * conv.unitConversionMultiplier(hcformula.hcfObj.RE_TH_SP_Adt_Unit__c,mopsQuote.RE_Rate_Unit__c,hcformula.country,hcformula.product,curConvMap) / TH_15_to_30_factor;      
		                   Double gantryVal = hcformula.hcfObj.RE_TH_Gantry_Charge__c *  conv.unitConversionMultiplier(hcformula.hcfObj.RE_TH_Gantry_charge_Unit__c,mopsQuote.RE_Rate_Unit__c,hcformula.country,hcformula.product,curConvMap) / TH_15_to_30_factor;
                           finalTPPrice1 = qpVal + spAdtVal + gantryVal;
                           }
                        else
                            finalTPPrice1 = hcformula.hcfObj.RE_TH_TP_Premium_HCV1__c;
                        if(mopsQuote.RE_Rate_Unit__c == 'USD/TON' && hcformula.hcfObj.TP_Premium_HCV1_Unit__c=='USD/TON' && hcformula.hcfObj.HCV_Surcharges_UNIT__c =='THB/KG'){                            
                            Double conversionmultiplierMop = conv.unitConversionMultiplier('USD/TON','THB/KG',hcformula.country, hcformula.product,curConvMap);                            
                            Double conversionmultiplierKGtoLTR	=	conv.unitConversionMultiplier('THB/KG',hcformula.finalUnit,hcformula.country, hcformula.product,curConvMap);
                            mopsValQ1 = (mopsQuote.RE_Price__c * conversionmultiplierMop + finalTPPrice1 * conversionmultiplierMop)/conversionmultiplierKGtoLTR; 
                        }
                        else if(mopsQuote.RE_Rate_Unit__c == 'USD/BBL' && hcformula.hcfObj.TP_Premium_HCV1_Unit__c=='USD/TON' && hcformula.hcfObj.TP_Premium_HCV1_Unit__c=='USD/TON' && hcformula.product =='BF MFO 0.50%S VLSFO Global'){			
                            Double conversionmultiplierMop = conv.unitConversionMultiplier('USD/BBL','USD/TON',hcformula.country ,hcformula.product,curConvMap);																	   
                            Double conversionmultiplierTP = conv.unitConversionMultiplier('USD/TON','THB/KG',hcformula.country,	hcformula.product,curConvMap);						
                            Double conversionmultiplierKGtoLTR	=	conv.unitConversionMultiplier('THB/KG',hcformula.finalUnit,hcformula.country, hcformula.product,curConvMap);                           
                            mopsValQ1 = (mopsQuote.RE_Price__c * conversionmultiplierMop * conversionmultiplierTP + hcformula.hcfObj.RE_TH_TP_Premium_HCV1__c * conversionmultiplierTP)/conversionmultiplierKGtoLTR; 
                            System.debug('mopsValQ1@@'+mopsValQ1);
                         }
                        else{  
                            Double conversionmultiplierMop = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,hcformula.finalUnit,hcformula.country, hcformula.product,curConvMap);
                            Double conversionmultiplierTP = conv.unitConversionMultiplier(hcformula.hcfObj.TP_Premium_HCV1_Unit__c,hcformula.finalUnit,hcformula.country, hcformula.product,curConvMap);
                            mopsValQ1 = mopsQuote.RE_Price__c * conversionmultiplierMop + finalTPPrice1 * conversionmultiplierTP; 
                        }
                        
                    }
                    
                    if(hcformula.product == 'Shell Fuel Oil A Extra' && hcformula.hcfObj.RE_TH_HCV_Quote1__c == 'FOA Price'){                        
                        mopsValQ1 = formulaFOAWrapMAP.containsKey(hcformula.location) ? (formulaFOAWrapMAP.get(hcformula.location).oillosspercentage * ((formulaFOAWrapMAP.get(hcformula.location).MOPSpercentage1 * formulaFOAWrapMAP.get(hcformula.location).MOPSval1) + (formulaFOAWrapMAP.get(hcformula.location).MOPSpercentage2 * formulaFOAWrapMAP.get(hcformula.location).MOPSval2)) + formulaFOAWrapMAP.get(hcformula.location).HCV_Surcharges) : 0.0;
                    }
                    
                    // for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){       
                    if(TH_HCV_Quote2 == mopsQuote.RE_Quote_Name__c){  
                        if(mopsQuote.RE_Rate_Unit__c == 'USD/BBL' && hcformula.hcfObj.TP_Premium_HCV2_Unit__c=='USD/BBL' && hcformula.hcfObj.TP_Premium_HCV1_Unit__c=='USD/TON' && hcformula.hcfObj.HCV_Surcharges_UNIT__c =='THB/KG'){
                            Double cmBBLtoTON = conv.unitConversionMultiplier('USD/BBL','USD/TON',hcformula.country, hcformula.product,curConvMap);
                            Double cmTONtoKG = conv.unitConversionMultiplier('USD/TON','THB/KG',hcformula.country, hcformula.product,curConvMap);
                            Double cmKGtoLTR = conv.unitConversionMultiplier('THB/KG',hcformula.finalUnit,hcformula.country, hcformula.product,curConvMap);
                            mopsValQ2 = (mopsQuote.RE_Price__c  * cmTONtoKG + hcformula.hcfObj.RE_TH_TP_Premium_HCV2__c  * cmTONtoKG)/(cmKGtoLTR * cmBBLtoTON);
                        }
                        else{
                            Double conversionmultiplierMop = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,hcformula.finalUnit,hcformula.country, hcformula.product,curConvMap);
                            Double conversionmultiplierTP = conv.unitConversionMultiplier(hcformula.hcfObj.TP_Premium_HCV2_Unit__c,hcformula.finalUnit,hcformula.country, hcformula.product,curConvMap);
                            mopsValQ2 = bioquoteMapes.containsKey(mopsQuote.RE_Quote_Name__c) ? mopsQuote.RE_Price__c * conversionmultiplierMop : (TH_HCV_Quote2 == 'GTL' ? mopsQuote.RE_Price__c : (mopsQuote.RE_Price__c * conversionmultiplierMop + hcformula.hcfObj.RE_TH_TP_Premium_HCV2__c * conversionmultiplierTP));
                        }
                    }
                }
            }
            else{
                
                mopsValQ1   =   hcformula.hcfObj.RE_TH_TP_Premium_HCV1__c != null ? hcformula.hcfObj.RE_TH_TP_Premium_HCV1__c : 0.00;
            }
            Double oillosspercentage = hcformula.hcfObj.RE_TH_Oil_Loss_Percent__c!=null ? hcformula.hcfObj.RE_TH_Oil_Loss_Percent__c : 0.0;
            formwrap.isFixedMopsVal =   isFixedMops;
            formwrap.MOPSval1 = mopsValQ1;
            formwrap.MOPSval2 = mopsValQ2;            
            formwrap.MOPSpercentage1 = hcformula.hcfObj.RE_TH_HCV_Quote1_Percent__c != null ? ((hcformula.hcfObj.RE_TH_HCV_Quote1_Percent__c/100)* TH_15_to_30_factor) : 0;
            formwrap.MOPSpercentage2 = hcformula.hcfObj.RE_TH_HCV_Quote2_Percent__c != null ? hcformula.hcfObj.RE_TH_HCV_Quote2_Percent__c/100 : 0;         
            formwrap.depoId = hcformula.depoId;
            formwrap.location = hcformula.location;
            formwrap.product = hcformula.product;
            formwrap.oillosspercentage  =   oillosspercentage == 0.0 ? 1 : 1.00/(1.00-(oillosspercentage/100));
            
            formwrap.HCV_Surcharges     =   hcformula.hcfObj.RE_TH_HCV_Surcharges__c != null ? (hcformula.hcfObj.HCV_Surcharges_UNIT__c !='THB/KG' ? (hcformula.hcfObj.RE_TH_HCV_Surcharges__c * (conv.unitConversionMultiplier(hcformula.hcfObj.HCV_Surcharges_UNIT__c,hcformula.finalUnit,hcformula.country, hcformula.product,curConvMap))) : (hcformula.hcfObj.RE_TH_HCV_Surcharges__c / (conv.unitConversionMultiplier(hcformula.hcfObj.HCV_Surcharges_UNIT__c,hcformula.finalUnit,hcformula.country,hcformula.product,curConvMap))))  : 0.00;
            
            formulaWrapList.add(formwrap); 
            if(formwrap.product == 'Fuel Oil A 2%S-80 CST'){
                formulaFOAWrapMAP.put(formwrap.location,formwrap);
            }
        }
        return hcfCalculation(formulaWrapList,prodMap);
    }       
    
    public RE_UtilitywrapperController.lineitemwraapper hcfCalculation(List<formulaWrapper> formulaWrapList,Map<String,RE_Product__c> prodsMap){
        Map<Id, Double> hcValue = new Map<Id, Double>();  
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        try{
            for(formulaWrapper wrapperdata : formulaWrapList){ 
                location = wrapperdata.location;
                product = wrapperdata.product;
                Double finalPrice =0.0;
                finalPrice= wrapperdata.isFixedMopsVal ? wrapperdata.MOPSval1 : (wrapperdata.oillosspercentage * ((wrapperdata.MOPSpercentage1 * wrapperdata.MOPSval1) + (wrapperdata.MOPSpercentage2 * wrapperdata.MOPSval2)) + wrapperdata.HCV_Surcharges);                   
                    hcValue.put(wrapperdata.depoId,finalPrice);
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
    
    public class formulaWrapper{
        public Double MOPSval1;
        public Double MOPSpercentage1;
        public Double MOPSval2;
        public Double MOPSpercentage2;
        public Double oillosspercentage;
        public Double HCV_Surcharges;
        public String location;
        public String product;
        public Boolean isFixedMopsVal;
        public Id depoId;
    }
}