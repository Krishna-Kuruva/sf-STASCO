@isTest
private class TCP_EmailServiceTest {

    @isTest
    static void testSendEmail()
    {	
        List<contact> testContact= new List<contact>();
        List<Order> testOrders=new List<Order>();
        List<TCP_OrderLineItem__c> testOrderLineItem= new  List<TCP_OrderLineItem__c>();   
        TCP_TestDataUtilities.createAccounts(1,true);
       string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        Account acc=[select id,name,recordtype.id,Active__c from account where name='SampleAccount0' limit 1];
        acc.recordtypeId=tcpAccountRecTypeid;
        update acc;
            testContact=TCP_TestDataUtilities.createContacts(1,acc);
            testOrders=TCP_TestDataUtilities.createOrders(1,acc);
                for(Order testOrder:testOrders){
                     testOrderLineItem=TCP_TestDataUtilities.createOrderLineItems(1,testOrder);
                }
        
        insert new TCP_DistributionEmailList__c(TCP_Commops_Delivery_Lists__c ='ishaque.mohammad@shell.com',TCP_Region__c='SETO',Name='SETO');
        Test.StartTest();
        TCP_EmailService.sendEmail(testOrders[0].id,testContact[0].id,acc.id,null,'TCP_Order_acknowledgement_EN_US',true);
        TCP_EmailService.sendEmail(testOrders[0].id,null,acc.id,userinfo.getUserId(),'TCP_Order_acknowledgement_EN_US',true);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
 		System.assertEquals(2, invocations);
    }
}