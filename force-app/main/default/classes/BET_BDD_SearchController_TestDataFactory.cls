@isTest
public class BET_BDD_SearchController_TestDataFactory {
	
    public static BET_BDD_Form__c createBDDForm(String lob,String legalEntity,String onboarding){
        BET_BDD_Form__c bddForm=new BET_BDD_Form__c(BDD_Line_of_Business__c=lob,BDD_Entity_Type__c=legalEntity,BDD_Onboard_Type__c=onboarding);
        return bddForm;
    }
	
   
    public static Object getBankersResult(){
        return BET_BDD_Search_Controller.getEdpData('SBI','WONA','Bank','India','','Primary').BankersResult[0];
    }
    
    public static Object getOrbisResult(){
        //return BET_BDD_Search_Controller.getEdpData('SBI','WONA','Bank','India','','Secondary').orbisResultPayload.Data[0];
        return BET_BDD_Search_Controller.getEdpData('SBI','WONA','Bank','India','','Secondary').OrbisResult[0];
    }
    
    public static Object getGTMIResult(){
     	BET_BDD_Search_Controller.getGTRecordSet('','123','');
        return BET_BDD_Search_Controller.getGTRecordSet('SBI Equity Hybrid Fund','','').ResultPayload[0];
    }
        
    
}