import { LightningElement,track, wire, api} from 'lwc';       
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchProductAMVoutputdata from '@salesforce/apex/RE_MY_AMVCalculationController.fetchProductAMVoutputdata';
import fetchSalesTaxHeaderData from '@salesforce/apex/RE_MY_AMVCalculationController.fetchSalesTaxHeaderData';
import fetchSalesTaxData from '@salesforce/apex/RE_MY_AMVCalculationController.fetchSalesTaxData';
import fetchcompareData from '@salesforce/apex/RE_MY_AMVCalculationController.fetchcompareData';
import saveAMVdata from '@salesforce/apex/RE_MY_AMVCalculationController.saveAMVdata';
import sendEmailtoAM from '@salesforce/apex/RE_MY_AMVCalculationController.sendEmailtoAM';
import runCustomerOpp from '@salesforce/apex/RE_MY_AMVCalculationController.generateCustomOppdata';
import RE_EditLandingPage from '@salesforce/customPermission/RE_EditLandingPage';
import generatePM_EM from '@salesforce/apex/RE_MY_AMVCalculationController.checkPM_EMPlantPrice';


export default class Re_my_amvoutput extends LightningElement {
    @track prodList = [];
    @track selectedprodList = [];
    @track amvList = [];
    @track amvarray = [];
    @track prodtypelist = [];
    @track pmvalueList = [];
    @track sbvalueList = [];
    @track swvalueList = [];
    @track cmpvalList = [];
    @track isValue;
    @track activeSections = '';
    @track showSectionData;
    @track showSectionData1;
    @track spinnerLoadPlantPrice=false;
    @track spinnerMsg;
    activeSectionsMessage = '';
    finalupdatedamvList=[];
    @track selectedOption;
    @track isModalOpen = false;
    @track ShowDirectListPrice = false;
    @track ShowAMV = true;
    toggleSection(event){
        let name = event.target.dataset.name;
        if(name == 'section'){
            if(this.showSectionData)
                this.showSectionData = false;
            else
                this.showSectionData = true;
        }
    }
    toggleSection1(event){
            let name = event.target.dataset.name;
            if(name == 'section1'){
                if(this.showSectionData1)
                    this.showSectionData1 = false;
                else
                    this.showSectionData1 = true;
            }
        }
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    toggleDirectList(){
        if(this.ShowDirectListPrice)
            this.ShowDirectListPrice = false;
        else
            this.ShowDirectListPrice = true
    }
    submitDetails() {
        this.isModalOpen = false;
        sendEmailtoAM()
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title : 'Success',
                  message : 'Mail Sent to AM!',
                  variant : 'success',
                }),
            )
        })
        .catch(error => {
            this.error = error;
            console.log("Error in Save call back:", this.error);
        });
    }
    changeHandler(event) {
        this.activeSections = '';
        this.selectedprodList = [];
        const field = event.target.name;
        if (field === 'optionSelect') {
            this.selectedOption = event.target.value;
            if(this.selectedOption === 'All')
                this.selectedprodList = this.prodList;
            else{                                
                this.selectedprodList = this.prodList;
                setTimeout(() => {
                    this.activeSections = this.selectedOption;
                }, 500);
                
                this.selectedprodList = [];
                this.selectedprodList.push(JSON.parse('{"Name": '+'"'+this.selectedOption+'"'+'}'));
            }                
        }
    }

    handlepspchanged(event){
        const amvdetail = event.detail;
        let isPresent = false;
        this.finalupdatedamvList.forEach(function(element, index){
            if(element.Id === event.detail.Id) {
                element.RE_Final_PSP__c = event.detail.RE_Final_PSP__c;
                element.RE_Remark__c = event.detail.RE_Remark__c;
                element.RE_Agreed_PSP__c = event.detail.RE_Final_PSP__c;
                isPresent = true;
            }
        });
        if(isPresent === false)
            this.finalupdatedamvList.push(amvdetail);
    }

    handlesave(){
        console.log('insave--',this.finalupdatedamvList);
        let toSaveList = this.finalupdatedamvList;
        saveAMVdata({amvupdatedList : toSaveList})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : 'Records saved succesfully!',
                    variant : 'success',
                }),                
            )
        })
        .catch(error => {
            this.error = error;
            console.log("Error in Save call back:", this.error);
        }); 
    }

    getproddata(){ 
        fetchSalesTaxHeaderData()
        .then(result => {
            this.prodtypelist  = result; 
            this.error = undefined;    
        })
        .catch(error => {
            this.error = error;
            this.prodtypelist = undefined;
        }); 
        fetchSalesTaxData({region : 'Peninsular'})
        .then(result => {
            this.pmvalueList  = result; 
            this.error = undefined;
            this.showSectionData1 = true;
        })
        .catch(error => {
            this.error = error;
            this.pmvalueList = undefined;
        });
        fetchSalesTaxData({region : 'Sabah'})
        .then(result => {
            this.sbvalueList  = result; 
            this.error = undefined;
            this.showSectionData1 = true;
        })
        .catch(error => {
            this.error = error;
            this.sbvalueList = undefined;
        });
        fetchSalesTaxData({region : 'Sarawak'})
        .then(result => {
            this.swvalueList  = result; 
            this.error = undefined;
            this.showSectionData1 = true;
        })
        .catch(error => {
            this.error = error;
            this.swvalueList = undefined;
        });  
        fetchcompareData()
        .then(result => {
            this.cmpvalList  = result; 
            this.error = undefined;
            this.showSectionData = true;
        })
        .catch(error => {
            this.error = error;
            this.cmpvalList = undefined;
        }); 
    } 
    
    getproducttype(){
        fetchProductAMVoutputdata({country : 'Malaysia'})
        .then(result => {
            this.prodList  = result; 
            this.error = undefined;     
            this.selectedprodList = this.prodList;      
        })
        .catch(error => {
            this.error = error;
            this.prodList = undefined;
        });
    }

    handleSectionToggle(event) {        
        this.amvarray = [];
        const openSections = event.detail.openSections; 
        console.log('insidetoggled',openSections);
        let sectionarray = [];
        let sectionarrayLastElement ;
        let entries = Object.entries(openSections);
        entries.forEach( ([prop, val]) => {
            sectionarray.push(val);
        });
        console.log('sectionarray  ',sectionarray);
        const selectedRecords = this.template.querySelectorAll('c-re_my_amvoutputdetail.childcls');       
        console.log('selectedRecords  ',selectedRecords);
        let sectionelement = null;
        sectionarray.forEach(element =>{
            let qselector = '[data-proditem =' + '"' + element + '"' + ']' ;
            sectionelement = this.template.querySelector(qselector);
            console.log('sectionelement  ',sectionelement);
            sectionelement.style = 'display : block';
        });
        

        selectedRecords.forEach(element => {
            if(  sectionarray.indexOf(element.prodName) > -1 ){
               if(element.amvList.length == 0){
                    element.fetchAMVDetail(element.prodName);
               }                
            }                
        });
    }

    generateCustomerOpps(){
        if (confirm("Click ok to Generate Todays Malaysia Customer Opps ")){
            this.template.querySelectorAll('lightning-button').forEach(comboname => {

                if(comboname.label ==='Generate customer Opps')
                    comboname.disabled=true;
            });
            runCustomerOpp({})
            .then(result =>{
                console.log('@@@--'+JSON.stringify(result.Error));
                if(result.Error === 'false'){
                    this.showToast('success',result.message,'');                
                }
                else{
                    this.showToast('error',result.message,'');               
                }
            })
            .catch(error =>{
                console.log('error'+JSON.stringify(error));
                this.showToast('error','Error occured','');           
            })
        }
    }

    showToast(type,msgtitle,msg)
    {
        const evt = new ShowToastEvent({
            title: msgtitle,
            message: msg,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    connectedCallback() {
        this.getproddata();    
        this.getproducttype();    
    }

    statusOfCustomButton(){

    }

    handlesaveDirectList(){
        this.template.querySelector('c-re-my-listpriceupdate').saveDirectListPrice();
    }
    toggleAMVview(){
        if(this.ShowAMV)
        this.ShowAMV = false;
    else
        this.ShowAMV = true
    }
    get hasReadAccessButton(){
        return !RE_EditLandingPage;
    }

    generatePM(){
        if (confirm("Click ok to Generate PM Final Price  based on Plant price ")){
            this.loadSpinner(true,'Generating');
            this.template.querySelectorAll('lightning-button').forEach(comboname => {

                if(comboname.label ==='PM')
                    comboname.disabled=true;
            });
            generatePM_EM({region:'PM'})
            .then(result=>{
                this.showToast('success','Data got generated for PM',''); 
                this.template.querySelectorAll('lightning-button').forEach(comboname => {

                    if(comboname.label ==='PM')
                        comboname.disabled=false;
                });
                this.loadSpinner(false,'loading data')
            })
            .catch(error =>{
                console.log('error'+JSON.stringify(error));
                    this.showToast('error','Error occured','');    
                    this.loadSpinner(false,'loading data')       
            })
        }
    }

    generateEM(){
        if (confirm("Click ok to Generate EM Final Price  based on Plant price ")){
            this.loadSpinner(true,'Generating');
            this.template.querySelectorAll('lightning-button').forEach(comboname => {

                if(comboname.label ==='EM')
                    comboname.disabled=true;
            });
            generatePM_EM({region : 'EM'})
            .then(result=>{
                this.showToast('success','Data got generated for EM',''); 
                this.template.querySelectorAll('lightning-button').forEach(comboname => {

                    if(comboname.label ==='EM')
                        comboname.disabled=false;
                });
                this.loadSpinner(false,'loading data')
            })
            .catch(error =>{
                console.log('error'+JSON.stringify(error));
                this.showToast('error','Error occured','');  
                this.loadSpinner(false,'loading data')         
            })
        }
    }
    loadSpinner(load, msg)
    {
        if(load)
        {
            this.spinnerLoadPlantPrice = true;
            this.spinnerMsg = msg;
        }
        else
            this.spinnerLoadPlantPrice = false;
    }
}