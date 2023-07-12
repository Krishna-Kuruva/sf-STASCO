public with sharing class TCP_ExceptionLogClass {
	public static String insertExceptionRecord(String  getStatusCode,String getMessage,String className,String methodName,String type){
        
        RV_Exception__c rvExcep = new RV_Exception__c();
        
        rvExcep.Status_Code__c = getStatusCode;
        rvExcep.gsap_Message__c = getMessage;//using this field even naming convention is different as exception length will be more than 250 chars
        rvExcep.Apex_Class__c = className;
        rvExcep.Method_Name__c = methodName;
        rvExcep.Type__c = type;
        try{
        	insert rvExcep;
        }catch(Exception e){
            System.debug('^^^^^^^^^^^^^^^^'+e);
        }
        
        if(rvExcep <> null)
       		 return 'Success';
        else{
            return 'Failure';
        }
    }
}