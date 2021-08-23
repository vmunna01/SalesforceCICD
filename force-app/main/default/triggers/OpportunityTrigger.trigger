trigger OpportunityTrigger on Opportunity (before update, before delete) {
    //Get current user profile name
    String profileName = [Select Id, Name from Profile where Id=:userinfo.getProfileId()].Name;
    //if it is update
    if (Trigger.isUpdate) {
        //loop through all the Opportunities for this trigger context
        for (Opportunity opp : Trigger.New) {
            //prevent non-admin users from modifying the Opportunity name if probability is greater than 50%
            if (profileName != 'System Administrator' && opp.Probability > 50 && opp.Name <> Trigger.oldMap.get(opp.Id).Name) {
                //adding error message to be displayed to the users
                opp.addError('Only Admins can modify the name if probability is greater than 50%.');
            } 
        }
    }
    //if it is delete
    if (Trigger.isDelete) {
        //loop through all the Opportunities for this trigger context
        for(Opportunity opp : Trigger.Old) {
            //prevent non-admins from deleting opportunities which probability is greater than or equal to 75%
            if (profileName != 'System Administrator' && opp.Probability >= 75) {
                //adding error message to be displayed to the users
                opp.addError('If the Opportunity Probability is greater than 75%, You can\'t delete this record!');
            }
        }
    }
}