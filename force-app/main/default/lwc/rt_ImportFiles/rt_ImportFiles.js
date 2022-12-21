/**
 * Created by Soumyajit.Jagadev on 08-Jun-20.
 */

import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveFileApex from '@salesforce/apex/RT_ImportFiles.uploadFile';
import cancelSaveApex from '@salesforce/apex/RT_ImportFiles.cancelSave';
import upsertFileApex from '@salesforce/apex/RT_ImportFiles.upsertFile';
import getPageDetailsApex from '@salesforce/apex/RT_ImportFiles.getPageDetails';
import getAppListApex from '@salesforce/apex/RT_ImportFiles.getAppList';
import getRecentUploadsApex from '@salesforce/apex/RT_ImportFiles.getRecentUploads';
import hasAdminPermission from '@salesforce/customPermission/RT_ImportWizardAdmin';

export default class Rt_ImportFiles extends NavigationMixin(LightningElement) {

    //Property Declaration starts here
    @api appName = '';
    @track isAdmin = false;
    @track pageViewAllowed = false;
    @track showMessage = false;
    @track message ='';
    @track spinnerLoad = false;
    @track spinnerMessage = '';

    @api appList = [	{ label: '--None--', value: '--None--'} ];
    @api selectedAppFilter = '--None--';
    @track showAppFilter = false;
    @track byPassAppFilter = false;
    @track displaySchedulingOption = false;   // added by Dharmendra
    @track disableAppProceedBtn = false;
    appMap = new Map();

    @api filterList = [	{ label: '--None--', value: '--None--'} ];
    @api importList = [];
    @api selectedFilter = '--None--';
    @track selectedImportList = {};
    @track importListColumn = [	{ label: 'Source Column Number', fieldName: 'OrderNum'},
                                { label: 'Source Column', fieldName: 'SourceCol' },
                                { label: 'Is Identifier?', fieldName: 'Identifier', type: 'boolean' },
                                { label: 'Mapped Field Name', fieldName: 'FieldName'}
                              ];
    @track filterDisabled = false;
    @track disableConfirmBtn = false;
    @track disableResetBtn = false;
    @track showViewMappingBtn = false;

    @track showMapping = false;
    @track mappingMode = 'VIEWEDIT';
    @track mappingTypeID = '';
    @track hideAdminBtns = false;

    @track progressTrack = '1';

    @track showUploader = false;
    @track fileName = '';
    @track fileSelected = false;
    @track disableUploadBtn = false;
    allowedFileExtention = '.csv';
    filesUploaded = [];
    fileContents;

    @track showPreview = false;
    @api uploadList = [];
    @track dataGrid = [];

    @track showResults = false;
    logID='';
    successString = '';
    successFileName = 'Success.csv';
    errorString = '';
    errorFileName = 'Error.csv';
    uploadNowLimit = 500;
    previewLimit = 10;
    MAX_FILE_SIZE = 1540000; //1.5mb

    @track showExportMapping = false;

    @track showRecentLogs = false;
    @track recentLogList = [];
    @track recentLogColumn = [	{ label: 'Name', fieldName: 'LogLinkName' , type: 'url', typeAttributes: {label: { fieldName: 'LogName'}, target: '_blank'}},
                                { label: 'Import Type', fieldName: 'TypeName' },
                                { label: 'Status', fieldName: 'ImportStatus'},
                                { label: 'Start Time', fieldName: 'StartTime'},
                                { label: 'End Time', fieldName: 'EndTime'}
                              ];
    //Property Declaration ends here

    //Init Method Declaration starts here
    connectedCallback() {

        this.openAppFilter();
        this.pageViewAllowed = true;
        this.disableConfirmBtn = true;
        this.disableResetBtn = true;
        this.disableUploadBtn = true;
        this.isAdmin = hasAdminPermission;
        if(!this.pageViewAllowed)
            {
                this.showMessage = true;
                this.message = 'You do not have sufficient permissions to view this page. Please contact System Administrator.';
                this.showToast('error','User Authentication Failure','You do not have sufficient permissions to view this page.');
                this.filterDisabled = true;
            }

    }
    //Init Method Declaration end here

    //Method Declaration starts here
    getAppDetails()
    {
        this.loadSpinner(true,'Fetching Applications');
        this.appList = [	{ label: '--None--', value: '--None--'} ];
        console.log('---appList---');
        getAppListApex()
        .then(result => {
            this.appList = result;
            console.log('---appList---'+result);
            this.disableAppProceedBtn = true;
            if(result != undefined && result != '')
            {
                for(let i=0;i<result.length;i++)
                    this.appMap.set(result[i].value,result[i].label);

                this.byPassAppFilter = false;
                if(result.length == 1)
                {
                    this.selectedAppFilter = result[0].value;
                    this.appName = result[0].label;
                    this.byPassAppFilter = true;
                    this.loadSpinner(false,'');
                    this.fetchAppData();
                }
                else
                {
                    if(this.selectedAppFilter != '--None--' && this.selectedAppFilter != undefined && this.showAppFilter)
                    {
                        if(this.appMap.has(this.selectedAppFilter))
                        {
                            this.disableAppProceedBtn = false;
                            this.appName = this.appMap.get(this.selectedAppFilter);
                        }
                    }

                     this.loadSpinner(false,'');
                }
            }
            else
                this.showToast('error','Application Fetch Error','Something went wrong. Please try again later!');
        })
        .catch(error => {
            this.showToast('error','Application Fetch Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    getPageDetails()
    {
        this.loadSpinner(true,'Page Loading');
        this.appList = [	{ label: '--None--', value: '--None--'} ];
        getPageDetailsApex( {appName: this.selectedAppFilter} )
        .then(result => {
            this.filterList = result.ImportFilterList;
            this.importList = result.ImportType;
            this.uploadNowLimit = result.uploadNowLimit;
            this.previewLimit = result.previewLimit;
            this.loadSpinner(false,'');
            this.getRecentUploads();
        })
        .catch(error => {
            this.showToast('error','Page Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    setAppName(event)
    {
        this.selectedAppFilter = event.detail.value;
        if(this.selectedAppFilter != '--None--' && this.selectedAppFilter != undefined)
        {
            this.disableAppProceedBtn = false;
            this.appName = this.appMap.get(this.selectedAppFilter);
            if(this.appName == 'Revolution'){
                this.displaySchedulingOption = true;
                this.recentLogColumn = [	{ label: 'Name', fieldName: 'LogLinkName' , type: 'url', typeAttributes: {label: { fieldName: 'LogName'}, target: '_blank'}},
                                                     { label: 'Import Type', fieldName: 'TypeName' },
                                                     { label: 'Status', fieldName: 'ImportStatus'},
                                                     { label: 'Success Count', fieldName: 'SuccessCount'},
                                                     { label: 'Error Count', fieldName: 'ErrorCount'},
                                                     { label: 'Start Time', fieldName: 'StartTime'},
                                                     { label: 'End Time', fieldName: 'EndTime'}
                                                   ];
            }else{
                this.displaySchedulingOption = false;
                this.recentLogColumn = [	{ label: 'Name', fieldName: 'LogLinkName' , type: 'url', typeAttributes: {label: { fieldName: 'LogName'}, target: '_blank'}},
                                                     { label: 'Import Type', fieldName: 'TypeName' },
                                                     { label: 'Status', fieldName: 'ImportStatus'},
                                                     { label: 'Start Time', fieldName: 'StartTime'},
                                                     { label: 'End Time', fieldName: 'EndTime'}
                                                   ];
            }
        }
        else
            this.disableAppProceedBtn = true;
    }

    openAppFilter()
    {
        this.showAppFilter = true;
        this.getAppDetails();
    }

    fetchAppData()
    {
        this.showAppFilter = false;
        this.getPageDetails();
    }

    closeAppFilter()
    {
        this.showAppFilter = false;
        this.pageViewAllowed = false;
        this.showMessage = true;
        this.message = 'Cannot Load Page As Application Selection Is Missing';
    }

    fetchFilter(event)
    {
        this.selectedFilter = event.detail.value;
        this.selectedImportList = {};
        this.disableConfirmBtn = true;
        this.showExportMapping = false;

        if(this.selectedFilter != '--None--' && this.selectedFilter != undefined)
        {
            this.disableConfirmBtn = false;
            this.showViewMappingBtn = true;
            this.disableResetBtn = false;
            for(let i = 0; i < this.importList.length; i++)
            {
                if(this.importList[i].Name == this.selectedFilter)
                    this.selectedImportList = this.importList[i];
            }
            this.showExportMapping = true;
        }
        else
            this.showViewMappingBtn = false;
    }

    viewMapping()
    {
        this.showMapping = true;
        this.mappingTypeID = this.selectedImportList.TypeID;
        this.showViewMappingBtn = false;
    }

    hideMapping()
    {
        if(this.mappingMode == 'CREATE')
            this.mappingMode = 'VIEWEDIT';
        this.showMapping = false;
        if((this.mappingMode == 'VIEW' || this.mappingMode == 'VIEWEDIT')
        && this.selectedFilter != '' && this.selectedFilter != '--None--' && this.selectedFilter != undefined)
            this.showViewMappingBtn = true;
    }

    createMapping()
    {
        this.showMapping = true;
        this.showViewMappingBtn = false;
        this.mappingMode = 'CREATE';
    }

    handleCloseEvent()
    {
        this.getPageDetails();
        this.resetSelection();
    }

    confirmSelection()
    {
        this.filterDisabled = true;
        this.disableConfirmBtn = true;
        this.disableResetBtn = false;
        this.progressTrack = '2';
        this.showUploader = true;
        this.hideAdminBtns = true;
        this.mappingMode = 'VIEW';
        this.showExportMapping = false;
        this.showRecentLogs = false;
    }

    resetSelection()
    {
        this.selectedFilter = '--None--';
        this.filterDisabled = false;
        this.disableConfirmBtn = true;
        this.disableResetBtn = true;
        this.showViewMappingBtn = false;
        this.showMapping = false;
        this.progressTrack = '1';
        this.showUploader = false;
        this.fileSelected = false;
        this.uploadList = [];
        this.showResults = false;
        this.showPreview = false;
        this.disableUploadBtn = true;
        this.hideAdminBtns = false;
        this.mappingMode = 'VIEWEDIT';
        this.showExportMapping = false;
        this.getRecentUploads();
    }

    handleFileChange(event)
    {
        this.disableUploadBtn = true;
        if(event.target.files.length > 0)
        {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.fileSelected = true;
            this.disableUploadBtn = false;

            let file = this.filesUploaded[0];
            console.log('File Size = ' + file.size);
            if (file.size > this.MAX_FILE_SIZE)
            {
                this.showToast('error','File Size Is More Than 1.5 MB','Please Select A Smaller File to Upload or Split This File & Upload One By One');
                this.filesUploaded = [];
                this.fileName = '';
                this.fileSelected = false;
                this.disableUploadBtn = true;
            }
        }
    }

    handleSave(event)
    {
        if(this.fileName.endsWith(this.allowedFileExtention))
        {
            var buttonName = event.target.dataset.name;
            if(this.filesUploaded.length > 0)
                this.uploadHelper(buttonName);
            else
                this.showToast('error','File Upload Failure','Please Select A File to Upload');
        }
        else
            this.showToast('error','File Upload Failure','Allowed File Extension is ' + this.allowedFileExtention);
    }

    uploadHelper(loadType)
    {
        this.uploadList = [];
        this.showPreview = false;
        this.disableUploadBtn = true;
        this.loadSpinner(true,'File Upload In Progress');

        let base64 = 'base64,';
        let file = this.filesUploaded[0];
        let fileReader = new FileReader();
        let content;

        fileReader.onloadend = (() => {
                    this.fileContents = fileReader.result;
                    content = this.fileContents.indexOf(base64) + base64.length;
                    this.fileContents = this.fileContents.substring(content);
                    this.saveToFile(loadType);
                });
        fileReader.readAsDataURL(file);
    }

    saveToFile(loadType) {
        saveFileApex( {uploadType: loadType,
                       importType: JSON.stringify(this.selectedImportList),
                       fileName  : this.fileName,
                       base64Data: encodeURIComponent(this.fileContents)
                    }
                )
            .then(result => {

                if(loadType == 'NOW')
                {
                    if(result != '' && result!=undefined)
                    {
                        this.uploadList = result;

                        if(this.uploadList.ImportStatus == 'Error')
                        {
                            this.showToast('error','File is having more than ' + this.uploadNowLimit + ' records'
                                                            ,'Please use "Upload Selected File In Background" option');
                            this.disableUploadBtn = false;
                        }
                        else
                        {
                            if(this.uploadList.bodyRow != '' && this.uploadList.bodyRow != undefined)
                            {
                                    this.setGridCSS();
                                    this.showPreview = true;
                                    this.showUploader = false;
                                    this.progressTrack = '3';
                                    this.showToast('success','File Upload Successful','Preview will be truncated to ' + this.previewLimit + ' data rows');
                            }
                            else
                                this.showToast('error','No Rows found to Upload','Please check the file');
                        }

                    }
                    this.loadSpinner(false,'');
                }
                else if(loadType == 'QUEUE'){
                    this.showUploader = false;
                    this.showToast('success','Success','File Has Been Sent For Upload In Background. Please Check Logs For Status');
                    this.loadSpinner(false,'');
                    this.resetSelection();
                }
                else
                {
                    this.showUploader = false;
                    this.showPreview = false;
                    this.showToast('success','Success','File Has Been Scheduled. Please Check Logs For Status');
                    this.loadSpinner(false,'');
                    this.resetSelection();
                }

            })
            .catch(error => {
                this.showToast('error','File Preview Upload Failure',error.message);
                this.loadSpinner(false,'');
            });
    }

    setGridCSS()
    {
        let dataGrid = [];
        let header = [];
        let body = [];

        if(this.uploadList != '' && this.uploadList != undefined)
        {
            for(let i=0; i< this.uploadList.headerRow.length ; i++)
            {
                let head = this.uploadList.headerRow[i];

                head.divClass = '';
                head.thClass = '';

                if(i==0)
                {
                    head.divClass = 'rowNumCol';
                    head.thClass = 'rowNumCol';
                }
                else
                {
                    if(head.FieldMapFound)
                    {
                        head.divClass = 'mappingCol';
                        head.thClass = 'mappingCol';
                    }
                    else
                    {
                        head.divClass = 'headerCol';
                        head.thClass = 'headerCol';
                    }
                }

                header.push(head);
            }

            dataGrid.headerRow = header;

            for(let i=0; i< this.uploadList.bodyRow.length ; i++)
            {
                let bodyRow = this.uploadList.bodyRow[i];
                let rowCol = [];

                for(let j=0; j< bodyRow.rowCol.length ; j++)
                {
                    let col = bodyRow.rowCol[j];
                    col.divClass = '';
                    col.tdClass = '';

                    if(j==0)
                    {
                        col.divClass = 'rowNumCol';
                        col.tdClass = 'rowNumCol';
                    }
                    else
                    {
                        if(col.FieldMapFound)
                        {
                            col.divClass = 'mappingCol';
                            col.tdClass = 'mappingCol';
                        }
                        else
                        {
                            col.divClass = '';
                            col.tdClass = '';
                        }
                    }
                    rowCol.push(col);
                }
                bodyRow.rowCol = rowCol;
                body.push(bodyRow);
            }
            dataGrid.bodyRow = body;
        }

        this.dataGrid = dataGrid;
    }

    finalConfirm()
    {
        this.progressTrack = '4';

        this.loadSpinner(true,'Inserting Data into System');
        upsertFileApex( {TypeID: this.selectedImportList.TypeID, LogID: this.uploadList.LogID, fileName: this.fileName})
            .then(result => {
                this.logID = result.LogID;
                this.successFileName = result.successFileName;
                this.successString = result.successString;
                this.errorFileName = result.errorFileName;
                this.errorString = result.errorString;

                if(result.status)
                    this.showToast('success','Success',result.statusMsg);
                else
                    this.showToast('error','Error',result.statusMsg);

                this.progressTrack = '5';
                this.loadSpinner(false,'');
                this.showPreview = false;
                this.showResults = true;
            })
            .catch(error => {
                this.showToast('error','File Upload Failure',error.message);
                this.loadSpinner(false,'');
            });
    }

    cancelUpload()
    {
        this.loadSpinner(true,'Cancelling Upload');
        cancelSaveApex( {LogID: this.uploadList.LogID})
            .then(result => {
                this.resetSelection();
                this.loadSpinner(false,'');
            })
            .catch(error => {
                this.showToast('error','Something Went Wrong',error.message);
                this.loadSpinner(false,'');
            });
    }

    viewLog()
    {
        this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.logID,
                        objectApiName: 'RT_ImportLog__c', // objectApiName is optional
                        actionName: 'view'
                    }
                });
    }

    downloadCSVFile(event)
    {
        let callType = event.target.name;

        if(callType == 'Success')
            this.createDownloadCSVFile(this.successString, this.successFileName);

        if(callType == 'Error')
            this.createDownloadCSVFile(this.errorString, this.errorFileName);
    }

    createDownloadCSVFile(csvString, csvFileName) //(headerRow, dataRow, csvFileName)
    {
        try{
        if(csvString == '')
            csvString = 'No Data';

            let downloadElement = document.createElement('a');
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
            downloadElement.target = '_self';
            downloadElement.download = csvFileName;
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            downloadElement.click();
        }
        catch(err)
            {console.log(err.message);}
    }

    navigateToTab()
    {
        this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'RT_ImportType__c',
                        actionName: 'home'
                    }
                });
    }

    exportMapping()
    {
            let downloadElement = document.createElement('a');
            downloadElement.href = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(this.selectedImportList));
            downloadElement.target = '_self';
            downloadElement.download = this.selectedImportList.Name + '.json';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            downloadElement.click();
    }

    getRecentUploads()
    {
        this.loadSpinner(true,'Fetching Recent Import Logs');
        this.showRecentLogs = true;
        this.recentLogList = [];

        getRecentUploadsApex()
            .then(result => {
                this.recentLogList = result;

                if(result == '' || result == undefined)
                    this.showRecentLogs = false;

                this.loadSpinner(false,'');

            })
            .catch(error => {
                this.showToast('error','Recent Import Fetch Failure',error.message);
                this.loadSpinner(false,'');
            });
    }
    // Navigation to Custom Tab
        openLogs() {
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/lightning/o/RT_ImportLog__c/list?filterName=Recent'
                    }
                }).then(generatedUrl => {
                    window.open(generatedUrl);
                });
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

    @track toggleCSS = 'slds-section slds-is-close';
    toggleSection()
    {
        if(this.toggleCSS == 'slds-section slds-is-close')
            this.toggleCSS ='slds-section slds-is-open';
        else
            this.toggleCSS = 'slds-section slds-is-close';
     }
    //Method Declaration ends here
}