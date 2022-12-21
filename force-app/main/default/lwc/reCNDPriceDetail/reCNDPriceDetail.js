import { LightningElement, api, track } from 'lwc';
import customStyle from '@salesforce/resourceUrl/RE_CND_Detail';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReCNDPriceDetail extends LightningElement {

    @api selectedRecord;
    @api isSFJ;
    @api allowEditForDate;
    @api cpAdjustAccess;
    @api pbAdjustAccess;
    @api versionList;
    @api disableButtons;

    @track newAdjustment;
    @track newComment;
    @track newFinalValue;
    @track isAdjusted = false;
    @track isCommented = false;

    @track adjustError=false;
    @track commentError=false;

    @track showDetails = true;
    @track showHistory = true;


    connectedCallback() {
        try {
            Promise.all([
            loadStyle(this, customStyle)
        ])
        }
        catch (error) {
            console.log(error.message);
        }
    }

    @api
    resetparams() {
        console.log('Redended calll===')
            this.adjustError=false;
            this.commentError=false;
            this.newAdjustment='';
            this.newComment=''
            console.log('value--'+this.template.querySelector('lightning-input').value);
            this.template.querySelector('lightning-input').value=this.selectedRecord.Adjustment; 
            this.template.querySelector('lightning-textarea').value=this.selectedRecord.Comment; 
    }

    closeDetail() {
        try {
            const selectedEvent = new CustomEvent("closedetail", {
                detail: false
            });
            this.dispatchEvent(selectedEvent);
        }
        catch (error) {
            console.log(error.message);
        }
    }

    handleAdjustment(event) {
        try {
            console.log('New value--' + event.target.value);
            
            this.newAdjustment=event.target.value;
            this.isAdjusted=true;
            console.log('isAdusted--true');
            
        }
        catch (error) {
            console.log(error.message);
        }
    }


    handleCommentChange(event) {
        try {
            console.log('New value--' + event.target.value);
            this.newComment = event.target.value;
            this.isCommented=true;
        }
        catch (error) {
            console.log(error.message);
        }
    }

    showWarningToast(messageToShow) {
        const evt = new ShowToastEvent({
            title: 'Warning',
            message: messageToShow,
            variant: 'info',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    handlesave() {
        try {
            console.log('handle save called--');
            if (this.isAdjusted && this.newAdjustment!='' && this.newAdjustment!=undefined &&
                this.isCommented && this.newComment!='' && this.newComment!=undefined)
                    {
                        this.adjustError=false;
                        this.commentError=false;

                        console.log('Adjustmet made--');
                        const selectedEvent = new CustomEvent('changeadjustment', {
                            detail: { Adjustment: this.newAdjustment, Comment: this.newComment }
                        });
                        this.dispatchEvent(selectedEvent);
                     }
            else if(this.isAdjusted)
             {
                    if(this.newAdjustment=='' || this.newAdjustment==undefined)
                    {
                        this.adjustError=true;
                        console.log('Ad error true');
                    }
                    else{
                        this.adjustError=false;
                        console.log('Ad error false');
                    }
                    
                    if(this.isCommented)
                    {
                        if(this.newComment=='' || this.newComment==undefined)
                        {
                            this.commentError=true;
                        }
                        else
                        this.commentError=false;
                    }
                    else
                    {
                        this.commentError=true;
                    }
                }
            else{
                console.log('Else part--');
                this.showWarningToast('No Adjustment Made!!!');
            }
            
        }
        catch (error) {
            console.log(error.message);
        }
    }


}