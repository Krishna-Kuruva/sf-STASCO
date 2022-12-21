import { LightningElement,track,api } from 'lwc';
import customStyle from '@salesforce/resourceUrl/RE_CND_Detail';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllData from '@salesforce/apex/RE_CND_RackDetail_Controller.getAllData';
import saveRecords from '@salesforce/apex/RE_CND_RackDetail_Controller.saveRecords';
import generateSFJPrices from '@salesforce/apex/RE_CND_RackDetail_Controller.generateSFJPrices';
import uploadToGSAP from '@salesforce/apex/RE_CND_RackDetail_Controller.uploadToGSAP';
import getVersionRecords from '@salesforce/apex/RE_CND_RackDetail_Controller.getVersionRecords';
import getJobStatus from '@salesforce/apex/RE_CND_RackDetail_Controller.getGSAPUploadStatus';
import pricExcDataIntegrityChecks from '@salesforce/apex/RE_CND_RackDetail_Controller.priceExecutnDataIntegrityChecks';
import getSaveStatus from '@salesforce/apex/RE_CND_RackDetail_Controller.getSaveStatus';
import { NavigationMixin } from 'lightning/navigation';
import getStatusOfJobRunAudit from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.getStatusOfJobRunAudit';
import getSAPdownloadData from '@salesforce/apex/RE_CND_RackDetail_Controller.getSAPdownloadData';
import checkFutureRecord from '@salesforce/apex/RE_CND_RackDetail_Controller.checkFutureRecord';
import updatingCancelledJobRunAudit from '@salesforce/apex/RE_CND_RackDetail_Controller.updatingCancelledJobRunAudit';
import {exportCSVFile} from 'c/re_csvgenerator';
import RE_SAPDownloadFileResource from '@salesforce/resourceUrl/RE_SAPDownloadFileResource';

export default class ReCndPriceList extends NavigationMixin(LightningElement)  {
  
  @track listToShow;
  @track mainList;
  @track orignalList;
  @track selectedRecord;
  @track detailIndex=0;
  @track pop
  @track editType;
  @track showPricingDashboard;
  
  @track popUpList =[];
  @track detailList=[];
  @track selectionList=[];
  @track unbrandedIndexList=[];
  @track versionsList=[];
  @track versionMasterList=[];
  @track typeToAdjust=[];

  @track validFromDate;
  @track validToDate;

  @track newAdjustment;
  @track newComment;

  @track adjustmentFromDetail;
  @track commentFromDetail;
  @track uploadType;

  @track showPopUp=false;
  @track showDetails =false;
  @track isSFJ=false;
  @track isAllSelected=false;
  @track allowEditForDate=true;
  @track disableButtons=true;
  @track isLoading=false;
  @track isLoadingGSAP=false;
  @track disableSFJButton=true;
  
  @track noRecord=false;
  @track showStatusBar=false;
  @track filterOption=false;
  @track saveWarning=false;
  @track isGSAP=false;
  @track filterLabel;

  @track brandedList=[];
  @track UNbrandedList=[];
  @track SFJList=[];

  @track brandedListAll=[];
  @track UNbrandedListAll=[];
  @track SFJListAll=[];

  @api datefilter;
  @api customertypefilter;
  @api producttypefilter;
  @api classificationfilter;
  @api statusfilter;
  @api updateTodayPrice;
  @api pricingAccess;
  @api gsapAccess;
  @api isAllPG;
  @api isAllLocation;
  @api isAllProduct;
  @api isAllRack;
  @track selectedRacks=[];
  @track selectedProdGroups=[];
  @track selectedLocations=[];
  @track selectedProducts=[];

  @track showMailList=false;
  @track mapData= [];
  @track isreload =true;
  @track tableClass='fixTableHead';
  @track mailDetail;
  @track opisReport;
  @api todayDate;
  @track isRetry=false;
  @track hasFutureRecord=false;
  @track isPrceDiscrepancyExists = false;
  @track gosolinePrceDiscrpcyResult = [];
  @track gosoilPrceDiscrpcyResult = [];
  @track isGosolineResult = false;
  @track isDieselResult = false;
  @track showProgress=false;
  @track totalUpload;
  @track totalProcessed;
  @track downloadOption = false;
  @track isSapUpload = false;
  @track isAnothrSapUplodInProgres = false;
  @track jobRunName;
  @track jobRunStartDtTime;
  @track disableDwldButton = false;

  @track generateSFJ=false;



  showCompetitorReport()
  {
    
  if(this.opisReport !=undefined)
  {
      this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.opisReport.Record_Id__c,
            objectApiName: 'Report', // objectApiName is optional
            actionName: 'view'
        }
    }).then(url => {
        window.open(url, "_blank");
    });
  }
}


  renderedCallback()
  {
    console.log('renderedCallback--reload--'+this.isreload);
    if(this.isreload != false)
    {
    const queryString = window.location.search;
    //console.log('queryString--'+queryString);
    if(queryString != undefined || queryString != '')
    {
      var urlParams = new URLSearchParams(queryString);
      if(urlParams.has('c__reloadDashboard'))
      {
        var orgURL=window.location.href.split("?");
        //console.log('urlParams--'+urlParams+'--after split--'+orgURL[0]);
         // this.isreload=false;
          window.history.pushState("object or string", "Page Title", orgURL[0]);
          //this.getRecords();
          //window.location.reload(true);
      }
    }
    }
  }

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


connectedCallback() {
   console.log('List connectedCallback called---');
    var today = this.getLoggedInUserDate('');
        this.todaysDate=today;
        var nextDate = this.getLoggedInUserDate(today);
        this.tommorrowDate = nextDate;
  try{
    Promise.all([
      loadStyle(this, customStyle)
      ])
      checkFutureRecord()
      .then(result => {
          if(result==true)
          {
              this.datefilter = this.tommorrowDate;  
          }
          else
          {
              this.datefilter = this.todaysDate;  
          }
        if(this.isreload!=false)
      {
      this.getRecords();
      this.tableClass='fixTableHead'+this.showDetails;
      this.isreload=false;
      }
         
      })
      .catch(error => {
          console.log('connected callback error occured--'+error.message);
          //this.showToast('error','error occured',error.body.message);
          //this.loadSpinner(false, 'error occured');
      })

      
  }
  catch(error)
  {
    this.isLoading=false;
    console.log('connectedCallback error--'+error.message);
  }
} 


hideStatusBar()
  {
      this.showStatusBar=false;
  }
showMail(){
  this.showMailList=true;
}


handleShowStatusBar()
  {
      this.showStatusBar=true;
  }   
generateSFJPrices()
{
  if(this.SFJList.length>0)
  {
    this.showWarningToast('SFJ Records Already Created!!');
  }
  else{
    this.isLoading=true;
  generateSFJPrices({datefilter:this.datefilter})
  .then(result=>{ 
                this.isLoading=false; 
              this.getRecords();
              this.clearFilterAfter();
              this.showSuccessToast('SFJ Records Created.')
              }  )
  .catch(error=>{
                this.isLoading=false;
                console.log('ERROR--'+error.message);
              }) 
  }
  
}


toogleFilter()
{
const selectedEvent = new CustomEvent('handlefilterbar', 
                    {detail: true});
  this.dispatchEvent(selectedEvent);
}

saveRecords()
{
  try
    {
    this.isLoading=true;
    let listToSave=[];
    let x;
    for(x=0;x<this.orignalList.length;x++)
    {
      
      if(this.orignalList[x].Status=='DR')
      {
        var DashboardItem = {
          recordId   :     this.orignalList[x].Id,
          Adjustment   :   this.orignalList[x].Adjustment,
          finalValue   :   this.orignalList[x].finalValue,
          Comment      :   this.orignalList[x]. Comment ,
          custType     :   this.orignalList[x].Group
        }
        listToSave.push(DashboardItem);
      }
    }
    
    if(listToSave.length > 0)
    {
    //  console.log('listToSave--'+JSON.stringify(listToSave));
	  saveRecords({updatedRecords:JSON.stringify(listToSave) ,datefilter:this.datefilter})
  .then(result=>{                            
                this.checkSaveStatus();
                }  )
  .catch(error=>{
                  console.log('Inside error occured'+error.message);
                  this.isLoading=false;
                  console.log(error.message);
                }) 
	}
  else{
    //console.log(' No listToSave--'+JSON.stringify(listToSave));
    this.isLoading=false;
  }
}
catch(error)
  {
    this.isLoading=false;
    console.log(error.message);
  }
}
  
  
   checkSaveStatus()
  {
    //console.log('checkSaveStatus called--');
    let priceExectnPromise = new Promise( (resolve, reject) => {
      let interval = setInterval(() => {                               
          getSaveStatus()
          .then(result => { 
                  console.log('result - checkSaveStatus Method-->'+JSON.stringify(result));                              
                  if(result.saveStatus !='Processing')
                  {
                    if(result.saveStatus =='Completed')
                    {
					          if(result.isSuccess)
					          this.showSuccessToast(result.saveMessage);
					
					          else
					          this.showWarningToast(result.saveMessage);
                    }

                    else if(result.saveStatus =='Partial Complete')
                    this.showWarningToast(result.saveMessage);

                    else 
                    this.showFailedToast('Error While Saving Records!!!');

					          clearInterval(interval);
					          this.getRecords();                  
					          this.clearFilterAfter();     
					          let isIntegrityChekButtnClickd = false;            
					          this.dataIntegrityCheck(isIntegrityChekButtnClickd);  
				          } 
                  })

              .catch(error => {                                     
                  this.isLoading = false;  
                  console.log('error checkSaveStatus -->'+console.error(error));
              });
          }, 10000)
        });
    priceExectnPromise.then();   
  }

showIntegrityCheck(isIntegrityChekButtnClickd)
{
  this.dataIntegrityCheck(isIntegrityChekButtnClickd);
}


dataIntegrityCheck(isIntegrityChekButtnClickd)
{      
  this.isLoading = true;   
  pricExcDataIntegrityChecks({datefilter:this.datefilter})
    .then(result => { 
      if(result != undefined){  
         this.isPrceDiscrepancyExists = result.isPrceDiscrepancyExists;

         if(this.isPrceDiscrepancyExists)
         { 
          let executeGasolineRacks = [];
          let gosolineDiscrpcyResult = []; 
          let dieselDiscrpcyResult = []; 
          this.gosolinePrceDiscrpcyResult = gosolineDiscrpcyResult;
          this.gosoilPrceDiscrpcyResult = dieselDiscrpcyResult;

          executeGasolineRacks.push('montreal');
          executeGasolineRacks.push('toronto');
          executeGasolineRacks.push('belleville');  
          executeGasolineRacks.push('ottawa');  
          executeGasolineRacks.push('kingston');              
          executeGasolineRacks.push('sarnia');  
          executeGasolineRacks.push('london');  
          executeGasolineRacks.push('sault ste marie');                
          executeGasolineRacks.push('edmonton');
          executeGasolineRacks.push('thunder bay');                
          executeGasolineRacks.push('kamloops'); 
          executeGasolineRacks.push('vancouver');    

          for(let j=0; j<executeGasolineRacks.length;j++)
          {
              for(let i=0;i<result.prcngDiffLst.length;i++)
              {
                let returnData = Object.assign({}, result.prcngDiffLst[i]);

                if((returnData.grpclassifictn.toLowerCase() === 'gasoline') && (executeGasolineRacks[j] === returnData.rack.toLowerCase()))
                {
                    if(returnData.rack.toLowerCase() === 'toronto' || returnData.rack.toLowerCase() === 'belleville')
                        returnData.stylClas = "torontoGasolinegrp";
                    else if(returnData.rack.toLowerCase() === 'montreal')
                        returnData.stylClas = "montrealGasolinegrp";
                    else if(returnData.rack.toLowerCase() === 'vancouver')
                        returnData.stylClas = "vancouverGasolinegrp";
                    else if(returnData.rack.toLowerCase() === 'ottawa' || returnData.rack.toLowerCase() === 'kingston')
                        returnData.stylClas = "ottawaGasolinegrp"; 
                    else if(returnData.rack.toLowerCase() === 'sarnia' || returnData.rack.toLowerCase() === 'london' || returnData.rack.toLowerCase() === 'sault ste marie')
                        returnData.stylClas = "sarniaGasolinegrp";  
                    else if(returnData.rack.toLowerCase() === 'edmonton' || returnData.rack.toLowerCase() === 'thunder bay' || returnData.rack.toLowerCase() === 'kamloops')
                        returnData.stylClas = "edmontonGasolinegrp";                                                                            
                    else
                        returnData.stylClas = "notSpecifiedgrp";                                                                                               

                        console.log('returnData-->'+JSON.stringify(returnData));    
                    gosolineDiscrpcyResult.push(returnData);  
                    break;                    
                }
              }
          }
     
          //console.log('gosolineDiscrpcyResult-->'+JSON.stringify(gosolineDiscrpcyResult));  
          this.gosolinePrceDiscrpcyResult = gosolineDiscrpcyResult;
          
          let executeGasOilRacks = [];
          executeGasOilRacks.push('montreal');
          executeGasOilRacks.push('toronto');                 
          executeGasOilRacks.push('ottawa');  
          executeGasOilRacks.push('belleville'); 
          executeGasOilRacks.push('kingston');              
          executeGasOilRacks.push('sarnia');  
          executeGasOilRacks.push('london');  
          executeGasOilRacks.push('sault ste marie');                
          executeGasOilRacks.push('edmonton');
          executeGasOilRacks.push('thunder bay');                
          executeGasOilRacks.push('kamloops'); 
          executeGasOilRacks.push('vancouver');                       
                           
          for(let j=0; j<executeGasOilRacks.length;j++)
          {
              for(let i=0;i<result.prcngDiffLst.length;i++)
              {
                let returnData = Object.assign({}, result.prcngDiffLst[i]);

                if((returnData.grpclassifictn.toLowerCase() === 'gas oil') && (executeGasOilRacks[j] === returnData.rack.toLowerCase()))
                {
                    if(returnData.rack.toLowerCase() === 'toronto' || returnData.rack.toLowerCase() === 'belleville')
                        returnData.stylClas = "torontoGasolinegrp";
                    else if(returnData.rack.toLowerCase() === 'montreal')
                        returnData.stylClas = "montrealGasolinegrp";
                    else if(returnData.rack.toLowerCase() === 'vancouver')
                        returnData.stylClas = "vancouverGasolinegrp";
                    else if(returnData.rack.toLowerCase() === 'ottawa' || returnData.rack.toLowerCase() === 'kingston')
                        returnData.stylClas = "ottawaGasolinegrp"; 
                    else if(returnData.rack.toLowerCase() === 'sarnia' || returnData.rack.toLowerCase() === 'london' || returnData.rack.toLowerCase() === 'sault ste marie')
                        returnData.stylClas = "sarniaGasolinegrp";  
                    else if(returnData.rack.toLowerCase() === 'edmonton' || returnData.rack.toLowerCase() === 'thunder bay' || returnData.rack.toLowerCase() === 'kamloops')
                        returnData.stylClas = "edmontonGasolinegrp";
                    else
                        returnData.stylClas = "notSpecifiedgrp";                                                                                               

                    dieselDiscrpcyResult.push(returnData);  
                    break;                    
                }
              }
          }          

          this.gosoilPrceDiscrpcyResult = dieselDiscrpcyResult;

          if(gosolineDiscrpcyResult.length > 0)
             this.isGosolineResult  = true;
          else
             this.isGosolineResult  = false;   

          if(dieselDiscrpcyResult.length > 0)
             this.isDieselResult  = true;
          else
             this.isDieselResult  = false; 
        }
        else
        {
           this.isGosolineResult  = false; 
           this.isDieselResult  = false; 

           if(isIntegrityChekButtnClickd)
              this.showSuccessToast('All the Gasoline & Gas Oil Racks in the Price Execution prices are matching with CA Dashboard prices!');
        }

        this.isLoading = false; 
      }
    }).catch(error => {        
      this.isLoading = false;  
      console.log('error -->'+error.message);
  });
}

closeModal(event) {      
  this.isPrceDiscrepancyExists = false;          
}

uploadToGSAP()
{
 // console.log('Upload to GSAP called--');
  try
 {
   //this.isLoading=true;
   this.showProgress=false;
   this.isLoadingGSAP=true;
   this.disableSFJButton=true;
   this.disableButtons=true;
   const selectedEvent = new CustomEvent('gsaploading', {
  });  
  this.dispatchEvent(selectedEvent);  
  uploadToGSAP({recordstoupload:this.typeToAdjust,datefilter:this.datefilter,uploadType:this.uploadType})
  .then(result=>{ 
                //console.log('Inside - Upload to GSAP called--');
                this.isLoadingGSAP=true;                                                  
                this.isStillprocessing();
                })
  .catch(error=>{
                  console.log('Inside error occured'+error.message);
                  this.isLoading=false;
                  console.log(error.message);
                }) 
  
  
}
catch(error)
{
  //this.isLoading=false;
  this.isLoadingGSAP=false;
  console.log(error.message);
  console.log('uploadToGSAP Method Error-->'+JSON.stringify(error)); 
}
}

  isStillprocessing()
  {
   // console.log('isStillprocessing called--');
    let priceExectnPromise = new Promise( (resolve, reject) => {
      let interval = setInterval(() => {                               
          getJobStatus({datefilter:this.datefilter})
          .then(result => { 
                  console.log('result - getJobStatus Method-->'+JSON.stringify(result));                              
                  if(result.GSAPProcessingStatus != undefined &&( result.GSAPProcessingStatus=='Completed'||result.GSAPProcessingStatus=='Cancelled'||result.GSAPProcessingStatus=='Failed'||result.GSAPProcessingStatus=='Partial Complete'))
                  {   
                        this.totalUpload=result.totalUploaded;                       
                        this.totalProcessed=result.totalUploaded;                                   
                        clearInterval(interval);
                        this.clearFilterAfter();
                        this.getRecords();
                        this.isLoadingGSAP =false;
                        if(result.GSAPProcessingStatus=='Completed'|| result.GSAPProcessingStatus=='Partial Complete')
                          this.showSuccessToast('Records uploaded to GSAP');
                        else if(result.GSAPProcessingStatus=='Cancelled')
                        {
                          updatingCancelledJobRunAudit({jobType:'Canada GSAP Upload'})
                          .then(result=>{        
                                          //console.log('reached inside');                       
                                          this.showWarningToast('GSAP Upload Cancelled');
                                        })
                          .catch(error=>{
                                          console.log('updatingCancelledJobRunAudit - error occured'+error.message);                                          
                                          console.log(error.message);
                                        })                       
                        }
                        else if(result.GSAPProcessingStatus=='Failed')
                            this.showFailedToast('GSAP Upload Failed');

                       if(this.mainList.length >0)
                    {
                    this.disableButtons=(!(this.allowEditForDate)) && (this.mainList.length >0) ;
                   
                    }
                   
                     // console.log('getRecords..SFJ list >0');
                      //this.disableSFJButton=(!(this.allowEditForDate)) && (this.SFJList.length >0) ;

                      if(this.allowEditForDate)
                        this.disableSFJButton= !(this.generateSFJ) ;
                     else
                        this.disableSFJButton= true;

                    
                        resolve();
                  }
                  else{
                     // console.log('Is Still Processing Latest Result--'+JSON.stringify(result));
                      if(result.totalUploaded >0)
                      this.showProgress=true;
                      this.totalUpload=result.totalUploaded;
                      this.totalProcessed=result.numberProcessed;
                  }
                 })

              .catch(error => {                                     
                  this.isLoading = false;  
                  console.log('In Still Processing -- error GSAP Upload -->'+JSON.stringify(error));
              });
          }, 10000)
        });
    priceExectnPromise.then();   
  }

  handleSave(event)
  {
    this.saveWarning=false;
    this.disableSFJButton=event.detail;
    if(this.disableSFJButton == false)
    {
      this.saveRecords();
    }
  }

  showSaveWarning()
  {
    //console.log('showSaveWarning--'+this.disableSFJButton);
    if(this.disableSFJButton == false)
    {
      this.saveRecords();
    }
    else{
      this.saveWarning=true;
    } 
  }


  handleMassEdit(event)
  {
    try
    {
      this.isLoading=true;
      //console.log('handleMassEdit called---'+event.detail.Adjustment+'--comment--'+event.detail.Comment);
      this.showPopUp=false;
      this.newAdjustment=event.detail.Adjustment;
      this.newComment=event.detail.Comment;
      this.getDependentRecords(this.popUpList,this.newAdjustment,this.newComment);
      this.isAllSelected=false;
      this.isLoading=false;
      this.showSuccessToast('Records Updated');
    }
    catch(error)
    {
      console.log(error.message);
      this.isLoading=false;
    }
  }

  handleDetailUpdate()
  {
    try{
      this.isLoading=true;
      this.getDependentRecords(this.detailList,this.adjustmentFromDetail,this.commentFromDetail);
      this.isLoading=false;
      this.showSuccessToast('Record Updated');
    }
    catch(error)
    {
      console.log(error.message);
      this.isLoading=false;
    }
  }

  getDependentRecords(indexlist,adjustment,comment)
  {
     // console.log('getDependentRecords called--'+JSON.stringify(indexlist));
    try
  {
    if(this.customertypefilter=='Unbranded')
    {
    let i;
      for(i of indexlist)
    { 
      if(this.listToShow[i].isChanged)
      {
        //console.log('already changed--');
        var newAdj = this.listToShow[i].Adjustment * -1;
        this.updateNewValues(newAdj,comment,i,this.listToShow);
        this.updateNewValues(adjustment,comment,i,this.listToShow);
        }
      else
      {
        //console.log('value updated 1st time');
        this.updateNewValues(adjustment,comment,i,this.listToShow);
      }
      let pricingBasis=this.listToShow[i].productCode+'-'+this.listToShow[i].locationCode+'-'+this.listToShow[i].Group;
      
      this.checkandUpdateDependentProducts(pricingBasis,adjustment,comment);
      }
    }
  else
    {
      let i;
      for(i of indexlist)
      {
        this.updateNewValues(adjustment,comment,i,this.listToShow);
      }
    
    }
  }
    catch(error)
      {
        console.log(error.message);
        this.isLoading=false;
      }
  }

  checkandUpdateDependentProducts(pricingBasis,adjustment,comment)
  {
    // console.log('checkandUpdateDependentProducts called--')
    for( var basisMap of this.mapData)
    {
      if(basisMap.key==pricingBasis)
      {
        
        for( var x of basisMap.value)
          {
          for( var custType of this.typeToAdjust)
          {
           if((this.orignalList[x]!==undefined) && (this.orignalList[x].Group==custType)) 
          {
            if(this.orignalList[x].isChanged)
            {
            var newAdj = this.orignalList[x].Adjustment * -1;
            this.updateNewValues(newAdj,comment,x,this.orignalList);
            this.updateNewValues(adjustment,comment,x,this.orignalList);
            }
            else
            {
              this.updateNewValues(adjustment,comment,x,this.orignalList);
            }
            let pBasis=this.orignalList[x].productCode+'-'+this.orignalList[x].locationCode+'-'+this.orignalList[x].Group;
            this.checkandUpdateDependentProducts(pBasis,adjustment,comment);

          }
        }
        }	
      }
    }
  }
  
  updateNewValues(adjustment,comment,j,listToModify)
  {
    //console.log('update new value called:'+adjustment+'-'+comment+'-'+j+'--final Value Before:'+listToModify[j].finalValue);
    try
    {
      // console.log('final Value:::'+listToModify[j].finalValue+':::old adjustment:::'+listToModify[j].Adjustment+':::new adjustment::'+adjustment);
      var oldAdj=listToModify[j].Adjustment;
      listToModify[j].Status='DR';
          listToModify[j].isChanged=true;
          listToModify[j].Adjustment=adjustment;
          listToModify[j].Comment=comment;
          listToModify[j].isSelected  =false;
          listToModify[j].changedClass='Adjustment'+true;
          listToModify[j].statusClass='slds-avatar__initials slds-icon-standard-account '+ 'DR';
          
         // listToModify[j].finalValue =parseFloat(listToModify[j].finalValue) -parseFloat(oldAdj) + parseFloat(adjustment);
         listToModify[j].finalValue =parseFloat(listToModify[j].valueBefore)  + parseFloat(adjustment);
          listToModify[j].finalValue=listToModify[j].finalValue.toFixed(2);
          this.isLoading=false;
         // console.log('update--finalValu:'+listToModify[j].finalValue);
         //console.log('original List--'+JSON.stringify(this.orignalList));
      }
    catch(error)
    {
      console.log(error.message);
      this.isLoading=false;
    }
  }  


  handleCustomerTypes(event)
  {
    //console.log('handle Customer Type called--');
    this.filterOption=false;
    this.isGSAP=false;
    this.isSapUpload = false;
    this.isAnothrSapUplodInProgres = false;
    this.typeToAdjust=event.detail;
    //console.log('options--'+this.typeToAdjust);
    if(this.editType=='popUp')
    {
      this.handlePopUp();
    }

    if(this.editType=='detailSection')
    {
      this.handleDetailUpdate();
    }

    if(this.editType=='GSAP')
    {
      this.uploadToGSAP();
    }

    if(this.editType=='DownloadSAP')
    {
      this.isGSAP = false;
      this.isSapUpload = true;
      this.isAnothrSapUplodInProgres = false;
      this.DownloadSAPFiles();
    }
  }

  closePopUp(){
    this.showPopUp=false;
    this.filterOption =false;
    this.showMailList=false;
    this.isGSAP=false;
    this.downloadOption = false;
    this.isSapUpload = false;
    this.isAnothrSapUplodInProgres = false;
  }

  handlePopUp(){

    this.showPopUp=true;
    this.validFromDate=this.listToShow[0].validFrom;
    this.validToDate=this.listToShow[0].validTo;
}

GSAPOptions(event)
{
  //console.log('GSAP option called-'+event.currentTarget.label);
  this.uploadType=event.currentTarget.label;
  if(this.uploadType=='Retry Upload')
  this.isRetry=true;
  else
  this.isRetry=false;
  this.typeToAdjust=[];
  this.filterOption=true;
  this.editType='GSAP';
  this.isGSAP=true;
  this.filterLabel='Select Customer Type to Upload:';
}

  openPopUp(event)
  {
    this.popUpList=[];
    this.editType='popUp';
    let index= event.currentTarget.value;
    this.popUpList.push(index);
    //console.log('record--'+JSON.stringify(this.listToShow[index]));
    if(this.customertypefilter=='Unbranded')
    { 
      this.typeToAdjust=[];
      this.filterOption =true;
      this.filterLabel='Select Customer Type to Update:';
    }

    else{
        this.handlePopUp();
        }
  }

  openPopForMassUpdate()
  {
    if(this.selectionList.length >0)
    {
      this.editType='popUp';
      this.popUpList=[];
      this.popUpList=this.selectionList;   
      let i;
      let hasBaseProduct=false;
      for(i of this.popUpList )
      {
        if(this.customertypefilter=='Unbranded')
        {
          hasBaseProduct=true;
          //console.log('openPop---');
          this.typeToAdjust=[];
          this.filterOption =true;
          this.filterLabel='Select Customer Type to Update:';
          break;
        } 
      }

      if(hasBaseProduct==false)
      {
        this.handlePopUp();
      }
      
    }
    else{
      this.showWarningToast('Select Records for Mass Update');
    }
        
  }


  getNewValuesFromDetail(event)
  {   
    //console.log('getNewValuesFromDetail called--');
      this.adjustmentFromDetail=event.detail.Adjustment;
      this.commentFromDetail = event.detail.Comment;
      if(this.customertypefilter=='Unbranded')
      {
        this.typeToAdjust=[];
        this.filterOption =true;
        this.filterLabel='Select Customer Type to Update:';
      }
      else{
        this.isLoading=true;
      this.updateNewValues( this.adjustmentFromDetail,this.commentFromDetail,this.detailIndex,this.listToShow);
      this.showSuccessToast('Record Saved');
      }
    }

showDetailSection(event)
  {
    try
    {
      //console.log('show Detail Called--'+event.currentTarget.value);
      this.isLoading=true;
      this.editType='detailSection';
      this.detailList=[];
      this.showDetails=false;
      this.versionsList=[];
      this.listToShow[this.detailIndex].isDetail= false;

      this.detailIndex=event.currentTarget.value;
      this.selectedRecord=this.listToShow[this.detailIndex];
      this.detailList.push(this.detailIndex);
      this.listToShow[this.detailIndex].isDetail= true;
      this.showDetails=true;
      this.tableClass='fixTableHead'+this.showDetails;
     // console.log('show Details true');
      getVersionRecords({version:this.listToShow[this.detailIndex].version,
                        groupName:this.listToShow[this.detailIndex].Group})
    .then(result=>{ 
                    this.versionsList=result;
                    this.isLoading=false;
                  }  )
    .catch(error=>{
                    console.log('error occured'+JSON.stringify(error));
                    this.isLoading=false;
                  })
      //this.template.querySelector('c-re-c-n-d-price-detail').resetparams(); 
    }
    catch(error)
    {
      //correct
      console.log(error.message);
      this.isLoading=false;
    }
  }


  @api
  clearfilter()
  {
    this.isLoading=true;
    new Promise(
      (resolve,reject) => {
      
          //here
          this.isAllPG=true;
    this.isAllLocation=true;
    this.isAllProduct=true;
    this.isAllRack=true;
    this.statusfilter='All';
    this.producttypefilter='All';
    this.classificationfilter='All';
    this.applyFilters();
      resolve(
      );
      reject();
      })
      .finally(() => {
        this.showSuccessToast('Filters cleared!!');
        this.isLoading=false;
      });  
    
  }


  clearFilterAfter()
  {

    new Promise(
      (resolve,reject) => {
      
          //here
            //console.log('clearFilterAfter called--')
    this.isAllPG=true;
    this.isAllLocation=true;
    this.isAllProduct=true;
    this.isAllRack=true;
    this.statusfilter='All';
    this.producttypefilter='All';
    this.classificationfilter='All';
    const selectedEvent = new CustomEvent('clearfilteronmain', {
    });
    this.dispatchEvent(selectedEvent);
      resolve(
    );
    reject();
    })
    .then()
  
  }

  @api
  groupchange(filtername, filtervalue,isAll)
  {
    this.isLoading=true;
    new Promise(
      (resolve,reject) => {
      setTimeout(()=> {
          //here
          if(filtername=='Product Group')
    {
      this.isAllPG=isAll;
      this.selectedProdGroups=filtervalue;
    }
    if(filtername=='Location')
    {
      this.isAllLocation=isAll;
      this.selectedLocations=filtervalue;
    }
    if(filtername=='Product')
    {
      this.isAllProduct=isAll;
      this.selectedProducts=filtervalue;
    }

    if(filtername=='Rack')
    {
     // console.log('filternae--'+filtername);
      this.isAllRack=isAll;
      this.selectedRacks=filtervalue;
    }
    this.applyFilters();
    this.applyOtherFilters();
    this.isLoading=false;
      resolve();
    }, 0);
    }).then(

    );
    
  }

  @api
  filterchange(filtername, filtervalue)
  {
    try
    {
      this.isLoading=true; 
      new Promise(
        (resolve,reject) => {
          
        setTimeout(()=> {
          
      //console.log('isLoading--'+true);
      this.isAllSelected=false;
      this.selectionList=[];
      this.showDetails=false;
      this.tableClass='fixTableHead'+this.showDetails;

         if(filtername=='CustomerType')
          {
            this.customertypefilter=filtervalue;
          }
          else if(filtername=='Classification')
          {
            this.classificationfilter=filtervalue;
            // console.log('classification filter--'+this.classificationfilter);
          }
          else if(filtername=='ProductType')
          {
          this.producttypefilter=filtervalue;
          }
          else if(filtername=='Status')
          {
          this.statusfilter=filtervalue;
          }
          this.applyFilters();
          this.applyOtherFilters();
        resolve();
      }, 0);
    }).then(

    );
      
    }
    catch(error)
    {
      this.isLoading=false;
      console.log(error.message);
    }
  }


  @api
    handledatechange(newdate)
{
  //console.log('handledatechange--'+newdate);
    try
    {
      new Promise(
        (resolve,reject) => {
        setTimeout(()=> {
            //here

            this.isLoading=true;
      this.isAllSelected=false;
    this.selectionList=[];
    this.showDetails=false;
    this.tableClass='fixTableHead'+this.showDetails;
    this.datefilter=newdate;
    var newDateValue = new Date(newdate);
    var today= new Date(this.todayDate);
    if(newDateValue.getFullYear() <= today.getFullYear())
    {
      if(newDateValue.getFullYear()== today.getFullYear())
      {
        if(newDateValue.getMonth() <= today.getMonth())
        {
          if(newDateValue.getMonth()== today.getMonth())
          {
            if(newDateValue.getDate()<= today.getDate())
            {
              if(newDateValue.getDate()== today.getDate())
              {
                this.allowEditForDate =true;
              }
              else{
                this.allowEditForDate =false;
              }
            }
            else{
              this.allowEditForDate =true;
            }
          }
          else{
            this.allowEditForDate =false;
          }
        }
        else{
          this.allowEditForDate =true;
        }
      }
      else{
        this.allowEditForDate =false;
      }
    }
    else{
      this.allowEditForDate =true;
    }
    this.disableButtons=true;
    
    this.disableSFJButton=true;
    this.brandedList=[];
    this.UNbrandedList=[];
    this.SFJList=[];
    
    this.getRecords();
    this.clearFilterAfter();

   // if(this.pricingAccess)
    //this.template.querySelector('c-re-cnd-report').handledatechange(this.datefilter);

    // console.log('handledatechange--allowEditForDate--'+this.allowEditForDate+'--disableSFJButtons--'+this.disableSFJButton);
    
    //this.disableButtons=(!(this.allowEditForDate)) && (this.mainList.length >0) ;
        resolve();
          }, 0);
      })
  .then(

    )
    .finally(() => {
    console.log('Finally'); // Finally
    });  

 }
  catch(error)
  {
    this.isLoading=false;
    console.log('handledatechange error--'+error.message);
  }
    
  }

  applyOtherFilters()
  {
    try
    {
      // console.log('applyOtherFilters called--');
      if(this.isAllPG==false)
      {
          for(var l2=0;l2<this.listToShow.length;)
          {
            if(!this.selectedProdGroups.includes(this.listToShow[l2].productGroup))
              {
                this.listToShow.splice(l2,1);
              }
              else
              {l2++;}
          }
      }
      if(this.isAllLocation==false)
      {
          for(var l2=0;l2<this.listToShow.length;)
          {
            if(!(this.selectedLocations.includes(this.listToShow[l2].Location+'-'+this.listToShow[l2].locationCode)))
              {
                this.listToShow.splice(l2,1);
              }
              else
              {l2++;}
          }
      }
  
if(this.isAllProduct==false)
      {
          for(var l2=0;l2<this.listToShow.length;)
          {
            if(!this.selectedProducts.includes(this.listToShow[l2].productDescription+'-'+this.listToShow[l2].productCode))
              {
                this.listToShow.splice(l2,1);
              }
              else
              {l2++;}
          }
      }

if(this.isAllRack==false)
      {
          for(var l2=0;l2<this.listToShow.length;)
          {
            if(!this.selectedRacks.includes(this.listToShow[l2].Rack))
              {
                this.listToShow.splice(l2,1);
              }
              else
              {l2++;}

          }
      }
    //console.log('after splice--'+this.listToShow.length);
    if(this.producttypefilter!='All')
    {
      for(var l2=0;l2<this.listToShow.length;)
          {
            if(this.listToShow[l2].isBaseProduct != this.producttypefilter)
            {
              this.listToShow.splice(l2,1);
            }
            else
            {l2++;}
          }
    }
    //console.log('after splice--'+this.listToShow.length+'--branded size--'+this.brandedList.length+'--list to Search--'+this.listToSearch.length);
    if(this.statusfilter!='All')
    {
      for(var l2=0;l2<this.listToShow.length;)
          {
            if(this.listToShow[l2].Status != this.statusfilter)
            {
              this.listToShow.splice(l2,1);
            }
            else
            {l2++;}
          }
    }

    if(this.classificationfilter!='All')
      {
          for(var l2=0;l2<this.listToShow.length;)
          {
            if(this.listToShow[l2].Classification!= this.classificationfilter) 
              {
                if(this.listToShow[l2].Classification!= 'Gasoline' &&  this.classificationfilter=='Gas Oil') 
                {
                 // console.log('product classiofication-'+this.listToShow[l2].Classification+'--filter--'+this.classificationfilter);
                l2++;
                }
                else
                this.listToShow.splice(l2,1);
              }
              else
              {l2++;}
          }
      }
    this.isLoading=false;
    if(this.listToShow.length==0)
    {this.noRecord=true;
     this.disableDwldButton = true;}
    else{this.noRecord=false;
         this.disableDwldButton = false;}
  }
  catch(error)
  {
    console.log('applyOtherFilters error--'+error.message);
  }
}
applyFilters()
  {
    try
    {
     // console.log('applyFilters called--sfj list--'+this.SFJList.length);
     
      console.log('applyFilters--branded--'+this.brandedList.length+'--unbranded--'+this.UNbrandedList.length+'--sfj --'+this.SFJList.length);
      if(this.customertypefilter=='Branded'){
        //console.log('Branded--');
      this.isSFJ=false;
      this.listToShow=this.brandedList.slice(0);
      if(this.listToShow.length>0)
      this.noRecord=false;
      this.disableDwldButton = false;
      // console.log('size of Branded list--'+this.brandedList.length);
      //this.applyOtherFilters();
      }

      else if(this.customertypefilter=='Unbranded'){
      this.isSFJ=false;
      this.listToShow=this.UNbrandedList.slice(0);
      if(this.listToShow.length>0)
      this.noRecord=false;
      this.disableDwldButton = false;
      //this.applyOtherFilters();
      }

      else if(this.customertypefilter=='SFJ'){
        //console.log('listToshow--');
      this.isSFJ=true;
      this.listToShow=this.SFJList.slice(0);
      if(this.listToShow.length>0)
      this.noRecord=false;
      this.disableDwldButton = false;
      //this.applyOtherFilters();
      }
    }
    catch(error)
    {
      console.log('error in apply filter--'+error.message);
    }
  }

  initializePriceBookItems(t,index)
  {
    try{
    // console.log('Pricebook record--'+JSON.stringify(t));
        var DashboardItem = {
          Id            :t.pbRecord.Id,
          // pricingDate   :t.pbRecord.RE_Pricing_Date__c,RE_Customer_Number__c
          ShipTo        :t.pbRecord.RE_CND_Customer_Name__r.Name,
      //    ShipToNumbr   :t.pbRecord.RE_CND_Customer_Name__r.AccountNumber,
          ShipToNumbr   :t.pbRecord.RE_CND_ShipTo_Number__c,
          Location      :t.pbRecord.RT_Location_Code__c, 
          Product       :t.pbRecord.RT_Product_Code__c,
          Rack          :t.pbRecord.RE_CND_Rack__c, 
          Group         :t.groupName,
          productGroup  :t.pbRecord.RE_CND_Product_Group__c,
          productDescription :t.pbRecord.RE_CND_Product_Name__c,
          isBaseProduct :t.isBase,
          oldBase       :t.pbRecord.RE_CND_Old_Base_Value__c,
          marketMove    :t.pbRecord.RE_CND_Market_Move__c,
          netMove       :t.pbRecord.RE_CND_Net_Move_Value__c,
          Adjustment    :t.pbRecord.RE_CND_Adjustment_Value__c,
          newBase       :t.pbRecord.RE_CND_New_Base_Value__c,
          valueBefore   :t.pbRecord.RE_CND_Final_Value__c,
          finalValue    :t.pbRecord.RE_CND_Final_Value__c,
          Rate          :t.pbRecord.RE_Final_Price_Unit__c,
          FXRate        :t.pbRecord.RE_Fx_Rate__c,
          Status        :t.status,
          statusClass   :'slds-avatar__initials slds-icon-standard-account '+ t.status,
          isSelected    :false,
          Classification:t.pbRecord.RT_Product__r.RE_Product_Classification_L0__c,
          
          brandFee        :0,
          brandDiscount   :0,
          productDiff     :0,
          plantDiff       :0,
          specialAdj      :0,
          specialComm     :'',
          rackBasisDiff   :0,

          validFrom     :t.pbRecord.RE_CND_Effective_From_Date__c,
          validTo       :t.pbRecord.RE_CND_Effective_To_Date__c,
          Comment       :t.pbRecord.RE_Submitter_Comments__c,
          version       :t.pbRecord.RE_Initial_Version__c,
          PricingBasis  :t.pbRecord.RE_CND_Pricing_Basis__c,
          diffBasis     :'',
          locationCode  :t.pbRecord.RT_Location_Code__c ,
          productCode   :t.pbRecord.RT_Product_Code__c,
          isChanged     :false,
          changedClass :'Adjustment'+t.isChanged,
          isDetail      :false,
          loc           :index,
          productName   :t.pbRecord.RE_CND_Product_Name__c,

          supp1:'',
          supp2:'',
          supp3:'',
          supp4:'',
          isOnlySFJ:''
      };
      
      //console.log('Pricebook Item--'+JSON.stringify(DashboardItem));
      
      this.SFJListAll.push(DashboardItem); 
      if(t.isLatest==true)
        {
            this.SFJList.push(DashboardItem); 
            this.orignalList.push(DashboardItem);
        }      
    }
    catch(error)
    {
      console.log('initializePriceBookItems error--'+error.message);
    }
  }
  initializeCostPriceItems(t,index){
    //console.log('inside initializeDashboardItems--'+this.listToShow.length);
    try{
            //console.log(i+'--'+JSON.stringify(t));
            var DashboardItem = {
              Id              :t.cpRecord.Id,
              // pricingDate     :t.cpRecord.RE_Pricing_Date__c,
              ShipTo          :'', 
              ShipToNumbr     :'',
              Location        :t.cpRecord.RE_CND_Location_Abbreviated_Name__c, 
              Product         :t.cpRecord.RE_Product_Codes__c,
              Rack            :t.cpRecord.RE_CND_Rack__c, 
              Group           :t.groupName,
              productGroup    :t.cpRecord.RE_CND_Product_Group__c,
              productDescription :t.cpRecord.RE_CND_Product_Name__c,
              isBaseProduct   :t.isBase,
              oldBase         :t.cpRecord.RE_CND_Old_Base_Value__c,
              marketMove      :t.cpRecord.RE_CND_Market_Move__c,
              netMove         :t.cpRecord.RE_CND_Net_Move_Value__c,
              Adjustment      :t.cpRecord.RE_CND_Adjustment_Value__c,
              newBase         :t.cpRecord.RE_CND_New_Base_Value__c,
              valueBefore     :t.cpRecord.RE_CND_Final_Value__c,
              finalValue      :t.cpRecord.RE_CND_Final_Value__c,
              Rate            :t.cpRecord.RE_Costprice_Unit__c,
              Status          :t.status,
              FXRate          :t.cpRecord.RE_Fx_Rate__c,
              statusClass     :'slds-avatar__initials slds-icon-standard-account '+ t.status,
              isSelected      :false,
              Classification:t.cpRecord.RE_Product_Name__r.RE_Product_Classification_L0__c,
              
              brandFee        :t.cpRecord.RE_CND_Brand_Fee__c,
              brandDiscount   :t.cpRecord.RE_CND_Brand_Discount__c,
              productDiff     :t.cpRecord.RE_CND_Product_Differential__c,
              plantDiff       :t.cpRecord.RE_CND_Plant_Differential__c,
              specialAdj      :t.cpRecord.RE_CND_Special_Adjustment__c,
              specialComm     :t.cpRecord.RE_Comments__c,
              rackBasisDiff   :t.cpRecord.RE_CND_Rack_Basis_Differential__c,

              Comment         :t.cpRecord.RE_Submitter_Comments__c,
              PricingBasis    :t.cpRecord.RE_CND_Pricing_Basis__c,
              diffBasis       :t.cpRecord.RE_CND_Differential_Basis__c,
              validFrom       :t.cpRecord.RE_CND_Effective_From_Date__c,
              validTo         :t.cpRecord.RE_CND_Effective_To_Date__c,
              locationCode    :t.cpRecord.RE_Depot_Code__c ,
              productCode     :t.cpRecord.RE_Product_Codes__c,
              version         :t.cpRecord.RE_Initial_Version__c,
              isDetail        :false,
              loc              :index,
              isChanged       :false,
              changedClass    :'Adjustment'+t.isChanged,
              productName   :t.cpRecord.RE_CND_Product_Name__c,
              
              supp1         :t.cpRecord.RE_CND_Supplier1_Price__c,
              supp2         :t.cpRecord.RE_CND_Supplier2_Price__c,
              supp3         :t.cpRecord.RE_CND_Supplier3_Price__c,
              supp4         :t.cpRecord.RE_CND_Supplier4_Price__c,
              isOnlySFJ     :t.isOnlySFJ
          };
          
          //console.log('dashboardItem--'+JSON.stringify(DashboardItem));
          
          if(DashboardItem.Group=='Branded')
          {
            this.brandedListAll.push(DashboardItem);
            if(t.isLatest==true)
            {
              this.brandedList.push(DashboardItem);
              this.orignalList.push(DashboardItem);
            }
          }
            

          if(DashboardItem.Group=='Unbranded')
          {
            this.UNbrandedListAll.push(DashboardItem); 
            if(t.isLatest==true)
            {
              this.UNbrandedList.push(DashboardItem);
              this.orignalList.push(DashboardItem);
            }
          }
          
        }
        catch(error)
        {
          console.log('initializeCostPriceItems error--'+error.message);
        }
  }
  
  filterCustomerTypeRecords()
  {
    try
    {
      //console.log('inside filterCustomerTypeRecords--');
      for(var l2=0;l2<this.mainList.length;l2++)
      {
        if(this.mainList[l2].groupName=='Branded' || this.mainList[l2].groupName=='Unbranded')
        {
          this.initializeCostPriceItems(this.mainList[l2],l2);
        }

        else if(this.mainList[l2].groupName=='SFJ')
        {
            this.initializePriceBookItems(this.mainList[l2],l2); 
        }
      }
      // this.mainList = JSON.parse(JSON.stringify( this.orignalList ));
      //this.orignalList=this.mainList;
      
    }
    catch(error)
    {
      this.isLoading=false;
      console.log('filterCustomerTypeRecords error--'+error.message);
    }
  }
  getRecords()
  {
     console.log('Get Record--Date--'+this.datefilter);
    //console.log('getRecords--branded--'+this.brandedList.length+'--unbranded--'+this.UNbrandedList.length+'--sfj --'+this.SFJList.length);
    this.isLoading=true;
    this.mainList=[];
    this.listToShow=[];
    this.orignalList=[];
    
    this.brandedList=[];
    this.UNbrandedList=[];
    this.SFJList=[];

    this.brandedListAll=[];
    this.UNbrandedListAll=[];
    this.SFJListAll=[];
    this.mapData= [];

    this.validFromDate='';
    this.validToDate='';
    getAllData({datefilter:this.datefilter})
    .then(result=>{ 
                    this.mainList=result.cppbRecords;
                    var derivativeMap =result.baseMap;
                    this.opisReport=result.opisReportID;
                    this.hasFutureRecord=result.hasFutureRecord;
                    this.generateSFJ=result.generateSFJ;
                    for(var key in derivativeMap)
                    {
                      this.mapData.push({value:derivativeMap[key], key:key});
                      //console.log('Map--'+JSON.stringify(this.mapData));
                    }
                    //console.log('Main list--'+JSON.stringify(this.mainList));
                    //this.orignalList = JSON.parse(JSON.stringify( this.listToSearch ));
                    this.filterCustomerTypeRecords();
                    this.applyFilters();
                    this.applyOtherFilters();
                    if(this.hasFutureRecord)
                    {
                      this.allowEditForDate=false;
                    }

                    if(this.listToShow.length >0)
                    {
                    this.validFromDate=this.listToShow[0].validFrom;
                    this.validToDate=this.listToShow[0].validTo;
                    }
                   // console.log('getRecords--allowEditForDate--'+this.allowEditForDate);
                   // console.log('getRecords--SFJ length--'+this.SFJList.length);

                    if(this.mainList.length >0)
                    {
                    //  console.log('--inside if mainlist--');
                    this.disableButtons=(!(this.allowEditForDate)) && (this.mainList.length >0) ;
                   
                    }
                   
                      console.log('getRecords--generateSFJ--'+this.generateSFJ);
                     // this.disableSFJButton=(!(this.allowEditForDate)) && (this.SFJList.length >0) ;
                     if(this.allowEditForDate)
                        this.disableSFJButton= !(this.generateSFJ) ;
                     else
                        this.disableSFJButton= true;

                    if(result.GSAPProcessingStatus != 'Processing')
                    this.isLoadingGSAP=false;
                    else
                    this.isLoadingGSAP=true;

                   
                    if(this.isLoadingGSAP==true)
                    {
                    this.disableButtons=true;
                    this.disableSFJButton=true;
                    this.isStillprocessing();
                    }
                    //this.isLoadingGSAP=false;
                    this.isLoading=false;
                    

                  }  )
    .catch(error=>{
                   console.log('getRecords error--'+error.message);
                    this.isLoading=false;
                    this.isLoadingGSAP=false;
                  })
  } 

  showWarningToast(messageToShow) {
    const evt = new ShowToastEvent({
        title: 'Warning',
        message: messageToShow,
        variant: 'info',
        mode: 'sticky'
    });
    this.dispatchEvent(evt);
}

showSuccessToast(successMessage) {
  const evt = new ShowToastEvent({
      title: 'Success',
      message: successMessage,
      variant: 'success',
      mode: 'dismissable'
  });
  this.dispatchEvent(evt);
}

showFailedToast(errorMessage) {
  const evt = new ShowToastEvent({
          title: 'Error Message',               
          message: errorMessage,
          variant: 'error',
          mode: 'dismissable'
      });
  this.dispatchEvent(evt);
}


closeDetail(event){
try
{
  //console.log('close Detail called--');
  this.listToShow[this.detailIndex].isDetail= false;
  this.showDetails=false;
  this.tableClass='fixTableHead'+this.showDetails;
}
catch(error)
{
  console.log(error.message);
}
}

selectAll(event){
try
  {
    //console.log('select All called--');
    //console.log('event--'+event.target.name);
    this.selectionList=[];
    if(this.isAllSelected==false)
    {
      let i;
      for(i=0;i<this.listToShow.length;i++)
      {
        this.listToShow[i].isSelected=true;
        this.selectionList.push(i);
      }
      this.isAllSelected=true;
      //console.log('All---selection list--'+this.selectionList);
    }
    else
    {
      let i;
      for(i=0;i<this.listToShow.length;i++)
      {
        this.listToShow[i].isSelected=false;
      }
      this.selectionList=[];
      this.isAllSelected=false;
      //console.log('All---selection list--'+this.selectionList);
    }
  }
  catch(error)
  {
    console.log(error.message);
  }
}


selectRecord(event)
  {
    try
    {
      let index=event.currentTarget.value;
      if(this.listToShow[index].isSelected==false)
      {   this.listToShow[index].isSelected=true; 
          this.selectionList.push(index);  
          //console.log('push---selection list--'+this.selectionList); 
        }
      else
      { 
        let index=event.currentTarget.value;
        this.listToShow[index].isSelected=false;
        let i;
        for(i=0;i<this.selectionList.length;i++)
        {
        if(index==this.selectionList[i])
          {
          this.selectionList.splice(i,1);
          //console.log('pop--selection list--'+this.selectionList);
          }
        }
      }
    }
    catch(error)
    {
      console.log(error.message);
    }
  }  

  DownloadOptions(event)
  {
    this.downloadOption = true;
    this.editType = 'DownloadSAP';
    this.isGSAP = false;
    this.isSapUpload = true;  
    this.isAnothrSapUplodInProgres = false;
    this.jobRunStartDtTime = '';
    this.jobRunName = '';
    getStatusOfJobRunAudit({jobType:'Canada GSAP Upload'})
    .then(result => { 
        if(result != undefined){                           
            var totRecords = result.totalRecordCount;              
            // This indicate that already GSAP upload job started processing
            if(totRecords === 3)
            {            
                this.isAnothrSapUplodInProgres = true;  
                this.jobRunStartDtTime = result.jobStartDateTime;
                this.jobRunName = result.jobRunName;
            }  
            else
                this.isAnothrSapUplodInProgres = false;        
        }
    }).catch(error => {
         console.log('getStatusOfJobRunAudit error -->'+JSON.stringify(error));
    }); 
  }

  DownloadSAPFiles()
  {
    try
    {
      this.isLoading = true;      
      const selectedEvent = new CustomEvent('downloadsapfileselection', {
      });      
      this.dispatchEvent(selectedEvent);

      //Columns in Download files stored in a Static resource
      let request = new XMLHttpRequest();
      request.open("GET", RE_SAPDownloadFileResource, false);
      request.send(null);
      var jsonToShow = request.responseText;
      this.headers = JSON.parse(jsonToShow);

      var currentdate = new Date(); 
      var datetime =  ('0' + currentdate.getDate()).slice(-2) + "-"
                      + String(currentdate.getMonth() + 1).padStart(2, '0') + "-"                                                                
                      + currentdate.getFullYear() + "_"  
                      + ('0' + currentdate.getHours()).slice(-2) + "-"
                      + ('0' + currentdate.getMinutes()).slice(-2) + "-"
                      + ('0' + currentdate.getSeconds()).slice(-2);    
                      
      if(this.typeToAdjust.includes('Unbranded') || this.typeToAdjust.includes('Branded') || this.typeToAdjust.includes('SFJ'))
      {
         getSAPdownloadData({recordsToDownload:this.typeToAdjust,datefilter:this.datefilter})
         .then(result => { 
          if(result != undefined){    
            if(result.unbrandedLst.length > 0) 
              exportCSVFile(this.headers, result.unbrandedLst, "Unbranded ["+this.datefilter+"]_"+datetime);
 
            if(result.brandedLst.length > 0)   
              exportCSVFile(this.headers, result.brandedLst, "Branded ["+this.datefilter+"]_"+datetime); 
            
            if(result.sfjLst.length > 0)  
              exportCSVFile(this.headers, result.sfjLst, "SFJ ["+this.datefilter+"]_"+datetime);             
         }
      }).catch(error => {
           console.log('getSAPdownloadData-Unbranded/Branded/SFJ error -->'+JSON.stringify(error));
      });
      }                
    
      this.isLoading = false;
      this.closePopUp();    
    }
    catch(error)
      {
        this.isLoading = false;
        console.log(error.message);
        console.log('Download SAP Files Method Error-->'+JSON.stringify(error)); 
        this.showFailedToast('There is an issue while downloading the SAP file(s)');
      }
  }


}