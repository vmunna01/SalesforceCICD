import { LightningElement, track, api } from 'lwc';
import findRecordsById from '@salesforce/apex/CustomLookupController.findRecordsById';
export default class CustomLookup extends LightningElement {
    @track recordsById = '';
    @track error = '';
    @api label = 'Record';
    @api placeholdertext = 'Search a record';
    @api selectedrecord = '';
    @api iconname = "standard:account";
    @api objectname = 'Contact';
    @api searchfield = 'Name';
    @api lookupfield = 'AccountId';
    @api lookupsearchid = '';
    @api junctionobject='AccountContactRelation';
    @api idtosearch='ContactId';

    handleOnchange(event) {
        
        const searchKey = event.detail.value;
        /* Call the Salesforce Apex class method to find the Records */
        findRecordsById({
            searchKey: searchKey,
            objectName: this.objectname,
            searchField: this.searchfield,
            lookupField: this.lookupfield,
            relatedId: this.lookupsearchid,
            junctionObject: this.junctionobject,
            idToSearch: this.idtosearch
        })
            .then(result => {
                this.recordsById = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.recordsById = undefined;
            });
    }

    handleSelect(event) {
        const selectedRecordId = event.detail;
        this.selectedrecord = this.recordsById.find(record => record.Id === selectedRecordId);
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrecbyid",
            {
                //detail : selectedRecordId
                detail: { recordId: selectedRecordId, recordName: this.selectedrecord.Name }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRemove(event) {
        event.preventDefault();
        this.selectedRecord = undefined;
        this.recordsById = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrecbyid",
            {
                detail: { recordId: undefined, recordName: undefined }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }


}