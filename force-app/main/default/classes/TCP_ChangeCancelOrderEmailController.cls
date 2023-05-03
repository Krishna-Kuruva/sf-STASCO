/**************************************************************************************************************************
 * Application  :   Trading and Supply  (TCP)
 * Description  :   Controller class for vf component's
 *                  built to send out order Modify/Change email's              
***************************************************************************************************************************/

public with sharing class TCP_ChangeCancelOrderEmailController {
    public String ContactName{get;set;}    
    public String RecordId {get;set;}
    public string siteURL{get;set;}
    public string ordNumber {get;set;}
    public list<TCP_Change_Cancel_Request__c> ChangeOrderDetails;
    public list<TCP_Change_Cancel_Order_Line_Items__c>ChangeItemDetails{get;set;}
    
    public list<TCP_Change_Cancel_Request__c> getChangeOrderDetails(){
        System.debug('Check Record Id '+RecordId);
        ChangeOrderDetails = new list<TCP_Change_Cancel_Request__c>([Select Id, Customer_PO__c, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, Status__c, Type__c, Web_Order__c, Customer_PO_New__c, Delivery_Terms_New__c, Mode_of_Transport_New__c, Other_Instruction_New__c, Other_Instruction__c, Modify_Cancel_Remarks__c,Web_Order__r.OrderNumber,Web_Order__r.CreatedBy.Name,Web_Order__r.Sold_To_Address__c,Web_Order__r.Ship_To_Address__c, Web_Order__r.CreatedDate,Web_Order__r.CreatedbyID,Web_Order__r.Customer_Name__c,Web_Order__r.Name,Web_Order__r.TCP_Order_Status__c,Web_Order__r.ordered_by__c,Web_Order__r.ordered_by__r.Name,Web_Order__r.TCP_Modification_Requested_By__c,Web_Order__r.TCP_Modification_Requested_By__r.name, Web_Order__r.TCP_Modification_Requested_Date__c, Web_Order__r.TCP_Cancellation_Requested_By__c, Web_Order__r.TCP_Cancellation_Requested_By__r.name, Web_Order__r.TCP_Cancellation_Requested_Date__c  From TCP_Change_Cancel_Request__c where Id=: RecordId]);         
        ChangeItemDetails=getChangeOrderLIDetails();
        //get site url
        list<Site> tcpSite = [select Id from Site where Name =: System.Label.TCP_Site_Name];
        if(!tcpSite.isEmpty()){
            system.debug('in if 1');
            list<SiteDetail> tcpSiteDetail = [select SecureURL from SiteDetail where DurableId = :tcpSite[0].Id];
            if(!tcpSiteDetail.isEmpty()){
                siteURL = tcpSiteDetail[0].SecureURL+'?c__wonumber='+ChangeOrderDetails[0].Web_Order__r.OrderNumber;
                ordNumber = ChangeOrderDetails[0].Web_Order__r.OrderNumber;
            }
        }
        return ChangeOrderDetails;
    }
    
    public list<TCP_Change_Cancel_Order_Line_Items__c> getChangeOrderLIDetails(){
        list<TCP_Change_Cancel_Order_Line_Items__c> ChangeOrderLineItemDetails;
        ChangeOrderLineItemDetails= [SELECT Id, Name, Change_Cancel_Request_Order__c, Delivery_Collection_Date__c, Type__c, Delivery_Collection_Date_New__c, Item_number__c, Product_Name__c,Material_Number__c, Quantity__c, Quantity_New__c, Unit__c, Unit_New__c, Shell_Contract_No__c, Shell_Contract_No_New__c, Instruction__c, Instruction_New__c FROM TCP_Change_Cancel_Order_Line_Items__c where Change_Cancel_Request_Order__r.id=: RecordId and Quantity_New__c!=0];
        return ChangeOrderLineItemDetails; 
    }
    
    
    public list<ChangeProdWrapper> getChangeProdWrapList(){    
        If(!ChangeItemDetails.isempty()){
            List<ChangeProdWrapper> ProdWrapList = new List<ChangeProdWrapper>();
            for(TCP_Change_Cancel_Order_Line_Items__c LI:ChangeItemDetails){
                
                ChangeProdWrapper PWrp = new ChangeProdWrapper();            
                PWrp.ProdName = LI.Product_Name__c;
                PWrp.ProdNumber = LI.Material_Number__c;
                PWrp.Qty = string.valueof(LI.Quantity__c);
                PWrp.QtyNew = string.valueof(LI.Quantity_New__c);
                PWrp.Unit = LI.Unit__c;
                PWrp.UnitNew = LI.Unit_New__c;
                PWrp.CollectionDate=TCP_Utilities.getDateWithMonthName(LI.Delivery_Collection_Date__c);
                PWrp.CollectionDateNew=TCP_Utilities.getDateWithMonthName(LI.Delivery_Collection_Date_New__c);
                PWrp.OtherInstruction= LI.Instruction__c;
                PWrp.OtherInstructionNew= LI.Instruction_New__c;
                PWrp.ShellContractNo= LI.Shell_Contract_No__c;
                PWrp.ShellContractNoNew= LI.Shell_Contract_No_New__c;
                ProdWrapList.add(PWrp);
            }
            return ProdWrapList; 
            }
        return null;
    }
    
    public class ChangeProdWrapper{
      
        public String ProdName{get;set;}
        public String ProdNumber{get;set;}
        public String Qty{get;set;}
        public String QtyNew{get;set;}
        public String Unit{get;set;}
        public String UnitNew{get;set;}
        public String CollectionDate{get;set;}
        public String CollectionDateNew{get;set;}
        public String OtherInstruction{get;set;}
        public String OtherInstructionNew{get;set;}
        public String ShellContractNo{get;set;}
        public String ShellContractNoNew{get;set;}
        
        public ChangeProdWrapper(){
                
        }
    } 
}