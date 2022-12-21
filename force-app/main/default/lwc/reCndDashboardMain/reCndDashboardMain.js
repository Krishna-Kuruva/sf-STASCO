import { LightningElement, track } from 'lwc';
import getCanadaFilters from '@salesforce/apex/RE_CND_RackDetail_Controller.getCanadaFilters';
import checkFutureRecord from '@salesforce/apex/RE_CND_RackDetail_Controller.checkFutureRecord';
import customStyle from '@salesforce/resourceUrl/RE_CND_DashboardFilter';
import { loadStyle } from 'lightning/platformResourceLoader';
import TIMEZONE from '@salesforce/i18n/timeZone';

export default class ReCndDashboardMain extends LightningElement {

 
    @track selectedProductType = 'Y';
    @track selectedStatus = 'All';
    @track selectedClassification='All';
    @track selectedDate;
    @track selectedCustomerType = 'Unbranded';
    
    @track updateTodayPrice = false;
    @track tommorrowDate;
    @track todaysDate;
    @track PricingAccess=false;
    @track GSAPAccess=false;

    @track showFilterBar=false;
    @track isLoading=false;
    @track lstLocale = TIMEZONE;

    @track ProductClassification= [{ label: 'All', value: 'All' },
    { label: 'Gasoline', value: 'Gasoline' },
    { label: 'Gas Oil (Diesel)', value: 'Gas Oil' }];

    @track CustomerTypeList = [{ label: 'Branded', value: 'Branded' },
    { label: 'Unbranded', value: 'Unbranded' },
    { label: 'SFJ', value: 'SFJ' }];

    @track productTypeList = [{ label: 'All', value: 'All' },
    { label: 'Base', value: 'Y' },
    { label: 'Derived', value: 'N' }];

    @track statusList = [{ label: 'All', value: 'All' },
    { label: 'Draft', value: 'DR' },
    { label: 'Ready to Upload', value: 'RU' },
    { label: 'Uploaded', value: 'UP' },
    { label: 'Failed', value: 'FA' },
    { label: 'Upload not allowed', value: 'UN' }];

    @track rackSearchText;
    @track rackListToSearch=[];
    @track rackListToShow=[];
    @track showRackGroup=false;
    @track rackAll=true;

    @track groupSearchText;
    @track groupListToSearch=[];
    @track maingroupListToSearch=[];
    @track groupListToShow=[];

    @track gasolineList=[];
    @track gasOilList=[];
    @track showProductGroup=false;
    @track pgAll=true;

    @track locSearchText;
    @track locListToSearch=[];
    @track locListToShow=[];
    @track showLocList=false;
    @track locAll=true;

    @track prodSearchText;
    @track prodListToSearch=[];
    @track prodListToShow=[];
    @track showProdList=false;
    @track prodAll=true;
    @track isGSAPload=false;



    getLoggedInUserDate(dt)
    {
        if(dt === '')
        {
            var mydate = new Date().toLocaleDateString("en-GB", {timeZone: this.lstLocale});
            var splitMydate = mydate.split('/');
            if(splitMydate.length > 0)
            {
                var splitDay = splitMydate[0];
                var splitMonth = splitMydate[1];
                var splityear = splitMydate[2];
                var dtToday = splityear+'-'+ splitMonth +'-'+splitDay;  
                return dtToday;
            }
            else
            {
                splitMydate = mydate.split('-');
                var splitDay = splitMydate[0];
                var splitMonth = splitMydate[1];
                var splityear = splitMydate[2];
                var dtToday = splityear+'-'+ splitMonth +'-'+splitDay;  
                return dtToday;
            }
        }
        else
        {
            var nextDate =  new Date(dt);
            nextDate.setDate(nextDate.getDate() + 1);
            var day = String(nextDate.getDate()).padStart(2, '0');
            var month = String(nextDate.getMonth() + 1).padStart(2, '0'); 
            var year = nextDate.getFullYear();        
            nextDate = year+'-'+ month +'-'+day;
            return nextDate;
        }
    }

    gsaploading()
    {
        console.log('gsaploading--'+true);
        this.isGSAPload=true;
    }

    clearFilterMain()
    {
        this.isGSAPload=false;
        this.groupSearchText='';
        this.locSearchText='';
        this.prodSearchText='';
        this.rackSearchText='';

        this.selectAllLocation();
        this.selectAllProduct();
        this.selectAllGroup();
        this.selectAllRack();
        this.selectedClassification='All';
        this.selectedProductType ='All';
        this.selectedStatus ='All' ;
        this.pgAll=true;
        this.locAll=true;
        this.prodAll=true; 
        this.rackAll=true;
    }

    clearFilter(event)
    {
       console.log('clearFilter---'+event.target.name+'--value--'+event.target.value); 
       new Promise(
        (resolve,reject) => {
        this.groupSearchText='';
          this.locSearchText='';
          this.prodSearchText='';
          this.rackSearchText='';
  
          this.handleLocationSelect(event);
          this.handleProductSelect(event);
          this.handleRackSelect(event);
          //this.handleGroupSelect(event);
          this.selectAllGroup();
          this.selectedClassification='All';
          this.selectedProductType ='All';
          this.selectedStatus ='All';
         
          this.rackListToShow=this.rackListToSearch;
	      this.locListToShow=this.locListToSearch;
	      this.prodListToShow=this.prodListToSearch;
         // console.log('clearFilter -- rackListToShow--'+JSON.stringify(this.rackListToShow));
          this.template.querySelector('c-re-cnd-price-list').clearfilter(); 
        resolve(
      );
      reject();
      })
      .then()
            
    }

    connectedCallback() 
    {
        Promise.all([
            loadStyle(this, customStyle)
        ])
       console.log('ain connected callback-------');
       var today = this.getLoggedInUserDate('');
        this.todaysDate=today;
        var nextDate = this.getLoggedInUserDate(today);
        this.tommorrowDate = nextDate;
       // this.selectedDate = nextDate;

       
        checkFutureRecord()
            .then(result => {
                if(result==true)
                {
                    this.selectedDate = this.tommorrowDate;  
                }
                else
                {
                    this.selectedDate = this.todaysDate;  
                }
                this.getLatestFilters();
            })
            .catch(error => {
                console.log('connected callback error occured--'+error.message);
                //this.showToast('error','error occured',error.body.message);
                //this.loadSpinner(false, 'error occured');
            })
     
    }

    dateChanged(event) {
        try {
            console.log('dateChanged called--');
            this.rackListToSearch=[];
            this.rackListToShow=[];
            this.groupListToSearch=[];
            this.maingroupListToSearch=[];
            this.groupListToShow=[];
            this.gasolineList=[];
            this.gasOilList=[];
            this.locListToSearch=[];
            this.locListToShow=[];
            this.prodListToSearch=[];
            this.prodListToShow=[];
            this.selectedDate = event.target.value;
            this.getLatestFilters();
            this.template.querySelector('c-re-cnd-price-list').handledatechange(event.target.value);
        }
        catch (error) {
            this.showErrorToast(error.body.message);
        }
    }


    getLatestFilters()
    {
      //  console.log('getLatestFilters--date'+this.selectedDate);
        getCanadaFilters({ datefilter:this.selectedDate})
            .then(result => {

                let alloption = { label: 'All', value: 'All' };
                this.PricingAccess = result.PricingAccess;
                this.GSAPAccess=result.GSAPAccess;

                if(result.GSAPProcessingStatus != 'Processing')
                this.isGSAPload=false;
                else
                this.isGSAPload=true;
                
                const allRack={isSelected:true , rackGroup:'All'};
                this.rackListToSearch.push(allRack);
                for (const rack2 of result.racklist) {
                    const rack1 = {isSelected:true , rackGroup:rack2};
                    this.rackListToSearch = [...this.rackListToSearch, rack1];
                }
                this.rackListToShow=this.rackListToSearch;


                const allGroup={isSelected:true , prodGroup:'All'};
                this.groupListToSearch.push(allGroup);
                for (const group of result.prodGroupList) {
                    const pg = {isSelected:true , prodGroup:group};
                    this.groupListToSearch = [...this.groupListToSearch, pg];
                    this.maingroupListToSearch=this.groupListToSearch.slice(0);
                }
                this.groupListToShow=this.groupListToSearch;
                
                for (const gasoline of result.gasolineList) {
                    const gaso = {isSelected:true , prodGroup:gasoline};
                    this.gasolineList = [...this.gasolineList, gaso];
                }

                for (const diesel of result.dieselList) {
                    const gasOil = {isSelected:true , prodGroup:diesel};
                    this.gasOilList = [...this.gasOilList, gasOil];
                }


                const allLoc={isSelected:true , location:'All'};
                this.locListToSearch.push(allLoc);
                for (const loc of result.locList) {
                    const loc1 = {isSelected:true , location:loc};
                    this.locListToSearch = [...this.locListToSearch, loc1];
                }
                this.locListToShow=this.locListToSearch;
				
				const allProd={isSelected:true , product:'All'};
                this.prodListToSearch.push(allProd);
                for (const prod of result.prodList) {
                    const prod1 = {isSelected:true , product:prod};
                    this.prodListToSearch = [...this.prodListToSearch, prod1];
                }
                this.prodListToShow=this.prodListToSearch;
            })
            .catch(error => {
                console.log('connected callback error occured--'+error.message);
                //this.showToast('error','error occured',error.body.message);
                //this.loadSpinner(false, 'error occured');
            })
    }
   
    
    handleGroupSearch(event){
        this.groupSearchText=event.detail.value.toLowerCase();
        var x;
        var y=[];
        
        for(x of this.groupListToSearch)
        {
          var textToSearch = x.prodGroup.toLowerCase();
         var  isAvailable=textToSearch.includes(this.groupSearchText);
         if(isAvailable)
          {
            y.push(x);
          }
         }
        this.groupListToShow=y;
      }

      handleRackSearch(event)
      {
        this.rackSearchText=event.detail.value.toLowerCase();
        var x;
        var y=[];
        
        for(x of this.rackListToSearch)
        {
          var textToSearch = x.rackGroup.toLowerCase();
         var  isAvailable=textToSearch.includes(this.rackSearchText);
         if(isAvailable)
          {
            y.push(x);
          }
         }
        this.rackListToShow=y;
      }

      handleLocationSearch(event){
        this.locSearchText=event.detail.value.toLowerCase();
        var x;
        var y=[];
        
        for(x of this.locListToSearch)
        {
          var textToSearch = x.location.toLowerCase();
         var  isAvailable=textToSearch.includes(this.locSearchText);
         if(isAvailable)
          {
            y.push(x);
          }
         }
        this.locListToShow=y;
      }

      handleProductSearch(event){
        this.prodSearchText=event.detail.value.toLowerCase();
        var x;
        var y=[];
        
        for(x of this.prodListToSearch)
        {
          var textToSearch = x.product.toLowerCase();
         var  isAvailable=textToSearch.includes(this.prodSearchText);
         if(isAvailable)
          {
            y.push(x);
          }
         }
        this.prodListToShow=y;
      }
      handleLocationSelect(event)
      {
        console.log('handleLocationSelect name--'+event.target.name+'--value--'+event.target.value);
        
        if(event.target.name=='All')
        {  
            for(var l2=0;l2<this.locListToSearch.length;l2++)
            {
                if(event.target.value)
                this.locListToSearch[l2].isSelected=false;
                
                 else
                 this.locListToSearch[l2].isSelected=true;
            }
        }
        else
        {
            for(var l2=0;l2<this.locListToShow.length;l2++)
            {
                if(this.locListToShow[l2].location==event.target.name)
                {
                if(event.target.value)
                    this.locListToShow[event.target.dataset.record].isSelected=false;
                
                else
                    this.locListToShow[event.target.dataset.record].isSelected=true;
                
                }
            }
        }
      }

      handleRackSelect(event)
      {
        if(event.target.name=='All')
        {  
            for(var l2=0;l2<this.rackListToSearch.length;l2++)
            {
                if(event.target.value)
                this.rackListToSearch[l2].isSelected=false;
                
                 else
                 {
                 this.rackListToSearch[l2].isSelected=true;
                 }
            }
        }
        else
        {
            for(var l2=0;l2<this.rackListToShow.length;l2++)
            {
                if(this.rackListToShow[l2].rackGroup==event.target.name)
                {
                if(event.target.value)
                    this.rackListToShow[event.target.dataset.record].isSelected=false;
                
                else
                    this.rackListToShow[event.target.dataset.record].isSelected=true;
                
                }
            }
        }
      }


      handleProductSelect(event)
      {
        if(event.target.name=='All')
        {  
            for(var l2=0;l2<this.prodListToSearch.length;l2++)
            {
                if(event.target.value)
                this.prodListToSearch[l2].isSelected=false;
                
                 else
                 this.prodListToSearch[l2].isSelected=true;
            }
        }
        else
        {
            for(var l2=0;l2<this.prodListToShow.length;l2++)
            {
                if(this.prodListToShow[l2].product==event.target.name)
                {
                if(event.target.value)
                    this.prodListToShow[event.target.dataset.record].isSelected=false;
                
                else
                    this.prodListToShow[event.target.dataset.record].isSelected=true;
                
                }
            }
        }
      }
      handleGroupSelect(event)
      {
        if(event.target.name=='All')
        {  
            for(var l2=0;l2<this.groupListToSearch.length;l2++)
            {
                if(event.target.value)
                this.groupListToSearch[l2].isSelected=false;
                
                 else
                 this.groupListToSearch[l2].isSelected=true;
            }
        }
        else
        {
            for(var l2=0;l2<this.groupListToShow.length;l2++)
            {
                if(this.groupListToShow[l2].prodGroup==event.target.name)
                {
                if(event.target.value)
                    this.groupListToShow[event.target.dataset.record].isSelected=false;
                
                else
                    this.groupListToShow[event.target.dataset.record].isSelected=true;
                
                }
            }
        }
      }

      applyProdGroupFilter()
      {
          var selectedGroup=[];
          for(var l2=0;l2<this.groupListToSearch.length;l2++)
            {
                if(this.groupListToSearch[l2].isSelected)
                {
                    selectedGroup.push(this.groupListToSearch[l2].prodGroup);
                }
            } 
            if(selectedGroup.length<this.groupListToSearch.length-1)
                this.pgAll=false;
            else
            this.pgAll=true;
            this.template.querySelector('c-re-cnd-price-list').groupchange('Product Group',selectedGroup ,this.pgAll); 
      }

      applyRackFilter()
      {
          var selectedRack=[];
          for(var l2=0;l2<this.rackListToSearch.length;l2++)
            {
                if(this.rackListToSearch[l2].isSelected)
                {
                    selectedRack.push(this.rackListToSearch[l2].rackGroup);
                }
            } 
            if(selectedRack.length<this.rackListToSearch.length-1)
                this.rackAll=false;
            else
            this.rackAll=true;
            this.template.querySelector('c-re-cnd-price-list').groupchange('Rack',selectedRack ,this.rackAll); 
      }

      applyLocationFilter()
      {
          var selectedGroup=[];
          for(var l2=0;l2<this.locListToSearch.length;l2++)
            {
                if(this.locListToSearch[l2].isSelected)
                {
                    selectedGroup.push(this.locListToSearch[l2].location);
                }
            } 
            if(selectedGroup.length<this.locListToSearch.length-1)
                this.locAll=false;
            else
            this.locAll=true;
            this.template.querySelector('c-re-cnd-price-list').groupchange('Location',selectedGroup ,this.locAll); 
      }
      applyProductFilter()
      {
          var selectedGroup=[];
          for(var l2=0;l2<this.prodListToSearch.length;l2++)
            {
                if(this.prodListToSearch[l2].isSelected)
                {
                    selectedGroup.push(this.prodListToSearch[l2].product);
                }
            } 
            if(selectedGroup.length<this.prodListToSearch.length-1)
                this.prodAll=false;
            else
            this.prodAll=true;
            this.template.querySelector('c-re-cnd-price-list').groupchange('Product',selectedGroup ,this.prodAll); 
      }
      focusSearch(event)
      {
        if(event.target.name=='Group')
        this.showProductGroup=true; 

        else if(event.target.name=='Location')
        this.showLocList=true; 

        else if(event.target.name=='Product')
        this.showProdList=true; 

        else if(event.target.name=='Rack')
        this.showRackGroup =true
      }

    closeSearchFilter(event)
      {
        if(event.target.name=='Group')
        this.showProductGroup=false; 

        else if(event.target.name=='Location')
        this.showLocList=false; 

        else if(event.target.name=='Product')
        this.showProdList=false; 

        else if(event.target.name=='Rack')
        this.showRackGroup =false;
      }



    handleFilterBar(event)
    {
        this.showFilterBar=event.detail;
    }
    closeFilter()
    {
        this.showFilterBar =false;
    }
    handleToggle() {
        try {
            if (this.updateTodayPrice == false) 
            {
                var today = this.getLoggedInUserDate('');

                this.selectedDate = today;
                this.updateTodayPrice = true;
                this.template.querySelector('c-re-cnd-price-list').handledatechange(this.selectedDate);
            }
            else {
                this.updateTodayPrice = false;
                this.selectedDate = this.tommorrowDate;
                this.template.querySelector('c-re-cnd-price-list').handledatechange(this.selectedDate);
            }
        }
        catch (error) {
            console.log('handleToggle error--'+error.body.message);
        }

    }


    CustomerTypeFilter(event) {
        try {
            if(event.target.name=='CustomerType')
            this.selectedCustomerType =event.target.value;
           // if(event.target.name=='Rack')
            //this.selectedRack =event.target.value;
            if(event.target.name=='ProductType')
            this.selectedProductType =event.target.value;
            if(event.target.name=='Status')
            this.selectedStatus =event.target.value;
            if(event.target.name=='Classification')
            {
            this.selectedClassification =event.target.value;
            if(event.target.value=='All')
            {
               		this.groupListToSearch	=	this.maingroupListToSearch;
					this.groupListToShow	=	this.maingroupListToSearch;
            }
			
			else if(event.target.value=='Gasoline')
			{
					this.groupListToSearch	=	this.gasolineList;
					this.groupListToShow	=	this.gasolineList;
			}
			
			else if(event.target.value=='Gas Oil')
			{
					this.groupListToSearch	=	this.gasOilList;
					this.groupListToShow	=	this.gasOilList;
			}
            }
            this.template.querySelector('c-re-cnd-price-list').filterchange(event.target.name, event.target.value);
        }
        catch (error) {
            this.showErrorToast(error.body.message);
        }
    }

    

    selectAllLocation()
      {
          for(var l2=0;l2<this.locListToSearch.length;l2++)
            {
                 this.locListToSearch[l2].isSelected=true;
            }
            this.locListToShow=this.locListToSearch;
      }
      selectAllProduct()
      { 
          for(var l2=0;l2<this.prodListToSearch.length;l2++)
            {
                 this.prodListToSearch[l2].isSelected=true;
            }
            this.prodListToShow=this.prodListToSearch;
      }
      selectAllGroup()
      {
        this.groupListToSearch	=	this.maingroupListToSearch;
            /*for(var l2=0;l2<this.groupListToSearch.length;l2++)
            {
                 this.groupListToSearch[l2].isSelected=true;
            }*/
            this.groupListToShow=this.groupListToSearch;
      }
      selectAllRack()
      {
        for(var l2=0;l2<this.rackListToSearch.length;l2++)
            {
                 this.rackListToSearch[l2].isSelected=true;
            }
            this.rackListToShow=this.rackListToSearch;
      }
      

}