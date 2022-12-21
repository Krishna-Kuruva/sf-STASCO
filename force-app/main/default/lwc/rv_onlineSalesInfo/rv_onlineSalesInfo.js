/**
 * Created by Dharmendra.Singh2 on 8/27/2021.
 */

import { LightningElement, track, api } from 'lwc';
import getDealsInfo from '@salesforce/apex/rv_customerInfoController.getContact';
import olfCustomerField from '@salesforce/schema/Account.Rv_Available_for_OLF__c';

var list = [
        { date: '12/1/2011', reading: 3, id: 20055 },
        { date: '13/1/2011', reading: 5, id: 20053 },
        { date: '14/1/2011', reading: 6, id: 45652 }
    ];

export default class RvOnlineSalesInfo extends LightningElement {

        @track accRecordId='0012500001RIxXnAAL';
        @track deals;
        @track account;
        olfField = olfCustomerField;
        @api errorMessage;
        connectedCallback(){
            getDealsInfo({ accountId: this.accId })
                .then(result => {
                    console.log('--result--',result);
                    if (result) {
                        this.deals = result.deals;
                        this.account    = result.account;
                        console.log(deals);
                        console.log(account);
                    }
                })
                .catch(error => {
                    this.error = error;
                });
        }

    }