({
    runCallout : function(cmp, event, helper) {
        
        let action = cmp.get('c.doCallout');
        action.setParams({accountId : cmp.get('v.recordId')});
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire(); // if you want to self-close
                helper.successToast('Address Validated Successfully.');
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.unKnownErrorToast(errors[0].message);
                    } else {
                        helper.unKnownErrorToast('Unknown Error Occurred. Please contact administrator');
                    } 
                } else {
                    helper.unKnownErrorToast('Unknown Error Occurred. Please contact administrator');
                } 
            } else {
                helper.unKnownErrorToast('Unknown Error Occurred. Please contact administrator');
            }
        });
        $A.enqueueAction(action);
    }
})