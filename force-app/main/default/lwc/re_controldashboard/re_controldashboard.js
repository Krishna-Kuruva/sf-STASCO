import { LightningElement } from 'lwc'; 
import getData from '@salesforce/apex/RE_ControlDashboard.getData';
import getAutomatedJobs from '@salesforce/apex/RE_ControlDashboard.getAutomatedJobs';
import getJobsMetaData from '@salesforce/apex/RE_ControlDashboard.getJobsMetaData';

export default class Re_controldashboard extends LightningElement {

    pageName = 'Control Dashboard';
    showHideAccordian = true;
    pageRefreshInterval;
    pageRefreshedAt;
    showSectionData;
    mopsDataMY = [];
    mopsDataPH = [];
    mopsDataSG = [];
    showbatchSectionData;
    batchrundatal = [];
    batchrundatar = [];
    malaysiaList = [];
    philippinesList = [];
    singaporeList = [];
    pageRefreshInterval = 50;
    pageRefreshedAt = '';
    batchJobsListOne = [];
    batchJobsListTwo = [];
    batchType = {
                // 'Malaysia Output' : '',
                // 'MY Customer Opps CBU' : '',
                // 'MY Export Report' : '',
                // 'Singapore Output' : '',
                // 'SG Midday Output' : '' ,
                // 'CustomerOps Output' : '',
                // 'Philippines Output' : '',
                // 'New Contract Pricing Output' : ''
            }

    connectedCallback(){
        let context = this;
      //  this.handleData();
        this.getMetaData();
        setInterval(function () { 
            var currentdate = new Date(); 
            context.pageRefreshedAt = currentdate.getHours() + " : "  + currentdate.getMinutes() + " : " + currentdate.getSeconds();
            context.handleData();
            }, this.pageRefreshInterval * 1000);
    }

    getMetaData(){
        getJobsMetaData().then(result => {
                for(let item in result){
                    this.batchType[item] = result[item];
                }
                  this.handleData();
        }).catch(error=> {
            console.error(error);
        })
    }

    handleData(){
         getData().then(response =>{
           let result = JSON.parse(response);
           console.log(result);
           this.malaysiaList = Object.keys(result.malaysia).map(key => ({key : key, value : result.malaysia[key]}));
           this.philippinesList = Object.keys(result.philippines).map(key => ({key : key, value : result.philippines[key]}));
           this.singaporeList = Object.keys(result.singapore).map(key => ({key : key, value : result.singapore[key]}));
        }).catch(error =>{
            console.error(error);
        });

        getAutomatedJobs().then(response =>{
            console.log('response',response);
           

                for(let i in this.batchType){
                    if(!response[i]){
                        response[i] = {CountryName: this.batchType[i],CreatedDate: "-",IsSuccess: false,Name: i,color: "black",icon:false};
                    }else{
                      response[i].color = response[i].IsSuccess ? 'green' : 'red'; 
                      response[i].icon = true;
                      response[i].CountryName = this.batchType[i];
                    }
                }
             console.log('response',response);
             let list =   Object.values(response);
             this.batchJobsListOne = list.splice(0,5);
             this.batchJobsListTwo = list.splice(0,5);
       
             console.log(this.batchJobsList);
            }).catch(error =>{
            console.error(error);
        });
    }

    handleAccordionOne(event){
     let className = 'item-'+event.currentTarget.dataset.value;
     let element = this.template.querySelectorAll('.item');
        if(element.length){
        for(let item of element){
        if(item.classList.contains(className)){
            if(!item.classList.contains('slds-is-open')){
                item.classList.add('slds-is-open');
            }else{
                  item.classList.remove('slds-is-open');
            }
        }
        }
        }
        console.log(event.currentTarget.dataset.value);
        this.showHideAccordian = !this.showHideAccordian;
    }
}