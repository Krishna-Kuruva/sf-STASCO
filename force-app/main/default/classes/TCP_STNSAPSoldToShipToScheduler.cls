/***** TCP STNSAP SoldTo ShipTo Service 2 Schedular  ***********/
global class TCP_STNSAPSoldToShipToScheduler implements Schedulable {
    public final string tcp_AccRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    global void execute(SchedulableContext ctx) {
        try{
            //get customer details
            //list<Account> tcpCustomersList = database.query('SELECT id, AccountNumber FROM Account WHERE recordtypeid =: tcp_AccRecTypeid AND AccountNumber != null AND TCP_STNSAP_ExternalId1__c != null AND Sales_Area__c != null AND Customer_Type__c =\'' + String.escapeSingleQuotes('Sold To') + '\'');
            list<Account> tcpCustomersList = [SELECT id, Active__c , AccountNumber, Customer_Type__c, Sales_Area__c, TCP_STNSAP_ExternalId1__c , TCP_STNSAP_ExternalId2__c  FROM Account WHERE recordtypeid =: tcp_AccRecTypeid AND AccountNumber != null AND TCP_STNSAP_ExternalId1__c != null AND Sales_Area__c != null AND Customer_Type__c IN ('Sold To')];
            List<list<string>> accountIdInSplits = new List<list<string>>();
            Integer size =tcpCustomersList.size();
            Integer splitSize=45;
            Integer count=0,index=0;
            list<string> tempSet = new list<string>();
            while(index < size) {
                tempSet.add(tcpCustomersList.get(index++).id);
                ++count;
                if(count == splitSize) {
                    accountIdInSplits.add(tempSet);
                    tempSet=new list<string>();
                    count = 0;
                }
            }
            if(!tempSet.isEmpty()) {
                accountIdInSplits.add(tempSet);
            }
            for(Integer i=0;i<accountIdInSplits.size();i++){
                System.enqueueJob(new TCP_STNSAPSoldToShipToQueueable(accountIdInSplits.get(i),i) );
            }
        }
        catch(Exception e){
            system.debug('Exception in TCP_STNSAPSoldToShipToScheduler class : '+e.getMessage()+'line : '+e.getLineNumber());
            TCP_ExceptionLogClass.insertExceptionRecord('STNSAP SoldTo ShipTo Queueable Exception',e.getMessage(),'TCP_STNSAPSoldToShipToScheduler','execute','Exception');          
        }
    } 
}