({
	doInit : function(component, event, helper) { 
        /*helper.getCurrentUser(component);
		helper.getfxratesdata(component);
        helper.getfxcostingdata(component);
        helper.getmopsdata(component);*/
        console.log('test');
        helper.getInitialParamaterDetails(component);
        var today = new Date();
		var todaysdate = today.getDate() + '/' + (today.getMonth()+1) + '/' + today.getFullYear();
        component.set("v.todaydate",todaysdate);
		const yesterday = new Date(today);
		yesterday.setDate(yesterday.getDate() - 1);
        var yesterdaydate = yesterday.getDate() + '/' + (yesterday.getMonth()+1) + '/' + yesterday.getFullYear();
        component.set("v.yesterdaydate",yesterdaydate);
	}, 
    reviewEmail : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = '/apex/CostingOutputConga?id=' + recordId;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    recalculate : function(component, event, helper) {
        helper.executelastruntime(component); 
    },
    closePopUp  : function(component, event, helper) {
        component.set("v.isRecalculate",false);
    },
    executejob  : function(component, event, helper) {        
        component.set("v.isValidProfile",false); 
        component.set("v.isRecalculate",false);
        helper.executejobhelper(component);
    },
 });