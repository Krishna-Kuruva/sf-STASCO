/*****************************************************************************
@Name:  RV_DAL     
@=========================================================================
@Purpose: DAL Class to query records from sobjects
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      26/09/2017         INITIAL DEVELOPMENT

******************************************************************************/
public class RV_DAL {

    public static List<SHT__c> fetchSHTRecord(List<SHT__c> shtLst){
        return [SELECT Id,
                Name,
                IsATPVolumeReduced__c,
                IsVolumeHedged__c ,
                Sales_Type__c,
                Status__c,
                Tranche__c,
                Volume_CBM__c,
                Location__c,
                Product_Category__c,
                Product_Sub_Group__c,
                Contract_Start__c,
                Contract_End_Date__c,
                isOlfDeal__c FROM SHT__c WHERE Id in:shtLst];
    }
    public static List<SHT__c> fetchSHTRecordSHTDave(List<SHT__c> shtLst){ // fetch records from SHT object
        //PBI_166252_DataCleanup_Lakshmi_1stOct2019==> Removed MOGAS_E5_Volume__c,MOGAS_E10_Volume__c,MOGAS_98_Volume__c,Quantitiy_CBM__c,Quantitiy_ATP2__c,Quantitiy_ATP3__c

        return [select id,Name,IsATPVolumeReduced__c,IsVolumeHedged__c ,Status__c,LastModifiedDate,Tranche__c,Volume_CBM__c,Contract_Start__c,Location__c,Product_Category__c from SHT__c where Id in:shtLst OR LastModifiedDate = TODAY
        LIMIT 50000];
    }
    public static List<ATP__c> fetchATPRecord(List<String> productset,List<String> locationset){
        System.debug('^^^^^^LocationSet^^^6'+locationset);
        //START - Rahul Sharma | Date - 11-Nov-2020 : Updated query to fetch live online volume for tranche 2 and 3.
        //START - Rahul Sharma | PBI-731483 | Date - 30-Apr-2021 : Updated query to fetch addtional fields for online ATP split.
        return [SELECT Id,
                ATP_Live__c,
                Sales_8_30_17_30__c,
                Sales_15_28__c,
                Location__c,
                Grade_Level2__c,
                ATP2_Live__c,
                ATP3_Live__c,
                Sales_29_61__c,
                Live_Online_00_14__c,
                Live_Online_ATP2__c,
                Split_Volume__c,
                Split_Volume_Per_ATP2__c,
                Split_Volume_Per_ATP3__c,
                Minimum_Daily_Split_Volume__c,
                Min_Daily_Split_Vol_ATP2__c,
                Min_Daily_Split_Vol_ATP3__c,
                Minimum_Online_Volume__c,
                Min_Online_Volume_ATP2__c,
                Min_Online_Volume_ATP3__c,
                Maximum_Online_Volume__c,
                Max_Online_Volume_ATP2__c,
                Max_Online_Volume_ATP3__c,
                Live_Online_ATP3__c FROM ATP__c WHERE Location__c in:locationset AND
        Grade_Level2__c in:productset];
        //END - Rahul Sharma | PBI-731483 | Date - 30-Apr-2021 : Updated query to fetch addtional fields for online ATP split.
        //END - Rahul Sharma | Date - 11-Nov-2020 : Updated query to fetch live online volume for tranche 2 and 3.
    }

    public static List<ATP__c> fetchAllATPRecord(){// fetch records from ATP object

        /*PBI_166252_DataCleanup_Lakshmi_1stOct2019==>Removed AGO_IGO_CBM_to_Ton__c,AGO_IGO_Ton_To_CBM__c,ATP_Input_Type__c,ATP1_Quantity_CBM__c,ATP2_Quantity_CBM__c
           ATP3_Quantity_CBM__c,ATP1_Status__c,ATP2_Status__c,ATP3_Status__c,ATP1_CBM__c,ATP2_CBM__c,ATP3_CBM__c,Min_Margin_T1_Euro_100L__c,Min_Margin_T1_USD_t__c,
           Min_Margin_T2_Euro_100L__c,Min_Margin_T2_USD_t__c,Min_Margin_T3_Euro_100L__c,Min_Margin_T3_USD_t__c,Published_Date__c
           */

        return [Select  Location_Name__c,Location__r.Name, a.SystemModstamp, a.Sales_Region__c, a.Sales_8_30_17_30__c,
                a.Region__c, a.Refresh_ATP__c,a.Plant_Code__c,a.OwnerId, a.Name, a.Mode_of_Transport_MOT__c,
                a.Location__c, a.LocType__c, a.Lifting_Window__c,a.Lifting_Validity_From2__c, a.Lifting_Validity_From1__c,
                a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.IsChanged__c, a.Id, a.Grade_Level2__c, a.Date__c,
                a.Current_Date__c, a.CreatedDate, a.CreatedById, a.Contract_Start__c, a.Company_Code__c,
                a.Comment_Prompt_Sales__c, a.Comment_Forward_Sales__c,a.ATP_Submit_Time__c,a.ATP_Live__c,a.ATP3__c,
                a.ATP3_Live__c,a.ATP2__c,a.ATP2_Live__c, a.ATP1__c,
                Live_Online_00_14__c //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit
        From ATP__c a order by Location__r.Name ASC];
    }

    public static List<ATP__c> fetchSelectedATPRecord(List<String> fetchFinalATPLst){// fetch records from ATP object
        return [SELECT id,ATP_Refresh__c,ATP_Auto_Refresh__c,ATP_Live__c,Minimum_ATP1__c,Location__c,ATP1__c
                ,Live_Online_00_14__c //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit
        from ATP__c where Id in:fetchFinalATPLst];
    }

    public static ListView fetchLstViewATP(){
        return [SELECT Id,Name,DeveloperName,SobjectType FROM ListView where SobjectType = 'ATP__c' AND DeveloperName = 'MOGAS_E5'];
    }
}