@isTest
public class LiveAtpPspControllerTest {
    @testSetup 
    static void setup() {
        List<ATP__c> atplst = new List<ATP__c>();
        Location__c loc = new Location__c();
        loc.Name = 'Ludwigshafen depot';
        loc.Plant_Code__c = 'D004';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        insert loc;
        //AdditionalTestCoverage_12Jun2019_Lakshmi_starts
        /* PBI_166252_DataCleanup_Lakshmi_1stOct2019 == Commented PSP Object Related fields
        List<PSP__c> PspList = new List<PSP__c>();
        
		 PSP__c PspDataInsertAGO = new PSP__c();
         PspDataInsertAGO.Plant_Name__c = loc.Id;
         PspDataInsertAGO.Grade__c= Label.AGO_B7;
         PspDataInsertAGO.Product_Category__c=Label.AGO_B7;
         PspDataInsertAGO.AMV__c = 1000.78;
         PspDataInsertAGO.HCV__c = 1000.78;
         PspDataInsertAGO.Manual_Adjustment1__c=100.56;
         PspDataInsertAGO.Apply_Throughput__c='Yes';
         PspDataInsertAGO.Throughputcost__c=1000.78;
         PspList.add(PspDataInsertAGO);
         insert PspList;
		*/
        //AdditionalTestCoverage_12Jun2019_Lakshmi_Ends
        
        ATP__c atpDataInsertAGO = new ATP__c();
        atpDataInsertAGO.Location__c = loc.Id;
        atpDataInsertAGO.Grade_Level2__c = Label.AGO_B7;
        atpDataInsertAGO.ATP1__c = 1000;
        atpDataInsertAGO.ATP2__c = 1000;
        atpDataInsertAGO.ATP3__c = 1000;
        atpDataInsertAGO.ATP_Live__c = 1000;
        atpDataInsertAGO.ATP2_Live__c  = 1000;
        atpDataInsertAGO.ATP3_Live__c  = 1000;   
        atpDataInsertAGO.Sales_8_30_17_30__c = 0;
        atpDataInsertAGO.Sales_15_28__c = 0;
        atpDataInsertAGO.Sales_29_61__c = 0;
        //AdditionalTestCoverage_12Jun2019_Lakshmi_starts
        //atpDataInsertAGO.Lifting_Validity_From1__c = Date.Today();
        atpDataInsertAGO.Lifting_Validity_From1__c=system.today();
       	atpDataInsertAGO.Lifting_Validity_From2__c=system.today();
        atpDataInsertAGO.Lifting_Validity_From3__c=system.today();
        atpDataInsertAGO.Comment_Forward_Sales__c='test';
        atpDataInsertAGO.Comment_Prompt_Sales__c='test1';
        atpDataInsertAGO.Comment_Forward2_Sales__c='test2';
        //AdditionalTestCoverage_12Jun2019_Lakshmi_Ends
        atpDataInsertAGO.ATP_Auto_Refresh__c = true;
        atplst.add(atpDataInsertAGO);
        
        
        ATP__c atpDataInsertIGO = new ATP__c();
        atpDataInsertIGO.Location__c = loc.Id;
        atpDataInsertIGO.Grade_Level2__c = Label.IGO_50ppm;
        atpDataInsertIGO.ATP1__c = 1000;
        atpDataInsertIGO.ATP2__c = 1000;
        atpDataInsertIGO.ATP3__c = 1000;
        atpDataInsertIGO.ATP_Live__c = 1000;
        atpDataInsertIGO.ATP2_Live__c  = 1000;
        atpDataInsertIGO.ATP3_Live__c  = 1000;   
        atpDataInsertIGO.Sales_8_30_17_30__c = 0;
        atpDataInsertIGO.Sales_15_28__c = 0;
        atpDataInsertIGO.Sales_29_61__c = 0;
        //AdditionalTestCoverage_12Jun2019_Lakshmi_Starts
        //atpDataInsertIGO.Lifting_Validity_From2__c = Date.Today();
        atpDataInsertIGO.Lifting_Validity_From2__c = system.today();
        atpDataInsertIGO.Lifting_Validity_From2__c=system.today();
        atpDataInsertIGO.Lifting_Validity_From3__c=system.today();
        atpDataInsertIGO.Comment_Forward_Sales__c='test';
        atpDataInsertIGO.Comment_Prompt_Sales__c='test1';
        atpDataInsertIGO.Comment_Forward2_Sales__c='test2';
        //AdditionalTestCoverage_12Jun2019_Lakshmi_Ends
        atpDataInsertIGO.ATP_Auto_Refresh__c = true;
        atplst.add(atpDataInsertIGO);    
        
        ATP__c atpDataInsertULG = new ATP__c();
        atpDataInsertULG.Location__c = loc.Id;
        atpDataInsertULG.Grade_Level2__c =  'ULG95 E5';
        atpDataInsertULG.ATP1__c = 1000;
        atpDataInsertULG.ATP2__c = 1000;
        atpDataInsertULG.ATP3__c = 1000;
        atpDataInsertULG.ATP_Live__c = 1000;
        atpDataInsertULG.ATP2_Live__c  = 1000;
        atpDataInsertULG.ATP3_Live__c  = 1000;   
        atpDataInsertULG.Sales_8_30_17_30__c = 0;
        atpDataInsertULG.Sales_15_28__c = 0;
        atpDataInsertULG.Sales_29_61__c = 0;
        //AdditionalTestCoverage_12Jun2019_Lakshmi_Starts
        //atpDataInsertULG.Lifting_Validity_From1__c = Date.Today();
         atpDataInsertULG.Lifting_Validity_From1__c =system.today();
         atpDataInsertULG.Lifting_Validity_From2__c=system.today();
        atpDataInsertULG.Lifting_Validity_From3__c=system.today();
        atpDataInsertULG.Comment_Forward_Sales__c='test';
        atpDataInsertULG.Comment_Prompt_Sales__c='test1';
        atpDataInsertULG.Comment_Forward2_Sales__c='test2';
        //AdditionalTestCoverage_12Jun2019_Lakshmi_Ends
        atpDataInsertULG.ATP_Auto_Refresh__c = true;
        atplst.add(atpDataInsertULG);
        insert atplst;
    }
    public static testMethod void testLiveAtpPspController() {
        PageReference pageRef = new PageReference('');
        Test.setCurrentPage(pageRef);
      
        // To insert user and it's property and do run as user 
        Profile objProfile = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        User objUser = [Select Id, ProfileId from User where Id=: UserInfo.getUserId()];
        objUser.My_DE_Locations__c = 'D004';
        objUser.My_AT_Locations__c ='';
        ApexPages.currentPage().getParameters().put('qp', 'yyyy');
        String[] companyCodes = new String[]{'AT01','DE01'};
        String[] companyCode = new String[]{'DE01'};
        String option = 'My';
        String wndw = 'ATP1';
        
        List<LiveATPPSPDemoController.ATPWrap> wrapList = new List<LiveATPPSPDemoController.ATPWrap>(); 
        //LiveATPPSPDemoController.ATPWrap = new LiveATPPSPDemoController.ATPWrap();
        system.runAs(objUser){
            LiveAtpPspController controller = new LiveAtpPspController(); 
            controller.option = option;
            controller.wndw = wndw;
            controller.companyCodes=companyCodes;
            controller.atpWrapper = wrapList;
            controller.setRefreshedTime('5');
            controller.setOption('All');
            controller.setWndw('ATP1');
            controller.SetCompanyCodes(companyCodes);
            controller.selectedCompanyCodes();
            controller.selectedWindows();
            
            controller.getItems();
            controller.getOption();
            controller.getRefreshedTime();
            controller.getTranche();
            controller.getChannels();
            
            controller.selectedPreference();
            controller.refreshPage();
            
            LiveAtpPspController controller2 = new LiveAtpPspController(); 
            controller2.option = option;
            controller2.wndw = wndw;
            controller2.companyCodes=companyCodes;
            controller2.atpWrapper = wrapList;
            controller2.setRefreshedTime('5');
            controller2.setOption('All');
            controller2.setWndw('ATP2');
            controller2.SetCompanyCodes(companyCodes);
            wrapList = LiveATPPSPDemoController.getAllATPList(companyCodes,'ATP1','All');
            LiveATPPSPDemoController.getAllATPList(companyCodes,'ATP2','All');
            LiveATPPSPDemoController.getAllATPList(companyCodes,'ATP3','All');
            LiveATPPSPDemoController.saveLocationPref(JSON.serialize(wrapList),companyCodes);
            LiveATPPSPDemoController.saveLocationPref(JSON.serialize(wrapList),companyCode);
            //Added by Dharmendra on 12/11/2020 for RV_LocaleHelper Start
            RV_LocaleHelper.formattedDecimal(11.11);
            //Added by Dharmendra for RV_LocaleHelper End
        }
    }
}