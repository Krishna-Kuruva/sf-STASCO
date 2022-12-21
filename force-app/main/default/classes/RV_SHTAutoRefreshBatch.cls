global class RV_SHTAutoRefreshBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){            
        Datetime dt=DateTime.now();
        //String dateTimeFormat = dt.addMinutes(-5).formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String query = 'Select Id, Status__c, CreatedDate ,CreatedById from SHT__c where Status__c = \'Saved\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SHT__c> scope){    
        List<SHT__c> shtList = new List<SHT__c>();
        Datetime dt=DateTime.now();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Map<Id,List<SHT__c>> shtMap = new Map<Id,List<SHT__c>>();
        for(SHT__c sht: scope){
            Long diff = dt.getTime() - sht.CreatedDate.getTime();
            Long mins = diff / 60000;
            if(sht.Status__c == 'Saved' && mins >= 5){
                
                shtMap = RV_SHTAutoRefreshBatchHelper.CreateSHTMap(sht,shtMap);//Map contains users as key and list of SHT as values
                //sht.Status__c = 'Auto-Completed';
                shtList.add(sht);
            }
        }
        System.debug('------shtList-------'+shtList);
        if(!shtMap.isEmpty()){
            for(Id userId : shtMap.keyset()){
                allmsg = RV_SHTAutoRefreshBatchHelper.createEmailMessage(userId,allmsg); 
            }
        }
        System.debug('-----------'+allmsg);
        if(!allmsg.isEmpty()){
           // Database.SaveResult[] saveResultList  = Database.update(shtList,false);
            try{
                Messaging.sendEmail(allmsg,false);
            }catch(Exception e){
                System.debug('-----------'+e);
            }
        }
    }
    
    
    global void finish(Database.BatchableContext BC){
        system.debug('---------inside finish method--------');
        Datetime sysTime = System.now();
        sysTime = sysTime.addMinutes(2);

        String chron_exp = '' + 0 + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + 
            				sysTime.month() + ' ? ' + sysTime.year();
        
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('New Schedule' + sysTime.getTime(),chron_exp, new RV_SHTAutoRefreshScheduler());
    }
}