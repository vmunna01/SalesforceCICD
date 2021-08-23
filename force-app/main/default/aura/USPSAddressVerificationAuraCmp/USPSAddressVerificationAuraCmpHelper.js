({
    unKnownErrorToast : function(value) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            Title:'title',
            type:'error',
            message: value
        });
        toastEvent.fire();
    },
    
    successToast : function(value) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            Title:'title',
            type:'success',
            message: value
        });
        toastEvent.fire();
    }
})