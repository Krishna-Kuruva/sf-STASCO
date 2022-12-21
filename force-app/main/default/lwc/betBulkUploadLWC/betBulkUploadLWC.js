import { LightningElement, wire, api, track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBulkUploadRecords from '@salesforce/apex/BET_BDD_Search_Controller.getBulkUploadRecords';
import updateReadyToOnboard from '@salesforce/apex/BetBulkUploadLWCController.updateReadyToOnboard';
const columns = [{
        label: 'BDD Form Name',
        fieldName: 'LinkName',
        type: 'url',
        sortable: true,
        typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
    },
	{
		label: 'Legal Name',
        fieldName: 'GT_Legal_Name__c',
        sortable: true
	},
	{
		label: 'BDD Entity Type',
        fieldName: 'BDD_Entity_Type__c',
        sortable: true
	},
	{
		label: 'BDD Region',
        fieldName: 'BDD_Line_of_Business__c',
        sortable: true
	},
    {
        label: 'BET Status',
        fieldName: 'BET_Status__c',
        sortable: true
    },
    {
        label: 'Assigned Cof',
        fieldName: 'AssignedCofUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {label: { fieldName: 'AssignedCofName' }, target: '_blank'}
    },
    {
        label: 'BDD Onboard Type',
        fieldName: 'BDD_Onboard_Type__c',
        sortable: true
    }
];


const sucessColumns = [{
    label: 'BDD Form Name',
    fieldName: 'processedRecNumber',
    sortable: true
},
{
    label: 'Legal Name',
    fieldName: 'processedRecName',
    sortable: true
},
{
    label: 'Update Status',
    fieldName: 'successMessage',
    sortable: true
}
];

const failedColumns = [{
    label: 'BDD Form Name',
    fieldName: 'processedRecNumber',
    sortable: true
},
{
    label: 'Legal Name',
    fieldName: 'processedRecName',
    sortable: true
},
{
    label: 'Error Message',
    fieldName: 'errorMessage',
    sortable: true
},
{
    label: 'Error Causing Fields',
    fieldName: 'errorFields'
}
];

export default class BetBulkUploadLWC extends LightningElement {
    @track value;
    @track error;
    @track data;
    @api sortedDirection = 'asc';
    @api sortedBy = 'Name';
    @api searchKey = '';
    result;
    @track allSelectedRows = [];
    @track page = 1; 
    @track items = []; 
    @track data = []; 
    @track columns; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 25; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track showModal = false;
    @track isConfirmDialogVisible = false;
    @track originalMessage='open modal';
    @track apexResp;
    @track apexRespSuccessList=[];
    @track apexRespFailedList=[];
    @track apexRespSuccessCount=0;
    @track apexRespFailedCount=0;
    @track showRespSuccessTable=false;
    @track showRespFailedTable=false;
    @track sucessColumns;
    @track failedColumns;
    @track wiredFormList = [];
    isPageChanged = false;
    initialLoad = true;
    mapformNameVsForm = new Map();;
  
    @wire(getBulkUploadRecords, {searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection'}) formList(result) {
		this.wiredFormList = result;
		if (result.data) {
		  let tempDataList = [];
				var dataVar;
				result.data.forEach((record) => {
					let tempFormRec = Object.assign({}, record);  
					tempFormRec.LinkName = '/' + tempFormRec.Id;
                    tempFormRec.AssignedCofUrl ='/'+tempFormRec.Assigned_COF__c;
                    tempFormRec.AssignedCofName =tempFormRec.Assigned_COF__r.Name;
					tempDataList.push(tempFormRec);
					
				});
				this.data=tempDataList;
				dataVar=tempDataList;
				this.processRecords(dataVar);
				this.error = undefined;
		} else if (result.error) {
		  this.error = error;
		  this.data = undefined;
		}
	}

    processRecords(data){
        this.items = data;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            
            this.data = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            this.columns = columns;
    }
    //clicking on previous button this method will be called
    previousHandler() {
        this.isPageChanged = true;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
            selectedIds.push(this.allSelectedRows[i].Id);
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;
    }

    //clicking on next button this method will be called
    nextHandler() {
        this.isPageChanged = true;
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
            selectedIds.push(this.allSelectedRows[i].Id);
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }    
    
    sortColumns( event ) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        return refreshApex(this.result);
        
    }
    
    onRowSelection(event){
        if(!this.isPageChanged || this.initialLoad){
            if(this.initialLoad) this.initialLoad = false;
            this.processSelectedRows(event.detail.selectedRows);
        }else{
            this.isPageChanged = false;
            this.initialLoad =true;
        }
        
    }

    
    openConfirmModalLwc(event){
        //it can be set dynamically based on your logic
        console.log('inside openConfirmModalLwc function');
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length > 0){
            this.originalMessage = 'Open Confrim Modal';
            this.isConfirmDialogVisible = true;
        } else {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one record to process',
                variant: 'error',
                mode: 'dismissable',
            });
            this.dispatchEvent(evt);
        }
    }

    handleconfirmModalButtonclick(event){
        console.log('Inside handleconfirmModalButtonclick ');
        console.log('Inside handleconfirmModalButtonclick '+event.detail);
        console.log('Inside handleconfirmModalButtonclick '+event.detail.status);
        if(event.detail !== 1){
            //gets the detail message published by the child component
            this.displayMessage = 'Status: ' + event.detail.status + '. Event detail: ' + JSON.stringify(event.detail.originalMessage) + '.';

            //you can do some custom logic here based on your scenario
            if(event.detail.status === 'confirm') {
                //do something
                console.log('Inside handleconfirmModalButtonclick status eqauls confirm');
                this.getSelectedRec();
            }else if(event.detail.status === 'cancel'){
                //do something else
            }
        }
        //hides the component
        this.isConfirmDialogVisible = false;
    }

    getSelectedRec() {
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length > 0){
            console.log('selectedRecords are ', selectedRecords);
            let ids = '';
            selectedRecords.forEach(currentItem => {
                ids = ids + ',' + currentItem.Id;
            });
            //this.selectedIds = ids.replace(/^,/, '');
            //this.lstSelectedRecords = selectedRecords;
            console.log('selectedRecords are '+JSON.stringify(selectedRecords));
            updateReadyToOnboard({ selectedFormList: selectedRecords })
            .then(result => {
                console.log('Resp from APex'+JSON.stringify(result));
                this.apexResp = result;
                this.apexRespSuccessList = result.UpdateSuccessList;
                this.apexRespFailedList = result.UpdateFailedList;
                this.apexRespSuccessCount = this.apexRespSuccessList.length;
                if(this.apexRespSuccessCount >0) {
                    this.showRespSuccessTable = true;
                }
                console.log('Show Success Table'+this.showRespSuccessTable);
                this.apexRespFailedCount = this.apexRespFailedList.length;
                if(this.apexRespFailedCount >0) {
                    this.showRespFailedTable = true;
                }
                console.log('Show failed Table'+this.showRespFailedTable);
                this.sucessColumns =sucessColumns;
                this.failedColumns =failedColumns;
                //success event 
                const eventsc = new ShowToastEvent({
                    title: 'Update Success',
                    message: 'Records updated successfully.',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(eventsc);

                this.showModal = true;
                refreshApex(this.wiredFormList);
            })
            .catch(error => {
                this.error = error;
            });
        }   
      }

    processSelectedRows(selectedOpps){
        var newMap = new Map();
        for(var i=0; i<selectedOpps.length;i++){
            if(!this.allSelectedRows.includes(selectedOpps[i])){
                this.allSelectedRows.push(selectedOpps[i]);
            }
            this.mapformNameVsForm.set(selectedOpps[i].Name, selectedOpps[i]);
            newMap.set(selectedOpps[i].Name, selectedOpps[i]);
        }
        for(let [key,value] of this.mapformNameVsForm.entries()){
            if(newMap.size<=0 || (!newMap.has(key) && this.initialLoad)){
                const index = this.allSelectedRows.indexOf(value);
                if (index > -1) {
                    this.allSelectedRows.splice(index, 1); 
                }
            }
        }
    }

    
    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        var data = [];
        for(var i=0; i<this.items.length;i++){
            if(this.items[i]!= undefined && this.items[i].Name.includes(this.searchKey)){
                data.push(this.items[i]);
            }
        }
        this.processRecords(data);
    }

    openModal() {
        // Setting boolean variable to true, this will show the Modal
        this.showModal = true;
    }

    closeModal() {
        // Setting boolean variable to false, this will hide the Modal
        this.showModal = false;
        refreshApex(this.wiredFormList);
    }

}