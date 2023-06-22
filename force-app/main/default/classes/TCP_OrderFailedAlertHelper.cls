public with sharing class TCP_OrderFailedAlertHelper {
	public static void processFailedOrderList(List<sObject> scope){
        List<Order> ordList = new List<Order>();
        for(sObject objScope : scope){
                Order ord = (Order)objScope;
                if(ord.GSAP_Status__c == 'No GSAP Response' || ord.GSAP_Status__c == 'Sent Failed'){
                    ord.tcp_email_alert_sent__c = true;
                    ordList.add(ord);
                }
        }
        
        if(ordList.size()>0){
            List<String> ordStrListEast = new List<String>();
            List<String> ordStrListEur = new List<String>();
            List<String> ordStrListNA = new List<String>();
            for(Order ord: ordList){
                datetime ordDate = ord.CreatedDate;
                String ordCreatedDate = ordDate.format('dd MMM yyyy HH:MM:SS').toUpperCase();
                dateTime lastModDt = ord.LastModifiedDate;
                String lastModDate = lastModDt.format('dd MMM yyyy HH:MM:SS').toUpperCase();
                String ordString = 'WEBORDERNUMBER- '+ord.OrderNumber+', SOLDTOID- '+ord.Sold_To__r.GSAP_Account_Number__c+', SHIPTOID- '+ord.Ship_To__r.GSAP_Account_Number__c+', CREATEDBY- '+ord.CreatedBy.Name+', CREATEDDATE- '+ordCreatedDate+', STATUS- '+ord.GSAP_Status__c+', LASTMODIFIED- '+lastModDate;
                if(ord.Sold_To__r.Sales_Area__r.Sales_Region__c == 'EAST'){
                    ordStrListEast.add(ordString);
                }else if(ord.Sold_To__r.Sales_Area__r.Sales_Region__c == 'EUROPE'){
                    ordStrListEur.add(ordString);
                }else if(ord.Sold_To__r.Sales_Area__r.Sales_Region__c == 'NA'){
                    ordStrListNA.add(ordString);
                }
            }
            if(ordStrListEast.size()>0){
                sendEmail(ordStrListEast,'EAST',true);
            }
            if(ordStrListEur.size()>0){
                sendEmail(ordStrListEur,'EUROPE',true);
            }
            if(ordStrListNA.size()>0){
                sendEmail(ordStrListNA,'NA',true);
            }
			update ordList;        
        }
		
    }
    
    public static void sendEmail(List<String> ordStrList,String region, Boolean useOrgAddress) {
        try {
            String msgBody ='<pre><br></br>Failed Order Information:<br></br>';
            for(String ord : ordStrList){
                msgBody += ord+'<br></br>';
            }
            msgBody = msgBody + '</pre>';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            TCP_DistributionEmailList__c ccListBasedOnRegion = TCP_DistributionEmailList__c.getValues(region);
            if(ccListBasedOnRegion!=null){
             	List<string> toEmailList=ccListBasedOnRegion.TCP_Commops_Delivery_Lists__c.split(';'); 
                mail.setToAddresses(toEmailList);
                mail.setSubject('Order Alert - '+region);
                mail.setHtmlBody(System.label.TCP_BatchJobOrderAlertHeaderText+msgBody);
            }
           
            if(useOrgAddress){
                OrgWideEmailAddress OrgWideEmail = [Select id From OrgWideEmailAddress o where o.DisplayName =:Label.TCP_From_Email_Address Limit 1];
          	  	mail.setOrgWideEmailAddressId(OrgWideEmail.Id);
            }
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		 	mails.add(mail);
            if(!mails.isempty()){
                Messaging.sendEmail(mails);
            }
        }
        catch(Exception excptn) {
            TCP_ExceptionLogClass.insertExceptionRecord('TCP Failed Order Alert',excptn.getMessage(),'TCP_OrderFailedAlertHelper','sendEmail','Exception');
            throw excptn;
        }
    }
}