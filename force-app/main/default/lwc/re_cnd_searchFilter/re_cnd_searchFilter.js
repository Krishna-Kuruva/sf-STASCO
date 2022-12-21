import { LightningElement ,api,track} from 'lwc';

export default class Re_cnd_searchFilter extends LightningElement {
    @api filterLabel;
    @api filterSearchText;
    @api filterListToShow=[];
    @api filterListToSearch=[];
    @api showFilterGroup=false;
    @api isAll=false;
    @track dup_filterListToSearch=[];
    @track dup_filterListToShow=[];
    
    @api 
    handleFilterSearch(event)
    {
        this.filterSearchText=event.detail.value.toLowerCase();
        var x;
        var y=[];
        
        for(x of this.filterListToSearch)
        {
          var textToSearch = x.filter.toLowerCase();
         var  isAvailable=textToSearch.includes(this.filterSearchText);
         if(isAvailable)
          {
            y.push(x);
          }
         }
        this.filterListToShow=y;
    }

    /*renderedCallback()
    {
        console.log('search text--'+this.filterSearchText)
    }*/

    @api resetparams()
    {
        this.showFilterGroup=false;
        this.filterSearchText='';
        this.isAll=true;
       // this.template.querySelector('lightning-input').value=''; 
        this.template.querySelector("lightning-input[data-my-id=in3]").value = "";
        console.log('resetparams--filterSearchText--'+this.filterSearchText+'--showFilterGroup--'+this.showFilterGroup);
    } 
    
    
    @api 
    focusSearch(){
        console.log('Search Filter--focus search called--');
        this.showFilterGroup=true;
    }

    @api 
    handleFilterSelect(event)
    {
        //console.log('Before--filterListToSearch--'+JSON.stringify(this.filterListToSearch));
        //console.log('Before--filterListToShow--'+JSON.stringify(this.filterListToShow));

        this.dup_filterListToSearch=JSON.parse(JSON.stringify(this.filterListToSearch));
        this.dup_filterListToShow=JSON.parse(JSON.stringify(this.filterListToShow))
        //this.dup_filterListToShow=this.dup_filterListToSearch;
      
      if(event.target.name=='All')
      { 
          for(var l2=0;l2<this.dup_filterListToSearch.length;l2++)
          {
              if(event.target.value)
              {
              this.dup_filterListToSearch[l2].isSelected=false;
              }
               else
               {
               this.dup_filterListToSearch[l2].isSelected=true;
               }
            }
            this.dup_filterListToShow =      this.dup_filterListToSearch;
            //this.filterListToShow   =      this.dup_filterListToSearch;
      }
      else
      {
          for(var l2=0;l2<this.dup_filterListToShow.length;l2++)
          {
              if(this.dup_filterListToShow[l2].filter==event.target.name)
              {
              if(event.target.value)
                  this.dup_filterListToShow[l2].isSelected=false;
              
              else
                  this.dup_filterListToShow[l2].isSelected=true;
              
              }
          }

          
          for(var l3=0;l3<this.dup_filterListToSearch.length;l3++)
          {
           
              if(this.dup_filterListToSearch[l3].filter==event.target.name)
              {
                console.log(event.target.name+'---'+this.dup_filterListToSearch[l3].filter);
              if(event.target.value)
              {
                  this.dup_filterListToSearch[l3].isSelected=false;
                 // console.log('true---dup_filterListToSearch--'+JSON.stringify(this.dup_filterListToSearch));

              }
              
              else
              {
                  this.dup_filterListToSearch[l3].isSelected=true;
                  //console.log('false--dup_filterListToSearch--'+JSON.stringify(this.dup_filterListToSearch));
              }
              
              }
          }

          var selectedGroup=[];
          for(var l2=1;l2<this.dup_filterListToSearch.length;l2++)
            {
                if(this.dup_filterListToSearch[l2].isSelected)
                {
                    selectedGroup.push(this.dup_filterListToSearch[l2].filter);
                }
            }

            if(selectedGroup.length<this.dup_filterListToSearch.length-1)
                this.isAll=false;
            else
            this.isAll=true;

            if(this.dup_filterListToShow[0].filter=='All')
            { this.dup_filterListToShow[0].isSelected=this.isAll;}

            this.dup_filterListToSearch[0].isSelected=this.isAll;

          
         }

     
         console.log('dup_filterListToSearch--'+JSON.stringify(this.dup_filterListToSearch));
      this.filterListToSearch=JSON.parse(JSON.stringify(this.dup_filterListToSearch));
      this.filterListToShow=JSON.parse(JSON.stringify(this.dup_filterListToShow));

     // console.log('filterListToSearch--'+JSON.stringify(this.filterListToSearch));
     // console.log('filterListToShow--'+JSON.stringify(this.filterListToShow));
      //console.log('dup_filterListToShow--'+JSON.stringify(this.dup_filterListToShow));
      //console.log('dup_filterListToSearch--'+JSON.stringify(this.dup_filterListToSearch));

      const selectedEvent = new CustomEvent('filterselect', {
        detail:{filterListToSearch: this.dup_filterListToSearch , filterListToShow: this.dup_filterListToShow }});
        this.dispatchEvent(selectedEvent);
     
    }



    @api 
    applyFilter(){

        var selectedGroup=[];
          for(var l2=1;l2<this.filterListToSearch.length;l2++)
            {
                if(this.filterListToSearch[l2].isSelected)
                {
                    selectedGroup.push(this.filterListToSearch[l2].filter);
                }
            }

            if(selectedGroup.length<this.filterListToSearch.length-1)
                this.isAll=false;
            else
            this.isAll=true;

            console.log('is All--'+this.isAll+'--selected--'+JSON.stringify(this.filterListToSearch));

            const selectedEvent = new CustomEvent('applyfilter', {
                detail:{isAll: this.isAll , selectedFilter: selectedGroup,filterType:this.filterLabel }});
                this.dispatchEvent(selectedEvent)
    }

    @api 
    closeSearchFilter(){
        this.showFilterGroup=false;
    }
}