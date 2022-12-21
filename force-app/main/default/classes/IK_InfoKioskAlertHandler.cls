/*****************************************************************************
@Name:  IK_InfoKioskAlertHandler     
@=========================================================================
@Purpose: Trigger handler will execute on insert and update and delete to assign the  user in particular user group 
         
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      12/10/2017         INITIAL DEVELOPMENT

******************************************************************************/
public class IK_InfoKioskAlertHandler {
    
    public static void onbeforeinsertInfoKioskAlert(List<InfoKiosk_Alert__c> alertnewlst){
        
        Map<String,List<String>> locationcodeMap = new Map<String,List<String>>();
        Set<String> locationCodeSet = new Set<String>();
        
        for(InfoKiosk_Alert__c alertDetails : alertnewlst){
       	  	  if(alertDetails.All_Changes__c == true ){
       	  	  	 alertDetails.User_Selection__c = 'All Changes';
              }
              if(alertDetails.New_items_are_added__c == true){
       	  	  	 alertDetails.User_Selection__c = 'New items are added';
              }
              if(alertDetails.Existing_items_are_modified__c == true){
       	  	  	 alertDetails.User_Selection__c = 'Existing items are modified';
              }
              if(alertDetails.Items_are_deleted__c == true){
       	  	  	 alertDetails.User_Selection__c = 'Items are deleted';
              }
              List<String> locationCodeLst = new List<String>();
              if(alertDetails.Select_Location__c <> null){
             		locationCodeLst.addall(alertDetails.Select_Location__c.split(';'));
                    locationcodeMap.put(alertDetails.createdById,locationCodeLst);
              }else{
                  locationcodeMap.put(alertDetails.createdById,new List<String>{'All Location'});
              }
              if(alertDetails.Select_Location__c <> null){
              		locationCodeSet.addall(alertDetails.Select_Location__c.split(';'));
              }
        }
        System.debug('------locationCodeSet-------'+locationCodeSet);
        if(!locationcodeMap.values().isEmpty()){
             List<IK_location__c> locationLst = [Select id,Name,Plant_Code__c
                                             from IK_location__c where Name in:locationCodeSet];
            Map<String,String> locationNameCodeMap = new Map<String,String>();
            if(!locationLst.isEmpty()){
                for(IK_location__c loc : locationLst){
                    locationNameCodeMap.put(loc.Name, loc.Plant_Code__c);
                }
            }
            
            for(InfoKiosk_Alert__c alertDetails : alertnewlst){
                if(locationcodeMap.containskey(alertDetails.CreatedById)){
                    List<String> locNameLst = locationcodeMap.get(alertDetails.CreatedById);
                    String locCode = '';
                    for(String locName : locNameLst){
                        if(locationNameCodeMap.containskey(locName)){
                            locCode+=locationNameCodeMap.get(locName)+';';
                        }
                    }
                    if(locCode.endsWith(';')){
                        locCode = locCode.removeEnd(';');
                        System.debug('-----------'+locCode);
                    }
                   
                    alertDetails.Location_Code__c = locCode;
                }
            }
        }
    }
    
    public static void onafterinsertInfoKioskAlert(List<InfoKiosk_Alert__c> alertnewlst){
           
           List<String> infoLst = new List<String>();
           for(InfoKiosk_Alert__c alrt : alertnewlst){
               
               infoLst.add(alrt.ID);
           }
           
       	   createpublicGroup(infoLst);
       }
    
    @future
    public static void createpublicGroup(List<String> alertID){
        
          Map<String,Group> groupMap = new Map<String,Group>();
          Set<String> setOfGroupName = new Set<String>();
          setOfGroupName = fetchGroupDevName();
       	  List<Group> groupLst = IK_DAL.fetchGroup(setOfGroupName);
       	  if(groupLst <> null && groupLst.size() > 0){
              
       	  	  for(Group grpLst:groupLst){
       	  	  	groupMap.put(grpLst.DeveloperName,grpLst);
       	  	  }
       	  } 
           List<InfoKiosk_Alert__c> infoLst = new List<InfoKiosk_Alert__c>();
          infoLst = IK_DAL.fetchInfoKioskAlert(alertID);
       	  List<GroupMember> addlistGroupMember =new List<GroupMember>();  
       	  for(InfoKiosk_Alert__c alertDetails : infoLst){
       	  	
       	  	  
       	  	  if(alertDetails.All_Changes__c == true || alertDetails.Anything_changes__c == true){
       	  	  	 alertDetails.User_Selection__c = 'All Changes';
                  
       	  	  	 if(groupMap.containskey(Label.All_Changes_c)){
       	  	  	 	GroupMember gm= new GroupMember(); 
       	  	  	 	gm.GroupId = groupMap.get(Label.All_Changes_c).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
       	  	  if(alertDetails.New_items_are_added__c == true){
       	  	  	 alertDetails.User_Selection__c = 'New items are added';
       	  	  	 if(groupMap.containskey(Label.New_items_are_added_c)){
       	  	  	 	GroupMember gm= new GroupMember(); 
       	  	  	 	gm.GroupId = groupMap.get(Label.New_items_are_added_c).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
       	  	  if(alertDetails.Existing_items_are_modified__c == true){
       	  	  	 alertDetails.User_Selection__c = 'Existing items are modified';
       	  	  	 if(groupMap.containskey(Label.Existing_items_are_modified_c)){
       	  	  	 	GroupMember gm= new GroupMember(); 
       	  	  	 	gm.GroupId = groupMap.get(Label.Existing_items_are_modified_c).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
              if(alertDetails.Items_are_deleted__c == true){
       	  	  	 alertDetails.User_Selection__c = 'Items are deleted';
       	  	  	 if(groupMap.containskey(Label.Items_are_deleted_c)){
       	  	  	 	GroupMember gm= new GroupMember(); 
       	  	  	 	gm.GroupId = groupMap.get(Label.Items_are_deleted_c).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
              /*if(alertDetails.Someone_changes_item_last_modified_by_me__c == true){
       	  	  	
       	  	  	 if(groupMap.containskey(Label.Info_Kiosk_Last_Modfied_By_me)){
       	  	  	 	GroupMember gm= new GroupMember(); 
       	  	  	 	gm.GroupId = groupMap.get(Label.Info_Kiosk_Last_Modfied_By_me).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
              if(alertDetails.Someone_changes_an_item_created_by_me__c == true){
       	  	  	 System.debug('$$$$$$$$$$$$$$$'+alertDetails.Someone_changes_an_item_created_by_me__c);
       	  	  	 if(groupMap.containskey(Label.Info_Kiosk_Items_Created_By_Me)){
       	  	  	 	System.debug('$$$$$$$$$$$$$$$'+Label.Info_Kiosk_Items_Created_By_Me);
                    GroupMember gm= new GroupMember(); 
       	  	  	 	gm.GroupId = groupMap.get(Label.Info_Kiosk_Items_Created_By_Me).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }*/
       	  }
       	  System.debug('&&&&&&&addlistGroupMember&&&&&'+addlistGroupMember);
       	  if(addlistGroupMember <> null && addlistGroupMember.size() > 0){
       	  	 try{
       	  	 	insert addlistGroupMember;
       	  	 }catch(Exception e){
       	  	 	System.debug('$$$$$$$$$$$$$$$'+e);
       	  	 }
       	  }
    }
    
    public static void onbeforeUpdateInfoKioskAlert(List<InfoKiosk_Alert__c> alertnewlst,List<InfoKiosk_Alert__c> alertoldlst,
    Map<Id,InfoKiosk_Alert__c> alertnewMap,Map<Id,InfoKiosk_Alert__c> alertoldMap){
        
        Map<String,List<String>> locationcodeMap = new Map<String,List<String>>();
        Set<String> locationCodeSet = new Set<String>();
        
        for(InfoKiosk_Alert__c alertDetails : alertnewlst){
            
       	  	  if(alertDetails.All_Changes__c == true ){
       	  	  	 alertDetails.User_Selection__c = 'All Changes';
              }
              if(alertDetails.New_items_are_added__c == true){
       	  	  	 alertDetails.User_Selection__c = 'New items are added';
              }
              if(alertDetails.Existing_items_are_modified__c == true){
       	  	  	 alertDetails.User_Selection__c = 'Existing items are modified';
              }
              if(alertDetails.Items_are_deleted__c == true){
       	  	  	 alertDetails.User_Selection__c = 'Items are deleted';
              }
            
              List<String> locationCodeLst = new List<String>();
              if(alertDetails.Select_Location__c <> null){
             		locationCodeLst.addall(alertDetails.Select_Location__c.split(';'));
                    locationcodeMap.put(alertDetails.createdById,locationCodeLst);
              }else{
                  locationcodeMap.put(alertDetails.createdById,new List<String>{'All Location'});
              }
              if(alertDetails.Select_Location__c <> null){
              	locationCodeSet.addall(alertDetails.Select_Location__c.split(';'));
              }
        }
        
        System.debug('------locationCodeSet-------'+locationCodeSet);
        System.debug('------locationcodeMap.values()-------'+locationcodeMap.values());
        if(!locationcodeMap.values().isEmpty()){
            List<IK_location__c> locationLst = [Select id,Name,Plant_Code__c
                                             from IK_location__c where Name in:locationCodeSet];
            Map<String,String> locationNameCodeMap = new Map<String,String>();
            if(!locationLst.isEmpty()){
                for(IK_location__c loc : locationLst){
                    locationNameCodeMap.put(loc.Name, loc.Plant_Code__c);
                }
            }
            
            for(InfoKiosk_Alert__c alertDetails : alertnewlst){
                if(locationcodeMap.containskey(alertDetails.CreatedById)){
                    List<String> locNameLst = locationcodeMap.get(alertDetails.CreatedById);
                    String locCode = '';
                    for(String locName : locNameLst){
                        if(locationNameCodeMap.containskey(locName)){
                            locCode+=locationNameCodeMap.get(locName)+';';
                        }
                    }
                    if(locCode.endsWith(';')){
                        locCode = locCode.removeEnd(';');
                        System.debug('-----------'+locCode.removeEnd(';'));
                    }
                   
                    alertDetails.Location_Code__c = locCode;
                }
            }
        }
    }
    
    public static void onafterupdateInfoKioskAlert(List<InfoKiosk_Alert__c> alertnewlst,List<InfoKiosk_Alert__c> alertoldlst,
    Map<Id,InfoKiosk_Alert__c> alertnewMap,Map<Id,InfoKiosk_Alert__c> alertoldMap){
          List<String> updateinfoLst = new List<String>();
          for(InfoKiosk_Alert__c iterateValue :alertnewlst){
              if((alertnewMap.get(iterateValue.ID).All_Changes__c <> alertoldMap.get(iterateValue.ID).All_Changes__c) ||
                 (alertnewMap.get(iterateValue.ID).New_items_are_added__c <> alertoldMap.get(iterateValue.ID).New_items_are_added__c) ||
                 (alertnewMap.get(iterateValue.ID).Existing_items_are_modified__c <> alertoldMap.get(iterateValue.ID).Existing_items_are_modified__c) ||
                (alertnewMap.get(iterateValue.ID).Items_are_deleted__c <> alertoldMap.get(iterateValue.ID).Items_are_deleted__c) ||
                
                (alertnewMap.get(iterateValue.ID).Someone_changes_item_last_modified_by_me__c <> alertoldMap.get(iterateValue.ID).Someone_changes_item_last_modified_by_me__c) ||
                (alertnewMap.get(iterateValue.ID).Someone_changes_an_item_created_by_me__c <> alertoldMap.get(iterateValue.ID).Someone_changes_an_item_created_by_me__c)){
                     if(iterateValue.All_Changes__c == true ||iterateValue.New_items_are_added__c == true || iterateValue.Existing_items_are_modified__c == true ||
                       iterateValue.Items_are_deleted__c == true  || iterateValue.Someone_changes_item_last_modified_by_me__c == true ||
                       iterateValue.Someone_changes_an_item_created_by_me__c == true){
                         System.debug('&&&&&iterateValue.Id&&&&&'+iterateValue.Id);
                         updateinfoLst.add(iterateValue.Id);
                     }
                 }                            
          }   
         if(!updateinfoLst.isEmpty()){
             
         		updatepublicGroupUsers(updateinfoLst);
         }
    }
    @future
    
    public static void updatepublicGroupUsers(List<String> alertID) {
        List<InfoKiosk_Alert__c> infoLst = new List<InfoKiosk_Alert__c>();
        infoLst = IK_DAL.fetchInfoKioskAlert(alertID);
        Map<String,Group> groupMap = new Map<String,Group>();
          Set<String> setOfGroupName = new Set<String>();
          setOfGroupName = fetchGroupDevName();
       	  List<Group> groupLst = IK_DAL.fetchGroup(setOfGroupName);
       	  if(groupLst <> null && groupLst.size() > 0){
       	  	  for(Group grpLst:groupLst){
       	  	  	groupMap.put(grpLst.DeveloperName,grpLst);
       	  	  } 
       	  } 
        List<GroupMember> gmUser= new List<GroupMember>(); 
        gmUser = IK_DAL.fetchGroupMember(groupMap.keySet(),UserInfo.getUserId());
        try{
            delete gmUser;
        }catch(Exception de){
            System.debug('$$$$$$$$$$$$$'+de);
        }
        List<GroupMember> addlistGroupMember =new List<GroupMember>(); 
        if(infoLst <> null && infoLst.size() > 0){
            
            for(InfoKiosk_Alert__c alertDetails : infoLst){
            	   
       	  	  if(alertDetails.All_Changes__c == true || alertDetails.Anything_changes__c == true){
       	  	  	 alertDetails.User_Selection__c = 'All Changes';
       	  	  	 if(groupMap.containskey(Label.All_Changes_c)){
       	  	  	 	GroupMember gm= new GroupMember();
       	  	  	 	gm.GroupId = groupMap.get(Label.All_Changes_c).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
       	  	  if(alertDetails.New_items_are_added__c == true){
       	  	  	 alertDetails.User_Selection__c = 'New items are added';
       	  	  	 if(groupMap.containskey(Label.New_items_are_added_c)){
       	  	  	 	GroupMember gm= new GroupMember();
       	  	  	 	gm.GroupId = groupMap.get(Label.New_items_are_added_c).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
       	  	  if(alertDetails.Existing_items_are_modified__c == true){
       	  	  	 alertDetails.User_Selection__c = 'Existing items are modified';
       	  	  	 if(groupMap.containskey(Label.Existing_items_are_modified_c)){
       	  	  	 	GroupMember gm= new GroupMember();
       	  	  	 	gm.GroupId = groupMap.get(Label.Existing_items_are_modified_c).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
              if(alertDetails.Items_are_deleted__c == true){
       	  	  	 alertDetails.User_Selection__c = 'Items are deleted';
       	  	  	 if(groupMap.containskey(Label.Items_are_deleted_c)){
       	  	  	 	GroupMember gm= new GroupMember();
       	  	  	 	gm.GroupId = groupMap.get(Label.Items_are_deleted_c).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
                /*if(alertDetails.Someone_changes_item_last_modified_by_me__c == true){
       	  	  	 System.debug('$$$$$$$$$$$$$$$'+alertDetails.Someone_changes_item_last_modified_by_me__c);
       	  	  	 if(groupMap.containskey(Label.Info_Kiosk_Last_Modfied_By_me)){
                     System.debug('$$$$$$$$$$$$$$$'+alertDetails.Someone_changes_item_last_modified_by_me__c);
       	  	  	 	GroupMember gm= new GroupMember();
       	  	  	 	gm.GroupId = groupMap.get(Label.Info_Kiosk_Last_Modfied_By_me).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }
              if(alertDetails.Someone_changes_an_item_created_by_me__c == true){
       	  	  	
       	  	  	 if(groupMap.containskey(Label.Info_Kiosk_Items_Created_By_Me)){
       	  	  	 	GroupMember gm= new GroupMember();
       	  	  	 	gm.GroupId = groupMap.get(Label.Info_Kiosk_Items_Created_By_Me).Id;
       	  	  	 	gm.UserOrGroupId = UserInfo.getUserId();
       	  	  	 	addlistGroupMember.add(gm);
       	  	  	 }
       	  	  }*/

            }
            if(addlistGroupMember <> null && addlistGroupMember.size() > 0){
                 try{
                    insert addlistGroupMember;
                 }catch(Exception e){
                    System.debug('$$$$$$$$$$$$$$$'+e);
                 }
       	    }
        }  
    }
    
    public static void onafterdeleteInfoKiosk(List<InfoKiosk_Alert__c> alertnewlst,
                                              List<InfoKiosk_Alert__c> alertoldlst,
    										  Map<Id,InfoKiosk_Alert__c> alertnewMap,
                                              Map<Id,InfoKiosk_Alert__c> alertoldMap){
                                                  
          List<String> updateinfoLst = new List<String>();
          Map<String,InfoKiosk_Alert__c> createdByIdMap = new Map<String,InfoKiosk_Alert__c>();                                        
          for(InfoKiosk_Alert__c iterateValue :alertoldlst){
              updateinfoLst.add(iterateValue.Id);
              createdByIdMap.put(iterateValue.CreatedById,iterateValue);                               
          }   
 
          List<InfoKiosk_Alert__c> fetchInfoKioskLst = [Select id,createdById,All_Changes__c,New_items_are_added__c,Existing_items_are_modified__c,Items_are_deleted__c,
               Anything_changes__c,Someone_changes_item_last_modified_by_me__c,Someone_changes_an_item_created_by_me__c,
               User_Selection__c,Select_Location__c,Select_Products__c,Location_Code__c from InfoKiosk_Alert__c 
                                                        where createdById in:createdByIdMap.keySet()];
          Boolean deleteUser = false; 
          Map<String,List<InfoKiosk_Alert__c>> fetchExistingInfoKioskMap = new Map<String,List<InfoKiosk_Alert__c>>();                                       
          for(InfoKiosk_Alert__c info : fetchInfoKioskLst){

              if(!fetchExistingInfoKioskMap.containskey(info.CreatedById)){
                  fetchExistingInfoKioskMap.put(info.CreatedById,new List<InfoKiosk_Alert__c> {info});
              }else{
                  List<InfoKiosk_Alert__c> infoKioskNewLst = fetchExistingInfoKioskMap.get(info.CreatedById);
                  infoKioskNewLst.add(info);
                  fetchExistingInfoKioskMap.put(info.CreatedById,infoKioskNewLst);
              }
          }

          if(!alertoldMap.isEmpty()){                                        
              for(InfoKiosk_Alert__c create : alertoldMap.values()){
                  if(fetchExistingInfoKioskMap.containskey(create.CreatedById)){
                      List<InfoKiosk_Alert__c> infoKioskLst = fetchExistingInfoKioskMap.get(create.CreatedById);
                      for(InfoKiosk_Alert__c infoKiosk : infoKioskLst){
                          if(infoKiosk.Id <> create.Id){
                              if(infoKiosk.User_Selection__c ==  create.User_Selection__c){
                                  deleteUser = true;
                              }
                          }
                      }
                  }                                     
              }  
          }
                                                  
          if(deleteUser == false){                                        
          		deletepublicGroupUsers(updateinfoLst);
          }
    }
    
    @future
    public static void deletepublicGroupUsers(List<String> alertID){
          Map<String,Group> groupMap = new Map<String,Group>();
          Set<String> setOfGroupName = new Set<String>();
          setOfGroupName = fetchGroupDevName();
       	  List<Group> groupLst = IK_DAL.fetchGroup(setOfGroupName);
       	  if(groupLst <> null && groupLst.size() > 0){
       	  	  for(Group grpLst:groupLst){
       	  	  	groupMap.put(grpLst.DeveloperName,grpLst);
       	  	  } 
       	  } 
          List<GroupMember> gmUser= new List<GroupMember>(); 
          gmUser =IK_DAL.fetchGroupMember(groupMap.keySet(),UserInfo.getUserId());
          try{
            delete gmUser;
          }catch(Exception de){
            System.debug('$$$$$$$$$$$$$'+de);
          }
    }
    
    public static Set<String> fetchGroupDevName(){
        Set<String> setOfGroupDevName = new Set<String>();
        setOfGroupDevName.add(Label.All_Changes_c);
        setOfGroupDevName.add(Label.New_items_are_added_c);
        setOfGroupDevName.add(Label.Existing_items_are_modified_c);
        setOfGroupDevName.add(Label.Items_are_deleted_c);
        setOfGroupDevName.add(Label.Info_Kiosk_Last_Modfied_By_me);
        setOfGroupDevName.add(Label.Info_Kiosk_Items_Created_By_Me);
        return setOfGroupDevName;
    }
}