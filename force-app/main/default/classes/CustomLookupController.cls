public with sharing class CustomLookupController {
    public CustomLookupController() {
    }
    
    @AuraEnabled(cacheable = true) 
    public static List<SObject> findRecords(String searchKey, String objectName, String searchField) {
        
		String myQuery = null;

		if(string.isBlank(searchKey)) 
		{
			myQuery = 'Select Id, ' + searchField + ' From ' + objectName + ' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5';
		}
		
		else 
		{
			String key = '\'%' + searchKey + '%\'';
        	myQuery = 'Select Id, ' + searchField + ' From ' + objectName + ' Where ' + searchField + ' LIKE '+key+' Limit 5';
		}
        //System.debug('QUERY: '+myQuery);
        List<SObject> sObjectList = Database.query(myQuery);
        return sObjectList;
    }
    
    @AuraEnabled(cacheable = true) 
    public static List<SObject> findRecordsById(String searchKey, String objectName, String searchField, String lookupField, String relatedId, String junctionObject, String idToSearch) {
        
		String myQuery = null;
		if(string.isBlank(searchKey)) 
		{
			myQuery = 'Select Id, ' + searchField + ' From ' + objectName + ' Where Id IN (Select '+idToSearch+' from '+junctionObject+' Where ' + lookupField + ' = \'' + relatedId +'\') AND LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5';
		}
		else
		{
			String key = '\'%' + searchKey + '%\'';
        	myQuery = 'Select Id, ' + searchField + ' From ' + objectName + ' Where Id IN (Select '+idToSearch+' from '+junctionObject+' Where ' + lookupField + ' = \'' + relatedId +'\') AND ' + searchField + ' LIKE '+key+' Limit 5';
		}
        //System.debug('QUERY: '+myQuery);
        List<SObject> sObjectList = Database.query(myQuery);
        return sObjectList;
    }
}