public class IntakeItemTriggerHandler {
    
    Map<Id, Intake_Item__c> oldMapIntakeItems;
    Map<Id, Intake_Item__c> newMapIntakeItems;
    List<Intake_Item__c> newListIntakeItems;
    
    public static final Id salesCreditRecTypeId = Schema.SObjectType.Intake_Item__c.getRecordTypeInfosByName().get('Sales/Credit Intake').getRecordTypeId();
    public static final Id technologyRecTypeId = Schema.SObjectType.Intake_Item__c.getRecordTypeInfosByName().get('Technology Intake').getRecordTypeId();
    
    public IntakeItemTriggerHandler(List<Intake_Item__c> newTriggerIntakeItemsList) {
        newListIntakeItems = newTriggerIntakeItemsList;
    }
    
    public IntakeItemTriggerHandler(Map<Id, Intake_Item__c> oldTriggerIntakeItemsMap, Map<Id, Intake_Item__c> newTriggerIntakeItemsMap) {
        oldMapIntakeItems = oldTriggerIntakeItemsMap;
        newMapIntakeItems = newTriggerIntakeItemsMap;
    }
    
    public void handleIntakeItemsBeforeInsert() {
        
    }
    
    public void handleIntakeItemsBeforeUpdate() {
        
    }
    
    public void handleIntakeItemsBeforeDelete() {
        
    }
    
    public void handleIntakeItemsAfterInsert() {
        //postToChatterGroup(newListIntakeItems);
    }
    
    public void handleIntakeItemsAfterUpdate() {
        
    }
    
    public void handleIntakeItemsAfterDelete() {
        
    }
    
    /*public void postToChatterGroup(List<Intake_Item__c> newIntakeItemList) {
        
        Map<Id, Intake_Item__c> salesCreditAffordableItems = new Map<Id, Intake_Item__c>();
        Map<Id, Intake_Item__c> salesCreditNonAffordableItems = new Map<Id, Intake_Item__c>();
        Map<Id, Intake_Item__c> technologyItems = new Map<Id, Intake_Item__c>();
        
        for(Intake_Item__c i: newIntakeItemList) {
            if(i.RecordTypeId == salesCreditRecTypeId && i.Path__c == 'Affordable') {
                salesCreditAffordableItems.put(i.id, i);
            }
            else if(i.RecordTypeId == salesCreditRecTypeId && i.Path__c == 'Non-Affordable') {
                salesCreditNonAffordableItems.put(i.Id, i);
            }
            else if(i.RecordTypeId == salesCreditRecTypeId && i.Path__c == 'Both') {
                salesCreditAffordableItems.put(i.Id, i);
                salesCreditNonAffordableItems.put(i.Id, i);
            }
            else if(i.RecordTypeId == technologyRecTypeId) {
                technologyItems.put(i.Id, i);
            }
            if(salesCreditAffordableItems.size()>0) {
                
            }
            if(salesCreditNonAffordableItems.size()>0) {
                
            }
            if(technologyItems.size()>0) {
                
            }
        }
    }*/
}