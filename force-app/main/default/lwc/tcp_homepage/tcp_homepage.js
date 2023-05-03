import { LightningElement,track, wire ,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import communityBasePath from '@salesforce/community/basePath'; 
//import { sitecommunityurl } from '@salesforce/community/property';

import TCP_close_icon from '@salesforce/resourceUrl/TCP_close_icon';
import TCP_Placeholder from '@salesforce/resourceUrl/TCP_Placeholder';
import TCP_forwardIcon from '@salesforce/resourceUrl/TCP_forwardIcon';
import TCP_rightCircleArrow from '@salesforce/resourceUrl/TCP_rightCircleArrow';
import TCP_cross_icon from '@salesforce/resourceUrl/TCP_cross_icon';
import TCP_PlaceholderSmall from '@salesforce/resourceUrl/TCP_PlaceholderSmall';
import TCP_search from '@salesforce/resourceUrl/TCP_search';
import TCP_filter from '@salesforce/resourceUrl/TCP_filter';
import TCP_Action from '@salesforce/resourceUrl/TCP_Action';
import TCP_downArrow from '@salesforce/resourceUrl/TCP_downArrow';
import TCP_grid_icon from '@salesforce/resourceUrl/TCP_grid_icon';
import TCP_rows_icon from '@salesforce/resourceUrl/TCP_rows_icon';
import TCP_file_icon from '@salesforce/resourceUrl/TCP_file_icon';
import TCP_list_icon from '@salesforce/resourceUrl/TCP_list_icon';
import TCP_person_icon from '@salesforce/resourceUrl/TCP_person_icon';
import TCP_comment_icon from '@salesforce/resourceUrl/TCP_comment_icon';
import TCP_send_icon from '@salesforce/resourceUrl/TCP_send_icon';
import TCP_refresh_icon from '@salesforce/resourceUrl/TCP_refresh_icon';
import TCP_time_icon from '@salesforce/resourceUrl/TCP_time_icon';
import TCP_eye_icon from '@salesforce/resourceUrl/TCP_eye_icon';
import TCP_download_icon from '@salesforce/resourceUrl/TCP_download_icon';
import TCP_circleArrow from '@salesforce/resourceUrl/TCP_circleArrow';
import TCP_bell_icon from '@salesforce/resourceUrl/TCP_bell_icon';
import TCP_RoundCheck_icon from '@salesforce/resourceUrl/TCP_RoundCheck_icon';
import TCP_RoundClose_icon from '@salesforce/resourceUrl/TCP_RoundClose_icon';
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





export default class Tcp_homepage extends NavigationMixin (LightningElement) {

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
    
    TCP_close_icon=TCP_close_icon;
    TCP_Placeholder=TCP_Placeholder;
    TCP_forwardIcon=TCP_forwardIcon;
    TCP_rightCircleArrow=TCP_rightCircleArrow;
    TCP_cross_icon=TCP_cross_icon;
    TCP_PlaceholderSmall=TCP_PlaceholderSmall;
    TCP_search=TCP_search;
    TCP_filter=TCP_filter;
    TCP_Action=TCP_Action;
    TCP_downArrow=TCP_downArrow;
    TCP_grid_icon=TCP_grid_icon;
    TCP_rows_icon=	TCP_rows_icon;
    TCP_file_icon=	TCP_file_icon;
    TCP_list_icon= TCP_list_icon;
    TCP_person_icon= TCP_person_icon;
    TCP_comment_icon=TCP_comment_icon;
    TCP_send_icon=TCP_send_icon;
    TCP_refresh_icon=TCP_refresh_icon;
    TCP_time_icon=TCP_time_icon;
    TCP_eye_icon=TCP_eye_icon;
    TCP_download_icon=TCP_download_icon;
    TCP_circleArrow=TCP_circleArrow;
    TCP_bell_icon=TCP_bell_icon;
    TCP_RoundCheck_icon=TCP_RoundCheck_icon;
    TCP_RoundClose_icon=TCP_RoundClose_icon;

    @track dashboard = true;
    @track placeorder = false;
    @track reorderoverlay=false;
    @track orderhistory = false;
    @track userId = uId;
    @track accountData = [];
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
    

    constructor(){
        super();
        loggedInAsTcpUser().then(result => {
            this.logOnAsTCP = result;
            window.console.log('logged in user commops: '+this.logOnAsTCP);
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.name = undefined;
        });
    
    }
    
    renderedCallback(){
        
        if(this.logOnAsTCP && this.oneTimeLoad){
            let target = this.template.querySelector('.reviewOrderCount');
            if(target && target != null){
                target =  target.classList.add('boxHighlight');
                this.oneTimeLoad = false;
            }  
        }else if(!this.logOnAsTCP && this.oneTimeLoad && this.logOnAsTCP != undefined){
            let target = this.template.querySelector('.myCurrentOrderEU');
            if(target && target != null){
                target =  target.classList.add('boxHighlight');
                this.oneTimeLoad = false;
            } 
        }

        //document.title = 'Home';
        
    }


    connectedCallback() {      
        var wonumber =  this.currentPageReference.state.c__wonumber;
        var pageNavigate =  this.currentPageReference.state.navigateTo;
        
        
        if(wonumber){
            
            this.getOrderwithWebOrderNumber(wonumber);

        }
        if(pageNavigate=='Ohistory'){
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


   @wire(getAccountDetails)
    wiredAccounts({data, error}){
        this.isLoading = true;
        if(data){
            
            for (let key in data) {
                this.accountData = data;
                const option = {
                label : data[key].Name,
                value : data[key].Id
                };
                this.customerOptions = [...this.customerOptions, option];
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
                this.getOrderCountCU();
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
            this.error = undefined;
            
        }
        else if (error) {
            this.isLoading = false;
            this.error = error; 
            window.console.log('ERROR====>'+JSON.stringify(this.error));
        }
    }

    handleChange(event) {
        this.isLoading = true;
        this.value = event.detail.value;
        this.parentaccid = this.value;
        this.soldtoid = this.value;
        this.callOrdConfirmService();
        this.callGSAPService();

        if(this.logOnAsTCP){    
            this.endUserTable = false;
            this.commopsUserTabel=true;
            this.getOrderCountCU();
            document.title = 'TCP | Home';
            this.template.querySelector('c-tcp_-all-orders-c-u').handleDataOnSoldtoChange(this.soldtoid);
        }else{
            this.endUserTable = true;
            this.commopsUserTabel = false;
            document.title = 'TCP | Home';
            this.getOrderCountEU();
        }

        setTimeout(() => {
            this.isLoading = false;
        }, 2000);
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
        const isInputsCorrect = [...this.template.querySelectorAll(screenName)]
        .reduce((validSoFar, inputField) => {        
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
        }, true);
        return isInputsCorrect;
    }

   handlePlaceorder(event){
        this.reorderoverlay = false;
        this.placeorder=false;
        let typeInfo = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        if(typeInfo==='Order History'){ 
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = false;
        this.orderhistory=true;
        this.scrollToTopOfPage(); 
        document.title = 'TCP | Order History';
        }else{
        this.dashboard =  true;
        this.scrollToTopOfPage();
        if(typeInfo){
            this.initialLoadTileHomePage=typeInfo;
            } 
        this.endUserTable = true;
        document.title = 'TCP | Home';
    }
   }

   
   handlemodifyordereu(event){
        this.modifyOrderEU =  false;
        this.scrollToTopOfPage();
        let type = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        this.actionType = event.detail.status;
        if(type=='Order History'){
                this.initialLoadTileHomePage=type;
                this.orderhistory=true;
                document.title = 'TCP | Order History';
                this.scrollToTopOfPage();
        }else{
                this.scrollToTopOfPage();
                this.dashboard =  true;
                this.initialLoadTileHomePage=type;
                this.endUserTable = true;
                document.title = 'TCP | Home';
        }
    }

   handleSaveOrder(event){
    this.showOrderNumber = true;
    this.orderNumber = event.detail.ordernumber;
    let status = event.detail.status;
    this.filterdata = event.detail.filtereudata;
    let typeInfo = event.detail.type;
    
    this.reorderoverlay = false;
    this.placeorder =  false;
    if(status === 'Draft'){
        this.hasDraftOrder = true;
    }else if(status === 'Submitted'){
        this.hasSubmitted = true;
    }
    if(typeInfo==='Order History'){ 
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = false;
        this.orderhistory=true;
        this.scrollToTopOfPage(); 
        document.title = 'TCP | Order History';
        }else{
        this.dashboard =  true;
        document.title = 'TCP | Home';
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
    let status = event.detail.status;
        this.hasSubmitted = true;
        this.endUserTable = true;
       
    this.dashboard =   true;
    document.title = 'TCP | Home';
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
        this.template.querySelector('.reviewOrderCount').classList.add('boxHighlight');
        this.template.querySelector('.modifyCancelCountCU').classList.remove('boxHighlight');
        this.template.querySelector('.myCurrentOrderCountCU').classList.remove('boxHighlight');
        this.template.querySelector('.previousCountCU').classList.remove('boxHighlight');
        this.endUserTable = false
        this.template.querySelector('c-tcp_-all-orders-c-u').handleData(TCP_ReviewOrApprovalLabel+TCP_ApprovalLabel);
   }

   handleModifyCancelCU(){
        document.title = 'TCP | Modification/Cancellation Requests';
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector('.reviewOrderCount').classList.remove('boxHighlight');
        this.template.querySelector('.myCurrentOrderCountCU').classList.remove('boxHighlight');
        this.template.querySelector('.previousCountCU').classList.remove('boxHighlight');
        this.template.querySelector('.modifyCancelCountCU').classList.add('boxHighlight');
        this.commopsUserTabel = true;
        this.endUserTable = false
        this.getOrderCountCU();
        this.template.querySelector('c-tcp_-all-orders-c-u').handleData(TCP_ModificationOrCancelLabel+TCP_CancellationReqLabel);
    }

    handleCurrentOrderCU(){
        document.title = 'TCP | Current Orders';
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector('.myCurrentOrderCountCU').classList.add('boxHighlight');
        this.template.querySelector('.reviewOrderCount').classList.remove('boxHighlight');
        this.template.querySelector('.previousCountCU').classList.remove('boxHighlight');
        this.template.querySelector('.modifyCancelCountCU').classList.remove('boxHighlight');
        this.commopsUserTabel = true;
        this.endUserTable = false
        this.template.querySelector('c-tcp_-all-orders-c-u').handleData(TCP_CurrentOrderCULabel);

    }

    handlePreviousCU(){
        document.title = 'TCP | Previous Orders';
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector('.myCurrentOrderCountCU').classList.remove('boxHighlight');
        this.template.querySelector('.reviewOrderCount').classList.remove('boxHighlight');
        this.template.querySelector('.previousCountCU').classList.add('boxHighlight');
        this.template.querySelector('.modifyCancelCountCU').classList.remove('boxHighlight');
        this.commopsUserTabel = true;
        this.endUserTable = false
        
        this.template.querySelector('c-tcp_-all-orders-c-u').handleData(TCP_PreviousOrdersLabel);

    }

   handleMyCurrentOrderEU(){
        document.title = 'TCP | My Current Orders';
        
        this.commopsUserTabel = false;
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector('.myCurrentOrderEU').classList.add('boxHighlight');
        this.template.querySelector('.rejectCancelledCountEU').classList.remove('boxHighlight');
        this.template.querySelector('.previousCountEU').classList.remove('boxHighlight');
        this.endUserTable = true
        
        this.template.querySelector('c-tcp_-all-orders-e-u').handleData(TCP_CurrentOrderLabel+TCP_OrderLabel);
    }

   handlePreviousOrder(){
    document.title = 'TCP | Previous Orders';
        
        this.commopsUserTabel = false;
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector('.previousCountEU').classList.add('boxHighlight');
        this.template.querySelector('.myCurrentOrderEU').classList.remove('boxHighlight');
        this.template.querySelector('.rejectCancelledCountEU').classList.remove('boxHighlight');

        this.endUserTable = true
        this.template.querySelector('c-tcp_-all-orders-e-u').handleData(TCP_PreviousOrdersLabel);

    }

   handleRejectedCancelledOrder(){
        document.title = 'TCP | Rejected/Cancelled Orders';
        
        this.commopsUserTabel = false;
        this.tcpReviewOrderDetailCU = false;
        this.template.querySelector('.rejectCancelledCountEU').classList.add('boxHighlight');
        this.template.querySelector('.myCurrentOrderEU').classList.remove('boxHighlight');
        this.template.querySelector('.previousCountEU').classList.remove('boxHighlight');
        this.endUserTable = true
       
        this.template.querySelector('c-tcp_-all-orders-e-u').handleData(TCP_RejectLabel+TCP_CancelledOrderLabel);

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
    if(this.orderDetailData.status=='Draft'){
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
    if(event.detail.type == 'View All Docs'){
        this.viewAllDocumentsCU = true;
        this.scrollToTopOfPage();

    }else{
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

    if(event.detail.type == 'Modify Order'){
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
    this.getOrderCountCU();
    this.callOrdConfirmService();
    this.callGSAPService();
   }

   handleOrderDetailback(event){
    let status = event.detail.status;
    let type = event.detail.type;
    this.tcpReviewOrderDetailCU = false;
    this.endUserTable = false;
    this.filterdata = event.detail.filtercudata;
    if(type==='Order History'){
            this.initialLoadTileHomePage=type;
            this.commopsUserTabel = false;
            this.orderhistory=true;
            document.title = 'TCP | Order History';
            this.scrollToTopOfPage();
        }else{
            this.scrollToTopOfPage();
            this.dashboard =  true;
            this.initialLoadTileHomePage=type;
            this.commopsUserTabel = true;
            document.title = 'TCP | Home';
        } 
        
    if(status == 'Approved'){
        this.orderNumber = event.detail.ordernumber;
        this.hasApprovedOrder = true;
        this.showOrderNumber = true;
        this.scrollToTopOfPage();
        setTimeout(() => {
            this.showOrderNumber = false;
            this.hasApprovedOrder = false;
        }, 6000);
    }else if(status =='Approved GSAP'){
        this.orderNumber = event.detail.ordernumber;
        this.showGSAPOrderNumber = true;
        this.hasApprovedGSAPOrder = true;
        this.scrollToTopOfPage();
        setTimeout(() => {
            this.hasApprovedGSAPOrder = false;
            this.showGSAPOrderNumber = false;
        }, 6000);
    }else if(status =='Rejected'){
        this.orderNumber = event.detail.ordernumber;
        this.hasRejectedOrder = true;
        this.scrollToTopOfPage();
        setTimeout(() => {
            this.hasRejectedOrder = false;
        }, 6000);
    }else if(status =='Approved Cancel'){
        this.orderNumber = event.detail.ordernumber;
        this.hasCommopsCancelApproved = true;
        this.showOrderNumber = true;
        this.scrollToTopOfPage();
        setTimeout(() => {
            this.showOrderNumber = false;
            this.hasCommopsCancelApproved = false;
        }, 6000);
    }
    if(status == 'Approved' || status == 'Rejected' || status =='Approved Cancel' || status =='Approved GSAP'){
        this.getOrderCountCU();
    }    
   }

   handleViewOrderEUBack(event){
    let status = event.detail.status;
    if(status == 'back'){
        this.viewOrderDetailEU = false;
        let typeInfo = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        if(typeInfo==='Order History'){ 
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = false;
        this.orderhistory=true;
        document.title = 'TCP | Order History';
        this.scrollToTopOfPage(); 
        }else{
        this.dashboard =  true;
        this.scrollToTopOfPage();
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = true;
        document.title = 'TCP | Home';
    }
    }
   }

   handleReOrderBack(event){
    
    
        this.reorderoverlay = false;
        this.placeorder=false;
        let typeInfo = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        if(typeInfo==='Order History'){ 
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = false;
        this.orderhistory=true;
        document.title = 'TCP | Order History';
        this.scrollToTopOfPage(); 
        }else{
        this.dashboard =  true;
        this.scrollToTopOfPage();
        this.initialLoadTileHomePage=typeInfo;
        this.endUserTable = true;
        document.title = 'TCP | Home';
    }
   }

   handleCancelOrderEUBack(event){
   
    this.orderNumber = event.detail.data;
        this.viewOrderDetailEU = false;
        let typeInfo = event.detail.type;
        this.filterdata = event.detail.filtereudata;
        if(typeInfo==='Order History'){ 
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
        document.title = 'TCP | Order History';
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
        document.title = 'TCP | Home';
        
    }
    setTimeout(() => {
        this.hasCancelledOrder = false;
        this.hasSubmitted = false;
        this.hasSubmitted2=false;
       
    }, 6000);
    
   }

   handleViewOrderEUBack2(event){
    let status = event.detail.status;
    if(status == 'back'){
        this.dashboard =  true;
        this.scrollToTopOfPage();
        this.endUserTable = true;
        this.checkForWOnumber();
        document.title = 'TCP | Home';
    }
   }
  

   handleViewOrderCUBack(event){
    let status = event.detail.status;
    if(status == 'back'){
        this.viewOrderDetailCU = false;
        let typeInfo = event.detail.type;
        this.filterdata = event.detail.filtercudata;
        if(typeInfo==='Order History'){
            this.initialLoadTileHomePage=typeInfo;
            this.commopsUserTabel = false;
            this.orderhistory=true;
            document.title = 'TCP | Order History';
            this.scrollToTopOfPage();
        }else{
            this.dashboard =  true;
            this.scrollToTopOfPage();
            this.initialLoadTileHomePage=typeInfo;
            this.commopsUserTabel = true;
            document.title = 'TCP | Home';
        }
    }
   }

   handleViewOrderCUBack2(event){
    var baseurltemp = window.location.href;
    const baseurl = baseurltemp.substring(0, baseurltemp.indexOf('?'));
    window.open(baseurl,'_self');
    // let status = event.detail.status;
    // if(status == 'back'){
    //     this.viewOrderDetailCU2 = false;
    //     let typeInfo = event.detail.type;
    //     window.console.log('back button -- clicked:'+typeInfo);
    //     this.initialLoadTileHomePage=typeInfo;
    //     this.commopsUserTabel = true;
    //     this.dashboard =  true;
    //     this.scrollToTopOfPage();
    //     this.checkForWOnumber();
    // }
        
   }

   getOrderCount(){
        getCountOfOrders({soldToId: this.soldtoid, status: 'Submitted'})
        .then(result=>{
            if(result.length ==1){
                this.reviewOrderCount = '0'+result;
            }else{
                this.reviewOrderCount = result;
            }
        })
        .catch(error => {
            this.error = error;
            window.console.log("ERROR in getting details: "+this.error);
        });
   }

   getOrderCountEU(){
    getCountOfOrdersEU({soldToId: this.soldtoid})
    .then(result=>{
        if(result){
            for (let key in result) {
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
        window.console.log("ERROR in getting details: "+this.error);
    });
}

getOrderCountCU(){
    getCountOfOrdersCU({soldToId: this.soldtoid})
    .then(result=>{
        if(result){
            for (let key in result) {
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
        }
    })
    .catch(error => {
        this.error = error;
        window.console.log("ERROR in getting details: "+this.error);
    });
}
  
   dashboardClick(){
    document.title = 'TCP | Home';
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
        document.title = 'TCP | Order History';
        this.checkForWOnumber();
        this.dashboard = false;
        this.placeorder = false;
        this.viewOrderDetailCU = false;
        this.viewOrderDetailEU = false;
        this.tcpReviewOrderDetailCU=false;
        this.endUserTable=false;
        this.commopsUserTabel=false;
        this.initialLoadTileHomePage='Order History';
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
        if(this.soldtoid){
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
    if(this.soldtoid){
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
       getOrderDetailsByWONumber({WONumber : webordnumber})
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