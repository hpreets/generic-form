import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCoverLetter from '@salesforce/apex/FellowAppController.getCoverLetter';
import validateReviewSubmit from '@salesforce/apex/FellowAppController.validateReviewSubmit';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";

import FELLOW_APPLICATION_ID_FIELD from '@salesforce/schema/Fellow_Application__c.Id';
import COVER_LETTER from '@salesforce/schema/Fellow_Application__c.Cover_Letter__c';
import ADDITIONAL_INFORMATION from '@salesforce/schema/Fellow_Application__c.Additional_Information__c';
import RESUME_NAME from '@salesforce/schema/Fellow_Application__c.Resume_Name__c';
import REFERENCE_EMAIL_1 from '@salesforce/schema/Fellow_Application__c.Reference_Email_1__c';
import REFERENCE_EMAIL_2 from '@salesforce/schema/Fellow_Application__c.Reference_Email_2__c';
import REFERENCE_EMAIL_3 from '@salesforce/schema/Fellow_Application__c.Reference_Email_3__c';
import REFERENCE_NAME_1 from '@salesforce/schema/Fellow_Application__c.Reference_Name_1__c';
import REFERENCE_NAME_2 from '@salesforce/schema/Fellow_Application__c.Reference_Name_2__c';
import REFERENCE_NAME_3 from '@salesforce/schema/Fellow_Application__c.Reference_Name_3__c';
import REFERENCE_PHONE_1 from '@salesforce/schema/Fellow_Application__c.Reference_Phone_1__c';
import REFERENCE_PHONE_2 from '@salesforce/schema/Fellow_Application__c.Reference_Phone_2__c';
import REFERENCE_PHONE_3 from '@salesforce/schema/Fellow_Application__c.Reference_Phone_3__c';
import REFERENCE_TITLE_1 from '@salesforce/schema/Fellow_Application__c.Reference_Title_1__c';
import REFERENCE_TITLE_2 from '@salesforce/schema/Fellow_Application__c.Reference_Title_2__c';
import REFERENCE_TITLE_3 from '@salesforce/schema/Fellow_Application__c.Reference_Title_3__c';
import REFERENCE_SPECIAL_INSTRUCTIONS_1 from '@salesforce/schema/Fellow_Application__c.Reference_Special_Instructions_1__c';
import REFERENCE_SPECIAL_INSTRUCTIONS_2 from '@salesforce/schema/Fellow_Application__c.Reference_Special_Instructions_2__c';
import REFERENCE_SPECIAL_INSTRUCTIONS_3 from '@salesforce/schema/Fellow_Application__c.Reference_Special_Instructions_3__c';
import edfCoverLetter from '@salesforce/label/c.EDF_CoverLetter';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import checkDeadlinePassed from '@salesforce/apex/FellowAppController.isDeadlinePassed'; // Added by HSingh - FB-2039


export default class EDF18_CoverLetter extends NavigationMixin(LightningElement) {

    // variables
    fellowApplicationId = '';
    isChinaFellowShip = false;
    coverLetter = '';
    additionalInformation = '';
    resume = '';
    showUploaded = false;
    showWarning = false;
    referenceEmail1 = '';
    referenceEmail2 = '';
    referenceEmail3 = '';
    referenceName1 = '';
    referenceName2 = '';
    referenceName3 = '';
    referencePhone1 = '';
    referencePhone2 = '';
    referencePhone3 = '';
    referenceTitle1 = '';
    referenceTitle2 = '';
    referenceTitle3 = '';
    referenceSpecialInstructions1 = '';
    referenceSpecialInstructions2 = '';
    referenceSpecialInstructions3 = '';

    disableReviewSubmit = true;
    isPageLoad = false;
    isSaveSuccess = false;

    @api backgroundImageClass = 'body-bg-image-registration';

    @api isChild = false;
    @api readOnly = false;

    label = {
        edfCoverLetter
    };

    @track activeReferenceSections = ['AddReference1', 'AddReference2', 'AddReference3'];
    @track activeTutorSections = ['AddReference1'];

    _isDeadlinePassed = null; // FB-2039

    connectedCallback() {
        this.getcoverLetterDetails();
        this.isPageLoad = true;
        this.validateAllTabs();
        this.checkDeadline(); // FB-2039

    }

    getcoverLetterDetails() {
        getCoverLetter().then(response => {
            console.log('response:', response);

            this.fellowApplicationId = response.id;

            this.coverLetter = response.coverLetter ?? '';
            this.additionalInformation = response.additionalInformation ?? '';
            this.resume =  response.resumeName ?? '';
            this.showUploaded = response.resumeName ? true : false;
            this.referenceEmail1 = response.referenceEmail1 ?? '';
            this.referenceEmail2 = response.referenceEmail2 ?? '';
            this.referenceEmail3 = response.referenceEmail3 ?? '';
            this.referenceName1 = response.referenceName1 ?? '';
            this.referenceName2 = response.referenceName2 ?? '';
            this.referenceName3 = response.referenceName3 ?? '';
            this.referencePhone1 = response.referencePhone1 ?? '';
            this.referencePhone2 = response.referencePhone2 ?? '';
            this.referencePhone3 = response.referencePhone3 ?? '';
            this.referenceTitle1 = response.referenceTitle1 ?? '';
            this.referenceTitle2 = response.referenceTitle2 ?? '';
            this.referenceTitle3 = response.referenceTitle3 ?? '';
            this.referenceSpecialInstructions1 = response.referenceSpecialInstructions1 ?? '';
            this.referenceSpecialInstructions2 = response.referenceSpecialInstructions2 ?? '';
            this.referenceSpecialInstructions3 = response.referenceSpecialInstructions3 ?? '';
            this.fellowshipApplyingFor = response.fellowshipApplyingFor ?? '';
            if(this.fellowshipApplyingFor =='China Fellowship'){
                this.isChinaFellowShip = true;
            }else{
                this.isChinaFellowShip = false;
            }

        }).catch(error => {
            console.log('Error:', error);
        });
    }

    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadScript(this, BOOTSTRAPData +'/assets/js/bootstrap-4.0.0.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/custom.js'),

            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
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

    updateCoverLetter(){
        const fields = {};
        fields[FELLOW_APPLICATION_ID_FIELD.fieldApiName] = this.fellowApplicationId;
        fields[COVER_LETTER.fieldApiName] = this.coverLetter
        fields[ADDITIONAL_INFORMATION.fieldApiName] = this.additionalInformation
        fields[RESUME_NAME.fieldApiName] = this.resume
        fields[REFERENCE_EMAIL_1.fieldApiName] = this.referenceEmail1
        fields[REFERENCE_EMAIL_2.fieldApiName] = this.referenceEmail2
        fields[REFERENCE_EMAIL_3.fieldApiName] = this.referenceEmail3
        fields[REFERENCE_NAME_1.fieldApiName] = this.referenceName1
        fields[REFERENCE_NAME_2.fieldApiName] = this.referenceName2
        fields[REFERENCE_NAME_3.fieldApiName] = this.referenceName3
        fields[REFERENCE_PHONE_1.fieldApiName] = this.referencePhone1
        fields[REFERENCE_PHONE_2.fieldApiName] = this.referencePhone2
        fields[REFERENCE_PHONE_3.fieldApiName] = this.referencePhone3
        fields[REFERENCE_TITLE_1.fieldApiName] = this.referenceTitle1
        fields[REFERENCE_TITLE_2.fieldApiName] = this.referenceTitle2
        fields[REFERENCE_TITLE_3.fieldApiName] = this.referenceTitle3
        fields[REFERENCE_SPECIAL_INSTRUCTIONS_1.fieldApiName] = this.referenceSpecialInstructions1
        fields[REFERENCE_SPECIAL_INSTRUCTIONS_2.fieldApiName] = this.referenceSpecialInstructions2
        fields[REFERENCE_SPECIAL_INSTRUCTIONS_3.fieldApiName] = this.referenceSpecialInstructions3

        const recordInput = {
            fields: fields
        };

        if(this.isInputValid()){
            updateRecord(recordInput).then((record) => {
                console.log('updateCoverLetter', record);
                this.isSaveSuccess = true;
                // const toastEvent = new ShowToastEvent({
                //     title:'Updated',
                //     message:'Cover Letter & Resume Saved.',
                //     variant:'success'
                // });
                // this.dispatchEvent(toastEvent);
                this.getcoverLetterDetails();
                this.validateAllTabs();
                //this.isSaveSuccess = false;
            }).error(error => {

                console.log('Cover Letter Updated:Error:', error);
            });
        }

    }

    reviewSubmit() {
        // this.validReviewSubmit();
        // let isValidReviewSubmit = true;
        // let reviewSubmitValidationMessage = '';

        validateReviewSubmit().then(response => {
            console.log('validate review submit response:', response);
            if (response) {
                console.log('response true', response);
                const toastEvent = new ShowToastEvent({
                    title:'Mandatory Field data is missing in following tabs',
                    message: response,
                    variant:'error'
                });
                this.dispatchEvent(toastEvent);

            }
            else {
                if(!this.isChild) {
                    this.navigateToReviewFellowApplication();
                }
            }
        }).catch(error => {
            console.log('Error:', error);
        });

    }

    validateAllTabs() {

        validateReviewSubmit().then(response => {
            console.log('validate review submit response:', response);
            if (response) {
				this.disableReviewSubmit = true;
                console.log('response true', response);
                console.log('Is Page Load:', this.isPageLoad);
                if(!this.isPageLoad){
                    const toastEvent = new ShowToastEvent({
                        title:'Mandatory Field data is missing in following tabs, please fill the data before submit',
                        message: response,
                        variant:'error'
                    });
                    this.dispatchEvent(toastEvent);
                }
                this.isPageLoad = false;
            }
            else {
                if(!this.isChild) {
                    this.disableReviewSubmit = false;
                    console.log('Is Save Success:', this.isSaveSuccess);
                    if(this.isSaveSuccess){
                        const toastEvent = new ShowToastEvent({
                            title:'Updated',
                            message:'Cover Letter & Resume Saved. Please proceed for Review & Submit',
                            variant:'success'
                        });
                        this.dispatchEvent(toastEvent);
                    }
                }
            }
        }).catch(error => {
            console.log('Error:', error);
        });

    }

    navigateToReviewFellowApplication() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'reviewfellowapplication'
            }
        });
    }

    coverLetterChangeHandler(event){
        this.coverLetter = event.target.value;
    }

    additinalInforationChangeHandler(event){
        this.additionalInformation = event.target.value;
    }

    get acceptedFormats() {
        return ['.pdf'];
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.showUploaded = true;
        this.showWarning = false;
        for(let i = 0; i < uploadedFiles.length; i++) {
            this.resume = uploadedFiles[0].name;
            console.log('this.resume:',this.resume);
        }

    }

    referenceEmail1ChangeHandler(event){
        this.referenceEmail1 = event.target.value;
    }
    referenceEmail2ChangeHandler(event){
        this.referenceEmail2 = event.target.value;
    }
    referenceEmail3ChangeHandler(event){
        this.referenceEmail3 = event.target.value;
    }

    referenceName1ChangeHandler(event){
        this.referenceName1 = event.target.value;
    }
    referenceName2ChangeHandler(event){
        this.referenceName2 = event.target.value;
    }
    referenceName3ChangeHandler(event){
        this.referenceName3 = event.target.value;
    }

    referencePhone1ChangeHandler(event){
        this.referencePhone1 = event.target.value;
    }
    referencePhone2ChangeHandler(event){
        this.referencePhone2 = event.target.value;
    }
    referencePhone3ChangeHandler(event){
        this.referencePhone3 = event.target.value;
    }

    referenceTitle1ChangeHandler(event){
        this.referenceTitle1 = event.target.value;
    }
    referenceTitle2ChangeHandler(event){
        this.referenceTitle2 = event.target.value;
    }
    referenceTitle3ChangeHandler(event){
        this.referenceTitle3 = event.target.value;
    }

    referenceSpecialInstructions1ChangeHandler(event){
        this.referenceSpecialInstructions1 = event.target.value;
    }
    referenceSpecialInstructions2ChangeHandler(event){
        this.referenceSpecialInstructions2 = event.target.value;
    }
    referenceSpecialInstructions3ChangeHandler(event){
        this.referenceSpecialInstructions3 = event.target.value;
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input');

        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                inputField.focus();
                isValid = false;
            }
        });
        let textarea = this.template.querySelectorAll('lightning-textarea');
        textarea.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                inputField.focus();
                isValid = false;
            }
        });
        console.log('this.showUploaded: in validation'+this.showUploaded);
        if(!this.showUploaded){
            this.showWarning = true;
            isValid = false;
        }
        return isValid;
    }

    backToPreviousTab(){
        if (!this.isChild) {
            this.navigateToMatchPreference();
        }
    }
    navigateToMatchPreference() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'preferences'
            }
        });
    }

    // Added by HSingh - FB-2039
    checkDeadline() {
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

    navigateToDashboard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
}