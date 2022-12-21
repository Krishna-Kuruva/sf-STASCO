import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PHDataWrapper from '@salesforce/apex/RE_PH_OutputController.getInitParameterDetails';
import jobExecute from '@salesforce/apex/RE_MalayasiaOutputController.jobExecute';
import USER_ID from '@salesforce/user/Id'; 
import { NavigationMixin } from 'lightning/navigation';
import maxRunCountMethod from '@salesforce/apex/RE_PH_OutputController.maxRunCountMethod' 
import fetchPlantdata from '@salesforce/apex/RE_PH_OutputController.fetchPlantdata';

export default class Re_PH_OutputScreen extends NavigationMixin (LightningElement) {
    @track validProfile;
    @track lastModifiedDate;
    @track mopsData =[];
    @track fxData=[];
    @track ldcCostData = [];
    @track dateData = [];
    @track bioquote =   [];
    @track dateToday = new Date();
    @track todaysdate = this.dateToday.getDate() + '/' + (this.dateToday.getMonth()+1) + '/' + this.dateToday.getFullYear();
    @track isRecalculate;
    @track jobcount;
    @track recalculatecount;
    @track showSpinner = false;
    @track plantList = [];
    @track plantoptions = [];
    @track selectedplantList = [];
    @track costList = [];
    @track costarray = [];
    @track isValue;
    activeSections = 'PH Tabangao';
    activeSectionsMessage = '';
    @track selectedOption;
    @track showSectionData = true;
    @track costtype = 'TP Cost';
    @track cbuOutput = false;
    egCostData;
    tpCostData;
    currentyear;
    oldselectedplantList = [];
    oldactiveSections;
    selectedplant = [];
    toggleSection(event){
        let name = event.target.dataset.name;
        if(name == 'section'){
            if(this.showSectionData)
                this.showSectionData = false;
            else
                this.showSectionData = true;
        }
    }

    connectedCallback() {
        this.showSpinner    =   true;
        this.currentyear = new Date().getFullYear();
        this.selectedplant.push(this.activeSections);
        this.getPlantData();
        PHDataWrapper({userId : USER_ID})
        .then(result=>{
            this.validProfile = result.validProfile;
            this.lastModifiedDate = result.lastJobRun;
            this.mopsData = result.mops;
            this.ldcCostData = result.costMaps;
            this.tpCostData = result.costMaps;
            this.egCostData = result.egcostMaps;
            this.jobcount   =   result.jobruncount;
            this.recalculatecount   =   this.jobcount;
            this.dateData   = result.dataMaps;
            console.log("vAlidprofile___"+JSON.stringify(this.validProfile));
            console.log("lastJobRun--"+this.lastJobRun);
            console.log("mops___"+JSON.stringify(this.mopsData));
            this.showSpinner    =   false;
        })
        .catch(error=>{
            console.log("error in calling InitParameterDetails ---",error);
            this.showSpinner    =   false;
        });
        
    }
    
    handleRecalculate(){
        this.isRecalculate = true;
    }
    
    closePopUp(){
        this.isRecalculate = false;
    }
    
    executejob(){
        this.isRecalculate = false;
        this.validProfile  = false;
        console.log("executing job");
        this.showSpinner    =   true;
        jobExecute({country : "Philippines Output"})
        .then(result=>{
            console.log("success in executing job  ");
            this.recalculatecount = (this.recalculatecount != undefined) ? this.recalculatecount + 1 : 0;
            this.refreshjob();
        })
        .catch(error=>{
                        console.log("error in executing job ---",error);
            this.showSpinner    =   false;
        });
    }   
    
    handleMail(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {url: '/apex/RE_PH_Mail'}
        }) 
    }
    
    refreshjob(){   
        if(this.jobcount == this.recalculatecount){
            console.log('Job is executing....');
            this.connectedCallback();
            this.showSpinner    =   false;
        }
        else{
            maxRunCountMethod()
            .then(result=>{
                this.jobcount = result;
               // this.refreshjob();
                setTimeout(() => {
                    this.refreshjob();
                }, 2000);
            })
                    
            .catch(error=>{
                console.log("error in executing job refresh---",error);
                this.showSpinner    =   false;
            }) 
            console.log('Failed');
        }
    }

    handleValueChange(event) {
        console.log('--selectedplantList--'+JSON.stringify(this.selectedplantList));
        this.selectedplantList = [];
        console.log(JSON.stringify(event.detail.payload.values));
        setTimeout(() => {
            this.activeSections = event.detail.payload.values;
            event.detail.payload.values.forEach(elem =>{
                this.selectedplantList.push({Name:elem});
            });
            this.oldactiveSections = this.activeSections;
            this.oldselectedplantList = this.selectedplantList;
        },500);
        
        /*this.selectedOption = event.detail;
        console.log("you have selected : ",this.selectedOption);           
        setTimeout(() => {
            this.activeSections = this.selectedOption;
        }, 500);
        
        this.selectedplantList = [];
        this.selectedplantList.push(JSON.parse('{"Name": '+'"'+this.selectedOption+'"'+'}'));*/
    }

    getPlantData(){
        fetchPlantdata({country : 'Philippines'})
        .then(result => {
            result.forEach(element =>{
                this.plantoptions.push({label:element.Name, value:element.Name});
            });
            this.plantList  = result; 
            this.error = undefined;     
            this.selectedplantList.push(JSON.parse('{"Name": '+'"'+this.activeSections+'"'+'}'));
            const multiCombobox = this.template.querySelector('c-re_-multiselect-picklist');
            multiCombobox.refreshOptions(this.plantoptions);    
            this.oldactiveSections = this.activeSections;
            this.oldselectedplantList = this.selectedplantList; 
        })
        .catch(error => {
            this.error = error;
            this.plantList = undefined;
        });
    }

    handleSectionToggle(event) {
        this.costarray = [];
        const openSections = event.detail.openSections; 
        let sectionarray = [];
        let sectionarrayLastElement ;
        let entries = Object.entries(openSections);
        entries.forEach( ([prop, val]) => {
            sectionarray.push(val);
        });

        const selectedRecords = this.template.querySelectorAll('c-re_ph_plantbasedoutputdetail.childcls');        
        let sectionelement = null;
        sectionarray.forEach(element =>{
            let qselector = '[data-plantitem =' + '"' + element + '"' + ']' ;
            sectionelement = this.template.querySelector(qselector);
            sectionelement.style = 'display : block';
        });
        

        selectedRecords.forEach(element => {
            if(  sectionarray.indexOf(element.plantName) > -1 ){
               if(element.costList.length == 0){
                    element.fetchCostDetail(element.plantName, this.cbuOutput);
               }                
            }                
        });
    }

    handleToggle(event) {
        this.showSpinner    =   true;
        if(event.target.checked){
            this.costtype = 'Exgate Cost';            
            this.cbuOutput = true;
            this.ldcCostData = this.egCostData;
            
        }
        else{
            this.costtype = 'TP Cost';
            this.cbuOutput = false;
            this.ldcCostData = this.tpCostData;
           
        }
        this.selectedplantList = [];
        this.activeSections = '';
        console.log('--this.oldselectedplantList--'+JSON.stringify(this.oldselectedplantList));
        console.log('--this.oldactiveSections--'+JSON.stringify(this.oldactiveSections));
        setTimeout(() => {
            this.selectedplantList = this.oldselectedplantList;
            this.activeSections = this.oldactiveSections;
        }, 500);
        //this.selectedOption = 'All';
        this.showSpinner    =   false;
    }

}