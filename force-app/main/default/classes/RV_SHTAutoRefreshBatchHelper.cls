global class RV_SHTAutoRefreshBatchHelper {
    
    global static Map<Id,List<SHT__c>> CreateSHTMap(SHT__c shtVal,Map<Id,List<SHT__c>> shtMap){
        
        //Map<Id,List<SHT__c>> shtMap = new Map<Id,List<SHT__c>>();
        if(!shtMap.containsKey(shtVal.CreatedById)){
            shtMap.put(shtVal.CreatedById, new List<SHT__c>{shtVal});
        }else{
            List<SHT__c> newSHTList = shtMap.get(shtVal.CreatedById);
            newSHTList.add(shtVal);
            shtMap.put(shtVal.CreatedById , newSHTList);
            System.debug('&&&&&&&shtMap&&&&&'+shtMap);
        }
        return shtMap;
    }
    
    global static List<Messaging.SingleEmailMessage> createEmailMessage(Id userID,List<Messaging.SingleEmailMessage> allmsg){
        		String messageBody = '<html><body>Hi,<br/><br/>Please take action on pending deals<br/><br/>Best Regards,<br/>Revolution Admin</body></html>';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Pending SHT alert');
                mail.setHtmlBody(messageBody);
                mail.setTargetObjectId(userID);
        		mail.setSaveAsActivity(false);
        		allmsg.add(mail);
        		return allmsg;
    }
}