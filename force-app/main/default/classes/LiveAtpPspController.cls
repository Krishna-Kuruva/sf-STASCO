public class LiveAtpPspController {
    public String option = 'My';
    public String wndw = 'ATP1';
    public String[] companyCodes = new String[]{'DE01'};
    public List<LiveATPPSPDemoController.ATPWrap> atpWrapper {get;set;}

    public string refreshedTime = '';
    public String getRefreshedTime() {
        return refreshedTime;
    }
    public void setRefreshedTime(String refreshedTime) { this.refreshedTime = refreshedTime; }
    
    public LiveAtpPspController(){
        atpWrapper = new List<LiveATPPSPDemoController.ATPWrap>();
        system.debug('=======>'+companyCodes +'-'+ wndw +'-'+option );
        atpWrapper = LiveATPPSPDemoController.getAllATPList(companyCodes, wndw, option);
        system.debug('=======>'+atpWrapper);
    }
    
    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('My','Show My Locations'));
        options.add(new SelectOption('All','Show All Locations'));
        //options.add(new SelectOption('Customize','Customize Locations')); 
        return options;
    }
    
    public String getOption() {
        return option;
    }
    public void setOption(String option) { this.option = option; }
    
    public List<SelectOption> getTranche(){
        List<SelectOption> tranch = new List<SelectOption>();
        tranch.add(new SelectOption('ATP1','Days(0-14)'));
        tranch.add(new SelectOption('ATP2','Days(15-28)'));
        tranch.add(new SelectOption('ATP3','Days(29-61)')); 
        return tranch;
    }
    
    public String getWndw() {
        return wndw;
    }
    public void setWndw(String wndw) { this.wndw = wndw; }
    
    public List<SelectOption> getChannels() {
        List<SelectOption> chnl = new List<SelectOption>();
        chnl.add(new SelectOption('AT01','AT'));
        chnl.add(new SelectOption('DE01','DE'));
        return chnl;
    }

    public String[] getCompanyCodes() {
        return companyCodes;
    }
    public void SetCompanyCodes(String[] companyCodes){
        this.companyCodes = companyCodes;
    }
    
    public PageReference selectedCompanyCodes(){
        atpWrapper = LiveATPPSPDemoController.getAllATPList(companyCodes, wndw, option);      
        return null;
    }
    
    public PageReference selectedWindows(){
        atpWrapper = LiveATPPSPDemoController.getAllATPList(companyCodes, wndw, option);      
        return null;
    }
    
    public PageReference selectedPreference(){  
        atpWrapper = LiveATPPSPDemoController.getAllATPList(companyCodes, wndw, option);      
        return null;
    }

    public PageReference refreshPage() {
        Datetime myDateTime = system.now();
        refreshedTime = myDateTime.addHours(1).format('dd.MM.yyyy h:mm:ss a');
        /*refreshedTime = string.valueOf(system.now().day()) +'.'+string.valueOf(system.now().month())+'.'+string.valueOf(system.now().year()) +' '+ string.valueOf(system.now().hour().) +':' + string.valueOf(system.now().minute()) +':'+ string.valueOf(system.now().second());*/
        atpWrapper = LiveATPPSPDemoController.getAllATPList(companyCodes, wndw, option);
        return null;
    }
}