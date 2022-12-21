({
    
    uploadHelper: function(component, event) {
        
        component.set("v.showLoadingSpinner", true);
        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0];
        console.log(JSON.stringify(file));
        var self = this;
        var objFileReader = new FileReader();
        
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
            self.uploadProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
    },
    uploadProcess: function(component, file, fileContents) {
        
        var action = component.get("c.saveMRCData");
        action.setParams({
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents),
            contentType: file.type
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.errorList",result);
                if(result != null )
                	alert('Error while saving data.Please check logs');
                else
                    alert('your File is uploaded successfully');
                component.set("v.showLoadingSpinner", false);
            } else if (state === "INCOMPLETE") {
                alert("Error while saving : " + response.getReturnValue());
                component.set("v.showLoadingSpinner", false);
            } else if (state === "ERROR") {
                alert("Error while saving some records Pls check MRC data: " + response.getReturnValue());
                var errors = response.getError();
                component.set("v.showLoadingSpinner", false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
    
})