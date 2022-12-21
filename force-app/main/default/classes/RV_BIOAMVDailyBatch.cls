/*****************************************************************************
@Name:  RV_BIOAMVDailyBatch     
@=========================================================================
@Purpose: BIO AMV Batch class for calculating Prompt_Valid_From__c,Prompt_valid_To__c,Future_Valid_From__c,Future_Valid_To__c dates
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      12/04/2018         INITIAL DEVELOPMENT

******************************************************************************/
public class RV_BIOAMVDailyBatch implements Queueable{
	
   public void execute(QueueableContext context){
       String query = 'SELECT id,Prompt_Valid_From__c,Prompt_valid_To__c,Override_Date__c,Future_Valid_From__c,Future_Valid_To__c '+
          			 'from Bio_AMVs__c';//Fix_PBI-513549_12Jun2020_Lakshmi
       List<Bio_AMVs__c> updateBioAMVLst = new List<Bio_AMVs__c>();
       List<Bio_AMVs__c> bioAMVLst = Database.query(query);
       if(!bioAMVLst.isEmpty()){
           
             for(Bio_AMVs__c bioAMV : bioAMVLst){
                 
                bioAMV.Prompt_Valid_From__c = System.today();
                 //Fix_PBI-513549_12Jun2020_Lakshmi_Starts
                 if(bioAMV.Override_Date__c !=null)
            	 bioAMV.Prompt_valid_To__c = RV_BIOAMVsTriggerHelper.validToPrompt(System.today(),bioAMV.Override_Date__c);
            	 else
                 bioAMV.Prompt_valid_To__c = RV_BIOAMVsTriggerHelper.validToPromptnooverride(System.today());
                 if(bioAMV.Prompt_valid_To__c >  bioAMV.Override_Date__c)
           		 bioAMV.Override_Date__c = null;
                 //Fix_PBI-513549_12Jun2020_Lakshmi_Ends
                bioAMV.Future_Valid_From__c = RV_BIOAMVsTriggerHelper.validFromFuture(bioAMV.Prompt_valid_To__c);
                bioAMV.Future_Valid_To__c = RV_BIOAMVsTriggerHelper.validToFuture(bioAMV.Prompt_valid_To__c);
                updateBioAMVLst.add(bioAMV);
             }
           
             try{
               update updateBioAMVLst;
             }catch(Exception e){
               System.debug('#######Exception%#######'+e);
             }
       }
        
   }
 
}