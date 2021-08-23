/*
 * Class Name: TestUtility
 * Description: This class contains generic methods that are common for running test classes. Please be careful when 
 * 				changing method signatures and logic as these methods maybe used all over the place.
 * Author: Frederick Valle
 * CreatedDate: Oct 30, 2019
 * 
 * Modification History: (Date, Name, Description)
*/

@isTest
public class TestUtility {
    
    /*
     * Description: Retrieve all RecordTypeIDs for given objects using the ObjectName and RecordType.DeveloperName as the Key to retrieve the IDs
     * Sample Usage: 
	 		map <String, map <String, Id>> rtMap = getObjRecordTypeIds (new set <String> {'Case', 'Account'});
			Id accountSellerServiceRecordTypeId = rtMap.get('Account').get ('Seller_Servicer');
	*/
	public static map <String, map <String, Id>> getObjRecordTypeIds (set <String> objSet) {
        map <String, map <String, Id>> rMap = new map <String, map <String, Id>> ();
        
        for (RecordType r: [Select sObjectType, DeveloperName From RecordType Where sObjectType IN: objSet]) {
            if (rMap.get (r.sObjectType) == null) {
                rMap.put (r.sObjectType, new map <String, Id> ());
            }
            
            rMap.get (r.sObjectType).put (r.DeveloperName, r.Id);
        }
        return rMap;
    }
    
    /*
     * Description: Retrieve specific Queue IDs or all Queue IDs depending on the input parameter. Key = Queue Name/DeveloperName, Value ID. 
                    If useAPINameAsKey == true, use DeveloperName, otherwise use Label. 
                    Default signature is to use DeveloperName if useAPINameAsKey is not passed as a parameter.
     * Sample Usage: 
			map <String, Id> qMap = getQueueId (new set <String> {'ECU-Escalations', 'Short Sales Inquiries', 'IRCC - EDR'}, false);
			Id queueID = qMap.get ('ECU-Escalations');
	*/
    public static map <String, Id> getQueueId (set <String> qSet, boolean useAPINameAsKey) {
        return getGroup (qSet,useAPINameAsKey, GroupType.TYPEQUEUE);
    }
    
    public static map <String, Id> getQueueId (set <String> qSet) {
        return getGroup (qSet, true, GroupType.TYPEQUEUE);
    }

    /*
     * Description: Retrieve specific Group IDs or all Group IDs depending on the input parameter. Key = Group Name/DeveloperName, Value ID
                    If useAPINameAsKey == true, use DeveloperName, otherwise use Label.
                    Default signature is to use DeveloperName if useAPINameAsKey is not passed as a parameter.
     * Sample Usage: 
			map <String, Id> qMap = getGroupId (new set <String> {'BEMI', 'CAN All Knowledge Users', 'All Non-CRT and Non-ALAC'}, false);
			Id groupID = qMap.get ('BEMI');
	*/
    public static map <String, Id> getGroupId (set <String> gSet, boolean useAPINameAsKey) {
        return getGroup (gSet,useAPINameAsKey, GroupType.TYPEGROUP);
    }

    public static map <String, Id> getGroupId (set <String> gSet) {
        return getGroup (gSet, true, GroupType.TYPEGROUP);
    }
    
    /*
     * Description: Common routine to query Group Object 
     * Sample Usage: 
			For TestUtility internal use only. 
	*/
    private static map <String, Id> getGroup (set <String> qSet, boolean useAPINameAsKey, GroupType grpType) {
        map <String, Id> retMap = new map <String, Id> ();
        
        String gType = grpType == GroupType.TYPEQUEUE ? 'Queue': 'Group';
        String keyField = useAPINameAsKey == true? 'DeveloperName': 'Name';
        String whereClause = qSet == null? '': ' And ' + keyField + ' IN: qSet';
        for (sObject g: database.query ('Select ' + keyField + ' From Group Where Type = \'' + gType + '\' ' + whereClause)) {
            retMap.put (String.valueOf (g.get(keyField)), g.Id);
        }
        return retMap;
    }

    private enum GroupType {TYPEQUEUE, TYPEGROUP}

    /**
        Description: Get Profile IDs
     */
     public static map <String, Id> getProfileIDs () {
        map <String, Id> retMap = new map <String, Id> ();
        for (Profile p: [Select Name From Profile]) {
            retMap.put (p.Name, p.Id);
        }
        return retMap;
     }
}