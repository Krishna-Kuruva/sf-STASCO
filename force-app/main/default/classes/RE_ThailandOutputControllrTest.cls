@isTest
public class RE_ThailandOutputControllrTest {
  public static testmethod void testUtility()
  {
        RE_Market_Quotes__c createMQ1  = RE_UtilityClass.getMarketQuotes(23.6560,'USD','BBL','MID RON PREMIUM');
        RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(57.4658,'USD','BBL','Gasoil 0.05% S');
        RE_UtilityClass.getCountryCode('Thailand');
        RE_FX_Rates__c FXrate3 = RE_UtilityClass.createFXRecords('THB/USD',4.3520,'USD','THB','Thailand');
        List<RE_MY_Output__c> ls = new List<RE_MY_Output__c>();
        ls.add(new RE_MY_Output__c(RE_TH_AWD_DIFF__c=56.78,RE_TH_AWD_LDC__c = 231.21,RE_Region__c='Thailand',RE_Job_Run_Count__c=0));
        insert ls;
  }
}