/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class OLF_MRCDataHelper {
    
    public static Map<String, Decimal> getAtpforPlant(Set<string> plantCodeSet, Id accId, List<String> trancheList){
        
        Map<String ,Decimal> atpLocTrancheMap = new Map<String, Decimal >();
        Map<String ,Decimal> atpLocTrancheVsVolMap = new Map<String, Decimal>();
        Map<String,Decimal> locGrdSalesPerCustMap = new Map<String, Decimal>();
        List<ATP__c> atpList = [SELECT Id,
                                Name,
                                Location__c,
                                Location__r.Name,
                                ATP_Live__c,
                                Live_Online_00_14__c,
                                Live_Online_ATP2__c,
                                Live_Online_ATP3__c,
                                Volume_Cap_Customer__c, 
                                Vol_Cap_Customer_ATP2__c,
                                Vol_Cap_Customer_ATP3__c,
                                Plant_Code__c,
                                Grade_Level2__c from ATP__c WHERE Plant_Code__c  IN : plantCodeSet];
        for(String tranche : trancheList){
            if(tranche == 'ATP1'){
                atpLocTrancheMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Live_Online_00_14__c', tranche));
                atpLocTrancheVsVolMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Volume_Cap_Customer__c', tranche));
            }
            else if(tranche == 'ATP2'){
                atpLocTrancheMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Live_Online_ATP2__c', tranche));
                atpLocTrancheVsVolMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Vol_Cap_Customer_ATP2__c', tranche));
            }
            else if(tranche == 'ATP3'){
                atpLocTrancheMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Live_Online_ATP3__c', tranche));
                atpLocTrancheVsVolMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Vol_Cap_Customer_ATP3__c', tranche));
            }
        }
        if(!atpLocTrancheMap.isEmpty() && !atpLocTrancheVsVolMap.isEmpty()){
            locGrdSalesPerCustMap = OLF_Utility.getCustomerSpecificVolume(atpLocTrancheVsVolMap, accId, trancheList);
            for(String plantGrd: atpLocTrancheMap.keyset()){
                if(locGrdSalesPerCustMap.containsKey(plantGrd)){
                    if(locGrdSalesPerCustMap.get(plantGrd) < atpLocTrancheMap.get(plantGrd)){
                        atpLocTrancheMap.put(plantGrd, locGrdSalesPerCustMap.get(plantGrd));
                    }
                }
            }
        }
        return atpLocTrancheMap;
        
        
        //END ||| Rahul Sharma | Date - 27-Jan-2021 : Updated logic to get ATP and available volume based on tranches.
    }
    public static List<RV_SHT_CreateController.MRCDataWrap>  getMRCRecordsData(String tranche ,Set<Id> accountIds,string contractStartDate,string contractEndDate)
    {
        System.debug('=========contractStartDate==========='+contractStartDate);
        System.debug('=========contractEndDate==========='+contractEndDate);
        if(contractStartDate!=null && contractStartDate!='')
        {
            //Fix_252970_30Apr2019_Soumyajit starts
            if(	date.valueOf(contractStartDate) < system.today()
              ){
                  contractStartDate=String.valueOf(System.today());
                  if(date.valueOf(contractEndDate) <= system.today())
                      contractEndDate=String.valueOf(System.today());
                  else
                      contractEndDate=String.valueOf(System.today().addDays(13));
              }
            if(date.valueOf(contractStartDate)> date.valueOf(contractEndDate)){
                contractEndDate=String.valueOf(date.valueOf(contractStartDate).addDays(13));
            }
        }
        // System.debug('contractStartDate==>'+contractStartDate+'contractEndDate==>'+contractEndDate);
        Set<String> productSet= new Set<String>{'AGO B7','AGO B0','AGO B0 CH','AGO VPD','GTL B0','GTL B7','IGO 50ppm','IGO 1000ppm','IGO 10ppm','ULG95 E5','ULG95_BOB_E5','ULG95_BOB_E10','ULG95 E10','ULG98','ULG95 E0','ULG100 VP','AVGAS'};
            
            
            Map<String , ATP__c >  atpLocMap = new Map<String , ATP__c >();
        // decimal astmAgoIgo=Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
        //decimal astmMogas= Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon);
        List<RV_SHT_CreateController.MRCDataWrap> mrcWrapList = new List<RV_SHT_CreateController.MRCDataWrap>();
        
        
        List<MRC__c> mrcfinalList = new List<MRC__c>();
        //get Product custom settings
        Map<String,String> productMap = new Map<String,String>();
        List<Product_Name_Mapping__mdt> productMapMD = [SELECT ID,MasterLabel,DeveloperName,Product_Name__c from Product_Name_Mapping__mdt];
        for(Product_Name_Mapping__mdt mdt : productMapMD){
            productMap.put(mdt.MasterLabel, mdt.Product_Name__c);
        }
        
        //Get MRC Data
        List<MRC__c> mrcList = new List<MRC__c>();
        Id recTypeId=Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        String query='select id,name,Plant__c,Plant__r.Name,Plant__r.Country__c,Plant_code__c,'+
            'Supply_Type__c,Product__c,Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,Material_Description__c,Material_Name__c,PO_Type__c,'+
            ' Sold_To__c,Sold_To__r.Name,Sold_To__r.Rv_Olf_Customer_Email__c,Ship_To__c,Ship_To__r.Name,Ship_To__r.Rv_Olf_Customer_Email__c,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,'+
            ' Ship_to_Name__c,Shipping_Condition__c,Online_Location_Name__c,Online_Material_Name_Taxed__c,'+
            ' Online_Material_Name_UnTaxed__c,Online_Customer_Name__c from MRC__c WHERE Active__c = true AND Rv_Available_for_OLF__c = true  AND Ship_To__c IN :accountIds and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY' ;
        //' Online_Material_Name_UnTaxed__c,Online_Customer_Name__c from MRC__c WHERE Active__c = true  AND Ship_To__c IN :accountIds and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY' ;
        
        string queryOrderBy=' ORDER BY MRC_Number__c,Plant__r.Name,MRC_Grade_Sort__c';
        
        string queryString=query+queryOrderBy;
        //   system.debug('queryString::'+queryString);
        mrcList = Database.query (queryString);
        // system.debug('checked::'+mrcList.size());
        //remove ULG95 E5 and 98
        
        
        mrcfinalList.addAll(mrcList);
        
        //Added by Surbhi , PBI-1600304
        RV_SPCalculationController.isOlfDeal = true;
        //Ended by Surbhi, PBI-1600304
        
        //Added by Surbhi, PBI-1725277
        RV_SPCalculationController.tranche = tranche;
        //Ended by Surbhi, PBI-1725277
        //setting Inut data wrap for price calculation
        List<RV_SPCalculationController.salesPriceWrap> salesPriceWrapLst=new List<RV_SPCalculationController.salesPriceWrap>();
        List<RV_SPCalculationController.salesPriceWrap> finalSalesPriceWrapLst=new List<RV_SPCalculationController.salesPriceWrap>();
        RV_SPCalculationController.salesPriceCalAndAuditWrap spAdtWrp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
        spAdtWrp=RV_SPCalculationController.getCalulatedSp(mrcfinalList,date.valueOf(contractStartDate),date.valueOf(contractEndDate));
        salesPriceWrapLst=spAdtWrp.salesPriceWrpLst;
        finalSalesPriceWrapLst.addAll(salesPriceWrapLst);
        salesPriceWrapLst=null;
        Map<String,RV_SPCalculationController.salesPriceWrap> mrcNoSPwrap= new Map<String,RV_SPCalculationController.salesPriceWrap>();
        for(RV_SPCalculationController.salesPriceWrap spwrp:finalSalesPriceWrapLst){
            mrcNoSPwrap.put(spwrp.mrcNo,spwrp); //Map of Sp and MRC
        }
        Set<Id> LocIds= new Set<Id>();
        for(MRC__c mr:mrcList){
            LocIds.add(mr.Plant__c);
        }
        //Deal Event Manager metadata
        Map<String,Deal_Event_Manager__mdt> poTypeHandlingDealMdtMap=RV_SHT_CreateController.getDealEventMetdataMap();
        
        //create wraper object 
        RV_SHT_CreateController.MRCDataWrap wrapObj ;
        Decimal atpVal = 0;
        string grade = '';
        
        
        for(MRC__c mrcObj : mrcfinalList){
            wrapObj = new RV_SHT_CreateController.MRCDataWrap();
            //  System.debug('After MRC '+mrcObj.MRC_Number__c+' '+mrcObj.Ship_To__r.Rv_Olf_Customer_Email__c+' '+otmMRCMap.get(mrcObj.Name));
            
            atpVal =0;
            wrapObj.mrcId = mrcObj.id;
            if( mrcObj.Material_Description__c != null){
                grade = mrcObj.Material_Description__c;
            }
            wrapObj.grade = grade;
            if(mrcObj.Sold_To__c != null){
                wrapObj.accId=mrcObj.Sold_To__c;
                if(mrcObj.Sold_To__r.Name.length()>20)
                    wrapObj.accName=mrcObj.Sold_To__r.Name.subString(0,20);
                else
                    wrapObj.accName=mrcObj.Sold_To__r.Name;
                
                //Added By Sampada Bhat
                if(mrcObj.Sold_To__r.Rv_Olf_Customer_Email__c != null){
                    wrapObj.contactEmail = String.valueOf(mrcObj.Sold_To__r.Rv_Olf_Customer_Email__c);
                }else if(mrcObj.Ship_To__r.Rv_Olf_Customer_Email__c != null){
                    wrapObj.contactEmail = String.valueOf(mrcObj.Ship_To__r.Rv_Olf_Customer_Email__c);
                    
                }
            }
            if(mrcObj.Online_Customer_Name__c != null){
                wrapObj.accName=mrcObj.Online_Customer_Name__c;
            }
            wrapObj.mrcName = mrcObj.Name;
            wrapObj.salesOrg =mrcObj.Sales_Organization__c;
            //Added by Sampada.Bhat
            if(mrcObj.Product__r.Name != null){
                wrapObj.materialNo =(mrcObj.Product__r.Name).right(4);
            }
            wrapObj.materialName=mrcObj.Material_Name__c;
            wrapObj.shipToNumber = mrcObj.Ship_to_Number__c;
            wrapObj.locationId=mrcObj.Plant__c;
            wrapObj.location = mrcObj.Plant_Code__c;
            if(mrcObj.Online_Location_Name__c != null){
                wrapObj.locationName = mrcObj.Online_Location_Name__c;
            }
            
            //Get  ATP values for Account based on Material Number
            String prdtName = productMap.get(grade);
            //Deal Event Manager Attributes for Pricing ,Vol deduction & Hedging
            wrapObj.isPricingTaxed=false;
            
            
            string key=mrcObj.PO_Type__c+mrcObj.Handling_Type__c;
            String otherKey=mrcObj.PO_Type__c+'Others';
            // system.debug('GSAP key==>'+key+'otherKey==>'+otherKey);
            //  system.debug('GSAP MRC key==>'+ShipCondNoNameMap.get(Integer.valueOf(mrcObj.Shipping_Condition__c)));
            string finalKey;
            Deal_Event_Manager__mdt dealEvent;
            if(poTypeHandlingDealMdtMap.containsKey(key)){
                dealEvent=poTypeHandlingDealMdtMap.get(key);
                //system.debug('dealEvent2==>'+dealEvent);
            }
            else if(poTypeHandlingDealMdtMap.containsKey(otherKey)){
                dealEvent=poTypeHandlingDealMdtMap.get(otherKey);
                //system.debug('dealEvent1==>'+dealEvent);
            }
            //system.debug('dealEvent==>'+dealEvent);
            if(dealEvent != null){
                wrapObj.isPricingTaxed=dealEvent.IsPricingTaxed__c;
                
                
                //Online Material Name for OLF Based on taxation
                if(wrapObj.isPricingTaxed && mrcObj.Online_Material_Name_Taxed__c != null){
                    wrapObj.materialName=mrcObj.Online_Material_Name_Taxed__c;
                }else if(!wrapObj.isPricingTaxed && mrcObj.Online_Material_Name_UnTaxed__c !=null){
                    wrapObj.materialName=mrcObj.Online_Material_Name_UnTaxed__c;
                }else{
                    wrapObj.materialName=mrcObj.Material_Name__c;
                }
                
                // system caLCULATED price euro/100L
                IF(mrcNoSPwrap.get(mrcObj.Name) != null){
                    if(mrcNoSPwrap.get(mrcObj.Name).OTM != null){
                        wrapObj.OTM=((mrcNoSPwrap.get(mrcObj.Name)).OTM).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                //END - Rahul Sharma | Date - 28-Jan-2021 | PBI-702438 : Updated pricePerVol as 0 for zero price deal. 
                mrcWrapList.add(wrapObj);
            }
        }
        if(!mrcWrapList.isEmpty())
            return mrcWrapList;
        else
            return null;
    }
    public static void sendEmailandDeactivate(String className,String errorMessage){
        try{
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // String[] toAddresses = new String[] {'sampada.bhat@shell.com'}; 
            //    String[] ccAddresses = new String[] {'sampada.bhat@shell.com'};
            List<String> toAddresses = Label.RV_OLFExceptionEmailToAddress.split(';');
            List<String> ccAddresses = Label.RV_OLFExceptionEmailCCAddress.split(';');
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);            
            mail.setSenderDisplayName('Salesforce support');           
            // Specify the subject line for your email address.
            mail.setSubject('Class Exception : ' + className);            
            // Set to True if you want to BCC yourself on the email.
            mail.setBccSender(false);
            
            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(true);
            
            // Specify the text content of the email.
            mail.setPlainTextBody(className+' Exception  : ' + errorMessage);
            
            mail.setHtmlBody('<p>'+className+' Exception  '+errorMessage+ '</p>');
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            //Inactive OLF Connection
            OLF_DashboardApexController.userActivateInactivateFromScreen('STOP');
        }catch(Exception ex){
            System.debug('Email error');
        }
    }
}