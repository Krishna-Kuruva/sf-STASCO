/* eslint-disable no-unused-vars */
/* eslint no-console: ["error", { allow: ["log", "error"] }] */
import { LightningElement,track, wire, api} from 'lwc';
 
import fetchMC0Data from '@salesforce/apex/RE_GainLossClass.fetchMC0Data';
import updateRecords from '@salesforce/apex/RE_GainLossClass.updateRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RE_MC0_Dip extends LightningElement {
    @track myList = [];
    @track toggleSaveLabel = 'Save';
    @api updateddata;
    getMC0data(){
        fetchMC0Data()
        .then(result => {
            this.myList  = result; 
            this.error = undefined;  
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
        });
    }       
    
    handlemornvalueChange(event) {
        console.log('event.target  '+event.target.value);               
        const tempvar = event.target.value;
        this.myList.forEach(function(element){
            element.RE_Morning_MC0_Value__c = tempvar; 
        });
    }

    handlemornvalidfromChange(event){
        console.log('event.target  '+event.target.value);               
        const tempvar = event.target.value;
        this.myList.forEach(function(element){
            element.RE_Morning_MC0_Valid_From__c = tempvar; 
        });
    }
    
    handlemornvalidtoChange(event){
        console.log('event.target  '+event.target.value);               
        const tempvar = event.target.value;
        this.myList.forEach(function(element){
            element.RE_Morning_MC0_Valid_To__c = tempvar; 
        });
    }

    handlemidvalueChange(event) {
        console.log('event.target  '+event.target.value);               
        const tempvar = event.target.value;
        this.myList.forEach(function(element){
            element.RE_Midday_MC0_Value__c = tempvar; 
        });
    }

    handlemidvalidfromChange(event){
        console.log('event.target  '+event.target.value);               
        const tempvar = event.target.value;
        this.myList.forEach(function(element){
            element.RE_Midday_MC0_Valid_From__c = tempvar; 
        });
    }
    
    handlemidvalidtoChange(event){
        console.log('event.target  '+event.target.value);               
        const tempvar = event.target.value;
        this.myList.forEach(function(element){
            element.RE_Midday_MC0_Valid_To__c = tempvar; 
        });
    }

    handleSave() {
        this.toggleSaveLabel = 'Saving...'
        let toSaveList = this.myList;
        updateRecords({mc0List : toSaveList})
        .then(() => {
         //   this.toggleSaveLabel = 'Saved';
         this.dispatchEvent(new CustomEvent('refreshview',{details:{message:'Records saved succesfully!'}}));
  
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : `Records saved succesfully!`,
                    variant : 'success',
                }),
                this.toggleSaveLabel = 'Save'
            )
            this.getMC0data();
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
            console.log("Error in Save call back:", this.error);
        });
    }
    connectedCallback() {
        this.getMC0data();
    }
    handleCancel() {
        this.getMC0data();
    }
}