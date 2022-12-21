/*****************************************************************************
@Name:  RV_BIOAMVsTriggerHelper     
@=========================================================================
@Purpose: BIO AMV Trigger Helper for calculating Prompt_Valid_From__c,Prompt_valid_To__c,Future_Valid_From__c,Future_Valid_To__c dates
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      12/04/2018         INITIAL DEVELOPMENT

******************************************************************************/
public class RV_BIOAMVsTriggerHelper {
    
    //On Before insert
    public static void onBeforeInsert(List<Bio_AMVs__c> lstBioAMV){
        
        for(Bio_AMVs__c bioAMV : lstBioAMV){
            bioAMV.Prompt_Valid_From__c = System.today();
            //Fix_PBI-513549_12Jun2020_Lakshmi_Starts
            //bioAMV.Prompt_valid_To__c = validToPrompt(System.today());
            if(bioAMV.Override_Date__c !=null)
            	bioAMV.Prompt_valid_To__c = validToPrompt(System.today(),bioAMV.Override_Date__c);
            else
            	bioAMV.Prompt_valid_To__c = validToPromptnooverride(System.today());
            if(bioAMV.Prompt_valid_To__c >  bioAMV.Override_Date__c)
            bioAMV.Override_Date__c = null;
            //Fix_PBI-513549_12Jun2020_Lakshmi_Ends
            bioAMV.Future_Valid_From__c = validFromFuture(bioAMV.Prompt_valid_To__c);
            bioAMV.Future_Valid_To__c = validToFuture(bioAMV.Prompt_valid_To__c);
        }
    }
    
    //On Before update
    public static void onBeforeUpdate(List<Bio_AMVs__c> lstBioAMV){
        
        for(Bio_AMVs__c bioAMV : lstBioAMV){
            bioAMV.Prompt_Valid_From__c = System.today();
            //Fix_PBI-513549_12Jun2020_Lakshmi_Starts
            //bioAMV.Prompt_valid_To__c = validToPrompt(System.today());
            if(bioAMV.Override_Date__c !=null)
            	bioAMV.Prompt_valid_To__c = validToPrompt(System.today(),bioAMV.Override_Date__c);
            else
                bioAMV.Prompt_valid_To__c = validToPromptnooverride(System.today());
            if(bioAMV.Prompt_valid_To__c >  bioAMV.Override_Date__c)
            bioAMV.Override_Date__c = null;
            //Fix_PBI-513549_12Jun2020_Lakshmi_Ends
            bioAMV.Future_Valid_From__c = validFromFuture(bioAMV.Prompt_valid_To__c);
            bioAMV.Future_Valid_To__c = validToFuture(bioAMV.Prompt_valid_To__c);
        }
    }
    
     //Fix_PBI-513549_12Jun2020_Lakshmi_Starts
    //Calculating prompt valid To Date with Override Date
     public static Date validToPrompt(Date todaysDate,Date overridedate){
	    List<Date> dates = new List<Date>();
		date newDate;
		if(todaysDate > overridedate){
        date myDate = date.newInstance(todaysDate.year(),todaysDate.month(),todaysDate.day());
        newDate = myDate.addDays(60);
          }
         else{
		newDate = overridedate;
		}
        return newDate;
    }
    
    //Calculating prompt valid To Date when no override date
     public static Date validToPromptnooverride(Date todaysDate){
         date myDate = date.newInstance(todaysDate.year(),todaysDate.month(),todaysDate.day());
        date newDate = myDate.addDays(60);
        return newDate;
    }
    
    //Fix_PBI-513549_12Jun2020_Lakshmi_Ends
    
    //Calculating future valid from Date
    public static Date validFromFuture(Date validFromDate){
        
        Date m2 = validFromDate.addDays(1);
        return m2;
    }
    
    //Calculating Future valid To Date
    public static Date validToFuture(Date validFromDate){
		Date validToFuture =  date.newInstance(3999,12,31);       
        return validToFuture;
    }
}