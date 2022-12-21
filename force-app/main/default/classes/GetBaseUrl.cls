//Fix_Lakshmi
public class GetBaseUrl {
@AuraEnabled
public static String GetUrl() {
    system.debug('URL');
    String urlInstance=String.valueof(System.URL.getSalesforceBaseURL().gethost());
    system.debug(urlInstance);
    List<String> parts=urlInstance.split('\\.');
    system.debug(parts[0]);
     
    urlInstance  ='https://' + parts[0] + '.lightning.force.com/apex/';
	system.debug(urlInstance);
	return urlInstance;
 	 	 
        
      }
}