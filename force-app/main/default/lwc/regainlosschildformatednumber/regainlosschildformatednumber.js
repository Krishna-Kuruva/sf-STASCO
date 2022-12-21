import { LightningElement, track, api } from 'lwc';
/*eslint-disable no-console*/
 /*eslint-disable no-alert*/
export default class Regainlosschildformatednumber extends LightningElement {
    @api value;
    @track styleClass;
    renderedCallback(){
        
        if(this.value > 0 ){
           // alert("1");
            this.styleClass="test2";
        }else{
           // alert("2");
            this.styleClass="test1";
        }
    }
    
}