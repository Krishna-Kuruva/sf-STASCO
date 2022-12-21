/**************************************************************************************************
* Name: RV_MetadataCoverage
* Purpose: Class of Custom MetaData 
* Create Date: 2022-10-20
**************************************************************************************************/
public class RV_MetadataCoverage {
  @testVisible static private Map<String,List<Sobject>> MetadataCoverageRecordsMap = new Map<String,List<Sobject>>();
    
    public List<SObject> getMetadataCoverageRecords(String query){
        if(!MetadataCoverageRecordsMap.containsKey(query)){
            MetadataCoverageRecordsMap.put(query, Database.query(query));
        }
        return MetadataCoverageRecordsMap.get(query);
        
    }
}