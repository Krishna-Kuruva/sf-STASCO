import { LightningElement,api,track } from 'lwc';     
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CustomOppDirect extends LightningElement {
    //Direct data from parent
    @api CustData=[];
    @track editDirect;
    @api approvebuttondirect;
    @api hidectrlbut;
    @api cbuoutput;
    @api loginuser
    @track testdisable=false;
    @track rerenderstatus=false;
    @track ShowEdit = false;
    @track spinnerLoad=false;
    @track spinnerMessage='';
    @track sortCustomerNameASC=true;


    editDirectdata(event) { 
        this.rerenderstatus=true; 
        this.ShowEdit = true;
        this.editDirect=this.getselecteddata(event.target.dataset.id);
    }
    getselecteddata(idseleted){
        var datafrom ;
        this.CustData.forEach(function(element, index){
            if(element.id === idseleted ){               
            datafrom=index;
            }
        }) 

        return  this.CustData[datafrom];
    }
 
    enableInlineEdit(event){
        var dataId;
        var cloneDirect =JSON.parse(JSON.stringify(this.CustData)) ;
        cloneDirect.forEach(function(element, index){
            if(element.id === event.target.dataset.id ){               
                element.inlineEdit=true;
            }
        })
        console.log('---datat--');
        this.CustData=cloneDirect;
    }
    cancelInline(event){
        var dataId;
        var dataIndex;
        var cloneDirect =JSON.parse(JSON.stringify(this.CustData)) ;
        cloneDirect.forEach(function(element, index){
            if(element.id === event.target.name ){               
                element.inlineEdit=false;
                dataIndex=index;
            }
        })
        console.log('---datat--');
        this.CustData=cloneDirect;
        var datatoParent=this.recalculateprice(this.CustData[dataIndex]);
        var details={data:datatoParent , actionOn:'UpdateData',action:''}     
        const selectedevent = new CustomEvent("changedirect", { detail:details });
        this.dispatchEvent(selectedevent); 
    }
    slectedcheckbox(event){
        var datafrom =JSON.parse(JSON.stringify(this.getselecteddata(event.target.name))); 
        datafrom.isChecked =event.target.checked;
        var details={data:datafrom , actionOn:'checkBox' ,action:event.target.checked}
        const selectedevent = new CustomEvent("changedirect", { detail: details });
        this.dispatchEvent(selectedevent); 
    }

    closeModal() {  
        this.rerenderstatus=false;
        this.ShowEdit = false;
    }


    finalPriceChange(event){
        console.log(JSON.stringify(event.target));
        let changeindata=event.target.name;
        var cloneDirect =JSON.parse(JSON.stringify(this.editDirect)) ;
        
        if(event.target.name ==='RE_Final_Price_Rebate__c'){
            cloneDirect.finalPrice=event.target.value;
            cloneDirect=this.recalculateprice(cloneDirect);
        }
        if(event.target.name ==='RE_Pricing_Level__c'){
            cloneDirect.pricingLevel=event.target.value;
            cloneDirect=this.recalculateprice(cloneDirect);
        }

        if(event.target.name ==='SubmitterComments')
            cloneDirect.submitterComments= event.target.value;

        if(event.target.name ==='ApproverComments')
            cloneDirect.approverComments=event.target.value;
            

        this.editDirect=cloneDirect;

        console.log('this.editDirect---'+JSON.stringify(this.editDirect));

    }

    @api recalculateprice(dataTocal){
        console.log('--inside cal--');
       
            if( dataTocal.calculationLogic === 'Tier Discount (Reseller)')
                dataTocal.tempDiscount = parseFloat(dataTocal.listPrice) - parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.tieredDiscount) + parseFloat(dataTocal.transportCharge) ;
            
           
            if(dataTocal.calculationLogic === 'Price Level (Direct without transport charge) - 1 week' || dataTocal.calculationLogic === 'Price Level (Direct without transport charge) - 2 days validity' )
                dataTocal.discount=Math.floor(parseFloat(dataTocal.listPrice)- parseFloat(dataTocal.finalPrice));
            
            if(dataTocal.calculationLogic === 'Price Level (Direct with transport charge) - 1 week' || dataTocal.calculationLogic === 'Price Level (Direct with transport charge) - Eff Sat to Fri' 
            || dataTocal.calculationLogic === 'Direct As Reseller Price Adjustment (with transport charge)')
                dataTocal.discount=Math.floor(parseFloat(dataTocal.listPrice)- parseFloat(dataTocal.finalPrice) + parseFloat(dataTocal.transportCharge));
            
            dataTocal.marginAboveLDC = parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.dfoaCharges) - parseFloat(dataTocal.rebate) - parseFloat(dataTocal.bdf) - parseFloat(dataTocal.RE_CBU_LDC);
            dataTocal.marginAboveMC = parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.dfoaCharges) - parseFloat(dataTocal.rebate) - parseFloat(dataTocal.bdf) - parseFloat(dataTocal.cbuMC);
            dataTocal.forecastMarginAboveLDC = parseFloat(dataTocal.marginAboveLDC) - parseFloat(dataTocal.RE_Afternoon_Indication);
            dataTocal.forecastMarginAboveMC = parseFloat(dataTocal.marginAboveMC)- parseFloat(dataTocal.RE_Afternoon_Indication); 
          
        return dataTocal;

    }
    renderedCallback(){

        if(this.rerenderstatus){      
            var editablefields= this.editDirect.fields;
            var fields = editablefields.split(';');  
        this.template.querySelectorAll('lightning-input').forEach(comboname => {
            if(fields.includes(comboname.name)){
                console.log('this.approvebuttondirect--'+this.approvebuttondirect);
                console.log('this.editDirect.recordMode--'+this.editDirect.recordMode);

                if(!this.approvebuttondirect)
                    comboname.disabled=(this.editDirect.recordMode  ? false : true);                
                else   
                    comboname.disabled=true;  
                }  
                console.log('combination--'+comboname.disabled);        
            });
        }
    }

    finalPricechangeinLine(event){
        var editedId=event.target.name;
        var changedValue=event.target.value;
        var dataIndex;
        var clonedata = JSON.parse(JSON.stringify(this.CustData)) ;
        clonedata.forEach(function(element, index){
            if(element.id === editedId){                
                element.finalPrice=changedValue;
                dataIndex=index;
            }
        });
        this.CustData=clonedata;
        var datatoParent=this.recalculateprice(this.CustData[dataIndex]);
        var details={data:datatoParent , actionOn:'UpdateData',action:''}     
        const selectedevent = new CustomEvent("changedirect", { detail:details });
        this.dispatchEvent(selectedevent); 

    }
    pricecLevel(event){
        var editedId=event.target.name;
        var changedValue=event.target.value;
        var dataIndex;
        var clonedata = JSON.parse(JSON.stringify(this.CustData)) ;
        clonedata.forEach(function(element, index){
            if(element.id === editedId){                
                element.pricingLevel=changedValue;
                dataIndex=index;
            }
        });
        this.CustData=clonedata;
        var datatoParent=this.recalculateprice(this.CustData[dataIndex]);
        var details={data:datatoParent , actionOn:'UpdateData',action:''}     
        const selectedevent = new CustomEvent("changedirect", { detail:details });
        this.dispatchEvent(selectedevent); 

    }

    saveandClose(){
        this.rerenderstatus=false;
        this.ShowEdit = false;
        //var oldvalue=this.getselecteddata(this.editDirect.id);
       // if(oldvalue.finalPrice != this.editDirect.finalPrice ||  oldvalue.pricingLevel != this.editDirect.pricingLevel ){
       //     savedata({dataTosave : this.editDirect})
       //     .then(result => {
       //         this.editDirect=result;
                var details={data:this.editDirect , actionOn:'UpdateData',action:''}     
                const selectedevent = new CustomEvent("changedirect", { detail:details });
                this.dispatchEvent(selectedevent); 
                this.loadSpinner(false, 'Updating..');
        //    })
       /*  .catch(error =>{ 
                console.log('error--'+JSON.stringify(error));
                this.loadSpinner(false, 'Updating..');
                this.showToast('error','error occured',error.body.message);
            })

        }*/

    }

    handleselectAllData(event){
        var clonedata = JSON.parse(JSON.stringify(this.CustData)) ;
        var loginuserDetail=this.loginuser;
        clonedata.forEach(function(element, index){
            //if(loginuserDetail === 'Customer Opps Team' && element.approveStatus === 'NS')
            if( !loginuserDetail && element.approveStatus === 'NS')
                element.isChecked = event.target.checked;
            if((loginuserDetail ) && (element.approveStatus === 'SB' || element.approveStatus === 'SS' || element.approveStatus === 'SP'))
                element.isChecked = event.target.checked;
        });
        this.CustData = clonedata;

        var details={data:'' , actionOn:'AllCheckBox',action:event.target.checked}     
        const selectedevent = new CustomEvent("changedirect", { detail: details});
        this.dispatchEvent(selectedevent); 
    }

    connectedCallback(){

    }
    //Sort for Sold To Name, Ship To Name ,Product, Location 
    changeSortchar(event){
        this.loadSpinner(true, 'Sorting...');
        let sortCol=event.target.dataset.targetId;
        new Promise(
            (resolve,reject) => {
              setTimeout(()=> {
                if(this.sortCustomerNameASC){
                    this.CustData= this.sortchildData(sortCol,'desc',this.CustData);
                    this.sortCustomerNameASC=false;
                }
                else{
                    this.CustData= this.sortchildData(sortCol,'asc',this.CustData);
                    this.sortCustomerNameASC=true;
                }
                this.loadSpinner(false, 'Sorting...');
                resolve();
              }, 0);
          }).then(
             
          );
       
    }
    // sort function on charater
    sortchildData(fieldName, sortDirection,dataToSort){
        var data = JSON.parse(JSON.stringify(dataToSort));
        //function to return the value stored in the field
        var key =(a) => a[fieldName]; 
        var reverse = sortDirection === 'asc' ? 1: -1;
        data.sort((a,b) => {
            let valueA = key(a) ? key(a).toLowerCase() : '';
            let valueB = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((valueA > valueB) - (valueB > valueA));
        });

        return data;
    }

    //Sort for Sold-To , Ship To,Marg LDC, Marg MC, FCM LDC and FCM MC
    changesortNumber(event){
        this.loadSpinner(true, 'Sorting...');
        let sortCol=event.target.dataset.targetId;
        new Promise(
            (resolve,reject) => {
             setTimeout(()=> {
                if(this.sortAscOrDesc){
                    this.CustData= this.sortNumber(sortCol,'desc',this.CustData);
                    this.sortAscOrDesc=false;
                }
                else{
                    this.CustData= this.sortNumber(sortCol,'asc',this.CustData);
                    this.sortAscOrDesc=true;
                }
                this.loadSpinner(false, 'Sorting...');
                resolve();
              }, 0);
          }).then(

            );
        
    }
    // sort function on Number
    sortNumber(fieldName, sortDirection,dataToSort){
        var data = JSON.parse(JSON.stringify(dataToSort));
        //function to return the value stored in the field
        var key =(a) => a[fieldName]; 
        var reverse = sortDirection === 'asc' ? 1: -1;
        data.sort((a,b) => {
            let valueA = key(a) ? parseFloat(key(a).toLowerCase()) : 0.00;
            let valueB = key(b) ? parseFloat(key(b).toLowerCase()) : 0.00;
            return reverse * ((valueA > valueB) - (valueB > valueA));
        });

        return data;
    }

    loadSpinner(load, msg)
    {
        if(load)
        {
            this.spinnerLoad = true;
            this.spinnerMessage = msg;
        }
        else
            this.spinnerLoad = false;
    }

   showToast(type,msgtitle,msg)
   {
       const evt = new ShowToastEvent({
           title: msgtitle,
           message: msg,
           variant: type,
           mode: 'dismissable'
       });
       this.dispatchEvent(evt);
   }

}