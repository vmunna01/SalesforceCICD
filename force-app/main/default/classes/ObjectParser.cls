/**
    Class Name:     ObjectParser
    Description:    Generic class for parsing generic objects in different ways. Some codes are commented out for future use.
    Created By:     Frederick Valle
    Created Date:   10/20/2020
    Test Class:     ObjectParserTest

    Modification History:
    Author      Date            Description
    FVALLE      11/17/2020      Added methods related to CRM-2058


 */

public without sharing class ObjectParser {

    /* Recursive method that dynamically flattens an sObject record that spans relationships (nested JSON) into one level JSON
        INPUT: 
            obj: Type Object. instance of the sObject record to flatten 
            fullMap: Type Map <String, Object>. Collection that contains the flattened JSON
            prefix: Type String. String representation of the relationship 
        OUTPUT:
            Map <String, Object>. Single level key value pair of the field and its corresponding value
    */  
    public Map <String, Object> flattenObject (Object obj, Map <String, Object> fullMap, String prefix) {
        String jsonStr = JSON.serialize (obj) ;
        Map <String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);

        for (String key: objMap.keySet ()) {
            
            if (key != 'attributes') {
                Object objValue = objMap.get (key);

                // May not need the first condition because JSON.deserializeUntyped suppresses nulls by default
                if (objValue == null ) { fullMap.put (prefix + key, ''); }
                else if (objValue instanceOf Map <String, Object>) {
                    flattenObject (objValue, fullMap, prefix + key + '.');
                } 
                else {
                    fullMap.put (prefix + key, objMap.get (key));
                }
            }
        }
        return fullMap;
    }

    /* 
        Construct the CSV and return blob data 
        INPUT:
            headerSet: Set<String> that contains the fields from dataList
            dataList: List <Map <String, Object>> flattened collection of the data 
        OUTPUT:
            Blob value of the csv data.
    */
    public Blob getBlobValue (Set <String> headerSet, List <Map <String, Object>> dataList ) {

        transient String csvData = String.join (new List <String> (headerSet), ',') + '\n';
        
        // Iterate to get full CSV
        for (Map <String, Object> objMap: dataList) {
            for (String field: headerSet) {
                csvData += String.valueOf (objMap.get (field)) + ',';
            }
            csvData = csvData.removeEnd (',') + '\n';
        }
        
        return Blob.valueOf (csvData);
    }
    

    /**
        FVALLE  11/17/2020    
        Slice a collection of sObjects into a number of chunks
        INPUT:
            objLst: List of sObject collection 
            chunkSize: Integer representing the chunk size value
        OUTPUT:
            Map. Key = number of chunk, member = List <sObject> for that chunk
     */
    public Map <Integer, List <sObject>> chunk (List <sObject> objLst, Integer chunkSize) {
        Map <Integer, List <sObject>> retMap = new Map <Integer, List <sObject>> ();

        Integer numberOfChunks = objLst.size() / chunkSize;
        
        for (Integer chunk=0; chunk < numberOfChunks; chunk++) {
            retMap.put (chunk, getChunkList (objLst, chunk * chunkSize, (chunk + 1) * chunkSize));
        }
    
        if (numberOfChunks * chunkSize < objLst.size()) {
            retMap.put (numberOfChunks, getChunkList (objLst, numberOfChunks * chunkSize, objLst.size()));
        }

        return retMap;
    }

    /**
        FVALLE  11/17/2020    
        Get a subset of collection from indexStart to indexEnd of a given List.
        ASSUMPTION: indexStart and indexEnd are within the bounds of the collection objLst, otherwise fail silently
        INPUT: 
            objLst: List of sObject collection
            indexStart: index of the element to start from
            indexEnd: index of the element to end from
        OUTPUT:
            List. Subset list from the bigger collection
     */
    @TestVisible List <sObject> getChunkList (List <sObject> objLst, Integer indexStart, Integer indexEnd) {
        List <sObject> retLst = new List <sObject> ();
        for (Integer i=indexStart; i < indexEnd; i++) {
            try { retLst.add (objLst [i]); }
            catch (Exception e) { /* Abort silently if index is not within the collection bounds */}
        }

        return retLst;
    } 


    /** 
    This is the pattern that we're looking for in the string: 
    Sample: {!Status}, {!Case.Createdby.Name}
    */
    //@TestVisible final String FIELDPATTERN = '\\{!(.*?)\\}';
	
    /**
    INPUT:
        obj: Single sObject that contains all the necessary merge fields  
        message: String that contains the message and the candidate merge fields
    OUTPUT:
        String that contains the merged fields.
    */
    /*public String applyMergeFields (sObject obj, String message) {

        // Instantiate Pattern and Matcher
        Pattern textPattern = Pattern.compile (FIELDPATTERN);
        Matcher textMatcher = textPattern.matcher (message);
        
        String parsedMessage = message;

        // Iterate on all instances of the pattern
        while (textMatcher.find ()) {
        	String fieldName = textMatcher.group().replace ('{!', '').replace('}', '');
        	String fieldPttr =  textMatcher.group().replace ('{', '\\{').replace('}', '\\}');

            // Get value of the instance
            Object fieldValue = getValue (obj, fieldName);
		
            // Merge the value to the final message
        	parsedMessage = parsedMessage.replaceAll (fieldPttr, fieldValue == null? '': String.valueOf (fieldValue));
		}
        return parsedMessage;
	}*/
	

     /**
        Get value of field from an sObject record including the ones from relationship
        INPUT:
            obj: Single sObject that contains all the necessary merge fields  
            field: String that corresponds to a Single field. This is the API name of the field
        OUTPUT:
            Object type that represents the value of the field
    */
    /*
	public Object getValue (sObject obj, String field) {
        sObject retObj;
        Object val;
        
        // Check if the field is from a relationship
        if (field.contains('.')) {

            // Identify the relationships within the field
            List <String> tokens = field.split('\\.');
            
            // Iterate thru the join relationships
            for (Integer i = 0; i < tokens.size(); i++) {
                if (i == (tokens.size () - 1)) {
                    if (retObj != null){
                        val = retObj.get (tokens[i]);
                    }
                    else {
                        val = obj.get (tokens[i]);
                    }
                }
                else {
                    if (retObj == null) {
                    	retObj = obj.getSobject (tokens[i]);
                    }
                    else {
                        retObj = retObj.getSobject (tokens[i]);
                    }
                    
                    // Null relationship, break
                    if (retObj == null) {
                        break;
                    }
                }
            }
        }
        // Field is directly from the sObject (not a join)
        else {
        	val = obj.get (field);
        }
        
        return val;
    }	
    */

}