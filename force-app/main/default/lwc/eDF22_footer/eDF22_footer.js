import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';       
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class EDF22_footer extends LightningElement {

    headerLogo = BOOTSTRAPData + '/assets/img/logo.svg';
    edfLogoFooter = BOOTSTRAPData + '/assets/img/edf-logo-footer.svg';
    linkedinIcon = BOOTSTRAPData + '/assets/img/linkedin-icon.svg';
    twitterIcon = BOOTSTRAPData + '/assets/img/twitter-icon.svg';    

    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData +'/assets/js/bootstrap.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/header.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/community-override.css')
        ]).then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log("Error page")
            });
    }
}