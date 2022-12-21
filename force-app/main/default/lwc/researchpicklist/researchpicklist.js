import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import { LightningElement,api,track } from 'lwc';   

export default class Researchpicklist extends LightningElement {
 //values from the parent component
  @api picklistvalues=[];
  @api labelname='';
  //values to lightning-checkbox-group
  @track items=[];
  @track value=[];
  //holds search input value
  @track searchInput ='';
  @track placeHolder='Search..'; 
  //holds the selected values and ID's of selected values
  @track selectedid=[];
  @track selectedvalues=[];
  @api seletedvaluefromparent =[];

  //used to display data if search record found
  isDialogDisplay = false; 
  //used to display an error message if no record found
  isDisplayMessage = false;
  
  //init method
  connectedCallback(){
    console.log('---data from pa'+this.seletedvaluefromparent);
    console.log('--picklist--'+JSON.stringify(this.picklistvalues));
     //store the selected values to pass parent component
     for(let key=0; key<this.seletedvaluefromparent.length;key++){
      for(let keymain=0;keymain<this.picklistvalues.length;keymain++){
          if(this.seletedvaluefromparent[key].toLowerCase() === this.picklistvalues[keymain].label.toLowerCase() ){
              this.value.push(this.picklistvalues[keymain].value);
              this.selectedvalues.push(this.picklistvalues[keymain]);
          }

      }
    }
    console.log('itesma--'+JSON.stringify(this.selectedvalues));
    if(this.selectedvalues.length>0)
            this.placeHolder=this.value.length +'-selected';            
        
        else
            this.placeHolder='Search..';  

  }


  //this method will invoke when user enter search values
  onchangeSearchInput(event){
    var seractText= event.target.value;
    var itemTemp=[];
    var valuestemp=[];
    var valuesList=this.value;
    if(this.value.length === 0)
        this.selectedvalues=[];

    console.log('--data --'+JSON.stringify(this.picklistvalues));
    //checks if search character is greater than 0    
    if(seractText.trim().length>0 && this.picklistvalues.length > 0){
        //iterates through all picklist values
         this.picklistvalues.forEach(function(element,index){
                if(element.label.toLowerCase().includes(seractText.toLowerCase())){
                    if(!valuesList.includes(element.value)){
                        itemTemp.push(element);
                    }
                }
        });

        this.items=[];  
        //checks search values and previously selected values not empty      
        if(itemTemp.length > 0 || this.selectedvalues.length > 0){        
            this.isDialogDisplay = true; //display dialog
            this.isDisplayMessage = false;
           this.items=this.selectedvalues.concat(itemTemp);

        }
        else{
             //display No records found message
             this.isDialogDisplay = false;
             this.isDisplayMessage = true; 
        }
    }
    else{
         //display No records found message
         this.isDialogDisplay = false;
         this.isDisplayMessage = false; 
        }
    }

    //this method will invoke when the user select any values
    handleCheckboxChange(event){
        //the event will return all selected values when the user select any value
        let selectItemTemp = event.detail.value;

         this.selectedid=[];
        selectItemTemp.map(p=>{  
                this.selectedid.push(p);
        });

        var tempdata=[];
        //store the selected values to pass parent component
        for(let key=0; key<this.selectedid.length;key++){
            for(let keymain=0;keymain<this.items.length;keymain++){
                if(this.selectedid[key] ===this.items[keymain].value ){
                    tempdata.push(this.items[keymain]);
                }

            }
        }

        this.selectedvalues=tempdata;
        
    }
    //update selected to Parent component 
    handleDoneClick(){
        this.items=this.selectedvalues;
        this.value=this.selectedid;
        this.template.querySelectorAll('lightning-input').forEach(comboname => {
            if(comboname.name ==='Seacrh' )
               comboname.value='';
         });

         //disabling the error / searched values window
        this.isDialogDisplay = false;
        this.isDisplayMessage = false; 
        //show selected values length
        if(this.items.length>0)
            this.placeHolder=this.value.length +'-selected';            
        
        else
            this.placeHolder='Search..';   
        
        //trigger event to update parent component
        let selectednames=[];
        this.items.forEach( function (element,index){
            selectednames.push(element.label.toLowerCase());
         })

        const evtCustomEvent = new CustomEvent('slectedvalues', {   
            detail: selectednames
            });
        this.dispatchEvent(evtCustomEvent);
        
    }

    //to show selected values on click of search bar if previously values selected  
    showselected(){
        this.items=this.selectedvalues;
        if(this.items.length > 0){
            this.isDialogDisplay = true; //display dialog
            this.isDisplayMessage = false;
        }
        else{
            this.isDialogDisplay = false;
             this.isDisplayMessage = false; 
        }
    }

    //clear all the selected values
    handleCancelClick(){
        this.clearinitvalues();
        const evtCustomEvent = new CustomEvent('slectedvalues', {   
        detail: this.selectedvalues
        });
    this.dispatchEvent(evtCustomEvent);
    }


    //this method will call by parent component to clear all previously selected values when the customer type filter changed 
    @api  clearinitvalues(){
        this.items=[];
        this.value=[];
        this.selectedvalues=[];

        this.template.querySelectorAll('lightning-input').forEach(comboname => {
            if(comboname.name ==='Seacrh' )
               comboname.value='';
         });
         //display No records found message
         this.isDialogDisplay = false;
         this.isDisplayMessage = false; 
       // this.selectedvalues=tempdata;
       this.placeHolder='Search..';
    }
}