@isTest
   public class RE_TH_MailControllerTest {
    static testmethod void prepareCovamoUrlTest(){
        
        List<RE_MY_Output__c> costCovs = new List<RE_MY_Output__c>();
        RE_MY_Output__c objRef = new RE_MY_Output__c(RE_Depot_Name__c = 'Chongnonsri',RE_TH_AWD_DIFF__c= 4.5,RE_TH_AWD_LDC__c=43.2,RE_TH_Com_B0_DIFF__c=7.3,RE_TH_Com_B0_LDC__c=34.23,RE_TH_Com_B7_DIFF__c=12.23,RE_TH_Com_B7_LDC__c=37.252,RE_TH_Com_B10_DIFF__c=34.54,RE_TH_Com_B10_LDC__c=85.23);
        costCovs.add(objRef);
        
        String userId                                 = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        APXTConga4__Conga_Template__c   template      = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Thailand Output Template');
        APXTConga4__Conga_Email_Template__c etemplate = new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Thailand Output Email Template');
        APXTConga4__Conga_Merge_Query__c  emailId     = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Thailand Output Email Ids');
        
        insert costCovs;
        insert template;
        insert etemplate;
        insert emailId;
        
        List<RE_TH_Query_Data__c> CustomSettingList = new List<RE_TH_Query_Data__c>(); 
        RE_TH_Query_Data__c CustomSetting1 = new RE_TH_Query_Data__c();
        CustomSetting1.Name = 'Query1'; 
        CustomSetting1.RE_TH_Query_Name__c= 'Thailand LDC Output Query'; 
        CustomSettingList.add(CustomSetting1);
        
        RE_TH_Query_Data__c CustomSetting2 = new RE_TH_Query_Data__c();
        CustomSetting2.Name = 'Query2'; 
        CustomSetting2.RE_TH_Query_Name__c= 'Thailand FX Rate Query'; 
        CustomSettingList.add(CustomSetting1);
               
        Test.startTest();      
        PageReference pageRef = Page.RE_TH_Mail;
        pageRef.getParameters().put('id', String.valueOf(costCovs[0].id));
        Test.setCurrentPage(pageRef);
       // ApexPages.StandardController sc = new ApexPages.standardController(costCovs[0]);
        RE_TH_MailController controller = new RE_TH_MailController();
        controller.prepareThailandUrl();
        Test.stopTest();
    }
    
}