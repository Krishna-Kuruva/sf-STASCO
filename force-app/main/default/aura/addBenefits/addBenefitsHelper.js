({
	 createObjectData: function(component, event) {        
        var RowItemList = component.get("v.benefitByYearList");
        RowItemList.push({
            'sobjectType': 'Benefit_By_Year__c',
            'Benefit_Amount__c': '',
            'Year__c': ''
        });
        // set the updated list to attribute  again    
        component.set("v.benefitByYearList", RowItemList);
    },
    
    getL1PickList : function(component,event,helper,urlRecordTypeId){
        var actionType =component.get("c.getL1Type"); 
        if(urlRecordTypeId==undefined || urlRecordTypeId=='' || urlRecordTypeId== null){
            actionType.setParams({
                "recordTypeId" : null,
            });
        }
        else{
            actionType.setParams({
                "recordTypeId" : urlRecordTypeId,
            });
            actionType.setCallback(this, function(response) {
                var state = response.getState();
                if (response.getState() == "SUCCESS") {
                      var picklistMap = response.getReturnValue();
                        var picklist = [];
                        
                        for(var key in picklistMap){
                            picklist.push({label:picklistMap[key], value:key});
                        }
                        // set current user information on userInfo attribute
                        component.set("v.L1", picklist);
                    	if(component.get('v.benefits.L1_Type__c')!=undefined){
        					var selectedVal = component.get('v.benefits.L1_Type__c');
                            if(selectedVal!=undefined)
            					component.find("L1Type").set("v.value",selectedVal );
        				}
                     	
                }
        })
        $A.enqueueAction(actionType);
        }
        
    },
    
    getImpactedPickListValues : function(component,event,helper){
         var actionTypeUnit =component.get("c.getImpactedUnit");        
        
        actionTypeUnit.setCallback(this, function(response) {
                var state = response.getState();
                if (response.getState() == "SUCCESS") {
                      var picklistMap = response.getReturnValue();
                      var picklist = [];
                       for(var key in picklistMap){
                            picklist.push({label:picklistMap[key], value:key});
                       }
                        // set current user information on userInfo attribute
                       component.set("v.ImpactedUnit", picklist);
                }
        })
         $A.enqueueAction(actionTypeUnit);
    },
    
    getLoadedData : function(component,event,helper){        
        var recordId=component.get("v.recordId");  
        var loadData = component.get("c.getDataMap");
        
        if(recordId==undefined || recordId=='' || recordId== null){
            component.set("v.readOnly",false);
            loadData.setParams({
                "recordId" : null,
            });
        }
        else{
            component.set("v.readOnly",true);
            loadData.setParams({
                "recordId" : recordId,
            });
        }
        loadData.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                console.log("returnvalue",response.getReturnValue()); 
                //if (component.get("v.readOnly")){
                    if( response.getReturnValue().parentRecord!=undefined){
                    	component.set("v.benefits", response.getReturnValue().parentRecord[0]);
                        if(component.get('v.benefits.L1_Type__c')!=undefined){
        					var selectedVal = component.get('v.benefits.L1_Type__c');
                            if(selectedVal!=undefined  && component.find("L1Type")!=null && component.find("L1Type")!=undefined)
            					component.find("L1Type").set("v.value",selectedVal );
        				}
                        this.getL1PickList(component,event,helper,response.getReturnValue().parentRecord[0].RecordTypeId);
                        
                        if(component.get('v.benefits.Impacted_Unit__c')!=undefined){
        					var selectedUnit = component.get('v.benefits.Impacted_Unit__c');
                            if(selectedUnit!=undefined)
            					component.find("ImpactedUnit").set("v.value",selectedUnit );
        				}
                        this.getImpactedPickListValues(component,event,helper);
                       
                    }
                    if(response.getReturnValue().ChildRecords !=undefined && JSON.parse(response.getReturnValue().ChildRecords).length > 0){
                    	component.set("v.benefitByYearList", JSON.parse(response.getReturnValue().ChildRecords));
                    }
               // }
            }
        })
        $A.enqueueAction(loadData);
    },
    validateRequired: function(component, event) {
        var isValid = true;
        var allRows = component.get("v.benefitByYearList");
        for (var indexVar = 0; indexVar < allRows.length; indexVar++) {
            if(allRows[indexVar].Benefit_Amount__c == '' && allRows[indexVar].Year__c == ''){
            	isValid = false;   
            }
            else if (allRows[indexVar].Benefit_Amount__c == '') {
                isValid = false;
            }           
            else if(allRows[indexVar].Year__c == ''){
                isValid = false;    
            }
         }
        var compEvents =  $A.get("e.c:AddErrorEvent");
        if(!isValid){
          	compEvents.setParams({ "message" : "Add Error" });
			compEvents.fire();
		}
     
        else {
           compEvents.setParams({ "message" : "Remove Error" });
			compEvents.fire();
        }
        return isValid;
    },
     
     
})