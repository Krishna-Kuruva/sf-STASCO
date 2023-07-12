import { LightningElement, api, track } from 'lwc';
import uId from '@salesforce/user/Id';
import getPickListValues from '@salesforce/apex/TCP_HomePageController.getPickListValues';
import getDateWithMonthName from '@salesforce/apex/TCP_Utilities.getDateWithMonthName';
import getOrderNumberOnModify from '@salesforce/apex/TCP_ChangeCancelOrderController.getOrderNumberOnModify';

const columns = [
    { label: 'Product Name', fieldName: 'Name' },
];
const statusData = new Map([
    ['CN', { customClass: 'cn-line-item', expStatus: 'Line Item Cancelled'}],
    ['RC', { customClass: 'rc-line-item', expStatus: 'Requested for Cancellation'}],
    ['DN', { customClass: 'dn-line-item', expStatus: 'Delivery Note Created'}]
  ]);
  


export default class tcp_ModifyOrderEU extends LightningElement {

    orderApiName ='Order';
    deliveryTermApiName = 'Delivery_Terms__c';
    modeofTransportApiName = 'Mode_of_Transport__c';
    orderLineItemApiName = 'TCP_OrderLineItem__c';
    unitApiName = 'Unit__c';
    reqForCancel='RC';
    columns = columns;
    
    @api orderdetaildata;
    @api type;
    @api eufilterdata;
    @api actiontype;
    @track tableType;
    @track orderDetailList;
    @track oldOrderDetailList;
    @track oldOrderLineItemsList =[];
    /* Progress Steps **/
    @track progressStep1 = false;
    @track progressStep2 = true;
    @track progressStep3 = false;
   /* All Details Card */ 
    @track selectProductCustomerNameCard = true;
    @track selectProductDeliveryToCard = true;
    @track selectProductInvoiceToCard = true;
   /* All Tabels */ 
    @track selectProductTable = false;
    @track enterDetailsTable = true;
    @track reviewSubmitTable = false;
   /* All Forms */
    @track enterDetailsForm = true;
    @track reviewSubmitForm = false;
   
    @track userId = uId;
    @track customerValue;
    @track soldToOptions = [];
    @track soldToIdMap = [];
    @track deliveryValue;
    @track billingValue;
    @track customerDetails;
    @track deliveryDetails;
    @track billingDetails;
    @track parentSoldToAccId;
    @track shipToAccId;
    @track billToAccId;
    @track shipToData = [];
    @track billToData = [];
    @track payerData = [];
    @track shipToOptions = [] ;
    @track billToOptions = [];
    @track shipToNamesMap = [];
    @track billToNamesMap = [];
    @track productList = [];
    @track productListData = [];
    @track showProducts = false;
    @track searchTerm ='';
    @track selectedProducts =[];
    @track selectedRows =['01t25000007ZQNgAAO'];
    @track selectedProductMap = [];
    @track selectedProdDetails =[];
    @track deletedProdDetails =[];
    @track SelectedProdCount = 0;
    @track searchKey;
    @track delTermsOptions =[];
    @track modeOfTransOptions =[];
    @track unitOptions =[];
    @track deliveryTermsValue;
    @track modeOfTransportValue;
    @track unitValue;
    @track otherInstCount =0;
    @track otherInstValue;
    @track orderName;
    @track customerPo;
    @track orderWrapper = {};
    @track orderNumber;
    @track orderId;
    @track soldToNumber;
    @track shipToNumber;
    @track billToNumber;
    @track orderStatus;
    @track deliveryDateWithMonth;
    error;
    @track hasCustomerData = true;
    @track hasDeliveryToData = true;
    @track hasInvoiceToData = true;
    @track hasProductData = true;
    @track hasSelectedProducts=true;
    @track hasDeliveryTermsData = true;
    @track hasTransportData=true;
    @track childAccounts = [];
    @track materialNameMap =[];
    @track defaultOrdValue = 1;
    @track selectedStep = 'Step2';

    @track quantityMap = new Map();
    @track deliveryDateMap = new Map();
    @track deliveryDateWithMonthMap=new Map();
    @track shellContractMap =new Map();
    @track instructionsMap = new Map();
    @track oliStatusMap = new Map();
    @track lineItemIdMap=new Map();
    @track productNumberMap = new Map();
    @track unitComboMap = new Map();
    @track initialQuantityMap = new Map();
    @track initialDeliveryDateMap = new Map();
    @track initialShellContractMap =new Map();
    @track initialUnitComboMap = new Map();
    @track initialInstructionsMap = new Map();
    @track orderLineItemsList = [];
    @track isShowModal = false;
    @track isShowModalOrderModificationRequest = false;
    @track isShowModalModifyOrder = false;
    @api parentaccid;
    @track accountId;
    @track isLoading = false;
    @track soldToName;
    @track noSearchResult;
    @track isShowErrorModal;
    @track tableClassName = 'slds-table--header-fixed_container';
    @track scrollBarEnable = 'tablecheck';
    @track hasOrderSubmitted = false;
    @track deletedProducts=[];
    @track sendFilterData;
    @track ordActionType;
    @track sameData=false;
    @track showPopUp=false;
    @track showInstPopup=false;
    @track modifiedCustomerPO;
    @track modifiedDeliveryTerm;
    @track modifiedModeOfTransport;
    @track modifiedOtherInst;
    @track backToDashboard=true;
    @track updatedDate;

    lineItemError;
    lineItemInfo;
    lineItemleftInfo;
    minDateValue;
    maxDateValue;

    //For delivery date
    currentdate;
    maximumdate;
    selectedval;


    constructor(){
        super();

        this.accountId = this.parentaccid;
        getPickListValues({objectApiName: this.orderApiName, fieldApiName: this.deliveryTermApiName})
        .then(result=>{
            for(const res of result){
                const option = {
                    label : res,
                    value : res
                };
                this.delTermsOptions = [...this.delTermsOptions,option];

                if(this.delTermsOptions.length===0){
                    this.hasDeliveryTermsData=false;
                }
            }
        })
        .catch(error => {
            this.error = error;
            window.console.log('Error in getting data==>'+JSON.stringify(this.error));
        });

        getPickListValues({objectApiName: this.orderApiName, fieldApiName: this.modeofTransportApiName})
        .then(result=>{
            for(const res of result){
                const option = {
                    label : res,
                    value : res
                };
                this.modeOfTransOptions = [...this.modeOfTransOptions,option];
                
                if(this.modeOfTransOptions.length===0){
                    this.hasTransportData=false;
                }
            }
        })
        .catch(error => {
            this.error = error;
            window.console.log('Error in getting data===>'+JSON.stringify(this.error));
        });

        getPickListValues({objectApiName: this.orderLineItemApiName, fieldApiName: this.unitApiName})
        .then(result=>{
            for(const res of result){
                const option = {
                    label : res,
                    value : res
                };
                this.unitOptions = [...this.unitOptions,option];
            }
        })
        .catch(error => {
            this.error = error;
            window.console.log('Error in getting data===>'+JSON.stringify(this.error));
        });
    } 
    
    connectedCallback(){
        this.accountId = this.soldtoid;
        this.oldOrderDetailList=this.orderdetaildata;
        this.orderDetailList = this.orderdetaildata;
        this.oldOrderLineItemsList = this.orderDetailList.orderLineItemList;
        this.prepareSelectedOrder();
        this.prepareSelectedProductList();
        this.tableType = this.type;
        const value10 = 10;
        const value89 = 89;
        if(this.tableType==='Order History'){
            this.backToDashboard=false;
        }
        this.sendFilterData = this.eufilterdata;
        this.ordActionType = this.actiontype;
        
        
        //Calander View for Delivery date in place order page
        this.currentdate = new Date().toISOString().slice(0,value10);
        //Max Date
        const todaydate = new Date();
        // Add 90 days to current date
        todaydate.setDate(todaydate.getDate() + value89);
        this.maximumdate = todaydate.toISOString().slice(0,value10);
    }

    productInfoMapNullChecker(dataMap, dataId){
        if(dataMap.has(Number(dataId))){
            return dataMap.get(Number(dataId));
        }else{
            return '';
        }
    }

    handleDataCheck(){

        if(this.deliveryTermsValue!==this.oldOrderDetailList.deliveryTerms || this.modeOfTransportValue!==this.oldOrderDetailList.modeOfTransport|| this.customerPo!==this.oldOrderDetailList.poNumber||this.otherInstValue!==this.oldOrderDetailList.otherInstructions)
        {
        this.sameData=true;
        
        }
        if(this.selectedProdDetails.length!==this.oldOrderLineItemsList.length){
            this.sameData=true;
        }
            
        for (let i = 0; i < this.selectedProdDetails.length; i++) {
                for(let j=0;j<this.oldOrderLineItemsList.length; j++){
                
                    if(this.selectedProdDetails[i].LineItemId===this.oldOrderLineItemsList[j].Id)
                    {
                    
                        if (this.selectedProdDetails[i].quantity !== this.oldOrderLineItemsList[j].Quantity__c) {
                            this.sameData=true;
                        }
                        if (this.selectedProdDetails[i].unit !== this.oldOrderLineItemsList[j].Unit__c) {
                            this.sameData=true;
                        }
                        if (this.selectedProdDetails[i].deliveryCollDate !== this.oldOrderLineItemsList[j].Delivery_Collection_Date__c) {
                            this.sameData=true;
                        }
                        if (this.selectedProdDetails[i].shellContractNo !== this.oldOrderLineItemsList[j].Contract_No__c) {
                            this.sameData=true;
                        }
                        if (this.selectedProdDetails[i].instructions !== this.oldOrderLineItemsList[j].Other_Instruction__c) {
                            this.sameData=true;
                        }
                    }
                }
        }
        
    }

    handleNext() {
        this.showPopUp=false;
        const getselectedStep = this.selectedStep;
         
        if(getselectedStep === 'Step1'){
            if(this.doInputValidation('.Step1') && (this.SelectedProdCount>0)){
                this.prepareSelectedProductList();
                window.scrollTo(0,0); 
                this.selectedStep = 'Step2';
                this.selectProductTable = false;
                this.enterDetailsForm = true;
                this.enterDetailsTable = true;
                this.reviewSubmitTable = false;
                this.reviewSubmitForm = false;
                this.hasSelectedProducts=true;
                /* Progress Steps */
                this.progressStep1 = false;
                this.progressStep2 = true;
                this.progressStep3 = false;
            }
            else if(this.showProducts){
                this.hasSelectedProducts=false;
            }
        }
        else if(getselectedStep === 'Step2'){
            if(this.doInputValidation('.Step2')){
                    
                    this.orderLineItemsList.splice(0,this.orderLineItemsList.length); 
                   
                    this.saveOrderLineItems();
                    this.mapOrderLineItems();
                    this.handleDataCheck();
                    if(this.sameData===true){
                    window.scrollTo(0,0); 
                    this.selectedStep = 'Step3';
                    this.selectProductTable = false;
                    this.enterDetailsForm = false;
                    this.enterDetailsTable = false;
                    this.reviewSubmitTable = true;
                    this.reviewSubmitForm  = true;
                    /* Progress Steps */
                    this.progressStep1 = false;
                    this.progressStep2 = false;
                    this.progressStep3 = true;

                    }
                    else{
                        this.showPopUp=true;
                        this.scrollToTopOfPage();
                    }
                   
           }
           
        }
       
    }
    hideShowPopUp(){
        this.showPopUp=false;
    }
    hideshowInstPopup(){
        this.showInstPopup=false;
    }
    handlePrev() {
        const getselectedStep = this.selectedStep;

        if(getselectedStep === 'Step1'){
            window.scrollTo(0,0); 
            this.handleHomepage(this.ordActionType,this.tableType, this.sendFilterData);
        }
        if(getselectedStep === 'Step2'){
            window.scrollTo(0,0); 
            this.handleHomepage(this.ordActionType,this.tableType, this.sendFilterData);
            
        }
        else if(getselectedStep === 'Step3'){
            window.scrollTo(0,0);
            this.selectedStep = 'Step2';
            this.selectProductTable = false;
            this.reviewSubmitTable = false;
            this.reviewSubmitForm = false;
            this.enterDetailsForm = true;
            this.enterDetailsTable = true;
            /* Progress Steps */
            this.progressStep1 = false;
            this.progressStep2 = true;
            this.progressStep3 = false;
            
            setTimeout(() => {
                for(let i=0; i<this.selectedProdDetails.length; i++){
                    this.handleInstructionLogic(this.selectedProdDetails[i].Index,true);
                }
            }, 500);
        }
        
    }    

    handleCancel() {
            this.showModalBox();
    }

    handleHomepageNav(){
        this.handleHomepage(this.ordActionType,this.tableType, this.sendFilterData);
    }
    
    handleHomepage(data,type, filterdata) {
        this.dispatchEvent(new CustomEvent('modifyordereu',{detail : {"status":data, "type":type, "filtereudata": filterdata}}));
    }

    selectStep1() {
        this.selectedStep = 'Step1';
    }
 
    selectStep2() {
        this.selectedStep = 'Step2';
        
        
    }
 
    selectStep3() {
        this.selectedStep = 'Step3';
        
    }
    
    get isSelectStep3() {
        return this.selectedStep === "Step3";
    }

    get isSelectStep1(){
        return this.selectedStep === "Step1"
    }

    get minDate(){
        const value10 = 10;
        if(this.minDateValue=== undefined)
        {
        this.minDateValue= new Date().toISOString().substring(0, value10);
        }
        return this.minDateValue;
    }

    get maxDate(){
        const value10 = 10;
        if(this.maxDateValue=== undefined)
        {
            const today= new Date(); 
            const numberOfDaysToAdd = 90;
            const result = today.setDate(today.getDate() + numberOfDaysToAdd);
            this.maxDateValue= new Date(result).toISOString().substring(0, value10  );
        }
        return this.maxDateValue;
    }

    showModalBox() {  
        this.isShowModal = true;
    }
    hideModalBox() {  
        this.isShowModal = false;
    }

    showModalOrderModificationRequest() {  
        if(this.orderStatus==='Submitted'){
            this.isShowModalModifyOrder = true;
        this.isShowModalOrderModificationRequest = false;
            }
            if(this.orderStatus==='Approved' || this.orderStatus==='Approved (M)' || this.orderStatus==='Approved (C)'){
                this.isShowModalModifyOrder = false;
                this.isShowModalOrderModificationRequest = true;
                }
    }
    
    hideModalOrderModificationRequest() {  
        this.isShowModalOrderModificationRequest = false;
    }

    showModalModifyOrder() {  
        this.isShowModalModifyOrder = true;
        this.isShowModalOrderModificationRequest = false;
    }
    
    hideModalModifyOrder() {  
        this.isShowModalModifyOrder = false;
    }





    
    value = '10';

    get options() {
        return [
            { label: '10 / page ', value: '10' },
            { label: '15 / page', value: '15' },
            { label: '20 / page', value: '20' },
        ];
    }

    

    get CustomerOptions(){
        return this.soldToOptions;
    }

    get deliveryOptions(){
        return this.shipToOptions;
    }

    get billingOptions(){
        return this.billToOptions;
    }

    get deliveryTermOptions(){
        return this.delTermsOptions;
    }

    get modeOfTransportOptions(){
        return this.modeOfTransOptions;
    }

    get unitProdOptions(){
        return this.unitOptions;
    }

  
   

    handleChange(event){
        this.value = event.detail.value;


    }

   
    handleDeliveryTermsChange(event){
        this.deliveryTermsValue = event.detail.value;
        this.modifiedDeliveryTerm=event.detail.value;
        this.doInputValidation('.Step2DevTerm');
    }

    handleModeOfTransChange(event){
        this.modeOfTransportValue = event.detail.value;
        this.modifiedModeOfTransport=event.detail.value;
        this.doInputValidation('.Step2Transport');
    }

    handleUnitChange(event){
        const dataId = event.currentTarget.name;
        const inputValue = event.currentTarget.value;
        if(dataId){
            this.unitComboMap.set(Number(dataId),inputValue);
            this.handleInstructionLogic(dataId,false);  
        }
    }

    handleQuantityChange(event){
        const dataId = event.currentTarget.dataset.id;
        const prodName = event.currentTarget.dataset.name;
        let inputValue = event.currentTarget.value;
        if(inputValue && inputValue.length>0){
            inputValue = Number(inputValue);
            this.quantityMap.set(Number(dataId),inputValue);
        }
        if(prodName && prodName.length>0){
            this.materialNameMap.push({key:Number(dataId), value:prodName});
        }
        this.handleInstructionLogic(dataId,false);    
    }
    
    handleDeliveryDate(event){
        const dataId = event.currentTarget.dataset.id;
        let inputValue = event.currentTarget.value;
        if(inputValue && inputValue.length>0){
            this.deliveryDateMap.set(Number(dataId),inputValue);
            this.mapDeliveryDate(dataId);
        }
        getDateWithMonthName({ reqDate: inputValue }) .then(result => {
            inputValue = result;
            if(inputValue && inputValue.length>0){
                this.deliveryDateWithMonthMap.set(Number(dataId),inputValue);
                this.mapDeliveryDate(dataId);
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in updating date====>' + JSON.stringify(this.error));
        });        

        this.handleInstructionLogic(dataId,false);
    }

    handleInstructionLogic(dataId,isPrevious){
        let enableEditing=false;
        
        if(!this.initialShellContractMap.get(Number(dataId))){
            this.initialShellContractMap.set(Number(dataId),'');
        }
        if(!this.shellContractMap.get(Number(dataId))){
            this.shellContractMap.set(Number(dataId),'');
        }

        if((this.shellContractMap.get(Number(dataId))!==this.initialShellContractMap.get(Number(dataId))) || (this.quantityMap.get(Number(dataId))!==this.initialQuantityMap.get(Number(dataId))) || (this.deliveryDateMap.get(Number(dataId))!==this.initialDeliveryDateMap.get(Number(dataId))) || (this.unitComboMap.get(Number(dataId))!==this.initialUnitComboMap.get(Number(dataId)))){
            enableEditing=true;
        }

        const target = this.template.querySelector(`[data-name="${dataId}"]`);
        if( target && target != null){
            if(enableEditing){
                if(target.classList.contains('disabled-input')){
                    target.classList.remove('disabled-input');
                }    
            }else{
                target.classList.add('disabled-input');  
                if(this.instructionsMap.get(Number(dataId))!==this.initialInstructionsMap.get(Number(dataId))){
                target.value=this.initialInstructionsMap.get(Number(dataId));
                this.instructionsMap.set(Number(dataId),this.initialInstructionsMap.get(Number(dataId)));
                if(!isPrevious){
                this.showInstPopup=true;
                }
             }
            }
        }
    }

    mapDeliveryDate(dataId){
        for(let i=0; i<this.selectedProdDetails.length; i++){
            if(this.selectedProdDetails[i].Index === dataId){   
                this.selectedProdDetails[i].deliveryCollDate = this.productInfoMapNullChecker(this.deliveryDateMap, dataId);
            }
        }
    }
    

    handleShellContract(event){
        const dataId = event.currentTarget.dataset.id;
        const inputValue = event.currentTarget.value;
        this.shellContractMap.set(Number(dataId),inputValue);
        this.handleInstructionLogic(dataId,false);  
    }
    handleInstructions(event){
        const dataId = event.currentTarget.dataset.id;
        const inputValue = event.currentTarget.value;
        this.instructionsMap.set(Number(dataId),inputValue);
        
    }
    handleOrderAction(event){
        const dataId = event.currentTarget.dataset.id;
        const inputValue = event.currentTarget.value;
        if(inputValue && inputValue.length>0){
            this.orderActionMap.push({key:dataId, value:inputValue});
        }
    }

    handleOrdDetailsChange(event){
        const enteredValue = event.target.value;
        if(event.target.dataset.id === 'orderName'){
            this.orderName = enteredValue;
        }else if(event.target.dataset.id === 'customerPo'){
            this.customerPo = enteredValue;
            this.modifiedCustomerPO=enteredValue;
        }else if(event.target.dataset.id === 'otherInst'){
            this.otherInstValue = enteredValue;
            this.modifiedOtherInst=enteredValue;
            this.otherInstCount = this.otherInstValue.length;
        }
    }

  
    handleSubmit(){
        this.isLoading = true;
        this.isShowModalModifyOrder=false;
        this.saveOrderDetails();
    }

 
   
    hideModalBox() {  
        this.isShowErrorModal = false;
        this.isShowModal=false;
    }

    handleScrollBar(){
        const value6 = 6;
        const className = '.'+this.tableClassName;
        let target = this.template.querySelector(className);
        const classNameScroll = '.'+this.scrollBarEnable;
        let scroll = this.template.querySelector(classNameScroll);
        if(this.selectedProdDetails.length>value6){
            if(target && target != null){
                target.classList.add('tableHeight');
                scroll.classList.add('slds-scrollable_y');
            }
        }else if(target.classList.contains('tableHeight')){
                target.classList.remove('tableHeight');
            if(scroll.classList.contains('slds-scrollable_y')){
                scroll.classList.remove('slds-scrollable_y');
            }
        }
    }

    handleDeleteButton(event){
        let nonDeletedCount=0;
        for(let i=0; i<this.selectedProdDetails.length; i++){
            if(this.selectedProdDetails[i].quantity!==0){   
               nonDeletedCount++;
            }
        }
        
        if(nonDeletedCount>1){ 
            const dataId = event.currentTarget.dataset.id;
            //this.quantityMap.delete(Number(dataId));
            this.quantityMap.set(Number(dataId),0);
            this.oliStatusMap.set(Number(dataId),this.reqForCancel);
            let prodIndex=0;
            for(let i=0;i<this.selectedProdDetails.length;i++){
                
                const data = this.selectedProdDetails[i];
                if(Number(data.Index) === Number(dataId)){
                    prodIndex = i;
                    this.deletedProdDetails=[...this.deletedProdDetails,this.selectedProdDetails[i].LineItemId];
                    this.selectedProdDetails[i].quantity=0;
                    this.selectedProdDetails[i].oliStatus=this.reqForCancel;
                    this.selectedProdDetails[i].oliStatusAttr=statusData.get(this.reqForCancel);
                }
            }
           
            //this.selectedProdDetails.splice(Number(prodIndex),1);
            this.deletedProducts=[...this.deletedProducts,this.deletedProdDetails];
            this.generateSerialNumbers();
            this.handleScrollBar();
        }
    }

 

    getRandomNumber(){
        const crypto = window.crypto || window.msCrypto;
        const array = new Uint32Array(1);
        return Number(crypto.getRandomValues(array));
    }

    doInputValidation(screenName){
        
        const isInputsCorrect = [...this.template.querySelectorAll(screenName)]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
            return isInputsCorrect;
    }
    
    saveOrderDetails(){
        if(this.orderName && this.orderName.length>0){
            this.orderWrapper.name = this.orderName;
        }
        if(this.orderNumber && this.orderNumber.length>0){
            this.orderWrapper.orderNumber = this.orderNumber;
        }
        if(this.customerPo && this.customerPo.length>0){
            this.orderWrapper.poNumber = this.customerPo;
        }
        if(this.deliveryTermsValue && this.deliveryTermsValue.length>0){
            this.orderWrapper.deliveryTerms = this.deliveryTermsValue;
        }
        if(this.modeOfTransportValue && this.modeOfTransportValue.length>0){
            this.orderWrapper.modeOfTransport = this.modeOfTransportValue;
        }
        if(this.otherInstValue && this.otherInstValue.length>0){
            this.orderWrapper.otherInstructions = this.otherInstValue;
        }
        if(this.parentSoldToAccId && this.parentSoldToAccId.length>0){
            this.orderWrapper.soldToId = this.parentSoldToAccId; 
        }
        if(this.shipToAccId && this.shipToAccId.length>0){
            this.orderWrapper.shipToId = this.shipToAccId; 
        }
        if(this.billToAccId && this.billToAccId.length>0){
            this.orderWrapper.billToId = this.billToAccId; 
        }
        if(this.soldToNumber && this.soldToNumber.length>0){
            this.orderWrapper.soldToNumber = this.soldToNumber;
        }
        if(this.shipToNumber && this.shipToNumber.length>0){
            this.orderWrapper.shipToNumber = this.shipToNumber;
        }
        if(this.billToNumber && this.billToNumber.length>0){
            this.orderWrapper.billToNumber = this.billToNumber;
        }
        if(this.orderStatus && this.orderStatus.length>0){
            this.orderWrapper.status = this.orderStatus;
        }
        if(this.soldToName && this.soldToName.length>0){
            this.orderWrapper.soldToName = this.soldToName;
        }
        this.saveOrderLineItems();
        if(!this.hasOrderSubmitted){
            //newly added code
            window.console.log('before'+JSON.stringify(this.orderLineItemsList));

            for(let i=0;i<this.orderLineItemsList.length;i++){
                
                const data = this.orderLineItemsList[i];
                window.console.log('inside'+JSON.stringify(data.oliStatus));

                if(data.oliStatus==='CN' || data.oliStatus===this.reqForCancel){
                    this.orderLineItemsList.splice(i,1);
                    i=i-1;
                }
            }
            window.console.log('after'+JSON.stringify(this.orderLineItemsList));

            getOrderNumberOnModify({orderWrapper: this.orderWrapper, orderLineWrapList: this.orderLineItemsList, deletedProducts:this.deletedProdDetails})
            .then(result=>{
                this.hasOrderSubmitted = true;
                this.isLoading = false;
                this.navigateToHomePage();
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
                window.console.log('Error in getting Order Number====>'+JSON.stringify(this.error));
            });
        }
    }

    navigateToHomePage(){
        if(this.deliveryTermsValue!==this.oldOrderDetailList.deliveryTerms || this.modeOfTransportValue!==this.oldOrderDetailList.modeOfTransport|| this.customerPo!==this.oldOrderDetailList.poNumber||this.orderDetailList.otherInstructions!==this.oldOrderDetailList.otherInstructions)
      {
            this.sameData=true;
      }
      
        this.dispatchEvent(new CustomEvent('saveorder',{detail : {"status": this.orderStatus,"ordernumber":this.orderNumber} }));
    }
    prepareSelectedOrder(){
        this.orderName=this.orderDetailList.name;
        this.deliveryTermsValue = this.orderDetailList.deliveryTerms;
        this.customerPo = this.orderDetailList.poNumber;
        this.modeOfTransportValue = this.orderDetailList.modeOfTransport;
        this.otherInstValue = this.orderDetailList.otherInstructions;
        this.orderStatus=this.orderDetailList.status;
        this.orderNumber=this.orderDetailList.orderNumber;    
    }
    prepareSelectedProductList(){
        const value2 = 2;
        if(this.oldOrderLineItemsList && this.oldOrderLineItemsList.length >0){
            let productData =[];
            
            for(let i=0; i<this.oldOrderLineItemsList.length;i++){    
                const prodData =[];
                    let serialNo = i+1;
                    serialNo = serialNo + '';
                    prodData.sno = serialNo.padStart(value2,'0');
                    prodData.Id = this.getRandomNumber();
                    prodData.Index = this.getRandomNumber();
                    prodData.quantity =this.oldOrderLineItemsList[i].Quantity__c;
                    prodData.unit =this.oldOrderLineItemsList[i].Unit__c;
                    prodData.deliveryCollDate = this.oldOrderLineItemsList[i].Delivery_Collection_Date__c;
                    prodData.shellContractNo = this.oldOrderLineItemsList[i].Contract_No__c;
                    prodData.instructions = this.oldOrderLineItemsList[i].Other_Instruction__c;
                    prodData.Name=this.oldOrderLineItemsList[i].Material_Name__c;
                    prodData.Number=this.oldOrderLineItemsList[i].MaterialNumber__c;
                    prodData.LineItemId=this.oldOrderLineItemsList[i].Id;
                    prodData.oliStatus=this.handleOliStatus(this.oldOrderLineItemsList[i].TCP_Modify_Cancel_Status__c,this.oldOrderLineItemsList[i].Quantity__c,this.oldOrderLineItemsList[i].GSAP_Bol_Delivery__c);
                    prodData.oliStatusAttr=statusData.get(prodData.oliStatus);
                    productData = [...productData, prodData];   
                    this.quantityMap.set(prodData.Index,prodData.quantity);
                    this.initialQuantityMap.set(prodData.Index,prodData.quantity);
                    this.unitComboMap.set(prodData.Index,prodData.unit);
                    this.initialUnitComboMap.set(prodData.Index,prodData.unit);
                    this.shellContractMap.set(prodData.Index, prodData.shellContractNo);
                    this.initialShellContractMap.set(prodData.Index, prodData.shellContractNo);
                    this.instructionsMap.set(prodData.Index, prodData.instructions);
                    this.initialInstructionsMap.set(prodData.Index, prodData.instructions);
                    this.lineItemIdMap.set(prodData.Index,prodData.LineItemId);
                    this.deliveryDateMap.set(prodData.Index,prodData.deliveryCollDate);
                    this.initialDeliveryDateMap.set(prodData.Index,prodData.deliveryCollDate);
                    this.productNumberMap.set(prodData.Index,prodData.Number);
                    this.materialNameMap.push({key:prodData.Index, value:prodData.Name});
                    this.oliStatusMap.set(prodData.Index,prodData.oliStatus);
                    getDateWithMonthName({ reqDate: this.oldOrderLineItemsList[i].Delivery_Collection_Date__c }) .then(result => {
                        prodData.deliveryDateWithMonth = result;
                        if(prodData.deliveryDateWithMonth && prodData.deliveryDateWithMonth.length>0){
                            this.deliveryDateWithMonthMap.set(prodData.Index,prodData.deliveryDateWithMonth);
                        
                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.error = error;
                        window.console.log('Error in updating date====>' + JSON.stringify(this.error));
                    });


            }
            if(productData && productData.length>0){
                this.selectedProdDetails = productData;
                
            }
            
        }
    }

    handleOliStatus(status,quantity,boldel){
        if(status==='Cancelled' && quantity===0){
            return 'CN';
        }else if(status==='Cancellation' && quantity===0){
            return this.reqForCancel;
        }else if(boldel){
            return 'DN';
        }

    }

    renderedCallback(){
        const getselectedStep = this.selectedStep;
        
        if(getselectedStep === 'Step1'){
            this.populateProdCheckBox();
        }
        if(getselectedStep === 'Step2'){
            this.handleScrollBar();
        }
        if(getselectedStep === 'Step3'){
            this.handleScrollBar();
        }

        document.title = 'TCP | Modify Order';
    }

    populateProdCheckBox(){
        if(this.productList && this.productList.length>0){
            for(let i=0;i<this.productList.length; i++){
                if(this.productList[i].Checked===true){
                    const dataId = this.productList[i].Id;
                    const checkBox = this.template.querySelector('[name="'+dataId+'"]');
                    checkBox.checked = true;
                }
            }
        }
    }

    compareProductOnNavigation(){
        if(this.productList && this.productList.length>0){
            for(let i=0;i<this.productList.length; i++){
                if(this.productList[i].Checked===true){
                    const prodName = this.productList[i].Name;
                    let found = false;
                    for(let j=0; j<this.selectedProdDetails.length; j++){
                        const selProdName = this.selectedProdDetails[j].materialName;
                        if(prodName.trim() === selProdName.trim()){
                            found = true;
                            break;
                        }
                    }
                    if(!found){
                        this.productList[i].Checked=false;
                        const prodIndex = this.selectedProducts.indexOf(prodName);
                        this.selectedProducts.splice(prodIndex,1);
                        this.SelectedProdCount--;
                    }

                }
            }
        }
        
    }

    saveOrderLineItems(){
        const value2 = 2;
       if(this.orderLineItemsList.length === 0){ 
            let i=0;
            for(let [mapkey,mapvalue] of this.quantityMap){
                    const orderLine = {};
                    let serialNum = i+1;
                    serialNum = serialNum + '';
                    orderLine['sno'] = serialNum.padStart(value2,'0');
                    orderLine['quantity']  = mapvalue;
                    if(this.shellContractMap.has(mapkey)){
                        orderLine['shellContractNo'] = this.shellContractMap.get(mapkey);
                    }
                    if(this.deliveryDateMap.has(mapkey)){
                        orderLine['deliveryCollDate'] = this.deliveryDateMap.get(mapkey);
                    }
                    if(this.deliveryDateWithMonthMap.has(mapkey)){
                        orderLine['deliveryCollDateWithMonth'] = this.deliveryDateWithMonthMap.get(mapkey);
                    }
                    if(this.materialNameMap.find(o => o.key === mapkey)){
                        orderLine['materialName'] = this.materialNameMap.find(o => o.key === mapkey).value;
                    }
                    if(this.productNumberMap.has(mapkey)){
                        orderLine['materialNumber'] = this.productNumberMap.get(mapkey);
                    }
                    if(this.selectedProductMap.find(o => o.key === orderLine['materialName'])){
                        orderLine['productId'] = this.selectedProductMap.find(o => o.key === orderLine['materialName']).value;
                    }
                    if(this.instructionsMap.has(mapkey)){
                        orderLine['instructions'] = this.instructionsMap.get(mapkey);
                    }
                    if(this.lineItemIdMap.has(mapkey)){
                        orderLine['id'] = this.lineItemIdMap.get(mapkey);
                    }
                    
                    if(this.unitComboMap.has(mapkey)){
                        orderLine['unit'] = this.unitComboMap.get(mapkey);
                    }
                    //newly added
                    if(this.oliStatusMap.has(mapkey)){
                        orderLine['oliStatus'] = this.oliStatusMap.get(mapkey);
                        orderLine['oliStatusAttr']=statusData.get(this.oliStatusMap.get(mapkey));
                    }

                    i++;
                    this.orderLineItemsList = [...this.orderLineItemsList,orderLine];               
                
            }
        
        }
    }

    mapOrderLineItems(){
        for(let i=0; i<this.selectedProdDetails.length; i++){
            const dataId = this.selectedProdDetails[i].Index;
            this.selectedProdDetails[i].quantity = this.productInfoMapNullChecker(this.quantityMap, dataId);
            this.selectedProdDetails[i].unit = this.productInfoMapNullChecker(this.unitComboMap, dataId);
            this.selectedProdDetails[i].deliveryCollDate = this.productInfoMapNullChecker(this.deliveryDateMap, dataId);
            this.selectedProdDetails[i].deliveryDateWithMonth =this.productInfoMapNullChecker(this.deliveryDateWithMonthMap, dataId);
            this.selectedProdDetails[i].shellContractNo = this.productInfoMapNullChecker(this.shellContractMap, dataId);
            this.selectedProdDetails[i].instructions = this.productInfoMapNullChecker(this.instructionsMap, dataId);
            this.selectedProdDetails[i].oliStatus = this.productInfoMapNullChecker(this.oliStatusMap, dataId);
            
        }
    }

    scrollToTopOfPage(){
        window.scrollTo(0,0);
    }

    generateSerialNumbers(){
        const value2 = 2;
        let sno = 0;
        for(let i=0;i<this.selectedProdDetails.length;i++){
            sno++;
            const serialNo = sno+'';
            this.selectedProdDetails[i].sno = serialNo.padStart(value2,'0');
        }
    }
  
}