import { LightningElement, track, wire } from 'lwc';
import basePath from '@salesforce/community/basePath';

export default class TCP_UserDropdownLWC extends LightningElement {

    value = 'inProgress';
    changePasswordVal = false;
    logoutVal = false;

    get options() {
        return [
            { label: 'Change Password', value: 'changePassword' },
            { label: 'Logout', value: 'logout' },           
        ];
    }

    handleChange(event) {
        this.value = event.detail.value; 
        if (this.value === 'changePassword') {
            this.changePasswordVal = true;            
            window.open(basePath.substring(0,basePath.length - 2) + "/TS_ChangePassword");
        }
        else if (this.value === 'logout'){
            window.open(basePath.substring(0,basePath.length - 2) + "/TCP_Login","_self");
        }
            
    }
    
}