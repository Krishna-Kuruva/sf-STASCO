/**
 * Created by Soumyajit.Jagadev on 11-May-20.
 */

import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import startPage from '@salesforce/apex/Rv_PrepareSandbox.initPage';
import runRefresh from '@salesforce/apex/Rv_PrepareSandbox.RvGermanyRunFromPage';

export default class RvPostRefreshScript extends LightningElement {

    //Property Declaration starts here
    @track spinnerDisplay = false;
    @track spinnerMessage = '';
    @api displayPage = false;
    @track runBtnDisabled = false;
    @track resetBtnDisabled = false;
    @track showResults = false;
    @api checkOnly = false;
    @api invalidString = '.invalid';
    @api emailId = 'invalidEmail@test.com;';
    @track showEmailField = false;
    @api orgName = '';
    @track orgNameReceived = '';
    @track showOrgField = false;
    @api resultList = [];

    @track GsapUpdateChecked = false;
    @track ITalertEmailUpdateChecked = false;
    @track OlfEmailUpdateChecked = false;
    @track OlfConnInsertChecked = false;
    @track OlfAccEmailUpdateChecked = false;
    //Property Declaration ends here

    //Init Method Declaration starts here
    connectedCallback() {
                this.initPage();
                this.reset();
            }
    //Init Method Declaration ends here

    //Method Declaration starts here
    initPage()
    {
        this.spinnerDisplay = !this.spinnerDisplay;
        this.spinnerMessage = 'Verifying Authentication';
        startPage()
        .then(result => {
            this.displayPage = result.hasAccess;
            this.orgNameReceived = result.orgName;
            this.orgName = this.orgNameReceived;
            this.spinnerDisplay = !this.spinnerDisplay;
        })
        .catch(error => {
            this.showToast('error','Authentication Error','Something went wrong. Please try again later!');
            this.spinnerDisplay = !this.spinnerDisplay;
            });
    }

    runCommand(paramList)
        {
            this.runBtnDisabled = true;
            this.spinnerDisplay = !this.spinnerDisplay;
            this.spinnerMessage = 'Running Post Refresh Scripts';
            if(this.checkOnly)
                this.spinnerMessage += ' in Check Only Mode';
            runRefresh({runType : paramList
                        ,isCheckOnly : this.checkOnly
                        ,email : this.emailId
                        ,invalidStr : this.invalidString
                        ,orgNameAppend : this.orgName})
            .then(result => {
                this.resultList = result;
                this.showResults = true;
                this.resetBtnDisabled = false;
                this.spinnerDisplay = !this.spinnerDisplay;
            })
            .catch(error => {
                this.showToast('error','Authentication Error','Something went wrong. Please try again later!');
                this.spinnerDisplay = !this.spinnerDisplay;
                this.runBtnDisabled = false;
                });
        }

    checkboxChange(event)
    {
        const chkName = event.target.name;
        const chkVal = event.target.checked;

        if(chkName == 'GsapUpdate')
            this.GsapUpdateChecked = chkVal;
        else if(chkName == 'ITalertEmailUpdate')
        {
            this.showEmailField = false;
            this.showOrgField = false;
            this.ITalertEmailUpdateChecked = chkVal;
            if(chkVal || this.OlfEmailUpdateChecked)
            {
                this.showEmailField = true;
                this.showOrgField = true;
            }
        }
        else if(chkName == 'OlfEmailUpdate')
        {
            this.showEmailField = false;
            this.showOrgField = false;
            this.OlfEmailUpdateChecked = chkVal;
            if(chkVal || this.ITalertEmailUpdateChecked)
            {
                this.showOrgField = true;
                this.showEmailField = true;
            }
        }
        else if(chkName == 'OlfConnInsert')
            this.OlfConnInsertChecked = chkVal;
        else if(chkName == 'OlfAccEmailUpdate')
            this.OlfAccEmailUpdateChecked = chkVal;
        else if(chkName == 'CheckOnly')
            this.checkOnly = chkVal;
        else
            {}

        if(!chkVal)
            this.resetBtnDisabled = false;

        if(!this.GsapUpdateChecked
            && !this.ITalertEmailUpdateChecked
            && !this.OlfEmailUpdateChecked
            && !this.OlfConnInsertChecked
            && !this.OlfAccEmailUpdateChecked)
        {
            this.runBtnDisabled = true;
        }
        else
        {
            this.runBtnDisabled = false;
        }
    }

    textFldChange(event)
    {
        const name = event.target.name;
        const val = event.target.value;

        if(val != undefined && val != '')
        {
            if(name == 'emailId')
                this.emailId = val;
            else if(name == 'invalidString')
                this.invalidString = val;
            else if(name == 'orgName')
                this.orgName = val;
            else
            {}
        }
    }

    runPostRefresh()
    {
        let paramList = [];
        if(this.GsapUpdateChecked)
            paramList.push('GsapUpdate');
        if(this.ITalertEmailUpdateChecked)
            paramList.push('ITalertEmailUpdate');
        if(this.OlfEmailUpdateChecked)
            paramList.push('OlfEmailUpdate');
        if(this.OlfConnInsertChecked)
            paramList.push('OlfConnInsert');
        if(this.OlfAccEmailUpdateChecked)
            paramList.push('OlfAccEmailUpdate');

        if(paramList != undefined || paramList != '')
        {
            if(paramList.length > 0)
                this.runCommand(paramList);
        }
    }

    reset()
    {
        this.checkOnly = true;
        this.GsapUpdateChecked = true;
        this.ITalertEmailUpdateChecked = true;
        this.OlfEmailUpdateChecked = true;
        this.OlfConnInsertChecked = true;
        this.OlfAccEmailUpdateChecked = true;
        this.showEmailField = true;
        this.invalidString = '.invalid';
        this.emailId = 'invalidEmail@test.com;';
        this.orgName = this.orgNameReceived;
        this.showOrgField = true;

        this.runBtnDisabled = false;
        this.resetBtnDisabled = true;
        this.showResults = false;
    }

    showToast(type,msgtitle,msg)
        {
            const evt = new ShowToastEvent({
                title: msgtitle,
                message: msg,
                variant: type,
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    //Method Declaration ends here
}