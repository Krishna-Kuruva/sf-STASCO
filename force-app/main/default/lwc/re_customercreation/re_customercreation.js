import { LightningElement, api, wire, track } from 'lwc';         
 
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CONTRACT_OBJECT from '@salesforce/schema/REV_Contract_Master__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

import NAME_CONTRCT from '@salesforce/schema/REV_Contract_Master__c.Name';
import CUSTOMER from '@salesforce/schema/REV_Contract_Master__c.RE_Customer_Name__c';
import COCALC from '@salesforce/schema/REV_Contract_Master__c.RE_Custom_Ops_Calculation__c';
import VALID_FROM from '@salesforce/schema/REV_Contract_Master__c.RT_Valid_From__c';
import VALID_TO from '@salesforce/schema/REV_Contract_Master__c.RT_Valid_To__c';
import CON_ACTIVE from '@salesforce/schema/REV_Contract_Master__c.Active__c';
import PLANT from '@salesforce/schema/REV_Contract_Master__c.RT_Plant_Desc__c';
import MATERIAL from '@salesforce/schema/REV_Contract_Master__c.RT_Material_Desc__c';
import TPCHARGE from '@salesforce/schema/REV_Contract_Master__c.RE_Transport_Charges__c';
import SSCHARGE from '@salesforce/schema/REV_Contract_Master__c.RE_Service_SurChg__c';
import TPMODE from '@salesforce/schema/REV_Contract_Master__c.RE_Transport_Mode__c';
import TIER from '@salesforce/schema/REV_Contract_Master__c.RE_Tier__c';
import DFOCHARGE from '@salesforce/schema/REV_Contract_Master__c.RE_DFOA_Charges__c';
import SALESORG from '@salesforce/schema/REV_Contract_Master__c.RE_Sales_Org__c';
import REBATE from '@salesforce/schema/REV_Contract_Master__c.RE_Rebate__c';
import BDF from '@salesforce/schema/REV_Contract_Master__c.RE_BDF__c';
import ROUNDUP from '@salesforce/schema/REV_Contract_Master__c.RE_Round_Up__c';
import LISTPRICETIER from '@salesforce/schema/REV_Contract_Master__c.List_Price_Tier__c';
import PRICELEVEL from '@salesforce/schema/REV_Contract_Master__c.RE_Pricing_Levels__c';
import APPROVALSCHEME from '@salesforce/schema/REV_Contract_Master__c.RE_PH_Approval_Scheme__c';

import NAME_FIELD from '@salesforce/schema/Account.Name';
import ACC_ACTIVE from '@salesforce/schema/Account.RT_Active__c';
import PAYMENT_TERM from '@salesforce/schema/Account.RE_Payment_Term__c';
import ACCNO from '@salesforce/schema/Account.AccountNumber';
import CUSTTYPE from '@salesforce/schema/Account.Customer_Type__c';
import TYPE from '@salesforce/schema/Account.Type';
import CUSTOMER_GROUP from '@salesforce/schema/Account.RE_Customer_Group__c';
import SALES from '@salesforce/schema/Account.RE_Sales__c';
import PARENT_ACCOUNT from '@salesforce/schema/Account.RE_Parent_Customer__c';
import AMCODE from '@salesforce/schema/Account.RE_Account_Manager__c';

import accountId from '@salesforce/schema/Contact.AccountId';

import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Customer', fieldName: 'RE_Customer_Name__r.Name'},
    { label: 'Plant', fieldName: 'RT_Plant_Desc__r.Name' },
    { label: 'Material', fieldName: 'RT_Material_Desc__r.Name' },
    { label: 'Ship To', fieldName: 'RE_Ship_To_Number__c' },
    { label: 'Sold To', fieldName: 'RE_Sold_To_Number__c' },
    { label: 'Valid From', fieldName: 'RT_Valid_From__c', type: 'date' },
    { label: 'Valid To', fieldName: 'RT_Valid_To__c', type: 'date' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class Re_customercreation extends NavigationMixin (LightningElement) {
    //@api recordId;
    @track recordId;
    @api objectApiName;
    @track spinnerLoad=false;
    @track country='MY';
    @track AppSchme = 'Malaysia Approval Scheme';

    @track objectInfo;
    @track recordTypeId;
    @track contractrecordTypeId;
    @track hasconrecordId = false;
    @track hasrecordId = false;
    @track isContract = false;
    @track isModalOpen = false;
    @track contracts = [];
    @track contractId;
    columns = columns;
    record = {};
    @track data = [];

    @track selectedAccountID;
    

    fields = [NAME_FIELD, ACC_ACTIVE, CUSTTYPE, ACCNO, PARENT_ACCOUNT, TYPE, AMCODE,  CUSTOMER_GROUP];
    contractfields = [NAME_CONTRCT,CON_ACTIVE,CUSTOMER,PLANT,MATERIAL,TIER,TPMODE,TPCHARGE,SSCHARGE,COCALC,VALID_FROM,VALID_TO,DFOCHARGE,SALESORG,REBATE,BDF,ROUNDUP,LISTPRICETIER,PRICELEVEL,APPROVALSCHEME];

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    getObjectdata({data, error}){
        if(data){
            this.objectInfo = data;
            const rtis = data.recordTypeInfos;
            this.recordTypeId =  Object.keys(rtis).find(rti => rtis[rti].name === 'Revolution MY');
        }
    }

    @wire(getObjectInfo, { objectApiName: CONTRACT_OBJECT })
    getcontractObjectdata({data, error}){
        if(data){
            this.objectInfo = data;
            const conrtis = data.recordTypeInfos;
            //this.contractrecordTypeId =  Object.keys(conrtis).find(rti => conrtis[rti].name === 'Revolution MY');
        }
    }
    /*
    Validdation for Upper case on Account name
    */
   validateAndSubmit(event){
    event.preventDefault();       // stop the form from submitting
    const fields = event.detail.fields;
    console.log('fields.Customer_Type__c@@--'+fields.Customer_Type__c);
    console.log('fields.RE_Parent_Customer__c@@--'+fields.RE_Parent_Customer__c);
    if( fields.Customer_Type__c == 'Ship To' && (fields.RE_Parent_Customer__c == null || fields.RE_Parent_Customer__c == '')){
        this.showToast('error','Select Parent Customer','');
        this.loadSpinner(false,'Customer creating');
    }
    else{
        fields.Name = fields.Name.toUpperCase(); // modify a field
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.template.querySelector('[data-id="AccountEditForm"]').submit(fields);
        if(this.customerId == null)
            this.loadSpinner(true,'Customer creating');
        else
            this.loadSpinner(true,'Updating Customer');
    }   
    
 }
 
    disableloading(){
        this.loadSpinner(false,'Error occurred');
    }
    customerName  = CUSTOMER;
    @track customerId;
    handleSubmit(event){
        this.loadSpinner(false,'Customer created');
        const evt = new ShowToastEvent({
            title: "Account created",
            message: "" ,
            variant: "success"
        });
        const evtupdate = new ShowToastEvent({
            title: "Account Updated",
            message: "" ,
            variant: "success"
        });
        this.recordId = event.detail.id;
        if(this.customerId == null)
            this.dispatchEvent(evt);
        else
            this.dispatchEvent(evtupdate);
        
        console.log('account event.detail ',event.detail);
        this.customerId = event.detail.id;
        this.hasrecordId = true; 
    }
    handlereferesh(){
        window.top.location = window.top.location;
    }
    createcontractdata(){
        this.hasrecordId = false; 
        this.hasconrecordId = true;
    }
    handleContractSubmit(event){
        console.log('event.detail.fields--'+JSON.stringify(event.detail));
        const evt1 = new ShowToastEvent({
            title: "Contract created",
            message: "",
            variant: "success"
        });
        this.dispatchEvent(evt1);
        var jsonData = {};
        jsonData["Id"] = event.detail.id;
        jsonData["Name"] = event.detail.fields.Name.value;
        jsonData["RE_Customer_Name__r.Name"] = event.detail.fields.RE_Customer_Name__r.value.fields.Name.value;
        jsonData["RT_Material_Desc__r.Name"] = event.detail.fields.RT_Material_Desc__r.value.fields.Name.value;
        jsonData["RT_Plant_Desc__r.Name"] = event.detail.fields.RT_Plant_Desc__r.value.fields.Name.value;
        jsonData["RE_Sold_To_Number__c"] = event.detail.fields.RE_Sold_To_Number__c.value;
        jsonData["RE_Ship_To_Number__c"] = event.detail.fields.RE_Ship_To_Number__c.value;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {               
                jsonData[field.fieldName] = field.value;
            });
        }
        //this.contracts.push(event.detail.fields);
        this.contracts = [...this.contracts, jsonData];
        
        this.data = this.contracts;
        this.isContract = true;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'edit':
                this.showRowDetails(row);
                break;
            default:
        }
    }

    deleteRow(row) {
        deleteRecord(row.Id)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });    
        const id = row.Id;
        const index = this.findRowIndexById(id);
        if (index !== -1) {
            this.contracts = this.contracts
                .slice(0, index)
                .concat(this.contracts.slice(index + 1));
        }
        this.data = this.contracts;
    }

    findRowIndexById(id) {
        let ret = -1;
        this.contracts.some((row, index) => {
            if (row.Id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    showRowDetails(row) {
        this.contractId = row.Id;
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    handlecontractEdit(event){
        console.log('edit contract', JSON.stringify(event.detail.fields));
        this.contracts.forEach(function(element,index){
            if(element.Id === event.detail.id){
                element.Customer_Name__c = event.detail.fields.RE_Customer_Name__c.value;
                //element.Customer_Name__r.Name = event.detail.fields.Customer_Name__r.value.fields.Name.value;
                //element.RE_AM_Code__c = event.detail.fields.RE_AM_Code__c.value;
                element.RE_Transport_Charges__c = event.detail.fields.RE_Transport_Charges__c.value;
                element.RE_Service_SurChg__c = event.detail.fields.RE_Service_SurChg__c.value;
                element.RE_Transport_Mode__c = event.detail.fields.RE_Transport_Mode__c.value;
                //element.RE_Pricing_Level__c = event.detail.fields.RE_Pricing_Level__c.value;
                element.RE_Pricing_Levels__c = event.detail.fields.RE_Pricing_Levels__c.value;
                element.RE_Tier__c = event.detail.fields.RE_Tier__c.value;
                element.RT_Material_Desc__c = event.detail.fields.RT_Material_Desc__c.value;
                element.RT_Plant_Desc__c = event.detail.fields.RT_Plant_Desc__c.value;
                element.RT_Valid_From__c = event.detail.fields.RT_Valid_From__c.value;
                element.RT_Valid_To__c = event.detail.fields.RT_Valid_To__c.value;
                element.Active__c = event.detail.fields.Active__c.value;
                element.RE_Custom_Ops_Calculation__c = event.detail.fields.RE_Custom_Ops_Calculation__c.value;
            }
        });
        
        const evt2 = new ShowToastEvent({
            title: "Contract Updated",
            message: "" ,
            variant: "success"
        });
        this.dispatchEvent(evt2);
        this.isModalOpen = false;
        this.data = [];
        this.data = [...this.contracts];
    }

    loadSpinner(load, msg)
    {
        if(load)
        {
            this.spinnerLoad = true;
            this.spinnerMessage = msg;
        }
        else
            this.spinnerLoad = false;
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

   storeAccountId(event){
           console.log('account id--' +event.detail.value);          
           this.selectedAccountID = event.detail.value +'';
   }
   updateAccountId(){
        console.log('updated account Id');
        if(this.selectedAccountID !== null && this.selectedAccountID !== ''){
            console.log('clear data==');
        this.recordId = this.selectedAccountID;
        this.customerId = this.selectedAccountID;
        this.hasrecordId = true; 
        this.hasconrecordId = false;
        }
    
   }

   clearAccountId(){
    if(this.selectedAccountID !== null && this.selectedAccountID !== ''){
        this.recordId = null;
        this.customerId = null;
        this.hasrecordId = false; 
        this.hasconrecordId = false;
        this.selectedAccountID = '';
        this.data = [];
        this.contracts = [];
        }
   }
}