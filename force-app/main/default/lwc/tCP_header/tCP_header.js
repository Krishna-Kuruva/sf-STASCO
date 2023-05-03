import { LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import basePath from '@salesforce/community/basePath';
import TCP_logo from '@salesforce/resourceUrl/TCP_logo';
import TCP_profileAvatar from '@salesforce/resourceUrl/TCP_profileAvatar';
import getOrgDomainUrl from '@salesforce/apex/TCP_HearderCntlr.getOrgDomainUrl';
export default class Tcp_header extends LightningElement {
    TCP_logo=TCP_logo;
    TCP_profileAvatar=TCP_profileAvatar;
//get UserName
    @track objUser = {};
    orgDomainUrl;
    error;
    constructor(){
        super();
        getOrgDomainUrl().then(result => {
                this.orgDomainUrl = result;   
                this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            window.console.log('error ====> '+JSON.stringify(this.error));
        });

    }
    @wire(getRecord, { recordId: USER_ID, fields: ['User.FirstName', 'User.LastName', 'User.Logon_as_TCP_User__c'] })
    userData({error, data}) {
        if(data) {
            let objCurrentData = data.fields;
            this.objUser = {
                FirstName : objCurrentData.FirstName.value,
                LastName : objCurrentData.LastName.value,
                Logon_as_TCP_User : objCurrentData.Logon_as_TCP_User__c.value,
            }
        } 
        else if(error) {    window.console.log('error ====> '+JSON.stringify(error))    } 
    }
    get logoutLink() {
        let logoutLink ='';
        if(this.objUser.Logon_as_TCP_User){
            logoutLink = this.orgDomainUrl + '/secur/logout.jsp';
        }else{
            let sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
            
            logoutLink = sitePrefix + '/secur/logout.jsp';
            
        }
        return logoutLink;
    }
    get changePassword() {
         let sitePrefix = basePath.replace(/\/s$/i, ""); 
        let changePasswordLink = sitePrefix + '/TCP_ChangePassword';
        
        return changePasswordLink;
    }
}