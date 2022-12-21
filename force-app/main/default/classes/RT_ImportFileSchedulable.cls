public class RT_ImportFileSchedulable implements Schedulable {
	/*
	Version : 0.0
	Author	: Dharmendra
	Date	: 22-May-2021
	Details	: Schedulable controller for Import Wizard
	*/
    private String TypeID;
    private String LogID;
    private String fileName;
    private map<Integer,String> splitFileNameMap = new map<Integer,String>();
    private boolean createSplitFile = false;
    private map<Integer,String> acceptedFileLines = new map<Integer,String>();
    private List<String> fileLines = new List<String>();
    
    public RT_ImportFileSchedulable(String TypeID
                                   , String LogID
                                   , String fileName
                                   , map<Integer,String> splitFileNameMap
                                   , boolean createSplitFile
                                   , List<String> fileLines )
    {
        this.TypeID = TypeID;
        this.LogID = LogID;
        this.fileName = fileName;
        this.splitFileNameMap = splitFileNameMap;
        this.createSplitFile = createSplitFile;
        this.fileLines = fileLines;
      //  RT_ImportFileSchedulable job = new RT_ImportFileSchedulable();
    }
     public void execute(SchedulableContext sc) {
         System.debug('--Execute Class--');
        System.enqueueJob(new RT_ImportFilesQueueable(TypeID,LogID,fileName,splitFileNameMap,createSplitFile,fileLines));
   		system.abortJob(sc.getTriggerId());
     }
    
  /*  public void finish(SchedulableContext sc){
        CronTrigger ct = [SELECT Id FROM CronTrigger where Id =: sc.getJobId()];
        system.abortJob(ct.id);
    }*/
   /* private String TypeID;
    private String LogID;
    private String fileName;
    private map<Integer,String> splitFileNameMap = new map<Integer,String>();
    private boolean createSplitFile = false;
    private map<Integer,String> acceptedFileLines = new map<Integer,String>();
    private List<String> fileLines = new List<String>();
    public static final String SCHEDULE_TIME = '20 30 8 10 2 ?';
    
    public RT_ImportFileSchedulable(String TypeID
                                   , String LogID
                                   , String fileName
                                   , map<Integer,String> splitFileNameMap
                                   , boolean createSplitFile
                                   , List<String> fileLines )
    {
        this.TypeID = TypeID;
        this.LogID = LogID;
        this.fileName = fileName;
        this.splitFileNameMap = splitFileNameMap;
        this.createSplitFile = createSplitFile;
        this.fileLines = fileLines;
      //  RT_ImportFileSchedulable job = new RT_ImportFileSchedulable();
    }
    
    public void execute(SchedulableContext context)
    {
        
        if(createSplitFile)
            createSplitFiles(LogID);
        
        else
        {
            
            if(splitFileNameMap.size()>0)
            {	
                System.debug('doing split Upload');
                Integer splitCounter = 0;
                Integer thisSplitKey = 0;
                Boolean isLastUpload = false;
                
                for(Integer key : splitFileNameMap.keySet())
                {
                    if(splitCounter != 0)
                        break;
                    else
                        thisSplitKey = key;
                    splitCounter++;
                }
                
                System.debug('Split File Num = '+thisSplitKey);
                RT_ImportFiles.global_SuccessFileName = RT_ImportFiles.defaultSuccessFileName.replace('.csv','') + '_' + thisSplitKey + '.csv';
                RT_ImportFiles.global_ErrorFileName = RT_ImportFiles.defaultErrorFileName.replace('.csv','') + '_' + thisSplitKey + '.csv';
                String splitFileName = splitFileNameMap.get(thisSplitKey);
                
                doUpsert(TypeID, LogID, splitFileName);
                splitFileNameMap.remove(thisSplitKey);
                    
                if(splitFileNameMap.size()>0)
                    isLastUpload = false;
                else
                    isLastUpload = true;
                
                Boolean isError = false;
                RT_ImportLog__c[] logStat = [select id,ImportStatus__c from RT_ImportLog__c where id = :LogID limit 1];
                if(logStat.size()>0)
                    isError = logStat[0].ImportStatus__c.equalsignorecase('Error');
                
                if(!isError)
                	removeSplitFile(LogID, splitFileName,isLastUpload);
                
               // if(!isLastUpload && !isError)
                  //  System.schedule('Schedule Upload',SCHEDULE_TIME,job);
            }
            else
            {
                System.debug('doing normal Upload');
                doUpsert(TypeID, LogID, fileName);
            }
        }
    }
    
    void doUpsert(String fileTypeID, String fileLogID, String upsertfileName)
    {
        try{
    		System.debug('doUpsert with for' + upsertfileName);
                try{
                RT_ImportFiles.resultWrapper rw = RT_ImportFiles.upsertFile(fileTypeID, fileLogID, upsertfileName);
                }
                catch(Exception e){
                    if(LogID != null)
                    {
                        RT_ImportFiles.logWrapper log = new RT_ImportFiles.logWrapper();
                        log.LogID = LogID;
                        log.ImportStatus = 'Error';
                        log.addFile = false;
                        log.errMsg = e.getMessage();
                        log = RT_ImportFiles.saveLog(log);
                    }
                }
            } catch(Exception e){}
    }
    
    void removeSplitFile(String fileLogID, String splitFileName, Boolean isLastUpload)
    {
        try{
        Attachment[] attachList = [select id,Name,body from Attachment where ParentId = :fileLogID and name = :splitFileName];
        
        if(attachList.size()>0)
            delete attachList;
        } catch(Exception e){System.debug(e);}
        
        //String splitMessage = 'Number of Records >= ' + RT_ImportFiles.global_splitFileLimit + '.Please Check Log Files For Success/Error Count.';
        
        RT_ImportFiles.logWrapper log = new RT_ImportFiles.logWrapper();
        log.LogID = fileLogID;
        if(!isLastUpload)
        	log.ImportStatus = 'In Progress';
        else
            log.ImportStatus = 'Completed';
        log.addFile = false;
        //log.SuccessCount = 0;
        //log.ErrorCount = 0;
        //log.errMsg = splitMessage;
        log = RT_ImportFiles.saveLog(log);
    }
    
    @TestVisible
    void createSplitFiles(ID LogID)
    {
        try{
            System.debug('Inside Split');
        
        	map<Integer,String> acceptedFileLines = new map<Integer,String>();
        	Integer lineCounter = 0;
            for(String line : fileLines)
            {
                if(line.trim() != '')
                {
                    acceptedFileLines.put(lineCounter,line);
                    lineCounter++;
                }
            } 
        
        	fileLines.clear();	//Clear Heap
        
            Integer splitFileCnt = (Math.mod(lineCounter, RT_ImportFiles.global_splitFileLimit) ==0) ? (lineCounter/ RT_ImportFiles.global_splitFileLimit) : (lineCounter / RT_ImportFiles.global_splitFileLimit) + 1;
            List<Attachment> attachList = new List<Attachment>();
            
            for(Integer fileCnt = 1; fileCnt <= splitFileCnt; fileCnt++)
            {
                System.debug('HeapSize= '+Limits.getHeapSize());
                String splitFileName = fileName.replace('.csv','') + '_split_'+ fileCnt + '.csv';
                String splitFileContent = acceptedFileLines.get(0) + '\n';
                
                splitFileNameMap.put(fileCnt, splitFileName);
                
                for(Integer lineNum= ((fileCnt-1) * RT_ImportFiles.global_splitFileLimit) + 1;
                    lineNum <= (fileCnt * RT_ImportFiles.global_splitFileLimit) && lineNum < lineCounter; 
                    lineNum++)
                {
                    splitFileContent += acceptedFileLines.get(lineNum);
                    splitFileContent += '\n';
                    acceptedFileLines.remove(lineNum);	//Clear Heap
                }
				
                Attachment attachment = new Attachment();
                attachment.Body = Blob.valueOf(splitFileContent);
                attachment.Name = splitFileName;
                attachment.ParentId = LogID;
                attachList.add(attachment);
            }
            
            if(attachList.size()>0)
            {
                try{
        		insert attachList;
                } catch(Exception e){System.debug(e);}
            }
        
            if(splitFileNameMap.size()>0)
                System.enqueueJob(new RT_ImportFilesQueueable(TypeID, LogID, fileName, splitFileNameMap, false,new List<String>()));
            
            }
                catch(Exception e){
                    if(LogID != null)
                    {
                        RT_ImportFiles.logWrapper log = new RT_ImportFiles.logWrapper();
                        log.LogID = LogID;
                        log.ImportStatus = 'Error';
                        log.addFile = false;
                        log.errMsg = e.getMessage();
                        log = RT_ImportFiles.saveLog(log);
                    }
                }
    }	*/
    
}