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
        component.set("v.todaydate",todaysdate);
     
        //var todaysweek = today.getWeek() + '/' + today.getFullYear() ;
       // component.set("v.todaysweek",todaysweek);
		const yesterday = new Date(today);
		yesterday.setDate(yesterday.getDate() - 1);
        var yesterdaydate = yesterday.getDate() + '/' + (yesterday.getMonth()+1) + '/' + yesterday.getFullYear();
        component.set("v.yesterdaydate",yesterdaydate);
	},     
})