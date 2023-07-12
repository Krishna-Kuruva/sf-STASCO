/*****************************************************************************************************
ClassName   :   TCP_DeliveryNoteScheduler
Description :   This class manages schedules for Delivery Note data. Execute method will get all customers and split into set of 45 and calls Queueable class.
*****************************************************************************************************/

global with sharing class TCP_DeliveryNoteScheduler implements Schedulable {       
    public final string tcp_AccRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    global void execute(SchedulableContext ctx) {
        try{
            //get customer details
            list<Account> tcpCustomersList = database.query('SELECT id, AccountNumber, GSAP_Account_Number__c FROM Account where recordtypeid =: tcp_AccRecTypeid and GSAP_Account_Number__c != null and Customer_Type__c =\'' + String.escapeSingleQuotes('Sold To') + '\' AND Active__c = True');
            List<set<string>> accountIdInSplits = new List<set<string>>();
            Integer size =tcpCustomersList.size();
            Integer splitSize=45;
            Integer count=0,index=0;
            set<string> tempSet = new set<string>();
            while(index < size) {
                tempSet.add(tcpCustomersList.get(index++).id);
                ++count;
                if(count == splitSize) {
                    accountIdInSplits.add(tempSet);
                    tempSet=new set<string>();
                    count = 0;
                }
            }
            if(!tempSet.isEmpty()) {
                accountIdInSplits.add(tempSet);
            }
            for(Integer i=0;i<accountIdInSplits.size();i++){
                System.enqueueJob(new TCP_DeliveryNoteQueueable(accountIdInSplits.get(i),i) );
            }
        }
        catch(Exception e){
            system.debug('Exception in TCP_DeliveryNoteScheduler class : '+e.getMessage()+'line : '+e.getLineNumber());
            TCP_ExceptionLogClass.insertExceptionRecord('Scheduler',e.getMessage(),'TCP_DeliveryNoteScheduler','execute','Exception');

        }
    }        
}