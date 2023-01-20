/**
 * --------------Created by Dhriti.GhoshMoulick on 8/9/2021.
 */

 import { LightningElement,api,track,wire } from 'lwc';
 //import getPickListValuesMonth from '@salesforce/apex/RV_TermTriggerClass.getPickListValuesMonth';
 //import getPickListValuesYear from '@salesforce/apex/RV_TermTriggerClass.getPickListValuesMonth';
 import fetchTermTriggerDeal from '@salesforce/apex/RV_TermTriggerClass.fetchTermTriggerDeal1';
 import saveTermTriggerDeal from '@salesforce/apex/RV_TermTriggerClass.saveTermTriggerDeal1';
 //Surbhi-Start-PBI-1539864
import getTriggerSavedDeal from '@salesforce/apex/RV_TermTriggerClass.getTriggerSavedDeal';
//Surbhi-End-PBI-1539864
 import confirmTermTriggerDeal from '@salesforce/apex/RV_TermTriggerClass.confirmTermTriggerDeal';
 import deleteSHTRecord from '@salesforce/apex/RV_TermTriggerClass.deleteTermTriggerDeal';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import {publish,subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
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
	 //Surbhi-Start-PBI-1539864
     //  @track renderCreateDealMasterTable = true;
     //Surbhi-End-PBI-1539864
    //Surbhi-Start-PBI-1539864
    //changed value from true to false
    @track renderCreateDealMasterTable = false;
    //newly added
    @track triggerDealEntrySHTDataAvailability = '';
    //newly added
    @track isConfirmTriggerSavedDeal = false;
    @track isCancelTriggerSavedDeal = false;
    @track isCancelTriggerCompletedDeal = false;
    //Surbhi-End-PBI-1539864
     @track renderSavedDealMasterTable = true;
     @track renderCmpltdDealMasterTable = true;

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
     @track filteredMasterTriggerData1 = [];
    // @track filteredMasterTriggerData_1 = [];

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

    loadPMDeals(){
        var PMTemp = this.template.querySelector("c-rv_price-market");
        this.activeTab = 'TSFP_PM';
        if(PMTemp!=null && PMTemp!='' && PMTemp != undefined){
            console.log('Inside PMTemp -- this.parentMessage:'+JSON.stringify(this.parentMessage));
            this.template.querySelector("c-rv_price-market").recieveData(this.parentMessage);
        }
    }
    loadDeals() {
        var dealEntryTemp = this.template.querySelector("c-rv_dealentryview");
        this.activeTab = 'TSFP_DE';
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
         console.log('recieve data in TT:::'+JSON.stringify(message));
         this.parentMessage = message;
         console.log('this.parentMessage:'+this.parentMessage);
            //Surbhi-Start-PBI-1539864
   			//console.log(message.eventType);
             if(message != undefined){
                let objFilter = message.filterData;
			 //Surbhi-End-PBI-1539864
             if(message.eventType === 'search'){//'search' for search MRC and 'publish' for custom info section
                     console.log('Parent message in term trigger:'+message);
                      //this.recordId = message.customerId; // for customer info section
                        this.renderCreateDealMasterTable = true;
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
                                         this.filteredMasterTriggerData1 = [];
                                         this.renderCreateDealMasterTable = true;
                                        //Surbhi-Start-PBI-1539864
                                        if(this.isConfirmTriggerSavedDeal || this.isCancelTriggerSavedDeal || this.isCancelTriggerCompletedDeal){
                                            this.renderCreateDealMasterTable = false;
                                        }
                                        //setting to its default value
                                        this.isConfirmTriggerSavedDeal = false;
                                        this.isCancelTriggerSavedDeal = false;
                                        this.isCancelTriggerCompletedDeal = false;
                                        //Surbhi-End-PBI-1539864
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

                                       // this.filteredMasterTriggerData = mrcArray;



    //*****************************//added by swarna***************************************************************************************************
                                this.masterTriggerData = data;
                                let res_ponse = this.masterTriggerData['termTriggerWrapperList'];
                                let groupPlantData = new Map();
                                let _groupMRCData = new Map();
                                let count =0;
                                console.log('res_ponse::',res_ponse);
                                //res_ponse.forEach(triggermasterData => {
                                    for(let key in res_ponse) {
                                let temp = res_ponse;
                                console.log('temp::',temp);
                                    let newTriggerGroup = {};
                                    newTriggerGroup.Id = temp[key].triggerMasterData.Id;
                                    newTriggerGroup.Name  = temp[key].triggerMasterData.Name;
                                    newTriggerGroup.Sold_to_Name = temp[key].triggerMasterData.Sold_to_Name__c;
                                    newTriggerGroup.MRC_Number = temp[key].triggerMasterData.MRC_Number__c;
                                    newTriggerGroup.Monthly_volume = temp[key].triggerMasterData.Monthly_volume__c;
                                    newTriggerGroup.Trigger_Month = temp[key].triggerMasterData.Trigger_Month__c;
                                    newTriggerGroup.Trigger_Year = temp[key].triggerMasterData.Trigger_Year__c;
                                    newTriggerGroup.Min_Trigger_Volume = temp[key].triggerMasterData.Min_Trigger_Volume__c;
                                    newTriggerGroup.Max_Trigger_Volume = temp[key].triggerMasterData.Max_Trigger_Volume__c;
                                    newTriggerGroup.Max_number_of_triggers_per_month = temp[key].triggerMasterData.Max_number_of_triggers_per_month__c;
                                    newTriggerGroup.Remaining_triggers = temp[key].triggerMasterData.Remaining_triggers__c;
                                    newTriggerGroup.Remaining_trigger_volume = temp[key].triggerMasterData.Remaining_trigger_volume__c;
                                    newTriggerGroup.MRC_Number_Name =temp[key].triggerMasterData.MRC_Number__r.Name;
                                    newTriggerGroup.MRC_Number_Contract =temp[key].triggerMasterData.MRC_Number__r.Contract__c;
                                    newTriggerGroup.MRC_Number_Contract_Description= temp[key].triggerMasterData.MRC_Number__r.Contract_Description__c;
                                    newTriggerGroup.MRC_Number_Material_Description= temp[key].triggerMasterData.MRC_Number__r.Material_Description__c;
                                    newTriggerGroup.MRC_Number_Product= temp[key].triggerMasterData.MRC_Number__r.Product__c;
                                    newTriggerGroup.MRC_Number_Ship_to_Number=temp[key].triggerMasterData.MRC_Number__r.Ship_to_Number__c;
                                    newTriggerGroup.MRC_Number_Mode_Of_Transport=temp[key].triggerMasterData.MRC_Number__r.Mode_Of_Transport__c;
                                    newTriggerGroup.MRC_Number_PO_Type=temp[key].triggerMasterData.MRC_Number__r.PO_Type__c;
                                    newTriggerGroup.MRC_Number_Plant=temp[key].triggerMasterData.MRC_Number__r.Plant__c;
                                    newTriggerGroup.MRC_Number_Id=temp[key].triggerMasterData.MRC_Number__r.Id;
                                    newTriggerGroup.MRC_Number_Plant_Name=temp[key].triggerMasterData.MRC_Number__r.Plant__r.Name;
                                    newTriggerGroup.MRC_Number_Plant_Plant_Code=temp[key].triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c;
                                    newTriggerGroup.MRC_Number_Product_Name=temp[key].triggerMasterData.MRC_Number__r.Product__r.Name;
                                    newTriggerGroup.MRC_Number_Material_Number=temp[key].triggerMasterData.MRC_Number__r.Material_Name__c;
                                    newTriggerGroup.BSP=temp[key].triggerMasterData.BSP__c;
                                    newTriggerGroup.MSP=temp[key].triggerMasterData.MSP__c;
                                    newTriggerGroup.atpVoltoBeReduced=temp[key].atpVoltoBeReduced;
                                    newTriggerGroup.isGsapDealCancelOn=temp[key].isGsapDealCancelOn;
                                    newTriggerGroup.isGsapDealCreateOn=temp[key].isGsapDealCreateOn;
                                    newTriggerGroup.isPricingTaxed=temp[key].isPricingTaxed;
                                    newTriggerGroup.isVolToBeHedged=temp[key].isVolToBeHedged;
                                    newTriggerGroup.isZeroPriceDeal=temp[key].isZeroPriceDeal;
                                    newTriggerGroup.pricingCondition=temp[key].pricingCondition;
                                    newTriggerGroup.tranche = this.masterTriggerData.termTriggerWrapperList[key].tranche;
                                    newTriggerGroup.count=count;

                                    if(groupPlantData.has(temp[key].triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c+temp[key].triggerMasterData.Trigger_Month__c+temp[key].triggerMasterData.MRC_Number__r.Contract__c)){
                                        groupPlantData.get(temp[key].triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c+temp[key].triggerMasterData.Trigger_Month__c+temp[key].triggerMasterData.MRC_Number__r.Contract__c).push(newTriggerGroup);
                                    }else{
                                        let plantGroupList =[];
                                        plantGroupList=[newTriggerGroup];

                                        groupPlantData.set(temp[key].triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c+temp[key].triggerMasterData.Trigger_Month__c+temp[key].triggerMasterData.MRC_Number__r.Contract__c,plantGroupList);
                                        }
                                    count++;
                                    }

                                    console.log('groupPlantData in tt tab:',groupPlantData);

                                    let plantNames = new Set();
                                    //res_ponse.forEach(mrcData_ => {
                                    for(let key in res_ponse) {
                                        console.log('res_ponse::',res_ponse);
                                        //let temp = res_ponse;
                                        let mrcData = res_ponse[key];
                                        console.log('mrcData::',JSON.stringify(mrcData));
                                        let newMRCGroup = {};
                                        newMRCGroup.mrcNum = mrcData.triggerMasterData.MRC_Number__r.Contract__c;
                                        newMRCGroup.mrcLineItem = mrcData.triggerMasterData.MRC_Number__r.Name;
                                        newMRCGroup.mrcContract_Description= mrcData.triggerMasterData.MRC_Number__r.Contract_Description__c;
                                        newMRCGroup.location = mrcData.triggerMasterData.MRC_Number__r.Plant__r.Name;
                                        newMRCGroup.locationId = mrcData.triggerMasterData.MRC_Number__r.Plant__c;
                                        newMRCGroup.locationCode = mrcData.triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c;
                                        newMRCGroup.shipToNum = mrcData.triggerMasterData.MRC_Number__r.Ship_to_Number__c;
										newMRCGroup.triggerMonth = mrcData.triggerMasterData.Trigger_Month__c;
                                        newMRCGroup.gradeGroup = groupPlantData.get(mrcData.triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c+mrcData.triggerMasterData.Trigger_Month__c+mrcData.triggerMasterData.MRC_Number__r.Contract__c);
                                        newMRCGroup.rowspan = groupPlantData.get(mrcData.triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c+mrcData.triggerMasterData.Trigger_Month__c+mrcData.triggerMasterData.MRC_Number__r.Contract__c).length+1;
                                        if(!plantNames.has(mrcData.triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c+mrcData.triggerMasterData.Trigger_Month__c+mrcData.triggerMasterData.MRC_Number__r.Contract__c)){
                                            if(_groupMRCData.has(mrcData.triggerMasterData.Trigger_Month__c)){
                                                _groupMRCData.get(mrcData.triggerMasterData.Trigger_Month__c).push(newMRCGroup);
                                            }
                                            else{
                                                let mrcGroupList = [newMRCGroup];
                                                _groupMRCData.set(mrcData.triggerMasterData.Trigger_Month__c, mrcGroupList);
                                            }
                                        plantNames.add(mrcData.triggerMasterData.MRC_Number__r.Plant__r.Plant_Code__c+mrcData.triggerMasterData.Trigger_Month__c+mrcData.triggerMasterData.MRC_Number__r.Contract__c);
                                    }
                                    }

                                    console.log("Master Data in tt:",_groupMRCData);

                                    let _mrcArray = [];
									var _groupMRCLinesItemsData = new Map();
                                    _groupMRCData.forEach((values,keys)=>{
                                        console.log(keys+'---'+values);
                                        let mrc = {};
                                        mrc.mrcNo = keys;
										var palnts = values;
                                        console.log('plants::',JSON.stringify(palnts));
                                        palnts.forEach(eachPlants =>{
                                            console.log('mrcNum::'+eachPlants.mrcNum);
                                            if(eachPlants.triggerMonth === keys){
                                                var uniqueKey = eachPlants.mrcNum+'-'+eachPlants.mrcContract_Description+'-'+eachPlants.shipToNum+'*'+eachPlants.triggerMonth;
                                                if(_groupMRCLinesItemsData.has(uniqueKey)){
                                                    _groupMRCLinesItemsData.get(uniqueKey).push(eachPlants);
                                                }
                                                else{
                                                    var eachPlantsLst = [eachPlants];
                                                    _groupMRCLinesItemsData.set(uniqueKey, eachPlantsLst);
                                                }
                                            }
                                        });
                                        console.log(_groupMRCLinesItemsData);
                                        console.log('_groupMRCLinesItemsData::'+JSON.stringify(_groupMRCLinesItemsData));
                                        _groupMRCLinesItemsData.forEach((values,keys)=>{
                                                console.log('keys::'+JSON.stringify(keys));
                                                if(keys.includes(mrc.mrcNo)){
                                                    mrc.mrcNums = keys.substring(0,keys.length-5);;
                                                    mrc.plants = values;
                                                    console.log('values::'+JSON.stringify(values));
                                                }
                                        });
                                       _mrcArray.push(mrc);
                                        });
                                        console.log('mrcArray in TT::'+JSON.stringify(_mrcArray));
                                        this.filteredMasterTriggerData1 = _mrcArray;

                                        this.renderCreateDealMasterTable = true;
                                        console.log('json::',this.filteredMasterTriggerData1);

//****************************************//end ******************************************************************************


                                         if(this.masterTriggerData.shtList != 'undefined'){
                                             let soldTomap = new Map();
                                             console.log('log 2::',this.filteredMasterTriggerData1);
                                             var soldToList = [];
                                             this.savedMasterTriggerSHTData = [];
                                             console.log('SHT no::'+this.masterTriggerData.shtNo);
                                              for(let key in this.masterTriggerData.shtList) {
                                                     if(this.masterTriggerData.shtList[key].Status__c == 'Saved'){
                                                         //this.masterTriggerData.shtList[key].Material_No__c = parseInt(this.masterTriggerData.shtList[key].Material_No__c,4);
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
                                              console.log('log 4::',this.filteredMasterTriggerData1);
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
                                        //Surbhi-Start-PBI-1539864
                                        if((this.filteredMasterTriggerData1).length == 0){
                                            //alert('I am here');
                                            this.renderCreateDealMasterTable = false;
                                            this.triggerDealEntrySHTDataAvailability = '';
                                        }
                                        //Surbhi-Start-PBI-1539864
                                        if(filterObj.poType != "TTTT" && filterObj.poType != "TTTI"){
                                            this.renderCreateDealMasterTable = false;
                                            this.triggerDealEntrySHTDataAvailability = 'Please select TTTT/TTTI PO Type to book the deals in Trigger Entry!';
                                        }
                                        //Surbhi-End-PBI-1539864
                                        console.log('log 5::',this.filteredMasterTriggerData1);
                                        console.log('filterdata::'+JSON.stringify(this.filteredMasterTriggerData1));
                                         console.log('filteredMasterTriggerData1'+JSON.stringify(this.masterTriggerData.shtList));
                                 })
                                 .catch(error => {
                                       console.log('===error==='+JSON.stringify(error));
                                       //this.renderCreateDealMasterTable = true;
									   //Surbhi-Start-PBI-1539864
                                       this.renderCreateDealMasterTable = false;
                                       this.triggerDealEntrySHTDataAvailability = 'No Deals are available with filter search!';
									   //Surbhi-End-PBI-1539864
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
                    this.filteredMasterTriggerData1 = [];
                    //Surbhi-Start-PBI-1539864
                    this.renderCreateDealMasterTable = false;
                    //Surbhi-End-PBI-1539864
             }
             else{
                if(message.eventType == 'deSelectedCustomer_clear'){
                    console.log('Here is in else');
                    this.activeTab='TSFP_PM';
                    this.customerName = 'CUSTOMER(S) : ';
                    this.parentMessage = null;
                }

               }
            }
            /*if(message.eventType == 'deSelectedCustomer'){
                console.log('**this.activeTab::'+this.activeTab)
                this.activeTab='TSFP_PM';
            }*/
            console.log('log 3::',this.filteredMasterTriggerData1);
        }

     connectedCallback() {
        //Surbhi-Start-PBI-1539864
        this.triggerDealEntrySHTDataAvailability = 'Please select a Customer/MRC and TTTT/TTTI PO Type to view the deals in Trigger entry!';
        //Surbhi-End-PBI-1539864
        this.subscribeToMessageChannel();
        //Surbhi-Start-PBI-1539864
        this.loadTriggerSavedDeals();
        //Surbhi-End-PBI-1539864
     }
    //Surbhi-Start-PBI-1539864
    loadTriggerSavedDeals() {
        getTriggerSavedDeal()
             .then(result => {
                if(result != null){
                    this.savedMasterTriggerSHTData = result;
                    console.log('saved deals data on default::'+JSON.stringify(this.savedMastserTriggerSHTData));
                    if((this.savedMasterTriggerSHTData).length == 0){
                        this.savesDealsData = false;
                    }else{
                       this.savesDealsData = true;
                    }
                }
             })
             .catch(error => {
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
    //Surbhi-End-PBI-1539864
       refreshData(event){
        //Surbhi-Start-PBI-1539864
        if(event.type == 'refreshtermtriggercmp'){
            this.isCancelTriggerCompletedDeal = true;
        }
        //Surbhi-End-PBI-1539864
        this.recieveData(this.parentMessage);
    }


         onchangeTriggerVolume1(event){

            console.log('volume::'+event.target.value);
            var str = (event.target.value).toString();
            str = str.replace(/-/g,'');
            event.target.value = str;
            let gindex = event.currentTarget.dataset.id;
            let pIndex = event.currentTarget.dataset.plant;
            let index = event.currentTarget.dataset.mrc;


            //volumeArray = this.dealEntrySHTData[index].plants[pIndex];
            //this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].volumeCBM = event.target.value;
           // alert(event.target.value);//filteredMasterTriggerData1
            console.log('TD::',this.filteredMasterTriggerData1);
           // console.log('new::',this.filteredMasterTriggerData_1);
            this.filteredMasterTriggerData1[index].plants[pIndex].gradeGroup[gindex].TriggerVolume1 = event.target.value;
            console.log('data 1::', this.filteredMasterTriggerData1);




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
     onchangeTriggerComment1(event){
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
       // this.filteredMasterTriggerData[key].TriggerComment = event.target.value;
       let gindex = event.currentTarget.dataset.id;
       let pIndex = event.currentTarget.dataset.plant;
       let index = event.currentTarget.dataset.mrc;
        //this.filteredMasterTriggerData[indx].monthsdata[pIndex].TriggerComment = event.target.value;
        this.filteredMasterTriggerData1[index].plants[pIndex].gradeGroup[gindex].TriggerComment1 = event.target.value;
        console.log('comment::',this.filteredMasterTriggerData);
    }

     onchangeTriggerComment(event){
         var selectedRow = event.currentTarget;
         var key = selectedRow.dataset.id;
        // this.filteredMasterTriggerData[key].TriggerComment = event.target.value;
         let indx = event.currentTarget.dataset.id;
         let pIndex = event.currentTarget.dataset.plant;
         this.filteredMasterTriggerData[indx].monthsdata[pIndex].TriggerComment = event.target.value;
         console.log('comment::',this.filteredMasterTriggerData);
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
	        //Surbhi-Start-PBI-1539864
            this.isLoading = true;
			//Surbhi-End-PBI-1539864
            console.log('log 6::'+JSON.stringify(this.filteredMasterTriggerData1));
             console.log(JSON.stringify(this.filteredMasterTriggerData1));
             let allTriggerRecords = [];
             for(var i=0; i<(this.filteredMasterTriggerData1).length; i++){
                for(var j=0; j<(this.filteredMasterTriggerData1[i].plants).length; j++ ){
                    for(var k=0; k<(this.filteredMasterTriggerData1[i].plants[j].gradeGroup).length; k++){
                        let eachPlant = this.filteredMasterTriggerData1[i].plants[j].gradeGroup[k];
                        if(eachPlant['TriggerVolume1'] != undefined && eachPlant['TriggerVolume1'] != ""){
                            allTriggerRecords.push(this.filteredMasterTriggerData1[i].plants[j].gradeGroup[k]);
                        }
                    }
                 }
            }

             /*for(var i=0; i<(this.filteredMasterTriggerData1).length; i++){
                for(var j=0; j<(this.filteredMasterTriggerData1[i].monthsdata).length; j++ ){
                     let eachTriggerRecord = this.filteredMasterTriggerData1[i].monthsdata[j];
                        if(eachTriggerRecord['TriggerVolume'] != undefined  && eachTriggerRecord['TriggerVolume'] != 0){
                            allTriggerRecords.push(this.filteredMasterTriggerData1[i].monthsdata[j]);
                        }

                 }
            }*/
             this.savedMasterTriggerSHTData = [];
			 //Surbhi-Start-PBI-1539864
             //this.isLoading = true;
			 //Surbhi-End-PBI-1539864
             var isError = false;
          var msg ='';
          var count=0;
          var  totalSize=this.filteredMasterTriggerData1.length;
          for(var i=0;i<allTriggerRecords.length;i++){
             if((allTriggerRecords[i].TriggerVolume1 == 0 || allTriggerRecords[i].TriggerVolume1 == null || allTriggerRecords[i].TriggerVolume1 == '' || allTriggerRecords[i].TriggerVolume1 == undefined)){
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
              msg='Please Enter Values for at least one Deal before Saving!';
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
                                 //Surbhi-Start-PBI-1539864
								 //this.isLoading = false;
								 //Surbhi-End-PBI-1539864
                                 this.dispatchEvent(
                                     new ShowToastEvent({
                                         title: 'Success',
                                         message: 'Trigger deal created successfully',
                                         variant: 'success',
                                     }),
                                 );
								 //Surbhi-Start-PBI-1539864
                                 this.isLoading = false;
								 //Surbhi-End-PBI-1539864
                             }
                             this.savesDealsData = true;
							 //Surbhi-Start-PBI-1539864
                             this.isConfirmTriggerSavedDeal = true;
                             //Surbhi-End-PBI-1539864
							 //this.recieveData(this.parentMessage);
                             this.activeSections = 'B';
                             this.renderSavedDealMasterTable = true;

                            //Surbhi-Start-PBI-1539864
                            //this.renderCreateDealMasterTable = true;
                            this.renderCreateDealMasterTable = false;
                            //Surbhi-End-PBI-1539864
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

        console.log('========event.currentTarget.dataset.recid========'+event.currentTarget.dataset.recid);
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
                      //Surbhi-Start-PBI-1539864
                      this.isCancelTriggerSavedDeal = true;
                      //Surbhi-End--PBI-1539864
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
	            //Surbhi-Start-PBI-1539864
                this.isConfirmLoading = true;
				//Surbhi-End-PBI-1539864
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

                                     console.log('============'+JSON.stringify(this.completedMasterTriggerSHTData));

									 //Surbhi-Start-PBI-1539864

                                     //Surbhi-End-PBI-1539864
									 this.dispatchEvent(
                                         new ShowToastEvent({
                                             title: 'Success',
                                             message: 'Trigger deal confirmed successfully',
                                             variant: 'success',
                                         }),
                                     );
                                     //Surbhi-Start-PBI-1539864
                                     this.isConfirmTriggerSavedDeal = true;
                                     //Surbhi-End-PBI-1539864
                                     this.isConfirmLoading = false;
                                 }
                                //Surbhi-Start-PBI-1539864
                                 this.renderSavedDealMasterTable = false;
                                 this.renderCreateDealMasterTable = false;

                                //Surbhi-Start-PBI-1539864
                                 this.renderCmpltdDealMasterTable = true;
                                 //this.recieveData(this.parentMessage);
                                 console.log(JSON.stringify(result));
                                 console.log("result", this.message);
                                 //added as part of Bug-1261339

                                        //unnecessary line 1280873
                                        //this.loadSavedDeals();
                                        const objCompletedChild = this.template.querySelector('c-rv_termtriggercompledtedeals');
                                        objCompletedChild.onLoad();

                                    //end Bug-1261339


                                 this.republishfilterSection();
                                 this.activeTab = 'TSFP_PM';
                                 this.customerName='';
                             })
                             .catch(error => {
							    //Surbhi-Start-PBI-1539864
                                this.isConfirmLoading = false;
								//Surbhi-End-PBI-1539864
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

         republishfilterSection(){
           this.customerName = '';
            const payload = {
                eventType: 'deSelectedCustomer_clear_TT',
                customerId: '',
                mrcId: ''
                };

                publish(
                    this.messageContext,
                    refreshDataChannel,
                    payload
                );

         }

         handleChange(event){
             if(event.target.name == 'useAdvancedFilter'){
                 console.log('use advance filter:'+event.target.checked);
                 this.sAdvanceFilter = event.target.checked;
                  let dt= new Date();
                  this.startDateVal = dt;
                  var month = dt.getMonth();
                  var year = dt.getFullYear();
                  var monthVal = month+1;
                  let formatted_date =  dt.getFullYear()+ "-" + monthVal + "-" +dt.getDate();
                    this.startDte= formatted_date;
                    this.endDte=formatted_date;

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



         handleCustomerName(event){
            this.customerName = event.detail;
         }
 }