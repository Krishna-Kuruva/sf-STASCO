@isTest
public class RV_MRCDataUploadControllerTest {
	static testmethod void testMRCUpload(){
        Location__c loc = new Location__c();
        loc = RV_TestHelperPhase2.insertLocationTBG(loc);
        insert loc;
        
        Product_Catalogue__c prdctCat = new Product_Catalogue__c();
        prdctCat = RV_TestHelperPhase2.insertProductCat(prdctCat);
        insert prdctCat;  
        
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'KREUZMAYR GMBH';
        acc.Sold_To_Number__c = '11790370';
        acc.RecordTypeId =recTypeId;
        acc.Customer_Type__c = 'Sold To';
        insert acc;
        
        String encoded = 'Q29udHJhY3QtSXRlbSxDb250cmFjdCxJdGVtLFNhbGVzIE9yZ2FuaXphdGlvbixTaGlwLXRvIHBhcnR5IFBPIHR5cGUsRGlzdHJpYnV0aW9uIENoYW5uZWwsRGl2aXNpb24sU2FsZXMgRG9jIFR5cGUsVmFsaWQtRnJvbSxWYWxpZC1UbyxQbGFudCxQbGFudCBOYW1lLE1hdGVyaWFsIE5vLE1hdGVyaWFsIERlc2MsU2hpcCBUbyxTaGlwIFRvIE5hbWUsSGFuZGxpbmcgVHlwZSxTaGlwcGluZyBDb25kaXRpb24sTW9kZSBvZiBUcmFuc3BvcnQsUHVyY2hhc2UgT3JkZXIsU29sZCBUbyxTb2xkIFRvIE5hbWUsVmFsaWRpdHkNCjMyMTc5OTM2OS0xMDMwMDQsMzIxNzk5MzY5LDEwMzAwNCxBVDAxLFRTRlAsMiwyLFpDTSwyMDE4MDkwMSw5OTk5MTIzMSxBMDA0LEFUMTAwMyBTYWx6YnVyZyBUQkcgZGVwb3QsNDAwMDAzODE3LFNIIFVMRyA5NSAxMHBwbVMgRTUgVWR5IFVtayBBdXN0cmlhLDExNzkwNjE0LEtSRVVaTUFZUiBHTUJILENBLDEwLCwsMTE3OTAzNzAsQUJDLHZhbGlkDQozMjE3OTkzNjktMTAyMDA0LDMyMTc5OTM2OSwxMDIwMDQsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwNCxBVDEwMDMgU2FsemJ1cmcgVEJHIGRlcG90LDQwMDAwOTkwMyxUUCBBR08gMTBwcG1TIEI3IFVkeSBVbWsgQXVzdHJpYSwxMTc5MDYxNCxLUkVVWk1BWVIgR01CSCxDQSwxMCwsLDExNzkwMzcwLEtSRVVaTUFZUiBHTUJILHZhbGlkDQozMjE3OTg5NzktMTAyMDAzLDMyMTc5ODk3OSwxMDIwMDMsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwMyxBVDEwMDIgTGlueiBkZXBvdCw0MDAwMDIxMzAsVFAgQUdPIDEwcHBtUyBCNyBVZHkgVW1rIEF1c3RyaWEsMTIyNTc4MzQsS0FSTCBUSFJBSU5FUiBIQU5ERUxTIEdNQkgsQ0EsMTAsLCwxMTYyMTIyOSxLQVJMIFRIUkFJTkVSIEhBTkRFTFMgR01CSCx2YWxpZA0KVGVybSBUcmlnZ2VyIE1PR0FTLSxUZXJtIFRyaWdnZXIgTU9HQVMsLCwsLCwsLCwsLCwsLCwsLCwsLCxub3QgdmFsaWQNCjMyMTYzMTE4Mi0xMDAyMDAsMzIxNjMxMTgyLDEwMDIwMCwsLCwsLCwsLCwsLCwsLCwsLCwsbm90IHZhbGlkDQo%3D';
        RV_MRCDataUploadController.saveMRCData('', encoded,'');
        
       
        String updateMRC = 'Q29udHJhY3QtSXRlbSxDb250cmFjdCxJdGVtLFNhbGVzIE9yZ2FuaXphdGlvbixTaGlwLXRvIHBhcnR5IFBPIHR5cGUsRGlzdHJpYnV0aW9uIENoYW5uZWwsRGl2aXNpb24sU2FsZXMgRG9jIFR5cGUsVmFsaWQtRnJvbSxWYWxpZC1UbyxQbGFudCxQbGFudCBOYW1lLE1hdGVyaWFsIE5vLE1hdGVyaWFsIERlc2MsU2hpcCBUbyxTaGlwIFRvIE5hbWUsSGFuZGxpbmcgVHlwZSxTaGlwcGluZyBDb25kaXRpb24sTW9kZSBvZiBUcmFuc3BvcnQsUHVyY2hhc2UgT3JkZXIsU29sZCBUbyxTb2xkIFRvIE5hbWUsVmFsaWRpdHkNCjMyMTc5OTM2OS0xMDMwMDQsMzIxNzk5MzY5LDEwMzAwNCxERTAxLFRTRlAsMiwyLFpDTSwyMDE4MDkwMSw5OTk5MTIzMSxBMDA0LEFUMTAwMyBTYWx6YnVyZyBUQkcgZGVwb3QsNDAwMDAzODE3LFNIIFVMRyA5NSAxMHBwbVMgRTUgVWR5IFVtayBBdXN0cmlhLDExNzkwNjE0LEtSRVVaTUFZUiBHTUJILENBLDEwLCwsMTE3OTAzNzAsQUJDLHZhbGlkDQozMjE3OTkzNjktMTAyMDA0LDMyMTc5OTM2OSwxMDIwMDQsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwNCxBVDEwMDMgU2FsemJ1cmcgVEJHIGRlcG90LDQwMDAwOTkwMyxUUCBBR08gMTBwcG1TIEI3IFVkeSBVbWsgQXVzdHJpYSwxMTc5MDYxNCxLUkVVWk1BWVIgR01CSCxDQSwxMCwsLDExNzkwMzcwLEtSRVVaTUFZUiBHTUJILHZhbGlkDQozMjE3OTg5NzktMTAyMDAzLDMyMTc5ODk3OSwxMDIwMDMsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwMyxBVDEwMDIgTGlueiBkZXBvdCw0MDAwMDIxMzAsVFAgQUdPIDEwcHBtUyBCNyBVZHkgVW1rIEF1c3RyaWEsMTIyNTc4MzQsS0FSTCBUSFJBSU5FUiBIQU5ERUxTIEdNQkgsQ0EsMTAsLCwxMTYyMTIyOSxLQVJMIFRIUkFJTkVSIEhBTkRFTFMgR01CSCx2YWxpZA0KVGVybSBUcmlnZ2VyIE1PR0FTLSxUZXJtIFRyaWdnZXIgTU9HQVMsLCwsLCwsLCwsLCwsLCwsLCwsLCxub3QgdmFsaWQNCjMyMTYzMTE4Mi0xMDAyMDAsMzIxNjMxMTgyLDEwMDIwMCwsLCwsLCwsLCwsLCwsLCwsLCwsbm90IHZhbGlkDQo%3D';
        RV_MRCDataUploadController.saveMRCData('', updateMRC,'');
    }

	static testmethod void testMRCUpload1(){
        Location__c loc = new Location__c();
        loc = RV_TestHelperPhase2.insertLocationTBG(loc);
        insert loc;
        
        Product_Catalogue__c prdctCat = new Product_Catalogue__c();
        prdctCat = RV_TestHelperPhase2.insertProductCat(prdctCat);
        insert prdctCat;  
        
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'KREUZMAYR GMBH';
        acc.Sold_To_Number__c = '11790370';
        acc.RecordTypeId =recTypeId;
        acc.Customer_Type__c = 'Sold To';
        insert acc;
        Id mrcrecTypeId = Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        MRC__c mrcInsert = new MRC__c();
        mrcInsert.RecordTypeId = mrcrecTypeId;
        mrcInsert.Contract__c = '321799369';
        mrcInsert.Item_No_XLS__c = '103004';
        mrcInsert.Sales_Organization__c = 'DE01';
        mrcInsert.PO_Type__c = 'TSFP';
        mrcInsert.Distribution_Channel__c =2;
        mrcInsert.Division__c = 2;
        mrcInsert.Sales_Doc_Type__c = 'ZCM';
        mrcInsert.Valid_From_Date__c = System.today();
        mrcInsert.Valid_To_Date__c = System.today().addyears(100);
        mrcInsert.Plant__c = loc.Id;
        mrcInsert.Product__c = prdctCat.Id;
        mrcInsert.Ship_to_Number__c = '11790614';
        mrcInsert.Ship_to_Name__c ='KREUZMAYR GMBH';
        mrcInsert.Handling_Type__c = 'CA';
        mrcInsert.Shipping_Condition__c = 10;
        mrcInsert.Sold_To__c = acc.Id;
        mrcInsert.Name = mrcInsert.Contract__c+'-'+mrcInsert.Item_No_XLS__c;
        insert mrcInsert;
        System.debug('-----mrcInsert---'+mrcInsert);
        String encoded = 'Q29udHJhY3QtSXRlbSxDb250cmFjdCxJdGVtLFNhbGVzIE9yZ2FuaXphdGlvbixTaGlwLXRvIHBhcnR5IFBPIHR5cGUsRGlzdHJpYnV0aW9uIENoYW5uZWwsRGl2aXNpb24sU2FsZXMgRG9jIFR5cGUsVmFsaWQtRnJvbSxWYWxpZC1UbyxQbGFudCxQbGFudCBOYW1lLE1hdGVyaWFsIE5vLE1hdGVyaWFsIERlc2MsU2hpcCBUbyxTaGlwIFRvIE5hbWUsSGFuZGxpbmcgVHlwZSxTaGlwcGluZyBDb25kaXRpb24sTW9kZSBvZiBUcmFuc3BvcnQsUHVyY2hhc2UgT3JkZXIsU29sZCBUbyxTb2xkIFRvIE5hbWUsVmFsaWRpdHkNCjMyMTc5OTM2OS0xMDMwMDQsMzIxNzk5MzY5LDEwMzAwNCxBVDAxLFRTRlAsMiwyLFpDTSwyMDE4MDkwMSw5OTk5MTIzMSxBMDA0LEFUMTAwMyBTYWx6YnVyZyBUQkcgZGVwb3QsNDAwMDAzODE3LFNIIFVMRyA5NSAxMHBwbVMgRTUgVWR5IFVtayBBdXN0cmlhLDExNzkwNjE0LEtSRVVaTUFZUiBHTUJILENBLDEwLCwsMTE3OTAzNzAsQUJDLHZhbGlkDQozMjE3OTkzNjktMTAyMDA0LDMyMTc5OTM2OSwxMDIwMDQsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwNCxBVDEwMDMgU2FsemJ1cmcgVEJHIGRlcG90LDQwMDAwOTkwMyxUUCBBR08gMTBwcG1TIEI3IFVkeSBVbWsgQXVzdHJpYSwxMTc5MDYxNCxLUkVVWk1BWVIgR01CSCxDQSwxMCwsLDExNzkwMzcwLEtSRVVaTUFZUiBHTUJILHZhbGlkDQozMjE3OTg5NzktMTAyMDAzLDMyMTc5ODk3OSwxMDIwMDMsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwMyxBVDEwMDIgTGlueiBkZXBvdCw0MDAwMDIxMzAsVFAgQUdPIDEwcHBtUyBCNyBVZHkgVW1rIEF1c3RyaWEsMTIyNTc4MzQsS0FSTCBUSFJBSU5FUiBIQU5ERUxTIEdNQkgsQ0EsMTAsLCwxMTYyMTIyOSxLQVJMIFRIUkFJTkVSIEhBTkRFTFMgR01CSCx2YWxpZA0KVGVybSBUcmlnZ2VyIE1PR0FTLSxUZXJtIFRyaWdnZXIgTU9HQVMsLCwsLCwsLCwsLCwsLCwsLCwsLCxub3QgdmFsaWQNCjMyMTYzMTE4Mi0xMDAyMDAsMzIxNjMxMTgyLDEwMDIwMCwsLCwsLCwsLCwsLCwsLCwsLCwsbm90IHZhbGlkDQo%3D';
        RV_MRCDataUploadController.saveMRCData('', encoded,'');
        
        
        String updateMRC = 'Q29udHJhY3QtSXRlbSxDb250cmFjdCxJdGVtLFNhbGVzIE9yZ2FuaXphdGlvbixTaGlwLXRvIHBhcnR5IFBPIHR5cGUsRGlzdHJpYnV0aW9uIENoYW5uZWwsRGl2aXNpb24sU2FsZXMgRG9jIFR5cGUsVmFsaWQtRnJvbSxWYWxpZC1UbyxQbGFudCxQbGFudCBOYW1lLE1hdGVyaWFsIE5vLE1hdGVyaWFsIERlc2MsU2hpcCBUbyxTaGlwIFRvIE5hbWUsSGFuZGxpbmcgVHlwZSxTaGlwcGluZyBDb25kaXRpb24sTW9kZSBvZiBUcmFuc3BvcnQsUHVyY2hhc2UgT3JkZXIsU29sZCBUbyxTb2xkIFRvIE5hbWUsVmFsaWRpdHkNCjMyMTc5OTM2OS0xMDMwMDQsMzIxNzk5MzY5LDEwMzAwNCxERTAxLFRTRlAsMiwyLFpDTSwyMDE4MDkwMSw5OTk5MTIzMSxBMDA0LEFUMTAwMyBTYWx6YnVyZyBUQkcgZGVwb3QsNDAwMDAzODE3LFNIIFVMRyA5NSAxMHBwbVMgRTUgVWR5IFVtayBBdXN0cmlhLDExNzkwNjE0LEtSRVVaTUFZUiBHTUJILENBLDEwLCwsMTE3OTAzNzAsQUJDLHZhbGlkDQozMjE3OTkzNjktMTAyMDA0LDMyMTc5OTM2OSwxMDIwMDQsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwNCxBVDEwMDMgU2FsemJ1cmcgVEJHIGRlcG90LDQwMDAwOTkwMyxUUCBBR08gMTBwcG1TIEI3IFVkeSBVbWsgQXVzdHJpYSwxMTc5MDYxNCxLUkVVWk1BWVIgR01CSCxDQSwxMCwsLDExNzkwMzcwLEtSRVVaTUFZUiBHTUJILHZhbGlkDQozMjE3OTg5NzktMTAyMDAzLDMyMTc5ODk3OSwxMDIwMDMsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwMyxBVDEwMDIgTGlueiBkZXBvdCw0MDAwMDIxMzAsVFAgQUdPIDEwcHBtUyBCNyBVZHkgVW1rIEF1c3RyaWEsMTIyNTc4MzQsS0FSTCBUSFJBSU5FUiBIQU5ERUxTIEdNQkgsQ0EsMTAsLCwxMTYyMTIyOSxLQVJMIFRIUkFJTkVSIEhBTkRFTFMgR01CSCx2YWxpZA0KVGVybSBUcmlnZ2VyIE1PR0FTLSxUZXJtIFRyaWdnZXIgTU9HQVMsLCwsLCwsLCwsLCwsLCwsLCwsLCxub3QgdmFsaWQNCjMyMTYzMTE4Mi0xMDAyMDAsMzIxNjMxMTgyLDEwMDIwMCwsLCwsLCwsLCwsLCwsLCwsLCwsbm90IHZhbGlkDQo%3D';
        RV_MRCDataUploadController.saveMRCData('', updateMRC,'');
    }
    static testmethod void testMRCUpload2(){
        Location__c loc = new Location__c();
        loc = RV_TestHelperPhase2.insertLocationTBG(loc);
        insert loc;
        
        Product_Catalogue__c prdctCat = new Product_Catalogue__c();
        prdctCat = RV_TestHelperPhase2.insertProductCat(prdctCat);
        insert prdctCat;  
        
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'KREUZMAYR GMBH';
        acc.Sold_To_Number__c = '11790370';
        acc.RecordTypeId =recTypeId;
        acc.Customer_Type__c = 'Sold To';
        insert acc;
        Id mrcrecTypeId = Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        MRC__c mrcInsert = new MRC__c();
        mrcInsert.RecordTypeId = mrcrecTypeId;
        mrcInsert.Contract__c = '321799369';
        mrcInsert.Item_No_XLS__c = '103004';
        mrcInsert.Sales_Organization__c = 'DE01';
        mrcInsert.PO_Type__c = 'TSFP';
        mrcInsert.Distribution_Channel__c =2;
        mrcInsert.Division__c = 2;
        mrcInsert.Sales_Doc_Type__c = 'ZCM';
        mrcInsert.Valid_From_Date__c = System.today();
        mrcInsert.Valid_To_Date__c = System.today().addyears(100);
        mrcInsert.Plant__c = loc.Id;
        mrcInsert.Product__c = prdctCat.Id;
        mrcInsert.Ship_to_Number__c = '11790614';
        mrcInsert.Ship_to_Name__c ='KREUZMAYR GMBH';
        mrcInsert.Handling_Type__c = 'CA';
        mrcInsert.Shipping_Condition__c = 10;
        mrcInsert.Sold_To__c = acc.Id;
        mrcInsert.Name = mrcInsert.Contract__c+'-'+mrcInsert.Item_No_XLS__c;
        insert mrcInsert;
        System.debug('-----mrcInsert---'+mrcInsert);
        String encoded = 'Q29udHJhY3QtSXRlbSxDb250cmFjdCxJdGVtLFNhbGVzIE9yZ2FuaXphdGlvbixTaGlwLXRvIHBhcnR5IFBPIHR5cGUsRGlzdHJpYnV0aW9uIENoYW5uZWwsRGl2aXNpb24sU2FsZXMgRG9jIFR5cGUsVmFsaWQtRnJvbSxWYWxpZC1UbyxQbGFudCxQbGFudCBOYW1lLE1hdGVyaWFsIE5vLE1hdGVyaWFsIERlc2MsU2hpcCBUbyxTaGlwIFRvIE5hbWUsSGFuZGxpbmcgVHlwZSxTaGlwcGluZyBDb25kaXRpb24sTW9kZSBvZiBUcmFuc3BvcnQsUHVyY2hhc2UgT3JkZXIsU29sZCBUbyxTb2xkIFRvIE5hbWUsVmFsaWRpdHkNCjMyMTc5OTM2OS0xMDMwMDQsMzIxNzk5MzY5LDEwMzAwNCxBVDAxLFRTRlAsMiwyLFpDTSwyMDE4MDkwMSw5OTk5MTIzMSxBMDA0LEFUMTAwMyBTYWx6YnVyZyBUQkcgZGVwb3QsNDAwMDAzODE3LFNIIFVMRyA5NSAxMHBwbVMgRTUgVWR5IFVtayBBdXN0cmlhLDExNzkwNjE0LEtSRVVaTUFZUiBHTUJILENBLDEwLCwsMTE3OTAzNzAsQUJDLHZhbGlkDQozMjE3OTkzNjktMTAyMDA0LDMyMTc5OTM2OSwxMDIwMDQsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwNCxBVDEwMDMgU2FsemJ1cmcgVEJHIGRlcG90LDQwMDAwOTkwMyxUUCBBR08gMTBwcG1TIEI3IFVkeSBVbWsgQXVzdHJpYSwxMTc5MDYxNCxLUkVVWk1BWVIgR01CSCxDQSwxMCwsLDExNzkwMzcwLEtSRVVaTUFZUiBHTUJILHZhbGlkDQozMjE3OTg5NzktMTAyMDAzLDMyMTc5ODk3OSwxMDIwMDMsQVQwMSxUU0ZQLDIsMixaQ00sMjAxODA5MDEsOTk5OTEyMzEsQTAwMyxBVDEwMDIgTGlueiBkZXBvdCw0MDAwMDIxMzAsVFAgQUdPIDEwcHBtUyBCNyBVZHkgVW1rIEF1c3RyaWEsMTIyNTc4MzQsS0FSTCBUSFJBSU5FUiBIQU5ERUxTIEdNQkgsQ0EsMTAsLCwxMTYyMTIyOSxLQVJMIFRIUkFJTkVSIEhBTkRFTFMgR01CSCx2YWxpZA0KVGVybSBUcmlnZ2VyIE1PR0FTLSxUZXJtIFRyaWdnZXIgTU9HQVMsLCwsLCwsLCwsLCwsLCwsLCwsLCxub3QgdmFsaWQNCjMyMTYzMTE4Mi0xMDAyMDAsMzIxNjMxMTgyLDEwMDIwMCwsLCwsLCwsLCwsLCwsLCwsLCwsbm90IHZhbGlkDQo%3D';
        RV_MRCDataUploadController.saveMRCData('', encoded,'');
        
        
        String updateMRC = 'Q29udHJhY3QtSXRlbSxDb250cmFjdCxJdGVtLFNhbGVzIE9yZ2FuaXphdGlvbixTaGlwLXRvIHBhcnR5IFBPIHR5cGUsRGlzdHJpYnV0aW9uIENoYW5uZWwsRGl2aXNpb24sU2FsZXMgRG9jIFR5cGUsVmFsaWQtRnJvbSxWYWxpZC1UbyxQbGFudCxQbGFudCBOYW1lLE1hdGVyaWFsIE5vLE1hdGVyaWFsIERlc2MsU2hpcCBUbyxTaGlwIFRvIE5hbWUsSGFuZGxpbmcgVHlwZSxTaGlwcGluZyBDb25kaXRpb24sTW9kZSBvZiBUcmFuc3BvcnQsUHVyY2hhc2UgT3JkZXIsU29sZCBUbyxTb2xkIFRvIE5hbWUsVmFsaWRpdHkNCjMyMTc5OTM2OS0xMDMwMDQsMzIxNzk5MzY5LDEwMzAwNCxERTAxLFRTRlAsMiwyLFpDTSwyMDE4MDkwMSw5OTk5MTIzMSxBMDA0LEFUMTAwMyBTYWx6YnVyZyBUQkcgZGVwb3QsNDAwMDAzODE3LFNIIFVMRyA5NSAxMHBwbVMgRTUgVWR5IFVtayBBdXN0cmlhLDExNzkwNjE0LEtSRVVaTUFZUiBHTUJILENBLDEwLCwsMTE3OTAzNzAsQUJDLG5vdCB2YWxpZA0KMzIxNzk5MzY5LTEwMjAwNCwzMjE3OTkzNjksMTAyMDA0LEFUMDEsVFNGUCwyLDIsWkNNLDIwMTgwOTAxLDk5OTkxMjMxLEEwMDQsQVQxMDAzIFNhbHpidXJnIFRCRyBkZXBvdCw0MDAwMDk5MDMsVFAgQUdPIDEwcHBtUyBCNyBVZHkgVW1rIEF1c3RyaWEsMTE3OTA2MTQsS1JFVVpNQVlSIEdNQkgsQ0EsMTAsLCwxMTc5MDM3MCxLUkVVWk1BWVIgR01CSCx2YWxpZA0KMzIxNzk4OTc5LTEwMjAwMywzMjE3OTg5NzksMTAyMDAzLEFUMDEsVFNGUCwyLDIsWkNNLDIwMTgwOTAxLDk5OTkxMjMxLEEwMDMsQVQxMDAyIExpbnogZGVwb3QsNDAwMDAyMTMwLFRQIEFHTyAxMHBwbVMgQjcgVWR5IFVtayBBdXN0cmlhLDEyMjU3ODM0LEtBUkwgVEhSQUlORVIgSEFOREVMUyBHTUJILENBLDEwLCwsMTE2MjEyMjksS0FSTCBUSFJBSU5FUiBIQU5ERUxTIEdNQkgsdmFsaWQNClRlcm0gVHJpZ2dlciBNT0dBUy0sVGVybSBUcmlnZ2VyIE1PR0FTLCwsLCwsLCwsLCwsLCwsLCwsLCwsbm90IHZhbGlkDQozMjE2MzExODItMTAwMjAwLDMyMTYzMTE4MiwxMDAyMDAsLCwsLCwsLCwsLCwsLCwsLCwsLG5vdCB2YWxpZA0K';
        RV_MRCDataUploadController.saveMRCData('', updateMRC,'');
    }
}