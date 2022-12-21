import { LightningElement, track, wire, api } from 'lwc';
import {APPLICATION_SCOPE,publish,subscribe, unsubscribe, MessageContext} from 'lightning/messageService';
import advancedFilterChannel from '@salesforce/messageChannel/Rv_DiPublishAdvanceFilter__c';
import getUserListNames from '@salesforce/apex/RV_TermTriggerClass.getUserList';
import advancedFilterValueChannel from '@salesforce/messageChannel/Rv_DiPublishAdvanceFilterVales__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Rv_useadvancefilter extends LightningElement {
    subscription = null;
    @track useAdvancedFilter;
     createdOn;// ='TODAY';
    //@track createdOnOptions;
   // @track statusOptions;
     advStatus ;//='COMPLETED';
     internetSales;
     sAdvanceFilter;
     startDte;
     endDte;
     advcreatedBy;
    @track createdByOptions ;
     advSoldTo = 'ALL';
     
    @api soldToOptions ;//= 'ALL';
     advShtNo = 'ALL';
    @api shtNoOptions;
     advpoType = 'ALL';
    @api poTypeOptions;
    sAdvanceFilter;


//start
    @api allList = []; //receive the full list from calling component
    @api placeHolder = 'Search...'; // Display place holder Text in the input box
    @api labelName = ''; //Label the Component

    //contains list to be displayed 
    @track displayList = [];

    //contains the selected list  
    @api selectedList = [];

    //search letters input by the user
    @track searchInput = '';

    //toggle between the list opened and Closed, default is false
    @track listOpened = false;

    //style of the div
    @track comboClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
   


    SearchClick() {
        
        if (!this.listOpened) {

           this.listOpened = true;
           this.comboClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open'; 

            this.displayList = []; //initialize the array before assigning values coming from apex
            console.log('allList::'+JSON.stringify(this.soldToOptions));
            this.soldToOptions.map(allListElement => {
                
                if (allListElement.selected) {
                    
                    //Add item to selectedList of not already present 
                    if (this.selectedList.find(element => element.value == allListElement.value) == null) {
                        this.selectedList = [
                            ...this.selectedList,
                            {
                                label: allListElement.label,
                                value: allListElement.value,
                                selected: allListElement.selected
                            }
                        ]
                    }
                }
                
                //Add item to displayList of not already present 
                this.displayList = [
                    ...this.displayList,
                    {
                        label: allListElement.label,
                        value: allListElement.value,
                        selected: (this.selectedList.find(element => element.value == allListElement.value) != null) 
                    }
                ];

            });
        }
        else if (this.listOpened)
        {
            this.searchInput = ''; //clearing the text
            this.listOpened = false;
            this.comboClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
           
            //Pulishing Selected items through Event After closeing the dropdown list

            this.publishEvent();
        }
    }

    //filter the display options based on user's search input
    ChangeSearchInput(event) {
        
       
       this.listOpened = true;
       this.comboClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open'; 


        this.searchInput = event.target.value.toLowerCase();
        
        this.displayList = []; //initialize the array before assigning values coming from apex
        
        //filter the global list and repolulating the display options
        let filterList = this.allList.filter(
            item => item.value.toLowerCase().includes(this.searchInput.trim()) == true
        );
             
        filterList.map(allListElement => {
            this.displayList = [
                ...this.displayList,
                {
                    label: allListElement.label,
                    value: allListElement.value,
                    selected: this.selectedList.find(element => element.value == allListElement.value) != null
                }
            ];

            
        });
    }

    //handle check box changes to re-evaluate the display option and selected list
    handleCheckboxChange(e) {


        if (e.detail.checked) {

            if (this.selectedList.find(element => element.value == e.target.value) == null) {
                this.selectedList = [
                    ...this.selectedList,
                    {
                        label: e.target.label,
                        value: e.target.value,
                        selected: e.detail.checked
                    }
                ]
            }
        } else // unchecked 
        {
            this.selectedList = this.selectedList.filter(
                item => item.value != e.target.value
            );
        }

        this.displayList.map(element => {

            if (element.value == e.target.value) {

                element.selected = e.detail.checked;

            }

        });

    }
    //Publishning the selected list
    publishEvent()
    {
        // Creates the event with selected items.
        const selectedEvent = new CustomEvent('selected', { detail: this.selectedList });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    //end
    /*handleChange(event){
        if(event.target.name='useAdvancedFilter'){
            this.sAdvanceFilter = event.target.checked;
        }
        
        if(event.target.name='createdOn'){
            this.createdOn = event.detail.value;
        }
        if(event.target.name='status'){
            this.advStatus = event.detail.value;
        }
        console.log('createdOn:'+this.createdOn);
        console.log('advstatus:'+this.advStatus);
       // this.publishCustomerId();
    }*/
    connectedCallback(){
        this.createdOn = 'TODAY';
        this.startDte = new Date().toISOString().slice(0, 10);
        this.endDte = new Date().toISOString().slice(0, 10);
        this.advStatus = 'Completed';
        this.advcreatedBy = 'ME';
        //this.publishCustomerId();
        this.subscribeToMessageChannel();
        this.soldToOptions = [{ label: 'ALL', value: 'ALL'}];
        this.shtNoOptions = [{ label: 'ALL', value: 'ALL'}];
        this.poTypeOptions = [{label:'ALL', value:'ALL'}];
    }

    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }
    subscribeToMessageChannel(){
        //console.log('Subscribe::'+JSON.stringify(message));
        if(!this.subscription){
            this.subscription = subscribe(
            this.messageContext,
            advancedFilterValueChannel,
                (message) => this.recieveData(message),
                 { scope: APPLICATION_SCOPE }
                );
        }
        this.advSoldTo = this.advSoldTo;
        this.advShtNo = this.advShtNo;
        this.advpoType = this.advpoType;
    }

    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;

    }
    
    handleChange(event){
        if(event.target.name == 'useAdvancedFilter'){
            this.sAdvanceFilter = event.target.checked;
            this.startDte = new Date().toISOString().slice(0, 10);
            this.endDte = new Date().toISOString().slice(0, 10);
        }  
        if(event.target.name == 'createdOn')  
            this.createdOn = event.target.value;
        if(event.target.name == 'status')
            this.advStatus = event.target.value;
        if(event.target.name == 'endDate')  
            this.endDte = event.target.value;
        if(event.target.name == 'startDate')  
            this.startDte = event.target.value;
        if(event.target.name == 'createdBy')  
            this.advcreatedBy = event.target.value;
        
        if(event.target.name == 'soldTo' || event.target.label == 'soldTo')  {
            console.log('Selected solto::'+event.target.value);
            this.advSoldTo = event.target.value;
            
        }
        if(event.target.name == 'internetSales')
            this.internetSales = event.target.checked;
        if(event.target.name == 'shtNo')  
            this.advShtNo = event.target.value;
        if(event.target.name == 'poType')  
            this.advpoType = event.target.value;
            console.log('createdOn:'+this.sAdvanceFilter+'-'+this.createdOn);
            console.log('advstatus:'+this.advStatus+'--'+this.advpoType);
            console.log('startDate:'+this.startDte);
            console.log('endDate:'+this.endDte);

        let daysDiff = this.findDaysDifference();
        //let dateComp = this.datesComparision();
        console.log('date comparision::'+Date.parse(this.startDte) < Date.parse(this.endDte));
        if ((Date.parse(this.startDte) > Date.parse(this.endDte))) {
            //alert("End date should be greater than Start date");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'End date should be greater than Start date',
                    variant: 'error',
                }),
            );
        }
        else if(daysDiff >5){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Created Date range must be 5 days',
                    variant: 'error',
                }),
            );
            //alert('Created Date range must be 5 days');
        }/*else if(dateComp != ''){
            alert(dateComp);
        }*/else{
            this.evtName='change';
            var chnageevnt = event.detail;
            console.log('chnageevnt::'+JSON.stringify(chnageevnt));
            for (var key in (this.soldToOptions)) 
            {
                if ((this.soldToOptions)[key].value == chnageevnt.value && this.advadvSoldToShtNo != chnageevnt.value) {
                    console.log('***Yes i am in advSoldTo if');
                    this.advSoldTo =chnageevnt.value;
                    
                }
            }
            console.log('event soldTO::'+this.advSoldTo);

            console.log('chnageevnt::'+JSON.stringify(chnageevnt));
            for (var key in (this.shtNoOptions)) 
            {
                if ((this.shtNoOptions)[key].value == chnageevnt.value && this.advShtNo != chnageevnt.value) {
                    console.log('***Yes i am in advShtNo if');
                    this.advShtNo =chnageevnt.value;
                }
            }
            console.log('event advShtNo::'+this.advShtNo);

            console.log('chnageevnt::'+JSON.stringify(chnageevnt));
            for (var key in (this.createdByOptions)) 
            {
                if ((this.createdByOptions)[key].value == chnageevnt.value) {
                    console.log('***Yes i am in advcreatedBy if');
                    this.advcreatedBy =chnageevnt.value;
                }
            }
            console.log('event advcreatedBy::'+this.advcreatedBy);
            this.publishCustomerId();
        }
    }

    datesComparision(startDte,endDte){
        const startDate1 = new Date(this.startDte);
        const EndDate1 = new Date(this.endDte);
        if(Date.parse(EndDate1) <= Date.parse(startDate1)){
            return 'Start date should be less than end date';
        }else{
            return '';
        }
        
    }
    findDaysDifference(){
        const startDate1 = new Date(this.startDte);
        const EndDate1 = new Date(this.endDte);
        const diffTime = Math.abs(EndDate1 - startDate1);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 
        console.log(diffDays + " days");

        return diffDays;
    }
    get createdOnOptions() {
        return [
            { label: 'TODAY', value: 'TODAY'},
            { label: 'LAST DEAL DATE', value: 'LAST_DEAL_DATE' },
            { label: 'THIS WEEK', value: 'THIS_WEEK' },
            { label: 'LAST WEEK', value: 'LAST_WEEK' },
            { label: 'LAST 3 WEEKS', value: 'LAST_3_WEEKS' }
        ];
    }
    get statusOptions() {
        return [
            { label: 'COMPLETED', value: 'Completed'},
            { label: 'CANCELLED', value: 'Cancelled' },
            { label: 'EXPIRED', value: 'Expired' }
        ];
    }

   /* get shtNoOptions() {
        return [
            { label: 'ALL', value: 'ALL',selected: "true"}            
        ];
    }

    get soldToOptions() {
        return [
            { label: 'ALL', value: 'ALL',selected: "true"}            
        ];
    }

    get poTypeOptions(){
        return[
            {label:'ALL', value:'ALL', selected:"true"}
        ];
    }*/


    @wire(MessageContext)
    messageContext;
    
    publishCustomerId(){
        let payload = '';
        if(!this.sAdvanceFilter){
                payload = {
                                eventType: 'filter',
                                createdOn: this.createdOn,
                                advStatus:this.advStatus
                            };
        }
        if(this.sAdvanceFilter){
            console.log('new payload::');
            payload = {
                eventType: 'filter',
                endDte:this.endDte,
                dayInterval:5,
                advStatus:this.advStatus,
                advcreatedBy:this.advcreatedBy,//'005250000089QVEAA2',//advcreatedBy
                advSoldTo:this.advSoldTo,
                advShtNo:this.advShtNo,
                internetSales:this.internetSales,
                advpoType:this.advpoType,
                startDte:this.startDte,
                sAdvanceFilter:this.sAdvanceFilter
            };
            console.log('payload::'+JSON.stringify(payload));
        }
        publish(
            this.messageContext, 
            advancedFilterChannel,
            payload
        );
    }
    @wire(getUserListNames)
    wiredUserNames({ error, data }) {
        console.log('get user record**'+JSON.stringify(data));
       // console.log('user count::'+data);
        if (data) {
            var usersLst=[];
            for (var key in data) 
            {
                if (data.hasOwnProperty(key)) {
                    usersLst.push({value: key, label: data[key]});
                }
            }
            this.createdByOptions = usersLst;                                  
        } else if (error) {
            this.error = error;
            this.createdByOptions = undefined;
        }
        console.log('createdByOptions::'+JSON.stringify(this.createdByOptions));
    }
    
    recieveData(message){
        this.soldToOptions = [
            { label: 'ALL', value: 'ALL'}            
        ];
        //let soldToOptionslst =  [];// message.soldToOptions;
        console.log('sold to options::'+JSON.stringify(message.soldToOptions));
        for (var key in message.soldToOptions) 
            {
                console.log('Inside of::'+key+'--'+message.soldToOptions);
                if ((message.soldToOptions).hasOwnProperty(key)) {
                    this.soldToOptions.push({value: message.soldToOptions[key], label: message.soldToOptions[key]});
                    //soldToOptionslst.push({value: message.soldToOptions[key], label: message.soldToOptions[key]});
                }
            }

           
            console.log('soldTO::'+JSON.stringify(this.soldToOptions));
            this.advSoldTo = this.advSoldTo;
            //console.log('soldToLst::'+JSON.stringify(soldToLst));

            this.shtNoOptions = [
                { label: 'ALL', value: 'ALL'}            
            ];
            for (var key in message.shtNoOptions) 
                {
                   // if ((message.shtNoOptions).hasOwnProperty(key)) {
                       // shtNoOptionslst.push({value: message.shtNoOptions[key], label: message.shtNoOptions[key]});
                       this.shtNoOptions.push({value: message.shtNoOptions[key], label: message.shtNoOptions[key]});
                    //}
                }
               // this.shtNoOptions = shtNoOptionslst;
                console.log('SHTNo::'+this.advShtNo);
                this.advShtNo= this.advShtNo;

                this.poTypeOptions = [
                    { label: 'ALL', value: 'ALL'}            
                ];

                for (var key in message.poTypeOptions) 
                {
                   // if ((message.poTypeOptions).hasOwnProperty(key)) {
                       // poTypeOptionslst.push({value: message.poTypeOptions[key], label: message.poTypeOptions[key]});
                       this.poTypeOptions.push({value: message.poTypeOptions[key], label: message.poTypeOptions[key]});
                   // }
                }
               // this.poTypeOptions = poTypeOptionslst;
                console.log('poType::'+this.advpoType);
                this.advpoType = this.advpoType;
    }
}