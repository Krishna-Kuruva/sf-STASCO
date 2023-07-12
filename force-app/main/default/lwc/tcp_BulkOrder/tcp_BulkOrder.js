import { LightningElement, track, wire } from 'lwc';
import uId from '@salesforce/user/Id';
import { CurrentPageReference } from 'lightning/navigation';
import communityBasePath from '@salesforce/community/basePath';
import getCustomerDetails from '@salesforce/apex/TCP_BulkOrderController.getCustomerDetails';
import getContactsByCustomerId from '@salesforce/apex/TCP_BulkOrderController.getContactsByCustomerId';
import getAccDetailsByParentId from '@salesforce/apex/TCP_HomePageController.getAccDetailsByParentId';
import getProductDetails from '@salesforce/apex/TCP_HomePageController.getProductDetails';
import getProductDetailsBySearchKey from '@salesforce/apex/TCP_HomePageController.getProductDetailsBySearchKey';
import getPickListValues from '@salesforce/apex/TCP_HomePageController.getPickListValues';
import saveBulkOrderDetails from '@salesforce/apex/TCP_BulkOrderController.saveBulkOrderDetails';
import TCP_LineItemMinValueError from '@salesforce/label/c.TCP_LineItemMinValueError';
import TCP_LineItemMaxValueError from '@salesforce/label/c.TCP_LineItemMaxValueError';
import TCP_CurrentOrderLineInfo from '@salesforce/label/c.TCP_CurrentOrderLineInfo';
import TCP_LineItemLeftInfo from '@salesforce/label/c.TCP_LineItemLeftInfo';



const columns = [
    { label: 'Product Name', fieldName: 'Name' },
];

const calendarVal = 10;
const minTableHgt = 6;
const padNum = 2;

export default class TcpBulkOrder extends LightningElement{

    
    orderApiName ='Order';
    deliveryTermApiName = 'Delivery_Terms__c';
    modeofTransportApiName = 'Mode_of_Transport__c';
    orderLineItemApiName = 'TCP_OrderLineItem__c';
    unitApiName = 'Unit__c';
    columns = columns;
    
    /*  Progress  Steps */
    @track selectproduct = true;
    @track enterdetails  = false;
    @track reviewsubmit  = false;
    @track chevronrightShow = true;

    /* Model */
    @track isShowDeleteOrder = false;
    @track isShowExitOrder = false;
    @track isShowCancelOrder = false;
    @track isShowBulkOrder = false;
    @track isShowExitCurrentOrder = false;
    @track isShowError = false;
    @track isShowMaximumOrder = false;
    @track userId = uId;
    @track customerValue;
    @track soldToOptions = [];
    @track soldToIdMap = [];
    @track soldToIdNameMap = new Map();
    @track shipToIdNameMap = new Map();
    @track billToIdNameMap = new Map();
    @track contactIdMap = new Map();
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
    @track shipToOptions = [];
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
    @track selectedStep = 'Step1';

    @track quantityMap = new Map();
    @track deliveryDateMap = new Map();
    @track shellContractMap =new Map();
    @track instructionsMap = new Map();
    @track productNumberMap = new Map();
    @track unitComboMap = new Map();
    @track productIdMap = new Map();
    @track fetchedProductsMap = new Map();
    @track orderLineItemsList = [];
    @track isShowModal = false;

    @track tempQuantityMap = new Map();
    @track tempUnitComboMap = new Map();
    @track tempDeliveryDateMap = new Map();
    @track tempShellContractMap =new Map();
    @track tempInstructionsMap = new Map();
    tableHeader = 'slds-table--header-fixed_container';
    @track accountId;
    @track isLoading = false;
    @track soldToName;
    @track noSearchResult;
    @track isShowErrorModal;
    @track tableClassName = this.tableHeader;
    @track scrollBarEnable = 'tablecheck';
    @track reviewTable = this.tableHeader;
    @track scrollForReview = 'tablescroll';
    @track reviewProdTable = this.tableHeader;
    @track scrollForReviewProd = 'tablescroll';
    @track hasOrderSubmitted = false;
    @track requestedByOptions = [];
    @track selectedReqByValue;
    @track productNoteMsgEnable = true;
    @track reviewOrderList = [];
    @track deleteOrderDataId;
    @track onEditRecordData;
    @track enableComboBox = true;
    @track editedRecRandId;
    @track orderWrapperList = [];
    @track navToBulkOrder = false;
    @track enableExitBtn = false;
    @track populateProducts = false;
    @track enableActionBtn = false;
    @track editBtnEnabled = false;
  
    //For delivery date
    currentdate;
    maximumdate;
    selectedval;

    exitbuttonMsg1;
    exitbuttonMsg2;
    lineItemError;
    lineItemInfo;
    lineItemleftInfo;
    minDateValue;
    maxDateValue;

    sldsIsCompleted = 'slds-is-completed';
    sldsIsActive = 'slds-is-active';
    sldsIsProgress = 'slds-is-progress';
    scrollBarVar = 'slds-scrollable_y';
    calendarValue = calendarVal;
    minTableHeight = minTableHgt;
    padNo = padNum;

    constructor(){
        super();

        this.accountId = this.parentaccid;
        getPickListValues({objectApiName: this.orderApiName, fieldApiName: this.deliveryTermApiName})
        .then(result=>{
            for(const key in result){
                const option = {
                    label : result[key],
                    value : result[key]
                };
                this.delTermsOptions = [...this.delTermsOptions,option];
                if(this.delTermsOptions.length===0){
                    this.hasDeliveryTermsData=false;
                }
            }
        })
        .catch(error => {
            this.error = error;
        });

        getPickListValues({objectApiName: this.orderApiName, fieldApiName: this.modeofTransportApiName})
        .then(result=>{
            for(const key in result){
                const option = {
                    label : result[key],
                    value : result[key]
                };
                this.modeOfTransOptions = [...this.modeOfTransOptions,option]; 
                if(this.modeOfTransOptions.length===0){
                    this.hasTransportData=false;
                }
            }
        })
        .catch(error => {
            this.error = error;
        });

        getPickListValues({objectApiName: this.orderLineItemApiName, fieldApiName: this.unitApiName})
        .then(result=>{
            for(const key in result){
                const option = {
                    label : result[key],
                    value : result[key]
                };
                this.unitOptions = [...this.unitOptions,option];
            }
        })
        .catch(error => {
            this.error = error;
        });

    } 

    @wire(CurrentPageReference)
    currentPageReference;
    
    connectedCallback(){
        this.accountId = this.parentaccid;
        this.handleNavFromBulkOrder();
        //Calander View for Delivery date in place order page
        this.currentdate = new Date().toISOString().slice(0,this.calendarValue);
        //Max Date
        const todaydate = new Date();
        // Add 90 days to current date
        const noOfDays = 89;
        todaydate.setDate(todaydate.getDate() + noOfDays);
        this.maximumdate = todaydate.toISOString().slice(0,this.calendarValue);
    }

    handleExitBtn(){
        this.isShowExitCurrentOrder = true;
    }
    
    handleNavFromBulkOrder(){
        if(this.currentPageReference.state.pagesrc){
            this.navToBulkOrder = true;
        }else{
            this.navToBulkOrder = false;
        }
    }

    handleCancel() {
            this.showModalBox();
         }
    
    handleHomepage() {
        if(this.navToBulkOrder){
            this.navToBulkOrder = false;
        }
        this.navigateToHomePage();
    }

    handleExitOrderYes(){
        this.isShowExitCurrentOrder = false;
        this.enableActionBtn = true;
        window.scrollTo(0,0);
        this.enableActionButtons();
        if(this.selectproduct){
            this.selectproduct = false;
            this.enterdetails = false;
            this.reviewsubmit = true;
            this.handleProgressIndicator('selectproduct',this.sldsIsCompleted,this.sldsIsActive);
            this.handleProgressIndicator('enterdetails',this.sldsIsCompleted,this.sldsIsProgress);
            this.handleProgressIndicator('review',this.sldsIsActive,this.sldsIsProgress);
           
        }else if(this.enterdetails){
            this.selectproduct = false;
            this.enterdetails = false;
            this.reviewsubmit = true;
            this.handleProgressIndicator('enterdetails',this.sldsIsCompleted,this.sldsIsActive);
            this.handleProgressIndicator('review',this.sldsIsActive,this.sldsIsProgress);
            if(this.editBtnEnabled){
                this.checkForChangesOnExit();
            }
        }else{
            this.selectproduct = false;
        }
        
    }

    

    get minDate(){
        if(this.minDateValue=== undefined)
        {
        this.minDateValue= new Date().toISOString().substring(0, this.calendarValue);
        }
        return this.minDateValue;
    }

    get maxDate(){
        if(this.maxDateValue=== undefined)
        {
            const today= new Date(); 
            const numberOfDaysToAdd = 90;
            const result = today.setDate(today.getDate() + numberOfDaysToAdd);
            this.maxDateValue= new Date(result).toISOString().substring(0, this.calendarValue);
        }
        return this.maxDateValue;
    }

    get prodLineCount(){
        return this.selectedProdDetails.length;
    }

    get orderCount(){
        return this.reviewOrderList.length;
    }

    

    showModalBox() {  
        this.isShowModal = true;
    }
    handleCloseModal() {  
        this.isShowModal = false;
    }
    
    value = '10';

    get options() {
        return [
            { label: '10 / page ', value: '10' },
            { label: '15 / page', value: '15' },
            { label: '20 / page', value: '20' },
        ];
    }

    @wire(getCustomerDetails)
    wiredAccounts({data, error}){
        if(data){
            this.processWiredAccounts(data);
            this.populateAccounts();
            this.error = null;
           
        }
        else if (error) {
            this.error = error; 
            this.hasCustomerData = false;
            this.hasDeliveryToData = false;
            this.hasInvoiceToData = false;
        }else{
            this.error = error;
        }
    }

    processWiredAccounts(data){
        for (const key in data) {
            const accObj = data[key].Account__r;
            const shippingAddress = accObj.ShippingAddress;
            const accStreet = this.nullValueChecker(shippingAddress.street);
            const accCity = this.nullValueChecker(shippingAddress.city);
            const accState = this.nullValueChecker(shippingAddress.state);
            const accPostalCode = this.nullValueChecker(shippingAddress.postalCode);
            const accCountry = this.nullValueChecker(shippingAddress.country);
            const custAddr = `${accObj.Name}, ${accStreet}${accCity}${accState}${accPostalCode}${accCountry}`;
        
            this.soldToIdMap.push({key:custAddr, value: accObj});
            const accName = `${accObj.Name}, ${shippingAddress.city}`;
            this.soldToIdNameMap.set(data[key].Account__c,accName);
            
            const option = {
                label : `${accObj.Name}, ${shippingAddress.city}`,
                value : custAddr
            };
            this.soldToOptions = [...this.soldToOptions, option];
        }
    }

    populateAccounts(){
        if(this.soldToOptions.length === 1){
            this.customerValue = this.soldToOptions[0].value;
            const soldToData = this.soldToIdMap.find(o => o.key === this.customerValue).value;
            this.parentSoldToAccId = soldToData.Id
            this.soldToName = soldToData.Name;
            this.soldToNumber = soldToData.AccountNumber;
            this.customerDetails = this.soldToOptions[0].value;
            if(this.parentSoldToAccId){
                this.getChildAccounts();
            }
        }
        if(this.soldToOptions.length === 0){
            this.hasCustomerData = false;
            this.hasDeliveryToData = false;
            this.hasInvoiceToData = false;
        } 
    }

    nullValueChecker(input){
        if(input && input.length>0){
            return `${input}, `;
        }else{
            return '';
        }
    }

    get customerOptions(){
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

    get reqByOptions(){
        return this.requestedByOptions;
    }

    handleCustomerChange(event){
        const selectedValue = event.detail.value;
        this.customerValue = selectedValue;
        this.customerDetails = selectedValue;
        const soldToData = this.soldToIdMap.find(o => o.key === selectedValue).value; 
        this.parentSoldToAccId = soldToData.Id;
        this.soldToNumber = soldToData.AccountNumber;
        this.productNoteMsgEnable = true;
        this.showProducts = false;
        this.hasProductData = true;
        this.productList = [];
        this.selectedProducts = [];
        this.shipToOptions = [];
        this.billToOptions = [];
        this.deliveryValue = '';
        this.billingValue = '';
        this.deliveryDetails = '';
        this.billingDetails = '';
       
        if(this.parentSoldToAccId){
            this.getChildAccounts();
        }
        
    }

    handleDeliveryChange(event){
        const selectedValue = event.detail.value;
        this.deliveryValue = selectedValue;
        this.deliveryDetails = selectedValue;
        const shipToData = this.shipToNamesMap.find(o => o.key === selectedValue).value;
        this.shipToAccId = shipToData.Id;
        this.shipToNumber = shipToData.AccountNumber;
        this.getProductDetails();
    }

    handleInvoiceChange(event){
        const selectedValue = event.detail.value;
        this.billingValue = selectedValue;
        this.billingDetails = selectedValue;
        const billToData = this.billToNamesMap.find(o => o.key === selectedValue).value;
        this.billToAccId = billToData.Id;
        this.billToNumber = billToData.AccountNumber;
    }

    handleChange(event){
        this.value = event.detail.value;


    }

    handleRequestedBy(event){
        this.selectedReqByValue = event.detail.value;
    }

    handleProduct(event){
        const isChecked = event.target.checked;
        const productId = event.target.name;
        
        if(isChecked){  
            this.handleProductChecked(productId);
        }else{
            this.handleProductUnchecked(productId);
        }  
    }

    handleProductChecked(productId){
        if(this.productList && this.productList.length>0){
            for(const value of this.productList){
                if(value.Id === productId){
                    value.Checked=true;
                }
            }
        }
        this.SelectedProdCount++;
        this.selectedProducts = [...this.selectedProducts,productId];
        this.hasSelectedProducts=true;
    }

    handleProductUnchecked(productId){
        if(this.productList && this.productList.length>0){
            for(const value of this.productList){
                if(value.Id === productId){
                    value.Checked=false;
                }
            }
        } 
        const prodIndex = this.selectedProducts.indexOf(productId);
        this.selectedProducts.splice(prodIndex,1);
        this.SelectedProdCount--;
    }

    handleSearchProduct(event){
        const searchKey = event.target.value.toLowerCase();
        this.productSearchText=event.target.value;
        
        if(searchKey){
            this.productList = this.productListData;
            if(this.productList) {
                this.searchProductHelper(searchKey);    
            }
        }else{
            this.noSearchResult = false;
            this.productList = this.productListData;
        }  
    }

    searchProductHelper(searchKey){
        const recs = [];    
        for(const value of this.productList){
            const name =  (value.Name).toLowerCase();
            const number = (value.Number);
            if(name.includes(searchKey) || number.includes(searchKey)) {
                recs.push(value);
            }
        }
        if(recs && recs.length>0){
            this.productList = recs;
            this.noSearchResult = false;
            
        }else{
            this.productList = recs;
            this.noSearchResult = true;
            
        }
    }

    handleDeliveryTermsChange(event){
        this.deliveryTermsValue = event.detail.value;
    }

    handleModeOfTransChange(event){
        this.modeOfTransportValue = event.detail.value;
    }

    handleUnitChange(event){
        const dataId = event.currentTarget.name;
        const inputValue = event.currentTarget.value;
        if(dataId){
            this.unitComboMap.set(Number(dataId),inputValue);
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

    }
    handleDeliveryDate(event){
        
        const dataId = event.currentTarget.dataset.id;
        const inputValue = event.currentTarget.value;
        
        if(inputValue && inputValue.length>0){
            
            this.deliveryDateMap.set(Number(dataId),inputValue);
            this.mapDeliveryDate(Number(dataId));
        }
    }
    handleShellContract(event){
        const dataId = event.currentTarget.dataset.id;
        const inputValue = event.currentTarget.value;
        this.shellContractMap.set(Number(dataId),inputValue);
        
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
        }else if(event.target.dataset.id === 'otherInst'){
            this.otherInstValue = enteredValue;
            this.otherInstCount = this.otherInstValue.length;
        }else{
            this.error = enteredValue;
        }
    }

    handleBulkOrderSubmit(){
        this.isShowBulkOrder = false;
        this.isLoading = true;
        this.orderStatus ='Submitted';
        this.saveBulkOrder();
    }

    handleRowAction(event){
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].Name && selectedRows[i].Name.length>0){
                this.selectedProducts[i]=selectedRows[i].Name;
            }
        }
    }

    handleAddButton(event){
       
        const dataId = event.currentTarget.dataset.id;
        const prodName = event.currentTarget.dataset.name;
        const prodNumber=event.currentTarget.dataset.code;
        const title = event.currentTarget.dataset.title;
        const target = this.template.querySelector(`[data-id="${title}"]`);
        const inputValue = target.value;
        
        if(inputValue && inputValue.length>0 && Number(inputValue)>0){
            target.value=1;
            const totalItems = Number(inputValue) + this.selectedProdDetails.length;
            const maxNoOfProds = 30;
            
            if(totalItems > maxNoOfProds){
                this.isShowErrorModal = true;
                this.lineItemError = TCP_LineItemMaxValueError;
                let lineItemCount = (this.selectedProdDetails.length).toString();
                lineItemCount = lineItemCount.padStart(this.padNo,'0') + '.';
                this.lineItemInfo = `${TCP_CurrentOrderLineInfo} ${lineItemCount}`;
                let leftCount = (Number(maxNoOfProds)-Number(this.selectedProdDetails.length)).toString();
                leftCount = leftCount.padStart(this.padNo,'0') + '.';
                this.lineItemleftInfo = `${TCP_LineItemLeftInfo} ${leftCount}`;
            }else{
                this.addButtonHelper(inputValue, dataId, prodName, prodNumber);
                this.handleScrollBar();

            }
        }else{
            this.isShowErrorModal = true;
            this.lineItemError = TCP_LineItemMinValueError;
        }        
    }

    addButtonHelper(inputValue, dataId, prodName, prodNumber){
        const length = Number(inputValue); 
        let sno = Number(this.selectedProdDetails.length);
        for(let i=0;i<length; i++){
            sno++;
            for(const value of this.selectedProdDetails){
                if(Number(dataId) === value.Index){
                    const prodData =[];
                    const serialNo = sno+'';
                    prodData.sno = serialNo.padStart(this.padNo,'0');
                    prodData.materialName = prodName;
                    prodData.productNumber=prodNumber;
                    prodData.productId = value.productId;
                    prodData.Id = this.getRandomNumber();
                    prodData.Index = this.getRandomNumber();
                    prodData.quantity = this.productInfoMapNullChecker(this.quantityMap, dataId);
                    prodData.unit = this.productInfoMapNullChecker(this.unitComboMap, dataId);
                    prodData.deliveryCollDate = this.productInfoMapNullChecker(this.deliveryDateMap, dataId);
                    prodData.shellContractNo = this.productInfoMapNullChecker(this.shellContractMap, dataId);
                    prodData.instructions = this.productInfoMapNullChecker(this.instructionsMap, dataId);

                    this.quantityMap.set(Number(prodData.Index),prodData.quantity);
                    this.unitComboMap.set(Number(prodData.Index),prodData.unit);
                    this.deliveryDateMap.set(Number(prodData.Index),prodData.deliveryCollDate);
                    this.shellContractMap.set(Number(prodData.Index),prodData.shellContractNo);
                    this.instructionsMap.set(Number(prodData.Index),prodData.instructions);
                    this.materialNameMap.push({key:Number(prodData.Index), value:prodName});
                    this.selectedProdDetails = [...this.selectedProdDetails, prodData];
                    
                }
            }
        }        
    }

    hideModalBox() {  
        this.isShowErrorModal = false;
    }

    productInfoMapNullChecker(dataMap, dataId){
        if(dataMap.has(Number(dataId))){
            return dataMap.get(Number(dataId));
        }else{
            return '';
        }
    }

    handleScrollBar(){
        const className = '.'+this.tableClassName;
        const target = this.template.querySelector(className);
        const classNameScroll = '.'+this.scrollBarEnable;
        const scroll = this.template.querySelector(classNameScroll);
        if(this.selectedProdDetails.length>this.minTableHeight){
            if(target && target != null){
                target.classList.add('tableHeight');
                scroll.classList.add(this.scrollBarVar);
            }
        }else if(target.classList.contains('tableHeight')){
            target.classList.remove('tableHeight');
            if(scroll.classList.contains(this.scrollBarVar)){
                scroll.classList.remove(this.scrollBarVar);
            }
        }else{
            this.error = className;
        }
    }

    handleScrollBarReview(){        
        if(this.reviewOrderList.length > this.minTableHeight){
            this.reviewTable += ' tableHeight';
            this.scrollForReview += ' '+this.scrollBarVar;
        }
        else{
            this.reviewTable = this.tableHeader;
            this.scrollForReview ='';
        }
    }

    handleDeleteButton(event){
       if(this.selectedProdDetails.length > 1){ 
            const dataId = event.currentTarget.dataset.id;
            this.quantityMap.delete(Number(dataId));
            let prodIndex=0;
            for(let i=0;i<this.selectedProdDetails.length;i++){
                const data = this.selectedProdDetails[i];
                if(Number(data.Index) === Number(dataId)){
                    prodIndex = i;
                }
            }
            this.selectedProdDetails.splice(Number(prodIndex),1);
            this.generateSerialNumbers()
            this.handleScrollBar();
        }
    }

    handleOrderDelete(event){ 
        this.isShowDeleteOrder = true;
        this.deleteOrderDataId = event.currentTarget.dataset.id;
    }

    handleConfirmDeleteOrder(){
        const dataId = this.deleteOrderDataId;
        if(dataId && dataId.length>0){
            let prodIndex;
            for(let i=0;i<this.reviewOrderList.length;i++){
                const data = this.reviewOrderList[i];
                if(data.randomId === dataId){
                    prodIndex = i;
                }
            }
            this.reviewOrderList.splice(Number(prodIndex),1);
            if(this.reviewOrderList.length ===0){
                this.enableActionBtn = false;
            }
            this.deleteOrderDataId = '';
            this.isShowDeleteOrder = false;
            this.handleScrollBarReview();
        }
    }

    getRandomNumber(){
        const crypto = window.crypto || window.msCrypto;
        const array = new Uint32Array(1);
        return Number(crypto.getRandomValues(array));
    }

    generateSerialNumbers(){
        let sno = 0;
        for(const value of this.selectedProdDetails){
            sno++;
            const serialNo = sno+'';
            value.sno = serialNo.padStart(this.padNo,'0');
            window.console.log('Checking S.No Value' +value);
        }
    }
    getChildAccounts(){
        if(this.parentSoldToAccId){
            this.childAccounts = [];
            getAccDetailsByParentId({parentAccId : this.parentSoldToAccId})
            .then(result => {
                const data = result;
                this.childAccounts = data;
                if(this.childAccounts && this.childAccounts.length >0){
                    this.hasDeliveryToData = true;
                    this.hasInvoiceToData = true;
                    this.formatChildAccData();
                }
                else{
                    this.hasDeliveryToData = false;
                    this.hasInvoiceToData = false;
                }
            })
            .catch(error => {
                this.error = error;
                window.console.log('Error in getting details====>'+JSON.stringify(this.error));
            });
            
        }
    }

    formatChildAccData(){
        this.shipToData = [];
        this.billToData = [];
        this.payerData = [];
        if(this.childAccounts && this.childAccounts.length >0 ){
            this.formatChildAccDataHelper();
            if(this.shipToData && this.shipToData.length > 0){
                this.getShipToDetails();
            }else{
                this.hasDeliveryToData = false;
            }
            
            if(this.billToData && this.billToData.length > 0){
                this.getBillToDetails();
            }else{
                this.hasInvoiceToData = false;
            }
            
        }
    }

    formatChildAccDataHelper(){
        for(const value of this.childAccounts){
            if(value.Customer_Type__c === 'Ship To'){
                this.shipToData = [...this.shipToData,value];
            }else if(value.Customer_Type__c === 'Bill To'){
                this.billToData = [...this.billToData,value];
            }else if(value.Customer_Type__c === 'Payer'){
                this.payerData = [...this.payerData,value];
            }else{
                this.error ='Failed';
            }
        }
    }

    getShipToDetails(){
        this.shipToOptions = [];
        for(const dataValue of this.shipToData){
            const shippingAddress = dataValue.ShippingAddress;
            const accStreet = this.nullValueChecker(shippingAddress.street);
            const accCity = this.nullValueChecker(shippingAddress.city);
            const accState = this.nullValueChecker(shippingAddress.state);
            const accPostalCode = this.nullValueChecker(shippingAddress.postalCode);
            const accCountry = this.nullValueChecker(shippingAddress.country);
            const shipToAddr = `${dataValue.Name}, ${accStreet}${accCity}${accState}${accPostalCode}${accCountry}`;
            
            this.shipToNamesMap.push({key:shipToAddr, value: dataValue});
            this.shipToIdNameMap.set(dataValue.Id,`${dataValue.Name}, ${shippingAddress.city}`);
            const option = {
                label : `${dataValue.Name}, ${shippingAddress.city}`,
                value : shipToAddr
            };
            this.shipToOptions = [...this.shipToOptions, option];     
        }
        if(this.shipToOptions.length === 1){
            const selectedValue = this.shipToOptions[0].value;
            this.deliveryValue = selectedValue;
            this.deliveryDetails = selectedValue;
            const shipToData = this.shipToNamesMap.find(o => o.key === selectedValue).value;
            this.shipToAccId = shipToData.Id;
            this.shipToNumber = shipToData.AccountNumber;
            this.getProductDetails();
        }
       
    }

    getBillToDetails(){
        let tempbillTo = [];
        for(const dataValue of this.billToData){
            const billingAddress = dataValue.ShippingAddress;
            const accStreet = this.nullValueChecker(billingAddress.street);
            const accCity = this.nullValueChecker(billingAddress.city);
            const accState = this.nullValueChecker(billingAddress.state);
            const accPostalCode = this.nullValueChecker(billingAddress.postalCode);
            const accCountry = this.nullValueChecker(billingAddress.country);
            const billToAddr = `${dataValue.Name}, ${accStreet}${accCity}${accState}${accPostalCode}${accCountry}`;
            
            this.billToNamesMap.push({key:billToAddr, value: dataValue});
            this.billToIdNameMap.set(dataValue.Id,`${dataValue.Name}, ${billingAddress.city}`);
            const option = {
                label : `${dataValue.Name}, ${billingAddress.city}`,
                value : billToAddr
            };
            tempbillTo = [...tempbillTo, option]; 
        }
        this.billToOptions = tempbillTo;
        if(this.billToOptions.length === 1){
            const selectedValue = this.billToOptions[0].value;
            this.billingValue = selectedValue;
            this.billingDetails = selectedValue;
            const billToData = this.billToNamesMap.find(o => o.key === selectedValue).value;
            this.billToAccId = billToData.Id;
            this.billToNumber = billToData.AccountNumber;

        }
        
        
    }

    getProductDetails(){
        this.productNoteMsgEnable = false;
        this.SelectedProdCount = 0;
        this.selectedProducts =[];
        let tempProdData = [];
        this.productList = [];
        this.isLoading=true;
        getProductDetails({soldToId: this.parentSoldToAccId, shipToId: this.shipToAccId})
        .then(result=>{
            for(const key in result){
                const prodData =[];
                prodData.Name = result[key].Product__r.Name;
                prodData.Id = result[key].Product__r.Id;
                prodData.Number = result[key].Product__r.ProductCode;
                this.fetchedProductsMap.set(String(result[key].Product__r.Id),result[key].Product__r.Name);
                prodData.Checked = false;
                tempProdData = [...tempProdData,prodData];
               
                this.selectedProductMap.push({key:prodData.Name, value:prodData.Id});
                this.productNumberMap.set(String(result[key].Product__r.Id),prodData.Number);
            }
            if(tempProdData && tempProdData.length >0){
                this.showProducts = true;
                this.hasProductData = true;
                this.productList = tempProdData;
                this.productListData = tempProdData;
            }else{
                this.productList = null;
                this.showProducts = false;
                this.hasProductData = false;
            }
            this.isLoading=false;
        })
        .catch(error => {
            this.isLoading=false;
            this.error = error;
            this.hasProductData = false;
            window.console.log('Error in getting products====>'+JSON.stringify(this.error));
        });

    }

    getProductSearchData(){
        let tempProdData = [];
        getProductDetailsBySearchKey({searchKey : this.searchKey, soldToId: this.parentSoldToAccId, shipToId: this.shipToAccId})
            .then(result=>{
                for(const i in result){
                    const prodData =[];
                    prodData.Name = result[i].Product__r.Name;
                    prodData.Id = result[i].Id;
                    tempProdData = [...tempProdData,prodData];
                }
                if(tempProdData && tempProdData.length >0){
                    this.showProducts = true;
                    this.productList = tempProdData;
                }else{
                    this.productList = null;
                    this.showProducts = false;
                }
                
        })
        .catch(error => {
            this.error = error;
            window.console.log('Error in getting products====>'+JSON.stringify(this.error));
        });

    }
    //Sort
    sortProductDesc(){
        if(this.showProducts && this.productList.length >0){
            // let prodList =[];
            //     for(let i=this.productList.length-1 ; i>=0 ;i--){
            //         const prodData =[];
            //         prodData.Name = this.productList[i].Name;
            //         prodData.Id = this.productList[i].Id;
            //         prodData.Number=this.productList[i].Number;
            //         prodList = [...prodList,prodData];
            //     }
            //     this.productList = prodList;
                this.productList.sort((a, b) => (a.Name > b.Name) ? 1 : -1);
        }
    }

    sortProductAsc(){
        if(this.showProducts){
            this.productList.sort((a, b) => (a.Name < b.Name) ? 1 : -1);
         
        }
    }
    sortProductCodeDesc(){
        if(this.showProducts){
            
            this.productList.sort((a, b) => (a.Number > b.Number) ? 1 : -1);
        }
    }
    sortProductCodeAsc(){
        if(this.showProducts){
            
            this.productList.sort((a, b) => (a.Number < b.Number) ? 1 : -1);
        }
    }

    doInputValidation(screenName){
        
        return  [...this.template.querySelectorAll(screenName)]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
    }

    navigateToHomePage(){
        let baseUrl = communityBasePath;
        if(this.navToBulkOrder){   
            baseUrl += '/?navigateTo=Ohistory';
            window.open(baseUrl,"_self");
        }else{
            window.open(baseUrl,"_self");
            
        }
    }

    prepareSelectedProductList(){
        if(this.selectedProducts && this.selectedProducts.length >0){
            let productData =[];
            let i=0;
            for(const value of this.selectedProducts){
                const prodData =[];
                let flag = false;
                
                flag = this.selectedProductChecker();
                prodData.productId = value;
                prodData.materialName= this.materialNameChecker(this.fetchedProductsMap,prodData.productId);
                prodData.productNumber=this.productNumberMap.get(prodData.productId);
                const srNo = Number(i) + 1;
                const serialNo = srNo+'';
                i++;
                prodData.sno = serialNo.padStart(this.padNo,'0');
                let found = false;
                if(flag){
                    const ProdId = prodData.productId;
                    for(const data of this.selectedProdDetails){
                        const materialId = data.productId;
                        if(ProdId === materialId){
                            productData = [...productData,data];
                            found = true;
                        }
                    }
                }
                if(!found){
                    prodData.Id = this.getRandomNumber();
                    prodData.Index = this.getRandomNumber();
                    prodData.quantity ='';
                    prodData.unit ='';
                    prodData.deliveryCollDate = '';
                    prodData.shellContractNo = '';
                    prodData.instructions = '';
                    productData = [...productData, prodData];
                }
            }
            this.productDataChecker(productData);
        }
    }

    productDataChecker(productData){
        if(productData && productData.length>0){
            this.selectedProdDetails = productData;
        }
    }
    selectedProductChecker(){
        if(this.selectedProdDetails && this.selectedProdDetails.length>0){
            return true;
        }else{
            return false;
        }
    }

    materialNameChecker(dataMap,dataId){
        if(dataMap.has(dataId)){
            return dataMap.get(dataId);
        }else{
            return '';
        }
    }

    renderedCallback(){
        if(this.selectproduct){
           this.populateProdCheckBox();
        }
    }

    populateProdCheckBox(){
        if(this.productList && this.productList.length>0){
            for(const i in this.productList){
                if(this.productList[i].Checked===true){
                    const dataId = this.productList[i].Id;
                    const checkBox = this.template.querySelector(`[name="${dataId}"]`);
                    checkBox.checked = true;
                }
            }
            this.populateProducts = false;
        }
    }

    compareProductOnNavigation(){
        if(this.productList && this.productList.length>0){
            this.compareProductHelper();
        }
        
    }

    compareProductHelper(){
        for(const value of this.productList){
            this.compareProductIterator(value);
        }
    }

    compareProductIterator(value){
        if(value.Checked===true){
            const prodName = value.Name;
            let found = false;
            for(const data of this.selectedProdDetails){
                const selProdName = data.materialName;
                if(prodName.trim() === selProdName.trim()){
                    found = true;
                    break;
                }
            }
            if(!found){
                value.Checked=false;
                const prodIndex = this.selectedProducts.indexOf(prodName);
                this.selectedProducts.splice(prodIndex,1);
                this.SelectedProdCount--;
            }
        }
    }


    mapOrderLineItems(){
        for(const value of this.selectedProdDetails){
            const dataId = value.Index;
            value.quantity = this.productInfoMapNullChecker(this.quantityMap, dataId);
            value.unit =  this.productInfoMapNullChecker(this.unitComboMap, dataId); 
            value.deliveryCollDate = this.productInfoMapNullChecker(this.deliveryDateMap, dataId);       
            value.shellContractNo =  this.productInfoMapNullChecker(this.shellContractMap, dataId);
            value.instructions = this.productInfoMapNullChecker(this.instructionsMap, dataId);
            
        }
    }

    mapDeliveryDate(dataId){
        for(const value of this.selectedProdDetails){
            if(value.Index === dataId){
                value.deliveryCollDate = this.productInfoMapNullChecker(this.deliveryDateMap, dataId);
            }
        }
    }

    getRequestedByDetails(){
        getContactsByCustomerId({soldToId : this.parentSoldToAccId})
        .then(result=>{
            this.requestedByOptions = [];
            if(result){
                for(const key in result){
                    const option = {
                        label : result[key].Contact.Name,
                        value : result[key].ContactId
                    };
                    this.contactIdMap.set(result[key].ContactId,result[key].Contact.Name);
                    this.requestedByOptions = [...this.requestedByOptions, option];
                }
                
            }
        })
        .catch(error=>{
            this.error = error;
            window.console.log('Error in getting Requested By details====>'+JSON.stringify(this.error));
        });
    }


    handleNextSelectProduct(){
        if(this.doInputValidation('.Step1') && (this.SelectedProdCount>0)){ 
            this.prepareSelectedProductList();
            this.getRequestedByDetails();
            if(this.editBtnEnabled){
                this.saveProdLineMapsOnEdit();
            }
            this.hasSelectedProducts=true;
            this.selectproduct = false;
            this.handleProgressIndicator('selectproduct',this.sldsIsCompleted,this.sldsIsActive);
            this.handleProgressIndicator('enterdetails',this.sldsIsActive,this.sldsIsProgress);
            this.enterdetails  = true;
            window.scrollTo(0,0);
            this.reviewsubmit  = false;

            
        }else if(this.showProducts){
            this.hasSelectedProducts=false;
        }else{
            this.error = 'Data Error';
        }
    }

    handleProgressIndicator(targetClassName1,targetClassAdd1,targetClassRemove1){
        const className = '.'+targetClassName1;
        const target = this.template.querySelector(className);
        if(target && target != null){
            target.classList.add(targetClassAdd1);
        }
        if(targetClassRemove1 && targetClassRemove1.length>0){
            const targetRemove = this.template.querySelector(className);
            if(targetRemove != null && targetRemove.classList.contains(targetClassRemove1)){
                targetRemove.classList.remove(targetClassRemove1);
            }
        }
        
    }

    handleOpenEnterDetails(){
        this.selectproduct = false;
        this.enterdetails  = true;
        this.reviewsubmit  = false;

    }

    handleOpenReviewSubmit(){
        this.selectproduct = false;
        this.enterdetails  = false;
        this.reviewsubmit  = true;

    }

    handleConfirmDetail(){
        if(this.doInputValidation('.Step2')){
            this.mapOrderLineItems();
            this.enableActionButtons();
            if(!this.enableComboBox){
                this.compareIfDataExist();
            }else{
                const randomId = 'rdm'+this.getRandomNumber();
                const tempObj = this.formatDataForReview(randomId);
                this.reviewOrderList = [...this.reviewOrderList,tempObj];
            }
            window.scrollTo(0,0);
            this.selectproduct = false;
            this.enterdetails  = false;
            this.enableActionBtn = true;
            this.handleProgressIndicator('enterdetails',this.sldsIsCompleted,this.sldsIsActive);
            this.reviewsubmit  = true;
            this.handleProgressIndicator('review',this.sldsIsActive,this.sldsIsProgress);
            this.handleScrollBarReview();
            this.handleScrollReviewProduct();

        }
    }

    handleBulkOrdCancel(){
        this.isShowCancelOrder = true;
    }
    
    handleCancelOrder(){
        this.hideModalCancelOrder();   
        this.navigateToHomePage();
    }

    handleAddMoreOrder(){
        const maxLimit = 30;
        if(this.reviewOrderList.length >= maxLimit){
            this.isShowMaximumOrder = true;
        }else{
           
            this.reviewsubmit = false;
            this.enableExitBtn = true;
            this.enableActionBtn = false;
            this.enableComboBox = true;
            this.exitbuttonMsg1 = 'Are you sure you want to exit from the current order?'
            this.exitbuttonMsg2 =  'Exiting order will not save any data of this order.'
            this.handleProgressIndicator('selectproduct',this.sldsIsActive,this.sldsIsCompleted);
            this.handleProgressIndicator('review',this.sldsIsProgress,this.sldsIsActive);
            this.handleProgressIndicator('enterdetails',this.sldsIsProgress,this.sldsIsCompleted);
            this.resetAllValues();
            this.isShowMaximumOrder = false;
        }
    }

    handleEditButton(event){
        const dataId = event.currentTarget.dataset.id;
        const target = this.template.querySelector(`[data-name="${dataId}"]`);
        if(target && target != null){
            target.classList.add('highlightTR');
        }
        
        this.template.querySelectorAll('.disableBtn').forEach(targetElement => {
            targetElement.classList.add('disableIconColor');
        });
    
        this.handleProgressIndicator('selectproduct',this.sldsIsActive,this.sldsIsCompleted);
        this.handleProgressIndicator('enterdetails',this.sldsIsProgress,this.sldsIsCompleted);
        this.loadOrderDetailsOnEdit(dataId);
        this.enableExitBtn = true;
        this.editBtnEnabled = true;
        this.populateProducts = true;
        this.enableActionBtn = false;
        this.exitbuttonMsg1 = 'Are you sure you want to exit from the current order?'
        this.exitbuttonMsg2 =  'Exiting the order will discard your all the changes and you will be seeing the previous data of this order.'

    }

    enableActionButtons(){
        this.template.querySelectorAll('.disableBtn').forEach(targetElement => {
            if(targetElement.classList.contains('disableIconColor')){
                targetElement.classList.remove('disableIconColor');
            }     
        });
    }

    loadOrderDetailsOnEdit(dataId){
        if(this.reviewOrderList && this.reviewOrderList.length>0){
            for(const value of this.reviewOrderList){
                if(value.randomId === dataId){
                    this.onEditRecordData = value;
                    this.resetAllValues();
                    this.loadOrderData();
                    break;

                }
            }
           
        }
    }

    loadOrderData(){
        if(this.onEditRecordData){
           // Select Product Screen
            window.scrollTo(0,0);
            this.parentSoldToAccId = this.onEditRecordData.soldToId;
            this.shipToAccId = this.onEditRecordData.shipToId;
            this.billToAccId = this.onEditRecordData.billToId;
            this.customerValue = this.onEditRecordData.soldToId;
            this.soldToNumber = this.onEditRecordData.soldToNumber;
            this.shipToNumber = this.onEditRecordData.shipToNumber;
            this.billToNumber = this.onEditRecordData.billToNumber;
            this.customerDetails = this.onEditRecordData.customerDetails;
            this.deliveryDetails = this.onEditRecordData.deliveryDetails;
            this.billingDetails = this.onEditRecordData.billingDetails;
            this.SelectedProdCount = this.onEditRecordData.SelectedProdCount;
            this.selectedProducts = this.onEditRecordData.selectedProducts;
            this.productList = this.onEditRecordData.productListData;
            this.productListData = this.onEditRecordData.productListData;
            this.payerData = this.onEditRecordData.payerData;
            this.loadSelectedProductsForEdit();
            this.productNoteMsgEnable = false;
            this.selectproduct = true;
            this.enterdetails = false;
            this.enableComboBox = false;
            this.selectedProdDetails = this.onEditRecordData.orderLineItemList;
            
            // Enter Details Screen
            this.orderName = this.onEditRecordData.Name;
            this.customerPo = this.onEditRecordData.poNumber;
            this.selectedReqByValue = this.onEditRecordData.requestedById;
            this.deliveryTermsValue = this.onEditRecordData.deliveryTerms;
            this.modeOfTransportValue = this.onEditRecordData.modeOfTransport;
            this.otherInstValue = this.onEditRecordData.otherInstructions;
            this.otherInstCount = this.otherInstValue.length;
            this.editedRecRandId = this.onEditRecordData.randomId;
        }
    }

    loadSelectedProductsForEdit(){
        for(const outerData of this.selectedProducts){
            for(const innerData of this.productList){
                if(outerData == innerData.Id){
                    innerData.Checked=true;
                }
            }
        }
    }

    resetAllValues(){
        // Select Product Screen
        this.selectproduct = true;
        this.enterdetails = false;
        this.customerValue = '';
        this.deliveryValue = '';
        this.billingValue = '';
        this.customerDetails = '';
        this.deliveryDetails = '';
        this.billingDetails = '';
        this.SelectedProdCount = 0;
        this.productList =[];
        this.productListData = [];
        this.productNoteMsgEnable = true;

        // Enter Details Screen
        this.orderName = '';
        this.customerPo = '';
        this.selectedReqByValue = '';
        this.deliveryTermsValue = '';
        this.modeOfTransportValue = '';
        this.otherInstValue = '';
        this.otherInstCount = 0;

        this.selectedProdDetails = [];
        window.scrollTo(0,0);

    }
/*  models */
    showModalDeletOrder(){
        this.isShowDeleteOrder= true;
    }

    hideModalDeleteOrder(){
        this.isShowDeleteOrder= false;
    }


    showModalExitOrder(){
        this.isShowExitOrder = true;
    }

    hideModalExitOrder(){
        this.isShowExitOrder = false;
    }

    showModalExitCurrentOrder(){
        this.isShowExitCurrentOrder = true;
    }

    hideModalExitCurrentOrder(){
        this.isShowExitCurrentOrder = false;
    }
    
    showModalCancelOrder(){
        this.isShowCancelOrder = true;
    }

    hideModalCancelOrder(){
        this.isShowCancelOrder = false;
    }

    showModalBulkOrder(){
        this.isShowBulkOrder = true;
    }

    hideModalBulkOrder(){
        this.isShowBulkOrder = false;
    }


    showModalError(){
        this.isShowError = true;
    }

    hideModalError(){
        this.isShowError = false;
    }
    
    hideModalmaximumOrder(){
     this.isShowMaximumOrder = false;
    }

    compareIfDataExist(){
        if(!this.enableComboBox && this.editedRecRandId){
            for(const i in this.reviewOrderList){
                let randId = this.reviewOrderList[i].randomId;
                if(randId === this.editedRecRandId){
                    let tempObj = this.formatDataForReview(randId);
                    this.reviewOrderList[i] = tempObj;
                    this.enableComboBox = true;
                    this.editedRecRandId = '';
                    break;
                }
            }
        }
    }

    formatDataForReview(randomId){
        const tempObj = [];
        
        tempObj.randomId = randomId;
        tempObj.Name = this.inputNullChecker(this.orderName);
        tempObj.soldToId = this.parentSoldToAccId;
        tempObj.soldToNumber = this.soldToNumber;
        tempObj.soldToName = this.soldToIdNameMap.get(this.parentSoldToAccId);
        tempObj.shipToId = this.shipToAccId;
        tempObj.shipToNumber = this.shipToNumber;
        tempObj.shipToName = this.shipToIdNameMap.get(this.shipToAccId);
        tempObj.billToId = this.billToAccId;
        tempObj.billToNumber = this.billToNumber;
        tempObj.payerId = this.payerData[0].Id;
        tempObj.payerNumber = this.payerData[0].AccountNumber;
        tempObj.payerData = this.payerData;
        tempObj.billToName = this.billToIdNameMap.get(this.billToAccId);
        tempObj.customerDetails = this.customerDetails;
        tempObj.deliveryDetails = this.deliveryDetails;
        tempObj.billingDetails = this.billingDetails;
        tempObj.productList = this.productList;
        tempObj.selectedProducts = this.selectedProducts;
        tempObj.productListData = this.productListData;
        tempObj.SelectedProdCount = this.SelectedProdCount;
        tempObj.requestedById = this.selectedReqByValue;
        tempObj.requestedByName = this.contactIdMap.get(this.selectedReqByValue);
        tempObj.poNumber = this.inputNullChecker(this.customerPo);
        tempObj.modeOfTransport = this.modeOfTransportValue;
        tempObj.deliveryTerms = this.deliveryTermsValue;
        tempObj.otherInstructions = this.inputNullChecker(this.otherInstValue);
        tempObj.orderLineItemList = this.selectedProdDetails;
        
        return tempObj;
    }

    saveBulkOrder(){
        if(this.reviewOrderList && this.reviewOrderList.length>0){
            this.saveBulkOrderHelper();
        }        
    }

    saveBulkOrderHelper(){
        let orderData =[];
            this.orderWrapperList = [];
            for(const dataValue of this.reviewOrderList){
                this.orderWrapper = {};
                const reviewObj = dataValue;
                this.orderWrapper.name = this.inputNullChecker(reviewObj.Name);
                this.orderWrapper.poNumber = this.inputNullChecker(reviewObj.poNumber);
                this.orderWrapper.deliveryTerms = this.inputNullChecker(reviewObj.deliveryTerms);
                this.orderWrapper.modeOfTransport = this.inputNullChecker(reviewObj.modeOfTransport);
                this.orderWrapper.otherInstructions = this.inputNullChecker(reviewObj.otherInstructions);
                this.orderWrapper.soldToId = this.inputNullChecker(reviewObj.soldToId); 
                this.orderWrapper.shipToId = this.inputNullChecker(reviewObj.shipToId); 
                this.orderWrapper.billToId = this.inputNullChecker(reviewObj.billToId);
                this.orderWrapper.soldToNumber = this.inputNullChecker(reviewObj.soldToNumber);
                this.orderWrapper.shipToNumber = this.inputNullChecker(reviewObj.shipToNumber);
                this.orderWrapper.billToNumber = this.inputNullChecker(reviewObj.billToNumber);
                this.orderWrapper.status = this.inputNullChecker(this.orderStatus);
                this.orderWrapper.soldToName = this.inputNullChecker(reviewObj.soldToName);
                this.orderWrapper.payerId = this.inputNullChecker(reviewObj.payerId);
                this.orderWrapper.payerNumber = this.inputNullChecker(reviewObj.payerNumber);
                this.orderWrapper.requestedById = this.inputNullChecker(reviewObj.requestedById);
                this.orderWrapper.orderLineItemWrapList = this.saveBulkOrderLineItems(reviewObj.orderLineItemList);
                
                orderData = [...orderData,this.orderWrapper];
            }
            if(orderData && orderData.length>0){
                this.orderWrapperList = orderData;
            }
            if(this.orderWrapperList && this.orderWrapperList.length>0){
                saveBulkOrderDetails({ordWrapList : this.orderWrapperList})
                .then(result=>{
                    if(result && result.length>0){
                        this.isShowError = false;
                        this.navigateToHomePage();
                    }else{
                        this.isLoading = false;
                        this.isShowError = true;
                    }
                    this.isLoading = false;
                })
                .catch(error=>{
                    this.isShowError = true;
                    this.error = error;
                    this.isLoading = false;
                    window.console.log('Error in getting bulk order data====>'+JSON.stringify(this.error));
                });
            }
    }

    inputNullChecker(input){
        if(input && input.length>0){
            return input;
        }else{
            return '';
        }
    }

    saveBulkOrderLineItems(orderLineItemList){
        let lineItemData = [];
        for(const dataValue of orderLineItemList){
            const data = dataValue;
            const orderLine = {};
            const prodId = data.productId;
            orderLine['quantity']  = data.quantity;
            orderLine['shellContractNo'] = data.shellContractNo;
            orderLine['deliveryCollDate'] = data.deliveryCollDate;
            orderLine['materialName'] = data.materialName;
            orderLine['materialNumber'] = this.productNumberMap.get(prodId);
          // orderLine['productNumber'] = this.productNumberMap.get(prodData.productId);
            //prodData.productNumber=this.productNumberMap.get(prodData.productId);
            orderLine['productId'] = prodId;
            orderLine['instructions'] = data.instructions;
            orderLine['unit'] = data.unit;
            //newly added
            orderLine['sno'] = data.sno;
            lineItemData = [...lineItemData,orderLine];
           // window.console.log('prodId checking' +prodId);
           // window.console.log('Checking the list ',JSON.stringify(this.))
        }
        return lineItemData;
    }

    


    showCollapseRow(event) {
        const dataId = event.currentTarget.dataset.id;
        const target = this.template.querySelector(`[data-id="${dataId}"]`);
        if( target && target != null){
            if(target.classList.contains('iconRotate')){
                target.classList.remove('iconRotate');
                const className = '.'+dataId;
                const row = this.template.querySelector(className);
                if(row && row != null){
                    row.classList.remove('showRow');
                }
                
            }else{
                target.classList.add('iconRotate');
                const className = '.'+dataId;
                const row = this.template.querySelector(className);
                if(row && row != null){
                    row.classList.add('showRow');
                }
                this.checkProductToEnableScroll(dataId);
            }
        }
        
    }

    checkProductToEnableScroll(dataId){
        for(const dataValue of this.reviewOrderList){
            if(dataId === dataValue.randomId){
                if(dataValue.orderLineItemList.length>this.minTableHeight){
                    this.reviewProdTable += ' tableHeight';
                    this.scrollForReviewProd += ' '+this.scrollBarVar;
                }else{
                    this.reviewProdTable = this.tableHeader;
                    this.scrollForReviewProd ='';
                }
            }
        }
    }

    saveProdLineMapsOnEdit(){
        this.tempQuantityMap.clear();
        this.tempUnitComboMap.clear();
        this.tempDeliveryDateMap.clear();
        this.tempShellContractMap.clear();
        this.tempInstructionsMap.clear();

        this.tempQuantityMap = this.assignTempKeyToSaveMap(this.quantityMap);
        this.tempUnitComboMap = this.assignTempKeyToSaveMap(this.unitComboMap);
        this.tempDeliveryDateMap = this.assignTempKeyToSaveMap(this.deliveryDateMap);
        this.tempShellContractMap = this.assignTempKeyToSaveMap(this.shellContractMap);
        this.tempInstructionsMap = this.assignTempKeyToSaveMap(this.instructionsMap);
    }

    assignTempKeyToSaveMap(dataMap){
        const tempMap = new Map();
        for(const [mapkey,mapvalue] of dataMap){
            tempMap.set(mapkey,mapvalue);
        }
        return tempMap;
    }

    checkForChangesOnExit(){
       
        this.editBtnEnabled = false;
        this.quantityMap = this.assignTempKeyToSaveMap(this.tempQuantityMap);
        this.unitComboMap = this.assignTempKeyToSaveMap(this.tempUnitComboMap);
        this.deliveryDateMap = this.assignTempKeyToSaveMap(this.tempDeliveryDateMap);
        this.shellContractMap = this.assignTempKeyToSaveMap(this.tempShellContractMap);
        this.instructionsMap = this.assignTempKeyToSaveMap(this.tempInstructionsMap);
        this.mapOrderLineItems();
    }

}