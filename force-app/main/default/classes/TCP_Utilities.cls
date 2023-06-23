public with sharing class TCP_Utilities {

    //Get Month in Text
    @AuraEnabled
    public static string getMonthName(integer monthNumber){    
        string monthName;          
        Map<String,string> monthMAp = new Map<String,string>{'1' => 'Jan', '2' => 'Feb', '3' => 'Mar', '4' => 'Apr', '5' => 'May', '6' => 'Jun', '7' => 'Jul', '8' => 'Aug', '9' => 'Sep', '10' => 'Oct', '11' => 'Nov', '12' => 'Dec'};
        monthName = monthMap.get(string.valueof(monthNumber));
        return monthName;
    }

    // get logged in user details
    public static User getLoggedInUserDetails(){
        return [SELECT  Id, Username, Email, Name, ProfileId, Logon_as_TCP_User__c, Is_First_Time_Login__c, TCP_Region__c, TCP_Role__c from User where Id =: UserInfo.getUserId()];
    }

    public static List<String> getStatusForSelectedTile(string selectedTile, boolean isCommopsUser){
       
        if(selectedTile==system.label.TCP_ReviewOrApprovalLabel+system.label.TCP_ApprovalLabel){
            return new List<String>{'Submitted'};
        }else if((selectedTile==system.label.TCP_CurrentOrderLabel+system.label.TCP_OrderLabel)||(selectedTile==system.label.TCP_CurrentOrderCULabel)||(selectedTile==system.label.TCP_CurrentOrderLabel+' '+system.label.TCP_OrderLabel)){
            return new List<String>{'Submitted','Approved','Approved (C)','Approved (M)','Shipped'};
        }else if(selectedTile==system.label.TCP_ModificationOrCancelLabel+system.label.TCP_CancellationReqLabel){
            return new List<String>{'Approved (C)','Approved (M)'};
        }else if(selectedTile==system.label.TCP_RejectLabel+system.label.TCP_CancelledOrderLabel){
            return new List<String>{'Rejected', 'Cancelled'};
        }
        else if(selectedTile==system.label.TCP_PreviousOrdersLabel){
            if(isCommopsUser){
            	return new List<String>{'Submitted','Approved','Rejected','Cancelled','Approved (C)','Approved (M)','Shipped'};
            }else{
             	return new List<String>{'Draft','Submitted','Approved','Rejected','Cancelled','Approved (C)','Approved (M)','Shipped'};
            }        
        }
        else if(selectedTile==system.label.TCP_SavedOrderLabel){
            return new List<String>{'Draft'};
        }else if(selectedTile=='Order History'){
            if(isCommopsUser){
            	return new List<String>{'Submitted','Approved','Rejected','Cancelled','Approved (C)','Approved (M)','Shipped'};
            }else{
            	return new List<String>{'Draft','Submitted','Approved','Rejected','Cancelled','Approved (C)','Approved (M)','Shipped'};
            }
        }
        return null;
    }
    
    public static Integer getQueryDaysForSelectedTile(string selectedTile){
       
        if((selectedTile==system.label.TCP_RejectLabel+system.label.TCP_CancelledOrderLabel)||(selectedTile==system.label.TCP_SavedOrderLabel)){
            return 180;
        }
        else if(selectedTile==system.label.TCP_PreviousOrdersLabel){
            return 90;
        }
        return null;
    }
    @AuraEnabled
    public static String getDateWithMonthName(Date reqDate){
        Time myTime = Time.newInstance(3, 3, 3, 0);
        DateTime reqDatetime = dateTime.newInstance(reqDate,myTime);
        return (reqDatetime.format('dd MMM yyyy')).toUpperCase();
    }
}