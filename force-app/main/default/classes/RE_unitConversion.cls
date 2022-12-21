public class RE_unitConversion{ 
    
    //Converting Base currency value to Converted currency
    public Double convertBaseToConvertCurrency(String baseCurrency, String convertCurrency, Map<String,Double> fxRateMap)
    {
        Double finalVal = 1;
        if(convertCurrency == baseCurrency)
            finalVal = 1;        
        else
        {          
            String[] formulaLst;
            String formula;
            String keyVal = convertCurrency+'-'+baseCurrency;
            
            // Get the Revolution Currency Conversion Formula
            for(RE_Currency_Conversion__c curConvr : RE_Currency_Conversion__c.getall().values()){
                if((curConvr.Base_Currency_Unit__c == baseCurrency) 
                   && (curConvr.Converted_Currency_Unit__c == convertCurrency))
                {
                    formula = curConvr.Formula__c;                     
                }
            }
            
            if(formula != null && formula.toLowerCase().trim() == 'fxrate')
            {
                if(fxRateMap.containsKey(keyVal))
                    finalVal = (fxRateMap.get(keyVal));         
            }
            else if(formula != null)
            {
                formulaLst = formula.split('\\*');
                
                if(formulaLst[0] != formula && formulaLst[0].IsNumeric() && formulaLst[1].toLowerCase().trim() == 'fxrate' && fxRateMap.containsKey(keyVal))
                    finalVal = Double.valueOf(formulaLst[0]) * (fxRateMap.get(keyVal));                     
                else if (formulaLst[0] != formula && formulaLst[1].IsNumeric() && formulaLst[0].toLowerCase().trim() == 'fxrate' && fxRateMap.containsKey(keyVal))
                    finalVal = Double.valueOf(formulaLst[1]) * (fxRateMap.get(keyVal));            
                else
                {
                    formulaLst = formula.split('\\/');
                    if(formulaLst[0] != formula && formulaLst[0].IsNumeric() && formulaLst[1].toLowerCase().trim() == 'fxrate' && fxRateMap.containsKey(keyVal))
                        finalVal = Double.valueOf(formulaLst[0]) / (fxRateMap.get(keyVal));                     
                    else if(formulaLst[0] != formula && formulaLst[1].IsNumeric() && formulaLst[0].toLowerCase().trim() == 'fxrate' && fxRateMap.containsKey(keyVal))
                        finalVal = Double.valueOf(formulaLst[1]) / (fxRateMap.get(keyVal));                        
                    else if (formulaLst[0].IsNumeric())                 
                        finalVal = Double.valueOf(formula);             
                }
            }     
        }
        
        return finalVal;
    }
    
    //Converting currency value to Malayasian currency
    public Double convertCurrencyMultiplier(String baseCurrency, String convertCurrency, Map<String, Double> curConvMap){        
        Double finalVal;       
        if((convertCurrency == 'MYR' && baseCurrency == 'MYR CTS') 
           || (convertCurrency == 'USD' && baseCurrency == 'USD CTS')
           || (convertCurrency == 'SGD' && baseCurrency == 'SGD CTS')){
               finalVal = 0.01;
           }
        else if ((convertCurrency == 'MYR CTS' && baseCurrency == 'MYR') 
                 || (convertCurrency == 'USD CTS' && baseCurrency == 'USD')
                 || (convertCurrency == 'SGD CTS' && baseCurrency == 'SGD')){           
                     finalVal = 100; 
                 }
        else if(convertCurrency == baseCurrency){
            finalVal = 1;
        }
        else if(convertCurrency == 'USD CTS' && baseCurrency == 'SGD CTS'){
            baseCurrency = 'USD';
            convertCurrency = 'SGD';
            String keyVal = convertCurrency+'-'+baseCurrency;
            if(curConvMap.containsKey(keyVal)){
                finalVal = 1/(curConvMap.get(keyVal));
            }
        } else if(baseCurrency == 'STG' && convertCurrency == 'THB'){
            
            finalVal = 0.01;
        }
        else if(convertCurrency == 'USD' && baseCurrency == 'THB'){ 
            String keyVal = baseCurrency+'-'+convertCurrency;
            if(curConvMap.containsKey(keyVal)){
                finalVal = 1/(curConvMap.get(keyVal));
            }
        }
        else{
            String keyVal = convertCurrency+'-'+baseCurrency;
            if(curConvMap.containsKey(keyVal)){
                finalVal = (curConvMap.get(keyVal));
            }			
        }
        return finalVal;
    }
    
    //Converting volume data to litre value
    public Double convertVolumeMultiplier(String subgroup, String baseUnit, String conversionUnit, String country){		
        Double finalValue = 0;  
        if(baseUnit == conversionUnit) 
            finalValue = 1; 
        else{
            for(RE_MY_VolumeConversion__c conversionRate : RE_MY_VolumeConversion__c.getall().values()){            
                if(conversionRate.RE_MY_Product_Subgroup__c == subgroup && 
                   conversionRate.RE_MY_Base_Volume_Unit__c == conversionUnit &&
                   conversionRate.RE_MY_Country__c == country &&
                   conversionRate.RE_MY_Volume_Unit__c == baseUnit){
                       finalValue = conversionRate.RE_MY_Conversion_Rate__c;                    
                       break;
                   }
                
                if(conversionRate.RE_MY_Base_Volume_Unit__c == conversionUnit &&
                   conversionRate.RE_MY_Country__c == country &&
                   conversionRate.RE_MY_Volume_Unit__c == baseUnit){
                       finalValue = conversionRate.RE_MY_Conversion_Rate__c;                                              
                   }                        
            }                        
        }
        return finalValue;        
    }
    
    //Break the base unit and return the volume and currecncy list
    public static List<String> unitBreakUp(String baseUnit){        
        List<String> unitpart = new List<String>();
        for(RE_Rate_Unit_Manager__c unitbreak : RE_Rate_Unit_Manager__c.getall().values()){           
            if(baseUnit == unitbreak.RE_Rate_Unit__c){
                unitpart.add(unitbreak.RE_Currency_Unit__c);
                unitpart.add(unitbreak.RE_Volume_Unit__c);
            }
        }
        return unitpart;
    }
    
    public Double unitConversionMultiplier(String baseenergyunit, String conversionenergyunit, String country,  String subgroup, Map<String, Double> curConvMap)
    {        
        Double finalVal;
        String basevolumeunit;
        String basecurrencyunit;
        String convertvolumeunit;
        String convertcurrencyunit;	
        Double currencymultiplier;
            
        if(!string.isBlank(baseenergyunit) && baseenergyunit!=null){
                basevolumeunit = unitBreakUp(baseenergyunit)[1];                                               
                basecurrencyunit = unitBreakUp(baseenergyunit)[0];              
        }
        if(!string.isBlank(conversionenergyunit)&& conversionenergyunit!=null){
            convertvolumeunit = unitBreakUp(conversionenergyunit)[1];
            convertcurrencyunit = unitBreakUp(conversionenergyunit)[0];       
        }	
        
        if(String.isNotBlank(country) && country.toLowerCase() == 'canada')  
            // New method created for convert Base to Convert Currency
            currencymultiplier = convertBaseToConvertCurrency(basecurrencyunit,convertcurrencyunit,curConvMap);                                             
        else                                 
            currencymultiplier = convertCurrencyMultiplier(basecurrencyunit,convertcurrencyunit,curConvMap);       
        
        Double volumemultiplier = convertVolumeMultiplier(subgroup,basevolumeunit,convertvolumeunit,country);                                              
        if(volumemultiplier == 0)
            return 0;			
        return (currencymultiplier/volumemultiplier);
    }
}