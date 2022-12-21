({
    init: function (component, event, helper) {
        document.title='Sales Hedge';
        
        // Get the empApi component
        const empApi = component.find('empApi');
        // Uncomment below line to enable debug logging (optional)
        //empApi.setDebugFlag(true);
        // Register error listener and pass in the error handler function
        empApi.onError($A.getCallback(error => {
            // Error can be any type of error (subscribe, unsubscribe...)
            console.error('EMP API error: ', error);
        }));
            
         const newEmpApi = component.find('newEmpApi');
         //newEmpApi.setDebugFlag(true);
        // Register error listener and pass in the error handler function
        newEmpApi.onError($A.getCallback(error => {
            // Error can be any type of error (subscribe, unsubscribe...)
            console.error('New EMP API error: ', error);
        }));
            helper.subscribe(component,event,helper);
            helper.subscribeToMasters(component,event,helper);
            
        component.set('v.salesHedgecolumnsLs', [
            {label: 'Product Name', fieldName: 'Product_Name__c', type: 'text',sortable:true},
            {label: 'Time Stamp', fieldName: 'Time_Stamp__c', type: 'Text',sortable:true},
            {label: 'Transactions', fieldName: 'Transactions__c', type: 'Text',sortable:true},
            {label: 'Mass(CBM)', fieldName: 'Mass_CBM__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '3' }},
            {label: 'Mass(MT)', fieldName: 'Mass_MT__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '3' }},
            
            {label: 'Hedge(Lots)', fieldName: 'Hedge__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '4' }},
            {label: 'Exposure Factor(Lots)', fieldName: 'Exposure_Factor__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '3' }}
        ]);
         helper.getData(component,event,helper);
        
        component.set('v.TotalExposurecolumnsLs', [
            {label: 'Product Name', fieldName: 'Name', type: 'text',sortable:true},
            {label: 'Xposr CBM', fieldName: 'Total_Exposure_Factor_CBM__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '3' }},
            {label: 'Xposr Tonne', fieldName: 'Total_Exposure_Factor_MT__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '3' }},
            {label: 'Hedge(Lots)', fieldName: 'Hedged__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '3' }},
            {label: 'Open Xposr (LOTS)', fieldName: 'Final_Exposure_Factor__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '3' }},
            
        ]);
       
        helper.getDataMaster(component,event,helper);
       
        var optss = [{value: "Please Select", label: "Please Select"}, 
                     {value: "Sales", label: "Sales"},
                     {value: "Hedge", label: "Hedge"}];
        component.set("v.filterValueTransaction", optss);
        
        //checkEditAccess
        //AdditionalFix_166256_29Apr2019_Soumyajit starts
        var hasEditAccessAction = component.get('c.checkEditAccess');
        hasEditAccessAction.setCallback(component,function(response) 
        {
        	var state = response.getState();
             if (state === 'SUCCESS')
             {
             	if(hasEditAccessAction.getReturnValue() === false)
                {
                    component.set("v.disableSubmit",true);

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                            "title": "Warning!",
                            "type": "Warning",
                            "message": "You do not have permission for Manual Hedging!"
                        });
                    toastEvent.fire();
                }
              }
         });
         
        $A.enqueueAction(hasEditAccessAction);
        //AdditionalFix_166256_29Apr2019_Soumyajit ends
    },
    
     
                    
    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortedByMaster", fieldName);
        component.set("v.sortDirectionMaster", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
     // Client-side controller called by the onsort event handler
    updateColumnSortingChildObj: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        //alert(fieldName);
        var sortDirection = event.getParam("sortDirection");
         // alert(sortDirection);
        component.set("v.sortedBy", fieldName);
        component.set("v.sortDirection", sortDirection);
        helper.sortDataSalesHedge(component, fieldName, sortDirection);
    },
    insertManualHedge: function (component, event, helper) {
          var inputCmp = component.find("hedgeEntry");
          var hedgeEntry = inputCmp.get("v.value");
          var masterProdct = component.find("masterProduct");
          var prodct = masterProdct.get("v.value");
          if(typeof hedgeEntry == 'undefined'){
               inputCmp.set("v.errors", [{message:"Please enter hedge entry: "}]);
          }else if (isNaN(hedgeEntry)) {
            inputCmp.set("v.errors", [{message:"Input not a number: " + hedgeEntry}]);
        }else{
         var action = component.get('c.insertManualEntry');
         action.setParams({ productName : component.get("v.masterProductName") ,
                           hedgeEntry : component.get("v.hedgeEntry") });
            
            action.setCallback(component,function(response) {
                    var state = response.getState();
                    if (state === 'SUCCESS'){
                        helper.getData(component,event,helper);
                        helper.LastSync(component,event,helper);
                        component.set("v.masterProductName",'Please Select');
                        component.set("v.hedgeEntry",'');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": "success",
                            "message": "The record has been created successfully."
                        });
                        toastEvent.fire();
                        
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": "Please select Product Name"
                        });
                        toastEvent.fire();
                    }
                }
            );
          
            $A.enqueueAction(action);
          }
    },
    onchangeProduct: function (component, event, helper) {
       var totalExpo = component.get('v.salesHedgeLstTemp');
       var productType =  component.get("v.productType");
       var selectedTransaction =  component.get("v.selectedTransaction");
       //alert(selectedTransaction);
       //alert(productType);
       var selectioption = [];
       var selectioptionAll = [];
        var selectioption1 = [];
        var selectioption2 = [];
       var selectioptionnull = [];
        if(totalExpo.length > 0){
           for(var i=0;i<totalExpo.length;i++){
               if(productType == totalExpo[i].Product_Name__c && selectedTransaction == totalExpo[i].Transactions__c){
               		selectioption.push(totalExpo[i]); 
               }else if((productType === "" ||productType === "Please Select") && selectedTransaction == totalExpo[i].Transactions__c){
                    selectioption1.push(totalExpo[i]); 
               }else if(productType == totalExpo[i].Product_Name__c && (selectedTransaction === "Please Select" || selectedTransaction === "")){
                    selectioption2.push(totalExpo[i]); 
               }else if((productType === "" ||productType === "Please Select") && (selectedTransaction === "Please Select" || selectedTransaction === "")){
                    selectioptionAll.push(totalExpo[i]); 
               }
           }
             //alert(selectioption);
             //alert(selectioption);
    	}
        //alert(selectioption1);
        if(selectioption.length > 0){
            component.set('v.salesHedgeLst', selectioption);
        }
        else if(selectioption1.length > 0){
            component.set('v.salesHedgeLst', selectioption1);
        }
        else if(selectioption2.length > 0){
            component.set('v.salesHedgeLst', selectioption2);
        }
        else if(selectioptionAll.length > 0){
             component.set('v.salesHedgeLst', selectioptionAll);
        }else{
            component.set('v.salesHedgeLst', selectioptionnull);
        }
       }
          
})