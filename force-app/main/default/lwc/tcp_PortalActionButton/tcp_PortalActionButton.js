import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from "lightning/navigation";

import uId from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getuserid from '@salesforce/apex/TCP_HearderCntlr.getuserrecordid';
import getcontactid from '@salesforce/apex/TCP_HearderCntlr.getcontactid';
import getNetworkid from '@salesforce/apex/TCP_HearderCntlr.getNetworkid';
import getorgId from '@salesforce/apex/TCP_HearderCntlr.getorgId';
import geturl from '@salesforce/apex/TCP_HearderCntlr.geturl';
import getportaluser from '@salesforce/apex/TCP_HearderCntlr.getportaluser';
import logonastcp from '@salesforce/apex/TCP_HearderCntlr.logonastcp';
import CONTACT_ID from '@salesforce/schema/Contact.Id';
import FIRST_NAME from "@salesforce/schema/Contact.Name";


const fields = [CONTACT_ID,FIRST_NAME];

export default class Tcp_PortalActionButton extends NavigationMixin(LightningElement) {

    @api recordId;
    error;
    contactId;
    name;
    userid = uId;
    @track useridfromapex;
    contactuserid;
    dateTime;
    logOnAsTCP;
    quickActionAPIName = "";
    urlUserId = null;
    urlStateParameters = null;
    userTypeInfo;
    networkidval;
    orgIdval;
    url;
    
    @wire(getRecord, { recordId:'$recordId', fields: fields })
    contact({ error, data }) {
        if (data) {
            this.contactId = data.id;
            getportaluser({contactid : this.contactId})
            
                .then(result => {
                
                    this.contactuserid = result;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.useridfromapex = undefined;
                });
                
        } else {
            this.error = error;
        }
    }

    constructor(){
        super();
        
        
        getuserid()
            .then(result => {
                this.useridfromapex = result;
                
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.useridfromapex = undefined;
            });

            getcontactid().then(result => {
                this.name = result;
                
                
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.name = undefined;
            });
            getNetworkid().then(result => {
                this.networkidval = result;
                
                
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.networkidval = undefined;
            });
            getorgId().then(result => {
                this.orgIdval = result;
                
                
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.orgIdval = undefined;
            });
            geturl().then(result => {
                this.url = result;
                
                
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.orgIdval = undefined;
            });
            logonastcp().then(result => {
                this.logOnAsTCP = result;
                
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.name = undefined;
            });
    }
    
    @api invoke() {
        let returl = "https://"+this.url+"/servlet/servlet.su?oid="+this.orgIdval+"&sunetworkid="+this.networkidval+"&sunetworkuserid=";
        setTimeout( this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": returl + this.contactuserid
            }
        }),3000);
    }
}