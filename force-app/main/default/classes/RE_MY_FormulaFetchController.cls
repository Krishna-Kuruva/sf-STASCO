public class RE_MY_FormulaFetchController { 
    public Map<Id,formulaWrapper> formulaformedMap = new Map<Id,formulaWrapper>();
    public Map<Id,formulaWrapperSG> formulaformedMapSG = new Map<Id,formulaWrapperSG>();
    public Map<Id,formulaWrapperAMVMY> formulaformedMapAMVMY = new Map<Id,formulaWrapperAMVMY>();
    public Map<Id,formulaWrapperTH>	formulaformedMapTH	= new Map<Id,formulaWrapperTH>();
    
	public List<formulaWrapper> formulaforDepotData(List<RE_Depot_Pricing_Backbone__c> depotpricinglist, List<RE_Malaysian_Formula_Table__mdt> malformulalist){
		//Preparing formula data and adding to wrapper list		
		for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){
			formulaWrapper formwrapData = new formulaWrapper();  
			formwrapData.depoId = dpbData.Id;
            formwrapData.location = dpbData.RE_Depot_Name__r.Name;
            formwrapData.product = dpbData.RE_Product_Name__r.Name;
			formwrapData.country = dpbData.RE_Country__r.Name;
			formwrapData.finalUnit = dpbData.RE_Final_Price_Unit__c;
			for(RE_Malaysian_Formula_Table__mdt formulaData : malformulalist){
				if(dpbData.RE_Product_Name__r.Name == formulaData.RE_MY_Product__c && dpbData.RE_Depot_Name__r.RE_Region_Name__c == formulaData.RE_MY_Region__c){					
					if(formulaData.RE_MY_Plant__c != null && dpbData.RE_Depot_Name__r.Name == formulaData.RE_MY_Plant__c ){
						if(formulaformedMap.containsKey(dpbData.Id))
							formulaformedMap.remove(dpbData.Id);						
						formwrapData.hcfObj = formulaData;
						formulaformedMap.put(dpbData.Id, formwrapData);  
						break;
					}				
					else if(formulaData.RE_MY_Plant__c == null){										
						formwrapData.hcfObj = formulaData;
						formulaformedMap.put(dpbData.Id, formwrapData);   
					}
				}                
			}
		}
		return formulaformedMap.Values();
	}
    
	public List<formulaWrapperSG> formulaforDepotDataSG(List<RE_Depot_Pricing_Backbone__c> depotpricinglist, List<RE_SG_Cost_Price_Manager__mdt> sgformulalist){
		//Preparing formula data and adding to wrapper list	
		for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){
			formulaWrapperSG formwrapData = new formulaWrapperSG();  
			formwrapData.depoId = dpbData.Id;
			formwrapData.country = dpbData.RE_Country__r.Name;
            formwrapData.location = dpbData.RE_Depot_Name__r.Name;
            formwrapData.product = dpbData.RE_Product_Name__r.Name;
			formwrapData.finalUnit = dpbData.RE_Final_Price_Unit__c;
			for(RE_SG_Cost_Price_Manager__mdt formulaData : sgformulalist){
				if(dpbData.RE_Product_Name__r.Name == formulaData.RE_SG_Product__c && dpbData.RE_Depot_Name__r.Name == formulaData.RE_SG_Plant__c ){										
					formwrapData.hcfObj = formulaData;
					formulaformedMapSG.put(dpbData.Id, formwrapData);
					break;														
				}                
			}
		}
		return formulaformedMapSG.Values();
	}
    
    public List<formulaWrapperAMVMY> formulaforDepotDataAMVMY(List<RE_Depot_Pricing_Backbone__c> depotpricinglist, List<RE_Route_Backbone__c> rbblist){
		//Preparing formula data and adding to wrapper list			
        for(RE_Route_Backbone__c formulaData : rbblist){ 
            formulaWrapperAMVMY formwrapData = new formulaWrapperAMVMY();              
            formwrapData.hcfObj = formulaData;
            for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){
                if(dpbData.RE_Product_Name__c == formulaData.RE_Product_Name__c && dpbData.RE_Depot_Name__c == formulaData.RE_Destination_Name__c ){
                    formwrapData.depoId = dpbData.Id;
                    formwrapData.country = dpbData.RE_Country__r.Name;
                    formwrapData.location = dpbData.RE_Depot_Name__r.Name;
                    formwrapData.product = dpbData.RE_Product_Name__r.Name;
                    formwrapData.finalUnit = dpbData.RE_Final_Price_Unit__c;
                }
            }        
            formulaformedMapAMVMY.put(formulaData.Id, formwrapData);
        }
		return formulaformedMapAMVMY.Values();
	}
    public List<formulaWrapperTH> formulaforDepotDataTH(List<RE_Depot_Pricing_Backbone__c> depotpricinglist){
		//Preparing formula data and adding to wrapper list			
        for(RE_Depot_Pricing_Backbone__c formulaData : depotpricinglist){ 
            
            formulaWrapperTH formwrapData = new formulaWrapperTH();              
            formwrapData.hcfObj = formulaData;
            formwrapData.depoId = formulaData.Id;
            formwrapData.country = formulaData.RE_Country__r.Name;
            formwrapData.location = formulaData.RE_Depot_Name__r.Name;
            formwrapData.product = formulaData.RE_Product_Name__r.Name;
            formwrapData.finalUnit = formulaData.RE_Final_Price_Unit__c;                    
            formulaformedMapTH.put(formulaData.Id, formwrapData);
        }
		return formulaformedMapTH.Values();
	}
    public class formulaWrapperSG{
		public Id depoId;
		public String finalUnit;
		Public RE_SG_Cost_Price_Manager__mdt hcfObj;
        public String country;
        public String location;
        public String product;
	}
    public class formulaWrapper{
		public Id depoId;
		public String finalUnit;
		Public RE_Malaysian_Formula_Table__mdt hcfObj;
        public String country;
        public String location;
        public String product;
	}
    public class formulaWrapperAMVMY{
		public Id depoId;
		public String finalUnit;
		Public RE_Route_Backbone__c hcfObj;
        public String country;
        public String location;
        public String product;
	}
    public class formulaWrapperTH{
		public Id depoId;
		public String finalUnit;
		Public RE_Depot_Pricing_Backbone__c hcfObj;
        public String country;
        public String location;
        public String product;
	}
}