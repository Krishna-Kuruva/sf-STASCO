import { LightningElement,track, wire, api} from 'lwc';   

import fetchAMVoutputdata from '@salesforce/apex/RE_MY_AMVCalculationController.fetchAMVoutputdata';
import RE_EditLandingPage from '@salesforce/customPermission/RE_EditLandingPage';
export default class Re_my_amvoutputdetail extends LightningElement {
    @api amvList = [];
    @api prodName;
    @track amvarray = [];

    @api
    fetchAMVDetail(objElement){
        fetchAMVoutputdata({prodName : objElement})
        .then(result => {
            result.forEach(elem => {
                this.amvarray.push(elem);
            });
            this.error = undefined;
            this.amvList = this.amvarray;
        })
        .catch(error => {
            this.error = error;
            this.amvList = undefined;
        });
    }

    handlePSPChange(event) {
        const tempvar = event.target.value;
        let elementdata;
        this.amvList.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_Final_PSP__c = tempvar;
                console.log('element-->',element);
                elementdata = element;
            }
        });
        event.preventDefault();
        const selectedevent = new CustomEvent('pspchanged', { detail: elementdata});
        this.dispatchEvent(selectedevent);
    }

    handleRemarkChange(event){
        const tempvar = event.target.value;
        let elementdata;
        this.amvList.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_Remark__c = tempvar;
                console.log('element-->',element);
                elementdata = element;
            }
        });
        event.preventDefault();
        const selectedevent = new CustomEvent('pspchanged', { detail: elementdata});
        this.dispatchEvent(selectedevent);
    }

    handlePantprice(event){
        const tempvar = event.target.value;
        let elementdata;
        this.amvList.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_Price_Value__c = tempvar;     
                console.log('element-->',element);
                elementdata = element;                
            }             
        });   
        event.preventDefault();
        const selectedevent = new CustomEvent('pspchanged', { detail: elementdata});
        this.dispatchEvent(selectedevent); 
    }
    get hasReadAccess(){
        return RE_EditLandingPage;
    }
    connectedCallback(){
        console.log('RE_EditLandingPage', RE_EditLandingPage);
    }
}