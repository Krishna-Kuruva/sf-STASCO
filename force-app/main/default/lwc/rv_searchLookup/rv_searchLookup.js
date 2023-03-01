import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import searchRecords from '@salesforce/apex/RV_SearchLookupController.search';

export default class SearchComponent extends LightningElement{

    @api objName = 'Account';
    @api iconName = 'standard:account';
    @api labelName;
    @api readOnly = false;
    @api currentRecordId;
    @api placeholder = 'Search';
    @api createRecord;
    @api fields = ['Name'];
    @api displayFields = 'Name';
    @api filterQuery;
    @api inSearchGroup = '';
    @track error;

    searchKey;
    @track searchResult;
    selectedRecord;
    objectLabel;
    isLoading = false;
    field;
    field1;
    field2;
    @track navigatorIndex = 0;
    @api selectedRecord;
    @api disabledVal = false;

    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';

    connectedCallback(){
        let icons = this.iconName.split(':');
        this.ICON_URL = this.ICON_URL.replace('{0}',icons[0]);
        this.ICON_URL = this.ICON_URL.replace('{1}',icons[1]);
        if(!this.objName.includes('__c')){
            this.objectLabel = this.objName;
        }
        //this.objectLabel = this.titleCase(this.objectLabel);
        let fieldList;
        if(!Array.isArray(this.displayFields)){
            fieldList = this.displayFields.split(',');
        }
        else{
            fieldList = this.displayFields;
        }
        if(fieldList.length > 1){
            this.field  = fieldList[0].trim();
            this.field1 = fieldList[1].trim();
        }
        if(fieldList.length > 2){
            this.field2 = fieldList[2].trim();
        }
        let combinedFields = [];
        fieldList.forEach(field => {
            if( !this.fields.includes(field.trim()) ){
                combinedFields.push( field.trim() );
            }
        });
        this.fields = combinedFields.concat( JSON.parse(JSON.stringify(this.fields)) ); 
    }
 
    @wire(searchRecords, {
                            objectName: '$objName',
                            fields: '$fields',
                            searchTerm: '$searchKey',
                            findInField: '$inSearchGroup',
                            filterQuery: '$filterQuery'
                         })
    returnedData(result){
        const {data, error} = result;
        if(data){
            let stringResult = JSON.stringify(data);
            let allResult    = JSON.parse(stringResult);
            allResult.forEach( record => {
                record.FIELD1 = record[this.field];
                record.FIELD2 = record[this.field1];
                if( this.field2 ){
                    record.FIELD3 = record[this.field2];
                }else{
                    record.FIELD3 = '';
                }
            });
            this.searchResult = allResult;
        }
        else if(error){
            this.searchResult = [];
            console.log('Error: '+JSON.stringify(error));
        }
    }

    handleInputChange(event){
        this.searchKey = event.target.value;
    }
    
    @api
    handleKeyPress(event){
        var key     = event.which || event.keyCode;
        var i       = 0;
        if(!this.searchResult){
            return;
        }
        if(key != null){
            if(key == 40){      //Down arrow key pressed.
                if(this.navigatorIndex < this.searchResult.length - 1)
                    this.navigatorIndex++;
            }
            else if(key == 38){     //Up arrow key pressed.
                if(this.navigatorIndex > 0)
                    this.navigatorIndex--;
            }
            else if(key == 13){
                var temObj = {};
                if(this.searchResult[this.navigatorIndex] != undefined){
                    temObj.detail = this.searchResult[this.navigatorIndex].Id;
                    this.handleEnterSelect(temObj);
                }
            }
        }
        for(i=0; i<this.searchResult.length; i++){
            if(i===this.navigatorIndex){
                this.searchResult[i].selected = true;
            }
            else{
                this.searchResult[i].selected = false;
            }
        }
    }

    handleEnterSelect(event){
        let recordId = event.detail;
        let selectRecord = this.searchResult.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord; 
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {  
                data : {
                    record : selectRecord,
                    recordId : recordId,
                    currentRecordId : this.currentRecordId
                }
            }
        });
        this.dispatchEvent(selectedEvent);       
    }

    handleBlur(){
        //this.searchResult = [];
    }

    handleSelect(event){
        let recordId = event.currentTarget.dataset.recordId;
        let selectRecord = this.searchResult.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {  
                data : {
                    record : selectRecord,
                    recordId : recordId,
                    currentRecordId : this.currentRecordId
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }
    //added api as part of PBI-1439256
    @api handleClose(){
        this.selectedRecord = undefined;
        this.searchResult  = undefined;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {  
                data : {
                    record: undefined,
                    recordId: undefined,
                    currentRecordId : this.currentRecordId
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    titleCase(string){
        var sentence = string.toLowerCase().split(" ");
        for(var i = 0; i< sentence.length; i++){
            sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
        }
        return sentence;
    }
}