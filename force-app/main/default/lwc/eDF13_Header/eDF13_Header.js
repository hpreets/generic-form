import { LightningElement,track, wire, api } from 'lwc';
// import CONTACT_FIRST_NAME from "@salesforce/schema/User.Contact.FirstName";
import getUserName from '@salesforce/apex/LoginController.getUserName';
import getApplicationStatus from '@salesforce/apex/LoginController.getApplicationStatus';
import basePath from "@salesforce/community/basePath";
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';       
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';


export default class EDF13_Header extends NavigationMixin(LightningElement) {
    
    headerLogo = BOOTSTRAPData + '/assets/img/logo.svg';
    uploadIcon = BOOTSTRAPData + '/assets/img/uploads-icon.svg';
    logoutIcon = BOOTSTRAPData + '/assets/img/logout-icon.svg';

    @api applicationStatus = '';
    // @track userDetail;
    

    // @wire(getUserDetails)
    // wiredUserDetails({ error, data }) {
    //     if (data) {
    //         //this.userDetail = data;
    //         this.userName = 'Ravindra';
    //     } else if (error) {
    //         console.log(error);
    //         //this.error = error;
    //     }
    // }

    @wire(getUserName)
    userName;  

    // @wire(getApplicationStatus)
    // applicationStatus; 
    
    showUserLogout = false;

    connectedCallback() { 
        getApplicationStatus().then(response => {
            this.applicationStatus = response;
        }).catch(error => {
            console.log('Header Error:', error);
        });
    }

    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadScript(this, BOOTSTRAPData +'/assets/js/bootstrap.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/custom.js'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/header.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css')
        ]).then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log("Error page")
            });
        //console.log('firstName', firstName);
        
        //this.getUserInfo();
        
    }

    showHideUserLogout() {
        if (this.showUserLogout) {
            this.showUserLogout = false;
        }
        else {
            this.showUserLogout = true;
        }

        console.log('showUserLogout', this.showUserLogout);
    }

    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";
    }

   
}