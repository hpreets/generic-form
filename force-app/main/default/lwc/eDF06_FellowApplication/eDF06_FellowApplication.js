import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import backgroundImage from '@salesforce/resourceUrl/registrationgbImage';
import SubmitApplicationMethod from '@salesforce/apex/FellowAppController.submitApplication';
import getApplicationStatus from '@salesforce/apex/FellowAppController.getApplicationStatus';
//Pani added the below lable for the FB-1243
import fellowApplicationPDF from '@salesforce/label/c.EDF_GenarateFellowApplicationPDF';
import checkDeadlinePassed from '@salesforce/apex/FellowAppController.isDeadlinePassed'; // Added by HSingh - FB-2039

export default class EDF06_FellowApplication extends NavigationMixin (LightningElement) {

    iconPDF = BOOTSTRAPData + '/assets/img/application-pdf-format.svg';

    @api textPageHeading;
    @api textGetYourAppPDFLine1;
    @api textGetYourAppPDFLine2;
    @api textThankYouForSubmitting;
    @api labelSubmitAppBtn;
    @api labelContactInformationSection;
    @api labelEducationInformationSection;
    @api labelBackgroundInformationSection;
    @api labelMatchPreferenceSection;
    @api labelCoverLetterResumeSection;

    //appPdfPageUrl = window.location.href.replace("/s/", "/FellowApplicationPDF");
    backgroundstyle = `background: url('${backgroundImage}');-webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover;`;
    blockRegister = false;
    readOnly = false;
    applicationStatus = '';
    @track navigateFromDashboard = true;

    _isDeadlinePassed = null; // FB-2039


    //Added by Kranti for FB-0065
    connectedCallback(){
        getApplicationStatus()
        .then(response => {
            console.log('Testing response:'+response);
            if(response!=null && response!='Prospective Applicant'){
                this.readOnly = true;
                // this.blockRegister = true;
            }
            console.log('this.readOnly:'+this.readOnly);
        }).catch(error => {
                console.log('Error:', error);
        });

        // Added by HSingh - FB-2039
        if (this._isDeadlinePassed == null) {
            checkDeadlinePassed()
            .then(response => {
                this._isDeadlinePassed = response;
            })
            .catch(error => {
                this._isDeadlinePassed = true;
            });
        }
    }

    // Added by HSingh - FB-2039
    set isDeadlinePassed(value) {
          this._isDeadlinePassed = value;
    }
    get isDeadlinePassed() {
        return (this._isDeadlinePassed == null  ||  this._isDeadlinePassed == true) ? true : false;
    }


    renderedCallback() {
        Promise.all([

            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/bootstrap-4.0.0.min.js'),
            loadScript(this, BOOTSTRAPData +'/assets/js/custom.js'),

            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/registration-application.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/contact-information.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/post-registration-form.css')
        ]).then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log("Error page")
            });
    }

    applicationPDF() {
        window.open(fellowApplicationPDF)
    }
    submitApplication(){
        SubmitApplicationMethod().then(response => {
            this.applicationStatus = response;
            console.log('Records updated: ', response);
            const toastEvent = new ShowToastEvent({
                title:'Application Submitted',
                message:'Your Application Submitted successfully!',
                variant:'success'
            });
            this.dispatchEvent(toastEvent);
            this.blockRegister = true;
            this.readOnly = true;
        }).catch(error =>{
            console.log('Error:', error);
        });

    }
    navigateToDashboard(){
        // let urlstring = window.location.href;
        // let startUrl = urlstring.substring(0,urlstring.indexOf("/s/"));
        // console.log('startUrl:'+startUrl);
        // let registerUrl = startUrl+'/s'
        // console.log('registerUrl:'+registerUrl);
        // this[NavigationMixin.Navigate]({
        //     type: "standard__webPage",
        //     attributes: {
        //       url: registerUrl
        //     }
        //   });
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });

    }
}