public class RE_PHOutputScheduler implements schedulable{
    public Static Map<String ,RE_MY_Output__c> outputdataList = new Map<String ,RE_MY_Output__c>();
    public Id rectypeId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId() ;
    //  Data Creation in MY_Output table
    public void execute(System.SchedulableContext sc){
        List<RE_MY_Output__c> updateolddata = new List<RE_MY_Output__c>();
        List<RE_MY_Output__c> LatestDataToday = [SELECT RE_IsLatest__c FROM RE_MY_Output__c WHERE RE_IsLatest__c = True AND RE_Type__c ='PH Output'];
        if(!LatestDataToday.isEmpty()){
            for(RE_MY_Output__c outputdata : LatestDataToday){
                outputdata.RE_IsLatest__c = False;
                updateolddata.add(outputdata);
            }
        }
        for(RE_MY_CostPrice__c costdata : [
                SELECT RE_Product_Name__r.RE_Material__c, RE_Product_Name__r.Name,RE_Product_Name__r.RE_PH_Index__c,RE_Costprice_Laid_Down_Cost__c,
                        id, RE_Type__c,RE_Data__c, RE_Effective_Date__c, RE_Costprice_Marginal_Cost__c,RE_Depot_Name__r.Name
                FROM RE_MY_CostPrice__c
                WHERE RE_IsLatest__c = True AND RecordType.Name = 'Philippines' AND RE_PH_Is_Blend__c = False AND  RE_Depot_Name__c != null AND RE_Type__c IN ('D-1','D-2','M-1','M-2','W-1','W-2','WTD','MTD')
                ORDER By RE_Product_Name__c	DESC]){
            String keyProDepo = costdata.RE_Product_Name__r.Name + '_' + costdata.RE_Depot_Name__r.Name;
            if(!outputdataList.containsKey(keyProDepo)){
                RE_MY_Output__c outputdata = new RE_MY_Output__c();
                outputdata.RE_PH_Product_Name__c = costdata.RE_Product_Name__c;
                outputdata.RE_Depot_Name__c = costdata.RE_Depot_Name__r.Name;
                outputdata.RE_PH_Product_Code__c = costdata.RE_Product_Name__r.RE_Material__c;
                outputdata.RE_Type__c ='PH Output';
                outputdata.RE_IsLatest__c = True;
                outputdata.recordtypeId = rectypeId;
                if(costdata.RE_Type__c == 'D-1'){
                    outputdata.RE_PH_D1Data__c = costdata.RE_Costprice_Laid_Down_Cost__c ;
                }
                if(costdata.RE_Type__c == 'D-2')
                {
                    outputdata.RE_PH_D2Data__c= costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'M-1'){
                    outputdata.RE_PH_M1Data__c= costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'M-2')
                {
                    outputdata.RE_PH_M2Data__c= costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-1'){
                    outputdata.RE_PH_W1Data__c= costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-2')
                {
                    outputdata.RE_PH_W2Data__c= costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'MTD'){
                    outputdata.RE_PH_MTDData__c= costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'WTD')
                {
                    outputdata.RE_PH_WTDData__c= costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                outputdataList.put(keyProDepo,outputdata);
            }
            else
            {
                if(costdata.RE_Type__c == 'D-1'){
                    outputdataList.get(keyProDepo).RE_PH_D1Data__c = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'D-2')
                {
                    outputdataList.get(keyProDepo).RE_PH_D2Data__c = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'M-1'){
                    outputdataList.get(keyProDepo).RE_PH_M1Data__c = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'M-2')
                {
                    outputdataList.get(keyProDepo).RE_PH_M2Data__c = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-1'){
                    outputdataList.get(keyProDepo).RE_PH_W1Data__c = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-2')
                {
                    outputdataList.get(keyProDepo).RE_PH_W2Data__c = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'MTD'){
                    outputdataList.get(keyProDepo).RE_PH_MTDData__c = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
                if(costdata.RE_Type__c == 'WTD')
                {
                    outputdataList.get(keyProDepo).RE_PH_WTDData__c = costdata.RE_Costprice_Laid_Down_Cost__c;
                }
            }
        }
        if(!updateolddata.isEmpty()){
            try{update updateolddata;}
            catch(Exception ex){system.debug(ex.getCause());}
        }

        if(!outputdataList.values().isEmpty()){
            try{insert outputdataList.values();}
            catch(Exception ex){system.debug(ex.getCause());}
        }



    }
}