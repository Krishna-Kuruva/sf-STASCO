/**************************************************************************************************
* Name: RE_CND_RevContractTriggerHelper
* Object: REV_Contract_Master__c
* Purpose: Update Canada Product Group and Pricing Basis in REV_Contract_Master__c
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-09-12
* Modify History: 
* 2021-09-12		Abhilash		Created
**************************************************************************************************/
public class RE_CND_RevContractTriggerHelper {
    
    // Update Canada Product Group and Pricing Basis
    public static void updateCNDpricingBasis(List<REV_Contract_Master__c> revContrctMastrLst, Set<Id> cndRevProdctGrpMap, Set<Id> cndRevProdctCodeMap, Set<Id> cndRevLoctnMap)
    {
        try
        {
            Map<Id,String> prdGrpMap = New Map<Id,String>();
            Map<Id,String> prdCodeMap = New Map<Id,String>();
            Map<Id,String> loctnMap = New Map<Id,String>();
            
            // Get all the required Canada Product Groups
            for(RE_Product__c rvPrdGr : [SELECT Id, RE_CND_Product_Groups__c FROM RE_Product__c
                                         WHERE Id IN : cndRevProdctGrpMap])
            {
                prdGrpMap.put(rvPrdGr.Id, rvPrdGr.RE_CND_Product_Groups__c);
            }    
            
            // Get all the required Canada Product Code
            for(RE_Product__c rvPrdCode : [SELECT Id, RT_Product_Code__c  FROM RE_Product__c
                                           WHERE Id IN : cndRevProdctCodeMap])
            {
                prdCodeMap.put(rvPrdCode.Id, rvPrdCode.RT_Product_Code__c );
            }
            
            // Get all the required Canada Location Code
            for(RE_Location__c rvLoctnCode : [SELECT Id, RE_Location_Code__c  FROM RE_Location__c
                                              WHERE Id IN : cndRevLoctnMap])
            {
                loctnMap.put(rvLoctnCode.Id, rvLoctnCode.RE_Location_Code__c );
            }

            for(REV_Contract_Master__c revContrct : revContrctMastrLst)
            {               
                // Revolution Canada SFJ Validation
                if(revContrct.RT_Sold_to_Name__c == null)
                    revContrct.addError('Sold to Name is mandatory');
                else if(revContrct.RT_Ship_to_Name__c == null)
                    revContrct.addError('Ship to Name is mandatory');
                else if(revContrct.RE_CND_Rack__c == null)
                    revContrct.addError('Rack is mandatory');
                else if(revContrct.RT_Material_Desc__c == null)
                    revContrct.addError('Material is mandatory');
                else if(revContrct.RE_CND_Plant_Pricing_Basis__c == null)
                    revContrct.addError('Plant Pricing Basis is mandatory');
                else if(revContrct.RE_CND_Product_Pricing_Basis__c == null)
                    revContrct.addError('Product Pricing Basis is mandatory');
                else if(revContrct.RE_CND_Group_Pricing_Basis__c == null)
                    revContrct.addError('Group Pricing Basis is mandatory');
                else if(revContrct.RE_Final_Price_Unit__c == null)
                    revContrct.addError('Final Price Unit is mandatory');
                                
                // Set Canada Product Group based on selected Material 
                if((revContrct.RT_Material_Desc__c != null) && (prdGrpMap.containsKey(revContrct.RT_Material_Desc__c)))
                  revContrct.RE_CND_Product_Group__c = prdGrpMap.get(revContrct.RT_Material_Desc__c);
                else
                  revContrct.RE_CND_Product_Group__c = '';
                
                // Set Pricing Basis based on the selection
                if(((revContrct.RE_CND_Product_Pricing_Basis__c != null) && (prdCodeMap.containsKey(revContrct.RE_CND_Product_Pricing_Basis__c)))
                   || ((revContrct.RE_CND_Plant_Pricing_Basis__c != null) && (loctnMap.containsKey(revContrct.RE_CND_Plant_Pricing_Basis__c)))
                   || (revContrct.RE_CND_Group_Pricing_Basis__c != null))
                {
                    revContrct.RE_CND_Pricing_Basis__c = prdCodeMap.get(revContrct.RE_CND_Product_Pricing_Basis__c) + '-' + 
                    							       loctnMap.get(revContrct.RE_CND_Plant_Pricing_Basis__c) + '-' +
                    							       revContrct.RE_CND_Group_Pricing_Basis__c;
                }
                else
                    revContrct.RE_CND_Pricing_Basis__c = '';         
            }
        }
        Catch(Exception ex)
        {
            RV_ClassException.insertExceptionRecord('UpdatePricingBasis',ex.getMessage(),'RE_CND_RevContractTriggerHelper','updateCNDpricingBasis','Exception');
        }
    }

}