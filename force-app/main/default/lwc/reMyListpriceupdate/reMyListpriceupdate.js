import { LightningElement, track ,api} from 'lwc';  
import getListprice from '@salesforce/apex/RE_MY_AMVCalculationController.getDirectListPrice';
import updateListPrice from '@salesforce/apex/RE_MY_AMVCalculationController.updateDirectLisprice';
import RE_EditLandingPage from '@salesforce/customPermission/RE_EditLandingPage';

export default class ReMyListpriceupdate extends LightningElement {
    @track directList ;
    @track mapData=[];
    @track spinnerLoad=false;
    @track spinnerMessage;
    connectedCallback() {
        this.loadSpinner(true,'loading data');
        getListprice({})
        .then(result=>{
            console.log(JSON.stringify(result));
            this.directList = result;

            for (var key1 in this.directList) {
                var map2 = this.directList[key1]; 

                var newMap = [];
                for (var key2 in map2) {
                    newMap.push({
                        value: map2[key2],
                        key: key2
                    })
                }
                this.mapData.push({
                    value: newMap,
                    key: key1
                });

            }
            this.loadSpinner(false,'loading data')
            console.log(JSON.stringify(this.mapData));
        })
        .catch(error =>{
            console.log(JSON.stringify(error));
            this.loadSpinner(false,'loading data')
        })
    }

    priceChange(event){
        console.log('---'+event.target.value);
        for( var salesorg in this.mapData){  
            for(var product in this.mapData[salesorg].value){
                if(this.mapData[salesorg].value[product].value.salesOrgProduct == event.target.name){
                    this.mapData[salesorg].value[product].value.listPrice = event.target.value;
                }
                    
            }
        }
    }

    @api saveDirectListPrice(){
       console.log('child method');
       this.loadSpinner(true,'Saving data');
        var updateData = [];
        for( var salesorg in this.mapData){  
            for(var product in this.mapData[salesorg].value){
                updateData.push(this.mapData[salesorg].value[product].value);
            }
        }

        updateListPrice({ updateData:updateData})
        .then(result =>{
            this.loadSpinner(false,'data saved');
        })
        .catch(error => {
            this.loadSpinner(false,'data saved');

        })
    }

    loadSpinner(load, msg)
    {
        if(load)
        {
            this.spinnerLoad = true;
            this.spinnerMessage = msg;
        }
        else
            this.spinnerLoad = false;
    }

   showToast(type,msgtitle,msg)
   {
       const evt = new ShowToastEvent({
           title: msgtitle,
           message: msg,
           variant: type,
           mode: 'dismissable'
       });
       this.dispatchEvent(evt);
   }
   get hasReadAccess(){
    return !RE_EditLandingPage;
    }
}