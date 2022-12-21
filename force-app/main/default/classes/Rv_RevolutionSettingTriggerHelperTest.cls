@isTest
public class Rv_RevolutionSettingTriggerHelperTest {

    @isTest
    static void doTest()
    {
        Revolution_Setting__c s2 = new Revolution_Setting__c();
        s2.name='OLF Connection Active';
        s2.Value__c='TRUE';
        insert s2;
        
        s2.Value__c='FALSE';
        update s2;
        
        s2.Value__c='TRUE';
        update s2;
    }
}