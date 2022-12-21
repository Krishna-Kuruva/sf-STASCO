import {LightningElement, api, wire} from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
//import {createMessageContext, releaseMessageContext, APPLICATION_SCOPE, subscribe,unsubscribe} from 'lightning/messageService';
import refreshDataChannel from '@salesforce/messageChannel/RV_DiRefreshData__c';

export default class Rv_diLiveScreen extends LightningElement{

    @api intervalSecs;
    progressInSecs = 0;
    refreshInSecs;
    liveProgressValPer = 100;
    liveProgressValDiv;
    lastRefreshedAt = '--:--:--';

    @wire(MessageContext)
    messageContext;
  // messageContext = createMessageContext();
    renderedCallback(){
        
    }

    connectedCallback(){
        this.init();
        this.startInterval();
    }


    init(){
 
      //  console.log('liveProgressValPer::'+this.liveProgressValPer);
      //  console.log('intervalSecs::'+this.intervalSecs);
      
      this.refreshInSecs = this.intervalSecs * 1000;
        if(this.liveProgressValPer && this.intervalSecs)
            this.liveProgressValDiv = this.liveProgressValPer / this.intervalSecs;
        
          //  console.log('liveProgressValDiv::'+this.liveProgressValDiv);
    }

  /*  startInterval(){
        this.refreshInSecs = this.intervalSecs; 
        this.interval = setInterval(() => {  
            if(this.progressInSecs == this.intervalSecs)
                this.refreshData();
            this.progressInSecs = this.progressInSecs + 1;
            if(this.refreshInSecs == 0){
                this.refreshInSecs = this.intervalSecs;
                this.progressInSecs = 0;
                this.liveProgressValPer = 100;
            }
            else{
                this.refreshInSecs = this.refreshInSecs - 1;
                this.liveProgressValPer -= this.liveProgressValDiv;
            }    
        }, 1000); 
    }*/
    startInterval(){
        
        this.interval = setInterval(() => {  
         this.refreshData();
         
        }, this.refreshInSecs); 
    }
    refreshData(){

        this.setLastRefreshTime();
        this.publishRefreshEvt();
    }

    publishRefreshEvt(){
        const payload = {eventType: 'live'};
        console.log(this.messageContext);
        if(this.messageContext != null){
        publish(
            this.messageContext, 
            refreshDataChannel,
            payload
        );
        }
    }

    setLastRefreshTime(){
        const date_today = new Date();
        this.hours = date_today.getHours();
        this.minutes = date_today.getMinutes();
        this.seconds = date_today.getSeconds();
        this.lastRefreshedAt = this.hours + ':' + this.minutes + ':' + this.seconds;
    }
    disconnectedCallback(){
        clearInterval(this.interval);
    }
}