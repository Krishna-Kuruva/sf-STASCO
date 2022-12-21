import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getProductDiffQuotes from '@salesforce/apex/Rv_DIDashboardController.getATPPriceforDashboard';
import {subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import refreshDataChannel from '@salesforce/messageChannel/RV_DiRefreshData__c';


export default class Rv_diProductDifferential extends LightningElement {
    @track columns = ['Product Differential', 'Cargoes', 'prev. Day', 'Barges', 'prev. Day'];
    @track channel = ['AT01','DE01'];
    @track MOT = ['Truck'];
    @track locType = '';
    @track taxType = '';
    @track getProdDiffList = true;

    @track ProdDiffLeftLst;
    @track ProdDiffRightLst;

    subscription = null;

    @wire(MessageContext)
    messageContext;

    
    @wire(getProductDiffQuotes, {channel: '$channel',MOT: '$MOT',locType:'$locType',taxType: '$taxType',getProdDiffList: '$getProdDiffList'})
    quotesData(result){
        this.prodDiffObjList = result;
        //console.log('quotes: '+this.quoteNames);
       // console.log('result @ 18: '+JSON.stringify(result));
        const {data, error} = result;
        if(data){
            let prodWrap = data.prdWrp;
            this.ProdDiffLeftLst = prodWrap.leftProdDiffLst;
          //  console.log('@26 prodwrap:'+JSON.stringify(this.ProdDiffLeftLst));
            this.ProdDiffRightLst = prodWrap.rightProdDiffLst;
        }
        else if(error){
            console.log('Error: '+JSON.stringify(error));
        }
    }

    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;
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

    connectedCallback(){
        //console.log('Constructorof product differential');  
        //this.init();
        this.subscribeToMessageChannel();
    }

    refreshData(message){
        if(message.eventType === 'live')
            refreshApex(this.prodDiffObjList);
    }
}