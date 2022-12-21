({
	
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    showSpinner: function(component, event, helper) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function(component, event, helper) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
	},
})