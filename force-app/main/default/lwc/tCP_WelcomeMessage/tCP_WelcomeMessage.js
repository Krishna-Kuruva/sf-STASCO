import { LightningElement,api } from 'lwc';
//import isguest from '@salesforce/user/isGuest';
export default class TCP_WelcomeMessage extends LightningElement {

// isGuestuser=isguest;
// alert('guestuser:'+isGuestuser);
@api orgusername;
@api portalusername;
@api logonastcp;
}