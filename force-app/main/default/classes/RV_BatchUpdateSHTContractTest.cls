//@isTest
public Class RV_BatchUpdateSHTContractTest{

 
 

   /*static testMethod void RV_BatchUpdateSHTContractTest1(){    
        List<SAP_Staging__c> stagingList = new List<SAP_Staging__c>();
        SAP_Staging__c s=new SAP_Staging__c(SfItemShtNo__c='SHT-0222',CreationInd__c='D',Processing_Indicator__c='01',Deal_Created_Date__c=system.today());
        stagingList.add(s);
        
        SAP_Staging__c s1=new SAP_Staging__c(SfItemShtNo__c='SHT-0223',CreationInd__c='C',Processing_Indicator__c='01',Deal_Created_Date__c=system.today());
        stagingList.add(s1);
        
        SAP_Staging__c s2=new SAP_Staging__c(SfItemShtNo__c='SHT-0224',CreationInd__c='C',Processing_Indicator__c='01',Deal_Created_Date__c=system.today());
        stagingList.add(s2);
        
          SAP_Staging__c s3=new SAP_Staging__c(SfItemShtNo__c='SHT-0225',CreationInd__c='D',Processing_Indicator__c='01',Deal_Created_Date__c=system.today());
        stagingList.add(s3);
        
        insert stagingList;
        
        Test.startTest();
        RV_BatchUpdateSHTContract obj = new RV_BatchUpdateSHTContract();
        DataBase.executeBatch(obj);         
        Test.stopTest();  
    }

     static testMethod void RV_BatchUpdateSHTContractTest2(){    

        //ommented by jaya for debugging     
        SAP_Staging__c s=new SAP_Staging__c(SfItemShtNo__c='SHT-0222',CreationInd__c='D',Processing_Indicator__c='01',Deal_Created_Date__c=system.today());
        insert s;
        S.Processing_Indicator__c='02';
        update s;
        SF_SAP_DataSet__x mockedRequest = new SF_SAP_DataSet__x(SfHeaderShtNo__c=s.SfHeaderShtNo__c, SfItemShtNo__c='SHT-0222', SapSalesContNo__c='32432432',Status__c='02',MsgTxt__c='test',Action__c='D');
        if(mockedRequest==null)
        mockedRequest = [SELECT EXTERNALiD, id,SfHeaderShtNo__c, SfItemShtNo__c, SapSalesContNo__c,Status__c,MsgTxt__c,Action__c
        FROM SF_SAP_DataSet__x WHERE Status__c ='01'  lIMIT 1];        
        SF_SAP_DataSet__x request = RV_GSAPMockExternalRequestModel.findById(mockedRequest.EXTERNALiD);        
        System.Debug('request :'+request +'mockedRequest.Id:'+mockedRequest.Id);        
        Test.startTest();
        RV_BatchUpdateSHTContract obj = new RV_BatchUpdateSHTContract();
        DataBase.executeBatch(obj);         
        Test.stopTest();  
    }
*/
     /** static testMethod void RV_BatchUpdateSHTContractTest2(){
    
        SF_SAP_DataSet__x mockedRequest = new SF_SAP_DataSet__x(SfHeaderShtNo__c='324435432', SfItemShtNo__c='SHT-0222', SapSalesContNo__c='32432432',Status__c='02',MsgTxt__c='test',Action__c='C');
    SF_SAP_DataSet__x request = RV_GSAPMockExternalRequestModel.findById(mockedRequest.Id);

          SAP_Staging__c s1=new SAP_Staging__C();
         //s.SfHeaderShtNo__c='222';
         s1.CreationInd__c='C';
         s1.SfItemShtNo__c='SHT-0222';
         s1.Processing_Indicator__c='01';
         
         s1.Deal_Created_Date__c=System.Today();
         insert S1;         
         Test.startTest();

            RV_BatchUpdateSHTContract obj = new RV_BatchUpdateSHTContract();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
         
    
    
    }

      static testMethod void RV_BatchUpdateSHTContractTest3(){
      try{
          RV_BatchUpdateSHTContract rb=new RV_BatchUpdateSHTContract();
        SF_SAP_DataSet__x mockedRequest = new SF_SAP_DataSet__x(SfHeaderShtNo__c='3244352', SfItemShtNo__c='SHT-0233', SapSalesContNo__c='32992432',Status__c='03',MsgTxt__c='test',Action__c='D');
    List<SF_SAP_DataSet__x> externalData=NEW List<SF_SAP_DataSet__x>();
            externalData.add(mockedRequest);
    SF_SAP_DataSet__x request = RV_GSAPMockExternalRequestModel.findById(mockedRequest.Id);
    System.Debug('request :'+request );
    
    
      // SF_SAP_DataSet__x mockedRequest = new SF_SAP_DataSet__x(ExternalId='22',SfHeaderShtNo__c='324435432', SfItemShtNo__c='SHT-0222', SapSalesContNo__c='32432432',Status__c='02',MsgTxt__c='test',Action__c='C');
          // List<SF_SAP_DataSet__x> externalData=NEW List<SF_SAP_DataSet__x>();
            //externalData.add(mockedRequest);
            if(RV_BatchUpdateSHTContract.externalData[0].ExternalId !=null)
            request = RV_GSAPMockExternalRequestModel.findById(RV_BatchUpdateSHTContract.externalData[0].ExternalId);
           
else 
   externalData= [ SELECT  id,ExternalId,SfHeaderShtNo__c, SfItemShtNo__c, SapSalesContNo__c,Status__c,MsgTxt__c,Action__c
            FROM SF_SAP_DataSet__x];
              request = RV_GSAPMockExternalRequestModel.findById(RV_BatchUpdateSHTContract.externalData[0].Id);
          SAP_Staging__c s1=new SAP_Staging__C();
         //s.SfHeaderShtNo__c='222';
         s1.CreationInd__c='D';
         s1.SfItemShtNo__c='SHT-0233';
         s1.Processing_Indicator__c='01';
         
         s1.Deal_Created_Date__c=System.Today()-11;
         insert S1;         
         Test.startTest();

            RV_BatchUpdateSHTContract obj = new RV_BatchUpdateSHTContract();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
         
    }
    catch(exception e){
    
    }
    
    }*/

}