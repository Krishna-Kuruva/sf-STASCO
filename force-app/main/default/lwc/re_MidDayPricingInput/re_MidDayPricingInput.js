import { LightningElement,track, wire, api} from 'lwc';  
import { createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import MQ_OBJECT from '@salesforce/schema/RE_Market_Quotes__c';
import inputmarketRecords from '@salesforce/apex/RE_MidDayPricingController.inputmarketRecords';

//import QNAME_FIELD from '@salesforce/schema/RE_Market_Quotes__c.RE_Quote_Name__c';
//import QTYPE_FIELD from '@salesforce/schema/RE_Market_Quotes__c.RE_Quote_Type__c';
//import RATE_FIELD from '@salesforce/schema/RE_Market_Quotes__c.RE_Rate_Unit__c';
//import PRICE_FIELD from '@salesforce/schema/RE_Market_Quotes__c.RE_Price__c';
//import DATE_FIELD from '@salesforce/schema/RE_Market_Quotes__c.RE_Pricing_Date__c';

export default class createMidDayRecord extends LightningElement {
@track isdisabled = false;
@track price1;
@track publishDate1;
@track price2;
@track publishDate2;
@track toggleSaveLabel = 'Save';
@track quoteType = 'Forward Swap';
@track quoteName = 'GO10ppm Forward Swap';
@track rateUnit = 'USD/BBL';
@track error_attribute = false;
@track dateThisMonth;
@track dateNextMonth;

    handlepriceChange1(event)
    {
    this.price1 = event.target.value;
    }
    handlepriceChange2(event)
    {
    this.price2 = event.target.value;
    }

    connectedCallback()
    {
        var dateToday = new Date();
        console.log("dateToday"+dateToday);
        var dateMonth = dateToday.getMonth();
        var todayMonth = dateMonth+1;
        var todayDate = dateToday.getDate();
        var todayYear = dateToday.getFullYear();

        if(todayDate <= "15")
        {
            var nextMonth = todayMonth;
            var nextDate  = "1";
            var nextYear  = todayYear;
            console.log("less15");
        }
        else{
            if(todayMonth == "12"){
            var nextMonth = "1";
            var nextDate  = "1";
            var nextYear  = todayYear+1;
            console.log("greater15");
            }
            else{
                var nextMonth = todayMonth+1;
                var nextDate  = "1";
                var nextYear  = todayYear;
                }
        }

                this.publishDate1  = nextMonth + '/' + nextDate +'/' + nextYear;
                this.dateThisMonth = new Date(this.publishDate1);
           
            if(nextMonth == "12"){
                this.publishDate2 = "1" + '/' + nextDate  +'/' + (parseInt(nextYear)+1);
                this.dateNextMonth = new Date(this.publishDate2);            
            }
            else{
                this.publishDate2 = (parseInt(nextMonth)+1) + '/' + nextDate +'/' + nextYear;
                this.dateNextMonth = new Date(this.publishDate2);              
            }           
    }
   
 
    handleSave() {

        if(this.price1 == null|| this.price2 == null)
        {
            this.error_attribute = true;
        }
        else{     
              
            const fieldsval = [{RE_Quote_Name__c:this.quoteName,RE_Quote_Type__c:this.quoteType,RE_Rate_Unit__c:this.rateUnit,RE_Price__c:this.price1,RE_Pricing_Date__c: this.dateThisMonth},
            {RE_Quote_Name__c:this.quoteName,RE_Quote_Type__c:this.quoteType,RE_Rate_Unit__c: this.rateUnit,RE_Price__c:this.price2,RE_Pricing_Date__c: this.dateNextMonth}];
            this.isdisabled = true;
            inputmarketRecords({marketquoteList : fieldsval})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Success',
                        message : `Records saved succesfully!`,
                        variant : 'success',
                    }),
                    this.toggleSaveLabel = 'Save'
                )
                this.dispatchEvent(new CustomEvent('refreshview',{details:{message:''}}));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.record = undefined;
                console.log("Error in Save call back:", this.error);
            });                                        
        }
	}	
	handleCancel() {
		this.price1= '';
		this.price2= '';
		this.error_attribute = false;		
	}
}