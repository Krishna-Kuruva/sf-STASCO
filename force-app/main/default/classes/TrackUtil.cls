/******************************************************************************************************************
className           :    TrackUtil
Description         :    Utility class for creation of History Records
Author              :    Vishal Nigam
Date                :    29-July-2022
Test Class          :    TrackUtilTest
*******************************************************************************************************************/
public without sharing class TrackUtil {

  public static void createHistoryRec(List<Sobject> records,String parentObjApiName, String trackObjAPiName, String status ) {
    Map<String, Schema.DisplayType> fieldListTrackMap = new Map<String, Schema.DisplayType>();
    List<String> finalFields = new List<String>();
    List<SObject> trackRecords = new List<SObject>();
    Map<Id,String> parObjRecordTypMap = new Map<Id,String>();
    Map<String,Id> trckObjRecordTypMap = new Map<String,Id>();
    List<RecordType> rtypesTrack = new List<RecordType>();

    List<RecordType> rtypesParent = [
      SELECT Name, Id
      FROM RecordType
      WHERE sObjectType = :parentObjApiName AND isActive = TRUE];

      if(!rtypesParent.isEmpty())
      {
        for (RecordType rt : rtypesParent)
        {
          parObjRecordTypMap.put(rt.Id,rt.Name);
        }
    
         rtypesTrack = [
          SELECT Name, Id
          FROM RecordType
          WHERE sObjectType = :trackObjAPiName AND isActive = TRUE
        ];

        if(!rtypesTrack.isEmpty())
        {
          for (RecordType rt : rtypesTrack)
          {
            trckObjRecordTypMap.put(rt.Name,rt.Id);
          }
        }

      }

    for (Schema.SObjectField field : schemaMap(trackObjAPiName).values()) {
      if (field.getDescribe().isCustom() && field.getDescribe().isUpdateable() ) {
        fieldListTrackMap.put(
          field.getDescribe().getName(),
          field.getDescribe().getType()
        );
      }
    }
    system.debug(fieldListTrackMap.keySet());

    for (Schema.SObjectField field : schemaMap(parentObjApiName).values()) {
      Schema.DescribeFieldResult fieldInfo = field.getDescribe();
      String parentFieldName = fieldInfo.getName().contains('__c')? fieldInfo.getName(): fieldInfo.getName() + '__c';
      if (
        fieldListTrackMap.containsKey(parentFieldName) &&
        fieldListTrackMap.get(parentFieldName) == fieldInfo.getType() 
      ) {
        finalFields.add(fieldInfo.getName());
      }
    }
    system.debug(':::'+finalFields);
    try {
      for (SObject rec : records) {
        SObject trackRecord = (SObject) Type.forName('Schema', trackObjAPiName).newInstance();
        for (String field : finalFields) {
          String tempField = field.contains('__c')? field:field+'__c';
          trackRecord.put(tempField, rec.get(field));
        }
        trackRecord.put('Parent_RecordId__c',(String)rec.get('Id'));
        trackRecord.put('Record_Action__c',status);
        trackRecord.put('Owner__c',rec.get('OwnerId'));
        if(!rtypesParent.isEmpty() && !rtypesTrack.isEmpty())
        {
          Id tempId  =(Id)rec.get('RecordTypeId');
          String tempName = parObjRecordTypMap.get(tempId);
         trackRecord.put('RecordTypeId',trckObjRecordTypMap.get(tempName));
        }
        
        trackRecords.add(trackRecord);
      }
    Database.SaveResult[] results = Database.insert(trackRecords, false);
    system.debug(results);
  } catch (Exception e) {
    system.debug(e);
   }
  }

  public static Map<String, Schema.SObjectField> schemaMap(String objectApiName) {
    return Schema.getGlobalDescribe()
      .get(objectApiName)
      .getDescribe()
      .fields.getMap();
  }
}