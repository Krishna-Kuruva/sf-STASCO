import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import DOCUMENT_OBJECT from '@salesforce/schema/BET_BDD_Document__c';
import DOCUMENT_TYPE from '@salesforce/schema/BET_BDD_Document__c.BET_Document_Type__c';
import DOCUMENT_CATEGORY from '@salesforce/schema/BET_BDD_Document__c.BET_Document__c';
import DOCUMENT_FORM from '@salesforce/schema/BET_BDD_Document__c.BET_BDD_Form__c';
import CREATED_DATE from '@salesforce/schema/BET_BDD_Document__c.Created_Date__c';
import UPLOAD_STATUS from '@salesforce/schema/BET_BDD_Document__c.BET_Upload_Status__c';
import MANUAL_UPLOAD from '@salesforce/schema/BET_BDD_Document__c.BET_Manual_Upload__c';
import FORM_REGION from '@salesforce/schema/BET_BDD_Form__c.BDD_Line_of_Business__c';

const FORM_FIELDS = ['BET_BDD_Form__c.BDD_Line_of_Business__c'];

export default class Bet_BddSupportingDocument extends LightningElement {
    @api recordId;
    documentRecId;
    recTypeName;
    @track
    documentObject = DOCUMENT_OBJECT;

    documentType = DOCUMENT_TYPE;
    documentCategory = DOCUMENT_CATEGORY;
    cratedDate = CREATED_DATE;
    formRegion = FORM_REGION;
    
    @track
    documentRecTypeId;

    //Get BDD Form record
    @wire(getRecord, { recordId: '$recordId', fields: FORM_FIELDS })
    handleFormInfo({error, data}){
        if(data){
            this.recTypeName = data.fields.BDD_Line_of_Business__c.value;
        }
    }

    //Get BDD Documment object info.
    @wire(getObjectInfo, { objectApiName: '$documentObject' })
    handleDocumentInfo({error, data}){
        if(data){
            const rtis = data.recordTypeInfos;
            this.documentRecTypeId = Object.keys(rtis).find(rti => rtis[rti].name === this.recTypeName);
        }
    } 

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        fields[DOCUMENT_FORM.fieldApiName] = this.recordId;
        fields[MANUAL_UPLOAD.fieldApiName] = true;
        fields[UPLOAD_STATUS.fieldApiName] = 'Pending';
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event){
        this.documentRecId = event.detail.id;
        eval("$A.get('e.force:refreshView').fire();");
        this.showToast('Success!',
                       'Supporting document is created successfully.',
                       'success');
    }

    handleError(error){
        console.log(JSON.stringify(error));
        this.showToast('Error!',
                        error.detail.detail,
                       'error');
    }

    //Show toast message
    showToast(title, message, variant){
        const event = new ShowToastEvent ({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}