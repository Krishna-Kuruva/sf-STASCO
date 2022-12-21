import { LightningElement,api,track } from 'lwc';
import marginalspiration from '@salesforce/apex/RE_SingaporeOutputController.marginalspiration';
/*eslint-disable no-console*/
 /*eslint-disable no-alert*/ 
 
export default class Re_sg_middayAspiration extends LightningElement {
    @track mymaList=[];
    @api showhaderval = 'true';
    @api isMidDayVal     = 'true';
    @track showhader;
    connectedCallback(){
        this.showhader = this.showhaderval === 'true' ? true : false;
        marginalspiration({IsMidday : this.isMidDayVal  === 'true' ? true : false})
        .then(result => {
            this.mymaList  = result; 
            this.error = undefined;              
        })        
        .catch(error => {
            this.error = error;
            this.mymaList = undefined;
        });
        console.log('result ', JSON.stringify(this.mymaList));
    }
}