/* eslint-disable no-unused-vars */
/* eslint no-console: ["error", { allow: ["log", "error"] }] */
import { LightningElement,track, wire, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSingOutput from '@salesforce/apex/RE_SingaporeOutputController.getSingOutput';
import fetchMarketQuoteMidday from '@salesforce/apex/RE_SingaporeOutputController.fetchMarketQuoteMidday';
import updateMiddayRecords from '@salesforce/apex/RE_SingaporeOutputController.updateMiddayRecords';
import fetchMiddayTemperatureGain from '@salesforce/apex/RE_SingaporeOutputController.fetchMiddayTemperatureGain';

export default class Re_sg_middaypricingoutput extends NavigationMixin (LightningElement) {
    @track myList = [];
    @track mymaList = [];
    @track mymqList = [];
    @track isdisabled = false;
    @track MOPSDetails = [];

    getmiddaydata(){
        getSingOutput({type : 'SG Midday Output'})
        .then(result => {
            this.myList  = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.myList = undefined;
        });

        fetchMiddayTemperatureGain()
        .then(result => {
          this.MOPSDetails  = result;
          this.error = undefined;
        })
        .catch(error => {
          this.error = error;
          this.MOPSDetails = undefined;
        });
    }

    marketquotedata(){
        fetchMarketQuoteMidday()
        .then(result => {
            this.mymqList  = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.mymqList = undefined;
        });
    }

    handlemarketpriceChange(event) {
        const tempvar = event.target.value;
        this.mymqList.forEach(function(element, index){
            if(element.Id === event.target.name) {
                element.RE_Price__c = tempvar;
            }
        });
    }

    handleSave() {
        this.isdisabled = true;
        this.toggleSaveLabel = 'Saving...'
        let toSaveList = this.mymqList;
        updateMiddayRecords({midmqlist : toSaveList})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : `Records saved succesfully!`,
                    variant : 'success',
                }),
            )
            this.dispatchEvent(new CustomEvent('refreshview',{details:{message:''}}));
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
            console.log("Error in Save call back:", this.error);
        });
    }

    handleMail() {
        //var url = '/apex/RE_MidDayMail';
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/RE_SG_MidDayMail'
            }
        })
    }

    connectedCallback() {
        this.getmiddaydata();
        this.marketquotedata();
    }
    handleCancel() {
        this.marketquotedata();
    }
}