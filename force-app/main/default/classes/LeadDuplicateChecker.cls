public class LeadDuplicateChecker {
    
    List<Lead> newleads = getNewLeads();
    Map<Boolean, List<Lead>> leadResults = leadDuplicateCheck(newLeads);
    
    public Map<Boolean, List<Lead>> leadDuplicateCheck(List<Lead> leads) {
        Map<Boolean, List<Lead>> leadMap = new Map<Boolean, List<Lead>>();
        //duplicate map
        Map<Id, Lead> dl = new Map<Id, Lead>();
        //non-duplicate map
        Map<Id, Lead> ndl = new Map<Id, Lead>();
        //getting Lead Records to validate the duplicates for the new lead records
        List<Lead> allLeads = [Select Id, Email, Company from Lead Where Email <> null And Company <> null];
        //looping through new lead records and then with all records to compare the required fields
        for(Lead nl: leads) {
            for(Lead al: allLeads) {
                //verify if the values are same add the lead to the duplicate map and then break the loop since it's duplicate
                if(nl.Email == al.Email && nl.Company == al.Company) {
                    dl.put(nl.Id, nl);
                    break;
                }
                //if it is not a duplicate then add the lead to the non-duplicate map and continue the loop to verify with other records
                else {
                    if(!dl.containsKey(nl.Id))
                        ndl.put(nl.Id, nl);
                }
            }
        }
        //if the non-duplicate list is not empty then add it to the final leadmap
        if(!ndl.isEmpty())
            leadMap.put(true, ndl.Values());
        //if the duplicate list is not empty then add it to the final leadmap
        if(!dl.isEmpty())
            leadMap.put(false, dl.Values());
        
        return leadMap;
    }
    
    public List<Lead> getNewLeads() {
        //get the new records as per our need
        return [Select Id, Email, Company from Lead Where createdDate > yesterday];
    }
}