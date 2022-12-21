import { LightningElement, wire, track, api } from 'lwc'; 
import gainLossDetails from '@salesforce/apex/RE_GainLossController.gainLossDetails'; 
import getMopsProducts from '@salesforce/apex/RE_GainLossController.getMopsProducts';
import fetchGainLossData from '@salesforce/apex/RE_GainLossController.fetchGainLossData';
import setTemparature from '@salesforce/apex/RE_MalayasiaOutputController.getMOPSData';
//import MTD_Search_Filter from '@salesforce/label/c.MTD_Search_Filter';
/*eslint-disable no-console*/
 /*eslint-disable no-alert*/
const gainlosscolumns = [
    {label: 'Mops', fieldName: 'mopsdata', type: 'text'},
    {label: 'Weekly Difference', fieldName: 'weeklydifference', type: 'number', typeAttributes:{maximumFractionDigits:2}},
    {label: 'Monthly Difference', fieldName: 'monthlydifference', type: 'number', typeAttributes:{maximumFractionDigits:2}},
];

const columns = [
    { label: 'Label', fieldName: 'liftingDate' },
    { label: 'Weeks', fieldName: 'weeks'},
    { label: 'W-1', fieldName: 'week_1', type: 'number',typeAttributes: { maximumFractionDigits: 2}},
    { label: 'Differences', fieldName: 'Differences', type: 'number',typeAttributes: { maximumFractionDigits: 2}},
    { label: 'Position', fieldName: 'Position'},
];

export default class Re_gain_loss extends LightningElement {
   /* label = {
        MTD_Search_Filter,
    };*/
    @track columns = columns;
    @api filters;
    @api country;
    @track gainlosscolumns=gainlosscolumns;
    @track monthavgs;
    @track weeklydiff;
    @track monthlydiff;
    @track gainWrapperList;
    @track mtdposition=0;
    @track temperature_Gain_USD ;
    @track temperature_Gain_MYR ;
    

    @track test2="test2";
    //filters= this.label.MTD_Search_Filter;

    connectedCallback(){
        setTemparature()
        .then(result =>{
            console.log('data in ---'+JSON.stringify(result));
            console.log('data in ---'+result[0].temperatureMYRCTSL);
            this.temperature_Gain_USD = result[0].temperature;
            this.temperature_Gain_MYR = result[0].temperatureMYRCTSL; 
        })
        .catch(error=>{
            console.log('error in mops Data --'+JSON.stringify(error)); 
        })
    }
   
    @wire (gainLossDetails,{searchFilter:'$filters',Country:'$country'})  
    load({data, error}){
        this.gainWrapperList={data, error};
        if(data){
            console.log('data is '+data);
            if(data[0] != undefined){
                this.monthavgs=data[0]['monthAverage'];
            }
            for(let i in data){
                if(data[i] != undefined){
                this.mtdposition += data[i]['Differences'];
                }
            }
            
        }
        
        
    }
    
    
    //.data[0]['monthAverage'];
    @wire (getMopsProducts)
    productLists;
    
    @wire(fetchGainLossData,{searchFilter:'$filters',Country:'$country'}) 
    gainlossData({data,error}){
        if(data){
            console.log('data[0]  '+data[0]);
            if(data[0] != undefined){
                this.weeklydiff  = data[0]['weeklydifference'];
                this.monthlydiff = data[0]['monthlydifference'];
            }
        }
        if(error){
            //
        }
    }

    
    setSelValue(event){
        
        this.filters= event.target.value;
        
    }
    /*({data,error}){
        if(data){
            //
            alert('same '+data);
            alert('same1 '+getFieldValue(data,prod_name));
           // alert('same2 '+data[0].GainLossWrapper.liftingDate);
            
        }
        if(error){
            alert('error '+error);
            //
        }
    }*/
    @track prodMap = [];
    @wire (getMopsProducts)
    getproductLists;
}