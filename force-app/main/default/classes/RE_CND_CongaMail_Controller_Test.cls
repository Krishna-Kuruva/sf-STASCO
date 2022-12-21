/******************************************************************************************************************
className           :    RE_CND_CongaMail_Controller_Test
Description         :    Test class for RE_CND_CongaMail_Controller
Author              :    Aasiya Siraj
Date				:	 10-Nov-2021 
*******************************************************************************************************************/
@isTest
public class RE_CND_CongaMail_Controller_Test {
    
     @testSetup 
     static void setup() {
        APXTConga4__Conga_Email_Template__c congTemp1=RE_CND_TestDataFactory.congaEmailTemplate( '<p>Hi,</p><p><br></p><p><br></p><p>Thanks,</p><p><b style="font-size: 12pt;">ABC </b><span style="font-size: 12pt;"> </span></p>' 
                                                                                                , 'Internal Rack Notification', 'I/A: Rack Notification -2021-11-13', 'Hi,\n\nThanks,\nABC');
        APXTConga4__Conga_Merge_Query__c congaQ1=RE_CND_TestDataFactory.createCongaQuery('SELECT RE_CND_Rack_English__c  FROM RE_MY_Output__c WHERE  RE_CND_Effective_From_Date__c =  2021-11-13' ,'Canada Rack Prices');
        APXTConga4__Conga_Merge_Query__c congaQ2=RE_CND_TestDataFactory.createCongaQuery('SELECT RE_CND_Rack_English__c  FROM RE_MY_Output__c WHERE  CreatedDate =  2021-11-13T00:00:00Z' ,'Canada SFJ');
     }
    
    @isTest
    static  void sendEmailDetailsTest(){
        Test.startTest(); 
        List<String> selectedMail=new List<String> ();
        Date todayDate = System.today();
        selectedMail.add('Rack Notification');
        List <APXTConga4__Conga_Email_Template__c> updatedEmail=[select id, APXTConga4__HTMLBody__c,  APXTConga4__Name__c, APXTConga4__Subject__c,  
                                                            APXTConga4__TextBody__c from APXTConga4__Conga_Email_Template__c ];
        RE_CND_CongaMail_Controller.sendEmailDetails(selectedMail,updatedEmail,true,todayDate );
        Test.stopTest();
    }
    
     @isTest
    static  void getMailDetailsTest(){
        Test.startTest(); 
        RE_CND_CongaMail_Controller.MailWrapper mw= new RE_CND_CongaMail_Controller.MailWrapper();
        mw =RE_CND_CongaMail_Controller.getMailDetails();        
        Test.stopTest();
    }
    

}