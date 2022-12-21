({
    closeModel: function(component, event, helper) {
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewName": null,
            "scope": "BET_BDD_Form__c"
        });
        navEvent.fire();
    },
})