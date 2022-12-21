/**
 * Created by Dharmendra.Singh2 on 8/30/2021.
 */

 import { LightningElement, track, api, wire } from 'lwc';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import { updateRecord } from 'lightning/uiRecordApi';
 import { refreshApex } from '@salesforce/apex';
 import getNotesList from '@salesforce/apex/rv_customerInfoController.getNotes1';
 import update_Note from '@salesforce/apex/rv_customerInfoController.updateNotes';
 import saveNote from '@salesforce/apex/rv_customerInfoController.createNote';
 import TITLE_NOTE from '@salesforce/schema/Note.Title';
 import ID_FIELD from '@salesforce/schema/Note.Id';
 import NOTE_OBJECT from '@salesforce/schema/Note';
 import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
 import {subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
 import refreshDataChannel from '@salesforce/messageChannel/Rv_DiPublishSearchFilter__c';
 
 const notefields = [ID_FIELD, TITLE_NOTE];
 
 export default class RvCustomerNotes extends LightningElement {
     disabled = false;
     noteObject = NOTE_OBJECT;
     @track error;
     @api recordId;
     notes;
     noteToDelete;
     noteId;
     error;
     enablenotebox = false;
     noteTitle = TITLE_NOTE;
     noteBody;
     wiredNotes;
	@track notesData;				  
    @track isDisableSave = false;
    @track isDisableDelete = false;
     @api mrcHeader;
     @track accountLinked = false;			   
 
                             
     handleNoteInput(event) {
              this.noteBody = event.detail.value;
          }
 
     handleNoteSave(event){
         this.noteBody = this.noteBody != undefined ? (this.noteBody).trim(): this.noteBody;
         this.noteTitle = event.target.title;
         if(this.noteTitle == 'clear'){
             this.noteBody = '';
         }else if(this.noteBody == '' || this.noteBody == undefined){
             const event = new ShowToastEvent({
                 title : 'Error',
                 message : 'Please provide notes to save',
                 variant : 'error'
             });
             this.dispatchEvent(event);
         }else{	
             this.isDisableSave = true;					
             let recId;
             if(this.recordId == ""){
                 recId = this.mrcHeader;
             }else{
                 recId = this.recordId;
             }
         saveNote({
             noteBody    : this.noteBody,
             accountId   : recId,
             noteTitle   : this.noteTitle
         })
         .then(result => {
                 console.log('result in notes::'+JSON.stringify(result));
             if(this.recordId == "" || this.recordId == undefined ){
                 this.recordId = result[0].ParentId;
             }
             console.log('recordId::'+this.recordId);
             const event = new ShowToastEvent({
                          title: 'Note created',
                          message: 'New Note created.',
                          variant: 'success'
                      });
                      this.isDisableSave = false;
                      this.noteBody = '';
                      this.dispatchEvent(event);
                      this.enablenotebox  = !this.enablenotebox;
                      refreshApex(this.wiredNotes);
                  })
                  .catch(error => {
                      const event = new ShowToastEvent({
                          title : 'Error',
                          message : 'Error creating Note. Please Contact System Admin',
                          variant : 'error'
                      });
                      this.dispatchEvent(event);
                  });
         }
     }
 
     @wire(getNotesList, {accountId: '$recordId',mrcId:'$mrcHeader'})
         notesList(result){
             this.wiredNotes = result;
             console.log('Get Notes::'+JSON.stringify(result));							 
             if(result.data){
                 this.notes = result.data;
                 this.error = undefined;
             }else if(result.error){
                 this.error = result.error;
                 this.data = undefined;
				this.notesData='No data is available';
                 this.accountLinked = false;
             }
         }
 
     displayNoteBox() {
                 this.enablenotebox  = !this.enablenotebox;
             }
     
     removeDisplayNoteBox(){
         this.enablenotebox = '';
     }
     updateNote(event) {
          // Display field-level errors and disable button if a name field is empty.
 
                         this.noteToDelete = event.target.value;
 
         const allValid = true;
 
         if (allValid) {
             this.isDisableDelete = true;
             // Create the recordInput object
            /* this.noteId = this.noteToDelete.Id;
             this.noteTitle = this.noteToDelete.Title;
             const fields = {};
             fields[ID_FIELD.fieldApiName] = this.noteToDelete.Id;
             fields[TITLE_NOTE.fieldApiName] = this.noteTitle + ' ' +'Deleted';
             const recordInput = { fields };
 
             updateRecord(recordInput)
                 .then(() => {
 
                     // Display fresh data in the form
                      refreshApex(this.wiredNotes);
                     //show a toast message on the screen!
                     this.dispatchEvent(
                         new ShowToastEvent({
                             title: 'Success',
                             message: 'Note deleted',
                             variant: 'success'
                         })
                     );
                 })
                 .catch(error => {
                     this.dispatchEvent(
                         new ShowToastEvent({
                             title: 'Error deleting record',
                             message: error.body.message,
                             variant: 'error'
                         })
                     );
                 });*/
                                                     
                 update_Note({
                     noteId    : this.noteToDelete.Id
                 })
                 .then(result => {
                              const event = new ShowToastEvent({
                                 title: 'Success',
                                 message: 'Note deleted',
                                 variant: 'success'
                              });
                              
                              this.dispatchEvent(event);
                              this.isDisableDelete = false;
                              refreshApex(this.wiredNotes);
                          })
                          .catch(error => {
                              console.log('Error in Notes Update::'+JSON.stringify(error));
                              const event = new ShowToastEvent({
                                  title : 'Error',
                                  message : 'Error updating Note. Please Contact System Admin',
                                  variant : 'error'
                              });
                              this.dispatchEvent(event);
                          });
             }
         else {
             // The form is not valid
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Something is wrong',
                     message: 'Check your input and try again.',
                     variant: 'error'
                 })
              );
         }
     }
     subscription = null;
             @wire(MessageContext)
                 messageContext;
 
                 connectedCallback(){
                     this.subscribeToMessageChannel();
                 }
 
                 disconnectedCallback(){
                     this.unsubscribeToMessageChannel();
                 }
 
                 subscribeToMessageChannel(){
                         if(!this.subscription){
                             this.subscription = subscribe(
                                 this.messageContext,
                                 refreshDataChannel,
                                 (message) => this.recieveData(message),
                                 {
                                     scope: APPLICATION_SCOPE
                                 }
                             );
                         }
                     }
 
                 unsubscribeToMessageChannel(){
                         unsubscribe(this.subscription);
                         this.subscription = null;
                     }
 
                 recieveData(message){
                         if(message.eventType === 'publish'){                               //'search' for search MRC and 'publish' for custom info section
                                    this.recordId = message.customerId;
                                    this.mrcHeader = message.mrcId;																												
                                  console.log('Record Id from channel :'+this.recordId+'--'+this.mrcHeader);
                                refreshApex(this.wiredCustomerData);
                            }
                            /* prod deployment */
                         else if(message.eventType == 'deSelectedCustomer'){
                                this.recordId = message.customerId;
                                this.mrcHeader = message.mrcId;
                                console.log('Record Id from channel :' + this.recordId);
                                refreshApex(this.wiredCustomerData);
                                this.accountLinked = false;
                                
                            }
                          if( message.eventType != 'deSelectedCustomer' && (this.recordId != null || this.recordId != undefined ||
                                                 this.mrcHeader != null || this.mrcHeader != undefined)){
                                                     this.accountLinked = true;
                                                 }						  
                                                  
 
                      
 
                     }
 }