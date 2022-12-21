({
    subscribe : function(component, event, helper) {
        // Get the empApi component
        const empApi = component.find('empApi');
        // Get the channel from the input box
        const channel = component.get('v.channel');
        // Replay option to get new events
        const replayId = -1;
 
        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ',JSON.stringify(eventReceived));
            console.log('Received event ',JSON.stringify(eventReceived.data.payload.Origination_Steer_Type__c));
            helper.getAllLocationSteerPlatform(component, event, helper,eventReceived.data.payload,
            								   eventReceived.data.payload.Steer_Value_mt__c,
            								   eventReceived.data.payload.Origination_Steer_Type__c);
        }))
        .then(subscription => {
            // Confirm that we have subscribed to the event channel.
            // We haven't received an event yet.
            console.log('Subscribed to channel ', subscription.channel);
             helper.LastSync(component,event,helper);
            // Save subscription to unsubscribe later
            component.set('v.subscription', subscription);
        });
    },
            
    // Invokes the unsubscribe method on the empApi component
    unsubscribe : function(component, event, helper) {
        // Get the empApi component
         const empApi = component.find('empApi');
         // Get the subscription that we saved when subscribing
          const subscription = component.get('v.subscription');
                
         // Unsubscribe from event
          empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
           // Confirm that we have unsubscribed from the event channel
          console.log('Unsubscribed from channel '+ unsubscribed.subscription);
          component.set('v.subscription', null);
          }));
                
    },
              
    LastSync : function(component,event,helper){      
        var currentdate = new Date(); 
        var datetime = "Last Sync: " + currentdate.getDate() + "/"
                + (currentdate.getMonth()+1)  + "/" 
                + currentdate.getFullYear() + "  "  
                + currentdate.getHours() + ":"  
                + currentdate.getMinutes() + ":" 
                + currentdate.getSeconds();
         component.set('v.MasterTableSync', datetime);
    },
              
    getAllLocationSteerPlatform : function(component,event,helper,steerValue,originationSteerValue,originationSteerType){
        console.log('----RecordId__c-----'+JSON.stringify(steerValue.RecordId__c));
        if(originationSteerType !== null ){
            var orgSteerLst = component.get("v.orgSteerLst");
            if(orgSteerLst != undefined && orgSteerLst.length >0){
                       console.log('----orgSteerLst-----'+JSON.stringify(orgSteerLst.length));
                        for(var i=0;i<orgSteerLst.length;i++){
                            if(orgSteerLst[i].Origination_Steer_Type__c=='ARA AGO Steer' &&
                               originationSteerType == 'ARA AGO Steer'){
                              component.set("v.ARAAGOSteer",originationSteerValue);  
                            }
                            else if(orgSteerLst[i].Origination_Steer_Type__c=='ARA IGO Steer' &&
                              originationSteerType == 'ARA IGO Steer'){
                              component.set("v.ARAIGOSteer",originationSteerValue);  
                            }else if(orgSteerLst[i].Origination_Steer_Type__c=='Harburg AGO steer' &&
                                    originationSteerType == 'Harburg AGO steer'){
                              component.set("v.HarburgAGOsteer",originationSteerValue);  
                            }
                            else if(orgSteerLst[i].Origination_Steer_Type__c=='ARA MOGAS Steer' &&
                                    originationSteerType == 'ARA MOGAS Steer'){
                              component.set("v.ARAMOGASSteer",originationSteerValue);  
                            }
                            else if(orgSteerLst[i].Origination_Steer_Type__c=='Harburg IGO steer' &&
                                    originationSteerType == 'Harburg IGO steer'){
                              component.set("v.HarburgIGOsteer",originationSteerValue);  
                            }       
                        }
            
            }
            else{
                 component.set('v.orgSteerLst',[]); 
            }
        }else if(steerValue.RecordId__c != null){
            console.log('----RecordId_ inside-----'+JSON.stringify(steerValue.RecordId__c));
            /*var depotSteerLst = component.get("v.depotSteerLst");
            for(var i=0;i<depotSteerLst.length;i++){
            }*/
            helper.getAllLocationSteer(component, event, helper);
        }
    } ,      
	
    getAllLocationSteer : function(component, event, helper) {
        helper.startSpinner(component, event, helper);
        var action = component.get("c.getLocationSteer");
        action.setParams({
            "srcStrGrade": component.get("v.gradeSel"),
            "depStrGrade": component.get("v.gradeSelDepot"),
            "depMot":component.get("v.motSel"),
            "depPlant": component.get("v.selPlant"),
            "plantOverriden" :component.get("v.showOverriddenPlants"),
            "contractDate" :component.get("v.contractStartDate")
       });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                //Source Steer 
                var srcSteerLst=response.getReturnValue().srcStrLst;
                  if(srcSteerLst != undefined && srcSteerLst.length >0){
                    component.set("v.sourceSteerLst",srcSteerLst);
                  }
                else{
                    component.set('v.sourceSteerLst',[]); 
                  }
				//Depot Steer
				var depSteerLst=response.getReturnValue().depotStrLst;
                if(depSteerLst != undefined && depSteerLst.length >0){
                    component.set("v.depotSteerLst",depSteerLst);
                  }
                else{
                    component.set('v.depotSteerLst',[]); 
                  }
               //Origination Steer 
                  var orgSteerLst=response.getReturnValue().orgStrLst;
                if(orgSteerLst != undefined && orgSteerLst.length >0){
                    component.set("v.orgSteerLst",orgSteerLst);
                    for(var i=0;i<orgSteerLst.length;i++){
                        if(orgSteerLst[i].Origination_Steer_Type__c=='ARA AGO Steer'){
                          component.set("v.ARAAGOSteer",orgSteerLst[i].Steer_Value__c);  
                        }
                        else if(orgSteerLst[i].Origination_Steer_Type__c=='ARA IGO Steer'){
                          component.set("v.ARAIGOSteer",orgSteerLst[i].Steer_Value__c);  
                        }else if(orgSteerLst[i].Origination_Steer_Type__c=='Harburg AGO steer'){
                          component.set("v.HarburgAGOsteer",orgSteerLst[i].Steer_Value__c);  
                        }
                        else if(orgSteerLst[i].Origination_Steer_Type__c=='ARA MOGAS Steer'){
                          component.set("v.ARAMOGASSteer",orgSteerLst[i].Steer_Value__c);  
                        }
                        else if(orgSteerLst[i].Origination_Steer_Type__c=='Harburg IGO steer'){
                          component.set("v.HarburgIGOsteer",orgSteerLst[i].Steer_Value__c);  
                        }       
                    }
                  }
                else{
                    component.set('v.orgSteerLst',[]); 
                  }
                //Set Conract Start Date
                var todaysdate=response.getReturnValue().todaysDate;
                component.set("v.contractStartDate",todaysdate);
              // PlantList  
                 var plantList=response.getReturnValue().depotLst;
                if(plantList != undefined && plantList.length >0){
                    component.set("v.plantList",plantList);
                    component.set("v.finalSteerplantList",plantList);
                  }
                else{
                    component.set('v.plantList',[]); 
                  }
                
             }
            else{
                component.set('v.sourceSteerLst',[]); 
             }
            var dailyBSPTrend = response.getReturnValue().backBoneMap;
            console.log('----------'+JSON.stringify(dailyBSPTrend));
            var arrayMapKeys = [];
            for(var key in dailyBSPTrend){
                     //console.log('----------'+JSON.stringify(dailyBSPTrend[key]));
                	var insidearrayMapKeys = [];
                    var displayInside = dailyBSPTrend[key];
                	for(var insideKey in displayInside){
                        
                        insidearrayMapKeys.push({key: insideKey, value: displayInside[insideKey]});
                	}
                	//console.log('-----insidearrayMapKeys-----'+JSON.stringify(insidearrayMapKeys));
                    arrayMapKeys.push({key: key, value: insidearrayMapKeys});
            }
            component.set("v.dailyBSPTrendMap",arrayMapKeys);
            if(arrayMapKeys.length > 0){
                component.set("v.renderFinalSteer",true);
            }else{
                component.set("v.renderFinalSteer",false);
            }
            //console.log('----------'+JSON.stringify(component.get("v.dailyBSPTrendMap")));
         helper.endSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    getSourceSteer : function(component, event, helper) {
        helper.startSpinner(component, event, helper);
		var grade= component.get("v.gradeSel");
        var action = component.get("c.getSourceSteer");
        component.set('v.gradeSelDepot', grade);    
        //added to change depot steer based on Source Steer selection
        //Dharam_1st_June_PBI811125(400)
        action.setParams({
            "grade": grade,
            "contractStartDate" : component.get("v.contractStartDate")
        });
        
            action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                 console.log('test',response.getReturnValue());
                if(response.getReturnValue().length >0){
                    component.set('v.sourceSteerLst', response.getReturnValue()); 
                }
                else{
                     component.set('v.sourceSteerLst',[]); 
                }
               
            }else{
                component.set('v.sourceSteerLst',[]); 
            }
         helper.endSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
	},
    getSelectedDepotSteer : function(component, event, helper){
        helper.startSpinner(component, event, helper);
        var grade= component.get("v.gradeSelDepot");
        var mot=component.get("v.motSel");
        var plant=component.get("v.selPlant");
        var showOverriden=component.get("v.showOverriddenPlants");
        var action = component.get("c.getDepotSteer");
        component.set('v.gradeSel', grade);    
        //added to change depot steer based on Source Steer selection
        //Dharam_1st_June_PBI811125(400)
        action.setParams({
            "grade": grade,
            "mot" : mot,
            "plantName" :plant,
            "showOverridden" : showOverriden,
            "contractStartDate" : component.get("v.contractStartDate")//Fix_PBI_442470_Lakshmi
        });
            action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                 console.log('testDepot',response.getReturnValue());
                if(response.getReturnValue().length >0){
                    component.set('v.depotSteerLst', response.getReturnValue()); 
                }
                else{
                     component.set('v.depotSteerLst',[]); 
                }
               
            }else{
                component.set('v.depotSteerLst',[]); 
            }
         helper.endSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    getSelectedFinalSteer : function(component, event, helper){
        helper.startSpinner(component, event, helper);
        var grade= component.get("v.FinalgradeSelDepot");
        var plant=component.get("v.selFinalPlant");
        var action = component.get("c.fetchDailyPricingTrend");
        action.setParams({
            
            
            "contractDate" : component.get("v.contractStartDate"),//Fix_PBI_442470_Lakshmi
            "plantName" :plant,
            "gradeName": grade
        });
            action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                    var dailyBSPTrend = response.getReturnValue();
                    console.log('----------'+JSON.stringify(dailyBSPTrend));
                    var arrayMapKeys = [];
                    for(var key in dailyBSPTrend){
                             //console.log('----------'+JSON.stringify(dailyBSPTrend[key]));
                            var insidearrayMapKeys = [];
                            var displayInside = dailyBSPTrend[key];
                            for(var insideKey in displayInside){
                                
                                insidearrayMapKeys.push({key: insideKey, value: displayInside[insideKey]});
                            }
                            //console.log('-----insidearrayMapKeys-----'+JSON.stringify(insidearrayMapKeys));
                            arrayMapKeys.push({key: key, value: insidearrayMapKeys});
                    }
					component.set("v.dailyBSPTrendMap",arrayMapKeys);
            }
         	helper.endSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
    },          
    startSpinner : function(component, event, helper) {
         var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    endSpinner : function(component, event, helper) {
         var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})