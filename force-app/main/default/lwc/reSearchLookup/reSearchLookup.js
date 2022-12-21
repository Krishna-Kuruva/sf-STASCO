// Example how to use this reusable component
/* <c-re-search-lookup lookup-ref=1 obj-name="RE_Product__c" icon-name="custom:custom6" label-name="Product Name" 
                        placeholder="Search Philippine Product" onlookup={handleLookUp} filter-query="RecordType.Name='Philippines'" 
                        current-record-id={selectedProductId} display-fields="Name,Id,RE_Product_Code__c"></c-re-search-lookup> */
import { LightningElement, api, track, wire } from 'lwc';
import searchRecords from '@salesforce/apex/Re_SearchLookupController.lookupRecords';


export default class ReSearchLookup extends LightningElement {
    @api objName = 'Account';
    @api iconName = 'standard:account';
    @api labelName;
    @api readOnly = false;
    @api currentRecordId;
    @api placeholder = 'Search';
    @api createRecord;
    @api fields = ['Name'];
    @api displayFields = 'Name';
    @api filterQuery = '';
    @api inSearchGroup = '';
    @api disableSelectedValue = false;
    @api lookupRef = 0; //To identify the source lookup if there are more than 1 in a single comp
    @api isRequired = false;
    @track error;
    @api customIconImage;
    

    searchKey;
    @track searchResult;
    selectedRecord;
    objectLabel;
    isLoading = false;
    //Below variables will be assigned with field API names in Connected Callback
    field;  //Prefer setting it to Name
    field1; //Prefer setting it to ID
    field2; //Prefer setting it to any other important field
    @track navigatorIndex = -1;
    @api selectedRecord;
    @api disabledVal = false;
    showMessage = '';
    resultSectionStyle;

    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';

    connectedCallback() {
        let icons = this.iconName.split(':');
        this.ICON_URL = this.ICON_URL.replace('{0}', icons[0]);
        this.ICON_URL = this.ICON_URL.replace('{1}', icons[1]);
        this.objectLabel = this.objName.toUpperCase();
        let fieldList;
        if (!Array.isArray(this.displayFields)) {
            fieldList = this.displayFields.split(',');
        }
        else {
            fieldList = this.displayFields;
        }
        if (fieldList.length > 1) {
            this.field = fieldList[0].trim();
            this.field1 = fieldList[1].trim();
        }
        if (fieldList.length > 2) {
            this.field2 = fieldList[2].trim();
        }
        let combinedFields = [];
        fieldList.forEach(field => {
            if (!this.fields.includes(field.trim())) {
                combinedFields.push(field.trim());
            }
        });
        this.fields = combinedFields.concat(JSON.parse(JSON.stringify(this.fields)));
        console.log('Icon URL: '+this.customIcon);
    }

    @wire(searchRecords, {
        objectName: '$objName',
        fields: '$fields',
        searchTerm: '$searchKey',
        findInField: '$inSearchGroup',
        filterQuery: '$filterQuery'
    })
    returnedData(result) {
        const { data, error } = result;
        if (data) {
            this.showMessage = '';
            let allResult = JSON.parse(JSON.stringify(data));
            allResult.forEach(record => {
                record.FIELD1 = record[this.field] || record.Name;
                record.FIELD2 = record[this.field1] || record.Id;
                if (this.field2) {
                    record.FIELD3 = record[this.field2];
                } else {
                    record.FIELD3 = '';
                }
            });
            if (allResult.length > 0) {
                this.searchResult = allResult;
            }
            else {
                this.searchResult = [];
                this.showMessage = 'No results found..';
            }
            this.isLoading = false;
        }
        else if (error) {
            this.searchResult = [];
            console.log('Error: ' + JSON.stringify(error));
            this.isLoading = false;
            this.showMessage = 'Error while searching..';
        }
    }

    handleInputChange(event) {
        this.resultSectionStyle = 'slds-dropdown_length-with-icon-7 slds-dropdown_fluid slds-show css_Bg_White';
        let inputString = event.target.value;
        //Logic to remove any preceding whitespaces starts
        let spaceCounter = 0;
        for(let i = 0; i < inputString.length; i++){
            if(inputString.charAt(i) != " "){
                break;
            }
            else{
                spaceCounter = spaceCounter + 1;
            }
        }
        for(let j = 0; j <= spaceCounter; j++){
            inputString = inputString.trim();
        }
        //Logic to remove any preceding whitespaces Ends
        if (inputString.length > 1) {
            this.showMessage = '';
            this.searchKey = inputString;
            this.isLoading = true;
        }
        else {
            this.showMessage = 'Please type atleast 2 characters';
            this.searchResult = [];
            return;
        }

    }

    
    // onkeyup={handleKeyPress} this part has been removed as it is sporadically not working
    // @api
    // handleKeyPress(event) {
    //     var key = event.which || event.keyCode;
    //     var i = 0;
    //     if (!this.searchResult) {
    //         return;
    //     }
    //     if (key != null) {
    //         if (key == 40) {//Down arrow key pressed.
    //             if (this.navigatorIndex < this.searchResult.length - 1)
    //                 this.navigatorIndex++;
    //         }
    //         else if (key == 38) {//Up arrow key pressed.
    //             if (this.navigatorIndex > 0)
    //                 this.navigatorIndex--;
    //         }
    //         else if (key == 13) {
    //             var temObj = {};
    //             if (this.searchResult[this.navigatorIndex] != undefined) {
    //                 temObj.detail = {
    //                     'recordId' : this.searchResult[this.navigatorIndex].Id,
    //                     'lookupRef' : this.lookupRef
    //                 }
    //                 // temObj.detail = this.searchResult[this.navigatorIndex].Id;
    //                 // temObj.lookupRef = this.lookupRef;
    //                 this.handleEnterSelect(temObj);
    //             }
    //         }
    //     }
    //     for (i = 0; i < this.searchResult.length; i++) {
    //         if (i === this.navigatorIndex) {
    //             this.searchResult[i].selected = true;
    //         }
    //         else {
    //             this.searchResult[i].selected = false;
    //         }
    //     }
    // }

    // handleEnterSelect(event) {
    //     let recordId = event.detail.recordId;
    //     let selectRecord = this.searchResult.find((item) => {
    //         return item.Id === recordId;
    //     });
    //     this.selectedRecord = selectRecord;
    //     const selectedEvent = new CustomEvent('lookup', {
    //         bubbles: true,
    //         composed: true,
    //         cancelable: true,
    //         detail: {
    //             data: {
    //                 record: selectRecord,
    //                 recordId: recordId,
    //                 currentRecordId: this.currentRecordId,
    //                 lookupRef: this.lookupRef || event.detail.lookupRef
    //             }
    //         }
    //     });
    //     this.dispatchEvent(selectedEvent);
    // }

    handleBlur() {
        this.searchResult = [];
        this.resultSectionStyle = 'slds-dropdown_length-with-icon-7 slds-dropdown_fluid slds-hide';
    }

    handleFocus(event) {
        this.resultSectionStyle = 'slds-dropdown_length-with-icon-7 slds-dropdown_fluid slds-show css_Bg_White';
        searchRecords({
            objectName: this.objName,
            fields: this.fields,
            searchTerm: this.searchKey || '',
            findInField: this.inSearchGroup,
            filterQuery: this.filterQuery
        }).then((result) => {
            this.showMessage = '';
            let allResult = JSON.parse(JSON.stringify(result));
            allResult.forEach(record => {
                record.FIELD1 = record[this.field] || record.Name;
                record.FIELD2 = record[this.field1] || record.Id;
                if (this.field2) {
                    record.FIELD3 = record[this.field2];
                } else {
                    record.FIELD3 = '';
                }
            });
            if (allResult.length > 0) {
                this.searchResult = allResult;
            }
            else {
                this.searchResult = [];
                this.showMessage = 'No results found..';
            }
            this.isLoading = false;
        }).catch((error) => {
            this.searchResult = [];
            console.log('Error: ' + JSON.stringify(error));
            this.isLoading = false;
            this.showMessage = 'Error while searching..';
        });
    }

    handleSelect(event) {
        let recordId = event.currentTarget.dataset.recordid;
        let selectRecord = this.searchResult.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                data: {
                    record: selectRecord,
                    recordId: recordId,
                    currentRecordId: this.currentRecordId,
                    lookupRef: this.lookupRef
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleClose() {
        this.selectedRecord = undefined;
        this.searchResult = undefined;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                data: {
                    record: undefined,
                    recordId: undefined,
                    currentRecordId: this.currentRecordId,
                    lookupRef: this.lookupRef
                }
            }
        });
        this.dispatchEvent(selectedEvent);
        this.searchKey = '';
    }

    // titleCase(string) {
    //     var sentence = string.toLowerCase().split(" ");
    //     for (var i = 0; i < sentence.length; i++) {
    //         sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
    //     }
    //     return sentence;
    // }
}