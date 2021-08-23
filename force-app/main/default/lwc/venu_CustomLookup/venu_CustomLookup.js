import { LightningElement, api } from 'lwc';

export default class Venu_CustomLookup extends LightningElement {
    
    @api LWCSelectedAccountRecord='';
    @api LWCSelectedContactRecord='';
    @api AccountId='';
    @api AccountName='';
    @api ContactId='';
    @api ContactName='';

    get LWCSelectedAccountRecord() {  
        return {Id: this.AccountId, Name: this.AccountName};
    }

    get LWCSelectedContactRecord() {  
        return {Id: this.ContactId, Name: this.ContactName};
    }

    handleSelectedRecAccount(event){
        this.AccountId = event.detail.recordId;
        this.AccountName = event.detail.recordName;
        if(!this.AccountId) {
            this.ContactId = undefined;
            this.ContactName = undefined;
        }
    }

    handleSelectedRecContact(event){
        this.ContactId = event.detail.recordId;
        this.ContactName = event.detail.recordName;
    }

    @api
    validate() {
        if(!this.AccountId)
        {  
            return { isValid: false, 
                    errorMessage: 'Please select Client' }; 
        }
        if(this.AccountId && !this.ContactId)
        {  
            return { isValid: false, 
                    errorMessage: 'Please select Client Point of Contact' }; 
        }
        return {isValid: true};
    }
}