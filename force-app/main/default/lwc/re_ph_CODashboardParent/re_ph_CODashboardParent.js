import { LightningElement,track,api,wire } from 'lwc'; 
import getDatefilter from '@salesforce/apex/RE_PHCustomerDashboard.getFilteredDate';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import RE_PH_Resource from '@salesforce/resourceUrl/RE_PH_Customer_Opps';
import saveToDatabase from '@salesforce/apex/RE_PHCustomerDashboard.savePricebook';
import submitForApprove from '@salesforce/apex/RE_PHCustomerDashboard.submitforApproval';
import ApprovalProcess from '@salesforce/apex/RE_PHCustomerDashboard.approveReject'; 
import {exportCSVFile} from 'c/re_csvgenerator';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import fetchuserdata from '@salesforce/apex/RE_PHCustomerDashboard.fetchuserdata';
import generateCustData from '@salesforce/apex/RE_PHCustomerDashboard.generateCustomOppdataData';
import generatemidWeekdata from '@salesforce/apex/RE_PH_RPG.midWeekRgpdatagene';
import newContractCustomerOpps from '@salesforce/apex/RE_PHCustomerDashboard.checkNewContractData';
import exportReport from '@salesforce/apex/RE_PHCustomerDashboard.exportReport';
import  exportButtonContr  from '@salesforce/apex/RE_PHCustomerDashboard.exportButtonContr';
import { NavigationMixin } from 'lightning/navigation';

export default class Re_ph_CODashboardParent extends NavigationMixin(LightningElement)  {
    @track spinnerLoad=false;
    @track spinnerMessage='';

    @track advanceOption = false;
    //To display publish date of CBU
    @track cbupublishDate;
    //Check dahboard is View only
    @track hideCtrltBut = false;

    //controls Submit for approval and Approve/Reject button
    @track isApprover;

    //export button control
    @track exportButton = true;
    @track retryButton = true;

    //export button track
     @track exportBackup = true ;
     @track retryBackup = true;

    //control Filter 
    @track showPageHeader

    //Filtered Data to child component
    @track dataToChild = [];

    //Main data from data base
    @track mainData = [];

    //contains checkbox to Approve or Reject Records
    @track checkboxList=[];
    //Login User is Approver or Not
    @track loginuser='';

    //Filter values
    //holds the current values for picklist
    @track plantList = [];
    @track material = [];
    @track customerName = [];
    @track soldTo = [];
    @track amcode = [];
    @track calculationMod = [];
    @track statusFilter = [];

    //Filter initial values 
    //holds the current value selected in picklist
    @track trackFilterplant='All';
    @track trackFilterMat='All';
    @track trackSoldto='All';
    @track trackAMcode='All';
    @track trackStatus='All';
    @track trackCalModel='All';
    @track selectedcustomerName=[];
    @track resetFilter = false;
    isolddate = false;
    //date filter value
    @track dateFilterValue;
    userselcted;
    userlist = [];
    trackuser;

    updatePrice = false;
    globalValidFrom;
    globalValidDate;
    validFromMin;
    validFromMax;
    ValidToCheckBox;
    ValidFromCheckBox;
    validToMin;
    validToMax;
    globalrefperiod;
    refperCheckBox;

    get refoptions() {
        return [
            { label: 'W-1', value: 'W-1' },
            { label: 'M-1', value: 'M-1' },
            { label: 'D-1', value: 'D-1' },
        ];
    }
    //Init Method Declaration
    connectedCallback() {
        fetchuserdata()
        .then(result=>{
           this.userlist = result.userList;
           this.isApprover = result.isApprover;
           this.userselcted = false;
        })
        .catch(error=>{
          console.log('error occured');
          this.showToast('error','error occured',error.body.message);
        })
        var newDate= new Date();
        newDate.setDate(newDate.getDate());
        let year= ''+newDate.getFullYear();
        let month=''+ (newDate.getMonth() + 1);
        let day=''+newDate.getDate();
        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;
        this.nextdate=year+'-'+ month +'-'+day;
        this.validFromMin = this.nextdate;
        this.validToMin = this.nextdate;
        this.validFromMax = '2050-12-31';
        this.validToMax = '2050-12-31';
    }

    selectuser(event){
        this.trackuser = event.detail.value;
    }

    opendashboard(){
        this.userselcted = true;
        this.loadSpinner(true, 'Loading data');
        //Column in Download files stored in Static resource
        let request = new XMLHttpRequest();
        request.open("GET", RE_PH_Resource, false);
        request.send(null);
        var jsonToShow = request.responseText;
        this.headers = JSON.parse(jsonToShow);
        //Defalut date is Todays
        var newDate= new Date();
        let year= ''+newDate.getFullYear();
        let month=''+ (newDate.getMonth() + 1);
        let day=''+newDate.getDate();
        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;
        var defaultdate = year+'-'+ month +'-'+day;
        this.dateFilterValue = defaultdate;
       getDatefilter({datefilter : defaultdate , CalculationModel :'', userfilter : this.trackuser})
       .then(result=>{
           console.log('initial load--'+JSON.stringify(result));
            if(result.reseller.resellerdata.length != 0){
                this.cbupublishDate = result.cubpublishDate;
                this.plantList = result.reseller.plant ;
                this.material = result.reseller.Material;
                this.customerName = result.reseller.customerName ;
                this.soldTo = result.reseller.soldTo ;
                this.amcode = result.reseller.amCode ;
                this.calculationMod = result.reseller.CalMod ;
                this.statusFilter = result.reseller.status;
                var sortData =  this.sortchildData('customerName','asc',result.reseller.resellerdata);
                this.dataToChild = JSON.parse(JSON.stringify(sortData));
                this.mainData = JSON.parse(JSON.stringify(sortData));
                this.loginuser=result.isApprover;
                this.isApprover = result.isApprover;
            }
            else{
               this.showToast('warning','No Contract Data','No Contract present under your name');
            }
            this.loadSpinner(false, 'Loading is done');
       })
       .catch(error=>{
           console.log('error occured');
           this.showToast('error','error occured',error.body.message);
           this.loadSpinner(false, 'error occured');

       })
    }
    closePopUp(){
        this.userselcted = true;
        this.showToast('error','No user selected');
    }
    filterBasedOnDate(event){
        this.dateFilterValue=event.target.value;
        var selecteddate = new Date(this.dateFilterValue).toISOString().slice(0, 10);
        console.log(selecteddate);
        var todayDate = new Date().toISOString().slice(0, 10);
        console.log(todayDate);
        this.isolddate = selecteddate<todayDate ? true : false;
        if(this.isolddate){
            this.exportButton = true;
            this.retryButton = true;
        }
        else{
            console.log('inside enable--');
            this.exportButton = this.exportBackup;
            this.retryButton = this.retryBackup;
        }
        console.log('isolddate--->'+this.isolddate);
        this.loadSpinner(true, 'Loading ');
        getDatefilter({datefilter : this.dateFilterValue , CalculationModel :'', userfilter : this.trackuser})
       .then(result=>{
           this.cbupublishDate = result.cubpublishDate;
           this.plantList = result.reseller.plant ;
           this.material = result.reseller.Material;
           this.customerName = result.reseller.customerName ;
           this.soldTo = result.reseller.soldTo ;
           this.amcode = result.reseller.amCode ;
           this.calculationMod = result.reseller.CalMod ;
           this.statusFilter = result.reseller.status;
           var sortData =  this.sortchildData('customerName','asc',result.reseller.resellerdata);
           this.dataToChild = JSON.parse(JSON.stringify(sortData));
           this.mainData = JSON.parse(JSON.stringify(sortData));
           this.loginuser=result.isApprover;
           this.isApprover = result.isApprover;
           this.filterdatatoChild();
           this.loadSpinner(false, 'Loading is done');
       })
       .catch(error=>{
           console.log('error occured');
           this.showToast('error','error occured',error.body.message);
           this.loadSpinner(false, 'error occured');

       })
    }
    //Filter the data
    CustomerTypeFilter(event){
        console.log('--name--'+event.target.value);
        this.loadSpinner(true, 'Filtering..');
        var eventName=event.target.name;
        this.checkboxList=[];
        new Promise(
            (resolve,reject) => {
              setTimeout(()=> {        
    
            //update the latest value in plant filter
             if(eventName === 'Plant')
                this.trackFilterplant=event.detail.value;  

            //update the latest value in Material filter
            if(eventName === 'Material')
                this.trackFilterMat=event.detail.value;   

            //update the latest value in AMCode filter
            if(eventName === 'AMCode')
                this.trackAMcode=event.detail.value;

            //update the latest value in Soldto filter        
            if(eventName === 'Soldto')
                this.trackSoldto=event.detail.value;

            //update the latest value in status filter
            if(eventName === 'Status')
                this.trackStatus=event.detail.value;

            //update the latest value in Calculation model
            if(eventName === 'calmodel')
                this.trackCalModel=event.detail.value;
            
            //recheck the filtered data
            this.filterdatatoChild();

            this.loadSpinner(false, 'Filtering');

                resolve();
              }, 0);
          }).then(   );
    }

    //Filter the data based on customer selected
    customerSelected(event){
        console.log('selected customer--'+JSON.stringify(event.detail));
        this.loadSpinner(true, 'Filtering');
        new Promise(
            (resolve,reject) => {
            setTimeout(()=> {
                this.selectedcustomerName=event.detail;
                this.filterdatatoChild();
                console.log('selected customer --'+this.selectedcustomerName);
                this.loadSpinner(false, 'Filtering');
                resolve();
            }, 0);
        }).then(  );        
    }

     //Filter the data
     filterdatatoChild(){
        console.log('inside filter data---');
        var localdata=[];       
            if(this.trackFilterplant === 'All' && this.trackFilterMat === 'All' && this.trackAMcode == 'All' && this.trackSoldto == 'All' && this.trackStatus == 'All' && this.selectedcustomerName.length === 0 && this.trackCalModel == 'All'){
                this.dataToChild =JSON.parse(JSON.stringify(this.mainData));
            }
            else
            {
                console.log('inside filter not equal--')
                this.dataToChild =[];  
                localdata=JSON.parse(JSON.stringify(this.mainData));
                this.dataToChild = JSON.parse(JSON.stringify(this.checkOtherfiltes(localdata)));  
            }
            
            console.log('data to child-'+JSON.stringify(this.dataToChild));
            const childcomp = this.template.querySelector('c-re_-P-H_-C-O-Dashboardchild');
            childcomp.closeModal();
    }

    //This method will check all the filters once the value changed in any one of the filters
    checkOtherfiltes(localdata ){
        var plantfilter=this.trackFilterplant;
        var material=this.trackFilterMat;
        var amcode=this.trackAMcode;
        var soldto=this.trackSoldto;
        var customernames=this.selectedcustomerName;
        var status=this.trackStatus;
        var CalLogic = this.trackCalModel;
        
        //check calulation method filter.
        if(this.trackCalModel !== 'All'){
            var tempdata=[];
            localdata.forEach(function(element, index){ 
                if(element.calcmethod === CalLogic ){    
                    tempdata.push(element);
                }
            })
            localdata=tempdata;
        }
        //check Location filter.
        if(this.trackFilterplant !== 'All'){
            var tempdata=[];
            localdata.forEach(function(element, index){ 
                if(element.locationCode === plantfilter ){    
                    tempdata.push(element);
                }
            })
            localdata=tempdata;
        }
        //check Material filter
        if(this.trackFilterMat !== 'All'){
            var tempdata=[];
            localdata.forEach(function(element, index){ 
                if(element.productCode === material ){    
                    tempdata.push(element);
                }
            })
            localdata=tempdata;
        }
        //check Am code filter
        if(this.trackAMcode !== 'All'){
            var tempdata=[];
            localdata.forEach(function(element, index){ 
                if(element.amCode === amcode ){    
                    tempdata.push(element);
                }
            })
            localdata = tempdata;
        }

        //check Sold To filter
        if(this.trackSoldto !== 'All'){
            var tempdata=[];
            localdata.forEach(function(element, index){ 
                if(element.soldTo === soldto ){    
                    tempdata.push(element);
                }
            })
             localdata = tempdata;
         }
        //check customer name filter
         if(this.selectedcustomerName.length !== 0){
            var tempdata=[];
            localdata.forEach(function(element, index){ 
                if(customernames.includes(element.customerNameSoldTo.toLowerCase())){    
                    tempdata.push(element);
                }
            })
             localdata=tempdata;
         }
         //check status filter
         if(this.trackStatus !== 'All'){
             var tempdata=[];
             localdata.forEach(function(element,index){
                 if(element.approveStatus === status){   
                    tempdata.push(element);
                 }
             })
             localdata=tempdata;
         }
         
         
         return localdata;

    }


    //update the changes from child component Reseller
    updatemaindata(event){
        this.loadSpinner(true, 'Updating..');
        var datachange=JSON.parse(JSON.stringify(event.detail.data));
        console.log('reseller main data- before--'+JSON.stringify(datachange));

        //if single checkbox is seleted
        if(event.detail.actionOn === 'checkBox' ){
            if(event.detail.data.isChecked)  {
                this.checkboxList.push(event.detail.data.id);
                this.dataToChild.forEach(function(element,index){  
                    if(event.detail.data.id ===element.id )
                        element.isChecked=true;           
                })
            }
            else{
                this.dataToChild.forEach(function(element,index){  
                    if(event.detail.data.id ===element.id )
                        element.isChecked=false;           
                })
                this.checkboxList.splice(this.checkboxList.indexOf(event.detail.data.id),1);
            }
        }

        //if All checkbox is seleted
        if( event.detail.actionOn === 'AllCheckBox'){
            var tempdata=[];
            var loginuserDetail=this.loginuser;
            
            if(event.detail.action){
                this.dataToChild.forEach(function(element,index){     
                    //if(loginuserDetail === 'Customer Opps Team' && element.approveStatus === 'NS')
                    if( !loginuserDetail  && element.approveStatus === 'NS')
                        {
                            element.isChecked =true;
                            tempdata.push(element.id);
                        }
                    //if((loginuserDetail === 'Customer Opps Approver 1' || loginuserDetail === 'Customer Opps Approver 2') && (element.approveStatus === 'SB' || element.approveStatus === 'AP' || element.approveStatus === 'RJ'))
                    if((loginuserDetail ) && (element.approveStatus === 'SB' || element.approveStatus === 'SS' || element.approveStatus === 'SP'))
                        {
                            element.isChecked =true;
                            tempdata.push(element.id);
                       }
                })
            }
            else{
                this.dataToChild.forEach(function(element,index){              
                    element.isChecked=false;           
                })
            }
            this.checkboxList=tempdata;
        }
        console.log('JSON data --'+JSON.stringify(this.checkboxList));
        //if data is updated in any one record
        if(event.detail.actionOn ==='UpdateData'){  

            this.dataToChild= JSON.parse(JSON.stringify(this.updatedata(this.dataToChild,datachange)));           
            this.mainData=JSON.parse(JSON.stringify(this.updatedata(this.mainData,datachange))); 
                       
        }
       // const childcomp = this.template.querySelector('c-re_-P-H_-C-O-Dashboardchild');
       // childcomp.refreshdata(this.dataToChild);
        this.loadSpinner(false, 'Updating..');

    }

     //update the data to the main array when the user changes the value
     updatedata(datalist,updatedData){
        var indexdata;
        datalist.forEach(function(element,index){
            if(element.id === updatedData.id){
                indexdata=index;
            }
        })
        datalist.splice(indexdata,1,updatedData);
        return datalist;
    }

    //Submit all records to approval Process / to review  
    submitForReview(){
        if(this.checkboxList.length <= 0)
            this.showToast('error','error occured','select the records before submitting for Approval');
       else{ 
           console.log('selected values--'+this.checkboxList);
           var listofchangedId = this.checkboxList;
           var dataNotforReview =[];
           var statusfull;
           var status;
           var statuspicklist = [];
           var finalstatuspicklist = [];
            this.loadSpinner(true, 'Submitting Records');
            this.mainData.forEach(function(element,index){
                    if(!listofchangedId.includes(element.id))
                        dataNotforReview.push(element);
            })            
            submitForApprove({recordsTOsubmit : listofchangedId})
                .then(result =>{  

                    result.forEach(function(element,index){
                        dataNotforReview.push(element);
                        statusfull = element.approveStatusFull;
                        status = element.approveStatus;
                        statuspicklist.push({ label: statusfull, value: status });
                        console.log('statuspicklist-->'+JSON.stringify(statuspicklist));
                    })
                    finalstatuspicklist = [...this.statusFilter, ...statuspicklist];
                    this.statusFilter  = Array.from(new Set(finalstatuspicklist.map(a => a.label)))
                     .map(label => {
                       return finalstatuspicklist.find(a => a.label === label)
                     })
                    console.log('this.statusFilter -->'+JSON.stringify(this.statusFilter ));
                    this.mainData = dataNotforReview; 
                    this.mainData = JSON.parse(JSON.stringify(this.sortchildData('customerName','asc',this.mainData)));
                    this.filterdatatoChild();
                    this.checkboxList=[];
                    const childcomp = this.template.querySelector('c-re_-P-H_-C-O-Dashboardchild');
                    childcomp.closeModal();
                    this.loadSpinner(false, 'done');
                })
                .catch(error =>{
                    console.log('error occured'+JSON.stringify(error));
                    this.loadSpinner(false, 'done');
                    this.showToast('error','error occured',error);
                })

        }
    }

    //Approve or Reject the record
    approveOrreject(event){
       
        if(this.checkboxList.length <= 0)
            this.showToast('error','error occured','select the records before submitting for Approval');
       else{ 
           console.log('selected values--'+this.checkboxList);
           var listofchangedId = this.checkboxList;
           var dataNotforReview =[];
            this.loadSpinner(true, 'Submitting Records');
            this.mainData.forEach(function(element,index){
                    if(!listofchangedId.includes(element.id))
                        dataNotforReview.push(element);               
            })
            console.log('event.target.title-->'+event.target.title);
            var status;
            var statusfull;
            var statuspicklist = [];
            var finalstatuspicklist = [];
            ApprovalProcess({recordsTOApRj : listofchangedId ,action : event.target.title})
                .then(result =>{                      
                    result.forEach(function(element,index){
                        dataNotforReview.push(element);
                        statusfull = element.approveStatusFull;
                        status = element.approveStatus;
                        statuspicklist.push({ label: statusfull, value: status });
                        console.log('statuspicklist-->'+JSON.stringify(statuspicklist));
                    })
                    finalstatuspicklist = [...this.statusFilter, ...statuspicklist];
                    this.statusFilter  = Array.from(new Set(finalstatuspicklist.map(a => a.label)))
                     .map(label => {
                       return finalstatuspicklist.find(a => a.label === label)
                     })
                    console.log('this.statusFilter -->'+JSON.stringify(this.statusFilter ));
                    this.mainData = dataNotforReview;
                    this.mainData = JSON.parse(JSON.stringify(this.sortchildData('customerName','asc',this.mainData)));

                    this.filterdatatoChild();
                    this.checkboxList=[];
                    const childcomp = this.template.querySelector('c-re_-P-H_-C-O-Dashboardchild');
                    childcomp.closeModal();
                    this.loadSpinner(false, 'done');
                })
                .catch(error =>{
                    console.log('error occured'+JSON.stringify(error));
                    this.loadSpinner(false, 'done');
                    this.showToast('error','error occured',error);
                })

        }
        //this.connectedCallback();
    }    
    //generates daily customer Opps 
    generateCustomerOpps(){
        if (confirm("Click ok to Generate Todays Customer Opps ")){
            this.loadSpinner(true, 'Submitting Records');        
            generateCustData({})
            .then(result =>{
                console.log('@@@--'+JSON.stringify(result.Error));
                if(result.Error === 'false'){
                    this.showToast('success',result.message,'');                
                }
                else{
                    this.showToast('error',result.message,'');               
                }
                this.loadSpinner(false, 'done');
            })
            .catch(error =>{
                console.log('error'+JSON.stringify(error));
                this.showToast('error','Error occured','');   
                this.loadSpinner(false, 'done');        
            })
        }
    }

      //generates midWeek customer Opps 
      generateMidWeek(){
        if (confirm("Click ok to Generate MidWeek Customer Opps ")){
            this.loadSpinner(true, 'Checking...');        
            generatemidWeekdata({})
            .then(result =>{
                console.log('@@@--'+JSON.stringify(result.Error));
                if(result.Error === 'false'){
                    this.showToast('success',result.message,'');                
                }
                else{
                    this.showToast('error',result.message,'');               
                }
                this.loadSpinner(false, 'done');
            })
            .catch(error =>{
                console.log('error'+JSON.stringify(error));
                this.showToast('error','Error occured','');   
                this.loadSpinner(false, 'done');        
            })
        }
    }

    newContCustOpps(){
        if (confirm("Click ok to Generate New contracts price Customer Opps ")){
            this.loadSpinner(true, 'Checking...');        
            newContractCustomerOpps({})
            .then(result =>{
                console.log('@@@--'+JSON.stringify(result.Error));
                if(result.Error === 'false'){
                    this.showToast('success',result.message,'');                
                }
                else{
                    this.showToast('error',result.message,'');               
                }
                this.loadSpinner(false, 'done');
            })
            .catch(error =>{
                console.log('error'+JSON.stringify(error));
                this.showToast('error','Error occured','');   
                this.loadSpinner(false, 'done');        
            })
        }
    }


    //update discount and temp valid from and valid to for the selected records(filtered records)
    updatePricevalue(event){

    }

     //Check new contracts created to create price book data
    checkNewContracts(){

    }

    //Re try to GSAP export for failed records.
    retryToGSAP(){ 

    }
    
    //Download the filtered data in the screen
    downloadCSV(){        
            exportCSVFile(this.headers, this.dataToChild, "PH Customer Opps ");        
    }

    //Show the filter  
    showfilterpopup(){
        if(this.showPageHeader)
            this.showPageHeader = false;           
        else
         this.showPageHeader = true;           
        
    }

    //Close filter options
    closeModal() {
        this.showPageHeader = false;
       
    }

    //legend Start (Ex: AP - Approved , RJ - Reject)
    showadvanceFilter(){
        if(this.advanceOption)
            this.advanceOption = false;
        else
            this.advanceOption = true;
    }

    
    //Save to data base
    RecalculatePrice(){        
        console.log('saving---');
        if(confirm("Click ok to Save changes")){
            this.loadSpinner(true, 'Saving To data base');
            var finalData=[];   
            var listofchangedId = [];    
            var unchnagedData = [];   
            
            this.mainData.forEach(function(element,index){
                 if(element.startDate != element.startDateOld || element.endDate != element.endDateOld  || element.finalPrice != element.finalPriceOld || element.submitterComments != element.submitterCommentsOld
                 || element.refperiod != element.refperiodOld || element.priceSupport != element.priceSupportOld || element.psStartDate != element.psStartDateOld || element.psEndDate != element.psEndDateOld){
                    finalData.push(element); 
                    listofchangedId.push(element.id);
                }
                else{
                    unchnagedData.push(element);
                }
            })
           
            if(finalData.length != 0) {
                saveToDatabase({wrapPBDataList :finalData ,customerType : '' , idChanged : listofchangedId,datefilter : this.dateFilterValue})
                .then(result =>{
                    result.forEach(function(element,index){
                        unchnagedData.push(element);
                    })
                    this.mainData = JSON.parse(JSON.stringify(unchnagedData)); 
                    this.mainData =  this.sortchildData('customerName','asc',this.mainData);
                    this.filterdatatoChild();
                    const childcomp = this.template.querySelector('c-re_-P-H_-C-O-Dashboardchild');
                    console.log('--dataToChild--');
                    childcomp.refreshdata(this.dataToChild);
                    this.loadSpinner(false, 'done');
                })
                .catch(error =>{
                    console.log('error occured'+error);
                    this.loadSpinner(false, 'done');
                    this.showToast('error','error occured',error);
                })
            }
            else
                this.loadSpinner(false, 'done');
                
        }
        //this.connectedCallback();
    }

    //Recalucalte Margins or Final value in Screen level
    RecalculatePriceLocal(){

    }

    
    savedetailchanges(event){

        this.loadSpinner(true, 'Saving To data base');
            var finalData=[];   
            var listofchangedId = [];    
            var unchnagedData = [];   
            
            this.mainData.forEach(function(element,index){
                 if(event.detail.idChanged==element.id &&
                    (event.detail.data.startDate != element.startDateOld || event.detail.data.endDate != element.endDateOld  || 
                    event.detail.data.finalPrice != element.finalPriceOld || 
                    event.detail.data.submitterComments != element.submitterCommentsOld || 
                    event.detail.data.refperiod != element.refperiodOld || 
                    event.detail.data.priceSupport != element.priceSupportOld || 
                    event.detail.data.psStartDate != element.psStartDateOld || 
                    event.detail.data.psEndDate != element.psEndDateOld))
                    
                    {
                    finalData.push(event.detail.data); 
                    listofchangedId.push(element.id);
                    }
                else{
                    unchnagedData.push(element);
                    }
            })
           
           


            if(finalData.length != 0) {
                saveToDatabase({wrapPBDataList :finalData ,customerType : '' , idChanged : listofchangedId,datefilter : this.dateFilterValue})
                .then(result =>{
                    result.forEach(function(element,index){
                        unchnagedData.push(element);
                    })
                    this.mainData = JSON.parse(JSON.stringify(unchnagedData)); 
                    this.mainData =  this.sortchildData('customerName','asc',this.mainData);
                    this.filterdatatoChild();
                    const childcomp = this.template.querySelector('c-re_-P-H_-C-O-Dashboardchild');
                    childcomp.refreshdata(this.dataToChild);
                    this.loadSpinner(false, 'done');
                })
                .catch(error =>{
                    console.log('error occured'+error);
                    this.loadSpinner(false, 'done');
                    this.showToast('error','error occured',error);
                })
            }
            else
                this.loadSpinner(false, 'done');
            

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

    exportdata(evt){
        if (confirm("Click ok to Export data to GSAP ")){
            this.loadSpinner(true, 'Opening..');
            exportReport({ datefilter:this.dateFilterValue, retryOrexport : true ,selectedUser : this.trackuser})
            .then(result =>{
                this.loadSpinner(false, 'Report');
                if(result.status === 'true'){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.resultdata,
                            objectApiName: 'Folder',
                            actionName: 'view'
                        }
                    });
                }
                else{
                    this.showToast('error','error occured',result.message);
                }
            })
            .catch(error=>{
                this.loadSpinner(false, 'Report');
                this.showToast('error','error occured',error.body.message);
                console.log('--error in report export'+JSON.stringify(error));

            })
        }
    }

    retryToGSAP(){
        if (confirm("Click ok to GSAP Retry ")){
            this.loadSpinner(true, 'Opening..');
            exportReport ({ datefilter:this.dateFilterValue, retryOrexport : false , selectedUser : this.trackuser})
            .then(result =>{
                this.loadSpinner(false, 'Report');
                if(result.status === 'true'){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.resultdata,
                            objectApiName: 'Folder',
                            actionName: 'view'
                        }
                    });
                }
                else{
                    this.showToast('error','error occured',result.message);
                }
            })
            .catch(error=>{
                this.loadSpinner(false, 'Report');
                this.showToast('error','error occured',error.body.message);
                console.log('--error in report export'+JSON.stringify(error));

            })
        }
    }

    @wire(exportButtonContr, {})
    expDetail({ error, data }) {
        if (data != undefined) {
            this.exportButton = data;
            this.retryButton = data;
            if(data)
                this.showToast('info','Batch job:Records are exporting to GSAP ','Export and Retry button will be disabled until job complete');

        } else if (error) {
             this.exportButton = true;
             this.retryButton = true;

        }
        this.exportBackup = this.exportButton ;
        this.retryBackup = this.retryButton;
    }

     disableCheckBox(fieldname){
        this.template.querySelectorAll('lightning-input').forEach(comboname => {
        if(comboname.name === fieldname)
            comboname.checked = false;
        });
    }

    //Mass update for the selected records
    updatePricevalue(event){
        var butnName=event.target.name;
        console.log('event name---'+butnName);
        if(butnName === 'popUpPriceUpdate'){
            this.updatePrice=true;
        }

        if(butnName === 'refperiodupdate'){
            this.globalrefperiod = event.target.value;
        }

        if(butnName === 'refperiodConfrim'){
            if(this.globalrefperiod != null && this.globalrefperiod != undefined)
                this.refperCheckBox = event.target.checked;
            else if(this.globalrefperiod  == null && this.globalrefperiod == undefined && event.target.checked){
                this.showToast('error','error occured','Please select Reference Period');
                this.disableCheckBox('refperiodConfrim');
                this.refperCheckBox = false;
            }
        }
        if(butnName === 'ValidFrom'){
            this.globalValidFrom = event.target.value;
            console.log('this.globalValidFrom---'+this.globalValidFrom);
            if( this.globalValidFrom >=this.validFromMin &&  this.globalValidFrom <=this.validFromMax){
                if(this.globalValidDate != null && this.globalValidDate != undefined && this.globalValidFrom > this.globalValidDate){
                    this.showToast('error','error occured','Valid From should be lesser than valid To');
                    this.globalValidFrom = null;
                    this.disableCheckBox('ValidFromConfrim');
                }
            }
            else{
                this.showToast('error','error occured','Please select correct valid From');
                this.globalValidFrom=null;
                this.disableCheckBox('ValidFromConfrim');
            }
        }

        if(butnName === 'ValidFromConfrim'){
            if(this.globalValidFrom == null || this.globalValidFrom == undefined ){
                this.disableCheckBox('ValidFromConfrim');
                this.showToast('error','error occured','Please select Valid from');
            }
            else if(this.globalValidFrom >=this.validFromMin &&  this.globalValidFrom <=this.validFromMax) {
                this.ValidFromCheckBox = event.target.checked;
                if(this.globalValidDate != null && this.globalValidDate != undefined && this.globalValidFrom > this.globalValidDate){
                        this.showToast('error','error occured','Valid From should be lesser than valid To');
                        this.globalValidFrom = null;
                        this.disableCheckBox('ValidFromConfrim');
                        this.ValidFromCheckBox=false;
                }
            }
            else{
                this.showToast('error','error occured','Please select Valid from');
                this.disableCheckBox('ValidFromConfrim');
            }
        }

        if(butnName === 'ValidTo'){
            this.globalValidDate = event.target.value;
            if(this.globalValidDate >=this.validToMin &&  this.globalValidDate <=this.validToMax){
                if(this.globalValidFrom != null && this.globalValidFrom != undefined && this.globalValidDate < this.globalValidFrom ){
                    this.showToast('error','error occured','Valid To should be greater than valid From');
                    this.globalValidDate=null;
                    this.disableCheckBox('ValidToConfrim');
                }
            }
            else{
                this.showToast('error','error occured','Please select correct valid To');
                this.globalValidDate=null;
                this.disableCheckBox('ValidToConfrim');
            }
        }

        if(butnName === 'ValidToConfrim'){
            if(this.globalValidDate == null || this.globalValidDate == undefined ){
                this.disableCheckBox('ValidToConfrim');
                this.showToast('error','error occured','Please select Valid To');
            }
            else if(this.globalValidDate >= this.validFromMin &&  this.globalValidDate <= this.validFromMax) {
                this.ValidToCheckBox = event.target.checked;
                if(this.globalValidFrom != null && this.globalValidFrom != undefined && this.globalValidFrom > this.globalValidDate){
                        this.showToast('error','error occured','Valid To should be greater than valid From');
                        this.globalValidDate = null;
                        this.disableCheckBox('ValidToConfrim');
                        this.ValidToCheckBox=false;
                }
            }
            else{
                this.showToast('error','error occured','Please select Valid To');
                this.disableCheckBox('ValidToConfrim');
            }
        }

        if(butnName === 'Cancel'){
            this.updatePrice=false;
            this.globalrefperiod = null;
            this.globalValidDate=null;
            this.globalValidFrom=null;
            this.ValidToCheckBox=false;
            this.ValidFromCheckBox=false;
            this.refperCheckBox = false;
        }

        if(butnName === 'Save'){
            this.updatePrice=false;
            this.updatevalues();
            this.globalrefperiod = null;
            this.globalValidDate=null;
            this.globalValidFrom=null;
            this.ValidToCheckBox=false;
            this.ValidFromCheckBox=false;
            this.refperCheckBox = false;

        }
    }

    updatevalues(){
        if(this.globalValidFrom != null)
            var globalValidfromdate = new Date(this.globalValidFrom);

        if(this.globalValidDate != null)
            var globalValidToDate = new Date(this.globalValidDate);

        for(let key=0; key<this.dataToChild.length;key++){
            if(this.dataToChild[key].recordMode){
                for(let keymain=0;keymain<this.mainData.length;keymain++){
                    if(this.dataToChild[key].id === this.mainData[keymain].id){
                        //var fields = this.dataToChild[key].fields.split(';');
                        var tempValidStart = new Date(this.dataToChild[key].startDate);
                        var tempValidend = new Date(this.dataToChild[key].endDate);
                        console.log('this.globalrefperiod'+this.globalrefperiod);
                        console.log('this.refperCheckBox'+this.refperCheckBox);
                        if(this.globalrefperiod != null && this.globalrefperiod != this.mainData[keymain].refperiod && this.refperCheckBox == true){
                            this.dataToChild[key].refperiod =this.globalrefperiod;
                            this.mainData[keymain].refperiod=this.globalrefperiod;
                            console.log('this.globalrefperiod--'+this.globalrefperiod);
                        }
                        if(this.globalValidFrom != this.mainData[keymain].startDate && this.ValidFromCheckBox == true && this.globalValidFrom != null &&  globalValidfromdate <= tempValidend ){
                            this.dataToChild[key].startDate=this.globalValidFrom;
                            this.mainData[keymain].startDate=this.globalValidFrom;
                        }
                        if(this.globalValidDate != this.mainData[keymain].endDate && this.ValidToCheckBox == true && this.globalValidDate != null && globalValidToDate >= tempValidStart ){
                            this.dataToChild[key].endDate=this.globalValidDate;
                            this.mainData[keymain].endDate=this.globalValidDate;
                        }
                    }
                }
            }
        }
    }
}