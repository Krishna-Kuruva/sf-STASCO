import { LightningElement,track,api  } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOrderDetailsBySoldToIdEU from '@salesforce/apex/TCP_OrderController.getOrderDetailsBySoldToIdEU';
import generatePDF from '@salesforce/apex/TCP_OrderController.generatePDF';
import getOrderEUReport from '@salesforce/apex/TCP_OrderController.getOrderEUReport';
import TCP_filter from '@salesforce/resourceUrl/TCP_filter';
import TCP_download_icon from '@salesforce/resourceUrl/TCP_download_icon';
import TCP_CurrentOrderLabel from '@salesforce/label/c.TCP_CurrentOrderLabel';
import TCP_OrderLabel from '@salesforce/label/c.TCP_OrderLabel';
import TCP_InvalidDateError from '@salesforce/label/c.TCP_InvalidDateError';
import TCP_NoDataFilterError from '@salesforce/label/c.TCP_NoDataFilterError';
import TCP_MinCharSearchError from '@salesforce/label/c.TCP_MinCharSearchError';
import getPickListValues from '@salesforce/apex/TCP_HomePageController.getPickListValues';
import getAllProductDetailsBySoldToId from '@salesforce/apex/TCP_HomePageController.getAllProductDetailsBySoldToId';
import getCustomerBySoldToAndType from '@salesforce/apex/TCP_HomePageController.getCustomerBySoldToAndType';
import getOrderedBySoldToId from '@salesforce/apex/TCP_HomePageController.getOrderedBySoldToId';
import getOrderDetailsByFilter from '@salesforce/apex/TCP_OrderController.getOrderDetailsByFilter';
import getOrderDetailsBySearchKey from '@salesforce/apex/TCP_OrderSearchController.getOrderDetailsBySearchKey';


const custPo='Customer PO';
const devTo='Delivery To';
const columns = [
    { label: 'Web Order Number', fieldName: 'WebOrderNo' , sortable: true, wrapText: true, initialWidth: 165, type: 'button',typeAttributes: {label: { fieldName: 'WebOrderNo' }, target: '', name: 'view_order_details'},cellAttributes: { class: 'clicableField' },},
    { label: 'Customer PO', fieldName: 'CustomerPO' , sortable: true,  type: 'text', wrapText: true, },
    { label: 'Order Name', fieldName: 'OrderName' , sortable: true,  type: 'text', wrapText: true,},
    { label: 'Delivery To', fieldName: 'DeliveryTo' , sortable: true,  type: 'text', wrapText: true, },
    { label: 'Product', fieldName: 'Product' , sortable: true,  type: 'text', wrapText: true,},
    { label: 'Status', fieldName: 'Status',  sortable: true, hideDefaultActions: true, initialWidth: 100,  type: 'text', 
        cellAttributes: { class: { fieldName: 'statusColor' }}},
    
];


export default class TcpAllOrdersEU extends NavigationMixin (LightningElement) {
    
    label = {
        TCP_CurrentOrderLabel,
        TCP_OrderLabel,
        TCP_InvalidDateError,
        TCP_NoDataFilterError,
        TCP_MinCharSearchError
    }


    TCP_filter=TCP_filter;
    TCP_download_icon=TCP_download_icon;
    modeofTransportApiName = 'Mode_of_Transport__c';
    deliveryTermApiName = 'Delivery_Terms__c';
    orderApiName ='Order';
   
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @api soldtoid;
    @api soldtoname;
    @api euselectedtile;
    @api euselectedtileUI;
    @api initialloadtile;
    @api filterlist;
    @track portalTile;
    @track accountId;
    @track orderList =[];
    @track refreshOrderList = [];
    @track orderDetailsMap = new Map();
    @track isLoadingEU = false;
    @track isOrderHistory =false;
    @track euReportHeading;
    @track filterSection = false;
    @track tableShowEU=true;
    @track customerPo;
    @track modeOfTransOptions =[];
    @track modeOfTransValue;
    @track isFilterActive = false;
    @track isStatusActive = false;
    @track isProductActive = false;
    @api prodListOptions = [];
    @track prodNameList=[];
    @track prodIdArray=[];
    @track selectedProduct;
    @track selectedProductId;
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
    @track prodIdList=[];
    productNameCodeMap = new Map();
    productMap = new Map();
    deliveryToMap = new Map();
    orderedByMap = new Map();
    initialRecords;
    userType ='End User';
    defaultRejCanStatus = 'Rejected;Cancelled';
    defaultCurrentStatus = 'Approved;Submitted;Approved (C);Approved (M);Shipped';
    defaultStatusOnApply;
    
    error;
    
    constructor() {
        super();
        this.columns = this.columns.concat( [
            { label: 'Action', fieldName: 'Action', hideDefaultActions: true, 
            cellAttributes: { iconName: 'utility:threedots_vertical', },
            type: 'action', fixedWidth: 75, fixedHeight: 48,
            typeAttributes: { rowActions: this.getRowActions }
        }
        ] );

    }

    connectedCallback(){
        this.filteredData = this.filterlist;
        if(this.filteredData && this.filteredData.length>0){
            
            if(this.filteredData[0] && Object.keys(this.filteredData[0]).length > 0){
                this.populateFilterPickListData();
                this.orderWrapper = this.filteredData[0];
                this.orderLineWrapper = this.filteredData[1];
                this.isFilterDataActive = true;
            }
            if(this.filteredData[3] && this.filteredData[3].length>0){
                this.isSearchDataActive = true;
            }
            
        }
        this.handleData(this.initialloadtile);
       
    } 


    @api handleData(euselecttile){
        this.closefilterClick();
        if(this.noDataFound){
            this.noDataFound = false;
            this.dataTableHeight ='height: 450px;';
        }
        this.isStatusActive = false;
        this.isProductActive = false;
        this.isFilterActive = false;
        this.searchTerm = '';
        this.isSearchActive = false;
        this.issearchText = false;
        this.orderStatus = '';
        this.clearAllFilterValues();
        this.defaultSortDirection = 'asc';
        this.sortDirection = 'asc';
        this.sortedBy=null;
        this.isLoadingEU = true;
        this.accountId = this.soldtoid;
        this.euselectedtile=euselecttile;
        if(euselecttile===TCP_CurrentOrderLabel+TCP_OrderLabel){
            this.euselectedtileUI=TCP_CurrentOrderLabel+' '+TCP_OrderLabel;
            this.euReportHeading=this.euselectedtileUI;
        }else if(euselecttile==='Order History'){
            this.euReportHeading=euselecttile;
            this.euselectedtileUI=this.soldtoname;
            this.isOrderHistory=true;
        }
        else{
             this.euselectedtileUI=euselecttile;
             this.euReportHeading=euselecttile;
        }
        this.tableShowEU=false;
        if(this.accountId){
            getOrderDetailsBySoldToIdEU({soldToId:this.accountId, selectedTile:this.euselectedtile})
            .then(result=>{
                if(result){
                    this.refreshOrderList = result;
                    this.orderList = [];
                    for(let key in result){    
                        const dataList = [];
                        dataList.WebOrderNo = result[key].orderNumber;
                        dataList.CustomerPO = result[key].poNumber;
                        dataList.OrderName = result[key].name ? result[key].name: '';
                        dataList.DeliveryTo = result[key].shipToName;
                        const lineItem = result[key].orderLineItemList;
                        let product='';
                        for(let item in lineItem){
                            if(!product.includes(lineItem[item].Material_Name__c)){
                                product += lineItem[item].Material_Name__c + ', '
                            }
                        }
                        dataList.Product = product;
                        dataList.Status = result[key].status;
                        if(dataList.Status)
                        {   
                            if(dataList.Status=='Approved (M)')
                            {
                                const statusData = dataList.Status;
                                const statSplit = statusData.split(' ');
                                dataList.statusColor ='colorApprovedM';
                                dataList.Status = 'M'+statSplit[0];
                            }else if(dataList.Status=='Approved (C)'){
                                const statusData = dataList.Status;
                                const statSplit = statusData.split(' ');
                                dataList.statusColor ='colorApprovedC';
                                dataList.Status = 'C'+statSplit[0];
                            }else{
                            dataList.statusColor ='color'+dataList.Status;
                            }
                        }
                        this.orderList = [...this.orderList,dataList];
                        this.orderDetailsMap.set(dataList.WebOrderNo, result[key]);
                    }
                    this.initialRecords = this.orderList;
                    this.tableShowEU=true;
                    if(this.isSearchDataActive){
                        this.searchTerm = this.filteredData[3];
                        this.issearchText = true;
                        if(!this.isFilterDataActive){
                            this.getSearchDataFromApex();
                            this.isSearchDataActive = false;
                        }
                    }
                    if(this.isFilterDataActive && this.euselectedtile == this.filteredData[2]){
                        this.filterSection = false;
                        this.isFilterActive = true;
                        this.activateFilterOnLoad();
                        this.prepareRequestWrapper();
                        this.isFilterDataActive = false;
                    }
                    this.isLoadingEU = false;
                    this.error = null;   
                }
            })
            .catch(error => {
                this.error = error;
                this.isLoadingEU = false;
                window.console.log('Error in getting data====> handleData'+JSON.stringify(this.error));
            });
        }
        else{
            this.isLoadingEU = false;
        }
        
    }

    sortBy(field, reverse, primer) {
        const key = primer ?
        function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
        function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
            

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.orderList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.orderList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    getRowActions(row, doneCallback) {
        const actions =[];
           if ((row[ 'Status' ]!=='Draft')){
                actions.push({ label: 'View Order Details', name: 'view_order_details' });
           
            }
           if ((row[ 'Status' ]!=='Rejected') && (row[ 'Status' ]!=='Cancelled') && (row[ 'Status' ]!=='Shipped') && (row[ 'Status' ]!=='Draft')){
            actions.push({ label: 'Modify Order', name: 'modify_order' });
            } 
            if ((row[ 'Status' ]!=='Draft') && (row[ 'Status' ]!=='Cancelled')) {
                actions.push({ label: 'Download Order Details', name: 'download_order_details' });
            }  
            if ((row[ 'Status' ]!=='Draft')){
                actions.push({ label: 'Re-order', name: 're_order' });
            }
            if ((row[ 'Status' ]=='Draft')){
                actions.push({ label: 'Resume Order', name: 're_order' });
            }
             
            doneCallback(actions);
        }

   handleDownloadPDFEU(data){
        if(data){
        this.isLoadingEU=true;
        generatePDF({orderNumber:data,soldToId:this.accountId}).then(response => {
        console.log(response);
        if(response){
        const element = document.createElement('a');
        element.setAttribute('href', 'data:application/pdf;base64,' + response);
        element.setAttribute('download', 'Order Acknowledgement - '+data+'.pdf');
        element.style.display = 'none';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element); 
        this.isLoadingEU=false;
        }   
        }).catch(error => {
            this.isLoadingEU=false;
            console.log('Error: ' +error.body.message);
        });
    }   
    }

    handleDownloadReportExcelEU(){
        if(this.orderList && this.orderList.length>0){
            this.isLoadingEU=true;
            const orderNumbersInReport=[];
            this.orderList.forEach(ord =>{
                orderNumbersInReport.push(ord.WebOrderNo);

            });
            
            const columnHeader = ['Customer Name','Web Order Number',custPo,'Order Name',devTo,'Product Number','Product','Invoice To','Status','Delivery/Collection Date','Quantity','Unit','Ordered Quantity in TO','Shell Contract No.','Shell Ref No.','Goods Issue Date','Goods Issue','Goods Issue Unit','Goods Issue Quantity in TO','Goods Issue status','Mode of Transport','Dispatch Date','Delivery Term','Other Instruction','Instructions','Ordered by','Ordered Date','Bol/Delivery','Mode of Transport ID','Remarks from Comm Ops','Modified By','Modified Date','Cancelled By','Cancelled Date'];
            
            getOrderEUReport({soldToId:this.accountId, ordersInReport:orderNumbersInReport})
            .then(result=>{
                if(result){
                    
                     // Prepare a html table
                    let doc ='';
                    //doc +='<div class="main" style="text-align:center;"> <h1>All Orders</h1><br/><h2><br/>Customer Name : ';
                    doc +=`<div class="main" style="text-align:center;"> <h1>${this.euReportHeading}</h1><br/></div>`;
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
                    doc = this.generateReportDataEU(result,doc);
                    doc += '</table>';
                    const hrefElement = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
                    const downloadElement = document.createElement('a');
                    downloadElement.href = hrefElement;
                    downloadElement.target = '_self';
                    downloadElement.download =  this.euReportHeading.replace('For ', '')+' Report';
                    document.body.appendChild(downloadElement);
                    downloadElement.click();
                    document.body.removeChild(downloadElement); 
                    this.isLoadingEU=false;
                    }
            })
            .catch(error => {
                this.error = error;
                this.isLoadingEU = false;
                window.console.log('Error'+JSON.stringify(this.error));
            });
            
        }
    }   

    generateReportDataEU(result,doc){
        for(const key in result){
            if (result.hasOwnProperty(key)) {            
            const lineItem = result[key].orderLineItemList;
            doc=this.generateReportDataEuHtmlGenarator(result,key,lineItem,doc); 
            }
        }
        return doc;
    }

    generateReportDataEuHtmlGenarator(result,key,lineItem,doc){
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
            doc += this.handleHtmlNullCheck(lineItem[item].GSAP_Goods_Issue_Value__c);
            doc += this.handleHtmlNullCheck(lineItem[item].GSAP_Goods_Issue_Unit__c);
            doc += this.handleHtmlNullCheckUnit(lineItem[item].GSAP_Goods_Issue_Unit__c,lineItem[item].GSAP_Goods_Issue_Value__c);
            doc += this.handleHtmlNullTextCheck(lineItem[item].GSAP_Goods_Issue_Status__c);
            doc += this.handleHtmlNullCheck(result[key].modeOfTransport);
            doc += this.handleHtmlNullDCheck(lineItem[item].GSAP_Dispatch_Date__c);
            doc += this.handleHtmlNullCheck(result[key].deliveryTerms);
            doc += this.handleHtmlNullTextCheck(result[key].otherInstructions);
            doc += this.handleHtmlNullTextCheck(lineItem[item].Other_Instruction__c);
            doc += this.handleHtmlNullTextCheck(result[key].orderedBy);
            doc += this.handleHtmlNullDCheck(result[key].orderedDate);
            doc += this.handleHtmlNullTextCheck(lineItem[item].GSAP_Bol_Delivery__c);
            doc += this.handleHtmlNullTextCheck(lineItem[item].GSAP_Mode_of_Transport_ID__c);
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
            return '<td></td>';
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

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const data = this.orderDetailsMap.get(row.WebOrderNo);
        switch (actionName) {
            case 'modify_order':
                this.wrapList = [];  
                    if(this.isFilterActive || this.isSearchActive){  
                        this.wrapList[0] = this.orderWrapper;
                        this.wrapList[1] = this.orderLineWrapper;
                        this.wrapList[2] = this.euselectedtile;
                        if(this.isSearchActive){
                            this.wrapList[3] = this.searchTerm ? this.searchTerm : '';
                        }
                    }
                this.navigateToModifyOrder(data,this.euselectedtile, this.wrapList, 'Modify Order Action');
                break;
            case 're_order':
                    this.wrapList = [];  
                    if(this.isFilterActive || this.isSearchActive){  
                        this.wrapList[0] = this.orderWrapper;
                        this.wrapList[1] = this.orderLineWrapper;
                        this.wrapList[2] = this.euselectedtile;
                        if(this.isSearchActive){
                            this.wrapList[3] = this.searchTerm ? this.searchTerm : '';
                        }
                    }
                this.navigateToReOrder(data,this.euselectedtile, this.wrapList);
                break;
            case 'view_order_details':
                    this.wrapList = [];  
                    if(this.isFilterActive || this.isSearchActive){  
                        this.wrapList[0] = this.orderWrapper;
                        this.wrapList[1] = this.orderLineWrapper;
                        this.wrapList[2] = this.euselectedtile;
                        if(this.isSearchActive){
                            this.wrapList[3] = this.searchTerm ? this.searchTerm : '';
                        }
                    }
                this.navigateToViewOrderDetail(data,this.euselectedtile, this.wrapList);
                break;
            case 'download_order_details':
                this.handleDownloadPDFEU(row.WebOrderNo);
                break;    
            default:
        }
    }

    navigateToViewOrderDetail(data,type,filterdata){
        this.dispatchEvent(new CustomEvent('vieworderdetail',{detail : {"data":data, "type":type, "filterdata": filterdata}}));
    }  

    navigateToModifyOrder(data,type,filterdata,ordertype){
        this.dispatchEvent(new CustomEvent('modifyorder',{detail : {"data":data, "type":type, "filterdata": filterdata, "ordertype": ordertype}}));
    }

    navigateToReOrder(data,type,filterdata){
        this.dispatchEvent(new CustomEvent('reorder',{detail : {"data":data, "type":type, "filterdata": filterdata}}));
    }

    filterClick(){
        this.filterSection = true;
        this.isStatusActive = true;
       // this.isProductActive = true;
        this.populateFilterPickListData();
    }

    placeOrderClick(){
        this.wrapList = [];  
        if(this.isFilterActive || this.isSearchActive){  
            this.wrapList[0] = this.orderWrapper;
            this.wrapList[1] = this.orderLineWrapper;
            this.wrapList[2] = this.euselectedtile;
            if(this.isSearchActive){
                this.wrapList[3] = this.searchTerm ? this.searchTerm : '';
            }
        }
        this.dispatchEvent(new CustomEvent('ohplaceorder',{detail : {"type":this.euselectedtile, "filterdata": this.wrapList}}));
    }

   closefilterClick(){

    this.filterSection = false;

   }

   @track filterStatusValueEU;
   @track filterStatusOptionsEU = [

       {label: 'Approved', value: 'Approved'},
       {label: 'Rejected', value: 'Rejected'},
       {label: 'Submitted', value: 'Submitted'}, 
       {label: 'Cancelled', value: 'Cancelled'}, 
       {label: 'Delivered', value: 'Delivered'}, 
       {label: 'In Draft', value: 'In Draft'}, 
   ]

   @track filterStatusAllValuesEU = [];

   handelChange(event){
       if(!this.filterStatusAllValuesEU.includes(event.target.value)){
           this.filterStatusAllValuesEU.push(event.target.value);
       }
        
   }

   handelremove(event){
      const valueRemoved = event.target.name;
      this.filterStatusAllValuesEU.splice(this.filterStatusAllValuesEU.indexOf(valueRemoved), 1);

   }

      get DateTypeOptions() {
       return [
           { label: 'None', value: 'None' },
           { label: 'Delivery Date', value: 'DeliveryDate' },
           { label: 'Dispatch Date', value: 'DispatchDate' },
       ];
   }

populateFilterPickListData(){

    getPickListValues({objectApiName: this.orderApiName, fieldApiName: this.modeofTransportApiName})
    .then(result=>{
        this.modeOfTransOptions.splice(0,this.modeOfTransOptions.length);
        for(let i=0; i<result.length; i++){
            const option = {
                label : result[i],
                value : result[i]
            };
            this.modeOfTransOptions = [...this.modeOfTransOptions,option];
        }
    })
    .catch(error => {
        this.error = error;
        window.console.log('Error in getting Mode of transport====>'+JSON.stringify(this.error));
    });

    getPickListValues({objectApiName: this.orderApiName, fieldApiName: this.deliveryTermApiName})
        .then(result=>{
            this.delTermsOptions.splice(0,this.delTermsOptions.length);
            for(let i=0; i<result.length; i++){
                const option = {
                    label : result[i],
                    value : result[i]
                };
                this.delTermsOptions = [...this.delTermsOptions,option];
            }
        })
        .catch(error => {
            this.error = error;
            window.console.log('Error in getting Delivery terms====>'+JSON.stringify(this.error));
        });

    
    getAllProductDetailsBySoldToId({soldToId: this.soldtoid})
        .then(result=>{
            this.prodListOptions.splice(0,this.prodListOptions.length);
            for(let i=0; i<result.length; i++){
                const option = {
                    label : result[i].Product__r.Name+'-'+result[i].Product__r.ProductCode,
                    value : result[i].Product__r.Id,
                    selected:false
                };
                this.prodListOptions = [...this.prodListOptions,option];
                window.console.log('Checking in All Order EU '+this.prodListOptions);
                this.productMap.set(result[i].Product__r.Id,result[i].Product__r.Name); 
                this.productNameCodeMap.set(result[i].Product__r.Id,result[i].Product__r.Name+'-'+result[i].Product__r.ProductCode);
           window.console.log('Checking the code map ',JSON.stringify(this.productNameCodeMap));
            }
            this.isProductActive = true;
        })
        .catch(error => {
            this.error = error;
            window.console.log('Error in getting products====>'+JSON.stringify(this.error));
        });

    getCustomerBySoldToAndType({parentAccId: this.soldtoid, type: 'Ship To'})
    .then(result=>{
        if(result){
            this.deliveryToOptions.splice(0,this.deliveryToOptions.length);
            for(let i=0; i<result.length; i++){ 
                const accName = result[i].Name;
                const cityName = result[i].ShippingAddress.city;
                const shipToAddr = result[i].Name + ', ' + result[i].ShippingAddress.street + ', ' + result[i].ShippingAddress.city + ', ' + result[i].ShippingAddress.state + ', ' + result[i].ShippingAddress.postalCode + ', ' + result[i].ShippingAddress.country;
                
                const option = {
                    label : shipToAddr,
                    value : result[i].Id
                };
                this.deliveryToOptions = [...this.deliveryToOptions, option];
                this.deliveryToMap.set(result[i].Id,accName + ', '+cityName);
            }
        }
    })
    .catch(error => {
        this.error = error;
        window.console.log('Error in getting Delivery To details====>'+JSON.stringify(this.error));
    });

    getOrderedBySoldToId({soldToId: this.soldtoid})
        .then(result=>{
            this.orderedByOptions.splice(0,this.orderedByOptions.length);
            for(let i=0; i<result.length; i++){
                const option = {
                    label : result[i].Ordered_By__r.Name,
                    value : result[i].Ordered_By__c
                };
                this.orderedByOptions = [...this.orderedByOptions,option];
                this.orderedByMap.set(result[i].Ordered_By__c,result[i].Ordered_By__r.Name); 
            }
        })
        .catch(error => {
            this.error = error;
            window.console.log('Error in getting ordered by details====>'+JSON.stringify(this.error));
        });

   }



    get modeOfTransportOptions(){
        return this.modeOfTransOptions;
    }

    get ProductOptions(){
        return this.prodListOptions;
    }

    get deliveryOptions(){
        return this.deliveryToOptions;
    }

    get DeliveryTermsOptions(){
        return this.delTermsOptions;
    }

    get ordByOptions(){
        return this.orderedByOptions;
    }

    handleFilterChange(event){
        const enteredValue = event.target.value;
        if(event.target.dataset.id === 'customerPo'){
            this.customerPo = enteredValue;
        }else if(event.target.dataset.id === 'toDate'){
            this.toDate = enteredValue;
        }else if(event.target.dataset.id === 'fromDate'){
            this.fromDate = enteredValue;
        }
    }

    handleMoT(event){
        this.modeOfTransValue = event.detail.value;
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
        if(this.dateTypeValue == 'None'){
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

    clearAllFilterValues(event){
            
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

        if(this.orderStatus && this.orderStatus.length >0){
            this.template.querySelector('c-tcp_multi-select').clearStatusPills();
        }
        this.orderStatus = '';
        if(this.selectedProduct && this.selectedProduct.length>0)
          {
            this.template.querySelector('c-tcp_-product-multi-select').clearStatusPills();
            }       
            this.selectedProduct='';
            this.selectedProductId='';
    }

    handleApplyButton(event){
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
            this.orderWrapper.soldToId = this.soldtoid;
            if(this.customerPo && this.customerPo.length >0){
                this.isFilterActive = true;
                this.clearFilterData = false;
                this.orderWrapper.poNumber = this.customerPo;
                const filterObj = [];
                filterObj.name = 'Customer PO';
                filterObj.value = this.customerPo;
                this.activeFilters = [...this.activeFilters,filterObj];
            }
            if(this.selectedDeliveryTo && this.selectedDeliveryTo.length >0){
                this.isFilterActive = true;
                this.clearFilterData = false;
                this.orderWrapper.shipToId = this.selectedDeliveryTo;
                const filterObj = [];
                filterObj.name = 'Delivery To';
                filterObj.value = this.deliveryToMap.get(this.selectedDeliveryTo);
                this.activeFilters = [...this.activeFilters,filterObj];
            }
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
                switch (this.euselectedtile) {
                    case 'Rejected/Cancelled Orders':
                        this.defaultStatusOnApply = this.defaultRejCanStatus;
                        break;
                    case 'My CurrentOrders':
                        this.defaultStatusOnApply = this.defaultCurrentStatus;
                        break;
                    
                    default:
                }
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
            if(this.fulfillByValue && this.fulfillByValue.length >0){
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
            if(this.ordPriorityValue && this.ordPriorityValue.length >0){
                this.isFilterActive = true;
                this.clearFilterData = false;
                this.orderWrapper.orderPriority = this.ordPriorityValue;
                const filterObj = [];
                filterObj.name = 'Ordered Priority';
                filterObj.value = this.ordPriorityValue;
                this.activeFilters = [...this.activeFilters,filterObj];
            }
            if(this.dateTypeValue && this.dateTypeValue.length >0 && this.dateTypeValue != 'None'){
                this.isFilterActive = true;
                this.clearFilterData = false;
                this.orderLineWrapper.dateType = this.dateTypeValue;
                this.orderLineWrapper.fromDate = this.fromDate ? this.fromDate : null;
                this.orderLineWrapper.toDate = this.toDate ? this.toDate : null;
                const filterObj = [];
                filterObj.name = this.dateTypeValue;
                filterObj.value = this.fromDate + ' To ' + this.toDate;
                this.activeFilters = [...this.activeFilters,filterObj];
            }
            if(this.selectedProductId && this.selectedProductId.length >0){
                this.prodNameList=[];
                this.isFilterActive = true;
                this.clearFilterData = false;
                this.orderLineWrapper.productId = this.selectedProductId;
                this.orderLineWrapper.materialName=this.selectedProduct;
                const filterObj = [];
                const splitProd=[];
                splitProd.name=this.selectedProductId.split(';');
              
                for(let i=0; i<splitProd.name.length;i++){
                
                    const prodName=this.productNameCodeMap.get(splitProd.name[i]);
                  
                    this.prodNameList = [...this.prodNameList,prodName];
                    this.prodNameList=[...new Set(this.prodNameList)];
                }
              
                filterObj.name = 'Product';
                filterObj.value = this.prodNameList;
                this.activeFilters = [...this.activeFilters,filterObj];
                
               
            }

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
                this.dataTableHeight ='height: 450px;';
                this.orderList = this.initialRecords;
            }

        }else if(this.doInputValidation('.errorMsg') && this.isFilterActive){
            this.getFilterDataFromApex();
        }
    }

    getFilterDataFromApex(){
      
        this.isLoadingEU=true;
        getOrderDetailsByFilter({ordWrap : this.orderWrapper, ordLineWrap : this.orderLineWrapper, defaultStatus : this.defaultStatusOnApply, userType: this.userType, selectedTile: this.euselectedtile})
        .then(result=>{
           
            if(result && result.length>0){
                this.noDataFound = false;
                this.dataTableHeight ='height: 450px;';
                this.orderList = [];
                this.filteredOrdersList = [];
                    for(let key in result){    
                        const dataList = [];
                        dataList.WebOrderNo = result[key].orderNumber;
                        dataList.CustomerPO = result[key].poNumber;
                        dataList.OrderName = result[key].name ? result[key].name: '';
                        dataList.DeliveryTo = result[key].shipToName;
                        const lineItem = result[key].orderLineItemList;
                        let product='';
                        for(let item in lineItem){
                            if(!product.includes(lineItem[item].Material_Name__c)){
                                product += lineItem[item].Material_Name__c + ', '
                            }
                        }
                        dataList.Product = product;
                        dataList.Status = result[key].status;
                        if(dataList.Status)
                        {   
                            if(dataList.Status=='Approved (M)')
                            {
                                const statusData = dataList.Status;
                                const statSplit = statusData.split(' ');
                                dataList.statusColor ='colorApprovedM';
                                dataList.Status = 'M'+statSplit[0];
                            }else if(dataList.Status=='Approved (C)'){
                                const statusData = dataList.Status;
                                const statSplit = statusData.split(' ');
                                dataList.statusColor ='colorApprovedC';
                                dataList.Status = 'C'+statSplit[0];
                            }else{
                            dataList.statusColor ='color'+dataList.Status;
                            }
                        }
                        if(this.isSearchActive){
                            for(let i=0; i<this.filteredOrdersList2.length; i++){
                                if(dataList.WebOrderNo == this.filteredOrdersList2[i].WebOrderNo){
                                    const tempList = this.filteredOrdersList2[i];
                                    this.orderList = [...this.orderList,tempList];
                                }
                            }
                        }else{
                            this.orderList = [...this.orderList,dataList];
                            
                        }
                        this.filteredOrdersList = [...this.filteredOrdersList, dataList];
                        
                    }
                    if(this.orderList.length==0){
                        this.dataTableHeight = 'height: 50px;'
                        this.noDataFound = true;
                    }
                    if(this.isSearchDataActive && this.euselectedtile == this.filteredData[2]){
                        this.getSearchDataFromApex();
                        this.isSearchDataActive = false;
                    }
                    this.isLoadingEU=false;
            }else{
                this.dataTableHeight = 'height: 50px;'
                this.noDataFound = true;
                this.isLoadingEU=false;
                this.orderList = [];
            }
        })
        .catch(error=>{
            this.error = error;
            this.isLoadingEU=false;
            window.console.log('Error in getting filter data====>'+JSON.stringify(this.error));
        });
    }

    getSearchDataFromApex(){
        this.defaultStatusOnSearch ='';
        switch (this.euselectedtile) {
            case 'Rejected/Cancelled Orders':
                this.defaultStatusOnSearch = this.defaultRejCanStatus;
                break;
            case 'My CurrentOrders':
                this.defaultStatusOnSearch = this.defaultCurrentStatus;
                break;
            
            default:
        }
        this.isLoadingEU = true;
        let soldToIds = [];
        soldToIds = [...soldToIds,this.soldtoid];
        getOrderDetailsBySearchKey({soldToId: this.soldtoid, searchKey: this.searchTerm.toLowerCase(), defaultStatus: this.defaultStatusOnSearch, userType: this.userType, selectedTile: this.euselectedtile})
        .then(result=>{
            if(result && result.length>0){
                this.isSearchActive = true;
                this.noDataFound = false;
                this.dataTableHeight ='height: 450px;';
                this.orderList = [];
                this.filteredOrdersList2 = [];
                    for(let key in result){    
                        const dataList = [];
                        dataList.WebOrderNo = result[key].orderNumber;
                        dataList.CustomerPO = result[key].poNumber;
                        dataList.OrderName = result[key].name ? result[key].name: '';
                        dataList.DeliveryTo = result[key].shipToName;
                        const lineItem = result[key].orderLineItemList;
                        let product='';
                        for(let item in lineItem){
                            if(!product.includes(lineItem[item].Material_Name__c)){
                                product += lineItem[item].Material_Name__c + ', '
                            }
                        }
                        dataList.Product = product;
                        dataList.Status = result[key].status;
                        if(dataList.Status)
                        {   
                            if(dataList.Status=='Approved (M)')
                            {
                                const statusData = dataList.Status;
                                const statSplit = statusData.split(' ');
                                dataList.statusColor ='colorApprovedM';
                                dataList.Status = 'M'+statSplit[0];
                            }else if(dataList.Status=='Approved (C)'){
                                const statusData = dataList.Status;
                                const statSplit = statusData.split(' ');
                                dataList.statusColor ='colorApprovedC';
                                dataList.Status = 'C'+statSplit[0];
                            }else{
                            dataList.statusColor ='color'+dataList.Status;
                            }
                        }
                        if(this.isFilterActive){
                            for(let i=0; i<this.filteredOrdersList.length; i++){
                                if(dataList.WebOrderNo == this.filteredOrdersList[i].WebOrderNo){
                                    const tempList = this.filteredOrdersList[i];
                                    this.orderList = [...this.orderList,tempList];
                                }
                            }
                        }else{
                            this.orderList = [...this.orderList,dataList];
                        }
                        this.filteredOrdersList2 = [...this.filteredOrdersList2, dataList];
                        
                    }
                    this.isLoadingEU = false;
            }else{
                this.dataTableHeight = 'height: 50px;'
                this.noDataFound = true;
                this.isLoadingEU = false;
                this.orderList = [];
            }

        })
        .catch(error=>{
            this.isSearchActive = false;
            this.error = error;
            this.isLoadingEU = false;
            window.console.log('Error in getting Search data====>'+JSON.stringify(this.error));
        });
    }


    doInputValidation(screenName){
        const isInputsCorrect = [...this.template.querySelectorAll(screenName)]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        return isInputsCorrect;
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
        if(this.orderLineWrapper.dateType && this.orderLineWrapper.dateType.length >0 && this.orderLineWrapper.dateType != 'None'){
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

    handleSearchClick(event){
        if(this.searchTerm && this.searchTerm.length>2){
            this.getSearchDataFromApex();
            this.scrollToTopOfPage();
        }else{
            this.isShowModal = true;
        }
    }
  
    handleProdFocus(event){
        this.template.querySelector('c-tcp_multi-select').closeMultiSelect();
        this.template.querySelector('c-tcp_-product-multi-select').closeMultiSelect();

    }



    handleSearchCancel(){
        this.searchTerm = '';
        this.issearchText = false;
        this.isSearchActive = false;
        if(this.isFilterActive && this.filteredOrdersList.length>0){
            if(this.noDataFound){
                this.noDataFound = false;
            }
            this.dataTableHeight ='height: 450px;';
            this.orderList = this.filteredOrdersList;   
        }
        else if(this.initialRecords && this.initialRecords.length>0){
            if(this.noDataFound){
                this.noDataFound = false;
            }
            this.dataTableHeight ='height: 450px;';
            this.orderList = this.initialRecords;
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
        this.activeFilters=[];
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
            this.dataTableHeight ='height: 450px;';
            this.orderList = this.initialRecords;
        }
    }

    clearStatusData(){
        if(this.orderStatus.length==0){
            this.template.querySelector('c-tcp_multi-select').clearStatusPills();
        }
    }

    scrollToTopOfPage(){
        this.isLoadingCU = true;
        this.dataTableHeight = 'height: auto;'
    }


}