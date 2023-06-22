import { LightningElement,track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import communityBasePath from '@salesforce/community/basePath';
import getOrderDetailsBySoldToIdCU from '@salesforce/apex/TCP_OrderController.getOrderDetailsBySoldToIdCU';
import generatePDF from '@salesforce/apex/TCP_OrderController.generatePDF';
import getOrderCUReport from '@salesforce/apex/TCP_OrderController.getOrderCUReport';
import tcpFilter from '@salesforce/resourceUrl/TCP_filter';
import tcpDownloadIcon from '@salesforce/resourceUrl/TCP_download_icon';
import TCP_CurrentOrderLabel from '@salesforce/label/c.TCP_CurrentOrderLabel';
import TCP_ReviewOrApprovalLabel from '@salesforce/label/c.TCP_ReviewOrApprovalLabel';
import TCP_ApprovalLabel from '@salesforce/label/c.TCP_ApprovalLabel';
import TCP_OrderLabel from '@salesforce/label/c.TCP_OrderLabel';
import TCP_InvalidDateError from '@salesforce/label/c.TCP_InvalidDateError';
import TCP_NoDataFilterError from '@salesforce/label/c.TCP_NoDataFilterError';
import TCP_MinCharSearchError from '@salesforce/label/c.TCP_MinCharSearchError';
import getPickListValues from '@salesforce/apex/TCP_HomePageController.getPickListValues';
import getAllProductDetailsBySoldToId from '@salesforce/apex/TCP_HomePageController.getAllProductDetailsBySoldToIdCU';
import getCustomerBySoldToAndType from '@salesforce/apex/TCP_HomePageController.getCustomerBySoldToAndTypeCU';
import getOrderedBySoldToId from '@salesforce/apex/TCP_HomePageController.getOrderedBySoldToIdCU';
import getOrderDetailsByFilter from '@salesforce/apex/TCP_OrderController.getOrderDetailsByFilter';
import getOrderDetailsBySearchKey from '@salesforce/apex/TCP_OrderSearchController.getOrderDetailsBySearchKey';

const custPo='Customer PO';
const devTo='Delivery To';
const index3=3;
const index2=2;
const columns = [
    { label: 'Web Order Number', fieldName: 'WebOrderNo' , sortable: true, initialWidth: 165,  type: 'button', typeAttributes: {label: { fieldName: 'WebOrderNo' }, target: '', name: 'view_order_details' },cellAttributes: { class: 'clicableField' },},
    { label: custPo, fieldName: 'CustomerPO' , sortable: true,  type: 'text', wrapText: true, },
    { label: 'Order Name', fieldName: 'OrderName' , sortable: true,  type: 'text', wrapText: true,},
    { label: devTo, fieldName: 'DeliveryTo' , sortable: true,  type: 'text', wrapText: true, },
    { label: 'Product', fieldName: 'Product' , sortable: true,  type: 'text', wrapText: true,},
    { label: 'Status', fieldName: 'Status',  sortable: true, hideDefaultActions: true, initialWidth: 100,  type: 'text',  cellAttributes: { class: { fieldName: 'statusColor' }}},
        
];

export default class TcpAllOrdersCU extends NavigationMixin (LightningElement) {

    label = {
        TCP_CurrentOrderLabel,
        TCP_ReviewOrApprovalLabel,
        TCP_ApprovalLabel,
        TCP_OrderLabel,
        TCP_InvalidDateError,
        TCP_NoDataFilterError,
        TCP_MinCharSearchError

    }
    modeofTransportApiName = 'Mode_of_Transport__c';
    deliveryTermApiName = 'Delivery_Terms__c';
    orderApiName ='Order';
    tcpFilter=tcpFilter;
    tcpDownloadIcon=tcpDownloadIcon;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    rushOrder='Rush Order';
    lateOrder='Late Order';
    heightDefault='height: 450px;';
    height50='height: 50px;';
    approvedM='Approved (M)';
    approvedC='Approved (C)';
    tcpMultiselectJS='c-tcp_multi-select';
    tcpProductMultiSelect='c-tcp_-product-multi-select';
    @api soldtoid;
    @api cuselectedtile;
    @api initialloadtile;
    @api customeroptionscu;
    @api filterlist;
    @api selectedaccids;
    @track accountId = [];
    @track orderList =[];
    @track refreshOrderList = [];
    @track orderDetailsMap = new Map();
    @track isOrderHistory =false;
    @track isLoadingCU = false;
    @track tableShow=true;
    @track filterSection = false;
    @track customerPo;
    @track modeOfTransOptions =[];
    @track modeOfTransValue;
    @track isFilterActive = false;
    @track isStatusActive = false;
    @track isProductActive=false;
    @track fulfilledByOptions = [{ label: 'None', value: 'None' },
                                {label: "Chemical GSAP P-31", value: "ChemicalGSAP"},
                                {label: "Third Party", value: "ThirdParty"},];
    @track fulfillByValue;
    @track orderPriorOptions = [
                                 { label: 'None', value: 'None' },
                                 { label: this.rushOrder, value: this.rushOrder},
                                 { label: this.lateOrder, value: this.lateOrder},
                                 { label: 'Last Minute Changes', value: 'Last Minute'},];
    @track ordPriorityValue;
    @api prodListOptions = [];
    @track selectedProduct;
    @track orderStatus;
    @track deliveryToOptions=[];
    @track selectedDeliveryTo;
    @track delTermsOptions =[];
    @track selectedDelValue;
    @track orderedByOptions =[];
    @track selectedOrderedByValue;
    @track dateTypeValue;
    @track disableDate = true;
    @track fromDate;
    @track toDate;
    @track orderWrapper = {};
    @track orderLineWrapper = {};
    @track activeFilters =[];
    @track filteredData;
    @track wrapList=[];
    @track isFilterDataActive = false;
    @track noDataFound = false;
    @track dataTableHeight ='height: 450px;';
    @track isShowModal = false;
    @track searchTerm ='';
    @track defaultStatusOnSearch;
    @track filteredOrdersList = [];
    @track filteredOrdersList2 = [];
    @track isSearchActive = false;
    @track isSearchDataActive = false;
    @track issearchText = false;
    @track clearFilterData = false;
    @track dateError = false;
    @track prodNameList=[];
    @track prodIdList=[];
    @track selectedProductId;
    @track customerSelectText;
    @track accountData = [];
    @track selectedCustMap = new Map();
    @track accountIds = [];
    @track setAccIds = true;

    productNameCodeMap = new Map();
    productMap = new Map();
    deliveryToMap = new Map();
    orderedByMap = new Map();
    initialRecords;
    defaultRevAppStatus = 'Submitted';
    defaultModCanStatus = 'Approved (C);Approved (M)';
    defaultCurrentStatus = 'Approved;Submitted;Approved (C);Approved (M);Shipped';
    defaultStatusOnApply;
    userType ='Comm Ops User';
    error;
    defaultCustText = 'All Customer Selected';
    custDropDownAction ='slds-is-open';
    custDropDownName = '.slds-dropdown-trigger';
    allCustCheck ='.all-cust-check';
    sldsVisible = 'slds-visible';
    sldsHidden = 'slds-hidden';
    sldsHasFocus = 'slds-has-focus';
    sldsCustFocus = '.slds-cust-focus';
    uncheckAll = '.uncheck-all';
    docTitle = 'TCP | Order History';
    
    constructor() {
        super();
        this.columns = this.columns.concat([
            { label: 'Action', fieldName: 'Action', hideDefaultActions: true, 
            cellAttributes: { iconName: 'utility:threedots_vertical', },
            type: 'action', fixedWidth: 75, fixedHeight: 48,
            typeAttributes: { rowActions: this.getRowActions },
            }
        ]);

    }

    connectedCallback(){
        this.accountData = this.customeroptionscu;
        this.filteredData = this.filterlist;
        this.customerSelectText = this.defaultCustText;
        if(this.filteredData && this.filteredData.length>0){
            if(this.filteredData[0] && Object.keys(this.filteredData[0]).length > 0){
                this.populateFilterPickListData();
                this.orderWrapper = this.filteredData[0];
                this.orderLineWrapper = this.filteredData[1];
                this.isFilterDataActive = true;
            }
            if(this.filteredData[index3] && this.filteredData[index3].length>0){
                this.isSearchDataActive = true;
            }
            
        }
        this.handleData(this.initialloadtile);
        this.accountIds = this.soldtoid;
    }

    validateAccountIds(){
        if(this.selectedaccids && this.selectedaccids.length>0 && this.setAccIds){
            this.setAccIds = false;
            this.accountId = this.selectedaccids;
            this.populateDropDownOnBack();
        }else{
            this.accountId = this.soldtoid;
        }
    }

    handleCustDropDown(event){
        const target = this.template.querySelector(this.custDropDownName);
        const focusElement = this.template.querySelector(this.sldsCustFocus);
    
        if(target != null && target.classList.contains(this.custDropDownAction)){
            target.classList.remove(this.custDropDownAction);
            if(focusElement != null && target.classList.contains(this.sldsHasFocus)){
                target.classList.remove(this.sldsHasFocus); 
            }
        }else{
            target.classList.add(this.custDropDownAction);
            if(focusElement != null){
                target.classList.add(this.sldsHasFocus);
            }
            event.stopImmediatePropagation();
            window.addEventListener('click', this.handleClose);
        }
    }

    handleClose = (event) => {
        event.stopPropagation();
        this.closeDropdown();
        window.removeEventListener('click', this.handleClose);
    }

    closeDropdown(){
        document.title = this.docTitle;
        const target = this.template.querySelector(this.custDropDownName);
        const focusElement = this.template.querySelector(this.sldsCustFocus);
        if(target != null && target.classList.contains(this.custDropDownAction)){
            target.classList.remove(this.custDropDownAction);
            if(focusElement != null && target.classList.contains(this.sldsHasFocus)){
                target.classList.remove(this.sldsHasFocus); 
            }
        }
    }

    handleAllCustCheck(){
        document.title = this.docTitle;
        const target = this.template.querySelector(this.allCustCheck);
        if(target != null && target.classList.contains(this.sldsVisible)){
            target.classList.remove(this.sldsVisible);
            target.classList.add(this.sldsHidden);
        }else{
            target.classList.remove(this.sldsHidden);
            target.classList.add(this.sldsVisible);
            this.uncheckAllOtherCustomers();
            this.handleChange();
            this.customerSelectText = this.defaultCustText;

        }
    }

    handleChange(){
        let accIds = [];
        if(this.selectedCustMap.size > 0){
           accIds = this.formatDataToList(this.selectedCustMap);
        }else{
            accIds = this.accountIds;
        }
        this.handleDataOnSoldtoChange(accIds);
    }

    formatDataToList(input){
        let data = [];
        if(input){
            for(const [mapkey,mapvalue] of input){
                data = [...data,mapvalue];
            }
        }
        return data;
    }


    handleCustChange(event){
        this.handleCustDropDown();
        this.handleAllCustCheck();
    }

    handleCustMultiSelect(event){
        const dataId = event.currentTarget.dataset.id;
        const target = this.template.querySelector(`[data-name="${dataId}"]`);
        if(target != null && target.classList.contains(this.sldsVisible)){
            target.classList.remove(this.sldsVisible);
            target.classList.add(this.sldsHidden);
            this.selectedCustMap.delete(dataId);
        }else{
            target.classList.remove(this.sldsHidden);
            target.classList.add(this.sldsVisible);
            this.selectedCustMap.set(dataId,dataId);
        }
        this.uncheckAllCustomer();
        this.handleCustDropDown();
        if(this.selectedCustMap.size > 0){
            this.handleChange();
            this.customerSelectText = `${this.selectedCustMap.size} Customer/s Selected`;
        }else{
            this.handleAllCustCheck();
        }
    }

    uncheckAllCustomer(){
        if(this.selectedCustMap.size > 0){
            const target = this.template.querySelector(this.allCustCheck);
            if(target != null && target.classList.contains(this.sldsVisible)){
                target.classList.remove(this.sldsVisible);
                target.classList.add(this.sldsHidden);
            }
        }
    }

    uncheckAllOtherCustomers(){
        this.template.querySelectorAll(this.uncheckAll).forEach(targetElement => {
            targetElement.classList.remove(this.sldsVisible);
            targetElement.classList.add(this.sldsHidden);
        });
        this.selectedCustMap.clear();
    }

    populateDropDownOnBack(){
        if(this.selectedaccids.length>0){
            this.customerSelectText = `${this.selectedaccids.length} Customer/s Selected`;
            setTimeout(() => {
                this.handleCustDropDown();
                for(const data of this.selectedaccids){
                    this.selectDropDownValue(data);
                    this.selectedCustMap.set(data,data);
                }
                
                this.handleAllCustCheck();
                this.handleCustDropDown();
            }, 2000);
        }
    }
    
    selectDropDownValue(dataId){
        const target = this.template.querySelector(`[data-name="${dataId}"]`);
        if(target != null){
            target.classList.remove(this.sldsHidden);
            target.classList.add(this.sldsVisible);
        }
    }

    @api handleDataOnSoldtoChange(soldToIdChanged){
        this.soldtoid=soldToIdChanged;
        if(this.isOrderHistory){
            this.handleData('Order History');
        }else{
            this.handleData(TCP_ReviewOrApprovalLabel+TCP_ApprovalLabel);
        }
    }

    @api handleData(cuselecttile){
        this.closefilterClick();
        if(this.noDataFound){
            this.noDataFound = false;
            this.dataTableHeight =this.heightDefault;
        }
        
        this.isStatusActive = false;
        this.isProductActive=false;
        this.isFilterActive = false;
        this.orderStatus = '';
        this.searchTerm = '';
        this.isSearchActive = false;
        this.issearchText = false;
        this.clearAllFilterValues();
        this.defaultSortDirection = 'asc';
        this.sortDirection = 'asc';
        this.sortedBy=null;
        this.isLoadingCU = true;
        //this.accountId = this.soldtoid;
        this.validateAccountIds();
        this.cuselectedtile=cuselecttile;
        if(cuselecttile==='Order History'){
            this.isOrderHistory=true;
        }
        this.tableShow=false;
        
        if(this.accountId){
            getOrderDetailsBySoldToIdCU({soldToId:this.accountId, selectedTile:this.cuselectedtile})
            .then(result=>{
                if(result){
                    this.generateOrderDetailsBySoldToIdCU(result);
                    if(this.isFilterDataActive && this.cuselectedtile === this.filteredData[index2]){
                        this.filterSection = false;
                        this.isFilterActive = true;
                        this.activateFilterOnLoad();
                        this.prepareRequestWrapper();
                        this.isFilterDataActive = false;
                    }else{
                        this.filteredData = [];
                    }
                    
                    this.isLoadingCU = false;
                    this.error = null;   
                }
            })
            .catch(error => {
                this.error = error;
                this.isLoadingCU = false;
                window.console.log('Error in getting data====> handleData'+JSON.stringify(this.error));
            });
        }
        else{
        this.isLoadingCU = false;
        }
    }

    generateOrderDetailsBySoldToIdCU(result){
        this.refreshOrderList = result;
        this.orderList = [];
        for(const key in result){  
            if (result.hasOwnProperty(key)) {  
            const dataList = [];
            dataList.WebOrderNo = result[key].orderNumber;
            dataList.CustomerPO = result[key].poNumber;
            dataList.OrderName = this.handleValueCheck(result[key].name);
            dataList.DeliveryTo = result[key].shipToName;
            const lineItem = result[key].orderLineItemList;
            dataList.Product = this.generateProductName(lineItem);
            dataList.statusColor =this.handleStatusColor(result[key].status);
            dataList.Status = this.handleStatusText(result[key].status);
            this.orderList = [...this.orderList,dataList];
            this.orderDetailsMap.set(dataList.WebOrderNo, result[key]);
            }
        }
        this.initialRecords = this.orderList;
        this.tableShow=true;
        if(this.isSearchDataActive){
            this.searchTerm = this.filteredData[index3];
            this.issearchText = true;
            if(!this.isFilterDataActive){
                this.getSearchDataFromApex();
                this.isSearchDataActive = false;
            }
        }
    }

    generateProductName(lineItemsInput){
        let product='';
            for(const item in lineItemsInput){
                if(!product.includes(lineItemsInput[item].Material_Name__c)){
                    product += lineItemsInput[item].Material_Name__c + ', '
                }
            }
        return product;
    }

    // handleOptionChange(event) {
    //     this.value = event.detail.value;
    //     this.soldtoIdChanged(this.value);
    //     this.handleDataOnSoldtoChange(this.value);
    // }

    handleStatusText(inputStatus){
        const statSplit = inputStatus.split(' ');
        if(inputStatus===this.approvedM){
            return 'M'+statSplit[0];
        }else if(inputStatus===this.approvedC){
            return 'C'+statSplit[0];
        }else{
            return inputStatus;
        }
    }

    handleStatusColor(inputStatus){
        if(inputStatus===this.approvedM){
            return 'colorApprovedM';
        }else if(inputStatus===this.approvedC){
            return 'colorApprovedC';
        }else{
            return 'color'+inputStatus;
        }
    }
    
    get options(){
        return this.customeroptionscu;
    }

    get modeOfTransportOptions(){
        return this.modeOfTransOptions;
    }

    get fulfillByOptions(){
        return this.fulfilledByOptions;
    }

    get orderedPriorityOptions(){
        return this.orderPriorOptions;
    }

    get productOptions(){
        return this.prodListOptions;
    }

    get deliveryOptions(){
        return this.deliveryToOptions;
    }

    get deliveryTermsOptions(){
        return this.delTermsOptions;
    }

    get ordByOptions(){
        return this.orderedByOptions;
    }

    sortBy(field, reverse, primer) {
        const key = primer ?
        function(x) {
            if (x.hasOwnProperty(field)) {
                return primer(typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]);
              }
              return primer('aaa');
            }:
        function(x) {
            if (x.hasOwnProperty(field)) {
                return (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]);
                }
                return 'aaa';
            }

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((String(a) > String(b)) - (String(b) > String(a)));
        };
    }

    handleDownloadPDFCU(data){
        if(data){
        this.isLoadingCU=true;
        generatePDF({orderNumber:data}).then(response => {
        if(response){
        const element = document.createElement('a');
        element.setAttribute('href', 'data:application/pdf;base64,' + response);
        element.setAttribute('download', `Order Acknowledgement - ${data}.pdf`);
        element.style.display = 'none';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element); 
        this.isLoadingCU=false;
        }   
        }).catch(error => {
            this.error = error;
            this.isLoadingCU=false;
            window.console.log('Error'+JSON.stringify(this.error));
        });
    }   
    }

    handleDownloadReportExcelCU(){
        if(this.orderList && this.orderList.length>0){
            this.isLoadingCU=true;
            const orderNumbersInReport=[];
            this.orderList.forEach(ord =>{
                orderNumbersInReport.push(ord.WebOrderNo);

            });
            
            const columnHeader = ['Customer Name','Web Order Number',custPo,'Order Name',devTo,'Product Code','Product','Invoice To','Status','Delivery/Collection Date','Quantity','Unit','Ordered Quantity in TO','Shell Contract No.','Shell Ref No.','Goods Issue Date','Goods Issue','Goods Issue Unit','Goods Issue Quantity in TO','Goods Issue status','Loading Date','Fulfilled By','Sold To',this.lateOrder,this.rushOrder,'last Minute Changes','Mode of Transport','Dispatch Date','Delivery Term','Other Instruction','Instructions','Ordered by','Ordered Date','Bol/Delivery','Mode of Transport ID','Reviewed By','Reviewed Date/Time','Remarks','Modified By','Modified Date','Cancelled By','Cancelled Date'];
            getOrderCUReport({soldToIds:this.accountId, ordersInReportCU:orderNumbersInReport})
            .then(result=>{
                if(result){
                    
                     // Prepare a html table
                    let doc ='';
                    //doc +='<div class="main" style="text-align:center;"> <h1>All Orders</h1><br/><h2><br/>Customer Name : ';
                    doc +=`<div class="main" style="text-align:center;"> <h1>${this.cuselectedtile}</h1><br/></div>`;
                    doc += '<table>';
                    // Add styles for the table
                    doc += '<style>';
                    doc += 'table, th, td {';
                    doc += '    border: 1px solid black;';
                    doc += '    border-collapse: collapse;';
                    //doc += '    mso-number-format:\\@;';
                    doc += '}';  
                    doc += '#textTD {';
                    doc += '    mso-number-format:\\@;';
                    doc += '}';    
                    doc += '#dateTimeTD {';
                    doc += '    mso-number-format:"dd MMM yyyy h:mm"';
                    doc += '}';  
                    doc += '#dateTD {';
                    doc += '    mso-number-format:"dd MMM yyyy"';
                    doc += '}';      
                    doc += '</style>';
                    // Add all the Table Headers
                    doc += '<tr>';
                    columnHeader.forEach(element => {            
                        doc += `<th>${element}</th>`;          
                    });
                    doc += '</tr>';
                    //Add the data rows
                    doc = this.generateReportDataCU(result,doc);
                    doc += '</table>';
                    const hrefElement = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
                    const downloadElement = document.createElement('a');
                    downloadElement.href = hrefElement;
                    downloadElement.target = '_self';
                    //downloadElement.download = 'All Orders for '+result[0].soldToName.replace(/\./g,'');
                    downloadElement.download =  this.cuselectedtile.replace('For ', '')+' Report';
                    document.body.appendChild(downloadElement);
                    downloadElement.click();
                    document.body.removeChild(downloadElement); 
                    this.isLoadingCU=false;
                    }
            })
            .catch(error => {
                this.error = error;
                this.isLoadingCU = false;
                window.console.log('Error'+JSON.stringify(this.error));
            });
            
        }
    }   

    generateReportDataCU(result,doc){
        for(const key in result){
            if (result.hasOwnProperty(key)) {            
            const lineItem = result[key].orderLineItemList;
            doc=this.generateReportDataCuHtmlGenarator(result,key,lineItem,doc); 
            }
        }
        return doc;
    }

    generateReportDataCuHtmlGenarator(result,key,lineItem,doc){
        for(const item in lineItem){
            if (lineItem.hasOwnProperty(item)) {
            doc += '<tr>';
            doc += this.handleHtmlNullTextCheck(result[key].soldToName);
            doc += this.handleHtmlNullTextCheck(result[key].orderNumber);
            doc += this.handleHtmlNullTextCheck(result[key].poNumber);
            doc += this.handleHtmlNullTextCheck(result[key].name);
            doc += this.handleHtmlNullTextCheck(result[key].shipToNameWithAddr);
            doc += this.handleHtmlNullTextCheck(lineItem[item].MaterialNumber__c);
            doc += this.handleHtmlNullTextCheck(lineItem[item].Material_Name__c);
            doc += this.handleHtmlNullTextCheck(result[key].billToNameWithAddr);
            doc += this.handleHtmlNullTextCheck(result[key].status);
            doc += this.handleHtmlNullDCheck(lineItem[item].Delivery_Collection_Date__c);
            doc += this.handleHtmlNullCheck(lineItem[item].Quantity__c);
            doc += this.handleHtmlNullCheck(lineItem[item].Unit__c);
            doc += this.handleHtmlNullCheckUnit(lineItem[item].Unit__c,lineItem[item].Quantity__c);
            doc += this.handleHtmlNullTextCheck(lineItem[item].Contract_No__c);
            doc += this.handleHtmlNullTextCheck(result[key].salesordernumber);
            doc += this.handleHtmlNullDCheck(lineItem[item].GSAP_Goods_Issue_Date__c);
            doc += this.handleHtmlNullCheckQuantity(lineItem[item].GSAP_Goods_Issue_Value__c);
            doc += this.handleHtmlNullCheck(lineItem[item].GSAP_Goods_Issue_Unit__c);
            doc += this.handleHtmlNullCheckUnit(lineItem[item].GSAP_Goods_Issue_Unit__c,lineItem[item].GSAP_Goods_Issue_Value__c);
            doc += this.handleHtmlNullTextCheck(lineItem[item].GSAP_Goods_Issue_Status__c);
            doc += this.handleHtmlNullDCheck(lineItem[item].Expected_Dispatch_Date__c);
            doc += this.handleHtmlNullTextCheck(result[key].fullfilledBy);
            doc += this.handleHtmlNullTextCheck(result[key].gsapSoldToName);
            doc += this.handleHtmlNullCheck(result[key].isLateOrderVal);
            doc += this.handleHtmlNullCheck(result[key].isRushOrderVal);
            doc += this.handleHtmlNullCheck(result[key].isLastMinuteChangeVal);
            doc += this.handleHtmlNullCheck(result[key].modeOfTransport);
            doc += this.handleHtmlNullDCheck(lineItem[item].GSAP_Dispatch_Date__c);
            doc += this.handleHtmlNullCheck(result[key].deliveryTerms);
            doc += this.handleHtmlNullTextCheck(result[key].otherInstructions);
            doc += this.handleHtmlNullTextCheck(lineItem[item].Other_Instruction__c);
            doc += this.handleHtmlNullTextCheck(result[key].orderedBy);
            doc += this.handleHtmlNullDCheck(result[key].orderedDate);
            doc += this.handleHtmlNullTextCheck(lineItem[item].GSAP_Bol_Delivery__c);
            doc += this.handleHtmlNullTextCheck(lineItem[item].GSAP_Mode_of_Transport_ID__c);
            doc += this.handleHtmlNullCheck(result[key].reviewedBy);
            doc += this.handleHtmlNullDTCheck(result[key].reviewedDateTime);
            doc += this.handleHtmlNullCheck(result[key].remarks);
            doc += this.handleHtmlNullCheck(result[key].modificationBy);
            doc += this.handleHtmlNullDCheck(result[key].modificationDate);
            doc += this.handleHtmlNullCheck(result[key].cancellationBy);
            doc += this.handleHtmlNullDCheck(result[key].cancellationDate);
            doc += '</tr>'; 
            }  
        }
        return doc;
    }

    handleHtmlNullCheck(inputValue){
        if(inputValue){
            return `<td>${inputValue}</td>`;
        }else{
            return '<td></td>';
        }
    }

    handleHtmlNullCheckQuantity(inputValue){
        if(inputValue){
            return `<td>${inputValue}</td>`;
        }else{
            return '<td>0</td>';
        }
    }

    handleHtmlNullTextCheck(inputValue){
        if(inputValue){
            return `<td id="textTD">${inputValue}</td>`;
        }else{
            return '<td></td>';
        }
    }

    handleHtmlNullCheckUnit(inputUnit,inputValue){
        if(inputUnit){
            if(inputUnit==='KG'){
                return `<td>${inputValue/1000}</td>`;
            }else{
                return `<td>${inputValue}</td>`; 
            }
        }else{
            return '<td>0</td>';
        }

    }

    handleHtmlNullDTCheck(inputValue){
        if(inputValue){
            return `<td id="dateTimeTD">${inputValue}</td>`;
        }else{
            return '<td></td>';
        }
    }

    handleHtmlNullDCheck(inputValue){
        if(inputValue){
            return `<td id="dateTD">${inputValue}</td>`;
        }else{
            return '<td></td>';
        }
    }
    handleValueCheck(inputValue){
        if(inputValue){
            return inputValue;
        }else{
            return '';
        }
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.orderList];
        
        cloneData.sort(this.sortBy(sortedBy, this.generateSortDirection(sortDirection)));
        this.orderList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    generateSortDirection(sortDirection){
        if(sortDirection === 'asc'){
            return 1;
        }else{
            return -1;
            }
    }

    getRowActions(row, doneCallback) {
        
        const actions =[
            { label: 'View Order Details', name: 'view_order_details' },
            ];
            if ((row[ 'Status' ]!=='Rejected') && (row[ 'Status' ]!=='Approved') && (row[ 'Status' ]!=='Cancelled') && (row[ 'Status' ]!=='Shipped')) {
                actions.push({ label: 'Review Order Detail', name: 'review_order_detail' });
            }
            if ((row[ 'Status' ]!=='Draft') && (row[ 'Status' ]!=='Cancelled')) {
                actions.push({ label: 'Download Order Details', name: 'download_order_details' });
            }  
            doneCallback(actions);
        }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const data = this.orderDetailsMap.get(row.WebOrderNo);
        switch (actionName) {
            case 'review_order_detail':
                  this.wrapList = [];
                  if(this.isFilterActive || this.isSearchActive){  
                    this.wrapList[0] = this.orderWrapper;
                    this.wrapList[1] = this.orderLineWrapper;
                    this.wrapList[index2] = this.cuselectedtile;
                    if(this.isSearchActive){
                        this.wrapList[index3] = this.handleValueCheck(this.searchTerm);
                    }
                  }
                  this.navigateToOrderDetail(data, this.cuselectedtile,this.wrapList, this.formatDataToList(this.selectedCustMap));
                  break;
            case 'view_order_details':
                this.wrapList = [];  
                if(this.isFilterActive || this.isSearchActive){  
                    this.wrapList[0] = this.orderWrapper;
                    this.wrapList[1] = this.orderLineWrapper;
                    this.wrapList[index2] = this.cuselectedtile;
                    if(this.isSearchActive){
                        this.wrapList[index3] = this.handleValueCheck(this.searchTerm);
                    }
                }
                this.navigateToViewOrderDetailCU(data, this.cuselectedtile,this.wrapList, this.formatDataToList(this.selectedCustMap));
                break;
            case 'download_order_details':
                this.handleDownloadPDFCU(row.WebOrderNo);
                break;  
            default:
        }
    }

    handleFilterChange(event){
        const enteredValue = event.target.value;
        if(event.target.dataset.id === 'customerPo'){
            this.customerPo = enteredValue;
        }else if(event.target.dataset.id === 'toDate'){
            this.toDate = enteredValue;
        }else if(event.target.dataset.id === 'fromDate'){
            this.fromDate = enteredValue;
        }else{
            return;
        }
    }

    handleMoT(event){
        this.modeOfTransValue = event.detail.value;
    }

    handleFulfillBy(event){
        this.fulfillByValue = event.detail.value;
    }

    handleOrderPriority(event){
        this.ordPriorityValue = event.detail.value;
    }

    handleProduct(event){
        this.selectedProduct='';
        this.selectedProductId = event.detail.value;
        const splitProd=[];
        this.prodIdList=[];
        splitProd.id=this.selectedProductId.split(';');
        
        for(let i=0; i<splitProd.id.length;i++){
               
            const prodName=this.productNameCodeMap.get(splitProd.id[i]);
           
            this.prodIdList = [...this.prodIdList,prodName];
          
          this.prodIdList=[...new Set(this.prodIdList)];
        }
        for(let i=0; i<this.prodIdList.length; i++){
           
            if(this.selectedProduct!='' && this.selectedProduct!=this.prodIdList[i]){
              
                this.selectedProduct=this.selectedProduct+';'+this.prodIdList[i];
            }
            else{
               
                this.selectedProduct=this.prodIdList[i];
            }
           
        }
    }

    handleStatus(event){
        this.orderStatus = event.detail.value;
    }

    handleDeliveryTo(event){
        this.selectedDeliveryTo = event.detail.value;
    }

    handleDeliveryTerms(event){
        this.selectedDelValue = event.detail.value;
    }

    handleOrderedBy(event){
        this.selectedOrderedByValue = event.detail.value;
    }

    handleDateType(event){
        this.dateTypeValue = event.detail.value;
        if(this.dateTypeValue === 'None'){
            this.disableDate = true;
            this.fromDate = null;
            this.toDate = null;
            this.dateError = false;
        }else{
            this.disableDate = false;
        }
    }

    handleSearch(event){
        const searchKey = event.target.value;
        this.searchTerm = searchKey.trim();
        if(this.searchTerm.length>0){
            this.issearchText = true;
        }else{
            this.issearchText = false;
        }       
    }

    handleProdFocus(){
        this.template.querySelector(this.tcpMultiselectJS).closeMultiSelect();
        this.template.querySelector(this.tcpProductMultiSelect).closeMultiSelect();


    }

    navigateToOrderDetail(data,type,filterdata,accountids){
        this.dispatchEvent(new CustomEvent('orderdetail',{detail : {data, type, filterdata, accountids}}));
    }  

    navigateToViewOrderDetailCU(data, type, filterdata,accountids){
        this.dispatchEvent(new CustomEvent('vieworderdetailcu',{detail : {data, type, filterdata, accountids}}));
    } 

    soldtoIdChanged(data){
        this.dispatchEvent(new CustomEvent('c',{detail : {data}}));
    } 
  
    filterClick(){
        this.filterSection = true;
        this.isStatusActive = true;
        this.populateFilterPickListData();
        
        this.clearStatusData();
        this.clearProductData();
       
    }

   closefilterClick(){
    this.filterSection = false;
   }
    
   get dateTypeOptions() {
       return [
           { label: 'None', value: 'None' },
           { label: 'Delivery Date', value: 'DeliveryDate' },
           { label: 'Dispatch Date', value: 'DispatchDate' },
           { label: 'Loading Date', value: 'LoadingDate' },
       ];
   }

   deliveryTo(event) {
       this.filterDeliveryToValue = event.detail.value;
   }

   populateFilterPickListData(){

    getPickListValues({objectApiName: this.orderApiName, fieldApiName: this.modeofTransportApiName})
    .then(result=>{
        this.modeOfTransOptions.splice(0,this.modeOfTransOptions.length);
        result.forEach(opt => {            
            const option = {
                        label :opt,
                        value :opt
                    };   
            this.modeOfTransOptions = [...this.modeOfTransOptions,option];       
        });
        
    })
    .catch(error => {
        this.error = error;
        window.console.log('Error in getting Mode of transport====>'+JSON.stringify(this.error));
    });

    getPickListValues({objectApiName: this.orderApiName, fieldApiName: this.deliveryTermApiName})
        .then(result=>{
            this.delTermsOptions.splice(0,this.delTermsOptions.length);
            result.forEach(opt => {            
                const option = {
                            label :opt,
                            value :opt
                        };   
                this.delTermsOptions = [...this.delTermsOptions,option];       
            });
        })
        .catch(error => {
            this.error = error;
            window.console.log('Error in getting Delivery terms====>'+JSON.stringify(this.error));
        });

    
    getAllProductDetailsBySoldToId({soldToIds: this.soldtoid})
        .then(result=>{
            this.prodListOptions.splice(0,this.prodListOptions.length);
            result.forEach(opt => {            
                const option = {
                            label :opt.Product__r.Name+'-'+opt.Product__r.ProductCode,
                            value :opt.Product__r.Id
                        };   
                this.prodListOptions = [...this.prodListOptions,option];
                this.productMap.set(opt.Product__r.Id,opt.Product__r.Name);    
                this.productNameCodeMap.set(opt.Product__r.Id,opt.Product__r.Name+'-'+opt.Product__r.ProductCode);  
            });
            this.isProductActive=true;
        })
        .catch(error => {
            this.error = error;
            window.console.log('Error in getting products====>'+JSON.stringify(this.error));
        });

    getCustomerBySoldToAndType({parentAccIds: this.soldtoid, type: 'Ship To'})
    .then(result=>{
        if(result){
            this.deliveryToOptions.splice(0,this.deliveryToOptions.length);
            result.forEach(opt => {            
                const accName = opt.Name;
                const cityName = opt.ShippingAddress.city;
                const shipToAddr = `${opt.Name}, ${opt.ShippingAddress.street}, ${opt.ShippingAddress.city}, ${opt.ShippingAddress.state}, ${opt.ShippingAddress.postalCode}, ${opt.ShippingAddress.country}`;
                
                const option = {
                    label : shipToAddr,
                    value : opt.Id
                };
                this.deliveryToOptions = [...this.deliveryToOptions, option];
                this.deliveryToMap.set(opt.Id,`${accName}, ${cityName}`);      
            });
        }
    })
    .catch(error => {
        this.error = error;
        window.console.log('ERROR=>'+this.error);
    });

    getOrderedBySoldToId({soldToIds: this.soldtoid})
        .then(result=>{
            this.orderedByOptions.splice(0,this.orderedByOptions.length);
            result.forEach(opt => {            
                const option = {
                    label : opt.Ordered_By__r.Name,
                    value : opt.Ordered_By__c
                };
                this.orderedByOptions = [...this.orderedByOptions,option];
                this.orderedByMap.set(opt.Ordered_By__c,opt.Ordered_By__r.Name); 
            });
        })
        .catch(error => {
            this.error = error;
        });

   }

   clearAllFilterValues(){
        
        this.prodNameList = [];
        this.customerPo = '';
        this.modeOfTransValue = '';
        this.StatusValue='';
        this.fulfillByValue = '';
        this.ordPriorityValue ='';
        this.selectedOrderedByValue = '';
        this.selectedDelValue = '';
        this.selectedDeliveryTo = '';
        this.dateTypeValue = '';
        this.fromDate = null;
        this.toDate = null;
        this.disableDate = true;
        this.dateError = false;
        
        if(this.orderStatus && this.orderStatus.length >0 && this.filterSection){
            this.template.querySelector(this.tcpMultiselectJS).clearStatusPills();
        }
        
        this.orderStatus = '';
        if(this.selectedProduct && this.selectedProduct.length>0 && this.filterSection)
          {
            this.template.querySelector('c-tcp_-product-multi-select').clearStatusPills();
            }       
            this.selectedProduct='';
            this.selectedProductId='';
   }

   handleApplyButton(){
    this.dataTableHeight = 'height: auto;'
    if(this.doInputValidation('.errorMsg')){
        if(this.fromDate > this.toDate){
            this.dateError = true;
        }else{
            this.dateError = false;
            this.filterSection = false;
            this.prepareRequestWrapper();
        }
    }
   }

   prepareRequestWrapper(){
        this.orderWrapper = {};
        this.orderLineWrapper = {};
        this.activeFilters = [];
        if(this.soldtoid && this.soldtoid.length >0){
            this.orderWrapper.soldToIdList = this.soldtoid;
            this.handleRequestWrapper1();
        }

        if(this.clearFilterData){
            this.isFilterActive = false;
            this.orderWrapper = [];
            this.orderLineWrapper = [];
            if(this.isSearchActive && this.filteredOrdersList2.length>0){
                this.orderList = this.filteredOrdersList2;
            }
            else if(this.initialRecords && this.initialRecords.length>0){
                if(this.noDataFound){
                    this.noDataFound = false;
                }
                this.dataTableHeight =this.heightDefault;
                this.orderList = this.initialRecords;
            }else{
                return;
            }
        }else if(this.doInputValidation('.errorMsg') && this.isFilterActive){
            this.getFilterDataFromApex();
        }else{
            return;
        }
    }

    handleRequestWrapper1(){
        if(this.customerPo && this.customerPo.length >0){
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderWrapper.poNumber = this.customerPo;
            const filterObj = [];
            filterObj.name = custPo;
            filterObj.value = this.customerPo;
            this.activeFilters = [...this.activeFilters,filterObj];
        }
        if(this.selectedDeliveryTo && this.selectedDeliveryTo.length >0){
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderWrapper.shipToId = this.selectedDeliveryTo;
            const filterObj = [];
            filterObj.name = devTo;
            filterObj.value = this.deliveryToMap.get(this.selectedDeliveryTo);
            this.activeFilters = [...this.activeFilters,filterObj];
        }
        if(this.selectedDelValue && this.selectedDelValue.length >0){
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderWrapper.deliveryTerms = this.selectedDelValue;
            const filterObj = [];
            filterObj.name = 'Delivery Terms';
            filterObj.value = this.selectedDelValue;
            this.activeFilters = [...this.activeFilters,filterObj];
        }
        if(this.modeOfTransValue && this.modeOfTransValue.length >0){
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderWrapper.modeOfTransport = this.modeOfTransValue;
            const filterObj = [];
            filterObj.name = 'Mode of Transport';
            filterObj.value = this.modeOfTransValue;
            this.activeFilters = [...this.activeFilters,filterObj];
        }
        this.handleRequestWrapper2();
    }
    
    handleRequestWrapper2(){
        if(this.orderStatus && this.orderStatus.length >0){
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderWrapper.status = this.orderStatus;
            const filterObj = [];
            filterObj.name = 'Status';
            filterObj.value = this.orderStatus;
            this.activeFilters = [...this.activeFilters,filterObj];
        }else{
            this.defaultStatusOnApply = '';
            switch (this.cuselectedtile) {
                case 'For Review/Approval':
                    this.defaultStatusOnApply = this.defaultRevAppStatus;
                      break;
                case 'Modification/Cancellation Requests':
                    this.defaultStatusOnApply = this.defaultModCanStatus;
                      break;
                case 'Current Orders':
                    this.defaultStatusOnApply = this.defaultCurrentStatus;
                      break;
                default:
            }
        }
        if(this.fulfillByValue && this.fulfillByValue.length >0 && this.fulfillByValue !== 'None'){
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderWrapper.fullfilledBy = this.fulfillByValue;
            const filterObj = [];
            filterObj.name = 'Fulfilled by';
            filterObj.value = this.fulfillByValue;
            this.activeFilters = [...this.activeFilters,filterObj];
        }
        if(this.selectedOrderedByValue && this.selectedOrderedByValue.length >0){
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderWrapper.orderedBy = this.selectedOrderedByValue;
            const filterObj = [];
            filterObj.name = 'Ordered by';
            filterObj.value = this.orderedByMap.get(this.selectedOrderedByValue);
            this.activeFilters = [...this.activeFilters,filterObj];
        }
        if(this.ordPriorityValue && this.ordPriorityValue.length >0 && this.ordPriorityValue !== 'None'){
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderWrapper.orderPriority = this.ordPriorityValue;
            const filterObj = [];
            filterObj.name = 'Ordered Priority';
            filterObj.value = this.ordPriorityValue;
            this.activeFilters = [...this.activeFilters,filterObj];
        }
        this.handleRequestWrapper3();
    }
    
    handleRequestWrapper3(){
        if(this.dateTypeValue && this.dateTypeValue.length >0 && this.dateTypeValue !== 'None'){
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderLineWrapper.dateType = this.dateTypeValue;
            this.orderLineWrapper.fromDate = this.handleJSNullCheck(this.fromDate);
            this.orderLineWrapper.toDate = this.handleJSNullCheck(this.toDate);
            const filterObj = [];
            filterObj.name = this.dateTypeValue;
            filterObj.value = `${this.fromDate} To ${this.toDate}`;
            this.activeFilters = [...this.activeFilters,filterObj];
        }
        if(this.selectedProductId && this.selectedProductId.length >0){
            this.prodNameList=[];
            this.isFilterActive = true;
            this.clearFilterData = false;
            this.orderLineWrapper.productId = this.selectedProductId;
            this.orderLineWrapper.materialName=this.selectedProduct;
            const splitProd=[];
                splitProd.name=this.selectedProductId.split(';');
              
                for(let i=0; i<splitProd.name.length;i++){
                
                    const prodName=this.productNameCodeMap.get(splitProd.name[i]);
                    this.prodNameList = [...this.prodNameList,prodName];
                    this.prodNameList=[...new Set(this.prodNameList)];
                }
            const filterObj = [];
            filterObj.name = 'Product';
            filterObj.value = this.prodNameList;
            this.activeFilters = [...this.activeFilters,filterObj];
        }
    }

    handleJSNullCheck(inputValue){
        if(inputValue){
            return inputValue;
        }else{
            return null;
        }
    }

    getFilterDataFromApex(){
        this.isLoadingCU = true;
        
        getOrderDetailsByFilter({ordWrap : this.orderWrapper, ordLineWrap : this.orderLineWrapper, defaultStatus : this.defaultStatusOnApply, userType: this.userType, selectedTile: this.cuselectedtile})
        .then(result=>{
           
            if(result && result.length>0){
                this.generateFilterData(result);
            }else{
                this.dataTableHeight = this.height50;
                this.noDataFound = true;
                this.isLoadingCU = false;
                this.orderList = [];
            }
        })
        .catch(error=>{
            this.error = error;
            this.isLoadingCU = false;
            window.console.log('Error in getting filter data====>'+JSON.stringify(this.error));
        });
    }

    generateFilterData(result){
        this.noDataFound = false;
        this.dataTableHeight =this.heightDefault;
        this.orderList = [];
        let tempList = [];
        this.filteredOrdersList = [];
            for(const key in result){   
                if (result.hasOwnProperty(key)){
                    const dataList = [];
                    dataList.WebOrderNo = result[key].orderNumber;
                    dataList.CustomerPO = result[key].poNumber;
                    dataList.OrderName = this.handleValueCheck(result[key].name);
                    dataList.DeliveryTo = result[key].shipToName;
                    const lineItem = result[key].orderLineItemList;
                    dataList.Product = this.generateProductName(lineItem);
                    dataList.statusColor =this.handleStatusColor(result[key].status);
                    dataList.Status = this.handleStatusText(result[key].status);
                    if(this.isSearchActive){
                        tempList=this.generateFilterSearchOverlap(dataList.WebOrderNo,tempList);
                    }else{
                        this.orderList = [...this.orderList,dataList];
                    }
                    this.filteredOrdersList = [...this.filteredOrdersList, dataList];
                }
            }
            if(this.isSearchActive){
                this.orderList = tempList;
            }
            if(this.orderList.length===0){
                this.dataTableHeight = this.height50;
                this.noDataFound = true;
            }
            if(this.isSearchDataActive && this.cuselectedtile === this.filteredData[index2]){
                this.getSearchDataFromApex();
                this.isSearchDataActive = false;
            }
            this.isLoadingCU = false;
    }

    generateFilterSearchOverlap(inputWebOrderNo,tempList){
        this.filteredOrdersList2.forEach(ord => {            
            if(inputWebOrderNo === ord.WebOrderNo){
                tempList = [...tempList, ord];
                
            }       
        });
        return tempList;
    }

    getSearchDataFromApex(){
        this.defaultStatusOnSearch ='';
        switch (this.cuselectedtile) {
            case 'For Review/Approval':
                 this.defaultStatusOnSearch = this.defaultRevAppStatus;
                 break;
            case 'Modification/Cancellation Requests':
                  this.defaultStatusOnSearch = this.defaultModCanStatus;
                  break;
            case 'Current Orders':
                this.defaultStatusOnSearch = this.defaultCurrentStatus;
                break;
            default:
        }
        this.isLoadingCU = true;
        
        getOrderDetailsBySearchKey({soldToIds: this.soldtoid, searchKey: this.searchTerm.toLocaleLowerCase(), defaultStatus: this.defaultStatusOnSearch, userType: this.userType, selectedTile: this.cuselectedtile})
        .then(result=>{
            
            if(result && result.length>0){
                this.generateSearchData(result);
            }else{
                this.dataTableHeight = this.height50;
                this.noDataFound = true;
                this.isLoadingCU = false;
                this.orderList = [];
            }

        })
        .catch(error=>{
            this.isSearchActive = false;
            this.error = error;
            this.isLoadingCU = false;
            window.console.log('Error in getting Search data====>'+JSON.stringify(this.error));
        });
    }

    generateSearchData(result){
        this.isSearchActive = true;
        this.noDataFound = false;
        this.dataTableHeight =this.heightDefault;
        this.orderList = [];
        this.filteredOrdersList2 = [];
        let tempList = [];
        for(const key in result){   
                if (result.hasOwnProperty(key)){ 
                    const dataList = [];
                    dataList.WebOrderNo = result[key].orderNumber;
                    dataList.CustomerPO = result[key].poNumber;
                    dataList.OrderName = this.handleValueCheck(result[key].name);
                    dataList.DeliveryTo = result[key].shipToName;
                    const lineItem = result[key].orderLineItemList;
                    dataList.Product = this.generateProductName(lineItem);
                    dataList.statusColor =this.handleStatusColor(result[key].status);
                    dataList.Status = this.handleStatusText(result[key].status);
                    if(this.isFilterActive){
                        tempList =this.generateSearchFilterOverlap(dataList.WebOrderNo,tempList);
                    }else{
                        this.orderList = [...this.orderList,dataList];
                    }
                    this.filteredOrdersList2 = [...this.filteredOrdersList2, dataList];
                }
            }
            if(this.isFilterActive){
                this.orderList = tempList;
            }
            this.isLoadingCU = false;
    }

    generateSearchFilterOverlap(inputWebOrderNo,tempList){
        this.filteredOrdersList.forEach(ord => {            
            if(inputWebOrderNo === ord.WebOrderNo){
                tempList = [...tempList, ord];
                
            }       
        });
        return tempList;
    }

    doInputValidation(screenName){
        return [...this.template.querySelectorAll(screenName)]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
    }

    activateFilterOnLoad(){
        if(this.orderWrapper.poNumber && this.orderWrapper.poNumber.length >0){
            this.customerPo = this.orderWrapper.poNumber;
        }
        if(this.orderWrapper.shipToId && this.orderWrapper.shipToId.length >0){
            this.selectedDeliveryTo = this.orderWrapper.shipToId;
        }
        if(this.orderWrapper.status && this.orderWrapper.status.length >0){
            this.orderStatus = this.orderWrapper.status;
        }
        if(this.orderWrapper.deliveryTerms && this.orderWrapper.deliveryTerms.length >0){
            this.selectedDelValue = this.orderWrapper.deliveryTerms;
        }
        this.handleFilterOnLoad1();
    }

    handleFilterOnLoad1(){
        if(this.orderWrapper.modeOfTransport && this.orderWrapper.modeOfTransport.length >0){
            this.modeOfTransValue =this.orderWrapper.modeOfTransport;
        }
        if(this.orderWrapper.fullfilledBy && this.orderWrapper.fullfilledBy.length >0){
            this.fulfillByValue = this.orderWrapper.fullfilledBy;
        }
        if(this.orderWrapper.orderedBy && this.orderWrapper.orderedBy.length >0){
            this.selectedOrderedByValue = this.orderWrapper.orderedBy;
        }
        if(this.orderWrapper.orderPriority && this.orderWrapper.orderPriority.length >0){
            this.ordPriorityValue = this.orderWrapper.orderPriority;
        }
        this.handleFilterOnLoad2();
    }

    handleFilterOnLoad2(){
        if(this.orderWrapper.orderPriority && this.orderWrapper.orderPriority.length >0){
            this.ordPriorityValue = this.orderWrapper.orderPriority;
        }
        if(this.orderLineWrapper.dateType && this.orderLineWrapper.dateType.length >0 && this.orderLineWrapper.dateType !== 'None'){
            this.dateTypeValue = this.orderLineWrapper.dateType;
            this.fromDate = this.orderLineWrapper.fromDate;
            this.toDate = this.orderLineWrapper.toDate;
            this.disableDate = false;
        }
        if(this.orderLineWrapper.productId && this.orderLineWrapper.productId.length >0){
            this.selectedProductId = this.orderLineWrapper.productId;
            this.selectedProduct=this.orderLineWrapper.materialName;
        }
    }

    showModalBox() {  
        this.isShowModal = true;
    }
    handleCloseModal() {  
        this.isShowModal = false;
    }

    handleSearchClick(){
        if(this.searchTerm && this.searchTerm.length>index2){
            this.getSearchDataFromApex();
            this.scrollToTopOfPage();
        }else{
            this.isShowModal = true;
        }
    }

    handleSearchCancel(){
        this.searchTerm = '';
        this.issearchText = false;
        this.isSearchActive = false;
        
        if(this.isFilterActive && this.filteredOrdersList.length>0){
            if(this.noDataFound){
                this.noDataFound = false;
            }
            this.dataTableHeight =this.heightDefault;
            this.orderList = this.filteredOrdersList;   
        }
        else if(this.initialRecords && this.initialRecords.length>0){
            if(this.noDataFound){
                this.noDataFound = false;
            }
            this.dataTableHeight =this.heightDefault;
            this.orderList = this.initialRecords;
        }
        else{
            return;
        }
    }

    handleClearFilter(){
        this.clearFilterData = true;
        this.clearAllFilterValues();
    }

    handleClearActiveFilters(){
        this.isFilterActive = false;
        this.orderStatus = '';
        this.selectedProduct='';
        this.clearAllFilterValues();
        this.orderWrapper = [];
        this.orderLineWrapper = [];
        if(this.isSearchActive && this.filteredOrdersList2.length>0){
            this.orderList = this.filteredOrdersList2;
        }
        else if(this.initialRecords && this.initialRecords.length>0){
            if(this.noDataFound){
                this.noDataFound = false;
            }
            this.dataTableHeight =this.heightDefault;
            this.orderList = this.initialRecords;
        }else{
            return;
        }
    }

    clearStatusData(){
        window.console.log('Coming to order status');
        if(this.orderStatus.length===0){
            window.console.log('Coming to order status inside');
            this.template.querySelector(this.tcpMultiselectJS).clearStatusPills();
        }
        window.console.log('outside of order status check');
    }
    clearProductData(){
        window.console.log('Coming to product data');
        if(this.selectedProduct.length===0){
            window.console.log('hecking coming inside');
            this.template.querySelector(this.tcpProductMultiSelect).clearStatusPills();
        }
        
    }

   

    scrollToTopOfPage(){
        this.isLoadingCU = true;
        this.dataTableHeight = 'height: auto;'
    }

    handleBulkOrder(){
        const pageName = communityBasePath + '/bulkOrder?pagesrc=orderhistory';
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
              url: pageName
            }
        });
    }

    
}