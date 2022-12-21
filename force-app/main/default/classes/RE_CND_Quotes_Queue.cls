/******************************************************************************************************************
className           :    RE_CND_Quotes_Queue
Description         :    Queueable Class to move Reuters Quote to RE_Market_Quotes and RE_ReutersHistory for Canada.
Using RE_JobControl__c custom setting to check if the action is needed and active.
RE_JobControl__c acts as single point to activate or decativate a method without any code change.
Author              :    Aasiya Siraj
Date				:	 30-April-2021 
*******************************************************************************************************************/
public class RE_CND_Quotes_Queue implements Queueable{
    
    private RE_Job_Run_Audit__c jra ;
    
    public RE_CND_Quotes_Queue (RE_Job_Run_Audit__c jobAudit){
        this.jra=jobAudit;
        System.debug('Statsu--'+this.jra);
    }
    
    public void execute(QueueableContext context) {
        try{
            Integer totalReutersQuoteCount = 0;
            List<Id> quoteIDList = new List<Id>();
            List<String> quoteNameList = new List<String>();
            List <Reuters_Quotes__c> settlementQuotesCanada = new List <Reuters_Quotes__c>();
            List <Reuters_Quotes__c> fxRatesCanada = new List <Reuters_Quotes__c>();
            
            Set<Id> commonQuoteIds = new Set<Id>();
            Set<Id> canadaQuoteIds = new Set<Id>();
            
            Boolean isDeleteCanada = false;
            Boolean isDeleteOtherCountry = false;
            Boolean isDeleteException=false;
            
            Map<String, String> displayNameMAp = new Map<String,String>();
            Map<Id,String> marketIdDisplayNameMap = new Map<Id,String>();
            Map<Id,String> fxIdDisplayNameMap = new Map<Id,String>();
            Map<String,String> frequencyNameMap = new Map<String,String>();
            Map<String,Boolean> pricetobeconvrtdMap = new Map<String,Boolean>();
            
            Map<Id, RE_CND_QuotesqueueHandler.StatusWrapper> IDMovedtoMarket 	= new Map<Id,RE_CND_QuotesqueueHandler.StatusWrapper>();
            Map<Id, RE_CND_QuotesqueueHandler.StatusWrapper> IDMovedtoHistory 	= new Map<Id,RE_CND_QuotesqueueHandler.StatusWrapper>();
            Map<Id, RE_CND_QuotesqueueHandler.StatusWrapper> IDMovedtoFX 		= new Map<Id,RE_CND_QuotesqueueHandler.StatusWrapper>();
            Map<String,Boolean> isActiveMethod = new Map<String,Boolean>();
            
            Decimal FxRate;
           
            RE_CND_QuotesQueueHandler.CountWrapper marketStatusCount = new RE_CND_QuotesQueueHandler.CountWrapper();
            RE_CND_QuotesQueueHandler.CountWrapper historyStatusCount = new RE_CND_QuotesQueueHandler.CountWrapper();
            RE_CND_QuotesQueueHandler.CountWrapper fxStatusCount = new RE_CND_QuotesQueueHandler.CountWrapper();
            
            //RE_JobControls__c checks active methods
            for(RE_JobControls__c rjc :[SELECT Id,Active__c,Method_Name__c FROM RE_JobControls__c WHERE Class_Name__c='RE_CND_QuotesQueueHandler' AND Country__c='Canada'])
            {
                isActiveMethod.put(rjc.Method_Name__c,rjc.Active__c);
            }
            
           if(isActiveMethod.containsKey('getTodaysCanadianQuotes') && isActiveMethod.get('getTodaysCanadianQuotes'))
            {
                RE_CND_QuotesQueueHandler.quoteWrapper qw =new RE_CND_QuotesQueueHandler.quoteWrapper();
                qw =RE_CND_QuotesQueueHandler.getTodaysCanadianQuotes(jra); 
                
                settlementQuotesCanada 	= 	qw.settlementQuotes;
                fxRatesCanada			=	qw.fxRates;
                
                commonQuoteIds 			=	qw.commonQuoteIDSet;
                canadaQuoteIds			=	qw.onlyCanadaQuoteIDSet;
                quoteIDList				=	qw.quoteIDList;
                
                marketIdDisplayNameMap	=	qw.marketIdDisplayNameMap;
                fxIdDisplayNameMap		=	qw.fxIdDisplayNameMap;
                displayNameMAp			=	qw.displayNameMap ;
                frequencyNameMap		=	qw.frequencyNameMap;
                IDMovedtoMarket			=	qw.isIDMovedtoMarket;
                IDMovedtoHistory		=	qw.isIDMovedtoHistory;
                IDMovedtoFX				=	qw.isIDMovedtoFX;
                totalReutersQuoteCount	=	quoteIDList.size();
                FxRate					= 	qw.fxRateValue;
                pricetobeconvrtdMap     = 	qw.pricetobeconvrtdMap;
            }
            
            //if moveToMarketQuotes is active ,Settlement Quotes are moved from Reuters Quotes to Market Quotes
            System.debug('Queue--jra--'+jra);
           if(isActiveMethod.containsKey('moveToMarketQuotes') && isActiveMethod.get('moveToMarketQuotes')){
                IDMovedtoMarket=RE_CND_QuotesQueueHandler.moveToMarketQuotes(FxRate,settlementQuotesCanada,displayNameMAp, marketIdDisplayNameMap,jra,IDMovedtoMarket,frequencyNameMap,pricetobeconvrtdMap);
            }
            //if moveToFXRates is active ,FX  are moved from Reuters Quotes to FX Rates
            
            if(isActiveMethod.containsKey('moveToFXRates') && isActiveMethod.get('moveToFXRates')){
                IDMovedtoFX=RE_CND_QuotesQueueHandler.moveToFXRates(fxRatesCanada,displayNameMAp, fxIdDisplayNameMap,jra,IDMovedtoFX);
            }
            
            //if moveToReutersHistory is active ,all Canada quotes in Reuters Quotes is moved to Reuters History
            
            if(isActiveMethod.containsKey('moveToReutersHistory') && isActiveMethod.get('moveToReutersHistory')){
                List <Reuters_Quotes__c> allQuotes = new List <Reuters_Quotes__c>();
                allQuotes.addAll(settlementQuotesCanada);
                allQuotes.addAll(fxRatesCanada);
                IDMovedtoHistory= RE_CND_QuotesQueueHandler.moveToReutersHistory(allQuotes,displayNameMAp, quoteIDList,jra,IDMovedtoHistory);
            }
            
            //if deleteCanadaQuotes is enabled it will delete Reuters Quote where country is Canada only
            //if deleteCommonQuotes is enabled it will delete Reuters Quote where country has value besides Canada
            //if deleteCommonQuotes is disabled it will not delete Reuters Quote which is common for other countries
            
          
           if(isActiveMethod.containsKey('deleteCanadaQuotes') && isActiveMethod.containsKey('deleteCommonQuotes') )
            {
                isDeleteCanada			=	isActiveMethod.get('deleteCanadaQuotes');
                isDeleteOtherCountry	=	isActiveMethod.get('deleteCommonQuotes');
                marketStatusCount 		=	RE_CND_QuotesQueueHandler.getStatusCount(IDMovedtoMarket,jra);
                historyStatusCount 		=	RE_CND_QuotesQueueHandler.getStatusCount(IDMovedtoHistory,jra);
                fxStatusCount 			=	RE_CND_QuotesQueueHandler.getStatusCount(IDMovedtoFX,jra);
                System.debug('marketStatusCount--'+marketStatusCount);
                System.debug('historyStatusCount--'+historyStatusCount);
                System.debug('fxStatusCount--'+fxStatusCount);
                //if number of reuters quotes are moved to market quotes and fx rates is same as total quotes,then delete quotes from reuters quote
                Integer totalSuccess=marketStatusCount.successIDSet.size()+fxStatusCount.successIDSet.size();
                if(totalSuccess==totalReutersQuoteCount)
                {
                    isDeleteException=RE_CND_QuotesQueueHandler.deleteQuotes(canadaQuoteIds,commonQuoteIds,isDeleteCanada,isDeleteOtherCountry,jra);  
                }
                
                //if all the reuters quote are not moved to market quotes and fx rates then check number of records moved to reuters history
                else if(totalSuccess < totalReutersQuoteCount)
                {
                    //if number of reuters quotes are moved to History is same as total quotes,then delete all quotes from reuters quote
                    if(historyStatusCount.successIDSet.size() ==totalReutersQuoteCount)
                    {
                        
                        isDeleteException=RE_CND_QuotesQueueHandler.deleteQuotes(canadaQuoteIds,commonQuoteIds,isDeleteCanada,isDeleteOtherCountry,jra);
                    }
                    //if number of reuters quotes are moved to History is less than total quotes,then compare number of records moved to market quotes and fx
                    // with number of records moved to reuters history
                    
                    else if(historyStatusCount.successIDSet.size() < totalReutersQuoteCount)
                    {
                        System.debug('history <total');
                        //partial delete 
                        if(totalSuccess >=historyStatusCount.successIDSet.size())
                        {
                            //delete records moved to market
                            System.debug('market >=history');
                            isDeleteException=RE_CND_QuotesQueueHandler.partialDeleteCanadaQuotes(canadaQuoteIds,commonQuoteIds,isDeleteCanada,isDeleteOtherCountry,jra,marketStatusCount.successIDSet);
                        }
                        else
                        {
                            //delete records moved to history
                            System.debug('market < history');
                            isDeleteException=RE_CND_QuotesQueueHandler.partialDeleteCanadaQuotes(canadaQuoteIds,commonQuoteIds,isDeleteCanada,isDeleteOtherCountry,jra,historyStatusCount.successIDSet);
                        }
                    }
                }
            }
            
            //if sendJobReportMail is enable Status report is sent
            if(isActiveMethod.containsKey('sendJobReportMail') && isActiveMethod.get('sendJobReportMail')){
                System.debug('Queue--sendJobReportMail--');
                Boolean isfailReport 	=	false;
                Boolean isSuccessReport =	false;
                
                 //if sendFailureReportMail is enabled, Status report is sent only if there is failure
                if(isActiveMethod.containsKey('sendFailureReportMail') && isActiveMethod.get('sendFailureReportMail'))
                {
                    isfailReport =true;
                }
                
                //if sendSuccessReportMail is enabled, Status report is sent only if there is success
                if(isActiveMethod.containsKey('sendSuccessReportMail') && isActiveMethod.get('sendSuccessReportMail'))
                {
                    isSuccessReport =true;
                }
                System.debug('Status--'+jra.RE_Job_Status__c+'--isFailReport--'+isfailReport);
                if((jra.RE_Job_Status__c=='Processing' && isSuccessReport)||((jra.RE_Job_Status__c=='Partial Complete' ||jra.RE_Job_Status__c=='Failed' )&& isfailReport))
                {
                    System.debug('send Mail called--');
                    RE_CND_QuotesQueueHandler.sendJobReportMail(totalReutersQuoteCount,historyStatusCount,marketStatusCount,fxStatusCount,isDeleteException,jra);
                }
            }
            
            
            if(jra.RE_Job_Status__c=='Processing')
            {
                jra.RE_Job_Status__c='Completed';               
                update jra;
            }
            
        }
        catch(Exception ex)
        {
            System.debug('Queue--line--'+ex.getLineNumber()+'--exception--'+ex.getCause());
            RE_CND_Utility.updateJobAudit(jra,'Failed',ex);
        }
    }	
}