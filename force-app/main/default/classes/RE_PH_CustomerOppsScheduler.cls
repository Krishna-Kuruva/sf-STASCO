public class RE_PH_CustomerOppsScheduler implements Schedulable {         
    public void execute(SchedulableContext ctx) {
        RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
        insertJob.RE_Run_Type__c='Automate';
        insertJob.RE_Job_Type__c = 'PH Customer Opps CBU';
        insertJob.RE_User__c=UserInfo.getUserId();
        insertJob.RE_Run_Time__c=DateTime.now();
        insertJob.RE_Job_Run_Count__c = 0;
        try{
            //Create daily records
            RE_PH_AspriedUC3.createAspriedUC3(true);
            RE_PH_RPG.calculateRPGContract(true);
            RE_PH_GPC_Calc.creategpc(true); 
            
            insertJob.RE_IsSuccess__c = True;
            insertJob.RE_Exception__c = '';
            insertJob.RE_Job_Status__c = 'Completed';
            Insert insertJob;
        }
        catch(Exception e){            
             
            insertJob.RE_IsSuccess__c = false;
            insertJob.RE_Job_Status__c = 'Failed';
            insertJob.RE_Exception__c = ''+e.getMessage() + '\n ' + e.getStackTraceString();
            Insert insertJob;
        }  
    }
}