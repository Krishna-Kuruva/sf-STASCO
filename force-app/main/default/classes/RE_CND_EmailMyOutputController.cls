/**************************************************************************************************
* Name: RE_CND_EmailMyOutputController
* Object: RE_MY_CostPrice__c, RE_MY_Output__c
* Purpose: My Output record creation to make use of Email output for Revolution Canada
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-11-06
* Modify History: 
* 2021-11-06		Abhilash		Created
**************************************************************************************************/
public class RE_CND_EmailMyOutputController {
    
    public static void emailMyOutputCreation(List<String> emailNames, Boolean isEmailToMe, Date reqFrmDate, RE_Job_Run_Audit__c jrAudit, String jrAuditStatus)    
    {     
        try
        {   
            Map<String,String> emailName = New Map<String,String>();
            
            if(emailNames.Size() > 0)
            {
                for(String eName : emailNames)
                {
                    emailName.put(eName,eName);
                }
                
                Map<String,RE_MY_CostPrice__c> reqNewRackCostPrice = new Map<String,RE_MY_CostPrice__c>();
                Map<String,RE_MY_CostPrice__c> reqNewBAPPCostPrice = new Map<String,RE_MY_CostPrice__c>();
                Map<String,RE_MY_CostPrice__c> reqRackChangeNotiCostPrice = new Map<String,RE_MY_CostPrice__c>();
                Map<String,RE_CND_Conga_Output_Settings__c> newRackSettngs = new Map<String,RE_CND_Conga_Output_Settings__c>(); 
                Map<String,RE_CND_Conga_Output_Settings__c> newBAPPSettngs = new Map<String,RE_CND_Conga_Output_Settings__c>(); 
                Map<String,RE_CND_Conga_Output_Settings__c> rackChngeNotiSettngs = new Map<String,RE_CND_Conga_Output_Settings__c>(); 
                Map<String,RE_CND_Conga_Output_Settings__c> branNotiChangeAmtSettngs = new Map<String,RE_CND_Conga_Output_Settings__c>();
                Map<String,RE_CND_Conga_Output_Settings__c> branNotiExtWebSettngs = new Map<String,RE_CND_Conga_Output_Settings__c>();
                Map<String,RE_CND_Conga_Output_Settings__c> canadianRackPricingSettngs = new Map<String,RE_CND_Conga_Output_Settings__c>(); 
                Id cndCostPriceRecdTypId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
                Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
                List<RE_MY_Output__c> tobeCreated = New List<RE_MY_Output__c>();
                List<RE_MY_Output__c> tobeUpdated = New List<RE_MY_Output__c>();
                Integer blnkRecordNo = 1;
                Date requestedDt, effectveFromDt, effectveToDt;
                
                // Get all the old RE_MY_Output__c records
                for(RE_MY_Output__c oldRecods : [Select Id, RE_IsLatest__c FROM RE_MY_Output__c
                                                 WHERE RecordTypeId =: cndMyOutputRecdTypId AND RE_IsLatest__c =: TRUE])
                {
                    RE_MY_Output__c updatdRecod = New RE_MY_Output__c();
                    updatdRecod.Id = oldRecods.Id;
                    updatdRecod.RE_IsLatest__c = FALSE;
                    tobeUpdated.add(updatdRecod);
                }                
                
                // Create Unbranded & Branded records in MyOutput Object
                if(((emailName.containsKey('Internal Shell Canada BRPP Notification')) || (emailName.containsKey('Shell Canada - Branded Customer Notification')))
                   && ((emailName.containsKey('Internal Rack Notification')) || (emailName.containsKey('SFJ Rack notification')) 
                       || (emailName.containsKey('Shell Rack Customer Notification'))
                       || (emailName.containsKey('Canadian Rack Pricing and rack pricing Files'))))
                {
                    // Get all the NewRack and NewBAPP Records on the specified date
                    for(RE_MY_CostPrice__c costPrice : [SELECT Id, RE_Product_Codes__c, RE_Depot_Code__c, RE_CND_Group__c, RE_CND_NewRack_Or_NewBAPP_File__c,                                             
                                                        RE_CND_Old_Base_Value__c,RE_CND_Net_Move_Value__c,RE_CND_Final_Value__c, RE_CND_Rack__c, RE_CND_Product_Group__c,                                                        
                                                        RE_Requested_Date__c, RE_CND_Effective_From_Date__c, RE_CND_Effective_To_Date__c
                                                        FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                                        AND RE_CND_Effective_From_Date__c <=: reqFrmDate AND RE_CND_Effective_To_Date__c >=: reqFrmDate
                                                        AND RE_IsLatest__c =: TRUE AND RE_CND_Notify_Users__c =: TRUE                                                        
                                                        AND RE_CND_NewRack_Or_NewBAPP_File__c IN ('NewRack','NewBAPP')])
                    {       
                        requestedDt = costPrice.RE_Requested_Date__c;
                        effectveFromDt = costPrice.RE_CND_Effective_From_Date__c;
                        effectveToDt = costPrice.RE_CND_Effective_To_Date__c;
                        
                        if(costPrice.RE_CND_NewRack_Or_NewBAPP_File__c == 'NewRack')
                            reqNewRackCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);
                        else if(costPrice.RE_CND_NewRack_Or_NewBAPP_File__c == 'NewBAPP')
                            reqNewBAPPCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);                    
                    }
                    
                    for(RE_CND_Conga_Output_Settings__c settngs: [SELECT Id, File_Name__c, Product_Code__c, Location_Code__c, Group__c, Display_English_Rack_Name__c, Display_French_Rack_Name__c,
                                                                  Display_English_Product_Group__c, Display_French_Product_Group__c, Sequence_No__c, Section_Name__c, Rack_Name__c, Product_Group_Name__c
                                                                  FROM RE_CND_Conga_Output_Settings__c WHERE Is_Active__c = : TRUE 
                                                                  AND File_Name__c IN ('RackCustomerNotification','NewBAPP','BrandedNotificationChangeAmount','BrandedNotificationExternalWeb', 'CanadianRackPricing')
                                                                  ORDER BY Name])
                    {
                        if((settngs.File_Name__c.contains('RackCustomerNotification')) && (!String.isEmpty(settngs.Product_Code__c)) && (!String.isEmpty(settngs.Location_Code__c)) && (!String.isEmpty(settngs.Display_English_Rack_Name__c)) && (!String.isEmpty(settngs.Display_English_Product_Group__c)))
                            newRackSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('RackCustomerNotification')) && (String.isEmpty(settngs.Product_Code__c)) && (String.isEmpty(settngs.Location_Code__c)))
                            newRackSettngs.put(settngs.Rack_Name__c+'-'+blnkRecordNo,settngs);
                        else if((settngs.File_Name__c.contains('NewBAPP')) && (!String.isEmpty(settngs.Product_Code__c)) && (!String.isEmpty(settngs.Location_Code__c)) && (!String.isEmpty(settngs.Display_English_Rack_Name__c)) && (!String.isEmpty(settngs.Display_English_Product_Group__c)))
                            newBAPPSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('NewBAPP')) && (String.isEmpty(settngs.Product_Code__c)) && (String.isEmpty(settngs.Location_Code__c)))
                            newBAPPSettngs.put(settngs.Rack_Name__c+'-'+blnkRecordNo,settngs);  
                        else if((settngs.File_Name__c.contains('BrandedNotificationChangeAmount')) && (!String.isEmpty(settngs.Rack_Name__c)))
                            branNotiChangeAmtSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('BrandedNotificationChangeAmount')) && (String.isEmpty(settngs.Rack_Name__c)))
                            branNotiChangeAmtSettngs.put('BrNotiChgAmt_'+blnkRecordNo+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('BrandedNotificationExternalWeb')) && (!String.isEmpty(settngs.Rack_Name__c)))
                            branNotiExtWebSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('BrandedNotificationExternalWeb')) && (String.isEmpty(settngs.Rack_Name__c)))
                            branNotiExtWebSettngs.put('BrNotiExtWeb_'+blnkRecordNo+'-'+settngs.Display_English_Product_Group__c,settngs);                  
                       else if((settngs.File_Name__c.contains('CanadianRackPricing')) && (!String.isEmpty(settngs.Rack_Name__c)))
                            canadianRackPricingSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('CanadianRackPricing')) && (String.isEmpty(settngs.Rack_Name__c)))
                            canadianRackPricingSettngs.put('CandRckPrcng_'+blnkRecordNo+'-'+settngs.Display_English_Product_Group__c,settngs); 
                 
                        blnkRecordNo = blnkRecordNo+1;
                    }
                }
                // Only NewRack records
                else if((emailName.containsKey('Internal Rack Notification')) 
                        || (emailName.containsKey('SFJ Rack notification')) || (emailName.containsKey('Shell Rack Customer Notification')))
                {                    
                    // Get all the NewRack and NewBAPP Records on the specified date
                    for(RE_MY_CostPrice__c costPrice : [SELECT Id, RE_Product_Codes__c, RE_Depot_Code__c, RE_CND_Group__c, RE_CND_NewRack_Or_NewBAPP_File__c,                                              
                                                        RE_CND_Old_Base_Value__c,RE_CND_Net_Move_Value__c,RE_CND_Final_Value__c, RE_CND_Rack__c, RE_CND_Product_Group__c,
                                                        RE_Requested_Date__c, RE_CND_Effective_From_Date__c, RE_CND_Effective_To_Date__c
                                                        FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                                        AND RE_CND_Effective_From_Date__c <=: reqFrmDate AND RE_CND_Effective_To_Date__c >=: reqFrmDate
                                                        AND RE_IsLatest__c =: TRUE AND RE_CND_Notify_Users__c =: TRUE                                                       
                                                        AND RE_CND_NewRack_Or_NewBAPP_File__c =: 'NewRack'])
                    {       
                        requestedDt = costPrice.RE_Requested_Date__c;
                        effectveFromDt = costPrice.RE_CND_Effective_From_Date__c;
                        effectveToDt = costPrice.RE_CND_Effective_To_Date__c;
                        
                        reqNewRackCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);                                         
                    }
                    
                    for(RE_CND_Conga_Output_Settings__c settngs: [SELECT Id, File_Name__c, Product_Code__c, Location_Code__c, Group__c, Display_English_Rack_Name__c, Display_French_Rack_Name__c,
                                                                  Display_English_Product_Group__c, Display_French_Product_Group__c, Sequence_No__c, Section_Name__c, Rack_Name__c, Product_Group_Name__c
                                                                  FROM RE_CND_Conga_Output_Settings__c WHERE Is_Active__c = : TRUE 
                                                                  AND File_Name__c =: 'RackCustomerNotification' ORDER BY Name])
                    {
                        if((settngs.File_Name__c.contains('RackCustomerNotification')) && (!String.isEmpty(settngs.Product_Code__c)) && (!String.isEmpty(settngs.Location_Code__c)) && (!String.isEmpty(settngs.Display_English_Rack_Name__c)) && (!String.isEmpty(settngs.Display_English_Product_Group__c)))
                            newRackSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('RackCustomerNotification')) && (String.isEmpty(settngs.Product_Code__c)) && (String.isEmpty(settngs.Location_Code__c)))
                            newRackSettngs.put(settngs.Rack_Name__c+'-'+blnkRecordNo,settngs);
                        
                        blnkRecordNo = blnkRecordNo+1;
                    }
                }
                // Only NewBAPP file
                else if(emailName.containsKey('Internal Shell Canada BRPP Notification')) 
                {
                    // Get all the NewRack and NewBAPP Records on the specified date
                    for(RE_MY_CostPrice__c costPrice : [SELECT Id, RE_Product_Codes__c, RE_Depot_Code__c, RE_CND_Group__c, RE_CND_NewRack_Or_NewBAPP_File__c,                                              
                                                        RE_CND_Old_Base_Value__c,RE_CND_Net_Move_Value__c,RE_CND_Final_Value__c, RE_CND_Rack__c, RE_CND_Product_Group__c,
                                                        RE_Requested_Date__c, RE_CND_Effective_From_Date__c, RE_CND_Effective_To_Date__c
                                                        FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                                        AND RE_CND_Effective_From_Date__c <=: reqFrmDate AND RE_CND_Effective_To_Date__c >=: reqFrmDate
                                                        AND RE_IsLatest__c =: TRUE AND RE_CND_Notify_Users__c =: TRUE                                                        
                                                        AND RE_CND_NewRack_Or_NewBAPP_File__c =: 'NewBAPP'])
                    {       
                        requestedDt = costPrice.RE_Requested_Date__c;
                        effectveFromDt = costPrice.RE_CND_Effective_From_Date__c;
                        effectveToDt = costPrice.RE_CND_Effective_To_Date__c;
                        
                        reqNewBAPPCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);                    
                    }
                    
                    for(RE_CND_Conga_Output_Settings__c settngs: [SELECT Id, File_Name__c, Product_Code__c, Location_Code__c, Group__c, Display_English_Rack_Name__c, Display_French_Rack_Name__c,
                                                                  Display_English_Product_Group__c, Display_French_Product_Group__c, Sequence_No__c, Section_Name__c, Rack_Name__c, Product_Group_Name__c
                                                                  FROM RE_CND_Conga_Output_Settings__c WHERE Is_Active__c = : TRUE 
                                                                  AND File_Name__c =: 'NewBAPP' ORDER BY Name])
                    {
                        if((settngs.File_Name__c.contains('NewBAPP')) && (!String.isEmpty(settngs.Product_Code__c)) && (!String.isEmpty(settngs.Location_Code__c)) && (!String.isEmpty(settngs.Display_English_Rack_Name__c)) && (!String.isEmpty(settngs.Display_English_Product_Group__c)))
                            newBAPPSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('NewBAPP')) && (String.isEmpty(settngs.Product_Code__c)) && (String.isEmpty(settngs.Location_Code__c)))
                            newBAPPSettngs.put(settngs.Rack_Name__c+'-'+blnkRecordNo,settngs);
                        
                        blnkRecordNo = blnkRecordNo+1;
                    }
                }      
                // Both NewRack & NewBAPP file
                else if(emailName.containsKey('Shell Canada - Branded Customer Notification')) 
                {
                    // Get all the NewRack and NewBAPP Records on the specified date
                    for(RE_MY_CostPrice__c costPrice : [SELECT Id, RE_Product_Codes__c, RE_Depot_Code__c, RE_CND_Group__c, RE_CND_NewRack_Or_NewBAPP_File__c,                                              
                                                        RE_CND_Old_Base_Value__c,RE_CND_Net_Move_Value__c,RE_CND_Final_Value__c, RE_CND_Rack__c, RE_CND_Product_Group__c,
                                                        RE_Requested_Date__c, RE_CND_Effective_From_Date__c, RE_CND_Effective_To_Date__c
                                                        FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                                        AND RE_CND_Effective_From_Date__c <=: reqFrmDate AND RE_CND_Effective_To_Date__c >=: reqFrmDate
                                                        AND RE_IsLatest__c =: TRUE AND RE_CND_Notify_Users__c =: TRUE                                                         
                                                        AND RE_CND_NewRack_Or_NewBAPP_File__c IN ('NewRack','NewBAPP')])
                    {       
                        requestedDt = costPrice.RE_Requested_Date__c;
                        effectveFromDt = costPrice.RE_CND_Effective_From_Date__c;
                        effectveToDt = costPrice.RE_CND_Effective_To_Date__c;
                        
                        if(costPrice.RE_CND_NewRack_Or_NewBAPP_File__c == 'NewRack')
                            reqNewRackCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);
                        else if(costPrice.RE_CND_NewRack_Or_NewBAPP_File__c == 'NewBAPP')
                            reqNewBAPPCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);                    
                    }
                    
                    for(RE_CND_Conga_Output_Settings__c settngs: [SELECT Id, File_Name__c, Product_Code__c, Location_Code__c, Group__c, Display_English_Rack_Name__c, Display_French_Rack_Name__c,
                                                                  Display_English_Product_Group__c, Display_French_Product_Group__c, Sequence_No__c, Section_Name__c, Rack_Name__c, Product_Group_Name__c
                                                                  FROM RE_CND_Conga_Output_Settings__c WHERE Is_Active__c = : TRUE 
                                                                  AND File_Name__c IN ('RackCustomerNotification','BrandedNotificationChangeAmount','BrandedNotificationExternalWeb')
                                                                  ORDER BY Name])
                    {
                        if((settngs.File_Name__c.contains('RackCustomerNotification'))  && (!String.isEmpty(settngs.Product_Code__c)) && (!String.isEmpty(settngs.Location_Code__c)) && (!String.isEmpty(settngs.Display_English_Rack_Name__c)) && (!String.isEmpty(settngs.Display_English_Product_Group__c)))
                            newRackSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('RackCustomerNotification'))  && (String.isEmpty(settngs.Product_Code__c)) && (String.isEmpty(settngs.Location_Code__c)))
                            newRackSettngs.put(settngs.Rack_Name__c+'-'+blnkRecordNo,settngs);
                        else if((settngs.File_Name__c.contains('BrandedNotificationChangeAmount')) && (!String.isEmpty(settngs.Rack_Name__c)))
                            branNotiChangeAmtSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('BrandedNotificationChangeAmount')) && (String.isEmpty(settngs.Rack_Name__c)))
                            branNotiChangeAmtSettngs.put('BrNotiChgAmt_'+blnkRecordNo+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('BrandedNotificationExternalWeb')) && (!String.isEmpty(settngs.Rack_Name__c)))
                            branNotiExtWebSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('BrandedNotificationExternalWeb')) && (String.isEmpty(settngs.Rack_Name__c)))
                            branNotiExtWebSettngs.put('BrNotiExtWeb_'+blnkRecordNo+'-'+settngs.Display_English_Product_Group__c,settngs); 
                        
                        blnkRecordNo = blnkRecordNo+1;
                    }
                }
                // Get Canadian Rack Pricing and rack pricing Files
				else if(emailName.containsKey('Canadian Rack Pricing and rack pricing Files'))  
                {
                     // Get all the NewRack Records on the specified date
                    for(RE_MY_CostPrice__c costPrice : [SELECT Id, RE_Product_Codes__c, RE_Depot_Code__c, RE_CND_Group__c, RE_CND_NewRack_Or_NewBAPP_File__c,                                              
                                                        RE_CND_Old_Base_Value__c,RE_CND_Net_Move_Value__c,RE_CND_Final_Value__c, RE_CND_Rack__c, RE_CND_Product_Group__c,
                                                        RE_Requested_Date__c, RE_CND_Effective_From_Date__c, RE_CND_Effective_To_Date__c
                                                        FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                                        AND RE_CND_Effective_From_Date__c <=: reqFrmDate AND RE_CND_Effective_To_Date__c >=: reqFrmDate
                                                        AND RE_IsLatest__c =: TRUE AND RE_CND_Notify_Users__c =: TRUE                                                        
                                                        AND RE_CND_NewRack_Or_NewBAPP_File__c =: 'NewRack'])
                    {       
                        requestedDt = costPrice.RE_Requested_Date__c;
                        effectveFromDt = costPrice.RE_CND_Effective_From_Date__c;
                        effectveToDt = costPrice.RE_CND_Effective_To_Date__c;
                        
                        reqNewRackCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);                    
                    }
                    
                    for(RE_CND_Conga_Output_Settings__c settngs: [SELECT Id, File_Name__c, Product_Code__c, Location_Code__c, Group__c, Display_English_Rack_Name__c, Display_French_Rack_Name__c,
                                                                  Display_English_Product_Group__c, Display_French_Product_Group__c, Sequence_No__c, Section_Name__c, Rack_Name__c, Product_Group_Name__c
                                                                  FROM RE_CND_Conga_Output_Settings__c WHERE Is_Active__c = : TRUE 
                                                                  AND File_Name__c =: 'CanadianRackPricing' ORDER BY Name])
                    {
                        if((settngs.File_Name__c.contains('CanadianRackPricing')) && (!String.isEmpty(settngs.Product_Code__c)) && (!String.isEmpty(settngs.Location_Code__c)) && (!String.isEmpty(settngs.Display_English_Rack_Name__c)) && (!String.isEmpty(settngs.Display_English_Product_Group__c)))
                            canadianRackPricingSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else if((settngs.File_Name__c.contains('CanadianRackPricing')) && (String.isEmpty(settngs.Product_Code__c)) && (String.isEmpty(settngs.Location_Code__c)))
                            canadianRackPricingSettngs.put(settngs.Rack_Name__c+'-'+blnkRecordNo,settngs);
                        
                        blnkRecordNo = blnkRecordNo+1;
                    }                   
                }
                
                blnkRecordNo = 1;
                // This is for Shell Canada Rack Notification
                if(emailName.containsKey('Shell Canada Rack Notification')) 
                {
                    // Get all the NewRack and NewBAPP Records on the specified date
                    for(RE_MY_CostPrice__c costPrice : [SELECT Id, RE_Product_Codes__c, RE_Depot_Code__c, RE_CND_Group__c,                                               
                                                        RE_CND_Old_Base_Value__c,RE_CND_Net_Move_Value__c,RE_CND_Final_Value__c, RE_CND_Rack__c, RE_CND_Product_Group__c,
                                                        RE_Requested_Date__c, RE_CND_Effective_From_Date__c, RE_CND_Effective_To_Date__c
                                                        FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                                        AND RE_CND_Effective_From_Date__c <=: reqFrmDate AND RE_CND_Effective_To_Date__c >=: reqFrmDate
                                                        AND RE_IsLatest__c =: TRUE AND RE_CND_Notify_Users__c =: TRUE                                                        
                                                        AND RE_CND_Req_in_DailyRackChange_Notifi__c =: TRUE])
                    {      
                        requestedDt = costPrice.RE_Requested_Date__c;
                        effectveFromDt = costPrice.RE_CND_Effective_From_Date__c;
                        effectveToDt = costPrice.RE_CND_Effective_To_Date__c;
                        
                        reqRackChangeNotiCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);                        
                    }
                    
                    for(RE_CND_Conga_Output_Settings__c settngs: [SELECT Id, File_Name__c, Product_Code__c, Location_Code__c, Group__c, Rack_Name__c, Product_Group_Name__c, 
                                                                  Display_English_Rack_Name__c, Display_English_Product_Group__c, Sequence_No__c
                                                                  FROM RE_CND_Conga_Output_Settings__c WHERE Is_Active__c = : TRUE 
                                                                  AND File_Name__c =: 'RackChangeNotification' ORDER BY Name])
                    {
                        if(!String.isEmpty(settngs.Rack_Name__c))
                            rackChngeNotiSettngs.put(settngs.Product_Code__c+'-'+settngs.Location_Code__c+'-'+settngs.Group__c+'-#@#-'+settngs.Display_English_Rack_Name__c+'-'+settngs.Display_English_Product_Group__c,settngs);
                        else
                            rackChngeNotiSettngs.put('RckChg_'+blnkRecordNo+'-'+settngs.Display_English_Product_Group__c,settngs);  
                        
                        blnkRecordNo = blnkRecordNo+1;
                    }
                }
                
                // NewRack records to be created in MyOutput
                if(newRackSettngs.Size() > 0)
                {             
                    String[] rckKeyNameSplit;
                    String rckKeyName;
                    for(String newRackKeyName: newRackSettngs.Keyset())
                    { 
                        RE_MY_Output__c myOP = New RE_MY_Output__c();
                        RE_MY_CostPrice__c costPrice = new RE_MY_CostPrice__c();  
                        RE_CND_Conga_Output_Settings__c cndCongaSettngs = New RE_CND_Conga_Output_Settings__c();
                        cndCongaSettngs = newRackSettngs.get(newRackKeyName);
                        
                        rckKeyNameSplit = newRackKeyName.split('-#@#-');
                        rckKeyName = rckKeyNameSplit[0];
                        
                        if(reqNewRackCostPrice.containsKey(rckKeyName))
                        {
                            costPrice = reqNewRackCostPrice.get(rckKeyName);
                            
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = costPrice.RE_Requested_Date__c;
                            myOP.RE_Effective_From_Date__c = costPrice.RE_CND_Effective_From_Date__c;
                            myOP.RE_Effective_To_Date__c = costPrice.RE_CND_Effective_To_Date__c;
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c;
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c;
                            myOP.RE_CND_Old_Value__c = costPrice.RE_CND_Old_Base_Value__c;
                            myOP.RE_CND_Change_Value__c = costPrice.RE_CND_Net_Move_Value__c;
                            myOP.RE_CND_New_Value__c = costPrice.RE_CND_Final_Value__c;
                            myOP.RE_CND_NewRackBAPP_Sequence__c = cndCongaSettngs.Sequence_No__c;
                            myOP.RE_CND_NewRackBAPP_Section__c = cndCongaSettngs.Section_Name__c;
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'RackCustomerNotification';
                            myOP.RE_CND_Output_Key_Name__c = costPrice.RE_CND_Rack__c +'-'+ costPrice.RE_Product_Codes__c + '-' + costPrice.RE_Depot_Code__c + '-' + costPrice.RE_CND_Product_Group__c + '-' + costPrice.RE_CND_Group__c;
                            tobeCreated.add(myOP);                            
                        }
                        else
                        {                           
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = requestedDt;
                            myOP.RE_Effective_From_Date__c = effectveFromDt;
                            myOP.RE_Effective_To_Date__c = effectveToDt;
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c;
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c;
                            myOP.RE_CND_NewRackBAPP_Sequence__c = cndCongaSettngs.Sequence_No__c;
                            myOP.RE_CND_NewRackBAPP_Section__c = cndCongaSettngs.Section_Name__c;
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'RackCustomerNotification';
                            myOP.RE_CND_Output_Key_Name__c = cndCongaSettngs.Rack_Name__c +'-'+ cndCongaSettngs.Product_Code__c + '-' + cndCongaSettngs.Location_Code__c + '-' + cndCongaSettngs.Product_Group_Name__c + '-' + cndCongaSettngs.Group__c;
                            tobeCreated.add(myOP);                            
                        }
                    }
                }
                
                // NewBAPP records to be created in MyOutput
                if(newBAPPSettngs.Size() > 0)
                {             
                    String[] nBAPPKeyNameSplit;
                    String nBAPPKeyName;
                    for(String newBAPPKeyName: newBAPPSettngs.Keyset())
                    { 
                        RE_MY_Output__c myOP = New RE_MY_Output__c();
                        RE_MY_CostPrice__c costPrice = new RE_MY_CostPrice__c();  
                        RE_CND_Conga_Output_Settings__c cndCongaSettngs = New RE_CND_Conga_Output_Settings__c();
                        cndCongaSettngs = newBAPPSettngs.get(newBAPPKeyName);
                        
                        nBAPPKeyNameSplit = newBAPPKeyName.split('-#@#-');
                        nBAPPKeyName = nBAPPKeyNameSplit[0];
                        
                        if(reqNewBAPPCostPrice.containsKey(nBAPPKeyName))
                        {
                            costPrice = reqNewBAPPCostPrice.get(nBAPPKeyName);                            
                            
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = costPrice.RE_Requested_Date__c;
                            myOP.RE_Effective_From_Date__c = costPrice.RE_CND_Effective_From_Date__c;
                            myOP.RE_Effective_To_Date__c = costPrice.RE_CND_Effective_To_Date__c;
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c;
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c;
                            myOP.RE_CND_Old_Value__c = costPrice.RE_CND_Old_Base_Value__c;
                            myOP.RE_CND_Change_Value__c = costPrice.RE_CND_Net_Move_Value__c;
                            myOP.RE_CND_New_Value__c = costPrice.RE_CND_Final_Value__c;
                            myOP.RE_CND_NewRackBAPP_Sequence__c = cndCongaSettngs.Sequence_No__c;
                            myOP.RE_CND_NewRackBAPP_Section__c = cndCongaSettngs.Section_Name__c;
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'NewBAPP';
                            myOP.RE_CND_Output_Key_Name__c = costPrice.RE_CND_Rack__c +'-'+ costPrice.RE_Product_Codes__c + '-' + costPrice.RE_Depot_Code__c + '-' + costPrice.RE_CND_Product_Group__c + '-' + costPrice.RE_CND_Group__c;
                            tobeCreated.add(myOP);                            
                        }
                        else
                        {
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = requestedDt;
                            myOP.RE_Effective_From_Date__c = effectveFromDt;
                            myOP.RE_Effective_To_Date__c = effectveToDt;
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c;
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c;
                            myOP.RE_CND_NewRackBAPP_Sequence__c = cndCongaSettngs.Sequence_No__c;
                            myOP.RE_CND_NewRackBAPP_Section__c = cndCongaSettngs.Section_Name__c;
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'NewBAPP';
                            myOP.RE_CND_Output_Key_Name__c = cndCongaSettngs.Rack_Name__c +'-'+ cndCongaSettngs.Product_Code__c + '-' + cndCongaSettngs.Location_Code__c + '-' + cndCongaSettngs.Product_Group_Name__c + '-' + cndCongaSettngs.Group__c;
                            tobeCreated.add(myOP);                            
                        }
                    }
                }
                
                 // Branded Notification Change Amount records to be created in MyOutput
                if(branNotiChangeAmtSettngs.Size() > 0)
                {       
                    String[] brNotiChangeKeyNameSplit;
                    String brNotiChangeAmtKeyName;
                    for(String brNotiChangeKeyName: branNotiChangeAmtSettngs.Keyset())
                    { 
                        RE_MY_Output__c myOP = New RE_MY_Output__c();
                        RE_MY_CostPrice__c costPrice = new RE_MY_CostPrice__c();  
                        RE_CND_Conga_Output_Settings__c cndCongaSettngs = New RE_CND_Conga_Output_Settings__c();
                        cndCongaSettngs = branNotiChangeAmtSettngs.get(brNotiChangeKeyName);
                        
                        brNotiChangeKeyNameSplit = brNotiChangeKeyName.split('-#@#-');
                        brNotiChangeAmtKeyName = brNotiChangeKeyNameSplit[0];                        
                        
                        if(reqNewBAPPCostPrice.containsKey(brNotiChangeAmtKeyName))
                        {
                            costPrice = reqNewBAPPCostPrice.get(brNotiChangeAmtKeyName);
                            
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = costPrice.RE_Requested_Date__c;
                            myOP.RE_Effective_From_Date__c = costPrice.RE_CND_Effective_From_Date__c;
                            myOP.RE_Effective_To_Date__c = costPrice.RE_CND_Effective_To_Date__c;                            
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c; 
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c; 							
                            myOP.RE_CND_Change_Value__c =  costPrice.RE_CND_Net_Move_Value__c / 100;                            
                            myOP.RE_CND_RackChangeNoti_Sequence__c = cndCongaSettngs.Sequence_No__c;                          
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'BrandedNotificationChangeAmount';
                            myOP.RE_CND_Output_Key_Name__c = costPrice.RE_CND_Rack__c +'-'+ costPrice.RE_Product_Codes__c + '-' + costPrice.RE_Depot_Code__c + '-' + costPrice.RE_CND_Product_Group__c + '-' + costPrice.RE_CND_Group__c;
                            tobeCreated.add(myOP);                            
                        }
                        else
                        {
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = requestedDt;
                            myOP.RE_Effective_From_Date__c = effectveFromDt;
                            myOP.RE_Effective_To_Date__c = effectveToDt;
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c; 
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c; 								
                            myOP.RE_CND_RackChangeNoti_Sequence__c = cndCongaSettngs.Sequence_No__c;                           
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'BrandedNotificationChangeAmount';
                            myOP.RE_CND_Output_Key_Name__c = cndCongaSettngs.Rack_Name__c +'-'+ cndCongaSettngs.Product_Code__c + '-' + cndCongaSettngs.Location_Code__c + '-' + cndCongaSettngs.Product_Group_Name__c + '-' + cndCongaSettngs.Group__c;
                            tobeCreated.add(myOP);                            
                        }
                    }
                }      
                
                // Branded Notification External Web records to be created in MyOutput
                if(branNotiExtWebSettngs.Size() > 0)
                {       
                    String[] brNotiExtWebKeyNameSplit;
                    String brNotiExtWebKeyName;
                    for(String brNotifiExtWebKeyName: branNotiExtWebSettngs.Keyset())
                    { 
                        RE_MY_Output__c myOP = New RE_MY_Output__c();
                        RE_MY_CostPrice__c costPrice = new RE_MY_CostPrice__c();  
                        RE_CND_Conga_Output_Settings__c cndCongaSettngs = New RE_CND_Conga_Output_Settings__c();
                        cndCongaSettngs = branNotiExtWebSettngs.get(brNotifiExtWebKeyName);
                        
                        brNotiExtWebKeyNameSplit = brNotifiExtWebKeyName.split('-#@#-');
                        brNotiExtWebKeyName = brNotiExtWebKeyNameSplit[0];                        
                        
                        if(reqNewBAPPCostPrice.containsKey(brNotiExtWebKeyName))
                        {
                            costPrice = reqNewBAPPCostPrice.get(brNotiExtWebKeyName);
                            
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = costPrice.RE_Requested_Date__c;
                            myOP.RE_Effective_From_Date__c = costPrice.RE_CND_Effective_From_Date__c;
                            myOP.RE_Effective_To_Date__c = costPrice.RE_CND_Effective_To_Date__c;                            
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c; 
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c; 							
                            myOP.RE_CND_New_Value__c = costPrice.RE_CND_Final_Value__c;                            
                            myOP.RE_CND_RackChangeNoti_Sequence__c = cndCongaSettngs.Sequence_No__c;                          
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'BrandedNotificationExternalWeb';
                            myOP.RE_CND_Output_Key_Name__c = costPrice.RE_CND_Rack__c +'-'+ costPrice.RE_Product_Codes__c + '-' + costPrice.RE_Depot_Code__c + '-' + costPrice.RE_CND_Product_Group__c + '-' + costPrice.RE_CND_Group__c;
                            tobeCreated.add(myOP);                            
                        }
                        else
                        {
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = requestedDt;
                            myOP.RE_Effective_From_Date__c = effectveFromDt;
                            myOP.RE_Effective_To_Date__c = effectveToDt;
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c; 
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c; 								
                            myOP.RE_CND_RackChangeNoti_Sequence__c = cndCongaSettngs.Sequence_No__c;                           
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'BrandedNotificationExternalWeb';
                            myOP.RE_CND_Output_Key_Name__c = cndCongaSettngs.Rack_Name__c +'-'+ cndCongaSettngs.Product_Code__c + '-' + cndCongaSettngs.Location_Code__c + '-' + cndCongaSettngs.Product_Group_Name__c + '-' + cndCongaSettngs.Group__c;
                            tobeCreated.add(myOP);                            
                        }
                    }
                }              
                
                // CanadianRackPricing records to be created in MyOutput
                if(canadianRackPricingSettngs.Size() > 0)
                {             
                    String[] rckKeyNameSplit;
                    String rckKeyName;
                    for(String newRackKeyName: canadianRackPricingSettngs.Keyset())
                    { 
                        RE_MY_Output__c myOP = New RE_MY_Output__c();
                        RE_MY_CostPrice__c costPrice = new RE_MY_CostPrice__c();  
                        RE_CND_Conga_Output_Settings__c cndCongaSettngs = New RE_CND_Conga_Output_Settings__c();
                        cndCongaSettngs = canadianRackPricingSettngs.get(newRackKeyName);
                        
                        rckKeyNameSplit = newRackKeyName.split('-#@#-');
                        rckKeyName = rckKeyNameSplit[0];
                        
                        if(reqNewRackCostPrice.containsKey(rckKeyName))
                        {
                            costPrice = reqNewRackCostPrice.get(rckKeyName);                           
                            
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = costPrice.RE_Requested_Date__c;
                            myOP.RE_Effective_From_Date__c = costPrice.RE_CND_Effective_From_Date__c;
                            myOP.RE_Effective_To_Date__c = costPrice.RE_CND_Effective_To_Date__c;
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c;
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c;                            
                            myOP.RE_CND_New_Value__c = costPrice.RE_CND_Final_Value__c;
                            myOP.RE_CND_NewRackBAPP_Sequence__c = cndCongaSettngs.Sequence_No__c;                            
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'CanadianRackPricing';
                            myOP.RE_CND_Output_Key_Name__c = costPrice.RE_CND_Rack__c +'-'+ costPrice.RE_Product_Codes__c + '-' + costPrice.RE_Depot_Code__c + '-' + costPrice.RE_CND_Product_Group__c + '-' + costPrice.RE_CND_Group__c;
                            tobeCreated.add(myOP);                            
                        }
                        else
                        {
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = requestedDt;
                            myOP.RE_Effective_From_Date__c = effectveFromDt;
                            myOP.RE_Effective_To_Date__c = effectveToDt;
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c;
                            myOP.RE_CND_Rack_French__c = cndCongaSettngs.Display_French_Rack_Name__c;
                            myOP.RE_CND_Product_Group_French__c = cndCongaSettngs.Display_French_Product_Group__c;
                            myOP.RE_CND_NewRackBAPP_Sequence__c = cndCongaSettngs.Sequence_No__c;                            
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'CanadianRackPricing';
                            myOP.RE_CND_Output_Key_Name__c = cndCongaSettngs.Rack_Name__c +'-'+ cndCongaSettngs.Product_Code__c + '-' + cndCongaSettngs.Location_Code__c + '-' + cndCongaSettngs.Product_Group_Name__c + '-' + cndCongaSettngs.Group__c;
                            tobeCreated.add(myOP);                            
                        }
                    }
                }                
                
                // Rack Change Notification records to be created in MyOutput
                if(rackChngeNotiSettngs.Size() > 0)
                {       
                    String[] rckChangeKeyNameSplit;
                    String rckChangeKeyName;
                    for(String newRackChngeKeyName: rackChngeNotiSettngs.Keyset())
                    { 
                        RE_MY_Output__c myOP = New RE_MY_Output__c();
                        RE_MY_CostPrice__c costPrice = new RE_MY_CostPrice__c();  
                        RE_CND_Conga_Output_Settings__c cndCongaSettngs = New RE_CND_Conga_Output_Settings__c();
                        cndCongaSettngs = rackChngeNotiSettngs.get(newRackChngeKeyName);
                        
                        rckChangeKeyNameSplit = newRackChngeKeyName.split('-#@#-');
                        rckChangeKeyName = rckChangeKeyNameSplit[0];                        
                        
                        if(reqRackChangeNotiCostPrice.containsKey(rckChangeKeyName))
                        {
                            costPrice = reqRackChangeNotiCostPrice.get(rckChangeKeyName);
                            
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = costPrice.RE_Requested_Date__c;
                            myOP.RE_Effective_From_Date__c = costPrice.RE_CND_Effective_From_Date__c;
                            myOP.RE_Effective_To_Date__c = costPrice.RE_CND_Effective_To_Date__c;                            
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c;                     
                            myOP.RE_CND_Change_Value__c = costPrice.RE_CND_Net_Move_Value__c;
                            myOP.RE_CND_New_Value__c = costPrice.RE_CND_Final_Value__c;
                            myOP.RE_CND_RackChangeNoti_Sequence__c = cndCongaSettngs.Sequence_No__c;                          
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'RackChangeNotification';
                            myOP.RE_CND_Output_Key_Name__c = costPrice.RE_CND_Rack__c +'-'+ costPrice.RE_Product_Codes__c + '-' + costPrice.RE_Depot_Code__c + '-' + costPrice.RE_CND_Product_Group__c + '-' + costPrice.RE_CND_Group__c;
                            tobeCreated.add(myOP);                            
                        }
                        else
                        {
                            myOP.RecordTypeId = cndMyOutputRecdTypId;
                            myOP.RE_Type__c = 'Canada Output';
                            myOP.RE_Pricing_Date__c = requestedDt;
                            myOP.RE_Effective_From_Date__c = effectveFromDt;
                            myOP.RE_Effective_To_Date__c = effectveToDt;
                            myOP.RE_CND_Rack_English__c = cndCongaSettngs.Display_English_Rack_Name__c;
                            myOP.RE_CND_Product_Group_English__c = cndCongaSettngs.Display_English_Product_Group__c;                    
                            myOP.RE_CND_RackChangeNoti_Sequence__c = cndCongaSettngs.Sequence_No__c;                           
                            myOP.RE_IsLatest__c = TRUE;    
                            myOP.RE_CND_Reporting_Name__c = 'RackChangeNotification';
                            myOP.RE_CND_Output_Key_Name__c = cndCongaSettngs.Rack_Name__c +'-'+ cndCongaSettngs.Product_Code__c + '-' + cndCongaSettngs.Location_Code__c + '-' + cndCongaSettngs.Product_Group_Name__c + '-' + cndCongaSettngs.Group__c;
                            tobeCreated.add(myOP);                            
                        }
                    }
                } 

                // Update existing MyOutput set as Inactive and Create new MyOutput
                if(tobeUpdated.Size() > 0 && tobeCreated.Size() > 0)
                {
                    // Update existing MyOutput set as Inactive
                    Database.SaveResult[] updateMyOPList = Database.update(tobeUpdated, false);
                    Boolean updateSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_EmailMyOutputController','emailMyOutputCreation-UpdateMyOutput',updateMyOPList,false, jrAudit);                                                                               
                    if(!updateSuccess)
                    {
                        Set<Id> myOPIds = New Set<Id>();
                        // Create new MyOutput
                        Database.SaveResult[] myOPList = Database.insert(tobeCreated, false);
                        myOPIds = RE_CND_Utility.handleInsert('RE_CND_EmailMyOutputController','emailMyOutputCreation-CreateMyOutput',myOPList,jrAudit);                        
                        
                        if(myOPIds.Size() > 0)
                            // Process Conga email part & Job Audit
 							processCongaEmails(emailNames,isEmailToMe,jrAudit,jrAuditStatus,reqFrmDate);                        
                        else                        
                            System.debug('There is no new records created in MyOutput!');                         
                    }
                    else                    
                        System.debug('There is a issue while updating Old MyOutput, please refer exception records!');                     
                }
                // Create new MyOutput
                else if(tobeCreated.Size() > 0)
                {                   
                    Set<Id> myOPIds = New Set<Id>();
                    Database.SaveResult[] myOPList = Database.insert(tobeCreated, false);
                    myOPIds = RE_CND_Utility.handleInsert('RE_CND_EmailMyOutputController','emailMyOutputCreation-CreateOnlyMyOutput',myOPList,jrAudit);                        
                    
                    if(myOPIds.Size() > 0)    
                        // Process Conga email part & Job Audit
                 		processCongaEmails(emailNames,isEmailToMe,jrAudit,jrAuditStatus,reqFrmDate);                    
                    else                    
                       System.debug('Only Records Part - There is no new records created in the MyOutput!');                     
                }
                // Update existing MyOutput
                else if(tobeUpdated.Size() > 0)
                {
                    // Update existing MyOutput set as Inactive
                    Database.SaveResult[] updateMyOPList = Database.update(tobeUpdated, false);
                    Boolean updateSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_EmailMyOutputController','emailMyOutputCreation-UpdateMyOutput',updateMyOPList,false, jrAudit);                                                                               
                    
                    if(!updateSuccess)
                       // Process Conga email part & Job Audit
                 	   processCongaEmails(emailNames,isEmailToMe,jrAudit,jrAuditStatus,reqFrmDate);                    
                    else
                       System.debug('There is a issue while updating Old MyOutput, please refer exception records!');                
                }
                else                					
                   // Process Conga email part & Job Audit
                   processCongaEmails(emailNames,isEmailToMe,jrAudit,jrAuditStatus,reqFrmDate); 
            }            
        }
        Catch(Exception ex)
        {
            System.debug('RE_CND_EmailMyOutputController-Error-->'+ex.getMessage());
            System.debug('RE_CND_EmailMyOutputController-Error-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('RE_CND_EmailMyOutputController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_EmailMyOutputController','emailMyOutputCreation','Exception');            
            RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex);  
        }
    }
    
   public static Map<String,String> fetchEmailIdForOutputEmail(String type)
   {     
        Map<String, RE_Email_Recipient__mdt> configMap = New Map<String, RE_Email_Recipient__mdt>();  
        Map<String,String> mailMap = new Map<String,String>();
        for(RE_Email_Recipient__mdt emilRec: [Select Id, MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt
                                              WHERE Country__c =: 'Canada' AND Type__c =: type AND Is_Active__c =: TRUE])
        {
            configMap.put(emilRec.MasterLabel,emilRec);
        }
        
        for(String str : configMap.keySet()) 
        {
            RE_Email_Recipient__mdt config = New RE_Email_Recipient__mdt();
            config = configMap.get(str);                    
            String EmailIds =    config.To_List__c;
            String ccEmailIds =  config.Cc_List__c;
            String bccEmailIds =  config.Bcc_List__c;
            mailMap.put(config.MasterLabel,EmailIds+'β©¶'+ccEmailIds+'β©¶'+bccEmailIds);            
            System.debug('EmailIds-->'+EmailIds);
            System.debug('ccEmailIds-->'+ccEmailIds);
            System.debug('bccEmailIds-->'+bccEmailIds);
        } 

        return mailMap;
    }       

    public static void processCongaEmails(List<String> emailNames, Boolean isEmailToMe, RE_Job_Run_Audit__c jrAudit, String jrAuditStatus, Date reqFrmDate)    
    {        
        Map<String,String> emailName = New Map<String,String>();
        if(jrAuditStatus == 'Processing')
        {          
            jrAudit.RE_Job_Status__c = 'Completed'; 
            if(isEmailToMe)
                jrAudit.Other_Comments__c = 'Email sent to Me';
            else
                jrAudit.Other_Comments__c = 'Email sent to Recipients';
            
            // Update Job Audit Status
            update jrAudit;  
            
            // Process Conga email part
            if(emailNames.Size() > 0)
            {
                for(String eName : emailNames)
                {                
                    emailName.put(eName,eName);
                } 
                
                Map<String,String> emptyEmailIdMap = new Map<String,String>();
                
                if((emailName.containsKey('Internal Rack Notification')) && (isEmailToMe))      
                    RE_CND_MailController.rackNotificationUrl(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('Internal Rack Notification')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('Internal Rack Notification');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.rackNotificationUrl(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('InternalRackNoti-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.rackNotificationUrl(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('InternalRackNoti-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.rackNotificationUrl(isEmailToMe,targetMap);
                        }
                    }                    
                }
                
                if((emailName.containsKey('Shell Canada Rack Notification')) && (isEmailToMe))      
                    RE_CND_MailController.shellCanadaRackNotiUrl(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('Shell Canada Rack Notification')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('Shell Canada Rack Notification');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.shellCanadaRackNotiUrl(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('ShellRackNotif-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.shellCanadaRackNotiUrl(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('InternalShellBRPP-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.shellCanadaRackNotiUrl(isEmailToMe,targetMap);
                        }
                    }                    
                }
                
                if((emailName.containsKey('Internal Shell Canada BRPP Notification')) && (isEmailToMe))      
                    RE_CND_MailController.canadaBRPPNotiUrl(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('Internal Shell Canada BRPP Notification')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('Internal Shell Canada BRPP Notification');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.canadaBRPPNotiUrl(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('InternalShellBRPP-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.canadaBRPPNotiUrl(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('InternalShellBRPP-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.canadaBRPPNotiUrl(isEmailToMe,targetMap);
                        }
                    }                    
                }
                
                if((emailName.containsKey('SFJ Rack notification')) && (isEmailToMe))      
                    RE_CND_MailController.sfjRackNotiUrl(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('SFJ Rack notification')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('SFJ Rack notification');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.sfjRackNotiUrl(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('SFJRackNoti-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.sfjRackNotiUrl(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('SFJRackNoti-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.sfjRackNotiUrl(isEmailToMe,targetMap);
                        }
                    }                    
                }                
                
                if((emailName.containsKey('Canadian Rack Prices')) && (isEmailToMe))      
                    RE_CND_MailController.cndRackPricesUrl(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('Canadian Rack Prices')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('Canadian Rack Prices');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.cndRackPricesUrl(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('CanadianRackPrices-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.cndRackPricesUrl(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('CanadianRackPrices-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.cndRackPricesUrl(isEmailToMe,targetMap);
                        }
                    }                    
                }                
                
                if((emailName.containsKey('7 Day Canadian Rack Prices')) && (isEmailToMe))      
                    RE_CND_MailController.cndRackPrice7Day(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('7 Day Canadian Rack Prices')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('7 Day Canadian Rack Prices');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.cndRackPrice7Day(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('7Day-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.cndRackPrice7Day(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('7Day-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.cndRackPrice7Day(isEmailToMe,targetMap);
                        }
                    }                    
                }
                
                if((emailName.containsKey('Shell Rack Customer Notification')) && (isEmailToMe))      
                    RE_CND_MailController.shellRackCustomer(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('Shell Rack Customer Notification')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('Shell Rack Customer Notification');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.shellRackCustomer(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('ShellRackCustomrNoti-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.shellRackCustomer(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('ShellRackCustomrNoti-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.shellRackCustomer(isEmailToMe,targetMap);
                        }
                    }                    
                }                
                
                if((emailName.containsKey('Shell Canada - Branded Customer Notification')) && (isEmailToMe))      
                    RE_CND_MailController.brandedCustomer(isEmailToMe,reqFrmDate,emptyEmailIdMap);
                else if((emailName.containsKey('Shell Canada - Branded Customer Notification')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('Shell Canada - Branded Customer Notification');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.brandedCustomer(isEmailToMe,reqFrmDate,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('ShellCanadaBranded-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.brandedCustomer(isEmailToMe,reqFrmDate,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('ShellCanadaBranded-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.brandedCustomer(isEmailToMe,reqFrmDate,targetMap);
                        }
                    }                    
                }                
                
                if((emailName.containsKey('Canadian Rack Pricing and rack pricing Files')) && (isEmailToMe))      
                    RE_CND_MailController.CanadianRackPricing(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('Canadian Rack Pricing and rack pricing Files')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('Canadian Rack Pricing and rack pricing Files');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.CanadianRackPricing(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('CanadianRackPricing-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.CanadianRackPricing(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('CanadianRackPricing-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.CanadianRackPricing(isEmailToMe,targetMap);
                        }
                    }                    
                }                
                
               if((emailName.containsKey('Ready to Upload Notification')) && (isEmailToMe))      
                    RE_CND_MailController.readyToUploadNotiUlr(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('Ready to Upload Notification')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('Ready to Upload Notification');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.readyToUploadNotiUlr(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('Ready to Upload Notification-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.readyToUploadNotiUlr(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('Ready to Upload Notification-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.readyToUploadNotiUlr(isEmailToMe,targetMap);
                        }
                    }                    
                } 
                
                if((emailName.containsKey('No Revised Pricing')) && (isEmailToMe))      
                    RE_CND_MailController.noRevisedPricingUlr(isEmailToMe,emptyEmailIdMap);
                else if((emailName.containsKey('No Revised Pricing')) && (!(isEmailToMe)))  
                {
                    Map<String,String> EmailIdMap = new Map<String,String>();
                    EmailIdMap = fetchEmailIdForOutputEmail('No Revised Pricing');
                    Integer numEmailSets = 1;
                    Set<String> targetKeyset = new Set<String>();

                    if(EmailIdMap.Size() <= 1)
                      RE_CND_MailController.noRevisedPricingUlr(isEmailToMe,EmailIdMap);
                    else
                    {
                        for(String key :EmailIdMap.keySet())
                        {
                            if(numEmailSets <= 0) 
                            { 
                                Map<String, String> targetMap = EmailIdMap.clone();
								targetMap.keySet().retainAll(targetKeyset);
                                system.debug('No Revised Pricing-targetMap-->'+ targetMap);
                                targetKeyset.removeAll(targetKeyset);
                                numEmailSets = 1;
                                RE_CND_MailController.noRevisedPricingUlr(isEmailToMe,targetMap);
                            }
                            
                            targetKeyset.add(key);
                            numEmailSets--;
                        }
                        
                        if(targetKeyset.Size() > 0)
                        {
                            Map<String, String> targetMap = EmailIdMap.clone();
                            targetMap.keySet().retainAll(targetKeyset);
                            system.debug('No Revised Pricing-targetMap-outside-->'+ targetMap);
							targetKeyset.removeAll(targetKeyset);
                            RE_CND_MailController.noRevisedPricingUlr(isEmailToMe,targetMap);
                        }
                    }                    
                }
            }          		
        }
        else
        {       
            String comments;
            if(isEmailToMe)
                comments = 'EmailToMe - Refer RV_Exception__c record for more details with jobAudit :'+jrAudit.Id;
            else
                comments = 'RecipientsEmail - Refer RV_Exception__c record for more details with jobAudit :'+jrAudit.Id;
            
            RE_CND_Utility.updateJobAuditPartialSuccess(jrAudit,'Issue while generating Canada Email Output Job',comments);                          
        }
    }
}