import { LightningElement, api, track } from 'lwc';
import TCP_PlaceOrderVideo from '@salesforce/label/c.TCP_Place_Order_Video';
import TCP_PortalTourVideo from '@salesforce/label/c.TCP_Portal_Tour_Video';
import TCP_EUGuide from '@salesforce/label/c.TCP_EU_Guide';
import TCP_CSAccountMapping from '@salesforce/label/c.TCP_CS_Account_Mapping';
import TCP_CSUserCreation from '@salesforce/label/c.TCP_CS_User_Creation';
import TCP_CSUserGuide from '@salesforce/label/c.TCP_CS_User_Guide';
import loggedInAsTcpUser from '@salesforce/apex/TCP_HomePageController.loggedInAsTcpUser';

export default class Tcp_ContactUsWithSidebar extends LightningElement {

    @track logOnAsTCP;
    @api label;
    label = {
        TCP_PlaceOrderVideo,
        TCP_PortalTourVideo,
        TCP_EUGuide,
        TCP_CSAccountMapping,
        TCP_CSUserCreation,
        TCP_CSUserGuide
    }
    constructor(){
        super();
        loggedInAsTcpUser().then(result => {
            this.logOnAsTCP = result;
            window.console.log('logged in user commops: '+this.logOnAsTCP);
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.name = undefined;
        });
    
    }


    scrollToTopOfPage(){
        window.scrollTo(0,0);
       }


       handleClickDownloadQuickStartGuide(event){

        window.open("https://www.shell.com/business-customers/chemicals/doing-business-with-us/customer-portal.html")
       }
    
       handleClickPrivacyPolicy(event){
        window.open("https://www.shell.com/privacy.html")
       }
}