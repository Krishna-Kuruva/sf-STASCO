import { LightningElement,track,wire } from 'lwc';          
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getAlldata from '@salesforce/apex/RE_customOppController.getallData';
import approveReject from '@salesforce/apex/RE_customOppController.approveReject';
import recalculationdata from '@salesforce/apex/RE_customOppController.convertToPriceBook';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import submitForApprove from '@salesforce/apex/RE_customOppController.submitforApproval';
import exportReport from '@salesforce/apex/RE_customOppController.exportReport';
import checkNewContracts from '@salesforce/apex/RE_customOppController.checkNewContractData';
import getDatefilter from '@salesforce/apex/RE_customOppController.getFilteredDate';
import  exportButtonContr  from '@salesforce/apex/RE_customOppController.exportButtonContr';
import updateLatestCBU from '@salesforce/apex/RE_customOppController.refreshCBU';
import {exportCSVFile} from 'c/re_csvgenerator';
import My_Resource from '@salesforce/resourceUrl/RE_MY_CustomerOpps';
export default class CustomOppParent extends NavigationMixin(LightningElement) {
   
    @track showPageHeader = false;
    @track spinnerLoad=false;
    @track spinnerMessage='';
    @track showDirectOpp=false;
    @track cbuOutput=false;
    @track loginuser='';
    @track cbupublishDate;
    @track MidDaypublishDate;
    @track advanceOption;
    //stores main data of CBU and MidDay 
    @track cbuMainData;
    @track midDayMainData;

    //export button control
    @track exportButton = true;
    @track retryButton = true;

    @track nextdate;   
    //date filter value
    @track dateFilterValue;
    //date filter range based on CBU(user can't select future values) and MidDay(user can select future values)
    @track dateFilterMin;
    @track dateFilterMax;

    //max and min date range based on CBU and MidDay view
    @track validFromMin;
    @track validFromMax;
    @track validToMin;
    @track validToMax;

    //export button track
     @track exportBackup = true ;
     @track retryBackup = true;

    //user inputs to change temp discount based on filter
    @track updatePrice=false;
    @track globalFinalPrice=0;
    @track globalPriceLevel=0;
    @track globalcomments='';
    @track globalValidDate;
    @track globalValidFrom;
    @track FinalPriceCheckBox = false;
    @track ValidFromCheckBox = false;
    @track ValidToCheckBox = false;
    
    //boolean field which tracks MidayDay edit date field
    @track trackEditedDate=null;
    //boolean field to track  update MidayDay edit price field
    @track trackPriceEdite=null;
    //boolean field to check data is saved
    @track trackDataSaved=false;
    //boolean field which tracks MidayDay edit date field
    @track trackPriceEditeCBU=null;
    //boolean field to track  update MidayDay edit price field
    @track trackEditedDateCBU=null;
    //boolean field to check data is saved
    @track trackDataSavedCBU=false;

    
    
    //CustomerType filter Reseller or Direct
    @track CustomerTypeList= [{ label: 'Reseller', value: 'Reseller'}
                        ,{ label: 'Direct', value: 'Direct'}];
    /*
    {label :'Submitted STL',value:'SB'},
    {label :'Support STL',value:'SS'},
    */
    @track statusFilter=[{label: 'All', value: 'All'},
                         {label :'Not Submitted',value:'NS'},
                         {label :'Submitted PM',value:'SB'},                                                  
                         {label :'Support PM',value:'SP'},
                         {label: 'Approved', value: 'AP'},
                         {label: 'Rejected', value: 'RJ'},
                         {label :'Auto Approved', value:'AA'},
                         {label :'Ready to Upload', value:'RU'},
                         {label :'Uploaded', value:'UP'},
                         {label :'Failed', value:'FA'},
                         {label :'Upload not allowed', value:'UN'},]

    //contains all data from server
    @track customOppsData;
    //contains checkbox to Approve or Reject Records
    @track checkboxList=[];

    //controls Submit for approval and Approve/Reject button
    @track isApprover;
    @track hideContBut;

    //holds the current values for picklist
    @track plantList=[];
    @track material=[];
    @track customerName=[];
    @track soldTo=[];
    @track amcode=[];
    @track calculationMod=[];


    //contains Reseller main data
    @track resellerPlant=[];
    @track resellerMaterial=[];
    @track resellercustomer=[];
    @track resellerSlodTo=[];
    @track resellerAMcode=[];
    @track resellerCustData=[];
    @track resellerCalMod=[];

    //contains Direct main data
    @track directPlants=[];
    @track directMaterial=[];
    @track directcustomer=[];
    @track directSlodTo=[];
    @track directAMcode=[];
    @track directCustData=[];
    @track directCalMod=[];

    //cpoied data of reseller to send child component
    @track resellerToChild=[];
    //cpoied data of Direct to send child component
    @track DirectToChild=[];

    //holds the current value selected in picklist
   // @track trackFilterplant='All';
    @track currentCustomer='Reseller';
    @track trackSoldto='All';
    @track trackStatus='All';
    @track trackCalModel='All';
   
    @track resetFilter = false;

    @track locListToShow=[];
		@track locListToSearch=[];
		@track showLocFilter=false;
		@track locAll=true;
		@track locSearchText;
        @track selectedLocations=[];
		
		@track prodListToShow=[];
		@track prodListToSearch=[];
		@track showProdFilter=false;
		@track prodAll=true;
		@track prodSearchText;
        @track selectedMaterials=[];
		
		@track custListToShow=[];
		@track custListToSearch=[];
		@track showCustFilter=false;
		@track custAll=true;
		@track custSearchText;
        @track selectedcustomerName=[];
		
		@track AMListToShow=[];
		@track AMListToSearch=[];
		@track showAMFilter=false;
		@track AMAll=true;
		@track AMSearchText;
        @track selectedAMcode=[];
    

    headers;
    
    handleLocationSelect(event)
    {
      //  console.log('handleLocSelect called--'+JSON.stringify(event.detail));
        this.locListToShow=event.detail.filterListToShow;
        this.locListToSearch=event.detail.filterListToSearch;
    } 

    handleCustSelect(event)
    {
        this.custListToShow=event.detail.filterListToShow;
        this.custListToSearch=event.detail.filterListToSearch;
    } 

    handleProductSelect(event)
    {
       
        this.prodListToShow=event.detail.filterListToShow;
        this.prodListToSearch=event.detail.filterListToSearch;
    } 

    handleAMCodeSelect(event)
    {
        this.AMListToShow=event.detail.filterListToShow;
        this.AMListToSearch=event.detail.filterListToSearch;
    } 

    handleApplyFilter(event)
    {
        this.loadSpinner(true, 'Filtering');

        new Promise(
            (resolve,reject) => {
            setTimeout(()=> {
               
                
        if(event.detail.filterType=="Location")
        {
            this.selectedLocations=event.detail.selectedFilter;
            this.locAll=event.detail.isAll;
        }
        else if(event.detail.filterType=="Customer")
        {
            this.selectedcustomerName=event.detail.selectedFilter;
            this.custAll=event.detail.isAll;
        }

        else if(event.detail.filterType=="Material")
        {
            this.selectedMaterials=event.detail.selectedFilter;
            this.prodAll=event.detail.isAll;
        }

        else if(event.detail.filterType=="AMCode")
        {
            this.selectedAMcode=event.detail.selectedFilter;
            this.AMAll=event.detail.isAll;
        }

        this.filterdatatoChild();
        this.loadSpinner(false, 'Filtering');
            resolve();
        }, 0);
         }).then();
    }

    showFilter(){
        if(this.showPageHeader)
            this.showPageHeader = false;
        else 
            this.showPageHeader = true;
    }

    
    //Init Method Declaration
    connectedCallback() {
        //Column in Download files stored in Static resource
        let request = new XMLHttpRequest();
        request.open("GET", My_Resource, false);
        request.send(null);

        var jsonToShow = request.responseText;
        this.headers = JSON.parse(jsonToShow);

        this.cbuOutput = false;
        this.resetFilter = true;
        var newDate= new Date();
        newDate.setDate(newDate.getDate() + 1);
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
        this.loadSpinner(true, 'Refreshing');
        this.showPageHeader = true;
        
        //var filtercondition =this.getfiltercondition();
        this.dateFilterValue=this.nextdate;
        this.dateFilterMin=this.nextdate;
        this.validFromMax = '2050-12-31';
        this.validToMax = '2050-12-31';
       // getAlldata({isMidDay : this.cbuOutput})
       getDatefilter({datefilter : this.dateFilterValue ,isMidDay : this.cbuOutput , customerType : this.currentCustomer})
        .then(result=>{
            //console.log('initial load--'+JSON.stringify(result));
            this.midDayMainData=result;
            this.updateArraylist(result);            
        })
        .catch(error=>{
            console.log('error occured');
            this.showToast('error','error occured',error.body.message);
            this.loadSpinner(false, 'error occured');

        })

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
    downloadCSV(){
        console.log("download triggered.");
        if(this.currentCustomer === 'Direct')
            exportCSVFile(this.headers, this.DirectToChild, "Direct Customer");
        else
            exportCSVFile(this.headers, this.resellerToChild, "Reseller Customer");
    }
    retryToGSAP(){       
        if (confirm("Click ok to GSAP Retry ")){
            this.exportButton = true;
            this.retryButton =  true;
            this.loadSpinner(true, 'Opening..');
            exportReport ({ datefilter:this.dateFilterValue ,isMidDay : this.cbuOutput , retryOrexport : false})
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
     
    //view CBU output
    cbuOutputView(event){
        this.resetFilter = false;
        console.log(event.target.checked);
        this.loadSpinner(true, 'Refreshing');
        this.cbuOutput=event.target.checked;
        var newDate= new Date();
        this.exportButton = this.exportBackup;
        this.retryButton = this.retryBackup;

        //Promise is added due to Spinner is not rendering on screen
        new Promise(
            (resolve,reject) => {
              setTimeout(()=> {

                if(this.cbuOutput){
                    let year= ''+newDate.getFullYear();
                    let month=''+ (newDate.getMonth() + 1);
                    let day=''+newDate.getDate();
                    if (month.length < 2) 
                        month = '0' + month;
                    if (day.length < 2) 
                        day = '0' + day;

                    this.dateFilterValue = year+'-'+ month +'-'+day;
                    this.validFromMin = this.dateFilterValue;
                    this.validToMin = this.dateFilterValue;
                    this.validFromMax = '2050-12-31';
                    this.validToMax = '2050-12-31';
                    //this.validFromMax = this.dateFilterValue;
                    //this.validToMax = this.dateFilterValue;
                   
                        getDatefilter({datefilter : this.dateFilterValue ,isMidDay : this.cbuOutput ,customerType : this.currentCustomer})
                        .then(result=>{  
                            this.cbuMainData=result;
                            this.updateArraylist(result);
        
                        })
                        .catch(error=>{
                            console.log('error occured');
                            this.showToast('error','error occured',error.body.message);
                            this.loadSpinner(false, 'error occured');
        
                        })
                }
                else{
                    newDate.setDate(newDate.getDate() + 1);
                    let year= ''+newDate.getFullYear();
                    let month=''+ (newDate.getMonth() + 1);
                    let day=''+newDate.getDate();
                    if (month.length < 2) 
                        month = '0' + month;
                    if (day.length < 2) 
                        day = '0' + day;
                    this.dateFilterValue=year+'-'+ month +'-'+day;
                    this.validFromMin = this.dateFilterValue;
                    this.validToMin = this.dateFilterValue;
                    this.validFromMax = '2050-12-31';
                    this.validToMax = '2050-12-31';
                        getDatefilter({datefilter : this.dateFilterValue ,isMidDay : this.cbuOutput , customerType : this.currentCustomer})
                        .then(result=>{                    
                           this.midDayMainData=result;
                            this.updateArraylist(result);
        
                        })
                        .catch(error=>{
                            console.log('error occured');
                            this.showToast('error','error occured',error.body.message);
                            this.loadSpinner(false, 'error occured');
        
                        })                   
                }
                 //clear all the values which were selected in the picklist         
                 //this.resetToinitialvalues();
                  resolve();
              }, 0);
          }).then(
            
          );      
       
         
    }
    filterBasedOnDate(event){
        console.log('filterBasedOnDate called--');
        this.resetFilter = false;
        var datevalue=event.target.value;
        let date = new Date();
        date.setHours(0, 0, 0, 0);
        var selectedDate= new Date(event.target.value);
        selectedDate.setHours(0, 0, 0, 0);
        if( ((!this.cbuOutput && selectedDate > date) || this.cbuOutput) && this.dateFilterValue !=datevalue){
            if(this.cbuOutput && selectedDate < date ){
                this.exportButton = true;
                this.retryButton = true;
            }
            else{
                console.log('inside enable--');
                this.exportButton = this.exportBackup;
                this.retryButton = this.retryBackup;
            }

            this.dateFilterValue=datevalue;
            this.loadSpinner(true, 'Refreshing');
            new Promise(
                (resolve,reject) => {
                setTimeout(()=> {
                    getDatefilter({datefilter : datevalue,isMidDay : this.cbuOutput ,customerType : this.currentCustomer})
                    .then(result=>{ 
                        this.updateArraylist(result);
                        
                    })
                    .catch(error=>{
                        this.loadSpinner(false, 'Data Loaded'); 
                    })
                resolve();
            }, 0);
        }).then(
    
        );
    }
    }

    //update all array list based on CUB toggle button
    updateArraylist(result){

        this.customOppsData=JSON.parse(JSON.stringify(result));
        // Reseller data 
        this.resellerPlant = JSON.parse(JSON.stringify(result.reseller.locationList));
        this.resellerMaterial = JSON.parse(JSON.stringify(result.reseller.MaterialList));            
        this.resellerSlodTo = JSON.parse(JSON.stringify(this.sortNumber('label','desc',result.reseller.soldTo)));
        this.resellerAMcode = JSON.parse(JSON.stringify(result.reseller.AMCodeList));
        this.resellercustomer = JSON.parse(JSON.stringify(result.reseller.customerList));
        this.resellerCustData = JSON.parse(JSON.stringify(this.sortData('customerName','asc',result.reseller.resellerdata)));
        this.resellerCalMod = JSON.parse(JSON.stringify(result.reseller.CalMod));
        //Direct data 
        this.directPlants = JSON.parse(JSON.stringify(result.direct.locationList));
        this.directMaterial = JSON.parse(JSON.stringify(result.direct.MaterialList));
        this.directSlodTo = JSON.parse(JSON.stringify(result.direct.soldTo));
        this.directAMcode = JSON.parse(JSON.stringify(result.direct.AMCodeList));
        this.directcustomer = JSON.parse(JSON.stringify(result.direct.customerList));
        this.directCalMod = JSON.parse(JSON.stringify(result.direct.CalMod));
        this.directCustData = JSON.parse(JSON.stringify(this.sortData('customerName','asc',result.direct.directdata)));

        //onpage loade Reseller data will assign
        if(this.currentCustomer == 'Reseller')
        {
            this.plantList = JSON.parse(JSON.stringify(this.resellerPlant));
            this.material = JSON.parse(JSON.stringify(this.resellerMaterial));
            this.soldTo = JSON.parse(JSON.stringify(this.sortNumber('label','asc',this.resellerSlodTo)));
            this.customerName = JSON.parse(JSON.stringify(this.resellercustomer));
            this.amcode = JSON.parse(JSON.stringify( this.resellerAMcode));
        }
        else
        {
            this.plantList = JSON.parse(JSON.stringify(this.directPlants));
            this.material = JSON.parse(JSON.stringify(this.directMaterial));
            this.soldTo = JSON.parse(JSON.stringify(this.sortNumber('label','asc',this.directSlodTo)));
            this.customerName = JSON.parse(JSON.stringify(this.directcustomer));
            this.amcode = JSON.parse(JSON.stringify( this.directAMcode));
        }
        //console.log('material--'+JSON.stringify(this.material));

        this.calculationMod = JSON.parse(JSON.stringify(result.reseller.CalMod));

        //coping data to variables which pass to child component
        // JSON.parse(JSON.stringify()) is used to avoid refer to same instance 
        this.resellerToChild=JSON.parse(JSON.stringify(this.resellerCustData));
        this.DirectToChild=JSON.parse(JSON.stringify(this.directCustData));

        this.locListToShow=[];
        this.locListToSearch=[];
        this.showLocFilter=false;
		this.locAll=true;
		this.locSearchText='';
        this.selectedLocations=[];

        if(this.plantList.length>0)
        {
       const allLoc={isSelected:true , filter:'All'};
                this.locListToSearch.push(allLoc);
                for (const loc of this.plantList) {
                    const loc1 = {isSelected:true , filter:loc};
                    this.locListToSearch = [...this.locListToSearch, loc1];
                }
                this.locListToShow=this.locListToSearch;
            }

        this.prodListToShow=[];
        this.prodListToSearch=[];
        this.showProdFilter=false;
		this.prodAll=true;
		this.prodSearchText='';
        this.selectedMaterials=[];

        if(this.material.length>0)
        {
        const allMat={isSelected:true , filter:'All'};
                this.prodListToSearch.push(allMat);
                for (const mat of this.material) {
                    const mat1 = {isSelected:true , filter:mat};
                    this.prodListToSearch = [...this.prodListToSearch, mat1];
                }
                this.prodListToShow=this.prodListToSearch;

        }

        this.custListToShow=[];
        this.custListToSearch=[];
        this.showCustFilter=false;
        this.custAll=true;
        this.custSearchText='';
        this.selectedcustomerName=[];

        if(this.customerName.length>0)
        {
            const allCust={isSelected:true , filter:'All'};
                this.custListToSearch.push(allCust);
                for (const cust of this.customerName) {
                    const mat1 = {isSelected:true , filter:cust};
                    this.custListToSearch = [...this.custListToSearch, mat1];
                }
                this.custListToShow=this.custListToSearch;
        }

        this.AMListToShow=[];
        this.AMListToSearch=[]; 
        this.showAMFilter=false;
		this.AMAll=true;
		this.AMSearchText='';
        this.selectedAMcode=[];

        if(this.amcode.length>0)
        {
            const allAM={isSelected:true , filter:'All'};
                this.AMListToSearch.push(allAM);
                for (const AMcode of this.amcode) {
                    const AMcode1 = {isSelected:true , filter:AMcode};
                    this.AMListToSearch = [...this.AMListToSearch, AMcode1];
                }
                this.AMListToShow=this.AMListToSearch;
            }
       

        if(this.resetFilter){
            console.log('currentCustomer==resetFilter');
            //picklist initial values
           // this.trackFilterplant="All"
            this.trackSoldto='All';
            this.trackStatus='All';
            this.trackCalModel='All';
        }
        else{
            if(this.currentCustomer == 'Direct'){
                this.plantList = JSON.parse(JSON.stringify(result.direct.locationList));
                this.material = JSON.parse(JSON.stringify(result.direct.MaterialList));
                this.soldTo = JSON.parse(JSON.stringify(result.direct.soldTo));
                this.customerName = JSON.parse(JSON.stringify(result.direct.customerList));
                this.amcode = JSON.parse(JSON.stringify(result.direct.AMCodeList));
                this.calculationMod = JSON.parse(JSON.stringify(result.direct.CalMod));
            }

            this.template.querySelector("c-re_cnd_search-filter[data-my-id=filter1]").resetparams();
            this.template.querySelector("c-re_cnd_search-filter[data-my-id=filter2]").resetparams();
            this.template.querySelector("c-re_cnd_search-filter[data-my-id=filter3]").resetparams();
            this.template.querySelector("c-re_cnd_search-filter[data-my-id=filter4]").resetparams();


            this.filterdatatoChild();

        }

        //MidDay or CBU published Date
        this.cbupublishDate= result.cubpublishDate;
        this.MidDaypublishDate=result.midpublishDate
        //login user ex. Customer Opps Team or Approver
        this.loginuser=result.isApprover;
        //this.isApprover =(result.isApprover === 'Customer Opps Team' ? false : true);
        this.isApprover = result.isApprover;
        //this.hideCtrltBut =(result.isApprover === 'ViewOnly' ? true : false);
        this.hideCtrltBut = result.controlFunction;
        this.loadSpinner(false, 'Data Loaded'); 

    }

    
    // sort function
    sortData(fieldName, sortDirection,dataToSort){
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

    //This method will call when the filter values changed
    //Based on filter name(lightning-combobox name) corresponding data will filter
    CustomerTypeFilter(event){
        this.loadSpinner(true, 'Filtering..');
        var eventName=event.target.name;
        this.checkboxList=[];
        var newDate= new Date();
        new Promise(
            (resolve,reject) => {
              setTimeout(()=> {

        //if customerType filter selected, All other filter values will be reassigned and data 
        if(eventName === 'CustomerType'){
            this.customerName=[];
            this.selectedcustomerName=[];
            this.selectedLocations=[];
            this.selectedMaterials=[];
            this.material=[];
            this.plantList=[];
            this.selectedAMcode=[];
            this.amcode=[];


           // this.template.querySelector('c-researchpicklist').clearinitvalues();

            this.template.querySelectorAll('lightning-combobox').forEach(comboname => {

                if(comboname.name ==='Soldto' ||   comboname.name ==='Status' || comboname.name ==='calmodel')
                    comboname.value='All';
             });

             this.trackSoldto='All';
             //this.currentCustomer='Reseller';
             this.trackStatus='All';
             this.trackCalModel='All';
            if(event.detail.value === 'Direct')
            {
                //update date field in mass update with min and max date user can give
                if(!this.cbuOutput)
                    newDate.setDate(newDate.getDate() + 1);

                let year= ''+ newDate.getFullYear();
                let month= ''+ (newDate.getMonth() + 1);
                let day= '' + newDate.getDate();
                if (month.length < 2) 
                    month = '0' + month;
                if (day.length < 2) 
                    day = '0' + day;   
                
                let datemin=year + '-' + month + '-' + day;
                this.validFromMin = datemin;
                this.validToMin = datemin;

                var curr = new Date;
				var first = curr.getDate() - curr.getDay() + 1; 
				var last = first + 6;
					
				var maxDate = new Date(newDate.setDate(first));
                var maxDateweekend = new Date(curr.setDate(last));
                console.log('---'+maxDateweekend);

                let yearMax= '' + maxDateweekend.getFullYear();
                let monthmax= ''+ (maxDateweekend.getMonth() + 1);
                let daymax= '' + maxDateweekend.getDate();
                if (monthmax.length < 2) 
                    monthmax = '0' + monthmax;
                if (daymax.length < 2) 
                    daymax = '0' + daymax;  

                this.validFromMax = yearMax + '-' + monthmax + '-' + daymax;
                this.validToMax =  yearMax + '-' + monthmax + '-' + daymax;
                if(this.cbuOutput){
                    this.validFromMax = datemin;
                    this.validToMax = datemin;
                    }

                this.validFromMax = '2050-12-31';
                this.validToMax = '2050-12-31';
                //assign direct customer values to picklist and table
                this.plantList=this.directPlants;
                this.material= this.directMaterial;
                this.customerName=this.directcustomer;
                this.soldTo=this.directSlodTo;
                this.amcode=this.directAMcode;
                this.calculationMod=this.directCalMod;
                // JSON.parse(JSON.stringify()) is used to avoid refer to same instance 
                //this.DirectToChild=JSON.parse(JSON.stringify(this.directCustData));
                this.currentCustomer=event.detail.value;
                new Promise(
                    (resolve,reject) => {
                    setTimeout(()=> {
                        this.loadSpinner(true, 'Filtering..');
                        getDatefilter({datefilter : this.dateFilterValue,isMidDay : this.cbuOutput ,customerType : this.currentCustomer})
                        .then(result=>{ 
                            this.resetFilter = false; 
                            this.updateArraylist(result);
                             //change table and update the customer type to Direct


                            this.showDirectOpp=true; 
                        })
                        .catch(error=>{
                            this.loadSpinner(false, 'Data Loaded'); 
                        })
                    resolve();
                }, 0);
            }).then(
        
            );
               
                
            }
            if(event.detail.value === 'Reseller')
            {

                let dateMin = newDate.getFullYear()+'-'+ (newDate.getMonth() + 1) +'-'+newDate.getDate();
                this.validFromMin = this.dateFilterValue;
                this.validToMin = this.dateFilterValue;
                this.validFromMax = '2050-12-31';
                this.validToMax = '2050-12-31';
                /*if(this.cbuOutput){
                this.validFromMax = this.dateFilterValue;
                this.validToMax = this.dateFilterValue;
                }*/

                 //assign Reseller customer values to picklist and table
                this.plantList=this.resellerPlant;
                this.material=this.resellerMaterial;
                this.customerName=this.resellercustomer;
                this.soldTo=this.resellerSlodTo;
                this.amcode=this.resellerAMcode;
                this.calculationMod=this.resellerCalMod;
                // JSON.parse(JSON.stringify()) is used to avoid refer to same instance 
                //this.resellerToChild=JSON.parse(JSON.stringify(this.resellerCustData));
                this.currentCustomer=event.detail.value;
                new Promise(
                    (resolve,reject) => {
                    setTimeout(()=> {
                        this.loadSpinner(true, 'Filtering..');
                        getDatefilter({datefilter : this.dateFilterValue,isMidDay : this.cbuOutput ,customerType : this.currentCustomer})
                        .then(result=>{ 
                            this.resetFilter = false;
                            this.updateArraylist(result);
                            //change table and update the customer type to Direct

                            this.showDirectOpp=false;
                        })
                        .catch(error=>{
                            this.loadSpinner(false, 'Data Loaded'); 
                        })
                    resolve();
                }, 0);
            }).then(
        
            );
                             

            }
            
        }
        else{

            //update the latest value in AMCode filter
            

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

        }
        this.loadSpinner(false, 'Filtering');

                resolve();
              }, 0);
          }).then(
              
          );
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
                this.resellerToChild.forEach(function(element,index){  
                    if(event.detail.data.id ===element.id )
                        element.isChecked=true;           
                })
            }
            else{
                this.resellerToChild.forEach(function(element,index){  
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
            console.log('---user in parent --'+loginuserDetail);
            if(event.detail.action){
                this.resellerToChild.forEach(function(element,index){              
                       
                    //if(loginuserDetail === 'Customer Opps Team' && element.approveStatus === 'NS')
                    if( !loginuserDetail  && element.approveStatus === 'NS')
                        {element.isChecked =true;
                         tempdata.push(element.id);
                        }
                    //if((loginuserDetail === 'Customer Opps Approver 1' || loginuserDetail === 'Customer Opps Approver 2') && (element.approveStatus === 'SB' || element.approveStatus === 'AP' || element.approveStatus === 'RJ'))
                    if((loginuserDetail ) && (element.approveStatus === 'SB' || element.approveStatus === 'SS' || element.approveStatus === 'SP'))
                        {element.isChecked =true;
                         tempdata.push(element.id);
                       }
                })
            }
            else{
                this.resellerToChild.forEach(function(element,index){              
                    element.isChecked=false;           
                })
            }
            this.checkboxList=tempdata;
        }
        //if data is updated in any one record
        if(event.detail.actionOn ==='UpdateData'){  
            if(this.cbuOutput === true){
                this.trackPriceEditeCBU = true;
                this.trackEditedDateCBU = false
                this.trackDataSavedCBU = true;
            }
            if(this.cbuOutput === false) {
                this.trackPriceEdite =true;
                this.trackEditedDate = false;
                this.trackDataSaved =true;
            }         
            this.resellerCustData= JSON.parse(JSON.stringify(this.updatedata(this.resellerCustData,datachange)));           
            this.resellerToChild=JSON.parse(JSON.stringify(this.updatedata(this.resellerToChild,datachange)));            
        }
        this.loadSpinner(false, 'Updating..');

    }

    //update the changes from child component Direct
    updatemaindatadirect(event){
        var datachange=JSON.parse(JSON.stringify(event.detail.data));

        //if single checkbox is seleted
        if(event.detail.actionOn === 'checkBox' ){
            if(event.detail.data.isChecked)  {
                this.checkboxList.push(event.detail.data.id);
                this.DirectToChild.forEach(function(element,index){  
                    if(event.detail.data.id ===element.id )
                        element.isChecked=true;           
                })
            }
            else{
                this.DirectToChild.forEach(function(element,index){  
                    if(event.detail.data.id ===element.id )
                        element.isChecked=false;           
                })
                this.checkboxList.splice(this.checkboxList.indexOf(event.detail.data.id),1);
            }
        }

         //if All checkbox is seleted
         if( event.detail.actionOn === 'AllCheckBox'){
            var tempdata=[]
            var loginUserdetail=this.loginuser;
            if(event.detail.action){
                this.DirectToChild.forEach(function(element,index){              
                      
                    //if(loginUserdetail === 'Customer Opps Team' && element.approveStatus === 'NS'){
                    if( !loginUserdetail  && element.approveStatus === 'NS'){
                        tempdata.push(element.id); 
                         element.isChecked =true;
                        }
                    //if((loginUserdetail === 'Customer Opps Approver 1' || loginUserdetail === 'Customer Opps Approver 2') && (element.approveStatus === 'SB' || element.approveStatus === 'AP' || element.approveStatus === 'RJ')){
                    if((loginUserdetail ) && (element.approveStatus === 'SB' || element.approveStatus === 'SS' || element.approveStatus === 'SP')){
                        tempdata.push(element.id); 
                        element.isChecked =true;
                   }
                })
            }
            else{
                this.DirectToChild.forEach(function(element,index){              
                    element.isChecked=false;           
                })
            }
            this.checkboxList=tempdata;
        }

        if(event.detail.actionOn ==='UpdateData'){
            console.log('inside data update---');
            if(this.cbuOutput === true){
                this.trackPriceEditeCBU = true;
                this.trackEditedDateCBU = false
                this.trackDataSavedCBU = true;
            }
            if(this.cbuOutput === false) {
                this.trackPriceEdite =true;
                this.trackEditedDate = false;
                this.trackDataSaved =true;
            } 
            this.directCustData=JSON.parse(JSON.stringify(this.updatedata(this.directCustData,datachange)));
            this.DirectToChild=JSON.parse(JSON.stringify(this.updatedata(this.DirectToChild,datachange)));
        }
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

   //Approve or Reject the record
   approveOrreject(event){
       console.log('---event.target.label---'+event.target.title);
    this.loadSpinner(true,'Processing.. ');
    var actionIs=event.target.title;
       if(this.checkboxList.length <= 0){
            this.showToast('error','error occured','Pls select record to Approve/Reject');
            this.loadSpinner(false,'Processing.. ');
       }
        else{
            var warpperList
            if(this.currentCustomer === 'Direct'){
                warpperList = this.directCustData;
                //commentsMap = this.Approvercomments(this.directCustData,this.checkboxList);
            }
            if(this.currentCustomer === 'Reseller'){
                warpperList = this.resellerToChild;
                //commentsMap = this.Approvercomments(this.resellerToChild,this.checkboxList);
            }
            approveReject({ids : this.checkboxList ,action:event.target.title , wrapPBDataList:warpperList,isMidDay : this.cbuOutput , dateFilter:this.dateFilterValue ,customerType : this.currentCustomer})
            .then(result =>{
                
                if(result.status === 'true'){
                    this.checkboxList=[];
                    //updating new values after submitting the record
                    var resellerdata=this.sortData('customerName','asc',result.reseller.resellerdata);
                    var directData=this.sortData('customerName','asc',result.direct.directdata); 
                    this.resellerCustData = JSON.parse(JSON.stringify(resellerdata));
                    this.directCustData = JSON.parse(JSON.stringify(directData));
    
                    this.resellerToChild=JSON.parse(JSON.stringify(resellerdata));
                    this.DirectToChild=JSON.parse(JSON.stringify(directData));
                    this.showToast('success',actionIs,'Records '+actionIs);
    
                        
                    if(this.cbuOutput && this.cbuMainData !== undefined){
                        this.cbuMainData.reseller.resellerdata=resellerdata;
                        this.cbuMainData.direct.directdata=directData;
                    }
                    if(!this.cbuOutput && this.midDayMainData !== undefined){
                        this.midDayMainData.reseller.resellerdata=resellerdata;
                        this.midDayMainData.direct.directdata=directData;
                    }

                    //clear all the values which were selected in the picklist
                    //this.resetToinitialvalues();
                    this.filterdatatoChild();                    
                }
            else{
                this.showToast('error','error occured',result.message);           
                }
                this.loadSpinner(false, 'Processed');
            })
            .catch(error =>{
                this.loadSpinner(false, 'error occured');
                console.log('error--'+JSON.stringify(error));
                this.showToast('error','error occured',error);
            })
        }

   }

   //update Approval status and checkbox field
   updateApprovalStatus(datalist,selectedCheckbox,actionName){  
        datalist.forEach(function(element,index){
            if(selectedCheckbox.includes(element.id)){
                element.approveStatus=actionName;
                element.avatarCssClass='slds-avatar__initials slds-icon-standard-account '+actionName;
            }
        });  

    return datalist;

   }

   Approvercomments(dataListdata,IdsList){
    let commentsMapwithID = new Map();
       dataListdata.forEach(function(element,index){
            if(IdsList.includes(element.id)){
                commentsMapwithID.set(element.id, element.approverComments);
            }
        });  

    return commentsMapwithID;
   }

   disableCheckBox(fieldname){
    this.template.querySelectorAll('lightning-input').forEach(comboname => {
        if(comboname.name === fieldname)
            comboname.checked = false;               
        });
   }

   cleardatevalues(fieldname){
    this.template.querySelectorAll('lightning-input').forEach(comboname => {
        if(comboname.name === fieldname)
            comboname.value = null;               
        });
   }
    //disable valid To if final price / price level is given  or vise versa
    checkData(event){
        var butnName=event.target.name;
       
        if(butnName == 'FinalPrice' && this.globalFinalPrice <= 0 &&  this.FinalPriceCheckBox == true){
            this.FinalPriceCheckBox= false;
            this.disableCheckBox('FinalPriceConfirm');
        }
    }

   /* renderedCallback(){
        console.log('calling rensercall back');
        if(this.updatePrice ===true ){
            if(this.trackDataSaved === true && this.cbuOutput === false){
                if( this.trackEditedDate === true){
                    this.disableInputField('FinalPrice',true);
                    this.disableInputField('PricingLevel',true);
                }
                if(this.trackPriceEdite === true)
                    this.disableInputField('ValidTo',true);
            }
            if(this.trackDataSavedCBU === true && this.cbuOutput === true){
                if( this.trackEditedDateCBU === true){
                    this.disableInputField('FinalPrice',true);
                    this.disableInputField('PricingLevel',true);
                }
                if(this.trackPriceEditeCBU === true)
                    this.disableInputField('ValidTo',true);
            }
        }
    }*/

    //update discount and temp valid from and valid to for the selected records(filtered records)
    updatePricevalue(event){
        var butnName=event.target.name;
        console.log('event name---'+butnName);       

        if(butnName === 'popUpPriceUpdate'){
            this.updatePrice=true;
        }

        if(butnName === 'FinalPriceConfirm'){
            if(this.globalFinalPrice > 0 && this.globalFinalPrice != null)
                this.FinalPriceCheckBox=event.target.checked;
            else if(this.globalFinalPrice <= 0 && this.globalFinalPrice != null && event.target.checked) {
                this.showToast('error','error occured','Price sholud be greater than 0');
                this.FinalPriceCheckBox = false;
                this.disableCheckBox('FinalPriceConfirm');
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
            this.globalFinalPrice=0;
            this.globalcomments='';
            this.globalValidDate=null;
            this.globalValidFrom=null;
            this.ValidToCheckBox=false;
            this.ValidFromCheckBox=false;  
            this.FinalPriceCheckBox=false;         
        }
        
        if(butnName === 'FinalPrice'){
            this.globalFinalPrice=event.target.value;           
        }

        if(butnName === 'comments')
            this.globalcomments=event.target.value;
        
       
             
        if(butnName === 'Save'){
            if(this.globalcomments == '' || this.globalcomments == null)
                this.showToast('error','Please enter comments before saving','');
            else{
                this.updatePrice=false;
                if(this.currentCustomer === 'Direct'){ 
                    this.updateDirectPrice();
                }
                if(this.currentCustomer === 'Reseller'){  
                    this.updateResellerPrice();
                } 
                this.globalFinalPrice=0;
                this.globalPriceLevel=0;
                this.globalcomments='';
                this.globalValidDate=null;
                this.globalValidFrom=null;
                this.ValidToCheckBox=false;
                this.ValidFromCheckBox=false;  
                this.FinalPriceCheckBox=false;    
            }

        }

    }    
   

        updateDirectPrice(){ 
            if(this.globalValidFrom != null)     
                var globalValidfromdate = new Date(this.globalValidFrom);
            
            if(this.globalValidDate != null)
                var globalValidToDate = new Date(this.globalValidDate);

            for(let key=0; key<this.DirectToChild.length;key++){
                if(this.DirectToChild[key].recordMode || this.DirectToChild[key].trackDateEdit){
                    for(let keymain=0;keymain<this.directCustData.length;keymain++){
                        if(this.DirectToChild[key].id === this.directCustData[keymain].id){
                            var fields = this.DirectToChild[key].fields.split(';'); 
                            var tempValidStart = new Date(this.DirectToChild[key].startDate);
                            var tempValidend = new Date(this.DirectToChild[key].endDate);
                            var validStartDt = new Date(this.DirectToChild[key].directValidFrom);
                            var validEndDt = new Date(this.DirectToChild[key].directValidTo);
                           

                            if(this.globalFinalPrice != 0 && this.globalFinalPrice != this.directCustData[keymain].finalPrice && this.FinalPriceCheckBox == true){
                                this.DirectToChild[key].finalPrice=this.globalFinalPrice;
                                this.directCustData[keymain].finalPrice=this.globalFinalPrice;
                            }
                            if(this.globalValidFrom != this.directCustData[keymain].startDate && this.ValidFromCheckBox == true && this.globalValidFrom != null &&  globalValidfromdate <= tempValidend && globalValidfromdate >= validStartDt && globalValidfromdate <= validEndDt){
                                this.DirectToChild[key].startDate=this.globalValidFrom;
                                this.directCustData[keymain].startDate=this.globalValidFrom;
                            }
                            if(this.globalValidDate != this.directCustData[keymain].endDate && this.ValidToCheckBox == true && this.globalValidDate != null && globalValidToDate >= tempValidStart && globalValidToDate >= validStartDt && globalValidToDate <= validEndDt){
                                this.DirectToChild[key].endDate=this.globalValidDate;
                                this.directCustData[keymain].endDate=this.globalValidDate;
                            }
                            
                            //if(this.loginuser === 'Customer Opps Team' && this.globalcomments !=''){
                            if( !this.loginuser  && this.globalcomments !=''){
                                    this.DirectToChild[key].submitterComments=this.DirectToChild[key].submitterComments+' '+this.globalcomments;
                            this.directCustData[keymain].submitterComments=this.directCustData[keymain].submitterComments+' '+this.globalcomments;
                            }
                            //if((this.loginuser === 'Customer Opps Approver 2' || this.loginuser === 'Customer Opps Approver 1') && this.globalcomments !=''){
                            if((this.loginuser ) && this.globalcomments !=''){
                                    this.DirectToChild[key].approverComments=this.DirectToChild[key].approverComments+' '+this.globalcomments;
                            this.directCustData[keymain].approverComments=this.directCustData[keymain].approverComments+' '+this.globalcomments;
                            }

                        }
                    }
                }
            }
        }

        updateResellerPrice(){    
            if(this.globalValidFrom != null)     
                var globalValidfromdate = new Date(this.globalValidFrom);
            
            if(this.globalValidDate != null)
                var globalValidToDate = new Date(this.globalValidDate);

            for(let key=0; key<this.resellerToChild.length;key++){
                if(this.resellerToChild[key].recordMode || this.resellerToChild[key].trackDateEdit){
                    for(let keymain=0;keymain<this.resellerCustData.length;keymain++){
                        if(this.resellerToChild[key].id === this.resellerCustData[keymain].id){
                            var fields = this.resellerToChild[key].fields.split(';'); 
                            var tempValidStart = new Date(this.resellerToChild[key].startDate);
                            var tempValidend = new Date(this.resellerToChild[key].endDate);

                            if(this.globalFinalPrice != 0 && this.globalFinalPrice != this.resellerCustData[keymain].finalPrice && this.FinalPriceCheckBox == true){
                                this.resellerToChild[key].finalPrice=this.globalFinalPrice;
                                this.resellerCustData[keymain].finalPrice=this.globalFinalPrice;
                            }
                            
                            if(this.globalValidFrom != this.resellerCustData[keymain].startDate && this.ValidFromCheckBox == true && this.globalValidFrom != null && globalValidfromdate <= tempValidend){
                                this.resellerToChild[key].startDate=this.globalValidFrom;
                                this.resellerCustData[keymain].startDate=this.globalValidFrom;
                                console.log('--resellerToChild-' + this.resellerToChild[key].startDate);
                            }
                            if(this.globalValidDate != this.resellerCustData[keymain].endDate && this.ValidToCheckBox == true && this.globalValidDate != null && globalValidToDate >= tempValidStart ){
                                this.resellerToChild[key].endDate=this.globalValidDate;
                                this.resellerCustData[keymain].endDate=this.globalValidDate;
                            }

                            //if(this.loginuser === 'Customer Opps Team' && this.globalcomments !==''){
                            if( !this.loginuser  && this.globalcomments !==''){
                                    this.resellerToChild[key].submitterComments=this.resellerToChild[key].submitterComments+' '+this.globalcomments;
                            this.resellerCustData[keymain].submitterComments=this.resellerCustData[keymain].submitterComments+' '+this.globalcomments;
                            }
                            //if((this.loginuser === 'Customer Opps Approver 2' || this.loginuser === 'Customer Opps Approver 1' ) && this.globalcomments !==''){
                            if((this.loginuser ) && this.globalcomments !==''){
                                    this.resellerToChild[key].approverComments=this.resellerToChild[key].approverComments+' '+this.globalcomments;
                            this.resellerCustData[keymain].approverComments=this.resellerCustData[keymain].approverComments+' '+this.globalcomments;
                            }
                        }
                    }
                }   
            } 
        }

    disableInputField(fieldname,disableOrEnable){
        this.template.querySelectorAll('lightning-input').forEach(comboname => {
            if(comboname.name === fieldname)
                comboname.disabled=disableOrEnable;               
            });
    }
    showadvanceFilter(){
        if(this.advanceOption)
            this.advanceOption = false;
        else
            this.advanceOption = true;
    }
    RecalculatePrice(){
        console.log('saving---');
        if(confirm("Click ok to Save changes")){
            var finalData=[];           
            
            this.directCustData.forEach(function(element,index){
                if(element.startDate != element.startDateOld || element.endDate != element.endDateOld  || element.finalPrice != element.finalPriceOld || element.submitterComments != element.submitterCommentsOld)
                    finalData.push(element);    
                
                if(element.startDate != element.startDateOld || element.endDate != element.endDateOld) 
                    element.validDateEdited = true;   

            })
            this.resellerCustData.forEach(function(element,index){
                if(element.startDate != element.startDateOld || element.endDate != element.endDateOld  || element.finalPrice != element.finalPriceOld || element.submitterComments != element.submitterCommentsOld)
                    finalData.push(element);     
                if(element.startDate != element.startDateOld || element.endDate != element.endDateOld) 
                    element.validDateEdited = true;   
                
                if(element.startDate != element.startDateOld || element.endDate != element.endDateOld) 
                    element.validDateEdited = true;  
                
            })

            console.log('- finalData.length ---'+JSON.stringify(finalData));
            if(finalData.length != 0)  
                this.updateDatabase(finalData );
        }
    }

    // update to data base when data changed
    updateDatabase(finalData){
        console.log('saving data base---');
        this.loadSpinner(true, 'Refreshing');

        recalculationdata({wrapPBDataList : finalData , isMidDay:  this.cbuOutput , curDashboardDate : this.dateFilterValue ,customerType : this.currentCustomer})
        .then(result =>{
            this.loadSpinner(false, 'done');
            console.log('save to data base'+JSON.stringify(result));
            //updating new values after recalculation 
            var resellerdata=this.sortData('customerName','asc',result.reseller.resellerdata);
            var directData=this.sortData('customerName','asc',result.direct.directdata);
            this.resellerCustData = JSON.parse(JSON.stringify(resellerdata));
            this.directCustData = JSON.parse(JSON.stringify(directData));

			this.resellerToChild=JSON.parse(JSON.stringify(resellerdata));
            this.DirectToChild=JSON.parse(JSON.stringify(directData));

            if(this.cbuOutput && this.cbuMainData !== undefined){
                this.cbuMainData.reseller.resellerdata=result.reseller.resellerdata;
                this.cbuMainData.direct.directdata=result.direct.directdata;
            }
            if(!this.cbuOutput && this.midDayMainData !== undefined){
                this.midDayMainData.reseller.resellerdata=result.reseller.resellerdata;
                this.midDayMainData.direct.directdata=result.direct.directdata;
            }

            if(this.cbuOutput === true && this.trackDataSavedCBU === true  ){
                this.trackDataSavedCBU=false;
                this.trackPriceEditeCBU = null;
                this.trackEditedDate = null;
            }
            if(this.cbuOutput === false && this.trackDataSaved === true  ){
                this.trackDataSaved = false;
                this.trackPriceEdite = null;
                 this.trackEditedDateCBU = null;
            }
            //clear all the values which were selected in the picklist
           // this.resetToinitialvalues();
           this.filterdatatoChild();
        })
        .catch(error =>{
            console.log('error occured'+error);
            this.loadSpinner(false, 'done');
            this.showToast('error','error occured',error);
        })
    }

    

    RecalculatePriceLocal(){
        this.loadSpinner(true, 'Calculating...');
        if(this.currentCustomer === 'Direct'){
            for(let key=0; key<this.DirectToChild.length;key++){
                if(this.DirectToChild[key].recordMode || this.DirectToChild[key].trackDateEdit){
                    for(let keymain=0;keymain<this.directCustData.length;keymain++){
                        if(this.DirectToChild[key].id === this.directCustData[keymain].id){
                            console.log('---direct---');
                            var directTemp =this.template.querySelector('c-re_custom-opp-direct').recalculateprice(this.DirectToChild[key]);
                            this.DirectToChild[key] = JSON.parse(JSON.stringify(directTemp));
                            this.directCustData[keymain] = JSON.parse(JSON.stringify(directTemp));
                        }
                    }
                }
            }

        }
        if(this.currentCustomer === 'Reseller'){
            for(let key=0; key<this.resellerToChild.length;key++){
                if(this.resellerToChild[key].recordMode || this.resellerToChild[key].trackDateEdit){
                    for(let keymain=0;keymain<this.resellerCustData.length;keymain++){
                        if(this.resellerToChild[key].id === this.resellerCustData[keymain].id){
                            console.log('---Reseller---');
                            var resllerTemp =this.template.querySelector('c-re_custom-opp-reseller').recalculateprice(this.resellerToChild[key]);
                            this.resellerToChild[key] = JSON.parse(JSON.stringify(resllerTemp));
                            this.resellerCustData[keymain] = JSON.parse(JSON.stringify(resllerTemp));
                        }
                    }
                }
            }
        }
        this.loadSpinner(false, 'Done...');
    }

    /*Refresh(){
        this.connectedCallback();
        this.loadSpinner(true, 'Refreshing');
    }*/
    //Navigation to salesforce report
    exportdata(evt){ 
        if (confirm("Click ok to Export data to GSAP ")){
            this.exportButton = true;
            this.retryButton = true;
            this.loadSpinner(true, 'Opening..');
            exportReport({ datefilter:this.dateFilterValue ,isMidDay : this.cbuOutput, retryOrexport : true})
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
    

    //Filter the data
    filterdatatoChild(){
        console.log('inside filter data---'+this.locSearchText);
        var localdata=[];
        if(this.currentCustomer === 'Direct'){
            if( this.trackSoldto == 'All' && this.trackStatus == 'All' &&  this.trackCalModel == 'All' && this.custAll && this.locAll && this.prodAll &&  this.AMAll ){
                this.DirectToChild =JSON.parse(JSON.stringify(this.directCustData));
            }
            else
            {
                this.DirectToChild =[];  
                localdata=JSON.parse(JSON.stringify(this.directCustData));
                this.DirectToChild= JSON.parse(JSON.stringify(this.checkOtherfiltes(localdata)));  
            }        

        }
        if(this.currentCustomer === 'Reseller'){
            if( this.trackSoldto == 'All' && this.trackStatus == 'All' &&  this.trackCalModel == 'All' && this.custAll && this.locAll && this.prodAll &&  this.AMAll ){
                this.resellerToChild =JSON.parse(JSON.stringify(this.resellerCustData));
            }
            else
            {
                this.resellerToChild =[];  
                localdata=JSON.parse(JSON.stringify(this.resellerCustData));
                this.resellerToChild=JSON.parse(JSON.stringify(this.checkOtherfiltes(localdata)));
            } 
            
        }
    }

    //This method will check all the filters once the value changed in any one of the filters
    checkOtherfiltes(localdata ){
       // var plantfilter=this.trackFilterplant;
       var locationnames=this.selectedLocations;
        var materialnames=this.selectedMaterials;
        var amcodeList=this.selectedAMcode;
        var soldto=this.trackSoldto;
        var customernames=this.selectedcustomerName;
        var status=this.trackStatus;
        var CalLogic = this.trackCalModel;

        if(this.trackCalModel !== 'All'){
            var tempdatareseller=[];
            localdata.forEach(function(element, index){ 
                if(element.calculationLogic === CalLogic ){    
                    tempdatareseller.push(element);
                }
            })
            localdata=tempdatareseller;
        }

        if(this.trackSoldto !== 'All'){
            var tempdatareseller=[];
            localdata.forEach(function(element, index){ 
                if(element.soldTo === soldto ){    
                    tempdatareseller.push(element);
                }
            })
             localdata=tempdatareseller;
         }

         //console.log('amcodeList--'+JSON.stringify(amcodeList));
         if(this.AMAll==false){
            var tempdataDirect=[];
            localdata.forEach(function(element, index){ 
                //console.log('element--'+JSON.stringify(element));
                if(amcodeList.includes(element.amCode)){    
                    tempdataDirect.push(element);
                }
            })
             localdata=tempdataDirect;
         }

         if(this.custAll==false){
            var tempdataDirect=[];
            localdata.forEach(function(element, index){ 
                if(customernames.includes(element.customerNameSoldTo)){    
                    tempdataDirect.push(element);
                }
            })
             localdata=tempdataDirect;
         }

         if(this.locAll == false){
            console.log('selcted loc filtering--'+locationnames);
            var tempdataDirect=[];
            localdata.forEach(function(element, index){ 
               // console.log('element--'+JSON.stringify(element));
                if(locationnames.includes(element.Location))
                {    
                    tempdataDirect.push(element);
                }
            })
             localdata=tempdataDirect;
         }

         if(this.prodAll == false){
            var tempdataDirect=[];
            localdata.forEach(function(element, index){ 
                if(materialnames.includes(element.product)){    
                    tempdataDirect.push(element);
                }
            })
             localdata=tempdataDirect;
         }

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
    //Submit all records to approval Process / to review  
    submitForReview(){
        if(this.checkboxList.length <= 0)
            this.showToast('error','error occured','select the records before submitting for Approval');
       else{ 
           console.log('selected values--'+this.checkboxList);
            this.loadSpinner(true, 'Submitting Records');

            submitForApprove({recordsTOsubmit : this.checkboxList , isMidDay : this.cbuOutput , dateFilter:this.dateFilterValue ,customerType : this.currentCustomer})
            .then(result=>{
                console.log('result in submiting--'+result.status);
                this.loadSpinner(false,'Submitted');
                if(result.status === 'true'){
                    this.checkboxList=[];
                    //updating new values after submitting the record
                    var resellerdata=this.sortData('customerName','asc',result.reseller.resellerdata);
                    var directData=this.sortData('customerName','asc',result.direct.directdata); 
                    this.resellerCustData = JSON.parse(JSON.stringify(resellerdata));
                    this.directCustData = JSON.parse(JSON.stringify(directData));
    
                    this.resellerToChild=JSON.parse(JSON.stringify(resellerdata));
                    this.DirectToChild=JSON.parse(JSON.stringify(directData));
                    this.showToast('success','Submitted','Record Submitted for Review');
    
                        
                    if(this.cbuOutput && this.cbuMainData !== undefined){
                        this.cbuMainData.reseller.resellerdata=resellerdata;
                        this.cbuMainData.direct.directdata=directData;
                    }
                    if(!this.cbuOutput && this.midDayMainData !== undefined){
                        this.midDayMainData.reseller.resellerdata=resellerdata;
                        this.midDayMainData.direct.directdata=directData;
                    }

                    //clear all the values which were selected in the picklist
                    //this.resetToinitialvalues();
                    this.filterdatatoChild();
                }
            else{
                this.showToast('error','error occured',result.message);           
                }
            })
            .catch(error=>{
                console.log('error in submiting--'+JSON.stringify(error));
                this.showToast('error','error occured',error.body.message);
                this.loadSpinner(false, 'error occured');
            })
        }
    }

    checkNewContracts(){
        this.loadSpinner(true, 'Checking...');
        checkNewContracts({})
        .then(result =>{
          console.log(JSON.stringify(result));
          if(result.error != 'true')
            this.showToast('success','Job triggered',result.message);
          else
            this.showToast('error',' ',result.message);
          this.loadSpinner(false, '');
        })
        .catch(error =>{
            console.log('error in submiting--'+JSON.stringify(error));
            this.showToast('error','error occured',error.body.message);
            this.loadSpinner(false, 'error occured');
        })

    }
    refreshCBU(){
        if (confirm("Updates the Latest CBU values")){
                this.loadSpinner(true, 'Updating ..');
            updateLatestCBU({})
            .then(result =>{
                console.log(JSON.stringify(result));
                if(result.Error === 'false'){
                    getDatefilter({datefilter : this.dateFilterValue ,isMidDay : this.cbuOutput ,customerType : this.currentCustomer})
                    .then(result=>{  
                        this.cbuMainData=result;
                        console.log('---'+JSON.stringify(result));
                        this.updateArraylist(result);
                        this.loadSpinner(false, 'Updated ..');

                    })
                    .catch(error=>{
                        console.log('error occured');
                        this.showToast('error','error occured',error.body.message);
                        this.loadSpinner(false, 'error occured');

                    })
                }
                else{
                    this.showToast('error','error occured',result.message);
                    this.loadSpinner(false, 'Updated ..');
                }
            })
            .catch(error=>{
                console.log(JSON.stringify(error));
                this.loadSpinner(false, 'Updated ..');
                this.showToast('error','error occured',error);
            })
        }
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