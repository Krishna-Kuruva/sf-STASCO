import {LightningElement, track, wire} from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {publish, MessageContext,subscribe,APPLICATION_SCOPE} from 'lightning/messageService';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import searchFilterChannel from '@salesforce/messageChannel/Rv_DiPublishSearchFilter__c';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import getFilterData from '@salesforce/apex/RV_DiSearchController.searchRelatedMRCs';
import searchMrcHeaders from '@salesforce/apex/RV_DiSearchController.searchMrcHeader';
import saveFilterData from '@salesforce/apex/RV_DiSearchController.saveCustomerFilter';
import getNegotiationData from '@salesforce/apex/RV_DiSearchController.getNegotiationsData';
import getNegotiationCustMrcData from '@salesforce/apex/RV_DiSearchController.getNegotiationsCustMrcData';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';
import checkMRCValue from '@salesforce/apex/rv_sht_CreateControllerLWC.checkMRC';
import SaveFilterDataErrorLabel from '@salesforce/label/c.RV_ErrorMessagesSaveFilterData';
import ApexClassErrorLabel from '@salesforce/label/c.RV_ErrorMessagesApexClassAccess';


export default class Rv_diCustomerFilterSection extends LightningElement {

    //Customer search var---
    customerRecId = '';
    customerFilter = 'Has_MRC__c = true AND (Rv_AT01_Deletion_Flag__c = false OR Rv_DE01_Deletion_Flag__c = false)';
    //MRC search  variables =====
    mrcSearchStr = '';
    mrcHeader = '';
    mrcSearchOpts;
    mrcDropDown = false; //SK
    //Sold-To search variables
    soldToFilter = 'Has_MRC__c = true AND (Rv_AT01_Deletion_Flag__c = false OR Rv_DE01_Deletion_Flag__c = false)';
    //MRC drop down variables
    mrcOptions;
    mrcVal = [];//'';
    //Ship To dropdown variables
    shipToNumOptions;
    shipToNumVal;

    //MOT dropdown variables
    motOptions;
    motVal = [];
    motArr = [];
    plantNameVsId;
    //MOT variables
    energyTaxVal = 'Taxed';
    //OLF MRC Only
    olfOnly =false;
    //Product dropdown variables
    productOptions;
    productVal =[];
    //Retail-Mix
    retailMix = false;
	ago = true;
    igo = true;
    mogas = true;
    //PO Type dropdown variables
    poTypeOptions;
    poTypeVal = '';
    //Depot dropdown variables
    depotOptions;
    shipToOptions;
    depotVal;
    mrcSelectedVal='';
    shipToSelectedVal='';
    //Sales org dropdown variables
    salesOrgOptions;
    salesOrgVal = [];
    //contract date values //SK
    startDateVal;
    endDateVal;
    negotiationRecord = false;
    depotValueCheck;
    mrcValueCheck;
    olfMrcOnlyVal;
    retailSelectedMix;
	depotSelectedVal='';
	igoSelected = true;
    agoSelected = true;
    mogasSelected = true;
       //SK
    //Filter toggle
    showCustomerSearch = true;
    showMrcSearch = true;
    //showSoldToSearch = true;//SK
    poTypeRow2 = false;
    //Search result from customer/MRC filter.
    searchResult;
    tranche1EndDate;
    trancheVal;
	tranche;
    energyTax;
    //contract duration variable
    contractDuration;
	durationError = false;
	searchBtn = false;

    endDateDisabled = false;
	customerName;




    //Energy Tax Option
    /*get energyTaxOptions(){
        return [
            {label: 'Taxed', value: 'Taxed'},
            {label: 'Untaxed', value: 'Untaxed'},
        ];
    }*/

    //Lifting Window Options
    get trancheOptions(){
        return [
            {label: 'Prompt', value: 'Prompt'},
            {label: 'Flex1', value: 'Flex1'},
            {label: 'Flex2', value: 'Flex2'},
        ];
    }

    connectedCallback(){
        this.energyTax = true;
        this.negotiationRecord = false;
        this.startDateVal = new Date().toISOString().slice(0, 10);
        this.endDateVal =this.addDaysToDate(this.startDateVal, 14);
        this.contractDuration = this.calculateDaysDiff(this.endDateVal,this.startDateVal) + 1;
        this.trancheVal = 'Prompt';
		this.tranche = 'ATP1';
        //added by swarna
        this.subscribeToMessageChannel();
    }

    /*added by swarna */
    subscribeToMessageChannel(){
        if(!this.subscription && this.messageContext != null){
             this.subscription = subscribe(
                 this.messageContext,
                 searchFilterChannel,
                 (message) => this.publishCustomerDeSelectMessage1(message),
                 {
                     scope: APPLICATION_SCOPE
                 }
             );
         }
     }

     publishCustomerDeSelectMessage1(message){
         console.log('****',message);
         if(message.eventType == 'deSelectedCustomer_clear' || message.eventType == 'deSelectedCustomer_clear_TT'){
             this.clearAllFilters();
             this.customerRecId= "";
             if(this.template.querySelector('c-rv_search-lookup') != null){
                 this.template.querySelector('c-rv_search-lookup').handleClose();
             }else{
                     this.inputMRCVal= '';
                     this.handleDeselectMrc();
                }
         }
     }
     //end

    addDaysToDate(date, days){
        var someDate = new Date(date);
        someDate.setDate(someDate.getDate() + parseInt(days));
        var dateFormated = someDate.toISOString().substring(0,10);
        console.log('line 120:'+dateFormated);
        return dateFormated;
    }
    calculateDaysDiff(endDate, startDate){
        //const diffTime = Math.abs(new Date(this.endDateVal) - new Date(this.startDateVal));
		if(startDate != null && startDate != undefined && endDate != null && endDate != undefined){
			const diffTime = Math.abs(new Date(endDate) - new Date(startDate));
			const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
			console.log(diffDays + " days");
			this.durationError = false;
            if(endDate >= startDate){
                this.searchBtn = false;
            }
            return diffDays;
		}
		else if(startDate == null && endDate == null ){
            this.durationError = true;
            this.searchBtn = true;
            return 'Contract End Date should be Greater than Contract Start Date and within M+15 from Today\'s Date';
        }
		 else if(startDate == null || startDate == undefined ){
            this.durationError = true;
            this.searchBtn = false;
            //Please enter date format as [DD.MM.YYYY] OR [DDMMYYYY] .
            return 'Please enter start date format as [DD/MM/YYYY]';
        }
        else if( endDate == null || endDate == undefined){
            this.durationError = true;
            this.searchBtn = false;
            //Please enter date format as [DD.MM.YYYY] OR [DDMMYYYY] .
            return 'Please enter end date format as [DD/MM/YYYY]';
        }

	}
    calculateDays(){
        console.log('In Calculate Days:'+this.startDateVal+'<--->'+this.tranche1EndDate+'**'+new Date());
        let todaysDate = new Date();
        if(this.startDateVal < todaysDate.toISOString().substring(0,10)){
            this.endDateVal = todaysDate.toISOString().substring(0,10);
            this.trancheVal = 'Prompt';
			this.tranche = 'ATP1';
            this.tranche1EndDate = this.endDateVal;
        }
        if(this.startDateVal > this.tranche1EndDate){
            this.endDateVal = this.addDaysToDate(this.startDateVal,13);
            this.trancheVal = 'Flex1';
			this.tranche = 'ATP2';

        }
        console.log('In Calculate Days Flex2:'+new Date());
        var flex2date = this.addDaysToDate(new Date(),28);
        console.log('In Calculate Days Flex2:'+this.startDateVal+'<--->'+flex2date);
        var ddiff = this.calculateDaysDiff(this.endDateVal,new Date());
        console.log('ddiff:'+ddiff);
        if(parseInt(ddiff) > 30){
           this.endDateVal = this.addDaysToDate(this.startDateVal,15);
           this.trancheVal = 'Flex2';
			this.tranche = 'ATP3';
        }
        this.dateDifferenceInDays();
    }

    @wire(MessageContext)
    messageContext;

    @wire(getObjectInfo, {objectApiName: ACCOUNT_OBJECT})
    objectInfo({data, error}){
        if(data){
            const rtis = data.recordTypeInfos;
            const recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Revolution');
            if(recordTypeId){
                this.customerFilter += 'AND RecordTypeId = \'' + recordTypeId + '\'';
                this.soldToFilter += 'AND RecordTypeId = \'' + recordTypeId + '\'';
            }
        }
        else if(error){
            console.error('Error: ' + JSON.stringify(error));
            if (error.body.message.includes('You do not have access to the Apex class named')) {
                this.showToast('Error',ApexClassErrorLabel, 'error');
            } else {
                this.showToast('Error', error.body.message, 'error');
            }
        }
    }

    //Get filter data based on Account Name for MRC Name search string.
    @wire(getFilterData, {acctId: '$customerRecId', mrcHeadStr: '$mrcHeader'})
    setFilterData(result){


        this.searchResult = result;
        const {data, error} = result;
        if(data){
            console.log('Data: '+this.customerRecId+'--'+JSON.stringify(data));

			if(data != null && data.mrcNoList != null && data.mrcNoList.length > 0){
                this.validMRC_Check = true;
                  this.getNegotinCustMrcData();

             }else{
                this.validMRC_Check = false;

            }
            if(this.customerRecId){
                this.setPrimaryFilters(data);
                this.setSecondaryFilter(data);
            }
            if(this.mrcHeader){
                this.setSecondaryFilter(data);
                this.setDatesOnLoad();
            }
            if(this.customerRecId == '' && data.size == 0){
                this.energyTax = true;
                this.negotiationRecord = true;
               // alert('no data'+data.size);
            }
        }
        else if(error){
            console.error('Error: '+JSON.stringify(error));
            if (error.body.message.includes('You do not have access to the Apex class named')) {
                this.showToast('Error',ApexClassErrorLabel, 'error');
            } else {
                this.showToast('Error', error.body.message, 'error');
            }
        }
    }

  /*  //Get list of MRC headers based on MRC search input.
    @wire(searchMrcHeaders, {mrcHeadStr: '$mrcSearchStr'})
    setMrcFilter({data, error}){
        if(data){
            console.log('mrcList:'+JSON.stringify(data));
            this.mrcSearchOpts = data;
            //SK
            if(data != undefined && data != null && data.length > 0 )
            this.mrcDropDown = true;
            //SK
        }
        else if(error){
            this.mrcDropDown = false;//SK
            console.error('Error: '+ JSON.stringify(error));
        }
    }*/

	@track inputMRCVal;
    Key_event (component, event, helper) {
        //alert(component.which);
        if (component.which == 13) {
            //alert ('Perform some action ');
            this.validateMRCNumberInput();
            this.handleSelectMrc(event);
            this.searchOffers('fromEnter');

       }
   }

   checkmrcnumber(event){
       //alert(event.detail.value);
       this.inputMRCVal = event.detail.value;
		if(this.mrcOld != this.inputMRCVal){
        console.log('clearing all filters:');
        this.mrcOld = this.inputMRCVal;
        this.clearAllFilters();
       }
       if(this.inputMRCVal != '' && !(this.inputMRCVal).startsWith("0", 0)){
            this.inputMRCVal = '0'+this.inputMRCVal;

       }else if((this.inputMRCVal).length == 0){
            this.handleDeselectMrc();
       }

       //alert('this.inputMRCVal::'+(this.inputMRCVal).length);
       if((this.inputMRCVal).length > 0){
            this.handleSelectMrc(event);
       }








   }

   validateMRCNumberInput(){
      // alert('validateMRCNumberInput::'+this.inputMRCVal+(this.inputMRCVal).length);
       if((this.inputMRCVal).length < 9){
           this.showToast('Error','MRC length is not sufficient','error');
			this.clearAllFilters();
       }else{
           this.mrcVal = this.inputMRCVal;
            //this.checkMRCVal();
		if(!this.validMRC_Check){
				this.clearAllFilters();
                this.showToast('Error', 'MRC Record does not exist for the search criteria.', 'error');
            }
       }
   }

   checkMRCVal(){
    checkMRCValue({
        mrcInput: this.inputMRCVal
        })
        .then(result => {
            console.log('result::'+result);

        })
        .catch(error => {
            console.error('Error: '+ JSON.stringify(error));
            this.showToast('Error', 'MRC Record does not exist for the search criteria.', 'error');
        });
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

    publishSearchFilter(filterObj){

        const payload = {
                        eventType: 'search',
                        filterData: filterObj};
        publish(
            this.messageContext,
            searchFilterChannel,
            payload
        );
    }

    handleArrowPress(event){
        if(event.target.value != null){
            this.template.querySelector('rv_search-lookup').handleKeyPress(event.target.value);
        }
    }

    handleLookup(event){
        this.energyTax = false;
        let selectedRec = event.detail.data;
        console.log('****lookup method hit');
        var stCmp = this.template.querySelector(".stDate");
        stCmp.setCustomValidity("") ;
        stCmp.reportValidity();

        var endDateCmp = this.template.querySelector(".edDate");
        endDateCmp.setCustomValidity("") ;
        endDateCmp.reportValidity();

        if(selectedRec){
            if(selectedRec.currentRecordId == 'Account'){
                if(selectedRec.record){

                    console.log('AccountRecordId:'+selectedRec.record.Id);
                    this.customerRecId = selectedRec.record.Id;
					this.customerName = selectedRec.record.Name;
                    this.showMrcSearch = false;
                    this.endDateVal =this.addDaysToDate(this.startDateVal, 14);

                    this.getNegotinCustMrcData();
					//this.getNegotiationDetails();
     //this.showSoldToSearch = false;//SK

                    this.publishCustomerId();
                }
                else{
                    this.showMrcSearch = true;
                    this.endDateVal =this.addDaysToDate(this.startDateVal, 14);
                    this.customerRecId = '';
                    this.clearAllFilters();
                    this.publishCustomerDeSelectMessage();

                }
            }
        }
    }

    publishCustomerDeSelectMessage(){
        const payload = {
                        eventType: 'deSelectedCustomer',
                        customerId: this.customerRecId,
                        mrcId: this.mrcHeader
        };

        publish(
            this.messageContext,
            searchFilterChannel,
            payload
        );
        this.endDateVal =this.addDaysToDate(this.startDateVal, 14);
        this.contractDuration = this.calculateDaysDiff(this.endDateVal,this.startDateVal) + 1;
    }

    //Handle input change on MRC search bar.
    handleMrcInput(event){
        let searchStr = event.target.value;
        this.mrcSearchStr = searchStr;

    }

    //Handle MRC select event.
    handleSelectMrc(event){
        console.log('@292');


        let mrcNo = this.inputMRCVal;
        console.log('MRC Select: '+mrcNo);
        this.showCustomerSearch = false;
       // this.showSoldToSearch = false;//SK
        this.mrcSearchOpts = undefined;
        this.mrcHeader = mrcNo;
        this.poTypeRow2 = true;
        //this.depotSelectedVal=[];
        this.energyTax = false;//SK
       // this.showMrcSearch = false;
        console.log('MRC header: '+this.mrcHeader);
		this.publishCustomerId();
         var stCmp = this.template.querySelector(".stDate");
        stCmp.setCustomValidity("") ;
        stCmp.reportValidity();

        var endDateCmp = this.template.querySelector(".edDate");
        endDateCmp.setCustomValidity("") ;
        endDateCmp.reportValidity();
    }

    handleDeselectMrc(){

        this.showCustomerSearch = true;
       // this.showSoldToSearch = true;//SK
        this.poTypeRow2 = false;
        this.mrcHeader = '';
        this.energyTax = true;
        this.clearAllFilters();
        // prod deployment
        this.publishCustomerDeSelectMessage();
        this.endDateVal =this.addDaysToDate(this.startDateVal, 14);
        this.contractDuration = this.calculateDaysDiff(this.endDateVal,this.startDateVal) + 1;

    }

    handleValueChange(event){
        console.log('***from multi select dropdown::'+JSON.stringify(event.detail));
        let mrcarray = [];
        if(event.detail != undefined ){
                for(let i in event.detail){
                    if(event.detail[i]!=null){
                    mrcarray.push(event.detail[i]);
                }
            }
            }
            console.log('MRC Array'+mrcarray);
            this.mrcVal = mrcarray;

    }
    handleshipToValueChange(event){
        console.log('***from multi select shipTo dropdown::'+JSON.stringify(event.detail));
        let shipToarray = [];
        if(event.detail != undefined ){
                for(let i in event.detail){
                    shipToarray.push(event.detail[i]);
                }
            }
            this.shipToNumVal = shipToarray;
        this.shipToSelectedVal = this.shipToNumVal;
    }
    handleDepotValueChange(event){
        console.log('***from multi select depot dropdown::'+JSON.stringify(event.detail));
        let depotarray = [];
        if(event.detail != undefined ){
                for(let i in event.detail){
                    if(event.detail[i]!=null){
                    depotarray.push(event.detail[i]);
                }
            }
            }
            console.log('Depot array'+depotarray.toString());
            this.depotVal = depotarray;
			this.depotSelectedVal = this.depotVal;

    }

    //Handle input change in filter fields
    handleChange(event){
        if(event.target.name == 'mrcFilter'){
            this.mrcVal = event.target.value;
        }
        if(event.target.name == 'shipToFilter')
            this.shipToNumVal = event.target.value;
        if(event.target.name == 'poTypeFilter'){
            this.poTypeVal = event.target.value;
            this.setTrancheWithPoType();
            console.log('this.poTypeVal in handlechange::'+this.poTypeVal);
			//set end date based on PO Type
        //ASHISH: PBI: 1375726 START =>
        if(this.poTypeVal == 'TSFP'){
            let diff;
            let todaysDate = new Date();
            if(this.startDateVal != null && this.startDateVal > todaysDate.toISOString().substring(0,10)){
                this.endDateVal = this.addDaysToDate(this.startDateVal, 13);
            }
            else if(this.startDateVal != null && this.startDateVal == todaysDate.toISOString().substring(0,10)){
                this.endDateVal = this.addDaysToDate(this.startDateVal, 14);
            }
            else if(this.startDateVal != null && this.startDateVal < todaysDate.toISOString().substring(0,10)){
                this.endDateVal = todaysDate.toISOString().substring(0,10);
            }
            diff = this.calculateDaysDiff(this.endDateVal,this.startDateVal);

            if(diff<=14){
                this.trancheVal = 'Prompt';
                this.tranche = 'ATP1';
            }else if(diff>14 && diff <=28){
                this.trancheVal = 'Flex1';
                this.tranche = 'ATP2';
            }else if(diff>28){
                this.trancheVal = 'Flex2';
                this.tranche = 'ATP3';
            }
            this.contractDuration = this.calculateDaysDiff(this.endDateVal,this.startDateVal) !='Please enter start date format as [DD/MM/YYYY]' ? this.calculateDaysDiff(this.endDateVal,this.startDateVal) +1:this.calculateDaysDiff(this.endDateVal,this.startDateVal);
        }

        if(this.poTypeVal == 'TTTT' || this.poTypeVal == 'TTTI'){
            let diff;
            let date1 = new Date(this.startDateVal);
            let lastDay = new Date(date1.getFullYear(), date1.getMonth() + 1, 0);
            lastDay.setDate(lastDay.getDate() + 1);

            let currentMonth = parseInt((date1.getMonth()+1));
            let endDate = this.addDaysToDate(this.startDateVal, 14);

            let endDateMonth = parseInt(endDate.substring(5, 7));

            let todaysDate = new Date();
            if(endDateMonth>currentMonth && this.startDateVal >= todaysDate.toISOString().substring(0,10)){
                this.endDateVal = lastDay.toISOString().substring(0,10);
            }else{
                if(this.startDateVal != null && this.startDateVal < todaysDate.toISOString().substring(0,10)){
                    this.endDateVal = todaysDate.toISOString().substring(0,10);
                }
                else if(this.startDateVal > todaysDate.toISOString().substring(0,10)){
                    this.endDateVal = this.addDaysToDate(this.startDateVal, 13);
                }
                else if(this.startDateVal == todaysDate.toISOString().substring(0,10)){
                    this.endDateVal = this.addDaysToDate(this.startDateVal, 14);
                }
                else if(this.startDateVal != null){
                    this.endDateVal = endDate;
                }
            }
            diff = this.calculateDaysDiff(this.endDateVal,this.startDateVal);
            if(diff<=14){
                this.trancheVal = 'Prompt';
                this.tranche = 'ATP1';
            }else if(diff>14 && diff <=28){
                this.trancheVal = 'Flex1';
                this.tranche = 'ATP2';
            }else if(diff>28){
                this.trancheVal = 'Flex2';
                this.tranche = 'ATP3';
            }
            this.contractDuration = this.calculateDaysDiff(this.endDateVal,this.startDateVal) !='Please enter start date format as [DD/MM/YYYY]' ? this.calculateDaysDiff(this.endDateVal,this.startDateVal) +1:this.calculateDaysDiff(this.endDateVal,this.startDateVal);
        }
        //PBI: 1375726 END
        }


        if(event.target.name == 'depotFilter')
            this.depotVal = event.target.value;
            console.log('this.depotVal in handlechange:::'+ this.depotVal);
        if(event.target.name == 'salesOrgFilter')
            this.salesOrgVal = event.target.value;
            console.log('this.salesOrgVal in handlechange:::'+ this.salesOrgVal);
        if(event.target.name == 'motFilter'){
            let mot = event.target.value;
            this.motVal = mot;
            console.log('this.motVal = mot in handlechange:::'+ this.motVal);
            let motArr = [];
            if(mot != undefined && mot.length > 0){
                for(let i = 0; i < mot.length; i++){
                    motArr.push(mot[i].split('-')[1]);
                }
            }
            this.motArr = motArr;
            console.log('this.motarr in handlechange:::'+ this.motArr);
            //this.motVal = this.motArr;
        }
        if(event.target.name == 'productFilter')
           this.productVal = event.target.value;
		if (event.target.name == 'ago') {
            console.log('AGO:: '+event.target.label + '---' + event.detail.label);
            this.ago = event.target.checked;
            if (this.ago && !(this.productVal).includes('AGO')) {
                this.productVal = this.productVal + ',' + event.target.label;
            } else {
                this.productVal = '';
            }
        }
        if (event.target.name == 'igo') {
             console.log('IGO:: '+event.target.label + '---' + event.detail.label);
            this.igo = event.target.checked;
            if (this.igo && !(this.productVal).includes('IGO')) {
                this.productVal = this.productVal + ',' + event.target.label;
            } else {
                this.productVal = '';
            }
        }
        if (event.target.name == 'mogas') {
            console.log('MOGAS:: '+event.target.label + '---' + event.detail.label);
            this.mogas = event.target.checked;
            if (this.mogas && !(this.productVal).includes('MOGAS')) {
                this.productVal = this.productVal + ',' + event.target.label;
            } else {
                this.productVal = '';
            }
        }
        if(event.target.name == 'retailMix')
            this.retailMix = event.target.checked;
        if(event.target.name == 'energyTaxFilter')
            this.energyTaxVal = event.target.value;
        if(event.target.name == 'olfMrcOnly')  {
            this.olfOnly = event.target.checked;
            console.log('olfOnly'+this.olfOnly);
        }
    //SK
        if(event.target.name == 'startDate')  {
            //alert(this.startDateVal);// = event.target.value;
            let startDate = event.target.value;

			//Added for 1304836
			if(startDate < new Date().toISOString().slice(0, 10)){
                 this.endDateVal = new Date().toISOString().slice(0, 10);
            }


			let endDateMonth;
            let diff;
            let date1 = new Date(startDate);
            let lastDay = new Date(date1.getFullYear(), date1.getMonth() + 1, 0);
            lastDay.setDate(lastDay.getDate() + 1);

            if(this.poTypeVal == 'TSFP' || this.poTypeVal == ''){
                this.startDateVal = event.target.value;
                //added by swarna BUG-1264522
                let todaysDate = new Date();
                if(this.startDateVal != null && this.startDateVal < todaysDate.toISOString().substring(0,10)){
                    this.endDateVal = todaysDate.toISOString().substring(0,10);
                }else if(this.startDateVal > todaysDate.toISOString().substring(0,10)){
                    this.endDateVal = this.addDaysToDate(this.startDateVal, 13);
                }
                else if(this.startDateVal == todaysDate.toISOString().substring(0,10)){
                    this.endDateVal = this.addDaysToDate(this.startDateVal, 14);
                }
                else if(this.startDateVal != null){
                   // this.endDateVal = this.addDaysToDate(startDate, 13);
                   //changing date diff to 14 as per US1304836
                   this.endDateVal = this.addDaysToDate(startDate, 13);
                }
                //end BUG-1264522
                //end BUG-1264522
                diff = this.calculateDaysDiff(this.endDateVal,startDate);

                if(diff<=14){
                    this.trancheVal = 'Prompt';
					this.tranche = 'ATP1';
                }else if(diff>14 && diff <=28){
                    this.trancheVal = 'Flex1';
					this.tranche = 'ATP2';
                }else if(diff>28){
                    this.trancheVal = 'Flex2';
					this.tranche = 'ATP3';
                }
                this.contractDuration = this.calculateDaysDiff(this.endDateVal,startDate) !='Please enter start date format as [DD/MM/YYYY]' ? this.calculateDaysDiff(this.endDateVal,startDate) +1:this.calculateDaysDiff(this.endDateVal,startDate);
            } else if(this.poTypeVal == 'TTTT' || this.poTypeVal == 'TTTI') {
                this.startDateVal = event.target.value;
                let currentMonth = parseInt((date1.getMonth()+1));
                let endDate = this.addDaysToDate(startDate, 14);

                let endDateMonth = parseInt(endDate.substring(5, 7));
                //added by swarna BUG-1264522
                let todaysDate = new Date();
                if(endDateMonth>currentMonth && this.startDateVal >= todaysDate.toISOString().substring(0,10)){
                    this.endDateVal = lastDay.toISOString().substring(0,10);
                }else{
                    if(this.startDateVal != null && this.startDateVal < todaysDate.toISOString().substring(0,10)){
                        this.endDateVal = todaysDate.toISOString().substring(0,10);
                    }else if(this.startDateVal > todaysDate.toISOString().substring(0,10)){
                        this.endDateVal = this.addDaysToDate(this.startDateVal, 13);
                    }
                    else if(this.startDateVal == todaysDate.toISOString().substring(0,10)){
                        this.endDateVal = this.addDaysToDate(this.startDateVal, 14);
                    }
                    else if(this.startDateVal != null){
                        this.endDateVal = endDate;
                    }
                }
                //end BUG-1264522
                diff = this.calculateDaysDiff(this.endDateVal,startDate);

                 if(diff<=14){
                    this.trancheVal = 'Prompt';
					this.tranche = 'ATP1';
                }else if(diff>14 && diff <=28){
                    this.trancheVal = 'Flex1';
					this.tranche = 'ATP2';
                }else if(diff>28){
                    this.trancheVal = 'Flex2';
					this.tranche = 'ATP3';
                }
                this.contractDuration = this.calculateDaysDiff(this.endDateVal,startDate) !='Please enter start date format as [DD/MM/YYYY]' ? this.calculateDaysDiff(this.endDateVal,startDate) +1:this.calculateDaysDiff(this.endDateVal,startDate);
            }
        }
        if(event.target.name == 'endDate'){

            let startDate = this.startDateVal;
            let endDate = event.target.value;
            let diff;
            this.endDateVal = event.target.value;
            if(endDate < startDate){
                this.searchBtn = true;
				this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Contract End Date should be Greater than Contract Start Date and within M+15 from Today\'s Date',
                        variant: 'error',
                    }),
                );

               // alert('Contract End Date should be Greater than Contract Start Date and within M+15 from Today\'s Date');


            }
            let date1 = new Date(startDate);
            let lastDay = new Date(date1.getFullYear(), date1.getMonth() + 1, 0);
            lastDay.setDate(lastDay.getDate() + 1);
            if(this.poTypeVal == 'TSFP' || this.poTypeVal == ''){
                diff = this.calculateDaysDiff(endDate,startDate);
                if(diff<=14){
                    this.trancheVal = 'Prompt';
					this.tranche = 'ATP1';
                }else if(diff>14 && diff <=28){
                    this.trancheVal = 'Flex1';
					this.tranche = 'ATP2';
                }else if(diff>28){
                    this.trancheVal = 'Flex2';
					this.tranche = 'ATP3';
                }
                this.contractDuration =  this.calculateDaysDiff(this.endDateVal,startDate) !='Please enter end date format as [DD/MM/YYYY]' ? this.calculateDaysDiff(this.endDateVal,startDate) +1:this.calculateDaysDiff(this.endDateVal,startDate);
           } else if(this.poTypeVal == 'TTTT' || this.poTypeVal == 'TTTI') {
                let currentMonth = parseInt((date1.getMonth()+1));
                let endDateMonth = endDate != null ? parseInt(endDate.substring(5, 7)) : endDate;
                //let endDateMonth = parseInt(endDate.substring(5, 7));
                if(endDateMonth>currentMonth){
                    this.endDateVal = lastDay.toISOString().substring(0,10);
                }else{
                    this.endDateVal = endDate;
                }
                diff = this.calculateDaysDiff(this.endDateVal,startDate);

              if(diff<=14){
                    this.trancheVal = 'Prompt';
					this.tranche = 'ATP1';
                }else if(diff>14 && diff <=28){
                    this.trancheVal = 'Flex1';
					this.tranche = 'ATP2';
                }else if(diff>28){
                    this.trancheVal = 'Flex2';
					this.tranche = 'ATP3';
                }
                this.contractDuration =  this.calculateDaysDiff(this.endDateVal,startDate) !='Please enter end date format as [DD/MM/YYYY]' ? this.calculateDaysDiff(this.endDateVal,startDate) +1:this.calculateDaysDiff(this.endDateVal,startDate);
            }
        }

    //SK
    console.log('startdate::'+this.startDateVal+'-'+this.endDateVal+'-'+this.retailMix+'-'+this.productVal+'--'+this.motVal);


    }


    setTrancheWithPoType(){
        //alert(this.poTypeVal);
        if(this.poTypeVal == 'TTTT' || this.poTypeVal == 'TTTI'){
            this.dateDifferenceInDays();
        }
    }


    //Primary filters are MRC and Ship To dropdown list
    setPrimaryFilters(data){
        this.mrcOptions = data.mrcNoList.map(key => ({ label: key, value: key }));
        this.shipToNumOptions = data.shipToList.map(key =>({ label: key, value: key }));
    }

    setSecondaryFilter(data){

        //this.productOptions = data.productList.map(key => ({ label: key, value: key }));
        let products = ['IGO','AGO','MOGAS'];
        let productsList = [];
        for(let ProductKey in products){
            for(let ProductListKey in data.productList){
                if(products[ProductKey]==data.productList[ProductListKey]){
                    productsList.push(products[ProductKey]);
                }
            }
        }
        console.log('this.productsList:'+JSON.stringify(this.productsList));
        this.productOptions = productsList.map(key => ({ label: key, value: key }));

        this.processMotFilter(data.motList);
        console.log('motlist in secondary filter:::'+ data.motList);
        this.processPoTypeFilter(JSON.parse(JSON.stringify(data.poTypeList)));
        //this.depotOptions = data.plantIdVsNameMap.map(item => ({console.log('Map: '+item)}));
        this.plantNameVsId=JSON.parse(JSON.stringify(data.plantIdVsNameMap));
        this.processDepotFilter(JSON.parse(JSON.stringify(data.plantIdVsNameMap)));
        this.processShipToFilter(JSON.parse(JSON.stringify(data.shipToIdVsNumberMap)));
        this.salesOrgOptions = data.salesOrgList.map(key => ({ label: key, value: key }));

        if(!this.negotiationRecord){
            this.productVal = data.productList;
           // this.salesOrgVal = data.salesOrgList;
           // this.motVal = data.motList;
            }
    }

    processMotFilter(motList){
        this.motOptions = motList.map(key => ({ label: key, value: key }));
        //this.motVal = motList;
        let motArr = [];
        if(motList != undefined && motList.length > 0){
            for(let i = 0; i < motList.length; i++){
                motArr.push(motList[i].split('-')[1]);
            }
        }
        this.motArr = motArr;
            }

    processPoTypeFilter(poTypeList){
        if(poTypeList && poTypeList.length > 0){
            poTypeList.unshift(poTypeList.splice(poTypeList.findIndex(item => item === "TSFP"), 1)[0]);
            this.poTypeOptions = poTypeList.map(key => ({ label: key, value: key }));
            //if(poTypeList[0] === 'TSFP')
                this.poTypeVal = poTypeList[0];
        }
    }

    processDepotFilter(depotMap){
        let depotOptions = [];
        Object.keys(depotMap).map(function(key, index){
            const obj = new Object({ label: depotMap[key], value: key });
            depotOptions.push(obj);
        });
        this.depotOptions = depotOptions;
        console.log("depot options"+this.depotOptions);
    }
    processShipToFilter(shipToMap){
        let shipToOptions = [];
        Object.keys(shipToMap).map(function(key, index){
            const obj = new Object({ label: shipToMap[key], value: shipToMap[key] });
            shipToOptions.push(obj);
        });
        this.shipToOptions = shipToOptions;
        console.log("shipToOptions options"+this.shipToOptions);
    }

    clearAllFilters(){
        this.mrcOptions = '';
        this.mrcVal = '';
        this.mrcSelectedVal='';
        this.shipToSelectedVal='';
        this.depotSelectedVal='';
        this.shipToNumOptions = '';
        this.shipToNumVal = '';
        this.motOptions = '';
        this.motVal = '';
        this.productOptions = '';
        this.productVal ='';
        this.poTypeOptions = '';
        this.poTypeVal = '';
        this.depotOptions = '';
        this.shipToOptions = '';
        this.depotVal = '';
        this.salesOrgOptions = '';
        this.salesOrgVal = '';
        this.startDateVal = new Date().toISOString().slice(0, 10);
        this.endDateVal =this.addDaysToDate(this.startDateVal, 13);
        this.contractDuration = this.calculateDaysDiff(this.endDateVal,this.startDateVal) + 1;
        this.trancheVal = 'Prompt';
			this.tranche = 'ATP1';
            this.olfOnly = false;
            this.olfMrcOnlyVal = false;
			this.validMRC_Check = true;
            this.retailSelectedMix = false;
            this.retailMix = false;
        //this.startDateVal = '';
        //this.endDateVal = '';
    }
	searchOffers1(){
        this.searchOffers('onButtonclick');
    }
    searchOffers(fromWhere){

        if(this.template.querySelector('[data-id="motFilter"]') != null){
            let motSelectedVal = this.template.querySelector('[data-id="motFilter"]').value;
            let motArr1 = [];
            for(let key in motSelectedVal){
                motArr1.push(motSelectedVal[key].split('-')[1]);
            }
            this.motArr =  motArr1;
        }
        console.log('this.this.motArr:'+this.motArr);
        var searchObj = new Object;
		let prducts = ['IGO', 'AGO', 'MOGAS'];
        console.log('prducts::'+prducts);
        console.log('igo::'+this.igo+'-ago-'+this.ago+'--mogas--'+this.mogas);
        if(!this.igo){
            var item = 'IGO';
            var index = prducts.indexOf(item);
            prducts.splice(index, 1);
        }
        if(!this.ago){
            var item = 'AGO';
            var index = prducts.indexOf(item);
            prducts.splice(index, 1);
        }
        if(!this.mogas){
            var item = 'MOGAS';
            var index = prducts.indexOf(item);
            prducts.splice(index, 1);
        }
        console.log('prducts::'+prducts);
        this.productVal = prducts;
        console.log('productVal::'+this.productVal);

        searchObj.customerRecId = this.customerRecId != undefined ? this.customerRecId : '';//SK
		searchObj.customerName = this.customerName != undefined ? this.customerName : '';
        //searchObj.soldToId = this.customerRecId != undefined ? this.customerRecId : '';//SK
        console.log('Before 497');
        searchObj.mrcNo = this.mrcHeader != undefined ? this.mrcHeader != '' ? this.mrcHeader : this.mrcVal != undefined ? (this.mrcVal).toString(): '' : '';
        console.log('after 499');
        searchObj.shipToNum = this.shipToNumVal != undefined ? (this.shipToNumVal).toString() : '';
        searchObj.mot = this.motArr != undefined ? this.motArr : '';
        searchObj.olfOnly = this.olfOnly != undefined ? this.olfOnly : false;
        searchObj.salesOrg = this.salesOrgVal != undefined ? (this.salesOrgVal.toString()).replaceAll(',',';') : '';
        searchObj.product = this.productVal != undefined ? (this.productVal.toString()).replaceAll(',',';')  : '';
        searchObj.retailMix = this.retailMix != undefined ? this.retailMix : false;
        searchObj.energyTax = this.energyTaxVal != undefined ? this.energyTaxVal : '';
        searchObj.poType = this.poTypeVal != undefined ? this.poTypeVal : '';
        searchObj.depot = this.depotVal != undefined ? this.depotVal : '';
        //SK
        searchObj.startDate = this.startDateVal != undefined ? this.startDateVal : '';
        //const eddte = new Date(this.endDateVal);
        //console.log('End Date::'+eddte.format('YYYY-MM-DD'));
        searchObj.endDate = this.endDateVal != undefined ? this.endDateVal : '';
		searchObj.tranche = this.tranche;

        searchObj.showAvailableOffers = true; // added by Mohan
        console.log('searchobj in searchoffers:::'+ searchObj);
        var msg="";
        var filterError = false;



		if(!this.showCustomerSearch && fromWhere == 'onButtonclick' && (searchObj.mrcNo).length < 9){
            this.showToast('Error','MRC length is not sufficient','error');
        }
        else if(!this.showCustomerSearch && fromWhere == 'onButtonclick' && (searchObj.mrcNo).length >=  9){
            //alert('this.showCustomerSearch::'+this.showCustomerSearch);
            this.checkMRCVal();
        }
        if((searchObj.mrcNo == "" || searchObj.mrcNo == undefined) && (searchObj.customerRecId == "" || searchObj.customerRecId == undefined)){
            filterError = true;
            msg="Please select MRC Or Customer to search";
        }
        /*else if(searchObj.customerRecId != "" && (searchObj.shipToNum == "" || searchObj.shipToNum == undefined)){
            filterError = true;
            msg="Please select Ship To Number to search";
        }*/
        //else if(searchObj.mot == "" || searchObj.mot == undefined){
         //   filterError = true;
       //     msg="Please select MOT to search";
       /* else if(searchObj.salesOrg == ""){
            filterError = true;
            msg="Please select Sales Org to search";
        }else if(searchObj.product == ""){
            filterError = true;
            msg="Please select Product to search";
        }else if(searchObj.depot == "" || searchObj.depot == undefined){
            filterError = true;
            msg="Please select Depot to search";
        }*/
         if(searchObj.startDate == "" || searchObj.startDate == undefined){
            filterError = true;
            msg="Please select Contract Start Date to search";
			this.searchBtn = true;
        }
        else if(searchObj.endDate == "" || searchObj.endDate == undefined){
            filterError = true;
            msg="Please select Contract End Date to search";
			this.searchBtn = true;
		}else{
            this.searchBtn = false;
        }

        if(filterError){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: msg,
                    variant: 'error',
                }),
            );
            filterError = false;
        }
        else if(!filterError){
            filterError = false;
            this.publishSearchFilter(searchObj);
        }

    }

    //Save filter data
    saveFilter(){
        console.log('this.mrcHeader::'+ this.mrcHeader);
        console.log('this.mrcVal::'+ this.mrcVal);
        let filterData = new Object;
        filterData.customerId = this.customerRecId != undefined ? this.customerRecId : '';
        filterData.shipToNum = this.shipToNumVal != undefined ? this.shipToNumVal.toString() : '';
        console.log('Before 526--'+this.productVal);
        filterData.mrcNo = this.mrcHeader != undefined ? this.mrcHeader != '' ? this.mrcHeader : this.mrcVal != undefined ? (this.mrcVal).toString(): '' : '';
        console.log('after 526--'+this.motVal);
        filterData.mot = this.motVal != undefined ? (this.motVal.toString()).replaceAll(',',';') : '';
        filterData.energyTax = this.energyTaxVal != undefined ? this.energyTaxVal : '';

        let prodSelected = '';
        if(this.ago == true){
            prodSelected = 'AGO';
        }
        prodSelected = prodSelected.includes('AGO') ? prodSelected +';' : prodSelected;

        if(this.igo == true){
            prodSelected = prodSelected + 'IGO';
        }
        prodSelected = prodSelected.includes('IGO') ? prodSelected +';' : prodSelected;
        if(this.mogas == true){
            prodSelected = prodSelected + 'MOGAS';
        }
        filterData.product =prodSelected;
        //filterData.product = this.productVal != undefined ? (this.productVal.toString()).replaceAll(',',';') : '';

        filterData.retailMix = this.retailMix;
        filterData.poType = this.poTypeVal != undefined ? this.poTypeVal : '';
        filterData.depot = this.depotVal != undefined ? this.depotVal.toString() : '';
        filterData.salesOrg = this.salesOrgVal != undefined ? (this.salesOrgVal.toString()).replaceAll(',',';') : '';
        filterData.olfOnly = this.olfOnly != undefined ? this.olfOnly : false;
        //SK
       // filterData.startDate = this.startDateVal != undefined ? this.startDateVal : '';
       // filterData.endDate = this.endDateVal != undefined ? this.endDateVal : '';
        //SK
        let filterDataStr = JSON.stringify(filterData);
        console.log('filterDataStr::'+filterDataStr);


        var msg="";
        var filterError = false;
       /*if(filterData.mrcNo == "" || filterData.mrcNo == undefined){
            filterError = true;
            msg="Please select MRC to search";
        }
        else if(filterData.customerId != "" && (filterData.shipToNum == "" || filterData.shipToNum == undefined)){
            filterError = true;
            msg="Please select Ship To Number to search";
        }else if(filterData.salesOrg == ""){



            filterError = true;
            msg="Please select Sales Org to search";
        }else if(filterData.product == ""){
            filterError = true;
            msg="Please select Product to search";
        }else if(filterData.depot == "" || filterData.depot == undefined){
            filterError = true;
            msg="Please select Depot to search";
        }
        else if(filterData.startDate == "" || filterData.startDate == undefined){
            filterError = true;
            msg="Please select Contract Start Date to search";
        }
        else if(filterData.endDate == "" || filterData.endDate == undefined){
            filterError = true;
            msg="Please select Contract End Date to search";
        }*/

        if(filterError){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: msg,
                    variant: 'error',
                }),
            );
            filterError = false;
        }
            else if(!filterError){
                saveFilterData({
                    filterObjStr: filterDataStr
                })
                    .then(result => {
                        this.showToast('Success', 'Filter saved successfully', 'success');
                    })
                    .catch(error => {
                        console.error('Error: '+ JSON.stringify(error));
                        if (error.body.message.includes('Insufficient permissions: secure query included inaccessible field')) {
                        this.showToast('Error',SaveFilterDataErrorLabel, 'error');
                        } else {
                        this.showToast('Error', error.body.message, 'error');
                        }
                    });
            }
        }

    showToast(heading, msg, type){
        const evt = new ShowToastEvent({
            title: heading,
            message: msg,
            variant: type,
        });
        this.dispatchEvent(evt);
    }

    dateDifferenceInDays(){
        this.setDatesOnLoad();
        console.log('line 494:'+this.startDateVal+'-'+this.endDateVal+'-'+this.poTypeVal);
        if(this.startDateVal != undefined  ){

            const startdte = new Date(this.startDateVal);
            if(startdte > this.addDaysToDate(this.startDateVal, 15)){
                this.trancheVal = 'Flex1';
				this.tranche = 'ATP2';
                this.addDaysToDate(this.startDateVal, 15);
            }
            var month = startdte.getMonth();
            var year = startdte.getFullYear();

            /*var lastDate = new Date(year, month + 1, 0);
            var monthVal = month + 1;
            let current_datetime = lastDate;
            let formatted_date =  current_datetime.getFullYear()+ "-" + monthVal + "-" +current_datetime.getDate();
            console.log('formatted_date @ 588:'+formatted_date);*/
            let current_datetime;
            let formatted_date;
            if(startdte.getDate > 25){
                var lastDate = new Date(year, month + 1, 0);
                var monthVal = month + 1;
                current_datetime = lastDate;
                 formatted_date =  current_datetime.getFullYear()+ "-" + monthVal + "-" +current_datetime.getDate();
                console.log('formatted_date @ 588:'+formatted_date);
            }else{
                formatted_date = this.endDateVal;
            }
            let edDateVal = new Date(formatted_date);

            console.log('comparision @589:'+startdte+'<==>'+edDateVal+'**'+this.endDateVal);

            if(this.poTypeVal == 'TTTT' || this.poTypeVal == 'TTTI'){
                this.endDateVal = formatted_date;
            }
            if(startdte <= edDateVal){
                let flex2Val = this.calculateDaysDiff(this.endDateVal,startdte);

                if(flex2Val != undefined && parseInt(flex2Val) > 26){
                    this.trancheVal = 'Flex2';
					this.tranche = 'ATP3';
                }
                this.contractDuration = this.calculateDaysDiff(this.endDateVal, this.startDateVal) + 1;
            }
        }
    }

    getNegotinCustMrcData(){

        console.log('get Negotiation Data'+this.customerRecId+'--'+this.inputMRCVal);
        getNegotiationCustMrcData({
            customerId : this.customerRecId,
            mrcName : this.inputMRCVal
        }).then(result => {
            console.log('Negotiation Data:'+JSON.stringify(result));
            this.negotiationRecord = true;
            if(result == null){
                this.depotSelectedVal=[];
                this.mrcSelectedVal=[];
                this.shipToSelectedVal=[];
                this.shipToNumVal = [];
                this.salesOrgVal = [];
            }

            this.depotSelectedVal = result[0].DepotLong__c!=null ? result[0].DepotLong__c.split(',') :[];
             //this.searchOffers('fromEnter');

            console.log('##### depot val in getnegotiateDetails',this.depotSelectedVal );
            this.mrcSelectedVal = result[0].MRC_Numbers__c != null ? result[0].MRC_Numbers__c.split(',') : [];
            this.shipToSelectedVal = result[0].Ship_To_Number__c!=null ? result[0].Ship_To_Number__c.split(',') : [];
            this.shipToNumVal = result[0].Ship_To_Number__c!=null ? result[0].Ship_To_Number__c.split(',') : [];
            this.salesOrgVal = result[0].Sales_Org__c !=null ? result[0].Sales_Org__c.split(';'):[];
            var productarray = result[0].Product__c !=null ? (result[0].Product__c).split(';') : [];
            this.productVal = productarray != null ? productarray :'';//(result[0].Product__c.toString());//.replaceAll(';',',');
            if(productarray.includes('AGO')){
             this.agoSelected = true;
            }else{
                this.agoSelected = false;
            }
            if(productarray.includes('IGO')){
                this.igoSelected = true;
            }else{
                   this.igoSelected = false;
            }
            if(productarray.includes('MOGAS')){
                this.mogasSelected = true;
            }else{
                this.mogasSelected = false;
            }

            console.log('Product Val::'+this.productVal);
            var motarray = result[0].Mode_Of_Transport__c != null ? (result[0].Mode_Of_Transport__c).split(';') : [];
            this.motVal = motarray;//(result[0].Product__c.toString());//.replaceAll(';',',');
            console.log('MOT Val::'+this.motVal);
            this.poTypeVal = result[0].PO_Type__c;
            //this.motVal = result[0].MOT__c;
            console.log('poTypeVal Val::'+this.poTypeVal);
            //this.energyTaxVal = result[0].Energy_Tax__c;

            this.olfMrcOnlyVal =result[0].OLF_MRC_Only__c;


            //console.log('mrcVal::'+this.mrcSelectedVal+' '+result[0].MRC_Numbers__c.split(','));
            this.retailSelectedMix=result[0].retailMix__c;
            this.retailMix = result[0].retailMix__c;
            console.log('retaiMix::'+this.retailSelectedMix+' '+result[0].retailMix__c);
            console.log('depot val:'+this.depotVal);
            this.dateDifferenceInDays();
        })
        .catch(error => {
                console.log('Error:'+JSON.stringify(error));
        })
    }



    refreshComponent(event){
        eval("$A.get('e.force:refreshView').fire();");
    }

    setDatesOnLoad(){
        let date1 = new Date(this.startDateVal);
        let lastDay = new Date(date1.getFullYear(), date1.getMonth() + 1, 0);
        lastDay.setDate(lastDay.getDate() + 1);

        let currentMonth = parseInt((date1.getMonth()+1));
        let endDate = this.addDaysToDate(this.startDateVal, 14);

        let endDateMonth = parseInt(endDate.substring(5, 7));
        let todaysDate = new Date();

       if((endDateMonth>currentMonth && this.startDateVal >= todaysDate.toISOString().substring(0,10)) && (this.poTypeVal =='TTTT' || this.poTypeVal == 'TTTI')){
         this.endDateVal = lastDay.toISOString().substring(0,10);
         this.contractDuration = this.calculateDaysDiff(this.endDateVal,this.startDateVal) + 1;
       }else{
         this.endDateVal =this.addDaysToDate(this.startDateVal, 14);
         this.contractDuration = this.calculateDaysDiff(this.endDateVal,this.startDateVal) + 1;
       }

    }

}