/**************************************************************************************************
* Name: RE_CND_MailController_Test
* Object: RE_MY_CostPrice__c, RE_MY_Output__c
* Purpose: Conga solution for Revolution Canada Mail - Test Class
* Author: Sunidhi Pandey (sunidhi.pandey@shell.com)
* Create Date: 2021-11-02
* Modify History: 
* 2021-11-02		Sunidhi Pandey		Created
**************************************************************************************************/
@isTest
public class RE_CND_MailController_Test {
    static testmethod void mailcontrollertest(){
        List<RE_MY_Output__c> costCovs = new List<RE_MY_Output__c>();
         RE_MY_Output__c objRef = new RE_MY_Output__c(RE_CND_Rack_French__c = 'test',
                                                      RE_CND_Product_Group_French__c = 'testproduct',
                                                      RE_CND_Rack_English__c= 'testproductgroup',
                                                      RE_CND_Old_Value__c  = 24,
                                                      RE_CND_Change_Value__c = 34,
                                                      RE_CND_New_Value__c  = 42);
        costCovs.add(objRef);
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String userEmail     = UserInfo.getUserEmail();
        List<APXTConga4__Conga_Template__c> tempList = new List<APXTConga4__Conga_Template__c>();
		APXTConga4__Conga_Template__c template1 = new APXTConga4__Conga_Template__c();
        template1.APXTConga4__Name__c =  'Newrack4';
		tempList.add(template1);
        
        APXTConga4__Conga_Template__c template2 = new APXTConga4__Conga_Template__c();
        template2.APXTConga4__Name__c =  'Daily Rack Change Notification';
		tempList.add(template2);
		
		APXTConga4__Conga_Template__c template3 = new APXTConga4__Conga_Template__c();
        template3.APXTConga4__Name__c =  'NewBRPP';
		tempList.add(template3);
		
		APXTConga4__Conga_Template__c template4 = new APXTConga4__Conga_Template__c();
        template4.APXTConga4__Name__c =  'Rack Customer Notification';
		tempList.add(template4);
		
		APXTConga4__Conga_Template__c template5 = new APXTConga4__Conga_Template__c();
        template5.APXTConga4__Name__c =  'Canadiandailyracks';
		tempList.add(template5);
		
		APXTConga4__Conga_Template__c template6 = new APXTConga4__Conga_Template__c();
        template6.APXTConga4__Name__c =  'Canadiandailyracks7DAY';
		tempList.add(template6);
        
        APXTConga4__Conga_Template__c template7 = new APXTConga4__Conga_Template__c();
        template7.APXTConga4__Name__c =  'Pricing English';
		tempList.add(template7);
        
        APXTConga4__Conga_Template__c template8 = new APXTConga4__Conga_Template__c();
        template8.APXTConga4__Name__c =  'Prix en francais';
		tempList.add(template8);
        
        APXTConga4__Conga_Template__c template9 = new APXTConga4__Conga_Template__c();
        template9.APXTConga4__Name__c =  'Shell Rack Customer Notification';
		tempList.add(template9);
        
        APXTConga4__Conga_Template__c template10 = new APXTConga4__Conga_Template__c();
        template10.APXTConga4__Name__c =  'rack_prices';
		tempList.add(template10);
        
         APXTConga4__Conga_Template__c template11 = new APXTConga4__Conga_Template__c();
        template11.APXTConga4__Name__c =  'Branded';
		tempList.add(template11);
        
        APXTConga4__Conga_Template__c template12 = new APXTConga4__Conga_Template__c();
        template12.APXTConga4__Name__c =  'UnBranded';
		tempList.add(template12);
		
        APXTConga4__Conga_Template__c template13 = new APXTConga4__Conga_Template__c();
        template13.APXTConga4__Name__c =  'SFJ';
		tempList.add(template13);
        
        APXTConga4__Conga_Template__c template14 = new APXTConga4__Conga_Template__c();
        template14.APXTConga4__Name__c =  'canadian-rack-pricing';
		tempList.add(template14);        
        
        List<APXTConga4__Conga_Email_Template__c> etempList = new List<APXTConga4__Conga_Email_Template__c>();
		APXTConga4__Conga_Email_Template__c etemplate1 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate1.APXTConga4__Name__c = 'Internal Rack Notification';
		etempList.add(etemplate1);
        
		APXTConga4__Conga_Email_Template__c etemplate2 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate2.APXTConga4__Name__c = 'Shell Canada Rack Notification';
		etempList.add(etemplate2);
		
		APXTConga4__Conga_Email_Template__c etemplate3 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate3.APXTConga4__Name__c = 'Internal Shell Canada BRPP Notification';
		etempList.add(etemplate3);
		
		APXTConga4__Conga_Email_Template__c etemplate4 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate4.APXTConga4__Name__c = 'SFJ Rack Notification';
		etempList.add(etemplate4);
		
		APXTConga4__Conga_Email_Template__c etemplate5 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate5.APXTConga4__Name__c = 'Canadian Rack Prices';
		etempList.add(etemplate5);
		
		APXTConga4__Conga_Email_Template__c etemplate6 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate6.APXTConga4__Name__c = '7 DAY Canadian Rack Prices';
		etempList.add(etemplate6);
        
        APXTConga4__Conga_Email_Template__c etemplate7 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate7.APXTConga4__Name__c = 'Shell Canada - Branded Customer Notification';
		etempList.add(etemplate7);
        
        APXTConga4__Conga_Email_Template__c etemplate8 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate8.APXTConga4__Name__c = 'Shell Rack Customer Notification';
		etempList.add(etemplate8);
        
        APXTConga4__Conga_Email_Template__c etemplate9 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate9.APXTConga4__Name__c = 'Canadian Rack Pricing and rack pricing Files';
		etempList.add(etemplate9);        
        
        APXTConga4__Conga_Email_Template__c etemplate10 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate10.APXTConga4__Name__c = 'Ready to Upload Notification';
		etempList.add(etemplate10);     
        
        APXTConga4__Conga_Email_Template__c etemplate11 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate11.APXTConga4__Name__c = 'No Revised Pricing';
		etempList.add(etemplate11);     
        
        insert costCovs;
        insert tempList;
        insert etempList;
        APXTConga4__Conga_Merge_Query__c ApexConga = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c= 'NewBAPP - Bare Point(Right)',RE_Type__c = 'CND CBU');
        APXTConga4__Conga_Solution_Query__c soln = new APXTConga4__Conga_Solution_Query__c();
        soln.APXTConga4__Alias__c='NewBAPPBarePointR' ;
        soln.APXTConga4__Conga_Query__c = ApexConga.Id;
        
        Test.startTest();
        Map<String,String> mailMap = new Map<String,String>();
        mailMap.put('ER1','test@shell.com_null_null');
        mailMap.put('ER2','test@shell.com_test1@shell.com_null');
        mailMap.put('ER3','test@shell.com_test1@shell.com_test2@shell.com');
        mailMap.put('ER4','test@shell.com_null_test2@shell.com'); 
        mailMap.put('ER5','null_test1@shell.com_test2@shell.com');
        mailMap.put('ER6','null_null_test2@shell.com');
        mailMap.put('ER7','null_test2@shell.com_null');
        
        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());
        RE_CND_MailController.cndRackPrice7Day(false,mailMap);
        RE_CND_MailController.cndRackPricesUrl(false,mailMap);
        RE_CND_MailController.rackNotificationUrl(false,mailMap);
        RE_CND_MailController.shellCanadaRackNotiUrl(false,mailMap);
        RE_CND_MailController.sfjRackNotiUrl(false,mailMap);
        Datetime requestdDate = system.now(); 
        Date frmDate = date.newinstance(requestdDate.year(), requestdDate.month(), requestdDate.day());
        RE_CND_MailController.brandedCustomer(false,frmDate,mailMap);
        RE_CND_MailController.canadaBRPPNotiUrl(false,mailMap);
        RE_CND_MailController.shellRackCustomer(false,mailMap);   
        RE_CND_MailController.CanadianRackPricing(false,mailMap);         
        RE_CND_MailController.readyToUploadNotiUlr(false,mailMap);
        RE_CND_MailController.noRevisedPricingUlr(false,mailMap);
        
        Map<String,String> emptryMailMap = new Map<String,String>(); 
        RE_CND_MailController.cndRackPrice7Day(true,emptryMailMap);
        RE_CND_MailController.cndRackPricesUrl(true,emptryMailMap);
        RE_CND_MailController.rackNotificationUrl(true,emptryMailMap);
        RE_CND_MailController.shellCanadaRackNotiUrl(true,emptryMailMap);
        RE_CND_MailController.sfjRackNotiUrl(true,emptryMailMap);
        RE_CND_MailController.brandedCustomer(true,frmDate,emptryMailMap);
        RE_CND_MailController.canadaBRPPNotiUrl(true,emptryMailMap);
        RE_CND_MailController.shellRackCustomer(true,emptryMailMap);   
        RE_CND_MailController.CanadianRackPricing(true,emptryMailMap); 
        RE_CND_MailController.readyToUploadNotiUlr(true,emptryMailMap);   
        RE_CND_MailController.noRevisedPricingUlr(true,emptryMailMap);
        
        Test.stopTest();
    }
}