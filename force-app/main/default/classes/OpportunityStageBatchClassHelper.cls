public with sharing class OpportunityStageBatchClassHelper {
    public static void OpportunityStageBatchClassHelper(Map<Id, List<OpportunityFieldHistory>> oppIdFieldHistoryMap, List<Opportunity> oppList) {
        
        Map<Id, Map<String, Decimal>> oppStageTimeMap = new Map<Id, Map<String, Decimal>>();
        List<String> stageNames = new List<String>{'Prospect','Qualify','Customize','Prove','Propose','Close'};
                
                for(opportunity o: oppList) {
                    Map<String, Decimal> stageTimeDecimalMap = new Map<String, Decimal>();
                    Map<String, Integer> stageTimeMap = new Map<String, Integer>();
                    for(String s: stageNames) {
                        stageTimeMap.put(s, 0);
                    }
                    if(oppIdFieldHistoryMap.get(o.Id) <> null) {
                        integer i = 0;
                        for(OpportunityFieldHistory ofh: oppIdFieldHistoryMap.get(o.Id)) {
                            if(i == 0) {
                                if(stageTimeMap.containsKey(String.valueOf(ofh.oldValue)))
                                    stageTimeMap.put(String.valueOf(ofh.oldValue), getNoOfHours(o.CreatedDate, ofh.CreatedDate, stageTimeMap.get(String.valueOf(ofh.oldValue))));
                            }
                            else if(i == oppIdFieldHistoryMap.get(o.Id).size()) {
                                if(stageTimeMap.containsKey(String.valueOf(ofh.newValue)))
                                    stageTimeMap.put(String.valueOf(ofh.newValue), getNoOfHours(ofh.CreatedDate, System.now(), stageTimeMap.get(String.valueOf(ofh.newValue))));
                            }
                            else {
                                if(stageTimeMap.containsKey(String.valueOf(ofh.oldValue)))
                                    stageTimeMap.put(String.valueOf(ofh.oldValue), getNoOfHours(oppIdFieldHistoryMap.get(o.Id)[i-1].CreatedDate, ofh.CreatedDate, stageTimeMap.get(String.valueOf(ofh.oldValue))));
                            }
                            i++;
                        }
                        for(String s1: stageNames) {
                            stageTimeDecimalMap.put(s1, getNoOfDays(stageTimeMap.get(s1)));
                        }
                        oppStageTimeMap.put(o.Id, stageTimeDecimalMap);
                    }
                    if(oppStageTimeMap.get(o.Id)<>null)
                        System.debug('Opportunity Id: '+o.Id+' Stage Hours: '+oppStageTimeMap.get(o.Id));
                }
    }
    
    public static Integer getNoOfHours(DateTime oldDate, DateTime newDate, Integer currentHours) {
        integer newHours = Integer.valueOf((newDate.getTime() - oldDate.getTime())/(1000*60*60));
        return newHours + currentHours;
    }
    
    public static Decimal getNoOfDays(Integer i) {
        
        if(i == 0) {
            return 0.00;
        }
        else if(i <= 12) {
            return 0.50;
        }
        else if(i <= 23) {
            return 1;
        }
        else {
            Integer remainingHours = math.mod(i, 24);
            Decimal Days = i/24 + getNoOfDays(remainingHours);
            return Days;
        }
    }
}