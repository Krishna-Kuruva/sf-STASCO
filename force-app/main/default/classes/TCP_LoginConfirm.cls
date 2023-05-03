/**************************************************************************************************
 * Class Name : TCP_LoginConfirm 
 * Description: To confirm to the user after successfully login 
 * Verion     : 1.0
 * **************************************************************************************************/
public class TCP_LoginConfirm {
    public string url {get; set;}
    public string urlPara {get; set;}
    public string buttonLabel {get; set;}
    public TCP_LoginConfirm(){
      	
       // this parameter coming from change password controller
       urlPara = ApexPages.currentPage().getParameters().get('firstTimeLogin');
        //if parameter value is no then url navigate to login page
        if(urlPara == 'no' ){
            url = 'secur/logout.jsp';
            buttonLabel = 'Login';
        }
        //if parameter value is yes then url navigate to home page
        else if (urlPara == 'yes' || urlPara == null){
            url = 's/';
            buttonLabel = 'Ok';
        }
        
    }
    
}