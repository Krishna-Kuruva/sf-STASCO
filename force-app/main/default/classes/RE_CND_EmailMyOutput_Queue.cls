/**************************************************************************************************
* Name: RE_CND_EmailMyOutput_Queue
* Object: RE_MY_Output__c
* Purpose: Used for Canada Output Email Report geneartion
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2023-03-14
* Modify History: 
* 2023-03-14		Abhilash		Created
**************************************************************************************************/
public class RE_CND_EmailMyOutput_Queue implements Queueable{
    
    private RE_Job_Run_Audit__c jra;
    private List<String> emailNames;
    private Boolean isEmailToMe;
    private Date reqFrmDate;
    
    //Constructor
    public RE_CND_EmailMyOutput_Queue(RE_Job_Run_Audit__c jra, List<String> emailNames, Boolean isEmailToMe, Date reqFrmDate){        
        this.jra = jra;
        this.emailNames = emailNames;
        this.isEmailToMe = isEmailToMe;
        this.reqFrmDate = reqFrmDate;
    }
    
    //Execute method
    public void execute(QueueableContext context){
        RE_CND_EmailMyOutputController.processCongaEmails(emailNames, isEmailToMe, jra, reqFrmDate);
    }
}