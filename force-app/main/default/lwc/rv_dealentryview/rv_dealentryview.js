/**
 ** Created by ===========> Swarna.Makam on 12/26/2021.
 */



 import { LightningElement, wire, track, api } from 'lwc';
 import getMRCData from '@salesforce/apex/rv_sht_CreateControllerLWC.getMrcData';
 import {subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
 import refreshDataChannel from '@salesforce/messageChannel/Rv_DiPublishSearchFilter__c';
 import saveEnteredDeals from '@salesforce/apex/rv_sht_CreateControllerLWC.saveSHTObjectRecordLWC';
 import updateSavedSHTRecord from '@salesforce/apex/rv_sht_CreateControllerLWC.updateSHTObjectRecord';
 import getsavedDeals from '@salesforce/apex/rv_sht_CreateControllerLWC.getSavedSHTDeal';
 import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
 import cancelSHTDeal from '@salesforce/apex/rv_sht_CreateControllerLWC.cancelSHTDeal';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import getAllSHTDeals from '@salesforce/apex/rv_sht_CreateControllerLWC.getAllSHTDeals';
 import UserAccessMessagesLabel from '@salesforce/label/c.RV_UserAccessMessages';

 
 export default class RvDealentryview extends LightningElement {
     @api accountId;
     @track potype='TSFP';
     subscription = null;
     @track dealEntrySHTData =[];
     @track mogasSummation=0;
     @track contractStartDate;
     @track contractEndDate;
     @track savedDealEntrySHTData = [];
     @track reloadCompletedDeals = true;
     @track show = true;
     @track spCheckModal = false;
     @track hideCreateDealsSection = true;
     @track dealEntrySHTDataAvailability;
     @track interval; // added as part of Bug-1261339
     isLoading = false;
     @track _customerName;
     isDisabled = false;
     dealEntryCss = 'row';
     completedDealCss = '';
    @track spPerCondRed='color:red';
    @track spPerCondBlack='color:black';
    confirmCancelDisable = false;

 
 @wire(MessageContext)
     messageContext;
 
 /* @wire(getsavedDeals)
 wiredSHTDeals({data, error}){
     console.log('data in wired function::'+JSON.stringify(data));
     if(data) {
         this.savedDealEntrySHTData =data;
         this.error = undefined;
     }else {
         this.savedDealEntrySHTData =undefined;
         this.error = error;
     }
 }*/
     connectedCallback(){
         this.hideCreateDealsSection = true;
         //alert('In dealENtry');
         this.subscribeToMessageChannel();
         this.loadSavedDeals();
         this.invokeParent();
         this.handleSHTAccess();
     }

     handleSHTAccess(){
        getAllSHTDeals()
            .then(result => {
                if(result.hasEditAccess === false){
                    this.dealEntryCss = 'row readonly-page';
                    this.completedDealCss = 'readonly-page';
                    this.isDisabled = true;
                     this.confirmCancelDisable = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            message: UserAccessMessagesLabel,
                            variant: 'warning',
                        }),
                    );
                }
            })
            .catch(error => {
                this.error = error;
            });
    }
 
     loadSavedDeals() {
        //commenting this as load saved deals is getting called at regular intervals 
       // this.isLoading = true;
         getsavedDeals()
             .then(result => {
                 console.log('in saved deals::'+JSON.stringify(result));
                 this.savedDealEntrySHTData = result;
                 console.log('in savedDealEntrySHTData::'+JSON.stringify(savedDealEntrySHTData));
			    this.isLoading = false;
							
             })
             .catch(error => {
			     this.isLoading = false;					   
                 this.error = error;
             });
     }
 
     disconnectedCallback(){
         this.unsubscribeToMessageChannel();
     }
 
     subscribeToMessageChannel(){
         //alert('In subscribeToMessageChannel');
         if(!this.subscription){
             this.subscription = subscribe(
                 this.messageContext,
                 refreshDataChannel,
                 (message) => this.recieveData(message),
                 {
                     scope: APPLICATION_SCOPE
                 }
             );
         }
     }
 
     unsubscribeToMessageChannel(){
         unsubscribe(this.subscription);
         this.subscription = null;
     }
     invokeParent() {
        console.log( 'Inside invokeParent function ' );
        this.dispatchEvent( new CustomEvent( 'pass', {
            detail: 'MessageFromDealEntry'
        } ) );

    }
    @api recieveData(message){
								 
         if(message != undefined){
         if(message.eventType === 'publish' || message.eventType === 'search'){
                 this.hideCreateDealsSection = true;
                 this.accountId = message.customerId;
                 console.log('Record Id from channel in dealEntry :'+this.accountId);
                 //refreshApex(this.wiredCustomerData);
         } else if(message.eventType === 'deSelectedCustomer') {
            this.dealEntrySHTData = [];
            this.dealEntrySHTDataAvailability = 'Please select a Customer/MRC and TSFP PO Type to book the deals in Deal Entry!';
         }
		
		    this.getMRCDataToCreate(message);
         }else{
            this.dealEntrySHTData = [];
            this.dealEntrySHTDataAvailability = 'Please select a Customer/MRC and TSFP PO Type to view the deals in Deal Entry!';
        }
		 
     }
 @track retailMixchecked;
 @track salesOrg;
     getMRCDataToCreate(message){
                 console.log('In DealEntry view');
                  let filterObj = message.filterData;
                  if(filterObj != undefined){
                  //filterObj::{"customerRecId":"0012500001RIxDuAAL","mrcNo":["0320078090","0321295798"],"shipToNum":"11176945","mot":["10"],
                  //"olfOnly":false,"salesOrg":"DE01","product":"AGO;MOGAS","retailMix":false,"energyTax":"Taxed","poType":"TSFP",
                  //"depot":"a0M25000009IoR6EAK","startDate":"2021-09-26","endDate":"2021-09-27"}
                  console.log('filterObj::'+JSON.stringify(filterObj));
                  console.log('product::'+filterObj.product);
                  console.log('filterObj.mot in dealentry: '+filterObj.mot);
                  this.contractStartDate = filterObj.startDate;
                  this.contractEndDate = filterObj.endDate;
                  let product = filterObj.product;
                  let agoCheck = false;
                  let igoCheck = false;
                  let mogasCheck = false;
                  this.retailMixchecked = filterObj.retailMix;
                  this.salesOrg = filterObj.salesOrg;
                  if(product.includes('AGO')){
                     agoCheck = true;
                  }else{
                     agoCheck = false;
                  }
                  if(product.includes('IGO')){
                     igoCheck = true;
                  }else{
                     igoCheck = false;
                  }
                  if(product.includes('MOGAS')){
                     mogasCheck = true;
                  }else{
                     mogasCheck = false;
                  }
                  
                 /*"tranche" : tranche,
                                                 "Mrcno" : Mrcno,
                                                 "accId" : accnt,
                                                 "shipto" :shipto,
                                                 "checked":checkVal,
                                                 "agoChk" :agoChk ,
                                                 "igoChk" : igoChk,
                                                 "mogasChk" :mogasChk,
                                                 "poType" :component.get("v.poType"),
                                                 "plant":component.get("v.plant"),
                                                 "mot":component.get("v.mot"),
                                                 "contractStartDate" : component.get("v.ContractStartDate"),
                                                 "contractEndDate" : component.get("v.ContractEndDate"),
                                                 "callFromOlf" : false,
                                                 //START - Rahul Sharma | Date - 21-Jul-2020 : Adding additional check to filter OLF deals
                                                 "OLFOnly" :component.get("v.OLFOnly")*/
        if(filterObj.poType == 'TSFP' || filterObj.poType == 'Dummy'){
         getMRCData({
                 tranche : filterObj.tranche,//"ATP1"
                 Mrcno : JSON.stringify(filterObj.mrcNo),
                 accId: filterObj.customerRecId,//0012500001RIxJQAA1
                 shipto : filterObj.shipToNum,//JSON.stringify(filterObj.shipToNum),
                 checked : filterObj.retailMix,//retailMix
                 agoChk : agoCheck ,
                 igoChk : igoCheck,
                 mogasChk : mogasCheck,
                 poType : filterObj.poType,
                 salesOrg :filterObj.salesOrg,
                 plant : filterObj.depot,//JSON.stringify(filterObj.depot),
                 //mot : 'Truck-10',//filterObj.mot+'',
                 mot:filterObj.mot,
                 contractStartDate : filterObj.startDate,
                 contractEndDate : filterObj.endDate,
                 callFromOlf : false,
                 OLFOnly : filterObj.olfOnly
         }).then(returnResponse =>{
                 console.log('GetMRCData::'+JSON.stringify(returnResponse));
                 this._customerName = returnResponse[0].accName;
                 if(returnResponse){
                     
                     console.log('GetMRCData inside');
                     //this.dealEntrySHTData = returnResponse;
                 }
                     let groupMRCData = new Map();
                     let groupPlantData = new Map();
                     let count =0;
                     let gradeset = new Set();
                     returnResponse.forEach(mrcData =>{
														
																			
                         let newPlantGroupMogas = null;
                         if(!gradeset.has(mrcData.mrcNameMogas+mrcData.mrcNo+mrcData.locationName+'ULG') && mrcData.grade.startsWith('ULG')){
                          
                             newPlantGroupMogas = {};
                             newPlantGroupMogas.grade = 'MOGAS';
                             newPlantGroupMogas.mogas = true;
                             newPlantGroupMogas.mogasSummation= 0;
                             newPlantGroupMogas.mogasId = 'mogasRec'+mrcData.mrcNameMogas+(mrcData.locationId).replaceAll(' ',''); 
                             let locGrade = mrcData.mrcNameMogas+mrcData.mrcNo+mrcData.locationName+'ULG';
                             gradeset.add(locGrade);
                             count++;
                         }
                         let newPlantGroup = {};
                         newPlantGroup.locationName = mrcData.locationName;
                         newPlantGroup.mrcNo = mrcData.mrcNo;
                         newPlantGroup.locationCode = mrcData.location;
                         newPlantGroup.locationId = mrcData.locationId;
                         newPlantGroup.location = mrcData.location;
                         newPlantGroup.salesOrg = mrcData.salesOrg;
                         newPlantGroup.mrcId = mrcData.mrcId;
                         newPlantGroup.accId = mrcData.accId;
                         newPlantGroup.shipToNum = mrcData.shipToNumber;
                         newPlantGroup.shipToNumber = mrcData.shipToNumber;
                         newPlantGroup.shipToName = mrcData.accName;
                         newPlantGroup.finalbspCal = mrcData.finalbspCal;
                         newPlantGroup.finalSalesPriceCal = mrcData.finalSalesPriceCal;
                         newPlantGroup.grade = mrcData.grade;
                         newPlantGroup.materialNo = mrcData.materialNo;
                         newPlantGroup.dailySales = parseInt(mrcData.dailySales);
                         newPlantGroup.otm = mrcData.OTM;
                         newPlantGroup.finalOTM = mrcData.finalOTM;
                          newPlantGroup.showFinalOTM = mrcData.showFinalOTM;
                         newPlantGroup.tranche = mrcData.tranche;
                         if(newPlantGroup.otm==newPlantGroup.finalOTM){
                            newPlantGroup.showOTM = false;
                        }else{
                            newPlantGroup.showOTM = true;
                        }
                         newPlantGroup.dealmargin = mrcData.dealmargin;
                         newPlantGroup.onlineATP =parseInt(mrcData.onlineATP);
                         newPlantGroup.phoneATP = parseInt(mrcData.atpLive);
                         newPlantGroup.margin = mrcData.finalSalesPriceCal-mrcData.OTM ;
                         newPlantGroup.lastOfferedPrice = mrcData.lastOfferedPrice;
                         newPlantGroup.isGsapDealCancelOn = mrcData.isGsapDealCancelOn;
                         newPlantGroup.isGsapDealCreateOn = mrcData.isGsapDealCreateOn;
                         newPlantGroup.isPricingTaxed = mrcData.isPricingTaxed;
						 newPlantGroup.pricingCondition = mrcData.pricingCondition;  
                         newPlantGroup.isVolToBeHedged = mrcData.isVolToBeHedged;
                         newPlantGroup.isZeroPriceDeal = mrcData.isZeroPriceDeal;
                         newPlantGroup.retroGsapDealCreateOn = mrcData.retroGsapDealCreateOn;
                         newPlantGroup.retroGsapDealCancelOn = mrcData.retroGsapDealCancelOn;
                         newPlantGroup.retroVolToBeHedged = mrcData.retroVolToBeHedged;
                         newPlantGroup.retroAtpVoltoBeReduced = mrcData.retroAtpVoltoBeReduced;
                         newPlantGroup.atpVoltoBeReduced = mrcData.atpVoltoBeReduced;
                         //newPlantGroup.mrcName = mrcData.mrcName.split('-')[0]+'-' + mrcData.shipToNumber;
                        newPlantGroup.mrcName = mrcData.mrcName;
                         console.log('newPlantGroup::'+JSON.stringify(newPlantGroup));

                          if(groupPlantData.has(mrcData.locationName+mrcData.mrcName.split('-')[0])){
                         if(newPlantGroupMogas != null){
                             groupPlantData.get(mrcData.locationName+mrcData.mrcName.split('-')[0]).push(newPlantGroupMogas);
                         }
                         groupPlantData.get(mrcData.locationName+mrcData.mrcName.split('-')[0]).push(newPlantGroup);
                         console.log('groupPlantData in if::'+groupPlantData);
                     }else{
                         let plantGroupList = [];
                         if(newPlantGroupMogas != null){
                             plantGroupList=[newPlantGroupMogas,newPlantGroup];
                         }
                         else{
                             plantGroupList=[newPlantGroup];
                         }
                         
                       
                         groupPlantData.set(mrcData.locationName+mrcData.mrcName.split('-')[0],plantGroupList);
                         console.log('groupPlantData::'+JSON.stringify(groupPlantData));
                     } 
                    
                         count++;
                     });
                 
                     console.log('PlantData::'+groupPlantData);
                     let plantNames = new Set();
										   
                     returnResponse.forEach(mrcData => {     
                         
                         let newMRCGroup = {};
                        newMRCGroup.mrcName = mrcData.mrcName.split('-')[0] + mrcData.shipToNumber;
                         newMRCGroup.contractDesc = mrcData.contractDescription;
                         newMRCGroup.location = mrcData.locationName;
                         newMRCGroup.locationCode = mrcData.location;
                         newMRCGroup.locationId = mrcData.locationId;
                         newMRCGroup.shipToNum = mrcData.shipToNumber;
                         newMRCGroup.shipToName = mrcData.accName;
                         newMRCGroup.gradeGroup = groupPlantData.get(mrcData.locationName+mrcData.mrcName.split('-')[0]);
                         newMRCGroup.rowspan = groupPlantData.get(mrcData.locationName+mrcData.mrcName.split('-')[0]).length+1;

                        
                         if(!plantNames.has(mrcData.locationName+mrcData.mrcName.split('-')[0])){
                            if(groupMRCData.has(mrcData.mrcName.split('-')[0] +'-' + mrcData.shipToNumber)){
                                groupMRCData.get(mrcData.mrcName.split('-')[0] +'-' + mrcData.shipToNumber).push(newMRCGroup);
                            }else{
                                let mrcGroupList =[newMRCGroup];                                
                                groupMRCData.set(mrcData.mrcName.split('-')[0] +'-' + mrcData.shipToNumber,mrcGroupList);
                            }
                            console.log('loc name + mrc Name::'+mrcData.locationName+mrcData.mrcName.split('-')[0]);
                         plantNames.add(mrcData.locationName+mrcData.mrcName.split('-')[0]);
                         console.log('plantNames in loop::'+JSON.stringify(plantNames));
                     }
                  
 
                       console.log('plantNames::'+plantNames);  
                     });
                     
 
                     console.log("Master Data :"+groupMRCData);
                   
                     let itr = groupMRCData;
                     let mrcArray =[];
                     groupMRCData.forEach((values,keys)=>{
                         console.log(JSON.stringify(values)+' '+ JSON.stringify(keys));
                         let mrc = {};
                         const headerSplit = keys.split("-");
                         mrc.mrcNo = headerSplit[0]+'--'+values[0].contractDesc+'--'+values[0].shipToNum;
                        // console.log('accNum::'+values[0].location+'***'+values[0].shipToNum+'----'+JSON.stringify(groupMRCData.get(keys).shipToNum));
                         //const headerSplit = keys.split("-");
                       //  mrc.mrcNo = headerSplit[0];
                       //  mrc.rowSpan = values.gradeGroup.length + 1;
                         mrc.plants = values;
                         mrcArray.push(mrc);                      
                     })
                     this.dealEntrySHTData = mrcArray;
                     console.log('MRC Array'+mrcArray+'----'+this.dealEntrySHTData);
                 /*GetMRCData::[{"accId":"0012500001RIxCsAAL","accName":"ADOLF ROTH GMBH & CO","atpLive":8284,"atpVoltoBeReduced":true,
                 "finalbspCal":78.73,"finalSalesPriceCal":78.73,"grade":"AGO B7","isGsapDealCancelOn":true,"isGsapDealCreateOn":true,
                 "isPricingTaxed":true,"isVolToBeHedged":true,"isZeroPriceDeal":false,"landedCostCal":38.88,"location":"D229",
                 "locationCode":"a0M25000009IoR6EAK","locationName":"Godorf Shell Gantry","materialName":"TP AGO 10ppmS B7 UdUm Low Dose dealer DE",
                 "materialNo":"1685","mrcId":"a0N25000006hnPjEAI","mrcName":"0321492213-106229","OTM":78.73,"pricingCondition":"YP23",
                 "retroAtpVoltoBeReduced":false,"retroGsapDealCancelOn":true,"retroGsapDealCreateOn":true,"retroVolToBeHedged":false,
                 "salesOrg":"AT01","shipToNumber":"0012567495"}]*/
 
                 //this.saveSHTFromDealEntry();
 
         }).catch(getMRCDataerror => {
               console.log('Error In DealEntry GetMRCData::'+JSON.stringify(getMRCDataerror));
               this.dealEntrySHTData = [];
               this.dealEntrySHTDataAvailability = 'No Deals are available with filter search!';
           });
         }
        else{
            this.dealEntrySHTData = [];
               this.dealEntrySHTDataAvailability = 'Please select TSFP PO Type to book the deals in Deal Entry!';
        }
                  }
     }
     getSortOrder(groupPlantData){
         const sort_by = (field, reverse, primer) => {
 
             const key = primer ?
               function(x) {
                 return primer(x[field])
               } :
               function(x) {
                 return x[field]
               };
           
             reverse = !reverse ? 1 : -1;
           
             return function(a, b) {
               return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
             }
           }
 
           return groupPlantData.sort(sort_by('grade', false, (a) =>  a.toUpperCase()));
     }
     onchangeTriggerVolume(event){
         console.log('volume::'+event.target.value);
         var str = (event.target.value).toString();
         str = str.replace(/-/g,'');
         event.target.value = str;
         let gIndex = event.currentTarget.dataset.id;
         let pIndex = event.currentTarget.dataset.plant;
         let index = event.currentTarget.dataset.mrc;
         let totalIndex = parseInt(gIndex)+parseInt(pIndex)+parseInt(index);
         let mrc = this.dealEntrySHTData[index].mrcNo;
         let plant = this.dealEntrySHTData[index].plants[pIndex].locationId;
         plant = plant.replaceAll(' ','');
         let mrcPlantCombo ='mogasRec'+mrc.split("-")[0]+plant;
         let volumeArray = [];
         let totalVolume = 0;
         let indexOfMogas =0;
         let countOfIndex=0
         //volumeArray = this.dealEntrySHTData[index].plants[pIndex];
         this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].volumeCBM = event.target.value;
 
         this.dealEntrySHTData[index].plants[pIndex].gradeGroup.forEach(gradeData =>{
             countOfIndex++;
             console.log("before"+gradeData.mogasId+" "+mrcPlantCombo+" "+totalVolume+" "+countOfIndex+" "+gradeData.volumeCBM+" "+gradeData.grade.startsWith('ULG')+" "+gradeData.grade);
             if(gradeData.volumeCBM != '' && gradeData.grade.startsWith('ULG') && gradeData.volumeCBM != null){
 
                 totalVolume = totalVolume+parseInt(gradeData.volumeCBM);
             }
             if(gradeData.mogasId != null && gradeData.mogasId == mrcPlantCombo ){
                 indexOfMogas=countOfIndex;
             }
             
         })
         if(this.dealEntrySHTData[index].plants[pIndex].gradeGroup[indexOfMogas-1] != undefined){
 
             this.dealEntrySHTData[index].plants[pIndex].gradeGroup[indexOfMogas-1].mogasSummation=totalVolume;
         }
         
         
         /*if(this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex] == totalidx){
             
             let currentMogasRec =this.template.querySelector("td[data-id="+totalidx+"]").innerHTML;
             this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].mogasSummation = this.mogasSummation;
         }*/
 
         //this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex-1].volumeCBM = event.target.value;
        /* var totalVol=0;
         for(var i=0; i<=gIndex; i++){
             let currentMogasRec =this.template.querySelector("td[data-label="+gradeString+"]").innerHTML;
             this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex-i].volumeCBM = event.target.value;
             totalVol = totalVol+this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex-i].volumeCBM
         }*/
 
     }
 
     onchangeTriggerSP(event){
         console.log('SP Val::'+event.target.value);
         var str = (event.target.value).toString();
         str = str.replace(/-/g,'');
         event.target.value = str;
         let gIndex = event.currentTarget.dataset.id;
         let pIndex = event.currentTarget.dataset.plant;
         let index = event.currentTarget.dataset.mrc;
         let totalIndex = parseInt(gIndex)+parseInt(pIndex)+parseInt(index);
         console.log('totalIndex Val::'+totalIndex);
         //let currentbspVal =this.template.querySelector("td[data-label=BSP]").innerHTML;
         let currentbspVal =this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].finalbspCal;
         console.log('currentbspVal Val::'+currentbspVal+'--'+this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].finalbspCal);
         let priceperVol = event.target.value - parseFloat(currentbspVal);
         console.log('priceperVol Val::'+priceperVol);
         this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].priceperVol = event.target.value;
         if(event.target.value == ''){
             this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].salesMargin = '';
         }else{
         this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].salesMargin = parseFloat(priceperVol).toFixed(2);
         }
         //pricePerVol
     }
 
     onchangeDealComment(event){
         let gIndex = event.currentTarget.dataset.id;
         let pIndex = event.currentTarget.dataset.plant;
         let index = event.currentTarget.dataset.mrc;
         this.dealEntrySHTData[index].plants[pIndex].gradeGroup[gIndex].Comment = event.target.value;
     }
     saveSHTFromDealEntry(event){
        this.isLoading = true; 							   
         let allPlants=[];
          for(var i=0; i<(this.dealEntrySHTData).length; i++){
                 for(var j=0; j<(this.dealEntrySHTData[i].plants).length; j++ ){
                     for(var k=0; k<(this.dealEntrySHTData[i].plants[j].gradeGroup).length; k++){
                         let eachPlant = this.dealEntrySHTData[i].plants[j].gradeGroup[k];
                         if(eachPlant['volumeCBM'] != undefined && eachPlant['volumeCBM'] != "" && eachPlant['grade'] != 'MOGAS'){
                             allPlants.push(this.dealEntrySHTData[i].plants[j].gradeGroup[k]);
                         }
                     }
                  }
             }
         console.log('allPlants::'+JSON.stringify(allPlants));
         var isError = false;
         var msg ='';
         var count=0;
         var  totalSize=allPlants.length;
         for(var i=0;i<allPlants.length;i++){
            if((allPlants[i].volumeCBM == null || allPlants[i].volumeCBM == '' || allPlants[i].volumeCBM == undefined) &&
                (allPlants[i].priceperVol == null || allPlants[i].priceperVol == '' || allPlants[i].priceperVol == undefined )){
                 count++;
             }
             if(allPlants[i].volumeCBM != null){
                 if((!allPlants[i].isZeroPriceDeal) &&(allPlants[i].priceperVol == '' || allPlants[i].priceperVol == undefined || allPlants[i].priceperVol == 0 || allPlants[i].priceperVol == '0')){
                     isError = true;msg='Please enter Price against Volume-'+allPlants[i].volumeCBM+' for MRC NO '+allPlants[i].mrcName;
                     break;
                 }
             }
             if(allPlants[i].priceperVol != null){
                 if((allPlants[i].volumeCBM == '' || allPlants[i].volumeCBM == undefined || allPlants[i].volumeCBM == 0 || allPlants[i].volumeCBM == '0') && !allPlants[i].isZeroPriceDeal){
                     isError = true;msg='Please enter Volume against Price-'+allPlants[i].priceperVol+' for MRC NO '+allPlants[i].mrcName;
                     break;
                 }
             }
         }
         if(count== totalSize){
		    this.isLoading = false; 							 
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
           // alert('')
         saveEnteredDeals({
             dataList :JSON.stringify(allPlants),//this.dealEntrySHTData,
             trancheVal : 'ATP1',
             contractStartDate : this.contractStartDate,
             contractEndDate: this.contractEndDate,
             checked: this.retailMixchecked
         }).then(saveDealResponse=>{
            // console.log('saveDealResponse::'+JSON.stringify(saveDealResponse));
             if(saveDealResponse){
                 this.savedDealEntrySHTData = saveDealResponse['savedResult'];
                 console.log('SHT Record created successfully!!');
                 this.dispatchEvent(
                     new ShowToastEvent({
                     title: 'Success',
                     message: 'SHT Record created Successfully',
                     variant: 'success',
                         }),
                        );
                         this.hideCreateDealsSection = false;
             }
		    this.isLoading = false;
							
 
         })
         .catch(error =>{
		     this.isLoading = false;							
             console.log('error in saving deal::'+JSON.stringify(error));
         })
         }
     }
 
     cancelSavedSHTDeal(event) {
         console.log('========event.currentTarget.dataset.recid========'+event.currentTarget.dataset.recid);
            this.isLoading = true;
            cancelSHTDeal({
                 shtId :event.currentTarget.dataset.recid,
                 status : 'Saved',
                 reason : null,
                 searchList : JSON.stringify([])
                 //RecordId : event.currentTarget.dataset.recid
             })
                 .then(result => {
                     this.dispatchEvent(
                         new ShowToastEvent({
                             title: 'Success',
                             message: 'Saved Deal cancelled Successfully',
                             variant: 'success',
                         }),
                     );
                     // this.savedDealEntrySHTData = result;
                     this.loadSavedDeals();
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
                     //this.loadSavedDeals();
                     this.isLoading = false;
                 });
     }
    /* @track correctionOnSavedDeal = [];
     confirmSavedDeals(){
         console.log('Entered confirmed Deals');
         updateSavedSHTRecord({
             dataList : JSON.stringify(this.savedDealEntrySHTData)
         }).then(result =>{
             console.log('result at confirming::'+JSON.stringify(result));
             this.loadSavedDeals();
             
         })
     }*/
 
     @track correctionOnSavedDeal = [];
 
     confirmSavedDeals(){
	    this.isLoading = true;						   
          console.log('Entered confirmed Deals');
         (this.savedDealEntrySHTData).forEach(savedDeal =>{
             if(savedDeal['spPer100L'] < savedDeal['msp']){
                 (this.correctionOnSavedDeal).push(savedDeal);
             }
         })
         console.log('correction needed::'+(this.correctionOnSavedDeal).length+'--'+JSON.stringify(this.correctionOnSavedDeal));
         if((this.correctionOnSavedDeal).length > 0){
             this.spCheckModal = true;
            this.isLoading = true;
         }
         else if((this.correctionOnSavedDeal).length <= 0){
             this.updateSavedSHTDealRecords();
         }

     }
 
     updateSavedSHTDealRecords(){
         var selLst=[];
         var priceLst=[];
         var volumeLst=[];
         var msg='';
         var isErrorV = false;
         var isErrorP = false;
         for(var i=0;i<(this.savedDealEntrySHTData).length;i++){
             
             if(this.savedDealEntrySHTData[i].selected == true){
                 if(!this.savedDealEntrySHTData[i].isZeroPriceDeal){
                     priceLst.push(this.savedDealEntrySHTData[i].spPer100L);
                 }
                 
                 volumeLst.push(this.savedDealEntrySHTData[i].volCbm);
             }
         }
         if(volumeLst.length>0){
             for(var i=0;i<volumeLst.length;i++){
                 if(volumeLst[i] == '' || volumeLst[i] == undefined){
                     msg = "Volume enterd should not be blank for selected row."
                     isErrorV = true;
                     break;
                 }else{
                     isErrorV = false;
                 }
             }
         }
         if(!isErrorV && priceLst.length>0){
             for(var i=0;i<priceLst.length;i++){
                 if(priceLst[i] == '' || priceLst[i] == undefined){
                     msg = "Price enterd should not be blank for selected row."
                     isErrorP = true;
                     break;
                 }else{
                     isErrorP = false;
                 }
             }
         }
         var validError = false;
             if(isErrorV || isErrorP ){
                 validError = true;
             }else{
                 validError = false;
             }
         console.log('Before confirming on sp popup::'+JSON.stringify(this.savedDealEntrySHTData));
         if(!validError){
             this.isLoading = true;
             updateSavedSHTRecord({
                 dataList : JSON.stringify(this.savedDealEntrySHTData)
             }).then(result =>{
                 console.log('result at confirming::'+JSON.stringify(result));
                 this.correctionOnSavedDeal = [];
                 //added as part of Bug-1261339
                  this.interval = setTimeout(() => {
                    this.loadSavedDeals();
                    const objCompletedChild = this.template.querySelector('c-rv_termtriggercompledtedeals');
                    objCompletedChild.onLoad();
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'SHT Record updated Successfully',
                            variant: 'success',
                        }),
                    );
                    this.hideCreateDealsSection = false;
                }, 10000);
             }).catch(error => {                
                this.isLoading = false;
            });										
									   
			   
         }else{
	        this.isLoading = false;							   
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Error',
                     message: msg,
                     variant: 'error',
                 }),
             );
         }
     }
     handleClickReview(event){
         this.spCheckModal = false;
         this.correctionOnSavedDeal = [];
         this.isLoading = false;
    }
    handleClickConfirm(){
         this.updateSavedSHTDealRecords();
         this.spCheckModal = false; 
    }
     @track spPerCond;
 
     onUpdateTriggerSP(event){
         var selectedRow = event.currentTarget;
         var key = selectedRow.dataset.id;
         var str = (event.target.value).toString();
         str = str.replace(/-/g,'');
         event.target.value = str;
         
         if (this.savedDealEntrySHTData[key] != undefined) {
            this.savedDealEntrySHTData[key].spPer100L = event.target.value;
            let currentSpPerVal = event.target.value;
            let currentbspVal = this.savedDealEntrySHTData[key].bsp;            
            let currentMargin = currentSpPerVal - currentbspVal;
            this.savedDealEntrySHTData[key].targetMargin = currentSpPerVal != '' ? parseFloat(currentMargin).toFixed(2) : '';
        } 
        console.log('sp check::'+this.savedDealEntrySHTData[key].salesPriceCheck+' <--->'+this.savedDealEntrySHTData[key].spPer100L+'<-->'+this.savedDealEntrySHTData[key].msp);
            this.savedDealEntrySHTData[key].msp = this.savedDealEntrySHTData[key].msp == undefined ? null : this.savedDealEntrySHTData[key].msp;
        this.savedDealEntrySHTData[key].spColor = this.savedDealEntrySHTData[key].spPer100L < this.savedDealEntrySHTData[key].msp ? 'color:red;':'color: var(--slds-c-input-text-color, var(--sds-c-input-text-color));';

        /* if(this.savedDealEntrySHTData[key].salesPriceCheck){
        
        this.spPerCondBlack= event.target.value < this.savedDealEntrySHTData[key].msp ? 'color:red;' : 'color: var(--slds-c-input-text-color, var(--sds-c-input-text-color));';
         //  this.spPerCondBlack= event.target.value < 40 ? 'color:red;' : 'color: var(--slds-c-input-text-color, var(--sds-c-input-text-color));';

    }
        else{
            this.spPerCondRed= event.target.value < this.savedDealEntrySHTData[key].msp ? 'color:red;' : 'color: var(--slds-c-input-text-color, var(--sds-c-input-text-color));';
        
        }*/
         /*if(event.target.value < this.savedDealEntrySHTData[key].msp){
             this.template.querySelector("lightning-input[data-id='"+this.savedDealEntrySHTData[key].MrcNo+"']").style.color='red';
         }
         else{
             this.template.querySelector("lightning-input[data-id='"+this.savedDealEntrySHTData[key].MrcNo+"']").style.color='var(--slds-c-input-text-color, var(--sds-c-input-text-color))';
         }*/
     }
 
     onUpdateTriggerVolume(event){
         var selectedRow = event.currentTarget;
         var key = selectedRow.dataset.id;
         var str = (event.target.value).toString();
         str = str.replace(/-/g,'');
         event.target.value = str;
         this.savedDealEntrySHTData[key].volCbm = event.target.value;
     }
 
     onUpdateDealComment(event){
             var selectedRow = event.currentTarget;
             var key = selectedRow.dataset.id;
             this.savedDealEntrySHTData[key].Comment = event.target.value;
             
     }
 
     
     showModalBox() {  
         this.spCheckModal = true;
     }
 
     hideModalBox() {  
         this.spCheckModal = false;
     }
 }