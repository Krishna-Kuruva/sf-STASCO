@isTest(SeeAllData = False)
public class RE_ApprovalProcessHandlerTest {     
     
    static RE_MOA__c createTestData(){
        RE_Product__c productTemp=new RE_Product__c();
        productTemp.Name='Gasoil B0 0.05% S';
        insert productTemp;
        
        RE_Location__c depoTemp=new RE_Location__c();
        depoTemp.Name='Bagan Luar';
        insert depoTemp;
        
        RE_MOA__c tempData= new RE_MOA__c();
        tempData.RE_AM_Challenged_Price__c =53;
        tempData.RE_Final_PSP__c=54;
        tempData.RE_Status__c='Submitted';
        tempData.RE_AM_Comments__c = 'test class';
        tempData.RE_Product__c =productTemp.Id;
        tempData.RE_Depot_Name__c=depoTemp.Id;
        
        insert tempData;
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setComments(tempData.RE_AM_Comments__c);        
        req.setObjectId(tempData.id);
        // Submit the approval request for the Opportunity        
        Approval.ProcessResult result = Approval.process(req); 
        
        return tempData;
        
    }
    public static testmethod void processRecordstest(){   
        RE_MOA__c tempRecord= new RE_MOA__c();
        tempRecord = createTestData();
        test.startTest(); 
        system.debug('testing started--');
        RE_ApprovalProcessHandler.checkRecordInApprovalProcess(tempRecord.id+'');
        RE_ApprovalProcessHandler.processRecords(tempRecord.id+'',tempRecord.RE_AM_Comments__c,'Approve');
        RE_ApprovalProcessHandler.checkRecordInApprovalProcess(tempRecord.id+'');
        system.debug('testing ended--');
        test.stopTest();        
    }
    
}