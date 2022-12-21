import { LightningElement,track, api } from 'lwc';

import fetchcostoutputdata from '@salesforce/apex/RE_PH_OutputController.getCostingDataPH';
export default class Re_ph_plantbasedoutputdetail extends LightningElement {
    @api costList = [];
    @api plantName;
    @api dateData;
    @track costarray = [];
    @track loaded = false;
    @api
    fetchCostDetail(objElement,cbuOutput){   
        console.log('objElement-->',objElement);
        fetchcostoutputdata({plantName : objElement, isEGcost : cbuOutput})
        .then(result => {
            result.forEach(elem => {
                this.costarray.push(elem); 
            });            
            this.error = undefined;                  
            this.costList = this.costarray;

            console.log('this.costList  ->',this.costList);
        })
        .catch(error => {
            this.error = error;
            this.costList = undefined;
        }); 
    }
}