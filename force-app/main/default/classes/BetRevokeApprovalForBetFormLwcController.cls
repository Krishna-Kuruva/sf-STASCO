public class BetRevokeApprovalForBetFormLwcController {
    @AuraEnabled(Cacheable=false)
    public static UpdateStatusWrapper revokeApproval(String recordId) {
        UpdateStatusWrapper resp = new UpdateStatusWrapper();
        if(string.isNotBlank(recordId)){
            
            List<BET_BDD_Form__c> updatelist = new List<BET_BDD_Form__c>();
            for(BET_BDD_Form__c obj : [select id,BDD_Approver__c, BDD_AppCom__c, BDD_Eligible_Status__c, Name from BET_BDD_Form__c where Id=: recordId LIMIT 1]){
                BET_BDD_Form__c updateObj = new BET_BDD_Form__c();
                updateObj.Id = obj.Id;
                updateObj.BDD_Approver__c = null;
                updateObj.BDD_AppCom__c = null;
                updateObj.BDD_Eligible_Status__c = null;
                updatelist.add(updateObj);
            }
            try{
                if(updatelist!=null && !updatelist.isempty()){
                    update updatelist;
                    resp.title ='Update Success';
                    resp.message ='Approval Fields are cleared successfully';
                    resp.variant = 'success';
                    return resp;
                }
                else {
                    resp.title ='Error';
                    resp.message ='Update List is Blank';
                    resp.variant = 'error';
                    return resp;
                }
            } catch(exception e){
                System.debug('The following exception has occurred: ' + e.getMessage() +' Cause :'+e.getCause() + 'Type : ' +e.getTypeName());
                resp.title ='Error';
                resp.message =e.getmessage();
                resp.variant = 'error';
                return resp;
            }
        }
        else {
            resp.title ='Error';
            resp.message ='Record Id is blank';
            resp.variant = 'error';
            return resp;
        }
    }
    
    public class UpdateStatusWrapper{
        @AuraEnabled
        Public String title{get;set;}
        @AuraEnabled
        Public String message{get;set;}
        @AuraEnabled
        Public String variant{get;set;}
    }
}