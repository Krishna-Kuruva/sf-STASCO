@isTest
public class RV_SP_Reuters_Live_Batch_Test {

    
     @testSetup 
  public static void setup() {

        
        Reuters_ICE_Calculation__c setting = new Reuters_ICE_Calculation__c();
		setting.Name = 'LGO';
        setting.Display_Name__c = 'ICE LCO Brent Crude Oil (Ask)';
        setting.ProdDiff_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
		setting.Quote_Name__c = 'Brent Crude';
        setting.Product_Differential__c=true;
        setting.frequency__c = 'Live';
        insert setting;
        
        Reuters_ICE_Calculation__c setting1 = new Reuters_ICE_Calculation__c();
		setting1.Name = 'PJK05';
        setting1.Display_Name__c = 'GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
		setting1.Quote_Name__c = 'GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        setting.Product_Differential__c=true;
        setting1.Gelt_Other_Currency__c=true;
        setting1.frequency__c = 'Daily';
        insert setting1;
        
        Reuters_Quotes__c objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objBrentEOD.Quote_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        objBrentEOD.Unit_Of_Measure__c = 'L';
        insert objBrentEOD;

        
    objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objBrentEOD.Quote_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        objBrentEOD.Unit_Of_Measure__c = 'L';
        insert objBrentEOD;
      objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objBrentEOD.Quote_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        objBrentEOD.Unit_Of_Measure__c = 'L';
        insert objBrentEOD;
        
 objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.Quote_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        objBrentEOD.Unit_Of_Measure__c = 'L';
        insert objBrentEOD;
      
      objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.Quote_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        objBrentEOD.Unit_Of_Measure__c = 'L';
        insert objBrentEOD;
    }
    
   
public  static testMethod void createReutersData()
{
     Reuters_Quotes__c  objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.Quote_Display_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        objBrentEOD.Unit_Of_Measure__c = 'L';
    	objBrentEOD.Frequency__c='Daily';
        insert objBrentEOD;
         objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.Quote_Display_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        objBrentEOD.Unit_Of_Measure__c = 'L';
    	objBrentEOD.Frequency__c='Daily';
        insert objBrentEOD;
         objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.Quote_Display_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        objBrentEOD.Unit_Of_Measure__c = 'L';
    	objBrentEOD.Frequency__c='Daily';
        insert objBrentEOD;
    	/*13th_July_2021_adding reuter quote for additional test scenario_DHARAM_Start*/
    	objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.Quote_Display_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
    	objBrentEOD.Pricing_Date__c = Date.today().addDays(-1);
        objBrentEOD.Unit_Of_Measure__c = 'L';
    	objBrentEOD.Frequency__c='Daily';
        insert objBrentEOD;
    	/*adding reuter quote for test scenario_DHARAM_End*/
    
 Test.startTest();
       RV_SP_Reuters_Live_Schedule schedule=new RV_SP_Reuters_Live_Schedule();
       RV_SP_Reuters_Live_Schedule.executeReutersBatch();
    //Fix_PBI_489251_26052020_Lakshmi_Starts
    DateTime lastpickedRecordDate=System.now();
    Map<String,String> mapofQuoteAndFrequency=RV_SP_Reuters_Live_Batch_Helper.getMapOFQuoteNameAndFrequency();
    /*13th_July_2021_adding reuter quote for additional test scenario_DHARAM_Start*/
    Map<String, RV_SP_Reuters_Live_Batch_Helper.QuoteDatesWrapper> mapOfQuoteMonthAndReuters=RV_SP_Reuters_Live_Batch_Helper.fetchDailyQuotes();
    //commented below map as it's not used
    //Map<String,DateTime> mapOfQuoteMonthAndReuters=RV_SP_Reuters_Live_Batch_Helper.getListOfData(lastpickedRecordDate,mapofQuoteAndFrequency);
    /*Dharam_End_ */
    //Fix_PBI_489251_26052020_Lakshmi_Ends 
    //AdditionalTestCoverage_12Jun2019_Soumyajit starts
    CronTrigger[] ct = [SELECT Id FROM CronTrigger where CronJobDetail.name = 'CloneAndDelete Daily and Delete Live Data' limit 1];
    if(ct.size()==0)
        RV_SP_Reuters_Live_Schedule.cronSchedule();
    //TestClassCoverage_PH3SP14_24Jul2019_Soumyajit ends
    List<Reuters_Quotes__c> listOfQuotesToCloneDaily = [select id,CreatedDate,Valid_To_Date__c
                                                        ,Valid_From_Date__c,Quote_Display_Name__c,Valid_Month__c,Quote_Name__c,Price__c
                                                        ,Frequency__c,Pricing_Date__c,Unit_Of_Measure__c from Reuters_Quotes__c
                                                       limit 1];
    //RV_SP_Reuters_Live_Batch_Helper.cloneAndDeleteDailyRec(listOfQuotesToCloneDaily);//Fix_PBI_489251_26052020_Lakshmi
    RV_SP_Reuters_Live_Batch_Helper.cloneAndDeleteDailyRec(listOfQuotesToCloneDaily,listOfQuotesToCloneDaily,mapOfQuoteMonthAndReuters,mapofQuoteAndFrequency);
    List<Reuters_Quotes__c> listOfQuotesToDeleteLive = [select id,CreatedDate,Valid_To_Date__c
                                                        ,Valid_From_Date__c,Quote_Display_Name__c,Valid_Month__c,Quote_Name__c,Price__c from Reuters_Quotes__c
                                                       limit 1];
    RV_SP_Reuters_Live_Batch_Helper.deleteLiveRec(listOfQuotesToDeleteLive);
    //AdditionalTestCoverage_12Jun2019_Soumyajit ends
    
Test.stopTest();

}
    
    
    
}