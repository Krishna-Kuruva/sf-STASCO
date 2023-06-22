public class TCP_CIPM_preRegWrapper{

    public String  client_id;
    public String  scope;
    public String  auth_type;
    public String  redirect_uri;
    public String  grant_type;
    public String  locale;
    public Boolean  resend;
    public profile_fields profile_fields;
    public TCP_CIPM_preRegWrapper(){
        profile_fields = new profile_fields();
    }
    public class profile_fields{
        public String emailAddress;
        public String firstName ;
        public String lastName;
        public Boolean resourceAccessTradingAndSupplyb2b;
        
    }

}