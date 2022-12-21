import { LightningElement,track, wire, api} from 'lwc';  
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchProductAMVTHoutputdata from '@salesforce/apex/RE_TH_AMVCalculationController.fetchProductAMVTHoutputdata';
import saveAMVTHdata from '@salesforce/apex/RE_TH_AMVCalculationController.saveAMVTHdata';
import sendEmailtoAM from '@salesforce/apex/RE_TH_AMVCalculationController.sendEmailtoAM';


export default class Re_th_amvoutput extends LightningElement {
    @track prodList = [];
    @track selectedprodList = [];
    @track amvList = [];
    @track amvarray = [];
    @track prodtypelist = [];
    @track activeSections = '';
    @track selectedcustomerName = [];
    finalupdatedamvList=[];
    @track CustomerTypeList= [];
    @track productArrayList= [];
    @track items=[];

    customerSelected(event){
        console.log('event.detail@@'+JSON.stringify(event.detail));
        this.selectedcustomerName=event.detail;
        console.log('this.selectedcustomerName@@'+this.selectedcustomerName);
		this.selectedprodList = [];
        for(let i = 0; i< this.selectedcustomerName.length;i++)
        {
            for(let j = 0; j< this.CustomerTypeList.length;j++)
            {
              let tempList = this.CustomerTypeList[j].label;
              console.log('this.tempList__'+tempList);
			  if(tempList.toLowerCase().includes(this.selectedcustomerName[i].toLowerCase())) 
                    this.selectedprodList.push(JSON.parse('{"Name": '+'"'+this.CustomerTypeList[j].label+'"'+'}'));
            }
        }
        if(this.selectedcustomerName.length== 0)
        {
            for(let j = 0; j< this.CustomerTypeList.length;j++)
            {
                this.selectedprodList.push(JSON.parse('{"Name": '+'"'+this.CustomerTypeList[j].label+'"'+'}'));
            }
        }
        console.log('this.CustomerTypeList___'+JSON.stringify(this.selectedprodList));
       
    }
    getproducttype(){
        fetchProductAMVTHoutputdata({country : 'Thailand'})
        .then(result => {
            this.prodList  = result;
            console.log('prodList ',this.prodList);
            console.log('prod-result ',result);
            console.log('prod-result stringify ',JSON.stringify(result));
            this.error = undefined;     
            this.selectedprodList = this.prodList; 
            for(let i = 0; i<= result.length;i++)
            {
                var picklistArray = {label: result[i].Name,value: result[i].Name};
                console.log('picklistArray@@'+JSON.stringify(picklistArray));
                this.CustomerTypeList.push(picklistArray);
                console.log('CustomerTypeList@@'+JSON.stringify(this.CustomerTypeList));
            }  
        })
        .catch(error => {
            this.error = error;
            this.prodList = undefined;
        });
    }

    handlepspchanged(event){
        const amvdetail = event.detail;
        let isPresent = false;
        console.log('infinalupdatedamvList--',this.finalupdatedamvList);
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
        saveAMVTHdata({amvupdatedList : toSaveList})
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
        const selectedRecords = this.template.querySelectorAll('c-re_th_amvoutputdetail.childcls');       
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


    changeHandler(event) {
        this.activeSections = '';
        this.selectedprodList = [];
        const field = event.target.name;
        if (field === 'optionSelect') {
            this.selectedOption = event.target.value;
            console.log('this.selectedOption@@'+this.selectedOption);
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
    connectedCallback() { 
        this.getproducttype();    
    }
}