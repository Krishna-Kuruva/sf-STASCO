/******************************************************************************************************************
className           :    RE_ApprovalProcessHandler
Description         :    Controller class for lightning components used to Approve / Reject the record.
Author              :    Vijaykumar S
 
*******************************************************************************************************************/
public class RE_ApprovalProcessHandler { 
    
/****************************************************************************************************************
Method Name:  getWorkItemId
Description:  Return the workID if record is submitted for approval process
			  Input to this method is Object ID/ record ID 
****************************************************************************************************************/   
    public static Id getWorkItemId(Id targetObjectId){
        Id retVal = null;        
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId])
            retVal  =  workItem.Id;
        
        return retVal;
    }

/****************************************************************************************************************
Method Name:  processRecords
Description:  Approve or Reject the record based on the input parameters 
****************************************************************************************************************/   
 
    @AuraEnabled
    public static void processRecords(String idValue,String comments,String ProcessType){
        system.debug('idValue@@-'+idValue);
        system.debug('comments@@-'+comments);        
        system.debug('ProcessType@@-'+ProcessType);
        
        try{
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(comments);
            req.setAction(ProcessType);
            req.setNextApproverIds(null);
            Id workItemId = getWorkItemId(idValue); 
            RE_MOA__c  dispalyInfeed=[Select ID,RE_AM_Challenged_Price__c,RE_Final_PSP__c from RE_MOA__c where id=:idValue];
            
                       
            if(workItemId != null){
                req.setWorkitemId(workItemId);
                // Submit the request for approval
                Approval.ProcessResult result =  Approval.process(req);
                system.debug('result--'+result);
                
                FeedItem feed = new FeedItem();
                feed.ParentId =idValue;
                feed.Body =  'Record Status:'+ProcessType+' \n Comments: '+comments+'\n AM Challenged Price :'+ dispalyInfeed.RE_AM_Challenged_Price__c+' \n Final PSP :'+ dispalyInfeed.RE_Final_PSP__c;
                feed.IsRichText =false;
                insert feed;
            }
        }catch(exception ex){
            system.debug('excetion'+ex);
            throw new AuraException(ex.getMessage());
        }
    }
/****************************************************************************************************************
Method Name:  checkRecordInApprovalProcess
Description:  Check weather record is submitted for the Approval Process. 
****************************************************************************************************************/   
    @AuraEnabled
    public static Map<String,String> checkRecordInApprovalProcess(String idValue){
        Map<String,String> Message=new Map<String,String>();
        
        Group approvalUserQueue =[select id, name, DeveloperName from Group where type='Queue' AND DeveloperName ='RE_MOA_Approval_Queue'];
        String userID=UserInfo.getUserId();
        List<GroupMember> userIDList = [select UserOrGroupId from GroupMember where GroupId=: approvalUserQueue.Id AND UserOrGroupId =: userID];
       	system.debug('data in group'+userIDList);
        
        if(getWorkItemId(idValue) != null){
            if(!userIDList.isEmpty()){
                Message.put('isRecordInApprovalPro','true');
                Message.put('ApproveRejectButton','false');
            }
            else{
                Message.put('isRecordInApprovalPro','true');
                Message.put('ApproveRejectButton','true');
            }
        }
        else{
            Message.put('isRecordInApprovalPro','false');
            Message.put('ApproveRejectButton','true');
        }        
        
        return Message;
    }
    
}