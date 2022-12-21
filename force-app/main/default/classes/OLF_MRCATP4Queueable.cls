public class OLF_MRCATP4Queueable implements Queueable{  
    
         Set<Id> accountIdsFirstBatch = new Set<Id>();
    String query;
    OLFWrapper.OlfTrancheWrap olfTrancheWrap;
    OLFWrapper.ContractDateWindowWrap dateWrap;
    String startDate;
    String endDate;
    public OLF_MRCATP4Queueable(Set<Id> ids,OLFWrapper.OlfTrancheWrap olfTrancheWrap,OLFWrapper.ContractDateWindowWrap dateWrap,String startDate,String endDate){
        this.accountIdsFirstBatch=ids;
        this.olfTrancheWrap= olfTrancheWrap;
        this.dateWrap=dateWrap;
        this.startDate=startDate;
        this.endDate=endDate;
    //   query ='Select Id from Account where Id IN :accountIdsFirstBatch';
        
    }
    public void execute(QueueableContext context) {
                 
        try{         
        	List<RV_OLF_MRC_Data__c> olfUpdatedList = new List<RV_OLF_MRC_Data__c>();
     
           List<RV_OLF_MRC_Data__c> olfWrapperList = new List<RV_OLF_MRC_Data__c>();
          List<RV_SHT_CreateController.MRCDataWrap> mrcMasterData = OLF_MRCDataHelper.getMRCRecordsData(olfTrancheWrap.tranche,this.accountIdsFirstBatch,startDate, endDate) ;
   		
        List<OLFWrapper.MrcPriceWrap> mrcPriceWrapVar = new List<OLFWrapper.MrcPriceWrap>();
        System.debug('Master Data'+mrcMasterData);
        if(mrcMasterData != null){
            Set<String> plantCodeSet = new Set<String>();
            
            for(RV_SHT_CreateController.MRCDataWrap wrp : mrcMasterData){
                plantCodeSet.add(wrp.location); 
            }
            Map<String,Decimal> atpLocMap = OLF_MRCDataHelper.getAtpforPlant(plantCodeSet, null, new List<String>{olfTrancheWrap.tranche});

            for(RV_SHT_CreateController.MRCDataWrap wrp : mrcMasterData){
                   
                String uniqueId=wrp.mrcName+'ATP4';
                RV_OLF_MRC_Data__c olfMRCUpdated = new RV_OLF_MRC_Data__c();
                   if(atpLocMap.get(wrp.location+wrp.grade+olfTrancheWrap.tranche)<1){
                   olfMRCUpdated.RV_VolumeCBM__c=0;  
                }else{
                    olfMRCUpdated.RV_VolumeCBM__c=Integer.valueOf(atpLocMap.get(wrp.location+wrp.grade+olfTrancheWrap.tranche)); 
                }
                    olfMRCUpdated.RV_PricePerVol__c=wrp.OTM;
                olfMRCUpdated.RV_MrcId__c = wrp.mrcName;
                 olfMRCUpdated.UniqueMRCId__c=uniqueId;
                olfMRCUpdated.tranche__c = olfTrancheWrap.tranche;
                olfMRCUpdated.RV_LocationName__c = wrp.locationName;
                olfMRCUpdated.RV_MaterialName__c = wrp.materialName;
            	olfMRCUpdated.RV_OLF_Contact_Email__c = wrp.contactEmail;
                olfMRCUpdated.RV_Grade__c = wrp.grade;
                olfMRCUpdated.RV_ContractEndDate__c=endDate;
                olfMRCUpdated.RV_ContractStartDate__c=startDate;
                olfMRCUpdated.tranche__c = 'ATP4';
                olfMRCUpdated.LastModifiedTime__c=String.valueOf(System.now());
                olfMRCUpdated.RV_OLFAccountName__c=wrp.accName;

                olfUpdatedList.add(olfMRCUpdated);
           
        }
                        System.debug('olfUpdatedList'+' '+olfUpdatedList.size());

        if(!olfUpdatedList.isEmpty()){
            Schema.SObjectField ftoken = RV_OLF_MRC_Data__c.Fields.UniqueMRCId__c;
			Database.UpsertResult[] srList = Database.upsert(olfUpdatedList,ftoken,false);
                        System.debug('Success ATP3'+srList.size()+srList);

			for (Database.UpsertResult sr : srList) {  
        		for(Database.Error err : sr.getErrors()) {
            		System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
            		System.debug('fields that affected this error: ' + err.getFields());
            
        		}
    
			} 
          
        }
   
    }
        }catch(Exception ex){
            System.debug('OLF_MRCATP4Queueable:'+ex.getStackTraceString());
            OLF_MRCDataHelper.sendEmailandDeactivate('OLF_MRCATP4Queueable',ex.getMessage());
        }
    
    }
}