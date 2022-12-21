/**
* Created by Dharmendra.Singh2 on 8/1/2020.
*/


@IsTest  (SeeAllData=false)
private class RT_REVContractDataBatchTest {


    @IsTest
    static void setupTestData() {
        
        List<RT_Setting__c> csList = new List<RT_Setting__c>();
        RT_Setting__c payTerm = new RT_Setting__c();
        payTerm.Name = 'Z042';
        payTerm.RecordTypeId = RT_Util.codeSettRecTypeId;
        payTerm.Type__c = 'Payment Term';
        csList.add(payTerm);
        
        RT_Setting__c condType = new RT_Setting__c();
        condType.Name = 'YP04';
        condType.RecordTypeId = RT_Util.codeSettRecTypeId;
        condType.Type__c = 'Condition Type';
        csList.add(condType);
        
        insert csList;
        
        
        List<Account> accList = new List<Account>();
        for(Integer i=0; i< 100; i++){
            Account a = new Account();
            a.Name = 'Test'+i;
            a.AccountNumber = '123456'+i;
            a.RecordTypeId =RT_Util.accRecTypeId;
            a.Customer_Type__c = 'Sold To';
            a.RT_PaymentTerm__c=csList[0].Id;
            accList.add(a);
        }
        insert accList;

        RE_Product__c product = new RE_Product__c();
        product.Name = 'Test Product';
        product.RT_Product_Code__c = '26536354';
        product.RecordTypeId = RT_Util.prodRecTypeId;
        insert product;

        RE_Location__c location = new RE_Location__c();
        location.Name = 'Test Location';
        location.RT_Location_Type__c = RT_Util.depotLocType;
        location.RecordTypeId = RT_Util.locRecTypeId;
        insert location;
        
        List<RE_Contract__c> contractList = new List<RE_Contract__c>();
        for(Integer j=0; j< 100; j++){
            RE_Contract__c c = new RE_Contract__c();
            c.Active__c=true;
            c.RT_Contract_Number__c='321133965'+j;
            c.RE_Product_Name__c = product.Id;
            c.RT_Contract_Item__c = '10';
            c.RT_Valid_From__c = System.today()-30;
            c.RT_Valid_To__c = System.today()+30;
            c.RT_Sold_To_Name__c = accList[j].Id;
            c.RT_Ship_to_Name__c = accList[j].Id;
            c.RE_Location_Name__c = location.Id;
            c.RT_Terms_of_Payment__c = csList[0].Id;
            contractList.add(c);
        }
        insert contractList;

        List<REV_Contract_Master__c> auList = new List<REV_Contract_Master__c>();
        for(Integer k=0; k< 100; k++){
            REV_Contract_Master__c au = new REV_Contract_Master__c();
            au.Active__c = true;
            //au.RT_Sold_to_Name__c=accList[k].Id;
            au.RT_AMOUNT__c = 300;
            //au.RT_Ship_to_Name__c = accList[k].Id;
            au.SAP_Contract__c = contractList[k].Id;
            au.RT_Condition_Type__c = csList[1].Id;
            au.RT_Plant_Desc__c = location.Id;
            au.RT_Material_Desc__c = product.Id;
            au.Country_Name__c = 'TU';
            au.RT_Key_Value__c = 'TR040202032222639600000000040000375'+k;
            auList.add(au);
        }
        insert auList;

        List<REV_Contract_Master__c> RevUpdateList = new List<REV_Contract_Master__c>();
        for(REV_Contract_Master__c revContract : auList){
            revContract.RT_AMOUNT__c = 400;
            RevUpdateList.add(revContract);
        }
        update RevUpdateList;

        String cronExpr = '0 0 0 15 3 ? 2099';
        String jobRunningTime = '2022-03-15 00:00:00';
        
        Test.startTest();
        RT_REVContractDataBatch obj = new RT_REVContractDataBatch();  
        Database.executeBatch( obj );
        String jobId = 
        System.schedule('RT_AureusJobSchedule', cronExpr, new RT_AureusJobSchedule());
        Test.stopTest();  
        
        //List < RT_PriceOutput__c > poList = [ SELECT Id FROM RT_PriceOutput__c ];  
        //system.assertEquals( 100, poList.size() );  
        
    }  
    
}