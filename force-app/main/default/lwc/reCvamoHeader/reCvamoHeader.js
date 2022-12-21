import { LightningElement,track,api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {updateRecord} from "lightning/uiRecordApi";
//import getRev_Covamo_Header from '@salesforce/apex/RE_CovamoController.getRev_Covamo_Header';
import getRev_Covamo_Header from '@salesforce/apex/RE_CovamoController.getCovHeaderDetails';
import searchRev_Covamo_Header from '@salesforce/apex/RE_CovamoController.searchRev_Covamo_Header';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReCvamoHeader extends  NavigationMixin (LightningElement) {
    @track resultvalset = [];
    @track covHeaderDataSet = [];
    @track urls;
    @api recordid;
    @api isAM;
    @track showSpinner = true;
    @track searchfilter='';


    connectedCallback(){
        this.genericsearch();
    }
  /*  @wire(getRev_Covamo_Header)
    loadData({error,data}){
        if(data){
            this.resultvalset= JSON.parse(data);
            var covHeadDataDraft = [];
            var covHeadDataSubmit = [];
            var totalData = [];
            console.log("this.resultvalset---",this.resultvalset);
            for(let i=0;i<this.resultvalset.length;i++){
                if(this.resultvalset[i].Status__c == "In-Draft"){
                    covHeadDataDraft.push(this.resultvalset[i]);                    
                }else if(this.resultvalset[i].Status__c == "Submitted"){
                    covHeadDataSubmit.push(this.resultvalset[i]);
                }
            }
            if(covHeadDataDraft.length !=0)
            totalData.push({"showEdit":true,"vals":covHeadDataDraft});
            if(covHeadDataSubmit.length !=0)
            totalData.push({"showEdit":false,"vals":covHeadDataSubmit});
            this.covHeaderDataSet = totalData;
            console.log("covHeaderDataSet -- ",JSON.stringify(this.covHeaderDataSet));
            
            this.showSpinner = false;
        }
        if(error){
            //
        }
    } */
    searchList(event){
        console.log("search value",event.target.value);
        var searchList = [];
        if((event.target.value).length >= 3){
            console.log("inside if");
            this.searchfilter   =  event.target.value; 
            this.searchMethod(this.searchfilter);
        }else
        {
            this.searchMethod('');
        }
    }
    searchMethod(searchKeyword){
        searchRev_Covamo_Header({searchText: searchKeyword})
        .then(result=>{
                console.log("success searchRev_Covamo_Header",JSON.stringify(result));
                this.resultvalset= result;
                console.log("this.resultvalset 3---",JSON.stringify(this.resultvalset));
            })
            .catch(error=>{
                console.log("error searchRev_Covamo_Header");
                
            });
    }
    /*
  connectedCallback(){
    getRev_Covamo_Header()
    .then(result=>{
        this.resultvalset = JSON.parse(result);
    })
  }*/
  opendata(event){
    var key = (event.target.id).split('-')[0];
    this.recordid=key;
    var url= '/lightning/r/Rev_Covamo_Header__c/'+key+'/view';
    window.open(url,"_blank");
    /*
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: key,
            objectApiName: 'Rev_Covamo_Header__c',
            actionName: 'view'
            //url: '/lightning/r/Rev_Covamo_Header__c/'+key+'/view'
        }
    })*/
  }
  openEdit(event){
    console.log("check url--",event.target.dataset.id);
    var url= '/lightning/r/Rev_Covamo_Header__c/'+event.target.dataset.id+'/edit';
    window.open(url,"_blank");
    
}
genericsearch(){
    getRev_Covamo_Header()
        .then(result=>{
            console.log("result---",JSON.stringify(result));
            this.resultvalset=result;
            this.showSpinner = false;
        })
        .catch(error=>{
            //
        });
}  
    discardcontract(event){
        var keyid = event.target.id.split('-')[0];
        const recordInput={fields:{
            Id:keyid,
            Status__c:'Discard'           
        },};
        updateRecord(recordInput)
        .then(result=>{
            const event = new ShowToastEvent({
                title: 'success',
                variant:'success',
                message: 'Covamo Discarded Successfully.'
            });

            this.dispatchEvent(event);
            if(this.searchfilter!='' && this.searchfilter!=null && this.searchfilter!=undefined){
                this.searchMethod(this.searchfilter);
            }else{
                this.genericsearch();
            }
            

            
        })
        .catch(error=>{

        });
    }
}