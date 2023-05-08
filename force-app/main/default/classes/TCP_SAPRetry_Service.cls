public with sharing class TCP_SAPRetry_Service {
 	public static integer goodsIssueCounter=1;
    public static integer ordConfCounter=1;
    public static integer ModifyOrderCounter=1;
    public static integer PlaceOrderCounter=1;
     @TestVisible private static list<CurrentOrders__x> MocklistGetCurrentOrder1 = new list<CurrentOrders__x>();
    @TestVisible private static List<OrdCnfDet__x> MocklistGetOrderConfirmation1=new List<OrdCnfDet__x>();
    
    public static void p31GoodsIssueRetry(string completeString, string soldtoID, string stnsapSoldTo){
        
        try{
            
            if(goodsIssueCounter <=2){
                list<CurrentOrders__x> listGetCurrentOrder=new List<CurrentOrders__x>();
                
                    listGetCurrentOrder = Database.query(completeString);
                
                if(listGetCurrentOrder != null){                
                    TCP_OrderManagementProcessor.trackCurrentOrderFromsGSAP(listGetCurrentOrder, soldtoID, stnsapSoldTo);
                

                }
            }
            
        }
        catch(exception e){
            goodsIssueCounter++;
            system.debug('in p31GoodsIssueRetry catch '+goodsIssueCounter);
            if(goodsIssueCounter == 3){
                TCP_ExceptionLogClass.insertExceptionRecord('Current order service Exception',e.getMessage(),'TCP_GSAPDataService','GetCurrentOrdersFromGsap','Exception');            
                }
            TCP_SAPRetry_Service.p31GoodsIssueRetry(completeString,  soldtoID,  stnsapSoldTo);
        }
        
    }
    
    public static void p31OrdConfirmRetry(string completeString, string soldtoID, string stnsapSoldTo){
        
        try{
            
            if(ordConfCounter <=2){
                list<OrdCnfDet__x> listGetOrderConfirmation=new List<OrdCnfDet__x>();
               
                listGetOrderConfirmation = Database.query(completeString); 
                
                if(listGetOrderConfirmation != null){                
                	TCP_OrderManagementProcessor.updateOrderConfirmationDetails(listGetOrderConfirmation, soldtoID, stnsapSoldTo);                
                    
                }
                
            }
             
            
        }
        catch(exception e){
            ordConfCounter++;
            system.debug('in p31OrdConfirmRetry catch '+ordConfCounter);
            if(ordConfCounter == 3){
                TCP_ExceptionLogClass.insertExceptionRecord('Order confirmation service Exception',e.getMessage(),'TCP_GSAPDataService','GetOrderConfirmationFromGsap','Exception');
            }
            TCP_SAPRetry_Service.p31OrdConfirmRetry(completeString,  soldtoID,  stnsapSoldTo);
        }
    }
    
    public static void p31ModifyCancelRetry(string completeString,String OrderId){
        CcpChOrdr__x lstChOrder = new CcpChOrdr__x();
        try{
            
            if(ModifyOrderCounter <= 2){
                if(test.isRunningTest()){
                    lstChOrder.Message__c='Order Processed';
                    lstChOrder.Msgid__c='1234';
                }
                else{
                      lstChOrder = Database.query(completeString);
                }
              
                system.debug('response form the gsap is'+ lstChOrder);
                if(lstChOrder != null && lstChOrder.Message__c != 'Order NOT Processed'){ 
                    system.debug('response sales order: '+ lstChOrder.Msgid__c);          
                    TCP_OrderManagementProcessor.trackStatusGSAPOrder(OrderId,true,false,lstChOrder.Msgid__c,false);
                }else{
                    TCP_OrderManagementProcessor.trackStatusGSAPOrder(OrderId,true,false,lstChOrder.Msgid__c,false);
                }
            }
        }
        catch(exception e){
            ModifyOrderCounter++;
            system.debug('in p31GoodsIssueRetry catch '+ModifyOrderCounter);
            if(ModifyOrderCounter == 3){
                TCP_ExceptionLogClass.insertExceptionRecord('Modify order exception',e.getMessage(),'TCP_GSAPDataService','SubmitToGSAPforModifyCancel','Exception');
                TCP_OrderManagementProcessor.trackStatusGSAPOrder(OrderId,true,false,lstChOrder.Msgid__c,false);
            }
            TCP_SAPRetry_Service.p31ModifyCancelRetry(completeString,OrderId);
        }
    }
    
 
    
    
}