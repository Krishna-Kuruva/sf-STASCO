/**
 * Created by Dharmendra.Singh2 on 8/16/2021.
 */

 import { LightningElement, api, wire, track } from 'lwc';
 import nameField from '@salesforce/schema/Contact.Name';
 import phoneField from '@salesforce/schema/Contact.Phone';
 import emailField from '@salesforce/schema/Contact.Email';
 import currentCreditField from '@salesforce/schema/Account.Rv_Credit_Available__c';
 import customerCreditField from '@salesforce/schema/Account.Rv_Credit_Limit__c';
 import DEcustomerCredit from '@salesforce/schema/Account.DE01_Customer_Credit_Limit__c'
 import olfField  from   '@salesforce/schema/Account.Rv_Available_for_OLF__c';
 //import getDealsList from '@salesforce/apex/rv_customerInfoController.getDeals';
 import getCustomerData from '@salesforce/apex/rv_customerInfoController.getContact1';
 import {subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
 import refreshDataChannel from '@salesforce/messageChannel/Rv_DiPublishSearchFilter__c';
 import { refreshApex } from '@salesforce/apex';
 
 
 export default class RvCustomerInformation extends LightningElement {
 
         recordId ;
         contactRecordId;
         Name = nameField;
         Phone = phoneField;
         Email = emailField;
         currentCredit = currentCreditField;
         customerCredit = customerCreditField;
         olfActive;
         creditPercentage;
         @track percentageColoring;
 
         @api mrcHeader;
         @track accountLinked = false;	   
         error;
         deals;
 
         @wire(getCustomerData, {accountId: '$recordId',mrcId:'$mrcHeader'})
             wiredCustomerData({error, data}){
                               
                 if(data){
                     /*
                     [12/14/2021 1:50 PM] Meiring, Melina SDE-STP/SB21
                     % Credit open to trade = Current Credit/ (DE01 Customer Credit Limit + AT01 Customer Credit Limit)
                     >30% green5-30% orange <4,99% red*/
                     
                     if(this.recordId == ""){
                         this.recordId = data.account.Id;
                     }
                     let deals = data.deals;
                     let finalDeals = [];
                     if (deals !== undefined && deals.length === 2) {
                         if (deals[0] !== null && deals[1] !== null) {
                             if (deals[0].CreatedDate.substring(0, 10) === deals[1].CreatedDate.substring(0, 10)) {
                                 finalDeals.push(deals[1]);
                             }
                             else if (deals[0].CreatedDate.substring(0, 10) !== deals[1].CreatedDate.substring(0, 10)) {
                                 finalDeals.push(deals[0]);
                                 finalDeals.push(deals[1]);
                             }
                         }
                     }
                     if (deals !== undefined && deals.length === 1) {
                         if (deals[0] !== null) {
                             finalDeals.push(deals[0]);
                         }
                     }
                     this.deals = finalDeals;
                     //this.deals = data.deals;
                     this.contactRecordId = data.primaryContact.Id;
                     this.olfActive  = data.account.Rv_Available_for_OLF__c;
                     console.log('credit avialable::'+data.account.Rv_Credit_Available__c);
                     console.log('DE credit avialable::'+data.account.DE01_Customer_Credit_Limit__c);
                     console.log('AT01 credit avialable::'+data.account.Rv_AT01_Customer_Credit_Limit__c);
                     let de01 = data.account.DE01_Customer_Credit_Limit__c != undefined ? parseFloat(data.account.DE01_Customer_Credit_Limit__c) : 0;
                     let AT01 = data.account.Rv_AT01_Customer_Credit_Limit__c != undefined ? parseFloat(data.account.Rv_AT01_Customer_Credit_Limit__c) : 0;
                     
                     this.creditPercentage=data.account.Rv_Credit_Available__c == undefined ? '':(parseFloat(data.account.Rv_Credit_Available__c)/(parseFloat(de01) + parseFloat(AT01))).toFixed(2);
                     this.creditPercentage = this.creditPercentage == undefined ? '':(parseFloat(this.creditPercentage*100)).toFixed(2);
                     
                     console.log('creditPercentage::'+this.creditPercentage);
                     if(parseInt(this.creditPercentage) >=30){
                         this.percentageColoring = 'color: green;font-size:12px;font-weight: 600;';
                     }else if(parseInt(this.creditPercentage) < 30 && parseInt(this.creditPercentage) > 5){
                         this.percentageColoring = 'color: orange;font-size:12px;font-weight: 600;';
                     }else if(parseInt(this.creditPercentage) <= 5 ){
                         this.percentageColoring = 'color: red;font-size:12px;font-weight: 600;';
                     }
                     this.error = undefined;
                 }else if(error){
                     this.error = error;
                     this.deals = undefined;
                 }
             }
 
         subscription = null;
         @wire(MessageContext)
             messageContext;
 
             connectedCallback(){
                // this.creditPercentage= Math.floor(parseFloat(currentCreditField) / parseFloat(DEcustomerCredit));
                 console.log('creditPercentage::'+this.creditPercentage);
                 this.subscribeToMessageChannel();
             }
 
             disconnectedCallback(){
                 this.unsubscribeToMessageChannel();
             }
 
             subscribeToMessageChannel(){
                     if(!this.subscription){
                         this.subscription = subscribe(
                             this.messageContext,
                             refreshDataChannel,
                             (message) => this.recieveData(message),
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
 
             recieveData(message){
                     if(message.eventType === 'publish'){                               //'search' for search MRC and 'publish' for custom info section
                                                          this.recordId = message.customerId;
                                                         this.mrcHeader = message.mrcId;																	
                                                          console.log('Record Id from channel :'+this.recordId);
                                                          refreshApex(this.wiredCustomerData);
                       }  
                    /* Prod deployment */                    
                    else if(message.eventType == 'deSelectedCustomer'){
                        this.recordId = message.customerId;
                        this.mrcHeader = message.mrcId;
                        console.log('Record Id from channel :' + this.recordId);
                        refreshApex(this.wiredCustomerData);
                        this.accountLinked = false;
                        
                    }
                    if( message.eventType != 'deSelectedCustomer' && ( this.recordId != null || this.recordId != undefined ||
                                             this.mrcHeader != null || this.mrcHeader != undefined)){
                                                 this.accountLinked = true;
                                             }																											
                                                                                                                                                                                                                                           
                                                                                                                
                                              
 
                 }
 
 
 
 }