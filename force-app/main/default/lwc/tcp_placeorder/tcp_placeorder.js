import { LightningElement, api, track, wire } from 'lwc';
import uId from '@salesforce/user/Id';
import getCustomerByAccountId from '@salesforce/apex/TCP_HomePageController.getCustomerByAccountId';
import getAccDetailsByParentId from '@salesforce/apex/TCP_HomePageController.getAccDetailsByParentId';
import getProductDetails from '@salesforce/apex/TCP_HomePageController.getProductDetails';
import getProductDetailsBySearchKey from '@salesforce/apex/TCP_HomePageController.getProductDetailsBySearchKey';
import getPickListValues from '@salesforce/apex/TCP_HomePageController.getPickListValues';
import getOrderNumberOnSave from '@salesforce/apex/TCP_HomePageController.getOrderNumberOnSave';
import getDateWithMonthName from '@salesforce/apex/TCP_Utilities.getDateWithMonthName';
import TCP_LineItemMinValueError from '@salesforce/label/c.TCP_LineItemMinValueError';
import TCP_LineItemMaxValueError from '@salesforce/label/c.TCP_LineItemMaxValueError';
import TCP_CurrentOrderLineInfo from '@salesforce/label/c.TCP_CurrentOrderLineInfo';
import TCP_LineItemLeftInfo from '@salesforce/label/c.TCP_LineItemLeftInfo';

const columns = [
    { label: 'Product Name', fieldName: 'Name' },
];


export default class TcpPlaceOrder extends LightningElement {

    orderApiName ='Order';
    deliveryTermApiName = 'Delivery_Terms__c';
    modeofTransportApiName = 'Mode_of_Transport__c';
    orderLineItemApiName = 'TCP_OrderLineItem__c';
    unitApiName = 'Unit__c';
    columns = columns;
    /* Progress Steps */
    @track progressStep1 = true;
    @track progressStep2 = false;
    @track progressStep3 = false;
   /* All Combobox */
    @track selectProductCustomerNameCombobox = true;
    @track selectProductDeliveryToCombobox = true;
    @track selectProductInvoiceToCombobox = true;
   /* All Details Card */ 
    @track selectProductCustomerNameCard = true;
    @track selectProductDeliveryToCard = true;
    @track selectProductInvoiceToCard = true;
   /* All Tables */ 
    @track selectProductTable = true;
    @track enterDetailsTable = false;
    @track reviewSubmitTable = false;
   /* All Forms */
    @track enterDetailsForm = false;
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
    @track notTodeleteOLIs=[];
    @track isOrgStatusDraft=false;
    @track OLIset=new Set();
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
    @track productSearchText=null;
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
    @track fromDashboard=true;
    @track quantityMap = new Map();
    @track deliveryDateMap = new Map();
    @track oliSfIdMap = new Map();
    @track shellContractMap =new Map();
    @track instructionsMap = new Map();
    @track productNumberMap = new Map();
    @track productIdMap = new Map();
    @track fetchedProductsMap = new Map();
    @track unitComboMap = new Map();
    @track orderLineItemsList = [];
    @track dateFormateWithMonthMap=new Map();
    @track reOrderLineItemsList =[];
    @track isShowModal = false;
    @track dateFormateWithMonth;

    @api orderdetaildata;
    @api parentaccid;
    @api reorderoverlay;
    @api type;
    @api eufilterdata;
    @track tableType;
    @track sendFilterData;
    @track reOrderText='Re-Order';
    @track draftOrderId;
    @track accountId;
    @track isLoading = false;
    @track soldToName;
    @track noSearchResult;
    @track isShowErrorModal;
    @track tableClassName = 'slds-table--header-fixed_container';
    @track scrollBarEnable = 'tablecheck';
    @track hasOrderSubmitted = false;
    //For delivery date
    currentdate;
    maximumdate;
    selectedval;

    lineItemError;
    lineItemInfo;
    lineItemleftInfo;
    minDateValue;
    maxDateValue;
    sldsScrollableY='slds-scrollable_y';
    constructor(){
        super();
        this.accountId = this.parentaccid;
        getPickListValues({objectApiName: this.orderApiName, fieldApiName: this.deliveryTermApiName})
        .then(result=>{
            for(let i=0; i<result.length; i++){
                const option = {
                    label : result[i],
                    value : result[i]
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
            for(let i=0; i<result.length; i++){
                const option = {
                    label : result[i],
                    value : result[i]
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
            for(let i=0; i<result.length; i++){
                const option = {
                    label : result[i],
                    value : result[i]
                };
                this.unitOptions = [...this.unitOptions,option];
            }
        })
        .catch(error => {
            this.error = error;
        });
    } 
    
    connectedCallback(){
       
        
        this.accountId = this.parentaccid;
        this.tableType = this.type;
        if(this.tableType==='Order History'){
            this.fromDashboard=false;
        }
        this.sendFilterData = this.eufilterdata;
        //reorder start
        if(this.reorderoverlay===true && this.orderdetaildata)
        {
            this.reOrderLineItemsList=this.orderdetaildata.orderLineItemList;
            this.orderName=this.orderdetaildata.name;
            this.customerPo=this.orderdetaildata.poNumber
            this.deliveryTermsValue=this.orderdetaildata.deliveryTerms
            this.modeOfTransportValue=this.orderdetaildata.modeOfTransport
            this.otherInstValue=this.orderdetaildata.otherInstructions
            if(this.orderdetaildata.status==='Draft'){
                this.isOrgStatusDraft=true;
                this.reOrderText='Place Order';
                this.draftOrderId=this.orderdetaildata.id;
            }
        }
        //reorder end
        //Calander View for Delivery date in place order page
        this.currentdate = new Date().toISOString().slice(0,10);
        //Max Date
        var todaydate = new Date();
        // Add 90 days to current date
        todaydate.setDate(todaydate.getDate() + 89);
        this.maximumdate = todaydate.toISOString().slice(0,10);
    }


    handleNext() {
        var getselectedStep = this.selectedStep;
         
        if(getselectedStep === 'Step1'){
            
            if(this.doInputValidation('.Step1') && (this.SelectedProdCount>0)){
                this.prepareSelectedProductList();
                window.scrollTo(0,0); 
                this.selectedStep = 'Step2';
                this.selectProductCustomerNameCombobox = false;
                this.selectProductDeliveryToCombobox = false;
                this.selectProductInvoiceToCombobox = false;
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
                    this.saveOrderLineItems();
                    this.mapOrderLineItems();
                    window.scrollTo(0,0); 
                    this.selectedStep = 'Step3';           
                    this.selectProductCustomerNameCombobox = false;
                    this.selectProductDeliveryToCombobox = false;
                    this.selectProductInvoiceToCombobox = false;
                    this.selectProductTable = false;
                    this.enterDetailsForm = false;
                    this.enterDetailsTable = false;
                    this.reviewSubmitTable = true;
                    this.reviewSubmitForm  = true;
                    /* Progress Steps */
                    this.progressStep1 = false;
                    this.progressStep2 = false;
                    this.progressStep3 = true;

                    //Verify Delivery date as required
                    const input = this.template.querySelector('input[type="date"]');

                    input.addEventListener('invalid', function (event) {
                    if (event.target.validity.valueMissing) {
                        event.target.setCustomValidity('Please fill out this field');
                    }
                    })

                    input.addEventListener('change', function (event) {
                    event.target.setCustomValidity('');
                    })

               
           }
           
        }
       
    }
 
    handlePrev() {
        var getselectedStep = this.selectedStep;
        if(getselectedStep === 'Step1'){
            window.scrollTo(0,0); 
            this.handleHomepage();  
            
        }
        if(getselectedStep === 'Step2'){
            this.compareProductOnNavigation();
            this.mapOrderLineItems();     
            window.scrollTo(0,0); 
            this.selectedStep = 'Step1';
            this.selectProductCustomerNameCombobox = true;
            this.selectProductDeliveryToCombobox = true;
            this.selectProductInvoiceToCombobox = true;
            this.selectProductTable = true;
            this.enterDetailsForm = false;
            this.enterDetailsTable = false;
            /* Progress Steps */
            this.progressStep1 = true;
            this.progressStep2 = false;
            this.progressStep3 = false;
         
            
        }
        else if(getselectedStep === 'Step3'){
            window.scrollTo(0,0);
            this.selectedStep = 'Step2';
            this.selectProductCustomerNameCombobox = false;
            this.selectProductDeliveryToCombobox = false;
            this.selectProductInvoiceToCombobox = false;
            this.selectProductTable = false;
            this.reviewSubmitTable = false;
            this.reviewSubmitForm = false;
            this.enterDetailsForm = true;
            this.enterDetailsTable = true;
            /* Progress Steps */
            this.progressStep1 = false;
            this.progressStep2 = true;
            this.progressStep3 = false;

        }
        
    }    

    handleCancel() {
            this.showModalBox();
         }
    
    handleHomepage() {
        
        if(this.reorderoverlay){
            this.dispatchEvent(new CustomEvent('reorderback',{detail : {"type" : this.tableType, "filtereudata": this.sendFilterData}}));
           }
        else{
            this.dispatchEvent(new CustomEvent('placeorder',{detail : {"type" : this.tableType, "filtereudata": this.sendFilterData}}));
        }
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
        if(this.minDateValue=== undefined)
        {
        this.minDateValue= new Date().toISOString().substring(0, 10);
        }
        return this.minDateValue;
    }

    get maxDate(){
        if(this.maxDateValue=== undefined)
        {
            var today= new Date(); 
            var numberOfDaysToAdd = 90;
            var result = today.setDate(today.getDate() + numberOfDaysToAdd);
            this.maxDateValue= new Date(result).toISOString().substring(0, 10);
        }
        return this.maxDateValue;
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

    @wire(getCustomerByAccountId, {accountId:'$accountId'})
    wiredAccounts({data, error}){
        if(data){
            for (const key in data) {
                const shippingAddress = data[key].ShippingAddress;
                const accStreet = shippingAddress.street ? `${shippingAddress.street}, `:'';
                const accCity = shippingAddress.city?`${shippingAddress.city}, `:'';
                const accState = shippingAddress.state? `${shippingAddress.state}, `:'';
                const accPostalCode = shippingAddress.postalCode?`${shippingAddress.postalCode}, `:'';
                const accCountry = shippingAddress.country?shippingAddress.country:'';
                const custAddr = `${data[key].Name}, ${accStreet}${accCity}${accState}${accPostalCode}${accCountry}`;
                this.soldToIdMap.push({key:custAddr, value: data[key]});
                const option = {
                    label : `${data[key].Name}, ${shippingAddress.city}`,
                    value : custAddr
                };
                this.soldToOptions = [...this.soldToOptions, option];
            }
              
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
            this.error = null;
           
        }
        else if (error) {
            this.error = error; 
            window.console.log('ERROR====>'+JSON.stringify(this.error));
            this.hasCustomerData = false;
            this.hasDeliveryToData = false;
            this.hasInvoiceToData = false;
        }
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

    handleCustomerChange(event){
        const selectedValue = event.detail.value;
        this.customerValue = selectedValue;
        this.customerDetails = selectedValue;
        const soldToData = this.soldToIdMap.find(o => o.key === selectedValue).value; 
        this.parentSoldToAccId = soldToData.Id
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
        this.doInputValidation('.Step1');
    }

    handleInvoiceChange(event){
        const selectedValue = event.detail.value;
        this.billingValue = selectedValue;
        this.billingDetails = selectedValue;
        const billToData = this.billToNamesMap.find(o => o.key === selectedValue).value;
        this.billToAccId = billToData.Id;
        this.billToNumber = billToData.AccountNumber;
        this.doInputValidation('.Step1');
    }

    handleChange(event){
        this.value = event.detail.value;


    }

    handleProduct(event){
        const isChecked = event.target.checked;
        const productId = event.target.name;
        
        if(isChecked){  
            if(this.productList && this.productList.length>0){
                for(let i=0;i<this.productList.length; i++){
                    if(this.productList[i].Id === productId){
                        this.productList[i].Checked=true;
                    }
                }
            }
            this.SelectedProdCount++;
            this.selectedProducts = [...this.selectedProducts,productId];
            this.hasSelectedProducts=true;
        }else{
            if(this.productList && this.productList.length>0){
                for(let i=0;i<this.productList.length; i++){
                    if(this.productList[i].Id === productId){
                        this.productList[i].Checked=false;
                    }
                }
            }
            const prodIndex = this.selectedProducts.indexOf(productId);
            this.selectedProducts.splice(prodIndex,1);
            this.SelectedProdCount--;

            
        }
        
    }

    handleSearchProduct(event){
        const searchKey = event.target.value.toLowerCase();
        this.productSearchText=event.target.value;
        if(searchKey){
            this.productList = this.productListData;
            if(this.productList) {
                const recs = [];    
                
                for(let i=0;i<this.productList.length; i++){
                    const name =  (this.productList[i].Name).toLowerCase();
                    const number=(this.productList[i].Number);
                    if(name.includes(searchKey)){
                        recs.push(this.productList[i]);
                    }
                    else if(number.includes(searchKey)){
                        recs.push(this.productList[i]);
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
        }else{
            this.noSearchResult = false;
            this.productList = this.productListData;
        }  
    }

    handleDeliveryTermsChange(event){
        this.deliveryTermsValue = event.detail.value;
        this.doInputValidation('.Step2DevTerm');
    }

    handleModeOfTransChange(event){
        this.modeOfTransportValue = event.detail.value;
        this.doInputValidation('.Step2Transport');
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
        const prodId = event.currentTarget.dataset.prodid;
       
        let inputValue = event.currentTarget.value;
        if(inputValue && inputValue.length>0){
            inputValue = Number(inputValue);
            this.quantityMap.set(Number(dataId),inputValue);
        }
        if(prodName && prodName.length>0){
            this.materialNameMap.push({key:Number(dataId), value:prodName});
        }
        if(prodId && prodId.length>0){
          this.productIdMap.set(Number(dataId),prodId);
        }

    }
    handleDeliveryDate(event){
        
        const dataId = event.currentTarget.dataset.id;
        let inputValue = event.currentTarget.value;
        if(inputValue && inputValue.length>0){
            this.deliveryDateMap.set(Number(dataId),inputValue);
            this.mapDeliveryDate(Number(dataId));
        }
        getDateWithMonthName({ reqDate: inputValue }) .then(result => {
            window.console.log('Checking date '+result);
            inputValue = result;
            window.console.log('Checking date2 '+inputValue);
            if(inputValue && inputValue.length>0){
                this.dateFormateWithMonthMap.set(Number(dataId),inputValue);
                this.mapDeliveryDateWithMonth(Number(dataId));
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in updating date====>' + JSON.stringify(this.error));
        });

    }

    mapDeliveryDate(dataId){
        for(let i=0; i<this.selectedProdDetails.length; i++){
            if(this.selectedProdDetails[i].Index === dataId){
                this.selectedProdDetails[i].deliveryCollDate = this.deliveryDateMap.has(Number(dataId)) ? this.deliveryDateMap.get(Number(dataId)): '';
            }
        }
    }
    mapDeliveryDateWithMonth(dataId){
        for(let i=0; i<this.selectedProdDetails.length; i++){
            if(this.selectedProdDetails[i].Index === dataId){
                this.selectedProdDetails[i].dateFormateWithMonth = this.dateFormateWithMonthMap.has(Number(dataId)) ? this.dateFormateWithMonthMap.get(Number(dataId)): '';
           window.console.log('Chevking final date'+JSON.stringify(this.selectedProdDetails[i].dateFormateWithMonth));
            }
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
        }
    }

    handleSaveAsDraft(){
        if(this.selectedStep=== 'Step2'){
            if(this.doInputValidation('.Step2')) 
            {    
                 this.orderStatus ='Draft';
                 this.isLoading = true;
                 this.saveOrderDetails();
                 this.handleCloseModal(); 
            }else
            {
                 this.handleCloseModal(); 
            }
        }
        else if(this.selectedStep=== 'Step3')
        {
                this.orderStatus ='Draft';
                this.isLoading = true;
                this.saveOrderDetails();
        }
    }

    handleSubmit(){
        this.isLoading = true;
        this.orderStatus ='Submitted';
        this.saveOrderDetails();
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
            if(totalItems > 30){
                this.isShowErrorModal = true;
                this.lineItemError = TCP_LineItemMaxValueError;
                let lineItemCount = (this.selectedProdDetails.length).toString();
                lineItemCount = lineItemCount.padStart(2,'0') + '.';
                this.lineItemInfo = `${TCP_CurrentOrderLineInfo} ${lineItemCount}`;
                let leftCount = (30-Number(this.selectedProdDetails.length)).toString();
                leftCount = leftCount.padStart(2,'0') + '.';
                this.lineItemleftInfo = `${TCP_LineItemLeftInfo} ${leftCount}`;
            }else{
                const length = Number(inputValue); 
                for(let i=0;i<length; i++){
                    for(let j=0;j<this.selectedProdDetails.length;j++){
                        if(Number(dataId) === this.selectedProdDetails[j].Index){
                            
                            const prodData =[];
                            prodData.materialName = prodName;
                            prodData.productNumber=prodNumber;
                            prodData.Id = this.getRandomNumber();
                            prodData.Index = this.getRandomNumber();
                            prodData.quantity = this.quantityMap.has(Number(dataId)) ? this.quantityMap.get(Number(dataId)) : '';
                            prodData.unit = this.unitComboMap.has(Number(dataId)) ? this.unitComboMap.get(Number(dataId)) : '';
                            prodData.deliveryCollDate = this.deliveryDateMap.has(Number(dataId)) ? this.deliveryDateMap.get(Number(dataId)) : '';
                            prodData.shellContractNo = this.shellContractMap.has(Number(dataId)) ? this.shellContractMap.get(Number(dataId)) : '';
                            prodData.instructions = this.instructionsMap.has(Number(dataId)) ? this.instructionsMap.get(Number(dataId)) : '';
                            prodData.productId=this.productIdMap.has(Number(dataId)) ? this.productIdMap.get(Number(dataId)) : this.selectedProdDetails[j].productId;
                            prodData.dateFormateWithMonth=this.dateFormateWithMonthMap.has(Number(dataId)) ? this.dateFormateWithMonthMap.get(Number(dataId)) : '';
                            this.quantityMap.set(Number(prodData.Index),prodData.quantity);
                            this.unitComboMap.set(Number(prodData.Index),prodData.unit);
                            this.deliveryDateMap.set(Number(prodData.Index),prodData.deliveryCollDate);
                            this.shellContractMap.set(Number(prodData.Index),prodData.shellContractNo);
                            this.instructionsMap.set(Number(prodData.Index),prodData.instructions);
                            this.materialNameMap.push({key:Number(prodData.Index), value:prodName});
                            this.productIdMap.set(Number(prodData.Index),prodData.productId);
                            this.dateFormateWithMonthMap.set(Number(prodData.Index),prodData.dateFormateWithMonth);
                            this.selectedProdDetails = [...this.selectedProdDetails, prodData];
                            
                        }
                    }
                }
                this.generateSerialNumbers();
                this.handleScrollBar();

            }
        }else{
            this.isShowErrorModal = true;
            this.lineItemError = TCP_LineItemMinValueError;
        }        
    }

    hideModalBox() {  
        this.isShowErrorModal = false;
    }

    handleScrollBar(){
        const className = '.'+this.tableClassName;
        const target = this.template.querySelector(className);
        const classNameScroll = '.'+this.scrollBarEnable;
        const scroll = this.template.querySelector(classNameScroll);
        if(this.selectedProdDetails.length>6){
            if(target && target != null){
                target.classList.add('tableHeight');
                scroll.classList.add(this.sldsScrollableY);
            }
        }else if(target.classList.contains('tableHeight')){
            target.classList.remove('tableHeight');
            if(scroll.classList.contains(this.sldsScrollableY)){
                scroll.classList.remove(this.sldsScrollableY);
            }
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
            this.handleScrollBar();
            this.generateSerialNumbers();
        }
    }

    getRandomNumber(){
        const crypto = window.crypto || window.msCrypto;
        var array = new Uint32Array(1);
        return Number(crypto.getRandomValues(array));
    }

    

    getChildAccounts(){
        if(this.parentSoldToAccId){
            getAccDetailsByParentId({parentAccId : this.parentSoldToAccId})
            .then(result => {
                const data = result;
                this.childAccounts = data;
                if(this.childAccounts && this.childAccounts.length >0){
                    this.formatChildAccData();
                }
                else
                {
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
        if(this.childAccounts && this.childAccounts.length >0 ){
            for(let i=0; i<this.childAccounts.length;i++){
                if(this.childAccounts[i].Customer_Type__c === 'Ship To'){
                    this.shipToData = [...this.shipToData,this.childAccounts[i]];
                }else if(this.childAccounts[i].Customer_Type__c === 'Bill To'){
                    this.billToData = [...this.billToData,this.childAccounts[i]];
                }else if(this.childAccounts[i].Customer_Type__c === 'Payer'){
                    this.payerData = [...this.payerData,this.childAccounts[i]];
                }
            }
            if(this.shipToData && this.shipToData.length > 0){
                this.getShipToDetails();
            }else
            {
                    this.hasDeliveryToData = false;
            }
            
            if(this.billToData && this.billToData.length > 0){
                this.getBillToDetails();
            }else
            {
                this.hasInvoiceToData = false;
            }
            
        }
    }

    getShipToDetails(){
        for(let i=0; i<this.shipToData.length; i++){
            const shippingAddress = this.shipToData[i].ShippingAddress;
            const accStreet = shippingAddress.street ? `${shippingAddress.street}, `:'';
            const accCity = shippingAddress.city?`${shippingAddress.city}, `:'';
            const accState = shippingAddress.state? `${shippingAddress.state}, `:'';
            const accPostalCode = shippingAddress.postalCode?`${shippingAddress.postalCode}, `:'';
            const accCountry = shippingAddress.country?shippingAddress.country:'';
            const shipToAddr = `${this.shipToData[i].Name}, ${accStreet}${accCity}${accState}${accPostalCode}${accCountry}`;
            this.shipToNamesMap.push({key:shipToAddr, value: this.shipToData[i]});
            const option = {
                label : `${this.shipToData[i].Name}, ${shippingAddress.city}`,
                value : shipToAddr
            };
            this.shipToOptions = [...this.shipToOptions, option];     
        }
        if(this.reorderoverlay===true && this.orderdetaildata){
            
            for(let i=0; i<this.shipToData.length; i++){
                if(this.shipToData[i].Id===this.orderdetaildata.shipToId)   
                {   
                    const selectedValue = this.shipToOptions[i].value;
                    this.deliveryValue = selectedValue;
                    this.deliveryDetails = selectedValue;
                    const shipToData = this.shipToNamesMap.find(o => o.key === selectedValue).value;
                    this.shipToAccId = shipToData.Id;
                    this.shipToNumber = shipToData.AccountNumber;
                    this.getProductDetails();
                }
            }
        }
        else if(this.shipToOptions.length === 1){
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
        for(let i=0; i<this.billToData.length; i++){
            const billingAddress = this.billToData[i].ShippingAddress;
            const accStreet = billingAddress.street ? `${billingAddress.street}, `:'';
            const accCity = billingAddress.city?`${billingAddress.city}, `:'';
            const accState = billingAddress.state? `${billingAddress.state}, `:'';
            const accPostalCode = billingAddress.postalCode?`${billingAddress.postalCode}, `:'';
            const accCountry = billingAddress.country?billingAddress.country:'';
            const billToAddr = `${this.billToData[i].Name}, ${accStreet}${accCity}${accState}${accPostalCode}${accCountry}`;
            
            this.billToNamesMap.push({key:billToAddr, value: this.billToData[i]});
            const option = {
                label : `${this.billToData[i].Name}, ${billingAddress.city}`,
                value : billToAddr
            };
            this.billToOptions = [...this.billToOptions, option]; 
        }
        if(this.reorderoverlay===true && this.orderdetaildata){
            for(let i=0; i<this.billToData.length; i++){
                
                if(this.billToData[i].Id===this.orderdetaildata.billToId)   
                {   
                    const selectedValue = this.billToOptions[0].value;
                    this.billingValue = selectedValue;
                    this.billingDetails = selectedValue;
                    const billToData = this.billToNamesMap.find(o => o.key === selectedValue).value;
                    this.billToAccId = billToData.Id;
                    this.billToNumber = billToData.AccountNumber;
                }
            }
        }
        else if(this.billToOptions.length === 1){
            const selectedValue = this.billToOptions[0].value;
            this.billingValue = selectedValue;
            this.billingDetails = selectedValue;
            const billToData = this.billToNamesMap.find(o => o.key === selectedValue).value;
            this.billToAccId = billToData.Id;
            this.billToNumber = billToData.AccountNumber;

        }
        
        
    }

    getProductDetails(){
        this.isLoading=true;
        let tempProdData = [];
        let reOrderProductIds=[];
        this.SelectedProdCount=0;
        this.selectedProducts =[];
        this.productList = [];
        getProductDetails({soldToId: this.parentSoldToAccId, shipToId: this.shipToAccId})
        .then(result=>{
            for(let i=0; i<result.length; i++){
                const prodData =[];
                prodData.Name = result[i].Product__r.Name;
                prodData.Id = result[i].Product__r.Id;
                prodData.Number = result[i].Product__r.ProductCode;
                this.fetchedProductsMap.set(String(result[i].Product__r.Id),result[i].Product__r.Name);
                //reorder Start
                //reorder start
                if((this.reorderoverlay===true) && (this.orderdetaildata) && (this.shipToAccId===this.orderdetaildata.shipToId) && (this.billToAccId===this.orderdetaildata.billToId)){
                      
                    for(let j=0; j<this.reOrderLineItemsList.length; j++){
                                
                        if((prodData.Id===this.reOrderLineItemsList[j].Product__c)&&(!reOrderProductIds.includes(prodData.Id))){
                            reOrderProductIds=[...reOrderProductIds,prodData.Id];
                            prodData.Checked = true;
                            this.SelectedProdCount++;
                            
                            this.selectedProducts = [...this.selectedProducts,prodData.Id];
                        }
                    }  
                }
                else{ 
                prodData.Checked = false;
                }
                //reorder end
                
                
                tempProdData = [...tempProdData,prodData];
               
                this.selectedProductMap.push({key:prodData.Name, value:prodData.Id});
                this.productNumberMap.set(prodData.Id,prodData.Number);
            }
            if(tempProdData && tempProdData.length >0){
                this.showProducts = true;
                this.productList = tempProdData;
                this.productListData = tempProdData;
                this.hasProductData = true;
            }else{
                this.productList = null;
                this.showProducts = false;
                this.hasProductData = false;
            }
        })
        .catch(error => {
            this.error = error;
            this.hasProductData = false;
            this.isLoading=false;
            window.console.log('Error in getting products====>'+JSON.stringify(this.error));
        });
        this.isLoading=false;
    }

    getProductSearchData(){
        let tempProdData = [];
        getProductDetailsBySearchKey({searchKey : this.searchKey, soldToId: this.parentSoldToAccId, shipToId: this.shipToAccId})
            .then(result=>{
                for(let i=0; i<result.length; i++){
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

    sortProductDesc(){
        if(this.showProducts){
            // if(this.productList.length >0){
            //     let prodList =[];
            //     for(let i=this.productList.length-1 ; i>=0 ;i--){
            //         const prodData =[];
            //         prodData.Name = this.productList[i].Name;
            //         prodData.Id = this.productList[i].Id;
            //         prodData.Number=this.productList[i].Number;
            //         prodList = [...prodList,prodData];
            //     }
            //     this.productList = prodList;
            // }
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
    



    saveOrderDetails(){
        if(this.orderName && this.orderName.length>0){
            this.orderWrapper.name = this.orderName;
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
        if(this.payerData[0].Id && this.payerData[0].Id.length>0){
            this.orderWrapper.payerId = this.payerData[0].Id;
        }
        if(this.payerData[0].AccountNumber && this.payerData[0].AccountNumber.length>0){
            this.orderWrapper.payerNumber = this.payerData[0].AccountNumber;
        }
        if(this.draftOrderId && this.draftOrderId.length>0 && this.isOrgStatusDraft===true){
            this.orderWrapper.id = this.draftOrderId;
        }
        
        this.saveOrderLineItems();

        if(this.isOrgStatusDraft===true){
        for(let i=0;i<this.orderLineItemsList.length; i++){
            if(this.orderLineItemsList[i].id && this.orderLineItemsList[i].id.length>0){
                this.OLIset.add(this.orderLineItemsList[i].id);
            }
        }
        window.console.table(this.OLIset);
        this.notTodeleteOLIs=Array.from(this.OLIset);
        }
        
        if(!this.hasOrderSubmitted){
            getOrderNumberOnSave({orderWrapper: this.orderWrapper, orderLineWrapList: this.orderLineItemsList, draftOLINotToBeDeleted: this.notTodeleteOLIs, isResumeDraftOrder: this.isOrgStatusDraft})
            .then(result=>{
                    this.orderNumber = result.OrderNumber;
                    this.orderId = result.Id;
                    this.hasOrderSubmitted = true;
                    this.isLoading = false;
                    this.navigateToHomePage();
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
            });
        }
    }

    navigateToHomePage(){
        this.dispatchEvent(new CustomEvent('saveorder',{detail : {"status": this.orderStatus,"ordernumber":this.orderNumber,"type" : this.tableType, "filtereudata": this.sendFilterData} }));   
    }

    prepareSelectedProductList(){
        
        if(this.selectedProducts && this.selectedProducts.length >0){
            let productData =[];
            let includedOLIs=[];
            for(let i=1; i<=this.selectedProducts.length;i++){  
                const prodData =[];
                const serialNo = i+'';
                prodData.sno = serialNo.padStart(2,'0');
                let flag = false;
                if(this.selectedProdDetails && this.selectedProdDetails.length>0){
                    flag = true;
                    //Additionally added ////
                    if(this.productList && this.productList.length>0 && this.quantityMap && this.productIdMap){
                                for(let i=0;i<this.productList.length; i++){
                                    if(this.productList[i].Checked===false){
                                        const prodId = this.productList[i].Id;
                                       for(const [mapkey,mapvalue] of this.productIdMap){
                                            if(mapvalue===prodId){
                                            this.quantityMap.delete(Number(mapkey));
                                            }
                                        } 
                                    }
                                }
                            }
                    ///// 
                }   
                
                prodData.productId = this.selectedProducts[i-1];
                prodData.materialName=this.fetchedProductsMap.has(prodData.productId) ? this.fetchedProductsMap.get(prodData.productId): '';
                prodData.productNumber=this.productNumberMap.get(prodData.productId);
                let found = false;
                if(flag){
                    const ProdId = prodData.productId;
                    for(let i=0; i<this.selectedProdDetails.length;i++){
                        
                        const materialId = this.selectedProdDetails[i].productId;
                        
                        if(ProdId === materialId){
                            productData = [...productData,this.selectedProdDetails[i]];
                            found = true;
                        }
            
                    }
                }
                if(!found){
                    
                    if((this.reorderoverlay===true) && (this.orderdetaildata) && (this.shipToAccId===this.orderdetaildata.shipToId) && (this.billToAccId===this.orderdetaildata.billToId)){
                    
                        let productInOldOrder=false;
                        const uiProdID =prodData.productId;
                        for(let j=0; j<this.reOrderLineItemsList.length; j++){
                            const OLIdata =[];
                            const orgMaterialId= this.reOrderLineItemsList[j].Product__c;

                            if((uiProdID===orgMaterialId)&&(!includedOLIs.includes(this.reOrderLineItemsList[j].Id))){
                                productInOldOrder=true;
                                OLIdata.productId = this.selectedProducts[i-1];
                                OLIdata.materialName=this.fetchedProductsMap.has(OLIdata.productId) ? this.fetchedProductsMap.get(OLIdata.productId): '';
                                OLIdata.productNumber=this.productNumberMap.get(OLIdata.productId);
                                OLIdata.Id = this.getRandomNumber();                               
                                OLIdata.Index = this.getRandomNumber();
                                OLIdata.quantity =this.reOrderLineItemsList[j].Quantity__c;
                                OLIdata.unit =this.reOrderLineItemsList[j].Unit__c;
                                if(this.orderdetaildata.status==='Draft' && this.isOrgStatusDraft===true){
                                    OLIdata.deliveryCollDate = this.reOrderLineItemsList[j].Delivery_Collection_Date__c;
                                    //sfId
                                    OLIdata.sfId=this.reOrderLineItemsList[j].Id;
                                    this.deliveryDateMap.set(Number(OLIdata.Index),OLIdata.deliveryCollDate);
                                    this.oliSfIdMap.set(Number(OLIdata.Index),OLIdata.sfId);
                                }else{
                                    OLIdata.deliveryCollDate = '';
                                }
                                OLIdata.shellContractNo =this.reOrderLineItemsList[j].Contract_No__c;
                                OLIdata.instructions =this.reOrderLineItemsList[j].Other_Instruction__c; 
                                this.quantityMap.set(Number(OLIdata.Index),OLIdata.quantity);
                                this.unitComboMap.set(Number(OLIdata.Index),OLIdata.unit);
                                this.shellContractMap.set(Number(OLIdata.Index),OLIdata.shellContractNo);
                                this.instructionsMap.set(Number(OLIdata.Index),OLIdata.instructions);
                                this.productIdMap.set(Number(OLIdata.Index),OLIdata.productId);

                                this.materialNameMap.push({key:Number(OLIdata.Index), value:this.reOrderLineItemsList[j].Material_Name__c});
                                 
                                productData = [...productData, OLIdata];  
                                includedOLIs=[...includedOLIs,this.reOrderLineItemsList[j].Id];
                            }
                          
                        }
                        
                        if(!productInOldOrder){
                        prodData.Id = this.getRandomNumber();
                        prodData.Index = this.getRandomNumber();
                        prodData.quantity ='';
                        prodData.unit ='';
                        prodData.deliveryCollDate = '';
                        prodData.shellContractNo = '';
                        prodData.instructions = '';
                        prodData.dateFormateWithMonth='';
                        productData = [...productData, prodData];
                        }

                    }
                    else{
                        prodData.Id = this.getRandomNumber();
                        prodData.Index = this.getRandomNumber();
                        prodData.quantity ='';
                        prodData.unit ='';
                        prodData.deliveryCollDate = '';
                        prodData.shellContractNo = '';
                        prodData.instructions = '';
                        prodData.dateFormateWithMonth='';
                        productData = [...productData, prodData];
                    }
                    
                }
              
                
            }
            if(productData && productData.length>0){
                this.selectedProdDetails = productData;
            }
            this.generateSerialNumbers();
        }
    }

    renderedCallback(){
        var getselectedStep = this.selectedStep;
        
        if(getselectedStep === 'Step1'){
            this.populateProdCheckBox();
        }
        if(getselectedStep === 'Step2'){
            this.handleScrollBar();
        }
        if(getselectedStep === 'Step3'){
            this.handleScrollBar();
        }
     
    }

    generateSerialNumbers(){
        let sno = 0;
        for(let i=0;i<this.selectedProdDetails.length;i++){
            sno++;
            const serialNo = sno+'';
            this.selectedProdDetails[i].sno = serialNo.padStart(2,'0');
        }
    }

    populateProdCheckBox(){
        if(this.productList && this.productList.length>0){
            for(let i=0;i<this.productList.length; i++){
                if(this.productList[i].Checked===true){
                    const dataId = this.productList[i].Id;
                    const checkBox = this.template.querySelector(`[name="${dataId}"]`);
                    checkBox.checked = true;
                }
            }
        }
    }

    compareProductOnNavigation(){
        if(this.productList && this.productList.length>0){
            for(let i=0;i<this.productList.length; i++){
                if(this.productList[i].Checked===true){
                    const prodId = this.productList[i].Id;
                    let found = false;
                    for(let j=0; j<this.selectedProdDetails.length; j++){
                        const selProdId = this.selectedProdDetails[j].productId;
                        if(prodId === selProdId){
                            found = true;
                            break;
                        }
                    }
                    if(!found){
                        this.productList[i].Checked=false;
                        const prodIndex = this.selectedProducts.indexOf(prodId);
                        this.selectedProducts.splice(prodIndex,1);
                        this.SelectedProdCount--;
                    }

                }
            }
        }
        
    }

    saveOrderLineItems(){
        this.orderLineItemsList.splice(0,this.orderLineItemsList.length); 
       if(this.orderLineItemsList.length === 0){ 
            let i=0;
            for(const [mapkey,mapvalue] of this.quantityMap){
                
                    const orderLine = {};
                    let serialNum = i+1;
                    serialNum = serialNum + '';
                    orderLine['sno'] = serialNum.padStart(2,'0');
                    orderLine['quantity']  = mapvalue;
                    if(this.shellContractMap.has(mapkey)){
                        orderLine['shellContractNo'] = this.shellContractMap.get(mapkey);
                    }
                    if(this.deliveryDateMap.has(mapkey)){
                        orderLine['deliveryCollDate'] = this.deliveryDateMap.get(mapkey);
                    }
                    if(this.deliveryDateMap.has(mapkey)){
                        orderLine['deliveryCollDateMonth'] = this.dateFormateWithMonthMap.get(mapkey);
                    }
                    if(this.materialNameMap.find(o => o.key === mapkey)){
                        orderLine['materialName'] = this.materialNameMap.find(o => o.key === mapkey).value;
                    }
                    if(this.productIdMap.has(Number(mapkey))){
                        orderLine['productId'] = this.productIdMap.get(mapkey);
                    }
                    if(this.productNumberMap.has(orderLine['productId'])){
                        orderLine['materialNumber'] = this.productNumberMap.get(orderLine['productId']);
                    }
                    if(this.instructionsMap.has(mapkey)){
                        orderLine['instructions'] = this.instructionsMap.get(mapkey);
                    }
                    if(this.unitComboMap.has(mapkey)){
                        orderLine['unit'] = this.unitComboMap.get(mapkey);
                    }
                    if(this.oliSfIdMap.has(mapkey) && this.isOrgStatusDraft===true){
                        orderLine['id'] = this.oliSfIdMap.get(mapkey);
                    }
                    i++;
                    this.orderLineItemsList = [...this.orderLineItemsList,orderLine];
            }
        }
    }

    mapOrderLineItems(){
        for(let i=0; i<this.selectedProdDetails.length; i++){
            const dataId = this.selectedProdDetails[i].Index;
            this.selectedProdDetails[i].quantity = this.quantityMap.has(Number(dataId)) ? this.quantityMap.get(Number(dataId)): '';
            this.selectedProdDetails[i].unit = this.unitComboMap.has(Number(dataId)) ? this.unitComboMap.get(Number(dataId)): '';
            this.selectedProdDetails[i].deliveryCollDate = this.deliveryDateMap.has(Number(dataId)) ? this.deliveryDateMap.get(Number(dataId)): '';
            this.selectedProdDetails[i].dateFormateWithMonthMap=this.dateFormateWithMonthMap.has(Number(dataId)) ? this.dateFormateWithMonthMap.get(Number(dataId)): '';
            this.selectedProdDetails[i].shellContractNo = this.shellContractMap.has(Number(dataId)) ? this.shellContractMap.get(Number(dataId)): '';
            this.selectedProdDetails[i].instructions = this.instructionsMap.has(Number(dataId)) ? this.instructionsMap.get(Number(dataId)): '';
            this.selectedProdDetails[i].productId = this.productIdMap.has(Number(dataId)) ? this.productIdMap.get(Number(dataId)): '';
            if(this.isOrgStatusDraft===true){
            this.selectedProdDetails[i].sfId = this.oliSfIdMap.has(Number(dataId)) ? this.oliSfIdMap.get(Number(dataId)): '';
            }
        }

    }
  
}