({
    doInit : function(component, event, helper) {
        // Get the empApi component
        const empApi = component.find('empApi');
        // Uncomment below line to enable debug logging (optional)
        //empApi.setDebugFlag(true);
        // Register error listener and pass in the error handler function
        empApi.onError($A.getCallback(error => {
            // Error can be any type of error (subscribe, unsubscribe...)
            console.error('EMP API error: ', error);
        }));
		helper.subscribe(component,event,helper);
            
        component.set('v.sourceSteerLstColumnsLst', [
            {label: 'Plant Name', fieldName: 'Plant_Name__c', type: 'Text',sortable:true},
            {label: 'Plant Code', fieldName: 'Plant_Code__c', type: 'Text',sortable:true},
            {label: 'Product Sub Group', fieldName: 'Product_Sub_Group__c', type: 'Text',sortable:true},
            {label: 'Scenario', fieldName: 'Scenario__c', type: 'Text',sortable:true},
            {label: 'Scenario Value', fieldName: 'Scenario_Value__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '2' }},
            {label: 'Manual Adjustment', fieldName: 'Manual_Adjustment__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '2' }},
            {label: 'Source Steer', fieldName: 'Source_Steer__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '2' }},
        ]);
        // added additional fields below to display under Depot Steer section_Dharam_1st_June_PBI811125(400)
        component.set('v.depotSteerLstColumnsLst', [
            {label: 'Plant Name', fieldName: 'Plant_Name__c', type: 'Text',sortable:true},
            {label: 'Plant Code', fieldName: 'Plant_Code__c', type: 'Text',sortable:true},
            {label: 'Product Sub Group', fieldName: 'Product_Sub_Group__c', type: 'Text',sortable:true},
            {label: 'MOT', fieldName: 'MOT__c', type: 'Text',sortable:true},
            {label: 'Depot Steer', fieldName: 'Depot_Steer__c', type: 'number',sortable:true,typeAttributes: { maximumFractionDigits: '2' }},
            {label: 'Valid From', fieldName: 'Valid_From__c', type: 'Text',sortable:true},
            {label: 'Valid To', fieldName: 'Valid_To__c', type: 'Text',sortable:true},
            {label: '% of Steer in prompt window', fieldName: 'Rv_prompt_window_percent__c', type: 'Text',sortable:true},
        ]);
       
        helper.getAllLocationSteer(component, event, helper);
        
          component.set("v.items", [
            { expanded: false, title: "Row 1" },
            { expanded: false, title: "Row 2" },
            { expanded: false, title: "Row 3" }
        ]);
    },
    
    toggle: function(component, event, helper) {
        var items = component.get("v.items"), index = event.getSource().get("v.value");
        console.log('index'+index);
        items[index].expanded = !items[index].expanded;
        component.set("v.items", items);
    },
    toggle123: function(component, event, helper) {
         var items = component.get("v.dailyBSPTrendMap"), index = event.getSource().get("v.value");
        console.log('index'+JSON.stringify(index.split(";")[0]));
        console.log('index'+JSON.stringify(index.split(";")[1]));
        console.log('index'+JSON.stringify(index.split(";")[2]));
        var value = index.split(";")[0];
         console.log('index'+JSON.stringify(items[0]));
        for(var key in items ){
            if(items[key].key === value){//Plant Code(A002)
                var insideVal = items[key].value;
                for(var key in insideVal){
                    console.log('index Plant Code'+JSON.stringify(insideVal[key]));
                    var insideValue = insideVal[key];
                    console.log('index insideValue'+JSON.stringify(insideValue.value.backBoneLst));
                    console.log('index insideValue is Expand'+JSON.stringify(insideValue.value.isExpand));
                    if(insideValue.key === index.split(";")[2]){
              
                            if(insideValue.value.isExpand === true){
                                insideValue.value.isExpand = false;
                            }
                            else if(insideValue.value.isExpand === false){
                                insideValue.value.isExpand = true;
                            }
                  
                        console.log('insideValue.value'+JSON.stringify(insideValue.value.isExpand));
                    }
                }
            }
        }
        //items[index].isExpand = !items[index].isExpand;
        console.log('items[index].isExpand'+JSON.stringify(items));
        component.set("v.dailyBSPTrendMap", items);
    },
    getOverriddenPlants :function(component, event, helper) {
        helper.getSelectedDepotSteer(component, event, helper);
    },
    
    handleClick: function(component, event, helper) {
        helper.getAllLocationSteer(component, event, helper);
    },
    getSelGrdSteer : function(component, event, helper) {
        helper.getSourceSteer(component, event, helper);
        helper.getSelectedDepotSteer(component, event, helper); 
        //addition done to update Depot Steer records based on selection for Source Steer
        //Dharam_1st_June_PBI811125(400)
    },
    getSelGrdDepotSteer: function(component, event, helper) {
        helper.getSelectedDepotSteer(component, event, helper);
        helper.getSourceSteer(component, event, helper);
        //addition done to update Depot Steer records based on selection for Source Steer
        //Dharam_1st_June_PBI811125(400)
    },
    getSelGrdFinalSteer: function(component, event, helper) {
        helper.getSelectedFinalSteer(component, event, helper);
    },
    updateColumnSorting: function(component, event, helper) {
    },
     calculateWidth : function(component, event, helper) {
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            console.log('final tag Name'+parObj.tagName);
            var mouseStart=event.clientX;
            component.set("v.mouseStart",mouseStart);
            component.set("v.oldWidth",parObj.offsetWidth);
    },
    setNewWidth : function(component, event, helper) {
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            var mouseStart = component.get("v.mouseStart");
            var oldWidth = component.get("v.oldWidth");
            var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
            parObj.style.width = newWidth+'px';
    }
})