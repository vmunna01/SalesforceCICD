({
   init: function (cmp, event, helper) {
        cmp.set('v.mycolumns', [
            { label: 'Contact Name', fieldName: 'Name', type: 'text', sortable: true},
            { label: 'Status', fieldName: 'Status__c', type: 'picklist', sortable: true},
            { label: 'Email', fieldName: 'Email', type: 'email'}
        ]);
        helper.getData(cmp);
        // helper.enableChangeStatus(component,event,helper);
    },
    
    changeStatus : function (cmp, event, helper) {
        // alert("You clicked: " + event.getSource().get("v.label"));
        var table = cmp.find("tbl");
        // console.log(table.getSelectedRows());
        var selectedRows = table.getSelectedRows();
        // Display that fieldName of the selected rows
        var conArray = new Array();
        for (var i = 0; i < selectedRows.length; i++){
            conArray.push(selectedRows[i].Id);
        }
        var action = cmp.get('c.saveStatus');
        action.setParams({
                "contactList": conArray,
                "status" : cmp.get("v.status")
            });

        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
        cmp.set("v.selectedRows", []);
        cmp.set('v.showStatuspopUp', false);
        var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
	        "title": "Success!",
	        "message": "The record(s) has been updated successfully."
    	});
    	toastEvent.fire();
    },

    getFilterData : function(cmp) {
        var action = cmp.get('c.searchContact');
        action.setParams({
                "search": cmp.get("v.searchQuery")
            });

        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    showPopUp : function (cmp) {
    	var table = cmp.find("tbl");
        var selectedRows = table.getSelectedRows();
        if(selectedRows.length<=0){
        	var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
	        "title": "Error!",
	        "message": "You need to select atleast one record to upodate Status."
    	});
    	toastEvent.fire();
        }
        else
    		cmp.set('v.showStatuspopUp', true);
    },

	hidePopUp : function (cmp) {
    	cmp.set('v.showStatuspopUp', false);
    },

    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        // console.log(fieldName);
        var sortDirection = event.getParam('sortDirection');
        // console.log(sortDirection);
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
})