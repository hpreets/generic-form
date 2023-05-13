import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class EDF05_ItemsforEDF extends NavigationMixin(LightningElement) {
    dueDate = 'Due date';
    /*     renderedCallback() {
             Promise.all([
                 loadScript(this, BOOTSTRAPData + '/assets/js/bootstrap.min.js'),
                 loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
                 loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
                 loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
                 loadStyle(this, BOOTSTRAPData + '/assets/css/header.css'),
                 loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
                loadStyle(this, BOOTSTRAPData + '/assets/css/registration-application.css'),
               loadStyle(this, BOOTSTRAPData + '/assets/css/contact-information.css')
             ]).then(() => {
                 console.log("All scripts and CSS are loaded.")
             })
                 .catch(error => {
                     console.log("Error page")
                 });
         }
    */
    accordIcon = "utility:chevronright";
    clickedIcon = true;
    isSubmissionOpen = false;
    changeIcon(event) {
        this.clickedIcon = false;
        if (this.accordIcon == 'utility:chevronright') {
            this.accordIcon = "utility:chevrondown";
            this.isSubmissionOpen = true;
        } else {
            this.accordIcon = "utility:chevronright";
            this.isSubmissionOpen = false;
        }
        this.clickedIcon = true;
    }


    get options() {
        return [
            { label: 'Show All', value: 'all' },
            { label: 'Hide All', value: 'hide' },
        ];
    }

    handleToggleSection(event) {
        console.log(this.isDVisible);
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }
  /*
    onClickWatchOrientation(event) {
        console.log('clicked onClickWatchOrientation');
        this.navigateToPortalStartDate();
    }
    navigateToPortalStartDate(event) {
        event.preventDefault();
        let componentDef = {
            componentDef: "c:eDF09_portalDeliverbales",
            attributes: {
                label: 'Navigated From Another LWC Without Using Aura'
            }
        };
        // Encode the componentDefinition JS object to Base64 format to make it url addressable
        let encodedComponentDef = btoa(JSON.stringify(componentDef));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedComponentDef
            }
        });
    }


    onClickSignupKilWatt(event) {
        console.log('clicked SignupKilWatt');
    }

    onClickStudentPolicy(event) {
        console.log('clicked StudentPolicy');
    }


    onClickHRWebinar(event) {
        console.log('clicked HRWebinar');
    } */
    onClickSubmitDates(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'portaldeliverables'
            }
        });
        console.log('clicked onClickSubmitDates');
    }
    /*
    onClickSubmitWorkPlan(event) {
        console.log('clicked onClickSubmitWorkPlan');
    }
    onClickMediaProfile(event) {
        console.log('clicked onClickMediaProfile');
    }

    onClickTrainingInfoCheck(event) {
        console.log('clicked onClickTrainingInfoCheck');
    }

    handleFilterChange(event) {

    } */
}