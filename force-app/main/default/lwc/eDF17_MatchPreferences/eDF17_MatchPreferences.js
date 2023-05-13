import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import getMatchPreferences from '@salesforce/apex/FellowAppController.getMatchPreferences';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";

// Import reference to the object and the fields
import FELLOW_APPLICATION_OBJECT from '@salesforce/schema/Fellow_Application__c';
import FELLOW_APPLICATION_ID_FIELD from '@salesforce/schema/Fellow_Application__c.Id';
import APPLY_INDIA_FIELD from '@salesforce/schema/Fellow_Application__c.Apply_India_as_well__c';
import APPLY_CHINA_FIELD from '@salesforce/schema/Fellow_Application__c.Apply_for_China_Fellowship_as_well__c';
import REGIONS_IN_INDIA_FIELD from '@salesforce/schema/Fellow_Application__c.Regions_in_India__c';
import REGIONS_IN_CHINA_FIELD from '@salesforce/schema/Fellow_Application__c.Regions_in_China__c';
import REGIONS_IN_US_FIELD from '@salesforce/schema/Fellow_Application__c.Geographic_Yes_Region__c';
import US_REGIONAL_PREFERENCES_FIELD from '@salesforce/schema/Fellow_Application__c.US_regional_preferences__c';
import VALID_US_DRIVERS_LICENSE_FIELD from '@salesforce/schema/Fellow_Application__c.ValidUSDriversLicense__c';
import ACCESS_TO_VEHICLE_FIELD from '@salesforce/schema/Fellow_Application__c.AccessToAVehicleThisSummer__c';
import SECTOR_FIRST_CHOICE_FIELD from '@salesforce/schema/Fellow_Application__c.Sector_first_choice__c';
import SECTOR_SECOND_CHOICE_FIELD from '@salesforce/schema/Fellow_Application__c.Sector_second_choice__c';
import SECTOR_THIRD_CHOICE_FIELD from '@salesforce/schema/Fellow_Application__c.Sector_third_choice__c';
import PROJECT_TYPE_PREFERENCE_ONE from '@salesforce/schema/Fellow_Application__c.Project_Type_Preference_One__c';
import PROJECT_TYPE_PREFERENCE_TWO from '@salesforce/schema/Fellow_Application__c.Project_Type_Preference_Two__c';
import PROJECT_TYPE_PREFERENCE_THREE from '@salesforce/schema/Fellow_Application__c.Project_Type_Preference_Three__c';

// Labels added by Harpreet on 04-Jan-2022
import Page_Heading from '@salesforce/label/c.FellowApp_MatchPref_Page_Heading';
import USRegionPref_HelpText from '@salesforce/label/c.FellowApp_MatchPref_USRegionPref_HelpText';
import IndiaRegionPref_HelpText from '@salesforce/label/c.FellowApp_MatchPref_IndiaRegionPref_HelpText';
import ChinaRegionPref_HelpText from '@salesforce/label/c.FellowApp_MatchPref_ChinaRegionPref_HelpText';
import USRegionPref_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_USRegionPref_FieldLabel';
import IndiaRegionPref_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_IndiaRegionPref_FieldLabel';
import ChinaRegionPref_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_ChinaRegionPref_FieldLabel';
import InterestForIndiaChina_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_InterestForIndiaChina_FieldLabel';
import InterestForIndiaChina_HelpText from '@salesforce/label/c.FellowApp_MatchPref_InterestForIndiaChina_HelpText';
import USRegionPrefText_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_USRegionPrefText_FieldLabel';
import USRegionPrefText_CharacterLimit from '@salesforce/label/c.FellowApp_MatchPref_USRegionPrefText_CharacterLimit';
import USDriverLicense_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_USDriverLicense_FieldLabel';
import AccessToVehicle_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_AccessToVehicle_FieldLabel';
import SectorPreference_Heading from '@salesforce/label/c.FellowApp_MatchPref_SectorPreference_Heading';
import SectorPreference3Choices_Heading from '@salesforce/label/c.FellowApp_MatchPref_SectorPreference3Choices_Heading';
import SectorFirstChoice_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_SectorFirstChoice_FieldLabel';
import SectorSecondChoice_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_SectorSecondChoice_FieldLabel';
import SectorThirdChoice_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_SectorThirdChoice_FieldLabel';
import ProjectTypePreference_Heading from '@salesforce/label/c.FellowApp_MatchPref_ProjectTypePreference_Heading';
import ProjectTypePreference3Choices_Heading from '@salesforce/label/c.FellowApp_MatchPref_ProjectTypePreference3Choices_Heading';
import ProjectTypeFirstChoice_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_ProjectTypeFirstChoice_FieldLabel';
import ProjectTypeSecondChoice_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_ProjectTypeSecondChoice_FieldLabel';
import ProjectTypeThirdChoice_FieldLabel from '@salesforce/label/c.FellowApp_MatchPref_ProjectTypeThirdChoice_FieldLabel';
import Back_ButtonLabel from '@salesforce/label/c.FellowApp_Back_ButtonLabel';
import SaveNext_ButtonLabel from '@salesforce/label/c.FellowApp_SaveNext_ButtonLabel';
import Cancel_ButtonLabel from '@salesforce/label/c.FellowApp_Cancel_ButtonLabel';
import Save_ButtonLabel from '@salesforce/label/c.FellowApp_Save_ButtonLabel';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import registrationgbImage from '@salesforce/resourceUrl/registrationgbImage';
import checkDeadlinePassed from '@salesforce/apex/FellowAppController.isDeadlinePassed'; // Added by HSingh - FB-2039


export default class EDF17_MatchPreferences extends NavigationMixin(LightningElement) {

    // Labels added by Harpreet on 04-Jan-2022
    label = {
        Page_Heading: this.getCustomLabel(Page_Heading),
        USRegionPref_HelpText: this.getCustomLabel(USRegionPref_HelpText),
        IndiaRegionPref_HelpText: this.getCustomLabel(IndiaRegionPref_HelpText),
        ChinaRegionPref_HelpText: this.getCustomLabel(ChinaRegionPref_HelpText),
        USRegionPref_FieldLabel: this.getCustomLabel(USRegionPref_FieldLabel),
        IndiaRegionPref_FieldLabel: this.getCustomLabel(IndiaRegionPref_FieldLabel),
        ChinaRegionPref_FieldLabel: this.getCustomLabel(ChinaRegionPref_FieldLabel),

        InterestForIndiaChina_FieldLabel: this.getCustomLabel(InterestForIndiaChina_FieldLabel),
        InterestForIndiaChina_HelpText: this.getCustomLabel(InterestForIndiaChina_HelpText),
        USRegionPrefText_FieldLabel: this.getCustomLabel(USRegionPrefText_FieldLabel),
        USRegionPrefText_CharacterLimit: this.getCustomLabel(USRegionPrefText_CharacterLimit),
        USDriverLicense_FieldLabel: this.getCustomLabel(USDriverLicense_FieldLabel),
        AccessToVehicle_FieldLabel: this.getCustomLabel(AccessToVehicle_FieldLabel),
        SectorPreference_Heading: this.getCustomLabel(SectorPreference_Heading),
        SectorPreference3Choices_Heading: this.getCustomLabel(SectorPreference3Choices_Heading),
        SectorFirstChoice_FieldLabel: this.getCustomLabel(SectorFirstChoice_FieldLabel),
        SectorSecondChoice_FieldLabel: this.getCustomLabel(SectorSecondChoice_FieldLabel),
        SectorThirdChoice_FieldLabel: this.getCustomLabel(SectorThirdChoice_FieldLabel),
        ProjectTypePreference_Heading: this.getCustomLabel(ProjectTypePreference_Heading),
        ProjectTypePreference3Choices_Heading: this.getCustomLabel(ProjectTypePreference3Choices_Heading),
        ProjectTypeFirstChoice_FieldLabel: this.getCustomLabel(ProjectTypeFirstChoice_FieldLabel),
        ProjectTypeSecondChoice_FieldLabel: this.getCustomLabel(ProjectTypeSecondChoice_FieldLabel),
        ProjectTypeThirdChoice_FieldLabel: this.getCustomLabel(ProjectTypeThirdChoice_FieldLabel),
        Back_ButtonLabel: this.getCustomLabel(Back_ButtonLabel),
        SaveNext_ButtonLabel: this.getCustomLabel(SaveNext_ButtonLabel),
        Cancel_ButtonLabel: this.getCustomLabel(Cancel_ButtonLabel),
        Save_ButtonLabel: this.getCustomLabel(Save_ButtonLabel),
    }
     // variables
    fellowApplicationId = '';
    fellowshipApplyingFor = '';
    applyIndia = false;
    applyChina = false;
    regionsInIndia = '';
    regionsInChina = '';
    regionsInUS = '';
    usRegionalPreferences = '';
    validUSDriversLicense = '';
    accessToVehicle = '';
    sectorFirstChoice = '';
    sectorSecondChoice = '';
    sectorThirdChoice = '';
    projectTypePreferenceOne = '';
    projectTypePreferenceTwo = '';
    projectTypePreferenceThree = '';
    isUSFellowShip = false;
    isChinaFellowship = false;
    isIndiaFellowShip = false;
    isUsRelocation = false;
    isFirstChoice = false;
    isSecondChoice = false;
    isThirdChoice = false;
    isChinaRelocation = false;
    isIndiaRelocation = false;

    @track regionsInIndiaSelected = [];
    @track regionsInIndiaOptions = [];

    @track regionsInChinaSelected = [];
    @track regionsInChinaOptions = [];

    @track regionsInUSSelected = [];
    @track regionsInUSOptions = [];

    @api backgroundImageClass = 'body-bg-image-application';

    @api isChild = false;
    @api readOnly = false;

    _isDeadlinePassed = null; // FB-2039

    connectedCallback() {
        this.getMatchPref();
        this.checkDeadline(); // FB-2039
    }

    getMatchPref() {
        getMatchPreferences().then(response => {
            console.log('response:', response);

            this.fellowApplicationId = response.id;
            this.fellowshipApplyingFor = response.fellowshipApplyingFor ?? '';
            if(this.fellowshipApplyingFor =='India Fellowship'){
                this.isIndiaFellowShip = true;
                this.isChinaFellowship = false;
                this.isUSFellowShip = false;
            }
            if(this.fellowshipApplyingFor =='China Fellowship'){
                this.isChinaFellowship = true;
                this.isIndiaFellowShip = false;
                this.isUSFellowShip = false;
            }
            if(this.fellowshipApplyingFor =='U.S. Fellowship'){
                this.isUSFellowShip = true;
                this.isIndiaFellowShip = false;
                this.isChinaFellowship = false;
            }
            this.applyIndia = response.applyIndia ?? '';
            this.applyChina = response.applyChina ?? '';
            this.regionsInIndia = response.regionsInIndia ?? '';
            if (response.regionsInIndia) {
                this.regionsInIndiaSelected = response.regionsInIndia.split(';');
            }
            this.regionsInChina = response.regionsInChina;
            if (response.regionsInChina) {
                this.regionsInChinaSelected = response.regionsInChina.split(';');
            }
            this.regionsInUS = response.regionsInUS;
            if (response.regionsInUS) {
                this.regionsInUSSelected = response.regionsInUS.split(';');
            }
            this.usRegionalPreferences = response.usRegionalPreferences ?? '';
            this.validUSDriversLicense = response.validUSDriversLicense ?? '';
            this.accessToVehicle = response.accessToVehicle ?? '';
            this.sectorFirstChoice = response.sectorFirstChoice ?? '';
            this.sectorSecondChoice = response.sectorSecondChoice ?? '';
            this.sectorThirdChoice = response.sectorThirdChoice ?? '';
            this.projectTypePreferenceOne = response.projectTypePreferenceOne ?? '';
            this.projectTypePreferenceTwo = response.projectTypePreferenceTwo ?? '';
            this.projectTypePreferenceThree = response.projectTypePreferenceThree ?? '';

            this.handleFieldsValidity();

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

         //this.setDefaultValues();

    }

    // Get Object Info.
    @wire (getObjectInfo, {objectApiName: FELLOW_APPLICATION_OBJECT})
    fellowAppObjectInfo;

    setDefaultValues(){

        this.template.querySelector('.apply-india').checked = this.applyIndia;
        this.template.querySelector('.apply-china').checked = this.applyChina;
        //this.template.querySelector('.regions-in-india').value = this.regionsInIndiaSelected;
        //this.template.querySelector('.regions-in-china').value = this.regionsInChinaSelected;
        //this.template.querySelector('.us-regional-preferences').value = this.usRegionalPreferences;
        this.template.querySelector('.valid-us-drivers-license').value = this.validUSDriversLicense;
        this.template.querySelector('.access-to-vehicle').value = this.accessToVehicle;
        this.template.querySelector('.sector-first-choice').value = this.sectorFirstChoice;
        this.template.querySelector('.sector-second-choice').value = this.sectorSecondChoice;
        this.template.querySelector('.sector-third-choice').value = this.sectorThirdChoice;
    }

    // Get "Regions in India" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: REGIONS_IN_INDIA_FIELD })
    regionsInIndiaPickListValues(data, error){
        if(data && data.data && data.data.values){
            data.data.values.forEach( objPicklist => {
                this.regionsInIndiaOptions.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
            });
        } else if(error){
            console.log(error);
        }
    };

    // Get "Regions in China" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: REGIONS_IN_CHINA_FIELD })
    regionsInChinaPickListValues(data, error){
        if(data && data.data && data.data.values){
            data.data.values.forEach( objPicklist => {
                this.regionsInChinaOptions.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
            });
        } else if(error){
            console.log(error);
        }
    };

    // Get "Regions in US" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: REGIONS_IN_US_FIELD })
    regionsInUSPickListValues(data, error){
        if(data && data.data && data.data.values){
            data.data.values.forEach( objPicklist => {
                this.regionsInUSOptions.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
            });
        } else if(error){
            console.log(error);
        }
    };



    // Get "Do you have a valid US Driver's License" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: VALID_US_DRIVERS_LICENSE_FIELD })
    validUSDriversLicensePickList;

    // Get "Access to a vehicle" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: ACCESS_TO_VEHICLE_FIELD })
    accessToVehiclePickList;

    // Get "Sector First Choice" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: SECTOR_FIRST_CHOICE_FIELD })
    sectorFirstChoicePickList;

    // Get "Sector Second Choice" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: SECTOR_SECOND_CHOICE_FIELD })
    sectorSecondChoicePickList;

    // Get "Sector Third Choice" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: SECTOR_THIRD_CHOICE_FIELD })
    sectorThirdChoicePickList;

     // Get "Project Type Preference One" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: PROJECT_TYPE_PREFERENCE_ONE })
    projectTypePreferenceOnePickList;

    // Get "Project Type Preference Two" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: PROJECT_TYPE_PREFERENCE_TWO })
    projectTypePreferenceTwoPickList;

    // Get "Project Type Preference Three" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: PROJECT_TYPE_PREFERENCE_THREE })
    projectTypePreferenceThreePickList;

    //Change Handlers
    applyIndiaChangeHandler(event){
        this.applyIndia = event.target.checked;
    }

    applyChinaChangeHandler(event){
        this.applyChina = event.target.checked;
    }

    regionsInIndiaChangeHandler(event) {
        this.regionsInIndiaSelected = event.detail.value;
    }

    regionsInChinaChangeHandler(event) {
        this.regionsInChinaSelected = event.detail.value;
    }
    regionsInUSChangeHandler(event) {
        this.regionsInUSSelected = event.detail.value;
    }

    usRegionalPreferencesChangeHandler(event){
        this.usRegionalPreferences = event.target.value;
    }

    validUSDriversLicenseChangeHandler(event){
        this.validUSDriversLicense = event.target.value;
    }

    accessToVehicleChangeHandler(event){
        this.accessToVehicle = event.target.value;
    }

    sectorFirstChoiceChangeHandler(event){
        this.sectorFirstChoice = event.target.value;
    }

    sectorSecondChoiceChangeHandler(event){
        this.sectorSecondChoice = event.target.value;
    }

    sectorThirdChoiceChangeHandler(event){
        this.sectorThirdChoice = event.target.value;
    }

    projectTypePreferenceOneChangeHandler(event) {
        this.projectTypePreferenceOne = event.target.value;
    }

    projectTypePreferenceTwoChangeHandler(event) {
        this.projectTypePreferenceTwo = event.target.value;
    }

    projectTypePreferenceThreeChangeHandler(event) {
        this.projectTypePreferenceThree = event.target.value;
    }


    //update details
    updateMatchPreferences(){

        const fields = {};
        fields[FELLOW_APPLICATION_ID_FIELD.fieldApiName] = this.fellowApplicationId;
        fields[APPLY_INDIA_FIELD.fieldApiName] = this.applyIndia;
        fields[APPLY_CHINA_FIELD.fieldApiName] = this.applyChina;
        fields[REGIONS_IN_INDIA_FIELD.fieldApiName] = this.regionsInIndiaSelected.join(';');
        fields[REGIONS_IN_CHINA_FIELD.fieldApiName] = this.regionsInChinaSelected.join(';');
        fields[REGIONS_IN_US_FIELD.fieldApiName] = this.regionsInUSSelected.join(';');
        fields[US_REGIONAL_PREFERENCES_FIELD.fieldApiName] = this.usRegionalPreferences;
        fields[VALID_US_DRIVERS_LICENSE_FIELD.fieldApiName] = this.validUSDriversLicense;
        fields[ACCESS_TO_VEHICLE_FIELD.fieldApiName] = this.accessToVehicle;
        fields[SECTOR_FIRST_CHOICE_FIELD.fieldApiName] = this.sectorFirstChoice;
        fields[SECTOR_SECOND_CHOICE_FIELD.fieldApiName] = this.sectorSecondChoice;
        fields[SECTOR_THIRD_CHOICE_FIELD.fieldApiName] = this.sectorThirdChoice;
        fields[PROJECT_TYPE_PREFERENCE_ONE.fieldApiName] = this.projectTypePreferenceOne;
        fields[PROJECT_TYPE_PREFERENCE_TWO.fieldApiName] = this.projectTypePreferenceTwo;
        fields[PROJECT_TYPE_PREFERENCE_THREE.fieldApiName] = this.projectTypePreferenceThree;

        const recordInput = {
            fields: fields
        };

        if(this.isInputValid()){
            updateRecord(recordInput).then((record) => {
                console.log('updateMatchPreferences', record);
                const toastEvent = new ShowToastEvent({
                    title:'Updated',
                    message:'Match Preferences Updated',
                    variant:'success'
                });
                this.dispatchEvent(toastEvent);

                this.getMatchPref();
                //this.setDefaultValues();
                this.saveNext();
            }).error(error => {

                console.log('Match Preferences Updated:Error:', error);
            });
        }

    }

    saveNext() {
        if (!this.isChild) {
            this.navigateToCoverLetter();
        }
    }
    navigateToCoverLetter() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'coverletter'
            }
        });
    }
    backToPreviousTab(){
        if (!this.isChild) {
            this.navigateToBackgroundInformation();
        }
    }
    navigateToBackgroundInformation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'backgroundinformation'
            }
        });
    }
    handleFieldsValidity(){
        if(this.fellowshipApplyingFor == 'U.S. Fellowship' ){
            this.isUsRelocation = true;
            this.isFirstChoice = true;
            this.isSecondChoice = true;
            this.isThirdChoice = true;
        }
        if(this.fellowshipApplyingFor == 'China Fellowship'){
            this.isChinaRelocation = true;
        }
        if(this.fellowshipApplyingFor == 'India Fellowship'){
            this.isIndiaRelocation = true;
        }
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-combobox');
        let multiSelect = this.template.querySelectorAll('lightning-dual-listbox');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                inputField.focus();
                isValid = false;
            }
        });
        multiSelect.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                inputField.focus();
                isValid = false;
            }
        });
        return isValid;


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

    getCustomLabel(labelText) {
        return (labelText == '___HIDE___') ? null : labelText;
    }
}