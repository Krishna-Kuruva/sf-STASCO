import { LightningElement, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Name';
import getMyApprovalFormData from '@salesforce/apex/BetExportApprovalDataController.getMyApprovalDataToExport';

export default class BetExportApprovalDataLWCController extends LightningElement {

    @track formData = {}
    userId = userId;
    currentUserName;
    error;
    columnHeader = ['ID', 'BDD Form Name', 'Counterparty Legal Name', 'Incorporation Country'
						, 'Assigned COF'/*, 'BDD Approver Name'*/, 'How was contact made with this CP?'
						, 'Trading Name', 'Intended business relationship', 'Rationale for Onboarding this CP?', 'Customer Entity Type | Classification'
						, 'Nature of Business', 'What type of relationship is requested', 'Relationship', 'BDD Commodity'
						, 'Other Relationship Comment', 'BDD Government Intermediary', 'Core Business Activity'
						, 'BDD Business Division', 'Requestor Name', 'Shell Company'
						, 'Desk', 'Were any deviations applied to this CP?', 'Counterparty Type', 'Operating Region'
						, 'PEPs and Sanctions Found', 'Adverse Media Found', 'PEPs and Sanctions Comments'
						, 'Adverse Media Comments'];
		
	
    @wire(getRecord, { recordId: userId, fields: [UserNameFld]}) 
    userDetails({usererror, userdata}) {
        if (userdata) {
            this.currentUserName = userdata.fields.Name.value;
        } else if (usererror) {
            this.error = usererror ;
        }
    }

    @wire(getMyApprovalFormData)
    wiredData({ error, data }) {
        if (data) {
            console.log('Data', data);
            this.formData = data;
        } else if (error) {
            console.error('Error:', error);
        }
    }

    exportFormData(){
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columnHeader.forEach(element => {            
            doc += '<th>'+ element +'</th>'           
        });
        doc += '</tr>';
        // Add the data rows
        this.formData.forEach(record => {
            doc += '<tr>';
            doc += '<th>'+(record.Id == null?"":record.Id)+'</th>'; 
            doc += '<th>'+(record.Name == null?"":record.Name)+'</th>';
			doc += '<th>'+(record.Full_Legal_Name__c== null?"":record.Full_Legal_Name__c)+'</th>';
            doc += '<th>'+(record.Inc_Country__c== null?"":record.Inc_Country__c)+'</th>';
		    doc += '<th>'+(record.Assigned_COF__r.Name== null?"":record.Assigned_COF__r.Name)+'</th>';
		    //doc += '<th>'+(this.currentUserName == null?"":+this.currentUserName)+'</th>';
		    doc += '<th>'+(record.GT_Contact_With_CP__c== null?"":record.GT_Contact_With_CP__c)+'</th>';
		    doc += '<th>'+(record.GT_Trading_Name__c== null?"":record.GT_Trading_Name__c)+'</th>';
		    doc += '<th>'+(record.GT_Int_Business_Rel__c== null?"":record.GT_Int_Business_Rel__c)+'</th>';
		    doc += '<th>'+(record.GT_Rationale_OB_CP__c== null?"":record.GT_Rationale_OB_CP__c)+'</th>';
		    doc += '<th>'+(record.GT_Cust_Entity_Type_Class__c== null?"":record.GT_Cust_Entity_Type_Class__c)+'</th>';
		    doc += '<th>'+(record.GT_Nature_of_Business__c== null?"":record.GT_Nature_of_Business__c)+'</th>';
		    doc += '<th>'+(record.GT_Type_Of_RelationShip__c== null?"":record.GT_Type_Of_RelationShip__c)+'</th>';
		    doc += '<th>'+(record.GT_Relationship__c== null?"":record.GT_Relationship__c)+'</th>';
		    doc += '<th>'+(record.GT_BDD_Commodity__c== null?"":record.GT_BDD_Commodity__c)+'</th>';
		    doc += '<th>'+(record.GT_Other_Relationship_Comment__c== null?"":record.GT_Other_Relationship_Comment__c)+'</th>';
		    doc += '<th>'+(record.GT_GI__c== null?"":record.GT_GI__c)+'</th>';
		    doc += '<th>'+(record.GT_Core_Business_Act__c== null?"":record.GT_Core_Business_Act__c)+'</th>';
		    doc += '<th>'+(record.GT_BDD_Business_Division__c== null?"":record.GT_BDD_Business_Division__c)+'</th>';
		    doc += '<th>'+(record.GT_Req_Name__c== null?"":record.GT_Req_Name__c)+'</th>';
		    doc += '<th>'+(record.GT_Shell_Company__c== null?"":record.GT_Shell_Company__c)+'</th>';
		    doc += '<th>'+(record.GT_Desk__c== null?"":record.GT_Desk__c)+'</th>';
		    doc += '<th>'+(record.GT_Were_any_deviations_applied_tothis_CP__c== null?"":record.GT_Were_any_deviations_applied_tothis_CP__c)+'</th>';
		    doc += '<th>'+(record.GT_Counterparty_Type__c== null?"":record.GT_Counterparty_Type__c)+'</th>';
		    doc += '<th>'+(record.GT_Operating_Region__c== null?"":record.GT_Operating_Region__c)+'</th>';
		    doc += '<th>'+(record.PEPs_and_Sanc_Found__c== null?"":record.PEPs_and_Sanc_Found__c)+'</th>';
		    doc += '<th>'+(record.Negative_Stories_Found__c== null?"":record.Negative_Stories_Found__c)+'</th>';
		    doc += '<th>'+(record.BET_PEPs_and_Sanctions_Comments__c== null?"":record.BET_PEPs_and_Sanctions_Comments__c)+'</th>';
		    doc += '<th>'+(record.BET_Negative_Stories_Comments__c== null?"":record.BET_Negative_Stories_Comments__c)+'</th>'; 
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'My Approval Forms.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
}