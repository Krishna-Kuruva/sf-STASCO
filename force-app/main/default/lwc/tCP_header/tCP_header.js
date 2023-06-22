import { LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import basePath from '@salesforce/community/basePath';
import TCP_logo from '@salesforce/resourceUrl/TCP_logo';
import TCP_profileAvatar from '@salesforce/resourceUrl/TCP_profileAvatar';
import getOrgDomainUrl from '@salesforce/apex/TCP_HearderCntlr.getOrgDomainUrl'; 
import getChangePasswordUrl from '@salesforce/apex/TCP_HearderCntlr.getChangePasswordUrl';
import getLogoutUrl from '@salesforce/apex/TCP_HearderCntlr.getLogoutUrl';  
import deleteSession from '@salesforce/apex/TCP_HearderCntlr.deleteSession';
import loggedInAsTcpUser from '@salesforce/apex/TCP_HomePageController.loggedInAsTcpUser';

export default class Tcp_header extends LightningElement {
    TCP_logo=TCP_logo;
    TCP_profileAvatar=TCP_profileAvatar;
//get UserName
    @track objUser = {};
    @track changePasswordLink;
    @track logOutLinkUrl;
    orgDomainUrl;
    error;
    constructor(){
       super();
       loggedInAsTcpUser().then(result => {
        this.logOnAsTCP = result;
        window.console.log('logged in user commops: '+this.logOnAsTCP);
        this.error = null;
        })
        .catch(error => {
        this.error = error;
        this.name = null;
        });
        getOrgDomainUrl().then(result => {
                this.orgDomainUrl = result;   
                this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            window.console.log('error ====> '+JSON.stringify(this.error));
        });
        this.changePassword();
        this.LogoutUrl();
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
    //get changePassword() {
    changePassword() {
       let sitePrefix = basePath.replace(/\/s$/i, "");
        getChangePasswordUrl().then(result => {
                this.changePasswordLink = result;   
                this.error = undefined;
                console.log('this.changePassword '+this.changePasswordLink);
        })
        .catch(error => {
            this.error = error;
            window.console.log('error ====> '+JSON.stringify(this.error));
        });
        //let changePasswordLink = sitePrefix + 'https://dev.account.shell.com/personal-details?client_id=qa4cax6ftb74uq95y8j6pbpxabxvmkfp&redirect_uri=https://stasco--tcp.sandbox.my.site.com/&response_type=code&scope=openid&prompt=consent&access_type=offline';
        
        //return changePassword;
    }
    LogoutUrl() {
        getLogoutUrl().then(result => {
                 this.logOutLinkUrl = result;   
                 this.error = undefined;
                 console.log('this.logOutLink '+this.logOutLinkUrl);
         })
         .catch(error => {
             this.error = error;
             window.console.log('error ====> '+JSON.stringify(this.error));
         });
         
     }

     onlogout(){
        
        deleteSession().then(result => {
            this.error = undefined;
                console.log('Inside Onlogout');
                //alert("inside onlogout");
        })
        .catch(error => {
            this.error = error;
            window.console.log('error ====> '+JSON.stringify(this.error));
        });
     }
}