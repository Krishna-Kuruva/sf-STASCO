public class RV_LocaleHelper{  //RV_LocaleHelper.formattedNumber(-1102320);

    public static String formattedNumber(Integer volume){
        List<String> args = new String[]{'0','number','#,###,###,###'};
        String strVal = String.format(volume.format(), args);
        system.debug('str Val  before ------>'+strVal);
        System.debug('Val : '+strVal);
        Boolean rA1 = strVal.contains('.');
        System.debug('Val : '+ra1);
        String lasttwodigit;
        
        
      
        system.debug('str Val  ------>'+strVal);
        String result = UserInfo.getLocale();
        system.debug('----User Locale ====='+result);
        if(result != 'de_DE'){
            strVal = strVal.replace('.','');  
        }else{
            
        }
        return strVal;
    }
    
    public static String formattedDecimal(Decimal volume){

        List<String> args = new String[]{'0','number','#,###,###,###'};

        String strVal = String.format(volume.format(), args);
        
        //System.debug('Val : '+strVal);
        Boolean rA1 = strVal.contains('.');
        //System.debug('Val : '+ra1);
        String lasttwodigit;
        
        
        if(rA1 == true){
            lasttwodigit = strVal.substringAfter('.');
            //System.debug('&&&&&lasttwodigit&&&&&'+lasttwodigit);
            
            strVal = strVal.substring(0,strVal.length()-3);
            //System.debug('Val :  '+strVal);
            
            strVal = strVal.replaceAll(',','.');
            strVal = strVal+','+lasttwodigit;
        }
        else{
            strVal = strVal.replaceAll(',','.');
        }
        //System.debug(strVal);
        return strVal;
    }
    
    
    
    
}