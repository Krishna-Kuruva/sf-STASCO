/*
 ----------------- Created by Sampada.Bhat on 12/23/2021.
*/
// Rv PriceMarket
import { LightningElement, track, wire, api } from 'lwc';
import getMRCDataPriceAndMarket from '@salesforce/apex/RV_PriceAndMarket.getMRCDataPriceAndMarket';
import saveOfferTrackDetails from '@salesforce/apex/RV_PriceAndMarket.saveOfferTrackDetails';
import getTableDataForPriceAndMarket from '@salesforce/apex/RV_PriceAndMarket.getTableDataForPriceAndMarket';
import {publish,subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import refreshDataChannel from '@salesforce/messageChannel/Rv_DiPublishSearchFilter__c';
import advancedFilterValueChannel from '@salesforce/messageChannel/Rv_DiPublishAdvanceFilterVales__c';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Rv_PriceMarket extends LightningElement {
    subscription = null;
    @api customerName;
    @track arrayOfSHT = [];
    @track activeSections = 'A';
    @track mapOfSHTData=[];
    @track monthOptions;
    @track yearOptions;
    @track filterStartDate;
    @track filterEndDate;
    @track fieldLabelName;
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
    @track completedMasterTriggerSHTData = [];
    @track priceMarketViewTab = false;
    @track dealEntryViewTab = false;
    @track termTriggerTab = false;
    @track sectionLabel = "show";
    @track showPricePage = false;
    @track parentMessage;
    isLoading = false;
    //@track isSaveButtonDisabled = false; // Ashish:Added variable under 1165063,1182368
    @track retailMixChecked = false;
    @track showSaveButton = false;
     @track mrcsAvailable;
    @wire(MessageContext)
    messageContext;
    isDisabled = false;
    priceMarketCss = 'row';
    //added by swarna
    @track datetime;
    @track _onLoad = true;
    @track refreshInSecs;
    @track intervalSecs = 30;
    //end

    connectedCallback(){
        this.subscribeToMessageChannel();
       // this.onLoad();
     //   this.cancellationReasonOptions = [{ label: 'None', value: 'None'}];
    }
    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }
    subscribeToMessageChannel(){
        console.log('Subscribe::'+JSON.stringify(this.subscription));
        if(!this.subscription){

            this.subscription = subscribe(
            this.messageContext,
            refreshDataChannel,
                (message) => this.recieveData(message),
                 { scope: APPLICATION_SCOPE }
                );
                console.log('Subscribe1::'+JSON.stringify(this.subscription));

        }
    }

    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;

    }
    @api loadPriceMarketPage(message){
        this.showPricePage = true;
        console.log('inside price market: Message : '+message);
    }

    @api recieveData(message){
        this._onLoad = true;
        this.completedMasterTriggerSHTData = [];
        this.parentMessage = message;
        console.log('message from channel::'+JSON.stringify(message));
        window.clearInterval(this.timerRef);
        window.localStorage.removeItem('startTimer');
        this.setTimer1();
        if(message != undefined && message != null){
        if(message.eventType === 'search'){                               //'search' for search MRC and 'publish' for custom info section
            let filterObj = message.filterData; // for search MRC section
            console.log('at recieveData::'+JSON.stringify(filterObj));
            this.filterStartDate = filterObj.startDate;
            this.filterEndDate = filterObj.endDate;
            this.retailMixChecked = filterObj.retailMix;
            if(this.filterStartDate){
                    let startDate = this.filterStartDate;
                    const startDateLst = startDate.split("-");
                    this.filteredYear = startDateLst[0];

             }
             if(filterObj.poType != 'TTTT' && filterObj.poType != 'TTTI'){
                this.getPM_MRCData(filterObj);
             }else{
                this.showSaveButton = false;
                this.completedMasterTriggerSHTData = [];
                this.mrcsAvailable = 'Please select TSFP PO Type to book the offers in Price & Market!';
            }
        }
    }
    }
    getPM_MRCData(filterObj){
        if(filterObj.poType != 'TTTT' && filterObj.poType != 'TTTI'){
            getMRCDataPriceAndMarket({
                soldToAccId: filterObj.customerRecId,//0012500001RIxDuAAL
                mrcNumber: JSON.stringify(filterObj.mrcNo),
                shipToAccNum : filterObj.shipToNum,
                mot : filterObj.mot,
                energyTax : filterObj.energyTax,
                productName : filterObj.product,
                poType : filterObj.poType,
                //plantId :JSON.stringify(filterObj.depot),
                plantId :filterObj.depot,
                salesOrg :filterObj.salesOrg,
                startDate : filterObj.startDate,
                endDate : filterObj.endDate,
                callFromOlf:filterObj.olfOnly,
                checked :filterObj.retailMix
        })
        .then(result => {
                   let groupMRCData = new Map();
                  console.log('Offer result :'+JSON.stringify(result));
                   console.log('result.Length:'+result.length);
                    let mrcArray =[];
                  if(result.length>0){
                    const selectedEvent = new CustomEvent("customervaluechange", {
                                    detail: 'CUSTOMER(S) : ' + result[0].accName
                        });
                    this.dispatchEvent(selectedEvent);
                    let groupPlantData = new Map();
                    let count =0;
                    let flag = 0;
                    let gradeSet = new Set();
                    result.forEach(mrcData => {
                         if(mrcData.hasEditAccess ===  false){
                            this.isDisabled = true;
                            this.priceMarketCss = 'row readonly-page'
                         }
                        let newPlantGroupMogas = null;
                       // console.log('count before ULG:'+count);
                        if(!gradeSet.has(mrcData.mrcNo+mrcData.locationName+'ULG') && mrcData.grade.startsWith('ULG')){

                            newPlantGroupMogas = {};
                            newPlantGroupMogas.bsp = null;
                            newPlantGroupMogas.salesPrice = null;
                            newPlantGroupMogas.grade = 'MOGAS';
                            newPlantGroupMogas.otm = null;
                            newPlantGroupMogas.onlineATP = null;
                            newPlantGroupMogas.phoneATP = null;
                            newPlantGroupMogas.offer = null;
                            newPlantGroupMogas.mogas = true;
                            newPlantGroupMogas.margin =null ;
                            let locGrade = mrcData.mrcNo+mrcData.locationName+'ULG';
                            gradeSet.add(locGrade);
                            count++;
                        }
                        console.log('count after ULG :'+count);
                        let newPlantGroup = {};
                            newPlantGroup.bsp = mrcData.finalbspCal;
                            newPlantGroup.finalSalesPriceCal = mrcData.finalSalesPriceCal;//parseInt(mrcData.finalSalesPriceCal);
                            newPlantGroup.dailySales = parseInt(mrcData.dailySales);//added by swarna hypercare
                            //newPlantGroup.salesPrice = parseInt(mrcData.finalSalesPriceCal);
                            newPlantGroup.grade = mrcData.grade;
                            newPlantGroup.otm = mrcData.OTM;
                            newPlantGroup.finalOtm = mrcData.finalOTM; //
                            if(newPlantGroup.otm==newPlantGroup.finalOtm){
                                newPlantGroup.showOTM = false;
                            }else{
                                newPlantGroup.showOTM = true;
                            }
                            newPlantGroup.id = "otm"+count;
                            newPlantGroup.onlineATP = parseInt(mrcData.onlineATP);
                            //newPlantGroup.phoneATP = mrcData.phoneATP;
                            newPlantGroup.phoneATP = parseInt(mrcData.atpLive);
                            //newPlantGroup.offer = null;
                            /* Start - Code added by Mohan for offer tracking */
                            newPlantGroup.offerPrice = "offerPrice"+count;
                            newPlantGroup.offerValue = '';
                            newPlantGroup.mrcLineItemId = "mrcLineItemId"+count;
                            newPlantGroup.mrcLineItem = mrcData.mrcLineItem;
                            newPlantGroup.shipToName = mrcData.shipToName;
                            newPlantGroup.soldTo = mrcData.soldTo;
                            newPlantGroup.soldToNumber = mrcData.soldToNumber;
                            newPlantGroup.tranche = mrcData.tranche;
                            newPlantGroup.startDate = mrcData.startDate;
                            newPlantGroup.endDate = mrcData.endDate;
                            newPlantGroup.offerId = "offer"+count;
                            newPlantGroup.showOfferField = (mrcData.finalOTM!=null)?true:false;
                            //newPlantGroup.offerTrackMap = mrcData.offerTrackMap;
                            //newPlantGroup.lastOfferedPrice = mrcData.lastOfferedPrice;
                            newPlantGroup.lastOfferedPrice = ((mrcData.lastOfferedPrice)*1).toFixed(2);
                            newPlantGroup.lastOfferedVolume = mrcData.lastOfferedVolume;
                            newPlantGroup.createdDate = mrcData.createdDate;
                            newPlantGroup.materialNo = mrcData.materialNo;
                            newPlantGroup.salesOrg = mrcData.salesOrg;
                            newPlantGroup.showFinalOTM = mrcData.showFinalOTM;
                            newPlantGroup.lastOfferAvailable = false;
                            newPlantGroup.count = count;
                            if(mrcData.lastOfferedVolume!='' && mrcData.lastOfferedVolume!=null){
                                newPlantGroup.lastOfferAvailable = true;
                            }else{
                                newPlantGroup.lastOfferAvailable = false;
                            }

                            /* End - Code added by Mohan for offer tracking */
                            //newPlantGroup.margin = (mrcData.finalSalesPriceCal-mrcData.OTM).toFixed(2) ;// Ashish: commented under 1177068
                            newPlantGroup.margin = mrcData.finalOTM == null ? 0 :(mrcData.finalOTM-mrcData.finalbspCal).toFixed(2) ;
                            //newPlantGroup.margin = (mrcData.OTM-mrcData.finalbspCal).toFixed(2); //Ashish :Added code under 1177068
                        if(groupPlantData.has(mrcData.locationName+mrcData.mrcName)){
                            if(newPlantGroupMogas != null){
                                groupPlantData.get(mrcData.locationName+mrcData.mrcName).push(newPlantGroupMogas);
                            }
                            groupPlantData.get(mrcData.locationName+mrcData.mrcName).push(newPlantGroup);
                        }else{
                            let plantGroupList =[];
                            if(newPlantGroupMogas != null){
                                plantGroupList=[newPlantGroupMogas,newPlantGroup];

                            }

                            else{

                             plantGroupList=[newPlantGroup];
                            }
                            groupPlantData.set(mrcData.locationName+mrcData.mrcName,plantGroupList);
                        }
                        count++;
                    });
                    console.log('groupPlantData:'+groupPlantData);
                    let plantNames = new Set();
                    result.forEach(mrcData => {
                        let newMRCGroup = {};
                        newMRCGroup.location = mrcData.locationName;
                        newMRCGroup.locationId = mrcData.location;
                        newMRCGroup.shipToNum = mrcData.shipToNumber;
                        newMRCGroup.gradeGroup = groupPlantData.get(mrcData.locationName+mrcData.mrcName);
                        newMRCGroup.rowspan = groupPlantData.get(mrcData.locationName+mrcData.mrcName).length+1;
                        if(!plantNames.has(mrcData.locationName+mrcData.mrcName)){
                        if(groupMRCData.has(mrcData.mrcName)){

                            groupMRCData.get(mrcData.mrcName).push(newMRCGroup);
                        }else{
                           let mrcGroupList =[newMRCGroup];
                           groupMRCData.set(mrcData.mrcName,mrcGroupList);
                        }
                        plantNames.add(mrcData.locationName+mrcData.mrcName);
                    }


                    });


                    console.log("Master Data :"+groupMRCData);

                    let itr = groupMRCData;
                    let mrcArray =[];
                    groupMRCData.forEach((values,keys)=>{
                        console.log(values+' '+keys);
                        let mrc = {};

                        mrc.mrcNo = keys;

                      //  mrc.rowSpan = values.gradeGroup.length + 1;
                        mrc.plants = values;
                        mrcArray.push(mrc);
                    })
                       // this.completedMasterTriggerSHTData = mrcArray;
                       if(this._onLoad){
                        this.completedMasterTriggerSHTData = mrcArray;
                            this.refreshInSecs = this.intervalSecs * 1000;
                            this._onLoad = false;
                            console.log('startInterval msg::'+JSON.stringify(this.parentMessage));
                            //this.startInterval();
                           // this.datetime = this.currentDate;
                    }
                    else if(!this._onLoad){
                        console.log('time in else::'+this.currentDate);
                        console.log('completedMaster::',this.completedMasterTriggerSHTData);
                        for(var i = 0;i<this.completedMasterTriggerSHTData.length; i++){
                            for(var j = 0;j<this.completedMasterTriggerSHTData[i].plants.length; j++){
                                for(var k = 0;k<this.completedMasterTriggerSHTData[i].plants[j].gradeGroup.length; k++){
                                    //Added by swarna Bug1725181
                                    this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k].dailySales = mrcArray[i].plants[j].gradeGroup[k].dailySales ;
                                    this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k].onlineATP = mrcArray[i].plants[j].gradeGroup[k].onlineATP ;
                                    this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k].phoneATP = mrcArray[i].plants[j].gradeGroup[k].phoneATP ;
                                    this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k].bsp = mrcArray[i].plants[j].gradeGroup[k].bsp ;
                                    this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k].finalSalesPriceCal = mrcArray[i].plants[j].gradeGroup[k].finalSalesPriceCal ;
				    this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k].margin = mrcArray[i].plants[j].gradeGroup[k].margin ;
                                    this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k].otm = mrcArray[i].plants[j].gradeGroup[k].otm ;
                                    this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k].finalOtm = mrcArray[i].plants[j].gradeGroup[k].finalOtm ;
				    //end
                                }
                            }
                        }
                        //this.datetime = this.currentDate;
                    }

                    //    console.log('MRC Array'+mrcArray+' '+JSON.stringify(this.completedMasterTriggerSHTData));
                        this.showSaveButton = true;
                        window.clearInterval(this.timerRef);
                        window.localStorage.removeItem('startTimer');
                        this.setTimer1();
                    }
                    else{
                        this.completedMasterTriggerSHTData = [];
                        this.mrcsAvailable = 'Data is not available with search criteria!';
                        console.log('MRC Array'+mrcArray+' '+JSON.stringify(this.completedMasterTriggerSHTData));
                         const selectedEvent = new CustomEvent("customervaluechange", {
                            detail: ''
                        });
                        this.dispatchEvent(selectedEvent);
                        this.showSaveButton = false;
                    }

               // this.cancellationReasonOptions = result.reasonList;

        })
        .catch(error => {
				this.showSaveButton = false;
                this.completedMasterTriggerSHTData = [];
                console.log('===error===',error);
                this.mrcsAvailable = 'Data is not available with search criteria!';
                const selectedEvent = new CustomEvent("customervaluechange", {
                            detail: ''
                        });
                this.dispatchEvent(selectedEvent);
            });


            }
    }
    @track timerRef;
     timer = '0'

     StartTimerHandler(){
        const startTime = new Date()
        window.localStorage.setItem('startTimer', startTime)
        return startTime
    }
    setTimer1(){
        const startTime = new Date( window.localStorage.getItem("startTimer") || this.StartTimerHandler())
        this.timerRef = window.setInterval(()=>{
            const secsDiff = new Date().getTime() - startTime.getTime();
            this.timer = this.secondToHms(Math.floor(secsDiff/1000));
            const str = this.timer;

            let before_ = str.substring(0, str.indexOf(' '));
            if(before_ >= 30){
                before_ = 1
            }
            //console.log(before_);
             this.timer = 30 - before_;
        }, 1000)

    }
    secondToHms(d){
        d = Number(d)
        const h = Math.floor(d / 3600);
        const m = Math.floor(d % 3600 / 60);
        const s = Math.floor(d % 3600 % 60);
        const hDisplay = h > 0 ? h + (h == 1 ? " hour, " : " hours, ") : "";
        const mDisplay = m > 0 ? m + (m == 1 ? " minute, " : " minutes, ") : "";
        const sDisplay = s > 0 ? s + (s == 1 ? " second" : " seconds") : "";
        //alert(sDisplay);
        if(sDisplay == '30 seconds'){
            //alert('sdsdsd'+sDisplay);
            if(this.parentMessage != null && this.parentMessage['eventType'] == 'search'){
                let msgdata = this.parentMessage.filterData;
                this.getPM_MRCData(msgdata);
                window.clearInterval(this.timerRef);
                window.localStorage.removeItem('startTimer');
            }

        }
        return hDisplay + mDisplay + sDisplay;
    }

    otmDecrement(event){
        // console.log('DataSet'+event.currentTarget.dataset.mrc+' '+event.currentTarget.dataset.location+' '+event.currentTarget.dataset.otm)

        let gIndex = event.currentTarget.dataset.id;
        let pIndex = event.currentTarget.dataset.plant;
        let index = event.currentTarget.dataset.mrc;
        let count = event.currentTarget.dataset.count;
        //let totalIndex = parseInt(gIndex)+parseInt(pIndex)+parseInt(index);
        let totalIndex = parseInt(count);
        let otmString = 'otm'+totalIndex;
        let decrementedValue = 0;
        let offerPriceString = 'offerPrice'+totalIndex;
        let offerString = 'offer'+totalIndex;

        let presentValue=this.template.querySelector("div[data-id="+otmString+"]").innerHTML;
        let offerPriceInput = this.template.querySelector("lightning-input[data-my-id="+offerPriceString+"]");
        if(presentValue!='' && presentValue!=null && offerPriceInput!=null){
            let currentOffer=this.template.querySelector("lightning-input[data-my-id="+offerPriceString+"]").value;
            console.log('offerPriceString:'+offerPriceString);
            if(currentOffer!=0){
                presentValue = currentOffer ;
            }
            console.log('currentOffer:'+currentOffer);
            console.log('presentValue:'+presentValue);

            const presentValueArray = presentValue.split(".");

            console.log('parseFloat(presentValue):'+(parseFloat(presentValue)));
            let decimalValue = ('0.'+presentValueArray[1])%0.05;
            decimalValue = Math.round((decimalValue + Number.EPSILON) * 100) / 100;
            console.log('decimalValue:'+decimalValue);
            if(decimalValue > 0.00){
                if(parseFloat(decimalValue)==0.05){
                    decrementedValue= (parseFloat(presentValue)-decimalValue).toFixed(2);
                }
                else{
                    decrementedValue= (parseFloat(presentValue)-(decimalValue)).toFixed(2);
                }
            }else {
                decrementedValue= (parseFloat(presentValue)-0.05).toFixed(2);
            }
            console.log('decrementedValue:'+decrementedValue);

            //this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].finalOtm = decrementedValue;
            this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offerValue = decrementedValue;
            if(this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offerValue != null){
                this.template.querySelector("lightning-input[data-my-id="+offerString+"]").classList.remove('slds-hidden');
            }
        }
     }
  otmIncrement(event){
     // console.log('DataSet'+event.currentTarget.dataset.mrc+' '+event.currentTarget.dataset.location+' '+event.currentTarget.dataset.otm)

    let gIndex = event.currentTarget.dataset.id;
    let pIndex = event.currentTarget.dataset.plant;
    let index = event.currentTarget.dataset.mrc;
    let count = event.currentTarget.dataset.count;
    //let totalIndex = parseInt(gIndex)+parseInt(pIndex)+parseInt(index);
    let totalIndex = parseInt(count);
    let otmString = 'otm'+totalIndex;
    let incrementedValue = 0;
    //let res = parseInt(presentValue.split("."));
    let offerPriceString = 'offerPrice'+totalIndex;
    let offerString = 'offer'+totalIndex;

    let presentValue=this.template.querySelector("div[data-id="+otmString+"]").innerHTML;
    console.log('presentValue:'+presentValue);
    let offerPriceInput = this.template.querySelector("lightning-input[data-my-id="+offerPriceString+"]");
    if(presentValue!='' && presentValue!=null && offerPriceInput!=null){
        let currentOffer=this.template.querySelector("lightning-input[data-my-id="+offerPriceString+"]").value;
        console.log('offerPriceString:'+offerPriceString);
        if(currentOffer!=0){
            presentValue = currentOffer ;
        }
        console.log('currentOffer:'+currentOffer);
        console.log('presentValue:'+presentValue);

        const presentValueArray = presentValue.split(".");

        console.log('parseFloat(presentValue):'+(parseFloat(presentValue)));
        let decimalValue = ('0.'+presentValueArray[1])%0.05;
        decimalValue = Math.round((decimalValue + Number.EPSILON) * 100) / 100;
        console.log('decimalValue::'+decimalValue);
        if(decimalValue > 0.00){
            if(parseFloat(decimalValue)==0.05){
                incrementedValue= (parseFloat(presentValue)+decimalValue).toFixed(2);
                console.log('incrementedValue in if::'+incrementedValue);
            }
            else{
                incrementedValue= (parseFloat(presentValue)+(0.05-(decimalValue))).toFixed(2);
                console.log('incrementedValue in else::'+incrementedValue);
            }
        }else {
            incrementedValue= (parseFloat(presentValue)+0.05).toFixed(2);
            console.log('incrementedValue in e else::'+incrementedValue);
        }
        console.log('incrementedValue:'+incrementedValue);
        //this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].finalOtm = incrementedValue;
        //this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offer = incrementedValue;
        this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offerValue = incrementedValue;

        if(this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offerValue != null){
            this.template.querySelector("lightning-input[data-my-id="+offerString+"]").classList.remove('slds-hidden');
        }
    }
  }
    otmEquals(event){
        let gIndex = event.currentTarget.dataset.id;
        let pIndex = event.currentTarget.dataset.plant;
        let index = event.currentTarget.dataset.mrc;
        let count = event.currentTarget.dataset.count;
        //let totalIndex = parseInt(gIndex)+parseInt(pIndex)+parseInt(index);
        let totalIndex = parseInt(count);
        let otmString = 'otm'+totalIndex;
        let offerString = 'offer'+totalIndex;
        if(this.template.querySelector("div[data-id="+otmString+"]").innerHTML!=null && this.template.querySelector("div[data-id="+otmString+"]").innerHTML!=''){
            this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offer = this.template.querySelector("div[data-id="+otmString+"]").innerHTML;
            if(this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offer != null){
                this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offerValue = this.template.querySelector("div[data-id="+otmString+"]").innerHTML;
                this.template.querySelector("lightning-input[data-my-id="+offerString+"]").classList.remove('slds-hidden');
            }
        }
    }
       // Ashish : this mathod will Replace "-" sign under 1167553.
    offeredVolumeCheck(event) {
        console.log('event.target.value:'+event.target.value);
        var str = (event.target.value).toString();
        str = str.replace(/-/g,'');
        console.log('str:'+str);
        //alert(str);
        event.target.value = str;
    }



    keycheck(event) {
        //const typedValue = evt.target.value;
        //const trimmedValue = typedValue.trim(); // trims the value entered by the user
        //if (typedValue !== trimmedValue) {
        console.log('event.target.value:'+event.target.value);
        var str = (event.target.value).toString();
        str = str.replace(/-/g,'');
        console.log('str:'+str);
        //alert(str);
        event.target.value = str;
        let gIndex = event.currentTarget.dataset.id;
        let pIndex = event.currentTarget.dataset.plant;
        let index = event.currentTarget.dataset.mrc;
        let totalIndex = parseInt(gIndex)+parseInt(pIndex)+parseInt(index);
        /*
        let offerVolString = 'offer'+totalIndex;
        console.log('gIndex:'+gIndex+'~pIndex:'+pIndex+'~index:'+index+'~totalIndex:'+totalIndex+'~offerVolString:'+offerVolString);
        console.log('this.completedMasterTriggerSHTData:'+JSON.stringify(this.completedMasterTriggerSHTData));

        if(parseFloat(str)>0 && str!=null ){
            if(this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offerValue != null){
                this.template.querySelector("lightning-input[data-my-id="+offerVolString+"]").classList.remove('slds-hidden');
            }
        }else{
            if(this.completedMasterTriggerSHTData[index].plants[pIndex].gradeGroup[gIndex].offerValue != null){
                this.template.querySelector("lightning-input[data-my-id="+offerVolString+"]").classList.add('slds-hidden');
            }
        }
        */

        let count = event.currentTarget.dataset.id;
        let offerVolString = 'offer'+count;
        let offerPriceString = 'offerPrice'+count;
        console.log('gIndex:'+gIndex+'~pIndex:'+pIndex+'~index:'+index+'~totalIndex:'+totalIndex+'~offerVolString:'+offerVolString);
        console.log('this.completedMasterTriggerSHTData:'+JSON.stringify(this.completedMasterTriggerSHTData));
        console.log('this.template.querySelector("lightning-input[data-my-id="+offerPriceString+"]").value:'+this.template.querySelector("lightning-input[data-my-id="+offerPriceString+"]").value);
        if(parseFloat(str)>0 && str!=null ){
            if(this.template.querySelector("lightning-input[data-my-id="+offerPriceString+"]").value != null){
                this.template.querySelector("lightning-input[data-my-id="+offerVolString+"]").classList.remove('slds-hidden');
            }
        }else{
            if(this.template.querySelector("lightning-input[data-my-id="+offerPriceString+"]").value != null){
                this.template.querySelector("lightning-input[data-my-id="+offerVolString+"]").classList.add('slds-hidden');
            }
        }

    }

    saveOfferPrice(event){
        this.isLoading = true;
        let allPlants=[];
        this.isLoading = true;
        console.log('completedMasterTriggerSHTData::'+JSON.stringify(this.completedMasterTriggerSHTData));
        if(this.completedMasterTriggerSHTData !=null && this.completedMasterTriggerSHTData !=undefined){ //Ashish :added code for removing component Error under 1165063
            for(var i=0; i<(this.completedMasterTriggerSHTData).length; i++){
                for(var j=0; j<(this.completedMasterTriggerSHTData[i].plants).length; j++ ){
                    for(var k=0; k<(this.completedMasterTriggerSHTData[i].plants[j].gradeGroup).length; k++){
                        let eachPlant = this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k];
                        console.log('eachPlant:'+JSON.stringify(eachPlant));
                        let count = eachPlant['count'];
                        //let offerVolumeString = 'offer'+k;
                        //let offerPrice = 'offerPrice'+k;
                        let offerVolumeString = 'offer'+count;
                        let offerPrice = 'offerPrice'+count;
                        let offerTrack = {};
                        console.log('~~~~~offerPrice:'+offerPrice+'~~'+'offerVolumeString'+offerVolumeString);
                        offerTrack.mrcNo = this.completedMasterTriggerSHTData[i].mrcNo;
                        offerTrack.shipToNum = this.completedMasterTriggerSHTData[i].plants[j].shipToNum;
                        offerTrack.plantCode = this.completedMasterTriggerSHTData[i].plants[j].locationId;
                        offerTrack.bsp = eachPlant['bsp'];
                        offerTrack.finalOtm = eachPlant['finalOtm'];
                        //offerTrack.offerValue = eachPlant['offerValue'];
                        if(this.template.querySelector("lightning-input[data-my-id="+offerPrice+"]") != null){
                            console.log('offerValueNew+:~'+offerPrice+'~~'+this.template.querySelector("lightning-input[data-my-id="+offerPrice+"]").value);
                            offerTrack.offerValue = parseFloat(this.template.querySelector("lightning-input[data-my-id="+offerPrice+"]").value);
                            this.template.querySelector("lightning-input[data-my-id="+offerPrice+"]").value = ''; // Clearing the field as this needs to be null after save
                        }else{
                            offerTrack.offerValue=0;
                        }
                        offerTrack.mrcLineItem = eachPlant['mrcLineItem'];
                        offerTrack.soldTo = eachPlant['soldTo'];
                        offerTrack.soldToNumber = eachPlant['soldToNumber'];
                        offerTrack.ShipTo = eachPlant['ShipTo'];
                        offerTrack.shipToName = eachPlant['shipToName'];
                        offerTrack.soldToNumber = eachPlant['soldToNumber'];
                        offerTrack.tranche = eachPlant['tranche'];
                        offerTrack.startDate = eachPlant['startDate'];
                        offerTrack.endDate = eachPlant['endDate'];
                        offerTrack.salesOrg = eachPlant['salesOrg'];
                        if(this.template.querySelector("lightning-input[data-my-id="+offerVolumeString+"]")!=null){
                            offerTrack.offerVolume = ((this.template.querySelector("lightning-input[data-my-id="+offerVolumeString+"]").value!=undefined) && (this.template.querySelector("lightning-input[data-my-id="+offerVolumeString+"]").value!='') && (this.template.querySelector("lightning-input[data-my-id="+offerVolumeString+"]").value!=null))?this.template.querySelector("lightning-input[data-my-id="+offerVolumeString+"]").value:0;
                        }else{
                            offerTrack.offerVolume = 0;
                        }
                        //offerTrack.offerVolume = '';
                        console.log('offerTrack.offerVolume:'+offerTrack.offerVolume);

                        if(offerTrack.offerValue!='' && offerTrack.offerValue>0){
                            offerTrack.grade = this.completedMasterTriggerSHTData[i].plants[j].gradeGroup[k].grade;
                            allPlants.push(offerTrack);
                        }
                    }
                }
            }
        }

        console.log('allPlants::'+JSON.stringify(allPlants));
        console.log('this.parentMessage:'+this.parentMessage);
        var isError = false;
        var msg ='';
        var count=0;
        var totalSize=allPlants.length;

        for(var i=0;i<allPlants.length;i++)
        {
            //alert(totalSize);
            if(allPlants[i].offerValue == '' || allPlants[i].offerValue == undefined || allPlants[i].offerValue == null)
            {
                //alert(allPlants[i].offerValue);
                count++;
                //alert(count);
            }
            //isError=true;
            //msg='Please Enter Values for atleast one Deal before Saving!';
        }
        if(count == totalSize){
            isError=true;
            msg='Please enter values for at least one offer before saving!';
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
            saveOfferTrackDetails({
                dataList :JSON.stringify(allPlants),
                checked : this.retailMixChecked
            }).then(saveOfferResponse=>{
                console.log('saveOfferResponse::'+JSON.stringify(saveOfferResponse));
                if(saveOfferResponse=='success'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Offer(s) has been successfully saved',
                            variant: 'success',
                        }),
                    );
                    this.isLoading = false;
                    this.recieveData(this.parentMessage);
                }else if(saveOfferResponse=='error'){
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error while saving the offer',
                            variant: 'error',
                        }),
                    );
                }
            })
            .catch(error =>{
                this.isLoading = false;
                console.log('Error while saving the offer::'+JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            })
        }
    }
}
