public class USPSAddressVerificationController {
    
    @AuraEnabled
    public static String doCallout(Id accountId){
        try {
            if(accountId == null){
                throw new MyException('Missing record id');
            }
            List<Account> accounts = [SELECT USPS_Response__c , Date_Time_Validated__c, Is_Valid_Address_For_USPS__c, BillingAddress FROM Account WHERE Id = :accountId];
            if(accounts.isEmpty() || String.isBlank(String.valueOf(accounts[0].BillingAddress))){
                throw new MyException('Could not find the account');
            }
            Address AddressToQuery = accounts[0].BillingAddress;
            String BaseURL = 'http://production.shippingapis.com/ShippingAPI.dll?API=Verify&XML=';
            String ReturnValue = '<AddressValidateRequest USERID="' + Label.USPS_UserId + '"><Address ID="0">';
            ReturnValue += '<Address1>' + AddressToQuery.Street + '</Address1>';
            ReturnValue += '<Address2>' +  + '</Address2>';
            ReturnValue += '<City>' + AddressToQuery.City + '</City>';
            ReturnValue += '<State>' + AddressToQuery.State + '</State>';
            ReturnValue += '<Zip5>' + AddressToQuery.PostalCode + '</Zip5>';
            ReturnValue += '<Zip4>' +  + '</Zip4>';		
            ReturnValue += '</Address></AddressValidateRequest>';
            
            ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8');
            
            ReturnValue = BaseURL + ReturnValue;
            /** http://production.shippingapis.com/ShippingAPI.dll?API=Verify
&XML=<AddressValidateRequest USERID="163DELOI1249"><Address ID="0"><Address1></Address1>
<Address2>2915 Wickersham Way</Address2><City>Falls Church</City><State>VA</State>
<Zip5></Zip5><Zip4></Zip4></Address></AddressValidateRequest>**/
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ReturnValue);
            req.setMethod('GET');
            
            HTTPResponse res = new Http().send(req);
            
            System.debug(res.getStatus());
            System.debug(res.getBody());
            String response = res.getBody();
            // no special parsing, just chuck it into Description field
            // no error handling
            if(res.getStatusCode() == 200){
                if(response.contains('Error')) {
                    Accounts[0].Is_Valid_Address_For_USPS__c = 'Not a Valid Address';
                } else {
                    Accounts[0].Is_Valid_Address_For_USPS__c = 'Valid Address';
                }
                Accounts[0].Date_Time_Validated__c = System.now();
                Accounts[0].USPS_Response__c = res.getBody();
                update Accounts;
            }
            return res.getBody();
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class MyException extends Exception{}
}