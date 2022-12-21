/*****************************************************************************
@Name:  RV_ClassException    
@=========================================================================
@Purpose: This class is used to throw exception and create record in RV_Exception object 
         
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      5/12/2017         INITIAL DEVELOPMENT

******************************************************************************/
public class RV_ClassException   extends Exception{
    
		private static RV_ClassException single_instance = null;
        // static method to create instance of Singleton class
        public static RV_ClassException getInstance()
        {
          
            if (single_instance == null)
                single_instance = new RV_ClassException();
            return single_instance;
        }
    
    public static String insertExceptionRecord(String  getStatusCode,String getMessage,String className,String methodName,String type){
        
        RV_Exception__c rvExcep = new RV_Exception__c();
        
        rvExcep.Status_Code__c = getStatusCode;
        rvExcep.getMessage__c = getMessage;
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
    
    //Fix_Exception_04Sep2019_Soumyajit starts
    public static String insertExceptionRecord(List<RV_Exception__c> excpList)
    {
        String returnMsg = 'Success';
        if(excpList.size()>0)
        {
            System.debug('Exception List:' + excpList);
            try{
                insert excpList;
               }
            catch(Exception e)
            	{
                System.debug(e);
                returnMsg = 'Failure';
                }
        }
        return returnMsg;
    }
    //Fix_Exception_04Sep2019_Soumyajit ends
}