import { LightningElement, track, wire, api } from 'lwc';
import getAllSHTDeals1 from '@salesforce/apex/RV_SHT_CreateController.getAllSHTDeals';
import createSHTObjectRecord from '@salesforce/apex/RV_SHT_CreateController.saveCancelledDealLWC';
import cancelSHTDealRecord from '@salesforce/apex/RV_SHT_CreateController.cancelSHTDeal';
import getCompletedSHTDeals from '@salesforce/apex/RV_SHT_CreateController.getCompletedSHTDeal';
import getCompletedSHTDealWthAdvFilter from '@salesforce/apex/RV_SHT_CreateController.getCompletedSHTDealWithAdvanceFilterWrap';
import {publish,subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import searchFilterChannel from '@salesforce/messageChannel/Rv_DiPublishSearchFilter__c';
import advancedFilterChannel from '@salesforce/messageChannel/Rv_DiPublishAdvanceFilter__c';
import advancedFilterValueChannel from '@salesforce/messageChannel/Rv_DiPublishAdvanceFilterVales__c';
import retryDealinGSAP from '@salesforce/apex/rv_sht_CreateControllerLWC.retrySHTDealtoGSAP';
//Bug-1265721 added apex method=======
import updateCommentsofCompletedDeals from '@salesforce/apex/rv_sht_CreateControllerLWC.updateDealComment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Rv_termtriggercompledtedeals extends LightningElement {
    subscription = null;
    @track completedMasterTriggerSHTData;
    @api createdOn ;
    @api advStatus ;

    @api internetSales;
    @api sAdvanceFilter;
    @api startDte;
    @api endDte;
    @api advcreatedBy;
    @api advSoldTo;
    @api advShtNo;
    @api advpoType;

    soldToOptions;
    createdByOptions;
    shtNoOptions;
    poTypeOptions;

    @track create_newDeal = false;
    @track cancel_shtNo;
    @track cancel_compDealRec;
    @track cancelReason;
    @track cancellationReasonOptions;
    @track haveCancelReason = true;
    @track cancelledStatus = false;
    @track selectedReasonValue;
    @track newDeal;
    @track cancelButton;
    @track cancelReasonVal;
    //added below var:ashish
    plantId;
    customerFilter = '';
    customerRecId;
    customerAccId;
    defaultPlant;
    tranche;
    isDisabled = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.subscribeToMessageChannel();
        this.onLoad();
        this.cancellationReasonOptions = [{ label: 'None', value: 'None'}];
    }
    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }
    subscribeToMessageChannel(){
        //console.log('Subscribe::'+JSON.stringify(message));
        if(!this.subscription){
            this.subscription = subscribe(
            this.messageContext,
            advancedFilterChannel,
                (message) => this.recieveData(message),
                 { scope: APPLICATION_SCOPE }
                );
        }
    }

    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;

    }
    @api
    onLoad() {
                if(this.advStatus !== 'Cancelled' && this.advStatus !== 'Expired'){//PBI - 1288339 by Sampada.Bhat
        getAllSHTDeals1()
            .then(result => {
                this.cancellationReasonOptions = [{ label: 'None', value: 'None'}];
                console.log('data::'+JSON.stringify(result));
                console.log('CompletedDeal::'+JSON.stringify(result.CompletedDeal));
                this.completedMasterTriggerSHTData = result.CompletedDeal;


                if(result.reasonList != undefined){
                            var canreasonLst=[];
                    for (var key in result.reasonList)
                    {
                        if (result.reasonList.hasOwnProperty(key)) {
                            this.cancellationReasonOptions.push({value: result.reasonList[key], label: result.reasonList[key]});
                        }
                    }
                    //this.cancellationReasonOptions = canreasonLst;
                }
                if(result.CompletedDeal[0] != null && result.CompletedDeal[0].tranche!=null){
                    this.tranche = result.CompletedDeal[0].tranche;
                }
                 if(result.CompletedDeal[1] != null && result.CompletedDeal[1].tranche!=null){
                    this.tranche = result.CompletedDeal[1].tranche;
                }
               // this.cancellationReasonOptions = result.reasonList;
            })
            .catch(error => {
                this.error = error;
            });
    }
    }
    recieveData(message){
        // console.log('message from channel::'+JSON.stringify(message));
        if(message.eventType === 'filter'){                               //'search' for search MRC and 'publish' for custom info section
            this.createdOn = message.createdOn;
            this.advStatus = message.advStatus;
            if(message.sAdvanceFilter){
                this.sAdvanceFilter = message.sAdvanceFilter;
                this.internetSales = message.internetSales;
                this.startDte = message.startDte;
                this.endDte = message.endDte;
                this.advcreatedBy = message.advcreatedBy;
                this.advSoldTo = message.advSoldTo;
                this.advShtNo = message.advShtNo;
                this.advpoType = message.advpoType;
                this.dayInterval = 5;
                this.advStatus = message.advStatus;

                console.log('adv filter channel::'+this.sAdvanceFilter+'-'+this.internetSales+'-'+this.startDte+'-'+this.endDte+'-'+this.advStatus);
                console.log('adv filter channel2::'+this.advcreatedBy+'-'+this.advSoldTo+'-'+this.advShtNo+'-'+this.advpoType);

                    this.getCompletedDealsAdvFilters();
            }
            if(this.advStatus == 'Cancelled' || this.advStatus == 'Expired'){
                this.cancelledStatus = true;
            }
            if(this.advStatus == 'Completed'){
                this.cancelledStatus = false;
            }
            console.log('Record Id from channel::'+this.createdOn+'-'+this.advStatus);
            console.log('filter from channel::'+this.startDte+'-'+this.endDte);
            //refreshApex(this.wiredCustomerData);
        //}
        if(!message.sAdvanceFilter){
            getCompletedSHTDeals({
                day : message.createdOn,
                status : message.advStatus,
                createdby :'Me'
                }).then(data => {
                    console.log('data::'+JSON.stringify(data));
                    this.completedMasterTriggerSHTData = data;
                }).catch(error =>{
                    this.error = error;
                });
            }
        }
    }

    getCompletedDealsAdvFilters(){
        getCompletedSHTDealWthAdvFilter({
            createdOnStartDate:this.startDte,
            createdOnEndDate:this.endDte,
            dayInterval:5,
            status:this.advStatus,
            createdBy:this.advcreatedBy,//'005250000089QVEAA2',//advcreatedBy
            soldTo:this.advSoldTo,
            sht:this.advShtNo,
            internetSales:this.internetSales,
            poType:this.advpoType
        })
        .then(data =>{
            console.log('data on advance filter::'+JSON.stringify(data));
            if(data){
                this.completedMasterTriggerSHTData = data.SHTDisplayWrapList;
                if(data.SoldToList != undefined || data.SoldToList != []){
                    this.soldToOptions = data.soldToListMap;
                }
                if(data.shtNoOptions != undefined || data.shtNoOptions != []){
                    this.shtNoOptions = data.SHTListMap;
                }
                if(data.poTypeOptions != undefined || data.poTypeOptions != []){
                    this.poTypeOptions = data.poTypeListMap;//Map;
                }
                this.publishOptions();

            }
        });
    }

    publishOptions(){
        const optionspayload={
            eventType: 'filterValues',
            soldToOptions : this.soldToOptions,
            shtNoOptions: this.shtNoOptions,
            poTypeOptions : this.poTypeOptions
        }
        publish(
            this.messageContext,
            advancedFilterValueChannel,
            optionspayload
        );

    }
    /*

    var action = component.get("c.getCompletedSHTDealWithAdvanceFilterWrap");
        action.setParams({
            	"createdOnStartDate" : createdOnStartDate,
            	"createdOnEndDate" : createdOnEndDate,
            	"dayInterval" : dayInterval,
                "status" : status,
                "createdBy" :createdby,
            	"soldTo" : soldTo,
                "sht" : sht,
                "internetSales" : InternetSales, //270192_OLFDealCancel_08Jul2019_Soumyajit
                "poType" : poType
            	});

                */

    cancelCompledtedTriggerDeal(event){
            this.isDisabled = false;
            let tempdeal = [];
            console.log('event::'+event.target.dataset.id);
            this.cancel_shtNo = event.target.dataset.id;
            if(this.completedMasterTriggerSHTData != undefined){
                for(var i in this.completedMasterTriggerSHTData){
                   // console.log('@133::'+JSON.stringify(this.completedMasterTriggerSHTData[i]));
                   if(this.completedMasterTriggerSHTData[i].shtNo == this.cancel_shtNo){
                    //this.cancel_compDealRec = Object.assign({}, this.completedMasterTriggerSHTData[i]);
                    //this.cancel_compDealRec ={...this.completedMasterTriggerSHTData[i]};
                   // this.cancel_compDealRec = JSON.parse(JSON.stringify(this.completedMasterTriggerSHTData[i]));
                   //const eDate = new Date(this.completedMasterTriggerSHTData[i].contractStartDate);

                  // eDate.setDate(eDate.getDate() + parseInt(14));
					 //this.completedMasterTriggerSHTData[i].contractEndDate =  eDate.toISOString().substr(0,10);

                    tempdeal.push(this.completedMasterTriggerSHTData[i]);
                    console.log('@133::'+JSON.stringify(this.cancel_compDealRec));
                   }
                }
                this.cancel_compDealRec = tempdeal;
                console.log('@188::'+JSON.stringify(this.cancel_compDealRec));
            }

        if(event.target.title=='Cancel & New'){
            this.create_newDeal = true;
            //get AccountId and Location Id and create JSON for rv_searchLookup component to populate Plant value on load
               let cancomDeal = this.cancel_compDealRec[0];
               this.customerAccId = cancomDeal['CustomerId'];
               this.defaultPlant = {
                   "FIELD1" : cancomDeal['location'],
                   "Location_Name__c" : cancomDeal['location'],
                   "record" : {
                    "Location_Name__c" : cancomDeal['location'],
                    "Plant__c" : cancomDeal['locationId']

                   }
               };
         if(!this.customerFilter.includes(this.customerAccId)){
            this.customerFilter =  'Active__c = true and  Sold_To__c=' + '\''+this.customerAccId + '\' LIMIT 1';
            }
        }
        if(event.target.title == 'Cancel'){

            this.cancelButton = false;
            this.cancelSHTDeal();
        }
    }

    handleArrowPress(event){
        if(event.target.value != null){
            this.template.querySelector('rv_search-lookup').handleKeyPress(event.target.value);
        }
    }

     onchangeTriggerVolume(event){
        const selector = 'endDate';
        console.log('onchangeTriggerVolumestart event.target.name '+ event.target.name);

        if(event.target.name == 'startDate')  {
            let startDate = event.target.value;
            console.log('onchangeTriggerVolumestart date '+ event.target.value);
                if(startDate < new Date().toISOString().slice(0, 10)){
               // this.endDateVal = new Date().toISOString().slice(0, 10);
               this.template.querySelector('[data-id="contractEndDate"]').value = new Date().toISOString().slice(0, 10);
           }

        }

    }

    handleLookup(event){
        let selectedRec = event.detail.data;
        if(selectedRec){
            if(selectedRec.currentRecordId == 'Location'){
                if(selectedRec.record){
                    this.plantId = selectedRec.record.Plant__c;
                    this.publishCustomerId();
                }
                else{
                    this.plantId = '';
                }
            }
        }
    }

    publishCustomerId(){
        const payload = {
                        eventType: 'publish',
                        customerId: this.customerRecId,
                        mrcId: this.mrcHeader
        };

        publish(
            this.messageContext,
            searchFilterChannel,
            payload
        );
    }
    close_createDealBox() {
        this.create_newDeal = false;
        this.cancelReason = 'None';
        this.haveCancelReason = true;
    }
   //added by swarna as part of bug-1265721
    onchangeTriggerComments(event){
        console.log('id::'+event.currentTarget.dataset.id);
        console.log('comment value::'+event.target.value);
         updateCommentsofCompletedDeals({
            shtId:event.currentTarget.dataset.id,
            comment:event.target.value
        })
        .then(data =>{
            console.log('updated record::'+JSON.stringify(data));
            if(data){
                let msg= '';
                if(data == 'Success'){
                    msg='Comments Updated Successfully.';

                    this.dispatchEvent(
                    new ShowToastEvent({
                    title: 'Success',
                    message: msg,
                    variant: 'success',
                        }),
                    );
                }
            }
        });
    }
	//end bug-1265721
    handleReasonChange(event){
        this.cancelReasonVal = event.detail.value;
        console.log('cancel Reason val in direct cancel::'+this.cancelReasonVal);

    }
    handleChange(event){
        this.cancelReason = event.detail.value;
        console.log('cancel Reason::'+this.cancelReason);
        if(this.cancelReason != '' || this.cancelReason != null || this.cancelReason != undefined || this.cancelReason != 'None' ){
            this.haveCancelReason = false;
        }else if(this.cancelReason == 'None'){
            this.haveCancelReason = true;
        }
    }
    @track CN_endDateVal;
    addDaysToDate(date, days){
        var someDate = new Date(date);
        someDate.setDate(someDate.getDate() + parseInt(days));
        var dateFormated = someDate.toISOString().substring(0,10);
        console.log('line 120:'+dateFormated);
        return dateFormated;
    }
    validateEndDate(startDateofCancelNew, poType){
            let date1 = new Date(startDateofCancelNew);
            let lastDay = new Date(date1.getFullYear(), date1.getMonth() + 1, 0);
            lastDay.setDate(lastDay.getDate() + 1);
            //this.startDateVal = event.target.value;
            let currentMonth = parseInt((date1.getMonth()+1));
            let CNendDate = this.addDaysToDate(startDateofCancelNew, 14);
            let endDateMonth = parseInt(CNendDate.substring(5, 7));
            if(endDateMonth>currentMonth && poType == 'TTTT'){
                this.CN_endDateVal = lastDay.toISOString().substring(0,10);
            }else{
                this.CN_endDateVal = CNendDate;
            }
            console.log('CN_endDateVal::'+this.CN_endDateVal);
        }

	createCancelledNewDeal(){
        this.isDisabled = true;
		let cancomDeal = this.cancel_compDealRec[0];
            this.defaultPlant = {
                "FIELD1" : cancomDeal['location'],
                "Location_Name__c" : cancomDeal['location'],
                "record" : {
                "Location_Name__c" : cancomDeal['location'],
                 "Plant__c" : cancomDeal['locationId']
                }
            };

        if(this.plantId == 'undefined' || this.plantId == null || this.plantId == ''){
            this.plantId = cancomDeal['locationId'];
        }
        if(this.tranche == '' || this.tranche == 'undefined' || this.tranche ==null){
            this.tranche = cancomDeal['tranche'];
        }
        if(this.cancelReason != 'None' && this.cancelReason != undefined){
        let shtObjRec = {};
        shtObjRec.mrcId = this.template.querySelector('[data-id="mrcNo"]').value;
        shtObjRec.accId = this.template.querySelector('[data-id="customer"]').value;
        shtObjRec.shipToNumber = this.template.querySelector('[data-id="shipToNumber"]').value;
        shtObjRec.poType = this.template.querySelector('[data-id="poType"]').value;
        shtObjRec.location = this.plantId;
        //shtObjRec.location = this.template.querySelector('[data-id="location"]').value;
        shtObjRec.grade = this.template.querySelector('[data-id="product"]').value;
        shtObjRec.materialNo = this.template.querySelector('[data-id="materialNo"]').value;
        //added by swarna Bug-1264522
        shtObjRec.contractStartDate = this.template.querySelector('[data-id="contractStartDate"]').value;
        shtObjRec.tranche = this.tranche;
        shtObjRec.atpVoltoBeReduced = true;
        let todaysDate = new Date();
        this.validateEndDate(this.template.querySelector('[data-id="contractStartDate"]').value, shtObjRec.poType);
        shtObjRec.contractEndDate = (shtObjRec.contractStartDate < todaysDate.toISOString().substring(0,10)) ? this.template.querySelector('[data-id="contractEndDate"]').value : this.CN_endDateVal;//this.addDaysToDate(shtObjRec.contractStartDate, 14);
        //end Bug-1264522
        shtObjRec.volumeCBM = this.template.querySelector('[data-id="volCbm"]').value;
        shtObjRec.Comment = this.template.querySelector('[data-id="Comment"]').value;
        shtObjRec.Comment = shtObjRec.Comment+'- cancelled deal '+this.cancel_shtNo;
        shtObjRec.locationId =  this.plantId;
        //shtObjRec.locationId = this.template.querySelector('[data-id="location"]').value;
        shtObjRec.spPer100L = this.template.querySelector('[data-id="spPer100L"]').value == "" ? 0 : this.template.querySelector('[data-id="spPer100L"]').value;
        shtObjRec.targetMargin = this.template.querySelector('[data-id="targetMargin"]').value;
        shtObjRec.msp=this.template.querySelector('[data-id="msp"]').value;
        shtObjRec.cancellationReason = this.cancelReason;
        console.log('shtObjRec::'+JSON.stringify(shtObjRec));
        if(shtObjRec.poType == "" || shtObjRec.locationId == "" || shtObjRec.grade == "" || shtObjRec.contractStartDate == "" || shtObjRec.contractEndDate == "" || shtObjRec.volumeCBM == "" || ((shtObjRec.spPer100L == "" || shtObjRec.spPer100L == "0" || shtObjRec.spPer100L == "0.00") &&  shtObjRec.poType == "TSFP")
            || shtObjRec.poType == undefined || shtObjRec.locationId == undefined || shtObjRec.grade == undefined || shtObjRec.contractStartDate == undefined || shtObjRec.contractEndDate == undefined || shtObjRec.volumeCBM == undefined || shtObjRec.spPer100L == undefined ){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please fill all the inputs to create new deal.',
                        variant: 'error',
                    }),
                );
            }
            else{
                if(this.cancelReason != 'None'){
                      this.createSHT(shtObjRec);
                  }else{
                      this.dispatchEvent(
                          new ShowToastEvent({
                              title: 'Error',
                              message: 'Please select cancellation reason and confirm.',
                              variant: 'error',
                          }),
                      );
                  }
              }
          }else{
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'Please select cancellation reason before confirming the new deal.',
                      variant: 'error',
                  }),
              );
          }
      }

    createSHT(shtobj){
        console.log('In method entry::'+JSON.stringify(shtobj));
    createSHTObjectRecord({
        dataList : JSON.stringify(shtobj)
    })
    .then(result => {
        console.log('created deal::'+JSON.stringify(result));
        //[{"Id":"a0V25000003gOreEAE","Name":"SHT - 209174"}]
        if(result != null){
            this.create_newDeal = false;
            for(var i in result){
                console.log('result[i].Name::'+result[i].Name);
                this.newDeal = result[i].Name;
                this.cancelButton = true;
                this.cancelReason = shtobj.cancellationReason;
            }
            this.cancelSHTDeal();
           // this.onLoad();
        }
    })
    .catch(error => {
        this.error = error;
    });
}
    cancelSHTDeal(){
        console.log('cancelButton::'+this.cancelButton+'--'+this.cancelReason);
        console.log('cancelDeal::'+JSON.stringify(this.cancel_compDealRec));

        let cancelDealJson1 ;
        for(var key in this.cancel_compDealRec){
            this.cancelDealJson1 = this.cancel_compDealRec[key];
            if(this.newDeal != '' && this.newDeal != undefined){
                this.cancel_compDealRec.Comment = 'by '+this.newDeal;
            }

            var resn ;
            var executeCancelFunc = false;
            console.log('New Deal::'+this.newDeal);
            if(this.cancelButton == false){
                resn = this.cancelReasonVal;
                 //resn = this.cancel_compDealRec[key].cancellationReason+'-'+this.newDeal;
            }else if(this.cancelButton == true){
                    resn = this.cancelReason == undefined ? this.cancel_compDealRec[key].cancellationReason+'-'+this.newDeal : this.cancelReason+'-'+this.newDeal;
            }
            if(resn != undefined && resn != 'None' && resn != ""){
                executeCancelFunc = true;
            }
            console.log('resn::'+resn);
                if(executeCancelFunc){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            type:'Warning',
                            message: 'This contract could already contain booked liftings in GSAP. Please consider checking the open contract volume in GSAP before cancelling this deal.',
                            variant: 'Warning',
                        }),
                    );
                    cancelSHTDealRecord({

                        shtId : this.cancel_compDealRec[key].shtRecordId,
                        status : this.cancel_compDealRec[key].dealStatus,//this.advStatus,
                        reason : resn,
                        searchList : JSON.stringify(this.cancel_compDealRec)

                    }).then(result =>{
                        console.log('Cancel function::'+JSON.stringify(result));
                        this.refreshTermTriggerDeals();
                        this.cancelReason = 'None';
                        this.cancelReasonVal= 'None';
                        this.haveCancelReason = true;
                        //prod deployment
                        this.selectedReasonValue = 'None';
                        this.onLoad();
                    })
                    .catch(error => {
                        this.error = error;
                    });
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please select cancellation reason',
                            variant: 'error',
                        }),
                    );
                }
            }
    }
           refreshTermTriggerDeals(event){
            let paramData = {eventType:'canceledSuccess'};
            let refreshParent = new CustomEvent('refreshtermtriggercmp',
                                     {detail : paramData}
                                    );
                this.dispatchEvent(refreshParent);

    }

    resendDealtoGsap(event){
        let retryDeal = [];
        /*for(var key in this.completedMasterTriggerSHTData){
            if(this.completedMasterTriggerSHTData[key].gsapError != undefined &&
                    this.completedMasterTriggerSHTData[key].gsapError != null){
                        retryDeal.push(this.completedMasterTriggerSHTData[key].shtRecordId);
            }
        }*/
        //added by swarna as part of PBI-1659185
        if(event.currentTarget.dataset.id != null && event.currentTarget.dataset.id != undefined){
            retryDeal.push(event.currentTarget.dataset.id);
        }
        retryDealinGSAP({
            shtIds :retryDeal
        }).then(GSAPResult =>{
            console.log('GSAPResult::'+JSON.stringify(GSAPResult));
            //added by swarna as part of PBI-1659185
            this.dispatchEvent(
                new ShowToastEvent({
                title: 'Success',
                message:JSON.stringify(GSAPResult),
                variant: 'success',
                    }),
                );
                retryDeal = [];
                //end
        }).catch(error =>{
            console.log('Error in GSAP::'+JSON.stringify(error));
            this.error = error;
        })
    }
}