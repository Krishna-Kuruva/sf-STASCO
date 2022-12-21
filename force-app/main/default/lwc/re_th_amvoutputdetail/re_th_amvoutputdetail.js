import { LightningElement,track, wire, api} from 'lwc';   

import fetchAMVTHoutputdata from '@salesforce/apex/RE_TH_AMVCalculationController.fetchAMVTHoutputdata';
import RE_EditLandingPage from '@salesforce/customPermission/RE_EditLandingPage';
export default class re_th_amvoutputdetail extends LightningElement {
    @api amvList = [];
    @api prodName;
    @track amvarray = [];
    
    @api
    fetchAMVDetail(objElement){        
        fetchAMVTHoutputdata({prodName : objElement})
        .then(result => {
            result.forEach(elem => {
                this.amvarray.push(elem); 
                console.log('child-result ',result);
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
        console.log('element-->',tempvar);
        this.amvList.forEach(function(element, index){
            console.log('element-->',tempvar);
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
    get hasReadAccess(){
        return RE_EditLandingPage;
    }
    connectedCallback(){
        console.log('RE_EditLandingPage', RE_EditLandingPage);
    }
}