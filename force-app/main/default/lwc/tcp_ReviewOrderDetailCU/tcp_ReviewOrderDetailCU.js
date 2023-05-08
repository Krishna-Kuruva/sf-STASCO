import { LightningElement, api, track } from 'lwc';
import updateOrderReviewDetails from '@salesforce/apex/TCP_OrderController.updateOrderReviewDetails';
import validateMappingReference from '@salesforce/apex/TCP_OrderController.validateMappingReference';
import getOrderOnCommopsApproval from '@salesforce/apex/TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsApproval';
import getOrderOnCommopsRejection from '@salesforce/apex/TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsRejection';
import getOrderOnCommopsCancellationApproval from '@salesforce/apex/TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsCancellationApproval';
import getOrderOnCommopsCancellationRejection from '@salesforce/apex/TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsCancellationRejection';

export default class TcpReviewOrderDetailCU extends LightningElement {

    @track chevronrightShow = true;

    value = '';
    error;
    @api orderdetaildata;
    @api soldtoid;
    @api type;
    @api cufilterdata;
    @track orderDetailList;
    @track orderLineItemsList =[];
    @track decision;
    @track orderParty;
    @track orderPriority = [];
    @track modifyDecision;
    @track modifyOrderPriority = [];
    @track cancelDecision;
    @track orderWrapper = {};
    @track approveModifyCancelWrapper={};
    @track rejectModifyCancelWrapper={};
    @track approveOrderCancellationWrapper={};
    @track rejectOrderCancellationWrapper={};
    @track remarks;
    @track modifyCommopsRemarks;
    @track cancelCommopsRemarks;
    @track isDisableParty = true;
    @track isDisableModifyPriority = true;
    @track enableSubmit=false; 
    @track enableModifySubmit=false; 
    @track enableCancelSubmit=false; 
    @track accountId;
    @track isShowModal; 
    @track isLoading;
    @track remarksCount = 0;
    @track modifyCommopsRemarksCount = 0;
    @track isModifyRemarksFilled=false;
    @track cancelCommopsRemarksCount = 0;
    @track isCancelRemarksFilled=false;
    @track tableType;
    @track tableClassName = 'slds-table--header-fixed_container';
    @track showReviewOptions=false;
    @track showModificationOptions=false;
    @track showCancellationOptions=false;
    @track sendFilterData;
    @track backToDashboard=true;
    @track ordLineItemList = [];
    @track orderId;

    connectedCallback(){
        this.accountId = this.soldtoid;
        this.orderDetailList = this.orderdetaildata;
        this.orderId = this.orderdetaildata.id;
        this.orderLineItemsList = this.orderDetailList.orderLineItemList;
        this.tableType = this.type;
        if(this.tableType=='Order History'){
            this.backToDashboard=false;
        }
        this.sendFilterData = this.cufilterdata;
        this.addSerailNumberToList(this.orderLineItemsList);
        if(this.orderLineItemsList.length > 6){
            
            this.tableClassName += ' tableHeight';
        }
        if(this.orderDetailList.status && this.orderDetailList.status != 'Approved' && this.orderDetailList.status != 'Approved (M)' && this.orderDetailList.status != 'Approved (C)'){

            this.chevronrightShow = false;
        }
        if(this.orderDetailList.status=='Submitted'){
            this.showReviewOptions=true;
        }
        else if(this.orderDetailList.status=='Approved (M)'){
            this.handleModifyOrdervalues();
            this.showModificationOptions=true;
        }
        else if(this.orderDetailList.status=='Approved (C)'){
            this.showCancellationOptions=true;
        }
    }

    get options() {
        return [
            { label: 'Approve Order', value: 'Approved' },
            { label: 'Reject Order', value: 'Rejected' },
        ];
    }

    get modifyOptions() {
        return [
            { label: 'Approve Modification', value: 'Approved Modification' },
            { label: 'Reject Modification', value: 'Rejected Modification' },
        ];
    }

    get cancelOptions() {
        return [
            { label: 'Approve Cancellation', value: 'Approved Cancellation' },
            { label: 'Reject Cancellation', value: 'Rejected Cancellation' },
        ];
    }

    get options1() {
        return [
            { label: 'Chemical GSAP P-31', value: 'ChemicalGSAP' },
            { label: 'Third Party', value: 'ThirdParty' },
        ];
    }


    value = [''];

    get options2() {
        return [
            { label: 'Rush Order', value: 'Rush Order' },
            { label: 'Late Order', value: 'Late Order' },
            { label: 'Last Minute Changes', value: 'Last Minute' },   
        ];
    }

    get selectedValues() {
        return this.value.join(',');
    } 

    handleOrderPriority(event) {
        this.orderPriority = event.detail.value;
    }

    handleModifyOrderPriority(event) {
        this.modifyOrderPriority = event.detail.value;
    }

    handleModifyOrdervalues(){
        if(this.orderDetailList.isRushOrderVal==='Yes'){
            this.modifyOrderPriority=[...this.modifyOrderPriority,'Rush Order'];
        }
        if(this.orderDetailList.isLateOrderVal==='Yes'){
            this.modifyOrderPriority=[...this.modifyOrderPriority,'Late Order'];
        }
        if(this.orderDetailList.isLastMinuteChangeVal==='Yes'){
            this.modifyOrderPriority=[...this.modifyOrderPriority,'Last Minute'];
        }
    }

    handleDecision(event){
        this.decision = event.detail.value;
        if(this.decision == 'Approved'){
            this.enableSubmit = false;
            this.isDisableParty = false;
        }else if(this.decision == 'Rejected'){
            this.orderPriority = [];
            this.orderParty = null;
            this.isDisableParty = true;
            this.enableSubmit = true;
        }   
    }

    handleModifyDecision(event){
        this.modifyDecision = event.detail.value;
        if(this.isModifyRemarksFilled && this.modifyDecision){
            this.enableModifySubmit = true;
            }
        if(this.modifyDecision == 'Approved Modification'){
            this.handleModifyOrdervalues();
            this.isDisableModifyPriority = false;
        }else if(this.modifyDecision == 'Rejected Modification'){
            this.modifyOrderPriority = [];
            this.handleModifyOrdervalues();
            this.isDisableModifyPriority = true;
        }   
        
    }

    handleCancelDecision(event){
        this.cancelDecision = event.detail.value;
        if((this.cancelDecision == 'Approved Cancellation')||(this.cancelDecision == 'Rejected Cancellation')){
            if(this.isCancelRemarksFilled){
                this.enableCancelSubmit = true;
                }
        }  
        
    }

    handleParty(event){
        this.orderParty = event.detail.value;
        this.enableSubmit = true;
    }

    handleBack(){
        this.navigateToHomePage('back','',this.tableType,this.sendFilterData);
    }

    navigateToHomePage(data,orderNumber, type,filterdata){
        this.dispatchEvent(new CustomEvent('backbutton',{detail : {"status":data, "ordernumber":orderNumber , "type" : type, "filtercudata": filterdata}}));
    }

    handleSubmit(){
        this.isLoading = true;
        if(this.decision == 'Approved' && this.orderParty == 'ChemicalGSAP'){
            this.validateMapping();
        }else{
            this.updateOrderDetails();
        }
    }

    handleModificationSubmit(){
        this.isLoading = true;
        if(this.modifyDecision =='Approved Modification'){
            this.validateMappingForModify();
        }
        if(this.modifyDecision =='Rejected Modification'){
            this.rejectModifyCancelDetails();
         }
    }

    handleCancelSubmit(){
        this.isLoading = true;
        if(this.cancelDecision =='Approved Cancellation'){
           this.validateMappingForCancel();
        }
        if(this.cancelDecision =='Rejected Cancellation'){
            this.rejectOrderCancellationDetails();
         }
    }

    handleRemarks(event){
        this.remarks = event.detail.value;
        this.remarksCount = this.remarks.length;
    }

    handleModifyRemarks(event){
        
        this.modifyCommopsRemarks = event.detail.value;
        this.modifyCommopsRemarksCount = this.modifyCommopsRemarks.length;
        if(this.modifyCommopsRemarksCount>0){
            this.isModifyRemarksFilled=true;
        }else{
            this.isModifyRemarksFilled=false;
        }
        if(this.isModifyRemarksFilled && this.modifyDecision){
            this.enableModifySubmit=true;
        }else{
            this.enableModifySubmit=false;
        }
    }

    handleCancelRemarks(event){
        this.cancelCommopsRemarks = event.detail.value;
        this.cancelCommopsRemarksCount = this.cancelCommopsRemarks.length;
        
        if(this.cancelCommopsRemarksCount>0){
            this.isCancelRemarksFilled=true;
        }else{
            this.isCancelRemarksFilled=false;
        }
        if(this.isCancelRemarksFilled && this.cancelDecision){
            this.enableCancelSubmit=true;
        }else{
            this.enableCancelSubmit=false;
        }
    }
    

    validateMapping(){
        validateMappingReference({orderId: this.orderId})
        .then(result=>{
            window.console.log('response'+result);
            if(result == 'Success'){
                this.updateOrderDetails();
            }else{
                this.showModalBox();
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in updating data=====>'+JSON.stringify(this.error));
        });

    }

    validateMappingForModify(){
        validateMappingReference({orderId: this.orderId})
        .then(result=>{
            if(result == 'Success'){
                this.approveModifyCancelDetails();
            }else{
                this.showModalBox();
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in updating data==>'+JSON.stringify(this.error));
        });

    }

    validateMappingForCancel(){
        validateMappingReference({orderId: this.orderId})
        .then(result=>{
            if(result == 'Success'){
                this.approveOrderCancellationDetails();
            }else{
                this.showModalBox();
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in updating data===>'+JSON.stringify(this.error));
        });

    }

    updateOrderDetails(){

        if(this.orderDetailList.id && this.orderDetailList.id.length>0){
            this.orderWrapper.id = this.orderDetailList.id;
        }
        if(this.orderDetailList.orderNumber && this.orderDetailList.orderNumber.length>0){
            this.orderWrapper.orderNumber = this.orderDetailList.orderNumber;
        }
        if(this.decision && this.decision.length >0){
            this.orderWrapper.status = this.decision;
        }
        if(this.orderParty === 'ChemicalGSAP'){
            this.orderWrapper.isChemicalGSAP = true;
        }else if(this.orderParty === 'ThirdParty'){
            this.orderWrapper.isThirdParty = true;
        }
        if(this.orderPriority && this.orderPriority.length>0){
            if(this.orderPriority.includes('Rush Order')){
                this.orderWrapper.isRushOrder = true;
            }else{
                this.orderWrapper.isRushOrder = false;
            }
            if(this.orderPriority.includes('Late Order')){
                this.orderWrapper.isLateOrder = true;
            }else{
                this.orderWrapper.isLateOrder = false;
            }
            if(this.orderPriority.includes('Last Minute')){
                this.orderWrapper.isLastMinute = true;
            }else{
                this.orderWrapper.isLastMinute = false;
            }
        }
        if(this.remarks && this.remarks.length>0){
            this.orderWrapper.remarks = this.remarks;
        }

        updateOrderReviewDetails({ordWrap : this.orderWrapper})
        .then(result=>{
            let resp = result;
            if(resp.TCP_Order_Status__c == this.decision){
                this.isLoading = false;
                if(resp.Chemical_GSAP_P_31__c){
                    this.navigateToHomePage('Approved GSAP',resp.OrderNumber, this.tableType);
                }else{
                this.navigateToHomePage(resp.TCP_Order_Status__c,resp.OrderNumber, this.tableType);
                }
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in updating data==>'+JSON.stringify(this.error));
        });
        
    }

    //Approval of modification (which can include a line item cancellation)
    approveModifyCancelDetails(){

        if(this.orderDetailList.id && this.orderDetailList.id.length>0){
            this.approveModifyCancelWrapper.id = this.orderDetailList.id;
        }
        if(this.orderDetailList.orderNumber && this.orderDetailList.orderNumber.length>0){
            this.approveModifyCancelWrapper.orderNumber = this.orderDetailList.orderNumber;
        }
        if(this.modifyOrderPriority && this.modifyOrderPriority.length>0){
            if(this.modifyOrderPriority.includes('Rush Order')){
                this.approveModifyCancelWrapper.isRushOrder = true;
            }else{
                this.approveModifyCancelWrapper.isRushOrder = false;
            }
            if(this.modifyOrderPriority.includes('Late Order')){
                this.approveModifyCancelWrapper.isLateOrder = true;
            }else{
                this.approveModifyCancelWrapper.isLateOrder = false;
            }
            if(this.modifyOrderPriority.includes('Last Minute')){
                this.approveModifyCancelWrapper.isLastMinute = true;
            }else{
                this.approveModifyCancelWrapper.isLastMinute = false;
            }
        }
        if(this.modifyCommopsRemarks && this.modifyCommopsRemarks.length>0){
            this.approveModifyCancelWrapper.modifyCommopsRemarks = this.modifyCommopsRemarks;
        }
        
        getOrderOnCommopsApproval({ordWrap : this.approveModifyCancelWrapper})
        .then(result=>{
            let resp = result;
            if(resp.TCP_Order_Status__c == 'Approved'){
                this.isLoading = false;
                this.navigateToHomePage(resp.TCP_Order_Status__c,resp.OrderNumber, this.tableType);
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in approveModifyCancelDetails updating data====>'+JSON.stringify(this.error));
        });
        
    }

    //Rejection of both modification and cancellation follow same high level process.
   rejectModifyCancelDetails(){

        if(this.orderDetailList.id && this.orderDetailList.id.length>0){
            this.rejectModifyCancelWrapper.id = this.orderDetailList.id;
        }
        if(this.orderDetailList.orderNumber && this.orderDetailList.orderNumber.length>0){
            this.rejectModifyCancelWrapper.orderNumber = this.orderDetailList.orderNumber;
        }
        if(this.modifyCommopsRemarks && this.modifyCommopsRemarks.length>0){
            //captures remarks if modification is rejected
            this.rejectModifyCancelWrapper.modifyCommopsRemarks = this.modifyCommopsRemarks;
        }

        getOrderOnCommopsRejection({ordWrap : this.rejectModifyCancelWrapper})
        .then(result=>{
            let resp = result;
            if(resp.TCP_Order_Status__c == 'Approved'){
                this.isLoading = false;
                this.navigateToHomePage('Rejected',resp.OrderNumber, this.tableType);
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in approveModifyCancelDetails updating data====>'+JSON.stringify(this.error));
        });
        
    }

    approveOrderCancellationDetails(){

        if(this.orderDetailList.id && this.orderDetailList.id.length>0){
            this.approveOrderCancellationWrapper.id = this.orderDetailList.id;
        }
        if(this.orderDetailList.orderNumber && this.orderDetailList.orderNumber.length>0){
            this.approveOrderCancellationWrapper.orderNumber = this.orderDetailList.orderNumber;
        }
        if(this.cancelCommopsRemarks && this.cancelCommopsRemarks.length>0){
            this.approveOrderCancellationWrapper.cancelCommopsRemarks = this.cancelCommopsRemarks;
        }

        getOrderOnCommopsCancellationApproval({ordWrap : this.approveOrderCancellationWrapper})
        .then(result=>{
            let resp = result;
            if(resp.TCP_Order_Status__c == 'Cancelled'){
                this.isLoading = false;
                this.navigateToHomePage('Approved Cancel',resp.OrderNumber, this.tableType);
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in approveOrderCancellationDetails updating data====>'+JSON.stringify(this.error));
        });
        
    }

    rejectOrderCancellationDetails(){

        if(this.orderDetailList.id && this.orderDetailList.id.length>0){
            this.rejectOrderCancellationWrapper.id = this.orderDetailList.id;
        }
        if(this.orderDetailList.orderNumber && this.orderDetailList.orderNumber.length>0){
            this.rejectOrderCancellationWrapper.orderNumber = this.orderDetailList.orderNumber;
        }
        if(this.cancelCommopsRemarks && this.cancelCommopsRemarks.length>0){
            this.rejectOrderCancellationWrapper.cancelCommopsRemarks = this.cancelCommopsRemarks;
        }

        getOrderOnCommopsCancellationRejection({ordWrap : this.rejectOrderCancellationWrapper})
        .then(result=>{
            let resp = result;
            if(resp.TCP_Order_Status__c == 'Approved'){
                this.isLoading = false;
                this.navigateToHomePage('Rejected',resp.OrderNumber, this.tableType);
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            window.console.log('Error in getOrderOnCommopsCancellationRejection updating data====>'+JSON.stringify(this.error));
        });
        
    }


    showModalBox() {  
        this.isLoading=false;
        this.isShowModal = true;
    }
    hideModalBox() {  
        this.isShowModal = false;
    }

    showCollapseRow(event) {
        let dataId = event.currentTarget.dataset.id;
        let target = this.template.querySelector('[data-id="'+dataId+'"]');
        if( target && target != null){
            if(target.classList.contains('iconRotate')){
                target = target.classList.remove('iconRotate');
                let className = '.'+dataId;
                let row = this.template.querySelector(className);
                if(row && row != null){
                    row = row.classList.remove('showRow');
                }
            }else{
                target = target.classList.add('iconRotate');
                let className = '.'+dataId;
                let row = this.template.querySelector(className);
                if(row && row != null){
                    row = row.classList.add('showRow');
                }
            }
        }
        
    };


    addSerailNumberToList(ordLineList){
        let tempOrdLineList = [];
        for(let i=0; i<ordLineList.length;i++){
            let tempList = [];
            let serialNum = i+1;
            serialNum = serialNum + '';
            tempList.sno = serialNum.padStart(2,'0');
            tempList.Id = ordLineList[i].Id ? ordLineList[i].Id : '';
            tempList.Material_Name__c = ordLineList[i].Material_Name__c ? ordLineList[i].Material_Name__c : '';
            tempList.MaterialNumber__c = ordLineList[i].MaterialNumber__c ? ordLineList[i].MaterialNumber__c : '';
            tempList.Quantity__c = ordLineList[i].Quantity__c ? ordLineList[i].Quantity__c : '';
            tempList.Unit__c = ordLineList[i].Unit__c ? ordLineList[i].Unit__c : '';
            tempList.Delivery_Collection_Date__c = ordLineList[i].Delivery_Collection_Date__c ? ordLineList[i].Delivery_Collection_Date__c : '';
            tempList.Contract_No__c = ordLineList[i].Contract_No__c ? ordLineList[i].Contract_No__c : '';
            tempList.Other_Instruction__c = ordLineList[i].Other_Instruction__c ? ordLineList[i].Other_Instruction__c : '';
            tempList.GSAP_Due_Date__c = ordLineList[i].GSAP_Due_Date__c ? ordLineList[i].GSAP_Due_Date__c : '';
            tempList.GSAP_Dispatch_Date__c = ordLineList[i].GSAP_Dispatch_Date__c ? ordLineList[i].GSAP_Dispatch_Date__c : '';
            tempList.GSAP_Bol_Delivery__c = ordLineList[i].GSAP_Bol_Delivery__c ? ordLineList[i].GSAP_Bol_Delivery__c : '';
            tempList.GSAP_Mode_of_Transport_ID__c = ordLineList[i].GSAP_Mode_of_Transport_ID__c ? ordLineList[i].GSAP_Mode_of_Transport_ID__c : '';
            tempList.GSAP_Goods_Issue_value__c = ordLineList[i].GSAP_Goods_Issue_value__c ? ordLineList[i].GSAP_Goods_Issue_value__c : '';
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

        document.title = 'TCP | Review Order Details';
    }

   



}