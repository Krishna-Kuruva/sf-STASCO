@isTest
global class BET_BDD_MockHttpResp_Orbis implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        
        if(req.getEndpoint() == 'https://test.salesforce.com/services/oauth2/token'){
            string response='{"access_token":"SESSION_ID_REMOVED","instance_url":"https://stasco--betdev.my.salesforce.com","id":"https://test.salesforce.com/id/00D3G0000008jbYUAQ/0053G000000VhgSQAS","token_type":"Bearer","issued_at":"1599292917370","signature":"PjqQxdEd9itpomPELkqAWkmBLBl8pupssCBNimVuFm8="}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().contains('BET_BDD/Orbis') && !req.getEndpoint().contains('BET_BDD/Orbis/UploadKycDocToSharePoint') && !req.getEndpoint().contains('BET_BDD/Orbis/UploadFinDocToSharePoint')){
            system.debug('req--'+req);
            
            String response='{"resultPayload": {"searchSummary": {"databaseInfo": { "releaseNumber": "200","updateNumber": "200005","updateDate": "2020-09-18T00:00:00","versionNumber": "129.00" },'+
                ' "sortBy": {"descOrder": "OPRE"}},"data": [{"name": "SBI HOLDINGS, INC","namE_INTERNATIONAL": "SBI HOLDINGS, INC","bvdid": "JP6010401045208","status": ["Active"],'+
                '"lei": "353800L6LMHYIPSMRQ17","giin": ["2KZ1C1.00000.LE.392"],"tin": "6010401045208","vaT_NUMBER": ["6010401045208"],"nationaL_ID_LABEL": null,'+
                '"address_Line1_Additional": ["R FLORIZEL MALHEIROS ARAUJO 181","R FLORIZEL MALHEIROS ARAUJO 181","R ACROPOLE 2458"],'+
                '"address_Line2_Additional": ["TAYAMA PARK","TAYAMA PARK","VILA DANUBIO AZUL"],'+
                '"address_Line3_Additional": [null,null,null],"address_Line4_Additional": [null,null,null],'+
                '"postcodE_ADDITIONAL": ["79036-410","79540","79036-030"],"citY_ADDITIONAL": ["CAMPO GRANDE","CASSILANDIA","CAMPO GRANDE"],"countrY_ADDITIONAL": ["Brazil","Brazil","Brazil"],'+
                '"addresS_LINE1": "1-6-1 ROPPONGI, MINATO-KU","addresS_LINE2": "","addresS_LINE3": "","postcode": "106-6019","city": "TOKYO",'+
                '"country": "Japan","productS_SERVICES": "Offers securities business; banking business; insurance business; financial media business; proprietary trading system;'+
                ' forex margin trading; face-to-face sales channels; other financial services; venture capital; buyout investment; overseas development; 5-ALA related business; research and development for medical products; and rent guarantee services [source: Bureau van Dijk]",'+
                '"europeaN_VAT_NUMBER": "12345","uS_STATE": "","tradE_REGISTER_NUMBER": ["1234567"],"akA_NAME": [],"bO_STATUS": "This company is listed. 48 beneficial owners.","bO_NAME": ["MR ANDREW TELFER"],'+
                '"naicS2017_CORE_CODE": "5511","incorporatioN_STATE": "","naicS2017_CORE_LABEL": "Management of Companies and Enterprises","worldcompliancE_MATCH_SANCTION_INDICATOR": "No","worldcompliancE_MATCH_CURRENT_PEP_INDICATOR": "No",'+
                '"worldcompliancE_MATCH_ADVERSE_MEDIA_INDICATOR": "No"}]},"responseMessage": "Success","isSuccess": true,"responseCode": 200}';            
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().contains('callout:BET_BDD/Bankers') && !req.getEndpoint().contains('BET_BDD/Bankers/baid') && !req.getEndpoint().contains('BET_BDD/Bankers/UploadFinDocToSharePoint') &&
                !req.getEndpoint().contains('BET_BDD/Bankers/UploadKycDocToSharePoint')){
                    system.debug('req--'+req);
                    
                    String response='{"resultPayload": {"totalResults": 8,"displayedResults": 8,"results": [{"legalEntity": {"bankersAlmanacId": "71562","linkToFullDetails": "https://api.bankersalmanac.com/fulldetails/baid/71562",'+
                        '"names": [{"type": "Legal Title","value": "SBI Bank Limited Liability Company"}],'+
                        '"status": "active","type": "Bank","lei": "253400HGXRLW3EFSMC03","noOfDomesticOffices": 1,"noOfForeignOffices": 0},"office": {"officeId": "71562-0",'+
                        '"names": [{"type": "Office Name","value": "Leningradskiy Avenue"}],"types": ["Registered Office","Head Office"],"status": "active","giin": ["PZA85W.99999.SL.643"],'+
                        '"location": {"id": "59248","streetAddress": {"addressLine1": "bld.2., bld.3.","addressLine2": "Leningradskiy Avenue 72","addressLine3": null,"addressLine4": null'+
                        '},"area": null,"city": "Moscow","country": {"name": "Russian Federation","iso3": "RUS"},"postalCode": "125315","subArea": null},'+
                        '"swiftBICs": ["OBIBRUMM"],"clearingCodes": [],"linkToFullDetails": null}}]},"responseMessage": "Success","isSuccess": true,"responseCode": 200}';
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody(response);
                    res.setStatusCode(200);
                }else if(req.getEndpoint().contains('BET_BDD/Bankers/baid')){
                    system.debug('req--'+req);
                    
                    StaticResource srObject = [select id,body from StaticResource Where Name = 'BankersBaidResponse'];
                    String contents = srObject.body.toString();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody(contents);
                    res.setStatusCode(200);
                }
        else if(req.getEndpoint().contains('callout:BET_BDD_GTMI/GTMI')){
            system.debug('req--'+req);
            
            String response='{"resultPayload": [{"reG_ID": "","reG_ID_TYP": "","goldtieR_ID": 256201,"legaL_NAME": "SBI Equity Hybrid Fund","shorT_NAME": "SBI Equity Hybrid Fund",'+
                '"dD_LEVEL": "Related Party","policY_STS": "","policY_STS_DT": "","legaL_CNTRY": "India","dD_LEVEL_APPRD": "","entitY_TYP": "Bank/Financial Institution","dndB_LIST": "N",'+
                '"reC_ACTIVE_FLAG": "Y","shiP_ID_NO_IMO": "","apprD_WITH_CONDITIONS_FLAG": "","rejecteD_WITH_CONDITIONS_FLAG": ""}],"responseMessage": "Success","isSuccess": true,'+
                '"responseCode": 200}';
            res.setBody(response);
            res.setStatusCode(200);
        }
        else if((req.getEndpoint().contains('callout:BET_BDD/Vies/GetVIESData') || req.getEndpoint().contains('callout:BET_BDD/Sovos') ||
                req.getEndpoint().contains('callout:BET_BDD/Ofac')) && !req.getEndpoint().contains('BET_BDD/Sovos/UploadSovosData')){
                system.debug('req--'+req);
                String response='{"resultPayload": "Test","responseMessage": "Success","isSuccess": true,"responseCode": 200}';
                res.setBody(response);
                res.setStatusCode(200);
                }
        else if(req.getEndpoint().contains('BET_BDD/Bankers/UploadFinDocToSharePoint') || req.getEndpoint().contains('BET_BDD/Vies/UploadViesData') ||req.getEndpoint().contains('BET_BDD/Orbis/UploadKycDocToSharePoint')
                || req.getEndpoint().contains('BET_BDD/Bankers/UploadKycDocToSharePoint') || req.getEndpoint().contains('BET_BDD/Orbis/UploadFinDocToSharePoint') || req.getEndpoint().contains('BET_BDD/SharePointService')
               || req.getEndpoint().contains('BET_BDD/Sovos/UploadSovosData')){
                    String response='{"resultPayload": ["https://shelldevelopment.sharepoint.com/sites/SPODA1540/Shared Documents/BDD-Automation Counterparties/HSBC HOLDINGS PLC - Bank - 09082020/09082020 - Financial Statement.pdf"],"responseMessage":"Success","isSuccess":true,"responseCode":200}';
                    res.setBody(response);
                    res.setStatusCode(200);
                }
        else if(req.getEndpoint().contains('TestingPass')){
            System.debug('reqq+test');
            String response='{"responseMessage":"Success","isSuccess":true,"responseCode":200}';
                    res.setBody(response);
                    res.setStatusCode(200);
        }
        else if(req.getEndpoint().contains('TestingFail')){
            System.debug('reqq+fail');
            String response='{"responseMessage":"Success","isSuccess":true,"responseCode":400}';
                    res.setBody(response);
                    res.setStatusCode(401);
        }
        
        else{        
            system.debug('req--'+req);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"test"}');
            res.setStatusCode(200);
        }
        return res;
    }
}