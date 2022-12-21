({
	doInit : function(component, event, helper) {  
        helper.poller(component, event, helper);
	},
    doRefresh : function(component, event, helper) {  
        helper.getAllData(component, event, helper);
	},
    doSelectedBatchAction : function(component, event, helper){
    	helper.batchAction(component, event, helper);
        helper.setPageData(component, event, helper);
	},
    doStartStopAllBatch : function(component, event, helper){
        component.set("v.ShowRunAllButton",true);
        component.set("v.ShowStopAllButton",true);
    	helper.startStopAllBatch(component, event, helper);
	},
    toggleSection : function(component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    openPostRefresh: function(component, event, helper) 
    {
        component.set("v.isPostRefreshOpen", true);
   	},
  	closePostRefresh: function(component, event, helper) 
    {
        component.set("v.isPostRefreshOpen", false);
   	},
    
    //Fix_PBI-517826_08Jun2020_Lakshmi_Starts
    OpenIceMonthPopUp : function(component, event, helper)
    {
        helper.IceMonthPopUp(component, event, helper);
     },
    
    CloseIceMonthPopUp: function(component, event, helper) 
    {
      component.set("v.ShowMonths", false);
   	},
    
  //Fix_PBI-517826_08Jun2020_Lakshmi_Ends
})