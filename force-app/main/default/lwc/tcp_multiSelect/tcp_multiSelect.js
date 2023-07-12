import { LightningElement, api, track } from 'lwc';

const forReviewOptions = [{label:'Submitted',value:'Submitted',selected:false},];
const modCancelOptions = [{label:'Approved (C)',value:'Approved (C)',selected:false},
                          {label:'Approved (M)',value:'Approved (M)',selected:false},];
const currentOptions = [{label:'Approved',value:'Approved',selected:false},
                        {label:'Approved (C)',value:'Approved (C)',selected:false},
                        {label:'Approved (M)',value:'Approved (M)',selected:false},
                        {label:'Shipped',value:'Shipped',selected:false},
                        {label:'Submitted',value:'Submitted',selected:false},
                        ]; 
const prevOptions = [{label:'Approved',value:'Approved',selected:false},
                      {label:'Approved (C)',value:'Approved (C)',selected:false},
                          {label:'Approved (M)',value:'Approved (M)',selected:false},
                          {label:'Cancelled',value:'Cancelled',selected:false},
                          {label:'Draft',value:'Draft',selected:false},
                          {label:'Rejected',value:'Rejected',selected:false},
                          {label:'Shipped',value:'Shipped',selected:false},
                          {label:'Submitted',value:'Submitted',selected:false},
                          ];
const prevOptionsCU = [{label:'Approved',value:'Approved',selected:false},
                    {label:'Approved (C)',value:'Approved (C)',selected:false},
                        {label:'Approved (M)',value:'Approved (M)',selected:false},
                        {label:'Cancelled',value:'Cancelled',selected:false},
                        {label:'Rejected',value:'Rejected',selected:false},
                        {label:'Shipped',value:'Shipped',selected:false},
                        {label:'Submitted',value:'Submitted',selected:false},
                        ];
const rejCanOptions = [{label:'Rejected',value:'Rejected',selected:false},
                          {label:'Cancelled',value:'Cancelled',selected:false},];
                          

export default class Tcp_multiSelect extends LightningElement {

    @api width = 100;
    @api variant = '';
    @api label = '';
    @api name = '';
    @api tilename;
    @api iscommops=false;
    @api populatestatus;
    @track tileSelected;
    @api dropdownLength = 5;
    @track options_;
    @track optionsByDefault = [{label:'Approved',value:'Approved',selected:false},
                      {label:'Rejected',value:'Rejected',selected:false},
                      {label:'Submitted',value:'Submitted',selected:false},
                      {label:'Cancelled',value:'Cancelled',selected:false},
                      {label:'Delivered',value:'Delivered',selected:false},
                      {label:'In Draft',value:'In Draft',selected:false},
                      ];
    @track value_ = ''; //serialized value - ie 'CA;FL;IL' used when / if options have not been set yet
    @track isOpen = false;
    @api selectedPills = [];  //seperate from values, because for some reason pills use {label,name} while values uses {label:value}
    rendered = false;
    @api
    get options(){
      return this.options_
    }
    set options(options){
      this.rendered = false;
      this.parseOptions(options);
      this.parseValue(this.value_);
    }
    @api
    get value(){
      let selectedValues =  this.selectedValues();
      return selectedValues.length > 0 ? selectedValues.join(";") : "";
    }
    set value(value){
      this.value_ = value;
      this.parseValue(value);
      
    }
    parseValue(value){
      if (!value || !this.options_ || this.options_.length < 1){
        return;
      }
      var values = value.split(";");
      var valueSet = new Set(values);
      this.options_ = this.options_.map(function(option) {
        if (valueSet.has(option.value)){
          option.selected = true;
        }
        return option;
      });
      this.selectedPills = this.getPillArray();
    }
    parseOptions(options){
      if (options != undefined && Array.isArray(options)){
        this.options_ = JSON.parse(JSON.stringify(options)).map( (option,i) => {
          option.key = i;
          return option;
        });
      }
    }
    //private called by getter of 'value'
    selectedValues(){
      var values = [];
      //if no options set yet or invalid, just return value
      if (this.options_.length < 1){
        return this.value_;
      }
      this.options_.forEach(function(option) {
        if (option.selected === true) {
          values.push(option.value);
        }
      });
      return values;
    }
  
    connectedCallback() {
      this.tileSelected = this.tilename;
      switch (this.tileSelected) {
        case 'For Review/Approval':
              this.options_ = forReviewOptions;
              break;
        case 'Modification/Cancellation Requests':
              this.options_ = modCancelOptions;
              break;
        case 'Current Orders':
              this.options_ = currentOptions;
              break;
        case 'My CurrentOrders':
              this.options_ = currentOptions;
              break;
        case 'Previous Orders':
          window.console.log('this.iscommops'+this.iscommops);
              if(this.iscommops===true){
                window.console.log('inside Prv Order');
                this.options_ = prevOptionsCU;
              }else{
               this.options_ = prevOptions;
              }
              break;
        case 'Rejected/Cancelled Orders':
                this.options_ = rejCanOptions;
                break;
        case 'Order History':
          window.console.log('this.iscommops'+this.iscommops);
              if(this.iscommops===true){
                window.console.log('inside OrdHis Order');
                this.options_ = prevOptionsCU;
              }else{
              this.options_ = prevOptions;
              }
              break;
              
        default:
      }
      if(this.populatestatus && this.populatestatus.length>0){
        this.populateStatusOnLoad(this.populatestatus);
      }else{
        if(this.options_ && this.options_.length>0){
          this.options_.forEach(function(element) {
            element.selected = false;
          });
        }
      }
      
    }
  
    renderedCallback(){
    }
  
  
  
    get labelStyle() {
      return this.variant === 'label-hidden' ? ' slds-hide' : ' slds-form-element__label ' ;
    }
  
    get dropdownOuterStyle(){
      return 'slds-dropdown slds-dropdown_fluid slds-dropdown_length-5' + this.dropdownLength;
    }
  
    get mainDivClass(){
      var style = ' slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
      return this.isOpen ? ' slds-is-open ' + style : style;
    }
    get hintText(){
      if (this.selectedPills.length === 0) {
        return "";
      }
      
    }
  
    openDropdown(){
      this.isOpen = true;
    }
    closeDropdown(){
      this.isOpen = false;
    }
  
    /* following pair of functions are a clever way of handling a click outside,
       despite us not having access to the outside dom.
       see: https://salesforce.stackexchange.com/questions/255691/handle-click-outside-element-in-lwc
       I made a slight improvement - by calling stopImmediatePropagation, I avoid the setTimeout call
       that the original makes to break the event flow.
    */
    handleClick(event){
      event.stopImmediatePropagation();
      this.openDropdown();
      window.addEventListener('click', this.handleClose);
      this.template.querySelector('c-tcp_-product-multi-select').closeMultiSelect();

    }
    handleClose = (event) => {
      event.stopPropagation();
      this.closeDropdown();
      window.removeEventListener('click', this.handleClose);
    }


    handleKeyPress(event){
      if(event.keyCode === 13){
        this.openDropdown();
      }
    }
  
    handlePillRemove(event){
      event.preventDefault();
      event.stopPropagation();
  
      const name = event.detail.item.name;
  
      this.options_.forEach(function(element) {
        if (element.value === name) {
          element.selected = false;
        }
      });
      this.selectedPills = this.getPillArray();
      this.dispatchChangeEvent();
  
    }

    handleOpenPill(event){
      this.openDropdown();
    }
  
    handleSelectedClick(event){
  
      var value;
      var selected;
      event.preventDefault();
      event.stopPropagation();
  
      const listData = event.detail;
      value = listData.value;
      selected = listData.selected;
  
      //shift key ADDS to the list (unless clicking on a previously selected item)
      //also, shift key does not close the dropdown.
      if (listData.shift) {
        this.options_.forEach(function(option) {
          if (option.value === value) {
            option.selected = selected === true ? false : true;
          }
        });
      }
      else {
        this.options_.forEach(function(option) {
          if (option.value === value) {
            option.selected = selected === true ? false : true;
            window.console.log('option selected from status'+option.selected);
          } 
        });
        this.closeDropdown();
      }
  
      this.selectedPills = this.getPillArray();
      this.dispatchChangeEvent();
  
    }
  
  
    dispatchChangeEvent() {
      let values =  this.selectedValues();
      let valueString = values.length > 0 ? values.join(";") : "";
      const eventDetail = {value:valueString};
      const changeEvent = new CustomEvent('change', { detail: eventDetail });
      this.dispatchEvent(changeEvent);
    }
  
  
    getPillArray(){
      var pills = [];
      this.options_.forEach(function(element) {
        var interator = 0;
        if (element.selected) {
          pills.push({label:element.label, name:element.value, key: interator++});
        }
      });
      return pills;
    }

     
  @api clearStatusPills(){
    window.console.log('Started pills');
    this.selectedPills = [];
    this.options_.forEach(function(element) {
      if (element.selected) {
        element.selected = false;
      }
    });
    window.console.log('Ended pills');
  }

  @api closeMultiSelect(){
    this.isOpen = false;
    window.console.log('Checking is open ', this.isOpen);
  }
  

  populateStatusOnLoad(statusList){
    if(statusList.includes(';')){
      let listData = statusList.split(';');
      let objData = [];
      var count = 0;
      for(let i=0; i<listData.length;i++){
        let element = listData[i];
        objData.push({label:element, name:element, key: count++});
        for(let j=0; j<this.options_.length;j++){
          if (element == this.options_[j].label){
            this.options_[j].selected = true;
          }
        }
      }
      this.selectedPills = objData;
      
    }else{
      let objData = [];
      objData.push({label:statusList, name:statusList, key:0});
      for(let j=0; j<this.options_.length;j++){
        if (statusList == this.options_[j].label){
          this.options_[j].selected = true;
        }
      }
      this.selectedPills = objData;
    }
  }
    
  

}