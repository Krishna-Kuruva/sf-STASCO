global class Rv_ITdashboardAlert implements Schedulable {
    /*
	Version : 0.0
	Author	: Soumyajit
	Date	: 25-Jun-2019
	Details	: Scheduler Job for IT Dashboard Alert
	*/
    public static boolean global_overrideChecks = false;
    public static String global_ICEquoteName = 'ICE LGO Low Sulfur Gasoil';
    global static void execute(SchedulableContext s)
    { 
        Rv_ITdashboardController.pageWrapper pw = Rv_ITdashboardController.getAllData();
        if(pw.ErrorStatus || global_overrideChecks)
        {
            Rv_ITdashboardController.checkAndSendAlert(pw.ErrorList, true);
            Rv_ITdashboardController.saveError(pw.ErrorList);
            
            //Fix_365305_Soumyajit_18Oct2019 starts
            if(pw.StopOLF || global_overrideChecks)
            {
                Rv_RevolutionSettingTriggerHelper.global_reason = pw.StopOLFReason;
                OLF_DashboardApexController.userActivateInactivate('STOP');
            }
            //Fix_365305_Soumyajit_18Oct2019 ends
        }
        
        //ICELimit_Soumyajit_27Apr2020 starts
        map<String,Double> thrPrice = OLF_DashboardApexController.getThresholdPrice();
        String ICELGO_thresholdLabel = OLF_DashboardApexController.global_ICELGO_thresholdLabel;
        String ICEquoteName = global_ICEquoteName;
        if(thrPrice.containsKey(ICELGO_thresholdLabel))
        {
            Double icePrice = thrPrice.get(ICELGO_thresholdLabel);
            if(icePrice != -999.99)
            {
                try{
                    Reuters_Quotes__c iceRQ = [Select  id, Price__c from Reuters_Quotes__c 
                                               where Valid_From_Date__c <= TODAY and Valid_To_Date__c >= TODAY 
                                               and Quote_Display_Name__c = :ICEquoteName
                                              limit 1];
                    if(iceRQ != null)
                    {
                        if(iceRQ.Price__c < icePrice)
                        {
                            Rv_RevolutionSettingTriggerHelper.global_reason = 'ICE LGO price is below the defined threshold.';
                            OLF_DashboardApexController.userActivateInactivate('STOP');
                        }
                    }
                }
                catch(Exception e)
                {}
            }
        }
        //ICELimit_Soumyajit_27Apr2020 ends
    }
}