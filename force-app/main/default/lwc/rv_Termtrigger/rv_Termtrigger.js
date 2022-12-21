/**
 * --------------Created by Dhriti.GhoshMoulick on 8/9/2021.
 */

 import { LightningElement,api,track,wire } from 'lwc';
 import getPickListValuesMonth from '@salesforce/apex/RV_TermTriggerClass.getPickListValuesMonth';
 import getPickListValuesYear from '@salesforce/apex/RV_TermTriggerClass.getPickListValuesMonth';
 import fetchTermTriggerDeal from '@salesforce/apex/RV_TermTriggerClass.fetchTermTriggerDeal1';
 import saveTermTriggerDeal from '@salesforce/apex/RV_TermTriggerClass.saveTermTriggerDeal1';
 import confirmTermTriggerDeal from '@salesforce/apex/RV_TermTriggerClass.confirmTermTriggerDeal';
 import deleteSHTRecord from '@salesforce/apex/RV_TermTriggerClass.deleteTermTriggerDeal';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import {subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
 import refreshDataChannel from '@salesforce/messageChannel/Rv_DiPublishSearchFilter__c';
 import getUserListNames from '@salesforce/apex/RV_TermTriggerClass.getUserList';
 export default class RvTermtrigger extends LightningElement {
     subscription = null;
     @track activeSections = 'A';
     @track monthOptions;
     @track yearOptions;
     @track filterStartDate;
     @track filterEndDate;
     @track fieldLabelName;
     @track masterTriggerData = [];
     @track filteredMasterTriggerData = [];
     @track savedMasterTriggerSHTData = [];
     @track completedMasterTriggerSHTData = [];
     @track monthValue;
     @track yearValue;
     //@track renderCreateDealMasterTable = false;
     //@track renderSavedDealMasterTable = false;
     //@track renderCmpltdDealMasterTable = false;
       @track renderCreateDealMasterTable = true;
     @track renderSavedDealMasterTable = true;
     @track renderCmpltdDealMasterTable = true;
     @track filteredMonth;
     //Trigger contacts 25 and above
    @track filteredMonth1;
    @track renderCreateDealMasterTableFuture = false;
     //Trigger contacts 25 and above
     @track filteredYear;
     @track saveSHTRecords;
     @track isLoading = false;
     @track isConfirmLoading = false;
     @track completedDealsData = true;
     @track saveDealsData = true;
     @track useAdvancedFilter;
     @track internetSales;
     @track sAdvanceFilter;
     @track startDate;
     @track endDate;
     @track createdOn = 'TODAY';
     @track advStatus = 'Completed';
     @track startDte;
     @track endDte;
     @track advSoldTo = 'ALL';
     @track advShtNo = 'ALL';
     @track advpoType = 'ALL';
     @track useritems = [];
 
     @track priceMarketViewTab = false;
     @track dealEntryViewTab = false;
     @track termTriggerTab = false;
     @track sectionLabel = "Show";
     @track show = false;
     @track salesOrg;
     @track shipToNumber;
     @track retailMix;
     @api parentMessage;

     @track activeTab = 'TSFP_PM';
     @track customerName;
     isDisabled = false;
     completedDealCss = 'slds-size_12-of-12';
     
     handleToggleChange(event){
         //console.log('show::'+event.detail.value);
         if(!this.show){
             this.show = true;//event.detail.value;
             this.sectionLabel = "Hide";
             this.template.querySelector('[data-id="tabset"]').classList.remove('slds-hide');
         }else if(this.show){
             this.show = false;
             this.sectionLabel = "Show";
             this.template.querySelector('[data-id="tabset"]').classList.add('slds-hide');
         }
     }
 
     handleTab(event){
         if(event.target.name='termTrigger'){
             console.log(event.target.name);
             if(!this.termTriggerTab){
                 this.termTriggerTab = true;
                 this.priceMarketViewTab = false;
                 this.dealEntryViewTab = false;
            } else if(this.termTrigger){
                 this.termTrigger = false;
             }
         }
         if(event.target.name='DealEntryView'){
             if(!this.dealEntryViewTab){
                 this.termTriggerTab = false;
                 this.priceMarketViewTab = false;
                 this.dealEntryViewTab = true;
            } else if(this.dealEntryViewTab){
                 this.dealEntryViewTab = false;
             }
         }
 
         if(event.target.name='priceMarketView'){
             if(!this.priceMarketViewTab){
                 this.termTriggerTab = false;
                 this.priceMarketViewTab = true;
                 this.dealEntryViewTab = false;
            } else if(this.priceMarketViewTab){
                 this.priceMarketViewTab = false;
             }
         }
        
     }
 
     @wire(MessageContext)
             messageContext;
 
      /* @wire(getUserListNames)
         wiredUserNames({ error, data }) {
             console.log('get user record**'+JSON.stringify(data));
            // console.log('user count::'+data);
             if (data) {
                 var usersLst=[];
                 for (var key in data) 
                 {
                     if (data.hasOwnProperty(key)) {
                         usersLst.push({value: key, label: data[key]});
                     }
                 }
                 this.createdByOptions = usersLst;                                  
             } else if (error) {
                 this.error = error;
                 this.createdByOptions = undefined;
             }
         }*/
     connectedCallback(){
         var today = new Date();
         this.startDate=today.toISOString();
         console.log('in advance filter::'+today.toISOString());
         this.endDate = today.toISOString();
         //var last=new Date(new Date().getFullYear(), 11, 32);
         var date=new Date();
                     var first1 = date.substring(0,2);
                     var second2 = date.substring(2,4);
                     var third3= date.substring(4,8);
                     var date1=third3+'-'+second2+'-'+first1;
                     this.startDate=date1;
                     console.log('in advance filter::'+this.startDate);
 
     }
     /*connectedCallback(){
         this.subscribeToMessageChannel();
     }*/
     disconnectedCallback(){
         this.unsubscribeToMessageChannel();
     }
 
     subscribeToMessageChannel(){
             console.log('Subscribe');
             if(!this.subscription && this.messageContext !=null){
 
                 this.subscription = subscribe(
 
                     this.messageContext,
 
                     refreshDataChannel,
 
                     (message) => this.recieveData(message),
 
                     {
                         
                         scope: APPLICATION_SCOPE
 
                     }
 
                 );
                 //console.log('message in dealentry view:'+message);
             }
         
     }
 
     unsubscribeToMessageChannel(){
 
             unsubscribe(this.subscription);
             this.subscription = null;
 
      }
    
    loadDeals( event ) {
        var dealEntryTemp = this.template.querySelector("c-rv_dealentryview");
        //console.log('dealEntryTemp:'+dealEntryTemp);
        if(dealEntryTemp!=null && dealEntryTemp!=''){
            console.log('Inside dealEntryTemp -- this.parentMessage:'+JSON.stringify(this.parentMessage));
            this.template.querySelector("c-rv_dealentryview").recieveData(this.parentMessage);
        }
        /*
        if(event.detail=='MessageFromDealEntry'){
            console.log('this.parentMessage:'+JSON.stringify(this.parentMessage));
            this.template.querySelector("c-rv_dealentryview").recieveData(this.parentMessage);
        }
        */
        //this.strOutput = event.detail;
    }
     /*
     handlePriceMarketClick(){
         this.template.querySelector('[data-id="priceMarketComponent"]').classList.remove('slds-hidden');
         this.template.querySelector('[data-id="dealEntryComponent"]').classList.add('slds-hidden');
         this.template.querySelector('[data-id="triggerComponent"]').classList.add('slds-hidden');
     }
     handleDealEntryClick(){
         this.template.querySelector('[data-id="dealEntryComponent"]').classList.remove('slds-hidden');
         this.template.querySelector('[data-id="priceMarketComponent"]').classList.add('slds-hidden');
         this.template.querySelector('[data-id="triggerComponent"]').classList.add('slds-hidden');
     }
     handleTriggerClick(){
         this.template.querySelector('[data-id="triggerComponent"]').classList.remove('slds-hidden');
         this.template.querySelector('[data-id="priceMarketComponent"]').classList.add('slds-hidden');
         this.template.querySelector('[data-id="dealEntryComponent"]').classList.add('slds-hidden');
     }*/
     recieveData(message){
         console.log('recieve data:::'+JSON.stringify(message));
         this.parentMessage = message; 
         console.log('this.parentMessage:'+this.parentMessage);
             console.log(message.eventType);
             if(message.eventType === 'search'){//'search' for search MRC and 'publish' for custom info section
                     console.log('Parent message in term trigger:'+message);
                      //this.recordId = message.customerId; // for customer info section
 
                      let filterObj = message.filterData; // for search MRC section
                     console.log('at recieveData::'+JSON.stringify(filterObj));
                     this.activeTab = (filterObj.poType == "TTTT" || filterObj.poType == "TTTI") ? "TTTT" : "TSFP_PM";
                     this.filterStartDate = filterObj.startDate;
                     this.filterEndDate = filterObj.endDate;
                     this.salesOrg = filterObj.salesOrg;
                     this.shipToNumber = filterObj.shipToNum;
                     this.retailMix = filterObj.retailMix;
                     if((filterObj.poType === "TTTT"  || filterObj.poType == "TTTI") ){
                        this.customerName = 'CUSTOMER(S) : '+ filterObj.customerName;
                     }
                     
                     if(this.filterStartDate){
                             let startDate = this.filterStartDate;
                             const startDateLst = startDate.split("-");
                             ////Trigger contacts 25 and above
                            if(startDateLst[2] == '25' || startDateLst[2] == '26' || startDateLst[2] == '27' || startDateLst[2] == '28' || startDateLst[2] == '29' || startDateLst[2] == '30' || startDateLst[2] == '31')
                            {let nextMonth = parseInt(startDateLst[1]) + 1;
                             console.log('nextMonth:::'+nextMonth);
                             let nextmon;
                             if(nextMonth<10){
                             nextmon = nextMonth.toString().padStart(2, '0');
                             console.log('nextmon:::'+nextmon);}
                             this.filteredMonth1 = this.monthName(nextmon);
                             console.log('this.filteredmonth1::'+this.filteredMonth1);
                             ////Trigger contacts 25 and above
                             }
                             this.filteredYear = startDateLst[0];
                             this.filteredMonth = this.monthName(startDateLst[1]);
                      }
                     fetchTermTriggerDeal({
                                         soldToAccId: filterObj.customerRecId,//0012500001RIxDuAAL
                                         //mrcNumber: filterObj.mrcNo,//JSON.stringify(filterObj.mrcNo),
                                         mrcNumber: filterObj.mrcNo,
                                         shipToAccNum : filterObj.shipToNum,//JSON.stringify(filterObj.shipToNum),
                                         mot : filterObj.mot,
                                         energyTax : filterObj.energyTax,
                                         productName : filterObj.product,
                                         poType : filterObj.poType,
                                         plantId :filterObj.depot,// filterObj.depot,//JSON.stringify(filterObj.depot),
                                         salesOrg :filterObj.salesOrg,
                                         startDate : filterObj.startDate,
                                         endDate : filterObj.endDate,
                                         isRetailMixChecked : filterObj.retailMix
                                 })
                                 .then(data => {
                                         console.log('at fetchTermTriggerDeal:'+JSON.stringify(data));
                                         this.masterTriggerData = data;
                                          let groupMonthData = new Map();
                                         this.filteredMasterTriggerData = [];
                                         this.renderCreateDealMasterTable = true;
                                          if(data.hasEditAccess ===  false){
                                            this.isDisabled = true;
                                            this.completedDealCss = 'slds-size_12-of-12 readonly-page';
                                         }
                                           if((filterObj.poType === "TTTT" || filterObj.poType == "TTTI")){
                                         this.customerName = 'CUSTOMER(S) : '+this.masterTriggerData['termTriggerWrapperList'][0]['triggerMasterData']['Sold_to_Name__r']['Name'];
                                         }
                                         //this.customerName = 'CUSTOMER(S) : '+this.masterTriggerData['termTriggerWrapperList'][0]['triggerMasterData']['Sold_to_Name__r']['Name'];
                                         const triggerObj = {};
                                         console.log('Length of returnresponse::'+this.masterTriggerData['termTriggerWrapperList'].length);
                                         //this.masterTriggerData['termTriggerWrapperList'].forEach(triggerData =>{
                                        for(let key in this.masterTriggerData['termTriggerWrapperList']) {
                                            let newTriggerGroup = {};
                                           
                                            newTriggerGroup.Id = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Id;
                                            newTriggerGroup.Name  = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Name;
                                            newTriggerGroup.Sold_to_Name = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Sold_to_Name__c;
                                            newTriggerGroup.Sold_to_Number = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Sold_to_Number__c;
                                            newTriggerGroup.MRC_Number = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__c;
                                            newTriggerGroup.Monthly_volume = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Monthly_volume__c;
                                            newTriggerGroup.Trigger_Month = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Trigger_Month__c;
                                            newTriggerGroup.Trigger_Year = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Trigger_Year__c;
                                            newTriggerGroup.Min_Trigger_Volume = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Min_Trigger_Volume__c;
                                            newTriggerGroup.Max_Trigger_Volume = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Max_Trigger_Volume__c;
                                            newTriggerGroup.Max_number_of_triggers_per_month = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Max_number_of_triggers_per_month__c;
                                            newTriggerGroup.Remaining_triggers = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Remaining_triggers__c;
                                            newTriggerGroup.Remaining_trigger_volume = this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Remaining_trigger_volume__c;
                                            newTriggerGroup.MRC_Number_Name =this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Name;
                                            newTriggerGroup.MRC_Number_Contract =this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Contract__c;
                                            newTriggerGroup.MRC_Number_Material_Description= this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Material_Description__c;
                                            newTriggerGroup.MRC_Number_Product= this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Product__c;
                                            newTriggerGroup.MRC_Number_Ship_to_Number=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Ship_to_Number__c;
                                            newTriggerGroup.MRC_Number_Mode_Of_Transport=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Mode_Of_Transport__c;
                                            newTriggerGroup.MRC_Number_PO_Type=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.PO_Type__c;
                                            newTriggerGroup.MRC_Number_Plant=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Plant__c;
                                            newTriggerGroup.MRC_Number_Id=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Id;
                                            newTriggerGroup.MRC_Number_Plant_Name=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Plant__r.Name;
                                            newTriggerGroup.MRC_Number_Plant_Plant_Code=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c;
                                            newTriggerGroup.MRC_Number_Product_Name=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MRC_Number__r.Product__r.Name;
                                            newTriggerGroup.BSP=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.BSP__c;
                                            newTriggerGroup.MSP=this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.MSP__c;
                                            newTriggerGroup.atpVoltoBeReduced=this.masterTriggerData.termTriggerWrapperList[key].atpVoltoBeReduced;
                                            newTriggerGroup.isGsapDealCancelOn=this.masterTriggerData.termTriggerWrapperList[key].isGsapDealCancelOn;
                                            newTriggerGroup.isGsapDealCreateOn=this.masterTriggerData.termTriggerWrapperList[key].isGsapDealCreateOn;
                                            newTriggerGroup.isPricingTaxed=this.masterTriggerData.termTriggerWrapperList[key].isPricingTaxed;
                                            newTriggerGroup.isVolToBeHedged=this.masterTriggerData.termTriggerWrapperList[key].isVolToBeHedged;
                                            newTriggerGroup.isZeroPriceDeal=this.masterTriggerData.termTriggerWrapperList[key].isZeroPriceDeal;
                                            newTriggerGroup.pricingCondition=this.masterTriggerData.termTriggerWrapperList[key].pricingCondition;
                                            //prod deployment
                                            newTriggerGroup.tranche = this.masterTriggerData.termTriggerWrapperList[key].tranche;
                                           
                                           if(groupMonthData.has(this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Trigger_Month__c)){
                                                groupMonthData.get(this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Trigger_Month__c).push(newTriggerGroup);
                                            }
                                            else{
                                                let triggerGroupList = [];
                                                triggerGroupList=[newTriggerGroup];
                                                console.log('triggerGroupList::'+triggerGroupList+'---'+JSON.stringify(triggerGroupList));
                                               
                                                console.log(this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Trigger_Month__c);
                                                
                                                groupMonthData.set(this.masterTriggerData.termTriggerWrapperList[key].triggerMasterData.Trigger_Month__c,triggerGroupList);
                                              
                                                console.log('triggerObj in else::'+groupMonthData);
                                            }
                                                
                                                
                                            //triggerGroupList=[newTriggerGroup];
                                            /*if(groupMonthData.has(triggerData.Trigger_Month__c)){
                                                groupMonthData.get(triggerData.Trigger_Month__c).push(newTriggerGroup);
                                            }else{
                                                let triggerGroupList = [];
                                                triggerGroupList=[newTriggerGroup];
                                                groupMott5nthData.set(triggerData.Trigger_Month__c,triggerGroupList);
                                               
                                            }*/
                                         }
                                         console.log('tr data::'+[...groupMonthData.entries()]);
                                         //console.log('triggerObj::'+groupMonthData.get('March'));
                                         let mrcArray =[];
                                         groupMonthData.forEach((values,keys)=>{
                                            console.log(JSON.stringify(values)+'--'+ JSON.stringify(keys));
                                            let mrc = {};
                                            mrc.months = keys;
                                            mrc.monthsdata = values;
                                            mrcArray.push(mrc);                      
                                        })

                                        this.filteredMasterTriggerData = mrcArray;
                                        console.log('final result::'+JSON.stringify(this.filteredMasterTriggerData));
                                        
                                         if(this.masterTriggerData.shtList != 'undefined'){
                                             let soldTomap = new Map();
                                             var soldToList = [];
                                             this.savedMasterTriggerSHTData = [];
                                             console.log('SHT no::'+this.masterTriggerData.shtNo);
                                              for(let key in this.masterTriggerData.shtList) {
                                                     if(this.masterTriggerData.shtList[key].Status__c == 'Saved'){
                                                         let matNo = this.masterTriggerData.shtList[key].Material_No__c;
                                                         this.masterTriggerData.shtList[key].Material_No__c =  matNo.substr(matNo.length - 4);
                                                         const startDate = new Date(this.masterTriggerData.shtList[key].Contract_Start__c);
                                                         let mmStartDate = ("0" + (startDate.getMonth() + 1)).slice(-2);
                                                         const formattedStartDate = ("0" + startDate.getDate()).slice(-2)+ '-' + mmStartDate + '-' + startDate.getFullYear();
                                                         this.masterTriggerData.shtList[key].Contract_Start__c = formattedStartDate;
                                                         const endDate = new Date(this.masterTriggerData.shtList[key].Contract_End_Date__c);
                                                         let mmEndDate = ("0" + (endDate.getMonth() + 1)).slice(-2);
                                                         const formattedEndDate = ("0" + endDate.getDate()).slice(-2) + '-' + mmEndDate + '-' + endDate.getFullYear();
                                                         this.masterTriggerData.shtList[key].Contract_End_Date__c = formattedEndDate;
                                                         console.log('Start Date :: ' + formattedStartDate + ' End Date  :: ' + formattedEndDate);
                                                         this.savedMasterTriggerSHTData.push(this.masterTriggerData.shtList[key]);
                                                     }else  if(this.masterTriggerData.shtList[key].Status__c == 'Completed'){
                                                         this.completedMasterTriggerSHTData.push(this.masterTriggerData.shtList[key]);
                                                         //console.log('each deal rec::'+this.masterTriggerData.shtList[key].Customer__c);
                                                        // console.log('each deal rec::'+this.masterTriggerData.shtList[key].Name);
                                                          
                                                     }
                                              }
                                              
                                              var shtNoLst=[];
                                                 for (var key in this.masterTriggerData.shtNo) 
                                                 {
                                                     if ((this.masterTriggerData.shtNo).hasOwnProperty(key)) {
                                                         shtNoLst.push({value: this.masterTriggerData.shtNo[key], label: this.masterTriggerData.shtNo[key]});
                                                     }
                                                 }
                                                 this.shtNoOptions = shtNoLst; 
                                                 //console.log('shtNoOptions::'+JSON.stringify(this.shtNoOptions));
 
                                                 var soldToLst=[];
                                                 for (var key in this.masterTriggerData.soldToList) 
                                                 {
                                                     if ((this.masterTriggerData.soldToList).hasOwnProperty(key)) {
                                                         soldToLst.push({value: this.masterTriggerData.soldToList[key], label: this.masterTriggerData.soldToList[key]});
                                                     }
                                                 }
                                                 this.soldToOptions = soldToLst; 
                                                 //console.log('shtNoOptions::'+JSON.stringify(this.soldToOptions));
 
                                                 var poTypeLst=[];
                                                 for (var key in this.masterTriggerData.poTypeList) 
                                                 {
                                                     if ((this.masterTriggerData.poTypeList).hasOwnProperty(key)) {
                                                         poTypeLst.push({value: this.masterTriggerData.poTypeList[key], label: this.masterTriggerData.poTypeList[key]});
                                                     }
                                                 }
                                                 this.poTypeOptions = poTypeLst; 
                                             // console.log('Compledted deals::'+JSON.stringify(this.completedMasterTriggerSHTData));
                                         }
                                      if((this.savedMasterTriggerSHTData).length == 0){
                                             this.savesDealsData = false;
                                         }else{
                                            this.savesDealsData = true;
                                         }

                                         if((this.savedMasterTriggerSHTData).length > 0){
                                            this.savesDealsData = true;
                                        }
                                     
                                         if(this.completedMasterTriggerSHTData != null){
                                               this.completedDealsData = false;
                                         }
                                         //console.log('filteredMasterTriggerData'+JSON.stringify(this.masterTriggerData.shtList));
                                 })
                                 .catch(error => {
                                       console.log('===error==='+JSON.stringify(error));
                                       //this.renderCreateDealMasterTable = true;

                                 });
                     getPickListValuesMonth({
                                                             objApiName: 'RV_Trigger_Master_Data__c',
                                                             fieldName: 'Trigger_Month__c'
                                                             })
                                 .then(data => {
                                                 this.monthOptions = data;
                                                 let selectedMonthLst;
                                                 const nonSelectedMonthLst = [];
                                                 console.log('filteredMonth'+this.filteredMonth);
                                                 for(let key in this.monthOptions) {
                                                          console.log('this.monthOptions[key]'+this.monthOptions[key].value);
                                                           if(this.filterStartDate){
                                                               /////Trigger contacts 25 and above
                                                               if(this.monthOptions[key].value == this.filteredMonth1){
                                                               selectedMonthLst = this.monthOptions[key];
                                                               }
 
                                                               ////Trigger contacts 25 and above
                                                           if(this.monthOptions[key].value == this.filteredMonth){
                                                                 selectedMonthLst = this.monthOptions[key];
                                                                 this.monthValue = selectedMonthLst.label;
                                                           }else{
                                                                nonSelectedMonthLst.push(this.monthOptions[key]);
                                                           }
                                                           }
                                                 }
                                                // console.log('selectedMonthLst'+JSON.stringify(selectedMonthLst));
                                                // console.log('nonSelectedMonthLst'+JSON.stringify(nonSelectedMonthLst));
                                                 this.monthOptions = [];
                                                 this.monthOptions.push(selectedMonthLst);
                                                console.log('SelectedMonthLst'+JSON.stringify( this.monthOptions));
                                                 console.log('NonSelectedMonthLst'+JSON.stringify(nonSelectedMonthLst));
                                                 for(let key in nonSelectedMonthLst) {
                                                     this.monthOptions.push(nonSelectedMonthLst[key]);
                                                 }
 
                                                 console.log('Final'+JSON.stringify( this.monthOptions));
                                             })
                                 .catch(error => {
                                       this.displayError(error);
                                 });
                         getPickListValuesYear({
                                                             objApiName: 'RV_Trigger_Master_Data__c',
                                                             fieldName: 'Trigger_Year__c'
                                                             })
                                 .then(data => {
                                                                     this.yearOptions = data;
                                                                     let selectedYearLst;
                                                                     const nonSelectedYearLst = [];
                                                                     console.log('filteredYear'+this.filteredYear);
 
                                                                     for(let key in this.yearOptions) {
                                                                              //console.log('this.yearOptions[key]'+this.yearOptions[key].label);
                                                                               if(this.filterStartDate){
                                                                               if(this.yearOptions[key].label == this.filteredYear){
                                                                                     selectedYearLst = this.yearOptions[key];
                                                                                     this.yearValue = selectedYearLst.label;
                                                                               }else{
                                                                                    nonSelectedYearLst.push(this.yearOptions[key]);
                                                                               }
                                                                               }
                                                                     }
                                                                     //console.log('selectedYearLst'+JSON.stringify(selectedYearLst));
                                                                    // console.log('nonSelectedYearLst'+JSON.stringify(nonSelectedYearLst));
                                                                     this.yearOptions = [];
                                                                     this.yearOptions.push(selectedYearLst);
                                                                     //console.log('selectedYearLst'+JSON.stringify( this.yearOptions));
                                                                    // console.log('nonSelectedYearLst'+JSON.stringify(nonSelectedYearLst));
                                                                     for(let key in nonSelectedYearLst) {
                                                                         this.yearOptions.push(nonSelectedYearLst[key]);
                                                                     }
                                                             })
                                 .catch(error => {
                                       this.displayError(error);
                                 });
                                 
                                 if(filterObj.showAvailableOffers){
                                     this.show = true;
                                     this.sectionLabel = "Hide";
                                     this.template.querySelector("c-rv_price-market").loadPriceMarketPage(message);
                                     //this.template.querySelector("c-rv_dealentryview").loadDealEntryPage(message);
                                     //this.template.querySelector("c-rv_price-market").subscribeToMessageChannel();
                                     this.template.querySelector('[data-id="tabset"]').classList.remove('slds-hide');
                                 }else{
                                     this.show = false;
                                     this.sectionLabel = "Show";
                                     this.template.querySelector('[data-id="tabset"]').classList.add('slds-hide');
                                 }
             }else if(message.eventType ==='deSelectedCustomer'){
                    this.customerName = 'CUSTOMER(S) : ';
                    this.filteredMasterTriggerData = [];
             }
 
     }
 
     connectedCallback() {
             this.subscribeToMessageChannel();
 
 
 
     }

       refreshData(event){
        this.recieveData(this.parentMessage);
    }

 
     monthName(startDateMonth){
         let month;
         if(startDateMonth == '01')
             month = 'Jan';
         if(startDateMonth == '02')
             month = 'Feb';
         if(startDateMonth == '03')
             month = 'Mar';
         if(startDateMonth == '04')
             month = 'Apr';
         if(startDateMonth == '05')
             month = 'May';
         if(startDateMonth == '06')
             month = 'Jun';
         if(startDateMonth == '07')
             month = 'Jul';
         if(startDateMonth == '08')
             month = 'Aug';
         if(startDateMonth == '09')
             month = 'Sep';
         if(startDateMonth == '10')
             month = 'Oct';
         if(startDateMonth == '11')
             month = 'Nov';
         if(startDateMonth == '12')
             month = 'Dec';
        
         return month;
     };
 
     onchangeMonth(event){
             this.filteredMasterTriggerData = [];
             this.monthValue = event.target.value;
             console.log('onchangemonth execution::'+ this.monthValue);
             //console.log('========year======'+JSON.stringify(this.yearValue));
             for(let key in this.masterTriggerData) {
                   if(this.masterTriggerData[key].triggerMasterData.Trigger_Month__c == event.target.value &&
                      (typeof(this.yearValue) == 'undefined' || this.yearValue == 'Select')){
                         console.log("if this.masterTriggerData[key] in onchangemonth:::", JSON.stringify(this.masterTriggerData[key]));
                         this.renderCreateDealMasterTable = true;
                         this.filteredMasterTriggerData.push(this.masterTriggerData[key]);
                   }
                   else if(this.masterTriggerData[key].triggerMasterData.Trigger_Month__c == event.target.value &&
                           this.masterTriggerData[key].triggerMasterData.Trigger_Year__c == this.yearValue){
                       //console.log("else this.masterTriggerData[key]", JSON.stringify(this.masterTriggerData[key]));
                      this.filteredMasterTriggerData.push(this.masterTriggerData[key]);
                      this.renderCreateDealMasterTable = true;
                   }
             }
               if(this.filteredMasterTriggerData.length == 0){
                 this.renderCreateDealMasterTable = true;
               }
     }
 
     onchangeYear(event){
                 this.filteredMasterTriggerData = [];
                 this.yearValue = event.target.value;
                 console.log('onchangeyear execution::'+ this.yearValue);
                 for(let key in this.masterTriggerData) {
                       if(this.masterTriggerData[key].triggerMasterData.Trigger_Year__c == event.target.value &&
                       (typeof(this.monthValue) == 'undefined' || this.monthValue == 'Select')){
                          console.log("if this.masterTriggerData[key] in onchangeyear", JSON.stringify(this.masterTriggerData[key]));
                             this.filteredMasterTriggerData.push(this.masterTriggerData[key]);
                             this.renderCreateDealMasterTable = true;
                       }
                       else if(this.masterTriggerData[key].triggerMasterData.Trigger_Month__c == this.monthValue &&
                               this.masterTriggerData[key].triggerMasterData.Trigger_Year__c == this.yearValue){
                           //console.log("else this.masterTriggerData[key]", JSON.stringify(this.masterTriggerData[key]));
                           this.filteredMasterTriggerData.push(this.masterTriggerData[key]);
                           this.renderCreateDealMasterTable = true;
                       }
                 }
                 if(this.filteredMasterTriggerData.length == 0){
                     this.renderCreateDealMasterTable = true;
                 }
                // console.log("else this.masterTriggerData[key]", JSON.stringify(this.filteredMasterTriggerData));
         }
 
     onchangeTriggerVolume(event){
         var selectedRow = event.currentTarget;
         var key = selectedRow.dataset.id;
         var str = (event.target.value).toString();
         str = str.replace(/-/g,'');
         event.target.value = str;
         let indx = event.currentTarget.dataset.id;
         let pIndex = event.currentTarget.dataset.plant;
        // this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].volumeCBM = event.target.value;
         this.filteredMasterTriggerData[indx].monthsdata[pIndex].TriggerVolume = event.target.value;
         this.filteredMasterTriggerData[indx].monthsdata[pIndex].salesOrg = this.salesOrg;
         this.filteredMasterTriggerData[indx].monthsdata[pIndex].shipToNumber = this.shipToNumber;
        // alert(key);
        // this.filteredMasterTriggerData[key].TriggerVolume = event.target.value;
        // this.filteredMasterTriggerData[key].salesOrg = this.salesOrg;
        // alert(this.shipToNumber+this.filteredMasterTriggerData[key].TriggerVolume);
        // this.filteredMasterTriggerData[key].shipToNumber = this.shipToNumber;
     }
 
     onchangeTriggerComment(event){
         var selectedRow = event.currentTarget;
         var key = selectedRow.dataset.id;
        // this.filteredMasterTriggerData[key].TriggerComment = event.target.value;
         let indx = event.currentTarget.dataset.id;
         let pIndex = event.currentTarget.dataset.plant;
         this.filteredMasterTriggerData[indx].monthsdata[pIndex].TriggerComment = event.target.value;
     }
 
     onchangeTriggerVolumeOnSave(event){
             var selectedRow = event.currentTarget;
             var key = selectedRow.dataset.id;
             var str = (event.target.value).toString();
             str = str.replace(/-/g,'');
             event.target.value = str;
             this.savedMasterTriggerSHTData[key].Volume_CBM__c = event.target.value;
     }
 
     onchangeTriggerCommentOnSave(event){
             var selectedRow = event.currentTarget;
             var key = selectedRow.dataset.id;
             this.savedMasterTriggerSHTData[key].Deal_Comment__c = event.target.value;
     }
     saveTriggerDeal(event){
             console.log(JSON.stringify(this.filteredMasterTriggerData));
             let allTriggerRecords = [];
             for(var i=0; i<(this.filteredMasterTriggerData).length; i++){
                for(var j=0; j<(this.filteredMasterTriggerData[i].monthsdata).length; j++ ){
                     let eachTriggerRecord = this.filteredMasterTriggerData[i].monthsdata[j];
                        if(eachTriggerRecord['TriggerVolume'] != undefined  && eachTriggerRecord['TriggerVolume'] != 0){
                            allTriggerRecords.push(this.filteredMasterTriggerData[i].monthsdata[j]);
                        }
                    
                 }
            }
             this.savedMasterTriggerSHTData = [];
             this.isLoading = true;
             var isError = false;
          var msg ='';
          var count=0;
          var  totalSize=this.filteredMasterTriggerData.length;
          for(var i=0;i<allTriggerRecords.length;i++){
             if((allTriggerRecords[i].TriggerVolume == 0 || allTriggerRecords[i].TriggerVolume == null || allTriggerRecords[i].TriggerVolume == '' || allTriggerRecords[i].TriggerVolume == undefined)){
                  count++;
              }
              /*if(this.filteredMasterTriggerData[i].volumeCBM != null && this.filteredMasterTriggerData[i].TriggerVolume != 0){
                  if((!this.filteredMasterTriggerData[i].isZeroPriceDeal) &&( this.filteredMasterTriggerData[i].TriggerVolume == 0 )){
                      isError = true;msg='Please enter  Volume-'+this.filteredMasterTriggerData[i].TriggerVolume+' for MRC NO '+this.filteredMasterTriggerData[i].triggerMasterData.MRC_Number__r.Name;
                      break;
                  }
              }*/
              
          }
          if(count== totalSize || allTriggerRecords == [] || allTriggerRecords.length == 0 || allTriggerRecords == null || allTriggerRecords == undefined){
              isError=true;
              msg='Please Enter Values for atleast one Deal before Saving!';
          }
         if(isError){
             this.isLoading = false;
              this.dispatchEvent(
                  new ShowToastEvent({
                  title: 'Error',
                  message: msg,
                  variant: 'error',
                      }),
                  );
         }else if(!isError){
             console.log('allTriggerRecords::'+JSON.stringify(allTriggerRecords));
             saveTermTriggerDeal({
                                // masterTriggerList : allTriggerRecords,//this.filteredMasterTriggerData,
                                 triggerdata : JSON.stringify(allTriggerRecords),
                                 startDate : this.filterStartDate,
                                 endDate : this.filterEndDate,
                                 checked : this.retailMix,
                                 trancheVal : this.tranche_Val
                             })
                         .then(result => {
                             this.message = result;
                             this.error = undefined;
                             if(this.message !== undefined) {
                                 //this.savedMasterTriggerSHTData = result;
                                 console.log('============Start'+JSON.stringify(result));
                                 result.forEach(obj => {
                                    const startDate = new Date(obj.Contract_Start__c);
                                    let mmStartDate =  ("0" + (startDate.getMonth() + 1)).slice(-2);
                                    const formattedStartDate = ("0" + startDate.getDate()).slice(-2) + '-' + mmStartDate + '-' + startDate.getFullYear();
                                    obj.Contract_Start__c = formattedStartDate;
                                    const endDate = new Date(obj.Contract_End_Date__c);
                                    let mmEndDate =  ("0" + (endDate.getMonth() + 1)).slice(-2);
                                    const formattedEndDate = ("0" + endDate.getDate()).slice(-2) + '-' + mmEndDate + '-' + endDate.getFullYear();
                                    obj.Contract_End_Date__c = formattedEndDate;
                                    let matNo = obj.Material_No__c;
                                    obj.Material_No__c = matNo.substr(matNo.length - 4);
                                    this.savedMasterTriggerSHTData.push(obj);
                                });
                                console.log('============End'+JSON.stringify(this.savedMasterTriggerSHTData));
                                 this.isLoading = false;
                                 this.dispatchEvent(
                                     new ShowToastEvent({
                                         title: 'Success',
                                         message: 'Trigger deal created successfully',
                                         variant: 'success',
                                     }),
                                 );
                             }
                             this.savesDealsData = true;
                             this.recieveData(this.parentMessage);
                             this.activeSections = 'B';
                             this.renderSavedDealMasterTable = true;
                             this.renderCreateDealMasterTable = true;
                             this.renderCmpltdDealMasterTable = true;
                             console.log(JSON.stringify(result));
                             console.log("result", this.message);
                             /*console.log(' After adding Record List ', result);
                             this.accountList = result;
                             console.log(' After adding Record List ', this.accountList);*/
                         })
                         .catch(error => {
                             this.isLoading = false;
                             this.message = undefined;
                             this.error = error;
                             this.dispatchEvent(
                                 new ShowToastEvent({
                                     title: 'Error creating record',
                                     message: error.body.message,
                                     variant: 'error',
                                 }),
                             );
                             console.log("error", JSON.stringify(this.error));
                         });
                     }
     }
 
     cancelTriggerDeal(event) {
 +        console.log('========event.currentTarget.dataset.recid========'+event.currentTarget.dataset.recid);
            this.isLoading = true;
             deleteSHTRecord({
                             RecordId : event.currentTarget.dataset.recid})
                 .then(result => {
                     this.dispatchEvent(
                         new ShowToastEvent({
                             title: 'Success',
                             message: 'Saved Deal cancelled Successfully',
                             variant: 'success',
                         }),
                     );
                      this.savedMasterTriggerSHTData = result;
                      this.recieveData(this.parentMessage);
                     this.connectedCallback();
                     this.isLoading = false;
                 })
                 .catch(error => {
                     this.dispatchEvent(
                         new ShowToastEvent({
                             title: 'Error',
                             message: error.message,
                             variant: 'error',
                         }),
                     );
                     this.connectedCallback();
                     this.isLoading = false;
                 });
     }
 
      confirmTriggerDeal(event){
                  console.log('Confirm Data :: '+JSON.stringify(this.savedMasterTriggerSHTData));
                 let cont = String.valueOf(this.savedMasterTriggerSHTData);
                 let saveSHTData = this.savedMasterTriggerSHTData;
                 let saveConfirmSHTData= [];
                 saveSHTData.forEach(obj => {
                    console.log('Start Date1 :: '+obj.Contract_Start__c+' :: '+obj.Contract_End_Date__c);
                    const [startday, startmonth, startyear] = obj.Contract_Start__c.split('-');
                    const [endday, endmonth, endyear] = obj.Contract_End_Date__c.split('-');
                    var varStartDateTime = new Date(+startyear, startmonth - 1, +startday) ;
                    var varEndDateTime = new Date(+endyear, endmonth - 1, +endday);
                    var startDate = varStartDateTime.setDate(varStartDateTime.getDate()+1);
                    var endDate = varEndDateTime.setDate(varEndDateTime.getDate()+1);
                    obj.Contract_Start__c =  varStartDateTime.toISOString();
                    obj.Contract_End_Date__c = varEndDateTime.toISOString();
                    console.log('Start Date2 :: '+obj.Contract_Start__c+' :: '+obj.Contract_End_Date__c);
                    saveConfirmSHTData.push(obj);
                });
                console.log('Confirm Data 1:: '+JSON.stringify(saveConfirmSHTData));
                 this.isConfirmLoading = true;
                 //this.completedMasterTriggerSHTData = [];
                 //this.savedMasterTriggerSHTData = [];
                 this.savedMasterTriggerSHTData = [];
                 confirmTermTriggerDeal({
                             confirmTriggerList : saveConfirmSHTData})
                             .then(result => {
                                 this.savedMasterTriggerSHTData = [];
                                 this.message = result;
                                 this.error = undefined;
                                 let soldTomap = new Map();
                                 if(this.message !== undefined) {
                                     for(let key in result) {
                                         if(result[key].Status__c == 'Saved'){
                                             result[key].Material_No__c = parseInt(result[key].Material_No__c,4);
                                             console.log(result[key].Material_No__c);
                                             this.savedMasterTriggerSHTData.push(result[key]);
                                         }else  if(result[key].Status__c == 'Completed'){
                                             this.completedMasterTriggerSHTData.push(result[key]);
                                             
                                             soldTomap.set(result[key].Id,result[key].Status__c);
                                         }
                                     }
                                     console.log('soldTomap::', soldTomap);
                                     this.soldToOptions = soldTomap;
                                     //his.completedMasterTriggerSHTData = result;
                                     console.log('============'+JSON.stringify(this.completedMasterTriggerSHTData));
                                     /*this.acc.Name = '';
                                     this.acc.AccountNumber = '';
                                     this.acc.Phone = '';*/
                                     this.isConfirmLoading = false;
                                     this.dispatchEvent(
                                         new ShowToastEvent({
                                             title: 'Success',
                                             message: 'Trigger deal confirmed successfully',
                                             variant: 'success',
                                         }),
                                     );
                                 }
                                 this.renderSavedDealMasterTable = true;
                                 this.renderCreateDealMasterTable = true;
                                 this.renderCmpltdDealMasterTable = true;
                                 this.recieveData(this.parentMessage);
                                 console.log(JSON.stringify(result));
                                 console.log("result", this.message);
                                 //added as part of Bug-1261339
                                  //  this.interval = setInterval(() => {  
                                        //unnecessary line 1280873 
                                        //this.loadSavedDeals();
                                        const objCompletedChild = this.template.querySelector('c-rv_termtriggercompledtedeals');
                                        objCompletedChild.onLoad();
                                   // }, 10000);
                                    //end Bug-1261339
                                 /*const objCompletedChild = this.template.querySelector('c-rv_termtriggercompledtedeals');
                                    objCompletedChild.onLoad();*/
                                 /*console.log(' After adding Record List ', result);
                                 this.accountList = result;
                                 console.log(' After adding Record List ', this.accountList);*/
                             })
                             .catch(error => {
                                 this.message = undefined;
                                 this.error = error;
                                 this.dispatchEvent(
                                     new ShowToastEvent({
                                         title: 'Error creating record',
                                         message: error.body.message,
                                         variant: 'error',
                                     }),
                                 );
                                 console.log("error", JSON.stringify(this.error));
                             });
         }
 
         handleChange(event){
             if(event.target.name == 'useAdvancedFilter'){
                 console.log('use advance filter:'+event.target.checked);
                 this.sAdvanceFilter = event.target.checked;
                  let dt= new Date();
                  this.startDateVal = dt;
                  var month = dt.getMonth();
                  var year = dt.getFullYear();
                 // var lastDate = new Date(year, month + 1, 0);
                  var monthVal = month+1;
                  let formatted_date =  dt.getFullYear()+ "-" + monthVal + "-" +dt.getDate();
                    this.startDte= formatted_date;
                    this.endDte=formatted_date;
 
                /* var date=new Date();
                 date = date.toString();
                 var first1 = date.substring(0,2);
                 var second2 = date.substring(2,4);
                 var third3= date.substring(4,8);
                 var date1=third3+'-'+second2+'-'+first1;
                 this.startDate=date1;
                 console.log('in advance filter::'+this.startDate);
                 this.endDate=date1;*/
             }
             if(event.target.name == 'createdOn'){
                 this.createdOn = event.detail.value;
             }
             if(event.target.name == 'status'){
                 this.advStatus = event.detail.value;
             }
             if(event.target.name == 'soldTo'){
                 this.advSoldTo = event.detail.value;
             }
             if(event.target.name == 'shtNo'){
                 this.advShtNo = event.detail.value;
             }
         }
 
         /*get createdOnOptions() {
                 return [
                     { label: 'TODAY', value: 'TODAY',selected: "true"},
                     { label: 'LAST DEAL DATE', value: 'LAST_DEAL_DATE' },
                     { label: 'THIS WEEK', value: 'THIS_WEEK' },
                     { label: 'LAST WEEK', value: 'LAST_WEEK' },
                     { label: 'LAST 3 WEEKS', value: 'LAST_3_WEEKS' }
                 ];
             }
         get statusOptions() {
                         return [
                             { label: 'COMPLETED', value: 'Completed',selected: "true"},
                             { label: 'CANCELLED', value: 'Cancelled' },
                             { label: 'EXPIRED', value: 'Expired' }
                         ];
                     }
         
 
         /*get createdByOptions() {
             return this.items;
         }*/

         handleCustomerName(event){
            this.customerName = event.detail;
         }
 }