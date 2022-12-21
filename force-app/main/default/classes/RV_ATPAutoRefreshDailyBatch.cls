/*****************************************************************************
@Name:  RV_ATPAutoRefreshDailyBatch      
@=========================================================================
@Purpose: Batch will execute  to calculate ATP auto Refresh                                                                                        
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      10/18/2017         INITIAL DEVELOPMENT

******************************************************************************/
global  class RV_ATPAutoRefreshDailyBatch implements Queueable{
    global void execute(QueueableContext context ){
        //START - Rahul Sharma | Date - 11-Nov-2020 : Added new fields in the query to refresh live online volume for tranche 2 and tranche 3.
        String query = 'SELECT Id, ATP1__c, ATP2__c, ATP3__c, Batch1__c, Batch2__c, ATP_Refresh__c, Lifting_Validity_From1__c,'+
            'Lifting_Validity_From2__c, Lifting_Validity_From3__c, Sales_8_30_17_30__c, Sales_15_28__c,'+
            'Sales_29_61__c, ATP2_Live__c, ATP3_Live__c, ATP_Auto_Refresh__c, ATP_Live__c, Minimum_ATP1__c,'+
            'Live_Online_00_14__c, Live_Online_ATP2__c, Live_Online_ATP3__c, Minimum_Daily_Split_Volume__c,'+
            'Min_Daily_Split_Vol_ATP2__c, Min_Daily_Split_Vol_ATP3__c, Split_Volume__c, Split_Volume_Per_ATP2__c,'+
            'Split_Volume_Per_ATP3__c, Minimum_Online_Volume__c, Min_Online_Volume_ATP2__c, Min_Online_Volume_ATP3__c,'+
            'Maximum_Online_Volume__c, Max_Online_Volume_ATP2__c, Max_Online_Volume_ATP3__c, ATP_MIN_15_28__c, ATP_MIN_29_61__c, Location__c from ATP__c';
            //END - Rahul Sharma | Date - 11-Nov-2020 : Added new fields in the query to refresh live online volume for tranche 2 and tranche 3.
        List<ATP__c> atpLst = Database.query(query);
        List<ATP__c> finalupdateATPRecord = new List<ATP__c>();
        for(ATP__c atpRecords : atpLst){
            atpRecords.Sales_8_30_17_30__c = 0;
            atpRecords.Sales_15_28__c = 0;
            atpRecords.Sales_29_61__c = 0;
            if(atpRecords.ATP_Auto_Refresh__c == true || atpRecords.Batch1__c == true || atpRecords.Batch2__c == true){
                if(atpRecords.ATP_Auto_Refresh__c == true){     
                    if(atpRecords.ATP_Live__c <> null){ 
                        if(atpRecords.Minimum_ATP1__c == null)atpRecords.Minimum_ATP1__c=0.0;
                        atpRecords.ATP1__c = atpRecords.Minimum_ATP1__c;
                        atpRecords.ATP_Live__c = atpRecords.ATP1__c;
                        atpRecords.Sales_8_30_17_30__c = 0;
                        if(atpRecords.Lifting_Validity_From1__c != null && atpRecords.Lifting_Validity_From1__c == Date.Today()){
                            atpRecords.Lifting_Validity_From1__c = null;
                        }
                        Decimal dailyVol = atpRecords.ATP_Live__c;
                        Decimal minDailyVol = atpRecords.Minimum_Daily_Split_Volume__c;
                        Decimal splitVol = atpRecords.Split_Volume__c;
                        Decimal minOnlineVol = atpRecords.Minimum_Online_Volume__c;
                        Decimal maxOnlineVol = atpRecords.Maximum_Online_Volume__c;
                            
                        atpRecords.Live_Online_00_14__c = RV_ATPTriggerHelper.getOnlineATP( dailyVol
                                                                                            ,minDailyVol
                                                                                            ,splitVol
                                                                                            ,minOnlineVol
                                                                                            ,maxOnlineVol);
                    }     
                }
                if(atpRecords.Batch1__c == true){  
                    if(atpRecords.ATP2_Live__c <> null){  
                        if(atpRecords.ATP_MIN_15_28__c == null)atpRecords.ATP_MIN_15_28__c=0.0;
                        atpRecords.ATP2__c = atpRecords.ATP_MIN_15_28__c;
                        atpRecords.ATP2_Live__c = atpRecords.ATP2__c;
                        atpRecords.Sales_15_28__c = 0;
                        if(atpRecords.Lifting_Validity_From2__c != null && atpRecords.Lifting_Validity_From2__c == Date.Today()){
                            atpRecords.Lifting_Validity_From2__c = null;
                        }
                        //START - Rahul Sharma | Date - 11-Nov-2020 : Refresh live online volume for tranche 2.
                        Decimal dailyVol = atpRecords.ATP2_Live__c;
                        Decimal minDailyVol = atpRecords.Min_Daily_Split_Vol_ATP2__c;
                        Decimal splitVol = atpRecords.Split_Volume_Per_ATP2__c;
                        Decimal minOnlineVol = atpRecords.Min_Online_Volume_ATP2__c;
                        Decimal maxOnlineVol = atpRecords.Max_Online_Volume_ATP2__c;   
                        atpRecords.Live_Online_ATP2__c = RV_ATPTriggerHelper.getOnlineATP(dailyVol,
                                                                                          minDailyVol,
                                                                                          splitVol,
                                                                                          minOnlineVol,
                                                                                          maxOnlineVol); 
                        //END - Rahul Sharma | Date - 11-Nov-2020 : Refresh live online volume for tranche 2.
                    }   
                }
                if(atpRecords.Batch2__c == true){	  
                    if(atpRecords.ATP3_Live__c <> null){ 
                        if(atpRecords.ATP_MIN_29_61__c == null)atpRecords.ATP_MIN_29_61__c=0.0;
                        atpRecords.ATP3__c = atpRecords.ATP_MIN_29_61__c;
                        atpRecords.ATP3_Live__c = atpRecords.ATP3__c;
                        atpRecords.Sales_29_61__c = 0;
                        if(atpRecords.Lifting_Validity_From3__c != null && atpRecords.Lifting_Validity_From3__c == Date.Today()){
                            atpRecords.Lifting_Validity_From3__c = null;
                        }
                        //START - Rahul Sharma | Date - 11-Nov-2020 : Refresh live online volume for tranche 3.
                        Decimal dailyVol = atpRecords.ATP3_Live__c;
                        Decimal minDailyVol = atpRecords.Min_Daily_Split_Vol_ATP3__c;
                        Decimal splitVol = atpRecords.Split_Volume_Per_ATP3__c;
                        Decimal minOnlineVol = atpRecords.Min_Online_Volume_ATP3__c;
                        Decimal maxOnlineVol = atpRecords.Max_Online_Volume_ATP3__c;              
                        atpRecords.Live_Online_ATP3__c = RV_ATPTriggerHelper.getOnlineATP(dailyVol,
                                                                                          minDailyVol,
                                                                                          splitVol,
                                                                                          minOnlineVol,
                                                                                          maxOnlineVol); 
                        //END - Rahul Sharma | Date - 11-Nov-2020 : Refresh live online volume for tranche 3.
                    }                   
                }
            }
            finalupdateATPRecord.add(atpRecords);     
        }
        if(!finalupdateATPRecord.isEmpty()){
            if(RV_ATPTriggerHelper.recursiveValue == true){
                RV_ATPTriggerHelper.recursiveValue = false;
            }
            Database.SaveResult[] saveResultList  = Database.update(finalupdateATPRecord,false);
            for (Database.SaveResult sr : saveResultList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated AMV Scenario: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        RV_ClassException.getInstance();
                        RV_ClassException.insertExceptionRecord(String.valueof(err.getStatusCode()), err.getMessage(), 'RV_ATPAutoRefreshDailyBatch', 'execute','Exception');
                    }
                }
            }
        }
    }
}