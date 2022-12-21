({
	doInit : function(component, event, helper) { 
		/*helper.getCurrentUser(component);
        helper.executelastruntime(component);
        helper.getMOPSData(component);
        helper.getfxratesdata(component);
        helper.getPeninsularcostingData(component);
        helper.getSabahcostingData(component);  
        helper.getSarawakcostingData(component);*/
		helper.getInitialParamaterDetails(component);
        
        var today = new Date();
		var todaysdate = today.getDate() + '/' + (today.getMonth()+1) + '/' + today.getFullYear();
        component.set("v.currentyear",today.getFullYear()); 
        component.set("v.todaydate",todaysdate);
     
        //var todaysweek = today.getWeek() + '/' + today.getFullYear() ;
       // component.set("v.todaysweek",todaysweek);
		const yesterday = new Date(today);
		yesterday.setDate(yesterday.getDate() - 1);
        var yesterdaydate = yesterday.getDate() + '/' + (yesterday.getMonth()+1) + '/' + yesterday.getFullYear();
        component.set("v.yesterdaydate",yesterdaydate);
	},
     reviewEmail : function(component, event, helper) {
        var url = '/apex/CostingMYOutputConga';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    recalculate : function(component, event, helper) {
        component.set("v.isRecalculate",true);                
    },
    midDayInput : function(component, event, helper) {
        helper.getmiddaydata(component);                         
    },
    closePopUp  : function(component, event, helper) {
        component.set("v.isRecalculate",false);
        component.set("v.isMidDay",false);
    },
    executejob  : function(component, event, helper) {
        component.set("v.isRecalculate",false);
        component.set("v.isValidProfile",false); 
        helper.executejobhelper(component);
    },
    getValueFromLwc : function(component, event, helper) {
        console.log(event);
    },
    refreshview : function(component, event, helper){
        
        $A.get('e.force:refreshView').fire();
    }
})