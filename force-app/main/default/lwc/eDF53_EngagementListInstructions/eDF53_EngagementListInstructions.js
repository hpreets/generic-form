import { LightningElement, track, api } from 'lwc';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class EDF53_EngagementListInstructions extends LightningElement {

    @track showTips = false;
    instructionsImageURL = BOOTSTRAPData + '/assets/img/instructions-icon.svg';
    infoImageURL = BOOTSTRAPData + '/assets/img/info-icon.svg';
    @api headingEngagementPage;


    openTipsModel() {
        this.showTips = true;
    }

    closeModalAction() {
        this.showTips = false;
    }

    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData + '/assets/js/bootstrap-4.0.0.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),

            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/registration-application.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/contact-information.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/post-registration-form.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/registration-application.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/community-override.css')

        ]).then(() => {
            console.log("All scripts and CSS are loaded.");
        })
        .catch(error => {
            console.log("Error page")
        });
    }
}