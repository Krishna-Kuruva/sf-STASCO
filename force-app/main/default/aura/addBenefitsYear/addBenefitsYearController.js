({
    doInit : function(component, event, helper) {
        
       
    	var action =component.get("c.getYear");  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (response.getState() == "SUCCESS") {
                  var picklistMap = response.getReturnValue();
                  var picklist = [];
                   for(var key in picklistMap){
                        picklist.push({label:picklistMap[key], value:key});
                   }
                   component.set("v.Year", picklist);
                    if(component.get('v.benefitByYear.Year__c')!=undefined){
                        var selectedYear = component.get('v.benefitByYear.Year__c');
                        if(selectedYear!=undefined)
                        	component.find("Year").set("v.value",selectedYear );
                    }
            }
        })
        
       $A.enqueueAction(action);
    },
   
    AddNewRow : function(component, event, helper){
      if(component.get("v.readOnly")==false) {
      	component.getEvent("AddRowEvt").fire();   
      }
    },
    
    removeRow : function(component, event, helper){
     // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
      if(component.get("v.readOnly")==false) {
      		component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
      }
    }, 
    
    changeYear:function(component,event,helper){
         var selectCmp = event.getSource().get("v.value");  
    },
    checkIfNotNumber : function(component, event, helper) {
        if(isNaN(component.get("v.benefitByYear.Benefit_Amount__c"))){
            component.set("v.benefitByYear.Benefit_Amount__c","");
        }
    },
    
    handleErrorNotifications: function(component, event, helper) {
 		var name =event.getParam("message");// getting the value of event attribute
        if (name == 'Add Error'){
           var inputCmp = component.find("Amount");
        	var value = inputCmp.get("v.value");
            
            var inputYear=component.find("Year");
            var yVal=inputYear.get("v.value");

            // Is input numeric?
            if (value == '') {
               inputCmp.showHelpMessageIfInvalid();
            } 
            
            if(yVal=='' || yVal=='None'){
                inputYear.showHelpMessageIfInvalid(); 
                inputYear.focus();
            }
        }
       
	}
     
})