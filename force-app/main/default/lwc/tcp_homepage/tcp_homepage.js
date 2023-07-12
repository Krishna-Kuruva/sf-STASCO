import { LightningElement,track, wire ,api} from 'lwc';
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';
import communityBasePath from '@salesforce/community/basePath'; 
import getAccountDetails from '@salesforce/apex/TCP_HomePageController.getAccountDetails';
import getCountOfOrders from '@salesforce/apex/TCP_HomePageController.getCountOfOrders';
import getCountOfOrdersEU from '@salesforce/apex/TCP_HomePageController.getCountOfOrdersEU';
import getCountOfOrdersCU from '@salesforce/apex/TCP_HomePageController.getCountOfOrdersCU';
import loggedInAsTcpUser from '@salesforce/apex/TCP_HomePageController.loggedInAsTcpUser';
import fetchGSAPCurrentOrders from '@salesforce/apex/TCP_OrderController.fetchGSAPCurrentOrders';
import getOrderDetailsByWONumber from '@salesforce/apex/TCP_OrderController.getOrderDetailsByWONumber';
import fetchGSAPOrderConfirmationdetails from '@salesforce/apex/TCP_OrderController.fetchGSAPOrderConfirmationdetails';
import uId from '@salesforce/user/Id';
import TCP_PlaceOrderLabel from '@salesforce/label/c.TCP_PlaceOrderLabel';
import TCP_ReviewOrApprovalLabel from '@salesforce/label/c.TCP_ReviewOrApprovalLabel';
import TCP_ModifiedOrdersLabel from '@salesforce/label/c.TCP_ModifiedOrdersLabel';
import TCP_ModificationOrCancelLabel from '@salesforce/label/c.TCP_ModificationOrCancelLabel';
import TCP_RecentOrdersLabel from '@salesforce/label/c.TCP_RecentOrdersLabel';
import TCP_PreviousOrdersLabel from '@salesforce/label/c.TCP_PreviousOrdersLabel';
import TCP_ApprovalLabel from '@salesforce/label/c.TCP_ApprovalLabel';
import TCP_CancellationReqLabel from '@salesforce/label/c.TCP_CancellationReqLabel';
import TCP_RejectLabel from '@salesforce/label/c.TCP_RejectLabel';
import TCP_CancelledOrderLabel from '@salesforce/label/c.TCP_CancelledOrderLabel';
import TCP_CurrentOrderLabel from '@salesforce/label/c.TCP_CurrentOrderLabel';
import TCP_CurrentOrderCULabel from '@salesforce/label/c.TCP_CurrentOrderCULabel';
import TCP_OrderLabel from '@salesforce/label/c.TCP_OrderLabel';
import TCP_SavedOrderLabel from '@salesforce/label/c.TCP_SavedOrderLabel';
import TCP_PlaceOrderVideo from '@salesforce/label/c.TCP_Place_Order_Video';
import TCP_PortalTourVideo from '@salesforce/label/c.TCP_Portal_Tour_Video';
import TCP_EUGuide from '@salesforce/label/c.TCP_EU_Guide';
import TCP_CSAccountMapping from '@salesforce/label/c.TCP_CS_Account_Mapping';
import TCP_CSUserCreation from '@salesforce/label/c.TCP_CS_User_Creation';
import TCP_CSUserGuide from '@salesforce/label/c.TCP_CS_User_Guide';
import TCP_send_icon from '@salesforce/resourceUrl/TCP_send_icon';
import TCP_refresh_icon from '@salesforce/resourceUrl/TCP_refresh_icon';
import TCP_time_icon from '@salesforce/resourceUrl/TCP_time_icon';
import TCP_eye_icon from '@salesforce/resourceUrl/TCP_eye_icon';
import TCP_rightCircleArrow from '@salesforce/resourceUrl/TCP_rightCircleArrow';
import TCP_RoundCheck_icon from '@salesforce/resourceUrl/TCP_RoundCheck_icon';
import TCP_RoundClose_icon from '@salesforce/resourceUrl/TCP_RoundClose_icon';





export default class Tcphomepage extends NavigationMixin (LightningElement) {

    @api orderhistory;
    @api label;
    @wire(CurrentPageReference)
    currentPageReference;
    label = {
                TCP_PlaceOrderLabel,
                TCP_ReviewOrApprovalLabel,
                TCP_ModifiedOrdersLabel,
                TCP_ModificationOrCancelLabel,
                TCP_RecentOrdersLabel,
                TCP_PreviousOrdersLabel,
                TCP_ApprovalLabel,
                TCP_CancellationReqLabel,
                TCP_CancelledOrderLabel,
                TCP_RejectLabel,
                TCP_CurrentOrderLabel,
                TCP_SavedOrderLabel,
                TCP_CurrentOrderCULabel,
                TCP_OrderLabel,
                TCP_PlaceOrderVideo,
                TCP_PortalTourVideo,
                TCP_EUGuide,
                TCP_CSAccountMapping,
                TCP_CSUserCreation,
                TCP_CSUserGuide
    }
    
    TCP_send_icon=TCP_send_icon;
    TCP_refresh_icon=TCP_refresh_icon;
    TCP_time_icon=TCP_time_icon;
    TCP_eye_icon=TCP_eye_icon;
    TCP_rightCircleArrow=TCP_rightCircleArrow;
    TCP_RoundCheck_icon=TCP_RoundCheck_icon;
    TCP_RoundClose_icon=TCP_RoundClose_icon;

    @track dashboard = true;
    @track placeorder = false;
    @track reorderoverlay=false;
    @track orderhistory = false;
    @track userId = uId;
    @track accountData = [];
    @track accountIds = [];
    @track value;
    @track logOnAsTCP;
    @track showOrderNumber = false;
    @track showGSAPOrderNumber = false;
    @track orderNumber;
    @track hasSubmitted;
    @track hasSubmitted2;
    @track customerOptions = [];
    error;
    @track redirectOhistory=false;
    @track navSelected='link_Dashboard';
    @track parentaccid;
    @track soldtoid;
    @track commopsUserTabel = false;
    @track endUserTabel = true;
    @track tcpReviewOrderDetailCU = false;
    @track endUserTable = false;
    @track orderDetailData = [];
    @track isLoading = false;
    @track hasApprovedOrder;
    @track hasApprovedGSAPOrder;
    @track hasDraftOrder;
    @track hasRejectedOrder;
    @track hasAccessOrder;
    @track hasCommopsCancelApproved;
    @track reviewOrderCount;
    @track myCurrentOrderCountEU;
    @track rejectCancelledCountEU;
    @track previousCountEU;
    @track previousCountCU;
    @track modifyCancelCountCU;
    @track myCurrentOrderCountCU; 
    @track custName;
    @track viewOrderDetailCU = false;
    @track viewOrderDetailCU2 = false;
    @track viewOrderDetailEU = false;
    @track viewOrderDetailEU2 = false;
    @track viewAllDocumentsCU = false;
    @track euselectedtile;
    @track cuselectedtile;
    @track tableType;
    @track initialLoadTileHomePage;
    @track modifyOrderEU = false;
    @track filterdata;
    @track iswebemailvar;
    @track actionType;
    @track oneTimeLoad = true;
    @track selectedCustMap = new Map();
    @track customerSelectText;
    @track ordHisAccIds = [];
    
    defaultCustText = 'All Customer Selected';
    allOrderEuVar = 'c-tcp_-all-orders-e-u';
    prevCountEu ='.previousCountEU';
    rejCanCountEu = '.rejectCancelledCountEU';
    prevCountCu = '.previousCountCU';
    myCurOrdCountCu = '.myCurrentOrderCountCU';
    modCanCountCU = '.modifyCancelCountCU';
    docTitle = 'TCP | Order History';
    ordHistoryLabel = 'Order History';
    allOrdCu = 'c-tcp_-all-orders-c-u';
    docTitleHome = 'TCP | Home';
    myCurOrdEu = '.myCurrentOrderEU';
    reviewOrdCnt = '.reviewOrderCount';
    custDropDownAction ='slds-is-open';
    custDropDownName = '.slds-dropdown-trigger';
    allCustCheck ='.all-cust-check';
    sldsVisible = 'slds-visible';
    sldsHidden = 'slds-hidden';
    sldsHasFocus = 'slds-has-focus';
    sldsCustFocus = '.slds-cust-focus';
    uncheckAll = '.uncheck-all';

    constructor(){
        super();
        loggedInAsTcpUser().then(result => {
            this.logOnAsTCP = result;
            window.console.log('logged in user commops: '+this.logOnAsTCP);
            this.error = null;
        })
        .catch(error => {
            this.error = error;
            this.name = null;
        });
    
    }
    
    renderedCallback(){
        
        if(this.logOnAsTCP && this.oneTimeLoad){
            const target = this.template.querySelector(this.reviewOrdCnt);
            if(target && target != null){
                target.classList.add('boxHighlight');
                this.oneTimeLoad = false;
            }  
        }else if(!this.logOnAsTCP && this.oneTimeLoad && this.logOnAsTCP !== undefined){
            const target = this.template.querySelector(this.myCurOrdEu);
            if(target && target != null){
                target.classList.add('boxHighlight');
                this.oneTimeLoad = false;
            } 
        }

    }


    connectedCallback() {      
        var wonumber =  this.currentPageReference.state.c__wonumber;
        var pageNavigate =  this.currentPageReference.state.navigateTo;
        this.customerSelectText = this.defaultCustText;
        window.console.log('connected');
        if(wonumber){
            
            this.getOrderwithWebOrderNumber(wonumber);

        }
        if(pageNavigate==='Ohistory'){
            this.redirectOhistory=true;
            this.navSelected='link_orderhistory';
            
        }
    }
        
    handleClick(event) {

    window.open("https://www.epc.shell.com/");
   
   }

   handleClickDownloadQuickStartGuide(event){

    //window.open("https://www.shell.com/business-customers/chemicals/doing-business-with-us/customer-portal.html")
    if(this.logOnAsTCP){
    window.open("https://stasco--tcp.sandbox.my.site.com/sfc/servlet.shepherd/document/download/06925000001w4w4AAA?operationContext=S1")
    }else{
    window.open("https://stasco--tcp.sandbox.my.site.com/sfc/servlet.shepherd/document/download/06925000001w4w9AAA?operationContext=S1")
    }
}
    
    handleClickPlaceOrderVideo(event){

    //window.open("https://www.shell.com/business-customers/chemicals/doing-business-with-us/customer-portal.html")
    window.open("https://stasco--tcp.sandbox.my.site.com/sfc/servlet.shepherd/document/download/06925000001w4wYAAQ?operationContext=S1")
   }

   handleClickDownloadPortalVideo(event){
    window.open("https://stasco--tcp.sandbox.my.site.com/sfc/servlet.shepherd/document/download/06925000001vyWAAAY?operationContext=S1")
   }

   handleClickPrivacyPolicy(event){
    window.open("https://www.shell.com/privacy.html")
   }

   handleClickUserCreationGuide(event){
    window.open("https://stasco--tcp.sandbox.my.site.com/sfc/servlet.shepherd/document/download/06925000001vyWAAAY?operationContext=S1")
   }

   handleClickAccountMappingGuide(event){
    //window.open("https://stasco--tcp.sandbox.my.site.com/sfc/servlet.shepherd/document/download/06925000001vyWAAAY?operationContext=S1")
    window.open(label.TCP_CSAccountMapping)
   
    }

    handleCustDropDown(event){
        document.title = this.docTitleHome;
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
        document.title = this.docTitleHome;
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
        document.title = this.docTitleHome;
        const target = this.template.querySelector(this.allCustCheck);
        if(target != null && target.classList.contains(this.sldsVisible)){
            target.classList.remove(this.sldsVisible);
            target.classList.add(this.sldsHidden);
        }else{
            target.classList.remove(this.sldsHidden);
            target.classList.add(this.sldsVisible);
            this.uncheckAllOtherCustomers();
            this.getOrderCountCU(this.accountIds);
            this.handleChange();
            this.customerSelectText = this.defaultCustText;

        }
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
            this.getOrderCountCU(this.formatDataToList(this.selectedCustMap));
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

    formatDataToList(input){
        let data = [];
        if(input){
            for(const [mapkey,mapvalue] of input){
                data = [...data,mapvalue];
            }
        }
        return data;
    }

    validateAndCountOrders(){
        if(this.selectedCustMap.size > 0){
            this.getOrderCountCU(this.formatDataToList(this.selectedCustMap));
        }else{
            this.getOrderCountCU(this.accountIds);
        }
    }

    get accountIdsToProcess(){
        if(this.selectedCustMap.size > 0){
            return this.formatDataToList(this.selectedCustMap);
        }else{
            return this.accountIds;
        }
    }

    uncheckAllOtherCustomers(){
        this.template.querySelectorAll(this.uncheckAll).forEach(targetElement => {
            targetElement.classList.remove(this.sldsVisible);
            targetElement.classList.add(this.sldsHidden);
        });
        this.selectedCustMap.clear();
    }

   @wire(getAccountDetails)
    wiredAccounts({data, error}){
        this.isLoading = true;
        if(data){
            this.accountData = data;
            let tepmObj = [];
            for (let key in data) {
                const option = {
                label : data[key].Name,
                value : data[key].Id
                };
                this.customerOptions = [...this.customerOptions, option];
                tepmObj = [...tepmObj,data[key].Id];
            }

            if(tepmObj && tepmObj.length>0){
                this.accountIds = tepmObj;
            }
            if(this.accountData.length > 0){
                this.value = this.customerOptions[0].value;
                this.custName = this.customerOptions[0].label;
                this.parentaccid =  this.customerOptions[0].value;
                this.soldtoid = this.customerOptions[0].value;
                this.callOrdConfirmService();
                this.callGSAPService();
            }
              
            if(this.logOnAsTCP){
                this.initialLoadTileHomePage = TCP_ReviewOrApprovalLabel+TCP_ApprovalLabel;
                this.commopsUserTabel=true;
                this.getOrderCountCU(this.accountIds);
                if(this.redirectOhistory){
                    this.orderHistoryClick();
                }
            }else{
                this.euselectedtile='My Current Order EU';
                this.initialLoadTileHomePage=TCP_CurrentOrderLabel+TCP_OrderLabel;
                this.endUserTable=true;
                this.getOrderCountEU();
                if(this.redirectOhistory){
                    this.orderHistoryClick();
                }
            }
            this.isLoading = false;
            this.error = null;
            
        }
        else if (error) {
            this.isLoading = false;
            this.error = error; 
            window.console.log('ERROR====>'+JSON.stringify(this.error));
        }
    }

    handleChange(event) {
        // this.isLoading = true;
        // this.value = event.detail.value;
        // this.parentaccid = this.value;
        // this.soldtoid = this.value;
        // this.callOrdConfirmService();
        // this.callGSAPService();

        if(this.logOnAsTCP){    
            this.endUserTable = false;
            this.commopsUserTabel=true;
            document.title = this.docTitleHome;
            let accIds = [];
            if(this.selectedCustMap.size > 0){
                accIds = this.formatDataToList(this.selectedCustMap);
            }else{
                accIds = this.accountIds;
            }
            this.template.querySelector(this.allOrdCu).handleDataOnSoldtoChange(accIds);
        }else{
            this.endUserTable = true;
            this.commopsUserTabel = false;
            document.title = this.docTitleHome;
            this.getOrderCountEU();
        }

        // setTimeout(() => {
        //     this.isLoading = false;
        // }, 2000);
    }

    get options(){
        return this.customerOptions;
    }

   placeorderClick(event){
    if(this.doInputValidation('.placeordercheck')){
        this.orderhistory=false;
        this.dashboard =   false;
        this.reorderoverlay=false;
        this.placeorder =  true;
        this.tableType = event.detail.type;
        this.filterdata = event.detail.filterdata;
        document.title = 'TCP | Place Order';
    } 
   }

   doInputValidation(screenName){
        return  [...this.template.querySelectorAll(screenName)]
        .reduce((validSoFar, inputField) => {        
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
        }, true);
    }

   handlePlaceorder(event){
        this.reorderoverlay = false;
        this.placeorder=false;
        const typeInfo = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        if(typeInfo===this.ordHistoryLabel){ 
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = false;
        this.orderhistory=true;
        this.scrollToTopOfPage(); 
        document.title = this.docTitle;
        }else{
        this.dashboard =  true;
        this.scrollToTopOfPage();
        if(typeInfo){
            this.initialLoadTileHomePage=typeInfo;
            } 
        this.endUserTable = true;
        document.title = this.docTitleHome;
    }
   }

   
   handlemodifyordereu(event){
        this.modifyOrderEU =  false;
        this.scrollToTopOfPage();
        const type = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        this.actionType = event.detail.status;
        if(type===this.ordHistoryLabel){
                this.initialLoadTileHomePage=type;
                this.orderhistory=true;
                document.title = this.docTitle;
                this.scrollToTopOfPage();
        }else{
                this.scrollToTopOfPage();
                this.dashboard =  true;
                this.initialLoadTileHomePage=type;
                this.endUserTable = true;
                document.title = this.docTitleHome;
        }
    }

   handleSaveOrder(event){
    this.showOrderNumber = true;
    this.orderNumber = event.detail.ordernumber;
    const status = event.detail.status;
    this.filterdata = event.detail.filtereudata;
    const typeInfo = event.detail.type;
    
    this.reorderoverlay = false;
    this.placeorder =  false;
    if(status === 'Draft'){
        this.hasDraftOrder = true;
    }else if(status === 'Submitted'){
        this.hasSubmitted = true;
    }
    if(typeInfo===this.ordHistoryLabel){ 
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = false;
        this.orderhistory=true;
        this.scrollToTopOfPage(); 
        document.title = this.docTitle;
        }else{
        this.dashboard =  true;
        document.title = this.docTitleHome;
        this.scrollToTopOfPage();
        if(typeInfo){
        this.initialLoadTileHomePage=typeInfo;
        }   
        this.endUserTable = true;
    }
    setTimeout(() => {
        this.showOrderNumber = false;
        this.hasSubmitted = false;
        this.hasDraftOrder = false;
    }, 6000);
   
}

   handleModifyOrder(event){
    this.showModifiedOrderNumber = true;
    this.orderNumber = event.detail.ordernumber;
    
        this.hasSubmitted = true;
        this.endUserTable = true;
       
    this.dashboard =   true;
    document.title = this.docTitleHome;
    this.scrollToTopOfPage();
    this.modifyOrderEU =  false;
    setTimeout(() => {
        this.showModifiedOrderNumber = false;
        this.hasSubmitted = false;
        this.hasDraftOrder = false;
    }, 6000);
   
}

   handleClose(){
        this.showOrderNumber = false;
   }

   handleReviewOrderCU(){
        document.title = 'TCP | Review/Approval';
        this.tcpReviewOrderDetailCU = false;        
        this.commopsUserTabel = true;
        this.template.querySelector(this.reviewOrdCnt).classList.add('boxHighlight');
        this.template.querySelector(this.modCanCountCU).classList.remove('boxHighlight');
        this.template.querySelector(this.myCurOrdCountCu).classList.remove('boxHighlight');
        this.template.querySelector(this.prevCountCu).classList.remove('boxHighlight');
        this.endUserTable = false
        this.template.querySelector(this.allOrdCu).handleData(TCP_ReviewOrApprovalLabel+TCP_ApprovalLabel);
   }

   handleModifyCancelCU(){
        document.title = 'TCP | Modification/Cancellation Requests';
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector(this.reviewOrdCnt).classList.remove('boxHighlight');
        this.template.querySelector(this.myCurOrdCountCu).classList.remove('boxHighlight');
        this.template.querySelector(this.prevCountCu).classList.remove('boxHighlight');
        this.template.querySelector(this.modCanCountCU).classList.add('boxHighlight');
        this.commopsUserTabel = true;
        this.endUserTable = false
        this.validateAndCountOrders();
        this.template.querySelector(this.allOrdCu).handleData(TCP_ModificationOrCancelLabel+TCP_CancellationReqLabel);
    }

    handleCurrentOrderCU(){
        document.title = 'TCP | Current Orders';
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector(this.myCurOrdCountCu).classList.add('boxHighlight');
        this.template.querySelector(this.reviewOrdCnt).classList.remove('boxHighlight');
        this.template.querySelector(this.prevCountCu).classList.remove('boxHighlight');
        this.template.querySelector(this.modCanCountCU).classList.remove('boxHighlight');
        this.commopsUserTabel = true;
        this.endUserTable = false
        this.template.querySelector(this.allOrdCu).handleData(TCP_CurrentOrderCULabel);

    }

    handlePreviousCU(){
        document.title = 'TCP | Previous Orders';
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector(this.myCurOrdCountCu).classList.remove('boxHighlight');
        this.template.querySelector(this.reviewOrdCnt).classList.remove('boxHighlight');
        this.template.querySelector(this.prevCountCu).classList.add('boxHighlight');
        this.template.querySelector(this.modCanCountCU).classList.remove('boxHighlight');
        this.commopsUserTabel = true;
        this.endUserTable = false
        
        this.template.querySelector(this.allOrdCu).handleData(TCP_PreviousOrdersLabel);

    }

   handleMyCurrentOrderEU(){
        document.title = 'TCP | My Current Orders';
        
        this.commopsUserTabel = false;
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector(this.myCurOrdEu).classList.add('boxHighlight');
        this.template.querySelector(this.rejCanCountEu).classList.remove('boxHighlight');
        this.template.querySelector(this.prevCountEu).classList.remove('boxHighlight');
        this.endUserTable = true
        
        this.template.querySelector(this.allOrderEuVar).handleData(TCP_CurrentOrderLabel+TCP_OrderLabel);
    }

   handlePreviousOrder(){
    document.title = 'TCP | Previous Orders';
        
        this.commopsUserTabel = false;
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector(this.prevCountEu).classList.add('boxHighlight');
        this.template.querySelector(this.myCurOrdEu).classList.remove('boxHighlight');
        this.template.querySelector(this.rejCanCountEu).classList.remove('boxHighlight');

        this.endUserTable = true
        this.template.querySelector(this.allOrderEuVar).handleData(TCP_PreviousOrdersLabel);

    }

   handleRejectedCancelledOrder(){
        document.title = 'TCP | Rejected/Cancelled Orders';
        
        this.commopsUserTabel = false;
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector(this.rejCanCountEu).classList.add('boxHighlight');
        this.template.querySelector(this.myCurOrdEu).classList.remove('boxHighlight');
        this.template.querySelector(this.prevCountEu).classList.remove('boxHighlight');
        this.endUserTable = true
       
        this.template.querySelector(this.allOrderEuVar).handleData(TCP_RejectLabel+TCP_CancelledOrderLabel);

    }   

   handleModification(){
        this.tcpReviewOrderDetailCU = true;
        this.commopsUserTabel = false;
        document.title = 'TCP | Review Order Details';
   }

   handleOrderDetail(event){
    this.commopsUserTabel = false;
    this.dashboard =  false;
    this.orderhistory=false;
    this.ordHisAccIds = event.detail.accountids;
    this.tcpReviewOrderDetailCU = true;
    this.scrollToTopOfPage();
    this.orderDetailData = event.detail.data;
    this.tableType = event.detail.type;
    this.filterdata = event.detail.filterdata;
    document.title = 'TCP | Review Order Details';
     
   }

   handleModifyAction(event){
    this.commopsUserTabel = false;
    this.dashboard =  false;
    this.orderhistory=false;
    this.endUserTable=false;
    this.modifyOrderEU = true;
    this.viewOrderDetailEU=false;
    this.viewOrderDetailEU2=false;
    this.scrollToTopOfPage();
    this.orderDetailData = event.detail.data;
    this.filterdata = event.detail.filterdata;
    this.tableType = event.detail.type;
    this.actionType = event.detail.ordertype;
   }

   handleReOrderAction(event){
   
    this.reorderoverlay=true;
    this.commopsUserTabel = false;
    this.dashboard =  false;
    this.orderhistory=false;
    this.endUserTable=false;
    this.modifyOrderEU = false;
    this.viewOrderDetailEU=false;
    this.viewOrderDetailEU2=false;
    this.placeorder=true;
    this.scrollToTopOfPage();
    this.orderDetailData = event.detail.data;
    if(this.orderDetailData.status==='Draft'){
        document.title = 'TCP | Place Order';  
    }
    else{
        document.title = 'TCP | Re-Order';
    }
    this.filterdata = event.detail.filterdata;
    this.tableType = event.detail.type;
    this.actionType = event.detail.ordertype;
    
   }

   handleViewAllDocumentsCU(event){
    
   }
 
   handleviewOrderDetailCU(event){
    this.commopsUserTabel = false;
    this.dashboard =  false;
    this.orderhistory=false;
    this.endUserTable=false;
    if(event.detail.type === 'View All Docs'){
        this.viewAllDocumentsCU = true;
        this.scrollToTopOfPage();

    }else{
        this.ordHisAccIds = event.detail.accountids;
        this.viewOrderDetailCU = true;
        this.scrollToTopOfPage();
        this.orderDetailData = event.detail.data;
        this.tableType = event.detail.type;
        this.filterdata = event.detail.filterdata;
    }
   }

   handleViewOrderDetail(event){
    this.commopsUserTabel = false;
    this.dashboard =  false;
    this.orderhistory=false;
    this.endUserTable=false;

    if(event.detail.type === 'Modify Order'){
        this.modifyOrderEU = true;
        this.viewOrderDetailEU=false;
        this.viewOrderDetailEU2=false;
        this.scrollToTopOfPage();
        this.orderDetailData = event.detail.data;

    }else{
        this.filterdata = event.detail.filterdata;
        this.viewOrderDetailEU=true;
        this.hasCancelledOrder=false;
        this.modifyOrderEU = false;
        this.scrollToTopOfPage();
        this.orderDetailData = event.detail.data;
        this.tableType = event.detail.type;
        
    }


   }


   handleSoldToidChanged(event){
    this.soldtoid=event.detail.data;
    this.value=event.detail.data;
    this.validateAndCountOrders();
    this.callOrdConfirmService();
    this.callGSAPService();
   }

   handleOrderDetailback(event){
    const status = event.detail.status;
    const type = event.detail.type;
    this.tcpReviewOrderDetailCU = false;
    this.endUserTable = false;
    this.filterdata = event.detail.filtercudata;
    if(type===this.ordHistoryLabel){
        this.initialLoadTileHomePage=type;
        this.commopsUserTabel = false;
        this.selectedCustMap = event.detail.selectedaccids;
        this.orderhistory=true;
        document.title = this.docTitle;
        this.scrollToTopOfPage();
    }else{
        this.scrollToTopOfPage();
        this.dashboard =  true;
        this.initialLoadTileHomePage=type;
        this.commopsUserTabel = true;
        document.title = this.docTitleHome;
        this.populateDropDownOnBack();
    } 
        
    if(status === 'Approved'){
        this.orderNumber = event.detail.ordernumber;
        this.hasApprovedOrder = true;
        this.showOrderNumber = true;
        this.scrollToTopOfPage();
        setTimeout(() => {
            this.showOrderNumber = false;
            this.hasApprovedOrder = false;
        }, 6000);
    }else if(status ==='Approved GSAP'){
        this.orderNumber = event.detail.ordernumber;
        this.showGSAPOrderNumber = true;
        this.hasApprovedGSAPOrder = true;
        this.scrollToTopOfPage();
        setTimeout(() => {
            this.hasApprovedGSAPOrder = false;
            this.showGSAPOrderNumber = false;
        }, 6000);
    }else if(status ==='Rejected'){
        this.orderNumber = event.detail.ordernumber;
        this.hasRejectedOrder = true;
        this.scrollToTopOfPage();
        setTimeout(() => {
            this.hasRejectedOrder = false;
        }, 6000);
    }else if(status ==='Approved Cancel'){
        this.orderNumber = event.detail.ordernumber;
        this.hasCommopsCancelApproved = true;
        this.showOrderNumber = true;
        this.scrollToTopOfPage();
        setTimeout(() => {
            this.showOrderNumber = false;
            this.hasCommopsCancelApproved = false;
        }, 6000);
    }
    if(status === 'Approved' || status === 'Rejected' || status ==='Approved Cancel' || status ==='Approved GSAP'){
        this.validateAndCountOrders();
    }    
   }

   handleViewOrderEUBack(event){
    const status = event.detail.status;
    if(status === 'back'){
        this.viewOrderDetailEU = false;
        const typeInfo = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        if(typeInfo===this.ordHistoryLabel){ 
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = false;
        this.orderhistory=true;
        document.title = this.docTitle;
        this.scrollToTopOfPage(); 
        }else{
        this.dashboard =  true;
        this.scrollToTopOfPage();
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = true;
        document.title = this.docTitleHome;
    }
    }
   }

   handleReOrderBack(event){
    
    
        this.reorderoverlay = false;
        this.placeorder=false;
        const typeInfo = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        if(typeInfo===this.ordHistoryLabel){ 
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = false;
        this.orderhistory=true;
        document.title = this.docTitle;
        this.scrollToTopOfPage(); 
        }else{
        this.dashboard =  true;
        this.scrollToTopOfPage();
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = true;
        document.title = this.docTitleHome;
    }
   }

   handleCancelOrderEUBack(event){
   
    this.orderNumber = event.detail.data;
        this.viewOrderDetailEU = false;
        const typeInfo = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        if(typeInfo===this.ordHistoryLabel){ 
            this.hasCancelledOrder=true;
            if(event.detail.status==='Submitted'){
            this.hasSubmitted=true;
            }
            else{
            this.hasSubmitted2=true;
            }
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = false;
        this.orderhistory=true;
        document.title = this.docTitle;
        this.scrollToTopOfPage(); 
        }else{
            this.hasCancelledOrder=true;
            if(event.detail.status==='Submitted'){
            this.hasSubmitted=true;
            }
            else{
            this.hasSubmitted2=true;
            }
        this.dashboard =  true;
        this.scrollToTopOfPage();
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = true;
        document.title = this.docTitleHome;
        
    }
    setTimeout(() => {
        this.hasCancelledOrder = false;
        this.hasSubmitted = false;
        this.hasSubmitted2=false;
       
    }, 6000);
    
   }

   handleViewOrderEUBack2(event){
    const status = event.detail.status;
    if(status === 'back'){
        this.dashboard =  true;
        this.scrollToTopOfPage();
        this.endUserTable = true;
        this.checkForWOnumber();
        document.title = this.docTitleHome;
    }
   }
  

   handleViewOrderCUBack(event){
    const status = event.detail.status;
    if(status === 'back'){
        this.viewOrderDetailCU = false;
        const typeInfo = event.detail.type;
        this.filterdata = event.detail.filtercudata;
        if(typeInfo===this.ordHistoryLabel){
            this.initialLoadTileHomePage=typeInfo;
            this.commopsUserTabel = false;
            this.orderhistory=true;
            document.title = this.docTitle;
            this.scrollToTopOfPage();
        }else{
            this.dashboard =  true;
            this.scrollToTopOfPage();
            this.initialLoadTileHomePage=typeInfo;
            this.commopsUserTabel = true;
            document.title = this.docTitleHome;
            this.populateDropDownOnBack();
        }
        
    }
   }

   populateDropDownOnBack(){
    if(this.selectedCustMap.size>0){
        setTimeout(() => {
            this.handleCustDropDown();
            for(const data of this.selectedCustMap.values()){
                this.selectDropDownValue(data);
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

   handleViewOrderCUBack2(event){
    var baseurltemp = window.location.href;
    const baseurl = baseurltemp.substring(0, baseurltemp.indexOf('?'));
    window.open(baseurl,'_self');
        
   }

   getOrderCount(){
        getCountOfOrders({soldToId: this.soldtoid, status: 'Submitted'})
        .then(result=>{
            if(result.length ===1){
                this.reviewOrderCount = '0'+result;
            }else{
                this.reviewOrderCount = result;
            }
        })
        .catch(error => {
            this.error = error;
            
        });
   }

   getOrderCountEU(){
    getCountOfOrdersEU({soldToId: this.soldtoid})
    .then(result=>{
        if(result){
            for (const key in result) {
                if(key===TCP_CurrentOrderLabel+TCP_OrderLabel){
                    this.myCurrentOrderCountEU = result[key];
                }
                if(key===TCP_PreviousOrdersLabel){
                    this.previousCountEU = result[key];
                }
                if(key===TCP_RejectLabel+TCP_CancelledOrderLabel){
                    this.rejectCancelledCountEU =result[key];
                }
            }
        }
    })
    .catch(error => {
        this.error = error;
        
    });
}

getOrderCountCU(accountIds){
    this.isLoading = true;
    
    getCountOfOrdersCU({soldToIds: accountIds})
    .then(result=>{
        if(result){
            for (const key in result) {
                if(key===TCP_ReviewOrApprovalLabel+TCP_ApprovalLabel){
                    this.reviewOrderCount = result[key];
                }
                if(key===TCP_ModificationOrCancelLabel+TCP_CancellationReqLabel){
                    this.modifyCancelCountCU = result[key];
                }
                if(key===TCP_PreviousOrdersLabel){
                    this.previousCountCU =result[key];
                }
                if(key===TCP_CurrentOrderCULabel){
                    this.myCurrentOrderCountCU =result[key];
                }
            }
            this.isLoading = false;
        }
    })
    .catch(error => {
        window.console.log('Catch:'+JSON.stringify(accountIds));
        this.isLoading = false;
        this.error = error;
        
    });
}
  
   dashboardClick(){
    document.title = this.docTitleHome;
    var wonumber =  this.currentPageReference.state.c__wonumber;
    if(wonumber){
        this.handleViewOrderCUBack2();
    }
    this.dashboard =   true;
    this.orderhistory =  false;
    this.viewOrderDetailCU = false;
    this.viewOrderDetailEU = false;
    this.tcpReviewOrderDetailCU=false;
    this.placeorder = false;
    this.viewAllDocumentsCU=false;
    this.modifyOrderEU = false;
  
    if(this.logOnAsTCP){
        this.initialLoadTileHomePage = TCP_ReviewOrApprovalLabel+TCP_ApprovalLabel;
        this.commopsUserTabel=true;
        this.selectedCustMap.clear();
        this.customerSelectText = this.defaultCustText;
    }else{
        this.initialLoadTileHomePage=TCP_CurrentOrderLabel+TCP_OrderLabel;
        this.endUserTable=true;
    }
    if(this.filterdata && this.filterdata.length >0){
        this.filterdata = [];
    }
    this.callOrdConfirmService();
    this.callGSAPService();
    
    
}

   orderHistoryClick(){
        document.title = this.docTitle;
        this.checkForWOnumber();
        this.dashboard = false;
        this.placeorder = false;
        this.viewOrderDetailCU = false;
        this.viewOrderDetailEU = false;
        this.tcpReviewOrderDetailCU=false;
        this.endUserTable=false;
        this.commopsUserTabel=false;
        this.initialLoadTileHomePage=this.ordHistoryLabel;
        this.viewAllDocumentsCU=false;
        this.modifyOrderEU = false;
        this.orderhistory = true;

        if(this.filterdata && this.filterdata.length >0){
            this.filterdata = [];
        }
        this.callOrdConfirmService();
        this.callGSAPService();
   }

   viewOrderDetailClick(){

        this.dashboard = false;
        this.placeorder = false;
        this.orderhistory = false;
        this.viewOrderDetailCU = false;
        this.viewOrderDetailEU = true;
        
   }

   callGSAPService(){
        if(this.soldtoid && !this.logOnAsTCP){
        fetchGSAPCurrentOrders({soldToId : this.soldtoid})
        .then(result=>{

        })
        .catch(error => {
            this.error = error;
            window.console.log('ERROR in calling GSAP Service====>'+JSON.stringify(this.error));
        });
        }
   }

   callOrdConfirmService(){
    if(this.soldtoid && !this.logOnAsTCP){
    fetchGSAPOrderConfirmationdetails({soldToId : this.soldtoid})
    .then(result=>{
    
    })
    .catch(error => {
        this.error = error;
        window.console.log('ERROR in calling order confirmation Service====>'+JSON.stringify(this.error));
    });
    }
}

   scrollToTopOfPage(){
    window.scrollTo(0,0);
   }

   getOrderwithWebOrderNumber(webordnumber){
       //call apex method
       getOrderDetailsByWONumber({woNumber : webordnumber})
        .then(result=>{
            var recordData = result;
            
            if(result){
                
                this.orderDetailData = recordData[0];
                this.commopsUserTabel = false;
                this.dashboard =  false;
                this.orderhistory=false;
                this.endUserTable=false;
                if(this.logOnAsTCP){
                    
                    this.viewOrderDetailCU2 = true;
                }
                else{
                    
                    this.viewOrderDetailEU2=true;
                }

                this.iswebemailvar = 'yes';
                    this.modifyOrderEU = false;
                    this.scrollToTopOfPage();
            }
            else{
                
                this.hasAccessOrder = true;
                setTimeout(() => {
                    this.hasAccessOrder = false;
                }, 6000); 
            }
            
        })
        .catch(error => {
            this.error = error;
            window.console.log('error in web order details'+JSON.stringify(this.error));
        });
   }

   //check if URL contains webordernumber and redirect
   checkForWOnumber(){
       var wonumber =  this.currentPageReference.state.c__wonumber;
        
        var baseurltemp = window.location.href;
        const baseurl = baseurltemp.substring(0, baseurltemp.indexOf('?'));
        window.console.log('base ur::'+baseurl);
        if(wonumber){
            this.viewOrderDetailCU2 = false;
            this.viewOrderDetailEU2 = false;
            this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: baseurl
                    }
                },
                true // Replaces the current page in your browser history with the URL
            );

        }

          
   }
   checkForWOnumberUrl(){
    var wonumber =  this.currentPageReference.state.c__wonumber;
     
     var baseurltemp = window.location.href;
     const baseurl = baseurltemp;
     if(wonumber){
        this.dashboard=false;
        this.endUserTabel=false;
         this.viewOrderDetailCU2 = false;
         this.viewOrderDetailEU2 = true;
         this[NavigationMixin.Navigate]({
                 type: 'standard__webPage',
                 attributes: {
                     url: baseurl
                 }
             },
             true // Replaces the current page in your browser history with the URL
         );

     }
     else{
        this.dashboard =  true;
        this.scrollToTopOfPage();
        this.endUserTable = true;
     }

       
}


handleBulkOrder(){
    const pageName = communityBasePath + '/bulkOrder';
    
    this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: pageName
        }
    });
}

}