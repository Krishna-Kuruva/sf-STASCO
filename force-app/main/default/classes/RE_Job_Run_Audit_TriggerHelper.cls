public class RE_Job_Run_Audit_TriggerHelper { 
    public static Boolean checkCountry(List<RE_Job_Run_Audit__c> jraList){
        Boolean isEastData = false;
        for(RE_Job_Run_Audit__c jrdata : jraList){
            if(jrdata.RE_Job_Type__c == 'Malaysia Output' || jrdata.RE_Job_Type__c == 'Singapore Output' || jrdata.RE_Job_Type__c == 'SG Midday Output'  || jrdata.RE_Job_Type__c == 'Malaysia AMV Output' 
              || jrdata.RE_Job_Type__c == 'Thailand Output' || jrdata.RE_Job_Type__c == 'Thailand AMV Output' || jrdata.RE_Job_Type__c == 'CustomerOps Output'  || jrdata.RE_Job_Type__c == 'New Contract Pricing Output' 
              || jrdata.RE_Job_Type__c == 'Philippines Output'  || jrdata.RE_Job_Type__c == 'Philippines W-1 Output'  || jrdata.RE_Job_Type__c == 'Philippines M-1 Output' || jrdata.RE_Job_Type__c == 'PH Customer Opps' 
              || jrdata.RE_Job_Type__c == 'PH Customer Opps CBU')
                isEastData = true;
        }
        return isEastData;
    }
    public void onBeforeJobRunAudit(List<RE_Job_Run_Audit__c> jraList, Map<Id,RE_Job_Run_Audit__c> jraMap){
        if(!System.isScheduled()){
            System.debug('Not Schedule');
            RE_ExternalTriggerHelper.mopsDataTracker();
            RE_ExternalTriggerHelper.fxDataTracker();
        }   
        String jsonString = json.serialize(jraList);
        runcostjob(jsonString);        
    } 
    @future
    public static void runcostjob(String jsonString){
        List<RE_Job_Run_Audit__c> jraList = (List<RE_Job_Run_Audit__c>)Json.deserialize(jsonString,List<RE_Job_Run_Audit__c>.class);
        for(RE_Job_Run_Audit__c jra : jraList){
            if(jra.RE_Job_Type__c == 'Malaysia Output'){
                Boolean resultMY = false;
                RE_MY_CostCalculation mycost = new RE_MY_CostCalculation();
                resultMY = mycost.lineItemsCalculation(jra);
                if(resultMY)
                {                    
                    RE_OutputDataFormation optdata = new RE_OutputDataFormation(jra.RE_Job_Type__c);    
                    // MY Data Analysis Charting(PBI#1448628) - Start
                    // Processing MY Data Analysis CBU Report for MY CBU Generation
                    if(!Test.isRunningTest())
                    { 
                        // Get all old RE MY Data Analysis Scheduled Job for abort
                        for(CronTrigger job : [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType 
                                               FROM CronTrigger WHERE CronJobDetail.Name Like 'RE MY Data Analysis_%'])
                        {
                            try
                            {
                                System.abortJob(job.Id); 
                            }
                            catch(Exception e){
                                System.debug('line-'+e.getLineNumber()+e.getMessage());
                                RV_ClassException.insertExceptionRecord('RE_MY_Data_Analysis-AbortScheduledJobs',e.getMessage()+e.getLineNumber()+job.Id,'RE_MY_DataAnalysisReportScheduler','RE_MY_Data_Analysis-AbortScheduledJobs','Exception');                                                    
                            }          
                        }
                        
                        datetime dt = system.now().addMinutes(30);                        
                        String day = string.valueOf(dt.day());
                        String month = string.valueOf(dt.month());
                        String hour = string.valueOf(dt.hour());
                        String minute = string.valueOf(dt.minute() + 1);
                        String second = string.valueOf(dt.second());
                        String year = string.valueOf(dt.year());
                        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
                        RE_MY_DataAnalysisReportScheduler MyJob = new RE_MY_DataAnalysisReportScheduler();
                        String jobID2 = System.schedule('RE MY Data Analysis_' + strSchedule, strSchedule, MyJob);                 
                    }      
                    // MY Data Analysis Charting(PBI#1448628) - End
                }
            }
            else if(jra.RE_Job_Type__c == 'Singapore Output'){
                Boolean resultSG = false;
                RE_SG_CostCalculation sgcost = new RE_SG_CostCalculation();
                resultSG = sgcost.lineItemsCalculation(jra);
                 if(resultSG)
                     RE_OutputDataFormation sgOptdata = new RE_OutputDataFormation(jra.RE_Job_Type__c);
            }
            else if(jra.RE_Job_Type__c == 'SG Midday Output'){
                 Boolean resultSGMid = false;
                 RE_SG_CostCalculation sgcost = new RE_SG_CostCalculation();
                 resultSGMid = sgcost.lineItemsCalculation(jra);
                 if(resultSGMid)
                     RE_OutputDataFormation sgOptdata = new RE_OutputDataFormation(jra.RE_Job_Type__c);
            }
            else if(jra.RE_Job_Type__c == 'Malaysia AMV Output'){
                Boolean resultSGMid = false;
                RE_MY_AMVCalculationController amvcost = new RE_MY_AMVCalculationController();
                amvcost.lineItemsCalculation(jra);                
            }
             else if(jra.RE_Job_Type__c == 'Thailand Output'){
                RE_TH_CostCalculation thCost = new RE_TH_CostCalculation();
                thCost.lineItemsCalculation(jra);   
                RE_OutputDataFormation sgOptdata = new RE_OutputDataFormation(jra.RE_Job_Type__c);                                        

            }
            else if(jra.RE_Job_Type__c == 'Thailand AMV Output'){
                RE_TH_AMVCalculationController amvcost = new RE_TH_AMVCalculationController();
                amvcost.lineItemsCalculation(jra);                
            }
            else if(jra.RE_Job_Type__c == 'CustomerOps Output'){
                //RE_MY_CustOpsCalculationController.createfinalPriceBookData(jra);
                RE_MY_CustOpsCalculationController.generateDailyData(jra);                                       

            }
            else if(jra.RE_Job_Type__c == 'New Contract Pricing Output'){
               // RE_MY_CustOpsCalculationController.newContractfinalPriceBookData(jra);  
                RE_MY_CustOpsCalculationController.newPriceBookToMidDay(jra);
            }
            else if(jra.RE_Job_Type__c == 'Philippines Output'){
                Boolean resultMY = false;
                RE_PH_CostCalculation phcost = new RE_PH_CostCalculation('D-1');
                resultMY = phcost.lineItemsCalculation(jra);
                Id recordTypeph = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId() ;
				RE_MY_CostPrice_TriggerHelper.costDataTracker('D-1', recordTypeph);
                if(resultMY){
                    phcost.phMTDWTDDataCreation('WTD');
                    RE_PH_CostCalculation phcostwtd = new RE_PH_CostCalculation('WTD');
                    phcostwtd.lineItemsCalculation(jra);
                    phcost.phMTDWTDDataCreation('MTD');
                    RE_PH_CostCalculation phcostmtd = new RE_PH_CostCalculation('MTD');
                    phcostmtd.lineItemsCalculation(jra);
                }
            }            
            else if(jra.RE_Job_Type__c == 'Philippines W-1 Output'){
                Boolean resultMY = false;
                RE_PH_CostCalculation phcost = new RE_PH_CostCalculation('W-1');
                resultMY = phcost.lineItemsCalculation(jra);
                Id recordTypeph = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId() ;
				RE_MY_CostPrice_TriggerHelper.costDataTracker('W-1', recordTypeph);
            }            
            else if(jra.RE_Job_Type__c == 'Philippines M-1 Output'){
                Boolean resultMY = false;
                RE_PH_CostCalculation phcost = new RE_PH_CostCalculation('M-1');
                resultMY = phcost.lineItemsCalculation(jra);
                Id recordTypeph = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId() ;
				RE_MY_CostPrice_TriggerHelper.costDataTracker('M-1', recordTypeph);
            }     
             else if(jra.RE_Job_Type__c == 'PH Customer Opps'){
               RE_PH_AspriedUC3.generateDailyPHdata(jra);
            }  
        }
    }
}