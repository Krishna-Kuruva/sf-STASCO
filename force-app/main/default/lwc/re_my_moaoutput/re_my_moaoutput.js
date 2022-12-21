import { LightningElement,track, wire, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchProductAMVoutputdata from '@salesforce/apex/RE_MY_AMVCalculationController.fetchProductAMVoutputdata';

export default class Re_my_moaoutput extends LightningElement {
    @track prodList = [];
    @track selectedprodList = [];
    @track amvList = [];
    @track amvarray = [];
    @track isValue;
    activeSections = '';
    activeSectionsMessage = '';
    @track selectedOption;

    changeHandler(event) {
        this.selectedprodList = [];
        const field = event.target.name;
        if (field === 'optionSelect') {
            this.selectedOption = event.target.value;
            console.log("you have selected : ",this.selectedOption);
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
        console.log('this.selectedprodList-->',this.selectedprodList) ;
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
        let sectionarray = [];
        let sectionarrayLastElement ;
        let entries = Object.entries(openSections);
        entries.forEach( ([prop, val]) => {
            sectionarray.push(val);
        });

        const selectedRecords = this.template.querySelectorAll('c-re_my_moaoutputdetail.childcls');        
        let sectionelement = null;
        sectionarray.forEach(element =>{
            let qselector = '[data-proditem =' + '"' + element + '"' + ']' ;
            sectionelement = this.template.querySelector(qselector);
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

    connectedCallback() {
        this.getproducttype();    
    }
}