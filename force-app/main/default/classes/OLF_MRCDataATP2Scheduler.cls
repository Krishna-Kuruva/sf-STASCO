global class OLF_MRCDataATP2Scheduler implements Schedulable {  
    
     	Set<Id> accountIdsFirstBatch = new Set<Id>();
        Set<Id > accountIdsSecondBatch = new Set<Id>();
        OLFWrapper.OlfTrancheWrap olfTrancheWrap = OLF_Utility.checkOLFConnectionStatus(OLF_DashboardApexController.global_liftingWindowTwo);
    	List<Set<Id>> accountIdInSplits = new List<Set<Id>>();
        OLFWrapper.ContractDateWindowWrap dateWrap = OLF_Utility.getContractDateWindow(olfTrancheWrap.startDay, olfTrancheWrap.endDay);
         String startDate = String.valueOf(dateWrap.contractStartDate);
        String endDate = String.valueOf(dateWrap.contractEndDate);
        //Added by Surbhi,Dt: 17-10-2022
        @TestVisible
        private DateTime testObjDT {get; set;}
        //Ended
    global void execute(SchedulableContext ctx) {
                List<Account> accounts = [Select Id from Account where RecordType.Name = 'Revolution Ship-To Account' AND Rv_Available_for_OLF__c = true and Has_MRC__c=true];
				    	List<Set<Id>> accountIdInSplits = new List<Set<Id>>();
	
       Integer size =accounts.size();
        Integer splitSize=Integer.valueOf(System.Label.OLF_Split_Size);
        Integer count=0,index=0;
        Set<Id> tempSet = new Set<Id>();
         while(index < size) {
                tempSet.add(accounts.get(index++).Id);
                ++count;
                if(count == splitSize) {
                    accountIdInSplits.add(tempSet);
                    tempSet=new Set<Id>();
                    count = 0;
                }
            }
            if(!tempSet.isEmpty()) {
                accountIdInSplits.add(tempSet);
            }
         System.debug('Account in splits'+ accountIdInSplits.size());
         olfTrancheWrap.tranche='ATP2';
         for(Integer i=0;i<accountIdInSplits.size();i++){
      		 System.enqueueJob(new OLF_MRCATP2Queueable(accountIdInSplits.get(i),olfTrancheWrap,dateWrap,startDate,endDate) );
          }
        //Commented by Surbhi
        // DateTime objDT = DateTime.newInstance(System.today(),Time.newInstance(Integer.valueOf(System.Label.OLF_Hour),Integer.valueOf(System.Label.OLF_Minute),0,0));       
        //Added by Surbhi, Dt: 17-10-2022
        DateTime objDT = Test.isRunningTest() ? testObjDT : DateTime.newInstance(System.today(),Time.newInstance(Integer.valueOf(System.Label.OLF_Hour),Integer.valueOf(System.Label.OLF_Minute),0,0));
        //Ended
            if(System.now() < objDT){
               // if(asyncJobs.size() <= 100){
               
                DateTime systime = System.now().addSeconds(15);
              
                String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();

                System.schedule('ATP2 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP2Scheduler());
            
               }else{
                String qryBatchName = '%' + 'ATP2 Scheduler' + '%';
                 CronTrigger[] ct = [select id, CronJobDetailId, CronJobDetail.name, NextFireTime, State, CronExpression from CronTrigger 
                                                            where NextFireTime != null and state != 'DELETED' and CronJobDetail.name like :qryBatchName];
                
                for(CronTrigger cronT : ct){
                    System.abortJob(cronT.id);
                }
                OLF_DashboardApexController.userActivateInactivateFromScreen('STOP');
            }
          
    }
}