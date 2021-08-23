import { LightningElement, api, track } from 'lwc';

export default class SearchComponent extends LightningElement {
    @api label = 'Record';
    @track searchKey = '';
    @api placeholdertext = 'Search a record';

    handleChange(event){
        /* eslint-disable no-console */
        const searchKey = event.target.value;
        event.preventDefault();
        const searchEvent = new CustomEvent(
            'change', 
            { 
                detail : searchKey
            }
        );
        this.dispatchEvent(searchEvent);
    }
}