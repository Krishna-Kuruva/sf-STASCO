/*****************************************************************************
@Name:  IK_LiveDisruptionTriggerClass     
@=========================================================================
@Purpose: helper class will execute on insert,update delete to  send email to particular user group                          
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      14/11/2017           INITIAL DEVELOPMENT
 
******************************************************************************/ 
public class IK_LiveDisruptionTriggerClass {
        
    public static void onbeforeinsertLiveDisrupt(List<Live_Disruption__c> alertnewlst){
        
        for(Live_Disruption__c liveDisrup : alertnewlst){
            
            if(liveDisrup.Product__c <> null && liveDisrup.IK_Location_Name__c <> null){// Assigning Title// Location_Name__c
                liveDisrup.Title__c =  title(liveDisrup.Product__c,liveDisrup.IK_Location_Name__c);
            }
            
            if(liveDisrup.Begin_Date__c > liveDisrup.Estimated_End_Date__c){//Validation on Begin Date and Estimated end date
                liveDisrup.addError('Begin Date cannot be greater than Estimated End Date');
            }  
            
        }
    }
    
    public static void onafterinsertLiveDisrupt(List<Live_Disruption__c> alertnewlst){
        
        Map<Id,InfoKiosk_Alert__c> fetchInfoKioskALetMap = fetchALertOnCreation();
        
        Map<String,List<InfoKiosk_Alert__c>> fetchprdctAlertMap = new Map<String,List<InfoKiosk_Alert__c>>();
        fetchprdctAlertMap = createprdctAlertMap(fetchInfoKioskALetMap);
        
        Map<String,List<InfoKiosk_Alert__c>> fetchLocAlertMap = new Map<String,List<InfoKiosk_Alert__c>>();
        fetchLocAlertMap = createLocAlertMap(fetchInfoKioskALetMap);
        
        
        //List<ID> lstUserIDs;
        List<Messaging.SingleEmailMessage>  sendmailLst = new List<Messaging.SingleEmailMessage> ();
        
        Map<String,InfoKiosk_Alert__c> infoKioskMatchedLocMap = new Map<String,InfoKiosk_Alert__c>();
        Map<String,InfoKiosk_Alert__c> infoKioskMatchedProMap = new Map<String,InfoKiosk_Alert__c>();
        
        for(Live_Disruption__c liveDisrup : alertnewlst){
            
            if(liveDisrup.IK_Location_Code__c <> null){//Location_Code__c
                
                if(!fetchLocAlertMap.isEmpty()){
                    for(String locName : fetchLocAlertMap.keyset()){
                        
                        if((locName.contains(liveDisrup.IK_Location_Code__c) || // Location_Code__c
                           locName.contains('All Locations'))){
                            List<InfoKiosk_Alert__c> infoKioskAlertLst = fetchLocAlertMap.get(locName);
                            for(InfoKiosk_Alert__c info : infoKioskAlertLst){
                                if(info.Enter_Internal_Email_Addresses__c <> null || 
                                   info.External_Stakeholder_Email_addresses__c <> null){
                                        infoKioskMatchedLocMap.put(liveDisrup.Id+''+info.Id,info);
                                        //System.debug('-----infoKioskMatchedLocMap-------'+infoKioskMatchedLocMap.keyset());
                                }
                            }
                        }
                    }
                }
                
                if(!fetchprdctAlertMap.isEmpty()){
                    for(String prctName : fetchprdctAlertMap.keyset()){
                        Boolean bolPrdct = false;
                        for(String liveDusrupPrdct : liveDisrup.Product__c.split(';')){
                            if(prctName.contains(liveDusrupPrdct) || liveDusrupPrdct == 'All Products'){
                                bolPrdct = true;
                                break;
                            }
                        }
                        if(bolPrdct == true ||
                           prctName.contains('All Products')){
                            List<InfoKiosk_Alert__c> infoKioskAlertLst = fetchprdctAlertMap.get(prctName);
                            for(InfoKiosk_Alert__c info : infoKioskAlertLst){
                                if(info.Enter_Internal_Email_Addresses__c <> null || 
                                   info.External_Stakeholder_Email_addresses__c <> null){
                                        infoKioskMatchedProMap.put(liveDisrup.Id+''+info.Id,info); 
                                        //System.debug('-----infoKioskMatchedProMap-------'+infoKioskMatchedProMap.keyset());
                                }
                            }
                        }
                    }
                }
            }
        }
        
        Map<String,InfoKiosk_Alert__c> infoKioskFinalMap = new Map<String,InfoKiosk_Alert__c>();
        for(Live_Disruption__c liveDisrup : alertnewlst){
            if(liveDisrup.IK_Location_Code__c <> null){// Location_Code__c
                for(InfoKiosk_Alert__c info : fetchInfoKioskALetMap.values()){
                    if(infoKioskMatchedLocMap.containskey(liveDisrup.Id +''+info.Id) && 
                       infoKioskMatchedProMap.containskey(liveDisrup.Id +''+info.Id)){
                        //System.debug('-----info-------'+info);
                        if(info.Enter_Internal_Email_Addresses__c <> null || 
                           info.External_Stakeholder_Email_addresses__c <> null){
                            
                             infoKioskFinalMap.put(liveDisrup.Id +''+info.Id,info);
                           }
                    }
                }
            }
        }
        
        //System.debug('-----infoKioskFinalMap-----'+infoKioskFinalMap.size());
        for(Live_Disruption__c liveDisrup : alertnewlst){
            if(liveDisrup.IK_Location_Code__c <> null){// Location_Code__c
                for(String infoKey : infoKioskFinalMap.keyset()){
                    if(infoKey.contains(String.valueof(liveDisrup.ID))){
                    	if(infoKioskFinalMap.containskey(infoKey)){
                                   
                                    InfoKiosk_Alert__c info = infoKioskFinalMap.get(infoKey);
                            
                                         List<String> prdctLst = liveDisrup.Product__c.split(';');
                                         String finalPrdctstr = '';
                                         for(String str : prdctLst){
                                             if(str.contains(info.Select_Products__c) || 
                                                info.Select_Products__c.contains(str) ||
                                                info.Select_Products__c.contains('All Products') ||
                                                liveDisrup.Product__c.contains('All Products')){
                                                 finalPrdctstr += str+';';
                                             }
                                         }
                                         //System.debug('-----finalPrdctstr-----'+finalPrdctstr);
                                         if(finalPrdctstr.endsWith(';')){
                                            finalPrdctstr = finalPrdctstr.removeEnd(';');
                                           // System.debug('-----------'+finalPrdctstr);
                                        }
                                        if(info.Enter_Internal_Email_Addresses__c <> null){
                                            Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
                                            List<String> internalEmailAddress = info.Enter_Internal_Email_Addresses__c.split(';');
                                           // System.debug('---------internalEmailAddress------'+internalEmailAddress);
                                            String status = '';
                                            if(liveDisrup.Resolution_Status__c == 'Resolved'){
                                                status = 'Resolved';
                                            }else{
                                                status = 'Created';
                                            }
                                            mail.setSubject(title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+' '+'-'+' '+createDateFormat(liveDisrup.Begin_Date__c)+' '+'('+liveDisrup.Name+')'+' ('+status+')');//Location_Name__c
                                            String messageBody = '<html><body>Dear customer,<br/><br/>' +'<b>'+title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+
                                                '</b>'+'&nbsp;Created.<br/><br/><br/>';
                                            messageBody += createHtmlTemplate(liveDisrup,finalPrdctstr);
                                            messageBody += info.Signature_of_the_emails__c;
                                            mail.setHtmlBody(messageBody);
                                            mail.setToAddresses(internalEmailAddress);
                                            mail.setWhatId(liveDisrup.ID);
                                            mail.setSaveAsActivity(false);
                                            if(mail.getToAddresses() <> null){
                                               // System.debug('$$$$$$$$$e$$$$$$$$$'+mail.getToAddresses());
                                                sendmailLst.add(mail);
                                            }
                                        }
                                        
                                        if(info.External_Stakeholder_Email_addresses__c <> null){
                                            Messaging.SingleEmailMessage  externalmail = new Messaging.SingleEmailMessage ();
                                            List<String> externalEmailAddress = info.External_Stakeholder_Email_addresses__c.split(';');
                                           // System.debug('---------externalEmailAddress------'+externalEmailAddress);
                                            String status = '';
                                            if(liveDisrup.Status__c == 'Resolved'){
                                                status = 'Resolved';
                                            }else{
                                                status = 'Created';
                                            }
                                            externalmail.setSubject(title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+' '+'-'+' '+createDateFormat(liveDisrup.Begin_Date__c)+' '+'('+liveDisrup.Name+')'+' ('+status+')');//Location_Name__c
                                            String messageBodyExt = '<html><body>Dear customer,<br/><br/>' +'<b>'+title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+
                                                '</b>'+'&nbsp;Created.<br/><br/><br/>';
                                            messageBodyExt += createHtmlTemplateExternal(liveDisrup,finalPrdctstr);
                                            messageBodyExt += info.Signature_of_the_emails__c;
                                            externalmail.setHtmlBody(messageBodyExt);
                                            externalmail.setToAddresses(externalEmailAddress);
                                            externalmail.setWhatId(liveDisrup.ID);
                                            externalmail.setSaveAsActivity(false);
                                            if(externalmail.getToAddresses() <> null){
                                               // System.debug('$$$$$$$$$e$$$$$$$$$'+externalmail.getToAddresses());
                                                sendmailLst.add(externalmail);
                                            }
                                        }
                                } 
                        }  
                }
            }
        }
       // System.debug('$$$$$$$$$e$$$$$$$$$'+sendmailLst);
        if(!sendmailLst.isEmpty()){
            
                try{
                    Messaging.sendEmail(sendmailLst); 
                }catch(Exception e){
                           // System.debug('$$$$$$$$$e$$$$$$$$$'+e);
                }
        }
    }
    
    public static void onBeforeupdateLiveDisrupt(List<Live_Disruption__c> alertnewlst,List<Live_Disruption__c> alertoldlst,
                                                Map<ID,Live_Disruption__c> alertnewMap,Map<ID,Live_Disruption__c> alertoldMap){
             for(Live_Disruption__c liveDisrup : alertnewlst){
                 
                    if((alertnewMap.get(liveDisrup.Id).Resolve_Date_Time__c  <> 
                        alertoldMap.get(liveDisrup.Id).Resolve_Date_Time__c )){
                        if(liveDisrup.Resolution_Status__c == 'Resolved'){
                            liveDisrup.Resolve_Date_Time__c = alertnewMap.get(liveDisrup.Id).Resolve_Date_Time__c;
                        }
                    }else{
                        if(liveDisrup.Resolution_Status__c == 'Resolved'){
                            if(liveDisrup.Estimated_End_Date__c <> null){
                                liveDisrup.Resolve_Date_Time__c = liveDisrup.Estimated_End_Date__c;
                            }else{
                                liveDisrup.Resolve_Date_Time__c = system.now();
                            }
                        }
                    }
                 
                    /*if(liveDisrup.Resolution_Status__c =='Resolved'){
                        if(alertnewMap.get(liveDisrup.Id).Resolution_Status__c <> 
                           alertoldMap.get(liveDisrup.Id).Resolution_Status__c)
                        liveDisrup.Resolve_Date_Time__c = System.now();
                       
                    }*/
                 
                    if(liveDisrup.Product__c <> null && liveDisrup.IK_Location_Name__c <> null){//Location_Name__c
                        
                        liveDisrup.Title__c =  title(liveDisrup.Product__c,liveDisrup.IK_Location_Name__c);
                    }      
                    if(liveDisrup.Begin_Date__c > liveDisrup.Estimated_End_Date__c){
                        
                        liveDisrup.addError('Begin Date cannot be greater than Estimated End Date');
                    } 
                    
             }
    }    
    
    public static void onafterupdateLiveDisrupt(List<Live_Disruption__c> alertnewlst,List<Live_Disruption__c> alertoldlst,
                                                Map<ID,Live_Disruption__c> alertnewMap,Map<ID,Live_Disruption__c> alertoldMap){
        
        Map<Id,InfoKiosk_Alert__c> fetchInfoKioskALetMap = fetchALertOnModification();
        
        Map<String,List<InfoKiosk_Alert__c>> fetchprdctAlertMap = new Map<String,List<InfoKiosk_Alert__c>>();
        fetchprdctAlertMap = createprdctAlertMap(fetchInfoKioskALetMap);
        
        Map<String,List<InfoKiosk_Alert__c>> fetchLocAlertMap = new Map<String,List<InfoKiosk_Alert__c>>();
        fetchLocAlertMap = createLocAlertMap(fetchInfoKioskALetMap);                                            
        
        List<Messaging.SingleEmailMessage>  sendmailLst = new List<Messaging.SingleEmailMessage> ();
        Map<String,InfoKiosk_Alert__c> infoKioskMatchedLocMap = new Map<String,InfoKiosk_Alert__c>();
        Map<String,InfoKiosk_Alert__c> infoKioskMatchedProMap = new Map<String,InfoKiosk_Alert__c>();                                            
        
        List<Live_Disruption__c> modifiedLiveDisruptionLst = new  List<Live_Disruption__c>();  
        Map<Id,Live_Disruption__c> modIntEmailMap = new  Map<Id,Live_Disruption__c>(); 
        Map<Id,Live_Disruption__c> modExtEmailMap = new  Map<Id,Live_Disruption__c>();
                                                    
        for(Live_Disruption__c liveDisrup : alertnewlst){
             Boolean sendEmail = false;
             //if(liveDisrup.Sales_Region__c <> null){
                    
                    if((alertnewMap.get(liveDisrup.Id).Status__c <> alertoldMap.get(liveDisrup.Id).Status__c) ||
                       (alertnewMap.get(liveDisrup.Id).Resolution_Status__c <> alertoldMap.get(liveDisrup.Id).Resolution_Status__c) ||
                        //(alertnewMap.get(liveDisrup.Id).Cause__c <> alertoldMap.get(liveDisrup.Id).Cause__c) ||
                        (alertnewMap.get(liveDisrup.Id).Category__c <> alertoldMap.get(liveDisrup.Id).Category__c) ||
                        (alertnewMap.get(liveDisrup.Id).Subcategory__c <> alertoldMap.get(liveDisrup.Id).Subcategory__c) ||
                        //(alertnewMap.get(liveDisrup.Id).Location__c  <> alertoldMap.get(liveDisrup.Id).Location__c )||
                        (alertnewMap.get(liveDisrup.Id).IK_Locations__c  <> alertoldMap.get(liveDisrup.Id).IK_Locations__c )||
                        (alertnewMap.get(liveDisrup.Id).Country__c  <> alertoldMap.get(liveDisrup.Id).Country__c )||
                        //(alertnewMap.get(liveDisrup.Id).option__c  <> alertoldMap.get(liveDisrup.Id).option__c )||
                        (alertnewMap.get(liveDisrup.Id).IK_Option_1__c  <> alertoldMap.get(liveDisrup.Id).IK_Option_1__c )||
                        //(alertnewMap.get(liveDisrup.Id).Option_2__c  <> alertoldMap.get(liveDisrup.Id).Option_2__c )||
                        (alertnewMap.get(liveDisrup.Id).IK_Option_2__c  <> alertoldMap.get(liveDisrup.Id).IK_Option_2__c )||
                        (alertnewMap.get(liveDisrup.Id).Product__c  <> alertoldMap.get(liveDisrup.Id).Product__c )||
                        (alertnewMap.get(liveDisrup.Id).Begin_Date__c  <> alertoldMap.get(liveDisrup.Id).Begin_Date__c )||
                        (alertnewMap.get(liveDisrup.Id).Estimated_End_Date__c  <> alertoldMap.get(liveDisrup.Id).Estimated_End_Date__c )||
                        (alertnewMap.get(liveDisrup.Id).Comment__c  <> alertoldMap.get(liveDisrup.Id).Comment__c )||
                        (alertnewMap.get(liveDisrup.Id).External_Stakeholders_Comment__c  <> alertoldMap.get(liveDisrup.Id).External_Stakeholders_Comment__c )||
                        (alertnewMap.get(liveDisrup.Id).Resolve_Date_Time__c  <> alertoldMap.get(liveDisrup.Id).Resolve_Date_Time__c )
                      ){
                            modifiedLiveDisruptionLst.add(liveDisrup);
                          
                            if((alertnewMap.get(liveDisrup.Id).Status__c <> alertoldMap.get(liveDisrup.Id).Status__c) ||
                            (alertnewMap.get(liveDisrup.Id).Resolution_Status__c <> alertoldMap.get(liveDisrup.Id).Resolution_Status__c) ||
                           // (alertnewMap.get(liveDisrup.Id).Cause__c <> alertoldMap.get(liveDisrup.Id).Cause__c) ||
                            (alertnewMap.get(liveDisrup.Id).Category__c <> alertoldMap.get(liveDisrup.Id).Category__c) ||
                        	(alertnewMap.get(liveDisrup.Id).Subcategory__c <> alertoldMap.get(liveDisrup.Id).Subcategory__c) ||
                            //(alertnewMap.get(liveDisrup.Id).Location__c  <> alertoldMap.get(liveDisrup.Id).Location__c )||
                            (alertnewMap.get(liveDisrup.Id).IK_Locations__c  <> alertoldMap.get(liveDisrup.Id).IK_Locations__c )||
                            (alertnewMap.get(liveDisrup.Id).Country__c  <> alertoldMap.get(liveDisrup.Id).Country__c )||
                            //(alertnewMap.get(liveDisrup.Id).option__c  <> alertoldMap.get(liveDisrup.Id).option__c )||
                            (alertnewMap.get(liveDisrup.Id).IK_Option_1__c  <> alertoldMap.get(liveDisrup.Id).IK_Option_1__c )||
                            //(alertnewMap.get(liveDisrup.Id).Option_2__c  <> alertoldMap.get(liveDisrup.Id).Option_2__c )||
                            (alertnewMap.get(liveDisrup.Id).IK_Option_2__c  <> alertoldMap.get(liveDisrup.Id).IK_Option_2__c )||
                            (alertnewMap.get(liveDisrup.Id).Product__c  <> alertoldMap.get(liveDisrup.Id).Product__c )||
                            (alertnewMap.get(liveDisrup.Id).Begin_Date__c  <> alertoldMap.get(liveDisrup.Id).Begin_Date__c )||
                            (alertnewMap.get(liveDisrup.Id).Estimated_End_Date__c  <> alertoldMap.get(liveDisrup.Id).Estimated_End_Date__c )||
                            (alertnewMap.get(liveDisrup.Id).Resolve_Date_Time__c  <> alertoldMap.get(liveDisrup.Id).Resolve_Date_Time__c )
                            )
                                sendEmail = true;
                          
                                if((alertnewMap.get(liveDisrup.Id).Comment__c  <> 
                                    alertoldMap.get(liveDisrup.Id).Comment__c) ||
                                    sendEmail == true){
                                    modIntEmailMap.put(liveDisrup.Id,liveDisrup);
                                }
                                if((alertnewMap.get(liveDisrup.Id).External_Stakeholders_Comment__c  <> 
                                    alertoldMap.get(liveDisrup.Id).External_Stakeholders_Comment__c) ||
                                    sendEmail == true){
                                    modExtEmailMap.put(liveDisrup.Id,liveDisrup);
                                }
                          
                                if(!fetchLocAlertMap.isEmpty()){
                                    for(String locName : fetchLocAlertMap.keyset()){
                                        
                                        if((locName.contains(liveDisrup.IK_Location_Code__c) ||  //Location_Code__c
                                           locName.contains('All Locations'))){
                                            List<InfoKiosk_Alert__c> infoKioskAlertLst = fetchLocAlertMap.get(locName);
                                            for(InfoKiosk_Alert__c info : infoKioskAlertLst){
                                                if(info.Enter_Internal_Email_Addresses__c <> null || 
                                                   info.External_Stakeholder_Email_addresses__c <> null){
                                                        infoKioskMatchedLocMap.put(liveDisrup.Id+''+info.Id,info);
                                                       // System.debug('-----infoKioskMatchedLocMap-------'+infoKioskMatchedLocMap.keyset());
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                if(!fetchprdctAlertMap.isEmpty()){
                                    for(String prctName : fetchprdctAlertMap.keyset()){
										Boolean bolPrdct = false;
                                        for(String liveDusrupPrdct : liveDisrup.Product__c.split(';')){
                                            if(prctName.contains(liveDusrupPrdct) || liveDusrupPrdct == 'All Products'){
                                                bolPrdct = true;
                                                break;
                                            }
                                        }
                                        if(bolPrdct == true || prctName.contains('All Products')){
                                            List<InfoKiosk_Alert__c> infoKioskAlertLst = fetchprdctAlertMap.get(prctName);
                                            for(InfoKiosk_Alert__c info : infoKioskAlertLst){
                                                if(info.Enter_Internal_Email_Addresses__c <> null || 
                                                   info.External_Stakeholder_Email_addresses__c <> null){
                                                        infoKioskMatchedProMap.put(liveDisrup.Id+''+info.Id,info); 
                                                       // System.debug('-----infoKioskMatchedProMap-------'+infoKioskMatchedProMap.keyset());
                                                }
                                            }
                                        }
                                    }
                                }
                        
                        //}
             }
       }          
       
       Map<String,InfoKiosk_Alert__c> infoKioskFinalMap = new Map<String,InfoKiosk_Alert__c>();
       for(Live_Disruption__c liveDisrup : alertnewlst){
            if(liveDisrup.IK_Location_Code__c <> null){ // Location_Code__c
                for(InfoKiosk_Alert__c info : fetchInfoKioskALetMap.values()){
                    if(infoKioskMatchedLocMap.containskey(liveDisrup.Id +''+info.Id) && 
                       infoKioskMatchedProMap.containskey(liveDisrup.Id +''+info.Id)){
                        //System.debug('-----info-------'+info);
                        if(info.Enter_Internal_Email_Addresses__c <> null || 
                           info.External_Stakeholder_Email_addresses__c <> null)
                            
                             infoKioskFinalMap.put(liveDisrup.Id +''+info.Id,info);
                    }
                }
            }
       }
       
       for(Live_Disruption__c liveDisrup : modifiedLiveDisruptionLst){
            if(liveDisrup.IK_Location_Code__c <> null){// Location_Code__c
                
                for(String infoKey : infoKioskFinalMap.keyset()){
                    if(infoKey.contains(String.valueof(liveDisrup.ID))){
                    	if(infoKioskFinalMap.containskey(infoKey)){
                           
                            InfoKiosk_Alert__c info = infoKioskFinalMap.get(infoKey);
                            List<String> prdctLst = new List<String> (); 
                            List<String> oldprdctLst = new List<String> (); 
                            String modifedStr ='';
                            String finalPrdctstr = '';
                            prdctLst = liveDisrup.Product__c.split(';');
                            oldprdctLst = alertoldMap.get(liveDisrup.Id).Product__c.split(';');
                            String newVal = liveDisrup.Product__c+';';
                            //System.debug('------newVal-----'+newVal);
                            String oldVal = alertoldMap.get(liveDisrup.Id).Product__c+';';
                           // System.debug('------oldVal-----'+oldVal);
                            String remainingStr = '';
                            if(prdctLst.size() <= oldprdctLst.size()){
        
                                for(String str : oldprdctLst){
                                    
                                     //System.debug('------str-----'+str+';');
                                     if(!newVal.contains(str+';'))
                                     remainingStr += str+';';
                                }
                                //System.debug('-------remainingStr--------'+remainingStr);
                            }
                            if(prdctLst.size() > oldprdctLst.size()){
                                for(String str : prdctLst){
                                     //System.debug('------oldVal-----'+oldVal);
                                     //System.debug('------str-----'+str+';');
                                     if(!oldVal.contains(str+';'))
                                     remainingStr += str+';';
                                }
                                //System.debug('-------remainingStr--------'+remainingStr);
                            }
        
                            List<String> alertPrctLst = info.Select_Products__c.split(';');
                            
                            if(liveDisrup.Product__c <> alertoldMap.get(liveDisrup.Id).Product__c){
                               // System.debug('-------');
                                String selectedAlertPrct = '';
                                String selectedStr = '';
                                for(String str : prdctLst){
                                         if(remainingStr != ''){
                                            for(String remain : remainingStr.split(';')){
                                                 if(info.Select_Products__c.contains(str) &&
                                                    info.Select_Products__c.contains(remain)){
                                                    //System.debug('-------remain--------'+remain);
                                                    selectedAlertPrct += str+';';
                                                    //System.debug('-------selectedAlertPrct--------'+selectedAlertPrct);
                                                 }
                                            }
                                         }
                                         if((!alertoldMap.get(liveDisrup.Id).Product__c.contains(str)) &&
                                            (info.Select_Products__c.contains(str))){
                                                selectedStr += str+';';
                                                selectedAlertPrct = selectedAlertPrct.remove(str+';');
                                             //System.debug('------selectedStr-----'+selectedStr);
                                         }
                                         else if(info.Select_Products__c.contains('All Products')){
                                             finalPrdctstr += str+';';
                                             //System.debug('------selectedStr 2-----'+selectedStr);
                                         }
                                }
                                List<String> selectedAlertStrSize = selectedAlertPrct.split(';');
                                if(selectedStr != '' && finalPrdctstr == ''){
                                    finalPrdctstr = selectedAlertPrct + selectedStr;
                                    //System.debug('------finalPrdctstr-----'+finalPrdctstr);
                                }else if(selectedAlertStrSize.size() > 0 &&
                                         selectedAlertStrSize.size() <= oldprdctLst.size() &&
                                         finalPrdctstr == ''){
                                    finalPrdctstr = selectedAlertPrct;
                                    //System.debug('------finalPrdctstr-----'+finalPrdctstr);
                                }
                                
                                //System.debug('-----------'+finalPrdctstr);
                                 if(finalPrdctstr.endsWith(';')){
                                    finalPrdctstr = finalPrdctstr.removeEnd(';');
                                    
                                 }
                                if(prdctLst.contains('All Products')){
                                    finalPrdctstr = 'All Products';
                                }
                                 //System.debug('-----finalPrdctstr------'+finalPrdctstr);
                            }else{
                                 //System.debug('-----prdctLst------'+prdctLst);
                                 for(String str : prdctLst){
                                     if(str.contains(info.Select_Products__c) || 
                                        info.Select_Products__c.contains('All Products') ||
                                        info.Select_Products__c.contains(str) ||
                                        liveDisrup.Product__c.contains('All Products')){
                                         finalPrdctstr += str+';';
                                     }
                                 }
                                 if(finalPrdctstr.endsWith(';')){
                                    finalPrdctstr = finalPrdctstr.removeEnd(';');
                                    //System.debug('-----------'+finalPrdctstr);
                                 }
                                 //System.debug('-----finalPrdctstr------'+finalPrdctstr);
                            }
                            
                            if(modIntEmailMap.containskey(liveDisrup.Id)){
                                    //System.debug('----finalPrdctstr----'+finalPrdctstr);
                                    //System.debug('----info----'+info);
                                    if(info.Enter_Internal_Email_Addresses__c <> null && finalPrdctstr <> ''){
                                        System.debug('--------'+info.Id);
                                         Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
                                        List<String> internalEmailAddress = info.Enter_Internal_Email_Addresses__c.split(';');
                                        String status = '';
                                        System.debug('-------------'+liveDisrup.Resolution_Status__c);
                                        if(liveDisrup.Resolution_Status__c == 'Resolved'){
                                            status = 'Resolved';
                                        }else{
                                            status = 'Modified';
                                        }
                                        mail.setSubject(title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+' '+'-'+' '+createDateFormat(liveDisrup.Begin_Date__c)+' '+'('+liveDisrup.Name+')'+  '('+status+')');// Location_Name__c
                                        String messageBody = '<html><body>Dear customer,<br/><br/>' +'<b>'+title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+
                                            '</b>'+'&nbsp;has been changed.<br/><br/><br/>';
                                        messageBody += createHtmlTemplateOnUpdate(liveDisrup,alertoldMap.get(liveDisrup.Id),
                                                                                  finalPrdctstr);
                                        messageBody += info.Signature_of_the_emails__c;
                                        mail.setHtmlBody(messageBody);
                                        mail.setToAddresses(internalEmailAddress);
                                        mail.setWhatId(liveDisrup.ID);
                                        mail.setSaveAsActivity(false);
                                        if(mail.getToAddresses() <> null){
                                            sendmailLst.add(mail);
                                        }
                                    }
                            }
                            
                            if(modExtEmailMap.containskey(liveDisrup.Id) && finalPrdctstr <> ''){
                                    if(info.External_Stakeholder_Email_addresses__c <> null){
                                        //System.debug('----------------'+info);
                                        Messaging.SingleEmailMessage  externalmail = new Messaging.SingleEmailMessage ();
                                        List<String> externalEmailAddress = info.External_Stakeholder_Email_addresses__c.split(';');
                                        String liveDisruptionName = '('+liveDisrup.Name+')';
                                        String status = '';
                                        if(liveDisrup.Resolution_Status__c == 'Resolved'){
                                            status = 'Resolved';
                                        }else{
                                            status = 'Modified';
                                        }
                                        externalmail.setSubject(title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+' '+'-'+' '+createDateFormat(liveDisrup.Begin_Date__c)+' '+'('+liveDisrup.Name+')'+ ' ('+status+')');// Location_Name__c
                                        String messageBodyExt = '<html><body>Dear customer,<br/><br/>' +'<b>'+title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+
                                            '</b>'+'&nbsp;has been changed.<br/><br/><br/>';
                                        messageBodyExt += createHtmlTemplateOnUpdateExt(liveDisrup,alertoldMap.get(liveDisrup.Id),
                                                                                        finalPrdctstr);
                                        messageBodyExt += info.Signature_of_the_emails__c;
                                        externalmail.setHtmlBody(messageBodyExt);
                                        externalmail.setToAddresses(externalEmailAddress);
                                        externalmail.setWhatId(liveDisrup.ID);
                                        externalmail.setSaveAsActivity(false);
                                        if(externalmail.getToAddresses() <> null){
                                            sendmailLst.add(externalmail);
                                        }
                                    }
                            }
                            
                        }
                	}
            	}
            }
       }
             System.debug('$$$$$$$$$sendmailLst$$$$$$$$$'+sendmailLst);                                       
       if(!sendmailLst.isEmpty()){
                try{
                    Messaging.sendEmail(sendmailLst); 
                }catch(Exception e){
                    // System.debug('$$$$$$$$$mail$$$$$$$$$'+mail);
                }
       }
    }
    
    
    public static void onafterdeleteLiveDisrupt(List<Live_Disruption__c> alertnewlst){
        
        Map<Id,InfoKiosk_Alert__c> fetchInfoKioskALetMap = fetchALertOnDeletion();
        
        Map<String,List<InfoKiosk_Alert__c>> fetchprdctAlertMap = new Map<String,List<InfoKiosk_Alert__c>>();
        fetchprdctAlertMap = createprdctAlertMap(fetchInfoKioskALetMap);
        
        Map<String,List<InfoKiosk_Alert__c>> fetchLocAlertMap = new Map<String,List<InfoKiosk_Alert__c>>();
        fetchLocAlertMap = createLocAlertMap(fetchInfoKioskALetMap);
        
        List<Messaging.SingleEmailMessage>  sendmailLst = new List<Messaging.SingleEmailMessage> ();
        Map<String,InfoKiosk_Alert__c> infoKioskMatchedLocMap = new Map<String,InfoKiosk_Alert__c>();
        Map<String,InfoKiosk_Alert__c> infoKioskMatchedProMap = new Map<String,InfoKiosk_Alert__c>();
        
         for(Live_Disruption__c liveDisrup : alertnewlst){
            
            if(liveDisrup.IK_Location_Code__c <> null){// Location_Code__c
                
                if(!fetchLocAlertMap.isEmpty()){
                    for(String locName : fetchLocAlertMap.keyset()){
                        
                        if((locName.contains(liveDisrup.IK_Location_Code__c) ||//Location_Code__c
                           locName.contains('All Locations'))){
                            List<InfoKiosk_Alert__c> infoKioskAlertLst = fetchLocAlertMap.get(locName);
                            for(InfoKiosk_Alert__c info : infoKioskAlertLst){
                                if(info.Enter_Internal_Email_Addresses__c <> null || 
                                   info.External_Stakeholder_Email_addresses__c <> null){
                                        infoKioskMatchedLocMap.put(liveDisrup.Id+''+info.Id,info);
                                        //System.debug('-----infoKioskMatchedLocMap-------'+infoKioskMatchedLocMap.keyset());
                                }
                            }
                        }
                    }
                }
                
                if(!fetchprdctAlertMap.isEmpty()){
                    for(String prctName : fetchprdctAlertMap.keyset()){
                        Boolean bolPrdct = false;
                        for(String liveDusrupPrdct : liveDisrup.Product__c.split(';')){
                            if(prctName.contains(liveDusrupPrdct) || liveDusrupPrdct == 'All Products'){
                                bolPrdct = true;
                                break;
                            }
                        }
                        if(bolPrdct == true ||
                           prctName.contains('All Products')){
                            List<InfoKiosk_Alert__c> infoKioskAlertLst = fetchprdctAlertMap.get(prctName);
                            for(InfoKiosk_Alert__c info : infoKioskAlertLst){
                                if(info.Enter_Internal_Email_Addresses__c <> null || 
                                   info.External_Stakeholder_Email_addresses__c <> null){
                                        infoKioskMatchedProMap.put(liveDisrup.Id+''+info.Id,info); 
                                        //System.debug('-----infoKioskMatchedProMap-------'+infoKioskMatchedProMap.keyset());
                                }
                            }
                        }
                    }
                }
            }
        }
        
        Map<String,InfoKiosk_Alert__c> infoKioskFinalMap = new Map<String,InfoKiosk_Alert__c>();
        for(Live_Disruption__c liveDisrup : alertnewlst){
            if(liveDisrup.IK_Location_Code__c <> null){// Location_Code__c
                for(InfoKiosk_Alert__c info : fetchInfoKioskALetMap.values()){
                    if(infoKioskMatchedLocMap.containskey(liveDisrup.Id +''+info.Id) && 
                       infoKioskMatchedProMap.containskey(liveDisrup.Id +''+info.Id)){
                        //System.debug('-----info-------'+info);
                        if(info.Enter_Internal_Email_Addresses__c <> null || 
                           info.External_Stakeholder_Email_addresses__c <> null)
                             infoKioskFinalMap.put(liveDisrup.Id +''+info.Id,info);
                    }
                }
            }
        }
        
        //System.debug('-----infoKioskFinalMap-----'+infoKioskFinalMap.size());
        for(Live_Disruption__c liveDisrup : alertnewlst){
            if(liveDisrup.IK_Location_Code__c <> null){//Location_Code__c
                for(String infoKey : infoKioskFinalMap.keyset()){
                    if(infoKey.contains(String.valueof(liveDisrup.ID))){
                    	if(infoKioskFinalMap.containskey(infoKey)){
                            InfoKiosk_Alert__c info = infoKioskFinalMap.get(infoKey);
                            List<String> prdctLst = liveDisrup.Product__c.split(';');
                            String finalPrdctstr = '';
                            
                            for(String str : prdctLst){
                                 if(str.contains(info.Select_Products__c) ||
                                    info.Select_Products__c.contains(str) ||
                                    info.Select_Products__c.contains('All Products') ||
                                    liveDisrup.Product__c.contains('All Products')){
                                     finalPrdctstr += str+';';
                                 }
                            }
                            
                            if(finalPrdctstr.endsWith(';')){
                                finalPrdctstr = finalPrdctstr.removeEnd(';');
                                //System.debug('-----------'+finalPrdctstr);
                            }
                            
                            if(info.Enter_Internal_Email_Addresses__c <> null){
                                Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
                                List<String> internalEmailAddress = info.Enter_Internal_Email_Addresses__c.split(';');
                                String status = '';
                                if(liveDisrup.Resolution_Status__c == 'Resolved'){
                                     status = 'Resolved';
                                }else{
                                     status = 'Deleted';
                                }
                                mail.setSubject(title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+' '+'-'+' '+createDateFormat(liveDisrup.Begin_Date__c)+' '+'('+liveDisrup.Name+')'+' ('+status+')');//Location_Name__c
                                String messageBody = '<html><body>Dear customer,<br/><br/>' +'<b>'+title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+
                                                     '</b>'+'&nbsp;has been Deleted.<br/><br/><br/>';
                                messageBody += createHtmlTemplate(liveDisrup,finalPrdctstr);
                                messageBody += info.Signature_of_the_emails__c;
                                mail.setHtmlBody(messageBody);
                                mail.setToAddresses(internalEmailAddress);
                                mail.setWhatId(liveDisrup.ID);
                                mail.setSaveAsActivity(false);
                                if(mail.getToAddresses() <> null){
                                    sendmailLst.add(mail);
                                }
                            }
                            
                            if(info.External_Stakeholder_Email_addresses__c <> null){
                                Messaging.SingleEmailMessage  externalmail = new Messaging.SingleEmailMessage ();
                                List<String> externalEmailAddress = info.External_Stakeholder_Email_addresses__c.split(';');
                                String status = '';
                                if(liveDisrup.Resolution_Status__c == 'Resolved'){
                                     status = 'Resolved';
                                }else{
                                     status = 'Deleted';
                                }
                                externalmail.setSubject(title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+' '+'-'+' '+createDateFormat(liveDisrup.Begin_Date__c)+' '+'('+liveDisrup.Name+')'+' ('+status+')');//Location_Name__c
                                String messageBodyExt = '<html><body>Dear customer,<br/><br/>' +'<b>'+title(finalPrdctstr,liveDisrup.IK_Location_Name__c)+
                                                        '</b>'+'&nbsp;has been Deleted.<br/><br/><br/>';
                                messageBodyExt += createHtmlTemplateExternal(liveDisrup,finalPrdctstr);
                                messageBodyExt += info.Signature_of_the_emails__c;
                                externalmail.setHtmlBody(messageBodyExt);
                                externalmail.setToAddresses(externalEmailAddress);
                                externalmail.setWhatId(liveDisrup.ID);
                                externalmail.setSaveAsActivity(false);
                                if(externalmail.getToAddresses() <> null){
                                    sendmailLst.add(externalmail);
                                }
                            }
                   		}   
                  	}   
                }
            }
        }
        
        
         if(!sendmailLst.isEmpty()){
              try{
                 Messaging.sendEmail(sendmailLst); 
              }catch(Exception e){
                  // System.debug('$$$$$$$$$mail$$$$$$$$$'+mail);
              }
         }
    }
    
    public static Map<Id,InfoKiosk_Alert__c> fetchALertOnCreation(){
        return new Map<Id,InfoKiosk_Alert__c>([select id,All_Changes__c,New_items_are_added__c,Existing_items_are_modified__c,Items_are_deleted__c,
               Anything_changes__c,Someone_changes_item_last_modified_by_me__c,Someone_changes_an_item_created_by_me__c,
               User_Selection__c,Select_Location__c,Select_Products__c,Location_Code__c,Enter_Internal_Email_Addresses__c,
               External_Stakeholder_Email_addresses__c,Signature_of_the_emails__c                                
               from InfoKiosk_Alert__c where All_Changes__c =: true OR New_items_are_added__c =: true]);
    }
    
    public static Map<Id,InfoKiosk_Alert__c> fetchALertOnModification(){
        return new Map<Id,InfoKiosk_Alert__c>([select id,All_Changes__c,New_items_are_added__c,Existing_items_are_modified__c,Items_are_deleted__c,
               Anything_changes__c,Someone_changes_item_last_modified_by_me__c,Someone_changes_an_item_created_by_me__c,
               User_Selection__c,Select_Location__c,Select_Products__c,Location_Code__c,Enter_Internal_Email_Addresses__c,
               External_Stakeholder_Email_addresses__c,Signature_of_the_emails__c                                 
               from InfoKiosk_Alert__c where All_Changes__c =: true OR  Existing_items_are_modified__c =: true]);
    }
    
    public static Map<Id,InfoKiosk_Alert__c> fetchALertOnDeletion(){
        return new Map<Id,InfoKiosk_Alert__c>([select id,All_Changes__c,New_items_are_added__c,Existing_items_are_modified__c,Items_are_deleted__c,
               Anything_changes__c,Someone_changes_item_last_modified_by_me__c,Someone_changes_an_item_created_by_me__c,
               User_Selection__c,Select_Location__c,Select_Products__c,Location_Code__c,Enter_Internal_Email_Addresses__c,
               External_Stakeholder_Email_addresses__c,Signature_of_the_emails__c                                
               from InfoKiosk_Alert__c where All_Changes__c =: true OR  Items_are_deleted__c =: true]);
    }
    
    public static Map<String,List<InfoKiosk_Alert__c>> createprdctAlertMap(Map<Id,InfoKiosk_Alert__c>
                                                                           fetchInfoKioskALetMap){
                  Map<String,List<InfoKiosk_Alert__c>> createMap = new  Map<String,List<InfoKiosk_Alert__c>>();
                  for(InfoKiosk_Alert__c infoKiosk : fetchInfoKioskALetMap.values()){
                      if(infoKiosk.Select_Products__c == null){
                          infoKiosk.Select_Products__c = 'All Products';
                      }  
                      if(!createMap.containsKey(infoKiosk.Select_Products__c)){
                          createMap.put(infoKiosk.Select_Products__c,new List<InfoKiosk_Alert__c>{infoKiosk});
                      }else{
                          List<InfoKiosk_Alert__c> fetchAlertLst = createMap.get(infoKiosk.Select_Products__c);
                          fetchAlertLst.add(infoKiosk);
                          createMap.put(infoKiosk.Select_Products__c,fetchAlertLst);
                      }
                  } 
                  return  createMap;                                                           
    }
    
    public static Map<String,List<InfoKiosk_Alert__c>> createLocAlertMap(Map<Id,InfoKiosk_Alert__c>
                                                                           fetchInfoKioskALetMap){
                  Map<String,List<InfoKiosk_Alert__c>> createMap = new  Map<String,List<InfoKiosk_Alert__c>>();
                  for(InfoKiosk_Alert__c infoKiosk : fetchInfoKioskALetMap.values()){
                      if(infoKiosk.Location_Code__c == null){
                          infoKiosk.Location_Code__c = 'All Locations';
                      }  
                      if(!createMap.containsKey(infoKiosk.Location_Code__c)){
                          createMap.put(infoKiosk.Location_Code__c,new List<InfoKiosk_Alert__c>{infoKiosk});
                      }else{
                          List<InfoKiosk_Alert__c> fetchAlertLst = createMap.get(infoKiosk.Location_Code__c);
                          fetchAlertLst.add(infoKiosk);
                          createMap.put(infoKiosk.Location_Code__c,fetchAlertLst);
                      }
                  } 
                  return  createMap;                                                           
    }
   
    public static String title(String productName,String Location){
        
        String title ='';
        List<String> splitProductName = productName.split(';');
        Integer increment = 1;
        
        if(splitProductName.size() > 1){
            for(String str : splitProductName){
                if(increment < splitProductName.size()){
                    title +=str+'/';
                    increment++;
                }else{
                    title +=str;
                }
            }
        }else{
            title =productName;
        }
        title+=' - '+Location;
        return title;
    }
    
    public static String createHtmlTemplate(Live_Disruption__c liveDisrup,String prdctStr){

        String beginDate = createDateTimeFormat(liveDisrup.Begin_Date__c);
        
        String estimatedEndDate = '';
        if(liveDisrup.Estimated_End_Date__c == null){
            estimatedEndDate = '';
        }else{
            estimatedEndDate = createDateTimeFormat(liveDisrup.Estimated_End_Date__c);
        }
        
        String createdDate = createDateTimeFormat(liveDisrup.CreatedDate);
        
        String lastModifiedDate = createDateTimeFormat(liveDisrup.LastModifiedDate);
        if(String.isBlank(liveDisrup.Title__c )){
            liveDisrup.Title__c = '';
        }
        
        String resolutionStatus = '';
        if(String.isBlank(liveDisrup.Resolution_Status__c )){
                resolutionStatus = '';
        }else{
            resolutionStatus = liveDisrup.Resolution_Status__c;
        }

        String comment = '';
        if(String.isBlank(liveDisrup.Comment__c )){
            comment = '';
        }else{
            comment = liveDisrup.Comment__c ;
        }
        
        String option = '';
        if(liveDisrup.IK_Option_1_Location_Name__c == null){// Option_Location_Name__c
                option = '';
        }else{
                option = liveDisrup.IK_Option_1_Location_Name__c;
        }
        
        String option2 = '';
        if(liveDisrup.IK_Option_2_Location_Name__c == null){// Option_2_Location_Name__c
                option2 = '';
        }else{
                option2 = liveDisrup.IK_Option_2_Location_Name__c;
        }
        
        String strProd = '';
		List<String> prdctLst = prdctStr.split(';');
        for(String str : prdctLst){
            strProd += str+'\n'+'<br/>';
        }
        String htmlTemplate = '<table><tr><td>'+'Product:&nbsp;&nbsp;&nbsp;</td><td>'+strProd +
                                '</td></tr><tr><td>'+'Location:&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.IK_Location_Name__c +// Location_Name__c
                                //'</td></tr><tr><td>'+'Region:&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Sales_Region__c +
                                '</td></tr><tr><td>'+'Status:&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Status__c +
                                '</td></tr><tr><td>'+'Resolution Status:&nbsp;&nbsp;&nbsp;</td><td>'+resolutionStatus +
                                //'</td></tr><tr><td>'+'Disruption :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Cause__c +
            					'</td></tr><tr><td>'+'Category :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Category__c +
            					'</td></tr><tr><td>'+'Subcategory :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Subcategory__c +
                                '</td></tr><tr><td>'+'Disruption Start:&nbsp;&nbsp;&nbsp;</td><td>'+beginDate +
                                '</td></tr><tr><td>'+'Estimated Disruption End:&nbsp;&nbsp;&nbsp;</td><td>'+estimatedEndDate +
                                '</td></tr><tr><td>'+'Option 1:&nbsp;&nbsp;&nbsp;</td><td>'+option +
                                '</td></tr><tr><td>'+'Option 2:&nbsp;&nbsp;&nbsp;</td><td>'+option2 +
                                '</td></tr><tr><td>'+'Comment :&nbsp;&nbsp;&nbsp;</td><td>'+comment+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                               // '</td></tr><tr><td>'+'Link to Real Time List :&nbsp;&nbsp;&nbsp;</td><td>'+Label.Salesforce_URL+'/'+liveDisrup.Id+
                               // '</td></tr><tr><td>'+'Expiration Date:&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Resolve_Date_Time__c+
                               // '</td></tr><tr><td>'+'Created Date :&nbsp;&nbsp;&nbsp;</td><td>'+CreatedDate+
                               // '</td></tr><tr><td>'+'Created By :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.CreatedBy__c+
                               // '</td></tr><tr><td>'+'Last Modified Date :&nbsp;&nbsp;&nbsp;</td><td>'+LastModifiedDate+
                               // '</td></tr><tr><td>'+'Last Modified By :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Last_ModfiedBy__c+
                                '</td></tr></table></body>  </html>';
        return htmlTemplate;
        
    }
    
    public static String createHtmlTemplateExternal(Live_Disruption__c liveDisrup,String prdctStr){
        String beginDate = createDateTimeFormat(liveDisrup.Begin_Date__c);
        String estimatedEndDate = '';
        if(liveDisrup.Estimated_End_Date__c == null){
            estimatedEndDate = '';
        }else{
            estimatedEndDate = createDateTimeFormat(liveDisrup.Estimated_End_Date__c);
        }
        String createdDate = createDateTimeFormat(liveDisrup.CreatedDate);
        String lastModifiedDate = createDateTimeFormat(liveDisrup.LastModifiedDate);
        if(String.isBlank(liveDisrup.Title__c )){
            liveDisrup.Title__c = '';
        }
        
        String resolutionStatus = '';
        if(String.isBlank(liveDisrup.Resolution_Status__c )){
                resolutionStatus = '';
        }else{
            resolutionStatus = liveDisrup.Resolution_Status__c;
        }

        String comment = '';
        if(String.isBlank(liveDisrup.External_Stakeholders_Comment__c )){
            comment = '';
        }else{
            comment = liveDisrup.External_Stakeholders_Comment__c ;
        }
        
        String option = '';
        if(liveDisrup.IK_Option_1_Location_Name__c == null){// Option_Location_Name__c
                option = '';
        }else{
                option = liveDisrup.IK_Option_1_Location_Name__c;
        }
        
        String option2 = '';
        if(liveDisrup.IK_Option_2_Location_Name__c == null){ //Option_2_Location_Name__c
                option2 = '';
        }else{
                option2 = liveDisrup.IK_Option_2_Location_Name__c;
        }
        String strProd = '';
        List<String> strPrdLst = prdctStr.split(';');
        for(String str : strPrdLst){
            strProd += str+'\n'+'<br/>';
        }
        String htmlTemplate = '<table><tr><td>'+'Product:&nbsp;&nbsp;&nbsp;</td><td>'+strProd+
                                '</td></tr><tr><td>'+'Location:&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.IK_Location_Name__c + //Location_Name__c
                                //'</td></tr><tr><td>'+'Region:&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Sales_Region__c +
                                '</td></tr><tr><td>'+'Status:&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Status__c +
                                '</td></tr><tr><td>'+'Resolution Status:&nbsp;&nbsp;&nbsp;</td><td>'+resolutionStatus +
                                //'</td></tr><tr><td>'+'Disruption :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Cause__c +
            					'</td></tr><tr><td>'+'Category :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Category__c +
            					//'</td></tr><tr><td>'+'Subcategory :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Subcategory__c +
                                '</td></tr><tr><td>'+'Disruption Start:&nbsp;&nbsp;&nbsp;</td><td>'+beginDate +
                                '</td></tr><tr><td>'+'Estimated Disruption End:&nbsp;&nbsp;&nbsp;</td><td>'+estimatedEndDate +
                                //'</td></tr><tr><td>'+'Option 1:&nbsp;&nbsp;&nbsp;</td><td>'+option +
                                //'</td></tr><tr><td>'+'Option 2:&nbsp;&nbsp;&nbsp;</td><td>'+option2 +
                                '</td></tr><tr><td>'+'Comment :&nbsp;&nbsp;&nbsp;</td><td>'+comment+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                //'</td></tr><tr><td>'+'Link to Real Time List :&nbsp;&nbsp;&nbsp;</td><td>'+Label.Salesforce_URL+'/'+liveDisrup.Id+
                               // '</td></tr><tr><td>'+'Created Date :&nbsp;&nbsp;&nbsp;</td><td>'+CreatedDate+
                               // '</td></tr><tr><td>'+'Created By :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.CreatedBy__c+
                               // '</td></tr><tr><td>'+'Last Modified Date :&nbsp;&nbsp;&nbsp;</td><td>'+LastModifiedDate+
                               // '</td></tr><tr><td>'+'Last Modified By :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Last_ModfiedBy__c+
                                '</td></tr></table></body>  </html>';
        return htmlTemplate;
        
    }
    
    public static String createHtmlTemplateOnUpdate(Live_Disruption__c liveDisrup,Live_Disruption__c oldVal,
                                                    String prdctStr){

        String beginDate = '';
        if(liveDisrup.Begin_Date__c <> oldVal.Begin_Date__c){
            if(liveDisrup.Begin_Date__c == null){
                beginDate = '<strike>'+createDateTimeFormat(oldVal.Begin_Date__c)+'</strike>';
            }else{
                beginDate = '<strike>'+createDateTimeFormat(oldVal.Begin_Date__c)+'</strike>'+' '+createDateTimeFormat(liveDisrup.Begin_Date__c);
            }
        }else{
            if(liveDisrup.Begin_Date__c == null){
                beginDate = '';
            }else{
                beginDate = String.valueOf(createDateTimeFormat(liveDisrup.Begin_Date__c));
            }
        }
                                                        
        String estimatedEndDate = '';
        if(liveDisrup.Estimated_End_Date__c <> oldVal.Estimated_End_Date__c){
            if(liveDisrup.Estimated_End_Date__c == null){
                estimatedEndDate = '<strike>'+createDateTimeFormat(oldVal.Estimated_End_Date__c)+'</strike>';
            }else{
                estimatedEndDate = '<strike>'+createDateTimeFormat(oldVal.Estimated_End_Date__c)+'</strike>'+' '+createDateTimeFormat(liveDisrup.Estimated_End_Date__c);
            }
        }else{
            if(liveDisrup.Estimated_End_Date__c == null){
                estimatedEndDate = '';  
            }else{
                estimatedEndDate = String.valueof(createDateTimeFormat(liveDisrup.Estimated_End_Date__c));
            }
        }
        
        String resolveDateTime = '';
        if(liveDisrup.Resolve_Date_Time__c <> oldVal.Resolve_Date_Time__c){
            if(liveDisrup.Resolve_Date_Time__c == null){
                resolveDateTime = '<strike>'+createDateTimeFormat(oldVal.Resolve_Date_Time__c)+'</strike>';
            }else{
                resolveDateTime = '<strike>'+createDateTimeFormat(oldVal.Resolve_Date_Time__c)+'</strike>'+' '+createDateTimeFormat(liveDisrup.Resolve_Date_Time__c);
            }
        }else{
            if(liveDisrup.Resolve_Date_Time__c == null){
                resolveDateTime = '';   
            }else{
                resolveDateTime = String.valueof(createDateTimeFormat(liveDisrup.Resolve_Date_Time__c));
            }
        }
        
        String createdDate = createDateTimeFormat(liveDisrup.CreatedDate);
        
        String lastModifiedDate = createDateTimeFormat(liveDisrup.LastModifiedDate);
        
        if(String.isBlank(liveDisrup.Title__c )){
            liveDisrup.Title__c = '';
        }
        
        String resolutionStatus = '';
        if(liveDisrup.Resolution_Status__c <> oldVal.Resolution_Status__c){
            if(liveDisrup.Resolution_Status__c == null){
                        resolutionStatus = '<strike>'+oldVal.Resolution_Status__c+'</strike>';
            }else if(liveDisrup.Resolution_Status__c == 'Resolved'){
                        resolutionStatus = '<strike>'+oldVal.Resolution_Status__c+'</strike>'+' '+'!!!'+'<b>'+liveDisrup.Resolution_Status__c.touppercase()+'</b>'+'!!!';
            }else{
                        resolutionStatus = '<strike>'+oldVal.Resolution_Status__c+'</strike>'+' '+liveDisrup.Resolution_Status__c;
             }
        }else{
            if(liveDisrup.Resolution_Status__c == null){
                resolutionStatus = '';
            }else{
                resolutionStatus = liveDisrup.Resolution_Status__c;
            }
        }

        String comment = '';
        if(liveDisrup.Comment__c <> oldVal.Comment__c){
            
            if(String.isBlank(liveDisrup.Comment__c )){
                comment = '<strike>'+oldVal.Comment__c+'</strike>';
            }else{
                comment = '<strike>'+oldVal.Comment__c+'</strike>'+' '+liveDisrup.Comment__c ;
            }
        }else{
            if(liveDisrup.Comment__c == null){
                comment = '';
            }else{
                comment = liveDisrup.Comment__c ;
            }
        }
        
        String option = '';
        if(liveDisrup.IK_Option_1_Location_Name__c <> oldVal.IK_Option_1_Location_Name__c){// Option_Location_Name__c
            if(liveDisrup.IK_Option_1_Location_Name__c == null){
                    option = '<strike>'+oldVal.IK_Option_1_Location_Name__c+'</strike>';
            }else{
                    option = '<strike>'+oldVal.IK_Option_1_Location_Name__c+'</strike>'+' '+liveDisrup.IK_Option_1_Location_Name__c;
            }
        }else{
            if(liveDisrup.IK_Option_1_Location_Name__c == null){
                option = '';
            }else{
                option = liveDisrup.IK_Option_1_Location_Name__c;
            }
        }
        
        String option2 = '';
        if(liveDisrup.IK_Option_2_Location_Name__c <> oldVal.IK_Option_2_Location_Name__c){// Option_2_Location_Name__c
            if(liveDisrup.IK_Option_2_Location_Name__c == null){
                    option2 = '<strike>'+oldVal.IK_Option_2_Location_Name__c+'</strike>';
            }else{
                    option2 = '<strike>'+oldVal.IK_Option_2_Location_Name__c+'</strike>'+' '+liveDisrup.IK_Option_2_Location_Name__c;
            }
        }else{
            if(liveDisrup.IK_Option_2_Location_Name__c == null){
                option2 = '';
            }else{
                option2 = liveDisrup.IK_Option_2_Location_Name__c;
            }
        }
        
        String productName = '';
        if(liveDisrup.Product__c <> oldVal.Product__c){
                 productName = '<strike>'+oldVal.Product__c+'</strike>'+' '+liveDisrup.Product__c;
        }else{
                 productName = liveDisrup.Product__c;
        }
        
        String locationName = '';
        if(liveDisrup.IK_Location_Name__c <> oldVal.IK_Location_Name__c){//Location_Name__c
                 locationName = '<strike>'+oldVal.IK_Location_Name__c+'</strike>'+' '+liveDisrup.IK_Location_Name__c;
        }else{
                 locationName = liveDisrup.IK_Location_Name__c;
        }
        
        /*String salesRegion = '';
        if(liveDisrup.Sales_Region__c <> oldVal.Sales_Region__c){
                 salesRegion = '<strike>'+oldVal.Sales_Region__c+'</strike>'+' '+liveDisrup.Sales_Region__c;
        }else{
                 salesRegion = liveDisrup.Sales_Region__c;
        }*/
        
        String status = '';
        if(liveDisrup.Status__c <> oldVal.Status__c){
                 status = '<strike>'+oldVal.Status__c+'</strike>'+' '+liveDisrup.Status__c;
        }else{
                 status = liveDisrup.Status__c;
        }
        
       /* String cause = '';
        if(liveDisrup.Cause__c <> oldVal.Cause__c){
                 cause = '<strike>'+oldVal.Cause__c+'</strike>'+' '+liveDisrup.Cause__c;
        }else{
                 cause = liveDisrup.Cause__c;
        }*/
                                                        
        String category = '';
        if(liveDisrup.Category__c <> oldVal.Category__c){
                 category = '<strike>'+oldVal.Category__c+'</strike>'+' '+liveDisrup.Category__c;
        }else{
                 category = liveDisrup.Category__c;
        }
                                                           
        String subcategory = '';
        if(liveDisrup.Subcategory__c <> oldVal.Subcategory__c){
                 subcategory = '<strike>'+oldVal.Subcategory__c+'</strike>'+' '+liveDisrup.Subcategory__c;
        }else{
                 subcategory = liveDisrup.Subcategory__c;
        }    
        String strProd = '';
        /*List<String> strPrdLst = liveDisrup.Product__c.split(';');
        for(String str : strPrdLst){
            strProd += str+'\n'+'<br/>';
        }
        String productName = '';*/
        //System.debug('-----prdctStr------'+prdctStr); 
        String newStr = '';                                                
        if(liveDisrup.Product__c <> oldVal.Product__c){
                 List<String> strPrdLst = prdctStr.split(';');
                 for(String str : strPrdLst){
                    newStr += str+'\n'+'<br/>';
                 }
                 strProd = '<strike>'+oldVal.Product__c+'</strike>'+'\n'+'<br/>'+newStr;
            	 //System.debug('-----strProd------'+strProd);
        }else{
                 List<String> strPrdLst = prdctStr.split(';');
                 for(String str : strPrdLst){
                    strProd += str+'\n'+'<br/>';
                 }
        }
        String htmlTemplate = '<table><tr><td>Product:&nbsp;&nbsp;&nbsp;</td><td>'+strProd+
                                '</td></tr><tr><td>'+'Location:&nbsp;&nbsp;&nbsp;</td><td>'+locationName +
                                //'</td></tr><tr><td>'+'Region:&nbsp;&nbsp;&nbsp;</td><td>'+salesRegion +
                                '</td></tr><tr><td>'+'Status:&nbsp;&nbsp;&nbsp;</td><td>'+status +
                                '</td></tr><tr><td>'+'Resolution Status:&nbsp;&nbsp;&nbsp;</td><td>'+resolutionStatus +
                                //'</td></tr><tr><td>'+'Disruption :&nbsp;&nbsp;&nbsp;</td><td>'+cause +
            					'</td></tr><tr><td>'+'Category :&nbsp;&nbsp;&nbsp;</td><td>'+category +
            					'</td></tr><tr><td>'+'Subcategory :&nbsp;&nbsp;&nbsp;</td><td>'+subcategory +
                                '</td></tr><tr><td>'+'Disruption Start:&nbsp;&nbsp;&nbsp;</td><td>'+beginDate +
                                '</td></tr><tr><td>'+'Estimated Disruption End:&nbsp;&nbsp;&nbsp;</td><td>'+estimatedEndDate +
                                '</td></tr><tr><td>'+'Actual Disruption End:&nbsp;&nbsp;&nbsp;</td><td>'+resolveDateTime +
                                '</td></tr><tr><td>'+'Option 1:&nbsp;&nbsp;&nbsp;</td><td>'+option +
                                '</td></tr><tr><td>'+'Option 2:&nbsp;&nbsp;&nbsp;</td><td>'+option2 +
                                '</td></tr><tr><td>'+'Comment :&nbsp;&nbsp;&nbsp;</td><td>'+comment+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                //'</td></tr><tr><td>'+'Link to Real Time List :&nbsp;&nbsp;&nbsp;</td><td>'+Label.Salesforce_URL+'/'+liveDisrup.Id+
                                //'</td></tr><tr><td>'+'Created Date :&nbsp;&nbsp;&nbsp;</td><td>'+CreatedDate+
                                //'</td></tr><tr><td>'+'Created By :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.CreatedBy__c+
                                //'</td></tr><tr><td>'+'Last Modified Date :&nbsp;&nbsp;&nbsp;</td><td>'+LastModifiedDate+
                                //'</td></tr><tr><td>'+'Last Modified By :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Last_ModfiedBy__c+
                                '</td></tr></table></body>  </html>';
        return htmlTemplate;
        
    }
    
    public static String createHtmlTemplateOnUpdateExt(Live_Disruption__c liveDisrup,Live_Disruption__c oldVal,
                                                       String prdctStr){

        String beginDate = '';
        if(liveDisrup.Begin_Date__c <> oldVal.Begin_Date__c){
            if(liveDisrup.Begin_Date__c == null){
                beginDate = '<strike>'+createDateTimeFormat(oldVal.Begin_Date__c)+'</strike>';
            }else{
                beginDate = '<strike>'+createDateTimeFormat(oldVal.Begin_Date__c)+'</strike>'+' '+createDateTimeFormat(liveDisrup.Begin_Date__c);
            }
        }else{
            if(liveDisrup.Begin_Date__c == null){
                beginDate = '';
            }else{
                beginDate = String.valueOf(createDateTimeFormat(liveDisrup.Begin_Date__c));
            }
        }
                                                           
        String estimatedEndDate = '';
        if(liveDisrup.Estimated_End_Date__c <> oldVal.Estimated_End_Date__c){
            if(liveDisrup.Estimated_End_Date__c == null){
                estimatedEndDate = '<strike>'+createDateTimeFormat(oldVal.Estimated_End_Date__c)+'</strike>';
            }else{
                estimatedEndDate = '<strike>'+createDateTimeFormat(oldVal.Estimated_End_Date__c)+'</strike>'+' '+createDateTimeFormat(liveDisrup.Estimated_End_Date__c);
            }
        }else{
            if(liveDisrup.Estimated_End_Date__c == null){
                estimatedEndDate = '';
            }else{
                estimatedEndDate = String.valueOf(createDateTimeFormat(liveDisrup.Estimated_End_Date__c));
            }
        }
        
        String resolveDateTime = '';
        if(liveDisrup.Resolve_Date_Time__c <> oldVal.Resolve_Date_Time__c){
            if(liveDisrup.Resolve_Date_Time__c == null){
                resolveDateTime = '<strike>'+createDateTimeFormat(oldVal.Resolve_Date_Time__c)+'</strike>';
            }else{
                resolveDateTime = '<strike>'+createDateTimeFormat(oldVal.Resolve_Date_Time__c)+'</strike>'+' '+createDateTimeFormat(liveDisrup.Resolve_Date_Time__c);
            }
        }else{
            if(liveDisrup.Resolve_Date_Time__c == null){
                resolveDateTime = '';   
            }else{
                resolveDateTime = String.valueof(createDateTimeFormat(liveDisrup.Resolve_Date_Time__c));
            }
        }
        
        String createdDate = createDateTimeFormat(liveDisrup.CreatedDate);
        
        String lastModifiedDate = createDateTimeFormat(liveDisrup.LastModifiedDate);
        
        if(String.isBlank(liveDisrup.Title__c )){
            liveDisrup.Title__c = '';
        }
        
                                                      
        String resolutionStatus = '';
        if(liveDisrup.Resolution_Status__c <> oldVal.Resolution_Status__c){
                if(String.isBlank(liveDisrup.Resolution_Status__c )){
                        resolutionStatus = '<strike>'+oldVal.Resolution_Status__c+'</strike>';
                }else{
                    if(liveDisrup.Resolution_Status__c == 'Resolved'){
                        resolutionStatus = '<strike>'+oldVal.Resolution_Status__c+'</strike>'+' '+'!!!'+'<b>'+liveDisrup.Resolution_Status__c.touppercase()+'</b>'+'!!!';
                    }    else{
                        resolutionStatus = '<strike>'+oldVal.Resolution_Status__c+'</strike>'+' '+liveDisrup.Resolution_Status__c;
                    }
                }
        }else{
                if(liveDisrup.Resolution_Status__c == null){
                    resolutionStatus = '';
                }else{
                    resolutionStatus = liveDisrup.Resolution_Status__c;
                }
        }
        String comment = '';
        if(liveDisrup.External_Stakeholders_Comment__c <> oldVal.External_Stakeholders_Comment__c){
            
            if(String.isBlank(liveDisrup.External_Stakeholders_Comment__c )){
                comment = '<strike>'+oldVal.External_Stakeholders_Comment__c+'</strike>';
            }else{
                comment = '<strike>'+oldVal.External_Stakeholders_Comment__c+'</strike>'+' '+liveDisrup.External_Stakeholders_Comment__c ;
            }
        }else{
            if(liveDisrup.External_Stakeholders_Comment__c == null){
                comment = '';
            }else{
                comment = liveDisrup.External_Stakeholders_Comment__c;
            }
        }
        
        String option = '';
        if(liveDisrup.IK_Option_1_Location_Name__c <> oldVal.IK_Option_1_Location_Name__c){
            if(liveDisrup.IK_Option_1_Location_Name__c == null){
                    option = '<strike>'+oldVal.IK_Option_1_Location_Name__c+'</strike>';
            }else{
                    option = '<strike>'+oldVal.IK_Option_1_Location_Name__c+'</strike>'+' '+liveDisrup.IK_Option_1_Location_Name__c;
            }
        }else{
            if(liveDisrup.IK_Option_1_Location_Name__c == null){//Option_Location_Name__c
                    option = '';
            }else{
                    option = liveDisrup.IK_Option_1_Location_Name__c;
            }
        }
        
        String option2 = '';
        if(liveDisrup.IK_Option_2_Location_Name__c <> oldVal.IK_Option_2_Location_Name__c){
            if(liveDisrup.IK_Option_2_Location_Name__c == null){
                    option2 = '<strike>'+oldVal.IK_Option_2_Location_Name__c+'</strike>';
            }else{
                    option2 = '<strike>'+oldVal.IK_Option_2_Location_Name__c+'</strike>'+' '+liveDisrup.IK_Option_2_Location_Name__c;
            }
        }else{
            if(liveDisrup.IK_Option_2_Location_Name__c == null){
                    option2 = '';
            }else{
                    option2 = liveDisrup.IK_Option_2_Location_Name__c;
            }
        }
        
        String productName = '';
        if(liveDisrup.Product__c <> oldVal.Product__c){
                 productName = '<strike>'+oldVal.Product__c+'</strike>'+' '+liveDisrup.Product__c;
        }else{
                 productName = liveDisrup.Product__c;
        }
        
        String locationName = '';
        if(liveDisrup.IK_Location_Name__c <> oldVal.IK_Location_Name__c){//Location_Name__c
                 locationName = '<strike>'+oldVal.IK_Location_Name__c+'</strike>'+' '+liveDisrup.IK_Location_Name__c;
        }else{
                 locationName = liveDisrup.IK_Location_Name__c;
        }
        
        /*String salesRegion = '';
        if(liveDisrup.Sales_Region__c <> oldVal.Sales_Region__c){
                 salesRegion = '<strike>'+oldVal.Sales_Region__c+'</strike>'+' '+liveDisrup.Sales_Region__c;
        }else{
                 salesRegion = liveDisrup.Sales_Region__c;
        }*/
        
        String status = '';
        if(liveDisrup.Status__c <> oldVal.Status__c){
                 status = '<strike>'+oldVal.Status__c+'</strike>'+' '+liveDisrup.Status__c;
        }else{
                 status = liveDisrup.Status__c;
        }
        
        /*String cause = '';
        if(liveDisrup.Cause__c <> oldVal.Cause__c){
                 cause = '<strike>'+oldVal.Cause__c+'</strike>'+' '+liveDisrup.Cause__c;
        }else{
                 cause = liveDisrup.Cause__c;
        }*/
                                                           
        String category = '';
        if(liveDisrup.Category__c <> oldVal.Category__c){
                 category = '<strike>'+oldVal.Category__c+'</strike>'+' '+liveDisrup.Category__c;
        }else{
                 category = liveDisrup.Category__c;
        }
                                                           
        String subcategory = '';
        if(liveDisrup.Subcategory__c <> oldVal.Subcategory__c){
                 subcategory = '<strike>'+oldVal.Subcategory__c+'</strike>'+' '+liveDisrup.Subcategory__c;
        }else{
                 subcategory = liveDisrup.Subcategory__c;
        }                                                  
        
        String strProd = '';
        /*List<String> strPrdLst = liveDisrup.Product__c.split(';');
        for(String str : strPrdLst){
            strProd += str+'\n'+'<br/>';
        }*/
        if(liveDisrup.Product__c <> oldVal.Product__c){
                 List<String> strPrdLst = prdctStr.split(';');
                 for(String str : strPrdLst){
                    strProd += str+'\n'+'<br/>';
                 }
                 strProd = '<strike>'+oldVal.Product__c+'</strike>'+'\n'+'<br/>'+strProd;
        }else{
                 List<String> strPrdLst = prdctStr.split(';');
                 for(String str : strPrdLst){
                    strProd += str+'\n'+'<br/>';
                 }
        }
        String htmlTemplate = '<table><tr><td>'+'Product:&nbsp;&nbsp;&nbsp;</td><td>'+strProd+
                                '</td></tr><tr><td>'+'Location:&nbsp;&nbsp;&nbsp;</td><td>'+locationName +
                                //'</td></tr><tr><td>'+'Region:&nbsp;&nbsp;&nbsp;</td><td>'+salesRegion +
                                '</td></tr><tr><td>'+'Status:&nbsp;&nbsp;&nbsp;</td><td>'+status +
                                '</td></tr><tr><td>'+'Resolution Status:&nbsp;&nbsp;&nbsp;</td><td>'+resolutionStatus +
                                //'</td></tr><tr><td>'+'Disruption :&nbsp;&nbsp;&nbsp;</td><td>'+cause + 
            					'</td></tr><tr><td>'+'Category :&nbsp;&nbsp;&nbsp;</td><td>'+category +
            					//'</td></tr><tr><td>'+'Subcategory :&nbsp;&nbsp;&nbsp;</td><td>'+subcategory +
                                '</td></tr><tr><td>'+'Disruption Start:&nbsp;&nbsp;&nbsp;</td><td>'+beginDate +
                                '</td></tr><tr><td>'+'Estimated Disruption End:&nbsp;&nbsp;&nbsp;</td><td>'+estimatedEndDate +
                                '</td></tr><tr><td>'+'Actual Disruption End:&nbsp;&nbsp;&nbsp;</td><td>'+resolveDateTime +
                                //'</td></tr><tr><td>'+'Option 1:&nbsp;&nbsp;&nbsp;</td><td>'+option +
                                //'</td></tr><tr><td>'+'Option 2:&nbsp;&nbsp;&nbsp;</td><td>'+option2 +
                                '</td></tr><tr><td>'+'Comment :&nbsp;&nbsp;&nbsp;</td><td>'+comment+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                '</td></tr><tr><td>'+'</td><td>'+''+
                                //'</td></tr><tr><td>'+'Link to Real Time List :&nbsp;&nbsp;&nbsp;</td><td>'+Label.Salesforce_URL+'/'+liveDisrup.Id+
                                //'</td></tr><tr><td>'+'Created Date :&nbsp;&nbsp;&nbsp;</td><td>'+CreatedDate+
                                //'</td></tr><tr><td>'+'Created By :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.CreatedBy__c+
                                //'</td></tr><tr><td>'+'Last Modified Date :&nbsp;&nbsp;&nbsp;</td><td>'+LastModifiedDate+
                                //'</td></tr><tr><td>'+'Last Modified By :&nbsp;&nbsp;&nbsp;</td><td>'+liveDisrup.Last_ModfiedBy__c+
                                '</td></tr></table></body>  </html>';
        return htmlTemplate;
        
    }
    
    public static String createDateTimeFormat(DateTime dateTimeVal){
        String datTimeVal;
        if(dateTimeVal <> null){
            datTimeVal = dateTimeVal.format('dd-MM-YYYY HH:mm:ss');
        }
        return datTimeVal;
    }
    
    public static String createDateFormat(DateTime dateTimeVal){
        String datTimeVal;
        if(dateTimeVal <> null){
            datTimeVal = dateTimeVal.format('dd-MM-YYYY');
        }
        return datTimeVal;
    }
    
    
}