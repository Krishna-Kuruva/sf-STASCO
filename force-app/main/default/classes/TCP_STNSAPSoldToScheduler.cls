/***** TCP STNSAP SoldTo ShipTo Service 1 Schedular  ***********/
global class TCP_STNSAPSoldToScheduler implements Schedulable { 
	global void execute(SchedulableContext ctx) { 
		try{
		//get the sales area records
		list<TCP_Sales_Area__c> salesAreaList = database.query('SELECT Id, Name, Distribution_Channel__c, Division__c, Sales_Org__c FROM TCP_Sales_Area__c WHERE Sales_Org__c != null AND Distribution_Channel__c != null AND Division__c != null');
		
            List<set<string>> salesAreaIdInSplits = new List<set<string>>();
            Integer size =salesAreaList.size();
            Integer splitSize=45;
            Integer count=0,index=0;
            set<string> tempSet = new set<string>();
            while(index < size) {
                tempSet.add(salesAreaList.get(index++).id);
                ++count;
                if(count == splitSize) {
                    salesAreaIdInSplits.add(tempSet);
                    tempSet=new set<string>();
                    count = 0;
                }
            }
            if(!tempSet.isEmpty()) {
                salesAreaIdInSplits.add(tempSet);
            }
            for(Integer i=0;i<salesAreaIdInSplits.size();i++){                
                System.enqueueJob(new TCP_STNSAPSoldToQueueable(salesAreaIdInSplits.get(i),i) );
            }
		
		}
		catch(Exception e){
			system.debug('Exception in TCP_STNSAPSoldToScheduler class : '+e.getMessage()+'line : '+e.getLineNumber());
            TCP_ExceptionLogClass.insertExceptionRecord('STNSAP SoldTo Scheduler Exception',e.getMessage(),'TCP_STNSAPSoldToScheduler','execute','Exception');         
		}
	}
}