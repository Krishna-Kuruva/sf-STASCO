import { LightningElement } from 'lwc';
import CUSTOM_IMAGES from '@salesforce/resourceUrl/RE_Custom_Images';

export default class Re_Ph_TP_Management_Main extends LightningElement {
    selectedLocationId;
    selectedProductId;
    showTPNewOrCloneSection = false;
    isClone = false; //Value of the toggle to show hide the clone screen
    toggleTitle = 'Select a valid Location & Product combination to enable';

    locationIcon = CUSTOM_IMAGES+'/Location_Pin_Red.png';
    productsIcon = CUSTOM_IMAGES+'/Oil_Tin.png';

    disableToggle = true;
    isChecked = false;
    showCustomLocationSearch    = true;
    showCustomProductSearch     = true;

    selectedLocationCode;
    selectedMaterialCode;
    selectedProductName;
    selectedLocationName;
    selectedProductDetail;
    selectedLocationDetail;

    withValueSelected = true;

    onCancel = false;

    showSpinner = false;
    spinnerMessage = '';


    handleLookUp(event){
        this.template.querySelector('[data-id="newOrCloneToggle"]').checked = false;
        this.isChecked  = false;
        this.isClone    = false;
        let eventData = JSON.parse(JSON.stringify(event.detail.data));
        if(eventData.lookupRef == 0){//Re_Location Lookup
            this.selectedLocationId = eventData.recordId;
        }
        else if(eventData.lookupRef == 1){//RE_Product Lookup
            this.selectedProductId = eventData.recordId;
        }
        if(this.selectedLocationId && this.selectedProductId){
            this.showTPNewOrCloneSection = true;
            this.showSpinner = true;
        }
        else{
            this.showTPNewOrCloneSection = false;
            this.disableToggle  = true;
            this.toggleTitle = 'Select a valid Location & Product combination to enable';
        }

        //refresh the error message
        this.template.querySelector('c-re_ph_tp-_-new-or-clone').refreshErrorMessage(this.selectedLocationId,this.selectedProductId);
    }

    handleNewOrCloneToggle(event){
        if(event.target.checked == true){
            this.isClone = true;
        }
        else{
            this.isClone = false;
        }
    }

    controlNewCloneToggle(event){
        let eventData = JSON.parse(JSON.stringify(event.detail.data));
        this.disableToggle = eventData.disable;
        if(this.disableToggle == true){
            this.toggleTitle = 'Select a valid Location & Product combination to enable';
        }
        else{
            this.toggleTitle = '';
        }
    }

    displayNewRecord(event){
        let eventData = JSON.parse(JSON.stringify(event.detail.data));
        if(eventData){
            this.selectedProductId    = eventData.productId;
            this.selectedLocationId   = eventData.locationId;
            this.selectedLocationCode = eventData.selectedLocationCode;
            this.selectedMaterialCode = eventData.selectedMaterialCode;
            this.selectedLocationName = eventData.selectedLocationName;
            this.selectedProductName  = eventData.selectedProductName;
            let selectedProductData = {
                FIELD1 : this.selectedProductName,
                FIELD2 : this.selectedProductId,
                FIELD3 : this.selectedMaterialCode
            }
            this.selectedProductDetail = selectedProductData;
            let selectedLocationData = {
                FIELD1 : this.selectedLocationName,
                FIELD2 : this.selectedLocationId,
                FIELD3 : this.selectedLocationCode
            }
            this.selectedLocationDetail = selectedLocationData;
            this.showCustomLocationSearch   = false;
            this.showCustomProductSearch    = false;
            this.isClone    = false;
            this.withValueSelected = true;
            this.template.querySelector('[data-id="newOrCloneToggle"]').checked = false;
            this.isChecked = false;
            this.showSpinner = true;
            setTimeout(() => {
                this.showSpinner = false;
            }, 500);
        }
    }

    handleCancelButton(event){
        this.withValueSelected = !this.withValueSelected;
        this.template.querySelector('[data-id="newOrCloneToggle"]').checked = false;
        this.isChecked  = false;
        this.disableToggle = true;
        this.showTPNewOrCloneSection = false;
        this.isClone    = false;
        this.selectedLocationDetail = null;
        this.selectedProductDetail = null;
        this.selectedLocationId= null;
        this.selectedProductId = null;
    }

    handleTPRecordDownload(){
        this.template.querySelector('c-re_ph_tp-_-new-or-clone').generateExcel();
    }
}