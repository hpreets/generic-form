import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import getEducationInformation from '@salesforce/apex/FellowAppController.getEducationInformation';
/* import retrieveUniversityAccounts from '@salesforce/apex/FellowAppController.retrieveUniversityAccounts';
import retrieveUniversitySchoolAccounts from '@salesforce/apex/FellowAppController.retrieveUniversitySchoolAccounts';
import retrieveUniversitySchoolAccountsWithParents from '@salesforce/apex/FellowAppController.retrieveUniversitySchoolAccountsWithParents'; */
import retrieveUniversityAccounts from '@salesforce/apex/UniversityHelper.retrieveUniversityAccounts';
import retrieveUniversitySchoolAccounts from '@salesforce/apex/UniversityHelper.retrieveUniversitySchoolAccounts';
import retrieveUniversitySchoolAccountsWithParents from '@salesforce/apex/UniversityHelper.retrieveUniversitySchoolAccountsWithParents';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import updateEducationInformation from '@salesforce/apex/UniversityHelper.updateEducationInformation';

// Import reference to the object and the fields
import FELLOW_APPLICATION_OBJECT from '@salesforce/schema/Fellow_Application__c';
import FELLOW_APPLICATION_ID_FIELD from '@salesforce/schema/Fellow_Application__c.Id';
import GRADUATE_UNIVERSITY_FIELD from '@salesforce/schema/Fellow_Application__c.University_School_1__c';
import SCHOOL_WITHIN_UNIVERSITY_FIELD from '@salesforce/schema/Fellow_Application__c.GRAD_School_within_University__c';
import SCHOOL_UNIVERSITY_OTHER_FIELD from '@salesforce/schema/Fellow_Application__c.University_Other_1__c';
import GRADUATE_UNIVERSITY_DUAL_FIELD from '@salesforce/schema/Fellow_Application__c.GRAD_University_Dual_Degree__c';
import SCHOOL_WITHIN_DUAL_UNIVERSITY_FIELD from '@salesforce/schema/Fellow_Application__c.GRAD_Dual_Degree_School_in_University__c';
import SCHOOL_DUAL_UNIVERSITY_OTHER_FIELD from '@salesforce/schema/Fellow_Application__c.Dual_Degree_School_Name__c';
import GRADUATE_DEGREE_FIELD from '@salesforce/schema/Fellow_Application__c.GRAD_Degree_s_pursuing__c';
import GRADUATE_DEGREE_OTHER_FIELD from '@salesforce/schema/Fellow_Application__c.GRAD_Degree_s_if_not_listed__c';
import GRADUATE_DEGREE_CONCENTRATION_FIELD from '@salesforce/schema/Fellow_Application__c.GRAD_Degree_Concentration__c';
import GRADUATE_DEGREE_START_DATE_FIELD from '@salesforce/schema/Fellow_Application__c.Graduation_Start_Date__c';
import EXPECTED_GRADUATION_DATE_FIELD from '@salesforce/schema/Fellow_Application__c.Date_Expected_Graduated_1__c';
import UNDERGRADUATE_UNIVERSITY_FIELD from '@salesforce/schema/Fellow_Application__c.University_School_2__c';
import UNDERGRADUATE_UNIVERSITY_OTHER_FIELD from '@salesforce/schema/Fellow_Application__c.University_Other_2__c';
import UNDERGRADUATE_DEGREE_EARNED_FIELD from '@salesforce/schema/Fellow_Application__c.Degree_Earned_2__c';
import UNDERGRADUATE_DEGREE_EARNED_OTHER_FIELD from '@salesforce/schema/Fellow_Application__c.UG_Degree_s_if_not_listed__c';
import UNDERGRAD_MAJOR_FIELD from '@salesforce/schema/Fellow_Application__c.Undergrad_Major__c';
import OTHER_COURSES_CERTIFICATIONS_FIELD from '@salesforce/schema/Fellow_Application__c.Other_courses_certifications__c';

import Id from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import userIsActiveFld from '@salesforce/schema/User.IsActive';
import userAliasFld from '@salesforce/schema/User.Alias';
import USER_CONTACTID from '@salesforce/schema/User.ContactId';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import registrationgbImage from '@salesforce/resourceUrl/registrationgbImage';
import checkDeadlinePassed from '@salesforce/apex/FellowAppController.isDeadlinePassed'; // Added by HSingh - FB-2039

let i=0;
let j=0;
export default class EDF15_EducationInformation extends NavigationMixin(LightningElement) {

    userId = Id;
    currentUserName;
    currentUserEmailId;
    currentIsActive;
    currentUserAlias;
    contactId;

    // variables
    fellowApplicationId = '';
    fellowshipApplyingFor ='';
    graduateUniversity = '';
    schoolWithinUniversity = ''
    schoolUniversityOther = '';
    dualGraduateUniversity = '';
    schoolWithinDualUniversity = ''
    schoolDualUniversityOther = '';
    graduateDegree = '';
    graduateDegreeOther = '';
    graduateDegreeConcentration = '';
    graduateDegreeStartDate = '';
    expectedGraduationDate = '';
    undergraduateUniversity = '';
    undergraduateUniversityOther = '';
    undergraduateDegreeEarned = '';
    undergraduateDegreeEarnedOther = '';
    undergradMajor = '';
    otherCoursesCertifications = '';
    addDualDegree = this.dualGraduateUniversity ? true : false;;
    enableRequired = false;
    isError = false;

    @api backgroundImageClass = 'body-bg-image-application';

    @api isChild = false;
    @api readOnly = false;
    @track graduateDegreeSelected = [];
    @track graduateDegreeOptions = [];

    @track undergraduateDegreeEarnedSelected = [];
    @track undergraduateDegreeEarnedOptions = [];
    @track parentItems = [{value: 'null', label: '-- None --'}];
    @track childDefaultItems = [{value: 'null', label: '-- None --'}];
    @track childItems = [{value: 'null', label: '-- None --'}];
    @track childDualItems = [{value: 'null', label: '-- None --'}];
    parentOptions = '';
    childOptions = '';
    underGraduateOptions = '';
    parentDualOptions = '';
    childDualtOptions = '';
    @track parentId='';

    _isDeadlinePassed = null; // FB-2039

    connectedCallback() {
        this.getEducationInfo();
        this.checkDeadline(); // FB-2039
    }

    getEducationInfo() {
        getEducationInformation().then(response => {
            console.log('response:', response);

            this.fellowApplicationId = response.id;
            // this.contactId = response.contactId;
            this.fellowshipApplyingFor = response.fellowshipApplyingFor ?? '';
            this.graduateUniversity = response.graduateUniversity ?? '';
            this.parentId = this.graduateUniversity;
            console.log(' this.parentId:'+this.parentId);
            this.schoolWithinUniversity = response.schoolWithinUniversity ?? '';
            console.log('this.schoolWithinUniversity: in connected call back'+this.schoolWithinUniversity);
            this.schoolUniversityOther = response.schoolUniversityOther ?? '';
            this.dualGraduateUniversity = response.dualGraduateUniversity ?? '';
            this.addDualDegree = this.dualGraduateUniversity ? true : false;
            this.schoolWithinDualUniversity = response.schoolWithinDualUniversity ?? '';
            console.log('this.schoolWithinDualUniversity: in connected call back'+this.schoolWithinDualUniversity);
            this.schoolDualUniversityOther = response.schoolDualUniversityOther ?? '';
            this.graduateDegree = response.graduateDegree ?? '';
            if (response.graduateDegree) {
                this.graduateDegreeSelected = response.graduateDegree.split(';');
            }
            this.graduateDegreeOther = response.graduateDegreeOther ?? '';
            this.graduateDegreeConcentration = response.graduateDegreeConcentration ?? '';
            this.graduateDegreeStartDate = response.graduateDegreeStartDate ?? '';
            this.expectedGraduationDate = response.expectedGraduationDate ?? '';
            this.undergraduateUniversity = response.undergraduateUniversity ?? '';
            this.undergraduateUniversityOther = response.undergraduateUniversityOther ?? '';
            this.undergraduateDegreeEarned = response.undergraduateDegreeEarned ?? '';
            if (response.undergraduateDegreeEarned) {
                this.undergraduateDegreeEarnedSelected = response.undergraduateDegreeEarned.split(';');
            }
            this.undergraduateDegreeEarnedOther = response.undergraduateDegreeEarnedOther ?? '';
            this.undergradMajor = response.undergradMajor ?? '';
            this.otherCoursesCertifications = response.otherCoursesCertifications ?? '';
            this.handleFieldsValidity();
        }).catch(error => {
            console.log('Error:', error);
        });
    }

    renderedCallback() {
        Promise.all([

            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/bootstrap-4.0.0.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/custom.js'),

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

        //this.setDefaultValues();
        //alert('userId:', this.userId);
        //this.getEducationInfo();
    }

    // Get Object Info.
    @wire(getObjectInfo, { objectApiName: FELLOW_APPLICATION_OBJECT })
    fellowAppObjectInfo;

    setDefaultValues() {

        this.graduateUniversity = getFieldValue(this.fellowApp.data, GRADUATE_UNIVERSITY_FIELD);
        alert('this.graduateUniversity ::' + this.graduateUniversity);
        //this.schoolWithinUniversity = getFieldValue(this.fellowApp.data, SCHOOL_WITHIN_UNIVERSITY_FIELD);
        // this.schoolUniversityOther = getFieldValue(this.fellowApp.data, SCHOOL_UNIVERSITY_OTHER_FIELD);
        // this.graduateDegree = getFieldValue(this.fellowApp.data, GRADUATE_DEGREE_FIELD);
        // this.graduateDegreeOther = getFieldValue(this.fellowApp.data, GRADUATE_DEGREE_OTHER_FIELD);
        // this.graduateDegreeConcentration = getFieldValue(this.fellowApp.data, GRADUATE_DEGREE_CONCENTRATION_FIELD);
        // this.graduateDegreeStartDate = getFieldValue(this.fellowApp.data, GRADUATE_DEGREE_START_DATE_FIELD);
        // this.expectedGraduationDate = getFieldValue(this.fellowApp.data, EXPECTED_GRADUATION_DATE_FIELD);
        // this.undergraduateUniversity = getFieldValue(this.fellowApp.data, UNDERGRADUATE_UNIVERSITY_FIELD);
        // this.undergraduateUniversityOther = getFieldValue(this.fellowApp.data, UNDERGRADUATE_UNIVERSITY_OTHER_FIELD);
        // this.undergraduateDegreeEarned = getFieldValue(this.fellowApp.data, UNDERGRADUATE_DEGREE_EARNED_FIELD);
        // this.undergraduateDegreeEarnedOther = getFieldValue(this.fellowApp.data, UNDERGRADUATE_DEGREE_EARNED_OTHER_FIELD);
        // this.undergradMajor = getFieldValue(this.fellowApp.data, UNDERGRAD_MAJOR_FIELD);
        // this.otherCoursesCertifications = getFieldValue(this.fellowApp.data, OTHER_COURSES_CERTIFICATIONS_FIELD);

        this.template.querySelector('.graduate-university').value = this.graduateUniversity;
        // this.template.querySelector('.school-within-university').value = this.schoolWithinUniversity;
        // this.template.querySelector('.school-university-other').value = this.schoolUniversityOther;
        // this.template.querySelector('.graduate-degree').value = this.graduateDegree;
        // this.template.querySelector('.graduate-degree-other').value = this.graduateDegreeOther;
        // this.template.querySelector('.graduate-degree-concentration').value = this.graduateDegreeConcentration;
        // this.template.querySelector('.graduate-degree-start-date').value = this.graduateDegreeStartDate;
        // this.template.querySelector('.expected-graduation-date').value = this.expectedGraduationDate;
        // this.template.querySelector('.undergraduate-university').value = this.undergraduateUniversity;
        // this.template.querySelector('.undergraduate-university-other').value = this.undergraduateUniversityOther;
        // this.template.querySelector('.undergraduate-degree-earned').value = this.undergraduateDegreeEarned;
        // this.template.querySelector('.undergraduate-degree-earned-other').value = this.undergraduateDegreeEarnedOther;
        // this.template.querySelector('.undergrad-major').value = this.undergradMajor;
        // this.template.querySelector('.other-courses-certifications').value = this.otherCoursesCertifications;
    }

    // Get "Graduate Degree(s) you are Pursuing" Picklist values.
    @wire(getPicklistValues, { recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: GRADUATE_DEGREE_FIELD })
    graduateDegreePickListValues(data, error) {
        if (data && data.data && data.data.values) {
            data.data.values.forEach(objPicklist => {
                this.graduateDegreeOptions.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
            });
        } else if (error) {
            console.log(error);
        }
    };

    // Get "Undergraduate Degree(s) earned" Picklist values.
    @wire(getPicklistValues, { recordTypeId: '$fellowAppObjectInfo.data.defaultRecordTypeId', fieldApiName: UNDERGRADUATE_DEGREE_EARNED_FIELD })
    undergraduateDegreeEarnedPickListValues(data, error) {
        if (data && data.data && data.data.values) {
            data.data.values.forEach(objPicklist => {
                this.undergraduateDegreeEarnedOptions.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
            });
        } else if (error) {
            console.log(error);
        }
    };

    // Get "Graduate universites" as a Picklist values.
    @wire(retrieveUniversityAccounts, {})
    retrieveUniversityAccounts({ error, data }) {
        if (data) {
            console.log('Data:'+data);
            try{
                console.log('inside try');
                for(i=0; i<data.length; i++) {
                    console.log('id=' + data[i].Id );
                    console.log('Name=' + data[i].Name );
                    this.parentItems = [...this.parentItems ,{value: data[i].Id , label: data[i].Name}];
                    //console.log('this.items:'+this.items);
                }
                this.parentOptions = this.parentItems;
                this.parentDualOptions = this.parentItems;
                this.underGraduateOptions = this.parentItems;

            }catch(error){
                alert(JSON.stringify(error));
            }
        }else if (error){
            console.log('Error in retrieveUniversityAccounts:'+JSON.stringify(error));
        }
    }

    @wire(retrieveUniversitySchoolAccounts, {parentId: '$parentId'})
    retrieveUniversitySchoolAccounts({ error, data }){
        if (data) {
            try{
                for(i=0; i<data.length; i++) {
                    console.log('id= retrieveUniversitySchoolAccounts' + data[i].Id );
                    console.log('Name= retrieveUniversitySchoolAccounts' + data[i].Name );
                    this.childDefaultItems = [...this.childDefaultItems ,{value: data[i].Id , label: data[i].Name}];
                    //console.log('this.items:'+this.items);
                    this.childOptions = this.childDefaultItems;
                    this.childDualtOptions = this.childDefaultItems;
                }


            }catch(error){
                console.log('Error in 1. retrieveUniversitySchoolAccounts:'+JSON.stringify(error));
            }
        }else if (error){
            console.log('Error in 2. retrieveUniversitySchoolAccounts:'+JSON.stringify(error));
        }

    }

    graduateUniversityChangeHandler(event) {
        // //this.graduateUniversity = event.detail;
        // let target = JSON.parse(JSON.stringify(event.detail))
        // if (target.length > 0) {
        //     this.graduateUniversity = target[0];
        //     //console.log('target length > 0:');
        // }
        // else {
        //     this.graduateUniversity = '';
        // }

        // console.log('graduateUniversity:', this.graduateUniversity);
        this.graduateUniversity = event.detail.value;
        this.childOptions = '';
        this.childItems = [{value: 'null', label: '-- None --'}];
        console.log(':: Before::this.childOptions:'+this.childOptions);
        console.log('selectedOption=' + this.graduateUniversity);
        retrieveUniversitySchoolAccounts({ parentId: this.graduateUniversity })
            .then(result => {
                try{
                for(j=0; j<result.length; j++) {
                    console.log('id=' + result[j].Id );
                    console.log('Name=' + result[j].Name );
                    this.childItems = [...this.childItems ,{value: result[j].Id , label: result[j].Name}];
                    //console.log('this.items:'+this.items);
                }
                this.childOptions = this.childItems;
                console.log(':: After::this.childOptions:'+this.childOptions);
                }catch(error){
                    alert(JSON.stringify(error));
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    schoolWithinUniversityChangeHandler(event) {
        // let target = JSON.parse(JSON.stringify(event.detail))
        // if (target.length > 0) {
        //     this.schoolWithinUniversity = target[0];
        // }
        // else {
        //     this.schoolWithinUniversity = '';
        // }

        // console.log('schoolWithinUniversity:', this.schoolWithinUniversity);
        this.schoolWithinUniversity = event.detail.value;
        console.log('this.schoolWithinUniversity:'+this.schoolWithinUniversity);
    }

    schoolUniversityOtherChangeHandler(event) {
        this.schoolUniversityOther = event.target.value;
    }

    dualGraduateUniversityChangeHandler(event) {
        // let target = JSON.parse(JSON.stringify(event.detail))
        // if (target.length > 0) {
        //     this.dualGraduateUniversity = target[0];
        // }
        // else {
        //     this.dualGraduateUniversity = '';
        // }
        this.dualGraduateUniversity = event.detail.value;
        this.childDualtOptions = '';
        this.childDualItems = [{value: 'null', label: '-- None --'}];
        console.log(':: Before::this.childOptions:'+this.childDualItems);
        console.log('selectedOption=' + this.dualGraduateUniversity);
        retrieveUniversitySchoolAccounts({ parentId: this.dualGraduateUniversity })
            .then(result => {
                try{
                for(j=0; j<result.length; j++) {
                    console.log('id=' + result[j].Id );
                    console.log('Name=' + result[j].Name );
                    this.childDualItems = [...this.childDualItems ,{value: result[j].Id , label: result[j].Name}];
                    //console.log('this.items:'+this.items);
                }
                this.childDualtOptions = this.childDualItems;
                console.log(':: After::this.childOptions:'+this.childDualtOptions);
                }catch(error){
                    alert(JSON.stringify(error));
                }
            })
            .catch(error => {
                this.error = error;
            });

    }

    schoolWithinDualUniversityChangeHandler(event) {
        // let target = JSON.parse(JSON.stringify(event.detail))
        // if (target.length > 0) {
        //     this.schoolWithinDualUniversity = target[0];
        // }
        // else {
        //     this.schoolWithinDualUniversity = '';
        // }
        this.schoolWithinDualUniversity = event.detail.value;
        console.log('schoolWithinDualUniversity:', this.schoolWithinDualUniversity);
    }

    schoolDualUniversityOtherChangeHandler(event) {
        this.schoolDualUniversityOther = event.target.value;
    }

    graduateDegreeChangeHandler(event) {
        this.graduateDegreeSelected = event.detail.value;
    }

    graduateDegreeOtherChangeHandler(event) {
        this.graduateDegreeOther = event.target.value;
    }

    graduateDegreeConcentrationChangeHandler(event) {
        this.graduateDegreeConcentration = event.target.value;
    }

    graduateDegreeStartDateChangeHandler(event) {
        this.graduateDegreeStartDate = event.target.value;
    }

    expectedGraduationDateChangeHandler(event) {
        this.expectedGraduationDate = event.target.value;
    }

    undergraduateUniversityChangeHandler(event) {
        //this.undergraduateUniversity = event.detail;
        // let target = JSON.parse(JSON.stringify(event.detail))
        // if (target.length > 0) {
        //     this.undergraduateUniversity = target[0];
        // }
        // else {
        //     this.undergraduateUniversity = '';
        // }
        this.undergraduateUniversity = event.detail.value;
        console.log('undergraduateUniversity:', this.undergraduateUniversity);
    }

    undergraduateUniversityOtherChangeHandler(event) {
        this.undergraduateUniversityOther = event.target.value;
    }

    undergraduateDegreeEarnedChangeHandler(event) {
        this.undergraduateDegreeEarnedSelected = event.detail.value;
    }

    undergraduateDegreeEarnedOtherChangeHandler(event) {
        this.undergraduateDegreeEarnedOther = event.target.value;
    }

    undergradMajorChangeHandler(event) {
        this.undergradMajor = event.target.value;
    }

    otherCoursesCertificationsChangeHandler(event) {
        this.otherCoursesCertifications = event.target.value;
    }

    updateEducationInformation() {
        console.log('entered');
        const fields = {};
        fields[FELLOW_APPLICATION_ID_FIELD.fieldApiName] = this.fellowApplicationId;
        fields[GRADUATE_UNIVERSITY_FIELD.fieldApiName] = this.graduateUniversity == 'null' ? null : this.graduateUniversity;
        fields[SCHOOL_WITHIN_UNIVERSITY_FIELD.fieldApiName] = this.schoolWithinUniversity == 'null' ? null : this.schoolWithinUniversity;
        fields[SCHOOL_UNIVERSITY_OTHER_FIELD.fieldApiName] = this.schoolUniversityOther;
        fields[GRADUATE_UNIVERSITY_DUAL_FIELD.fieldApiName] = this.dualGraduateUniversity == 'null' ? null : this.dualGraduateUniversity;
        fields[SCHOOL_WITHIN_DUAL_UNIVERSITY_FIELD.fieldApiName] = this.schoolWithinDualUniversity == 'null' ? null : this.schoolWithinDualUniversity;
        fields[SCHOOL_DUAL_UNIVERSITY_OTHER_FIELD.fieldApiName] = this.schoolDualUniversityOther;
        fields[GRADUATE_DEGREE_FIELD.fieldApiName] = this.graduateDegreeSelected.join(';');
        fields[GRADUATE_DEGREE_OTHER_FIELD.fieldApiName] = this.graduateDegreeOther;
        fields[GRADUATE_DEGREE_CONCENTRATION_FIELD.fieldApiName] = this.graduateDegreeConcentration;
        fields[GRADUATE_DEGREE_START_DATE_FIELD.fieldApiName] = this.graduateDegreeStartDate;
        fields[EXPECTED_GRADUATION_DATE_FIELD.fieldApiName] = this.expectedGraduationDate;
        fields[UNDERGRADUATE_UNIVERSITY_FIELD.fieldApiName] = this.undergraduateUniversity == 'null' ? null : this.undergraduateUniversity;
        fields[UNDERGRADUATE_UNIVERSITY_OTHER_FIELD.fieldApiName] = this.undergraduateUniversityOther;
        fields[UNDERGRADUATE_DEGREE_EARNED_FIELD.fieldApiName] = this.undergraduateDegreeEarnedSelected.join(';');
        fields[UNDERGRADUATE_DEGREE_EARNED_OTHER_FIELD.fieldApiName] = this.undergraduateDegreeEarnedOther;
        fields[UNDERGRAD_MAJOR_FIELD.fieldApiName] = this.undergradMajor;
        fields[OTHER_COURSES_CERTIFICATIONS_FIELD.fieldApiName] = this.otherCoursesCertifications;

        const recordInput = {
            fields: fields
        };
        console.log('fields', fields);
        if(this.isInputValid()){
            // updateRecord(recordInput).then((record) => {
            updateEducationInformation({fa:fields}).then((record) => {
                console.log('updateEducationInformation', record);
                const toastEvent = new ShowToastEvent({
                    title: 'Education Information Updated',
                    message: 'Education Information Updated',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                this.connectedCallback();
                this.saveNext();

            }).catch(error => {
                alert(JSON.stringify(error));
                console.log('Education Information Updated:Error:', error);
            });
        }

    }

    saveNext() {
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
    backToPreviousTab() {
        if (!this.isChild) {
            this.navigateToContactInformation();
        }
    }
    navigateToContactInformation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'contactinfo'
            }
        });
    }
    openDualDegreeFields() {
        this.addDualDegree = true;
        // var x = this.template.querySelector(".dualDegree");
        // if (x.style.display === "none") {
        //     x.style.display = "block";
        // } else {
        //     x.style.display = "none";
        // }
    }

    handleFieldsValidity(){
        if(this.fellowshipApplyingFor == 'U.S. Fellowship' || this.fellowshipApplyingFor == 'China Fellowship' || this.fellowshipApplyingFor == 'India Fellowship'){
            this.enableRequired = true;
        }
    }

    isInputValid() {
        let isValid = true;
        let comboFields = this.template.querySelectorAll('lightning-dual-listbox');
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

       // isValid = this.template.querySelector('c-custom-lookup').isValid();
        //isValid = this.graduateUniversity; // uncommented & commented back by Phani
        console.log('isValid:'+isValid);
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