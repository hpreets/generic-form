import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';       
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getContact from "@salesforce/apex/EdfContactController.getContact";
import isShortCutsTilesExist from "@salesforce/apex/DashboardController.isShortCutsTilesExist";
import isNextStepsTilesExist from "@salesforce/apex/DashboardController.isNextStepsTilesExist";
import hello from '@salesforce/label/c.EDF_Hello';

export default class CcFellowDashboard extends NavigationMixin(LightningElement) {
    isPostReg = true;
    contact;
    @track ShortCuts = false;
    @track NextSteps = false;
    @track error;

    label = {
        hello
    };

    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData +'/assets/js/bootstrap.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/header.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/dashboard.css')
        ]).then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log("Error page")
            });
    }

    navigateToFellowDetails() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'fellowdetails'
            }
        });
    }
    connectedCallback() {
        getContact()
        .then((response) => {
        this.contact = response;
        })
        .catch((error) => {
        this.dispatchEvent(
            new ShowToastEvent({
            title: "ERROR In Contact",
            message: error.message,
            variant: "error"
            })
        );
        });

        isNextStepsTilesExist()
        .then(result => {
            this.NextSteps = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.NextSteps = undefined;
        });

        isShortCutsTilesExist()
        .then(result => {
            this.ShortCuts = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.ShortCuts = undefined;
        });
        // isNextStepsTilesExist()
        // .then(response => {
        // alert('isNextStepsTilesExist:' +response);
        // this.NextSteps = response;           
        // }).error(error => {
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //         title: "ERROR In Next Steps",
        //         message: error.message,
        //         variant: "error"
        //         })
        //     );
        // });

        // isShortCutsTilesExist()
        // .then(response => {
        // alert('isShortCutsTilesExist:' +response);
        // this.ShortCuts = response;
        // }).error(error => {
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //         title: "ERROR In Short Cuts",
        //         message: error.message,
        //         variant: "error"
        //         })
        //     );
        // });
        
    }
    // isShortCutsTilesExists() {
    //     isShortCutsTilesExist()
    //     .then(response => {
    //     alert('User Name:' +response);
    //     this.ShortCuts = response;
    //     }).error(error => {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //             title: "ERROR In Short Cuts",
    //             message: error.message,
    //             variant: "error"
    //             })
    //         );
    //     });
    // }
    // isNextStepsTilesExists() {
    //     isNextStepsTilesExist()
    //     .then(response => {
    //     alert('User Name:' +response);
    //     this.NextSteps = response;           
    //     }).error(error => {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //             title: "ERROR In Next Steps",
    //             message: error.message,
    //             variant: "error"
    //             })
    //         );
    //     });
    // }
   

    // getUserInfo() {
    //     getUserDetails().then(response => {
    //         //alert('User Name:' +response.userName);
    //         this.userName = response.userName;
    //     }).error(error => {
    //         //alert('Error:' + error);
    //     });
    // }

    // connectedCallback() {
    //     //this.getUserInfo();
    //    // console.log('userName',userName);
    // }


    //Temp code 
    // connectedCallback() {
    //     const param = 'regtype';
    //     const paramValue = this.getUrlParamValue(window.location.href, param);
    //     console.log('regtype:', paramValue);
    //     if(paramValue === 'prereg'){
    //         isPostReg = false;
    //     }
    //     else if(paramValue === 'postreg'){
    //         isPostReg = true;
    //     }
    // }
    // getUrlParamValue(url, key) {
    //     return new URL(url).searchParams.get(key);
    // }
}