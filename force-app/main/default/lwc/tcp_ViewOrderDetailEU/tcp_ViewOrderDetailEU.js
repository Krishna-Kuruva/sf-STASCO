import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getOrderId from '@salesforce/apex/TCP_ChangeCancelOrderController.getOrderId';

export default class Tcp_ViewOrderDetailEU extends NavigationMixin (LightningElement) {
    @wire(CurrentPageReference)
    currentPageReference;
    @track ViewOrderDetailEU = true;
    @track chevronrightShow = true;
    

    value = '';
    error;
    @api orderdetaildata;
    @api soldtoid;
    @api type;
    @api eufilterdata;
    @api iswebemail;
    @track orderDetailList;
    @track orderLineItemsList =[];
    @track orderIdsList=[];
    @track decision;
    @track orderParty;
    @track orderPriority = [];
    @track orderWrapper = {};
    @track remarks;
    @track isDisableParty = true;
    @track enableSubmit=false; 
    @track accountId;
    @track isShowModal; 
    @track isLoading;
    @track tableType;
    @track tableClassName = 'slds-table--header-fixed_container';
    @track sendFilterData;
    @track isShowModalCancellationOrderRequest = false;
    @track isShowModalCancelOrder = false;
    @track isShowModalCancelOrderWhenSubmitted = false;
    @track orderName;
    @track customerPo;
    @track orderNumber;
    @track orderId;
    @track soldToNumber;
    @track shipToNumber;
    @track billToNumber;
    @track orderStatus;
    @track isShowModifyButton=true;
    @track isShowCancelButton=true;
    @track backToDashboard=true;
    @track docSalesOrdNum;
    @track docBolDelivery;
    @track showDetails=true;
    @track viewAllAction=true;
    @track isDraftOrder=false;
    @track ordLineItemList = [];

    connectedCallback(){
       
        
        if(this.iswebemail === "yes"){
            
            this.orderDetailList = this.orderdetaildata;
            this.orderLineItemsList = this.orderDetailList.orderLineItemList;
            
            if(this.orderDetailList.status==='Cancelled'||this.orderDetailList.status==='Rejected' ||this.orderDetailList.status==='Draft' || this.orderDetailList.status==='Shipped' ){
                this.isShowModifyButton=false;
            }
            if(this.orderDetailList.status==='Approved (C)'||this.orderDetailList.status==='Cancelled'||this.orderDetailList.status==='Rejected' ||this.orderDetailList.status==='Draft' || this.orderDetailList.status==='Shipped' ){
                this.isShowCancelButton=false;
            }
        }
        else{
            this.sendFilterData = this.eufilterdata;
            
            this.accountId = this.soldtoid;
            this.orderDetailList = this.orderdetaildata;
            this.orderLineItemsList = this.orderDetailList.orderLineItemList;
            this.tableType = this.type;
            if(this.tableType==='Order History'){
                this.backToDashboard=false;
            }
            if(this.orderLineItemsList.length > 6){
                this.tableClassName += ' tableHeight';
            }
            
            if(this.orderDetailList.status==='Cancelled'||this.orderDetailList.status==='Rejected' ||this.orderDetailList.status==='Draft' ||this.orderDetailList.status==='Shipped' ){
                this.isShowModifyButton=false;
            }
            if(this.orderDetailList.status==='Approved (C)'||this.orderDetailList.status==='Cancelled'||this.orderDetailList.status==='Rejected' ||this.orderDetailList.status==='Draft' ||this.orderDetailList.status==='Shipped' ){
                this.isShowCancelButton=false;
            }
        }
        this.addSerailNumberToList(this.orderLineItemsList);
        
        if(this.orderDetailList.fullfilledBy==='Third Party'){
            this.viewAllAction = false;
        }
        //check if order is approved and disable or enable relavent variables
        if(this.orderDetailList.status && this.orderDetailList.status !== 'Approved'  && this.orderDetailList.status !== 'Approved (M)'  && this.orderDetailList.status !== 'Approved (C)' && this.orderDetailList.status !== 'Shipped'){
            this.viewAllAction = false;
            this.chevronrightShow = false;
        }
        if(this.orderDetailList.status && this.orderDetailList.status === 'Draft'){
            this.isDraftOrder=true;
        }
        
    }

    get options() {
        return [
            { label: 'Approve Modification', value: 'approve_Modification' },
            { label: 'Reject Modification', value: 'reject_modification' },
        ];
    }

    value = [''];

    get options2() {
        return [
            { label: 'Rush Order', value: 'option1' },
            { label: 'Late Order', value: 'option2' },
            { label: 'Laste Minute Chnages', value: 'option3' },



        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }
    handleBack(){
      
        this.navigateToHomePage('back',this.tableType, this.sendFilterData);
    }
    handleHome(){
        
        const data = this.orderDetailList.orderNumber;
        const status=this.orderDetailList.status;
        
        this.navigateToHomePageCancel(data,status,this.tableType, this.sendFilterData);
    }
    handleModifyOrder(){
        const data = this.orderdetaildata;
        this.sendFilterData = this.eufilterdata;
        this.navigateToViewOrderDetail(data,'Modify Order',this.sendFilterData);
    }
    navigateToViewOrderDetail(data,type,filterdata){
        
        this.dispatchEvent(new CustomEvent('vieworderdetail',{detail : {"data":data,"type":type,"filterdata": filterdata}}));
    }
    handleViewAllDocument(event){
        this.docBolDelivery= event.currentTarget.dataset.name;
        this.docSalesOrdNum=this.orderDetailList.salesordernumber;
        this.showDetails=false;
    }
    handleViewAllDocumentsBack(){
        this.showDetails=true;
    }

    navigateToHomePage(data,type, filterdata){
        
        this.dispatchEvent(new CustomEvent('backbutton',{detail : {"status":data, "type":type, "filtereudata": filterdata}}));
    }
    navigateToHomePageCancel(data,status,type, filterdata){
        
        this.dispatchEvent(new CustomEvent('cancelback',{detail : {"data":data,"status":status, "type":type, "filtereudata": filterdata}}));
    }
   
    showCollapseRow(event) {
        const dataId = event.currentTarget.dataset.id;
        let target = this.template.querySelector('[data-id="'+dataId+'"]');
        if( target && target != null){
            if(target.classList.contains('iconRotate')){
                target.classList.remove('iconRotate');
                const className = '.'+dataId;
                let row = this.template.querySelector(className);
                if(row && row != null){
                    row.classList.remove('showRow');
                }
            }else{
                target.classList.add('iconRotate');
                const className = '.'+dataId;
                let row = this.template.querySelector(className);
                if(row && row != null){
                    row.classList.add('showRow');
                }
            }
        }
        
    };
   
    showModalCancelOrder () {  
        if(this.orderDetailList.status==='Submitted'){
            
            this.isShowModalCancelOrderWhenSubmitted = true;
            this.isShowModalCancelOrder = false;
        }
        else if(this.orderDetailList.status==='Approved' || this.orderDetailList.status==='Approved (M)'){
            this.isShowModalCancelOrderWhenSubmitted = false;
            this.isShowModalCancelOrder = true;
        }
        
    }


    hideModalCancelOrder () {  
        this.isShowModalCancelOrderWhenSubmitted = false;
    }
    
    hideModalCancellationOrderRequest(){
        this.isShowModalCancelOrder=false;
    }

    handleSubmit(){
        this.prepareSelectedOrder();
        this.saveOrderDetails();
        this.isLoading=true
        
        getOrderId({orderData: this.orderWrapper})
        .then(result=>{
                
                this.isShowModalCancelOrderWhenSubmitted = false;
                this.isShowModalCancelOrder = false;
                this.handleHome();
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in getting Order Number====>'+JSON.stringify(this.error));
        });
        
    }
    prepareSelectedOrder(){
        this.orderName=this.orderDetailList.name;
        this.orderStatus=this.orderDetailList.status;
        this.orderNumber=this.orderDetailList.orderNumber;
    }
    saveOrderDetails(){
    
        if(this.orderName && this.orderName.length>0){
            this.orderWrapper.name = this.orderName;
        }
        if(this.orderNumber && this.orderNumber.length>0){
            this.orderWrapper.orderNumber = this.orderNumber;
        }

        if(this.orderStatus && this.orderStatus.length>0){
            this.orderWrapper.status = this.orderStatus;
        }
        
    }
    //check if URL contains webordernumber and redirect
    checkForWOnumber(){
        var wonumber =  this.currentPageReference.state.c__wonumber;
        
        if(wonumber){
            
            this.dispatchEvent(new CustomEvent('backbutton',{detail : {"status":"back"}}));

        }
        else{
            this.navigateToHomePage('back',this.tableType, this.sendFilterData);
        }
    }

    addSerailNumberToList(ordLineList){
        let tempOrdLineList = [];
        for(let i=0; i<ordLineList.length;i++){
            const tempList = [];
            let serialNum = i+1;
            serialNum = serialNum + '';
            tempList.sno = serialNum.padStart(2,'0');
            tempList.Id = ordLineList[i].Id ? ordLineList[i].Id : '';
            tempList.Material_Name__c = ordLineList[i].Material_Name__c ? ordLineList[i].Material_Name__c : '';
            tempList.MaterialNumber__c=ordLineList[i].MaterialNumber__c ? ordLineList[i].MaterialNumber__c : '';
            tempList.Quantity__c = ordLineList[i].Quantity__c ? ordLineList[i].Quantity__c : '';
            tempList.Unit__c = ordLineList[i].Unit__c ? ordLineList[i].Unit__c : '';
            tempList.Delivery_Collection_Date__c = ordLineList[i].Delivery_Collection_Date__c ? ordLineList[i].Delivery_Collection_Date__c : '';
            tempList.Contract_No__c = ordLineList[i].Contract_No__c ? ordLineList[i].Contract_No__c : '';
            tempList.Other_Instruction__c = ordLineList[i].Other_Instruction__c ? ordLineList[i].Other_Instruction__c : '';
            tempList.GSAP_Due_Date__c = ordLineList[i].GSAP_Due_Date__c ? ordLineList[i].GSAP_Due_Date__c : '';
            tempList.GSAP_Dispatch_Date__c = ordLineList[i].GSAP_Dispatch_Date__c ? ordLineList[i].GSAP_Dispatch_Date__c : '';
            tempList.GSAP_Bol_Delivery__c = ordLineList[i].GSAP_Bol_Delivery__c ? ordLineList[i].GSAP_Bol_Delivery__c : '';
            tempList.GSAP_Mode_of_Transport_ID__c = ordLineList[i].GSAP_Mode_of_Transport_ID__c ? ordLineList[i].GSAP_Mode_of_Transport_ID__c : '';
            tempList.GSAP_Goods_Issue_Value__c = ordLineList[i].GSAP_Goods_Issue_Value__c ? ordLineList[i].GSAP_Goods_Issue_Value__c : '';
            tempList.GSAP_Goods_Issue_Date__c = ordLineList[i].GSAP_Goods_Issue_Date__c ? ordLineList[i].GSAP_Goods_Issue_Date__c : '';
            tempList.GSAP_Goods_Issue_Unit__c = ordLineList[i].GSAP_Goods_Issue_Unit__c ? ordLineList[i].GSAP_Goods_Issue_Unit__c : '';
            tempList.GSAP_Goods_Issue_Status__c = ordLineList[i].GSAP_Goods_Issue_Status__c ? ordLineList[i].GSAP_Goods_Issue_Status__c : '';
            
            tempOrdLineList = [...tempOrdLineList, tempList];
        }
        if(tempOrdLineList.length>0){
            this.ordLineItemList = tempOrdLineList;
        }
    }
    
    renderedCallback(){

        document.title = 'TCP | Order Details';
    }
   

}