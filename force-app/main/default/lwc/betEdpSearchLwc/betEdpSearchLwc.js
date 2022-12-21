import { LightningElement, track, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEdpSearchResult from '@salesforce/apex/BetBulkUploadLWCController.getEdpSearchResult';
import updateRecordWithOrbisData from '@salesforce/apex/BetBulkUploadLWCController.updateRecordWithOrbisData';
const DELAY = 300;
/*const columns = [
    { label: 'Name', fieldName: 'name', sortable: true },
    { label: 'Address Line 1', fieldName: 'addresS_LINE1', sortable: true}
];*/
const columns = [
    {label: 'Name', fieldName: 'name', type: 'text'},
    {label: 'Address Line 1', fieldName: 'addresS_LINE1', type: 'text'},
    {label: 'Address Line 2', fieldName: 'addresS_LINE2', type: 'text'},
    {label: 'Address Line 3', fieldName: 'addresS_LINE3', type: 'text'},
    {label: 'City', fieldName: 'city', type: 'text'},
    {label: 'State', fieldName: 'uS_STATE', type: 'text'},
    {label: 'Country', fieldName: 'country', type: 'text'},
    {label: 'Post Code', fieldName: 'postcode', type: 'text'},
    {label: 'Company ID', fieldName: 'companY_ID_NUMBER_Str', type: 'text'},
    {label: 'LEI', fieldName: 'lei', type: 'text'},
    {label: 'Reg ID', fieldName: 'tradE_REGISTER_NUMBER_Str', type: 'text'},
    {label: 'VAT Num', fieldName: 'vaT_NUMBER_Str', type: 'text'},
    {label: 'EU VAT Num', fieldName: 'europeaN_VAT_NUMBER', type: 'text'},
    {label: 'TIN', fieldName: 'tin', type: 'text'},
    {label: 'Trading Name', fieldName: 'akA_NAME_Str', type: 'text'},
    {label: 'Previous Name', fieldName: 'previouS_NAME_Str', type: 'text'}
    ];

export default class BetEdpSearchLwc extends LightningElement {
    @api recordId;
    @track placeholder = 'Enter Legal Name';
    @track searchstring = '';
    @api isLoading =false;
    @track showOrbisResultTable =false;
    @track orbisresult=[];
    columns = columns;
    
    handleSearchChange(event){
        this.searchstring = event.target.value;
     }

    calledpsearch(){
        this.showOrbisResultTable =false;
        this.isLoading =true;
        console.log('print recordId : '+this.recordId);
        console.log('print this.searchstring : '+this.searchstring);
        //call apex method imperatively 
        getEdpSearchResult({ formId:this.recordId, searchString: this.searchstring })
            .then(result => {
                    this.orbisresult = result;
                    console.log('orbisresult : '+this.orbisresult);
                    console.log('String orbisresult : '+JSON.stringify(this.orbisresult));
                    this.isLoading=false;
                    if(this.orbisresult.length>0) {
                        this.showOrbisResultTable =true;
                        const eventsuccess = new ShowToastEvent({
                            message: ''+this.orbisresult.length+' Matches found',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(eventsuccess);
                        //showNotification(''+this.orbisresult.length+' Matches found',"success");
                    }
                    else {
                        //showNotification('No Matches found',"error");
                        const eventnomatch = new ShowToastEvent({
                            message: 'No Matches found',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(eventnomatch);
                    }
            })
            .catch(error => {
                this.error = error;
                this.isLoading=false;
                console.log('### error : '+error);
                //showNotification('An error occured',"error");
                const eventerror = new ShowToastEvent({
                    message: 'An error occured',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(eventerror);
            });
            
    }
    
    updaterecord(){
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
      if(selectedRecords.length === 1){
          console.log('selectedRecords are ', selectedRecords);
          this.isLoading=false;
          updateRecordWithOrbisData({ formId:this.recordId, orbisRecord: selectedRecords[0] })
            .then(result => {
                    console.log('Update message: '+result);
                    this.isLoading=false;
                    if(result ==='success') {
                        this.showOrbisResultTable =true;
                        const eventsuccess = new ShowToastEvent({
                            message: 'Updated the record successfully.',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(eventsuccess);
                    }
                    else {
                        const eventnomatch = new ShowToastEvent({
                            message: 'An error occured '+result,
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(eventnomatch);
                    }
            })
            .catch(error => {
                this.error = error;
                this.isLoading=false;
                const eventerror = new ShowToastEvent({
                    message: 'An error occured : '+error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(eventerror);
            });
      } else {
        const eventNoselct = new ShowToastEvent({
            message: 'Please select a record from below table',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(eventNoselct);
      }
        
    }
}