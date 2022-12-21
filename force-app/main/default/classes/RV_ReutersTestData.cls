public class RV_ReutersTestData {

    
          public static Reuters_Quotes__c ReutersQuotes(){
              
        List<Reuters_Quotes__c> reuters=new List<Reuters_Quotes__c>();
            
           Reuters_Quotes__c reuter=new Reuters_Quotes__c();   
            reuter.Quote_Name__c='Brent Crude';
           reuter.Valid_Month__c='OCT18';
           reuter.Price__c=670;
          reuters.add(reuter);
              
               reuter=new Reuters_Quotes__c();   
            reuter.Quote_Name__c='Brent Crude';
           reuter.Valid_Month__c='OCT18';
           reuter.Price__c=670;
          reuters.add(reuter);
              
               reuter=new Reuters_Quotes__c();   
            reuter.Quote_Name__c='Brent Crude';
           reuter.Valid_Month__c='OCT18';
           reuter.Price__c=670;
          reuters.add(reuter);
              
              
               reuter=new Reuters_Quotes__c();   
            reuter.Quote_Name__c='Brent Crude';
           reuter.Valid_Month__c='OCT18';
           reuter.Price__c=670;
          reuters.add(reuter);
              
              
              
           reuter.Quote_Name__c='ICE LGO IPE Average M P';
        reuter.Quote_Name__c='NYMEX RBOB (unleaded gasoline) LIVE';        
              
              
           
              reuter.Valid_Month__c='SEP18';   
              reuter.Valid_Month__c='NOV18';
              reuter.Valid_Month__c='DEC18';
              reuter.Valid_Month__c='JAN19';
              
         
      
        return reuter;
    }
    
    
    
}