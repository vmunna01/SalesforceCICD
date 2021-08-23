import { LightningElement, track, api } from 'lwc';
import findRecords from '@salesforce/apex/CustomLookupController.findRecords';
export default class CustomLookup extends LightningElement {
    @track records = '';
    @track error = '';
    @track recentlisttitle = '';
    @api label = 'Record';
    @api placeholdertext = 'Search a record';
    @api selectedrecord = '';
    @api iconname = "standard:account";
    @api objectname = 'Account';
    @api searchfield = 'Name';

    handleOnchange(event) {
        this.recentlisttitle = 'Select ' + this.label+'s';
        const searchKey = event.detail.value;
        /* Call the Salesforce Apex class method to find the Records */
        findRecords({
            searchKey: searchKey,
            objectName: this.objectname,
            searchField: this.searchfield
        })
            .then(result => {
                this.records = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.records = undefined;
            });
    }

    handleSelect(event) {
        const selectedRecordId = event.detail;
        this.selectedrecord = this.records.find(record => record.Id === selectedRecordId);
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
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
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail: { recordId: undefined, recordName: undefined }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }


}