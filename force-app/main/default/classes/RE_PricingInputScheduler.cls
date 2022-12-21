public class RE_PricingInputScheduler implements Schedulable{

    public void execute(System.SchedulableContext sc){ 
    	pricingInsert();
    }
    public static void pricingInsert(){
        List<RE_Pricing_Input_STG__c> priceStg = new List<RE_Pricing_Input_STG__c>();
        List<RE_Pricing_Input__c> priceinp = new List<RE_Pricing_Input__c>();
        List<String> recordtypeList = new List<String>{'GPC_Data','RPG_Data','Tier_Data'};
        List<String> checkTierOld = new List<String>();
        for(RE_Pricing_Input_STG__c stgdata : [ 
            SELECT Id, RecordTypeId, RecordType.Name,RE_Is_Processed__c, RE_Price__c, RE_Pricing_Date__c, RE_CurrentCnfgTierAmnt__c, RE_End_Date__c, 
            RE_FixedPrice__c, RE_GPCAmnt__c, RE_IsConfig__c, RE_IsDifferent__c, RE_Material__c, RE_PlantDesc__c, RE_Plant__c, RE_ShipTo__c, 
            RE_SoldTo__c, RE_Start_Date__c, RE_TierAmnt__c 
            FROM RE_Pricing_Input_STG__c WHERE RE_Is_Processed__c = false and RecordType.Name IN: recordtypeList
        ]){
            RE_Pricing_Input__c prinp = new RE_Pricing_Input__c();
            prinp.RE_Material__c = stgdata.RE_Material__c;
            prinp.RE_Is_latest__c = true;
            switch on stgdata.RecordType.Name {
                when 'GPC_Data' {		
                    prinp.RE_Type__c = 'GPC';
                    prinp.RE_GPCAmnt__c = stgdata.RE_GPCAmnt__c;
                    prinp.RE_Start_Date__c = stgdata.RE_Start_Date__c;
                    prinp.RE_End_Date__c = stgdata.RE_End_Date__c;
                }
                when 'RPG_Data' {		
                    prinp.RE_Type__c = 'RPG';
                    prinp.RE_Plant__c = stgdata.RE_Plant__c;
                    prinp.RE_PlantDesc__c = stgdata.RE_PlantDesc__c;
                    prinp.RE_FixedPrice__c = stgdata.RE_FixedPrice__c;
                    prinp.RE_Start_Date__c = stgdata.RE_Start_Date__c;
                    prinp.RE_End_Date__c = stgdata.RE_End_Date__c;
                }
                when 'Tier_Data' {		
                    prinp.RE_Type__c = 'Tier';
                    prinp.RE_ShipTo__c = stgdata.RE_ShipTo__c;
                    prinp.RE_SoldTo__c = stgdata.RE_SoldTo__c;
                    prinp.RE_Plant__c = stgdata.RE_Plant__c;
                    prinp.RE_TierAmnt__c = stgdata.RE_TierAmnt__c;
                    prinp.RE_CurrentCnfgTierAmnt__c = stgdata.RE_CurrentCnfgTierAmnt__c;
                    prinp.RE_IsConfig__c = stgdata.RE_IsConfig__c;
                    prinp.RE_IsDifferent__c = stgdata.RE_IsDifferent__c;                    
                    checkTierOld.add(stgdata.RE_ShipTo__c+stgdata.RE_SoldTo__c+stgdata.RE_Plant__c+stgdata.RE_Material__c);
                }
            }
            priceinp.add(prinp);
            stgdata.RE_Is_Processed__c = True;
            priceStg.add(stgdata);
        }
        if(!checkTierOld.isEmpty())
            TierValues(checkTierOld);

        if(!priceinp.isEmpty()){
            try{
                insert priceinp;
                if(!priceStg.isEmpty()){
                    try
                    { update priceStg;}
                    catch(Exception e)
                    {System.debug('--failed onupdating staging data--'+e.getCause());}
                }     
            }
            catch(Exception e){
                System.debug('--failed on inserting pricing input--'+e.getCause());
            }
        }
    }

    public static void TierValues(List<String> checkTierKey){        
        List<RE_Pricing_Input__c> oldTier = new  List<RE_Pricing_Input__c>();

        for(RE_Pricing_Input__c rpgtier : [
            SELECT id,RE_Is_latest__c,RE_ShipTo__c,RE_SoldTo__c,RE_Type__c,RE_Material__c,RE_Plant__c,RE_TierAmnt__c,RE_CurrentCnfgTierAmnt__c,RE_IsConfig__c,RE_IsDifferent__c
            FROM RE_Pricing_Input__c
            WHERE RE_Type__c = 'Tier'
            AND  RE_Is_latest__c = True  order by createddate desc
        ]){

            string key = rpgtier.RE_ShipTo__c+rpgtier.RE_SoldTo__c+rpgtier.RE_Plant__c+rpgtier.RE_Material__c;
            if(checkTierKey.contains(key)){
                rpgtier.RE_Is_latest__c = false;
                oldTier.add(rpgtier);
            }
        }
        if(!oldTier.isEmpty())
            update oldTier;

    }
}