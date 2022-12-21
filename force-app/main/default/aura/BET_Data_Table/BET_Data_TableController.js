({
    sendRowDetailsToParentComponent: function(component, event, helper) {
        component.set("v.showEdpResetBtn", true);
        let recList = [];
        recList = component.find('bet-data-table').getSelectedRows();
        
        if(recList != "" && recList.length >= 1){
            var selectedRec = recList[0];
            var compId = component.get('v.componentId');
            var compEvent = component.getEvent("DataTableRowSelEvent");
            compEvent.setParams({
                "selectedRecord": recList[0],
                "componentId": compId
            });
            compEvent.fire();  
        } 
    },
    ResetEDPResSelection : function(component, event, helper) {
        var EdpData =  component.get("v.edpData");
        component.set("v.edpData", EdpData);
        component.set("v.edpData", EdpData);
        var compId = component.get('v.componentId');
        var compEvent = component.getEvent("DataTableRowSelEvent");
        compEvent.setParams({
            "selectedRecord": '',
            "componentId": compId
        });
        compEvent.fire();
    },
})