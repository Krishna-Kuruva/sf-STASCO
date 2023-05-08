import { LightningElement,api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
// this gets you the logged in user
import USER_ID from '@salesforce/user/Id';

import getCommUserContactId from '@salesforce/apex/TCP_TermsandConditionCtrl.getCommUserContactId';
import header from '@salesforce/label/c.TCP_TandC';
import disclaimer1 from '@salesforce/label/c.TCP_Disclaimer';
import disclaimer2 from '@salesforce/label/c.TCP_terms_Liability';


export default class Tcp_TermsCondition extends LightningElement {
    @track conuser;
    isDisabled = true;

    TandCLabel=header;
    disclaimer=disclaimer1+''+disclaimer2;
    // @api graValue;
    @api dateofaccept;
    
    @wire (getCommUserContactId, {conuser:USER_ID}) wiredContacts({data,error}){
        if (data) {
          let dt = new Date(data.TCP_TandC_Accepted_Date__c);
          const dtf = new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: '2-digit'
      })
      const [{value: mo}, , {value: da}, , {value: ye}] = dtf.formatToParts(dt);
      
      let formatedDate = `${da} ${mo} ${ye}`;
      
      this.dateofaccept=formatedDate;//JSON.parse(JSON.stringify(data.TCP_TandC_Accepted_Date__c));
      } else if (error) {
        console.log(error);
      }
   }
    
 }