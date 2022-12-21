import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import COUNTRY_FIELD from '@salesforce/schema/RE_Product__c.RE_Country__c';
import MATERIALNAME_FIELD from '@salesforce/schema/RE_Product__c.RE_Material__c';
import PRODUCTNAME_FIELD from '@salesforce/schema/RE_Product__c.Name';
import LOCATIONCODE_FIELD from '@salesforce/schema/RE_Location__c.RE_Location_Code__c';
import LOCATIONNAME_FIELD from '@salesforce/schema/RE_Location__c.Name';
import getProductDepotCombo from '@salesforce/apex/re_Ph_TP_Management.checkProductDepotCombination';
import getRecordTypeId from '@salesforce/apex/re_Ph_TP_Management.getRecordTypeId';
import checkForActiveCombination from '@salesforce/apex/re_Ph_TP_Management.checkForActiveCombination';
import checkDPBForDateOverlapping from '@salesforce/apex/re_Ph_TP_Management.checkDPBForDateOverlapping';
import downloadTPRecords from '@salesforce/apex/re_Ph_TP_Management.downloadTPRecords';
import LightningAlert from 'lightning/alert';

import CUSTOM_IMAGES from '@salesforce/resourceUrl/RE_Custom_Images';


export default class Re_ph_tp_NewOrClone extends LightningElement {
    @api showNewOrCloneSection = false;
    @api productId;
    @api locationId;
    @api isCloneScreen = false;

    @api refreshErrorMessage(location, product) {
        if (!product && location) {
            this.errorMessage = 'Please select Product also to see more details';
        }
        else if (product && !location) {
            this.errorMessage = 'Please select Location also to see more details';
        }
        else if (!product && !location) {
            this.errorMessage = 'Please select both Location and Product to see more details';
        }
        else {
            this.errorMessage = '';
        }
    }

    selectedLocationId; //Selected from Custom Lookup in the Clone Screen
    selectedProductId; //Selected from Custom Lookup in the Clone Screen

    selectedLocationCode; //Used for setting tooltip in Parent component
    selectedMaterialCode; //Used for setting tooltip in Parent component
    selectedLocationName; //Used for setting tooltip in Parent component
    selectedProductName;  //Used for setting tooltip in Parent component

    locationIcon = CUSTOM_IMAGES + '/Location_Pin_Red.png';
    productsIcon = CUSTOM_IMAGES + '/Oil_Tin.png';

    @track dpbRecord;
    dpbRecordClone;
    error;
    errorMessage = 'Please select both Location and Product to see more details';
    @api showSpinner;
    spinnerMessage = 'Loading';
    countryId;

    objectName = 'RE_Depot_Pricing_Backbone__c';
    recordTypeName = 'Philippines';
    recordTypeId;


    disableSubmitBtn; //Disable button if the user does not have proper permission sets
    buttonTitle; //Show title when the button is disabled

    @track _wiredResult; //To refresh the wire data using ApexRefresh

    reValidFromDate = new Date(new Date().toISOString().split('T')[0] + 'T00:00:00.000Z').toISOString(); //Set this value for New or Clone records
    reValidToDate = new Date(new Date().getFullYear() + '-12-31T00:00:00.000Z').toISOString();//Set this value for New or Clone records
    disableValidFromDateInput = true;
    reValidFromIsUpdated = false; //Boolean indicating if the Re ValidFromDate is changed or not

    defaultPHPPerL15 = 'PHP/L15';

    //Excel related
    @track xlsHeader = []; //To hold the header row of each excel sheet
    @track xlsHeaderObj = {}; //To hold header names as {fieldApiName:fieldLabel}
    @track xlsData = []; //To hold the data rows of each excel sheet
    @track workSheetNameList = []; //To hold the name of each sheet in excel
    filename; //File name of the final excel to be downloaded
    xlsHeaderTemplate = new Map([
        [0, 'Name'], [1, 'RE_Product_Name__c'], [2, 'RE_Depot_Name__c'], [3, 'RE_PH_Blend_Percentage__c'], [4, 'RE_TH_HCV_Quote1_Percent__c'], [5, 'RE_TH_HCV_Quote1__c'], [6, 'RE_PH_Premium__c'], [7, 'RE_Fixed_Premium__c'], [8, 'RE_Fixed_Premium_Unit__c'], [9, 'RE_PH_Freight_Conversion_Factor__c'],
        [10, 'RE_PH_Freight_Quote__c'], [11, 'RE_PH_Freight_Charges__c'], [12, 'RE_PH_Freight_Charges_Unit__c'], [13, 'RE_PH_Bio_Percent__c'], [14, 'RE_PH_BIO_1__c'], [15, 'RE_PH_BIO_2__c'], [16, 'RE_PH_BIO_3__c'], [17, 'RE_PH_BIO_Fixed__c'], [18, 'RE_PH_BIO_Fixed_Unit__c'], [19, 'RE_Primary_Transport_Cost__c'],
        [20, 'RE_Primary_Transport_Unit__c'], [21, 'RE_PH_Small_Lot__c'], [22, 'RE_PH_Demurrage__c'], [23, 'RE_PH_Demurrage_Unit__c'], [24, 'RE_PH_FLC_Service_Fee__c'], [25, 'RE_PH_FLC_Service_Fee_Unit__c'], [26, 'RE_PH_Terminal_Cost__c'], [27, 'RE_PH_Wharfage_Cost__c'], [28, 'RE_PH_Wharfage_Cost_Unit__c'], [29, 'RE_PH_Fuel_Marking_Factor__c'],
        [30, 'RE_PH_MISC_Fuel_Marking_Fee__c'], [31, 'RE_PH_MISC_Fuel_Marking_Fee_Unit__c'], [32, 'RE_PH_Ocean_Cost__c'], [33, 'RE_PH_S_H__c'], [34, 'RE_PH_PT_Percentage__c'], [35, 'RE_Insurance_Percentage__c'], [36, 'RE_Snh_Cost__c'], [37, 'RE_SnH_Unit__c'], [38, 'RE_Valid_From__c'], [39, 'RE_Valid_To__c'],
        [40, 'RE_PH_MISC_Hosehandling_Cost__c'], [41, 'RE_PH_MISC_Hosehandling_Cost_Unit__c'], [42, 'RE_PH_MISC_Shifting_Cost__c'], [43, 'RE_PH_MISC_Shifting_Cost_Unit__c'], [44, 'RE_PH_MISC_PQ_Cost__c'], [45, 'RE_PH_MISC_PQ_Cost_Unit__c'], [46, 'RE_PH_MISC_Waterfront_Operations_Cost__c'], [47, 'RE_PH_Waterfront_Operations_Cost_Unit__c'], [48, 'RE_PH_MISC_Brokerage_Fee__c'], [49, 'RE_PH_MISC_Brokerage_Fee_Unit__c'],
        [50, 'RE_PH_MISC_Port_Charges__c'], [51, 'RE_PH_MISC_Port_Charges_Unit__c']
    ]);//Re-order this and add field in SOQL for any new field additions


    @wire(getProductDepotCombo, { productId: '$productId', locationId: '$locationId' })
    returnedData(wireResult) {
        this.spinnerMessage = 'Loading';
        if (!this.productId && this.locationId) {
            this.errorMessage = 'Please select Product also to see more details';
            return;
        }
        if (this.productId && !this.locationId) {
            this.errorMessage = 'Please select Location also to see more details';
            return;
        }
        if (this.productId && this.locationId) {
            this.showSpinner = true;
            const { data, error } = wireResult;
            this._wiredResult = wireResult;
            if (data) {
                let response = JSON.parse(JSON.stringify(data));
                this.showNewOrCloneSection = true;
                if (response.recordCount > 0) {
                    console.log('Matching record found');
                    this.dpbRecord = response.dpbRecords[0];
                    this.dpbRecordClone = this.dpbRecord;
                    this.toggleControlEvent(false);
                    let reValidFromInRecord = JSON.parse(JSON.stringify(response.dpbRecords[0].RE_Valid_From__c));
                    let todaysDate = JSON.parse(JSON.stringify(this.reValidFromDate)).split("T")[0];
                    //Valid From date should be editable only if the records Valid From is greater than or equals to today
                    this.disableValidFromDateInput = (reValidFromInRecord >= todaysDate) ? false : true;
                }
                else {
                    this.dpbRecord = undefined;
                    this.dpbRecordClone = this.dpbRecord;
                    console.log('No matching record found');
                    this.errorMessage = 'Depot Pricing Backbone could not be found with the selected Plant and Material details!';
                    this.toggleControlEvent(true);
                }

                this.disableSubmitBtn = (response.userHasAccess) ? false : true;
                this.buttonTitle = (this.disableSubmitBtn) ? 'Insufficient Access' : '';
                if(this.disableSubmitBtn){
                    this.toggleControlEvent(true);//Disable toggle button if the user has no proper access
                }

                setTimeout(() => {
                    this.showSpinner = false;
                }, 1000);

            }
            else if (error) {
                this.error = error;
                this.dpbRecord = undefined;
                this.showErrorToastMessage(error, 'Error occured, please contact your admin: ');
                this.showNewOrCloneSection = false;
                this.errorMessage = 'Error occured while searching for Depot Pricing Backbone. Please contact your admin.';
                this.toggleControlEvent(true);
                this.showSpinner = false;
            }
        }
        else {
            this.showSpinner = false;
            this.errorMessage = 'Please select both Location and Product to see more details';
        }
        this.reValidFromIsUpdated = false;//Resetting back to false after every search
        this.selectedProductId = '';
        this.selectedLocationId = '';
    }

    @wire(getRecord, { recordId: '$productId', fields: [COUNTRY_FIELD] })
    productRecord({ data, error }) {
        if (data) {
            this.countryId = data.fields.RE_Country__c.value;
        }
        if (error) {
            this.showErrorToastMessage(error, 'Error while getting country name: ');
        }
    }

    @wire(getRecord, { recordId: '$selectedLocationId', fields: [LOCATIONCODE_FIELD, LOCATIONNAME_FIELD] })
    locationRecord({ data, error }) {
        if (data) {
            this.selectedLocationCode = data.fields.RE_Location_Code__c.value;
            this.selectedLocationName = data.fields.Name.value;
        }
        else if (error) {
            this.showErrorToastMessage(error, 'Error while getting location code: ');
        }
    }

    @wire(getRecord, { recordId: '$selectedProductId', fields: [MATERIALNAME_FIELD, PRODUCTNAME_FIELD] })
    materialDataOfProduct({ data, error }) {
        if (data) {
            this.selectedMaterialCode = data.fields.RE_Material__c.value;
            this.selectedProductName = data.fields.Name.value;
        }
        else if (error) {
            this.showErrorToastMessage(error, 'Error while getting location code: ');
        }
    }

    @wire(getRecordTypeId, { objectName: '$objectName', recordTypeDevName: '$recordTypeName' })
    recordTypeWireData(recordTypeResult) {
        const { data, error } = recordTypeResult;
        if (data) {
            this.recordTypeId = JSON.parse(JSON.stringify(data));
        }
        else if (error) {
            this.recordTypeId = undefined;
            if (error.body.message) {
                this.showToastMessage('Record Type Error', error.body.message, 'error');
                this.errorMessage = error.body.message;
            }
            else {
                this.showToastMessage('Record Type Error', JSON.parse(JSON.stringify(error)), 'error');
                this.errorMessage = JSON.parse(JSON.stringify(error));
            }
            this.showNewOrCloneSection = false;
        }
    }

    //Method that handles the event when the value is selected from the Custom Lookup
    handleLookUpSelection(event) {
        let eventData = JSON.parse(JSON.stringify(event.detail.data));
        if (eventData.lookupRef == 0) {//Re_Location Lookup
            this.selectedLocationId = eventData.recordId;
        }
        else if (eventData.lookupRef == 1) {//RE_Product Lookup
            this.selectedProductId = eventData.recordId;
        }

        if (this.selectedLocationId && this.selectedProductId) {
            this.showSpinner = true;
            this.spinnerMessage = 'Checking active records';
            this.checkForActiveDPBCombination(this.selectedProductId, this.selectedLocationId, 'Alert');//To alert user after selection itself.
        }
    }


    checkForActiveDPBCombination(argProductId, argDepotId, argContext) {
        checkForActiveCombination({ productId: argProductId, locationId: argDepotId })
            .then((result) => {
                let resultWrapper = JSON.parse(JSON.stringify(result));
                this.showSpinner = false;
                if (argContext == 'Alert') {
                    if (resultWrapper.recordCount > 0) {
                        let validFrom = resultWrapper.dpbRecords[0].RE_Valid_From__c;
                        let validTo = resultWrapper.dpbRecords[0].RE_Valid_To__c;
                        const alert = LightningAlert.open({
                            message : 'There is already an active record for this Location and Product combination with validity from ' + validFrom + ' till ' + validTo,
                            theme   : 'warning',
                            label   : 'Active Record Exists'
                        });
                    }
                }

            }).catch((error) => {
                this.showSpinner = false;
                this.showErrorToastMessage(error, 'Apex error at checkForActiveCombination, Please contact your admin: ');
            });
    }

    handleSubmit(event) {
        event.preventDefault();
        //Whiling cloning a record
        if (this.isCloneScreen) {
            if (!this.selectedLocationId) {
                this.showToastMessage('Blank Location', 'Please select a location as mandatory', 'warning');
                this.showSpinner = false;
                return;
            }
            else if (!this.selectedProductId) {
                this.showToastMessage('Blank Product', 'Please select a product as mandatory', 'warning');
                this.showSpinner = false;
                return;
            }
            else if (this.selectedLocationId && this.selectedProductId) {
                this.showSpinner = true;
                this.spinnerMessage = 'Cloning Record';

                let validFromDate = event.detail.fields.RE_Valid_From__c.includes('T') ? new Date(event.detail.fields.RE_Valid_From__c.split('T')[0] + 'T00:00:00.000Z') : new Date(event.detail.fields.RE_Valid_From__c + 'T00:00:00.000Z');
                let validToDate = new Date(event.detail.fields.RE_Valid_To__c);
                let todaysDate = new Date(new Date().toISOString().split('T')[0] + 'T00:00:00.000Z');
                let isValid = this.validateValidFromAndValidToDates(validFromDate, validToDate, todaysDate, 'CLONE');
                if (isValid == false) {
                    this.showSpinner = false;
                    return;
                }

                checkDPBForDateOverlapping({ productId: this.selectedProductId, locationId: this.selectedLocationId, validFromDate: validFromDate, validToDate: validToDate })
                    .then(result => {
                        let returnResult = JSON.parse(JSON.stringify(result));
                        if (returnResult.recordCount > 0) {
                            let validFrom = returnResult.dpbRecords[0].RE_Valid_From__c;
                            let validTo = returnResult.dpbRecords[0].RE_Valid_To__c;
                            const alert = LightningAlert.open({
                                message : 'There is already an active record for this Location and Product combination with validity from ' + validFrom + ' till ' + validTo,
                                theme   : 'error',
                                label   : 'Cannot Clone A Record'
                            });
                            this.showSpinner = false;
                            return;
                        }
                        else {
                            let fields = event.detail.fields;
                            fields.RE_Depot_Name__c = this.selectedLocationId;
                            fields.RE_Product_Name__c = this.selectedProductId;
                            fields.RE_Country__c = this.countryId;
                            fields.RecordTypeId = this.recordTypeId;
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                            setTimeout(() => {
                                this.showSpinner = false;
                            }, 2000);
                        }
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        this.showErrorToastMessage(error, 'Error while creating record: ');
                    });
            }
        }
        //While updating a record
        else {
            this.showSpinner = true;
            this.spinnerMessage = 'Updating Record';
            try {
                let fields = event.detail.fields;
                console.log('Valid From: ' + fields.RE_Valid_From__c + '; Valid To: ' + fields.RE_Valid_To__c);
                let validFromDate = event.detail.fields.RE_Valid_From__c.includes('T') ? new Date(event.detail.fields.RE_Valid_From__c.split('T')[0] + 'T00:00:00.000Z') : new Date(event.detail.fields.RE_Valid_From__c + 'T00:00:00.000Z');
                let validToDate = new Date(fields.RE_Valid_To__c);
                let todaysDate = new Date(new Date().toISOString().split('T')[0] + 'T00:00:00.000Z');
                let isValid = this.validateValidFromAndValidToDates(validFromDate, validToDate, todaysDate, 'UPDATE');
                if (isValid == false) {
                    this.showSpinner = false;
                    return;
                }

                checkDPBForDateOverlapping({ productId: this.productId, locationId: this.locationId, validFromDate: validFromDate, validToDate: validToDate })
                    .then(result => {
                        let returnResult = JSON.parse(JSON.stringify(result));
                        returnResult.dpbRecords.forEach((res, index) => {
                            if (res.Id == this.dpbRecord.Id) {
                                returnResult.dpbRecords.splice(index, 1);
                            }
                        });
                        if (returnResult.dpbRecords.length > 0) {
                            let validFrom = returnResult.dpbRecords[0].RE_Valid_From__c;
                            let validTo = returnResult.dpbRecords[0].RE_Valid_To__c;
                            const alert = LightningAlert.open({
                                message : 'There is already an active record for this Location and Product combination with validity from ' + validFrom + ' till ' + validTo,
                                theme   : 'error',
                                label   : 'Cannot Update A Record'
                            });
                            this.showSpinner = false;
                            return;
                        }
                        else {
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                            setTimeout(() => {
                                this.showSpinner = false;
                            }, 1000);
                        }
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        this.showToastMessage('Error Occured', 'Error while updating record: ' + JSON.parse(JSON.stringify(error)), 'error');
                    });
            }
            catch (error) {
                this.showSpinner = false;
                this.showToastMessage('Error Occured', 'Error while updating record: ' + JSON.parse(JSON.stringify(error)), 'error');
            }
        }
    }

    handleUpdateSuccess(event) {
        if (this.isCloneScreen) {
            this.showSpinner = true;
            this.spinnerMessage = 'Refreshing';
            this.refreshOnCreateEvent();
            setTimeout(() => {
                refreshApex(this._wiredResult);
                this.showToastMessage('Clone Success!', 'Record has been cloned successfully!', 'success');
                this.selectedLocationId = '';
                this.selectedProductId = '';
                this.selectedProductDetail = '';
                this.selectedLocationDetail = '';
            }, 1000);
        }
        else {
            this.showSpinner = false;
            refreshApex(this._wiredResult);
            this.showToastMessage('Update Success!', 'Record has been updated successfully!', 'success');
        }
    }

    handleCreateSuccess(event) {
        // refreshApex(this._wiredResult);
        this.refreshOnCreateEvent();
        this.showToastMessage('Create Success!', 'Record has been created successfully!', 'success');
    }

    createNewDPBRecord(event) {
        event.preventDefault();
        let validFromDate = event.detail.fields.RE_Valid_From__c.includes('T') ? new Date(event.detail.fields.RE_Valid_From__c.split('T')[0] + 'T00:00:00.000Z') : new Date(event.detail.fields.RE_Valid_From__c + 'T00:00:00.000Z');
        let validToDate = new Date(event.detail.fields.RE_Valid_To__c);
        let todaysDate = new Date(new Date().toISOString().split('T')[0] + 'T00:00:00.000Z');
        let isValid = this.validateValidFromAndValidToDates(validFromDate, validToDate, todaysDate, 'NEW');
        if (isValid == false) {
            this.showSpinner = false;
            return;
        }
        this.showSpinner = true;
        this.spinnerMessage = 'Creating Record';

        checkDPBForDateOverlapping({ productId: this.productId, locationId: this.locationId, validFromDate: validFromDate, validToDate: validToDate })
        .then(result => {
            let returnResult = JSON.parse(JSON.stringify(result));
            if (returnResult.recordCount > 0) {
                let validFrom = returnResult.dpbRecords[0].RE_Valid_From__c;
                let validTo = returnResult.dpbRecords[0].RE_Valid_To__c;
                const alert = LightningAlert.open({
                    message : 'There is already an active record for this Location and Product combination with validity from ' + validFrom + ' till ' + validTo,
                    theme   : 'error',
                    label   : 'Cannot Create A Record'
                });
                this.showSpinner = false;
                return;
            }
            else {
                let fields = event.detail.fields;
                fields.RE_Depot_Name__c = this.locationId;
                fields.RE_Product_Name__c = this.productId;
                fields.RE_Country__c = this.countryId;
                fields.RecordTypeId = this.recordTypeId;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
                //To refresh the form after creation
                //To get Product and Depot Details
                this.selectedProductId = this.productId;
                this.selectedLocationId = this.locationId;
                this.dpbRecord = null;
                this.showNewOrCloneSection = false;
                returnResult = null;
                setTimeout(() => {
                    this.showSpinner = false;
                }, 2000);
            }
        })
        .catch((error) => {
            this.showSpinner = false;
            this.showErrorToastMessage(error, 'Error while creating record: ');
        });
    }

    handleOnLoad(event) {
        this.showSpinner = false;
    }

    //This function handles the Cancel action
    handleCancel(event) {
        this.errorMessage = 'Please select both Location and Product to see more details';
        const cancelEvent = new CustomEvent('cancel', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                data: {
                    productId: null,
                    locationId: null
                }
            }
        });
        this.dispatchEvent(cancelEvent);
    }

    //This event needs to be fired after record creation to refresh the screen data
    refreshOnCreateEvent() {
        const event = new CustomEvent('recordcreation', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                data: {
                    productId: this.selectedProductId, //Product Id
                    locationId: this.selectedLocationId, //Location Id
                    selectedLocationCode: this.selectedLocationCode,   //Location or Plant Code
                    selectedMaterialCode: this.selectedMaterialCode,   //Procut Code
                    selectedLocationName: this.selectedLocationName,   //Location Name
                    selectedProductName: this.selectedProductName     //Product Name
                }
            }
        });
        this.dispatchEvent(event);

        this.productId = this.selectedProductId;
        this.locationId = this.selectedLocationId;
        setTimeout(() => {
            refreshApex(this._wiredResult);
        }, 600);
    }

    //This event is to disable or enable the toggle
    toggleControlEvent(bool) {
        const selectedEvent = new CustomEvent('controltoggle', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                data: {
                    disable: bool
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    showToastMessage(title, message, variant) {
        const toast = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(toast);
    }

    showErrorToastMessage(error, errorAt) {
        if (error.body.message) {
            this.showToastMessage('Error Occured', errorAt + error.body.message, 'error');
        }
        else {
            this.showToastMessage('Error Occured', errorAt + JSON.parse(JSON.stringify(error)), 'error');
        }
    }

    validateValidFromAndValidToDates(validFromDate, validToDate, todaysDate, cloneOrUpdateOrNew) {
        let dmlCase = cloneOrUpdateOrNew;
        //Valid To must be >= Valid From date
        if (validFromDate.getTime() > validToDate.getTime()) {
            this.showToastMessage('Incorrect Dates', 'Valid From Date should be on or before Valid To Date.', 'error');
            return false;
        }
        //Valid From must be >= TODAY. Valid From would be disabled during UPDATE scenario
        else if (validFromDate.getTime() < todaysDate.getTime()) {
            if(dmlCase != 'UPDATE'){
                this.showToastMessage('Date error: Valid From', 'Valid From must be a current or a future date.', 'error');
                return false;
            }
            else if(this.reValidFromIsUpdated){
                this.showToastMessage('Date error: Valid From', 'Valid From must be a current or a future date.', 'error');
                return false;
            }
            else if (validToDate.getTime() < todaysDate.getTime()) {//Valid To must be >= TODAY even if the Valid From is past during update ase
                this.showToastMessage('Date Error: Valid To', 'Valid To must be a current or a future date.', 'error');
                return false;
            }
        }
        //Valid To must be >= TODAY
        else if (validToDate.getTime() < todaysDate.getTime()) {
            this.showToastMessage('Date Error: Valid To', 'Valid To must be a current or a future date.', 'error');
            return false;
        }
        else {
            this.showSpinner = true;
            return true;
        }
    }

    @api generateExcel() {
        this.showSpinner = true;
        this.spinnerMessage = 'Preparing to download';
        downloadTPRecords()
            .then((result) => {
                let response = JSON.parse(JSON.stringify(result));
                let mapOfFieldNamesByAPINames = new Map(Object.entries(response.mapOfFieldLabelByAPIName));

                let activeRecords = response.currentActiveRecords;
                let futureRecords = response.futureActiveRecords;
                if (!activeRecords && !futureRecords) {
                    this.showToastMessage('No Records To Download', 'There is no data to be downloaded', 'info');
                    return;
                }

                let totalNumberOfColumns = 0;
                let activeRecordWithMaxCols = activeRecords[0]; //Used to set header row of Excel with maximum columns
                //Preparing data for Active Records Excel Sheet
                activeRecords.forEach((rec) => {
                    rec.RE_Depot_Name__c = rec.hasOwnProperty('RE_Depot_Name__r') ? rec.RE_Depot_Name__r.Name : '';
                    if (rec.hasOwnProperty('RE_Depot_Name__r')) {
                        delete rec.RE_Depot_Name__r;
                    }
                    rec.RE_Product_Name__c = rec.hasOwnProperty('RE_Product_Name__r') ? rec.RE_Product_Name__r.Name : '';
                    if (rec.hasOwnProperty('RE_Product_Name__r')) {
                        delete rec.RE_Product_Name__r;
                    }
                    delete rec.RecordTypeId;
                    delete rec.Id;
                    if (Object.keys(rec).length > totalNumberOfColumns) {
                        totalNumberOfColumns = Object.keys(rec).length;
                        activeRecordWithMaxCols = rec;
                    }
                });
                activeRecords.forEach((rec) => {
                    Object.keys(activeRecordWithMaxCols).forEach((key) => {
                        if ((rec.hasOwnProperty(key) && !rec[key]) || !rec.hasOwnProperty(key)) {
                            rec[key] = '';
                        }
                    });
                });
                //Preparing data for Future Records excel Sheet
                futureRecords.forEach((rec) => {
                    rec.RE_Depot_Name__c = rec.hasOwnProperty('RE_Depot_Name__r') ? rec.RE_Depot_Name__r.Name : '';
                    if (rec.hasOwnProperty('RE_Depot_Name__r')) {
                        delete rec.RE_Depot_Name__r;
                    }
                    rec.RE_Product_Name__c = rec.hasOwnProperty('RE_Product_Name__r') ? rec.RE_Product_Name__r.Name : '';
                    if (rec.hasOwnProperty('RE_Product_Name__r')) {
                        delete rec.RE_Product_Name__r;
                    }
                    delete rec.RecordTypeId;
                    delete rec.Id;
                });
                futureRecords.forEach((rec) => {
                    Object.keys(activeRecordWithMaxCols).forEach((key) => {
                        if ((rec.hasOwnProperty(key) && !rec[key]) || !rec.hasOwnProperty(key)) {
                            rec[key] = '';
                        }
                    });
                });
                
                let headerObject = {}; //To hold field details in object as {fieldApiName : fieldLabelName}
                Object.keys(activeRecordWithMaxCols).forEach((val) => {
                    headerObject[val] = mapOfFieldNamesByAPINames.get(val.toLowerCase());
                })

                let headerNamesInOrder = {};//To hold field details in object as {fieldApiName : fieldLabelName}
                for (let i = 0; i < this.xlsHeaderTemplate.size; i++) {
                    let apiName = this.xlsHeaderTemplate.get(i);
                    if(apiName == 'RE_PH_Ocean_Cost__c'){
                        headerNamesInOrder[apiName] = 'Ocean GL%';
                    }
                    else if(apiName == 'RE_PH_S_H__c'){
                        headerNamesInOrder[apiName] = 'S&H GL%';
                    }
                    else if(apiName == 'RE_PH_PT_Percentage__c'){
                        headerNamesInOrder[apiName] = 'PT GL%';
                    }
                    else{
                        headerNamesInOrder[apiName] = mapOfFieldNamesByAPINames.get(apiName.toLowerCase());
                    }
                }

                if (activeRecords) { this.xlsFormatter(activeRecords, headerNamesInOrder, 'Active Records'); }
                if (futureRecords) { this.xlsFormatter(futureRecords, headerNamesInOrder, 'Future Records'); }
                this.filename = response.messageToReturn + '.xlsx';//File name will come here if success

                setTimeout(() => {
                    this.spinnerMessage = 'Downloading..';
                    this.template.querySelector("c-re_-excel-export").download();
                }, 400);

                setTimeout(() => {
                    this.showSpinner = false;
                    this.data = [];
                    this.xlsHeader = [];
                    this.xlsData = [];
                    this.spinnerMessage = 'Loading';
                }, 1500);

            }).catch((error) => {
                this.showSpinner = false;
                this.showToastMessage('Download Failed', 'Error while preparing data to excel download. Please contact admin' + error);
            });
    }

    xlsFormatter(data, headerListObj, sheetName) {
        this.xlsHeader.push(Object.values(headerListObj));  //this will hold headers for each sheet
        this.xlsHeaderObj = headerListObj;          //this will hold object as {fieldApiName :  fieldLabelName}
        this.workSheetNameList.push(sheetName);     //this will be the name of each sheet
        this.xlsData.push(data);                    //this will be the data in each sheet
    }

    reValidFromChangeHandler(){
        this.reValidFromIsUpdated = true;
    }
}