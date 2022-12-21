import { LightningElement,api,track } from 'lwc';    
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CustomOppDirect extends LightningElement {
    //Reseller data from parent
    @api CustData=[];

    @track editReseller;
    @api approvebutton;
    @api hidectrlbut;
    @api cbuoutput;
    @api loginuser;
    @track chCustData = [];
    @track rerenderstatus=false;
    @track spinnerLoad=false;
    @track spinnerMessage='';
    @track sortAscOrDesc=true;

    @track ShowEdit = false;

    editResellerdata(event) {  
        this.rerenderstatus=true;
        this.ShowEdit = true;
        this.editReseller=this.getselecteddata(event.target.dataset.id);        
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
        var cloneReseller =JSON.parse(JSON.stringify(this.CustData)) ;
        cloneReseller.forEach(function(element, index){
            if(element.id === event.target.dataset.id ){               
                element.inlineEdit=true;
            }
        })
        console.log('---datat--');
        this.CustData=cloneReseller;
    }
    cancelInline(event){
        var dataId;
        var dataIndex;
        var cloneReseller =JSON.parse(JSON.stringify(this.CustData)) ;
        cloneReseller.forEach(function(element, index){
            if(element.id === event.target.name ){               
                element.inlineEdit=false;
                dataIndex=index;
            }
        })
        console.log('---datat--');
        this.CustData=cloneReseller;
        var datatoParent=this.recalculateprice(this.CustData[dataIndex]);
        var details={data:datatoParent , actionOn:'UpdateData',action:''}     
        const selectedevent = new CustomEvent("changeseller", { detail:details });
        this.dispatchEvent(selectedevent); 
    }
    slectedcheckbox(event){
        var datafrom =JSON.parse(JSON.stringify(this.getselecteddata(event.target.name))); 
        datafrom.isChecked =event.target.checked;
        var details={data:datafrom , actionOn:'checkBox' ,action:event.target.checked}
        const selectedevent = new CustomEvent("changeseller", { detail: details });
        this.dispatchEvent(selectedevent); 
    }
    closeModal() {  
        this.rerenderstatus=false;
        this.ShowEdit = false;
    }

    pricechange(event){
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
        const selectedevent = new CustomEvent("changeseller", { detail:details });
        this.dispatchEvent(selectedevent); 

    }

    finalPriceChange(event){
        let changeindata=event.target.name;
        var cloneReseller =JSON.parse(JSON.stringify(this.editReseller)) ;
       
        if(event.target.name ==='RE_Final_Price_Rebate__c'){
            cloneReseller.finalPrice=event.target.value;
            cloneReseller=this.recalculateprice(cloneReseller);
        }
        if(event.target.name ==='SubmitterComments')
            cloneReseller.submitterComments= event.target.value;

        if(event.target.name ==='ApproverComments')
            cloneReseller.approverComments=event.target.value;
        
        console.log(JSON.stringify(cloneReseller));


        this.editReseller=cloneReseller;
    }

   @api recalculateprice(dataTocal){
        console.log('--inside cal--');
        /*if(dataTocal.calculationLogic === 'Direct Price Level Adjustment'){
            dataTocal.marginAboveLDC=parseFloat(dataTocal.listPrice)+parseFloat(dataTocal.transportCharge) -parseFloat(dataTocal.dfoaCharges)- parseFloat(dataTocal.RE_CBU_LDC);
            dataTocal.marginAboveMC=parseFloat(dataTocal.listPrice)+parseFloat(dataTocal.transportCharge) - parseFloat(dataTocal.dfoaCharges) - parseFloat(dataTocal.cbuMC);
            dataTocal.forecastMarginAboveLDC=parseFloat(dataTocal.marginAboveLDC) - parseFloat(dataTocal.RE_Afternoon_Indication);
            dataTocal.forecastMarginAboveMC=parseFloat(dataTocal.marginAboveMC)- parseFloat(dataTocal.RE_Afternoon_Indication);  

            dataTocal.discount =  Math.floor(parseFloat(dataTocal.forecastMarginAboveLDC) -  parseFloat(dataTocal.pricingLevel));
            dataTocal.finalPrice= parseFloat(dataTocal.listPrice)- parseFloat(dataTocal.discount);
            }
        else{*/
            if(dataTocal.calculationLogic === 'Reseller Final Price Adjustment' || dataTocal.calculationLogic === 'Direct As Reseller Price Adjustment' || dataTocal.calculationLogic === 'Tier Discount (Reseller)'){
                dataTocal.tempDiscount = parseFloat(dataTocal.listPrice) - parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.tieredDiscount) + parseFloat(dataTocal.transportCharge) ;
                }
           
            if(dataTocal.calculationLogic === 'Direct Final Price Adjustment' || dataTocal.calculationLogic === 'Direct Price Level Adjustment' || 
                dataTocal.calculationLogic === 'Price Level (Direct without transport charge) - 1 week' || dataTocal.calculationLogic === 'Price Level (Direct without transport charge) - 2 days validity' )
                dataTocal.discount=Math.floor(parseFloat(dataTocal.listPrice)- parseFloat(dataTocal.finalPrice));
            
            if(dataTocal.calculationLogic === 'Price Level (Direct with transport charge) - 1 week')
                dataTocal.discount=Math.floor(parseFloat(dataTocal.listPrice)- parseFloat(dataTocal.finalPrice) + parseFloat(dataTocal.transportCharge));
            
            dataTocal.marginAboveLDC = parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.dfoaCharges) - parseFloat(dataTocal.rebate) - parseFloat(dataTocal.bdf) - parseFloat(dataTocal.RE_CBU_LDC);
            dataTocal.marginAboveMC = parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.dfoaCharges) - parseFloat(dataTocal.rebate) - parseFloat(dataTocal.bdf) - parseFloat(dataTocal.cbuMC);
            dataTocal.forecastMarginAboveLDC = parseFloat(dataTocal.marginAboveLDC) - parseFloat(dataTocal.RE_Afternoon_Indication);
            dataTocal.forecastMarginAboveMC = parseFloat(dataTocal.marginAboveMC)- parseFloat(dataTocal.RE_Afternoon_Indication); 
            
            
       // }
        
        return dataTocal;

    }
    
    renderedCallback(){

        if(this.rerenderstatus){      
            var editablefields= this.editReseller.fields;
            var fields = editablefields.split(';');  
        this.template.querySelectorAll('lightning-input').forEach(comboname => {
            if(fields.includes(comboname.name)){
                if(!this.approvebutton)
                    comboname.disabled=(this.editReseller.recordMode  ? false : true);
                else   
                comboname.disabled=true;
            }            
            });
        }
    }

    
    saveandClose(){
        this.loadSpinner(true, 'Updating..');
        this.rerenderstatus=false;
        this.ShowEdit = false;  
        var oldvalue=this.getselecteddata(this.editReseller.id);
       // if(oldvalue.finalPrice != this.editReseller.finalPrice ){
            //savedata({dataTosave : this.editReseller})
           // .then(result => {
                //this.editReseller=result;
                var details={data:this.editReseller , actionOn:'UpdateData',action:''}     
                const selectedevent = new CustomEvent("changeseller", { detail:details });
                this.dispatchEvent(selectedevent); 
                this.loadSpinner(false, 'Updating..');
            //})
            //.catch(error =>{ 
            //    console.log('error--'+JSON.stringify(error));
            //    this.loadSpinner(false, 'Updating..');
            //    this.showToast('error','error occured',error.body.message);
            //})

       // }
    }

    handleselectAllData(event){
        var clonedata = JSON.parse(JSON.stringify(this.CustData)) ;
        console.log('---user in Reseller --'+this.loginuser)
        var loginuserDetail=this.loginuser;

        clonedata.forEach(function(element, index){
            //if(loginuserDetail === 'Customer Opps Team' && element.approveStatus === 'NS')
            if( !loginuserDetail && element.approveStatus === 'NS')
                element.isChecked = event.target.checked;
           // if((loginuserDetail === 'Customer Opps Approver 1' || loginuserDetail === 'Customer Opps Approver 2') && (element.approveStatus === 'SB' || element.approveStatus === 'AP' || element.approveStatus === 'RJ'))
            if((loginuserDetail ) && (element.approveStatus === 'SB' || element.approveStatus === 'SS' || element.approveStatus === 'SP'))
                element.isChecked = event.target.checked;
        });
        this.CustData = clonedata;

        var details={data:'' , actionOn:'AllCheckBox',action:event.target.checked}     
        const selectedevent = new CustomEvent("changeseller", { detail: details});
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
                if(this.sortAscOrDesc){
                    this.CustData= this.sortchildData(sortCol,'desc',this.CustData);
                    this.sortAscOrDesc=false;
                }
                else{
                    this.CustData= this.sortchildData(sortCol,'asc',this.CustData);
                    this.sortAscOrDesc=true;
                }
                 resolve();
                 this.loadSpinner(false, 'Sorting...');
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
                resolve();
                this.loadSpinner(false, 'Sorting...');

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