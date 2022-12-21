import {LightningElement, api, wire, track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getLiveQuotes from '@salesforce/apex/Rv_DIDashboardController.getLiveQuotes'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import refreshDataChannel from '@salesforce/messageChannel/RV_DiRefreshData__c';

export default class Rv_diDisplayQuotes extends LightningElement{

    quoteNames = '';
    subscription = null;
    prodDiffObjList;
    @api quoteNamesLeftBottom;
    @api quoteNamesLeft;
    @api quoteNamesRight;
    @api quoteNamesBottom;
    @api backgroundColor;
    @track quoteListLeft = [];
    @track quoteListRight = [];
    @track quoteListBottom = [];
    
    @api prodDiffLeft;
    @api prodDiffRight;
   
    connectedCallback(){
       // console.log('Constructor**');  
        this.init();
        this.subscribeToMessageChannel();
    }

    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    renderedCallback(){
        var card = this.template.querySelector('.live-card-outer');
        if(card && this.backgroundColor){
            this.template.host.style.setProperty('--card-background',  this.backgroundColor);
        }
    }

    @wire(MessageContext)
    messageContext;

    @wire(getLiveQuotes, {quoteNames: '$quoteNames'})
    quotesData(result){
        this.prodDiffObjList = result;
       // console.log('quotes: '+this.quoteNames);
        //console.log('result: '+JSON.stringify(result));
       // console.log('QuoteNames:'+this.quoteNamesRight);
        const {data, error} = result;
        if(data){

           /* let sortedData = data.sort(
                (dispName1,dispName2)=>dispName1.Display_Name__c - dispName2.Display_Name__c
                );*/

            let quoteListLeft = [];
            let quoteListRight = [];
            let quoteListBottom = [];
            for(let i=0; i<data.length; i++){
                let quote = data[i];
                let column = quote.Column__c;
                if(quote.Display_Name__c){
                    if(this.quoteNamesLeft && this.quoteNamesLeft.includes(quote.Display_Name__c))
                        quoteListLeft.push(quote); 
                    else if(this.quoteNamesRight && this.quoteNamesRight.includes(quote.Display_Name__c))
                        quoteListRight.push(quote); 
                    else if(this.quoteNamesBottom && this.quoteNamesBottom.includes(quote.Display_Name__c))
                        quoteListBottom.push(quote);
                } 
            }
            let E5surcharges = {
                Id : '',
                Display_Name__c : 'E5 Surcharge',
                Column__c:'',
                Price__c : 1.60
            } 
            let s98surcharges = {
                Id : '',
                Display_Name__c : 'S98 Surcharge',
                Column__c:'',
                Price__c : 8.30
            }
            
            if(quoteListLeft[2]!=null && quoteListLeft[2].Display_Name__c!=null &&  quoteListLeft[2].Display_Name__c=='Live €/CHF'){
             quoteListLeft.push(quoteListLeft.splice(2, 1)[0]);
           }
            //quoteListLeft.push(E5surcharges);
            //quoteListLeft.push(s98surcharges);
            this.quoteListLeft = quoteListLeft;
            this.quoteListRight = quoteListRight;
            this.quoteListBottom = quoteListBottom;
            // prod deployment
            console.log('#### quotelist bottom',JSON.stringify(this.quoteListLeft));
        }
        else if(error){
            console.log('Error: '+JSON.stringify(error));
        }
    }

    init(){
        this.prepareQuoteNames();
    }

    prepareQuoteNames(){
        let quoteNames = '';
            if(this.quoteNamesLeft){
                quoteNames += ',' + this.quoteNamesLeft;
            }
            if(this.quoteNamesRight)
                    quoteNames += ','+ this.quoteNamesRight;
            if(this.quoteNamesBottom)
                    quoteNames += ',' + this.quoteNamesBottom;
        if(quoteNames)
            this.quoteNames = quoteNames.replace(',', '');
    }

    subscribeToMessageChannel(){
        if(!this.subscription){
            this.subscription = subscribe(
                this.messageContext,
                refreshDataChannel,
                (message) => this.refreshData(message),
                {
                    scope: APPLICATION_SCOPE 
                }
            );
        }
    }

    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    refreshData(message){
        if(message.eventType === 'live')
            refreshApex(this.prodDiffObjList);
    }
}