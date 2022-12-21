trigger RV_ReutersQuoteTrigger on Reuters_Quotes__c (before insert ,before update,after insert, after update) {
    
    if ((Trigger.isInsert && Trigger.isBefore) || (Trigger.isUpdate && Trigger.isBefore)){ 
        
        RV_ReutersCalculationHelper.beforeInsetUpdate();
        
    }
    
    
    
    if (Trigger.isInsert && Trigger.isAfter || Trigger.isUpdate && Trigger.isAfter){
        
        RV_ReutersCalculationHelper.afterUpdateInsert();  
         RV_ReutersCalculationHelper.stopcreatingDailyQuotes(Trigger.new);
       
    }
    
    
    
}