public class BenefitController {
	
    //Methods to dynamically fetch Picklist Values :Start
    @AuraEnabled
    public  static Map<String,String> getLevel(){
       Map<String,String> options = new Map<String,String>();        
       Schema.DescribeFieldResult fieldResult = Benefit__c.Level__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
       for( Schema.PicklistEntry f : ple){
            options.put(f.getLabel(),f.getValue());
       }       
       return options;   
    }
    
    @AuraEnabled
    public  static Map<String,String> getL1Type(String recordTypeId){
       Map<String,String> options = new Map<String,String>();  
       if(recordTypeId!=null){
       		String Name=[Select Name from RecordType where Id=:recordTypeId].Name;
       		String recTypeId=Schema.SObjectType.Benefit__c.getRecordTypeInfosByName().get('L1').getDeveloperName();
        	If(Name==recTypeId){
            	Schema.DescribeFieldResult fieldResult = Benefit__c.L1_Type__c.getDescribe();
            	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            	for( Schema.PicklistEntry f : ple){
                    options.put(f.getLabel(),f.getValue());
                }
           	}
        }
        return options;   
    }
    
    @AuraEnabled
    public  static Map<String,String> getImpactedUnit(){
       Map<String,String> options = new Map<String,String>(); 
       Schema.DescribeFieldResult fieldResult = Benefit__c.Impacted_Unit__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
       for( Schema.PicklistEntry f : ple){
           options.put(f.getLabel(),f.getValue());
       }          
       return options;   
    }
    
    @AuraEnabled
    public  static Map<String,String> getYear(){
       Map<String,String> options = new Map<String,String>();        
       Schema.DescribeFieldResult fieldResult = Benefit_By_Year__c.Year__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
       for( Schema.PicklistEntry f : ple){
            options.put(f.getLabel(),f.getValue());
       }       
        return options;   
    }
    //Methods to dynamically fetch Picklist Values :End
    
    //Method to Save Data 
    @AuraEnabled
    public static Benefit__c saveDataMethod(Benefit__c benefitObj, 
                                      String benefitChild,
                                      String ParentId, 
                                      String recordTypeId,
                                      String recordId
                                      ){
        Benefit__c b=new Benefit__c();
        //Checking record Id for upsert
        if(recordId !=null){
            b.Id=recordId;
        }
       
        if(benefitObj!=null){
        	b.Name=benefitObj.Name;
            b.Impacted_Unit__c=benefitObj.Impacted_Unit__c;
            b.Included_In_LE__c=benefitObj.Included_In_LE__c;
            b.Impacted_Unit__c=benefitObj.Impacted_Unit__c;
            b.L1_Type__c=benefitObj.L1_Type__c;                             	
        }
            
        if(recordId==null){                               
            b.BE_Activities__c=ParentId;
            
            if(recordTypeId!=null)
                b.RecordTypeId=recordTypeId;
		}
        
		upsert b;
        
        //To insert and update Benefit By Year Records
        List<Benefit_By_Year__c> benefitYear=new List<Benefit_By_Year__c>();
        List<Benefit_By_Year__c> benefitYearListInsert=new List<Benefit_By_Year__c>();
        List<Benefit_By_Year__c> benefitYearListUpdate=new List<Benefit_By_Year__c>();
        benefitYear=(List<Benefit_By_Year__c>)JSON.deserialize(benefitChild,List<Benefit_By_Year__c>.class);
     	System.Debug('benefitYear:'+benefitYear+'List size:'+benefitYear.size());
        for(Benefit_By_Year__c Y:benefitYear){
            Benefit_By_Year__c bYear=new Benefit_By_Year__c();
            System.Debug('Id:'+Y.Id);
            
            bYear.Benefit_Amount__c =Y.Benefit_Amount__c;  
            if(Y.Benefit__c==null)
            	bYear.Benefit__c=b.Id;
            bYear.Year__c=Y.Year__c;
            System.Debug('bYear.Initiative_Id__c:'+bYear.Initiative_Id__c+'benefitObj.BE_Activities__c:'+benefitObj.BE_Activities__c);
            if(bYear.Initiative_Id__c==null)
          		bYear.Initiative_Id__c=benefitObj.BE_Activities__c;
            if(Y.Id!=null){
                bYear.Id=Y.Id;
                benefitYearListUpdate.add(bYear);
            }
            else{
            	benefitYearListInsert.add(bYear);
            }
            
        }
        
        if(benefitYearListUpdate.size()>0)
        	update benefitYearListUpdate;
                                          
        if(benefitYearListInsert.size()>0)
        	insert benefitYearListInsert;        
                                          
        return b;
    }
    
    //Method to display data back on Page Load
    @AuraEnabled
    public static Map<String,Object> getDataMap(string recordId){
    	Map<String,Object> resultMapToReturn = new Map<String,Object>(); 
        if(recordId!=null){
            List<Benefit__c> benfitList=[SELECT Id,BE_Activities__c,BE_Activities__r.Id,L1_Type__c,Name,Included_In_LE__c,Impacted_Unit__c,RecordTypeId,RecordType.Developername FROM Benefit__c where Id=:recordId Limit 1];
            List<Benefit_By_Year__c> benefitYearList=[Select id,Benefit_Amount__c,Benefit__c,Year__c from Benefit_By_Year__c where Benefit__c=:recordId];
            resultMapToReturn.put('parentRecord',benfitList);
            resultMapToReturn.put('ChildRecords',JSON.serialize(benefitYearList));
        }
        return resultMapToReturn;
    }
    
}