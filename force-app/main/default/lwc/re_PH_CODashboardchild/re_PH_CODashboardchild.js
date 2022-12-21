import { LightningElement,api,track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Re_PH_CODashboardchild extends LightningElement {
    //Data from parent object
    @api customerdata=[];
    @api approvebutton;
    @api hidectrlbut;
    @track editDirect;
    @track testdisable=false;
    @track rerenderstatus=false;
    @track ShowEdit = false;
    @track spinnerLoad=false;
    @track spinnerMessage='';
    @track sortCustomerNameASC=true;
    isAPM;
    isGPC;
    isRPG;
    isMan;
    ispriceSupport = false;
    isValidFrom = false;
    isValidTo = false;
    isoldpsdate = false;
    isvaliddate = false;
    isapproved;
    isuploaded;
    selectedId;
    @api CustData=[];
    @api isolddate;
    @api loginuser;
    className = 'class2';
    isProperDecimal = true;
    @track directDetail;

    get refoptions() {
        return [
            { label: 'W-1', value: 'W-1' },
            { label: 'M-1', value: 'M-1' },
            { label: 'D-1', value: 'D-1' },
        ];
    }
    @api refreshdata(customerdata) {
        this.isProperDecimal = true;
        if(customerdata && customerdata.length > 0)
        this.customerdata = JSON.parse(JSON.stringify(customerdata));
        this.CustData = this.customerdata;
        var divblock = this.template.querySelector('[data-id="divblock"]');
        if(divblock && !this.ShowEdit){
            this.template.querySelector('[data-id="divblock"]').className='class2';
        }
        else if(divblock && this.ShowEdit){
            this.template.querySelector('[data-id="divblock"]').className='class1';
            console.log('--this.selectedId--'+this.selectedId);
            //console.log('--this.CustData--'+JSON.stringify(this.CustData));
            this.editDirect = this.fetchcontractData(this.selectedId);
            console.log('--this.editDirect--'+JSON.stringify(this.editDirect));
            this.editDetail();
        }
    }

    //init method
    connectedCallback(){
      

    }

    editDirectdata(event) {
        this.isProperDecimal = true;
        if(this.editDirect == this.getselecteddata(event.target.dataset.id) && this.ShowEdit)
            this.closeModal();
        else{
            this.isAPM = false;
            this.isGPC = false;
            this.isRPG = false;
            this.isMan = false;
            this.isapproved = false;
            this.isuploaded = false;
            var divblock = this.template.querySelector('[data-id="divblock"]');
            if(divblock){
                this.template.querySelector('[data-id="divblock"]').className='class1';
            }
            this.rerenderstatus=true;
            this.ShowEdit =  true;
            this.editDirect=this.getselecteddata(event.target.dataset.id);
            this.directDetail=this.getselecteddata(event.target.dataset.id);
            this.editDetail();
        }
    }

    editDetail(){
        switch(this.editDirect.calcmethod){
            case "Aspired Margin" :
                this.isAPM = true;
                break;
            case "RPG" :
                this.isRPG = true;
                break;
            case "GPC" :
                this.isGPC = true;
                break;
            case "Manual" :
                this.isMan = true;
                break;
            default :
                this.isAPM = false;
                this.isGPC = false;
                this.isRPG = false;
                this.isMan = false;
        }
        this.selectedId = this.editDirect.contractID;
        if(this.editDirect.approveStatus == "AA" || this.editDirect.approveStatus == "AP"){
            this.isapproved = true;
        }
        else
        if(this.editDirect.approveStatus == "UP"){
            this.isapproved = true;
            this.isuploaded = true;
        }
        else{
            this.isapproved = false;
            this.isuploaded = false;
        }
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
    fetchcontractData(contractId){
        var datafrom ;
        this.CustData.forEach(function(element, index){
            if(element.contractID === contractId ){
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
        /*var dataIndex;
        var cloneDirect =JSON.parse(JSON.stringify(this.CustData)) ;
        cloneDirect.forEach(function(element, index){
            if(element.id === event.target.name ){               
                element.inlineEdit=false;
                dataIndex=index;
            }
        })
        console.log('---datat--');
        this.CustData=cloneDirect;*/
        //var datatoParent=this.recalculateprice(this.CustData[dataIndex]);
        var datatoParent = this.editDirect;
        var details={data:datatoParent , actionOn:'UpdateData',action:''}
        console.log('---datat--'+JSON.stringify(details));     
        const selectedevent = new CustomEvent("changeseller", { detail:details });
        this.dispatchEvent(selectedevent); 
    }
    slectedcheckbox(event){
        var datafrom =JSON.parse(JSON.stringify(this.getselecteddata(event.target.name))); 
        console.log(JSON.stringify(datafrom));
        datafrom.isChecked =event.target.checked;
        var details={data:datafrom , actionOn:'checkBox' ,action:event.target.checked}
        const selectedevent = new CustomEvent("changeseller", { detail: details });
        this.dispatchEvent(selectedevent); 
    }
    @api closeModal() {
        var divblock = this.template.querySelector('[data-id="divblock"]');
        if(divblock){
            this.template.querySelector('[data-id="divblock"]').className='class2';
        }
        this.rerenderstatus=false;
        this.ShowEdit = false;
    }
    finalPriceChange(event){
        this.ispriceSupport = false;
        this.isValidFrom = false;
        this.isValidTo = false;
        var cloneDirect =JSON.parse(JSON.stringify(this.editDirect)) ;
        console.log('--cloneDirect--'+JSON.stringify(cloneDirect));
        if(event.target.name ==='RE_Final_Price_Rebate__c'){
            const numStr = String(event.target.value);
            if(numStr.includes('.') ){
                if(numStr.split('.')[1].length >= 4 ){
                    cloneDirect.finalPrice=event.target.value;
                    if(cloneDirect.calcmethod == "Aspired Margin"){
                        cloneDirect.uc3M_1 = parseFloat(cloneDirect.finalPrice) - parseFloat(cloneDirect.exgM_1) - parseFloat(cloneDirect.transportCharge) - parseFloat(cloneDirect.exciseTax) ;
                        cloneDirect.uc3MTD = parseFloat(cloneDirect.finalPrice) - parseFloat(cloneDirect.exgMTD) - parseFloat(cloneDirect.transportCharge) - parseFloat(cloneDirect.exciseTax) ;
                        cloneDirect.uc3WTD = parseFloat(cloneDirect.finalPrice) - parseFloat(cloneDirect.exgWTD) - parseFloat(cloneDirect.transportCharge) - parseFloat(cloneDirect.exciseTax) ;
                        cloneDirect.uc3D_1 = parseFloat(cloneDirect.finalPrice) - parseFloat(cloneDirect.exgD_1) - parseFloat(cloneDirect.transportCharge) - parseFloat(cloneDirect.exciseTax) ;
                        cloneDirect.uc3W_1 = parseFloat(cloneDirect.finalPrice) - parseFloat(cloneDirect.exgW_1) - parseFloat(cloneDirect.transportCharge) - parseFloat(cloneDirect.exciseTax) ;
                    }
                    else
                        cloneDirect=this.recalculateprice(cloneDirect);
                    this.isProperDecimal = true;
                }
                else
                    this.isProperDecimal = false;
            }
            else{
                this.isProperDecimal = true;
                cloneDirect.finalPrice=event.target.value;
                cloneDirect=this.recalculateprice(cloneDirect);
            }
        }
        if(event.target.name ==='RE_Submitter_Comments__c'){
            cloneDirect.submitterComments = event.target.value;
        }
        if(event.target.name === 'RE_Reference_Period__c'){
            cloneDirect.refperiod = event.target.value;
        }
        if(event.target.name === 'RE_Price_support__c'){
            cloneDirect.priceSupport = event.target.value;
            if(cloneDirect.calcmethod != "Aspired Margin"){
                cloneDirect=this.recalculateprice(cloneDirect);
            }
            console.log('cloneDirect.psEndDate--'+cloneDirect.psEndDate);
            if(cloneDirect.psEndDate == '' || cloneDirect.psEndDate == undefined ){
                console.log('inside if')
                this.ispriceSupport = true;
            }
            else
                this.ispriceSupport = false;

        }
        if(event.target.name === 'RE_PS_valid_from__c'){
            var selecteddate = new Date(event.target.value).toISOString().slice(0, 10);
            var todayDate = new Date().toISOString().slice(0, 10);
            console.log('selecteddate--'+selecteddate);
            console.log('todayDate--'+todayDate);
            if(selecteddate >= todayDate){
                console.log('inside if');
                this.isoldpsdate = false;
                cloneDirect.psStartDate = event.target.value;
                if(cloneDirect.psEndDate === '' || cloneDirect.psEndDate === undefined)
                    this.isValidFrom = true;sa
            }
            else{
                console.log('inside else');
                this.isoldpsdate = true;
            }
        }
        if(event.target.name === 'RE_PS_valid_to__c'){
            var selecteddate = new Date(event.target.value).toISOString().slice(0, 10);
            var todayDate = new Date().toISOString().slice(0, 10);
            if(selecteddate >= todayDate){
                console.log('inside if');
                this.isoldpsdate = false;
                cloneDirect.psEndDate = event.target.value;
            }
            else{
                this.isoldpsdate = true;
            }
        }
        this.editDirect=JSON.parse(JSON.stringify(cloneDirect));
        console.log('this.editDirect---'+JSON.stringify(this.editDirect));
    }

     cancelDetail()
    {
        this.editDirect       = this.directDetail ;
        this.cancelInline();
    }

    saveDetail()
    {
        var details={data:this.editDirect , idChanged:this.editDirect.id}   
        const selectedevent = new CustomEvent("savedetail", { detail:details });
        this.dispatchEvent(selectedevent); 
    }

    @api recalculateprice(dataTocal){
        console.log('--inside cal--'+dataTocal);
        dataTocal.uc3M_1 = parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.exgM_1) - parseFloat(dataTocal.transportCharge) - parseFloat(dataTocal.exciseTax) + parseFloat(dataTocal.priceSupport);
        dataTocal.uc3MTD = parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.exgMTD) - parseFloat(dataTocal.transportCharge) - parseFloat(dataTocal.exciseTax) + parseFloat(dataTocal.priceSupport);
        dataTocal.uc3WTD = parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.exgWTD) - parseFloat(dataTocal.transportCharge) - parseFloat(dataTocal.exciseTax) + parseFloat(dataTocal.priceSupport);
        dataTocal.uc3D_1 = parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.exgD_1) - parseFloat(dataTocal.transportCharge) - parseFloat(dataTocal.exciseTax) + parseFloat(dataTocal.priceSupport);
        dataTocal.uc3W_1 = parseFloat(dataTocal.finalPrice) - parseFloat(dataTocal.exgW_1) - parseFloat(dataTocal.transportCharge) - parseFloat(dataTocal.exciseTax) + parseFloat(dataTocal.priceSupport);
        return dataTocal;
    }
    renderedCallback(){
        /*if(this.rerenderstatus){      
            var editablefields= this.editDirect.fields;
            console.log('--this.editDirect--'+JSON.stringify(this.editDirect));
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
        }*/
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
        const selectedevent = new CustomEvent("changeseller", { detail:details });
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
                const selectedevent = new CustomEvent("changeseller", { detail:details });
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
        const selectedevent = new CustomEvent("changeseller", { detail: details});
        this.dispatchEvent(selectedevent); 
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