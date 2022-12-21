import { LightningElement,track } from 'lwc';
import getMOAGasolineDieselDetails from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.getMOAGasolineDieselDetails';
import getExistingDepoPricingPriceBook from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.getExistingDepoPricingAndPriceBook';
import startCalculatingDepoPricing from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.startCalculatingDepoPricing';
import generateMVandMOAFromOpisSpotTickrData from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.generateMVandMOAFromOpisSpotTickrData';
import getJobRunAuditStatus from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.getJobRunAuditStatus';
import getFxValue from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.getFxRate';
import getExistingMarketMoveAndMOA from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.getExistingMarketMoveAndMOA';
import checkOPISSpotTickerExistsOrNot from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.checkOPISSpotTickerExistsOrNot';
import checkPreviousOPISSpotTickerExistsOrNot from '@salesforce/apex/RE_CND_ExecuteDepoPricingController.checkPreviousOPISSpotTickerExistsOrNot';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import TIMEZONE from '@salesforce/i18n/timeZone';

export default class Re_CND_ExecutePricing extends NavigationMixin(LightningElement) {

    @track userHasPriceExecuteAccess; 
    @track reqDt;    
    @track reqFromDate;
    @track reqToDate;
    @track moaGosolineResult = [];
    @track moaGosolineResultBackup = [];
    @track moaDieselResult = [];
    @track moaDieselResultBackup = [];
    @track isGosolineMOA = false;
    @track isDieselMOA = false;
    @track isGosolineMV = false;
    @track isDieselMV = false;
    @track IsreqFromToDisabled = false;     
    @track reqestedDate;
    @track reqFDate;
    @track reqTDate;    
    @track apexFromDate;
    @track apexToDate;
    @track showModal=false;
    @track isRecordExists = false;
    @track isUplodedRecordExists = false;
    @track isDepotPricngJobExists = false;
    @track isMVCalcJobExists = false;
    @track isLoading = false;
    @track mvGosolineResult = [];   
    @track mvDieselResult = [];
    @track showOPISModal = false; 
    @track isMVRecordExists = false;    
    @track prvFxDate;
    @track latestFxDate;
    @track prvFx;
    @track latestFx;
    @track showSpinner = false;    
    @track toastMsg;
    @track reqFxDate
    @track isFxExists = false; 
    @track fxValue;
    @track isCalMVBttnActive = false; 
    @track isYesBtnActive = false;
    @track iconMQName = 'utility:right';
    @track iconPAName = 'utility:right';
    @track showMVDetails = false;
    @track showPADetails = false;
    @track lstLocale = TIMEZONE;
    @track jobRunStartDtTime;
    @track jobRunName;

    @track prevFxRateReq = false;
    @track currFxRateReq = false;
                    
    connectedCallback(){    
        var today = this.getLoggedInUserDate('');        
        this.reqDt = today;   
        this.currMaxDt = today;     
        this.reqestedDate = this.reqDt;      
        this.reqFxDate = today;

        var nextDate = this.getLoggedInUserDate(today);        
        this.reqFromDate = nextDate;
        this.reqToDate =  this.reqFromDate;
        
        this.IsreqFromToDisabled = false;      
        this.initialMOAPageload();
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
    
    initialMOAPageload()
    {     
        this.showSpinner = true;
        let updatedMOAGosolineResult = []; 
        let updatedMOADieselResult = []; 
        let updatedMVGosolineResult = []; 
        let updatedMVDieselResult = []; 
        let updatedMVFxRateResult = [];
        this.moaGosolineResult = updatedMOAGosolineResult;
        this.moaGosolineResultBackup = updatedMOAGosolineResult;
        this.moaDieselResult = updatedMOADieselResult;
        this.moaDieselResultBackup = updatedMOADieselResult;
        this.mvGosolineResult = updatedMVGosolineResult;
        this.mvDieselResult = updatedMVDieselResult;
        this.mvFxResult = updatedMVFxRateResult;
        this.currOpisStatusMsg = '';
        
        getMOAGasolineDieselDetails({requestedStartDt:this.reqestedDate})
        .then(result => { 
            if(result != undefined){                  
                this.userHasPriceExecuteAccess = result.hasPriceExecuteAccess;
                this.apexFromDate = result.fromDate;
                this.apexToDate = result.toDate;

                this.prvFxDate = result.prvFxDay;
                this.latestFxDate = result.currtFxDay;
                this.prvFx = result.prvFx;
                this.latestFx = result.currtFx;

                var today = this.getLoggedInUserDate(''); 
                var isBothBtnDisabled = result.isBothBtnDisable; 
                this.isCalMVBttnActive = result.isCalMVBttnActive;                
                if(this.reqestedDate === today)                               
                    this.isCalMVBttnActive = false; 
                else
                    this.isCalMVBttnActive = true; 

                this.isCalExcBttnActive = result.isCalExcRecodExist;                 
                if((this.reqestedDate === today) && (this.isCalExcBttnActive))
                   this.isCalExcBttnActive = false;                     
                else
                   this.isCalExcBttnActive = true;     

                let executeGasolineRacks = [];

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
                    for(let i=0;i<result.moaGasolineDieselList.length;i++)
                    {
                        let returnData = Object.assign({}, result.moaGasolineDieselList[i]);
                       
                        if((returnData.RE_CND_Group__c.toLowerCase() === 'gasoline') && (executeGasolineRacks[j] === returnData.RE_CND_Rack__c.toLowerCase()))                                                    
                        {                            
                            this.reqFDate = returnData.RE_CND_Effective_From_Date__c;
                            this.reqTDate =  returnData.RE_CND_Effective_To_Date__c;
                           
                            if(returnData.RE_CND_Rack__c.toLowerCase() === 'toronto' || returnData.RE_CND_Rack__c.toLowerCase() === 'belleville')
                               returnData.stylClas = "torontoGasolinegrp";
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'montreal')
                               returnData.stylClas = "montrealGasolinegrp";
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'vancouver')
                               returnData.stylClas = "vancouverGasolinegrp";
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'ottawa' || returnData.RE_CND_Rack__c.toLowerCase() === 'kingston')
                               returnData.stylClas = "ottawaGasolinegrp"; 
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'sarnia' || returnData.RE_CND_Rack__c.toLowerCase() === 'london' || returnData.RE_CND_Rack__c.toLowerCase() === 'sault ste marie')
                               returnData.stylClas = "sarniaGasolinegrp";  
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'edmonton' || returnData.RE_CND_Rack__c.toLowerCase() === 'thunder bay' || returnData.RE_CND_Rack__c.toLowerCase() === 'kamloops')
                               returnData.stylClas = "edmontonGasolinegrp";
                            else
                               returnData.stylClas = "notSpecifiedgrp";                                                                                               

                            updatedMOAGosolineResult.push(returnData);  
                            break;
                        }           
                    }
                }

                this.moaGosolineResult = updatedMOAGosolineResult;
                this.moaGosolineResultBackup = updatedMOAGosolineResult;

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
                    for(let i=0;i<result.moaGasolineDieselList.length;i++)
                    {
                        let returnData = Object.assign({}, result.moaGasolineDieselList[i]);
                                                                               
                         if((returnData.RE_CND_Group__c.toLowerCase() === 'gas oil') && (executeGasOilRacks[j] === returnData.RE_CND_Rack__c.toLowerCase()))                      
                         {
                            if(returnData.RE_CND_Rack__c.toLowerCase() === 'toronto')
                               returnData.stylClas = "torontoGasolinegrp";
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'montreal')
                               returnData.stylClas = "montrealGasolinegrp";
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'vancouver')
                               returnData.stylClas = "vancouverGasolinegrp";
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'ottawa' || returnData.RE_CND_Rack__c.toLowerCase() === 'belleville' || returnData.RE_CND_Rack__c.toLowerCase() === 'kingston')
                               returnData.stylClas = "ottawaGasolinegrp"; 
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'sarnia' || returnData.RE_CND_Rack__c.toLowerCase() === 'london' || returnData.RE_CND_Rack__c.toLowerCase() === 'sault ste marie')
                               returnData.stylClas = "sarniaGasolinegrp";  
                            else if(returnData.RE_CND_Rack__c.toLowerCase() === 'edmonton' || returnData.RE_CND_Rack__c.toLowerCase() === 'thunder bay' || returnData.RE_CND_Rack__c.toLowerCase() === 'kamloops')
                               returnData.stylClas = "edmontonGasolinegrp";
                            else
                               returnData.stylClas = "notSpecifiedgrp";  

                             updatedMOADieselResult.push(returnData);  
                             break; 
                         }              
                     }
                 }                 

                 this.moaDieselResult = updatedMOADieselResult;
                 this.moaDieselResultBackup = updatedMOADieselResult;  
                
                 if(updatedMOAGosolineResult.length > 0)
                 {              
                    this.isGosolineMOA = true;  
                    this.reqFromDate =  this.reqFDate;     
                    this.reqToDate =  this.reqTDate;
                 }            
                 else             
                 {                     
                    this.isGosolineMOA = false; 
                    var today = this.getLoggedInUserDate('');                
                    if(this.reqDt === today)
                    {                       
                        this.reqFromDate = this.apexFromDate;
                        this.reqToDate = this.apexToDate;                                                                                                   
                    }
                    else
                    {                        
                        this.reqFromDate = null;
                        this.reqToDate = null;                                         
                    }                              
                }            
                
                if(updatedMOADieselResult.length > 0)
                    this.isDieselMOA = true;
                else
                    this.isDieselMOA = false;                      
               
                let markrNames = [];      

                markrNames.push('wti');               
                markrNames.push('rbob');
                markrNames.push('nyh rbob unl');         
                markrNames.push('nyh cbob');               
                markrNames.push('chi rbob');
                markrNames.push('chi cbob');
                markrNames.push('usg cbob');
                markrNames.push('pnw carbob');                
                markrNames.push('ho');
                markrNames.push('nyh uls#2');               
                markrNames.push('chi uls#2');
                markrNames.push('pnw uls#2'); 
                markrNames.push('la uls#2');  
                markrNames.push('usg uls#2');        
                markrNames.push('reuters fx');                                
               
                for(let m=0; m<markrNames.length;m++)
                {                    
                    for(let n=0;n<result.marketMoveList.length;n++)
                    {                             
                        let returnData = Object.assign({}, result.marketMoveList[n]);  
                        
                        if((returnData.RE_CND_Group__c.toLowerCase() === 'gasoline') && (markrNames[m] === returnData.RE_CND_Marker_Name__c.toLowerCase()))                        
                            updatedMVGosolineResult.push(returnData); 
                        else if((returnData.RE_CND_Group__c.toLowerCase() === 'gas oil') && (markrNames[m] === returnData.RE_CND_Marker_Name__c.toLowerCase()))                        
                            updatedMVDieselResult.push(returnData);     
                        else if((returnData.RE_CND_Group__c.toLowerCase() === 'fx rate') && (markrNames[m] === returnData.RE_CND_Marker_Name__c.toLowerCase()))                        
                            updatedMVFxRateResult.push(returnData);     
                    }
                }
                
                this.mvGosolineResult = updatedMVGosolineResult;
                this.mvDieselResult = updatedMVDieselResult;
                this.mvFxResult = updatedMVFxRateResult;
                
                if(updatedMVGosolineResult.length > 0)
                    this.isGosolineMV = true;
                    else
                    this.isGosolineMV = false;  

                if(updatedMVDieselResult.length > 0)
                    this.isDieselMV = true;
                else
                    this.isDieselMV = false;  
                    
                if(isBothBtnDisabled)
                {
                    this.isCalMVBttnActive = true;
                    this.isCalExcBttnActive = true; 
                    this.reqFromDate = null;
                    this.reqToDate = null;
                    this.IsreqFromToDisabled = true;
                }    
                  
                this.showMVDetails = true;
                this.iconMQName = 'utility:down';    
                this.showPADetails = true;
                this.iconPAName = 'utility:down';                 
                this.showSpinner = false;  
            }
        }).catch(error => {        
            this.showSpinner = false;   
            console.log('error -->'+JSON.stringify(error));
        });
    }

    handleFxEffectiveChange(event)
    {        
        var changeFxReqDt = event.target.value; 
        getFxValue({requestedFxDt:changeFxReqDt})
        .then(result => { 
            if(result != undefined){                           
                var fxRate = result;            
                if(this.reqestedDate === changeFxReqDt)
                {
                    if(fxRate === 0)
                    {
                        this.fxValue = '';
                        this.isFxExists = false;
                    }
                    else
                    {
                        var today = this.getLoggedInUserDate('');  
                        if(changeFxReqDt === today) 
                        {
                            this.fxValue = fxRate;
                            this.isFxExists = false; 
                        }
                        else
                        {
                            this.fxValue = fxRate;
                            this.isFxExists = true;  
                        } 
                    }    
                }   
                else
                {
                    this.fxValue = fxRate;
                    this.isFxExists = true; 
                }                                                        
            }
        }).catch(error => {             
             console.log('Fx Rate error -->'+JSON.stringify(error));
        });
    }  
    
    handleReqDtChange(event)
    {
        var changeReqDt = event.target.value;   
        this.reqDt = changeReqDt;
        var today = this.getLoggedInUserDate('');   
        if(this.reqDt === today)    
            this.IsreqFromToDisabled = false;                        
        else
        {                     
            if(changeReqDt === this.reqDt)                 
                this.IsreqFromToDisabled = true;             
            else            
                this.IsreqFromToDisabled = false;      
        }   
        this.reqestedDate = changeReqDt;        
        this.initialMOAPageload();
    }

    handleGasolineCompAdjChange(event) 
    {        
        var changeCompAdj = event.target.value; 
        var changeCompAdjRack = event.target.name;        
        var prevTodaysPrice = 0.00;      
        var prevMarketMove = 0.00;

        let prevTodaysPriceVal = new Map();
        let prevMarketMoveVal = new Map();  
        let compAdjRack = new Map();       
                    
        this.moaGosolineResultBackup.forEach(function(element, index)
        { 
            compAdjRack.set(element.Id, element.RE_CND_Rack__c);
            prevTodaysPriceVal.set(element.RE_CND_Rack__c, element.RE_CND_Today_s_Price__c);
            prevMarketMoveVal.set(element.RE_CND_Rack__c, element.RE_CND_Market_Move__c);          
        });

        var ottawaNetMove = 0.00;
        var ottawaClassname = '.';
        var torontoNetMove = 0.00;       
        var sarniaNetMove = 0.00;
        var sarniaClassname = '.';
        
        var edmontonNetMove = 0.00;
        var thunderbayNetMove = 0.00;
        var thunderbayClassname = '.';
        var kamloopsNetMove = 0.00;
        var kamloopsClassname = '.';

        var bellevilleNetMove = 0.00;
        var bellevilleClassname = '.';
        var kingstonNetMove = 0.00;
        var kingstonClassname = '.';
        var ssmarieNetMove = 0.00;
        var ssmarieClassname = '.';
        var londonNetMove = 0.00;
        var londonClassname = '.';

        if(compAdjRack.has(changeCompAdjRack))
          changeCompAdjRack = compAdjRack.get(changeCompAdjRack);
        else
          changeCompAdjRack = 'Toronto';           

        let derivedRacks = new Map();     
      
        if(changeCompAdjRack === 'Montreal')        
           derivedRacks.set('Montreal','Montreal');
        else if(changeCompAdjRack === 'Edmonton')  
        {      
           derivedRacks.set('Edmonton','Edmonton'); 
           derivedRacks.set('Thunder Bay','Thunder Bay');
           derivedRacks.set('Kamloops','Kamloops');
        }      
        else if(changeCompAdjRack === 'Thunder Bay')        
           derivedRacks.set('Thunder Bay','Thunder Bay');  
        else if(changeCompAdjRack === 'Kamloops')        
           derivedRacks.set('Kamloops','Kamloops'); 
        else if(changeCompAdjRack === 'Vancouver')        
           derivedRacks.set('Vancouver','Vancouver');            
        else if(changeCompAdjRack === 'Toronto')
        {
           derivedRacks.set('Toronto','Toronto');
           derivedRacks.set('Belleville','Belleville');
           derivedRacks.set('Ottawa','Ottawa'); 
           derivedRacks.set('Kingston','Kingston');  
           derivedRacks.set('Sarnia','Sarnia');             
           derivedRacks.set('London','London'); 
           derivedRacks.set('Sault Ste Marie','Sault Ste Marie');         
        }
        else if(changeCompAdjRack === 'Ottawa')
        {  
           derivedRacks.set('Ottawa','Ottawa'); 
           derivedRacks.set('Kingston','Kingston');
        }
        else if(changeCompAdjRack === 'Sarnia')
        {
           derivedRacks.set('Sarnia','Sarnia');             
           derivedRacks.set('London','London'); 
           derivedRacks.set('Sault Ste Marie','Sault Ste Marie'); 
        }
        else if(changeCompAdjRack === 'Belleville')        
           derivedRacks.set('Belleville','Belleville'); 
        else if(changeCompAdjRack === 'Kingston')        
           derivedRacks.set('Kingston','Kingston');                        
        else if(changeCompAdjRack === 'London')        
           derivedRacks.set('London','London'); 
        else if(changeCompAdjRack === 'Sault Ste Marie')        
           derivedRacks.set('Sault Ste Marie','Sault Ste Marie');           
       
        this.moaGosolineResult.forEach(function(element, index)
        {       
            if(derivedRacks.has(element.RE_CND_Rack__c)) 
            {
                if(changeCompAdj === null || changeCompAdj === '')
                {                                           
                    changeCompAdj = 0.00;  
                    element.RE_CND_Competitive_Adj__c  = 0.00;
                }
                else
                   element.RE_CND_Competitive_Adj__c = changeCompAdj;
                 
                if(prevMarketMoveVal.has(element.RE_CND_Rack__c))                
                    prevMarketMove = prevMarketMoveVal.get(element.RE_CND_Rack__c);
                else
                    prevMarketMove = 0.00;  
                    
                if(prevTodaysPriceVal.has(element.RE_CND_Rack__c))                
                    prevTodaysPrice = prevTodaysPriceVal.get(element.RE_CND_Rack__c);
                else
                    prevTodaysPrice = 0.00;   
                              
                var newNetMove = (+ parseFloat(prevMarketMove)) + (+ parseFloat(changeCompAdj));                

                if(parseFloat(newNetMove).toFixed(1) == -0.0)
                    element.RE_CND_Net_Move__c = 0.00; 
                else   
                    element.RE_CND_Net_Move__c = parseFloat(newNetMove).toFixed(1); 

                var newNewEnd = (+ parseFloat(prevTodaysPrice)) + (+ parseFloat(element.RE_CND_Net_Move__c))
                element.RE_CND_New_End_Price__c = parseFloat(newNewEnd).toFixed(1);                     
            }

            if(element.RE_CND_Rack__c.toLowerCase() === 'toronto')            
                torontoNetMove = element.RE_CND_Net_Move__c;      
            else if(element.RE_CND_Rack__c.toLowerCase() === 'ottawa')  
            {   
                ottawaNetMove = element.RE_CND_Net_Move__c;
                ottawaClassname = ottawaClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'sarnia')  
            {   
                sarniaNetMove = element.RE_CND_Net_Move__c;
                sarniaClassname = sarniaClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'edmonton')  
                edmontonNetMove = element.RE_CND_Net_Move__c;  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'thunder bay')  
            {   
                thunderbayNetMove = element.RE_CND_Net_Move__c;
                thunderbayClassname = thunderbayClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'kamloops')  
            {   
                kamloopsNetMove = element.RE_CND_Net_Move__c;
                kamloopsClassname = kamloopsClassname + element.Id;
            }   
            else if(element.RE_CND_Rack__c.toLowerCase() === 'belleville')  
            {   
                bellevilleNetMove = element.RE_CND_Net_Move__c;
                bellevilleClassname = bellevilleClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'kingston')  
            {   
                kingstonNetMove = element.RE_CND_Net_Move__c;
                kingstonClassname = kingstonClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'london')  
            {   
                londonNetMove = element.RE_CND_Net_Move__c;
                londonClassname = londonClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'sault ste marie')  
            {   
                ssmarieNetMove = element.RE_CND_Net_Move__c;
                ssmarieClassname = ssmarieClassname + element.Id;
            }                                                        
        });

        let ottawaValidtnErr = this.template.querySelector(ottawaClassname);
        let sarniaValidtnErr = this.template.querySelector(sarniaClassname);
        let tbayValidtnErr = this.template.querySelector(thunderbayClassname);
        let kamloopsValidtnErr = this.template.querySelector(kamloopsClassname);
        let bellevilleValidtnErr = this.template.querySelector(bellevilleClassname);
        let kingstonValidtnErr = this.template.querySelector(kingstonClassname);
        let ssmarieValidtnErr = this.template.querySelector(ssmarieClassname);
        let londonValidtnErr = this.template.querySelector(londonClassname);
              
        if(torontoNetMove == ottawaNetMove)       
           ottawaValidtnErr.setCustomValidity('');              
        else  
           ottawaValidtnErr.setCustomValidity('Please check Ottawa NetMove');  
        
        if(torontoNetMove == sarniaNetMove)  
           sarniaValidtnErr.setCustomValidity('');            
        else 
           sarniaValidtnErr.setCustomValidity('Please check Sarnia NetMove'); 
        
        if(edmontonNetMove == thunderbayNetMove)           
           tbayValidtnErr.setCustomValidity('');  
        else  
           tbayValidtnErr.setCustomValidity('Please check thunder bay NetMove');   
        
        if(edmontonNetMove == kamloopsNetMove)     
           kamloopsValidtnErr.setCustomValidity('');     
        else 
           kamloopsValidtnErr.setCustomValidity('Please check Kamloops NetMove');    
           
        if(torontoNetMove == bellevilleNetMove)     
           bellevilleValidtnErr.setCustomValidity('');     
        else 
           bellevilleValidtnErr.setCustomValidity('Please check Belleville NetMove');  
           
        if(ottawaNetMove == kingstonNetMove)     
           kingstonValidtnErr.setCustomValidity('');     
        else 
           kingstonValidtnErr.setCustomValidity('Please check Kingston NetMove');  
           
        if(sarniaNetMove == ssmarieNetMove)     
           ssmarieValidtnErr.setCustomValidity('');     
        else 
           ssmarieValidtnErr.setCustomValidity('Please check SS Marie NetMove');   
           
        if(sarniaNetMove == londonNetMove)     
           londonValidtnErr.setCustomValidity('');     
        else 
           londonValidtnErr.setCustomValidity('Please check London NetMove');           
                
        ottawaValidtnErr.reportValidity();
        sarniaValidtnErr.reportValidity();
        tbayValidtnErr.reportValidity();
        kamloopsValidtnErr.reportValidity();  
        bellevilleValidtnErr.reportValidity();  
        kingstonValidtnErr.reportValidity();  
        ssmarieValidtnErr.reportValidity();  
        londonValidtnErr.reportValidity();  
    }

    handleDieselCompAdjChange(event)
    {
        var changeCompAdj = event.target.value;  
        var changeCompAdjRack = event.target.name;     
        var prevTodaysPrice = 0.00;      
        var prevMarketMove = 0.00;
        let prevTodaysPriceVal = new Map();
        let prevMarketMoveVal = new Map();  
        let compAdjRack = new Map();        
      
        this.moaDieselResultBackup.forEach(function(element, index)
        {
            compAdjRack.set(element.Id, element.RE_CND_Rack__c);
            prevTodaysPriceVal.set(element.RE_CND_Rack__c, element.RE_CND_Today_s_Price__c);
            prevMarketMoveVal.set(element.RE_CND_Rack__c, element.RE_CND_Market_Move__c);              
        });

        var ottawaNetMove = 0.00;
        var ottawaClassname = '.';
        var torontoNetMove = 0.00;       
        var sarniaNetMove = 0.00;
        var sarniaClassname = '.';

        var edmontonNetMove = 0.00;
        var thunderbayNetMove = 0.00;
        var thunderbayClassname = '.';
        var kamloopsNetMove = 0.00;
        var kamloopsClassname = '.';

        var bellevilleNetMove = 0.00;
        var bellevilleClassname = '.';
        var kingstonNetMove = 0.00;
        var kingstonClassname = '.';
        var ssmarieNetMove = 0.00;
        var ssmarieClassname = '.';
        var londonNetMove = 0.00;
        var londonClassname = '.';        
        
        if(compAdjRack.has(changeCompAdjRack))
          changeCompAdjRack = compAdjRack.get(changeCompAdjRack);
        else
          changeCompAdjRack = 'Toronto';           

        let derivedRacks = new Map();     
      
        if(changeCompAdjRack === 'Montreal')        
           derivedRacks.set('Montreal','Montreal');
        else if(changeCompAdjRack === 'Edmonton') 
        {       
           derivedRacks.set('Edmonton','Edmonton'); 
           derivedRacks.set('Thunder Bay','Thunder Bay');  
           derivedRacks.set('Kamloops','Kamloops'); 
        }     
        else if(changeCompAdjRack === 'Thunder Bay')        
           derivedRacks.set('Thunder Bay','Thunder Bay');  
        else if(changeCompAdjRack === 'Kamloops')        
           derivedRacks.set('Kamloops','Kamloops'); 
        else if(changeCompAdjRack === 'Vancouver')        
           derivedRacks.set('Vancouver','Vancouver');            
        else if(changeCompAdjRack === 'Toronto') 
        {      
           derivedRacks.set('Toronto','Toronto');           
           derivedRacks.set('Ottawa','Ottawa'); 
           derivedRacks.set('Belleville','Belleville');
           derivedRacks.set('Kingston','Kingston');  
           derivedRacks.set('Sarnia','Sarnia');             
           derivedRacks.set('London','London'); 
           derivedRacks.set('Sault Ste Marie','Sault Ste Marie');             
        }
        else if(changeCompAdjRack === 'Ottawa')
        {  
           derivedRacks.set('Ottawa','Ottawa'); 
           derivedRacks.set('Belleville','Belleville');
           derivedRacks.set('Kingston','Kingston');
        }
        else if(changeCompAdjRack === 'Sarnia')
        {
           derivedRacks.set('Sarnia','Sarnia');             
           derivedRacks.set('London','London'); 
           derivedRacks.set('Sault Ste Marie','Sault Ste Marie'); 
        }
        else if(changeCompAdjRack === 'Belleville')        
           derivedRacks.set('Belleville','Belleville'); 
        else if(changeCompAdjRack === 'Kingston')        
           derivedRacks.set('Kingston','Kingston');                        
        else if(changeCompAdjRack === 'London')        
           derivedRacks.set('London','London'); 
        else if(changeCompAdjRack === 'Sault Ste Marie')        
           derivedRacks.set('Sault Ste Marie','Sault Ste Marie');         

        this.moaDieselResult.forEach(function(element, index)
        {
            if(derivedRacks.has(element.RE_CND_Rack__c)) 
            {
                if(changeCompAdj === null || changeCompAdj === '')
                {                                           
                    changeCompAdj = 0.00;  
                    element.RE_CND_Competitive_Adj__c  = 0.00;
                }
                else
                   element.RE_CND_Competitive_Adj__c = changeCompAdj;
                 
                if(prevMarketMoveVal.has(element.RE_CND_Rack__c))                
                    prevMarketMove = prevMarketMoveVal.get(element.RE_CND_Rack__c);
                else
                    prevMarketMove = 0.00;  
                    
                if(prevTodaysPriceVal.has(element.RE_CND_Rack__c))                
                    prevTodaysPrice = prevTodaysPriceVal.get(element.RE_CND_Rack__c);
                else
                    prevTodaysPrice = 0.00;   
                              
                var newNetMove = (+ parseFloat(prevMarketMove)) + (+ parseFloat(changeCompAdj));                

                if(parseFloat(newNetMove).toFixed(1) == -0.0)
                    element.RE_CND_Net_Move__c = 0.00; 
                else   
                    element.RE_CND_Net_Move__c = parseFloat(newNetMove).toFixed(1); 

                var newNewEnd = (+ parseFloat(prevTodaysPrice)) + (+ parseFloat(element.RE_CND_Net_Move__c))
                element.RE_CND_New_End_Price__c = parseFloat(newNewEnd).toFixed(1);                     
            }
           
            if(element.RE_CND_Rack__c.toLowerCase() === 'toronto')            
                torontoNetMove = element.RE_CND_Net_Move__c;      
            else if(element.RE_CND_Rack__c.toLowerCase() === 'ottawa')  
            {   
                ottawaNetMove = element.RE_CND_Net_Move__c;
                ottawaClassname = ottawaClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'sarnia')  
            {   
                sarniaNetMove = element.RE_CND_Net_Move__c;
                sarniaClassname = sarniaClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'edmonton')  
                edmontonNetMove = element.RE_CND_Net_Move__c;  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'thunder bay')  
            {   
                thunderbayNetMove = element.RE_CND_Net_Move__c;
                thunderbayClassname = thunderbayClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'kamloops')  
            {   
                kamloopsNetMove = element.RE_CND_Net_Move__c;
                kamloopsClassname = kamloopsClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'belleville')  
            {   
                bellevilleNetMove = element.RE_CND_Net_Move__c;
                bellevilleClassname = bellevilleClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'kingston')  
            {   
                kingstonNetMove = element.RE_CND_Net_Move__c;
                kingstonClassname = kingstonClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'london')  
            {   
                londonNetMove = element.RE_CND_Net_Move__c;
                londonClassname = londonClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'sault ste marie')  
            {   
                ssmarieNetMove = element.RE_CND_Net_Move__c;
                ssmarieClassname = ssmarieClassname + element.Id;
            }                           
        });
       
        let ottawaValidtnErr = this.template.querySelector(ottawaClassname);
        let sarniaValidtnErr = this.template.querySelector(sarniaClassname);
        let tbayValidtnErr = this.template.querySelector(thunderbayClassname);
        let kamloopsValidtnErr = this.template.querySelector(kamloopsClassname);
        let bellevilleValidtnErr = this.template.querySelector(bellevilleClassname);
        let kingstonValidtnErr = this.template.querySelector(kingstonClassname);
        let ssmarieValidtnErr = this.template.querySelector(ssmarieClassname);
        let londonValidtnErr = this.template.querySelector(londonClassname);        
      
        if(torontoNetMove == ottawaNetMove)           
            ottawaValidtnErr.setCustomValidity('');      
        else  
            ottawaValidtnErr.setCustomValidity('Please check Ottawa NetMove');   

        if(torontoNetMove == sarniaNetMove)         
            sarniaValidtnErr.setCustomValidity('');    
        else 
            sarniaValidtnErr.setCustomValidity('Please check Sarnia NetMove');   

        if(edmontonNetMove == thunderbayNetMove)           
            tbayValidtnErr.setCustomValidity('');      
        else  
            tbayValidtnErr.setCustomValidity('Please check thunder bay NetMove');   

        if(edmontonNetMove == kamloopsNetMove)         
            kamloopsValidtnErr.setCustomValidity('');    
        else 
            kamloopsValidtnErr.setCustomValidity('Please check Kamloops NetMove');     

        if(ottawaNetMove == bellevilleNetMove)     
            bellevilleValidtnErr.setCustomValidity('');     
        else 
            bellevilleValidtnErr.setCustomValidity('Please check Belleville NetMove');  
            
        if(ottawaNetMove == kingstonNetMove)     
            kingstonValidtnErr.setCustomValidity('');     
        else 
            kingstonValidtnErr.setCustomValidity('Please check Kingston NetMove');  
            
        if(sarniaNetMove == ssmarieNetMove)     
            ssmarieValidtnErr.setCustomValidity('');     
        else 
            ssmarieValidtnErr.setCustomValidity('Please check SS Marie NetMove');   
            
        if(sarniaNetMove == londonNetMove)     
            londonValidtnErr.setCustomValidity('');     
        else 
            londonValidtnErr.setCustomValidity('Please check London NetMove');             
        
        ottawaValidtnErr.reportValidity();
        sarniaValidtnErr.reportValidity();
        tbayValidtnErr.reportValidity();
        kamloopsValidtnErr.reportValidity(); 
        bellevilleValidtnErr.reportValidity();  
        kingstonValidtnErr.reportValidity();  
        ssmarieValidtnErr.reportValidity();  
        londonValidtnErr.reportValidity();                  
    }

    closeModal(event) {      
        this.showModal = false; 
        this.showOPISModal = false;           
    }

    handleKeyPress({code}) {
        if ('Escape' === code) {
            this.closeModal();
        }
    }

    handleMarketMovesFromOPIS(evt)
    {    
        this.toastMsg = '';
        let validateInput = this.validateInput();
        if(validateInput)
        { 
            var currOpisStats = '';
            if(this.template.querySelector('[data-id="currOpisStatus"]').value === null || this.template.querySelector('[data-id="currOpisStatus"]').value === '')
               currOpisStats = null;
            else   
               currOpisStats = this.template.querySelector('[data-id="currOpisStatus"]').value;

            var prvOpisStats = '';
            if(this.template.querySelector('[data-id="prevOpisStatus"]').value === null || this.template.querySelector('[data-id="prevOpisStatus"]').value === '')
               prvOpisStats = null;
            else   
               prvOpisStats = this.template.querySelector('[data-id="prevOpisStatus"]').value;               

            if(currOpisStats === null || currOpisStats === '' || currOpisStats === 'OPIS Spot Ticker exist')   
            {
                if(prvOpisStats === null || prvOpisStats === '' || prvOpisStats === 'OPIS Spot Ticker exist')   
                {   
                    var currOPISTrckrDate = '1990-01-01';
                    var currFxRateDate = '1990-01-01';
                    var currFxValue = '0.00';
                    var prevOPISTrckrDate = '1990-01-01';
                    var prevFxRateDate = '1990-01-01';
                    var prvFxValue = '0.00'; 
        
                    if(this.template.querySelector('[data-id="currOPISTrckrDate"]').value === null || this.template.querySelector('[data-id="currOPISTrckrDate"]').value === '')
                      currOPISTrckrDate = '1990-01-01';
                    else
                      currOPISTrckrDate = this.template.querySelector('[data-id="currOPISTrckrDate"]').value;
        
                    if(this.template.querySelector('[data-id="currFxRateDate"]').value === null || this.template.querySelector('[data-id="currFxRateDate"]').value === '')
                      currFxRateDate = '1990-01-01';
                    else
                      currFxRateDate = this.template.querySelector('[data-id="currFxRateDate"]').value;
                      
                    if(this.template.querySelector('[data-id="currFxRate"]').value === null || this.template.querySelector('[data-id="currFxRate"]').value === '')
                      currFxValue = '0.00';
                    else
                      currFxValue = this.template.querySelector('[data-id="currFxRate"]').value;              
        
                    if(this.template.querySelector('[data-id="prevOPISTrckrDate"]').value === null || this.template.querySelector('[data-id="prevOPISTrckrDate"]').value === '')
                      prevOPISTrckrDate = '1990-01-01';
                    else
                      prevOPISTrckrDate = this.template.querySelector('[data-id="prevOPISTrckrDate"]').value;              
        
                    if(this.template.querySelector('[data-id="prevFxRateDate"]').value === null || this.template.querySelector('[data-id="prevFxRateDate"]').value === '')
                      prevFxRateDate = '1990-01-01';
                    else
                      prevFxRateDate = this.template.querySelector('[data-id="prevFxRateDate"]').value;              
        
                    if(this.template.querySelector('[data-id="prevFxRate"]').value === null || this.template.querySelector('[data-id="prevFxRate"]').value === '')
                      prvFxValue = '0.00';
                    else
                      prvFxValue = this.template.querySelector('[data-id="prevFxRate"]').value;  

                    var today = this.getLoggedInUserDate('');   

                    if((prevOPISTrckrDate === '1990-01-01') && (currOPISTrckrDate < today))
                    {
                        console.log('Please chose Previous OPIS Spot Ticker instead of Current OPIS Spot Ticker')
                        this.toastMsg = 'Please chose Previous OPIS Spot Ticker instead of Current, if it considered only previous OPIS';
                        this.showOPISProcessInfoToast();                        
                    }
                    else if((currFxRateDate === prevFxRateDate) && (currFxValue !== prvFxValue))
                    {
                      console.log('Current & Previous Fx Rate should be matched for same FxRate Date');                         
                      this.toastMsg = 'Current & Previous Fx Rate should be matched for same FxRate Date';
                      this.showOPISProcessInfoToast();  
                    }
                    else if(((currFxRateDate !== '1990-01-01') && (currFxValue === '0')) || ((prevFxRateDate !== '1990-01-01') && (prvFxValue === '0')))
                    {
                        console.log('Current/Previous FxRate should be non zero Value');
                        this.toastMsg = 'Current/Previous FxRate should be non zero Value';
                        this.showOPISProcessInfoToast(); 
                    }   
                    else
                    {
                        this.reqToDate = this.template.querySelector('[data-id="effectiveToDate"]').value;
                        getExistingDepoPricingPriceBook({request_Date:this.template.querySelector('[data-id="requestedDate"]').value})
                        .then(result => { 
                            if(result != undefined){                           
                                var totRecords = result.totalRecordCount;  
                                this.isDepotPricngJobExists = false;
                                this.isUplodedRecordExists = false; 
                                this.isProcedBtnActive = false;
                                if(totRecords === 3)
                                {
                                    this.isDepotPricngJobExists = true;
                                    this.isProcedBtnActive = true;
                                    this.jobRunStartDtTime = result.jobStartDateTime;
                                    this.jobRunName = result.jobRunName;
                                }
                                else if(totRecords === 2)
                                {
                                    this.isUplodedRecordExists = true;
                                    this.isProcedBtnActive = true;
                                }
                                else if(totRecords === 0)
                                    this.isRecordExists = false;
                                else
                                    this.isRecordExists = true;                                    
                            }
                        }).catch(error => {
                             console.log('depotPricingPopup error -->'+JSON.stringify(error));
                        });

                        if(this.isDepotPricngJobExists == true)
                        {
                            console.log('Another Calculate Depot Pricing Job is in progress! So please wait to complete that Job.');                         
                            this.toastMsg = 'Another Calculate Depot Pricing Job is in progress! So please wait to complete that Job.';
                            this.showOPISProcessInfoToast();  
                        }
                        else if(this.isUplodedRecordExists == false)
                        {
                            this.isProcedBtnActive = true;
                            this.isLoading = true; 
                            generateMVandMOAFromOpisSpotTickrData({requestedDt:this.template.querySelector('[data-id="requestedDate"]').value, effectiveFromDate:this.template.querySelector('[data-id="effectiveFromDate"]').value, effectiveToDate:this.template.querySelector('[data-id="effectiveToDate"]').value, currOPISTikrDate: currOPISTrckrDate, currFxRateDate: currFxRateDate, currFxRate: currFxValue, prevOPISTikrDate: prevOPISTrckrDate, prevFxRateDate: prevFxRateDate, prevFxRate: prvFxValue})
                            .then(result => {
                                if(result != undefined){   
                                    var executionStatus = result.executionStatus; 
                                    this.toastMsg =  result.errorMsg;  
                                    var jobRunAudId = result.jobRunAuditId;            
                                    if(executionStatus === 'success')
                                    {                 
                                        let marketMovePromise = new Promise( (resolve, reject) => {
                                        let interval = setInterval(() => {                               
                                            getJobRunAuditStatus({jobRunAudId : jobRunAudId})
                                            .then(result => {
                                                    if(result != undefined){                                         
                                                        if(result.toLowerCase() === 'completed' || result.toLowerCase() === 'partial complete' || result.toLowerCase() === 'failed')
                                                        {                       
                                                            this.IsreqFromToDisabled = false;
                                                            this.isLoading = false;                     
                                                            clearInterval(interval);                                                                                   
                                                            this.closeModal();   
                                                            if(result.toLowerCase() === 'failed')
                                                            {
                                                                this.toastMsg = 'Market Move Calculation has been failed, please check with Support Team!';
                                                                this.showFailedToast();
                                                            }
                                                            else
                                                            {
                                                                this.toastMsg = 'Market Move Calculation has been completed successfully!';
                                                                this.showSuccessToast();
                                                            }

                                                            this.initialMOAPageload();                                        
                                                            resolve();
                                                        }
                                                    }
                                                })
                                                .catch(error => { 
                                                    this.IsreqFromToDisabled = false;
                                                    this.isProcedBtnActive = false;
                                                    this.isLoading = false;  
                                                    console.log('error MarketMove Job Run Audit -->'+JSON.stringify(this.error));
                                                });
                                            }, 3000)
                                        });
                
                                        marketMovePromise.then();
                                    }
                                    else if(executionStatus === 'failed')
                                    {                   
                                        this.IsreqFromToDisabled = false;
                                        this.isProcedBtnActive = false;
                                        this.isLoading = false; 
                                        this.closeModal(); 
                                        this.showFailedToast();                         
                                    }  
                                    else if(executionStatus === 'info')
                                    {                 
                                        this.IsreqFromToDisabled = false;
                                        this.isProcedBtnActive = false;
                                        this.isLoading = false;   
                                        this.closeModal(); 
                                        this.showOPISProcessInfoToast();                         
                                    }               
                                }           
                            })
                            .catch(error => {             
                                this.IsreqFromToDisabled = true;
                                this.isProcedBtnActive = false;
                                this.isLoading = false;         
                                console.log('error while generating OPIS Data-->'+JSON.stringify(this.error));
                                this.toastMsg = 'There are some error while calculating Market Move, please check exception log!';
                                this.showFailedToast();  
                            });   
    
                        }
                        else
                        {
                            console.log('Pricing is already calculated and records uploaded to SAP as well! So please do further changes in CA Dashboard itself.');                         
                            this.toastMsg = 'Pricing is already calculated and records uploaded to SAP as well! So do further changes in CA Dashboard itself.';
                            this.showOPISProcessInfoToast();  
                        }
                    }               
                }
            }
        }   
    }
    
    depoPricingPopup(evt)
    {   
        this.isYesBtnActive = true;
        this.isLoading = false;
        var ottawaGasNetMove = 0.00;
        var ottawaGasClassname = '.';
        var torontoGasNetMove = 0.00;       
        var sarniaGasNetMove = 0.00;
        var sarniaGasClassname = '.';

        var edmontonGasNetMove = 0.00;
        var thunderbayGasNetMove = 0.00;
        var thunderbayGasClassname = '.';
        var kamloopsGasNetMove = 0.00;
        var kamloopsGasClassname = '.';   
        
        var bellevilleGasNetMove = 0.00;
        var bellevilleGasClassname = '.';
        var kingstonGasNetMove = 0.00;
        var kingstonGasClassname = '.';
        var ssmarieGasNetMove = 0.00;
        var ssmarieGasClassname = '.';
        var londonGasNetMove = 0.00;
        var londonGasClassname = '.';        
        
        this.moaGosolineResult.forEach(function(element, index)
        {     
            if(element.RE_CND_Rack__c.toLowerCase() === 'toronto')            
                torontoGasNetMove = element.RE_CND_Net_Move__c;      
            else if(element.RE_CND_Rack__c.toLowerCase() === 'ottawa')  
            {   
                ottawaGasNetMove = element.RE_CND_Net_Move__c;
                ottawaGasClassname = ottawaGasClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'sarnia')  
            {   
                sarniaGasNetMove = element.RE_CND_Net_Move__c;
                sarniaGasClassname = sarniaGasClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'edmonton')  
                edmontonGasNetMove = element.RE_CND_Net_Move__c;  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'thunder bay')  
            {   
                thunderbayGasNetMove = element.RE_CND_Net_Move__c;
                thunderbayGasClassname = thunderbayGasClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'kamloops')  
            {   
                kamloopsGasNetMove = element.RE_CND_Net_Move__c;
                kamloopsGasClassname = kamloopsGasClassname + element.Id;
            } 
            else if(element.RE_CND_Rack__c.toLowerCase() === 'belleville')  
            {   
                bellevilleGasNetMove = element.RE_CND_Net_Move__c;
                bellevilleGasClassname = bellevilleGasClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'kingston')  
            {   
                kingstonGasNetMove = element.RE_CND_Net_Move__c;
                kingstonGasClassname = kingstonGasClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'london')  
            {   
                londonGasNetMove = element.RE_CND_Net_Move__c;
                londonGasClassname = londonGasClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'sault ste marie')  
            {   
                ssmarieGasNetMove = element.RE_CND_Net_Move__c;
                ssmarieGasClassname = ssmarieGasClassname + element.Id;
            }      
        });
       
        let ottawaGasValidtnErr = this.template.querySelector(ottawaGasClassname);
        let sarniaGasValidtnErr = this.template.querySelector(sarniaGasClassname);
        let tbayGasValidtnErr = this.template.querySelector(thunderbayGasClassname);
        let kamloopsGasValidtnErr = this.template.querySelector(kamloopsGasClassname);
        let bellevilleGasValidtnErr = this.template.querySelector(bellevilleGasClassname);
        let kingstonGasValidtnErr = this.template.querySelector(kingstonGasClassname);
        let ssmarieGasValidtnErr = this.template.querySelector(ssmarieGasClassname);
        let londonGasValidtnErr = this.template.querySelector(londonGasClassname);        
      
        if(torontoGasNetMove == ottawaGasNetMove)           
            ottawaGasValidtnErr.setCustomValidity('');      
        else  
            ottawaGasValidtnErr.setCustomValidity('Please check Ottawa NetMove');   

        if(torontoGasNetMove == sarniaGasNetMove)         
            sarniaGasValidtnErr.setCustomValidity('');    
        else 
            sarniaGasValidtnErr.setCustomValidity('Please check Sarnia NetMove');   

        if(edmontonGasNetMove == thunderbayGasNetMove)           
            tbayGasValidtnErr.setCustomValidity('');      
        else  
            tbayGasValidtnErr.setCustomValidity('Please check thunder bay NetMove');   

        if(edmontonGasNetMove == kamloopsGasNetMove)         
            kamloopsGasValidtnErr.setCustomValidity('');    
        else 
            kamloopsGasValidtnErr.setCustomValidity('Please check Kamloops NetMove'); 
            
        if(torontoGasNetMove == bellevilleGasNetMove)     
            bellevilleGasValidtnErr.setCustomValidity('');     
        else 
            bellevilleGasValidtnErr.setCustomValidity('Please check Belleville NetMove');  
            
        if(ottawaGasNetMove == kingstonGasNetMove)     
            kingstonGasValidtnErr.setCustomValidity('');     
        else 
            kingstonGasValidtnErr.setCustomValidity('Please check Kingston NetMove');  
            
        if(sarniaGasNetMove == ssmarieGasNetMove)     
            ssmarieGasValidtnErr.setCustomValidity('');     
        else 
            ssmarieGasValidtnErr.setCustomValidity('Please check SS Marie NetMove');   
            
        if(sarniaGasNetMove == londonGasNetMove)     
            londonGasValidtnErr.setCustomValidity('');     
        else 
            londonGasValidtnErr.setCustomValidity('Please check London NetMove');             
        
        ottawaGasValidtnErr.reportValidity();
        sarniaGasValidtnErr.reportValidity();
        tbayGasValidtnErr.reportValidity();
        kamloopsGasValidtnErr.reportValidity();
        bellevilleGasValidtnErr.reportValidity();  
        kingstonGasValidtnErr.reportValidity();  
        ssmarieGasValidtnErr.reportValidity();  
        londonGasValidtnErr.reportValidity();              
        
        var ottawaNetMove = 0.00;
        var ottawaClassname = '.';
        var torontoNetMove = 0.00;       
        var sarniaNetMove = 0.00;
        var sarniaClassname = '.';

        var edmontonNetMove = 0.00;
        var thunderbayNetMove = 0.00;
        var thunderbayClassname = '.';
        var kamloopsNetMove = 0.00;
        var kamloopsClassname = '.';  
        
        var bellevilleNetMove = 0.00;
        var bellevilleClassname = '.';
        var kingstonNetMove = 0.00;
        var kingstonClassname = '.';
        var ssmarieNetMove = 0.00;
        var ssmarieClassname = '.';
        var londonNetMove = 0.00;
        var londonClassname = '.';

        this.moaDieselResult.forEach(function(element, index)
        {           
            if(element.RE_CND_Rack__c.toLowerCase() === 'toronto')            
                torontoNetMove = element.RE_CND_Net_Move__c;      
            else if(element.RE_CND_Rack__c.toLowerCase() === 'ottawa')  
            {   
                ottawaNetMove = element.RE_CND_Net_Move__c;
                ottawaClassname = ottawaClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'sarnia')  
            {   
                sarniaNetMove = element.RE_CND_Net_Move__c;
                sarniaClassname = sarniaClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'edmonton')  
                edmontonNetMove = element.RE_CND_Net_Move__c;  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'thunder bay')  
            {   
                thunderbayNetMove = element.RE_CND_Net_Move__c;
                thunderbayClassname = thunderbayClassname + element.Id;
            }
            else if(element.RE_CND_Rack__c.toLowerCase() === 'kamloops')  
            {   
                kamloopsNetMove = element.RE_CND_Net_Move__c;
                kamloopsClassname = kamloopsClassname + element.Id;
            } 
            else if(element.RE_CND_Rack__c.toLowerCase() === 'belleville')  
            {   
                bellevilleNetMove = element.RE_CND_Net_Move__c;
                bellevilleClassname = bellevilleClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'kingston')  
            {   
                kingstonNetMove = element.RE_CND_Net_Move__c;
                kingstonClassname = kingstonClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'london')  
            {   
                londonNetMove = element.RE_CND_Net_Move__c;
                londonClassname = londonClassname + element.Id;
            }  
            else if(element.RE_CND_Rack__c.toLowerCase() === 'sault ste marie')  
            {   
                ssmarieNetMove = element.RE_CND_Net_Move__c;
                ssmarieClassname = ssmarieClassname + element.Id;
            }                        
        });
       
        let ottawaValidtnErr = this.template.querySelector(ottawaClassname);
        let sarniaValidtnErr = this.template.querySelector(sarniaClassname);
        let tbayValidtnErr = this.template.querySelector(thunderbayClassname);
        let kamloopsValidtnErr = this.template.querySelector(kamloopsClassname);
        let bellevilleValidtnErr = this.template.querySelector(bellevilleClassname);
        let kingstonValidtnErr = this.template.querySelector(kingstonClassname);
        let ssmarieValidtnErr = this.template.querySelector(ssmarieClassname);
        let londonValidtnErr = this.template.querySelector(londonClassname);        
      
        if(torontoNetMove == ottawaNetMove)           
            ottawaValidtnErr.setCustomValidity('');      
        else  
            ottawaValidtnErr.setCustomValidity('Please check Ottawa NetMove');   

        if(torontoNetMove == sarniaNetMove)         
            sarniaValidtnErr.setCustomValidity('');    
        else 
            sarniaValidtnErr.setCustomValidity('Please check Sarnia NetMove');   

        if(edmontonNetMove == thunderbayNetMove)           
            tbayValidtnErr.setCustomValidity('');      
        else  
            tbayValidtnErr.setCustomValidity('Please check thunder bay NetMove');   

        if(edmontonNetMove == kamloopsNetMove)         
            kamloopsValidtnErr.setCustomValidity('');    
        else 
            kamloopsValidtnErr.setCustomValidity('Please check Kamloops NetMove');  
            
        if(ottawaNetMove == bellevilleNetMove)     
            bellevilleValidtnErr.setCustomValidity('');     
        else 
            bellevilleValidtnErr.setCustomValidity('Please check Belleville NetMove');  
            
        if(ottawaNetMove == kingstonNetMove)     
            kingstonValidtnErr.setCustomValidity('');     
        else 
            kingstonValidtnErr.setCustomValidity('Please check Kingston NetMove');  
            
        if(sarniaNetMove == ssmarieNetMove)     
            ssmarieValidtnErr.setCustomValidity('');     
        else 
            ssmarieValidtnErr.setCustomValidity('Please check SS Marie NetMove');   
            
        if(sarniaNetMove == londonNetMove)     
            londonValidtnErr.setCustomValidity('');     
        else 
            londonValidtnErr.setCustomValidity('Please check London NetMove');            
        
        ottawaValidtnErr.reportValidity();
        sarniaValidtnErr.reportValidity();
        tbayValidtnErr.reportValidity();
        kamloopsValidtnErr.reportValidity();  
        bellevilleValidtnErr.reportValidity();  
        kingstonValidtnErr.reportValidity();  
        ssmarieValidtnErr.reportValidity();  
        londonValidtnErr.reportValidity();                

        this.reqToDate = this.template.querySelector('[data-id="effectiveToDate"]').value;
        getExistingDepoPricingPriceBook({request_Date:this.template.querySelector('[data-id="requestedDate"]').value})
        .then(result => { 
            if(result != undefined){                           
                var totRecords = result.totalRecordCount;  
                this.isDepotPricngJobExists = false;
                this.isUplodedRecordExists = false; 
                this.isYesBtnActive = false;
                if(totRecords === 3)
                {
                    this.isDepotPricngJobExists = true;
                    this.isYesBtnActive = true;
                    this.jobRunStartDtTime = result.jobStartDateTime;
                    this.jobRunName = result.jobRunName;                    
                }
                else if(totRecords === 2)
                {
                    this.isUplodedRecordExists = true;
                    this.isYesBtnActive = true;
                }
                else if(totRecords === 0)
                    this.isRecordExists = false;
                else
                    this.isRecordExists = true;                                    
            }
        }).catch(error => {
             console.log('depotPricingPopup error -->'+JSON.stringify(error));
        });

        this.showModal = true;  
    }

    validateInput(){
        const allValid = [...this.template.querySelectorAll('lightning-input')]
                .reduce((validSoFar, inputCmp) => {
                            inputCmp.reportValidity();
                            return validSoFar && inputCmp.checkValidity();
                }, true);
        if (allValid) {
            return true;
        } else {
            return false;
        }         
    }    
    
    handleCalDepoPricing(evt)
    {       
        this.isYesBtnActive = true;
        this.isLoading = true;       
        let updatedMOAGasolineDiesel = [];
        
        this.moaGosolineResult.forEach(function(element, index){                           
           updatedMOAGasolineDiesel.push(element);    
        });

        this.moaDieselResult.forEach(function(element, index){            
            updatedMOAGasolineDiesel.push(element); 
         });   
                 
        startCalculatingDepoPricing({request_Date:this.template.querySelector('[data-id="requestedDate"]').value, effectiveFromDate:this.template.querySelector('[data-id="effectiveFromDate"]').value, effectiveToDate:this.template.querySelector('[data-id="effectiveToDate"]').value, updatedMOA: updatedMOAGasolineDiesel})
        .then(result => {
            if(result != undefined){   
                var executionStatus = result.pricExecStatus;               
                var jobRunAudId = result.jobRunAuditId;            
                if(executionStatus === 'success')
                { 
                    let priceExectnPromise = new Promise( (resolve, reject) => {
                        let interval = setInterval(() => {                               
                            getJobRunAuditStatus({jobRunAudId : jobRunAudId})
                            .then(result => {                               
                                    if(result != undefined){                                         
                                        if(result.toLowerCase() === 'completed' || result.toLowerCase() === 'partial complete' || result.toLowerCase() === 'failed')
                                        {                                         
                                            this.isLoading = false;  
                                            this.isYesBtnActive = false;                    
                                            clearInterval(interval);                                                                                   
                                            this.closeModal();   
                                            if(result.toLowerCase() === 'failed')
                                            {                                                
                                                this.toastMsg = 'Depot Pricing Calculation has been failed, please check with Support Team!';                            
                                                this.showFailedToast();  
                                            } 
                                            else
                                            {
                                                this.toastMsg = 'Depot Pricing Calculation has been completed successfully!';                            
                                                this.showSuccessToast();   
                                                this.navigateToTab();  
                                            }                                 
                                            resolve();
                                        }
                                    }
                                })
                                .catch(error => {    
                                    this.isYesBtnActive = false;                                 
                                    this.isLoading = false;  
                                    console.log('error Price Execution Job Run Audit -->'+JSON.stringify(this.error));
                                });
                            }, 10000)
                        });

                        priceExectnPromise.then(); 
                }
                else{      
                    this.isYesBtnActive = false;   
                    this.isLoading = false;
                    this.closeModal();   
                    this.toastMsg = 'There are some error while calculating Market Move, please check exception log!';              
                    this.showFailedToast();                            
                }
            }        
        })
        .catch(error => {
            this.isYesBtnActive = false;
            this.isLoading = false;
            console.log('error -->'+JSON.stringify(this.error));
            this.toastMsg = 'There are some error while calculating Market Move, please check exception log!';
            this.showFailedToast();  
        });   
    }
        
    navigateToTab() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {                
                apiName: 'RE_CND_Canada_Dashboard'               
            },
            state: {
                c__reloadDashboard: 'yes'
            }
        });
    }

    handleEffectvToDateChange(evt)
    {
        var effctvToDt = evt.target.value; 
        this.reqToDate = effctvToDt;     
    }

    opisSpotTikcrPopup(evt)
    {
        this.isYesBtnActive = true;
        this.prevFxRateReq = false;
        this.currFxRateReq = false;
        this.currOpisStatusMsg = ''; 
        this.prevOpisStatusMsg = ''; 
        this.currFxValue = '';       
        this.prvFxValue = ''; 
        this.isProcedBtnActive = true;
        this.isLoading = false;

        this.isDisbldCurrFxRateDt = true;
        this.isCurrFxExists = true;
        this.isDisbldPrevFxRateDt = true;
        this.isPrevFxExists = true;

        let validateInput = this.validateInput();
        if(validateInput)
        {
            getExistingMarketMoveAndMOA({requested_Date:this.template.querySelector('[data-id="requestedDate"]').value})
            .then(result => { 
                if(result != undefined){                           
                    var totRecords = result.totalRecordCount;    
                    this.isUplodedRecordExists = false; 
                    this.isMVCalcJobExists = false;
                    this.isYesBtnActive = false;    
                    if(totRecords === 3)
                    {
                        this.isMVCalcJobExists = true;
                        this.isYesBtnActive = true;
                        this.jobRunStartDtTime = result.jobStartDateTime;
                        this.jobRunName = result.jobRunName;
                    }    
                    else if(totRecords === 2)
                    {
                        this.isUplodedRecordExists = true;
                        this.isYesBtnActive = true;
                    }              
                    else if(totRecords === 0)
                        this.isMVRecordExists = false;
                    else
                        this.isMVRecordExists = true;                                    
                }
            }).catch(error => {
                 console.log('depotPricingPopup error -->'+JSON.stringify(error));
            });            
            this.showOPISModal = true;
        }
    }

    handleCurrOPISTrckrDateChange(evt)
    {                      
        this.isProcedBtnActive = true;        
        this.currOpisStatusMsg = '';        
        var currOPISTikrDate = evt.target.value;          
        if(currOPISTikrDate === null || currOPISTikrDate === '')
        {
          this.isDisbldCurrFxRateDt = true;
          this.isCurrFxExists = true;  
          this.currFxRateReq = false;
          this.currFxRateDt = ''; 
          this.currFxValue = ''; 
          this.currFxRateDt = null;
          this.currFxValue = null; 
        }
        else
        {
          this.currFxRateReq = true; 
          this.isDisbldCurrFxRateDt = false;                        
          this.isLoading = true;
          var today = this.getLoggedInUserDate('');  
          if(currOPISTikrDate === today) 
          {
             checkOPISSpotTickerExistsOrNot({requestedOpisRecevdDt:currOPISTikrDate, isProcessed: false})
             .then(result => {
                if(result != undefined){                                         
                    if(result.toLowerCase() === 'received data')  
                    {                   
                      this.currOpisStatusMsg = 'OPIS Spot Ticker exist'; 
                      this.isProcedBtnActive = false; 
                    }        
                    else if(result.toLowerCase() === 'missing data')                    
                      this.currOpisStatusMsg = 'OPIS Spot Ticker exist, but few data missing!';          
                    else if(result.toLowerCase() === 'not received data')                    
                      this.currOpisStatusMsg = 'OPIS Spot Ticker does not exist!';          
                  }
                  this.isLoading = false;              
                })
                .catch(error => { 
                    this.isLoading = false;
                    console.log('Current OPIS Spot Ticker error -->'+JSON.stringify(this.error));
                });             
          }
          else  
          {
            checkPreviousOPISSpotTickerExistsOrNot({requestedOpisRecevdDt:currOPISTikrDate})
            .then(result => {
              if(result != undefined){                                         
                  if(result.toLowerCase() === 'received data')     
                  {                
                    this.currOpisStatusMsg = 'OPIS Spot Ticker exist';  
                    this.isProcedBtnActive = false;            
                  }        
                  else if(result.toLowerCase() === 'missing data')                    
                    this.currOpisStatusMsg = 'OPIS Spot Ticker exist, but few data missing!';          
                  else if(result.toLowerCase() === 'not received data')                    
                    this.currOpisStatusMsg = 'OPIS Spot Ticker does not exist!';          
                }
                this.isLoading = false;              
              })
              .catch(error => { 
                  this.isLoading = false;
                  console.log('Previous OPIS Spot Ticker error -->'+JSON.stringify(this.error));
              });               
          }
        }  

        if(this.isProcedBtnActive)
        {
            if((this.prevOpisStatusMsg === 'OPIS Spot Ticker exist') && (currOPISTikrDate === null || currOPISTikrDate === ''))
              this.isProcedBtnActive = false;
        }
    }

    handleCurrFxRateDateChange(event)
    {        
        var changeFxReqDt = event.target.value;         
        this.currFxValue = '';   
        this.currFxValue = null;        
        this.isCurrFxExists = false;
        if(changeFxReqDt === null || changeFxReqDt === '') 
        {       
           this.currFxValue = ''; 
           this.currFxValue = null;   
        }       
        else
        {   
            this.isLoading = true;
            getFxValue({requestedFxDt:changeFxReqDt})
            .then(result => { 
                if(result != undefined){                           
                    var fxRate = result;            
                    if(this.reqestedDate === changeFxReqDt)
                    {
                        if(fxRate === 0)
                        {
                            this.currFxValue = '';
                            this.isCurrFxExists = false;
                        }
                        else
                        {
                            var today = this.getLoggedInUserDate('');  
                            if(changeFxReqDt === today) 
                            {
                                this.currFxValue = fxRate;
                                this.isCurrFxExists = false; 
                            }
                            else
                            {
                                this.currFxValue = fxRate;
                                this.isCurrFxExists = true;  
                            } 
                        }    
                    }   
                    else
                    {
                        if(fxRate === 0)
                        {
                            this.currFxValue = '';
                            this.isCurrFxExists = false;
                        }
                        else
                        {
                            this.currFxValue = fxRate;
                            this.isCurrFxExists = true; 
                        }
                    }                                                        
                }
                this.isLoading = false;
            }).catch(error => {       
                this.isLoading = false;      
                 console.log('Current Fx Rate error -->'+JSON.stringify(error));
            });
        }
    }      

    handlePrevOPISTrckrDateChange(evt)
    {         
        this.isProcedBtnActive = true;
        this.prevOpisStatusMsg = '';         
        var prvOPISTikrDate = evt.target.value; 
        if(prvOPISTikrDate === null || prvOPISTikrDate === '' || this.reqestedDate === prvOPISTikrDate)
        {           
          this.isDisbldPrevFxRateDt = true; 
          this.isPrevFxExists = true; 
          this.prevFxRateReq = false;  
          this.prvFxRateDt = '';
          this.prvFxValue = '';
          this.prvFxRateDt = null; 
          this.prvFxValue = null;
        }     
        else
        {
          this.prevFxRateReq = true;   
          this.isDisbldPrevFxRateDt = false;              
          this.isLoading = true;
          checkPreviousOPISSpotTickerExistsOrNot({requestedOpisRecevdDt:prvOPISTikrDate})
          .then(result => {
            if(result != undefined){                                         
                if(result.toLowerCase() === 'received data')     
                {                
                  this.prevOpisStatusMsg = 'OPIS Spot Ticker exist';  
                  this.isProcedBtnActive = false;            
                }        
                else if(result.toLowerCase() === 'missing data')                    
                  this.prevOpisStatusMsg = 'OPIS Spot Ticker exist, but few data missing!';          
                else if(result.toLowerCase() === 'not received data')                    
                  this.prevOpisStatusMsg = 'OPIS Spot Ticker does not exist!';          
              }
              this.isLoading = false;              
            })
            .catch(error => { 
                this.isLoading = false;
                console.log('Previous OPIS Spot Ticker error -->'+JSON.stringify(this.error));
            });
        }   

        if(this.isProcedBtnActive)
        {
            if((this.currOpisStatusMsg === 'OPIS Spot Ticker exist') && (prvOPISTikrDate === null || prvOPISTikrDate === ''))
              this.isProcedBtnActive = false;
        }        
    } 
    
    handlePrevFxRateDateChange(event)
    {        
        var changeFxReqDt = event.target.value;         
        this.prvFxValue = '';  
        this.prvFxValue = null;     
        this.isPrevFxExists = false;
        if(changeFxReqDt === null || changeFxReqDt === '')
        {
          this.prvFxValue = '';
          this.prvFxValue = null;
        }
        else
        {  
            this.isLoading = true;
            getFxValue({requestedFxDt:changeFxReqDt})
            .then(result => { 
                if(result != undefined){                           
                    var fxRate = result;            
                    if(this.reqestedDate === changeFxReqDt)
                    {
                        if(fxRate === 0)
                        {
                            this.prvFxValue = '';
                            this.isPrevFxExists = false;
                        }
                        else
                        {
                            var today = this.getLoggedInUserDate('');  
                            if(changeFxReqDt === today) 
                            {
                                this.prvFxValue = fxRate;
                                this.isPrevFxExists = false; 
                            }
                            else
                            {
                                this.prvFxValue = fxRate;
                                this.isPrevFxExists = true;  
                            } 
                        }    
                    }   
                    else
                    {
                        if(fxRate === 0)
                        {
                            this.prvFxValue = '';
                            this.isPrevFxExists = false;
                        }
                        else
                        {                     
                            this.prvFxValue = fxRate;
                            this.isPrevFxExists = true; 
                        }
                    }                                                        
                }
                this.isLoading = false;
            }).catch(error => {       
                this.isLoading = false;      
                 console.log('Previous Fx Rate error -->'+JSON.stringify(error));
            });
        }
    }    

    showSuccessToast() {
        const evt = new ShowToastEvent({
                title: 'Success Message',               
                message: this.toastMsg,
                variant: 'success',
                mode: 'dismissable'
            });
        this.dispatchEvent(evt);
    }

    showFailedToast() {
        const evt = new ShowToastEvent({
                title: 'Error Message',               
                message: this.toastMsg,
                variant: 'error',
                mode: 'dismissable'
            });
        this.dispatchEvent(evt);
    }

    showOPISProcessInfoToast() {
        const evt = new ShowToastEvent({
            title: 'Infomation Message',
            message: this.toastMsg,
            variant: 'info',
            mode: 'dismissable'
        });
       this.dispatchEvent(evt);  
     }   

     toggleMQ() {
        try {
            if (this.showMVDetails == false) {
                this.showMVDetails = true;
                this.iconMQName = 'utility:down';
            }
            else {
                this.showMVDetails = false;
                this.iconMQName = 'utility:right';
            }
        }
        catch (error) {
            this.showErrorToast(error.body.message);
        }
    }

    togglePA() {
        try {
            if (this.showPADetails == false) {
                this.showPADetails = true;
                this.iconPAName = 'utility:down';
            }
            else {
                this.showPADetails = false;
                this.iconPAName = 'utility:right';
            }
        }
        catch (error) {
            this.showErrorToast(error.body.message);
        }
    }

}