import { LightningElement,api,wire,track} from 'lwc';    
import { getRecord } from 'lightning/uiRecordApi';
import covamoMetadata from '@salesforce/apex/RE_CovamoController.getCovamoMetadata';

const fields = ['Rev_Covamo_Header__c.Name'];
export default class CovamoReports extends LightningElement {
    @api recordId;
    @track financeSummary;
    @track covamoHeaderReport;
    @track covamoDetailReport;
    @track covamoYearlyFSReport;

    @wire (getRecord,{recordId: '$recordId',fields })
    loaddata({error,data}){

        if(error){
           //
        }
        if(data){
            this.covHeaderName = data.fields.Name.value;
            
        }
    }
    connectedCallback(){
        covamoMetadata()
        .then(result=>{
            console.log("result meta",JSON.stringify(result));
            this.financeSummary = '/lightning/r/Report/'+result.Covamo_FS_ReportId__c+'/view?fv0='+this.covHeaderName;
            this.covamoHeaderReport = '/lightning/r/Report/'+result.Covamo_Header_ReportId__c+'/view?fv0='+this.covHeaderName;
            this.covamoDetailReport = '/lightning/r/Report/'+result.Covamo_Detail_ReportId__c+'/view?fv0='+this.covHeaderName;
            this.covamoYearlyFSReport = '/lightning/r/Report/'+result.Covamo_Yearly_FS_ReportId__c+'/view?fv0='+this.covHeaderName;
        })
        .catch(error=>{
            console.log("error");
            
        });
    }
}