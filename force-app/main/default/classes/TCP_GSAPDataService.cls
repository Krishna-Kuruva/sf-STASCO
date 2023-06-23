/*******************************************************************************************
 * Created by Madhu Javvaji on 21-Sep-22.
 * GSAPDataService apex call from SF
********************************************************************************************/


public with sharing class TCP_GSAPDataService {     
    @TestVisible private static list<CurrentOrders__x> MocklistGetCurrentOrder1 = new list<CurrentOrders__x>();
    @TestVisible private static List<OrdCnfDet__x> MocklistGetOrderConfirmation1=new List<OrdCnfDet__x>();
    @TestVisible private static List<CurrentOrdersDelivery__x> MocklistGetOrderDeliverys1=new List<CurrentOrdersDelivery__x>();
     @TestVisible private static list<Filenet__x> MocklstofFiles = new list<Filenet__x>();
    @TestVisible private static CcpOrdr__x MockOrder=new CcpOrdr__x();
    @TestVisible private static List<CcpOrdr__x> MocklstOrder1 = new List<CcpOrdr__x>();
    
    /******* TCP Place Order call *******/
    @future
    public static void  SubmitToGsap(string completeString,String orderId){
        
        CcpOrdr__x lstOrder = new CcpOrdr__x();
        try{
            if(Test.isRunningTest()){
                CcpOrdr__x lstOrder1 = new CcpOrdr__x();
                List<CcpOrdr__x> lstOrder1List = new List<CcpOrdr__x>();
                System.debug('MocklstOrder1 Check '+MocklstOrder1);
                lstOrder1List.addAll(MocklstOrder1);
                lstOrder1=MockOrder;
                lstOrder = lstOrder1;
            }
            else{
                System.debug('@@: '+completeString);
                lstOrder = Database.query(completeString);
            }
            system.debug('response form the gsap is'+ lstorder);
            if(lstOrder != null && lstOrder.Message__c != 'Order NOT Processed' && lstOrder.Msgid__c != null ){                
                TCP_OrderManagementProcessor.trackStatusGSAPOrder(orderId,true,false,lstorder.Msgid__c,false);
            }
            else if(lstOrder != null && lstOrder.Message__c == 'Order NOT Processed' && lstOrder.Msgid__c != null ){ 
                TCP_OrderManagementProcessor.trackStatusGSAPOrder(orderId,false,false,lstorder.Msgid__c,false);    
            }else{
                TCP_OrderManagementProcessor.trackStatusGSAPOrder(orderId,false,false,lstorder.Msgid__c,false);
            }
        }
        catch(ExternalObjectException e){
            system.debug('External object Exception'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
            TCP_OrderManagementProcessor.trackStatusGSAPOrder(orderId,false,false,lstorder.Msgid__c,true);
            TCP_ExceptionLogClass.insertExceptionRecord('Place order exception',e.getMessage(),'TCP_GSAPDataService','SubmitToGsap','Exception');
        }
		catch(Exception e){
            system.debug('Exception occured SubmitToGsap'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
            TCP_OrderManagementProcessor.trackStatusGSAPOrder(orderId,false,true,lstorder.Msgid__c,false);
            TCP_ExceptionLogClass.insertExceptionRecord('Place order exception',e.getMessage(),'TCP_GSAPDataService','SubmitToGsap','Exception');
        }
		       
    }
    
   /******* TCP Modify/Cancel Order call *******/ 
    @future
    public static void  SubmitToGSAPforModifyCancel(string completeString,String orderId){
        
        CcpChOrdr__x lstChOrder = new CcpChOrdr__x();
        try{
            if(Test.isRunningTest()){
                CcpChOrdr__x lstChOrder1 = new CcpChOrdr__x();
                lstChOrder1.Message__c = 'Order NOT Processed';
                lstChOrder = lstChOrder1;
            }
            else{
                System.debug('@@: '+completeString);
                lstChOrder = Database.query(completeString);
                system.debug('response form: '+ lstChOrder.Msgid__c);
            }
            system.debug('response form the gsap is'+ lstChOrder);
            if(lstChOrder != null && lstChOrder.Message__c != 'Order NOT Processed'){ 
                system.debug('response sales order: '+ lstChOrder.Msgid__c);          
                TCP_OrderManagementProcessor.trackStatusGSAPOrder(orderId,true,false,lstChOrder.Msgid__c,false);
            }else{
                TCP_OrderManagementProcessor.trackStatusGSAPOrder(orderId,false,false,lstChOrder.Msgid__c,false);
            }
           
        }
        
        catch(ExternalObjectException e){
            system.debug('External object exception modify'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
            
            TCP_OrderManagementProcessor.trackStatusGSAPOrder(orderId,false,false,lstChOrder.Msgid__c,true);
            
        }catch(Exception e){
            system.debug('Exception modify'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
            TCP_OrderManagementProcessor.trackStatusGSAPOrder(orderId,false,true,lstChOrder.Msgid__c,false);
            TCP_ExceptionLogClass.insertExceptionRecord('Modify order exception',e.getMessage(),'TCP_GSAPDataService','SubmitToGSAPforModifyCancel','Exception');
        }
        
        
    }
    
    /******* TCP Get Order Confirmation call *******/
    @future(callout=true)
    public static void  GetOrderConfirmationFromGsap(string completeString, string soldtoID,string stnsapSoldTo){
        
        OrdCnfDet__x lstGetOrderConfirmation = new OrdCnfDet__x();
        list<OrdCnfDet__x> listGetOrderConfirmation = new list<OrdCnfDet__x>();
        try{
            if(Test.isRunningTest()){
                OrdCnfDet__x lstGetOrderConfirmation1 = new OrdCnfDet__x();
                list<OrdCnfDet__x> listGetOrderConfirmation1 = new list<OrdCnfDet__x>();
                listGetOrderConfirmation1.addAll(MocklistGetOrderConfirmation1);
                lstGetOrderConfirmation = lstGetOrderConfirmation1;
                listGetOrderConfirmation = listGetOrderConfirmation1;
            }
            else{
               
                listGetOrderConfirmation = Database.query(completeString); 
                 
            }  
            
            if(listGetOrderConfirmation != null){                
                TCP_OrderManagementProcessor.updateOrderConfirmationDetails(listGetOrderConfirmation, soldtoID, stnsapSoldTo);                
            	
            } 
            
        }
        
        catch(ExternalObjectException e){
            system.debug('External object Exception order confirmation'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());            
            TCP_SAPRetry_Service.p31OrdConfirmRetry( completeString,  soldtoID, stnsapSoldTo);
            throw e;
        }catch(Exception e){
            system.debug('Exception order confirmation'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('Order confirmation service Exception',e.getMessage(),'TCP_GSAPDataService','GetOrderConfirmationFromGsap','Exception');
            throw e;
        }  
    }
    
    
    /******* TCP Get Current Orders call *******/
    @future
    public static void  GetCurrentOrdersFromGsap(string completeString, string soldtoID, string stnsapSoldTo){
       
        CurrentOrders__x lstGetCurrentOrder = new CurrentOrders__x();
        list<CurrentOrders__x> listGetCurrentOrder = new list<CurrentOrders__x>();
        try{
            if(Test.isRunningTest()){
                CurrentOrders__x lstGetCurrentOrder1 = new CurrentOrders__x();
                list<CurrentOrders__x> listGetCurrentOrder1 = new list<CurrentOrders__x>();
               
              listGetCurrentOrder1.addAll(MocklistGetCurrentOrder1);
                lstGetCurrentOrder = lstGetCurrentOrder1;
                listGetCurrentOrder = listGetCurrentOrder1;
            }
            else{
                System.debug('@@: '+completeString);
			
                listGetCurrentOrder = Database.query(completeString);                
                system.debug('response form: '+ listGetCurrentOrder);
            }  
            
            if(listGetCurrentOrder != null){                
                TCP_OrderManagementProcessor.trackCurrentOrderFromsGSAP(listGetCurrentOrder, soldtoID, stnsapSoldTo);
                
            } 
           
        }
        
        
        catch(ExternalObjectException e){
            system.debug('external object Exception occured current orders'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
		
           TCP_SAPRetry_Service.p31GoodsIssueRetry( completeString, soldtoID, stnsapSoldTo); 
		throw e;
        }
        
        catch(Exception e){
            system.debug('Exception occured current orders'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('Current order service Exception',e.getMessage(),'TCP_GSAPDataService','GetCurrentOrdersFromGsap','Exception');
            TCP_OrderManagementProcessor.trackCurrentOrderFromsGSAP(listGetCurrentOrder, soldtoID, stnsapSoldTo);
            throw e;
        }
              
    }
    
    /******* TCP File Net call *******/
    // @future
    public static List<TCP_GSAPFileWrapper>  GetListofFilesFromGsap(string completeString){
       
        Filenet__x fetchFiles  = new Filenet__x();
        list<Filenet__x> lstofFiles = new list<Filenet__x>();
        List<TCP_GSAPFileWrapper> wrapFilesList = new List<TCP_GSAPFileWrapper>();
        try{
            if(Test.isRunningTest()){
                Filenet__x fetchFiles1  = new Filenet__x();
                list<Filenet__x> lstofFiles1 = new list<Filenet__x>();
                
                fetchFiles1.Reserve__c='String';
                lstofFiles1.addAll(MocklstofFiles);
                fetchFiles = fetchFiles1;
                lstofFiles = lstofFiles1;
            }
            else{
                System.debug('@@: '+completeString);
                lstofFiles = Database.query(completeString);
                system.debug('response form: =========>'+ lstofFiles);
            }
            
            if(lstofFiles != null){                
                system.debug('response form: =========>'+ lstofFiles);
                wrapFilesList = TCP_OrderManagementProcessor.fetchFilesFromGSAP(lstofFiles);
            }
          
            
        }
        
        
        catch(ExternalObjectException e){
            system.debug('external object Exception occured get list of files'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('FileNet service external object Exception',e.getMessage(),'TCP_GSAPDataService','GetListofFilesFromGsap','Exception');
            TCP_OrderManagementProcessor.fetchFilesFromGSAP(lstofFiles);
            throw e;
        }
        
        catch(Exception e){
            system.debug('Exception occured get list of files'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('FileNet service Exception',e.getMessage(),'TCP_GSAPDataService','GetListofFilesFromGsap','Exception');
            TCP_OrderManagementProcessor.fetchFilesFromGSAP(lstofFiles);
            throw e;
        }
        return wrapFilesList;
    }

    
     /***** Get the URL and display in PDF *****************/
    //@AuraEnabled(cacheable=false)
    public static String getPDFURL(){
        string base64Response;
        try{
            String docIDFromCS=ApexPages.currentPage().getParameters().get('q');
            String fileIDFromCS=ApexPages.currentPage().getParameters().get('i');
            List<Filenet__x> fileNetDocumentList = [SELECT Outputdesc__c, Zsectyp__c, Outputtype__c, Reserve__c, Uri__c, Document__c,Filenetid__c FROM Filenet__x WHERE Document__c = : docIDFromCS];
           if(Test.isRunningTest()){
                Filenet__x fetchFilesSample  = new Filenet__x(Filenetid__c='testId',Uri__c='sampleUrl');
                
                fileNetDocumentList.add(fetchFilesSample);
               	fileIDFromCS='testId';
            }
            String docURL;
            if(fileNetDocumentList.size()>0){
                for(Filenet__x fileRec:fileNetDocumentList){
                    if(fileRec.Filenetid__c==fileIDFromCS){
            			docURL = fileRec.Uri__c;
                        system.debug('fileRec.Filenetid__c'+fileRec.Filenetid__c);
                        system.debug('fileIDFromCS'+fileIDFromCS);
                        system.debug('docURL'+docURL);
                        }
                    }
            }
            String res;
            String TCP_OpentextBackendURL = TCP_KeyValueSettings__c.getvalues('TCP_OpentextBackendURL').TCP_Value__c.trim();
            String TCP_ApigeeOpentextURL = TCP_KeyValueSettings__c.getvalues('TCP_ApigeeOpentextURL').TCP_Value__c.trim();
            res = docURL.replace(TCP_OpentextBackendURL, TCP_ApigeeOpentextURL); 
            system.debug('****res'+res);
            String RefreshAccessTocken = getAccessToken(); 
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();        
            req.setEndpoint(res);
            req.setMethod('GET');        
            req.setHeader('Authorization', 'Bearer ' +RefreshAccessTocken);        
            HttpResponse resp = http.send(req);
            system.debug('****resp'+resp);
            Blob br = resp.getBodyAsBlob();        
            base64Response = EncodingUtil.base64Encode(br);         
            system.debug('****base64Response'+base64Response);
            
        }
        catch(Exception e){
            TCP_ExceptionLogClass.insertExceptionRecord('FileNet service Exception get pdf',e.getMessage(),'TCP_GSAPDataService','getPDFURL','Exception');
        }
        
        if(string.isNotBlank(base64Response))
            return base64Response;
        else
            return null;
               
    }
    
    
	/***** get Access Token dynamically *******/
    public static String getAccessToken(){
        APIGEE_Provider__mdt accessMdt =APIGEE_Provider__mdt.getInstance('TCP_APIGEE_Access_Token');
        string accessToken = '';
  	  string payload = 'client_id=' + accessMdt.Consumer_Key__c + '&client_secret=' + accessMdt.Consumer_Secret__c +'&grant_type=client_credentials';
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('POST');
        req.setEndpoint(accessMdt.Token_URL__c);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');        
        req.setBody(payload);
        req.setTimeout(120000);
        
        Http binding = new Http();
        try{
            
            res = binding.send(req);
            
            if(res.getStatusCode() == 200){                
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {                    
                    if (parser.getText() =='access_token'){
                        parser.nextToken();
                        accessToken= parser.getText();                    
                        
                    }
                }
            }            
        }
        catch(exception e){
            system.debug('Exception in getAccessToken'+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
        }
        
        return accessToken;
    }

    /*public static String GenerateGSAPQueryString(Order OrderDetails, List<TCP_OrderLineItem__c> ordLineList,String ResentRequest, Boolean isReviewOrderReq, Boolean isModifyCancelReq){*/
    public static String GenerateGSAPQueryString(Order OrderDetails, List<TCP_OrderLineItem__c> ordLineList,String ResentRequest){
        String completeString = 'Select WebOrder__c, Ttype__c, Tdline__c, Tdformat__c, Soldto__c, Shipto__c, ShipCond__c, SalesUnit__c, ReqQty__c, ReqDate__c, PurchNoC__c, Payer__c, Msgid__c, Message__c, Material__c, ItmNumber__c, Incoterms2__c, Incoterms1__c, ExternalId, DisplayUrl, CcluserId__c, Billto__c From CcpOrdr__x where ';
        try{
            
            String shipCondition = [SELECT id, Shipping_Condition_Code__c, Shipping_Condition_Description__c from TCP_Shipping_Condition__mdt where Shipping_Condition_Description__c=:OrderDetails.Mode_of_Transport__c].Shipping_Condition_Code__c;                              
            String ItmNumber;
            String MatNumber;
            String Quantity;
            String Unit;
            String DeliveryDate;
            String ContractNo;
            String TextDataType='';
            String TextDataLine = '';
            Integer lineItemNumber = 1001;                   
            //completeString = completeString+'Soldto__c=\''+OrderDetails.Sold_To__r.GSAP_Account_Number__c+'\''+' and '+'Shipto__c=\''+OrderDetails.Ship_To__r.GSAP_Account_Number__c+'\''+' and '+'Billto__c=\''+OrderDetails.Bill_To__r.GSAP_Account_Number__c+'\''+' and '+'Payer__c=\''+OrderDetails.Payer__r.GSAP_Account_Number__c+'\''+' and '+'WebOrder__c=\''+OrderDetails.OrderNumber+'\''+' and '+'Incoterms1__c=\''+OrderDetails.Delivery_Terms__c+'\''+' and '+'PurchNoC__c=\''+OrderDetails.PoNumber+'\''+' and '+'CcluserId__c=\''+OrderDetails.CreatedBy.Name+'\''+' and '+'ShipCond__c=\''+shipCondition+'\'';
			completeString = completeString+'Soldto__c=\''+OrderDetails.TCP_GSAP_Account_Number__c+'\''+' and '+'Shipto__c=\''+OrderDetails.Ship_To__r.GSAP_Account_Number__c+'\''+' and '+'Billto__c=\''+OrderDetails.TCP_GSAP_Account_Number__c+'\''+' and '+'Payer__c=\''+OrderDetails.TCP_GSAP_Account_Number__c+'\''+' and '+'WebOrder__c=\''+OrderDetails.OrderNumber+'\''+' and '+'Incoterms1__c=\''+OrderDetails.Delivery_Terms__c+'\''+' and '+'PurchNoC__c=\''+OrderDetails.PoNumber+'\''+' and '+'CcluserId__c=\''+OrderDetails.CreatedBy.Name+'\''+' and '+'ShipCond__c=\''+shipCondition+'\'';

            // order name
            TextDataType = 'Ttype__c=\''+'0000'+'01Name\'';
            if(String.isNotBlank(OrderDetails.Name)){
                TextDataLine = 'Tdline__c=\''+'0000'+'01'+ReplaceSpecialChar(OrderDetails.Name)+'\'';
            }else{
                TextDataLine = 'Tdline__c=\''+'0000'+'01'+''+'\'';
            }

            List<String> OtherInst = new List<String>();
            integer OtherInsindex = 0;
            if(String.isNotBlank(OrderDetails.Order_Other_Instructions__c)){
                while (OtherInsindex < OrderDetails.Order_Other_Instructions__c.length()) {
                    OtherInst.add(OrderDetails.Order_Other_Instructions__c.substring(OtherInsindex, Math.min(OtherInsindex + 132,OrderDetails.Order_Other_Instructions__c.length())));
                    OtherInsindex += 132;
                }
            }

            Integer i=2;
            for(string s: OtherInst){
                s = ReplaceSpecialChar(s);
                TextDataType = TextDataType+' Or Ttype__c=\''+'00000'+i+'INST\'';
                TextDataLine = TextDataLine+' Or Tdline__c=\''+'00000'+i+s+'\'';
                i=i+1;
            }
            

            if(!ordLineList.isempty() && ordLineList.size()>0){
                for(TCP_OrderLineItem__c lineItem : ordLineList){
                    String prefix = lineItem.Sales_Order_Line_Item_No__c;
                    if(String.isBlank(ItmNumber)){
                        ItmNumber = 'ItmNumber__c =\''+prefix+'\'';
                    }else{
                        ItmNumber = ItmNumber+' Or ItmNumber__c =\''+prefix+'\'';
                    }
                    if(String.isBlank(MatNumber)){
                        MatNumber = 'Material__c =\''+doInputValidation(prefix,lineItem.Product__r.Product_Number__c)+'\'';
                    }else{
                        MatNumber = MatNumber+' Or Material__c =\''+doInputValidation(prefix,lineItem.Product__r.Product_Number__c)+'\'';
                    }
                    String finalQuan;
                    if(String.valueOf(lineItem.Quantity__c).contains('.')){
                        String[] quanArr = String.valueOf(lineItem.Quantity__c).split('\\.');
                        String decimalPart = quanArr[1].leftPad(3, '0');
                        finalQuan = quanArr[0].leftPad(5, '0') + '.' +decimalPart;
                    }
                    if(String.isBlank(Quantity)){
                        Quantity = 'ReqQty__c =\''+doInputValidation(prefix,finalQuan)+'\'';
                    }else{
                        Quantity = Quantity +' Or ReqQty__c =\''+doInputValidation(prefix,finalQuan)+'\'';
                    }
                    if(String.isBlank(Unit)){
                        Unit = 'SalesUnit__c =\''+doInputValidation(prefix,lineItem.Unit__c)+'\'';
                    }else{
                        Unit = Unit +' Or SalesUnit__c =\''+doInputValidation(prefix,lineItem.Unit__c)+'\'';
                    }
                    if(String.isBlank(DeliveryDate)){
                        DeliveryDate = 'ReqDate__c =\''+doInputValidation(prefix,String.valueOf(lineItem.Delivery_Collection_Date__c).replaceAll('-',''))+'\'';
                    }else{
                        DeliveryDate = DeliveryDate +' Or ReqDate__c =\''+doInputValidation(prefix,String.valueOf(lineItem.Delivery_Collection_Date__c).replaceAll('-',''))+'\'';
                    }
                    if(String.isBlank(ContractNo)){
                        ContractNo = 'Oicontnr__c =\''+doInputValidation(prefix,lineItem.Contract_No__c)+'\'';
                    }else{
                        ContractNo = ContractNo +' Or Oicontnr__c =\''+doInputValidation(prefix,lineItem.Contract_No__c)+'\'';
                    }

                    // order line item instructions
                    if(String.isNotBlank(lineItem.Other_Instruction__c)){
                        //String lineItmNum = String.valueOf(lineItemNumber).leftPad(6,'0');
                        String lineItmNum =String.valueOf(prefix).removeStart('00')+'01';
                        TextDataType = TextDataType+' Or Ttype__c=\''+ lineItmNum+'ITEM\'';
                        string OI =  ReplaceSpecialChar(lineItem.Other_Instruction__c);
                        TextDataLine = TextDataLine+' Or Tdline__c=\''+lineItmNum+OI+'\'';
                        //lineItemNumber += 1000;
                    }
                
                    
                }
               
                completeString = completeString+' and '+'('+ItmNumber+')'+' and '+'('+MatNumber+')'+' and '+'('+Quantity+')'+' and '+'('+Unit+')'+' and '+'('+DeliveryDate+')'+' and '+'('+ContractNo+')'+' and '+'('+TextDataType+')'+' and '+'('+TextDataLine+')';
                System.debug('Result: '+completeString);
                Order updateStatusOrder = new Order(id = OrderDetails.id,GSAP_Status__c = 'Sent');
                if(ResentRequest == 'Resent'){
                    updateStatusOrder.GSAP_Status__c = 'Resent';
                }
                update updateStatusOrder;
                SubmitToGsap(completeString, OrderDetails.Id);
                
            }
           
        }catch (Exception e) {
            system.debug('Exception---->'+e.getMessage()+';'+e.getStackTraceString() + e.getLineNumber());
            TCP_ExceptionLogClass.insertExceptionRecord('GenerateGSAPQueryString exception',e.getMessage(),'TCP_GSAPDataService','GenerateGSAPQueryString','Exception');
            return e.getMessage();
        }
        return null;
    }

    public static String doInputValidation(String prefix,String value){
        String resp;
        if(String.isNotBlank(value)){
            resp = prefix + value; 
        }else{
            resp = prefix;
        }
        return resp;
    }
    
    public static string ReplaceSpecialChar(string StrToReplace){
        string ReplacedStr;
        ReplacedStr = StrToReplace;
        ReplacedStr = string.escapeSingleQuotes(ReplacedStr);
        return ReplacedStr;
    }

    @AuraEnabled
    public static List<TCP_GSAPFileWrapper> fetchFilesFromGSAP(String salesordnum,String boldel){
        List<TCP_GSAPFileWrapper> wrapFilesList = new List<TCP_GSAPFileWrapper>();
        try {
            String salesNum=salesordnum;
			String oliBolDel=boldel;
            
            if(String.isNotBlank(salesNum)){
            String completeString = 'SELECT Id, ExternalId, DisplayUrl, Application__c, Coa__c, Document__c, Filenetid__c, Outputdesc__c, Outputtype__c, Reserve__c, Uri__c, Zsectyp__c FROM Filenet__x where ';
            
            	
                if(String.isBlank(oliBolDel)){
                    completeString = completeString+'Document__c=\''+String.escapeSingleQuotes(salesNum)+'\'';
                }
                if(String.isNotBlank(oliBolDel)){
                    completeString = completeString+'Document__c in (\''+salesNum+'\''+',\''+String.escapeSingleQuotes(oliBolDel)+'\')';
                }
            wrapFilesList = GetListofFilesFromGsap(completeString);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrapFilesList;
    }
    
    /*String formation for Modify/Cancel order */
    public static String GenerateGSAPQueryStringForModifyCancel(Order OrderDetails, List<TCP_OrderLineItem__c> ordLineList,String ResentRequest){
        System.debug('GenerateGSAPQueryStringForModifyCancel ordLineList: '+ordLineList);
        String completeString = 'Select WebOrder__c, Ttype__c, Tdline__c, Tdformat__c, Soldto__c, Shipto__c, ShipCond__c, SalesUnit__c, ReqQty__c, ReqDate__c, PurchNoC__c, Payer__c, Msgid__c, Message__c, Material__c, ItmNumber__c, Incoterms2__c, Incoterms1__c, ExternalId, DisplayUrl, CcluserId__c, Billto__c From CcpChOrdr__x where ';
        try{
            
            String shipCondition = [SELECT id, Shipping_Condition_Code__c, Shipping_Condition_Description__c from TCP_Shipping_Condition__mdt where Shipping_Condition_Description__c=:OrderDetails.Mode_of_Transport__c].Shipping_Condition_Code__c;                              
            String ItmNumber;
            String MatNumber;
            String Quantity;
            String Unit;
            String DeliveryDate;
            String ContractNo;
            String TextDataType='';
            String TextDataLine = '';
            Integer lineItemNumber = 1001;                   
            completeString = completeString+'Soldto__c=\''+OrderDetails.TCP_GSAP_Account_Number__c+'\''+' and '+'Shipto__c=\''+OrderDetails.Ship_To__r.GSAP_Account_Number__c+'\''+' and '+'Billto__c=\''+OrderDetails.TCP_GSAP_Account_Number__c+'\''+' and '+'Payer__c=\''+OrderDetails.TCP_GSAP_Account_Number__c+'\''+' and '+'WebOrder__c=\''+OrderDetails.Sales_Order_Number__c+'\''+' and '+'Incoterms1__c=\''+OrderDetails.Delivery_Terms__c+'\''+' and '+'PurchNoC__c=\''+OrderDetails.PoNumber+'\''+' and '+'CcluserId__c=\''+OrderDetails.CreatedBy.Name+'\''+' and '+'ShipCond__c=\''+shipCondition+'\'';

            // order name
            TextDataType = 'Ttype__c=\''+'0000'+'01Name\'';
            if(String.isNotBlank(OrderDetails.Name)){
                TextDataLine = 'Tdline__c=\''+'0000'+'01'+ReplaceSpecialChar(OrderDetails.Name)+'\'';
            }else{
                TextDataLine = 'Tdline__c=\''+'0000'+'01'+''+'\'';
            }
			
            // other approach for order level instructions
            List<String> OtherInst = new List<String>();
            integer OtherInsindex = 0;
            if(String.isNotBlank(OrderDetails.Order_Other_Instructions__c)){
                while (OtherInsindex < OrderDetails.Order_Other_Instructions__c.length()) {
                    OtherInst.add(OrderDetails.Order_Other_Instructions__c.substring(OtherInsindex, Math.min(OtherInsindex + 132,OrderDetails.Order_Other_Instructions__c.length())));
                    OtherInsindex += 132;
                }
            }

            Integer i=2;
            for(string s: OtherInst){
                s = ReplaceSpecialChar(s);
                TextDataType = TextDataType+' Or Ttype__c=\''+'00000'+i+'INST\'';
                TextDataLine = TextDataLine+' Or Tdline__c=\''+'00000'+i+s+'\'';
                i=i+1;
            }
            

            if(!ordLineList.isempty() && ordLineList.size()>0){
                for(TCP_OrderLineItem__c lineItem : ordLineList){
                    String prefix = lineItem.Sales_Order_Line_Item_No__c;
                    if(String.isBlank(ItmNumber)){
                        ItmNumber = 'ItmNumber__c =\''+prefix+'\'';
                    }else{
                        ItmNumber = ItmNumber+' Or ItmNumber__c =\''+prefix+'\'';
                    }
                    if(String.isBlank(MatNumber)){
                        MatNumber = 'Material__c =\''+doInputValidation(prefix,lineItem.Product__r.Product_Number__c)+'\'';
                    }else{
                        MatNumber = MatNumber+' Or Material__c =\''+doInputValidation(prefix,lineItem.Product__r.Product_Number__c)+'\'';
                    }
                    String finalQuan;
                    if(String.valueOf(lineItem.Quantity__c).contains('.')){
                        String[] quanArr = String.valueOf(lineItem.Quantity__c).split('\\.');
                        String decimalPart = quanArr[1].leftPad(3, '0');
                        finalQuan = quanArr[0].leftPad(5, '0') + '.' +decimalPart;
                    }
                    System.debug('GenerateGSAPQueryStringForModifyCancel Quantity 563: '+Quantity);
                    if(String.isBlank(Quantity)){
                        Quantity = 'ReqQty__c =\''+doInputValidation(prefix,finalQuan)+'\'';
                    }else{
                        Quantity = Quantity +' Or ReqQty__c =\''+doInputValidation(prefix,finalQuan)+'\'';
                    }
                    System.debug('GenerateGSAPQueryStringForModifyCancel Quantity 569: '+Quantity);
                    if(String.isBlank(Unit)){
                        Unit = 'SalesUnit__c =\''+doInputValidation(prefix,lineItem.Unit__c)+'\'';
                    }else{
                        Unit = Unit +' Or SalesUnit__c =\''+doInputValidation(prefix,lineItem.Unit__c)+'\'';
                    }
                    if(String.isBlank(DeliveryDate)){
                        DeliveryDate = 'ReqDate__c =\''+doInputValidation(prefix,String.valueOf(lineItem.Delivery_Collection_Date__c).replaceAll('-',''))+'\'';
                    }else{
                        DeliveryDate = DeliveryDate +' Or ReqDate__c =\''+doInputValidation(prefix,String.valueOf(lineItem.Delivery_Collection_Date__c).replaceAll('-',''))+'\'';
                    }
                    if(String.isBlank(ContractNo)){
                        ContractNo = 'Oicontnr__c =\''+doInputValidation(prefix,lineItem.Contract_No__c)+'\'';
                    }else{
                        ContractNo = ContractNo +' Or Oicontnr__c =\''+doInputValidation(prefix,lineItem.Contract_No__c)+'\'';
                    }

                    // order line item instructions
                    if(String.isNotBlank(lineItem.Other_Instruction__c)){
                        //String lineItmNum = String.valueOf(lineItemNumber).leftPad(6,'0');
                        String lineItmNum =String.valueOf(prefix).removeStart('00')+'01';
                        system.debug('***lineItmNum'+lineItmNum);
                        TextDataType = TextDataType+' Or Ttype__c=\''+ lineItmNum+'ITEM\'';
                        string OI =  ReplaceSpecialChar(lineItem.Other_Instruction__c);
                        TextDataLine = TextDataLine+' Or Tdline__c=\''+lineItmNum+OI+'\'';
                        //lineItemNumber += 1000;
                    }
                
                    
                }
               
                completeString = completeString+' and '+'('+ItmNumber+')'+' and '+'('+MatNumber+')'+' and '+'('+Quantity+')'+' and '+'('+Unit+')'+' and '+'('+DeliveryDate+')'+' and '+'('+ContractNo+')'+' and '+'('+TextDataType+')'+' and '+'('+TextDataLine+')';
            }else{
            completeString = completeString+' and '+'('+TextDataType+')'+' and '+'('+TextDataLine+')'; 
            }
            System.debug('Result: '+completeString);
            Order updateStatusOrder = new Order(id = OrderDetails.id,GSAP_Status__c = 'Sent');
            if(ResentRequest == 'Resent'){
                updateStatusOrder.GSAP_Status__c = 'Resent';
            }
            update updateStatusOrder;
            SubmitToGSAPforModifyCancel(completeString, OrderDetails.Id);
        }catch (Exception e) {
            system.debug('Exception---->'+e.getMessage()+';'+e.getStackTraceString() + e.getLineNumber());
			TCP_ExceptionLogClass.insertExceptionRecord('GenerateGSAPQueryStringForModifyCancel exception',e.getMessage(),'TCP_GSAPDataService','GenerateGSAPQueryStringForModifyCancel','Exception');  
            return e.getMessage();          
        }
        return null;
    }

    @AuraEnabled(cacheable=false)
    public static TCP_KeyValueSettings__c saveDocIdToCS(String docId){
        TCP_KeyValueSettings__c data = new TCP_KeyValueSettings__c();
        try {
            data = [SELECT id, TCP_DocID__c, TCP_ServiceName__c, TCP_Value__c from TCP_KeyValueSettings__c where TCP_ServiceName__c ='Apigee'];
            data.TCP_DocID__c = docId;
            update data;
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('GSAP Data Services exception',e.getMessage(),'TCP_GSAPDataService','saveDocIdToCS','Exception');
            
        }
        return data;
    }
    
    @future
    public static void  getDeliveryDetailsAsync(string completeString, string soldtoID, string stnsapSoldTo){
        getDeliveryDetails(completeString,soldtoID,stnsapSoldTo);
    }
    
    public static void getDeliveryDetails(string completeString, string soldtoID,string stnsapSoldTo){
        try{
            CurrentOrdersDelivery__x lstGetDelivery = new CurrentOrdersDelivery__x();
            list<CurrentOrdersDelivery__x> listGetDeliverys = new list<CurrentOrdersDelivery__x>();
            
                if(Test.isRunningTest()){
                    CurrentOrdersDelivery__x lstGetDelivery2 = new CurrentOrdersDelivery__x();
                    list<CurrentOrdersDelivery__x> listGetDeliverys1 = new list<CurrentOrdersDelivery__x>();
                    listGetDeliverys1.addAll(MocklistGetOrderDeliverys1);
                    lstGetDelivery = lstGetDelivery2;
                    listGetDeliverys = listGetDeliverys1;
                }
                else{
                   
                    listGetDeliverys = Database.query(completeString);
                    for(CurrentOrdersDelivery__x tpdl : listGetDeliverys){
                        system.debug('rec : '+tpdl);
                    }
                     
                }
            	
            if(!listGetDeliverys.isEmpty()){                
                TCP_OrderManagementProcessor.updateOrderDeliveryDetails(listGetDeliverys, soldtoID, stnsapSoldTo);
                
            } 
            
        }
        catch(Exception e){
            TCP_ExceptionLogClass.insertExceptionRecord('GSAP Data Services exception',e.getMessage(),'TCP_GSAPDataService','getDeliveryDetails','Exception');
        }
    }

}