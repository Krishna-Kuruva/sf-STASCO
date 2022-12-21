@isTest
public class BET_BDD_Wrappers_Test {
    
    static testMethod void testBET_BDD_WrapperClass(){
        String response='{"resultPayload": {"searchSummary": {"databaseInfo": { "releaseNumber": "200","updateNumber": "200005","updateDate": "2020-09-18T00:00:00","versionNumber": "129.00" },'+
            ' "sortBy": {"descOrder": "OPRE"}},"data": [{"name": "SBI HOLDINGS, INC","namE_INTERNATIONAL": "SBI HOLDINGS, INC","bvdid": "JP6010401045208","status": ["Active"],'+
            '"lei": "353800L6LMHYIPSMRQ17","giin": ["2KZ1C1.00000.LE.392"],"tin": "6010401045208","vaT_NUMBER": ["6010401045208"],"nationaL_ID_LABEL": null,'+
            '"address_Line1_Additional": [],"addresS_LINE1": "1-6-1 ROPPONGI, MINATO-KU","addresS_LINE2": "","addresS_LINE3": "","postcode": "106-6019","city": "TOKYO",'+
            '"country": "Japan","productS_SERVICES": "Offers securities business; banking business; insurance business; financial media business; proprietary trading system;'+
            ' forex margin trading; face-to-face sales channels; other financial services; venture capital; buyout investment; overseas development; 5-ALA related business; research and development for medical products; and rent guarantee services [source: Bureau van Dijk]",'+
            '"europeaN_VAT_NUMBER": "12345","uS_STATE": "","tradE_REGISTER_NUMBER": ["1234567"],"akA_NAME": [],"bO_STATUS": "This company is listed. 48 beneficial owners.","bO_NAME": ["MR ANDREW TELFER"],'+
            '"naicS2017_CORE_CODE": "5511","incorporatioN_STATE": "","naicS2017_CORE_LABEL": "Management of Companies and Enterprises","worldcompliancE_MATCH_SANCTION_INDICATOR": "No","worldcompliancE_MATCH_CURRENT_PEP_INDICATOR": "No",'+
            '"worldcompliancE_MATCH_ADVERSE_MEDIA_INDICATOR": "No"}]},"responseMessage": "Success","isSuccess": true,"responseCode": 200}';            
        BET_BDD_WrapperClass.responseParametersORBIS orbis=new BET_BDD_WrapperClass.responseParametersORBIS();
        orbis=(BET_BDD_WrapperClass.responseParametersORBIS)JSON.deserialize(response,BET_BDD_WrapperClass.responseParametersORBIS.class);
        BET_BDD_WrapperClass.responseParametersORBIS orbisWrap=new BET_BDD_WrapperClass.responseParametersORBIS();
        orbisWrap.resultPayload=orbis.resultPayload;
        orbisWrap.accessToken=orbis.accessToken;
        orbisWrap.isSuccess=orbis.isSuccess;
        orbisWrap.responseCode=orbis.responseCode;
        orbisWrap.responseMessage=orbis.responseMessage;
        orbisWrap.resultPayload.searchSummary=orbis.resultPayload.searchSummary;
        orbisWrap.resultPayload.searchSummary.totalRecordsFound=orbis.resultPayload.searchSummary.totalRecordsFound;
        orbisWrap.resultPayload.searchSummary.offset=orbis.resultPayload.searchSummary.offset;
        orbisWrap.resultPayload.searchSummary.recordsReturned=orbis.resultPayload.searchSummary.recordsReturned;
        orbisWrap.resultPayload.searchSummary.databaseInfo=orbis.resultPayload.searchSummary.databaseInfo;
        orbisWrap.resultPayload.searchSummary.databaseInfo.releaseNumber=orbis.resultPayload.searchSummary.databaseInfo.releaseNumber;
        orbisWrap.resultPayload.searchSummary.databaseInfo.updateNumber=orbis.resultPayload.searchSummary.databaseInfo.updateNumber;
        orbisWrap.resultPayload.searchSummary.databaseInfo.updateDate=orbis.resultPayload.searchSummary.databaseInfo.updateDate;
        orbisWrap.resultPayload.searchSummary.databaseInfo.versionNumber=orbis.resultPayload.searchSummary.databaseInfo.versionNumber;
        orbisWrap.resultPayload.searchSummary.sortBy=orbis.resultPayload.searchSummary.sortBy;
        orbisWrap.resultPayload.searchSummary.sortBy.descOrder=orbis.resultPayload.searchSummary.sortBy.descOrder;
        orbisWrap.resultPayload.data=orbis.resultPayload.data;
        orbisWrap.resultPayload.data[0].name=orbis.resultPayload.data[0].name;
        orbisWrap.resultPayload.data[0].namE_INTERNATIONAL=orbis.resultPayload.data[0].namE_INTERNATIONAL;
        orbisWrap.resultPayload.data[0].bvdid=orbis.resultPayload.data[0].bvdid;
        orbisWrap.resultPayload.data[0].status=orbis.resultPayload.data[0].status;
        orbisWrap.resultPayload.data[0].lei=orbis.resultPayload.data[0].lei;
        orbisWrap.resultPayload.data[0].giin=orbis.resultPayload.data[0].giin;
        orbisWrap.resultPayload.data[0].tin=orbis.resultPayload.data[0].tin;
        orbisWrap.resultPayload.data[0].vaT_NUMBER=orbis.resultPayload.data[0].vaT_NUMBER;
        orbisWrap.resultPayload.data[0].entitY_TYPE=orbis.resultPayload.data[0].entitY_TYPE;
        orbisWrap.resultPayload.data[0].companY_ID_NUMBER=orbis.resultPayload.data[0].companY_ID_NUMBER;
        orbisWrap.resultPayload.data[0].nationaL_ID=orbis.resultPayload.data[0].nationaL_ID;
        orbisWrap.resultPayload.data[0].nationaL_ID_LABEL=orbis.resultPayload.data[0].nationaL_ID_LABEL;
        orbisWrap.resultPayload.data[0].address_Line1_Additional=orbis.resultPayload.data[0].address_Line1_Additional;
        orbisWrap.resultPayload.data[0].worlD_REGION=orbis.resultPayload.data[0].worlD_REGION;
        orbisWrap.resultPayload.data[0].industrY_CLASSIFICATION=orbis.resultPayload.data[0].industrY_CLASSIFICATION;
        orbisWrap.resultPayload.data[0].previouS_NAME=orbis.resultPayload.data[0].previouS_NAME;
        orbisWrap.resultPayload.data[0].opre=orbis.resultPayload.data[0].opre;
        orbisWrap.resultPayload.data[0].cf=orbis.resultPayload.data[0].cf;
        orbisWrap.resultPayload.data[0].toas=orbis.resultPayload.data[0].toas;
        orbisWrap.resultPayload.data[0].shfd=orbis.resultPayload.data[0].shfd;
        orbisWrap.resultPayload.data[0].prma=orbis.resultPayload.data[0].prma;
        orbisWrap.resultPayload.data[0].akA_NAME=orbis.resultPayload.data[0].akA_NAME;
        orbisWrap.resultPayload.data[0].bO_STATUS=orbis.resultPayload.data[0].bO_STATUS;
        orbisWrap.resultPayload.data[0].bO_NAME=orbis.resultPayload.data[0].bO_NAME;
        orbisWrap.resultPayload.data[0].bO_ENTITY_TYPE=orbis.resultPayload.data[0].bO_ENTITY_TYPE;
        orbisWrap.resultPayload.data[0].naicS2017_CORE_CODE=orbis.resultPayload.data[0].naicS2017_CORE_CODE;
        orbisWrap.resultPayload.data[0].incorporatioN_STATE=orbis.resultPayload.data[0].incorporatioN_STATE;
        orbisWrap.resultPayload.data[0].addresS_LINE1=orbis.resultPayload.data[0].addresS_LINE1;
        orbisWrap.resultPayload.data[0].addresS_LINE2=orbis.resultPayload.data[0].addresS_LINE2;
        orbisWrap.resultPayload.data[0].addresS_LINE3=orbis.resultPayload.data[0].addresS_LINE3;
        orbisWrap.resultPayload.data[0].postcode=orbis.resultPayload.data[0].postcode;
        orbisWrap.resultPayload.data[0].city=orbis.resultPayload.data[0].city;
        orbisWrap.resultPayload.data[0].country=orbis.resultPayload.data[0].country;
        orbisWrap.resultPayload.data[0].productS_SERVICES=orbis.resultPayload.data[0].productS_SERVICES;
        orbisWrap.resultPayload.data[0].europeaN_VAT_NUMBER=orbis.resultPayload.data[0].europeaN_VAT_NUMBER;
        orbisWrap.resultPayload.data[0].empl=orbis.resultPayload.data[0].empl;
        orbisWrap.resultPayload.data[0].uS_STATE=orbis.resultPayload.data[0].uS_STATE;
        orbisWrap.resultPayload.data[0].tradE_REGISTER_NUMBER=orbis.resultPayload.data[0].tradE_REGISTER_NUMBER;
        orbisWrap.resultPayload.data[0].worldcompliancE_MATCH_SANCTION_INDICATOR=orbis.resultPayload.data[0].worldcompliancE_MATCH_SANCTION_INDICATOR;
        orbisWrap.resultPayload.data[0].worldcompliancE_MATCH_CURRENT_PEP_INDICATOR=orbis.resultPayload.data[0].worldcompliancE_MATCH_CURRENT_PEP_INDICATOR;
        orbisWrap.resultPayload.data[0].NAICS2017_CORE_LABEL=orbis.resultPayload.data[0].NAICS2017_CORE_LABEL;
        orbisWrap.resultPayload.data[0].worldcompliancE_MATCH_ADVERSE_MEDIA_INDICATOR=orbis.resultPayload.data[0].worldcompliancE_MATCH_ADVERSE_MEDIA_INDICATOR;
        
        String responseEDP='{"resultPayload": ["https://shelldevelopment.sharepoint.com/sites/SPODA1540/Shared Documents/BDD-Automation Counterparties/HSBC HOLDINGS PLC - Bank - 09082020/09082020 - Financial Statement.pdf"],"responseMessage":"Success","isSuccess":true,"responseCode":200}';
        
        BET_BDD_WrapperClass.EdpResponseWrapper edp=(BET_BDD_WrapperClass.EdpResponseWrapper)JSON.deserialize(responseEDP, BET_BDD_WrapperClass.EdpResponseWrapper.class);
        BET_BDD_WrapperClass.EdpResponseWrapper edpWrap=new BET_BDD_WrapperClass.EdpResponseWrapper();
        edpWrap.isSuccess=edp.isSuccess;
        edpWrap.responseCode=edp.responseCode;
        edpWrap.responseMessage=edp.responseMessage;
        edpWrap.resultPayload=edp.resultPayload;
        
        String responsePdf='{"resultPayload": "Test","responseMessage": "Success","isSuccess": true,"responseCode": 200}';
        BET_BDD_WrapperClass.responseParametersPdfFiles edpPDF=(BET_BDD_WrapperClass.responseParametersPdfFiles)JSON.deserialize(responsePdf, BET_BDD_WrapperClass.responseParametersPdfFiles.class);
        BET_BDD_WrapperClass.responseParametersPdfFiles pdfWrap=new BET_BDD_WrapperClass.responseParametersPdfFiles();
        pdfWrap.isSuccess=edpPDF.isSuccess;
        pdfWrap.resultPayload=edpPDF.resultPayload;
        pdfWrap.responseMessage=edpPDF.responseMessage;
        pdfWrap.responseCode=edpPDF.responseCode;
    }
    
    static testMethod void testBET_BDD_Bankers_WrapperClass(){
        String response='{"resultPayload": {"totalResults": 8,"displayedResults": 8,"results": [{"legalEntity": {"bankersAlmanacId": "71562","linkToFullDetails": "https://api.bankersalmanac.com/fulldetails/baid/71562",'+
            '"names": [{"type": "Legal Title","value": "SBI Bank Limited Liability Company"}],'+
            '"status": "active","type": "Bank","lei": "253400HGXRLW3EFSMC03","noOfDomesticOffices": 1,"noOfForeignOffices": 0},"office": {"officeId": "71562-0",'+
            '"names": [{"type": "Office Name","value": "Leningradskiy Avenue"}],"types": ["Registered Office","Head Office"],"status": "active","giin": ["PZA85W.99999.SL.643"],'+
            '"location": {"id": "59248","streetAddress": {"addressLine1": "bld.2., bld.3.","addressLine2": "Leningradskiy Avenue 72","addressLine3": null,"addressLine4": null'+
            '},"area": null,"city": "Moscow","country": {"name": "Russian Federation","iso3": "RUS"},"postalCode": "125315","subArea": null},'+
            '"swiftBICs": ["OBIBRUMM"],"clearingCodes": [],"linkToFullDetails": null}}]},"responseMessage": "Success","isSuccess": true,"responseCode": 200}';
        BET_BDD_BankersWrapper.responseParametersBankers bankers=new BET_BDD_BankersWrapper.responseParametersBankers();
        bankers=(BET_BDD_BankersWrapper.responseParametersBankers)JSON.deserialize(response,BET_BDD_BankersWrapper.responseParametersBankers.class);
        BET_BDD_BankersWrapper.responseParametersBankers bankersWrap=new BET_BDD_BankersWrapper.responseParametersBankers();
        bankersWrap.resultPayload=bankers.resultPayload;
        bankersWrap.responseMessage=bankers.responseMessage;
        bankersWrap.isSuccess=bankers.isSuccess;
        bankersWrap.responseCode=bankers.responseCode;
        bankersWrap.accessToken=bankers.accessToken;
        bankersWrap.resultPayload.displayedResults=bankers.resultPayload.displayedResults;
        bankersWrap.resultPayload.totalResults=bankers.resultPayload.totalResults;
        bankersWrap.resultPayload.results[0].legalEntity.bankersAlmanacId=bankers.resultPayload.results[0].legalEntity.bankersAlmanacId;
        bankersWrap.resultPayload.results[0].legalEntity.linkToFullDetails=bankers.resultPayload.results[0].legalEntity.linkToFullDetails;
        bankersWrap.resultPayload.results[0].legalEntity.status=bankers.resultPayload.results[0].legalEntity.status;
        bankersWrap.resultPayload.results[0].legalEntity.type=bankers.resultPayload.results[0].legalEntity.type;
        bankersWrap.resultPayload.results[0].legalEntity.lei=bankers.resultPayload.results[0].legalEntity.lei;
        bankersWrap.resultPayload.results[0].legalEntity.noOfDomesticOffices=bankers.resultPayload.results[0].legalEntity.noOfDomesticOffices;
        bankersWrap.resultPayload.results[0].legalEntity.noOfDomesticOffices=bankers.resultPayload.results[0].legalEntity.noOfDomesticOffices;
        bankersWrap.resultPayload.results[0].legalEntity.names[0].type=bankers.resultPayload.results[0].legalEntity.names[0].type;
        bankersWrap.resultPayload.results[0].legalEntity.names[0].value=bankers.resultPayload.results[0].legalEntity.names[0].value;
        bankersWrap.resultPayload.results[0].office.names=bankers.resultPayload.results[0].office.names;
        bankersWrap.resultPayload.results[0].office.types=bankers.resultPayload.results[0].office.types;
        bankersWrap.resultPayload.results[0].office.status=bankers.resultPayload.results[0].office.status;
        bankersWrap.resultPayload.results[0].office.giin=bankers.resultPayload.results[0].office.giin;
        bankersWrap.resultPayload.results[0].office.location=bankers.resultPayload.results[0].office.location;
        bankersWrap.resultPayload.results[0].office.swiftBICs=bankers.resultPayload.results[0].office.swiftBICs;
        bankersWrap.resultPayload.results[0].office.clearingCodes=bankers.resultPayload.results[0].office.clearingCodes;
        bankersWrap.resultPayload.results[0].office.linkToFullDetails=bankers.resultPayload.results[0].office.linkToFullDetails;
        bankersWrap.resultPayload.results[0].office.location.streetAddress=bankers.resultPayload.results[0].office.location.streetAddress;
        bankersWrap.resultPayload.results[0].office.location.area=bankers.resultPayload.results[0].office.location.area;
        bankersWrap.resultPayload.results[0].office.location.city=bankers.resultPayload.results[0].office.location.city;
        bankersWrap.resultPayload.results[0].office.location.country=bankers.resultPayload.results[0].office.location.country;
        bankersWrap.resultPayload.results[0].office.location.postalCode=bankers.resultPayload.results[0].office.location.postalCode;
        bankersWrap.resultPayload.results[0].office.location.subArea=bankers.resultPayload.results[0].office.location.subArea;
        bankersWrap.resultPayload.results[0].office.location.streetAddress.addressLine1=bankers.resultPayload.results[0].office.location.streetAddress.addressLine1;
        bankersWrap.resultPayload.results[0].office.location.streetAddress.addressLine2=bankers.resultPayload.results[0].office.location.streetAddress.addressLine2;
        bankersWrap.resultPayload.results[0].office.location.streetAddress.addressLine3=bankers.resultPayload.results[0].office.location.streetAddress.addressLine3;
        bankersWrap.resultPayload.results[0].office.location.streetAddress.addressLine4=bankers.resultPayload.results[0].office.location.streetAddress.addressLine4;
        bankersWrap.resultPayload.results[0].office.location.country.name=bankers.resultPayload.results[0].office.location.country.name;
        bankersWrap.resultPayload.results[0].office.location.country.iso3=bankers.resultPayload.results[0].office.location.country.iso3;
        
    }
    
    static testmethod void testBET_BDD_GTMIWrapperClass(){
      /*  BET_BDD_GTMI_WrapperClass testWrap = new BET_BDD_GTMI_WrapperClass();
        BET_BDD_GTMI_WrapperClass.ResultPayload testRsl = new BET_BDD_GTMI_WrapperClass.ResultPayload();
        testRsl.goldtieR_ID = 134; */
        
        
        String response='{"REG_ID": "","REG_ID_TYP": "","goldtieR_ID": 256201,"legaL_NAME": "SBI Equity Hybrid Fund","shorT_NAME": "SBI Equity Hybrid Fund",'+
            '"dD_LEVEL": "Related Party","cusT_DD_LEVEL_KEY":"test","policY_STS": "","policY_STS_DT": "","legaL_CNTRY": "India","dD_LEVEL_APPRD": "","entitY_TYP": "Bank/Financial Institution","dndB_LIST": "N",'+
            '"reC_ACTIVE_FLAG": "Y","shiP_ID_NO_IMO": "","apprD_WITH_CONDITIONS_FLAG": "","rejecteD_WITH_CONDITIONS_FLAG": ""}';
        BET_BDD_GTMI_WrapperClass wrap = new BET_BDD_GTMI_WrapperClass();
        BET_BDD_GTMI_WrapperClass.ResultPayload gtmi=new BET_BDD_GTMI_WrapperClass.ResultPayload();
        gtmi=(BET_BDD_GTMI_WrapperClass.ResultPayload)JSON.deserialize(response, BET_BDD_GTMI_WrapperClass.ResultPayload.class);
        system.debug('gtmi'+gtmi);
        BET_BDD_GTMI_WrapperClass.ResultPayload gtmiWrap=new BET_BDD_GTMI_WrapperClass.ResultPayload();
        List<BET_BDD_GTMI_WrapperClass.ResultPayload> rstLoad = new List<BET_BDD_GTMI_WrapperClass.ResultPayload>{gtmi};
        BET_BDD_GTMI_WrapperClass wraptest = new BET_BDD_GTMI_WrapperClass();
        wraptest.resultPayload=rstLoad;
      wraptest.responseMessage = 'Success';
        wraptest.isSuccess = true;
        wraptest.responseCode = 200;
            wraptest.accessToken = 'abc1234';
        gtmiWrap.goldtieR_ID=gtmi.goldtieR_ID;
        gtmiWrap.legaL_NAME=gtmi.legaL_NAME;
        gtmiWrap.shorT_NAME=gtmi.shorT_NAME;
        gtmiWrap.dD_LEVEL=gtmi.dD_LEVEL;
        gtmiWrap.cusT_DD_LEVEL_KEY=gtmi.cusT_DD_LEVEL_KEY;
        gtmiWrap.policY_STS=gtmi.policY_STS;
        gtmiWrap.policY_STS_DT=gtmi.policY_STS_DT;
        gtmiWrap.legaL_CNTRY=gtmi.legaL_CNTRY;
        gtmiWrap.dD_LEVEL_APPRD=gtmi.dD_LEVEL_APPRD;
        gtmiWrap.entitY_TYP=gtmi.entitY_TYP;
        gtmiWrap.dndB_LIST=gtmi.dndB_LIST;
        gtmiWrap.reC_ACTIVE_FLAG=gtmi.reC_ACTIVE_FLAG;
        gtmiWrap.shiP_ID_NO_IMO=gtmi.shiP_ID_NO_IMO;
        gtmiWrap.apprD_WITH_CONDITIONS_FLAG=gtmi.apprD_WITH_CONDITIONS_FLAG;
        gtmiWrap.rejecteD_WITH_CONDITIONS_FLAG=gtmi.rejecteD_WITH_CONDITIONS_FLAG;
        gtmiWrap.REG_ID=gtmi.REG_ID;
        gtmiWrap.REG_ID_TYP=gtmi.REG_ID_TYP;
        /*gtmiWrap.isSuccess=gtmi.isSuccess;
gtmiWrap.responseCode=gtmi.responseCode;
gtmiWrap.responseMessage=gtmi.responseMessage;*/
    }
    
    static testmethod void testBET_BDD_Bankers_baidWrapper(){
        StaticResource srObject = [select id,body from StaticResource Where Name = 'BankersBaidResponse'];
        String contents = srObject.body.toString();
        
        BET_BDD_Bankers_baidWrapper.responseParameterBaid baid=(BET_BDD_Bankers_baidWrapper.responseParameterBaid)JSON.deserialize(contents, BET_BDD_Bankers_baidWrapper.responseParameterBaid.class);
        BET_BDD_Bankers_baidWrapper.responseParameterBaid baidWrap=new BET_BDD_Bankers_baidWrapper.responseParameterBaid();
        baidWrap.resultPayload=baid.resultPayload;
        baidWrap.responseMessage=baid.responseMessage;
        baidWrap.isSuccess=baid.isSuccess;
        baidWrap.responseCode=baid.responseCode;
        baidWrap.resultPayload=baid.resultPayload;
        baidWrap.resultPayload.legalEntity=baid.resultPayload.legalEntity;
        baidWrap.resultPayload.legalEntity.names=baid.resultPayload.legalEntity.names;
        baidWrap.resultPayload.legalEntity.names[0].type=baid.resultPayload.legalEntity.names[0].type;
        baidWrap.resultPayload.legalEntity.names[0].value=baid.resultPayload.legalEntity.names[0].value;
        baidWrap.resultPayload.legalEntity.type=baid.resultPayload.legalEntity.type;
        baidWrap.resultPayload.legalEntity.status=baid.resultPayload.legalEntity.status;
        baidWrap.resultPayload.legalEntity.offshoreIndicator=baid.resultPayload.legalEntity.offshoreIndicator;
        baidWrap.resultPayload.legalEntity.registeredOffice=baid.resultPayload.legalEntity.registeredOffice;
        baidWrap.resultPayload.legalEntity.registeredOffice.name=baid.resultPayload.legalEntity.registeredOffice.name;
        baidWrap.resultPayload.legalEntity.registeredOffice.types=baid.resultPayload.legalEntity.registeredOffice.types;
        baidWrap.resultPayload.legalEntity.registeredOffice.status=baid.resultPayload.legalEntity.registeredOffice.status;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations=baid.resultPayload.legalEntity.registeredOffice.locations;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address=baid.resultPayload.legalEntity.registeredOffice.locations[0].address;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.type=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.type;
        //baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.streetAddress=baid.resultPayload.legalEntity.registeredOffice.locations[0].streetAddress;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.city=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.city;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.subarea=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.subarea;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.subarea.name=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.subarea.name;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.subarea.displayName=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.subarea.displayName;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.subarea.isUsedInAddress=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.subarea.isUsedInAddress;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.area=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.area;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.country=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.country;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.postalCode=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.postalCode;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].address.postalCodePosition=baid.resultPayload.legalEntity.registeredOffice.locations[0].address.postalCodePosition;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails=baid.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.telephone=baid.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.telephone;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.fax=baid.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.fax;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.email=baid.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.email;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.telex=baid.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.telex;
        baidWrap.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.reuters=baid.resultPayload.legalEntity.registeredOffice.locations[0].contactDetails.reuters;
        baidWrap.resultPayload.legalEntity.registeredOffice.departments=baid.resultPayload.legalEntity.registeredOffice.departments;
        baidWrap.resultPayload.legalEntity.registeredOffice.departments[0].name=baid.resultPayload.legalEntity.registeredOffice.departments[0].name;
        baidWrap.resultPayload.legalEntity.registeredOffice.departments[0].routingCodes=baid.resultPayload.legalEntity.registeredOffice.departments[0].routingCodes;
        baidWrap.resultPayload.legalEntity.registeredOffice.departments[0].routingCodes[0].routingCodeType=baid.resultPayload.legalEntity.registeredOffice.departments[0].routingCodes[0].routingCodeType;
        baidWrap.resultPayload.legalEntity.registeredOffice.departments[0].routingCodes[0].routingCodeValue=baid.resultPayload.legalEntity.registeredOffice.departments[0].routingCodes[0].routingCodeValue;
        baidWrap.resultPayload.legalEntity.registeredOffice.departments[0].routingCodes[0].routingCodeStatus=baid.resultPayload.legalEntity.registeredOffice.departments[0].routingCodes[0].routingCodeStatus;
        baidWrap.resultPayload.legalEntity.registeredOffice.departments[0].contactDetails=baid.resultPayload.legalEntity.registeredOffice.departments[0].contactDetails;
        baidWrap.resultPayload.legalEntity.registeredOffice.identifiers=baid.resultPayload.legalEntity.registeredOffice.identifiers;
        baidWrap.resultPayload.legalEntity.registeredOffice.identifiers.bankersAlmanacId=baid.resultPayload.legalEntity.registeredOffice.identifiers.bankersAlmanacId;
        baidWrap.resultPayload.legalEntity.registeredOffice.identifiers.swiftBICs=baid.resultPayload.legalEntity.registeredOffice.identifiers.swiftBICs;
        baidWrap.resultPayload.legalEntity.registeredOffice.identifiers.giin=baid.resultPayload.legalEntity.registeredOffice.identifiers.giin;
        baidWrap.resultPayload.legalEntity.headOffice=baid.resultPayload.legalEntity.headOffice;
        baidWrap.resultPayload.legalEntity.headOffice.name=baid.resultPayload.legalEntity.headOffice.name;
        baidWrap.resultPayload.legalEntity.headOffice.types=baid.resultPayload.legalEntity.headOffice.types;
        baidWrap.resultPayload.legalEntity.headOffice.status=baid.resultPayload.legalEntity.headOffice.status;
        baidWrap.resultPayload.legalEntity.headOffice.locations=baid.resultPayload.legalEntity.headOffice.locations;
        baidWrap.resultPayload.legalEntity.headOffice.departments=baid.resultPayload.legalEntity.headOffice.departments;
        baidWrap.resultPayload.legalEntity.headOffice.identifiers=baid.resultPayload.legalEntity.headOffice.identifiers;
        baidWrap.resultPayload.legalEntity.identifiers=baid.resultPayload.legalEntity.identifiers;
        baidWrap.resultPayload.legalEntity.overview=baid.resultPayload.legalEntity.overview;
        baidWrap.resultPayload.legalEntity.overview.activities=baid.resultPayload.legalEntity.overview.activities;
        baidWrap.resultPayload.legalEntity.overview.services=baid.resultPayload.legalEntity.overview.services;
        baidWrap.resultPayload.legalEntity.memberOf=baid.resultPayload.legalEntity.memberOf;
        baidWrap.resultPayload.legalEntity.memberOf.items=baid.resultPayload.legalEntity.memberOf.items;
        baidWrap.resultPayload.legalEntity.memberOf.items[0].bankersAlmanacId=baid.resultPayload.legalEntity.memberOf.items[0].bankersAlmanacId;
        baidWrap.resultPayload.legalEntity.memberOf.items[0].name=baid.resultPayload.legalEntity.memberOf.items[0].name;
        baidWrap.resultPayload.legalEntity.regulators=baid.resultPayload.legalEntity.regulators;
        baidWrap.resultPayload.legalEntity.regulators[0].bankersAlmanacId=baid.resultPayload.legalEntity.regulators[0].bankersAlmanacId;
        baidWrap.resultPayload.legalEntity.regulators[0].name=baid.resultPayload.legalEntity.regulators[0].name;
        baidWrap.resultPayload.legalEntity.regulators[0].regulatorType=baid.resultPayload.legalEntity.regulators[0].regulatorType;
        baidWrap.resultPayload.legalEntity.regulators[0].registeredOffice=baid.resultPayload.legalEntity.regulators[0].registeredOffice;
        baidWrap.resultPayload.legalEntity.auditors=baid.resultPayload.legalEntity.auditors;
        baidWrap.resultPayload.legalEntity.Auditors[0].bankersAlmanacId=baid.resultPayload.legalEntity.Auditors[0].bankersAlmanacId;
        baidWrap.resultPayload.legalEntity.Auditors[0].name=baid.resultPayload.legalEntity.Auditors[0].name;
        baidWrap.resultPayload.legalEntity.Auditors[0].auditorType=baid.resultPayload.legalEntity.Auditors[0].auditorType;
        baidWrap.resultPayload.legalEntity.ownership=baid.resultPayload.legalEntity.ownership;
        baidWrap.resultPayload.legalEntity.ownership.ultimateParent=baid.resultPayload.legalEntity.ownership.ultimateParent;
        baidWrap.resultPayload.legalEntity.ownership.ultimateParent.name=baid.resultPayload.legalEntity.ownership.ultimateParent.name;
        baidWrap.resultPayload.legalEntity.ownership.ultimateParent.entityType=baid.resultPayload.legalEntity.ownership.ultimateParent.entityType;
        baidWrap.resultPayload.legalEntity.ownership.ultimateParent.bankersAlmanacId=baid.resultPayload.legalEntity.ownership.ultimateParent.bankersAlmanacId;
        baidWrap.resultPayload.legalEntity.ownership.directOwners=baid.resultPayload.legalEntity.ownership.directOwners;
        baidWrap.resultPayload.legalEntity.ownership.directOwners[0].name=baid.resultPayload.legalEntity.ownership.directOwners[0].name;
        baidWrap.resultPayload.legalEntity.ownership.directOwners[0].country=baid.resultPayload.legalEntity.ownership.directOwners[0].country;
        baidWrap.resultPayload.legalEntity.ownership.directOwners[0].percentageOwnership=baid.resultPayload.legalEntity.ownership.directOwners[0].percentageOwnership;
        baidWrap.resultPayload.legalEntity.ownership.directOwners[0].bankersAlmanacId=baid.resultPayload.legalEntity.ownership.directOwners[0].bankersAlmanacId;
        baidWrap.resultPayload.legalEntity.ownership.directOwners[0].lastVerifiedDate=baid.resultPayload.legalEntity.ownership.directOwners[0].lastVerifiedDate;
        baidWrap.resultPayload.legalEntity.ownership.directOwners[0].entityType=baid.resultPayload.legalEntity.ownership.directOwners[0].entityType;
        baidWrap.resultPayload.legalEntity.ownership.ubos=baid.resultPayload.legalEntity.ownership.ubos;
        baidWrap.resultPayload.legalEntity.ownership.ubos[0].name=baid.resultPayload.legalEntity.ownership.ubos[0].name;
        baidWrap.resultPayload.legalEntity.ownership.directSubsidiaries=baid.resultPayload.legalEntity.ownership.directSubsidiaries;
        baidWrap.resultPayload.legalEntity.ownership.directSubsidiaries[0].name=baid.resultPayload.legalEntity.ownership.directSubsidiaries[0].name;
        baidWrap.resultPayload.legalEntity.ownership.directSubsidiaries[0].bankersAlmanacId=baid.resultPayload.legalEntity.ownership.directSubsidiaries[0].bankersAlmanacId;
        baidWrap.resultPayload.legalEntity.ownership.directSubsidiaries[0].country=baid.resultPayload.legalEntity.ownership.directSubsidiaries[0].country;
        baidWrap.resultPayload.legalEntity.ownership.directSubsidiaries[0].entityType=baid.resultPayload.legalEntity.ownership.directSubsidiaries[0].entityType;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure=baid.resultPayload.legalEntity.ownership.groupStructure;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data=baid.resultPayload.legalEntity.ownership.groupStructure.data;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data.bankersAlmanacId=baid.resultPayload.legalEntity.ownership.groupStructure.data.bankersAlmanacId;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data.name=baid.resultPayload.legalEntity.ownership.groupStructure.data.name;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data.country=baid.resultPayload.legalEntity.ownership.groupStructure.data.country;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data.children=baid.resultPayload.legalEntity.ownership.groupStructure.data.children;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data.children[0].bankersAlmanacId=baid.resultPayload.legalEntity.ownership.groupStructure.data.children[0].bankersAlmanacId;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data.children[0].name=baid.resultPayload.legalEntity.ownership.groupStructure.data.children[0].name;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data.children[0].country=baid.resultPayload.legalEntity.ownership.groupStructure.data.children[0].country;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data.children[0].percentageOwnership=baid.resultPayload.legalEntity.ownership.groupStructure.data.children[0].percentageOwnership;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.data.children[0].children=baid.resultPayload.legalEntity.ownership.groupStructure.data.children[0].children;
        baidWrap.resultPayload.legalEntity.ownership.groupStructure.link=baid.resultPayload.legalEntity.ownership.groupStructure.link;
        baidWrap.resultPayload.legalEntity.stockExchanges=baid.resultPayload.legalEntity.stockExchanges;
        baidWrap.resultPayload.legalEntity.websites=baid.resultPayload.legalEntity.websites;
        baidWrap.resultPayload.legalEntity.personnel=baid.resultPayload.legalEntity.personnel;  
        baidWrap.resultPayload.legalEntity.personnel[0].name=baid.resultPayload.legalEntity.personnel[0].name;  
        baidWrap.resultPayload.legalEntity.personnel[0].titles=baid.resultPayload.legalEntity.personnel[0].titles;  
        baidWrap.resultPayload.legalEntity.personnel[0].lastVerifiedDate=baid.resultPayload.legalEntity.personnel[0].lastVerifiedDate;  
        baidWrap.resultPayload.legalEntity.summary=baid.resultPayload.legalEntity.summary;
        baidWrap.resultPayload.legalEntity.summary.numberOfOffices=baid.resultPayload.legalEntity.summary.numberOfOffices;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments=baid.resultPayload.legalEntity.dueDiligenceDocuments;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].nametype=baid.resultPayload.legalEntity.dueDiligenceDocuments[0].nametype;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].link=baid.resultPayload.legalEntity.dueDiligenceDocuments[0].link;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].filename=baid.resultPayload.legalEntity.dueDiligenceDocuments[0].filename;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].publishedDate=baid.resultPayload.legalEntity.dueDiligenceDocuments[0].publishedDate;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].documentRecordType=baid.resultPayload.legalEntity.dueDiligenceDocuments[0].documentRecordType;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].documentStatus =baid.resultPayload.legalEntity.dueDiligenceDocuments[0].documentStatus ;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].documentRecordType=baid.resultPayload.legalEntity.dueDiligenceDocuments[0].documentRecordType;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].documentGroup=baid.resultPayload.legalEntity.dueDiligenceDocuments[0].documentGroup;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].documentSet=baid.resultPayload.legalEntity.dueDiligenceDocuments[0].documentSet;
        baidWrap.resultPayload.legalEntity.dueDiligenceDocuments[0].parentDocument=baid.resultPayload.legalEntity.dueDiligenceDocuments[0].parentDocument;
        baidWrap.resultPayload.financials=baid.resultPayload.financials;
        baidWrap.resultPayload.financials[0].statementType=baid.resultPayload.financials[0].statementType;
        baidWrap.resultPayload.financials[0].periodStart=baid.resultPayload.financials[0].periodStart;
        baidWrap.resultPayload.financials[0].periodEnd=baid.resultPayload.financials[0].periodEnd;
        baidWrap.resultPayload.financials[0].consolidated=baid.resultPayload.financials[0].consolidated;
        baidWrap.resultPayload.financials[0].originalCurrencyName=baid.resultPayload.financials[0].originalCurrencyName;
        baidWrap.resultPayload.financials[0].originalCurrencyCode=baid.resultPayload.financials[0].originalCurrencyCode;
        baidWrap.resultPayload.financials[0].orderOfMagnitude=baid.resultPayload.financials[0].orderOfMagnitude;
        baidWrap.resultPayload.financials[0].lineItemsSets=baid.resultPayload.financials[0].lineItemsSets;
        baidWrap.resultPayload.financials[0].lineItemsSets[0].currencyName=baid.resultPayload.financials[0].lineItemsSets[0].currencyName;
        baidWrap.resultPayload.financials[0].lineItemsSets[0].currencyCode=baid.resultPayload.financials[0].lineItemsSets[0].currencyCode;
        baidWrap.resultPayload.financials[0].lineItemsSets[0].exchangeRate=baid.resultPayload.financials[0].lineItemsSets[0].exchangeRate;
        baidWrap.resultPayload.financials[0].lineItemsSets[0].lineItemsSet=baid.resultPayload.financials[0].lineItemsSets[0].lineItemsSet;
        baidWrap.resultPayload.financials[0].ratioItemSet=baid.resultPayload.financials[0].ratioItemSet;
        baidWrap.resultPayload.financials[0].ratioItemSet[0].lineName=baid.resultPayload.financials[0].ratioItemSet[0].lineName;
        baidWrap.resultPayload.financials[0].ratioItemSet[0].lineValue=baid.resultPayload.financials[0].ratioItemSet[0].lineValue;
        
        
    }
    
}