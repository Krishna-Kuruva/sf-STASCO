import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';
import {LightningElement, api, track} from 'lwc';
export default class Rv_multiselectdropdown extends LightningElement {
        
    /*   =======--- component receives the following params:
        label - String with label name;
        disabled - Boolean value, enable or disable Input;
        options - Array of objects [{label:'option label', value: 'option value'},{...},...];
    
        to clear the value call clear() function from parent:
        let multiSelectPicklist = this.template.querySelector('c-multi-select-pick-list');
        if (multiSelectPicklist) {
           multiSelectPicklist.clear();
        }
   
        to get the value receive "valuechange" event in parent;
        returned value is the array of strings - values of selected options;
        example of usage:
        <-multi-select-pick-list options={marketAccessOptions}
                                   onvaluechange={handleValueChange}
                                   label="Market Access">
        </c-multi-select-pick-list>

        handleValueChange(event){
            console.log(JSON.stringify(event.detail));
        }
    */
   reload='';
   valueSelected=[];
    @api values;
    @api label = "";
    _disabled = false;
    @api
    get disabled(){
        return this._disabled;
    }
    set disabled(value){
        this._disabled = value;
        this.handleDisabled();
    }
    @track inputOptions;
    @api
    get options() {
        //return this.inputOptions.filter(option => option.value !== 'All' && option.value !== 'None');
        return this.inputOptions.filter(option => option.value !== 'All' && option.value !== '--Select--');
    }
    set options(value) {
      /*  let options = [{
            value: 'All',
            label: 'None'
        }];*/
        let options = [{
            //value: 'None',
            //label: 'None'
            value: '--Select--', 
          label: '--Select--'
        },{
            value: 'All',
            label: 'All'
        }
        ];
        this.inputOptions = options.concat(value);
    }
    @api
    clear(){
        this.handleAllOption();
    }
    value = [];
  //  @track inputValue = 'None';
  //@track inputValue = 'None';
    @track inputValue = '--Select--';

    hasRendered;
    hasOption;
    renderedCallback() {
        console.log("renderedCallback"+this.values);
        if(this.values !== undefined && this.values.length !== 0 && this.hasOption != true){
            let uniqueIds = [...new Set(this.values)];
            this.values=uniqueIds;
            if( this.values.length >1){
                //if(this.values.length == this.options.length-2
                if(this.values.length == this.options.length){
                    this.inputValue='All';
                }else{
                    this.inputValue=this.values.length+' option selected';
        
                }

              //this.values.forEach(valueS=>{
                let option = this.options.filter(option => this.values.includes(option.value));
               console.log('Inside rendered Option'+this.value.length);

            //    if(this.value[option.label] !== valueS)
                    this.value.push(...option);
              //   });

            
              //   this.value.push(...this.valueSelected);
                 console.log('After rendered Option'+this.value.length);

                this.reload="true";  
                this.sendValues();
            }else if(this.values.length == 1){
                if(this.values[0] !== undefined){
                    let option = this.options.find(option => option.value === this.values[0]);
                  //  this.valueSelected=option;
        
                this.inputValue=option.label;
                this.value.push(option);
        
                this.reload="true";  
                this.sendValues();
               
                }
        
            
            }
            this.hasOption=false;
            }else{
                this.reload="false";
                this.hasOption=true;
            }
        if (!this.hasRendered) {
            //  we coll the logic once, when page rendered first time
            this.handleDisabled();
        }
        this.hasRendered = true;
    }
    handleDisabled(){
        let input = this.template.querySelector("input");
        if (input){
            input.disabled = this.disabled;
        }
    }
    comboboxIsRendered;
    handleClick() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.toggle("slds-is-open");
        if (!this.comboboxIsRendered){
            if(this.reload == "false"){
                if(this.valueSelected.length==0){
            // let allOption = this.template.querySelector('[data-id="All"]');
            // let allOption = this.template.querySelector('[data-id="None"]');
                let allOption = this.template.querySelector('[data-id="--Select--"]');

            allOption.firstChild.classList.add("slds-is-selected");
            
                }
             //   this.comboboxIsRendered = true;
            }else{
               // let firstChildSelected = this.template.querySelector('[data-id="None"]');
                let firstChildSelected = this.template.querySelector('[data-id="--Select--"]');
                firstChildSelected.firstChild.classList.remove("slds-is-selected");

                this.values.forEach(valueS => {
                let allOption = this.template.querySelector("[data-id=" + "\'" + valueS + "\'" + "]");
              //  console.log("all option"+allOption+" "+valueS);
              //  this.value.push(valueS);
                allOption.firstChild.classList.toggle("slds-is-selected");
                });
                this.reload="false";
            }
            this.comboboxIsRendered = true;
        }
        
    }
    handleNoneOption(){
        let listOfSelected=this.template.querySelectorAll('.slds-is-selected');
        for(let isSelected of listOfSelected){
            isSelected.classList.remove("slds-is-selected");

        }
       // let noneOption = this.template.querySelector('[data-id="None"]');
        let noneOption = this.template.querySelector('[data-id="--Select--"]');
        noneOption.firstChild.classList.add("slds-is-selected");
        this.value=[];
        //this.inputValue='None';
        this.inputValue='--Select--';

    }
    @api
    handleSelection(event) {
        let value = event.currentTarget.dataset.value;
        console.log('in multiSelect::'+JSON.stringify(value));
        if (value === 'All') {
            this.handleAllOption();
        }//else if(value === 'None'){
            else if(value === '--Select--'){
            this.handleNoneOption();
        }
        else {
            this.handleOption(event, value);
        }
        this.hasOption=true;
        let input = this.template.querySelector("input");
        input.focus();
        this.sendValues();
    }
    sendValues(){
        let values = [];
        for (const valueObject of this.value) {

            if(!values.includes(valueObject.value)){
            values.push(valueObject.value);
            }
        }
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: values
        }));
    }
    handleAllOption(){
        this.value = [];
      //  this.inputValue = 'None';
      this.inputValue = 'All';
        let listBoxOptions = this.template.querySelectorAll('.slds-is-selected');
        for (let option of listBoxOptions) {
            option.classList.remove("slds-is-selected");
        }
        let allOption = this.template.querySelector('[data-id="All"]');
        allOption.firstChild.classList.add("slds-is-selected");
        let options = this.options.filter(option => {
//return option.value !== 'All' && option.value !== 'None'
return option.value !== 'All' && option.value !== '--Select--'

        } );
     
        console.log('this.value'+this.value);
        this.value.push(...options);
        for(const handleObject of this.value){
           let allOption = this.template.querySelector("[data-id=" + "\'" + handleObject.value + "\'" + "]");
           allOption.firstChild.classList.toggle("slds-is-selected");
        }
        
        this.closeDropbox();
    }

    handleOption(event, value){
        let listBoxOption = event.currentTarget.firstChild;
        let allOption = this.template.querySelector('[data-id="All"]');
        allOption.firstChild.classList.remove("slds-is-selected");
        if (listBoxOption.classList.contains("slds-is-selected")) {
     
            this.value = this.value.filter(option => option.value !== value);
            console.log('value length'+this.value.length);
            this.values=this.values.filter(option => option.value !== value);
        }
        else {
           // let noneOption = this.template.querySelector('[data-id="None"]');
            let noneOption = this.template.querySelector('[data-id="--Select--"]');
            noneOption.firstChild.classList.remove("slds-is-selected");
               if(this.value[value] == undefined){

            let option = this.options.find(option => option.value === value);
            console.log('this.option::'+option.length);
            this.value.push(option);
            }
        }
        console.log('this.value::'+JSON.stringify(this.value));
        if (this.value.length>1) {
    let setOfValues = new Set();
    let uniqueValues = this.value.reduce((unique,selectedValue)=>{
        if(!setOfValues.has(selectedValue.value)){
            setOfValues.add(selectedValue.value)
            unique.push(selectedValue)
          }
          return unique;
        },[]);
                this.inputValue=(uniqueValues.length)+' options selected';

          

        }
        else if (this.value.length === 1) {
            this.inputValue = this.value[0].label;
        }
        else {
           // this.inputValue = 'None';
            this.inputValue = '--Select--';

        }
        console.log('Inside handle Option'+this.inputValue);
        

        listBoxOption.classList.toggle("slds-is-selected");
    
    }
    
    dropDownInFocus = false;
    handleBlur() {
        if (!this.dropDownInFocus) {
            this.closeDropbox();
        }
    }
    handleMouseleave() {
        this.dropDownInFocus = false;
    }
    handleMouseEnter() {
        this.dropDownInFocus = true;
    }
    closeDropbox() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.remove("slds-is-open");
    }
        
    //added by sampada.bhat @28/03/2022
/* connectedCallback(){
    console.log('Value from customer filter'+JSON.stringify(this.values));

 
  }*/
 
}