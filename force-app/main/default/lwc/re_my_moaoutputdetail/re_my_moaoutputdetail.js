import { LightningElement,track, wire, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchAMVoutputdata from '@salesforce/apex/RE_MY_AMVCalculationController.fetchAMVoutputdata';
import submitForApproval from '@salesforce/apex/RE_MY_AMVCalculationController.submitForApproval';

export default class Re_my_moaoutputdetail extends LightningElement {
    @api amvList = [];
    @api prodName;
    @track amvarray = [];
    @track loaded = false;
    @api
    fetchAMVDetail(objElement){   
        console.log('objElement-->',objElement);
        fetchAMVoutputdata({prodName : objElement})
        .then(result => {
            result.forEach(elem => {
                this.amvarray.push(elem); 
            });            
            this.error = undefined;                  
            this.amvList = this.amvarray;

            console.log('this.amvList  ->',this.amvList);
        })
        .catch(error => {
            this.error = error;
            this.amvList = undefined;
        }); 
    }
    
    handleRemarkChange(event){
        const tempvar = event.target.value;
        this.amvList.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_AM_Comments__c = tempvar;                 
            }             
        });
    }
    handleAMPriceChange(event) {        
        const tempvar = event.target.value;
        this.amvList.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_AM_Challenged_Price__c = tempvar;                 
            }             
        });
    }
    connectedCallback(){
      
    }
    
    handleChallenge(event){
        this.loaded = true;
        var moaTemp;
        var RE_AM_ChallengedPrice;
        var RE_Final_PSP;
        this.amvList.forEach(function(element, index){                   
            if(element.Id === event.target.name) {
                moaTemp= element; 
                console.log('Challenge price testitt'+element.RE_AM_Challenged_Price__c);
                console.log('RE_Final_PSP__c value'+element.RE_Final_PSP__c); 
                RE_AM_ChallengedPrice =  element.RE_AM_Challenged_Price__c; 
                RE_Final_PSP =element.RE_Final_PSP__c;

            }             
        });
        if(RE_Final_PSP === undefined){
            this.loaded = false;
            const eventtestign = new ShowToastEvent({
                title: 'Final PSP value is empty',
                message: 'A record cannot submit for Approval Process',
                variant: 'error'
                });
                this.dispatchEvent(eventtestign);
        }
        else if(RE_AM_ChallengedPrice === undefined){
                    this.loaded = false;
                    const eventtestign = new ShowToastEvent({
                        title: 'AM Challenged price',
                        message: 'Please enter AM Challenged price',
                        variant: 'error'
                        });
                        this.dispatchEvent(eventtestign);
                }
        else{
            this.amvList.forEach(function(element, index){               
                if(element.Id ===  moaTemp.Id){
                    element.RE_isDisabled__c = true;
                }}
            );
            submitForApproval({datToApprovalProcess:moaTemp})
            .then(res =>{
                console.log('successs',res);
                this.loaded = false;
                const eventtestign = new ShowToastEvent({
                    title: 'Success Title',
                    message: 'Sccussfully Challenged',
                    variant: 'success'
                });
                this.dispatchEvent(eventtestign);                
            })
            .catch(err =>{
                this.loaded = false;
                console.log('error dataaa---'+JSON.stringify(err.body.message));
                const eventtestign = new ShowToastEvent({
                    title: 'Error occurred while processing',
                    message: err.body.message,
                    variant: 'error'
                    });
                    this.dispatchEvent(eventtestign);
                                    
            });
            
        }
    }


}