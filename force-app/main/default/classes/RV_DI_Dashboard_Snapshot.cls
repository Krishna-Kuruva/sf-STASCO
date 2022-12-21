global class RV_DI_Dashboard_Snapshot implements Database.Batchable<sObject>{
    public static String snapShotRecId;
    global Database.QueryLocator start(Database.BatchableContext BC){
        String recTypeId = Schema.SObjectType.Revolution_Dashboard__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();

        String query = 'Select Id,RecordTypeId, ATP1_Live_AGO__c, ATP1_Live_IGO__c, ATP1_Live_MOGAS__c, BSP_AGO__c, BSP_GTL__c, ' +
                        'BSP_IGO__c, BSP_MOGAS__c, MOT__c, MRC_Name__c, OTM_AGO__c, OTM_IGO__c, ' +
                        'OTM_MOGAS__c, Plant_Code__c, Plant_Name__c, PSP_AGO__c, ' +
                        'PSP_IGO__c, PSP_MOGAS__c, Sales_Channel__c, Shipping_Condition__c, Total_Tax_AGO__c, ' +
                        'Total_Tax_IGO__c, Total_Tax_MOGAS__c from Revolution_Dashboard__c where RecordTypeId =\''+ ''+recTypeId+'\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Revolution_Dashboard__c> scope){ 
        snapShotRecId = Schema.SObjectType.Revolution_Dashboard__c.getRecordTypeInfosByName().get('Snapshot').getRecordTypeId();
		List<Revolution_Dashboard__c> rdSnapshotList = new List<Revolution_Dashboard__c>();       
        for(Revolution_Dashboard__c sObj : scope){
            Revolution_Dashboard__c rd = new Revolution_Dashboard__c();//(Revolution_Dashboard__c)sObj;
            rd = sObj.clone(false,false,false,false);
            rd.RecordTypeId = snapShotRecId;
            rdSnapshotList.add(rd);
        }
        if(!rdSnapshotList.isEmpty()){
            insert rdSnapshotList;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }

}