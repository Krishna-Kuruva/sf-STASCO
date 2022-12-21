public class InsertSAP {
    /*
    public static void createRecord (List<SAP_Staging__c> sapRecords) { 
        List<SF_SAP_DataSet__x> listOfItems=new List<SF_SAP_DataSet__x>();
        for(SAP_Staging__c sapData:sapRecords){
            SF_SAP_DataSet__x item= new SF_SAP_DataSet__x();  
            if(sapData.CondType__c==NULL)
                item.CondType__c='YP23';
            else
                item.CondType__c=sapData.CondType__c;
            item.ContEndDate__c=sapdata.EndDate__c;
            item.ContStartDate__c=sapdata.StartDate__c;
            item.CurrencyKey__c=sapData.CurrencyKey__c;
            item.MaterialNo__c=sapdata.MaterialNo__c;
            item.SapMrcItemNo__c=sapdata.MrcItemNo__c;
            item.Quantity__c=String.valueOf(sapdata.Quantity__c);
            item.QuantityUom__c=sapdata.QuantityUom__c;
            item.SalesOrg__c=sapdata.SalesOrg__c;
            item.SalesPrice__c=String.valueOf(sapdata.SalesPrice__c);
            item.SapMrcNo__c=sapdata.SapMrcNo__c;
            item.SfHeaderShtNo__c=sapdata.SfHeaderShtNo__c;
            item.SfItemShtNo__c=sapdata.SfItemShtNo__c;
            item.TotalItems__c=String.valueOf(sapdata.Counter__c);
            item.ItemCount__c=String.valueOf(sapdata.Count__c);
            item.Action__c=sapdata.CreationInd__c;
            item.Status__c=sapdata.Processing_Indicator__c;
            item.DealCreationDate__c=sapdata.Record_Created_Date__c;
            item.DealCreationTime__c=sapdata.Record_Created_Time__c;
            item.CondPUnt__c=sapData.CondPUnt__c;
            item.CondUnit__c=sapData.CondUnit__c;
            listOfItems.add(item);  
        }
        IF(listOfItems.size()>0){
            List<Database.SaveResult> sr = Database.insertAsync(listOfItems);
        }
    }
    
    public static void rejectRecord(List<SAP_Staging__c> sapRecords)
    {
        List<SF_SAP_DataSet__x> listOfItems=new List<SF_SAP_DataSet__x>();
        for(SAP_Staging__c sapData:sapRecords){
        SF_SAP_DataSet__x item= new SF_SAP_DataSet__x();
        if(sapData.CondType__c==NULL)
            item.CondType__c='YP23';
        else
            item.CondType__c=sapData.CondType__c;
        item.ContEndDate__c=sapdata.EndDate__c;
        item.ContStartDate__c=sapdata.StartDate__c;
        item.CurrencyKey__c=sapData.CurrencyKey__c;
        item.MaterialNo__c=sapdata.MaterialNo__c;
        item.SapMrcItemNo__c=sapdata.MrcItemNo__c;
        item.Quantity__c=String.valueOf(sapdata.Quantity__c);
        item.QuantityUom__c=sapdata.QuantityUom__c;
        item.SalesOrg__c=sapdata.SalesOrg__c;
        item.SalesPrice__c=String.valueOf(sapdata.SalesPrice__c);
        item.SapMrcNo__c=sapdata.SapMrcNo__c;
        item.SfHeaderShtNo__c=sapdata.SfHeaderShtNo__c;
        item.SfItemShtNo__c=sapdata.SfItemShtNo__c;
        item.Action__c=sapdata.CreationInd__c;
        item.Status__c=sapdata.Processing_Indicator__c;
        item.DealCreationDate__c=sapdata.Record_Created_Date__c;
        item.DealCreationTime__c=sapdata.Record_Created_Time__c;
        item.CondPUnt__c=sapData.CondPUnt__c;
        item.CondUnit__c=sapData.CondUnit__c;
        item.RejectionReason__c=sapData.Rejection_Reason__c;
        listOfItems.add(item);
        }
        IF(listOfItems.size()>0){
        List<Database.SaveResult> sr = Database.InsertAsync(listOfItems);
        }
    }
*/
}