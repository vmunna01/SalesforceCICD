global class OpportunityStageBatchClass implements Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    
    global OpportunityStageBatchClass() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, StageName, CreatedDate FROM Opportunity ' + 
            'Where StageName != \'Closed - Won\' And StageName != \'Closed - Lost\''
        );
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
        System.debug('Stage Size: '+scope.size());
        //List<OpportunityFieldHistory> history = [Select Id, CreatedDate, Field, NewValue, OldValue, OpportunityId 
          //                                      from OpportunityFieldHistory 
            //                                    Where Field = 'StageName' AND OpportunityId =: Scope Order By CreatedDate];
        Map<Id, List<OpportunityFieldHistory>> oppIdFieldHistoryMap = new Map<Id, List<OpportunityFieldHistory>>();
        for(OpportunityFieldHistory oh: [Select Id, CreatedDate, Field, NewValue, OldValue, OpportunityId 
                                                from OpportunityFieldHistory 
                                                Where Field = 'StageName' AND OpportunityId IN: Scope 
                                         		Order By CreatedDate]) {
            if(!oppIdFieldHistoryMap.containsKey(oh.OpportunityId)){
                oppIdFieldHistoryMap.put(oh.OpportunityId,new List<OpportunityFieldHistory>());
            }
            oppIdFieldHistoryMap.get(oh.OpportunityId).add(oh);
        }
		OpportunityStageBatchClassHelper.OpportunityStageBatchClassHelper(oppIdFieldHistoryMap, scope);
    }    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
    }    
}