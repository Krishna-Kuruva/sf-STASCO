/*******************************************************************************************************************
*******************************************************************************************************************/
@RestResource(urlMapping='/CPIOrderHandler/*')
global with sharing class TCP_P31_CPI_orderHandler {
        
    @HttpPost
    global static void processOrderData() {
        try{
            // Access the request body
            String requestBody = RestContext.request.requestBody.toString();
            // Parse the JSON payload
            Map<String, Object> parsedPayload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            // Extract the list of items
            map<string,list<Object>> dataByWeborderNo = new map<string,list<Object>>();
            // Check if 'row' is a single object or an array
            if (parsedPayload.get('row') instanceof List<Object>) {
                // 'row' is an array
                system.debug('in array');
                List<Object> rowItems = (List<Object>) parsedPayload.get('row');
                for (Object rowItem : rowItems) {
                    Map<String, Object> itemMap = (Map<String, Object>) rowItem;
                    String itemSONo = (String) itemMap.get('SalesOrderNumber');
                    String portal = (String) itemMap.get('PortalType');
                    system.debug(' itemSONo : '+itemSONo);
                    if(string.isNotBlank(itemSONo) && string.isNotBlank(portal) && portal == 'TCP'){
                        
                        if(dataByWeborderNo.containskey(itemSONo)){
                            dataByWeborderNo.get(itemSONo).add(rowItem);
                        }
                        else{
                            dataByWeborderNo.put(itemSONo,new list<object>{rowItem});
                        }
                    }
                    
                }
            } else if (parsedPayload.get('row') instanceof Map<String, Object>) {
                // 'row' is a single object
                system.debug('in single object');
                Map<String, Object> row = (Map<String, Object>) parsedPayload.get('row');
                String itemSONo = (String) row.get('SalesOrderNumber');
                String portal = (String) row.get('PortalType');
                // Process the single row object
                if(string.isNotBlank(itemSONo)  && string.isNotBlank(portal) && portal == 'TCP')
                    dataByWeborderNo.put(itemSONo,new list<object>{row});
            }
            
            system.debug('dataByWeborderNo '+dataByWeborderNo);
            
            //get orders data
            if(!dataByWeborderNo.isEmpty()){
                list<TCP_OrderLineItem__c> OrderLineItemList = [select id,New_loading_date__c,New_SO__c,New_so_line_item_no__c,New_Order_type__c,Return_Loading_Date__c,Return_Order_type__c,Return_order__c,Return_SO_line_item_no__c,Sales_Order_Line_Item_No__c,Order__r.Sales_Order_Number__c FROM TCP_OrderLineItem__c where Order__r.Sales_Order_Number__c IN:dataByWeborderNo.keyset() ];
                
                if(!OrderLineItemList.isEmpty()){
                    list<TCP_OrderLineItem__c> updateLineitemsList = new list<TCP_OrderLineItem__c>();
                    for(TCP_OrderLineItem__c tempLi : OrderLineItemList){
                        list<object> templist = dataByWeborderNo.get(tempLi.Order__r.Sales_Order_Number__c);
                        
                        for(object tempObj : templist){
                            Map<String, Object> itemMap = (Map<String, Object>) tempObj;
                            string itemNo = (string) itemMap.get('SalesOrderLineItemNo');
                            string ordertype = (string) itemMap.get('Ordertype');
                            system.debug('itemNo '+itemNo);
                            system.debug('tempLi.Sales_Order_Line_Item_No__c '+tempLi.Sales_Order_Line_Item_No__c);
                            if(itemNo == tempLi.Sales_Order_Line_Item_No__c){
                                if(ordertype == 'ZRET' || ordertype == 'ZRRD'){
                                    tempLi.Return_SO_line_item_no__c = (string) itemMap.get('NewSOlineitemno');
                                    tempLi.Return_order__c = (string) itemMap.get('NewSONumber');
                                    tempLi.Return_Order_type__c = (string) itemMap.get('Ordertype');
                                    tempLi.Return_Loading_Date__c = date.valueOf(((string) itemMap.get('Newloadingdate'))) ;
                                    updateLineitemsList.add(tempLi);
                                }
                                else if(ordertype == 'ZNOR' || ordertype == 'ZFOR'){
                                    tempLi.New_SO__c = (string) itemMap.get('NewSONumber'); 
                                    tempLi.New_so_line_item_no__c = (string) itemMap.get('NewSOlineitemno');
                                    tempLi.New_Order_type__c = (string) itemMap.get('Ordertype');
                                    tempLi.New_loading_date__c = date.valueOf(((string) itemMap.get('Newloadingdate'))) ;
                                    updateLineitemsList.add(tempLi);
                                }
                                break;
                            }
                        }//for2 ends
                        
                        
                    }//for1 ends
                    system.debug('updateLineitemsList '+updateLineitemsList);
                    if(!updateLineitemsList.isEmpty()){
                        list<Database.SaveResult> result = Database.update(updateLineitemsList, false);
                        // Iterate through each returned result
                        Boolean isAllSuccess = true;
                        for (Database.SaveResult sr : result) {
                            if (!sr.isSuccess()) {
                                isAllSuccess = false;
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    
                                    TCP_ExceptionLogClass.insertExceptionRecord('P31 CPI - Exception while updating records in SF',err.getMessage() ,'TCP_P31_CPI_orderHandler','processOrderData','Exception');

                                }
                            }
                            
                        }
                        
                        if(isAllSuccess){
                            // Return a response
                            RestContext.response.statusCode = 201; // HTTP 201 Created
                            RestContext.response.responseBody = Blob.valueOf(Label.TCP_CPI_Success);
                        }
                        else{
                            // Return a response
                            RestContext.response.statusCode = 201; // HTTP 201 Created
                            RestContext.response.responseBody = Blob.valueOf(Label.TCP_CPI_SF_side_issue);
                            TCP_ExceptionLogClass.insertExceptionRecord('TCP P31 CPI Exception',requestBody ,'TCP_P31_CPI_orderHandler','processOrderData','Exception');

                        }
                        
                    }
                }//if 2 ends
                else{
                    // Return a response
                    RestContext.response.statusCode = 500; // HTTP 201 Created
                    RestContext.response.responseBody = Blob.valueOf(Label.TCP_CPI_SO_not_found);
                }
                                                                                        
            }//if 1 ends
            else{
                // Return a response
                RestContext.response.statusCode = 500; // HTTP 201 Created
                RestContext.response.responseBody = Blob.valueOf(Label.TCP_CPI_request_issue+requestBody);
                TCP_ExceptionLogClass.insertExceptionRecord('TCP P31 CPI Bad request body',requestBody ,'TCP_P31_CPI_orderHandler','processOrderData','Exception');
            }
            
            
            
        }
        catch(Exception ex){
            // Handle exceptions and return an error response
            
            // Log the exception (optional)
            System.debug('Exception occurred: ' + ex.getMessage());
            // Handle the exception and provide an error response
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 500; // Internal Server Error

            // Create a custom error object with relevant information
            Map<String, Object> errorResponse = new Map<String, Object>();
            errorResponse.put('errorCode', 'ERROR_CODE');
            errorResponse.put('errorMessage', ex.getMessage());

            // Serialize the error object and send it as the response body
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            
            TCP_ExceptionLogClass.insertExceptionRecord('P31 CPI Exception',ex.getMessage(),'TCP_P31_CPI_orderHandler','processOrderData','Exception');
        }
        
    }
    
    
}