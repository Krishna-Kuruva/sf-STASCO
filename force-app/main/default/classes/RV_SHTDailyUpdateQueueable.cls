global class RV_SHTDailyUpdateQueueable implements Queueable {
    /*
	Version : 0.0
	Author	: Soumyajit
	Date	: 26-Nov-2019
	Details	: SHT Daily Update batch - PBI:199964
	*/
    global void execute(QueueableContext q)
    {
        String shtQry = 'select id, Status__c, Cancellation_Reason__c '
            			+ ' from sht__c'
            			+ ' where Status__c = \'Saved\'';
        try{
            List<sht__c> shtLst = Database.query(shtQry);
            if(shtLst.size()>0)
            {
                for(sht__c s : shtLst)
                {
                    s.Status__c = 'Expired';
                	s.Cancellation_Reason__c='Saved Deal';
                }
                
                update shtLst;
            }
            
        }
        Catch (Exception e)
        {
            System.debug('Error in RV_SHTDailyUpdateQueueable' + e.getMessage());
        }
    }
}