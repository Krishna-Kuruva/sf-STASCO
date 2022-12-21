/**
 * Created by Dharmendra.Singh2 on 1/5/2021.
 */

@IsTest
private class RV_MRCInsertWebserviceClassTest {
    @IsTest
    static void testMRC() {
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Sold_To_Number__c = '11113864';
        accInsert.Customer_Type__c = 'Sold To';
        insert accInsert;
        
        Account accInsert2 = new Account();
        Id recTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Ship_To').getRecordTypeId();
        accInsert2 = RV_TestHelper.insertAccount(accInsert2);
        accInsert2.Ship_to_Number__c = '11102253';
        accInsert2.Rv_Olf_Customer_Email__c='test@abc.com';
        accInsert2.Customer_Type__c = 'Ship To';
        accInsert2.recordTypeId = recTypeId;
        accInsert2.ParentId = accInsert.Id;
       // insert accInsert2;
        
        Location__c loc=new Location__c();
        loc=RV_TestHelper.insertLocation(loc);
        loc.Plant_Code__c = 'D003';
        insert loc;
        
        Product_Catalogue__c pc=new Product_Catalogue__c();
        pc=RV_TestHelper.insertProductCat(pc);
        pc.Online_Material_Name_Taxed__c='Diesel B7';
        pc.Online_Material_Name_UnTaxed__c='Diesel B7, unversteuert';
        pc.Commodity_Grade_L2__c='AGO B7';
        pc.Marketing_Cost__c = 0.014;
        pc.Name = '400003805';
        insert pc;

        String preq = '{'+
                ' "ActionInd":"C",'+
                ' "MRCNo":"320076190",'+
                ' "SalesDoctype":"ZCM",'+
                ' "ShipToPOtype":"TSFP",'+
                ' "SalesOrg":"DE01",'+
                ' "DistributionChannel":"2",'+
                ' "Division":"2",'+
                ' "ValidFrom":"2021-01-01",'+
                ' "ValidTo":"2022-12-31",'+
                ' "SoldTo":"11113864",'+
                ' "SoldToName":"ADAM OMMERT MINERALOELHANDEL",'+
                ' "ShipTo":"11102253",'+
                ' "ShipToName":"ADAM OMMERT MINERALOELHANDEL",'+
                ' "ShippingCondition":"10",'+
                ' "Description": "",'+
                ' "ShipCondDescription": "",'+
                ' "SoldToDelFlgAllArea":"",'+
                ' "SoldToDelFlgSaleArea":"",'+
                ' "SoldToNatiAccPart":"",'+
                ' "SoldToNatiAccPartName":"",'+
                ' "SoldToPrimSalesRep":"",'+
                ' "SoldToPrimSalesRepName":"",'+
                ' "SoldToSalesGrp":"",'+
                ' "SoldToSalesGrpDescrp":"",'+
                ' "ShipToPrimrySalesRepr":"",'+
                ' "ShipToPrimrySalesReprName":"",'+
                ' "ShipToSalesGrp":"",'+
                ' "ShipToSalesGrpDesc":"",'+
                ' "MRCItemList":[ '+
                '	{ '+
                ' "MRCItemNo":"103003",'+
                ' "MRCNumber":"320076188",'+
                ' "PlantCode":"D003",'+
                ' "PlantName":"Flörsheim Shell Depot",'+
                ' "MaterialNumber":"400003805",'+
                ' "MaterialDescription":"SH ULG95 10ppmS E10 UdyUmk LowDose DE",'+
                ' "HandlingType":"CA",'+
                ' "ReasonforRejectionCode":"",'+
                ' "ReasonforRejectionMessage":"",'+
                ' "ModeofTransport":"1",'+
                ' "ExterMOTDesc" : "",'+
                ' "incoTermsPart1" : "",'+
                ' "incoTermsPart2" : "",'+
                ' "PaymentTerms" : "Z011",'+
                ' "PaymentTermsDescrp" : "",'+
                ' "ValuationType" : "",'+
                ' "CondGroup2" : "",'+
                ' "CondGroup2Desc" : "",'+
                ' "InvoiceDate" : "",'+
                ' "InvoiceDateDesc" : "",'+
                ' "Paymentmethod" : "",'+
                ' "PaymentmethodDesc" : ""'+
                '	},'+
                '	{ '+
                ' "MRCItemNo":"101011",'+
                ' "MRCNumber":"320076188",'+
                ' "PlantCode":"D011",'+
                ' "PlantName":"Raunheim Unitank Depot",'+
                ' "MaterialNumber":"400002410",'+
                ' "MaterialDescription":"BF IGO 50ppmS B0 Dye Mkd Germany",'+
                ' "HandlingType":"EB11111111111",'+
                ' "ReasonforRejectionCode":"",'+
                ' "ReasonforRejectionMessage":"",'+
                ' "ModeofTransport":"1",'+
                ' "ExterMOTDesc" : "",'+
                ' "incoTermsPart1" : "",'+
                ' "incoTermsPart2" : "",'+
                ' "PaymentTerms" : "Z011",'+
                ' "PaymentTermsDescrp" : "",'+
                ' "ValuationType" : "",'+
                ' "CondGroup2" : "",'+
                ' "CondGroup2Desc" : "",'+
                ' "InvoiceDate" : "",'+
                ' "InvoiceDateDesc" : "",'+
                ' "Paymentmethod" : "",'+
                ' "PaymentmethodDesc" : ""'+
                '	}, '+
                '	{ '+
                ' "MRCItemNo":"101012", '+
                ' "MRCNumber":"320076188",'+
                ' "PlantCode":"D011",'+
                ' "PlantName":"Raunheim Unitank Depot",'+
                ' "MaterialNumber":"400002410",'+
                ' "MaterialDescription":"BF IGO 50ppmS B0 Dye Mkd Germany",'+
                ' "HandlingType":"EB",'+
                ' "ReasonforRejectionCode":"",'+
                ' "ReasonforRejectionMessage":"",'+
                ' "ModeofTransport":"1",'+
                ' "ExterMOTDesc" : "",'+
                ' "incoTermsPart1" : "",'+
                ' "incoTermsPart2" : "",'+
                ' "PaymentTerms" : "",'+
                ' "PaymentTermsDescrp" : "",'+
                ' "ValuationType" : "",'+
                ' "CondGroup2" : "",'+
                ' "CondGroup2Desc" : "",'+
                ' "InvoiceDate" : "",'+
                ' "InvoiceDateDesc" : "",'+
                ' "Paymentmethod" : "",'+
                ' "PaymentmethodDesc" : ""'+
                '	} '+

                ' ] '+
                '}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createMRC' ;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(preq);
        RestContext.request = req;
        RestContext.response= res;
		
        Test.startTest();
        RV_MRCInsertWebserviceClass.createMRCStagings();
        Test.stopTest();

    }
}