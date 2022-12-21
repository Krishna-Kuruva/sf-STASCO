({
	 getData : function(component,event,helper) {
        helper.getChildRecord(component,event,helper);
		
    },
    // Invokes the subscribe method on the empApi component
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
            console.log('Received event ', JSON.stringify(eventReceived));
            helper.addSalesHedgeTransactionLst(component, event, helper,eventReceived.data.payload);
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
    // Invokes the subscribe method on the empApi component
    subscribeToMasters : function(component, event, helper) {
        // Get the empApi component
        const empApi = component.find('newEmpApi');
        // Get the channel from the input box
        const channelMasters = component.get('v.channelMasters');
        // Replay option to get new events
        const replayId = -1;

        // Subscribe to an event
        empApi.subscribe(channelMasters, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(eventReceived));
           
           
            helper.updateTotalExposureLst(component, event, helper,eventReceived.data.payload);
        
             
        }))
        .then(subscription => {
            // Confirm that we have subscribed to the event channel.
            // We haven't received an event yet.
            console.log('Subscribed to channel ', subscription.channelMasters);
            // Save subscription to unsubscribe later
            component.set('v.subscriptionMasters', subscription);
        });
    },
    unsubscribeToMasters : function(component, event, helper) {
        // Get the empApi component
         const empApi = component.find('newEmpApi');
         // Get the subscription that we saved when subscribing
          const subscription = component.get('v.subscriptionMasters');
                
         // Unsubscribe from event
          empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
           // Confirm that we have unsubscribed from the event channel
          console.log('Unsubscribed from channel '+ unsubscribed.subscription);
          component.set('v.subscriptionMasters', null);
          }));
                
    },
    addSalesHedgeTransactionLst : function(component,event,helper,newShtData){
        if(newShtData != undefined){
           var tempshtdata=[];
            tempshtdata= component.get("v.salesHedgeLst");
            if(tempshtdata != undefined)
            {
                console.log('oldtempshtdata',JSON.stringify(tempshtdata));
                //tempshtdata.push(newShtData);
                tempshtdata.unshift(newShtData);
                //console.log('newtempshtdata',JSON.stringify(tempshtdata));
                component.set("v.salesHedgeLst",tempshtdata);
                helper.LastSync(component,event,helper);
            }
        }
    }, 
    updateTotalExposureLst : function(component, event, helper,newTotalExp) {
        if(newTotalExp != undefined){
            console.log('update total exposure');
            var totExp=component.get("v.TotalExposureLst");
            var newExpLst=[];
            console.log('prd name==>'+newTotalExp.Product_Name__c);
            console.log('Event==>'+JSON.stringify(newTotalExp));
            if(totExp != undefined)
            {
                for(var i=0;i<totExp.length;i++){
                    if(totExp[i].Name == newTotalExp.Product_Name__c){
                        totExp[i].Total_Exposure_Factor_CBM__c= newTotalExp.Xposr_CBM__c;
                        totExp[i].Total_Exposure_Factor_MT__c= newTotalExp.Xposr_Tonne__c;
                        totExp[i].Final_Exposure_Factor__c=newTotalExp.Open_Xposr_Lots__c;
                        totExp[i].Hedged__c=newTotalExp.Hedge_Lots__c;
                       // newExpLst.push(totExp[i]);
                    }
                    
                }
                component.set("v.TotalExposureLst",totExp);
            }
            //var updtotExp=component.get()
           // console.log('newTotalExp',JSON.stringify(totExp));  
        }
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
     getChildRecord: function (component,event,helper){
        //alert();
        var action = component.get('c.getShtDave');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set('v.salesHedgeLst', response.getReturnValue());
                 component.set('v.salesHedgeLstTemp',response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }, 
    getDataMaster : function(component,event,helper) {
                helper.getMasterRecord(component,event,helper);

        /* window.setInterval(
            $A.getCallback(function() { 
                helper.getMasterRecord(component,event,helper);
            }), 30000
        );
        
		*/
    },
    
    getMasterRecord: function(component,event,helper){
        
        var action = component.get('c.getShtDaveMaster');
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                component.set('v.TotalExposureLstTemp', response.getReturnValue());
                var totalExpo = component.get('v.TotalExposureLstTemp');
               var options=[]; 
                var displayProdtc = [];
                var shtDaveMasterProduct = [];
                for(var i=0;i<totalExpo.length;i++){
                    options.push(totalExpo[i].Name);
                    //alert(totalExpo[i].Name);
                    if( totalExpo[i].Name === "MOGAS" || totalExpo[i].Name === "AGO B7" || totalExpo[i].Name === "IGO 50ppm"){
                        displayProdtc.push(totalExpo[i]);
                        shtDaveMasterProduct.push(totalExpo[i].Name);
                    }
                }
                 
                  component.set('v.TotalExposureLst', displayProdtc);
               
                var v = component.get('v.SHTDaveMasterProduct');
                var defaultVal=[{value: "Please Select", label: "Please Select"}];
                 for(var i=0;i<shtDaveMasterProduct.length;i++){
                    defaultVal.push({"class": "optionClass", label: shtDaveMasterProduct[i], value:shtDaveMasterProduct[i]});
                }
                 component.set('v.SHTDaveMasterProduct', defaultVal);
                //var data=component.get();
                var opts=[{value: "Please Select", label: "Please Select"}];
                for(var i=0;i<options.length;i++){
                    opts.push({"class": "optionClass", label: options[i], value:options[i]});
                }
                  component.set("v.filterValue", opts);    
                //alert(JSON.stringify( component.get("v.filterValue")));
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    sortDataSalesHedge: function (component, fieldName, sortDirection) {
        var data = component.get("v.salesHedgeLst");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.salesHedgeLst", data);
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.TotalExposureLst");
        //alert(JSON.stringify(data));
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.TotalExposureLst", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
       // alert('key'+key);
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})