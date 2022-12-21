/**
* Created by Dharmendra.Singh2 on 8/6/2020.
*/

public class RT_REVContractTriggerHelper {
    // method for aureus operations
    public static void updateAureus(List<REV_Contract_Master__c> aureusList){
        Set<Id> condTypeSet = new Set<Id>();
        Set<Id> contrIdSet = new Set<Id>();
        for(REV_Contract_Master__c aur : aureusList ){
            System.debug('Aur data ---------' +aur);
            condTypeSet.add(aur.RT_Condition_Type__c);
            contrIdSet.add(aur.SAP_Contract__c);
        }
        Map<Id, RT_Setting__c> condMap 		= new Map<Id, RT_Setting__c>([SELECT Id, Name FROM RT_Setting__c WHERE Id IN : condTypeSet ]);
        Map<Id, RE_Contract__c> contrMap 	= new Map<Id, RE_Contract__c>(
            [SELECT Id, Name,RT_Terms_of_Payment__c, RT_Sold_To_Name__c,RT_Ship_to_Name__c,RE_Location_Name__c  FROM RE_Contract__c WHERE Id IN :contrIdSet ]);
        //System.debug('Condition map----' + condMap);
        
        for(REV_Contract_Master__c ad : aureusList){
            String conType;
            //System.debug('ad name----' + condMap.get(ad.RT_Condition_Type__c).Name);
            if (condMap.get(ad.RT_Condition_Type__c).Name != null) {
                conType = condMap.get(ad.RT_Condition_Type__c).Name;
            }
            if(conType != null && conType.startsWith('YS')){
                System.debug('ad.active----' + ad.Active__c);
                ad.Active__c = false; 
                ad.RT_Comment__c = RT_Util.surchargeMessage;
            }
            //YP04 logic moved to workflow
            //System.debug('Valid to date -----' +ad.Contract_Valid_To__c);
            if(ad.SAP_Contract__c != null){
                System.debug('Valid to date -----' +ad.Contract_Valid_To__c);
                if((ad.Contract_Valid_To__c !=null && ad.Contract_Valid_To__c < System.today() ) || (ad.RT_Valid_To__c !=null && ad.RT_Valid_To__c < System.today()) ){
                    ad.Active__c     = false;
                    ad.RT_Comment__c = RT_Util.validityMessage;
                }
                if(contrMap.size() != null ){
                    System.debug('Contract-----' +ad.SAP_Contract__c);
                    if (contrMap.get(ad.SAP_Contract__c).RT_Sold_To_Name__c != null) {
                        ad.RT_Sold_to_Name__c = contrMap.get(ad.SAP_Contract__c).RT_Sold_To_Name__c;
                    }
                    if (contrMap.get(ad.SAP_Contract__c).RT_Ship_to_Name__c != null) {
                        ad.RT_Ship_to_Name__c = contrMap.get(ad.SAP_Contract__c).RT_Ship_to_Name__c;
                    }
                    if (contrMap.get(ad.SAP_Contract__c).RE_Location_Name__c != null) {
                        ad.RT_Plant_Desc__c = contrMap.get(ad.SAP_Contract__c).RE_Location_Name__c;
                    }
                }
            } 
        }             
    }
    
    // method to upsert data on price output
    public static void upsertPriceOutPut(List<REV_Contract_Master__c> aureusList, Map<Id, REV_Contract_Master__c> mapRevContract){
        List<RT_PriceOutput__c> priceOutList 		= new List<RT_PriceOutput__c>();
        Map<Id, RT_PriceOutput__c> revConPOutMap 	= new Map<Id, RT_PriceOutput__c>();
        List<RT_PriceOutput__c> prOutUpdateList 	= new List<RT_PriceOutput__c>();
        List<RT_Price_Book__c> rtPriceBooks = new List<RT_Price_Book__c>();
        Map<Id, REV_Contract_Master__c> mapNewContractMaster = new Map<Id, REV_Contract_Master__c>();
        
        priceOutList = RT_Util.queryPriceData(' and PriceDate__c = TODAY');
        System.debug('Query data-----'+priceOutList);
        if (priceOutList.size() > 0) {
            for (RT_PriceOutput__c pOut : priceOutList) {
                if (!revConPOutMap.containsKey(pOut.Aureus_Data__c)) {
                    revConPOutMap.put(pOut.Aureus_Data__c, pOut);
                }
            }
        }
        System.debug('Aureus size -----'+aureusList.size()+'Aureus List'+aureusList);
        System.debug('Rev map data-----'+revConPOutMap);
        for(REV_Contract_Master__c rconMs : aureusList){
            if(revConPOutMap.containsKey(rconMs.Id)){
                prOutUpdateList.add(revConPOutMap.get(rconMs.Id));
            }else{
                mapNewContractMaster.put(rconMs.Id, rconMs);
            }
            
        }
        System.debug('mapNewContractMaster-----'+mapNewContractMaster.size());
        System.debug('prOutUpdateList-----'+prOutUpdateList.size());
        
        if (prOutUpdateList.size() > 0) {
            try{
            List<RT_PriceOutput__c> poUpsertList = RT_Util.buildPriceList(RT_Util.buildPriceWrapper(prOutUpdateList));
                if(poUpsertList.size()>0)
                    update poUpsertList;
            } catch(exception e){System.debug(e);}
        }
        if (mapNewContractMaster.size() > 0) {
            try{
            List<RT_PriceOutput__c> poInsertList = insertNewPriceOutPut(mapNewContractMaster);
                if(poInsertList.size()>0)
            		insert poInsertList;
            } catch(exception e){System.debug(e);}
        }
    }
    /*
    public static List<RT_PriceOutput__c> updateExistingPriceOutPut(List<RT_PriceOutput__c> poList, Map<Id, REV_Contract_Master__c> revConMap){
        for(RT_PriceOutput__c p : poList ){
            p.DepotName__c 		= revConMap.get(p.Aureus_Data__c).RT_Plant_Desc__c;
            p.AureusAmount__c 	= revConMap.get(p.Aureus_Data__c).RT_AMOUNT__c;
            p.ProductName__c 	= revConMap.get(p.Aureus_Data__c).RT_Material_Desc__c;
            p.SoldToName__c		= revConMap.get(p.Aureus_Data__c).RT_Sold_to_Name__c;
            p.RT_Country__c     = 'TU';
            p.PriceDate__c		= System.today();
            
        }
        return poList;
    }*/
    public static List<RT_PriceOutput__c> insertNewPriceOutPut(Map<ID, REV_Contract_Master__c> revConMap){
        List<RT_PriceOutput__c> poList = new List<RT_PriceOutput__c>();
 
        List<ID> materialList = new List<ID>();
        map<ID,RE_Product__c> productMap = new map<ID,RE_Product__c>();
        
        for(ID revConID : revConMap.keySet() )
        {
            if(!materialList.contains(revConMap.get(revConID).RT_Material_Desc__c))
                materialList.add(revConMap.get(revConID).RT_Material_Desc__c);
        }
        
        if(materialList.size()>0)
        {
            try{
            productMap = new map<ID,RE_Product__c>([select id, RT_Parent_Product__c,RT_Parent_Product__r.RT_Parent_Product__c 
                          							from RE_Product__c where id in :materialList]);
            } catch(exception e){System.debug(e);}
        }
        
        for(ID revConID : revConMap.keySet() ){
            RT_PriceOutput__c po 	= new RT_PriceOutput__c();
            po.DepotName__c 		= revConMap.get(revConID).RT_Plant_Desc__c;
            po.Aureus_Data__c 		= revConMap.get(revConID).id;
            po.AureusAmount__c		= revConMap.get(revConID).RT_AMOUNT__c;
            po.ProductName__c		= revConMap.get(revConID).RT_Material_Desc__c;
            if(productMap.containsKey(revConMap.get(revConID).RT_Material_Desc__c))
            {
            	po.ProductSubGrade__c 	= productMap.get(revConMap.get(revConID).RT_Material_Desc__c).RT_Parent_Product__c;
            	po.ProductGrade__c 		= productMap.get(revConMap.get(revConID).RT_Material_Desc__c).RT_Parent_Product__r.RT_Parent_Product__c;
            }
            po.SoldToName__c		= revConMap.get(revConID).RT_Sold_to_Name__c;
            po.Status__c            = 'New';
            po.RT_Country__c        = 'TU';
            po.PriceDate__c			= System.today();
            po.Key_Value__c = revConMap.get(revConID).RT_Key_Value__c;
            po.Condition_Type__c = revConMap.get(revConID).RT_Condition_Type_Name__c;
            poList.add(po);
        }
        
        try{
        poList = RT_Util.buildPriceList(RT_Util.buildPriceWrapper(poList));
        } catch(exception e){System.debug(e);}
		
        System.debug('poList=' + poList.size());
        
        return poList;
    }
    
    // method to upsert data on Price Book
    public static void upsertPriceBooks(List<REV_Contract_Master__c> aureusList, Map<Id, REV_Contract_Master__c> mapRevContract){
        List<RT_Price_Book__c> rtPriceBooks = new List<RT_Price_Book__c>();
        Map<Id, RT_Price_Book__c> priceBookMap 	= new Map<Id, RT_Price_Book__c>();
        List<RT_Price_Book__c> priceBooksUpdateList 	= new List<RT_Price_Book__c>();
        Map<Id, REV_Contract_Master__c> contractMasterMap = new Map<Id, REV_Contract_Master__c>();
        
        Map<Id, REV_Contract_Master__c> mapNewContractMaster = new Map<Id, REV_Contract_Master__c>();
        
        // Id revContractPBrecordTypeId = RT_Util.revContractPricesRecordTypeId;
        rtPriceBooks = RT_Util.queryPriceBooks('and createdDate=Today');
        //priceOutList = [ SELECT SoldToName__r.name,ProductName__r.name,DepotName__r.name,SiteName__r.name,RefineryName__r.name,Approver__r.name,Approver__r.firstname, Approver__r.lastname,Editor__r.name, Editor__r.firstname, Editor__r.lastname,ProductName__r.RT_Parent_Product__c, ProductName__r.RT_Parent_Product__r.RT_Parent_Product__c,AccountType__c,Adjustment__c,Amount__c,Approver__c,AureusAmount__c,Aureus_Data__c,CF_IMM__c,Condition_Type__c,CreatedById,CreatedDate,Defined_Depot_Price__c,Defined_Refinery_Price__c,DepotAbbreviatedName__c,DepotCode__c,DepotName__c,Depot_Price_wo_Tax__c,Depot_Price__c,DEPOT_REFINERY_DIFF__c,DiscountType__c,Editor__c,EMRA__c,Exception__c,Id,ImportProductRatio__c,ImportTerminal__c,IsDeleted,Key_Value__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,MaterialGrade__c,MaterialSubGrade__c,Name,OwnerId,PaymentDescription__c,PriceDate__c,ProductCode__c,ProductName__c,Pump_Price_wo_Tax__c,Pump_Price__c,PUMP_REFINERY_DIFF__c,RefineryCode__c,RefineryName__c,Refinery_Price_wo_Tax__c,Refinery_Price__c,RT_Country__c,SCT__c,Shell_IMM__c,SiteCode__c,SiteName__c,SoldToName__c,SoldToNumber__c,Status__c,TotalPostDiscountPrice__c from RT_PriceOutput__c where id='a3N3G0000004F46UHE'];
        System.debug('Query data-----'+rtPriceBooks);
        if (rtPriceBooks.size() > 0) {
            for (RT_Price_Book__c priceBook : rtPriceBooks) {
                if (!priceBookMap.containsKey(priceBook.RT_Rev_Contract__c)) {
                    priceBookMap.put(priceBook.RT_Rev_Contract__c, priceBook);
                }
            }
        }
        System.debug('Aureus size -----'+aureusList.size()+'Aureus List'+aureusList);
        System.debug('Rev map data-----'+priceBookMap);
        for(REV_Contract_Master__c revContractMaster : aureusList){
            if(priceBookMap.containsKey(revContractMaster.Id)){
                priceBooksUpdateList.add(priceBookMap.get(revContractMaster.Id));
            }else{
                contractMasterMap.put(revContractMaster.Id, revContractMaster);
            }
            
        }
        System.debug('contractMasterMap-----'+contractMasterMap.size());
        System.debug('priceBooksUpdateList-----'+priceBooksUpdateList.size());
        
        if (priceBooksUpdateList.size() > 0) {
            List<RT_Price_Book__c> updatePriceBooks = updateExistingPriceBook(priceBooksUpdateList, mapRevContract);
            update updatePriceBooks;
        }
        if (contractMasterMap.size() > 0) {
            List<RT_Price_Book__c> PBInsertList = insertNewPriceBook(contractMasterMap);
            insert PBInsertList;
        }
    }
    
    public static List<RT_Price_Book__c> updateExistingPriceBook(List<RT_Price_Book__c> pbList, Map<Id, REV_Contract_Master__c> revConMap) {
        for (RT_Price_Book__c pb : pbList) {
            pb.RT_Amount__c = revConMap.get(pb.RT_Rev_Contract__c).RT_AMOUNT__c;
            pb.RT_Condition_Type__c = revConMap.get(pb.RT_Rev_Contract__c).RT_Condition_Type__c;
            pb.RT_Key_Value__c = revConMap.get(pb.RT_Rev_Contract__c).RT_Key_Value__c;
            pb.RT_Product__c = revConMap.get(pb.RT_Rev_Contract__c).RT_Material_Desc__c;
            pb.RT_Sold_to_Name__c = revConMap.get(pb.RT_Rev_Contract__c).RT_Sold_to_Name__c;
            pb.RT_Location__c	= revConMap.get(pb.RT_Rev_Contract__c).RT_Plant_Desc__c;
            pb.RT_Effective_Date__c = System.today();
            pb.RT_Country__c = 'TU';
        }
        return pbList;
    }
    public static List<RT_Price_Book__c> insertNewPriceBook(Map<ID, REV_Contract_Master__c> revConMap){
        List<RT_Price_Book__c> newPBList = new List<RT_Price_Book__c>();

        for(ID revConID : revConMap.keySet() ){
            RT_Price_Book__c pb = new RT_Price_Book__c();
            
            pb.RT_Rev_Contract__c   =revConMap.get(revConID).id;
            pb.RT_Amount__c 		= revConMap.get(revConID).RT_AMOUNT__c;
            pb.RT_Condition_Type__c = revConMap.get(revConID).RT_Condition_Type__c;
            pb.RT_Location__c		= revConMap.get(revConID).RT_Plant_Desc__c;
            pb.RT_Key_Value__c		= revConMap.get(revConID).RT_Key_Value__c;
            pb.RT_Product__c        = revConMap.get(revConID).RT_Material_Desc__c;
            pb.RT_Sold_to_Name__c   = revConMap.get(revConID).RT_Sold_to_Name__c;
            pb.RecordTypeId         = RT_Util.revContractPricesRecordTypeId;
            pb.RT_Effective_Date__c = System.today();
            pb.RT_Country__c        = 'TU';
            
            newPBList.add(pb);
        }
        return newPBList;
    }
    @auraEnabled 
    public static void deactivateOldAureus() {
        List<REV_Contract_Master__c> updateRCM = new List<REV_Contract_Master__c>();
        List<REV_Contract_Master__c> rcList = RT_Util.returnOldAureus();
        system.debug('rcList' +rcList.size());
        if(rcList.size()>0){
            for(REV_Contract_Master__c rcMaster : rcList){
                rcMaster.Active__c = false;
                updateRCM.add(rcMaster);
            }   
        }
        system.debug('updateRCM' +updateRCM.size());
        if(updateRCM.size()>0){
           update updateRCM; 
        }  
    }   
}