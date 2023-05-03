import { LightningElement, api, track, wire} from 'lwc';
import loggedInAsTcpUser from '@salesforce/apex/TCP_HomePageController.loggedInAsTcpUser';
import getAccountDetails from '@salesforce/apex/TCP_HomePageController.getAccountDetails';
import getAccountDetailsforEnduser from '@salesforce/apex/TCP_HomePageController.getAccountDataOfEndUser';
import getCommOpsContacts from '@salesforce/apex/TCP_MyShellContactsCtrl.getShellContacts';

export default class Tcp_MyShellContactsEU extends LightningElement {
@api soldtoid;
@api customeroptionscu;
@track customerOptions = [];

@track logOnAsTCP;
error;
@track accountId;
@track selectedObj;


@track records;
    @track errorMsg;   
    
     //handle results
     handleOptionChange(event) {
        this.accountId=event.detail.value;
              
    }

    @wire (getCommOpsContacts, {accId:'$accountId'})
    wireConRecord({error,data}){
      if(data){
          this.records = data;
      }else{         
        this.errorMsg = error;
        this.records = undefined;
      }
    }

  handleChangeAction(event){
    this.accountId = event.detail;
  }
    constructor(){
        super();
        loggedInAsTcpUser().then(result=>{
            this.logOnAsTCP=result;
            

        }).catch(error=>{
            this.error=error;
        });

        getAccountDetailsforEnduser().then(result=>{
          this.accountId =result.Id;
          
        }).catch(error=>{
            this.error=error;
        });
 
    }


    @wire(getAccountDetails)
    wiredAccounts({data, error}){
        this.isLoading = true;
        if(data){
            
            this.customerOptions.push({ label: '--Select--', value: ''});
            for (let key in data) {
                
                const option = {
                  label : data[key].Name,
                  value : data[key].Id,
                };
                this.customerOptions = [...this.customerOptions, option];
                
                this.selectedObj=this.customerOptions[0].value;
                
            }
           
            
        }
        else if (error) {
            this.isLoading = false;
            this.error = error; 
            window.console.log('ERROR====>'+JSON.stringify(this.error));
        }
    }

   
   
   
}