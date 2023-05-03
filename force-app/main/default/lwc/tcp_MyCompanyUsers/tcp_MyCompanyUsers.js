import { LightningElement,track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import TCP_RoundCheck_icon from '@salesforce/resourceUrl/TCP_RoundCheck_icon';
import getContacts from '@salesforce/apex/TCP_MyCompanyUsersController.getContacts';
import getShellContacts from '@salesforce/apex/TCP_MyCompanyUsersController.getShellContacts';
import getNewRequestDetails from '@salesforce/apex/TCP_MyCompanyUsersController.getNewRequestDetails';
import getUserEditDetails from '@salesforce/apex/TCP_MyCompanyUsersController.getUserEditDetails';
import getUserDeleteDetails from '@salesforce/apex/TCP_MyCompanyUsersController.getUserDeleteDetails';


const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
    
];

const columns = [
   
    { label: 'Name', fieldName: 'Name' , sortable: false , wrapText: true, },
    { label: 'Email', fieldName: 'Email' , sortable: false , wrapText: true, },
    { label: 'Company', fieldName: 'Company' , sortable: false , wrapText: true,  },
    { label: 'Status', fieldName: 'Status',  hideDefaultActions: true, sortable: false , wrapText: true, fixedWidth: 70, cellAttributes: { class:"colorApproved"}},
    { label: '', fieldName: 'DeleteReason' , sortable: false , wrapText: true,fixedWidth: 170,hideDefaultActions: true,cellAttributes: { class:"colorRejected"}},
    { label: 'Action', fieldName: 'Action' , hideDefaultActions: true, 
        cellAttributes: { 
            iconName: 'utility:threedots_vertical',
            class: { fieldName: 'disableColor' }
            
    },
        type: 'action', fixedWidth: 75,
        typeAttributes: { rowActions: actions },
        
       
    
    },
        
];

const data = [
        
            { id: 1,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
               },


               { id: 2,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },


               { id: 3,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                
               },

               { id: 4,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active ', initialWidth: 70,
                update:'(Deletion request sent)',initialWidth: 170,
               
               },

               { id: 5,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 6,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 7,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 8,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 9,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 10,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active ', initialWidth: 70,
                update:'(Deletion request sent)',initialWidth: 170,
                 
               },

               { id: 11,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 12,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

              
               { id: 13,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 14,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 15,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 16,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

               { id: 17,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },
               { id: 18,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },
               { id: 19,
                Name: 'Sadiya Sultana',
                Email: 'sadiya.sultana@shell.com', 
                Company:'Shell Trading Rotterdam B V',
                Status:'Active', initialWidth: 70,
                update:'',initialWidth: 170,
                 
               },

];




export default class Tcp_MyCompanyUsers extends NavigationMixin (LightningElement) {
  @track MyCompanyUsers = true;
  @track RequestNewUser = false;
  @track isShowUsersEdit = false;
  @track isShowUsersDelete = false;
  @track shellConData = [];
  @track ContactList=[];
  @track conOptions = [];
  @track contacts;
  @track deleteReason='';
  @track companyName;
  @track contactName;
  @track contactEmail;
  @track firstname='';
  @track lastName='';
  @track email='';
  @track phone='';
  @track requestedTo='';
  @track accountId;
  @track editDetails='';
  @track enableSubmit=false;
  @track isShowMyDeleteRequestSuccess=false;
  @track isShowMyEditRequestSuccess=false;
  @track isShowMyRequestSuccess=false;
  @track isLoading=false;
  @track enableSpecify=false;
  @track comment='';
  TCP_RoundCheck_icon=TCP_RoundCheck_icon;

    data = data;
    columns = columns;
    connectedCallback(){
        getContacts()
            .then(result=>{
                this.ContactList =[];
                for(let key in result){
                    let dataList = [];
                    dataList.Company = result[key].Company;
                    dataList.Email = result[key].Email;
                    dataList.Id = result[key].Id;
                    dataList.Name = result[key].Name;
                    dataList.Status = result[key].Status;
                    if(result[key].DeleteReason){
                        dataList.DeleteReason = result[key].DeleteReason;
                        dataList.disableColor = 'disableIconColor';
                    }else{
                        dataList.disableColor = 'setAction';
                    }
                    this.ContactList = [...this.ContactList,dataList];
                }

            })
                .catch(error => {
                    this.error = error;
                    this.ContactList = undefined;
                    window.console.log('ERROR====>'+JSON.stringify(this.error));
                });
        }
        
        getShellContacts(data){

            getShellContacts({AccountId:data})
            .then(result=>{
                this.contacts = result.map((cls) => Object.assign({}, { label: cls.Contact_Name__c, value: cls.Id }));
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
                window.console.log('Error in updating data====>'+JSON.stringify(this.error));
            });
        
        
        }
    handleRowActions(event) {
        const actionName = event.detail.action.name;
        
        const row = event.detail.row;
        this.companyName=row.Company;
        this.contactName=row.Name;
        this.contactEmail=row.Email;
        switch (actionName) {
            case 'edit':
                this.showModalUsersEdit();
                break;
            case 'delete':
                this.showModalUsersDelete();
                break;
            default:
        }
    }
    get typeOfDeletionReason() {
        return [
            { label: 'Employee left the company', value: 'Employee Left The Company' },
            { label: 'Moved to another role', value: 'Moved To Another Role' },
            { label: 'Others', value: 'Others' },
          
        ];
    }
    handleRequest(event){
        this.requestedTo=event.target.value;
        if(this.RequestNewUser){
        if(this.firstName=='' || this.lastName=='' || this.phone=='' || this.email=='' || this.requestedTo==''){
            this.enableSubmit=false;
        }
        else{
            this.enableSubmit=true;
        }
    }
    else if(this.isShowUsersEdit){
        if(this.requestedTo=='' || this.editDetails==''){
            this.enableSubmit=false;
        }
        else{
            this.enableSubmit=true;
        }
    }
    else if(this.isShowUsersDelete){
            if(this.enableSpecify==false && (this.requestedTo=='' || this.deleteReason=='' )){
                this.enableSubmit=false;
            }
            else if(this.enableSpecify==true && (this.requestedTo=='' || this.deleteReason=='' || this.comment=='')){
                this.enableSubmit=false;
            }
            else{
                this.enableSubmit=true;
            }
        
    }
    
    }
    handleRequestChange(event){
        let enteredValue = event.target.value;
    if(event.target.dataset.id === 'firstName'){
        this.firstName = enteredValue;
    }else if(event.target.dataset.id === 'lastName'){
        this.lastName = enteredValue;
    }else if(event.target.dataset.id === 'phone'){
        this.phone = enteredValue;
    }
    else if(event.target.dataset.id === 'email'){
        this.email = enteredValue;
        
    }
    else if(event.target.dataset.id === 'additionalComment'){
        this.comment = enteredValue;
    }
    if(this.firstName=='' || this.lastName=='' || this.phone=='' || this.email=='' || this.requestedTo==''){
        this.enableSubmit=false;
    }
    else{
        this.enableSubmit=true;
    }
    }
    handleEditChange(event){
        this.editDetails = event.target.value;
        if(this.requestedTo=='' || this.editDetails==''){
            this.enableSubmit=false;
        }
        else{
            this.enableSubmit=true;
        }
    }
    handleChangeDeletion(event){
        this.deleteReason=event.target.value;
        
        if(this.requestedTo=='' || this.deleteReason==''){
            this.enableSubmit=false;
        }
        else{
            this.enableSubmit=true;
        }
        if(this.deleteReason=='Others'){
            this.enableSpecify=true;
        }
        else{
            this.enableSpecify=false;
        }
        if(this.deleteReason!='Others'){
            if(this.requestedTo=='' || this.deleteReason=='' ){
                this.enableSubmit=false;
            }
            else{
                this.enableSubmit=true;
            }
        }
        else if(this.deleteReason=='Others'){
            if(this.requestedTo=='' || this.deleteReason=='' || this.comment==''){
                this.enableSubmit=false;
            }
            else{
                this.enableSubmit=true;
            }
        } 
    }
    handleDeletion(event){
        this.comment=event.target.value;
        if(this.deleteReason!='Others'){
            if(this.requestedTo=='' || this.deleteReason=='' ){
                this.enableSubmit=false;
            }
            else{
                this.enableSubmit=true;
            }
        }
        else if(this.deleteReason=='Others'){
            if(this.requestedTo=='' || this.deleteReason=='' || this.comment==''){
                this.enableSubmit=false;
            }
            else{
                this.enableSubmit=true;
            }
        } 
    }

    handelRequestNewUser(){
        this.MyCompanyUsers = false;
        this.RequestNewUser = true;
        let data=null;
        this.getShellContacts(data);
    }
   
    handleReqSubmit(){
        if(this.doInputValidation('.requiredSet')){
        this.isLoading=true;
        getNewRequestDetails({AccountId:this.accountId,ContactId:this.requestedTo,FirstName:this.firstName,LastName:this.lastName,Email:this.email,Phone:this.phone,Comments:this.comment})
        .then(result=>{
            this.isLoading=false;
            this.RequestNewUser=false;
            this.MyCompanyUsers = true;
            this.isShowMyRequestSuccess=true;
            this.enableSubmit=false;
            this.firstName='';
            this.lastName='';
            this.phone='';
            this.email='';
            this.requestedTo='';
            this.comment='';
            this.scrollToTopOfPage();
        })
        .catch(error => {
            this.isLoading=false;
            this.error = error;
        });
        setTimeout(() => {
            this.isShowMyRequestSuccess=false;
        }, 6000);
    }
}
    handleUsersEdit(){
        
        this.isLoading=true;
        getUserEditDetails({contactEmail:this.contactEmail,companyName:this.companyName,contactName:this.contactName,requestedTo:this.requestedTo,EditDetails:this.editDetails})
        .then(result=>{
            this.isLoading=false;
            this.isShowUsersEdit=false;
            this.MyCompanyUsers = true;
            this.comment='';
            this.editDetails='';
            this.requestedTo='';
            this.isShowMyEditRequestSuccess=true;
            this.enableSubmit=false;

            this.scrollToTopOfPage();
        })
        .catch(error => {
            this.isLoading=false;
            this.error = error;
            window.console.log('Error ====>'+JSON.stringify(this.error));
        });
        setTimeout(() => {
            this.isShowMyEditRequestSuccess=false;
        }, 6000);
    }
    handleUsersDelete(){
        this.isLoading=true;
        getUserDeleteDetails({contactEmail:this.contactEmail,companyName:this.companyName,contactName:this.contactName,requestedTo:this.requestedTo,Description:this.comment,deletereason:this.deleteReason})
        .then(result=>{
            this.isLoading=false;
            this.isShowUsersDelete=false;
            this.MyCompanyUsers = true;
            this.comment='';
            this.deleteReason='';
            this.requestedTo='';
            this.enableSpecify=false;
            this.isShowMyDeleteRequestSuccess=true;
            this.enableSubmit=false;
            this.scrollToTopOfPage();
        })
        .catch(error => {
            this.isLoading=false;
            this.error = error;
            window.console.log('Error ====>'+JSON.stringify(this.error));
        });
        setTimeout(() => {
            this.isShowMyDeleteRequestSuccess=false;
            window.location.reload();
        }, 6000);
    }
    handlBack(){
        this.MyCompanyUsers = true;
        this.RequestNewUser = false;
        this.enableSubmit=false;
        this.firstName='';
            this.lastName='';
            this.phone='';
            this.email='';
            this.requestedTo='';
            this.comment='';
    }

    showModalUsersEdit(){
        this.isShowUsersEdit = true;
        let data=null;
        this.getShellContacts(data);
    }


    hideModalUsersEdit(){

        this.isShowUsersEdit = false;
        this.editDetails='';
        this.requestedTo='';
        this.enableSubmit=false;
    }

    showModalUsersDelete(){
        this.isShowUsersDelete = true;
        let data=null;
        this.getShellContacts(data);
    }

    hideModalUsersDelete(){
        
          this.deleteReason='';
          this.requestedTo='';
          this.enableSubmit=false;
          this.comment='';
          this.enableSpecify=false;
        this.isShowUsersDelete = false;
    }

    scrollToTopOfPage(){
        window.scrollTo(0,0);
    }

    doInputValidation(classname){
        const isInputsCorrect = [...this.template.querySelectorAll(classname)]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
            return isInputsCorrect;
    }

}