import { LightningElement, track, api } from 'lwc';

export default class Tcp_pillContainer extends LightningElement {

    @track items_ = [];
    rendered = false;
  
    @api
    get items() {
      return this.items_;
    }
    set items(values) {
  
      //console.log(JSON.parse(JSON.stringify(values)));
      let tempitems = JSON.parse(JSON.stringify(values));
      tempitems.forEach( (pill,index) => {
        pill.internalKey = index;
      });
  
      this.items_ = tempitems;
  
    }
  
    deletePill = (event) => {
      let key = event.target.dataset.key;
      this.items_.some( (pill,index) => {
        if (pill.internalKey == key){
          this.items_.splice(index, 1);
          this.despatchItemRemoveEventEvent(pill);
          return true;
        }
        return false;
      });
    }

    handleKeyPress(event){
      if(event.keyCode === 13){
        let key = event.target.dataset.key;
        this.items_.some( (pill,index) => {
          if (pill.internalKey == key){
            this.items_.splice(index, 1);
            this.despatchItemRemoveEventEvent(pill);
            this.dispatchEventToOpen('open');
            return true;
          }
          return false;
        });
      }
    }
  
    despatchItemRemoveEventEvent(pill) {
      const eventDetail = { item: pill };
      const changeEvent = new CustomEvent("itemremove", { detail: eventDetail });
      this.dispatchEvent(changeEvent);
    }


    dispatchEventToOpen(eventDetail){
      const changeEvent = new CustomEvent("openpill", { detail: eventDetail });
      this.dispatchEvent(changeEvent);
    }




}