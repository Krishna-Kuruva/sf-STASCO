import { LightningElement,api, track } from 'lwc';
import fatchPickListValue from '@salesforce/apex/RE_CovamoController.fetchProductValues';   
import fetchRecordTypeValues from '@salesforce/apex/RE_CovamoController.fetchRecordTypeValues';   

import fetchLocations from '@salesforce/apex/RE_CovamoController.fetchLocations';


const columns =[{Product_Name__c:'',RE_Product__c:'',RecordTypeId:'',Type__c:'',Volume__c:'',MOPS__c:'',Market_Premium__c:'',Fixed_Premium__c:'',Freight__c:'',Oil_Loss__c:'',Additives__c:'',Biofuel__c:'',Hedging_Cost__c:'',Breakbulk_Cost__c:'',Miscellaneous_Cost__c:'',Purchase_Margin__c:'',Primary_Transport__c:'',Handling_Cost__c:'',Secondary_Transport__c:'',Transportation_Margin__c:'',Temperature_Gain__c:'',Expected_Premium_Price_Out__c:'',Distillation_Premium__c:'',Total_Sales_Margin__c:'',Amortization_Per_Unit__c:'',Unit_C3__c:'',Target_Unit_C3__c:'',Cost_Between_C3_C5__c:'',Cost_Below_C5__c:'',Stocks_Days__c:'',Receivables_Days__c:'',Payables_Days__c:'',Stocks_Days__c:'',BDF__c:'',Excise_Fee__c:''}];
export default class ReCovamoChild extends LightningElement {
    @api covDetailsSet;
    @api exchangeRate;
    @api volumeset;
    @api isAM;
    @api isNew;
    @api isIndex;
    @track covDetailsDataSet=columns;
    @track productList;
    @track isShow = false;

    @track locationList = [];
    @track product = '';
    @track isbdfreq = false;
    @track firstproduct='';
   
    connectedCallback(){
       console.log("covDetailsSet",JSON.stringify(this.covDetailsSet));
       
       //this.isbdfreq    =   (this.isNew || this.isIndex===0) ? false : true;
        this.covDetailsDataSet.Product_Name__c                  =   this.covDetailsSet.Product_Name__c ;
        this.covDetailsDataSet.RE_Product__c                    =   this.covDetailsSet.RE_Product__c ;
        this.covDetailsDataSet.RecordTypeId                     =   this.covDetailsSet.RecordTypeId ;
        this.covDetailsDataSet.Volume__c                        =   this.covDetailsSet.Volume__c ;
        this.covDetailsDataSet.MOPS__c                          =   this.covDetailsSet.MOPS__c ;
        this.covDetailsDataSet.Market_Premium__c                =   this.covDetailsSet.Market_Premium__c ;
        this.covDetailsDataSet.Fixed_Premium__c                 =   this.isNew ? null : this.covDetailsSet.Fixed_Premium__c ;
        this.covDetailsDataSet.Freight__c                       =   this.covDetailsSet.Freight__c ;
        this.covDetailsDataSet.Oil_Loss__c                      =   this.covDetailsSet.Oil_Loss__c ;
        this.covDetailsDataSet.Additives__c                     =   this.covDetailsSet.Additives__c ;

        this.covDetailsDataSet.Biofuel__c                       =   this.covDetailsSet.Biofuel__c ;
        this.covDetailsDataSet.Hedging_Cost__c                  =   this.covDetailsSet.Hedging_Cost__c ;
        this.covDetailsDataSet.Breakbulk_Cost__c                =   this.covDetailsSet.Breakbulk_Cost__c ;
        this.covDetailsDataSet.Miscellaneous_Cost__c            =   this.isNew ? null : this.covDetailsSet.Miscellaneous_Cost__c ;
        this.covDetailsDataSet.Purchase_Margin__c               =   this.isNew ? null : this.covDetailsSet.Purchase_Margin__c ;
        this.covDetailsDataSet.Primary_Transport__c             =   this.covDetailsSet.Primary_Transport__c ;

        this.covDetailsDataSet.Handling_Cost__c                 =   this.covDetailsSet.Handling_Cost__c ;
        this.covDetailsDataSet.Secondary_Transport__c           =   this.isNew ? null : this.covDetailsSet.Secondary_Transport__c ;
        this.covDetailsDataSet.Transportation_Margin__c         =   this.isNew ? null : this.covDetailsSet.Transportation_Margin__c ;
        this.covDetailsDataSet.Temperature_Gain__c              =   this.covDetailsSet.Temperature_Gain__c ;
        this.covDetailsDataSet.Expected_Premium_Price_Out__c    =   this.isNew ? null : this.covDetailsSet.Expected_Premium_Price_Out__c ;
        this.covDetailsDataSet.Distillation_Premium__c          =   this.isNew ? null : this.covDetailsSet.Distillation_Premium__c ;


        this.covDetailsDataSet.Total_Sales_Margin__c            =   this.isNew ? null : this.covDetailsSet.Total_Sales_Margin__c ;
        this.covDetailsDataSet.Amortization_Per_Unit__c         =   this.isNew ? null : this.covDetailsSet.Amortization_Per_Unit__c ;
        this.covDetailsDataSet.Target_Unit_C3__c                =   this.covDetailsSet.Target_Unit_C3__c ;
        this.covDetailsDataSet.Cost_Between_C3_C5__c            =   this.covDetailsSet.Cost_Between_C3_C5__c ;
        this.covDetailsDataSet.Unit_C3__c                       =   this.isNew ? null : this.covDetailsSet.Unit_C3__c ;
        this.covDetailsDataSet.Cost_Below_C5__c                 =   this.covDetailsSet.Cost_Below_C5__c ;
        this.covDetailsDataSet.Stocks_Days__c                   =   this.covDetailsSet.Stocks_Days__c ;
        this.covDetailsDataSet.Receivables_Days__c              =   this.covDetailsSet.Receivables_Days__c ;
        this.covDetailsDataSet.Payables_Days__c                 =   this.covDetailsSet.Payables_Days__c ;
        this.covDetailsDataSet.Type__c                          =   this.covDetailsSet.Type__c;
        this.covDetailsDataSet.Excise_Fee__c                    =   this.covDetailsSet.Excise_Fee__c ;
        this.covDetailsDataSet.BDF__c                           =   this.covDetailsSet.BDF__c;
        //this.calculatepurchasecostvalue();
        for(var i=0;i<this.volumeset.length;i++){
            
            this.firstproduct   =  this.covDetailsSet.Type__c === this.volumeset[i].type ? this.volumeset[i].productsname : this.firstproduct;
            // alert(this.covDetailsSet.Type__c+'  --- '+ this.volumeset[i].type+'   ***  '+this.volumeset[i].products+'  ---  '+this.covDetailsSet.RE_Product__c);
              if(this.covDetailsSet.Type__c === this.volumeset[i].type && (this.volumeset[i].products === '' || this.volumeset[i].products ===this.covDetailsSet.RE_Product__c)){
                  this.isbdfreq = true;
                  this.calculatepurchasecostvalue('BDF__c');
  
              }
          }
        fatchPickListValue()
        .then(result => {
            console.log("get data",JSON.stringify(result));
            this.productList=result;
        })
        .catch(error => {
            console.log("error");
        });
        this.showDetails();
    }
    showDetails(){
       
        if(this.covDetailsDataSet.Product_Name__c != '' && this.covDetailsDataSet.RecordTypeId !=''){
           
            this.isShow = true;
        }else{
            this.isShow = false;
        }
    }
    onProductValueSelection(event){
       
        if(event.target.value != "--Select--"){
          
            this.covDetailsDataSet.Product_Name__c=this.productList[event.target.value].Name;
            this.covDetailsDataSet.RE_Product__c=this.productList[event.target.value].Id;
            fetchLocations({productId: this.productList[event.target.value].Id})
            .then(result=> {
            console.log("get location data",JSON.stringify(result));
            this.locationList=result;
            this.product = result[0].RE_Product_Name__r.Name;
        })
            .catch(error=> {
            console.log("error locations");
            
        });
        }else{
            this.covDetailsDataSet.Product_Name__c = '';
            this.covDetailsDataSet.RE_Product__c=null;
        }
        this.showDetails();
    }
    onTypeValueSelection(event){
        
        if(event.target.value != "--Select--"){
            
            fetchRecordTypeValues({typename:event.target.value})
            
            .then(result => {
                
                this.covDetailsDataSet.RecordTypeId = JSON.parse(result).Id;
                this.covDetailsDataSet.Type__c      = JSON.parse(result).Name;
                this.showDetails();
            })
            .catch(error => {
                console.log("error");
            });
        }else{
            this.covDetailsDataSet.RecordTypeId = '';
            this.showDetails();
        }
       // this.covDetailsDataSet.RecordTypeId=event.target.value;
    }

    handlechangeValue(event){
        this.covDetailsDataSet[event.target.name]=event.target.value;
        console.log("event.target.name",event.target.name);
        
        this.calculatepurchasecostvalue(event.target.name);
    }

    calculatepurchasecostvalue(fieldName){
    
      //  if(fieldNames === 'Market_Premium__c' || fieldNames === 'Freight__c' || fieldNames === 'Oil_Loss__c' || fieldNames === 'Additives__c' || fieldNames === 'Biofuel__c' || fieldNames === 'Hedging_Cost__c' || fieldNames === 'Breakbulk_Cost__c' || fieldNames === 'Miscellaneous_Cost__c')
      {
        
        console.log("field name -- ",fieldName);
        
            this.covDetailsDataSet.Purchase_Margin__c = (this.covDetailsDataSet.Market_Premium__c != null && this.covDetailsDataSet.Market_Premium__c != '' ? parseFloat(this.covDetailsDataSet.Market_Premium__c)  : 0.00 ) + 
            (this.covDetailsDataSet.Freight__c != null && this.covDetailsDataSet.Freight__c != '' ? parseFloat(this.covDetailsDataSet.Freight__c) : 0.00) +
            (this.covDetailsDataSet.Fixed_Premium__c != null && this.covDetailsDataSet.Fixed_Premium__c != '' ? parseFloat(this.covDetailsDataSet.Fixed_Premium__c) : 0.00) +
            (this.covDetailsDataSet.Oil_Loss__c != null && this.covDetailsDataSet.Oil_Loss__c != '' ? parseFloat(this.covDetailsDataSet.Oil_Loss__c) : 0.00) +
            (this.covDetailsDataSet.Additives__c != null && this.covDetailsDataSet.Additives__c != '' ? parseFloat(this.covDetailsDataSet.Additives__c) : 0.00) + 
            (this.covDetailsDataSet.Biofuel__c != null && this.covDetailsDataSet.Biofuel__c != '' ? parseFloat(this.covDetailsDataSet.Biofuel__c) : 0.00) + 
            (this.covDetailsDataSet.Hedging_Cost__c != null && this.covDetailsDataSet.Hedging_Cost__c != '' ? parseFloat(this.covDetailsDataSet.Hedging_Cost__c) : 0.00) +
            (this.covDetailsDataSet.Breakbulk_Cost__c != null && this.covDetailsDataSet.Breakbulk_Cost__c != '' ? parseFloat(this.covDetailsDataSet.Breakbulk_Cost__c) : 0.00) + 
            (this.covDetailsDataSet.Miscellaneous_Cost__c != null && this.covDetailsDataSet.Miscellaneous_Cost__c != '' ? parseFloat(this.covDetailsDataSet.Miscellaneous_Cost__c) : 0.00);
        }
        //if(fieldNames === 'Primary_Transport__c' || fieldNames === 'Handling_Cost__c' || fieldNames === 'Secondary_Transport__c')
        {
            
            this.covDetailsDataSet.Transportation_Margin__c = (this.covDetailsDataSet.Primary_Transport__c != null && this.covDetailsDataSet.Primary_Transport__c != '' ? parseFloat(this.covDetailsDataSet.Primary_Transport__c) : 0.00)  + 
            (this.covDetailsDataSet.Handling_Cost__c != null && this.covDetailsDataSet.Handling_Cost__c != '' ? parseFloat(this.covDetailsDataSet.Handling_Cost__c) : 0.00 ) + 
            (this.covDetailsDataSet.Secondary_Transport__c != null && this.covDetailsDataSet.Secondary_Transport__c != '' ? parseFloat(this.covDetailsDataSet.Secondary_Transport__c) : 0.00);      
         }
         
         //if(fieldNames === 'Temperature_Gain__c' || fieldNames === 'Expected_Premium_Price_Out__c' || fieldNames === 'Distillation_Premium__c')
        
            

          this.covDetailsDataSet.Expected_Premium_Price_Out__c = -(this.covDetailsDataSet.Purchase_Margin__c != null && this.covDetailsDataSet.Purchase_Margin__c != '' ? parseFloat(this.covDetailsDataSet.Purchase_Margin__c) : 0.00) - 
                                                                (this.covDetailsDataSet.Transportation_Margin__c != null && this.covDetailsDataSet.Transportation_Margin__c != '' ? parseFloat(this.covDetailsDataSet.Transportation_Margin__c) : 0.00) + 
                                                                (this.covDetailsDataSet.Target_Unit_C3__c != null && this.covDetailsDataSet.Target_Unit_C3__c != '' ? parseFloat(this.covDetailsDataSet.Target_Unit_C3__c) : 0.00);
        
        this.covDetailsDataSet.Total_Sales_Margin__c = (this.covDetailsDataSet.Temperature_Gain__c != null && this.covDetailsDataSet.Temperature_Gain__c != '' ? parseFloat(this.covDetailsDataSet.Temperature_Gain__c) : 0.00) + 
                                                        (this.covDetailsDataSet.Expected_Premium_Price_Out__c != null && this.covDetailsDataSet.Expected_Premium_Price_Out__c != '' ? parseFloat(this.covDetailsDataSet.Expected_Premium_Price_Out__c) : 0.00) + 
                                                        ((this.covDetailsDataSet.Distillation_Premium__c != null && this.covDetailsDataSet.Distillation_Premium__c != '') ? parseFloat(this.covDetailsDataSet.Distillation_Premium__c) : 0.00);          
           
       // this.covDetailsDataSet.Amortization_Per_Unit__c = (this.covDetailsDataSet.Amortization_Per_Unit__c != null && this.covDetailsDataSet.Amortization_Per_Unit__c != '' ? parseFloat(this.covDetailsDataSet.Amortization_Per_Unit__c) : parseFloat((((this.covDetailsDataSet.BDF__c != null && this.covDetailsDataSet.BDF__c != '' ? parseFloat(this.covDetailsDataSet.BDF__c) : 0.00) / this.covDetailsDataSet.Volume__c) * 1000 * ((this.exchangeRate != null && this.exchangeRate != '') ? parseFloat(this.exchangeRate) : 0.00)).toFixed(4)));
        if(fieldName == 'Amortization_Per_Unit__c'){
            this.covDetailsDataSet.Amortization_Per_Unit__c = (this.covDetailsDataSet.Amortization_Per_Unit__c != null && this.covDetailsDataSet.Amortization_Per_Unit__c != '' ? parseFloat(this.covDetailsDataSet.Amortization_Per_Unit__c) : 0.00);
        }else if(fieldName == 'BDF__c'){ 
            for(var i=0;i<this.volumeset.length;i++){
                if(this.covDetailsDataSet.Type__c === this.volumeset[i].type){
                   /* if(this.covDetailsDataSet.RE_Product__c === this.volumeset[i].products){
                        this.isbdfreq    =   true;
                    }*/
                   // alert((parseFloat(this.covDetailsDataSet.BDF__c)/this.volumeset[i].yeardiffs)+'    '+(this.isNew ? (this.covDetailsDataSet.Volume__c + this.volumeset[i].volume) : this.volumeset[i].volume)+'     '+parseFloat(this.exchangeRate));
                    this.covDetailsDataSet.Amortization_Per_Unit__c = parseFloat((((this.covDetailsDataSet.BDF__c != null && this.covDetailsDataSet.BDF__c != '' ? (-(parseFloat(this.covDetailsDataSet.BDF__c)/this.volumeset[i].yeardiffs) * this.volumeset[i].yeardiffs) : 0.00) / ((this.isNew ? (this.covDetailsDataSet.Volume__c + this.volumeset[i].volume) : this.volumeset[i].volume) * this.volumeset[i].yeardiffs)) * 1000 * ((this.exchangeRate != null && this.exchangeRate != '') ? parseFloat(this.exchangeRate) : 0.00)).toFixed(4));

                }

            }

          //  this.covDetailsDataSet.Amortization_Per_Unit__c = parseFloat((((this.covDetailsDataSet.BDF__c != null && this.covDetailsDataSet.BDF__c != '' ? parseFloat(this.covDetailsDataSet.BDF__c) : 0.00) / this.covDetailsDataSet.Volume__c) * 1000 * ((this.exchangeRate != null && this.exchangeRate != '') ? parseFloat(this.exchangeRate) : 0.00)).toFixed(4));
        }
       console.log("Amortization_Per_Unit__c ###",this.covDetailsDataSet.Amortization_Per_Unit__c);
        console.log("Purchase_Margin__c ####",(this.covDetailsDataSet.Purchase_Margin__c != null && this.covDetailsDataSet.Purchase_Margin__c != '' ? parseFloat(this.covDetailsDataSet.Purchase_Margin__c) : 0.00));
        console.log("Total_Sales_Margin__c ####",(this.covDetailsDataSet.Total_Sales_Margin__c != null && this.covDetailsDataSet.Total_Sales_Margin__c != '' ? parseFloat(this.covDetailsDataSet.Total_Sales_Margin__c) : 0.00));
        console.log("Transportation_Margin__c ####",(this.covDetailsDataSet.Transportation_Margin__c != null && this.covDetailsDataSet.Transportation_Margin__c != '' ? parseFloat(this.covDetailsDataSet.Transportation_Margin__c) : 0.00));
        console.log("exchange rate ####",(this.exchangeRate!= null && this.exchangeRate != '' ? parseFloat(this.exchangeRate) : 1.00));
        
        this.covDetailsDataSet.Unit_C3__c = parseFloat((((this.covDetailsDataSet.Purchase_Margin__c != null && this.covDetailsDataSet.Purchase_Margin__c != '' ? parseFloat(this.covDetailsDataSet.Purchase_Margin__c) : 0.00) + 
        (this.covDetailsDataSet.Total_Sales_Margin__c != null && this.covDetailsDataSet.Total_Sales_Margin__c != '' ? parseFloat(this.covDetailsDataSet.Total_Sales_Margin__c) : 0.00) + 
        (this.covDetailsDataSet.Transportation_Margin__c != null && this.covDetailsDataSet.Transportation_Margin__c != '' ? parseFloat(this.covDetailsDataSet.Transportation_Margin__c) : 0.00) + 
        (this.covDetailsDataSet.Amortization_Per_Unit__c != null && this.covDetailsDataSet.Amortization_Per_Unit__c != '' ? parseFloat(this.covDetailsDataSet.Amortization_Per_Unit__c) : 0.00))/(this.exchangeRate!= null && this.exchangeRate != '' ? parseFloat(this.exchangeRate) : 1.00)).toFixed(4));      // this.covDetailsDataSet.Unit_C3__c = (this.covDetailsDataSet.Purchase_Margin__c != null && this.covDetailsDataSet.Purchase_Margin__c != '' ? parseFloat(this.covDetailsDataSet.Purchase_Margin__c) : 0.00);
        
        console.log("Unit_C3__c ####",this.covDetailsDataSet.Unit_C3__c);
    }

    handlesave(event){
        var ds = this.covDetailsDataSet;
        console.log("this.covDetailsDataSet save..",JSON.stringify(ds));
        
       
            console.log(this.isNew);
            if(this.isNew){
               console.log("dssss",JSON.stringify(this.covDetailsDataSet));
               
                this.dispatchEvent(new CustomEvent("addcovamodataset",{detail:ds}));
            }else{
               
                var comdetailsval = {type:this.isNew, deailVals:ds,ind:this.isIndex};
                this.dispatchEvent(new CustomEvent("addupdatecovamodataset",{detail:comdetailsval}));
            }
        
        
    }
    showToast(title,variant,message) {
        const event = new ShowToastEvent({
            title: title,
            variant:variant,
            message: message
        });
        this.dispatchEvent(event);
    }
    showamort(){
       
        this.template.querySelector(".amort").className="amort slds-show";
    }
    calloutamortization(){
        this.template.querySelector(".amort").className="amort slds-hide";
               

    }
    callbdf(){
        console.log('hi');
        
        
        this.template.querySelector(".bdf").className="bdf slds-show";
    }
    calloutbdf(){
        this.template.querySelector(".bdf").className="bdf slds-hide";
               

    }
}