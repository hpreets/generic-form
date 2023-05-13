import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

import CONTACT_OBJECT from "@salesforce/schema/Contact";
import CONTACT_ID_FIELD from "@salesforce/schema/Contact.Id";
import CONTACT_FIRSTNAME_FIELD from "@salesforce/schema/Contact.FirstName";
import CONTACT_LASTNAME_FIELD from "@salesforce/schema/Contact.LastName";
import CONTACT_EMAIL_FIELD from "@salesforce/schema/Contact.Email";
import CONTACT_PHONE_FIELD from "@salesforce/schema/Contact.Phone";

import FELLOW_APPLICATION_OBJECT from '@salesforce/schema/Fellow_Application__c';
import FELLOW_APPLICATION_ID_FIELD from '@salesforce/schema/Fellow_Application__c.Id';
import APPLICANT_FIELD from '@salesforce/schema/Fellow_Application__c.Applicant__c';
import PRONOUNS_FIELD from '@salesforce/schema/Fellow_Application__c.Pronouns__c';
import PRONOUNS_SELF_DESCRIBE_FIELD from '@salesforce/schema/Fellow_Application__c.Pronouns_Self_Describe__c';
import RACE_FIELD from '@salesforce/schema/Fellow_Application__c.Race__c';
import FELLOWSHIP_APPLYING_FOR_FIELD from '@salesforce/schema/Fellow_Application__c.Fellowship_Applying_for__c';
import HOW_DID_YOU_FIND_US_FIELD from '@salesforce/schema/Fellow_Application__c.How_Did_You_Find_Us__c';
import HOW_DID_YOU_FIND_US_IF_OTHER_FIELD from '@salesforce/schema/Fellow_Application__c.How_did_find_out_about_EDF_Other__c';
import RETURNER_FELLOW_FIELD from '@salesforce/schema/Fellow_Application__c.Returner_Fellow__c';
import GENDER_FIELD from '@salesforce/schema/Fellow_Application__c.Sex__c';
import GENDER_SELF_DESCRIBE_FIELD from '@salesforce/schema/Fellow_Application__c.Sex_Self_Describe__c';
import DO_YOU_IDENTIFY_AS_LATINX_OR_HISPANIC_FIELD from '@salesforce/schema/Fellow_Application__c.Do_you_identify_as_Latinx_or_Hispanic__c';
import VETERAN_STATUS_FIELD from '@salesforce/schema/Fellow_Application__c.Veteran_Status__c';
import SKYPE_FIELD from '@salesforce/schema/Fellow_Application__c.Skype__c';

import { updateRecord } from "lightning/uiRecordApi";
import getContactInfo from '@salesforce/apex/EdfContactController.getContactInfo';
import updateFellowApplication from '@salesforce/apex/EdfContactController.updateFellowApplication';
import getStatesByCountry from '@salesforce/apex/EDF28_RegisterController.getStatesByCountry';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import registrationgbImage from '@salesforce/resourceUrl/registrationgbImage';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import checkDeadlinePassed from '@salesforce/apex/FellowAppController.isDeadlinePassed'; // Added by HSingh - FB-2039

export default class EDF14_ContactInformation extends NavigationMixin(LightningElement) {

    @track contacts;
    @track contact = {};
    // @track contactId = '0031D00000gDWUnQAO';
    contactId = '';
    // @track fellowApplicationId = 'a141D000001NYhLQAW';
    fellowApplicationId = '';
    fellowshipApplyingFor = '';
    firstName = '';
    lastName = '';
    email = '';
    pronouns = '';
    pronounsSelfDescribe = 'Prefer to self-describe';
    phone = '';
    country = '';
    postalCode = '';
    state = '';
    city = '';
    permanentStreetAddressLine1 = '';
    permanentStreetAddressLine2 = '';
    skypeID = '';
    howDidYouFindUs = '';
    howDidYouFindUsIfOther = '';
    returnerFellow = '';
    gender = '';
    genderSelfDescribe = 'Prefer to self-describe';
    race = '';
    latinxOrHispanic = '';
    veteranStatus = '';
    isOtherHowDidYouFindUs = false;
    labelOtherHowDidYouFindUs = 'Other (please specify)';
    showRaceDefinitionModel = false;
    showVeteranStatusDefinitionModel = false;
    isIndiaFellowShip = false;
    isUSFellowShip = false;
    isChinaFellowShip = false;
    usorchinaFellowShip = false;
    usorindiaFellowShip = false;
    isGenderSelfDescribe = false;
    isPronounsSelfDescribe = false;
    firsNameRequired = true;
    lastNameRequired = false;
    emailRequired = false;
    pronounsRequired = false;
    fellowshipRequired = false;
    pronounSelfDescRequired = false;
    phoneRequired = false;
    countryRequired = false;
    address1Required = false;
    cityRequired = false;
    stateRequired = false;
    postalCodeRequired = false;
    whichFelloshipApplyingRequired = false;
    howDidYouFindCCRequired = false;
    haveYouParticipatedRequired = false;
	skypeIdRequired = false;
    isDropDownField =false;

    @api backgroundImageClass = 'body-bg-image-application';

    @api isChild = false;
    @api readOnly = false;

    statePickListValues = [];
    countryPickListValues = [];
    @track fellowshipApplyingForPickListValues = [];
    howDidYouFindUsPickListValues = [];

    @track lstRaceSelected = [];
    @track lstRaceOptions = [];

    _isDeadlinePassed = null; // FB-2039


    // Get Object Info.
    @wire (getObjectInfo, {objectApiName: FELLOW_APPLICATION_OBJECT})
    fellowApplicationObjectInfo;

    // Get Race Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: RACE_FIELD })
    racePickListValues(data, error){
        if(data && data.data && data.data.values){
            data.data.values.forEach( objPicklist => {
                this.lstRaceOptions.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
            });
        } else if(error){
            console.log(error);
        }
    };

    // Get "Fellowship Applying For" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: FELLOWSHIP_APPLYING_FOR_FIELD })
    fellowshipApplyingForPickList;

    // Get "How Did You Find Us" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: HOW_DID_YOU_FIND_US_FIELD })
    howDidYouFindUsPickList;

    // Get "Participated in the Climate Corps program in the past" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: RETURNER_FELLOW_FIELD })
    returnerFellowPickList;

    // Get "Gender" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: GENDER_FIELD })
    genderPickList;

    // Get "Do you identify as Latinx or Hispanic" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: DO_YOU_IDENTIFY_AS_LATINX_OR_HISPANIC_FIELD })
    latinxOrHispanicPickList;

    // Get "Veteran Status" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: VETERAN_STATUS_FIELD })
    veteranStatusPickList;

    // Get "Veteran Status" Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$fellowApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: PRONOUNS_FIELD })
    pronounsPickList;

    raceChangeHandler(event) {
        this.lstRaceSelected = event.detail.value;
    }

    connectedCallback(){
        this.getContactInformation();
        this.checkDeadline();
    }

    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadScript(this, BOOTSTRAPData +'/assets/js/bootstrap-4.0.0.min.js'),
            loadScript(this, BOOTSTRAPData +'/assets/js/custom.js'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/registration-application.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/contact-information.css'),
        ]).then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log("Error page")
            });

         /*this.setState();
         this.setCountry();
         this.setFellowshipApplyingFor();
         this.setPronouns();
         this.setHowDidYouFindUs();
         this.setReturnerFellow();
         this.setGender();
         this.setLatinxOrHispanic();
         this.setVeteranStatus();*/
         //this.setVilidation()

    }

    /*setVilidation(){
        let listEle = this.template.querySelectorAll('.form-control');
        listEle.forEach(item=>{
            if(item.target.name!='address2' && item.target.name!='skypeid' && item.target.name!='otherreason' && item.target.name!='gender' && item.target.name!='genderdescribe' && item.target.name!='latinx-or-hispanic' && item.target.name!='veteran-status'){
                item.target.required=true;
            }
        })
    }*/

    getContactInformation(){
        getContactInfo().then(response => {
            console.log('response:', response);
            this.fellowApplicationId = response.id;
            this.contactId = response.contactId;
            this.fellowshipApplyingFor = response.fellowshipApplyingFor ?? '';
            if(this.fellowshipApplyingFor =='U.S. Fellowship' || this.fellowshipApplyingFor =='China Fellowship'){
                this.usorchinaFellowShip = true;
            }
            if(this.fellowshipApplyingFor =='China Fellowship'){
                this.isChinaFellowShip = true;
            }
            this.firstName = response.firstName ?? '';
            this.lastName = response.lastName ?? '';
            this.email = response.email ?? '';
            this.pronouns = response.pronouns ?? '';
            if(this.pronouns == 'Prefer to self-describe'){
                this.isPronounsSelfDescribe = true;
            }else{
                this.isPronounsSelfDescribe = false;
                this.pronounsSelfDescribe = '';
            }
            this.pronounsSelfDescribe = response.pronounsSelfDescribe ?? '';
            this.phone = response.phone ?? '';
            this.country = response.mailingCountry ?? '';
            if(this.country=="United States"|| this.country=="India" || this.country=="China"){
               this.isDropDownField =true;
            }
            this.postalCode = response.mailingPostalCode ?? '';
            this.state = response.mailingState ?? '';
            this.city = response.mailingCity ?? '';
            this.permanentStreetAddressLine1 = response.permanentStreetAddressLine1 ?? '';
            this.permanentStreetAddressLine2 = response.permanentStreetAddressLine2 ?? '';
            this.howDidYouFindUs = response.howDidYouFindUs ?? '';
            if (this.howDidYouFindUs === this.labelOtherHowDidYouFindUs) {
                this.isOtherHowDidYouFindUs = true;
                this.howDidYouFindUsIfOther = '';
            }
            else {
                this.isOtherHowDidYouFindUs = false;
                this.howDidYouFindUsIfOther = '';
            }
            this.howDidYouFindUsIfOther = response.howDidYouFindUsIfOther ?? '';
            this.returnerFellow = response.returnerFellow ?? '';
            this.skypeID = response.skypeID ?? '';
            this.gender = response.gender ?? '';
            if(this.gender == 'Prefer to self-describe'){
                this.isGenderSelfDescribe = true;
            }else{
                this.isGenderSelfDescribe = false;
                this.genderSelfDescribe = '';
            }
            this.genderSelfDescribe = response.genderSelfDescribe ?? '';
            this.race = response.race ?? '';
            if (response.race) {
                console.log('response.race',response.race);
                this.lstRaceSelected = response.race.split(';');
                console.log('this.lstRaceSelected',this.lstRaceSelected);
            }
            this.latinxOrHispanic = response.latinxOrHispanic ?? '';
            this.veteranStatus = response.veteranStatus ?? '';

            for(const list of response.countryPickListValues){
                const option = {
                    label: list,
                    value: list
                };
                this.countryPickListValues = [ ...this.countryPickListValues, option ];

            }
            for(const list of response.statePickListValues){
                const option = {
                    label: list,
                    value: list
                };
                this.statePickListValues = [ ...this.statePickListValues, option ];

            }
            //this.countryPickListValues = response.countryPickListValues ?? [];
            //this.statePickListValues = response.statePickListValues ?? [];
            /*this.setState();
            this.setCountry();
            this.setFellowshipApplyingFor();
            this.setPronouns();
            this.setHowDidYouFindUs();
            this.setReturnerFellow();
            this.setGender();
            this.setLatinxOrHispanic();
            this.setVeteranStatus();*/
            this.handleFieldsValidity();

            // const toastEvent = new ShowToastEvent({
            //     title:'Contact Information',
            //     message:'Contact Information Received',
            //     variant:'success'
            // });
            // this.dispatchEvent(toastEvent);
        }).catch(error => {
            alert(error);
            console.log('Error:', error);
            const toastEvent = new ShowToastEvent({
                title:'ERROR',
                message:error.message,
                variant:'error'
            });
            this.dispatchEvent(toastEvent);
        });
    }

    updateContactInformation() {
        const fields = {};
        fields[CONTACT_ID_FIELD.fieldApiName] = this.contactId;
        fields[CONTACT_FIRSTNAME_FIELD.fieldApiName] = this.firstName;
        fields[CONTACT_LASTNAME_FIELD.fieldApiName] = this.lastName;
        fields[CONTACT_EMAIL_FIELD.fieldApiName] = this.email;
        fields[CONTACT_PHONE_FIELD.fieldApiName] = this.phone;

        const recordInput = {
            fields: fields
        }

        updateRecord(recordInput).then((record) => {
            console.log(record);

            // const toastEvent = new ShowToastEvent({
            //     title:'Contact Information',
            //     message:'Contact Information Saved',
            //     variant:'success'
            // });
            // this.dispatchEvent(toastEvent);

        }).error(error => {
            //console.log('updateContactInformation', error);
        });

        //this.updateFellowApp();

    }
    updateFellowApp() {


        const fields2 = {};

        fields2[FELLOW_APPLICATION_ID_FIELD.fieldApiName] = this.fellowApplicationId;
        fields2[FELLOWSHIP_APPLYING_FOR_FIELD.fieldApiName] = this.fellowshipApplyingFor;
        fields2[PRONOUNS_FIELD.fieldApiName] = this.pronouns;
        fields2[PRONOUNS_SELF_DESCRIBE_FIELD.fieldApiName] = this.pronounsSelfDescribe;
        fields2[SKYPE_FIELD.fieldApiName] = this.skypeID;
        fields2[HOW_DID_YOU_FIND_US_FIELD.fieldApiName] = this.howDidYouFindUs;
        fields2[HOW_DID_YOU_FIND_US_IF_OTHER_FIELD.fieldApiName] = this.howDidYouFindUsIfOther;
        fields2[RETURNER_FELLOW_FIELD.fieldApiName] = this.returnerFellow;
        fields2[GENDER_FIELD.fieldApiName] = this.gender;
        fields2[GENDER_SELF_DESCRIBE_FIELD.fieldApiName] = this.genderSelfDescribe;
        fields2[DO_YOU_IDENTIFY_AS_LATINX_OR_HISPANIC_FIELD.fieldApiName] = this.latinxOrHispanic;
        fields2[VETERAN_STATUS_FIELD.fieldApiName] = this.veteranStatus;

        const recordInput = {
            fields: fields2
        }

        updateRecord(recordInput).then((record) => {
            console.log('updateFellowApp', record);
            const toastEvent = new ShowToastEvent({
                title:'Contact Information',
                message:'Contact Information Saved',
                variant:'success'
            });
            this.dispatchEvent(toastEvent);

        }).error(error => {
            console.log('updateFellowApp:Error:', error);
            const toastEvent = new ShowToastEvent({
                title:'Contact Information',
                message:'Contact Information Error',
                variant:'error'
            });
            this.dispatchEvent(toastEvent);
        });


    }

    saveFellowApp() {



        const fellowAppDetails = {
            id: this.fellowApplicationId,
            contactId:this.contactId,
            fellowApplicationId: this.fellowApplicationId,
            fellowshipApplyingFor: this.fellowshipApplyingFor,
            firstName: this.firstName,
            lastName: this.lastName,
            email: this.email,
            pronouns: this.pronouns,
            pronounsSelfDescribe : this.pronounsSelfDescribe,
            phone: this.phone,
            mailingCountry:this.country,
            mailingPostalCode: this.postalCode,
            mailingState:this.state,
            mailingCity:this.city,
            permanentStreetAddressLine1: this.permanentStreetAddressLine1,
            permanentStreetAddressLine2: this.permanentStreetAddressLine2,
            howDidYouFindUs: this.howDidYouFindUs,
            howDidYouFindUsIfOther: this.howDidYouFindUsIfOther,
            skypeID:this.skypeID,
            returnerFellow: this.returnerFellow,
            gender: this.gender,
            genderSelfDescribe: this.genderSelfDescribe,
            race: this.lstRaceSelected.join(';'),
            latinxOrHispanic: this.latinxOrHispanic,
            veteranStatus: this.veteranStatus

        }

        console.log('fellowAppWrapper', fellowAppDetails);
        if(this.isInputValid()){
            updateFellowApplication({fellowAppWrapper:fellowAppDetails}).then(response => {
                console.log('Records updated: ', response);
                //alert('Records updated: ' + response);
                const toastEvent = new ShowToastEvent({
                    title:'Contact Information Saved',
                    message:'Contact Information saved successfully!',
                    variant:'success'
                });
                this.dispatchEvent(toastEvent);
                this.connectedCallback();

                this.saveNext();
            }).catch(error =>{
                //alert('Error:' + error.message);
                console.log('Error:', error);
            });
        }

    }

    saveNext() {
        if (!this.isChild) {
            this.navigateToEducationInformation();
        }
    }
    navigateToEducationInformation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'educationinformation'
            }
        });
    }

    showRaceDefinition(){
        this.showRaceDefinitionModel = true;
    }
    hideRaceDefinition(){
        this.showRaceDefinitionModel = false;
    }
    showVeteranStatusDefinition(){
        this.showVeteranStatusDefinitionModel = true;
    }
    hideVeteranStatusDefinition(){
        this.showVeteranStatusDefinitionModel = false;
    }

    fellowshipApplyChangeHandler(event){
        this.fellowshipApplyingFor = event.target.value;
        console.log('this.fellowshipApplyingFor'+this.fellowshipApplyingFor);
        if(this.fellowshipApplyingFor =='U.S. Fellowship' || this.fellowshipApplyingFor =='China Fellowship'){
            this.usorchinaFellowShip = true;
        }
        if(this.fellowshipApplyingFor =='China Fellowship'){
            this.isChinaFellowShip = true;
        }
        if(this.fellowshipApplyingFor =='India Fellowship'){
            this.isChinaFellowShip = false;
            this.usorchinaFellowShip = false;
        }
        if(this.fellowshipApplyingFor =='U.S. Fellowship'){
            this.isChinaFellowShip = false;
        }
        this.handleFieldsValidity();
    }
    firstNameChangeHandler(event){
        this.firstName = event.target.value;
    }
    lastNameChangeHandler(event){
        this.lastName = event.target.value;
    }
    emailChangeHandler(event){
        this.email = event.target.value;
    }
    phoneChangeHandler(event){
        this.phone = event.target.value;
    }
    permanentStreetAddressLine1ChangeHandler(event){
        this.permanentStreetAddressLine1 = event.target.value;
        //console.log('permanentStreetAddressLine1:', this.permanentStreetAddressLine1);
    }
    permanentStreetAddressLine2ChangeHandler(event){
        this.permanentStreetAddressLine2 = event.target.value;
        //console.log('permanentStreetAddressLine2:', this.permanentStreetAddressLine2);
    }
    skypeIDChangeHandler(event){
        this.skypeID = event.target.value;
    }
    stateChangeHandler(event){
        this.state = event.target.value;
    }
    cityChangeHandler(event){
        this.city = event.target.value;
        //alert(this.city);
    }
    countryChangeHandler(event){
        this.country = event.target.value;
        this.handleStates();
    }
    postalCodeChangeHandler(event){
        this.postalCode = event.target.value;
    }
    pronounsChangeHandler(event){
        this.pronouns = event.target.value;
        if(this.pronouns == 'Prefer to self-describe'){
            this.isPronounsSelfDescribe = true;
        }else{
            this.isPronounsSelfDescribe = false;
            this.pronounsSelfDescribe = '';
        }
    }
    pronounsSelfDescribeChangeHandler(event){
        this.pronounsSelfDescribe = event.target.value;
    }
    howDidYouFindUsChangeHandler(event){
        this.howDidYouFindUs = event.target.value;
        if (this.howDidYouFindUs === this.labelOtherHowDidYouFindUs) {
            this.isOtherHowDidYouFindUs = true;
            this.howDidYouFindUsIfOther = '';
        }
        else {
            this.isOtherHowDidYouFindUs = false;
            this.howDidYouFindUsIfOther = '';
        }
    }
    howDidYouFindUsIfOtherChangeHandler(event){
        this.howDidYouFindUsIfOther = event.target.value;
    }
    returnerFellowChangeHandler(event){
        this.returnerFellow = event.target.value;
    }
    genderChangeHandler(event){
        this.gender = event.target.value;
        if(this.gender == 'Prefer to self-describe'){
            this.isGenderSelfDescribe = true;
        }else{
            this.isGenderSelfDescribe = false;
            this.genderSelfDescribe = '';
        }
    }
    genderSelfDescribeChangeHandler(event){
        this.genderSelfDescribe = event.target.value;
    }
    latinxOrHispanicChangeHandler(event){
        this.latinxOrHispanic = event.target.value;
    }
    veteranStatusChangeHandler(event){
        this.veteranStatus = event.target.value;
    }


    setState(){
        this.template.querySelector('.state').value = this.state;
    }
    setCountry(){
        this.template.querySelector('.country').value = this.country;
    }

    setFellowshipApplyingFor(){
       //this.template.querySelector('.fellow-ship-apply-for').value = this.fellowshipApplyingFor;
    }

    setPronouns(){
        this.template.querySelector('.pronouns').value = this.pronouns;
    }

    setHowDidYouFindUs(){
        this.template.querySelector('.how-did-you-find-us').value = this.howDidYouFindUs;
    }

    setReturnerFellow(){
        this.template.querySelector('.returner-fellow').value = this.returnerFellow;
    }

    setGender(){
        this.template.querySelector('.gender').value = this.gender;
    }

    setLatinxOrHispanic(){
        console.log('this.latinxOrHispanic:',this.latinxOrHispanic);
        //this.template.querySelector('.latinx-or-hispanic').value = this.latinxOrHispanic;
    }

    setVeteranStatus(){
        if(this.template.querySelector('.veteran-status')){
            this.template.querySelector('.veteran-status').value = this.veteranStatus;
        }
    }

    handleStates() {
        console.log(this.country)
        if(this.country=="United States" || this.country=="India" || this.country=="China"){
                this.isDropDownField = true;
                console.log('this.country Selected::'+this.country)
                getStatesByCountry({countrySelected: this.country })
    .then((result) => {
        console.log('result::'+result)
     this.statePickListValues = []; //Empty list

    for(const list of result){
        console.log('Result as a list::'+list)
        const option = {
            label: list,
            value: list
        };
        // this.selectOptions.push(option);
        this.statePickListValues = [ ...this.statePickListValues, option ];

    }

        this.error = undefined;
    })
    .catch((error) => {
        this.error = error;

    });
        } else{
            this.isDropDownField = false;
            this.selectedState = '';
        }

}

    handleFieldsValidity(){
       //if(this.fellowshipApplyingFor == 'U.S. Fellowship' || this.fellowshipApplyingFor == 'China Fellowship' || this.fellowshipApplyingFor == 'India Fellowship'){
            this.firsNameRequired = true;
            this.lastNameRequired = true;
            this.emailRequired = true;
            this.fellowshipRequired = true;
            this.pronounsRequired = true;
            this.pronounSelfDescRequired = true;
            this.phoneRequired = true;
            this.countryRequired = true;
            this.address1Required = true;
            this.cityRequired = true;
            this.stateRequired = true;
            this.postalCodeRequired = true;
            this.whichFelloshipApplyingRequired = true;
            this.howDidYouFindCCRequired = true;
            this.haveYouParticipatedRequired = true;
        //}
        if(this.fellowshipApplyingFor == 'China Fellowship'){
            this.skypeIdRequired = true;
        }
    }

    isInputValid() {
        let isValid = true;
        let comboFields = this.template.querySelectorAll('lightning-combobox');
        let inputFields = this.template.querySelectorAll('lightning-input');
        comboFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                inputField.focus();
                isValid = false;
            }
        });
        inputFields.forEach(inputField => {
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
}