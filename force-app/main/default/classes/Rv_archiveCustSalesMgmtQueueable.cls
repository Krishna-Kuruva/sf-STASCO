global class Rv_archiveCustSalesMgmtQueueable implements Queueable{
    global void execute(QueueableContext context ){
        List<Customer_Sales_Management__c> csmLst= new List<Customer_Sales_Management__c>();
        List<Customer_Sales_Management_Archive__c> csmArchLst= new List<Customer_Sales_Management_Archive__c>();
        csmLst=[Select Id,Customer__c,Customer__r.name,Plant__c,Plant__r.name,Plant_Code__c,
                Product_Category__c,Sales_CBM__c,SoldTo_Number__c,Online_Deal_Count__c,createdDate 
               from Customer_Sales_Management__c where createdDate < :system.today() LIMIT 10000];
        if(csmLst.size()>0){
            for(Customer_Sales_Management__c csm :csmLst){
               Customer_Sales_Management_Archive__c csma= new Customer_Sales_Management_Archive__c();
               csma.Customer_Name__c=csm.Customer__r.Name;
               csma.Customer_SoldTo_Number__c=csm.SoldTo_Number__c;
               csma.Plant_Name__c=csm.Plant__r.name;
               csma.Plant_Code__c=csm.Plant_Code__c;
               csma.Online_Deal_Count__c=csm.Online_Deal_Count__c;
               csma.Product_Category__c=csm.Product_Category__c;
               csma.Sales_CBM__c=csm.Sales_CBM__c;
               csma.CSM_Record_Created_Time__c=csm.createdDate;
               csmArchLst.add(csma);
            }
        }
        if(csmArchLst.size()>0){
            try{
                insert csmArchLst;
                delete csmLst;
            }Catch(Exception e){
                System.debug('Error deleteting csm or inserting csma'+e);
            }
        }
    }
}