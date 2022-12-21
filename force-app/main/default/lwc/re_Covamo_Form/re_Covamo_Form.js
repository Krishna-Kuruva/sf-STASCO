import { LightningElement,track ,wire,api} from 'lwc';

import { getListUi } from 'lightning/uiListApi';
import {updateRecord} from "lightning/uiRecordApi";
import COVAMO_OBJECT from '@salesforce/schema/Rev_Covamo_Header__c';

import getCovamo_HeaderFieldataset from '@salesforce/apex/RE_CovamoController.getCovamo_HeaderFieldataset';
import covemoDetailInitialization from '@salesforce/apex/RE_CovamoController.covemoDetailInitialization';

//save covamoheader
import saveCovamo_HeaderFieldataset from '@salesforce/apex/RE_CovamoController.saveCovamo_HeaderFieldataset';
import saveCovamo_detailsset from '@salesforce/apex/RE_CovamoController.saveCovamo_detailsset';
import saveUpdatedCovamo_detailsset from '@salesforce/apex/RE_CovamoController.saveUpdatedCovamo_detailsset';
import deleteCovamo_detailsset from '@salesforce/apex/RE_CovamoController.deleteCovamo_detailsset';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import calculateFinancialSummary from '@salesforce/apex/RE_CovamoController.calculateFinancialSummary';
import getCovamo_HeaderValueset from '@salesforce/apex/RE_CovamoController.getCovamo_HeaderValueset';
import getCovamo_DetailsValueset from '@salesforce/apex/RE_CovamoController.getCovamo_DetailsValueset';
import { NavigationMixin } from 'lightning/navigation';


// show Financial Summary
import FinanceDataSet from '@salesforce/apex/RE_CovamoController.FinanceDataSet';

import fatchPickListValue from '@salesforce/apex/RE_CovamoController.fetchProductValues';
import fetchRecordTypeValues from '@salesforce/apex/RE_CovamoController.fetchRecordTypeValues';
import fetchLocations from '@salesforce/apex/RE_CovamoController.fetchLocations';
import getCal from '@salesforce/apex/RE_CovamoController.myCostings';
import fetchPicklistArrayValues from '@salesforce/apex/RE_CovamoController.fetchPicklistArrayValues';

//Fatch User Permission 
import getCovamoHeaderQueueUsers from '@salesforce/apex/RE_CovamoController.getCovamoHeaderQueueUsers';
//const covamofields =[{name:'Volume__c',value:''},{name:'MOPS__c',value:''},{name:'Market_Premium__c',value:''}];
const covamofields =[{name:'Product_Name__c',value:''},
{name:'RE_Product__c',value:''},
{name:'RecordTypeId',value:''},
{name:'Volume__c',value:''},
{name:'MOPS__c',value:''},
{name:'Market_Premium__c',value:''},
{name:'Fixed_Premium__c',value:''},
{name:'Freight__c',value:''},
{name:'Oil_Loss__c',alue:''},
{name:'Additives__c',value:''},
{name:'Biofuel__c',value:''},
{name:'Hedging_Cost__c',value:''},
{name:'Breakbulk_Cost__c',value:''},
{name:'Miscellaneous_Cost__c',value:''},
{name:'Purchase_Margin__c',value:''},
{name:'Primary_Transport__c',value:''},
{name:'Handling_Cost__c',value:''},
{name:'Secondary_Transport__c',value:''},
{name:'Transportation_Margin__c',value:''},
{name:'Temperature_Gain__c',value:''},
{name:'Expected_Premium_Price_Out__c',value:''},
{name:'Distillation_Premium__c',value:''},
{name:'Total_Sales_Margin__c',value:''},
{name:'Amortization_Per_Unit__c',value:''},
{name:'Unit_C3__c',value:''},
{name:'Target_Unit_C3__c',value:''},
{name:'Cost_Between_C3_C5__c',value:''},
{name:'Cost_Below_C5__c',value:''},
{name:'Receivables_Days__c',value:''},
{name:'Payables_Days__c',value:''},
{name:'Stocks_Days__c',value:''},
{name:'Excise_Fee__c',value:''},
{name:'Type__c',value:''},
{name:'BDF__c',value:''}	];
const columns =[{Product_Name__c:'',RE_Product__c:'',RecordTypeId:'',Type__c:'',Volume__c:'',MOPS__c:'',Market_Premium__c:'',Fixed_Premium__c:'',Freight__c:'',Oil_Loss__c:'',Additives__c:'',Biofuel__c:'',Hedging_Cost__c:'',Breakbulk_Cost__c:'',Miscellaneous_Cost__c:'',Purchase_Margin__c:'',Primary_Transport__c:'',Handling_Cost__c:'',Secondary_Transport__c:'',Transportation_Margin__c:'',Temperature_Gain__c:'',Expected_Premium_Price_Out__c:'',Distillation_Premium__c:'',Total_Sales_Margin__c:'',Amortization_Per_Unit__c:'',Unit_C3__c:'',Target_Unit_C3__c:'',Cost_Between_C3_C5__c:'',Cost_Below_C5__c:'',Stocks_Days__c:'',Receivables_Days__c:'',Payables_Days__c:'',Stocks_Days__c:'',BDF__c:'',Excise_Fee__c:''}];

export default class Re_Covamo_Form extends NavigationMixin (LightningElement) {
    @api recordId='';
    @track SetCol;
    @track isModalOpen=false;   // show model window
    @track SetDetailsCol;
    @track covamoupdateddataset=[];
    @track covamodeletedataset;
    @track isnew= false;
    @track isindex= 0;
    @track isFinanceModalOpen = false;  //show Finance SUmmary Model
    @track tabVals ="Tab1";
    @track covamofinancialdataset ;
    @track financialdatavalyearset ;
    @track financialupdatedyearset ;
    @track financialdatavalset ;

    @track productList;
    @track covDetailsDataSet=columns;
    @track locationList = [];

    @track data = [];
    @track locTotalCost = [];
    @track freightCost = 0;
    @track oilLoss=0;
    @track handlingCost=0;
    @track breakupBulkCost=0;
    @track transportCost=0;
    @track totalVolume = 0;
    @track valuePresent = false;
    @api product = '';
    @track weightedAvFreight = 0;
    @track weightedAvOil = 0
    @track weightedAvHandling = 0;
    @track weightedAvBulk = 0;
    @track weightedAvTransport = 0;
    @track totalWeightedAv = 0;
    @track mopsval=0;
    @track marketpremiumval=0;
    @track isShow = false;
    @track recordTypeId = '';
    @track productId = '';
    @track recordType = '';
    @track showCalculateButton = true;
    @track showlocation = false;
    @track isLoading = false;
    @track isshowConfirmModel = false;
    @track isLoadingOnSave = false;
    @track isAM = false;
    @track isNotAM  =   true;
    @track covStartYear = '';
    @track covEndYear = '';
    @track pickListField =['RE_Valuation_Start_Year__c','RE_Valuation_End_Year__c'];
    @track valuationstartdata=[];
    @track valuationenddata=[];
    @track checkValuationYear = false;
    @track datavolume=[];
    @wire (getListUi,{objectApiName: COVAMO_OBJECT})
    property;
   
    connectedCallback(){
        
        console.log("recordId--",this.recordId);
        fetchPicklistArrayValues({objName : 'Rev_Covamo_Header__c', pickFields : this.pickListField})
        .then(result=>{
            console.log("result---"+ result);
            let mapData = new Map(); 
            mapData = result;
            if(mapData)
            {
            console.log("resultdata---"+ JSON.stringify(mapData.RE_Valuation_Start_Year__c));
            this.valuationstartdata = mapData.RE_Valuation_Start_Year__c;
            this.valuationenddata = mapData.RE_Valuation_End_Year__c;
            console.log("valuationenddata---"+ JSON.stringify(this.valuationenddata));
        }
        })
        .catch(error=>{
            console.log("result in error---",error);
        });

        this.locationList = [];
        getCovamoHeaderQueueUsers()
        .then(result=>{
            this.isAM   =   result;
            this.isNotAM    =   false;
            console.log("is AM--",result);
            
        })
        .catch(error => {
            console.log("getCovamoHeaderQueueUsers   fatch error",error);
        });

        fatchPickListValue()
        .then(result => {
            console.log("get data",JSON.stringify(result));
            this.productList=result;
        })
        .catch(error => {
            console.log("error");
        });
        /**Covamo Header DataSet */
        if(this.recordId === ''){
            
            getCovamo_HeaderFieldataset()    
            .then(result=>{           
                this.SetCol = JSON.parse(result);
				/*
                if(this.SetCol.Valuation_Start_Year__c != null){
                    console.log("this.SetCol.Valuation_Start_Year__c",this.SetCol.Valuation_Start_Year__c);
                    this.SetCol.Covamo_Start_Year__c = this.SetCol.Valuation_Start_Year__c.split("-")[0];
                }
                if(this.SetCol.Valuation_End_Year__c != null){
                    console.log("this.SetCol.Valuation_End_Year__c",this.SetCol.Valuation_End_Year__c);
                    this.SetCol.Covamo_End_Year__c = this.SetCol.Valuation_End_Year__c.split("-")[0];
                }*/
                })
            .catch(error=>{
                alert('in error');
            }); 
        }else {
        
            this.refreshcovamodatavalueset();
        /*
        getCovamo_HeaderValueset({recordId:this.recordId})
        .then(result=>{           
            this.SetCol = JSON.parse(result);
            })
            .catch(error=>{
                alert('in error');
            }); 
            getCovamo_DetailsValueset({recordId:this.recordId})
            .then(result=>{           
                this.covamoupdateddataset=result;
                })
                .catch(error=>{
                    alert('in error');
                }); 

            this.financeDataValueSet();
            */
        }
    }

    /* covamo Header datavalue change*/ 
    handleChange(event){       
        
        this.SetCol[event.target.name]= event.target.value;
        if(event.target.name == "RE_Valuation_Start_Year__c"){
            console.log("RE_Valuation_Start_Year__c",event.target.value,this.SetCol.RE_Valuation_Start_Year__c,this.SetCol.RE_Valuation_End_Year__c);
            if(event.target.value > this.SetCol.RE_Valuation_End_Year__c){
                this.showToast("warning","warning","Valuation Start Year cannot be more than Valuation End Year.");
            this.checkValuationYear = true;
            }else{
                this.checkValuationYear = false;
            }
        }
        if(event.target.name == "RE_Valuation_End_Year__c"){
            console.log("RE_Valuation_End_Year__c",event.target.value,this.SetCol.RE_Valuation_Start_Year__c,this.SetCol.RE_Valuation_End_Year__c);
            if(event.target.value < this.SetCol.RE_Valuation_Start_Year__c){
                this.showToast("warning","warning","Valuation End Year cannot be less than Valuation Start Year.");
                this.checkValuationYear = true;                
            }else{
                this.checkValuationYear = false;
            }
        }
    }
    /*Save Esisting covamo record */
    handlesave(){
        
        var dvarataval = this.covamoupdateddataset === undefined ? '' : JSON.stringify(this.covamoupdateddataset);
        console.log("set col data--",JSON.stringify(this.SetCol));
        console.log("set cov update data--",this.covamoupdateddataset+'    '+JSON.stringify(this.covamoupdateddataset));
        if(this.covamoupdateddataset != undefined){
            if(this.covamoupdateddataset.length>0){
                if(this.SetCol.Contract_Name__c && this.SetCol.Customer_Name__c && this.SetCol.RE_Valuation_Start_Year__c != '' && this.SetCol.RE_Valuation_Start_Year__c != null && this.SetCol.RE_Valuation_End_Year__c != null && this.SetCol.RE_Valuation_End_Year__c != '' && this.SetCol.Inflation_Rate__c != null && this.SetCol.VAT_Percentage__c != null && this.SetCol.Payment_Days__c != null)
                {
                    this.isLoadingOnSave = true;
                saveCovamo_HeaderFieldataset({covHeader:JSON.stringify(this.SetCol), covDetails:dvarataval,delList:this.covamodeletedataset})
                .then(result=>{
                        this.showToast("success","success","Covamo record created Successfully..");
                        
                    var url= '/lightning/r/Rev_Covamo_Header__c/'+result+'/view';
                    this.recordId   =   result;
                    this.SetCol.Id = this.recordId;
                    this.refreshcovamodatavalueset();
                   // this.financeDataValueSet();
                    this.closeModal();
                    this.isLoadingOnSave = false;
                    /*
                    setTimeout(() => {
                        window.location.reload();
                    }, 4000);
                *//*
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            objectApiName: 'Rev_Covamo_Header__c',
                            actionName: 'view',
                            url: url
                        }
                    })*/
                })
            }else{
                this.showToast("warning","warning","Please fill all the required fields in Key Valuation Assumptions.");
            }
        }else{
            this.showToast("warning","warning","There is no Key Assumptions Per Year.");
        }
    }
    else{
        this.showToast("warning","warning","There is no Key Assumptions Per Year.");
    }   
    }

    // to open modal window set 'bShowModal' tarck value as true
    openModal() {
        console.log("check vals openModal",this.SetCol.Contract_Name__c,this.SetCol.Customer_Name__c,this.SetCol.RE_Valuation_Start_Year__c,this.SetCol.RE_Valuation_End_Year__c,this.SetCol.Inflation_Rate__c,this.SetCol.VAT_Percentage__c,this.SetCol.Payment_Days__c);
        if(!this.checkValuationYear){
        if(this.SetCol.Contract_Name__c != null && this.SetCol.Customer_Name__c != null && this.SetCol.RE_Valuation_Start_Year__c != null && this.SetCol.RE_Valuation_Start_Year__c != '' && this.SetCol.RE_Valuation_End_Year__c != null && this.SetCol.RE_Valuation_End_Year__c != '' && this.SetCol.Inflation_Rate__c != null && this.SetCol.VAT_Percentage__c != null && this.SetCol.VAT_Percentage__c.toString() != "" && this.SetCol.Payment_Days__c != null && this.SetCol.Payment_Days__c.toString() != "")
        {   

            this.isnew=true;    
            this.data=[];
            this.isindex = this.covamoupdateddataset.length;

            this.showCalculateButton = true; 
            this.isModalOpen = true;
        }else{
            this.showToast("warning","warning","Please fill all the required fields in Key Valuation Assumptions.");
        }
    }else{
        this.showToast("warning","warning","Make sure Valuation Start Year is less than or equal to Valuation End Year.");
    }
        /*
        covemoDetailInitialization()
        .then(result=>{           
            this.SetDetailsCol = JSON.parse(result);
            this.isModalOpen = true;
            //  alert(this.SetDetailsCol.Volume__c);
            })
        .catch(error=>{
            alert('in error');
        }); 
        */
        // this.isModalOpen = true;
    }

    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {    
        this.isModalOpen = false;
        //this.isFinanceModalOpen = false;
        this.isShow = false;
        this.locationList = [];
        this.showCalculateButton = false;
        this.product = '';
        this.productId='';
        this.recordType='';
        this.recordTypeId='';
        this.showlocation = false;
        this.isshowConfirmModel = false;
    }

    addcovamodataset(event){
        
        var datasetval = event.detail;
        //covemoDetailInitialization()
        console.log("datasetval..",datasetval);
        console.log("SetDetailsCol----",JSON.stringify(this.SetDetailsCol));
        
        for(var i=0;i<covamofields.length;i++){
            console.log(covamofields[i].name+ '    '+  datasetval[covamofields[i].name]);
            this.SetDetailsCol[covamofields[i].name]=datasetval[covamofields[i].name];
        }
        var dvarataval = this.covamoupdateddataset === undefined ? '' : JSON.stringify(this.covamoupdateddataset);
        console.log("check fields-----",this.SetDetailsCol.Target_Unit_C3__c,this.SetDetailsCol.Cost_Below_C5__c);
        var count = 0;
        if(this.SetDetailsCol.Volume__c && this.SetDetailsCol.MOPS__c && this.SetDetailsCol.Unit_C3__c != null && this.SetDetailsCol.Unit_C3__c.toString() != "" && this.SetDetailsCol.Cost_Between_C3_C5__c != null && this.SetDetailsCol.Cost_Between_C3_C5__c.toString() != "" && this.SetDetailsCol.Target_Unit_C3__c != null && this.SetDetailsCol.Target_Unit_C3__c.toString() != "" && this.SetDetailsCol.Cost_Below_C5__c != null && this.SetDetailsCol.Cost_Below_C5__c.toString() != "" && this.SetDetailsCol.Stocks_Days__c != null && this.SetDetailsCol.Stocks_Days__c != "" && this.SetDetailsCol.Receivables_Days__c != null && this.SetDetailsCol.Receivables_Days__c != "" && this.SetDetailsCol.Payables_Days__c != null && this.SetDetailsCol.Payables_Days__c != "" )//&& this.SetDetailsCol.BDF__c != null && this.SetDetailsCol.BDF__c != ""
        {
        // if(this.SetDetailsCol.BDF__c !=0){
        /*    if(this.SetDetailsCol.Fixed_Premium__c != null && this.SetDetailsCol.Fixed_Premium__c >0){
                count++;
                console.log("count fixed",count);                
            }*/
            if(this.SetDetailsCol.Freight__c != null && this.SetDetailsCol.Freight__c >0){
                count++;
                console.log("count Freight__c",count);                
            }
        /*    if(this.SetDetailsCol.Oil_Loss__c != null && this.SetDetailsCol.Oil_Loss__c >0){
                count++;
                console.log("count Oil_Loss__c",count);                
            }*/
            if(this.SetDetailsCol.Additives__c != null && this.SetDetailsCol.Additives__c >0){
                count++;
                console.log("count Additives__c",count);                
            }
            if(this.SetDetailsCol.Biofuel__c != null && this.SetDetailsCol.Biofuel__c >0){
                count++;
                console.log("count Biofuel__c",count);                
            }
            if(this.SetDetailsCol.Hedging_Cost__c != null && this.SetDetailsCol.Hedging_Cost__c >0){
                count++;
                console.log("count Hedging_Cost__c",count);                
            }
            if(this.SetDetailsCol.Breakbulk_Cost__c != null && this.SetDetailsCol.Breakbulk_Cost__c >0){
                count++;
                console.log("count Breakbulk_Cost__c",count);                
            }
            if(this.SetDetailsCol.Miscellaneous_Cost__c != null && this.SetDetailsCol.Miscellaneous_Cost__c >0){
                count++;
                console.log("count Miscellaneous_Cost__c",count);                
            }
            if(this.SetDetailsCol.Primary_Transport__c != null && this.SetDetailsCol.Primary_Transport__c >0){
                count++;
                console.log("count Primary_Transport__c",count);                
            }
            if(this.SetDetailsCol.Handling_Cost__c != null && this.SetDetailsCol.Handling_Cost__c >0){
                count++;
                console.log("count Handling_Cost__c",count);                
            }
            if(this.SetDetailsCol.Secondary_Transport__c != null && this.SetDetailsCol.Secondary_Transport__c >0){
                count++;
                console.log("count Secondary_Transport__c",count);                
            }
            if(this.SetDetailsCol.Cost_Between_C3_C5__c != null && this.SetDetailsCol.Cost_Between_C3_C5__c >0){
                count++;
                console.log("count Cost_Between_C3_C5__c",count);                
            }
            if(this.SetDetailsCol.Cost_Below_C5__c != null && this.SetDetailsCol.Cost_Below_C5__c >0){
                count++;
                console.log("count Cost_Below_C5__c",count);                
            }
            if(count == 0){
                saveCovamo_detailsset({covDetails: JSON.stringify(this.SetDetailsCol), wrapData : dvarataval})
                .then(result=>{
                    this.covamoupdateddataset=result;
                    console.log("covamoupdateddataset",JSON.stringify(this.covamoupdateddataset));
                    
                })
                this.showToast("success","success","Covamo Detail is added..");
                this.closeModal();
            }else{
                this.showToast("warning","warning","Please enter a negative value.");
            }
        
    /* }else{
            this.showToast("warning","warning","BDF cannot be zero.");
        }*/
    }else{
        this.showToast("warning","warning","Please fill all the required fields.");
    }
    }

    editcovamodataset(event){
        this.volumecalculator();
        this.isnew = false;
        this.isShow = true;
        this.showCalculateButton = false;
        let keys = event.target.id;
        this.isindex = keys.split('-')[0];
        console.log("check key",keys,this.isindex,JSON.stringify(this.covamoupdateddataset));
        
        console.log(this.covamoupdateddataset[keys.split('-')[0]].comHeader.Miscellaneous_Cost__c);
        this.SetDetailsCol = this.covamoupdateddataset[keys.split('-')[0]].comHeader;
        this.isModalOpen = true;
    }
    deletecovamodataset(event){
        let keys = event.target.id;
        this.isindex = keys.split('-')[0];
        var dataval = this.covamoupdateddataset === undefined ? '' : JSON.stringify(this.covamoupdateddataset);
        
        deleteCovamo_detailsset({wrapData:dataval ,indexset:this.isindex, delList:this.covamodeletedataset})
        .then(result=>{
            this.covamoupdateddataset=result.coms;//covamodeletedataset
            this.covamodeletedataset = result.delcoms;
            
        })
        this.showToast("success","success","Covamo Detail is deleted..");
    }
    addeditcovamodataset(event){
            //  alert('in');
        var datasetval = event.detail.deailVals;
        var indexset = event.detail.ind;
        //covemoDetailInitialization()
        console.log(this.covamoupdateddataset);
        for(var i=0;i<covamofields.length;i++){
            console.log(covamofields[i].name+ '    '+  datasetval[covamofields[i].name]);
            this.SetDetailsCol[covamofields[i].name]=datasetval[covamofields[i].name];
        }
        var dataval = this.covamoupdateddataset === undefined ? '' : JSON.stringify(this.covamoupdateddataset);
        console.log("check this.SetDetailsCol",JSON.stringify(this.SetDetailsCol));
        var count = 0;
        if(this.SetDetailsCol.Volume__c && this.SetDetailsCol.MOPS__c && this.SetDetailsCol.Unit_C3__c != null && this.SetDetailsCol.Unit_C3__c.toString() != "" && this.SetDetailsCol.Cost_Between_C3_C5__c != null && this.SetDetailsCol.Cost_Between_C3_C5__c.toString() != "" && this.SetDetailsCol.Target_Unit_C3__c != null && this.SetDetailsCol.Target_Unit_C3__c.toString() != "" && this.SetDetailsCol.Cost_Below_C5__c != null && this.SetDetailsCol.Cost_Below_C5__c.toString() != "" && this.SetDetailsCol.Stocks_Days__c != null && this.SetDetailsCol.Stocks_Days__c.toString() != "" && this.SetDetailsCol.Receivables_Days__c != null && this.SetDetailsCol.Receivables_Days__c.toString() != "" && this.SetDetailsCol.Payables_Days__c != null && this.SetDetailsCol.Payables_Days__c.toString() != "")// && this.SetDetailsCol.BDF__c != null && this.SetDetailsCol.BDF__c.toString() != ""
        {
        // if(this.SetDetailsCol.BDF__c != 0){
          /*  if(this.SetDetailsCol.Fixed_Premium__c != null && this.SetDetailsCol.Fixed_Premium__c >0){
                count++;
                console.log("count fixed",count);                
            } */
            if(this.SetDetailsCol.Freight__c != null && this.SetDetailsCol.Freight__c >0){
                count++;
                console.log("count Freight__c",count);                
            }
        /*    if(this.SetDetailsCol.Oil_Loss__c != null && this.SetDetailsCol.Oil_Loss__c >0){
                count++;
                console.log("count Oil_Loss__c",count);                
            } */
            if(this.SetDetailsCol.Additives__c != null && this.SetDetailsCol.Additives__c >0){
                count++;
                console.log("count Additives__c",count);                
            }
            if(this.SetDetailsCol.Biofuel__c != null && this.SetDetailsCol.Biofuel__c >0){
                count++;
                console.log("count Biofuel__c",count);                
            }
            if(this.SetDetailsCol.Hedging_Cost__c != null && this.SetDetailsCol.Hedging_Cost__c >0){
                count++;
                console.log("count Hedging_Cost__c",count);                
            }
            if(this.SetDetailsCol.Breakbulk_Cost__c != null && this.SetDetailsCol.Breakbulk_Cost__c >0){
                count++;
                console.log("count Breakbulk_Cost__c",count);                
            }
            if(this.SetDetailsCol.Miscellaneous_Cost__c != null && this.SetDetailsCol.Miscellaneous_Cost__c >0){
                count++;
                console.log("count Miscellaneous_Cost__c",count);                
            }
            if(this.SetDetailsCol.Primary_Transport__c != null && this.SetDetailsCol.Primary_Transport__c >0){
                count++;
                console.log("count Primary_Transport__c",count);                
            }
            if(this.SetDetailsCol.Handling_Cost__c != null && this.SetDetailsCol.Handling_Cost__c >0){
                count++;
                console.log("count Handling_Cost__c",count);                
            }
            if(this.SetDetailsCol.Secondary_Transport__c != null && this.SetDetailsCol.Secondary_Transport__c >0){
                count++;
                console.log("count Secondary_Transport__c",count);                
            }
            if(this.SetDetailsCol.Cost_Between_C3_C5__c != null && this.SetDetailsCol.Cost_Between_C3_C5__c >0){
                count++;
                console.log("count Cost_Between_C3_C5__c",count);                
            }
            if(this.SetDetailsCol.Cost_Below_C5__c != null && this.SetDetailsCol.Cost_Below_C5__c >0){
                count++;
                console.log("count Cost_Below_C5__c",count);                
            }
            if(count == 0){
        saveUpdatedCovamo_detailsset({covDetails: JSON.stringify(this.SetDetailsCol), wrapData : dataval, indexset: indexset})
        .then(result=>{
            this.covamoupdateddataset=result;
        })
        this.showToast("success","success","Covamo Detail is added..");
        this.closeModal();
    }else{
        this.showToast("warning","warning","Please enter a negative value.");
    }
        /*}else{
            this.showToast("warning","warning","BDF cannot be zero.");
        }*/
    }else{
        this.showToast("warning","warning","Please fill all the required fields.");
    }
    }

    //Finance SUmmary
    openFinanceSummarySaveConfirmationModal(){
        if(this.financialdatavalset != null && this.financialupdatedyearset != null){
            this.isshowConfirmModel = true;
        }else{
            this.showToast("warning","warning","There are no Financial Summaries to Submit");
        }
    }

    //Finance SUmmary Check
    openFinanceSummaryConfirmationModal(){
        if(this.financialdatavalset != null && this.financialupdatedyearset != null){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    recordId: this.recordId,
                    url: '/apex/RE_Covamo_Mail?id='+this.recordId
                    
                }
            })
        }else{
            this.showToast("warning","warning","There are no Financial Summaries to Submit");
        }
        }
        /*
        var dvarataval = this.covamoupdateddataset === undefined ? '' : JSON.stringify(this.covamoupdateddataset);
        
        calculateFinancialSummary({covHeader:JSON.stringify(this.SetCol), covDetails:dvarataval})
        .then(result=>{
            this.covamofinancialdataset=JSON.parse(result);
            this.isFinanceModalOpen =   true;
        })
        */


    showToast(titls,varnt,msg) {
        const event = new ShowToastEvent({
            title: titls,
            variant:varnt,
            message: msg
        });
        this.dispatchEvent(event);
    }
    onProductValueSelection(event){
        
        if(event.target.value != "--Select--"){
            
            //  this.covDetailsDataSet.Product_Name__c=this.productList[event.target.value].Name;
            //   this.covDetailsDataSet.RE_Product__c=this.productList[event.target.value].Id;
            this.product=this.productList[event.target.value].Name;
            this.productId = this.productList[event.target.value].Id;
            // console.log("this.SetDetailsCol.RE_Product__c",this.SetDetailsCol.RE_Product__c,this.SetDetailsCol.Product_Name__c);
            this.locationList=[];
            fetchLocations({productId: this.productList[event.target.value].Id})
            .then(result=> {
            console.log("get location data",JSON.stringify(result));
            this.locationList=result;
            this.showlocation = true;
            // this.product = result[0].RE_Product_Name__r.Name;
            
        })
            .catch(error=> {
            console.log("error locations");
            
        });
        }else{
            //  this.covDetailsDataSet.Product_Name__c = '';
            //  this.covDetailsDataSet.RE_Product__c=null;
            this.product = '';
            this.productId = null;
        }
        //   this.showDetails();
    }
    onTypeValueSelection(event){
        
        if(event.target.value != "--Select--"){
            
            fetchRecordTypeValues({typename:event.target.value})
            
            .then(result => {
                console.log("check type data",JSON.parse(result));
                
                //   this.covDetailsDataSet.RecordTypeId = JSON.parse(result).Id;
                //  this.covDetailsDataSet.Type__c      = JSON.parse(result).Name;
                this.recordTypeId = JSON.parse(result).Id;
                this.recordType = JSON.parse(result).Name;
                //  console.log("this.SetDetailsCol.Type__c",this.SetDetailsCol.Type__c);

                //  this.showDetails();
            })
            .catch(error => {
                console.log("error");
            });
        }else{
            // this.SetDetailsCol.RecordTypeId = '';
            // this.showDetails();
            this.recordTypeId = '';
        }
        // this.covDetailsDataSet.RecordTypeId=event.target.value;
    }
    saveValue(event){
        console.log("saveValue",event.target.name,event.target.value,JSON.stringify(this.data));
        this.valuePresent = false;
        if(this.data.length>0){
            for(let i=0;i<this.data.length;i++){
                if(this.data[i].Location == event.target.name){
                    console.log("inside if.....");
                    this.data[i].Volume = event.target.value;
                    if(event.target.value == ""){
                        this.data.splice(i,1)
                    }
                    this.valuePresent = true;
                    break;
                }
            }
        }
        if(!this.valuePresent){
            console.log("inside else....");
            var pushData = {
                'Location':event.target.name,
                'Volume':event.target.value
            };
            this.data.push(pushData);
        }
        this.totalVolume = 0;
        for(let i=0;i<this.data.length;i++){
            this.totalVolume +=parseFloat(this.data[i].Volume);
            console.log("this.totalVolume",this.totalVolume);
            
        }
        
        console.log("check data",JSON.stringify(this.data));
    }
    getCalculations(){
        console.log("add assumption data ---",JSON.stringify(this.covamoupdateddataset));
        
        console.log("check in calculation",JSON.stringify(this.data),this.product,this.recordType,this.data.length);
        var count = 0;
        if(this.covamoupdateddataset != undefined){
            for(let i=0;i<this.covamoupdateddataset.length;i++){
                if(this.covamoupdateddataset[i].comHeader.Product_Name__c == this.product && this.covamoupdateddataset[i].comHeader.Type__c == this.recordType){
                    count++;
                    console.log("SetDetailsCol inside if ---- ",count,JSON.stringify(this.covamoupdateddataset));            
                }
                }
        }
        
        if(count == 0){
        if(this.data.length > 0 && this.product !== "" && this.recordType !== ""){
            this.isLoading = true;
        getCal({productLocation: JSON.stringify(this.data),product: this.product})
        .then(result=>{
            this.showCalculateButton = false;
            console.log("getCal",JSON.stringify(result));
            this.freightCost=0;
            this.oilLoss=0;
            this.handlingCost=0;
            this.breakupBulkCost=0;
            this.transportCost=0;
            this.locTotalCost=[];
            this.weightedAvFreight = 0;
            this.weightedAvOil=0;
            this.weightedAvHandling=0;
            this.weightedAvBulk=0;
            this.weightedAvTransport=0;
            this.totalWeightedAv=0;
            this.mopsval=0;
            this.marketpremiumval=0;

            console.log("check this.data 1",JSON.stringify(this.data));
            for(let i=0;i<result.length;i++){
                console.log("check this.data",JSON.stringify(this.data));
                
                var indexValue = this.data.findIndex(x => x.Location.includes(result[i].RE_Depot_Name__r.Name));
                console.log("check index",indexValue);
                this.mopsval=parseFloat(result[i].Covamo_MOPS__c).toFixed(4);
                console.log("check mopsval",this.mopsval);
                console.log("check mopsval 2",result[i].Covamo_MOPS__c);
                this.marketpremiumval=parseFloat(result[i].RE_Market_Premium__c).toFixed(4);
                this.weightedAvFreight += parseFloat(((parseFloat(this.data[indexValue].Volume)/parseFloat(this.totalVolume))*parseFloat(result[i].RE_MR_Freight_Cost__c)).toFixed(4));
                this.weightedAvOil += parseFloat(((parseFloat(this.data[indexValue].Volume)/parseFloat(this.totalVolume))*parseFloat(result[i].RE_Oil_Loss__c)).toFixed(4));
                this.weightedAvHandling += parseFloat(((parseFloat(this.data[indexValue].Volume)/parseFloat(this.totalVolume))*parseFloat(result[i].RE_Storage_Handling_Cost__c)).toFixed(4));
                this.weightedAvBulk += parseFloat(((parseFloat(this.data[indexValue].Volume)/parseFloat(this.totalVolume))*parseFloat(result[i].RE_Breakbulk_Premium__c)).toFixed(4));
                this.weightedAvTransport += parseFloat(((parseFloat(this.data[indexValue].Volume)/parseFloat(this.totalVolume))*parseFloat(result[i].RE_Primary_Transport_Cost__c)).toFixed(4));
                this.totalWeightedAv = parseFloat((this.weightedAvFreight+this.weightedAvOil+this.weightedAvHandling+this.weightedAvBulk+this.weightedAvTransport+this.totalWeightedAv).toFixed(4));
                console.log("check values",this.totalWeightedAv,this.weightedAvFreight,this.weightedAvOil,this.weightedAvHandling,this.weightedAvBulk,this.weightedAvTransport);
                
                var totalCost = 0;
                totalCost = parseFloat((parseFloat(result[i].RE_MR_Freight_Cost__c)+parseFloat(result[i].RE_Oil_Loss__c)+parseFloat(result[i].RE_Storage_Handling_Cost__c)+parseFloat(result[i].RE_Breakbulk_Premium__c)+parseFloat(result[i].RE_Primary_Transport_Cost__c)).toFixed(4));
                console.log("totalCost",totalCost,result[i].RE_Depot_Name__r.Name);
                
                this.locTotalCost.push({key:result[i].RE_Depot_Name__r.Name, value:totalCost}); 
                this.freightCost +=parseFloat(result[i].RE_MR_Freight_Cost__c);
                this.oilLoss +=parseFloat(result[i].RE_Oil_Loss__c);
                this.handlingCost +=parseFloat(result[i].RE_Storage_Handling_Cost__c);
                this.breakupBulkCost +=parseFloat(result[i].RE_Breakbulk_Premium__c);
                this.transportCost +=parseFloat(result[i].RE_Primary_Transport_Cost__c);
            }
            console.log("locTotalCost",JSON.stringify(this.locTotalCost),this.freightCost,this.oilLoss,this.handlingCost,this.breakupBulkCost,this.transportCost);
            this.isnew=true; 
            console.log('this.marketpremiumval   '+this.marketpremiumval);
            covemoDetailInitialization({product: this.product,productId: this.productId,recordType: this.recordType,recordTypeId: this.recordTypeId, volume: this.totalVolume,freight: this.weightedAvFreight,oilLoss: this.weightedAvOil,breakupBulkCost: this.weightedAvBulk,handlingCost: this.weightedAvHandling,transportCost: this.weightedAvTransport,covHeader:JSON.stringify(this.SetCol),mops:this.mopsval,marketpremium:this.marketpremiumval})
            .then(result=>{           
                this.volumecalculator();
                this.SetDetailsCol = JSON.parse(result);
                this.isModalOpen = true;
                this.isShow=true;
                this.isLoading=false;
                //  alert(this.SetDetailsCol.Volume__c);
                })
            .catch(error=>{
                alert('in error');
                this.isLoading=false;
            }); 
        })
        .catch(error=>{
            alert("error in calculaton");
            this.isLoading=false;
        });
    }
    else{
        this.showToast("error","error","Please select a Product and Type and Enter Volume");
    }
        }else{
        this.showToast("error","error","Assumption Per Year with this Product and Type already exists.");
        }
    }
    financeDataValueSet(){
        FinanceDataSet({recordId:this.recordId})
        .then(result=>{
            
            this.financialdatavalset    =   JSON.parse(result).covamoFS;
        
            this.financialdatavalyearset = (JSON.parse(result)).covamoYearlyFS;
            var offervalSet = [];
            var backstopvalSet = [];
            var financeYearSet = [];
            var offersumSet = [];
            var backstopsumSet = [];
            for(let i=0;i<this.financialdatavalyearset.length;i++){
                if(this.financialdatavalyearset[i].Type__c === 'Offer'){
                    offervalSet.push(this.financialdatavalyearset[i]);/*
                    NPVOffer = this.financialdatavalyearset[i].NPV__C + NPVOffer ;
                    ROACHEOffer = this.financialdatavalyearset[i].Average_ROACE__c + ROACHEOffer ;
                    VUINPVOffer = this.financialdatavalyearset[i].VIR_DENOMINATOR_NPV__c + VUINPVOffer ;
                    VIROffer = this.financialdatavalyearset[i].VIR__c + VIROffer ;*/
                }else if(this.financialdatavalyearset[i].Type__c === 'Backstop'){
                    backstopvalSet.push(this.financialdatavalyearset[i]);/*
                    NPVBackstop = this.financialdatavalyearset[i].NPV__C + NPVOffer ;
                    ROACHeBackstop = this.financialdatavalyearset[i].Average_ROACE__c + ROACHeBackstop;
                    VUINPVBackstop = this.financialdatavalyearset[i].VIR_DENOMINATOR_NPV__c + VUINPVBackstop ;
                    VIRBackstop = this.financialdatavalyearset[i].VIR__c + VIRBackstop;*/
                }
            }
            //  offersumSet.push({"NPVOffer":NPVOffer,"ROACHEOffer":ROACHEOffer,"VUINPVOffer":VUINPVOffer,"VIROffer":VIROffer});
            //backstopsumSet.push({"NPVOffer":NPVBackstop,"ROACHEOffer":ROACHeBackstop,"VUINPVOffer":VUINPVBackstop,"VIROffer":VIRBackstop});
            if(offervalSet.length !=0)
            financeYearSet.push({"type":"Offer","vals":offervalSet});//
            if(backstopvalSet.length !=0)
            financeYearSet.push({"type":"Backstop","vals":backstopvalSet});//,"sumset":backstopsumSet
            this.financialupdatedyearset       =   financeYearSet;
            

        
        })
        .catch(error=>{
            alert('with error ;;;;;');
        })
        this.isFinanceModalOpen = true;
    }
    activatecovamo(){
        const recordInput={fields:{
            Id:this.recordId,
            Status__c:'Submitted'           
        },};
        updateRecord(recordInput)
        .then(result=>{
            this.showToast("success","success","Covamo Submitted Successfully");
                        
            var url= '/lightning/r/Rev_Covamo_Header__c/'+this.recordId+'/view';
                    this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Rev_Covamo_Header__c',
                    actionName: 'view',
                    url: url
                }
            })
            this.closeModal();

        })
        

    }
    refreshCovamo(){

        window.open("/lightning/n/Covamo","_self");

    }

    refreshcovamodatavalueset(){
        getCovamo_HeaderValueset({recordId:this.recordId})
        .then(result=>{           
            this.SetCol = JSON.parse(result);
			/*
            if(this.SetCol.Valuation_Start_Year__c != null){
                console.log("this.SetCol.Valuation_Start_Year__c",this.SetCol.Valuation_Start_Year__c);
                this.SetCol.Covamo_Start_Year__c = this.SetCol.Valuation_Start_Year__c.split("-")[0];
            }
            if(this.SetCol.Valuation_End_Year__c != null){
                console.log("this.SetCol.Valuation_End_Year__c",this.SetCol.Valuation_End_Year__c);
                this.SetCol.Covamo_End_Year__c = this.SetCol.Valuation_End_Year__c.split("-")[0];
            }*/
            })
            .catch(error=>{
                alert('in error');
            }); 
            getCovamo_DetailsValueset({recordId:this.recordId})
            .then(result=>{           
            this.covamoupdateddataset=result;
            })
            .catch(error=>{
                alert('in error');
            }); 

        this.financeDataValueSet();
    }
    volumecalculator(){
        var yeardiffs = this.SetCol.RE_Valuation_End_Year__c - this.SetCol.RE_Valuation_Start_Year__c + 1;
        var offervolume = 0;
        var backstopvolume = 0;
        this.datavolume=[]; 
        var isoff    ='';
        var isbacks  ='';
        var isoffprod    ='';
        var isbacksprod  ='';
        if(this.covamoupdateddataset != undefined){
             
            for(let i=0;i<this.covamoupdateddataset.length;i++){
                
                if(this.covamoupdateddataset[i].comHeader.Type__c==='Offer'){
                    isoff = isoff==='' ? this.covamoupdateddataset[i].comHeader.RE_Product__c : isoff;
                    isoffprod = isoffprod==='' ? this.covamoupdateddataset[i].comHeader.Product_Name__c : isoffprod;
                    offervolume = offervolume + this.covamoupdateddataset[i].comHeader.Volume__c;
                }
                if(this.covamoupdateddataset[i].comHeader.Type__c==='Backstop'){

                    isbacks = isbacks==='' ? this.covamoupdateddataset[i].comHeader.RE_Product__c : isbacks;
                    isbacksprod = isbacksprod==='' ? this.covamoupdateddataset[i].comHeader.Product_Name__c : isbacksprod;
                    backstopvolume = backstopvolume + this.covamoupdateddataset[i].comHeader.Volume__c;

                }
                
            }                    
        }
        this.datavolume.push({type:'Offer',volume:offervolume,yeardiffs:yeardiffs,products:isoff,productsname:isoffprod});

        this.datavolume.push({type:'Backstop',volume:backstopvolume,yeardiffs:yeardiffs,products:isbacks,productsname:isbacksprod});

    }
}