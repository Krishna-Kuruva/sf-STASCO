/**
* Created by Dharmendra.Singh2 on 8/18/2021.
*/

public without sharing class rv_customerInfoController {
    @AuraEnabled(Cacheable=true)
    public static contactAndDealWrapper getContact1(String accountId, String mrcId){
        if(accountId == ''){
            return getContact(getAccoutnIdFromMRC(mrcId));
        }else{
            return getContact(accountId);
        }
    }
    public static String getAccoutnIdFromMRC(String mrcHeader){
        MRC__C mrcRec = [Select Id,Sold_To__c from MRC__c where Contract__c =:mrcHeader limit 1 ];
        return mrcRec.Sold_To__c;
    }

    @AuraEnabled(Cacheable=true)
    public static contactAndDealWrapper getContact(String accountId){
        Account acc = (Account) [SELECT Id, Name, Rv_Available_for_OLF__c, Rv_Credit_Available__c, Rv_Credit_Limit__c,Rv_AT01_Customer_Credit_Limit__c,DE01_Customer_Credit_Limit__c,
                                 (SELECT Id, Name, Phone, Email FROM Contacts ORDER BY LastModifiedDate DESC LIMIT 1),
                                 (SELECT Id, Title, Body, CreatedBy.Name, CreatedBy.Alias, CreatedDate   FROM Notes WHERE NOT (Title like '%Deleted%' OR Title like 'Expired%') ORDER BY CreatedDate DESC ),
                                 (SELECT Id, Name, CreatedDate, isOlfDeal__c FROM SHT__r where isOlfDeal__c = true ORDER BY CreatedDate DESC LIMIT 2)
                                 FROM Account WHERE Id=:accountId LIMIT 1];
        contactAndDealWrapper cdwrap = new contactAndDealWrapper();
        if(acc.Contacts.size() > 0){
            cdwrap.primaryContact = acc.Contacts[0];
        }else{
            cdwrap.primaryContact = new Contact();
        }
        cdwrap.notes    =   acc.Notes;
        cdwrap.deals    =   acc.SHT__r;
        cdwrap.account  =   acc;
        System.debug('cdWrap : '+cdwrap);
        return cdwrap;
        
    }
    public class contactAndDealWrapper{
        @AuraEnabled
        public Contact primaryContact{get;set;}
        @AuraEnabled
        public List<SHT__c> deals{get;set;}
        @AuraEnabled
        public List<Note> notes{get;set;}
        @AuraEnabled
        public Account account{get;set;}
        
    }
    // get the list of deals to be displayed on dashboard
    /*
@AuraEnabled(Cacheable=true)
public static AggregateResult[] getDeals(Id accountId){
AggregateResult[] groupedResults
= [SELECT Customer__c, MIN(CreatedDate)
FROM SHT__c
GROUP BY CreatedDate];
return groupedResults;
}
*/
    @AuraEnabled(cacheable=true)
    public static List<Note> getNotes1(String accountId,String mrcId){
        
        if(accountId == '' && mrcId != ''){
             accountId = getAccoutnIdFromMRC(mrcId);
        }
                return getNotes(accountId);
    }
    
    // get the list of notes to be displayed on dashboard
    @AuraEnabled(Cacheable=true)
    public static List<Note> getNotes(String accountId){
        system.debug('accountId::'+accountId);
        /*return (List<Note>) [
SELECT
Body,CreatedById,CreatedBy.Alias,CreatedDate,Id,ParentId,Title
FROM Note
WHERE ParentId =: accountId AND (NOT(Title like '%Deleted%' OR Title like 'valid%'))  WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];*/
        return (List<Note>) [ 
            SELECT Body, Title, CreatedById, CreatedBy.Alias, CreatedBy.Name, CreatedDate, Id, ParentId 
            FROM Note WHERE ParentId =: accountId/*'0012500001RIxDuAAL'*/ AND (NOT(title like '%Deleted%')) 
            AND (( Title like '%valid%' and createddate = today) or (title like 'Save%')) 
            WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
    }
    @AuraEnabled
    public static List<Note> updateNotes(String noteId){
        Note noteToUpdate = (Note)[SELECT Body,CreatedDate,Id,ParentId,Title FROM Note WHERE Id=:noteId];
        //String accountId = noteToUpdate.ParentId;
        //Note updateNote = new  Note();
        
        noteToUpdate.Title = noteToUpdate.Title + 'Deleted';
        System.debug('note to update: '+noteToUpdate);
        try {
            update noteToUpdate;
        }
        catch (Exception e){
            System.debug('Unable to update due to :'+e);
        }
        return getNotes(noteToUpdate.ParentId);
    }
    @AuraEnabled
    public static List<Note> createNote(String noteBody, String accountId, String noteTitle){
        if(accountId != null && accountId.startsWith('001')){
            accountId = accountId;
        }else{
             accountId = getAccoutnIdFromMRC(accountId);
        }
        Note newNote = new Note();
        System.debug('Note title : '+noteTitle);
        newNote.Title = noteTitle+ ' '+'Note created by : '+UserInfo.getName();
        newNote.Body = noteBody;
        newNote.ParentId = accountId;
        try {
            insert newNote;
        }
        catch (Exception e){
            System.debug('Unable to update due to :'+e);
        }
        return getNotes(newNote.ParentId);
    }
}