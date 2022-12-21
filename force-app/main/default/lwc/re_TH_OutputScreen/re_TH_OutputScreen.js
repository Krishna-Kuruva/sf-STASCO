import { LightningElement,track,wire,api } from 'lwc';
import ThailandDataWrapper from '@salesforce/apex/RE_ThailandOutputController.getInitParameterDetails';
import jobExecute from '@salesforce/apex/RE_MalayasiaOutputController.jobExecute';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the current user's Id.
import { NavigationMixin } from 'lightning/navigation'; //to retrieve conga data
import maxRunCountMethod from '@salesforce/apex/RE_ThailandOutputController.maxRunCountMethod' 
export default class Re_TH_OutputScreen extends NavigationMixin (LightningElement) {

@track toggleClick = false;
@track validProfile;
@track lastModifiedDate;
@track mopsData =[];
@track fxData=[];
@track ldcCostData = [];
@track bioquote =   [];
@track dateToday = new Date();
@track todaysdate = this.dateToday.getDate() + '/' + (this.dateToday.getMonth()+1) + '/' + this.dateToday.getFullYear();
@track isRecalculate;
@track jobcount;
@track recalculatecount;
@track showSpinner = false;
//to toggle between the two tables 
handleToggle(event) {
    this.toggleClick = event.target.checked;
   }
   renderedCallback(){
    this.template.querySelectorAll('lightning-formatted-number').forEach(comboname => {
        if(comboname.name === 'diff'){
            if(comboname.value > 0)
                comboname.className='redColor';

           if(comboname.value <= 0)
                comboname.className='blackColor';

        }            
     });
   }

    connectedCallback() {
        this.showSpinner    =   true;
        ThailandDataWrapper({userId : USER_ID})
        .then(result=>{
            this.validProfile = result.validProfile;
            this.lastModifiedDate = result.lastJobRun;
            this.mopsData = result.mops;
            this.fxData = result.fxrates;
            this.ldcCostData = result.costMaps;
            this.bioquote   =   result.bioQuotes;
            this.jobcount   =   result.jobruncount;
            this.recalculatecount   =   this.jobcount; 
            console.log("vAlidprofile___"+JSON.stringify(this.validProfile));
            console.log("lastJobRun--"+this.lastJobRun);
            console.log("mops___"+JSON.stringify(this.mopsData));
            console.log("FXDATa___"+JSON.stringify(this.fxData)); 
            console.log("COSTINGDATALDC__"+JSON.stringify(this.ldcCostData)); 
            this.showSpinner    =   false;
        })
        .catch(error=>{
                        console.log("error in calling InitParameterDetails ---",error);
            this.showSpinner    =   false;
          });
        
    }
    handleRecalculate(){
        this.isRecalculate = true;
        //jobExecute('Thailand Output'); 
    }
    closePopUp(){
        this.isRecalculate = false;
    }
    executejob(){
        this.isRecalculate = false;
        this.validProfile  = false;
        console.log("executing job");
        this.showSpinner    =   true;
        jobExecute({country : "Thailand Output"})
        .then(result=>{
            console.log("success in executing job  ");
            this.recalculatecount = (this.recalculatecount != undefined) ? this.recalculatecount + 1 : 0;
            this.refreshjob();
            

        })
        .catch(error=>{
                        console.log("error in executing job ---",error);
            this.showSpinner    =   false;
         });
    }   

    handleMail(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: '/apex/RE_TH_Mail'
       }
    }) 
   }
   refreshjob(){
       
        if(this.jobcount == this.recalculatecount){
            console.log('Job is executing....');
            this.connectedCallback();
            this.showSpinner    =   false;
        }else{
            maxRunCountMethod()
                    .then(result=>{
                        this.jobcount = result;
                       // this.refreshjob();
                        setTimeout(() => {
                            this.refreshjob();
                        }, 5000);
                    })
                    
                    .catch(error=>{
                        console.log("error in executing job refresh---",error);
                        this.showSpinner    =   false;
                    }) 
        }
    }
    
   
}