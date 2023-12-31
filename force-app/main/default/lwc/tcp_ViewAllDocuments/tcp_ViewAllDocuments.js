import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import fetchFilesFromGSAP from '@salesforce/apex/TCP_GSAPDataService.fetchFilesFromGSAP';

export default class tcp_ViewAllDocuments extends NavigationMixin(LightningElement) {

    error;
    siteURL;
    @track isViewLoading;
    @api salesordnum;
    @api boldel;
    @api redirectdel;
    @track docNameList = [];
    @track data1;
    @track pdfData ='data:application/pdf,';
    @track docDetailsMap = new Map();
    @track fileNetIdMap = new Map();
    @track isShowModal = false;
    @track noDocs = false;
    @track initialDoc=null;
    @track backText='Back';
    

    connectedCallback(){
        
        fetchFilesFromGSAP({salesordnum : this.salesordnum, boldel : this.boldel, redirectdel:this.redirectdel}).then(result=>{
            this.isViewLoading=true;
            
            for(let i=0; i<result.length; i++){
                const data = [];
                data.docName = result[i].Outputdesc+' '+result[i].Document;
                data.docLink = result[i].Uri;
                
                if(!this.docDetailsMap.has(data.docName) && data.docLink){
                this.docDetailsMap.set(data.docName,result[i].Document);
                this.docNameList = [...this.docNameList,data];   
                } 
                if(!this.fileNetIdMap.has(data.docName) && data.docLink){
                    this.fileNetIdMap.set(data.docName,result[i].Filenetid);
                } 
            }
            if(this.docDetailsMap && this.docDetailsMap.size>0){
                const docName = this.docNameList[0].docName;
                this.initialDoc=docName;
            }else{
                this.noDocs=true;
                this.isShowModal=true;
            }
            setTimeout(() => {
                this.isViewLoading=false;
                }, 4000);
            
        
        })
        .catch(error=>{
            this.error = error;
            window.console.log('Error in getting files====>'+JSON.stringify(this.error));
            this.isShowModal=true;
            this.isViewLoading=false;
        })
    }

    handleBack(){
        this.isShowModal=false;
        this.dispatchEvent(new CustomEvent('backbutton'));
    }

    handleSelect(event){
        this.isViewLoading=true;
        const docName = event.detail.name;
        const docId = this.docDetailsMap.get(docName);
        const fileNetId=this.fileNetIdMap.get(docName);
        window.console.log('docId '+docId);
        window.console.log('fileNetId '+fileNetId);
        window.console.log('*2*');
        if(docId && docId.length>0){
            
            this.siteURL = `/tradingandsupply/apex/TCP_ViewDocument?q=${docId}&i=${fileNetId}`;
        }
        setTimeout(() => {
            this.isViewLoading=false;
            }, 4000);
    }

    showModalBox() {  
        this.isShowModal = true;
    }
    handleCloseModal() {  
        this.isShowModal = false;
    }

    renderedCallback(){

        document.title = 'TCP | View All Documents';
    }
    
}