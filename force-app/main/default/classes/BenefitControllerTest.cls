@isTest(SeeAllData=false)
public Class BenefitControllerTest{
    static Initiatives__c initiative;
    static Benefit__c benefit;
    static Benefit__c benefitL1;
    static Benefit_By_Year__c bYear;
    static String benefitRecTypeId;
    static String benefitL1RecTypeId;
    
    static{
        String recTypeId=Schema.SObjectType.Initiatives__c.getRecordTypeInfosByName().get('Coached Project').getRecordTypeId();
        initiative=new Initiatives__c();
        initiative.Name='Test Init';
        initiative.Business_Unit__c='SEA';
        initiative.Description__c='test Class Data';
        initiative.Initiative_Status__c='Open';
        initiative.Sponsor__c='test COE';
        initiative.RecordTypeId=recTypeId;
        insert initiative;
        System.Debug('initiative:'+initiative);
        
        benefitRecTypeId=Schema.SObjectType.Benefit__c.getRecordTypeInfosByName().get('L3').getRecordTypeId();
        benefit=new Benefit__c();
        benefit.Name='test Benefit';
        benefit.Impacted_Unit__c='SEA';
        benefit.RecordTypeId=benefitRecTypeId;
        benefit.BE_Activities__c=initiative.Id;
        insert benefit;
        
        benefitL1RecTypeId=Schema.SObjectType.Benefit__c.getRecordTypeInfosByName().get('L1').getRecordTypeId();
        benefitL1=new Benefit__c();
        benefitL1.Name='test Benefit L1';
        benefitL1.Impacted_Unit__c='SEA';
        benefitL1.RecordTypeId=benefitL1RecTypeId;
        benefitL1.BE_Activities__c=initiative.Id;
        benefitL1.Included_In_LE__c=true;
        benefitL1.L1_Type__c='Value Generation';
        insert benefitL1;
        
        bYear=new Benefit_By_Year__c();
        bYear.Year__c='2040';
        bYear.Benefit_Amount__c=700000;
        bYear.Benefit__c=benefit.Id;
        insert bYear;
    
    }
    
    
    static testMethod void benefitTestMethod1(){
    
        String benfitJSON='[{"sobjectType":"Benefit_By_Year__c","Benefit_Amount__c":"3444","Year__c":"2040"}]';
        BenefitController b=new BenefitController();
        BenefitController.getLevel();
        BenefitController.getImpactedUnit();
        BenefitController.getYear();
        BenefitController.saveDataMethod(benefit, 
                                      benfitJSON,
                                      initiative.Id, 
                                      benefitRecTypeId,
                                      null);
        BenefitController.getDataMap(benefit.Id);
        System.Debug('benefitL1.Id:'+benefitL1.Id);
        BenefitController.getL1Type(benefitL1RecTypeId);
        
    }

}