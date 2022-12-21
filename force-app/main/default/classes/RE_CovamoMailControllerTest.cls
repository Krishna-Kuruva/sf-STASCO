@isTest
   public class RE_CovamoMailControllerTest {   
    static testmethod void prepareCovamoUrlTest(){
        
        List<Rev_Covamo_Header__c> costCovs = new List<Rev_Covamo_Header__c>();
        Rev_Covamo_Header__c objRef = new Rev_Covamo_Header__c(Customer_Name__c = 'ABC', Contract_Name__c = 'xyz',Valuation_Start_Year__c=System.today(),Valuation_End_Year__c=System.today(),
                                                               Inflation_Rate__c=3,VAT_Percentage__c=4,Payment_Days__c=5);
        costCovs.add(objRef);
        
        String userId                                 = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        APXTConga4__Conga_Template__c   template      = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Covamo Template');
        APXTConga4__Conga_Email_Template__c etemplate = new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Covamo Email Template');
        APXTConga4__Conga_Merge_Query__c  emailId     = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Covamo Email Ids');
        
        insert costCovs;
        insert template;
        insert etemplate;
        insert emailId;
        
        List<RE_Covamo_Query__c> CustomSettingList = new List<RE_Covamo_Query__c>(); 
        RE_Covamo_Query__c CustomSetting1 = new RE_Covamo_Query__c();
        CustomSetting1.Name = 'Query1'; 
        CustomSetting1.Query__c= 'Covamo Header Query'; 
        CustomSettingList.add(CustomSetting1);
        
        RE_Covamo_Query__c CustomSetting2 = new RE_Covamo_Query__c();
        CustomSetting2.Name = 'Query2'; 
        CustomSetting2.Query__c= 'Covamo Key Assumptions Query'; 
        CustomSettingList.add(CustomSetting1);
               
        Test.startTest();      
        PageReference pageRef = Page.RE_Covamo_Mail;
        pageRef.getParameters().put('id', String.valueOf(costCovs[0].id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(costCovs[0]);
        RE_CovamoMailController controller = new RE_CovamoMailController(sc);
        controller.prepareCovamoUrl();
        Test.stopTest();
    }
    
}