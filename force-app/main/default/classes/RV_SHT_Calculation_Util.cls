public class RV_SHT_Calculation_Util {
 
    private   Integer totalNumberOfDaysRBOB=0;
    private   Integer totalNumberOfDaysBRENT=0;
    private   Integer totalNumberOfDaysAGOIGO=0;
    
    private final Integer addMonthForBrent=1;  
      private final Integer addMonthForRbob=1;  
    private  MonthJumpWrapper rbobMonthJumpWrap;
    private  MonthJumpWrapper brentMonthJumpWrap;
    
    
    private   final  Integer numberOfDecimal=4;
    private  final  Integer addtionalIceDays=1;    
    private  final Integer retuerQuotesDayLimit=500;  
   
    
    
    List<GradesAndQuotesWrap> gradeWithQuotes=new List<GradesAndQuotesWrap>();
    private Map<String,Decimal> mapOfCurrency=new Map<String,Decimal>();
    private Map<String,Decimal> mapofUnits=new Map<String,Decimal>();
    
    private final String CONST_RBOB='RBOB';
    private final String CONST_BRENT='BRENT';
    private final String CONST_AGO_IGO='AGO/IGO';
    private final String CONST_CHF_TO_USD='EUR/CHF';
    private final String CONST_EU_TO_USD='EUR/USD';
    private final String CONST_USD1_CURRENCY_UNIT='US';
    private final String CONST_USD2_CURRENCY_UNIT='USD';    
    private final String CONST_CH1_CURRENCY_UNIT='CH';
    private final String CONST_CH2_CURRENCY_UNIT='CHF'; 
    private final String CONST_CH_CURRENCY_UNIT='CH';
    private final String CONST_US_CURRENCY_UNIT='EU'; 
    public final String CONST_DELIMETER_GRADE_META='_';
    private final String CONST_PRODUCT_MOGAS='MOGAS';
    private final String CONST_PRODUCT_AGO='AGO';
    private final String CONST_PRODUCT_IGO='IGO';
    private final String CONST_IGO_CARGO_ALTERATE1 ='IGO 50ppm_CargoAlternate1';
    private final String CONST_IGO_CARGO_ALTERATE2 ='IGO 50ppm_CargoAlternate2';
    private final String CONST_IGO_TYPE_BARGE='IGO_Barge';
    private final String CONST_IGO_TYPE_CARGO='IGO_Cargo';
    private final String CONST_AGO_TYPE_CARGO='AGO_Cargo';
    private final String CONST_TYPE_THIRD_PARTY='Third party';
    private final String CONST_TYPE_SHELL_OWNED='Own supply';     
    public final String CONST_ALT1_TYPE='Alternate1'; 
    public final String CONST_ALT2_TYPE='Alternate2';
    public final String CONST_BARGE='Barge';
    public final String CONST_CARGO='Cargo';
    
    
    
    /**
* This is the intial entry for the class.It accepts Price Data Wrap which would be send from the backbone AMV 
* formDate and to Date will be same for calculation of all the quotes in the reuters table.
* 
* */
    public List<PriceDataWrap>  getFinalHCV(List<PriceDataWrap> priceDatas,Date fromDate,Date toDate)
    {
        /*for (PriceDataWrap pD:priceDatas)
        {
            System.debug('getFinalHCV priceDatas '+pD);
        }*/
        
        Map<String,PriceDataWrap> mapOfGradeLocAndPriceDataWrap= Initialize(priceDatas);
        
        
        List<PriceDataWrap> resultWraps=new List<PriceDataWrap>();
       
        
        
        
        resultWraps= calculateHCV(mapOfGradeLocAndPriceDataWrap,fromDate,toDate);
        
        getFinalListOFAllPriceDataWrap(priceDatas, resultWraps);
        
                
        return  priceDatas;  
        
    }


    public Map<String,PriceDataWrap> Initialize(List<PriceDataWrap> priceDatas)
    {
        Map<String,PriceDataWrap> returnMapOfGradeLocAndPriceDataWrap=new Map<String,PriceDataWrap>() ;
        PirceInnerWrap innerWrap;
        List<Third_Party_Contract_Master__c> getMetas;
        Map<String,Third_Party_Contract_Master__c> GradeLocationWithThirdAndShellOwned=new Map<String,Third_Party_Contract_Master__c>();
        
        setPlantType(priceDatas);   
        
        setCurrencyAndUnitMap();  
        
        innerWrap= setTypeAndGradeMapForShellOwnedOrThirdParty(priceDatas);
        
        
        
        
        
        getMetas= [select GradeLocation__c,grade__c,Product_sub_grade__c,Average_Quote_1__c,Supplement_Quote_1__c,Average_Quote_2__c,Supplement_Quote_2__c,
                   Average_Multiplier_Quote__c,Base_Quote_1__c,Differential_Quote_1__c,Differential_Quote_2__c,Differential_Quote_3__c,
                   Differential_Quote_4__c,Base_Quote_1_Percent__c,Differential_Quote_1_Percent__c,Differential_Quote_2_Percent__c,
                   Differential_Quote_3_Percent__c,Differential_Quote_4_Percent__c,Shell_Owned_Type__c,isThirdParty__c 
                   from Third_Party_Contract_Master__c
                   where (GradeLocation__c in :innerWrap.mapOfGradewithPlantDataShellThirdPrty.keySet() or GradeLocation__c in :innerWrap.mapOfGradewithPlantDataShellOwned.keySet())
                   order by GradeLocation__c,Valid_To__c asc
                  ];
        
       // System.debug('Initialize getMetas mapOfGradewithPlantDataShellOwned '+innerWrap.mapOfGradewithPlantDataShellOwned);
       // System.debug('Initialize getMetas getMetas '+getMetas);
        
        for(Third_Party_Contract_Master__c thirdPArtyandShellOwned:getMetas)
        {
            //system.debug(' InitializethirdPArtyandShellOwned '+thirdPArtyandShellOwned);
            if(GradeLocationWithThirdAndShellOwned.containsKey(thirdPArtyandShellOwned.GradeLocation__c)==false)
                GradeLocationWithThirdAndShellOwned.put(thirdPArtyandShellOwned.GradeLocation__c,thirdPArtyandShellOwned);
        }
        
       // System.debug('Initialize getMetas GradeLocationWithThirdAndShellOwned '+GradeLocationWithThirdAndShellOwned);
        
        
        setGradeWithQuotes(GradeLocationWithThirdAndShellOwned.values());
        
        returnMapOfGradeLocAndPriceDataWrap.putAll(innerWrap.mapOfGradewithPlantDataShellOwned);
        returnMapOfGradeLocAndPriceDataWrap.putAll(innerWrap.mapOfGradewithPlantDataShellThirdPrty);
        
        
 // for(PriceDataWrap priceWarp : returnMapOfGradeLocAndPriceDataWrap.values())
 // {
     // system.debug('Intialize Final filtered data wrap '+priceWarp);
 // }
        
                
  //for(String priveVal : returnMapOfGradeLocAndPriceDataWrap.keySet())
 //{
      //system.debug('Intialize price Val '+priveVal);
  //}
        
        
        return returnMapOfGradeLocAndPriceDataWrap;
        
        
    }
 
    private List<PriceDataWrap> calculateHCV(Map<String,PriceDataWrap>mapOfGradewithPlantDataShellOwnedAndThirdParty,Date fromDate,Date toDate)
    {
        Map<String,Integer> mapOfIceDaysForAGOIGO;
        Map<String,Integer> mapOfIceDaysForBrent;
        Map<String,Integer> mapOfIceDaysForRbob;
        Map<String,Integer> mapOfIceDays=new Map<String,Integer>();
        
        ReutersQuoteMapWrap retuersValues;
        
        Map<String,Decimal> mapOfBaseQuoteAndQuoteValue;
        Map<String,Decimal> mapOfSettlementQuoteAndQuoteValue;
        Map<String,Decimal> mapOfDifferentialQuoteAndQuoteValue;
        Map<String,Decimal> mapOfFutureAndAverage;
        List<PriceDataWrap> returnValues;
        
        
        //get Months with number of days in Ice Months
        mapOfIceDaysForAGOIGO=getIceMonthWithDays(fromDate, todate,CONST_AGO_IGO);
        mapOfIceDaysForBrent=getIceMonthWithDays(fromDate,toDate,CONST_BRENT);
        mapOfIceDaysForRbob=getIceMonthWithDays(fromDate,toDate,CONST_RBOB);
        
        
        
        
        
        //Print the Maps Only no function call*********************************************
       // System.debug('calculateHCV mapOfIceDaysForAGOIGO'+mapOfIceDaysForAGOIGO);
      //  System.debug('calculateHCV mapOfIceDaysForBrent '+mapOfIceDaysForBrent);
      //  System.debug('calculateHCV mapOfIceDaysForRbob '+mapOfIceDaysForRbob);
        // get the reuters code for settlmenet, base and future
        // 
        //Printing of Maps End *************************************************************    
        //System.debug('MAP of Grade wiht plamnt data shell owned '+mapOfGradewithPlantDataShellOwnedAndThirdParty);
        
        retuersValues=getQuotesFromReuters(mapOfIceDaysForAGOIGO,mapOfIceDaysForBrent,mapOfIceDaysForRbob,mapOfGradewithPlantDataShellOwnedAndThirdParty);
        
        
        
        //Print the Maps Only no function call*********************************************
        
        //Initilaize map for future,base and settlement map
        
        
        mapOfBaseQuoteAndQuoteValue=retuersValues.mapOfBaseQuoteAndQuoteValue;
     //   System.debug('calculateHCV  mapOfBaseQuoteAndQuoteValue'+mapOfBaseQuoteAndQuoteValue);
        mapOfSettlementQuoteAndQuoteValue=retuersValues.mapOfSettlementQuoteAndQuoteValue;    
      //  System.debug('calculateHCV mapOfSettlementQuoteAndQuoteValue'+mapOfSettlementQuoteAndQuoteValue);
        mapOfDifferentialQuoteAndQuoteValue=retuersValues.mapOfDifferentialQuoteAndQuoteValue;  
      // System.debug('calculateHCV mapOfDifferentialQuoteAndQuoteValue'+mapOfDifferentialQuoteAndQuoteValue);
        
        // Initalize End **        
        
        //Printing of Maps End *************************************************************
        
        
        
        mapOfFutureAndAverage= getAverageOfFuture(retuersValues.reuterFutureWrap,mapOfIceDaysForAGOIGO,
                                                  mapOfIceDaysForBrent,mapOfIceDaysForRbob );
        
        
        
        
        //System.debug('calculateHCV  mapOfFutureAndAverage'+mapOfFutureAndAverage);
        
        returnValues= setHCVForMOGASOrAGOIGO(mapOfFutureAndAverage, mapOfBaseQuoteAndQuoteValue, mapOfSettlementQuoteAndQuoteValue,mapOfDifferentialQuoteAndQuoteValue,mapOfGradewithPlantDataShellOwnedAndThirdParty,fromDate, todate);
        //System.debug('calculateHCV returnValues '+returnValues);
        return returnValues;
    }	
    
    
    public List<PriceDataWrap>  setHCVForMOGASOrAGOIGO(Map<String,Decimal> mapOfFutureAndAverage, Map<String,Decimal> mapOfBaseQuoteAndQuoteValue,
                                                       Map<String,Decimal> mapOfSettlementQuoteAndQuoteValue,Map<String,Decimal> mapOfDifferentialQuoteAndQuoteValue,Map<String,PriceDataWrap> mapOfGradewithPlantDataShellOwned,
                                                       Date loadingWindowStartDate,Date loadingWindowEndDate)
    {
        List<ReturnWrap> returnWraps = new List<ReturnWrap>();
        List<PriceDataWrap> listOfShellOwnedPriceDataReturnWrap=new List<PriceDataWrap> ();
 
    
        
        Map<String,Decimal> mapOfFutureDifferentialQuoteAndValue=getFutureDifferentialForAGOIGO(loadingWindowStartDate,mapOfGradewithPlantDataShellOwned);
        
        // List<GradeWithQuote__mdt> allGradeMetaData=gradeWithQuotes;
        for(GradesAndQuotesWrap gradeMeta: gradeWithQuotes)
        {
            
            PriceDataWrap priceDataWrap=mapOfGradewithPlantDataShellOwned.get(gradeMeta.MasterLabel); 
            
            ReturnWrap returnWrap=null;
            if(gradeMeta.subGrade==CONST_PRODUCT_MOGAS)
            {
                returnWrap=calculateForMOGAS(gradeMeta, mapOfFutureAndAverage, mapOfBaseQuoteAndQuoteValue,mapOfSettlementQuoteAndQuoteValue, mapOfDifferentialQuoteAndQuoteValue,
                                             mapOfGradewithPlantDataShellOwned);
                
                
            }
            else
            {
                
                returnWrap=calculateForAGOAndIGO(gradeMeta, mapOfFutureAndAverage, mapOfBaseQuoteAndQuoteValue, mapOfSettlementQuoteAndQuoteValue, mapOfDifferentialQuoteAndQuoteValue,
                                                 mapOfGradewithPlantDataShellOwned,priceDataWrap.altType,mapOfFutureDifferentialQuoteAndValue,priceDataWrap.isThirdParty);
            }
            
            
            priceDataWrap.returnWrap=returnWrap;
            listOfShellOwnedPriceDataReturnWrap.add(priceDataWrap);
            //   returnWraps.add(returnWrap);
            
        }
        return listOfShellOwnedPriceDataReturnWrap;
    }
    
    
    public ReturnWrap calculateForAGOAndIGO(GradesAndQuotesWrap gradeMeta,Map<String,Decimal> mapOfFutureAndAverage, 
                                            Map<String,Decimal> mapOfBaseQuoteAndQuoteValue,Map<String,Decimal> mapOfSettlementQuoteAndQuoteValue,
                                            Map<String,Decimal> mapOfDifferentialQuoteAndQuoteValue,Map<String,PriceDataWrap> mapOfGradewithPlantDataShellOwned,String alternateType,
                                            Map<String,Decimal> mapOfFutureDifferentialQuoteAndValue,Boolean isThirdParty )
    {
        ReturnWrap returnWrap=new ReturnWrap();
        Decimal   averageOfFuture=mapOfFutureAndAverage.get(gradeMeta.averageQuote1);
        Decimal   supplementQuote=mapOfSettlementQuoteAndQuoteValue.get(gradeMeta.supplementQuote1);
        Decimal   baseQuoteValue=mapOfBaseQuoteAndQuoteValue.get(gradeMeta.baseQuote1);
        Decimal   baseValuePercent=gradeMeta.baseQuote1Percent;
        Decimal   initialDiffrential=0;
        Decimal   overallDifferentialValue=0;
        
        //System.debug('calculateForAGOAndIGO mapOfFutureDifferentialQuoteAndValue '+mapOfFutureDifferentialQuoteAndValue);
        PriceDataWrap priceDataWrap=mapOfGradewithPlantDataShellOwned.get(gradeMeta.MasterLabel);
        
        if((String.isEmpty(alternateType)==false &&  alternateType==CONST_ALT2_TYPE)||isThirdParty==true)
        {
            overallDifferentialValue=calculateDifferential(mapOfDifferentialQuoteAndQuoteValue, gradeMeta);
        }
      
        if(gradeMeta.label==CONST_IGO_CARGO_ALTERATE1  
           &&mapOfFutureDifferentialQuoteAndValue.containsKey(CONST_IGO_CARGO_ALTERATE1))
        {
           initialDiffrential= mapOfFutureDifferentialQuoteAndValue.get(CONST_IGO_CARGO_ALTERATE1);
            //System.debug('calculateForAGOAndIGO initialDiffrential with future differential '+initialDiffrential);
        }  
        
        
       else if(gradeMeta.label!=CONST_IGO_CARGO_ALTERATE1  && mapOfFutureDifferentialQuoteAndValue.containsKey(gradeMeta.subGradeSupplyType))
        {
           initialDiffrential= mapOfFutureDifferentialQuoteAndValue.get(gradeMeta.subGradeSupplyType);
            //System.debug('calculateForAGOAndIGO initialDiffrential with future differential '+initialDiffrential);
        }
        else
        {
           // System.debug('calculateForAGOAndIGO priceDataWrap '+priceDataWrap);
           // System.debug('calculateForAGOAndIGO initialDiffrential with basequote-supplementquote '+initialDiffrential+' baseQuoteValue '+baseQuoteValue+'supplementQuote '+supplementQuote);
            
            if(supplementQuote==null)
            {
                supplementQuote=0;
            }
            
                        if(baseQuoteValue==null)
            {
                baseQuoteValue=0;
            }
            
            initialDiffrential=baseQuoteValue-supplementQuote;
            //System.debug('calculateForAGOAndIGO initialDiffrential with basequote-supplementquote '+initialDiffrential);
        }
         //System.debug('initialDiffrential'+initialDiffrential);
         //System.debug('averageOfFuture'+averageOfFuture);
        //Fix_PBI_201967_Lakshmi_Starts
        if(averageOfFuture!=null){
        Decimal overallFuture=(initialDiffrential+averageOfFuture);
        
      //  System.debug('overallFuture'+overallFuture);
    //    System.debug('overallDifferentialValue'+overallDifferentialValue);
      //  System.debug('initialDiffrential'+initialDiffrential);
        
        Decimal HCVValue=(baseValuePercent*(overallFuture+overallDifferentialValue))/100;
        
        //System.debug('HCVValue'+HCVValue);
        
        
        returnWrap.futureAverageValue=overallFuture;
        returnWrap.basQuoteValue=baseQuoteValue;
        returnWrap.settlementValue=supplementQuote;
        returnWrap.finalHCVValue=HCVValue;
        
        returnWrap.differentialValue=overallDifferentialValue;
        }
        //Fix_PBI_201967_Lakshmi_Ends
        return returnWrap;
    }
    
    public ReturnWrap calculateForMOGAS(GradesAndQuotesWrap gradeMeta,Map<String,Decimal> mapOfFutureAndAverage, Map<String,Decimal> mapOfBaseQuoteAndQuoteValue,Map<String,Decimal> mapOfSettlementQuoteAndQuoteValue,
                                        Map<String,Decimal> mapOfDifferentialQuoteAndQuoteValue,
                                        Map<String,PriceDataWrap> mapOfGradewithPlantDataShellOwned)
    {
     //   System.debug('calculateForMOGAS mapOfFutureAndAverage '+mapOfFutureAndAverage);
    //    System.debug('calculateForMOGAS gradeMeta '+gradeMeta);
     //   System.debug('calculateForMOGAS mapOfBaseQuoteAndQuoteValue '+mapOfBaseQuoteAndQuoteValue);
     //   System.debug('calculateForMOGAS mapOfSettlementQuoteAndQuoteValue '+mapOfSettlementQuoteAndQuoteValue);
   //     System.debug('calculateForMOGAS mapOfDifferentialQuoteAndQuoteValue '+mapOfDifferentialQuoteAndQuoteValue);
     //   System.debug('calculateForMOGAS mapOfGradewithPlantDataShellOwned '+mapOfGradewithPlantDataShellOwned);
        ReturnWrap returnWrap=new ReturnWrap();
        String grade=gradeMeta.MasterLabel;
        Decimal averageOfBrentFuture=mapOfFutureAndAverage.get(gradeMeta.averageQuote1);
        Decimal averageOfRBOBFuture=mapOfFutureAndAverage.get(gradeMeta.averageQuote2);
        
        Decimal settlementRBOBValue=mapOfSettlementQuoteAndQuoteValue.get(gradeMeta.supplementQuote2); 
        Decimal settlementBrentValue=mapOfSettlementQuoteAndQuoteValue.get(gradeMeta.supplementQuote1);
        
        Decimal baseValue=mapOfBaseQuoteAndQuoteValue.get(gradeMeta.baseQuote1);
        Decimal baseValuePercentage=gradeMeta.baseQuote1Percent;
        
        Decimal baseValuetoMultiplySubtract=mapOfBaseQuoteAndQuoteValue.get(gradeMeta.averageMultiplierQuote);
        
        Decimal overallDifferential=0;
        
        if(baseValuetoMultiplySubtract==null||baseValuetoMultiplySubtract==0)
        {
            return returnWrap;
        }
        
        //Decimal calculateBrent= ((((averageOfBrentFuture/settlementBrentValue) * baseValuetoMultiplySubtract)) - baseValuetoMultiplySubtract)* 0.3333;    
        //Decimal calculateRBOB= ((((averageOfRBOBFuture/settlementRBOBValue) * baseValuetoMultiplySubtract)) - baseValuetoMultiplySubtract)* 0.6667;      
       Decimal calculateBrent;    
        Decimal calculateRBOB;    
        Decimal overallFutureOfMogas;
        try
        {
         calculateBrent= ((averageOfBrentFuture/settlementBrentValue) - 1)/3;    
         calculateRBOB= (((averageOfRBOBFuture/settlementRBOBValue) - 1)*2)/3;    
         overallFutureOfMogas=(calculateBrent+calculateRBOB)*baseValuetoMultiplySubtract;
        overallDifferential=calculateDifferential(mapOfDifferentialQuoteAndQuoteValue, gradeMeta);
        
        Decimal HCVValue= (baseValuePercentage* (baseValue+overallFutureOfMogas+overallDifferential))/100;
        returnWrap.finalHCVValue=HCVValue;
        returnWrap.futureAverageValue=overallFutureOfMogas;
        
        returnWrap.differentialValue=overallDifferential;
        }
        catch(Exception e)
        {
            //System.debug('ERROR in MOGAS for future data missing'+e);
    //      System.debug('ERROR calculateBrent '+calculateBrent+' = '+averageOfBrentFuture+'\\'+settlementBrentValue);
   //      System.debug('ERROR calculateRBOB'+calculateRBOB+' = '+averageOfRBOBFuture+'\\'+settlementRBOBValue);   
   //       System.debug('ERROR overallFutureOfMogas baseValuetoMultiplySubtract'+baseValuetoMultiplySubtract);   
        }
    
      
        
        return returnWrap;
    }
    
    
    private Decimal calculateDifferential(Map<String,Decimal> mapOfDifferentialQuoteAndQuoteValue,GradesAndQuotesWrap thirdeParty)
    {
        
        Decimal differrential=0;
        
        Decimal Quote1Percent=thirdeParty.differentialQuote1Per; 
        Decimal Quote2Percent=thirdeParty.differentialQuote2Per;
        Decimal Quote3Percent=thirdeParty.differentialQuote3Per;
        Decimal Quote4Percent=thirdeParty.differentialQuote4Per;
        
        
        
        
        Decimal Quote1=mapOfDifferentialQuoteAndQuoteValue.get(thirdeParty.differntialQuote1);
        Decimal Quote2=mapOfDifferentialQuoteAndQuoteValue.get(thirdeParty.differntialQuote2);
        Decimal Quote3=mapOfDifferentialQuoteAndQuoteValue.get(thirdeParty.differntialQuote3);
        Decimal Quote4=mapOfDifferentialQuoteAndQuoteValue.get(thirdeParty.differntialQuote4);
        
        
        //system.debug('calculateDifferential mapOfDifferentialQuoteAndQuoteValue'+mapOfDifferentialQuoteAndQuoteValue);
        //system.debug(' calculateDifferential thirdeParty'+thirdeParty);
        
        
        
        /*System.debug('calculateDifferential Quote1_Per__c'+Quote1Percent);
        System.debug(' calculateDifferential Quote2_Per__c'+Quote2Percent);
        System.debug(' calculateDifferential Quote3_Per__c'+Quote3Percent);
        System.debug('calculateDifferential Quote4_Per__c'+Quote4Percent);       
        
        
        System.debug('calculateDifferential  Quote1'+Quote1);
        System.debug(' calculateDifferential Quote2'+Quote2);
        System.debug('calculateDifferential  Quote3'+Quote3);  
        System.debug(' calculateDifferential Quote4'+Quote4);*/
        
        
        if(Quote1!=null&&Quote1Percent!=null)
            differrential=differrential+(Quote1*Quote1Percent);
        
        if(Quote2!=null&&Quote2Percent!=null)
            differrential=differrential+(Quote2*Quote2Percent);
        
        if(Quote3!=null&&Quote3Percent!=null)
            differrential=differrential+(Quote3*Quote3Percent);
        
        if(Quote4!=null&&Quote4Percent!=null)
            differrential=differrential+(Quote4*Quote4Percent);
        
        
        
        differrential=differrential/100;
        return differrential;
    }
    
    public ReutersQuoteMapWrap getQuotesFromReuters(Map<String,Integer> mapOfIceDaysForAGOIGO,Map<String,Integer> mapOfIceDaysForBrent,Map<String,Integer> mapOfIceDaysForRbob,Map<String,PriceDataWrap> mapOfGradewithPlantDataShellOwned )
    {
        
        ReutersQuoteMapWrap returnWrap=setQuotesIntialValues(mapOfIceDaysForAGOIGO,mapOfIceDaysForBrent,mapOfIceDaysForRbob,mapOfGradewithPlantDataShellOwned);
        
        
        
        ReutersFutureWrap reuterFutureWrap=returnWrap.reuterFutureWrap;
        
        Map<String,Decimal> mapOfBaseQuoteAndQuoteValue=new Map<String,Decimal>();
        Map<String,Decimal> mapOfSettlementQuoteAndQuoteValue=new Map<String,Decimal>();
        Map<String,Decimal> mapOfDifferentialQuoteAndQuoteValue=new Map<String,Decimal>();
        
        
        Date lastModifiedLimit=System.today() - retuerQuotesDayLimit;
        
        List<Reuters_Quotes__c> quotesValuesReuters=[Select  QuoteAndMonth__c,Valid_Month__c,
                                                     Quote_Display_Name__c,Price__c,CurrencyCode__c,
                                                     Unit_Of_Measure__c ,CreatedDate,LastModifiedDate 
                                                     from Reuters_Quotes__c where
                                                     (Quote_Display_Name__c in: returnWrap.baseQuoteName.keySet() or 
                                                      Quote_Display_Name__c in: returnWrap.supplementName.keySet() or 
                                                      Quote_Display_Name__c in: returnWrap.differentialName.keySet() or
                                                      QuoteAndMonth__c in: returnWrap.reuterFutureWrap.futureAndMonthsBrent.keySet() or
                                                      QuoteAndMonth__c in: returnWrap.reuterFutureWrap.futureAndMonthsRbob.keySet() or
                                                      QuoteAndMonth__c in: returnWrap.reuterFutureWrap.futureAndMonthsAGOIGO.keySet())
                                                     and
                                                     (LastModifiedDate >= : lastModifiedLimit)
                                                     order by QuoteAndMonth__c,LastModifiedDate desc];
        
        
        
        
        
        
        //System.debug('Reuters Quotes : '+quotesValuesReuters);
        
        /*for(Reuters_Quotes__c rq :quotesValuesReuters)
        {
            system.debug('All Quotes For HCV '+rq);
        }
        
        System.debug('Size of quotes reuters list is : '+quotesValuesReuters.size()); 
        System.debug('Intial Map OF Settlement '+returnWrap.supplementName);
        System.debug('Intial Map OF BAse '+returnWrap.baseQuoteName);
        System.debug('	Intial Map OF future '+returnWrap.reuterFutureWrap.futureAndMonthsBrent);*/
        
        for(Reuters_Quotes__c quoteReuters : quotesValuesReuters)
        {
            if(reuterFutureWrap.futureAndMonthsBrent.isEmpty()==false  &&reuterFutureWrap.futureAndMonthsBrent.containsKey(quoteReuters.QuoteAndMonth__c)  && 
               reuterFutureWrap.mapOFutureUniuqAndReuterQuoteBrent.containsKey(quoteReuters.QuoteAndMonth__c)==false)
            {
                reuterFutureWrap.mapOFutureUniuqAndReuterQuoteBrent.put(quoteReuters.QuoteAndMonth__c,quoteReuters);
            }
            
            if(reuterFutureWrap.futureAndMonthsRbob.isEmpty()==false  &&reuterFutureWrap.futureAndMonthsRbob.containsKey(quoteReuters.QuoteAndMonth__c)  && 
               reuterFutureWrap.mapOFutureUniuqAndReuterQuoteRbob.containsKey(quoteReuters.QuoteAndMonth__c)==false)
            {
                reuterFutureWrap.mapOFutureUniuqAndReuterQuoteRbob.put(quoteReuters.QuoteAndMonth__c,quoteReuters);
            }
            
            if(reuterFutureWrap.futureAndMonthsAGOIGO.isEmpty()==false  &&reuterFutureWrap.futureAndMonthsAGOIGO.containsKey(quoteReuters.QuoteAndMonth__c)  && 
               reuterFutureWrap.mapOFutureUniuqAndReuterQuoteAGOIGO.containsKey(quoteReuters.QuoteAndMonth__c)==false)
            {
                reuterFutureWrap.mapOFutureUniuqAndReuterQuoteAGOIGO.put(quoteReuters.QuoteAndMonth__c,quoteReuters);
            }
            
            
            
            if(returnWrap.baseQuoteName.containsKey(quoteReuters.Quote_Display_Name__c)   &&mapOfBaseQuoteAndQuoteValue.containsKey(quoteReuters.Quote_Display_Name__c)==false)
            {
                Decimal price=convertCurrencyAndUnitValue(quoteReuters.Price__c, quoteReuters.CurrencyCode__c, quoteReuters.Unit_Of_Measure__c);
                mapOfBaseQuoteAndQuoteValue.put(quoteReuters.Quote_Display_Name__c,price); 
            }
            if(returnWrap.supplementName.containsKey(quoteReuters.Quote_Display_Name__c)   &&mapOfSettlementQuoteAndQuoteValue.containsKey(quoteReuters.Quote_Display_Name__c)==false)
            {
                Decimal price=convertCurrencyAndUnitValue(quoteReuters.Price__c, quoteReuters.CurrencyCode__c, quoteReuters.Unit_Of_Measure__c);
                mapOfSettlementQuoteAndQuoteValue.put(quoteReuters.Quote_Display_Name__c,price); 
            }
            
            if(returnWrap.differentialName.containsKey(quoteReuters.Quote_Display_Name__c)   && mapOfDifferentialQuoteAndQuoteValue.containsKey(quoteReuters.Quote_Display_Name__c)==false)
            {
                Decimal price=convertCurrencyAndUnitValue(quoteReuters.Price__c, quoteReuters.CurrencyCode__c, quoteReuters.Unit_Of_Measure__c);
                mapOfDifferentialQuoteAndQuoteValue.put(quoteReuters.Quote_Display_Name__c,price); 
            }
            
            
        }
        
        
        
        returnWrap.mapOfBaseQuoteAndQuoteValue=mapOfBaseQuoteAndQuoteValue;
        returnWrap.mapOfSettlementQuoteAndQuoteValue=mapOfSettlementQuoteAndQuoteValue;
        returnWrap.mapOfDifferentialQuoteAndQuoteValue=mapOfDifferentialQuoteAndQuoteValue;
        //system.debug('returnWrap.mapOFutureUniuqAndReuterQuoteAGOIGO '+reuterFutureWrap.mapOFutureUniuqAndReuterQuoteAGOIGO);
        //system.debug('returnWrap.futureAndMonthsAGOIGO '+reuterFutureWrap.futureAndMonthsAGOIGO);
        
        return returnWrap;
    }
    
    public ReutersQuoteMapWrap  setQuotesIntialValues(Map<String,Integer> mapOfIceDaysForAGOIGO,Map<String,Integer> mapOfIceDaysForBrent,Map<String,Integer> mapOfIceDaysForRbob,Map<String,PriceDataWrap> mapOfGradewithPlantDataShellOwned )
    {
        
        ReutersQuoteMapWrap intialQuoteWrap=new ReutersQuoteMapWrap();
        Map<String,Reuters_Quotes__c> mapOFutureUniuqAndReuterQuote=new Map<String,Reuters_Quotes__c>();
        //   List<GradeWithQuote__mdt> gradeMetas=gradeWithQuotes;
        List<GradesAndQuotesWrap> gradeMetasMOGAS=new List<GradesAndQuotesWrap>();
        List<GradesAndQuotesWrap> gradeMetasAGOIGO=new List<GradesAndQuotesWrap>();
        
        for(GradesAndQuotesWrap gradeMeta:gradeWithQuotes)
        {
            String productType=gradeMeta.subGrade;
            
            
            if(String.isEmpty(productType)==false&&productType==CONST_PRODUCT_MOGAS)
            {
                gradeMetasMOGAS.add(gradeMeta);
            }
            else
            {
                gradeMetasAGOIGO.add(gradeMeta);
            }
            
        }
        
        //Fix_PBI_201967_Lakshmi_Starts
        //Start to set the future for ICE AGO/IGO, Brent and RBOB in different MAPS
        if(mapOfIceDaysForAGOIGO!=null && mapOfIceDaysForAGOIGO.isEmpty()==false)
            getfuturesIntialMaps(mapOfIceDaysForAGOIGO, gradeMetasAGOIGO, intialQuoteWrap,CONST_AGO_IGO);
        if(mapOfIceDaysForBrent!=null && mapOfIceDaysForBrent.isEmpty()==false)
            getfuturesIntialMaps(mapOfIceDaysForBrent, gradeMetasMOGAS, intialQuoteWrap,CONST_BRENT);
        if(mapOfIceDaysForRbob!=null && mapOfIceDaysForRbob.isEmpty()==false)
            getfuturesIntialMaps(mapOfIceDaysForRbob, gradeMetasMOGAS, intialQuoteWrap,CONST_RBOB);
 		//Fix_PBI_201967_Lakshmi_Ends        
        //********End to set the future for ICE AGO/IGO, Brent and RBOB in different MAPS
        
        //System.debug('setQuotesIntialValues for futureAndMonthsBrent '+intialQuoteWrap.reuterFutureWrap.futureAndMonthsBrent);
        
       // System.debug('setQuotesIntialValues for futureAndMonthsRbob '+intialQuoteWrap.reuterFutureWrap.futureAndMonthsRbob);
        
       // System.debug('setQuotesIntialValues for futureAndMonthsAGOIGO '+intialQuoteWrap.reuterFutureWrap.futureAndMonthsAGOIGO);
        
        
        
        //Set the Map for Base, supplement and diffrential with Names of Quotes and grade
        for(GradesAndQuotesWrap gradeQuote:gradeWithQuotes)
        {
            String productType=gradeQuote.subGrade;    
            String grade=gradeQuote.MasterLabel;
            
            PriceDataWrap priceWrap=mapOfGradewithPlantDataShellOwned.get(grade);
            
            String baseQuote1=gradeQuote.baseQuote1;
            String supplementQuote1=gradeQuote.supplementQuote1;
            String supplementQuote2=gradeQuote.supplementQuote2;
            
            String averageMultipierQuote=gradeQuote.averageMultiplierQuote;
            
            
            String differntialQuote1=gradeQuote.differntialQuote1;
            String differntialQuote2=gradeQuote.differntialQuote2;
            String differntialQuote3=gradeQuote.differntialQuote3 ;
            String differntialQuote4=gradeQuote.differntialQuote4;
            
            
            
            
            if(String.isEmpty(differntialQuote1)==false)
            {
                intialQuoteWrap.differentialName.put(differntialQuote1,grade);
            }
            if(String.isEmpty(differntialQuote2)==false)
            {
                intialQuoteWrap.differentialName.put(differntialQuote2,grade); 
            }
            if(String.isEmpty(differntialQuote3)==false)
            {
                intialQuoteWrap.differentialName.put(differntialQuote3,grade);
            }
            if(String.isEmpty(differntialQuote4)==false)
            {
                intialQuoteWrap.differentialName.put(differntialQuote4,grade); 
            }
            
            
            
            if(String.isEmpty(baseQuote1)==false)
            {
                intialQuoteWrap.baseQuoteName.put(baseQuote1,grade);
            }
            if(String.isEmpty(supplementQuote1)==false)
            {
                
                if(String.isEmpty(averageMultipierQuote)==false)
                {
                    intialQuoteWrap.baseQuoteName.put(averageMultipierQuote,grade);
                }   
                
                intialQuoteWrap.supplementName.put(supplementQuote1,grade);
            }
            
            if(String.isEmpty(supplementQuote2)==false)
            {
                intialQuoteWrap.supplementName.put(supplementQuote2,grade);
            }
            
            
        }
       // System.debug('setQuotesIntialValues for settlement '+intialQuoteWrap.supplementName);
        
       // System.debug('setQuotesIntialValues for baseQuote '+intialQuoteWrap.baseQuoteName);
        
       // System.debug('setQuotesIntialValues for differential '+intialQuoteWrap.differentialName);
        
        return intialQuoteWrap;
    }
    
    
    public void getfuturesIntialMaps(Map<String,Integer> mapOfIceDays, List<GradesAndQuotesWrap> gradeMetas,ReutersQuoteMapWrap intialQuoteWrap,String type)
    {
        
        for(String month :mapOfIceDays.keySet())
        {
            Integer numberOfDays=mapOfIceDays.get(month);
            for(GradesAndQuotesWrap gradeMeta:gradeMetas)
            {
                
                String productType=gradeMeta.subGrade;
                
                
                if(type==CONST_BRENT)
                {
                    String BrentMonth=month.split('-')[0];
                    intialQuoteWrap.reuterFutureWrap.futureAndMonthsBrent.put(gradeMeta.averageQuote1+ BrentMonth,numberOfDays);
                    intialQuoteWrap.reuterFutureWrap.futureNamesBrent.put(gradeMeta.averageQuote1,gradeMeta.MasterLabel);
                }
                else if(type==CONST_RBOB)
                {
                    String RBOBMonth=month.split('-')[0];
                    intialQuoteWrap.reuterFutureWrap.futureAndMonthsRbob.put(gradeMeta.averageQuote2+ RBOBMonth,numberOfDays);
                    intialQuoteWrap.reuterFutureWrap.futureNamesRbob.put(gradeMeta.averageQuote2,gradeMeta.MasterLabel);
                }
                
                else
                {
                    intialQuoteWrap.reuterFutureWrap.futureAndMonthsAGOIGO.put(gradeMeta.averageQuote1+ month,numberOfDays);
                    intialQuoteWrap.reuterFutureWrap.futureNamesAGOIGO.put(gradeMeta.averageQuote1,gradeMeta.MasterLabel);
                }
            }
        }
    }
    
    public Map<String,Decimal> getAverageOfFuture(ReutersFutureWrap reuterFutureWrap,Map<String,Integer> mapOfIceDaysForAGOIGO,
                                                  Map<String,Integer> mapOfIceDaysForBrent,Map<String,Integer> mapOfIceDaysForRbob )
    {
        Map<String,Decimal> mapOfFutureAndAverage=new Map<String,Decimal>();
        
        /*System.debug('getAverageOfFuture futureNamesBrent '+reuterFutureWrap.futureNamesBrent);
        System.debug('getAverageOfFuture futureNamesRbob '+reuterFutureWrap.futureNamesRbob);
        System.debug('getAverageOfFuture futureNamesAGOIGO'+reuterFutureWrap.futureNamesAGOIGO);
        
        System.debug('getAverageOfFuture mapOFutureUniuqAndReuterQuoteBrent '+reuterFutureWrap.mapOFutureUniuqAndReuterQuoteBrent);
        System.debug('getAverageOfFuture mapOFutureUniuqAndReuterQuoteRbob '+reuterFutureWrap.mapOFutureUniuqAndReuterQuoteRbob);
        System.debug('getAverageOfFuture mapOFutureUniuqAndReuterQuoteAGOIGO'+reuterFutureWrap.mapOFutureUniuqAndReuterQuoteAGOIGO);   */
        
        
        Map<String,Decimal> mapOfFutureBrent=getAverageOfFutureForEachType(reuterFutureWrap.mapOFutureUniuqAndReuterQuoteBrent,mapOfIceDaysForBrent,reuterFutureWrap.futureNamesBrent,CONST_BRENT,totalNumberOfDaysBRENT);
        Map<String,Decimal> mapOfFutureRbob=getAverageOfFutureForEachType(reuterFutureWrap.mapOFutureUniuqAndReuterQuoteRbob,mapOfIceDaysForRbob,reuterFutureWrap.futureNamesRbob,CONST_RBOB,totalNumberOfDaysRBOB);
        Map<String,Decimal> mapOfFutureAGO=getAverageOfFutureForEachType(reuterFutureWrap.mapOFutureUniuqAndReuterQuoteAGOIGO,mapOfIceDaysForAGOIGO,reuterFutureWrap.futureNamesAGOIGO,CONST_AGO_IGO,totalNumberOfDaysAGOIGO);
        
        
        /*System.debug('getAverageOfFuture mapOfFutureBrent '+mapOfFutureBrent);
        System.debug('getAverageOfFuture mapOfFutureRbob '+mapOfFutureRbob);
        System.debug('getAverageOfFuture mapOfFutureAGO'+mapOfFutureAGO);*/
        
        if(mapOfFutureBrent.isEmpty()==false)
        {
            mapOfFutureAndAverage.putAll(mapOfFutureBrent);
            
        }
        if(mapOfFutureRbob.isEmpty()==false)
            mapOfFutureAndAverage.putAll(mapOfFutureRbob);	
        
        if(mapOfFutureAGO.isEmpty()==false)
            mapOfFutureAndAverage.putAll(mapOfFutureAGO);
        
        return mapOfFutureAndAverage;
    }
    
    public Map<String,Decimal> getAverageOfFutureForEachType(Map<String,Reuters_Quotes__c> quotesValues,
                                                             Map<String,Integer> mapOfIceDays,Map<String,String> futureNames,
                                                             String type,Integer totalNumberOfDays)
    {
        
        
       /* System.debug('getAverageOfFutureForEachType quotesValues '+quotesValues);
        System.debug('getAverageOfFutureForEachType mapOfIceDays '+'type '+type+mapOfIceDays);
        System.debug('getAverageOfFutureForEachType futureNames '+futureNames);
        System.debug('getAverageOfFutureForEachType type '+type);
        System.debug('getAverageOfFutureForEachType totalNumberOfDays '+totalNumberOfDays); */
        
        Map<String,Decimal> mapOfFutureAndAverage=new Map<String,Decimal>();
        
        // isDuplicateBrentMonth=true;
        // nameOfDuplicateBrent=brentMonthJump.get(iceMonth);
        
        
        for(String futureQuoteName:  futureNames.keySet())
        {   
            Decimal sumOfQuotes=0;
            Boolean hasDuplicateNotRunnnedForBrent=true;
                Boolean hasDuplicateNotRunnnedForRbob=true;
            for(Reuters_Quotes__c reutersFuture:quotesValues.values())
            {
                String reutersFutureName=reutersFuture.Quote_Display_Name__c;
                String month=reutersFuture.Valid_Month__c;
                if(futureQuoteName != null){
                    if(futureQuoteName.equals(reutersFutureName)&& mapOfFutureAndAverage.containsKey(futureQuoteName)==false)
                    {
                        
                        
                        
                        Reuters_Quotes__c reuters=quotesValues.get(futureQuoteName+month);
                        if(reuters!=null)
                        {
                            if(type==CONST_BRENT)
                                month=month+'-'+CONST_BRENT;
                            else if(type==CONST_RBOB)
                                month=month+'-'+CONST_RBOB;
                            Integer numberofDays=mapOfIceDays.get(month);
                            
                            
                            
                            Decimal price=convertCurrencyAndUnitValue(reutersFuture.Price__c, reutersFuture.CurrencyCode__c, reutersFuture.Unit_Of_Measure__c);  
                            //System.debug('Sum of '+futureQuoteName+month+' Price '+price+'numberofDays '+numberofDays+'mapOfIceDays '+mapOfIceDays);
                            sumOfQuotes=sumOfQuotes+(price * numberofDays) ;
                            //System.debug('Sum of '+futureQuoteName+month+' Price '+price);
                        }
                    }
                }    
            }
            
         //   if(brentMonthJumpWrap.isDuplicateMonth==true&&type==CONST_BRENT&&hasDuplicateNotRunnnedForBrent==true)
         //   {
          // sumOfQuotes=addJumpedBrentOrRbobExtraMonth(futureQuoteName, brentMonthJumpWrap, quotesValues, sumOfQuotes);
                
         //   }
            
         //   if(rbobMonthJumpWrap.isDuplicateMonth==true&&type==CONST_RBOB &&hasDuplicateNotRunnnedForRbob==true)
         //   {
         //  sumOfQuotes=addJumpedBrentOrRbobExtraMonth(futureQuoteName, rbobMonthJumpWrap, quotesValues, sumOfQuotes);
                
          //  }
            
            
            
            
            Decimal average=sumOfQuotes/totalNumberOfDays;
            //System.debug(' average '+average);
            mapOfFutureAndAverage.put(futureQuoteName, average.setScale(numberOfDecimal));       
        }
        return mapOfFutureAndAverage;
    }

public Decimal addJumpedBrentOrRbobExtraMonth(String futureQuoteName,MonthJumpWrapper monthJumpWrap,Map<String,Reuters_Quotes__c> quotesValues,Decimal sumOfQuotes )
{

                Reuters_Quotes__c reuters=quotesValues.get(futureQuoteName+monthJumpWrap.nameOfDuplicate.split('-')[0]);
                if(reuters!=null)
                {
                    Integer numberofDays=monthJumpWrap.daysOfDuplicate;

                    Decimal price=convertCurrencyAndUnitValue(reuters.Price__c, reuters.CurrencyCode__c, reuters.Unit_Of_Measure__c);    
                    
                    sumOfQuotes=sumOfQuotes+(price * numberofDays) ; 
                    
                       //System.debug(' numberofDays '+numberofDays);
                    
                }
 
    
    return sumOfQuotes;
}


    
    public  Map<String,Integer> getIceMonthWithDays(Date fromDate,Date todate,String type)
    {
        Integer totalNumberOfDays=0;
        List<Ice_Month__mdt> iceMonthsStartDates=[Select 	Start_Date__c,End_Date__c,MasterLabel 
                                                  from Ice_Month__mdt where End_Date__c >=:fromDate and Quote_Name__c=:type order   by Start_Date__c asc ]  ;
        List<Ice_Month__mdt> iceMonthsEndDates=[Select 	End_Date__c,MasterLabel 
                                                from Ice_Month__mdt where End_Date__c >= :toDate and Quote_Name__c=:type order by End_Date__c asc]  ;
        if(iceMonthsStartDates.isEmpty()||iceMonthsEndDates.isEmpty())
        {
            return null;
        }  
        
       
        Map<String,Ice_Month__mdt> monthWithIceMeta=new Map<String,Ice_Month__mdt>();
        
        Map<String,Integer> mapOfIceDays=new Map<String,Integer>();
        
        //Get the min ice date to restrict the list from getting above the requird end date iteration.
        Date minEndIceDate=iceMonthsEndDates.get(0).End_Date__c;
        //System.debug('getAverageOfFuture minEndIceDate'+minEndIceDate);
        
        
        Integer sizeOfIceMonthList=iceMonthsStartDates.size();
        for(integer i=0;i<sizeOfIceMonthList;i++)
        {
            Ice_Month__mdt iceMonth= iceMonthsStartDates.get(i);
            Date endDate=iceMonth.End_Date__c;
            
            if(endDate<=minEndIceDate)
            {
                if(i==0 && iceMonth.Start_Date__c!=fromDate)
                {
                    Integer numberOfDays=getDateDifference(fromDate,iceMonth.End_Date__c) ;
                    mapOfIceDays.put(iceMonth.MasterLabel ,numberOfDays);
                    
                    monthWithIceMeta.put(iceMonth.MasterLabel, iceMonth) ;
                    
                    
                    totalNumberOfDays=totalNumberOfDays+numberOfDays;  
                }
                else if(iceMonth.End_Date__c==minEndIceDate)
                {
                    //if(iceMonth.End_Date__c!=toDate)  //EmergencyChange_16Mar2020_Soumyajit 
                    //{ 
                        Integer numberOfDays=getDateDifference(iceMonth.Start_Date__c,toDate) ;
                        mapOfIceDays.put(iceMonth.MasterLabel ,numberOfDays);
                        
                        monthWithIceMeta.put(iceMonth.MasterLabel, iceMonth) ;
                        
                        totalNumberOfDays=totalNumberOfDays+numberOfDays;  
                    //} 
                    break;
                }
                else
                {
                    Integer numberOfDays=getDateDifference(iceMonth.Start_Date__c,iceMonth.End_Date__c) ;
                    mapOfIceDays.put(iceMonth.MasterLabel ,numberOfDays);
                    
                    
                    monthWithIceMeta.put(iceMonth.MasterLabel, iceMonth) ;
                    
                    totalNumberOfDays=totalNumberOfDays+numberOfDays;
                }
            }
        }
        
        if(mapOfIceDays.isEmpty()==false&&mapOfIceDays.size()==1)
        {
            
            List<String> mapKeys = new List<String>(mapOfIceDays.keySet());
            totalNumberOfDays=getDateDifference(fromDate,toDate);
            mapOfIceDays.put(mapKeys[0], totalNumberOfDays);
            
            
            
        }
        
        if(type==CONST_BRENT)
        {
         //  brentMonthJumpWrap= jumpBrentAndRbobDays(monthWithIceMeta, type, addMonthForBrent, mapOfIceDays);
            
        }
        else if(type==CONST_RBOB)
        {
          //  rbobMonthJumpWrap=jumpBrentAndRbobDays(monthWithIceMeta, type, addMonthForRbob, mapOfIceDays);
        }
        
        
        if(type==CONST_RBOB)
            totalNumberOfDaysRBOB=totalNumberOfDays;
        if(type==CONST_BRENT)
            totalNumberOfDaysBRENT=totalNumberOfDays;
        if(type==CONST_AGO_IGO)
            totalNumberOfDaysAGOIGO=totalNumberOfDays; 
        
        return mapOfIceDays; 
    }
    
    
    public MonthJumpWrapper  jumpBrentAndRbobDays(Map<String,Ice_Month__mdt> monthWithIceMeta,String typeRBOBOrBrent,
                                     Integer addMonthsforBrentOrRBOB, Map<String,Integer> mapOfIceDays)
    {
        MonthJumpWrapper jumpWrap=new MonthJumpWrapper();
        Map<String,String> brentorRBOBOldIceMonthWithNewIceMonth=new Map<String,String>();
        Integer currentMonth=System.today().month();
            for(Ice_Month__mdt iceMonth: monthWithIceMeta.values())      
            {
                Date iceStartDate=iceMonth.Start_Date__c;
                Integer startMonth=iceStartDate.month();
                
                if(startmonth==currentMonth)
                {
                    Date startDatetobeJumped = iceStartDate.addMonths(addMonthsforBrentOrRBOB);              
                    //Date.newInstance(iceMonth.Start_Date__c.year(), startmonth+addMonthForBrent, 01);
                    List<Ice_Month__mdt> brentNewDates= [Select Start_Date__c,End_Date__c,MasterLabel from Ice_Month__mdt where Start_Date__c <=:startDatetobeJumped  
                                                         and Quote_Name__c=:typeRBOBOrBrent order by Start_Date__c desc ];
                    brentorRBOBOldIceMonthWithNewIceMonth.put(iceMonth.MasterLabel,brentNewDates.get(0).MasterLabel);
                    //System.debug('BRENT MONTH JUMPED '+brentorRBOBOldIceMonthWithNewIceMonth);
                    break;
                }
                
            }
            
            //The logic over here is written to first check if the Brent Or RBOB month lies in the current month if yes and jump the month in calender to M+2 or M+1
            //repectivley
            
            if(brentorRBOBOldIceMonthWithNewIceMonth.isEmpty()==false)
            {
                for(String iceMonthToBeReplaced:brentorRBOBOldIceMonthWithNewIceMonth.keySet())
                {
                    //system.debug('iceMonth '+iceMonthToBeReplaced+' '+brentorRBOBOldIceMonthWithNewIceMonth+' ICe Month '+mapOfIceDays);
                    String iceMonthTobeAdded=brentorRBOBOldIceMonthWithNewIceMonth.get(iceMonthToBeReplaced);
                    if(mapOfIceDays.containsKey(iceMonthTobeAdded)==false)
                    {
                        Integer iceDay=mapOfIceDays.get(iceMonthToBeReplaced);
                        mapOfIceDays.remove(iceMonthToBeReplaced);
                        mapOfIceDays.put(iceMonthTobeAdded,iceDay);
                        break;
                    }
                    else
                    {
                        //System.debug('Brent does not have M+2 month');
                        
                       
                        
                        jumpWrap.daysOfDuplicate=mapOfIceDays.get(iceMonthToBeReplaced);
                        
                        mapOfIceDays.remove(iceMonthToBeReplaced);
                        jumpWrap.isDuplicateMonth=true;
                        
                        //   System.debug('Brent does not have M+2 month '+duplicatMonth);
                        //System.debug('Ice month Brent'+mapOfIceDays);
                        jumpWrap.nameOfDuplicate=iceMonthTobeAdded;
                        
                    }
                }
            }
        
        return jumpWrap;
    }
    
    
    public Integer getDateDifference (Date startDate,Date endDate)
    {
        return startDate.daysBetween(endDate)+addtionalIceDays;
    }
    
    public void setPlantType(List<PriceDataWrap> priceDatas)
    {
        List<String> plantCodes=new List<String>();
        for(PriceDataWrap price:priceDatas) 
        {
            plantCodes.add(price.plantCode);
        }     
        // Get the location type Barge,cargo for plant Id to codes
        //System.debug('Plane Codes '+plantCodes);
        List<Location__c> locations=[Select Plant_Code__c,	Quote_Region__c,Supply_Type__c from Location__c  where Plant_Code__c in :plantCodes ];
        Map<String,Location__c> mapOfPlantCodeAndType=new  Map<String,Location__c> ();
        for(Location__c location:locations)
        {
            mapOfPlantCodeAndType.put(location.Plant_Code__c, location);
            
        }
        //Write the plant type :Barge or Cargo back to mainnlist
        for(PriceDataWrap priceData:  priceDatas)
        {
            if(mapOfPlantCodeAndType.containsKey(priceData.plantCode))
            {
                Location__c loc=mapOfPlantCodeAndType.get(priceData.plantCode);
                if(String.isEmpty( priceData.locationType))
                {
                    priceData.locationType=loc.Quote_Region__c;
                }
                if(String.isEmpty( priceData.plantType))
                {
                    priceData.plantType =loc.Supply_Type__c;
                }
            }
        }
    }
    
    public void setCurrencyAndUnitMap()
    {
        List<Reuters_Quotes__c> cuurencyQuotes=[Select  Quote_Display_Name__c,Price__c   
                                                from Reuters_Quotes__c where Quote_Display_Name__c =: CONST_CHF_TO_USD or
                                                Quote_Display_Name__c=:CONST_EU_TO_USD];
        Integer lengthOfList=cuurencyQuotes.size();
        for(Integer i=0;i<lengthOfList;i++)
        {
            Reuters_Quotes__c currQuote=cuurencyQuotes.get(i);
            mapOfCurrency.put(currQuote.Quote_Display_Name__c, currQuote.Price__c);
        }
        List<Unit_Reuters_Rate__mdt> units=[Select Conversion_Rate__c,MasterLabel from Unit_Reuters_Rate__mdt ];    
        lengthOfList= units.size();
        for(Integer i=0;i<lengthOfList;i++)
        {
            Unit_Reuters_Rate__mdt unit=units.get(i);
            mapofUnits.put(unit.MasterLabel, unit.Conversion_Rate__c);
        } 
    }
    
    public PirceInnerWrap setTypeAndGradeMapForShellOwnedOrThirdParty(List<PriceDataWrap> priceDatas)
    {
        PirceInnerWrap innerwrap=new PirceInnerWrap();       
        List<PriceDataWrap> priceDataWrapThirdParty= new   List<PriceDataWrap>();  
        List<PriceDataWrap> priceDataWrapshellOwned= new   List<PriceDataWrap>();  
        
        Map<String,PriceDataWrap> mapOfGradewithPlantDataShellOwned=new Map<String,PriceDataWrap>();
        Map<String,PriceDataWrap> mapOfGradewithPlantDataShellThirdPrty=new Map<String,PriceDataWrap>();       
        
        
        //system.debug('Entered in setGradeMap '+priceDatas);
        for(PriceDataWrap price:priceDatas)
        {
            String plantType=price.plantType;
            
            if((String.isEmpty(plantType)==false&&plantType.equals(CONST_TYPE_THIRD_PARTY))||(price.isThirdParty!=null&& price.isThirdParty))
            {
                
               // mapOfGradewithPlantDataShellThirdPrty.put(price.grade+CONST_DELIMETER_GRADE_META+price.plantCode,price);
             String thirdPartyKey= 
                 //price.grade+CONST_DELIMETER_GRADE_META+price.plantCode
                // +CONST_DELIMETER_GRADE_META+
                 price.salesOrg
                +CONST_DELIMETER_GRADE_META+price.routeName ;
                
                price.gradeLocation=thirdPartyKey;
                
                mapOfGradewithPlantDataShellThirdPrty.put(thirdPartyKey                                                        
                                                          ,price);
                priceDataWrapThirdParty.add(price);
                //System.debug('setTypeAndGradeMapForShellOwnedOrThirdParty in if loop for third party '+mapOfGradewithPlantDataShellThirdPrty+' '+priceDataWrapThirdParty);
                
                
            }
            else
            {
                String shellOwnedKey=price.grade+CONST_DELIMETER_GRADE_META+price.locationType;
                
                if(String.isEmpty(price.altType)==false
                   &&(price.altType==CONST_ALT1_TYPE||price.altType==CONST_ALT2_TYPE)
                   && shellOwnedKey.contains('IGO 50ppm_Cargo')
                  )
                {
                   shellOwnedKey=shellOwnedKey+ price.altType;
                }
                
                 price.gradeLocation=shellOwnedKey;
                mapOfGradewithPlantDataShellOwned.put(shellOwnedKey,price);
                
                
                
                priceDataWrapshellOwned.add(price);
            }
        }
        
        
        innerWrap.mapOfGradewithPlantDataShellThirdPrty=mapOfGradewithPlantDataShellThirdPrty;
        innerWrap.mapOfGradewithPlantDataShellOwned=mapOfGradewithPlantDataShellOwned;
        
        return innerwrap;
    }
    
    public Decimal convertCurrencyAndUnitValue(Decimal price,String currType,String unitType )
    {
        Decimal finalprice=price;
        
        if(price !=null)
        {
            //System.debug('Map of Currency' +mapOfCurrency);
            //System.debug(' Converting price '+price+' Currency Type '+currType+' Unit Type '+unitType);
          
            if(mapofUnits.containsKey(unitType))
            {
                finalprice=finalprice * mapofUnits.get(unitType);
            }
            Decimal CHFToUSD=mapOfCurrency.get(CONST_CHF_TO_USD);
            Decimal USDToEUR=1/mapOfCurrency.get(CONST_EU_TO_USD);
          //  USDToEUR=USDToEUR.setScale(numberOfDecimal);
            if(currType.equals(CONST_CH1_CURRENCY_UNIT)||currType.equals(CONST_CH2_CURRENCY_UNIT))
            {
                Decimal priceinUSD=finalprice * CHFToUSD;
                finalprice= priceinUSD * USDToEUR;
            }
            else if(currType.equals(CONST_USD1_CURRENCY_UNIT)||currType.equals(CONST_USD2_CURRENCY_UNIT))
            {
                finalprice= finalprice * USDToEUR;
            }
            
            //System.debug('Converted  To '+finalprice+' Currency Type '+currType+' Unit Type '+unitType+' Unit Price : '+mapofUnits+' USDToEUR '+USDToEUR+' CHFToUSD: '+CHFToUSD);
        }
        finalprice=finalprice.setScale(numberOfDecimal);
        //System.debug('Final Price '+finalprice);
        return finalprice;
    }
    
    
    
    private void setGradeWithQuotes(List<Third_Party_Contract_Master__c> gradeMetasForThirdPartyandShellOwned)
    {
        
        
        
        
        for(Third_Party_Contract_Master__c gradeMeta:gradeMetasForThirdPartyandShellOwned)
        {
            
            GradesAndQuotesWrap gradesQuotes=new GradesAndQuotesWrap();
            gradesQuotes.MasterLabel=gradeMeta.GradeLocation__c;           
            gradesQuotes.label=gradeMeta.GradeLocation__c;
            gradesQuotes.Product=gradeMeta.grade__c;
            gradesQuotes.subGradeSupplyType=gradeMeta.Product_sub_grade__c+'_'+gradeMeta.Shell_Owned_Type__c;
            gradesQuotes.subGrade=gradeMeta.Product_sub_grade__c;
            gradesQuotes.type=gradeMeta.Shell_Owned_Type__c;
            gradesQuotes.averageQuote1=gradeMeta.Average_Quote_1__c;
            gradesQuotes.supplementQuote1=gradeMeta.Supplement_Quote_1__c;
            gradesQuotes.averageQuote2=gradeMeta.Average_Quote_2__c;
            gradesQuotes.supplementQuote2=gradeMeta.Supplement_Quote_2__c;
            gradesQuotes.averageMultiplierQuote=gradeMeta.Average_Multiplier_Quote__c;
            gradesQuotes.baseQuote1=gradeMeta.Base_Quote_1__c;
            gradesQuotes.differntialQuote1=gradeMeta.Differential_Quote_1__c;
            gradesQuotes.differntialQuote2=gradeMeta.Differential_Quote_2__c;
            gradesQuotes.differntialQuote3=gradeMeta.Differential_Quote_3__c;
            gradesQuotes.differntialQuote4=gradeMeta.Differential_Quote_4__c;
            gradesQuotes.baseQuote1Percent=gradeMeta.Base_Quote_1_Percent__c;
            gradesQuotes.differentialQuote1Per=gradeMeta.Differential_Quote_1_Percent__c;
            gradesQuotes.differentialQuote2Per=gradeMeta.Differential_Quote_2_Percent__c;
            gradesQuotes.differentialQuote3Per=gradeMeta.Differential_Quote_3_Percent__c;
            gradesQuotes.differentialQuote4Per=gradeMeta.Differential_Quote_4_Percent__c;
            gradesQuotes.isThirdParty=gradeMeta.isThirdParty__c;
       		//System.debug('setGradeWithQuotes  gradesQuotes '+gradesQuotes);
            
            gradeWithQuotes.add(gradesQuotes) ;          
        }
        
        
        
        
    }
    
    
    private Map<String,Decimal> getFutureDifferentialForAGOIGO(Date loadingWindowStartDate,Map<String,PriceDataWrap> mapOfGradewithPlantDataShellOwned)
    {
        Map<String,Decimal> mapOfFutureDifferentialQuoteAndValue=new Map<String,Decimal>();
       List<String> gradeandSupplyTypeList=new List<String>();  
List<String> gradeandLocationList=new List<String>();  
    
 //CONST_IGO_CARGO_ALTERATE1
        for( GradesAndQuotesWrap gradeAndQuote: gradeWithQuotes)
        {
            //System.debug('getFutureDifferentialForAGOIGO gradeAndQuote '+gradeAndQuote);
            //SubGradeSupplyType__c CONST_IGO_TYPE_CARGO
            if(gradeAndQuote.isThirdParty==false&&
               ((gradeAndQuote.subGrade==CONST_PRODUCT_AGO||gradeAndQuote.subGrade==CONST_PRODUCT_IGO))
               &&gradeAndQuote.subGradeSupplyType!=CONST_IGO_TYPE_CARGO)
            {
                
                gradeandSupplyTypeList.add(gradeAndQuote.subGradeSupplyType);
                gradeandLocationList.add(gradeAndQuote.label);
              
            }
            
        }

               if(gradeandSupplyTypeList.contains(CONST_AGO_TYPE_CARGO)==false) 
               {
                   gradeandSupplyTypeList.add(CONST_AGO_TYPE_CARGO);
               }
            
        
   
            if(gradeandSupplyTypeList.contains(CONST_IGO_TYPE_BARGE)==false) 
               {
                   gradeandSupplyTypeList.add(CONST_IGO_TYPE_BARGE);
               } 
            
        
        
        //system.debug('gradeandSupplyTypeList '+gradeandSupplyTypeList+' gradeandLocationList'+gradeandLocationList);
        
        
        List<Future_Differential__c> futureDifferentials=[Select Diff_Value__c,Grade__c,SubGradeSupplyType__c,Supply_Type__c,Valid_From__c,Valid_To__c from Future_Differential__c
                                                          where SubGradeSupplyType__c   in :gradeandSupplyTypeList and      Valid_From__c <=	:  loadingWindowStartDate
                                                          and Valid_To__c >=	:  loadingWindowStartDate
                                                          order by SubGradeSupplyType__c,Valid_From__c asc
                                                          
                                                         ] ;
        
        //System.debug(' getFutureDifferentialForAGOIGO futureDifferentials '+futureDifferentials+' '+gradeandSupplyTypeList);
        
        if(futureDifferentials.isEmpty()==false)
        {
            for(Future_Differential__c futureDiff:futureDifferentials)
            {
                if(mapOfFutureDifferentialQuoteAndValue.containsKey(futureDiff.SubGradeSupplyType__c)==false)
                {
                    
                    mapOfFutureDifferentialQuoteAndValue.put(futureDiff.SubGradeSupplyType__c, futureDiff.Diff_Value__c);
                }
            }
            
   //System.debug(' getFutureDifferentialForAGOIGO before mapOfFutureDifferentialQuoteAndValue '+mapOfFutureDifferentialQuoteAndValue); 
      
              if(mapOfFutureDifferentialQuoteAndValue.containsKey(CONST_AGO_TYPE_CARGO)) 
               {
                Decimal quoteAgoCargoValue=mapOfFutureDifferentialQuoteAndValue.get(CONST_AGO_TYPE_CARGO);
                mapOfFutureDifferentialQuoteAndValue.put(CONST_IGO_CARGO_ALTERATE1, quoteAgoCargoValue);
      
               }
                
              if(mapOfFutureDifferentialQuoteAndValue.containsKey(CONST_IGO_TYPE_BARGE)) 
               {
               Decimal quoteIgoBargeValue=mapOfFutureDifferentialQuoteAndValue.get(CONST_IGO_TYPE_BARGE);
               mapOfFutureDifferentialQuoteAndValue.put(CONST_IGO_TYPE_CARGO, quoteIgoBargeValue);
                
               }
                
                
            
 
   
            
   
     
        }
          // System.debug(' getFutureDifferentialForAGOIGO mapOfFutureDifferentialQuoteAndValue '+mapOfFutureDifferentialQuoteAndValue);  
        return mapOfFutureDifferentialQuoteAndValue;
    }
    

       public static void getFinalListOFAllPriceDataWrap(List<RV_SHT_Calculation_Util.PriceDataWrap> initialHcvWrap,
                                             List<RV_SHT_Calculation_Util.PriceDataWrap> calculatedHcvWrap){
                                                 
                                                 Map<String,RV_SHT_Calculation_Util.ReturnWrap> mapOfKeyandValue=new    Map<String,RV_SHT_Calculation_Util.ReturnWrap>();
                                                 
                                                 for(RV_SHT_Calculation_Util.PriceDataWrap  pricefinal: calculatedHcvWrap)
                                                 {
                                                     
                                                     mapOfKeyandValue.put(pricefinal.gradeLocation,pricefinal.returnWrap) ;
                                                     
                                                 }
                                                 
                                                 for(RV_SHT_Calculation_Util.PriceDataWrap hcvWrp :initialHcvWrap){
                                                     hcvWrp.returnWrap=mapOfKeyandValue.get(hcvWrp.gradeLocation);
                                                     
                                                 }                                                          
                                                 
                                                 
                                                 
                                             }
    
    
    
    
    public class ReturnWrap
    {
        public Decimal futureAverageValue;
        public Decimal basQuoteValue;
        public Decimal settlementValue;
        public Decimal finalHCVValue;
        public Decimal differentialValue;
        
    }    
    
    public class ReutersQuoteMapWrap
    {
        Map<String,Decimal> mapOfSettlementQuoteAndQuoteValue;
        Map<String,Decimal> mapOfBaseQuoteAndQuoteValue;
        Map<String,Decimal> mapOfDifferentialQuoteAndQuoteValue;
        
        
        ReutersFutureWrap reuterFutureWrap=new  ReutersFutureWrap();
        Map<String,String> baseQuoteName=new Map<String,String>();
        Map<String,String> supplementName=new Map<String,String>(); 
        Map<String,String> differentialName=new Map<String,String>(); 
        
        
    }
    
    public class ReutersFutureWrap
    {
        Map<String,Integer> futureAndMonthsBrent=new Map<String,Integer>();
        Map<String,Integer> futureAndMonthsRbob=new Map<String,Integer>();
        Map<String,Integer> futureAndMonthsAGOIGO=new Map<String,Integer>();
        Map<String,Reuters_Quotes__c> mapOFutureUniuqAndReuterQuoteBrent=new Map<String,Reuters_Quotes__c> () ;
        Map<String,Reuters_Quotes__c> mapOFutureUniuqAndReuterQuoteRbob=new Map<String,Reuters_Quotes__c> ();
        Map<String,Reuters_Quotes__c> mapOFutureUniuqAndReuterQuoteAGOIGO=new Map<String,Reuters_Quotes__c> ();
        Map<String,String> futureNamesBrent=new Map<String,String>();
        Map<String,String> futureNamesRbob=new Map<String,String>();
        Map<String,String> futureNamesAGOIGO=new Map<String,String>();
    }
    
    public class PirceInnerWrap
    {
        
        private Map<String,PriceDataWrap> mapOfGradewithPlantDataShellOwned=new Map<String,PriceDataWrap>();
        private Map<String,PriceDataWrap> mapOfGradewithPlantDataShellThirdPrty=new Map<String,PriceDataWrap>();
    }
    
    public class PriceDataWrap
    {
        @AuraEnabled
        public String type;
        @AuraEnabled
        public string plantType;
        @AuraEnabled
        public string plantCode;
        @AuraEnabled
        public string grade;
        @AuraEnabled
        public string standardGrade;
        @AuraEnabled
        public String locationType;
        @AuraEnabled
        public String altType;
        @AuraEnabled
        public String salesOrg;
        @AuraEnabled
        public String routeName;
        @AuraEnabled
        public Boolean isThirdParty;
        @AuraEnabled 
       public String gradeLocation;
        @AuraEnabled 
        public ReturnWrap returnWrap;
        
        @AuraEnabled
        public String MRCNumber;
        
        public Id verficationId;
    }
    
    public class GradesAndQuotesWrap
    {
        Boolean isThirdParty;
        
        
        public String label;
        public String MasterLabel;
        public String Product;
        public String subGrade;
        public String type;
        public String averageQuote1;
        public String supplementQuote1;
        public String averageQuote2;
        public String supplementQuote2;
        public String averageMultiplierQuote;
        public String subGradeSupplyType;
        
        
        public String baseQuote1;
        public String differntialQuote1;
        public String differntialQuote2;
        public String differntialQuote3;
        public String differntialQuote4;
        public String differntialQuote5;
        
        
        
        public Decimal baseQuote1Percent;
        public Decimal differentialQuote1Per;
        public Decimal differentialQuote2Per;
        public Decimal differentialQuote3Per;
        public Decimal differentialQuote4Per; 
        public Decimal differentialQuote5Per; 
    }
    
    public class MonthJumpWrapper
    {
        
    private Boolean isDuplicateMonth=false;
    private String nameOfDuplicate;
    private Integer daysOfDuplicate=0;
  
    
    }
 
}
