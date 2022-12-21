@isTest
public class RV_SHTDaveTest {
        
    static testMethod void RV_SHTDaveTestInsert(){//Saved and expired
        
        SHT_Dave_Master__c insertSHTDaveMasterAGOInsert = new SHT_Dave_Master__c();
        insertSHTDaveMasterAGOInsert = RV_TestHelper.insertSHTDaveMasterAGO(insertSHTDaveMasterAGOInsert);
        insert insertSHTDaveMasterAGOInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterULGInsert = new SHT_Dave_Master__c();
        insertSHTDaveMasterULGInsert = RV_TestHelper.insertSHTDaveMasterULG(insertSHTDaveMasterULGInsert);
        insert insertSHTDaveMasterULGInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterMOGASInsert = new SHT_Dave_Master__c();
        insertSHTDaveMasterMOGASInsert = RV_TestHelper.insertSHTDaveMasterMOGAS(insertSHTDaveMasterMOGASInsert);
        insert insertSHTDaveMasterMOGASInsert;
        
        SHT_Dave__c insertSHTDaveAGO = new SHT_Dave__c();
        insertSHTDaveAGO = RV_TestHelper.insertSHTDave(insertSHTDaveAGO,insertSHTDaveMasterAGOInsert);
        insert insertSHTDaveAGO;
        
        SHT_Dave__c insertSHTDaveULG = new SHT_Dave__c();
        insertSHTDaveULG = RV_TestHelper.insertSHTDave(insertSHTDaveULG,insertSHTDaveMasterAGOInsert);
        insertSHTDaveULG.Product_Name__c = 'ULG95 E5';
        insertSHTDaveULG.Mass_MT__c = insertSHTDaveULG.Mass_CBM__c * 0.755;
        insert insertSHTDaveULG;
        
        SHT_Dave__c insertSHTDaveHedge = new SHT_Dave__c();
        insertSHTDaveHedge = RV_TestHelper.insertSHTDaveHedge(insertSHTDaveHedge,insertSHTDaveMasterAGOInsert);
        insert insertSHTDaveHedge;
        
        
        RV_SHTDave.getShtDaveMaster();
        RV_SHTDave.getShtDave();
        RV_SHTDave.insertManualEntry('AGO B7',1);
    }
}