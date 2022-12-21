/* eslint-disable no-unused-vars */
/* eslint no-console: ["error", { allow: ["log", "error"] }] */
import { LightningElement,track, wire, api} from 'lwc';
import fetchMidDayOutput from '@salesforce/apex/RE_MidDayPricingController.fetchMidDayOutput';
import updateMiddayRecords from '@salesforce/apex/RE_MidDayPricingController.updateMiddayRecords';
import fetchActSrcData from '@salesforce/apex/RE_MidDayPricingController.fetchActSrcData';
import recalculateMidDayOutput from '@salesforce/apex/RE_MidDayPricingController.recalculateMidDayOutput';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Re_middaypricingoutput extends NavigationMixin (LightningElement) {
    @track myListEM = [];
    @track myListPM = [];
    @track toggleSaveLabel = 'Save';
    @api updateddata;
    @track actsrc = [];
     
    getmiddaydata(){
        fetchMidDayOutput({region : 'EM'})
        .then(result => {
            this.myListEM  = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
        });

        fetchMidDayOutput({region : 'PM'})
        .then(result => {
            this.myListPM  = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
        });

        fetchActSrcData()
        .then(result => {
           this.actsrc  = result;
           this.error = undefined;
        })
        .catch(error => {
           this.error = error;
           this.record = undefined;
        });
    }

    handlemarketpriceChange(event) {
        const tempvar = event.target.value;
        this.myListEM.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_Market_Price__c = tempvar;
            }
        });
    }
    handleshellpriceChange(event) {
        const tempvar = event.target.value;
        let actsrcdata = this.actsrc;
        let myListEMupdated = this.myListEM;
        this.myListEM.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_Shell_Price__c = tempvar;
                actsrcdata.forEach(function(element1, index1){
                    if(element1.RE_Actual_Source__c ===  element.RE_Depot__c &&
                    element1.RE_Actual_Product__c === element.RE_Product__c &&
                    element.RE_Shell_Price__c != null){
                        myListEMupdated.forEach(function(element2, index2){
                            if(element1.RE_Target_Source__c === element2.RE_Depot__c &&
                            element1.RE_Target_Product__c === element2.RE_Product__c){
                                element2.RE_Shell_Price__c = parseFloat(element.RE_Shell_Price__c) + parseFloat(element1.RE_Actual_Difference__c);
                            }
                        });
                    }
                });
            }
        });
        this.myListEM = myListEMupdated;
    }
    handlemarketpriceChangePM(event) {
        const tempvar = event.target.value;
        this.myListPM.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_Market_Price__c = tempvar;
            }
        });
    }
    handleshellpriceChangePM(event) {
        const tempvar = event.target.value;
        let actsrcdata = this.actsrc;
        let myListPMupdated = this.myListPM;
        this.myListPM.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_Shell_Price__c = tempvar;
                actsrcdata.forEach(function(element1, index1){
                    if(element1.RE_Actual_Source__c ===  element.RE_Depot__c &&
                    element1.RE_Actual_Product__c === element.RE_Product__c &&
                    element.RE_Shell_Price__c != null){
                        myListPMupdated.forEach(function(element2, index2){
                            if(element1.RE_Target_Source__c === element2.RE_Depot__c &&
                            element1.RE_Target_Product__c === element2.RE_Product__c){
                                element2.RE_Shell_Price__c = parseFloat(element.RE_Shell_Price__c) + parseFloat(element1.RE_Actual_Difference__c);
                            }
                        });
                    }
                });
            }
        });
        this.myListPM = myListPMupdated;
    }
    handleSave() {
        this.toggleSaveLabel = 'Saving...'
        let toSaveList = this.myListEM.concat(this.myListPM);
        updateMiddayRecords({mc0List : toSaveList})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : `Records saved succesfully!`,
                    variant : 'success',
                }),
                this.toggleSaveLabel = 'Save'
            )
            this.getmiddaydata();
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
            console.log("Error in Save call back:", this.error);
        });
    }
    connectedCallback() {
        this.getmiddaydata();
    }
    handleCancel() {
        this.getmiddaydata();
    }
    handlePMMail() {
        //var url = '/apex/RE_MidDayMail';
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/RE_MidDayMail'
            }
        })
    }
    handleEMMail() {
        //var url = '/apex/RE_MidDayMail';
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/RE_MYMidDayMailEM'
            }
        })
    }

    handlerecalculate(){
        this.toggleSaveLabel = 'Recalculating...';
        recalculateMidDayOutput()
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Success',
                        message : `Recalculated succesfully!`,
                        variant : 'success',
                    }),
                    this.toggleSaveLabel = 'Save'
                )
                this.getmiddaydata();
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.record = undefined;
                console.log("Error in Save call back:", this.error);
            });
    }
}