public with sharing class contactDetailsController {
	@AuraEnabled
    public static List<Contact> getContacts() {
        List<Contact> contacts =
                [SELECT id, Name, Status__c, Email FROM Contact Limit 30];
        //Add isAccessible() check
        return contacts;
    }

    @AuraEnabled
    public static List<Contact> saveStatus(List<String> contactList, String status) {
    	List<Contact> contactToUpdate = new List<Contact>();
    	for(String cId: contactList){
    		contactToUpdate.add(new contact(id=cid, Status__c=status));
    	}
    	if(!contactList.isEmpty())
    		update contactToUpdate;
    	return getContacts();
    }


    @AuraEnabled
    public static List<Contact> searchContact(String search) {
    	search = '%'+search+'%';
    	List<Contact> contacts =
                [SELECT id, Name, Status__c, Email FROM Contact 
                Where (Name Like : search 
                OR Status__c Like : search
                OR Email Like : search)];
        //Add isAccessible() check
        return contacts;
    }
}