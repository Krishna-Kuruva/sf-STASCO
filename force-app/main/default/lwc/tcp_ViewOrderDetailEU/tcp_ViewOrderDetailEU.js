import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getOrderId from '@salesforce/apex/TCP_ChangeCancelOrderController.getOrderId';
import getOrderDetailsByWONumber from '@salesforce/apex/TCP_OrderController.getOrderDetailsByWONumber';
import fetchDeliveryNotedetails from '@salesforce/apex/TCP_OrderController.fetchDeliveryNotedetails';

const statusData = new Map([
    ['CN', { customClass: 'cn-line-item', expStatus: 'Line Item Cancelled'}],
    ['RC', { customClass: 'rc-line-item', expStatus: 'Requested for Cancellation'}],
    ['NIL', { customClass: 'slds-hint-parent', expStatus: ''}]
  ]);

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
    @track orderItemsList =[];
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
    @track isViewEULoading;
    @track tableType;
    @track tableClassName = 'slds-table--header-fixed_container';
    @track sendFilterData;
    @track isShowModalCancellationOrderRequest = false;
    @track isShowModalCancelOrder = false;
    @track isShowModalCancelOrderWhenSubmitted = false;
    @track isShowModalDnCreated = false;
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
    @track docRedirectDelivery;
    @track showDetails=true;
    @track viewAllAction=true;
    @track isDraftOrder=false;
    @track ordLineItemList = [];
    @track dnMessage='';
    @track rcMessage='';
    @track cnMessage='';
    @track isShowReturnOrderModal=false;
    @track lineitemId;
    @track returnLineItem = [];
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
        window.console.log('Checking OrderLine Iteam List'+this.orderLineItemsList);
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
        
        window.console.log(JSON.stringify(this.orderLineItemsList));
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
        //var data = this.orderdetaildata;
        this.dnMessage='';
        this.rcMessage='';
        this.cnMessage='';
        this.isViewEULoading=true;
        this.sendFilterData = this.eufilterdata;
        //call apex method
         fetchDeliveryNotedetails({soldToId : this.accountId,asyncRequest: false})
         .then(result=>{
            window.console.log('result'+JSON.stringify(result));
            if(result==='Success'){
            this.getOrderwithWebOrderNumber(this.orderdetaildata.orderNumber);
            }
         })
         .catch(error => {
            this.isViewEULoading = false;
             this.error = error;
             window.console.log('error in DN'+JSON.stringify(this.error));
         });
    }

    getOrderwithWebOrderNumber(webordnumber){
        //call apex method
        getOrderDetailsByWONumber({woNumber : webordnumber})
         .then(result=>{
             var recordData = result;
             window.console.log('recordData[0]'+recordData[0]);
             if(result){
                let editAllowed=false; 
                this.orderDetailData = recordData[0];
                const updOliList=this.orderDetailData.orderLineItemList;
                for(let i=0; i<updOliList.length;i++){
                    let j=i+1;
                    if((!updOliList[i].GSAP_Bol_Delivery__c)&&(updOliList[i].TCP_Modify_Cancel_Status__c!=='Cancelled')&&(updOliList[i].TCP_Modify_Cancel_Status__c!=='Cancellation')){
                        editAllowed=true; 
                    }else if(updOliList[i].GSAP_Bol_Delivery__c){
                        this.dnMessage=this.getNotifyText(this.dnMessage,j);
                    }else if(updOliList[i].TCP_Modify_Cancel_Status__c==='Cancelled'){
                        this.cnMessage=this.getNotifyText(this.cnMessage,j);
                    }else if(updOliList[i].TCP_Modify_Cancel_Status__c==='Cancellation'){
                        this.rcMessage=this.getNotifyText(this.rcMessage,j);
                    }
                }
                if(editAllowed){
                window.console.log('inside edit allowed');
                this.navigateToViewOrderDetail(this.orderDetailData,'Modify Order',this.sendFilterData);
                }else{
                    window.console.log('inside isShowModalDnCreated');
                    this.isShowModalDnCreated=true;
                }
                this.isViewEULoading = false;
             }
         })
         .catch(error => {
            this.isViewEULoading = false;
             this.error = error;
             window.console.log('error in web order details'+JSON.stringify(this.error));
         });
    }

    getNotifyText(prev,add){
        if(prev){
            return `${prev}, ${add}`;
        }else{
            return add;
        }
    }


    navigateToViewOrderDetail(data,type,filterdata){
        
        this.dispatchEvent(new CustomEvent('vieworderdetail',{detail : {"data":data,"type":type,"filterdata": filterdata}}));
    }
    handleViewAllDocument(event){
        this.docBolDelivery= event.currentTarget.dataset.name;
        this.docSalesOrdNum=this.orderDetailList.salesordernumber;
        this.docRedirectDelivery=event.currentTarget.dataset.value;
        window.console.log('this.docRedirectDelivery '+this.docRedirectDelivery);
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
        const existClass=event.currentTarget.dataset.name;
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
                    row.classList.add(existClass);
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

    hideModalDnCreated(){
        this.isShowModalDnCreated=false;
    }


    handleSubmit(){
        this.prepareSelectedOrder();
        this.saveOrderDetails();
        this.isViewEULoading=true
        
        getOrderId({orderData: this.orderWrapper})
        .then(result=>{
                
                this.isShowModalCancelOrderWhenSubmitted = false;
                this.isShowModalCancelOrder = false;
                this.handleHome();
        })
        .catch(error => {
            this.isViewEULoading = false;
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
    // check if URL contains webordernumber and redirect
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
            //tempList.Quantity__c = ordLineList[i].Quantity__c ? ordLineList[i].Quantity__c : '';
            tempList.Quantity__c = ordLineList[i].Quantity__c;
            tempList.Unit__c = ordLineList[i].Unit__c ? ordLineList[i].Unit__c : '';
            tempList.Delivery_Collection_Date__c = ordLineList[i].Delivery_Collection_Date__c ? ordLineList[i].Delivery_Collection_Date__c : '';
            tempList.Contract_No__c = ordLineList[i].Contract_No__c ? ordLineList[i].Contract_No__c : '';
            tempList.Other_Instruction__c = ordLineList[i].Other_Instruction__c ? ordLineList[i].Other_Instruction__c : '';
            tempList.GSAP_Due_Date__c = ordLineList[i].GSAP_Due_Date__c ? ordLineList[i].GSAP_Due_Date__c : '';
            tempList.GSAP_Dispatch_Date__c = ordLineList[i].GSAP_Dispatch_Date__c ? ordLineList[i].GSAP_Dispatch_Date__c : '';
            tempList.Expected_Dispatch_Date__c = ordLineList[i].Expected_Dispatch_Date__c ? ordLineList[i].Expected_Dispatch_Date__c : '';
            tempList.GSAP_Bol_Delivery__c = ordLineList[i].GSAP_Bol_Delivery__c ? ordLineList[i].GSAP_Bol_Delivery__c : '';
            tempList.GSAP_Mode_of_Transport_ID__c = ordLineList[i].GSAP_Mode_of_Transport_ID__c ? ordLineList[i].GSAP_Mode_of_Transport_ID__c : '';
            tempList.GSAP_Goods_Issue_Value__c = ordLineList[i].GSAP_Goods_Issue_Value__c ? ordLineList[i].GSAP_Goods_Issue_Value__c.toFixed(3) : '';
            tempList.GSAP_Goods_Issue_Date__c = ordLineList[i].GSAP_Goods_Issue_Date__c ? ordLineList[i].GSAP_Goods_Issue_Date__c : '';
            tempList.GSAP_Goods_Issue_Unit__c = ordLineList[i].GSAP_Goods_Issue_Unit__c ? ordLineList[i].GSAP_Goods_Issue_Unit__c : '';
            tempList.GSAP_Goods_Issue_Status__c = ordLineList[i].GSAP_Goods_Issue_Status__c ? ordLineList[i].GSAP_Goods_Issue_Status__c : '';
            //tempList.TCP_Modify_Cancel_Status__c = ordLineList[i].TCP_Modify_Cancel_Status__c ? ordLineList[i].TCP_Modify_Cancel_Status__c : '';
            tempList.oliStatus=this.handleOliStatus(ordLineList[i].TCP_Modify_Cancel_Status__c,ordLineList[i].Quantity__c);
            tempList.oliStatusAttr=statusData.get(tempList.oliStatus);
            //return redirect fields.
            tempList.Return_order__c = ordLineList[i].Return_order__c ? ordLineList[i].Return_order__c : '';
            tempList.Return_delivery__c = ordLineList[i].Return_delivery__c ? ordLineList[i].Return_delivery__c : '';
            tempList.Return_GI__c = ordLineList[i].Return_GI__c ? ordLineList[i].Return_GI__c : '';
            tempList.New_SO__c = ordLineList[i].New_SO__c ? ordLineList[i].New_SO__c : '';
            tempList.New_dispatch_date__c = ordLineList[i].New_dispatch_date__c ? ordLineList[i].New_dispatch_date__c : '';
            tempList.New_loading_date__c = ordLineList[i].New_loading_date__c ? ordLineList[i].New_loading_date__c : '';
            tempList.New_delivery__c = ordLineList[i].New_delivery__c ? ordLineList[i].New_delivery__c : '';
            tempList.New_Mot_Id__c = ordLineList[i].New_Mot_Id__c ? ordLineList[i].New_Mot_Id__c : '';
            tempList.New_GI_date__c = ordLineList[i].New_GI_date__c ? ordLineList[i].New_GI_date__c : '';
            tempList.New_GI_quantity__c = ordLineList[i].New_GI_quantity__c ? ordLineList[i].New_GI_quantity__c : '';
            tempList.New_GI_status__c = ordLineList[i].New_GI_status__c ? ordLineList[i].New_GI_status__c : '';
            tempList.New_GI_unit__c = ordLineList[i].New_GI_unit__c ? ordLineList[i].New_GI_unit__c : '';
            
            tempOrdLineList = [...tempOrdLineList, tempList];
        }
        if(tempOrdLineList.length>0){
            this.ordLineItemList = tempOrdLineList;
            window.console.log('Checking temp OrderLine Iteam List'+tempOrdLineList);
        }
    }
    
    renderedCallback(){

        document.title = 'TCP | Order Details';
    }

    handleOliStatus(status,quantity){
        if(status==='Cancelled' && quantity===0){
            return 'CN';
        }else if(status==='Cancellation' && quantity===0){
            return 'RC';
        }else{
            return 'NIL';
        }

    }
    handleReturnOrderShowModel(event) {  
    const clickedOLI = event.currentTarget.dataset.id;
       
       for(let i=0; i<this.ordLineItemList.length;i++){
        
            if(this.ordLineItemList[i].Id==clickedOLI){
                console.log('matched');
                this.returnLineItem=this.ordLineItemList[i];
                this.isShowReturnOrderModal = true;
            }
        }
      
    }
    handleReturnOrderCloseModal() {  
        this.isShowReturnOrderModal = false;
    }
   

}