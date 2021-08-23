trigger IntakeItemTrigger on Intake_Item__c (before insert) {
   // If(!((Global_VR_WFR_Settings__c.getInstance().Contact_Trigger_Disable__c) || (Global_VR_WFR_Settings__c.getInstance().Disable_All_Triggers__c))){
        
        if (Trigger.isBefore) {
            //BeforeInsert
            if (Trigger.isInsert) {
                IntakeItemTriggerHandler theHandler = new IntakeItemTriggerHandler(Trigger.New);
                theHandler.handleIntakeItemsBeforeInsert();
            }
            //BeforeUpdate
            if (Trigger.isUpdate) {
                IntakeItemTriggerHandler theHandler = new IntakeItemTriggerHandler(Trigger.OldMap, Trigger.NewMap);
                theHandler.handleIntakeItemsBeforeUpdate();
            }
            //BeforeDelete
            if (Trigger.isDelete) {
                IntakeItemTriggerHandler theHandler = new IntakeItemTriggerHandler(Trigger.OldMap, Trigger.NewMap);
                theHandler.handleIntakeItemsBeforeDelete();
            }
            
        }
        
        if (Trigger.IsAfter) {
            //AfterInsert
            if (Trigger.isInsert) {
                IntakeItemTriggerHandler theHandler = new IntakeItemTriggerHandler(Trigger.New);
                theHandler.handleIntakeItemsAfterInsert();
            }
            //AfterUpdate
            if (Trigger.isUpdate) {
                IntakeItemTriggerHandler theHandler = new IntakeItemTriggerHandler(Trigger.OldMap, Trigger.NewMap);
                theHandler.handleIntakeItemsAfterUpdate();
            }
            //AfterDelete
            if (Trigger.isDelete) {
                IntakeItemTriggerHandler theHandler = new IntakeItemTriggerHandler(Trigger.OldMap, Trigger.NewMap);
                theHandler.handleIntakeItemsAfterDelete();
            }            
        }
   // }
}