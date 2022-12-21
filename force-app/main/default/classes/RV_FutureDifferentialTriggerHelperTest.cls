@isTest
public class RV_FutureDifferentialTriggerHelperTest {

    @testSetup
    public static void setIntialData()
    {
               Future_Differential__c futureRec=new Future_Differential__c();
       futureRec.Diff_Value__c=40;
        futureRec.Grade__c='AGO B7';
      futureRec.Supply_Type__c='AGO';
       futureRec.Valid_From__c=System.today();
       futureRec.Valid_From__c=System.today()+1;
       insert futureRec;
       
        futureRec=new Future_Differential__c();
       futureRec.Diff_Value__c=40;
        futureRec.Grade__c='AGO B7';
       
       futureRec.Supply_Type__c='Cargo';
       futureRec.Valid_From__c=System.today();
       futureRec.Valid_From__c=System.today()+1;
       insert futureRec;
    }
    
    //AdditionalTestCoverage_14Jun2019_Lakshmi_starts 
    /* public static  testMethod void insertFuture()
   {
       List<Future_Differential__c>futures=new List<Future_Differential__c>();
       Future_Differential__c futureRec=new Future_Differential__c();
       futureRec.Diff_Value__c=40;
        futureRec.Grade__c='AGO B7';
      futureRec.Supply_Type__c='AGO';
       futureRec.Valid_From__c=System.today();
       futureRec.Valid_From__c=System.today()+1;
       insert futureRec;
       
        futureRec=new Future_Differential__c();
       futureRec.Diff_Value__c=40;
        futureRec.Grade__c='AGO B7';
       
       futureRec.Supply_Type__c='Cargo';
       futureRec.Valid_From__c=System.today();
       futureRec.Valid_From__c=System.today()+1;
       insert futureRec;
       
       
       
   }*/
    @isTest
    static void doTest()
    {
        List<Future_Differential__c> onBeforeNewLst = [SELECT id,Diff_Value__c,Name,Grade__c,SubGradeSupplyType__c,Supply_Type__c,Valid_From__c,Valid_To__c
                from Future_Differential__c];
        
        List<Future_Differential__c> onUpdLst = onBeforeNewLst;
        for(Future_Differential__c futureRec:onUpdLst)
        {
        futureRec.Valid_From__c=System.today();
       futureRec.Valid_From__c=System.today()+1;
            
        update onUpdLst;
        
        Map<String,List<Future_Differential__c>> mapOfInsertedFutDif = new Map<String,List<Future_Differential__c>>();
       mapOfInsertedFutDif = RV_FutureDifferentialTriggerHelper.createMap(onUpdLst);
        RV_FutureDifferentialTriggerHelper.validationRule(onBeforeNewLst,mapOfInsertedFutDif);
    }
    
    
}
    //AdditionalTestCoverage_14Jun2019_Lakshmi_Ends
}