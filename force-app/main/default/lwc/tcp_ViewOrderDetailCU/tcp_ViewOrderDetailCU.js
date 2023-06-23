import { LightningElement,track,api  } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
const statusData = new Map([
    ['CN', { customClass: 'cn-line-item', expStatus: 'Line Item Cancelled'}],
    ['RC', { customClass: 'rc-line-item', expStatus: 'Requested for Cancellation'}],
    ['NIL', { customClass: 'slds-hint-parent', expStatus: ''}]
  ]);

export default class tcp_ViewOrderDetailCU extends NavigationMixin (LightningElement) {

    @track ViewOrderDetailCU = true;
    @track chevronrightShow = true;
    
    value = '';
    error;
    @api orderdetaildata;
    @api soldtoid;
    @api ordhisaccids;
    @api type;
    @api iswebemail;
    @api cufilterdata;
    @track orderDetailList;
    @track orderLineItemsList =[];
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
    @track backToDashboard=true;
    @track docOrdNum;
    @track docSalesOrdNum;
    @track docBolDelivery;
    @track showDetails=true;
    @track viewAllAction=true;
    @track ordLineItemList = [];

    connectedCallback(){
        window.console.log('inside connected callback'+this.ordhisaccids);
        if(this.iswebemail === "yes"){
            
            this.tableType = 'For Review/Approval';
            this.orderDetailList = this.orderdetaildata;
            this.orderLineItemsList = this.orderDetailList.orderLineItemList;
        }
        else{
        
            this.sendFilterData = this.cufilterdata;
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
        }
        this.addSerailNumberToList(this.orderLineItemsList);
        //check if order is approved and disable or enable relavent variables
        if(this.orderDetailList.fullfilledBy==='Third Party'){
            this.viewAllAction = false;
        }
        if(this.orderDetailList.status && this.orderDetailList.status !== 'Approved' && this.orderDetailList.status !== 'Approved (M)' && this.orderDetailList.status !== 'Approved (C)' && this.orderDetailList.status !== 'Shipped'){
            this.chevronrightShow = false;
            this.viewAllAction = false;
            
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

    navigateToHomePage(data,type, filterdata){
        this.dispatchEvent(new CustomEvent('backbutton',{detail : {"status":data, "type":type, "filtercudata": filterdata}}));
    }

    handleViewAllDocument(event){
        this.docBolDelivery= event.currentTarget.dataset.name;
        this.docSalesOrdNum=this.orderDetailList.salesordernumber;
        this.showDetails=false;
    }

    handleViewAllDocumentsBack(){
        this.showDetails=true;
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
            tempList.MaterialNumber__c = ordLineList[i].MaterialNumber__c ? ordLineList[i].MaterialNumber__c : '';
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
            tempList.oliStatus=this.handleOliStatus(ordLineList[i].TCP_Modify_Cancel_Status__c,ordLineList[i].Quantity__c);
            tempList.oliStatusAttr=statusData.get(tempList.oliStatus);
            
            tempOrdLineList = [...tempOrdLineList, tempList];
        }
        if(tempOrdLineList.length>0){
            this.ordLineItemList = tempOrdLineList;
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
}