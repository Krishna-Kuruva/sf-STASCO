import { LightningElement,track,api } from 'lwc';
import getMailData from '@salesforce/apex/RE_CND_CongaMail_Controller.getMailDetails';
import sendEmailDetails from '@salesforce/apex/RE_CND_CongaMail_Controller.sendEmailDetails';
import getJobStatusMail from '@salesforce/apex/RE_CND_CongaMail_Controller.getJobStatusMail'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


export default class ReCndModalPopUp extends NavigationMixin(LightningElement)  {
    @track isModalOpen = true;
    @track newAdjustment;
    @track newComment;
    @track gsapvalue=[];

    @api adjustmentScreen=false;
    @api validfrom;
    @api validto;

    @api filterLabel;
    @api showSaveWarning=false;

    @api showCustomerTypeOptions=false;
    @api isGSAP=false;
    @api isRetry=false;

    @api showMailList=false;
    @track isOnlyMe=true;
    @track disableAll=false;
    @track noReviseDisable=false;
    @api popUpWidth="modalHeight";
    @api selectedDate;
    @track disableButton = false;

    @track emailReceierValue='me';

    @track CustomerTypeList = [{ label: 'Branded', value: 'Branded' },
    { label: 'Unbranded', value: 'Unbranded' },
    { label: 'SFJ', value: 'SFJ' }];

    @track emailReceiver = [{ label: 'Only Me', value: 'me' },
    { label: 'Intended Recipients', value: 'All' }];

    @track isIARackNotif=true;
    @track isSFJRackNotif=false;
    @track isBRPPNotif=false;
    @track isShellRackNotif=false;
    @track isCARackPrices=false;
    @track isCARackPrices7=false;
    @track isCustNotif=false;
    @track isBrandedNotif=false;
    @track isUploadFiles=false;
    @track isNoRevised=false;
	@track isCanadRackPrcngFiles=false;

    @track mailList=[];
    @track mappingList=[];
    @track mailListToupdate=[];
    @track selectedSubject='';
    @track selectedBody='';
    @track selectedIndex=0;
    @track defaultIndex=0;

    @track selectedMail=[];
    @track isLoading=false;
    @track selctedCustTypeValues=[];

    @api downloadGsapFile = false;
    @api isSapUpload = false;
    @api isAnothrSapUplodInProgres = false;
    @api jobRunName;
    @api jobRunStartDtTime;

    connectedCallback() {
        getMailData({})
        .then(result=>{ 
                        this.mailList=result.mailList;
                        this.mappingList=result.mappingList;
                        this.mailListToupdate=this.mailList.slice(0);
                        for(var l2=0;l2<this.mailListToupdate.length;l2++)
                        {
                            this.mailListToupdate[l2].APXTConga4__Subject__c=
                             this.mailListToupdate[l2].APXTConga4__Subject__c.slice(0, -10) + this.selectedDate;
                            if(this.mailListToupdate[l2].APXTConga4__Name__c=='Internal Rack Notification')
                            {
                                this.selectedSubject=this.mailListToupdate[l2].APXTConga4__Subject__c.slice(0, -10) + this.selectedDate;
                                this.selectedBody=this.mailListToupdate[l2].APXTConga4__HTMLBody__c;
                                this.selectedIndex=l2;
                                this.defaultIndex=l2;
                            }
                        }

                      }  )
        .catch(error=>{
                    console.log('error occured'+JSON.stringify(error));
                  })
} 

subjectChange(event)
{
    this.mailListToupdate[this.selectedIndex].APXTConga4__Subject__c=event.target.value;
}

bodyChange(event)
{
    this.mailListToupdate[this.selectedIndex].APXTConga4__HTMLBody__c=event.target.value;
    var text1=event.target.value.replace(/<br>/gi, "\n");
    var text2=text1.replace(/(<([p^>]+)>)/g, "\n");
    this.mailListToupdate[this.selectedIndex].APXTConga4__TextBody__c=text2.replace( /(<([^>]+)>)/ig, '');
}


   receiverChange(event)
   {
    this.emailReceierValue=event.target.value;
    if(event.target.value=='All')
    {       
        this.isOnlyMe=false;       
       if(this.isNoRevised)
       {
         this.template.querySelector('[data-id="isNoRevised"]').checked=false;
         this.template.querySelector(".noRevise").checked=false;
       }
    } 
    else
    {

    this.isOnlyMe=true;  
    this.disableAll=false;
    this.unSelectAll();
    this.template.querySelector('[data-id="isIARackNotif"]').checked=true;
    this.isIARackNotif=true;
    if(this.isNoRevised)
       this.template.querySelector('[data-id="isNoRevised"]').checked=false;
       for(var l1=0;l1<this.selectedMail.length;)
        {
            this.selectedMail.splice(l1,1);          
            l1++;
            this.template.querySelector(".noRevise").checked=false;
        } 

    }
    
  }
  
  showReport(event)
  {
    //  console.log('Name--'+event.target.name);
var reportName='';
var reportId='';
if(event.target.name=='Ready to Upload Notification')
{
    reportName='Canada GSAP Report';
}
else if(event.target.name=='7 Day Canadian Rack Prices')
{
    reportName='7 DAY Canadian Rack Prices';
}
else if(event.target.name=='Shell Rack Customer Notification')
{
    reportName='Rack Prices';
}
else if(event.target.name=='Canadian Rack Prices')
{
    reportName='Canadian Rack Prices';
}
if(reportName!='')
{
    for(var i=0;i<this.mappingList.length;i++)
        {
          if(this.mappingList[i].Type_Name__c==reportName)
          {
            reportId=this.mappingList[i].Record_Id__c;
          }
        }
}
console.log('Report id--'+reportId);
if(reportId !='')
{
      this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
            recordId: reportId,
            objectApiName: 'Report', // objectApiName is optional
            actionName: 'view'
        }
    }).then(url => {
        window.open(url, "_blank");
    });
}

  }

  proceedEmail()
  {
    if(this.selectedMail.length>0)
    {
        this.isLoading=true;
    sendEmailDetails({selectedMail:this.selectedMail,updatedEmail :this.mailListToupdate,
        isOnlyMe :this.isOnlyMe,dateFilter:this.selectedDate})
    .then(result=>{ 
        
        this.isStillprocessing();
        }  )
    .catch(error=>{
          console.log('error occured'+error.message);
          this.isLoading=false;
          console.log(error.message);
        })
    }
  }

  isStillprocessing()
  {
    console.log('---isStillprocessing--');
    let priceExectnPromise = new Promise( (resolve, reject) => {
      let interval = setInterval(() => {                               
          getJobStatusMail()
          .then(result => {                               
                  if(result != undefined && result==false)
                  {    
                      console.log('result false--');                                     
                        clearInterval(interval);
                       this.isLoading=false;
                       this.showSuccessToast('Mail Sent Successfully!!');
                       this.closeModal();
                        resolve();
                  }
                 })

              .catch(error => {                                     
                  this.isLoading = false;  
                  console.log('error sending Conga Email -->'+JSON.stringify(this.error));
              });
          }, 30000)
        });
    priceExectnPromise.then();   
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

  selectMail(event)
  {
      if(event.target.label=='No Revised Pricing')
      {
        if(event.target.checked==true)
          {
              this.unSelectAll();
              this.template.querySelector('[data-id="isNoRevised"]').checked=true;
              this.isNoRevised=true;
              
              if(this.isOnlyMe==true)
                this.disableAll=false;
              else 
                this.disableAll=true;  
            
              this.selectedMail=[];
              this.selectedMail.push('No Revised Pricing');
              for(var l2=0;l2<this.mailListToupdate.length;l2++)
             {
                if(this.mailListToupdate[l2].APXTConga4__Name__c=='No Revised Pricing')
                {
                    this.selectedSubject=this.mailListToupdate[l2].APXTConga4__Subject__c;
                    this.selectedBody=this.mailListToupdate[l2].APXTConga4__HTMLBody__c;
                    this.selectedIndex=l2;
                }
            }

            this.template.querySelectorAll('.checkClass2').forEach(element => {
                element.checked = false; //Contains HTML elements
            });
          }
          else
          {
            this.disableAll=false;
            this.isOnlyMe=false;
            this.selectedMail=[];
          }
      }
      else
      {
          if(event.target.checked==true)
          {
            this.selectedMail.push(event.target.label);
          }
          else
          {
            for(var l2=0;l2<this.selectedMail.length;l2++)
            {
              if(this.selectedMail[l2]==event.target.label)
               {
                 this.selectedMail.splice(l2,1);
               }
            }
          }
        }
         
  }


   showMailDetail(event)
   {
        this.unSelectAll();
       // console.log(event.target.label+'--value--'+event.target.value);
        if(event.target.label=='isIARackNotif')
        {
        this.template.querySelector('[data-id="isIARackNotif"]').checked=true;
            this.isIARackNotif=true;
        }

        else if(event.target.label=='isSFJRackNotif')
        {this.template.querySelector('[data-id="isSFJRackNotif"]').checked=true;
        this.isSFJRackNotif=true;}

        else if(event.target.label=='isBRPPNotif')
        {this.template.querySelector('[data-id="isBRPPNotif"]').checked=true;
        this.isBRPPNotif=true;}

        else if(event.target.label=='isShellRackNotif')
        {this.template.querySelector('[data-id="isShellRackNotif"]').checked=true;
        this.isShellRackNotif=true;}

        else if(event.target.label=='isCARackPrices')
        {this.template.querySelector('[data-id="isCARackPrices"]').checked=true;
        this.isCARackPrices=true;}

        else if(event.target.label=='isCARackPrices7')
        {this.template.querySelector('[data-id="isCARackPrices7"]').checked=true;
        this.isCARackPrices7=true;}

        else if(event.target.label=='isCustNotif')
        {this.template.querySelector('[data-id="isCustNotif"]').checked=true;
        this.isCustNotif=true;}

        else if(event.target.label=='isBrandedNotif')
        {this.template.querySelector('[data-id="isBrandedNotif"]').checked=true;
        this.isBrandedNotif=true;}

        else if(event.target.label=='isUploadFiles')
        {this.template.querySelector('[data-id="isUploadFiles"]').checked=true;
        this.isUploadFiles=true;}

        else if(event.target.label=='isCanadRackPrcngFiles')
        {this.template.querySelector('[data-id="isCanadRackPrcngFiles"]').checked=true;
        this.isCanadRackPrcngFiles=true;}

        else
        {this.template.querySelector('[data-id="isNoRevised"]').checked=true;
        this.isNoRevised=true;}

        for(var l2=0;l2<this.mailListToupdate.length;l2++)
         {
            if(this.mailListToupdate[l2].APXTConga4__Name__c==event.target.value)
                {
                    this.selectedSubject=this.mailListToupdate[l2].APXTConga4__Subject__c;
                    this.selectedBody=this.mailListToupdate[l2].APXTConga4__HTMLBody__c;
                    this.selectedIndex=l2;
                }
        }

   }

   unSelectAll()
   {
       
     this.template.querySelectorAll('.toggleClass').forEach(element => {
        element.checked = false; //Contains HTML elements
    });
    this.isIARackNotif=false;
    this.isSFJRackNotif=false;
    this.isBRPPNotif=false;
    this.isShellRackNotif=false;
    this.isCARackPrices=false;
    this.isCARackPrices7=false;
    this.isCustNotif=false;
    this.isBrandedNotif=false;
    this.isUploadFiles=false;
    this.isNoRevised=false;
	this.isCanadRackPrcngFiles=false;
   }

    optionChange(event)
    {
        this.gsapvalue =event.detail.value;
    }
    handleUpload()
    {
        this.showgsapOption=false;
        this.isModalOpen = false;
        if(this.isGSAP==false)
        {
            var addUnbranded=false;
            var custType;
            for( custType of this.gsapvalue)
            {
            if(custType=='Unbranded')
            {
                addUnbranded=true;
            }
        }
        if(addUnbranded==false)
        {this.gsapvalue.push('Unbranded');}
        }
        
       const selectedEvent = new CustomEvent('gsapselection', 
                                                {detail: this.gsapvalue});
        this.dispatchEvent(selectedEvent);
    }

    handlesaveAndGenerateSFJ()
    {
        this.showSaveWarning=false;
        this.isModalOpen = false;
        const selectedEvent = new CustomEvent('saveandgeneratesfj', 
                                                {detail: false});
        this.dispatchEvent(selectedEvent);
    }

    closeModal() 
    {
       try
        {  
            this.warningmessage=false;
            this.adjustmentScreen=false;
            this.showSaveWarning=false;
            this.isModalOpen = false;
            this.showMailList=false;
            this.isGSAP=false;
            this.isSapUpload = false;
            const selectedEvent = new CustomEvent('closepopup', {
            });
            this.dispatchEvent(selectedEvent);
        }
        catch(error)
        {
               console.log(error.message);
        }
    }

    handleAdjustment(event)
    {
            this.newAdjustment=event.target.value;
    }
    handleCommentChange(event)
    {
        this.newComment=event.target.value;
        
    }
    
    
    handlesave(){
        try
        {
            if(this.newAdjustment!='' && this.newAdjustment!=null && this.newAdjustment !=undefined &&
            this.newComment!='' && this.newComment!=null && this.newComment !=undefined)
            {
               
                this.template.querySelector('lightning-textarea').reportValidity();
                this.template.querySelector(".inputCmp").reportValidity();
                this.adjustmentScreen=false;
                    //propagate change to parent component
                const selectedEvent = new CustomEvent('massedit', {
                     detail:  {Adjustment : this.newAdjustment, Comment : this.newComment}});
                this.dispatchEvent(selectedEvent);
                
            }
            else{
                this.template.querySelector('lightning-textarea').reportValidity();
                this.template.querySelector(".inputCmp").reportValidity();
            }
        }
        catch(error)
        {
               this.showErrorToast(error.body.message);
        }
    }

    handleCustTypeChange(event)
    {
        this.selctedCustTypeValues = event.detail.value;
    }

    handleDownload()
    {
        this.isGSAP = false;
        this.isSapUpload = true;
        this.disableButton = true;
        if(this.selctedCustTypeValues.length > 0)
        {
          const selectedEvent = new CustomEvent('sapdownloadselection', {detail: this.selctedCustTypeValues});
          this.dispatchEvent(selectedEvent);  
        }
        else
           this.disableButton = false;     
    }
}