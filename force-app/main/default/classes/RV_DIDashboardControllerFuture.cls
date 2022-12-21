/*************************************************
 * Written By :Dhriti
 * Created Date :18/08/2018
 * Decription: This class is used to display future pricing table based on channel,MOT,Location,tax in Rev dashboard
 * Last Modified By:
 * Last Modfied Date :
 * ***********************************************/
public class RV_DIDashboardControllerFuture{
    public List<Revolution_Dashboard__c> revolutionDashboardLst {get;set;}
    public string refreshedTime = '';
    // Added by Dharmendra : PBI328 Start
    public string channelName = ApexPages.currentPage().getParameters().get('channel');
    public String MOGASOption {get;set;}
    public String  taxType {get;set;}
    public String  getChannelName(){
        
        system.debug('---channelName---'+channelName);
         return channelName;
    }
    // Added by Dharmendra : PBI328 End
    public String getRefreshedTime() {
        return refreshedTime;
    }
    public void setRefreshedTime(String refreshedTime) { this.refreshedTime = refreshedTime; }
    //Contructor
    public RV_DIDashboardControllerFuture(){
        revolutionDashboardLst = new List<Revolution_Dashboard__c>();
        fetchDashboard(revolutionDashboardLst);
        //Added by Dharmendra : PBI328
        if(channelName=='DE01'){
	  		MOGASOption='ULG95 E10';
        }else if(channelName=='AT01'){
            MOGASOption='ULG95 E5';
        }
        //String  channelName = ApexPages.currentPage().getParameters().get('channel');
    }
    public static  List<Revolution_Dashboard__c> fetchDashboard(List<Revolution_Dashboard__c> revolutionDashboardLst){
         String  channelName = ApexPages.currentPage().getParameters().get('channel');
         String  motName     = ApexPages.currentPage().getParameters().get('mot');
         String  startDate   = ApexPages.currentPage().getParameters().get('contractStartDate');
         String  endDate     = ApexPages.currentPage().getParameters().get('contractEndDate');
         String  showLocType = ApexPages.currentPage().getParameters().get('showLocType');
         String  taxType     = ApexPages.currentPage().getParameters().get('taxType');

         //Date Type Check starts
         try{Date chkStartDate = Date.valueof(startDate);} catch(Exception e){startDate = String.valueOf(System.today());}
         try{Date chkEndDate = Date.valueof(endDate);} catch(Exception e){endDate = String.valueOf(System.today().addDays(14));}
         //Date Type Check ends
         
         RV_DI_Dashboard rvDashBoard = new RV_DI_Dashboard();
         List<String> channel = new List<String>();
         List<String> MOT = new List<String>();
         if(channelName.contains(',')){
            channel.addall(channelName.split(','));
         }else{
             channel.add(channelName);
         }
         if(motName.contains(',')){
            MOT.addAll(motName.split(','));
         }else{
            MOT.add(motName);
         }
         
         //ATP Live 1,ATP Live 2,ATP Live 3
        
         Rv_DIDashboardController.DashoboardWrapper atpValue = Rv_DIDashboardController.getATPPriceforDashboard(channel,MOT,showLocType,taxType,false); // Lightning controller
         System.debug('------atpValue------>'+atpValue);
          
         List<Revolution_Dashboard__c> revDashBoardsLst = atpValue.dashBoardList;
         List<String> mrcNameLst = new List<String>();
         if(!revDashBoardsLst.isEmpty()){
                Map<Id,MRC__c> mrcMapValue = fetchMRCLst();
                // Price(BSP,PSP,OTM)
                Map<String,Revolution_Dashboard__c> revDashboardMap = rvDashBoard.getPriceForDashboard('Future',
                                                                      Date.valueof(startDate),Date.valueof(endDate),
                                                                      mrcMapValue);
                System.debug('-----revDashboardMap---'+revDashboardMap.keyset());
               
                for(Revolution_Dashboard__c rev : revDashBoardsLst){
                     System.debug('-----Unique key---'+rev.UniqueKey__c);
                     Revolution_Dashboard__c revolDashboard = new Revolution_Dashboard__c();
                     revolDashboard.Plant_Name_Text__c = rev.Plant_Name__r.Name;
                     revolDashboard.Sales_Channel__c   = rev.Sales_Channel__c;
					 revolDashboard.UniqueKey__c =   rev.UniqueKey__c; //Fix_331177_Soumyajit_17Sep2019
                     if(Date.valueof(startDate) >= System.today() && Date.valueof(startDate) <=System.today().addDays(14)){
                       
                         revolDashboard.ATP1_Live_IGO__c = rev.ATP1_Live_IGO__c;
                         revolDashboard.ATP1_Live_AGO__c = rev.ATP1_Live_AGO__c;
                         revolDashboard.ATP1_Live_MOGAS__c = rev.ATP1_Live_MOGAS__c;
                     }
                     if(Date.valueof(startDate) > System.today().addDays(14) && Date.valueof(startDate) <=System.today().addDays(28)){
                         revolDashboard.ATP1_Live_IGO__c = rev.ATP2_Live_IGO__c;
                         revolDashboard.ATP1_Live_AGO__c = rev.ATP2_Live_AGO__c;
                         revolDashboard.ATP1_Live_MOGAS__c = rev.ATP2_Live_MOGAS__c;
                     }
                     if(Date.valueof(startDate) > System.today().addDays(28)){
                         revolDashboard.ATP1_Live_IGO__c = rev.ATP3_Live_IGO__c;
                         revolDashboard.ATP1_Live_AGO__c = rev.ATP3_Live_AGO__c;
                         revolDashboard.ATP1_Live_MOGAS__c = rev.ATP3_Live_MOGAS__c;
                     }
                    if(rev.UniqueKey__c <> null){
                         if(revDashboardMap.containskey(rev.UniqueKey__c)){
                             
							 if(taxType == 'Taxed'){
                                 //Fix_260839_Lakshmi_20May2019 Starts
                                
                                if(revDashboardMap.get(rev.UniqueKey__c).BSP_IGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).BSP_IGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).BSP_AGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).BSP_AGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).BSP_MOGAS__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).BSP_MOGAS__c = 0;
                                }
                                 
                                if(revDashboardMap.get(rev.UniqueKey__c).PSP_IGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).PSP_IGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).PSP_AGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).PSP_AGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).PSP_MOGAS__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).PSP_MOGAS__c = 0;
                                }
                                 
                                 if(revDashboardMap.get(rev.UniqueKey__c).OTM_IGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).OTM_IGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).OTM_AGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).OTM_AGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).OTM_MOGAS__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).OTM_MOGAS__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).BSP_GTL__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).BSP_GTL__c = 0;
                                }
                                //Fix_260839_Lakshmi_20May2019 ends 
                                
                                revolDashboard.BSP_IGO__c = revDashboardMap.get(rev.UniqueKey__c).BSP_IGO__c;
                                revolDashboard.BSP_AGO__c = revDashboardMap.get(rev.UniqueKey__c).BSP_AGO__c;
                                revolDashboard.BSP_MOGAS__c = revDashboardMap.get(rev.UniqueKey__c).BSP_MOGAS__c;
                             
                                revolDashboard.PSP_IGO__c = revDashboardMap.get(rev.UniqueKey__c).PSP_IGO__c;
                                revolDashboard.PSP_AGO__c = revDashboardMap.get(rev.UniqueKey__c).PSP_AGO__c;
                                revolDashboard.PSP_MOGAS__c = revDashboardMap.get(rev.UniqueKey__c).PSP_MOGAS__c;
                                 
                           		revolDashboard.BSP_GTL__c= revDashboardMap.get(rev.UniqueKey__c).BSP_GTL__c;
                                 
                                  System.debug('Taxed BSP GTL'+ revDashboardMap.get(rev.UniqueKey__c).BSP_GTL__c);
                                 
                                  //Fix_260839_Lakshmi_20May2019 Starts
                                revolDashboard.OTM_IGO__c = revDashboardMap.get(rev.UniqueKey__c).OTM_IGO__c;
                                revolDashboard.OTM_AGO__c = revDashboardMap.get(rev.UniqueKey__c).OTM_AGO__c;
                                revolDashboard.OTM_MOGAS__c = revDashboardMap.get(rev.UniqueKey__c).OTM_MOGAS__c;
                                   
								 // Fix_260839_Lakshmi_20May2019 Ends
                                 
  
                                      
                             }else {
                              
                                if(revDashboardMap.get(rev.UniqueKey__c).Total_Tax_IGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).Total_Tax_IGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).Total_Tax_AGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).Total_Tax_AGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).Total_Tax_MOGAS__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).Total_Tax_MOGAS__c = 0;
                                }
                                
                                if(revDashboardMap.get(rev.UniqueKey__c).BSP_IGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).BSP_IGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).BSP_AGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).BSP_AGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).BSP_MOGAS__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).BSP_MOGAS__c = 0;
                                }
                                 
                                if(revDashboardMap.get(rev.UniqueKey__c).PSP_IGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).PSP_IGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).PSP_AGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).PSP_AGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).PSP_MOGAS__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).PSP_MOGAS__c = 0;
                                }
                                 //Fix_260839_Lakshmi_20May2019 Starts
                                 if(revDashboardMap.get(rev.UniqueKey__c).OTM_IGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).OTM_IGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).OTM_AGO__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).OTM_AGO__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).OTM_MOGAS__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).OTM_MOGAS__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).BSP_GTL__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).BSP_GTL__c = 0;
                                }
                                if(revDashboardMap.get(rev.UniqueKey__c).Total_Tax_GTL__c == null){
                                     revDashboardMap.get(rev.UniqueKey__c).Total_Tax_GTL__c = 0;
                                }
                                 
                                 //Fix_260839_Lakshmi_20May2019 Ends
                                
                                revolDashboard.BSP_IGO__c = revDashboardMap.get(rev.UniqueKey__c).BSP_IGO__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_IGO__c;
                                revolDashboard.BSP_AGO__c = revDashboardMap.get(rev.UniqueKey__c).BSP_AGO__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_AGO__c;
                                revolDashboard.BSP_MOGAS__c = revDashboardMap.get(rev.UniqueKey__c).BSP_MOGAS__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_MOGAS__c;
                             
                                revolDashboard.PSP_IGO__c = revDashboardMap.get(rev.UniqueKey__c).PSP_IGO__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_IGO__c;
                                revolDashboard.PSP_AGO__c = revDashboardMap.get(rev.UniqueKey__c).PSP_AGO__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_AGO__c;
                                revolDashboard.PSP_MOGAS__c = revDashboardMap.get(rev.UniqueKey__c).PSP_MOGAS__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_MOGAS__c;
                                 
                                //Fix_260839_Lakshmi_20May2019 Starts 
                             	revolDashboard.BSP_GTL__c=revDashboardMap.get(rev.UniqueKey__c).BSP_GTL__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_GTL__c;
                                  System.debug('Untaxed GTL'+ revDashboardMap.get(rev.UniqueKey__c).BSP_GTL__c);
                                 
                             
                              
                                revolDashboard.OTM_IGO__c = revDashboardMap.get(rev.UniqueKey__c).OTM_IGO__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_IGO__c;
                                revolDashboard.OTM_AGO__c = revDashboardMap.get(rev.UniqueKey__c).OTM_AGO__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_AGO__c;
                                revolDashboard.OTM_MOGAS__c = revDashboardMap.get(rev.UniqueKey__c).OTM_MOGAS__c - revDashboardMap.get(rev.UniqueKey__c).Total_Tax_MOGAS__c;
                                 
                                 
                             }
                             //Fix_260839_Lakshmi_20May2019 Ends
                         }
                        //UATAdditionalFix_13Aug2019_Soumyajit starts
                        if(revolDashboard.ATP1_Live_IGO__c ==0)
                            revolDashboard.ATP1_Live_IGO__c = null;
                        if(revolDashboard.ATP1_Live_AGO__c ==0)
                            revolDashboard.ATP1_Live_AGO__c = null;
                        if(revolDashboard.ATP1_Live_MOGAS__c ==0)
                            revolDashboard.ATP1_Live_MOGAS__c = null;
                        if(revolDashboard.BSP_IGO__c ==0)
                            revolDashboard.BSP_IGO__c = null;
                        if(revolDashboard.BSP_AGO__c ==0)
                            revolDashboard.BSP_AGO__c = null;
                        if(revolDashboard.BSP_MOGAS__c ==0)
                            revolDashboard.BSP_MOGAS__c = null;
                        if(revolDashboard.PSP_IGO__c ==0)
                            revolDashboard.PSP_IGO__c = null;
                        if(revolDashboard.PSP_AGO__c ==0)
                            revolDashboard.PSP_AGO__c = null;
                        if(revolDashboard.PSP_MOGAS__c ==0)
                            revolDashboard.PSP_MOGAS__c = null;
                        if(revolDashboard.BSP_GTL__c ==0)
                            revolDashboard.BSP_GTL__c= null;
                        if(revolDashboard.OTM_IGO__c ==0)
                            revolDashboard.OTM_IGO__c = null;
                        if(revolDashboard.OTM_AGO__c ==0)
                            revolDashboard.OTM_AGO__c = null;
                        if(revolDashboard.OTM_MOGAS__c ==0)
                            revolDashboard.OTM_MOGAS__c = null;
                        //UATAdditionalFix_13Aug2019_Soumyajit ends
                        
                         revolutionDashboardLst.add(revolDashboard);
                    }
             }
             System.debug('------revolutionDashboardLst----->'+revolutionDashboardLst);
         }
         return revolutionDashboardLst;
    }
    
    public static Map<Id,MRC__c> fetchMRCLst(){
        //Set<String> MaterialSet= new  Set<String>{'000000000400001685','000000000400002410','000000000400001637','000000000400001986','000000000400003805','000000000400002484'}; 	//400003805 & 400002484 added by Dharmendra : PBI328 
        String customLabel = Label.RV_MaterialName;
        List<String> matNameLst = customLabel.split(',');
        Set<String> MaterialSet = new Set<String>(matNameLst);
        String recTypeId = Schema.SObjectType.MRC__c.getRecordTypeInfosByDeveloperName().get('DI_Dashboard').getRecordTypeId();
        Map<Id,MRC__c> mrcMap = new Map<Id, MRC__c>([Select Id, Ship_to_Name__c, Shipping_Condition__c, Sales_Organization__c, 
                                        Material_Description__c, Plant__r.Name,PO_Type__c, Handling_Type__c,
                                        Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,
                                        Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,
                                        Sold_To__c, Plant__c, Plant_Code__c, 
                                        Valid_From_Date__c, Valid_To_Date__c, Name, Product__c, Mode_Of_Transport__c 
                                        from MRC__c where RecordTypeId =:recTypeId AND Product__r.Name IN :MaterialSet
                                        LIMIT 1000]);
        return mrcMap;
    }
    //Polling Method
    public PageReference refreshPage() {
        Datetime myDateTime = system.now();
        refreshedTime = myDateTime.addHours(1).format('dd.MM.yyyy h:mm:ss a');
        refreshedTime = string.valueOf(system.now().day()) +'.'+
                        string.valueOf(system.now().month())+'.'+
                        string.valueOf(system.now().year()) +' '+ 
                        string.valueOf(system.now().hour()) +':' + 
                        string.valueOf(system.now().minute()) +':'+ 
                        string.valueOf(system.now().second());
        revolutionDashboardLst = new List<Revolution_Dashboard__c>();
        revolutionDashboardLst = fetchDashboard(revolutionDashboardLst);
        return null;
    }
   
}