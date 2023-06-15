@isTest
public class RV_FreightRateTriggerHelperTest {
        static testmethod void testFreightRate(){
             Location__c locinsert = new Location__c();
             locinsert = RV_TestHelperPhase2.insertLocationLudwigshafen(locinsert);
             locinsert.Abbreviated_Name__c = 'Ludwigshafen';
             locinsert.Source_Location__c = true;
             insert locinsert;
            
             Location__c locinsert1 = new Location__c();
             locinsert1 = RV_TestHelperPhase2.insertLocationKarlsruhe(locinsert1);
             locinsert1.Abbreviated_Name__c = 'Karlsruhe';
             locinsert1.Source_Location__c = true;
             insert locinsert1;
            
             Reuters_Quotes__c reuterQuoteInsert1 = new Reuters_Quotes__c();
             reuterQuoteInsert1.Price__c = 749.7500;
             reuterQuoteInsert1.Pricing_Date__c = System.today();
             reuterQuoteInsert1.CurrencyCode__c = 'EUR';
             reuterQuoteInsert1.Unit_Of_Measure__c = 't';
             reuterQuoteInsert1.Quote_Name__c = 'GELT_Freight_Mogas_Rdam_Karlsruhe_M (Daily Spot)[EUR/t]';
             reuterQuoteInsert1.Quote_Display_Name__c = 'Reuters (PJK) Rhine Freight Gasoline ARA-Karlsruhe';
             insert reuterQuoteInsert1;
            
             Reuters_Quotes__c reuterQuoteInsert2 = new Reuters_Quotes__c();
             reuterQuoteInsert2.Price__c = 550.4500;
             reuterQuoteInsert2.Pricing_Date__c = System.today();
             reuterQuoteInsert2.CurrencyCode__c = 'EUR';
             reuterQuoteInsert2.Unit_Of_Measure__c = 't';
             reuterQuoteInsert2.Quote_Name__c = 'GELT_Freight_Mogas_Rdam_Frankfurt_M (Daily Spot)[EUR/t]';
             reuterQuoteInsert2.Quote_Display_Name__c = 'Reuters (PJK) Rhine Freight Gasoline ARA-Frankfurt';
             insert reuterQuoteInsert2;
            
             Freight_Rate__c freightRateInsert = new Freight_Rate__c();
             freightRateInsert = RV_TestHelperPhase2.insertFreightRate(freightRateInsert, locinsert1, locinsert);
             freightRateInsert.Freight_Quotation__c = 'Reuters (PJK) Rhine Freight Gasoline ARA-Karlsruhe';
             insert freightRateInsert;
            //added by swarna to cover queuable class
             freightRateInsert.Valid_To__c = System.today().addDays(7);
             freightRateInsert.Marker__c = 23.56;
             freightRateInsert.Freight_Quotation__c = 'Reuters (PJK) Rhine Freight Gasoline ARA-Frankfurt';
             update freightRateInsert;
        }
    
}