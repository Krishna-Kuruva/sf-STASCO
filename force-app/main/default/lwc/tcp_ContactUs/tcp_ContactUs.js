import { LightningElement, track, wire } from 'lwc';

import TCPRoundCheckicon from '@salesforce/resourceUrl/TCP_RoundCheck_icon';
import getContacts from '@salesforce/apex/TCP_MyCompanyUsersController.getShellContacts';
import getNewRequestDetails from '@salesforce/apex/TCP_MyCompanyUsersController.getNewRequestDetails';
import getComplaintDetails from '@salesforce/apex/TCP_MyCompanyUsersController.getComplaintDetails';
import getCommentDetails from '@salesforce/apex/TCP_MyCompanyUsersController.getCommentDetails';
import getEnquiryDetails from '@salesforce/apex/TCP_MyCompanyUsersController.getEnquiryDetails';
import loggedInAsTcpUser from '@salesforce/apex/TCP_HomePageController.loggedInAsTcpUser';
import getAccountDetails from '@salesforce/apex/TCP_HomePageController.getAccountDetails';

export default class TCPContactUs extends LightningElement {

    TCPRoundCheckicon = TCPRoundCheckicon;
    @track convalue;
    @track showError;
    @track typeOffeedbackValue;
    @track logOnAsTCP;
    @track contactUs = true;
    @track accountData = [];
    @track requestNewUser = false;
    @track complaint = false;
    @track comment = false;
    @track inquiry = true;
    @track successToast = false;
    @track value;
    @track accId='';
    @track custName;
    @track customerOptions = [];
    error;
    @track options;
    @track contacts;
    @track contactList = [];
    @track accContacts;
    @track parentaccid;
    prefix;
    @track contactValue;
    @track feedbackType = '';
    @track firstName = '';
    @track lastName = '';
    @track phone = '';
    @track email = '';
    @track shellRefNumber = '';
    @track customerPo = '';
    @track description = '';
    @track product = '';
    @track conId = '';
    @track commpos;
    @track successInquiry = false;
    @track successComment = false;
    @track successComplaint = false;
    @track successNewRequest = false;
    @track enableSubmit = false;
    @track isLoading = false;


    @wire(getAccountDetails)
    wiredAccounts({ data, error }) {

        if (data) {
            for (const key in data) {
                this.accountData = data;
                const option = {
                    label: data[key].Name,
                    value: data[key].Id
                };
                this.customerOptions = [...this.customerOptions, option];
                
            }
            if(!this.commpos){
            if (this.accountData.length === 1) {
                this.value = this.customerOptions[0].value;
                this.custName = this.customerOptions[0].label;
                this.accId = this.customerOptions[0].value;
                if (this.commpos === false) {
                    this.fetchContacts(this.accId);
                }
            }
        }

            this.error = null;
        }
        else if (error) {
            this.isLoading = false;
            this.error = error;
            window.console.log('ERROR====>' + JSON.stringify(this.error));
        }
    }

    connectedCallback() {

        loggedInAsTcpUser().then(result => {
            this.logOnAsTCP = result;
            if (this.logOnAsTCP) {
                this.commpos = true;
            }
            else {
                this.commpos = false;
                if (this.parentaccid !== null) {
                    const data = this.parentaccid;
                    this.fetchContacts(data);
                }
            }
            
            this.error = null;
        })
            .catch(error => {
                this.error = error;
                this.name = null;
                window.console.log('ERROR====>' + JSON.stringify(this.error));
            });

    }

    handleAccountChange(event) {
        this.accId = event.target.value;
        this.value=event.target.value;
        const data = event.target.value;
        this.fetchContacts(data);
    }

    fetchContacts(data) {
        getContacts({ accountId: this.accId })
            .then(result => {
                this.contacts = result.map((cls) => Object.assign({}, { label: cls.Contact_Name__c, value: cls.Id }));
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
                window.console.log('Error in updating data====>' + JSON.stringify(this.error));
            });


    }


    get typeOffeedbackOptions() {
        return [
            { label: 'Request New User', value: 'RequestNewUser' },
            { label: 'Comment', value: 'Comment' },
            { label: 'Complaint', value: 'Complaint' },
            { label: 'Inquiry', value: 'Inquiry' },
        ];
    }

    handletypeOffeedbackChange(event) {
        
        const value = event.detail.value;
        this.feedbackType = event.detail.value;
        this.typeOffeedbackValue = event.detail.value;
        if (value === 'RequestNewUser') {

            this.complaint = false;
            this.comment = false;
            this.requestNewUser = true;
            this.inquiry = false;
            this.enableSubmit = false;
        }
        else if (value === 'Comment') {
            this.complaint = false;
            this.comment = true;
            this.requestNewUser = false;
            this.inquiry = false;
            this.description = '';
            if (this.conId === '' || this.description === '') {
                this.enableSubmit = false;
            }
            else {
                this.enableSubmit = true;
            }

        }
        else if (value === 'Complaint') {
            this.complaint = true;
            this.comment = false;
            this.requestNewUser = false;
            this.inquiry = false;
            this.enableSubmit = false;

        }
        else if (value === 'Inquiry') {
            this.complaint = false;
            this.comment = false;
            this.requestNewUser = false;
            this.inquiry = true;
            this.description = '';
            if (this.conId === '' || this.description === '') {
                this.enableSubmit = false;
            }
            else {
                this.enableSubmit = true;
            }
        }
        else {
            this.complaint = false;
            this.comment = false;
            this.requestNewUser = false;
            this.inquiry = false;

        }

    }
    handleshellContactChange(event) {

        this.convalue = event.detail.value;
        this.conId = this.convalue;
        if (this.requestNewUser) {
            if (this.firstName === '' || this.lastName === '' || this.phone === '' || this.email === '' || this.feedbackType === '' || this.conId === '') {
                this.enableSubmit = false;
            }
            else {
                this.enableSubmit = true;
            }
        }
        if (this.complaint) {
            if (this.shellRefNuber === '' || this.customerpo === '' || this.product === '' || this.feedbackType === '' || this.conId === '') {
                this.enableSubmit = false;
            }
            else {
                this.enableSubmit = true;
            }
        }
      

        if(this.comment === true || this.enquiry === true){
            this.enableSubmit=this.feedbackType === '' || this.conId === '' || this.description === '' ? true : false;
            console.log('Enable submit:--:'+this.enableSubmit);
        }

    }
    handleNewUserDetailsChange(event) {
        const enteredValue = event.target.value;
        if (event.target.dataset.id === 'firstName') {
            this.firstName = enteredValue;
        } else if (event.target.dataset.id === 'lastName') {
            this.lastName = enteredValue;
        } else if (event.target.dataset.id === 'phone') {
            this.phone = enteredValue;
        }
        else if (event.target.dataset.id === 'email') {
            this.email = enteredValue;

        }
        else if (event.target.dataset.id === 'description') {
            this.description = enteredValue;

        }
        if (this.firstName === '' || this.lastName === '' || this.phone === '' || this.email === '' || this.feedbackType === '' || this.conId === '') {
            this.enableSubmit = false;
        }
        else {
            this.enableSubmit = true;
        }
    }
    handleComplaintDetailsChange(event) {
        const enteredValue = event.target.value;
        if (event.target.dataset.id === 'shellRefNuber') {
            this.shellRefNuber = enteredValue;
        } else if (event.target.dataset.id === 'customerpo') {
            this.customerpo = enteredValue;
        } else if (event.target.dataset.id === 'product') {
            this.product = enteredValue;
        }
        else if (event.target.dataset.id === 'description') {
            this.description = enteredValue;

        }
        if (this.shellRefNuber === '' || this.customerpo === '' || this.product === '' || this.feedbackType === '' || this.conId === '') {
            this.enableSubmit = false;
        }
        else {
            this.enableSubmit = true;
        }
    }
    handleCommentChange(event) {
        const enteredValue = event.target.value;
        if (event.target.dataset.id === 'description') {
            this.description = enteredValue;

        }
        if (this.feedbackType === '' || this.conId === '' || this.description === '') {
            this.enableSubmit = false;
        }
        else {
            this.enableSubmit = true;
        }
    }
    handleInquiryChange(event) {
        const enteredValue = event.target.value;
        if (event.target.dataset.id === 'comment') {
            this.description = enteredValue;

        }
        if (this.feedbackType === '' || this.conId === '' || this.description === '') {
            this.enableSubmit = false;
        }
        else {
            this.enableSubmit = true;
        }
    }
    handleSubmit() {
        const CONTACT_VALUE='lightning-input[data-formfield';
        if (this.feedbackType === 'RequestNewUser') {
            if (this.doInputValidation('.valid')) {
                this.isLoading = true;
                getNewRequestDetails({ accountId: this.accId, contactId: this.conId, firstName: this.firstName, lastName: this.lastName, email: this.email, phone: this.phone, comments: this.description })
                    .then(result => {
                        this.isLoading = false;
                        this.requestNewUser = false;
                        this.inquiry = true;
                        this.enableSubmit = false;
                        this.contactUs = true;
                        this.template.querySelectorAll(CONTACT_VALUE+'="contactValue"]').forEach(element => {
                            element.value = null;
                        });
                        this.convalue = [];
                        this.template.querySelectorAll(CONTACT_VALUE+'="typeValue"]').forEach(element => {
                            element.value = null;
                        });
                        this.typeOffeedbackValue = [];
                        if(this.commpos){
                            this.template.querySelectorAll(CONTACT_VALUE+'="custValue"]').forEach(element => {
                                element.value = null;
                            });
                        this.value=[];
                            this.value='';
                            this.contacts=[];
                            this.contacts='';
                        }
                        this.firstName = '';
                        this.lastName = '';
                        this.email = '';
                        this.phone = '';
                        this.description = '';
                        this.conId = '';
                        this.feedbackType = '';
                        this.successNewRequest = true;
                        this.scrollToTopOfPage();


                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.error = error;
                    });
                setTimeout(() => {
                    this.successNewRequest = false;
                }, 6000);
            }


        }
        else if (this.feedbackType === 'Comment') {
            this.isLoading = true;
            getCommentDetails({ accountId: this.accId, contactId: this.conId, description: this.description })
                .then(result => {
                    this.isLoading = false;
                    this.contactUs = true;
                    this.template.querySelectorAll(CONTACT_VALUE+'="contactValue"]').forEach(element => {
                        element.value = null;
                    });
                    this.convalue = [];
                    this.template.querySelectorAll(CONTACT_VALUE+'="typeValue"]').forEach(element => {
                        element.value = null;
                    });
                    this.typeOffeedbackValue = [];
                    if(this.commpos){
                        this.template.querySelectorAll(CONTACT_VALUE+'="custValue"]').forEach(element => {
                            element.value = null;
                        });
                    this.value=[];
                        this.value='';
                        this.contacts=[];
                        this.contacts='';
                    }
                    this.conId = '';
                    this.comment = false;
                    this.description = '';
                    this.feedbackType = '';
                    this.inquiry = true;
                    this.enableSubmit = false;
                    this.successComment = true;
                    this.scrollToTopOfPage();
                })
                .catch(error => {
                    this.isLoading = false;
                    this.error = error;
                    window.console.log('Error ====>' + JSON.stringify(this.error));
                });
            setTimeout(() => {
                this.successComment = false;
            }, 6000);
        }
        else if (this.feedbackType === 'Complaint') {
            if (this.doInputValidation('.valid')) {
                this.isLoading = true;
                getComplaintDetails({ accountId: this.accId, contactId: this.conId, description: this.description, shellRefNumber: this.shellRefNuber, customerPO: this.customerpo, product: this.product })
                    .then(result => {
                        this.isLoading = false;
                        this.contactUs = true;
                        this.template.querySelectorAll('lightning-input[data-formfield="contactValue"]').forEach(element => {
                            element.value = null;
                        });
                        this.convalue = [];
                        this.template.querySelectorAll('lightning-input[data-formfield="typeValue"]').forEach(element => {
                            element.value = null;
                        });
                        this.typeOffeedbackValue = [];
                        if(this.commpos){
                            this.template.querySelectorAll('lightning-input[data-formfield="custValue"]').forEach(element => {
                                element.value = null;
                            });
                        this.value=[];
                            this.value='';
                            this.contacts=[];
                            this.contacts='';
                        }
                        this.complaint = false;
                        this.inquiry = true;
                        this.enableSubmit = false;
                        this.shellRefNumber = '';
                        this.customerpo = '';
                        this.description = '';
                        this.product = '';
                        this.feedbackType = '';
                        this.conId = '';
                        this.successComplaint = true;
                        this.scrollToTopOfPage();
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.error = error;
                        window.console.log('Error ====>' + JSON.stringify(this.error));
                    });
                setTimeout(() => {
                    this.successComplaint = false;
                }, 6000);
            }

        }
        else if (this.feedbackType === 'Inquiry') {
            this.isLoading = true;
            getEnquiryDetails({ accountId: this.accId, contactId: this.conId, description: this.description })
                .then(result => {
                    this.isLoading = false;
                    this.contactUs = true;
                    this.template.querySelectorAll('lightning-input[data-formfield="contactValue"]').forEach(element => {
                        element.value = null;
                    });
                    this.convalue = [];
                    this.template.querySelectorAll('lightning-input[data-formfield="typeValue"]').forEach(element => {
                        element.value = null;
                    });
                    this.typeOffeedbackValue = [];
                    if(this.commpos){
                        this.template.querySelectorAll('lightning-input[data-formfield="custValue"]').forEach(element => {
                            element.value = null;
                        });
                    this.value=[];
                        this.value='';
                        this.contacts=[];
                        this.contacts='';
                    }
                    this.conId = '';
                    this.comment = true;
                    this.description = '';
                    this.feedbackType = '';
                    this.inquiry = false;
                    this.enableSubmit = false;
                    this.successInquiry = true;
                    this.scrollToTopOfPage();

                })
                .catch(error => {
                    this.isLoading = false;
                    this.error = error;
                });
            setTimeout(() => {
                this.successInquiry = false;
            }, 6000);
        }

    }
    scrollToTopOfPage() {
        window.scrollTo(0, 0);
    }
    doInputValidation(classname) {
       return [...this.template.querySelectorAll(classname)]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
       

    }

    renderedCallback() {
        if (this.enableSubmit && this.feedbackType === 'RequestNewUser') {
            if (this.convalue && this.typeOffeedbackValue) {
                this.convalue = this.conId;
                this.typeOffeedbackValue = this.feedbackType;
            }
        }
    }
}