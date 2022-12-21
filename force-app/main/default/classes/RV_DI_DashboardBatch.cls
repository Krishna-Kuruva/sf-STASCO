global class RV_DI_DashboardBatch  implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC){

        String recTypeId = Schema.SObjectType.MRC__c.getRecordTypeInfosByDeveloperName().get('DI_Dashboard').getRecordTypeId();
        System.debug('--------'+recTypeId);
        String query = 'Select Id, Ship_to_Name__c, Shipping_Condition__c, Sales_Organization__c,Material_Description__c,'+
                 'Plant__r.Name,Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c, Sold_To__c, Plant__c, Plant_Code__c,Valid_From_Date__c,PO_Type__c,Handling_Type__c,'+
                 'Valid_To_Date__c, Name, Product__c,Mode_Of_Transport__c from MRC__c where  RecordTypeId =\''+ ''+recTypeId+'\'';       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<MRC__c> mrcLst){ 
        
        RV_DI_Dashboard evDIDashboard = new RV_DI_Dashboard();
        System.debug('-----------'+mrcLst.size());
        Date contractStratDate = Date.Today();
        Date contractEndDate = Date.Today().addDays(14);
        if(!mrcLst.isEmpty()){
            Map<Id,MRC__c> mrcMap = new Map<Id,MRC__c>(mrcLst);
            evDIDashboard.getPriceForDashboard('Fixed', contractStratDate, contractEndDate,mrcMap);
        }
    }
    global void finish(Database.BatchableContext BC){
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(30 );
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();

        System.schedule('Dashboard excution every 30 seconds' + sysTime.getTime(), chronExpression, new RV_DI_DashboardScheduler());
    }
}