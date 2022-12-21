import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import revokeApproval from '@salesforce/apex/BetRevokeApprovalForBetFormLwcController.revokeApproval';
export default class BetRevokeApprovalForBetForm extends LightningElement {
    @api recordId;
    @track isConfirmDialogVisible = false;
    @api invoke(){
        this.isConfirmDialogVisible= true;
    }

    showToast(title, message, variant ){
        this.dispatchEvent(
            new showToastEvent({title, message, variant})
        )
    }

    handleconfirmModalButtonclick(event){

        if(event.detail !== 1){
            
            //you can do some custom logic here based on your scenario
            if(event.detail.status === 'confirm') {
                //do something
                console.log('Inside handleconfirmModalButtonclick status eqauls confirm');
                this.revokeApproval();
                
            }else if(event.detail.status === 'cancel'){
                //do something else
            }
        }
        //hides the component
        this.isConfirmDialogVisible = false;
    }

    revokeApproval(){

        revokeApproval({ recordId: this.recordId })
            .then((result) => {
                const eventsc = new ShowToastEvent({
                    title: result.title,
                    message: result.message,
                    variant: result.variant,
                    mode: 'dismissable'
                });
                this.dispatchEvent(eventsc);
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch((error) => {
                const eventerror = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(eventerror);
            });
    }
}