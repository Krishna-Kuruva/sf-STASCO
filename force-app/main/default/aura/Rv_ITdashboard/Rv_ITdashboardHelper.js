({
    poller : function(component, event, helper) {
        helper.setPageData(component, event, helper);
        
        var refreshInterval = component.get("v.PageRefreshInterval");

        var intervalID = window.setInterval	(  				
            				function(){ helper.setPageData(component, event, helper)},
        					refreshInterval * 1000
        					);
        console.log("intervalID created: " +intervalID);
        component.set("v.RefreshIntervalId",intervalID);
     },
	setPageData : function(component, event, helper) {
        console.log("current intervalID: " +component.get("v.RefreshIntervalId"));
        
        helper.getAllData(component, event, helper);
        
        var now = new Date();
        var month = now.getMonth()+1; //Fix_PBI_569346_22July2020_lakshmi
        
        //Fix_PBI_569346_22July2020_lakshmi_starts
        var nowFromatted = 	  (now.getDate()<10 ? '0' + now.getDate() : now.getDate()) + '.' 
        					+ (month < 10 ? '0' + month : month) + '.' 
        					+ now.getFullYear() + ' '
        					+ (now.getHours()<10 ? '0' + now.getHours() : now.getHours()) + ':' 
        					+ (now.getMinutes()<10 ? '0' + now.getMinutes() : now.getMinutes()) + ':' 
        					+ (now.getSeconds()<10 ? '0' + now.getSeconds() : now.getSeconds());
        //Fix_PBI_569346_22July2020_Ends
        
        component.set("v.PageRefreshedAt",nowFromatted);
	},
    getAllData : function(component, event, helper) {
        helper.startSpinner(component, event, helper);

        var callApexGetAllData = component.get("c.getAllData");
        console.log(callApexGetAllData);
        if(callApexGetAllData != undefined)
        {
            callApexGetAllData.setCallback(this, function(a) {
                var state = a.getState();     
                if(state === 'SUCCESS'){
                    component.set("v.PageName",a.getReturnValue().PageName);
                    component.set("v.DaveSectionName",a.getReturnValue().DaveSectionName);
                    component.set("v.DealSectionName",a.getReturnValue().DealSectionName);
                    component.set("v.MRCUploadSectionName",a.getReturnValue().MRCUploadSectionName);
                    component.set("v.LiveSectionName",a.getReturnValue().LiveSectionName);
                    component.set("v.BatchSectionName",a.getReturnValue().BatchSectionName);
                    component.set("v.DailyCheckSectionName",a.getReturnValue().DailyCheckSectionName);	//Fix_301484_26Dec2019_Soumyajit
                    
                    component.set("v.OverallStatus",a.getReturnValue().ErrorStatus);
                    
                    if(a.getReturnValue().ErrorStatus)
                    {
                        var errList = [];
                        a.getReturnValue().ErrorList.forEach(function(value,index){errList.push(value.ErrorMsg)});
                        component.set("v.OverallError",errList);
                    }
                    
                    component.set("v.PriceDetails"
                                  ,helper.makeDataChunk(component.get("v.NumOfTablesPriceSection")
                                                        ,a.getReturnValue().PriceData
                                                       )
                                 );
                    
                    component.set("v.BatchDetails"
                                  ,helper.makeDataChunk(component.get("v.NumOfTablesBatchSection")
                                                        ,a.getReturnValue().BatchData
                                                       )
                                 );
                    component.set("v.BatchActionAllowed",a.getReturnValue().BatchActionAllowed);
                    component.set("v.RunRefreshAllowed",a.getReturnValue().RunRefreshAllowed);
                    component.set("v.ShowRunAllButton",a.getReturnValue().ShowRunAllButton);
                    component.set("v.ShowStopAllButton",a.getReturnValue().ShowStopAllButton);
                    
                    component.set("v.DealDetails"
                                  ,helper.makeDataChunk(component.get("v.NumOfTablesDealSection")
                                                        ,a.getReturnValue().DealData
                                                       )
                                 );
                    
                    component.set("v.HedgeDetails",a.getReturnValue().DaveData);
                    component.set("v.MRCUploadDetails",a.getReturnValue().MRCUploadData);
                    
                    //Fix_301484_26Dec2019_Soumyajit starts
                    component.set("v.DailyCheckDetails"
                                  ,helper.makeDataChunk(component.get("v.NumOfTablesDailyCheckSection")
                                                        ,a.getReturnValue().DailyCheckData
                                                       )
                                 );
                    //Fix_301484_26Dec2019_Soumyajit ends
                }
                else
                    helper.popToast(component,'Error','Something went wrong. Please try again later!');
                helper.endSpinner(component, event, helper);
            });
            
            $A.enqueueAction(callApexGetAllData);
        }
    },
    batchAction : function(component, event, helper)
    {
        helper.startSpinner(component, event, helper);
        
    	var batchDetail = event.getSource().get("v.name");
        var type = event.getSource().getLocalId();
        var callApexDoBatchAction = component.get("c.doBatchAction");
        
        if(callApexDoBatchAction != undefined)
        {
            callApexDoBatchAction.setParams({
                "batchDetail": batchDetail,
                "actionType" : type
                });
            
            callApexDoBatchAction.setCallback(this, function(a) {
                var state = a.getState();     
                if(state === 'SUCCESS'){ 
                    var status = a.getReturnValue();
                    helper.popToast(component,'Success',status);
                }
                else
                    helper.popToast(component,'Error','Something went wrong. Please try again later!');
                helper.endSpinner(component, event, helper);
            });
            
            $A.enqueueAction(callApexDoBatchAction);
        }
	},
    startStopAllBatch : function(component, event, helper)
    {
        helper.startSpinner(component, event, helper);
        
    	var type = event.getSource().get("v.name");
        var callApexDoBatchAction = component.get("c.startStopAllBatches");
        
        if(callApexDoBatchAction != undefined)
        {
            callApexDoBatchAction.setParams({
                "actionType" : type
                });
            
            callApexDoBatchAction.setCallback(this, function(a) {
                var state = a.getState();     
                if(state === 'SUCCESS'){ 
                    var status = a.getReturnValue();
                    helper.popToast(component,'Success',status);
                    helper.setPageData(component, event, helper);
                }
                else
                    helper.popToast(component,'Error','Something went wrong. Please try again later!');
                helper.endSpinner(component, event, helper);
            });
            
            $A.enqueueAction(callApexDoBatchAction);
        }
	},
//Fix_PBI-517826_08Jun2020_Lakshmi_Starts
 IceMonthPopUp : function(component, event, helper) {
	helper.startSpinner(component, event, helper);
	var quote = event.getSource().get("v.name");
        component.set("v.RelatedQuote", quote);
                   
        var callApexIceMonth = component.get("c.getIceMonthDetails");
        
        if(callApexIceMonth != undefined)
        {
            callApexIceMonth.setParams({
                "quote": quote
                
                });
            console.log(quote);
            callApexIceMonth.setCallback(this, function(a) {
                var state = a.getState();     
                if(state === 'SUCCESS'){ 
                    console.log(a.getReturnValue());
                    component.set("v.IceMonthsList",a.getReturnValue());
                    component.set("v.ShowMonths", true);
                }
                else
                    helper.popToast(component,'Error','Something went wrong. Please try again later!');
               		helper.endSpinner(component, event, helper);
            });
            
            $A.enqueueAction(callApexIceMonth);
        }        
    },
// Fix_PBI-517826_08Jun2020_Lakshmi_Ends
    startSpinner : function(component, event, helper) {
         var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    endSpinner : function(component, event, helper) {
         var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    popToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },
    makeDataChunk: function(numOfTables,dataArray){
        var tableDataChunk = [];
        
        var chunkSize = Math.round(dataArray.length / numOfTables);
        var chunkData = [];
        
		//console.log(dataArray.length);
        
        for (var i=0,j=1; j<=numOfTables; j+=1) 
        {
        	chunkData = [];
            var l=dataArray.length - ((numOfTables-j)*chunkSize);
            var curIndex = 0;
            
            for (var k=i; k<l; k+=1) 
            {
                //console.log('DisplaySequence='+dataArray[k].DisplaySequence);
            	if(dataArray[k].DisplaySequence === k+1)
                	chunkData.push(dataArray[k]);
                
                curIndex += 1;
            }
                    
            tableDataChunk.push({Col: j,
                                 DataChunk : chunkData});
            
            i+=curIndex;
        }
        
        //console.log(tableDataChunk);
        
        return tableDataChunk;
	},
})