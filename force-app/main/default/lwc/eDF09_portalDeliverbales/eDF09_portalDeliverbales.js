import { LightningElement, api, track, wire } from 'lwc';
// import MOMENT_JS from '@salesforce/resourceUrl/moment';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { refreshApex } from '@salesforce/apex';
//STATIC RESOURCE
import ItemsForEDFDocs from '@salesforce/resourceUrl/ItemsForEDFDocs';
import registrationgbImage from '@salesforce/resourceUrl/registrationgbImage';

import { labels, files, filesIN, filesCN } from './labelUtils'

// Constants
// import getConstants from '@salesforce/apex/Constants.getAllConstants';


//APEX METHOD
import deleteDocument from '@salesforce/apex/Engagement_Controller.deleteDocument';
import getFellowEngagement from "@salesforce/apex/Engagement_Controller.getFellowEngagement";
import getFellowEngagementEDF from "@salesforce/apex/Engagement_Controller.getFellowEngagementEDF";
import updateEngagement from "@salesforce/apex/Engagement_Controller.updateEngagement";
// import getFinalDelURL from "@salesforce/apex/Engagement_Controller.getFinalDelURL";
import renameAttachments from "@salesforce/apex/Engagement_Controller.renameAttachments";
import getEngagementAttachments from "@salesforce/apex/Engagement_Controller.getEngagementAttachments";
import updateFieldValue from "@salesforce/apex/Engagement_Controller.updateFieldValue";
import fetchDeliverableDates from "@salesforce/apex/Engagement_Controller.fetchDeliverableDates";
import fetchDeliverableSections from "@salesforce/apex/EDF02_CustomMetadata_Helper.fetchPortalDeliverablesSection";

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CLIMATE_CORPS_OBJECT from '@salesforce/schema/Climate_Corps_Engagement__c';
import FINAL_DELIVERABLE_PROJ from '@salesforce/schema/Climate_Corps_Engagement__c.Final_Deliverables_Project_Area__c';
import GHG_TARGETTYPE_EXP from '@salesforce/schema/Climate_Corps_Engagement__c.GHG_Target_Type__c';

export default class EDF09_portalDeliverbales extends NavigationMixin(LightningElement) {

    @wire(getObjectInfo, { objectApiName: CLIMATE_CORPS_OBJECT })
    CLIMATE_CORPS_objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$CLIMATE_CORPS_objectInfo.data.defaultRecordTypeId', fieldApiName: FINAL_DELIVERABLE_PROJ })
    FINAL_DELIVERABLE_PROJ_Val;
    @wire(getPicklistValues, { recordTypeId: '$CLIMATE_CORPS_objectInfo.data.defaultRecordTypeId', fieldApiName: GHG_TARGETTYPE_EXP })
    GHG_TARGETTYPE_EXP_Val;

    label = labels;
    files;

    @track
    visibility = { };
    constants = {
        CC_ENGAGEMENT_PICKLIST_VALUE_APPROVED: 'Approved',
        CC_ENGAGEMENT_PICKLIST_VALUE_PENDING_APPROVAL: 'Pending Approval',

        CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX: 'Workplan',
        CC_ENGAGEMENT_PHOTO_FILE_TITLE_PREFIX: 'Photo',
        CC_ENGAGEMENT_PHOTO_RELEASE_FILE_TITLE_PREFIX: 'PhotoReleaseForm',
        CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX: 'PhotoOnsite',
        CC_ENGAGEMENT_ACTIVITY_REPORT_FILE_TITLE_PREFIX: 'Completed Activities Report',
        CC_ENGAGEMENT_FINAL_DELIVERABLES_FILE_TITLE_PREFIX: 'RemainingDeliverables',

        ICON_SECTION_CLOSE: 'utility:chevronup',
        ICON_SECTION_OPEN: 'utility:chevrondown',

        NAVIGATION_PAGE_TYPE_NAMED_PAGE: 'standard__namedPage',
        NAVIGATION_PAGE_HOME: 'home',

        SOBJ_FELLOW_APPLICATION_API: 'Fellow_Application__c',
        SOBJ_APPLICANT_API: 'Applicant__c',

        DATES_SECTION_CERTIFY_TRAINING_SESSION_ATTENDED: 'Certify_Training_Session_Attended',
        DATES_SECTION_COMPLETE_POST_TRAINING_SURVEY: 'Complete_Post_Training_Survey',
        DATES_SECTION_COMPLETE_PRE_WORK: 'Complete_Pre_Work',
        DATES_SECTION_PRE_TRAINING_SURVEY: 'Pre_Training_Survey',
        DATES_SECTION_TRAINING_INFO_SHEET: 'Training_Info_Sheet',
        DATES_SECTION_FINAL_DELIVERABLES_INSTRUCTION: 'Final_Deliverables_Instructions',


    }
    // constants;

    /* @wire(getConstants)
    allConstants(result) {
        console.log('allConstants :: result ::' + JSON.stringify(result));
        if (result.data) {
            this.constants = result.data;
            // console.log('allConstants :: result.data ::' + JSON.stringify(result.data));
            // console.log(result.data.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX ); // will give you the value of your constant
            // console.log(result.data.CC_ENGAGEMENT_FINAL_DELIVERABLES_FILE_TITLE_PREFIX ); // will give you the value of your constant
        }
    } */

    ccEngagement;
    finalDelPDFUrl = null;
    /* startDateApprovalStatus;
    endDateApprovalStatus;
    @track startDatesStyle = '';
    @track endDatesStyle = '';
    @track workPlanStyle = ''; */

    @track approvalStatus = {
        'startDate': '', 'endDate': '', 'workplan': ''
    };
    @track styleClass = {
        'startDate': '', 'endDate': '', 'workplan': ''
    };
    @track pillStyle = {
        'startDate': '', 'endDate': '', 'workplan': ''
    };

    @api uploadedPhotoRelease = '';
    @track navigateFromDashboard = true;
    currentPageReference;
    deliverables;
    openDateSection = false;
    openMediaProfileSection = false;
    openTrainingSection = false;
    showFileName = [];
    finalDeliverablesOtherArea;
    showSpinner;
    showWorkPlanFile = '';
    showMediaFile = '';
    showPublicSummnaryPhotos = '';
    showCompletedActivitiesFile = '';
    showFinalDeliverableFile = '';
    backgroundstyle = `background: url('${registrationgbImage}');-webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover;`;
    showModel = false;
    fellowEngagementAttachmentResult;
    @track workplanFilesList = [];
    @track photoOnsiteFilesList = [];
    @track photoReleaseFilesList = [];
    @track photoFilesList = [];
    @track projectDBFilesList = [];
    @track remainingDelFilesList = [];
    PostTrainingSurvey = null;
    PostTrainingRecordings = null;
    // pillStyle;

    @api currentPageLabel;
    @api previousPageLabel;
    @api previousPageName;
    @api maxlengthFinalDeliverableOtherArea;
    getFellowEnggResult;
    fellowshipApplyingFor;
    postTrainingSurveyInitials; // FB-2732

    @track dates = { };

    DATE_FORMAT = 'MMMM D';

    get uploadedFiles() {
        return this.showWorkPlanFile ? this.showWorkPlanFile.split(',') : [];
    }


    /**
     * Sets CurrentPageReference. This is used to check parameter and then open the desired section likewise.
     */
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }


    /**
     * Fetches CC Engagement data from backend
     */
    @wire(getFellowEngagementEDF)
    wiredGetFellowEnagement(result) {

        this.getFellowEnggResult = result;

        if (result.data) {
            this.ccEngagement = result.data;
            this.fellowshipApplyingFor = this.ccEngagement.Fellow_Application__r.Fellowship_Applying_for__c;

            if (this.ccEngagement != null) {
                this.goalSettingSelected = this.ccEngagement.GHG_Target_Type__c ? this.ccEngagement.GHG_Target_Type__c.split(';') : [];
                this.finalDeliverableSelected = this.ccEngagement.Final_Deliverables_Project_Area__c ? this.ccEngagement.Final_Deliverables_Project_Area__c.split(';') : [];

                // Check if this variable is used.
                this.showProjectOthers = this.finalDeliverableSelected.includes('Specify your own area') ? true : false;
            }

            this.createDatesMap();
            this.setPillTextClassAndStatus();
            this.setPageSectionProperties();
            this.setRegionSpecificFileURLs();

        }
        else if (result.error) {
            console.log(result.error);
            this.showErrorToast(JSON.stringify(result.error));
        }
        else {
            console.log('There is no Engagement linked to your Application. Contact EDF Climate Corps team.');
            // this.showErrorToast('There is no Engagement linked to your Application. Contact EDF Climate Corps team.');
        }
    }


    /**
     * Sets files specific to each region. File variables coming from labelUtils js file
     */
    setRegionSpecificFileURLs() {

        let filesToConvert;
        // console.log('setRegionSpecificFileURLs :: constants ::' + JSON.stringify(this.constants));
        if (this.fellowshipApplyingFor.includes('China')) filesToConvert = filesCN;
        else if (this.fellowshipApplyingFor.includes('India')) filesToConvert = filesIN;
        else filesToConvert = files;

        this.files = this.createFileURLForAll(filesToConvert);
    }


    /**
     * Sets various properties of section. Currently on visibility property is handled.
     */
    setPageSectionProperties() {
        fetchDeliverableSections({ fellowshipApplyingFor: this.fellowshipApplyingFor })
        .then((result) => {

            this.setSectionVisibility(result);

        })
        .catch((error) => {
            this.showErrorToast('ERROR IN setPageSectionProperties :: ' + error);
        });
    }


    /**
     * Sets visibility variable for each section
     * @param {*} data - Portal_Deliverables_Section__mdt records for current Fellowship region
     */
    setSectionVisibility(data) {
        data.map((item) => {
            /*
                Q. Why add a setTimeout and that too of 1 second delay?
                A. Refer to FB-2725 about the problem.
                    Since the visibility of section is dependent on this variable,
                    without the setTimeout, when user opens date and workplan section
                    directly (using c__selectedOption=dateSection), the order of the
                    fields was incorrect i.e. first it showed Workplan, then End Date
                    and then Start Date.
                    I faced similar problem with Sections too i.e. Media Profile was
                    displayed above Start End Date / Workplan section.
                    I added setTimeout to make sure that the visibility of the fields
                    is set in the order in which they are on the page. Hence field
                    would be made visible in the same order in which they are present
                    on the page. For the same reason, I added ORDER BY clause in
                    EDF02_CustomMetadata_Helper.fetchPortalDeliverablesSection method.
                    This fixed the issue of ordering.
            */
            setTimeout(() => {
                this.visibility[item.Section_Field__c] = item.Is_Visible__c;
            }, 1);
        });
    }


    /**
     * Sets text and html class for Start Date, End Date and Workplan
     */
    setPillTextClassAndStatus() {

        //START DATE AND END DATE APPROVAL COLORING AND VALUE TO BE SET
        this.setPillTextClassStatusGeneric('startDate', this.ccEngagement.Start_Date_Approval__c);
        this.setPillTextClassStatusGeneric('endDate', this.ccEngagement.End_Date_Approval__c);
        this.setPillTextClassStatusGeneric('workplan', this.ccEngagement.Workplan_Approval__c);

    }


    setPillTextClassStatusGeneric(fieldName, fieldValueToCheck) {
        // console.log('setPillTextClassStatusGeneric :: constants ::' + JSON.stringify(this.constants));
        if (fieldValueToCheck != undefined && fieldValueToCheck == this.constants.CC_ENGAGEMENT_PICKLIST_VALUE_APPROVED) { //  'Approved'
            this.approvalStatus[fieldName] = this.label.PortalDeliverable_PillLabel_Approved;
            this.styleClass[fieldName] = 'approvedDate badge badge-pill badge-success';
            this.pillStyle[fieldName] = this.label.PortalDeliverable_PillStyle_Approved;
        } else if (fieldValueToCheck != undefined && fieldValueToCheck == this.constants.CC_ENGAGEMENT_PICKLIST_VALUE_PENDING_APPROVAL) { //  'Pending Approval'
            this.approvalStatus[fieldName] = this.label.PortalDeliverable_PillLabel_PendingApproval; // 'Pending Approval'
            this.styleClass[fieldName] = 'notApprovedDate badge badge-pill badge-danger';
            this.pillStyle[fieldName] = this.label.PortalDeliverable_PillStyle_PendingApproval;
        } else {
            this.approvalStatus[fieldName] = '';
            this.styleClass[fieldName] = '';
            this.pillStyle[fieldName] = '';
        }

    }

    /**
     * Sets date from Deliverables Tracker tiles for Portal Deliverables page. Sets the this.dates variable.
     */
    createDatesMap() {
        fetchDeliverableDates({ fellowshipApplyingFor: this.fellowshipApplyingFor, enggId: this.ccEngagement.Id })
        .then((result) => {

            let data = result;

            this.dates.Certify_Training_Session_Attended = this.retrieveDates(data, this.constants.DATES_SECTION_CERTIFY_TRAINING_SESSION_ATTENDED); // 'Certify_Training_Session_Attended'
            this.dates.Complete_Post_Training_Survey     = this.retrieveDates(data, this.constants.DATES_SECTION_COMPLETE_POST_TRAINING_SURVEY); // 'Complete_Post_Training_Survey'
            this.dates.Complete_Pre_Work                 = this.retrieveDates(data, this.constants.DATES_SECTION_COMPLETE_PRE_WORK); // 'Complete_Pre_Work'
            this.dates.Pre_Training_Survey               = this.retrieveDates(data, this.constants.DATES_SECTION_PRE_TRAINING_SURVEY); // 'Pre_Training_Survey'
            this.dates.Training_Info_Sheet               = this.retrieveDates(data, this.constants.DATES_SECTION_TRAINING_INFO_SHEET); // 'Training_Info_Sheet'
            this.dates.Final_Deliverables_Instructions   = this.retrieveDates(data, this.constants.DATES_SECTION_FINAL_DELIVERABLES_INSTRUCTION); // 'Final_Deliverables_Instructions'

        })
        .catch((error) => {
            this.showErrorToast('ERROR IN createDatesMap :: ' + error);
        });
    }


    /**
     * Returns the formatted date
     */
    retrieveDates(result, keyName) {
        if (result[keyName]) return this.formattedDate(result[keyName]);
        else return '';
    }


    /**
     * Formats the date. Better to handle it as part of some DateUtils
     */
    formattedDate(inputDate) {
        let retDate = '';
        let dt = new Date(inputDate + ' 01:00:00');
        // console.log('formattedDate :: retDate ::' + retDate)
        switch(dt.getMonth()) {
            case 0:
                retDate += ' January';
                break;
            case 1:
                retDate += ' Febrary';
                break;
            case 2:
                retDate += ' March';
                break;
            case 3:
                retDate += ' April';
                break;
            case 4:
                retDate += ' May';
                break;
            case 5:
                retDate += ' June';
                break;
            case 6:
                retDate += ' July';
                break;
            case 7:
                retDate += ' August';
                break;
            case 8:
                retDate += ' September';
                break;
            case 9:
                retDate += ' October';
                break;
            case 10:
                retDate += ' November';
                break;
            case 11:
                retDate += ' December';
                break;
            default:
                retDate += '';
        }
        retDate += ' ' + dt.getDate();
        // console.log('formattedDate :: retDate ::' + retDate + '; inputDate ::' + inputDate + '; dt ::' + dt);
        return retDate;
    }


    /**
     * Fetches Attachments from Engagement.
     */
    @wire(getEngagementAttachments, { ccEngagement: '$ccEngagement' })
    wiredGetFellowEnagementAttachments(result) {
        this.fellowEngagementAttachmentResult = result;
        this.formateAttachments();
    }


    formateAttachments() {
        let result = this.fellowEngagementAttachmentResult;
        if (result.data) {
            const retrievedFiles = result.data;
            this.workplanFilesList = [];
            this.photoOnsiteFilesList = [];
            this.photoReleaseFilesList = [];
            this.photoFilesList = [];
            this.projectDBFilesList = [];
            this.remainingDelFilesList = [];
            let workPlanFileNames = '';
            let mediaUploadPhotoFile = '';
            let photoOnsite = '';
            let completedActivitiesFiles = '';
            let finalDeliverableFiles = '';
            let mapKeys = Object.keys(retrievedFiles);
            for (let i = 0; i < mapKeys.length; i++) {
                let mapKey = mapKeys[i];
                let title = retrievedFiles[mapKey];
                // console.log('formateAttachments :: constants ::' + JSON.stringify(this.constants));
                // console.log('formateAttachments :: constants ::' + this.constants.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX);
                if (title.includes(this.constants.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX) && this.workplanFilesList.length == 0) {
                    this.workplanFilesList.push({
                        "label": title,
                        "value": mapKey,
                        "url": `/sfc/servlet.shepherd/document/download/${mapKey}`
                    });
                    // console.log('formateAttachments:: this.workplanFilesList ::' + JSON.stringify(this.workplanFilesList));
                    // console.log('formateAttachments:: this.workplanFilesList ::' + this.workplanFilesList[0].value);
                    continue;
                } else if (title.includes(this.constants.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX)) { //  'PhotoOnsite'
                    this.photoOnsiteFilesList.push({
                        "label": title,
                        "value": mapKey,
                        "url": `/sfc/servlet.shepherd/document/download/${mapKey}`
                    });
                    continue;
                } else if (title.includes(this.constants.CC_ENGAGEMENT_PHOTO_RELEASE_FILE_TITLE_PREFIX) && this.photoReleaseFilesList.length == 0) { // 'PhotoReleaseForm'
                    this.photoReleaseFilesList.push({
                        "label": title,
                        "value": mapKey,
                        "url": `/sfc/servlet.shepherd/document/download/${mapKey}`
                    });
                    continue;
                } else if (title.includes(this.constants.CC_ENGAGEMENT_PHOTO_FILE_TITLE_PREFIX) && this.photoFilesList.length == 0) { // 'Photo'
                    this.photoFilesList.push({
                        "label": title,
                        "value": mapKey,
                        "url": `/sfc/servlet.shepherd/document/download/${mapKey}`
                    });
                    continue;
                } else if (title.includes(this.constants.CC_ENGAGEMENT_ACTIVITY_REPORT_FILE_TITLE_PREFIX) && this.projectDBFilesList.length == 0) { //  'Completed Activities Report'
                    this.projectDBFilesList.push({
                        "label": title,
                        "value": mapKey,
                        "url": `/sfc/servlet.shepherd/document/download/${mapKey}`
                    });
                    continue;
                } else if (title.includes(this.constants.CC_ENGAGEMENT_FINAL_DELIVERABLES_FILE_TITLE_PREFIX)) { // 'RemainingDeliverables'
                    this.remainingDelFilesList.push({
                        "label": title,
                        "value": mapKey,
                        "url": `/sfc/servlet.shepherd/document/download/${mapKey}`
                    });
                    continue;
                }
            }
        }
    }


    /**
     *
     */
    handleFileDelete(event) {
        let documentToDelete = event.target.dataset?.field;
        let documentTitle = event.target.dataset?.title;
        let filePrefixName = event.target.dataset?.fileprefix;
        if (documentToDelete) {
            deleteDocument({
                documentId: documentToDelete,
                fileName: filePrefixName,
                enggId: this.ccEngagement.Id,
                fellowshipRegion: this.fellowshipApplyingFor
            })
            .then(result => {

                this.showSuccessToast(this.label.PortalDeliverable_MessageLabel_FileDeletedSuccessfully);

                refreshApex(this.fellowEngagementAttachmentResult)
                .then(result => {
                    this.formateAttachments();
                }).catch(error => console.log('error in refresh' + error));

                // console.log('handleFileDelete :: documentTitle ::' + documentTitle);
                if (documentTitle  &&  documentTitle.startsWith(this.constants.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX)) { // 'Workplan'
                    // console.log('handleFileDelete :: refreshing Engagement data');
                    // Update the Workplan Pill if workplan is deleted.
                    refreshApex(this.getFellowEnggResult);
                }

            })
            .catch(error => {
                this.showErrorToast(this.label.PortalDeliverable_MessageLabel_UnableToDeleteFile);
            })
        }
    }


    async connectedCallback() {

        // setTimeout(() => {
            this.handleState();
        // }, 2000);
    }


    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData + '/assets/js/bootstrap-4.0.0.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/community-override.css')

        ]).then(() => {
            console.log("All scripts and CSS are loaded.");
        })
        .catch(error => {
            console.log("Error loading scripts and style files");
        });
    }


    handleState() {

        let value = this.currentPageReference.state.c__selectedOption;
        if (value == "dateSection" || value == "workPlanSection") {
            this.changeIcon(null);
        } else if (value == "mediaSection") {
            this.mediaChangeIcon(null);
        } else if (value == "trainingSection") {
            this.trainingChangeIcon(null);
        } else if (value == "finalDeliverables") {
            this.finalDeliverableChangeIcon(null);
        } else if (value == "postTrainingSection") {
            this.postTrainingChangeIcon(null);
        }
    }

    startEndDateIcon = this.constants.ICON_SECTION_OPEN;


    changeIcon(event) {
        if (this.startEndDateIcon == this.constants.ICON_SECTION_OPEN) {

            this.startEndDateIcon = this.constants.ICON_SECTION_CLOSE;
            this.openDateSection = true;

            this.closeMediaHelper();//close media
            this.closeTrainingHelper();//close media
            this.closeRegTrainingHelper();//TRAINING REGISTRATION
            this.closeTrainingPreWorkAgendaHelper();//PREWORKAGENDA
            this.closeFinalDeliverableHelper();//FINAL DELIVERABLE

        } else {
            this.closeDateHelper();
        }
    }

    closeDateHelper() {
        this.startEndDateIcon = this.constants.ICON_SECTION_OPEN;
        this.openDateSection = false;
    }

    workPlanFile = null;


    /**
     * Handler for event when workplan file is finished uploading
     */
    handleWorkPlanUpload = async (event) => {

        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        //this.showFileName = event.detail.files;

        let uploadedFileNames = '';
        let uploadedContentFileIds = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            //uploadedFileNames += uploadedFiles[i].name + ', ';
            if (i < uploadedFiles.length - 1) {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId + ',';
                uploadedFileNames += uploadedFiles[i].name + ', ';
            } else {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId;
                uploadedFileNames += uploadedFiles[i].name;
            }
        }

        this.workPlanFile = uploadedContentFileIds;
        this.showWorkPlanFile = uploadedFileNames;
        this.renameAttachmentHelper(this.workPlanFile, this.constants.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX); // 'Workplan'
    }

    /**
     * After upload is done, rename the file to match the file naming convention
     * @param {*} contVer - Id of the Content Version record to be renamed
     * @param {*} filePrefixName - Prefix of file used during rename
     */
    async renameAttachmentHelper(contVer, filePrefixName) {
        // console.log(`contVer :: ${contVer}, filePrefixName :: ${filePrefixName}, this.ccEngagement.Id :: ${this.ccEngagement.Id}`);
        //const res = await renameAttachments({ contVerIds: this.workPlanFile, fileName: 'WorkPlan' });
        const res = await renameAttachments({
            contVerIds: contVer,
            fileName: filePrefixName,
            enggId: this.ccEngagement.Id,
            fellowshipRegion: this.fellowshipApplyingFor
        });
        refreshApex(this.fellowEngagementAttachmentResult)
            .then(result => {
                this.formateAttachments();
            }).catch(error => console.log('error in refresh' + error));

        if (filePrefixName == this.constants.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX) { // 'Workplan'
            refreshApex(this.getFellowEnggResult);
        }
    }


    /**
     * Start End Date and Workplan 'Save' click handler.
     * @param {*} event
     */
    async onClickSaveDates(event) {

        this.commonTasksAtSaveStart();

        let startDate; let endDate; let twitterUserName = ''; let linkedInUserName = '';

        var inputText = this.template.querySelectorAll("lightning-input");
        // console.log('inputVal>>' + JSON.stringify(inputText));

        // Set the variables to be used later while setting JSON
        inputText.forEach(function (element) {
            // console.log('all>>' + element.name);
            if (element.name == "startDate") {
                startDate = element.value;

            } if (element.name == "endDate") {
                endDate = element.value;

            } if (element.name == "twitterUserName") {

                if (this.ccEngagement.Fellow_Application__r.Applicant__r.Twitter_Handle__c != undefined && this.ccEngagement.Fellow_Application__r.Applicant__r.Twitter_Handle__c != element.value) {
                    twitterUserName = element.value;
                } else {
                    twitterUserName = this.ccEngagement.Fellow_Application__r.Applicant__r.Twitter_Handle__c;
                }

            } if (element.name == "linkedInUserName") {
                if (this.ccEngagement.Fellow_Application__r.Applicant__r.LinkedIn_Profile__c != undefined && this.ccEngagement.Fellow_Application__r.Applicant__r.LinkedIn_Profile__c != element.value) {
                    linkedInUserName = element.value;
                } else {
                    linkedInUserName = this.ccEngagement.Fellow_Application__r.Applicant__r.LinkedIn_Profile__c;
                }
            }
        }, this);

        // Set JSON.
        const Climate_Corps_Engagement = {
            Id: this.ccEngagement.Id,
            Start_Date__c: startDate,
            End_date__c: endDate,
            Fellow_Application__r: {
                sObjectType: this.constants.SOBJ_FELLOW_APPLICATION_API, // 'Fellow_Application__c',
                Id: this.ccEngagement.Fellow_Application__c,
                Applicant__c: this.ccEngagement.Fellow_Application__r.Applicant__c,
                Applicant__r: {
                    sObjectType: this.constants.SOBJ_APPLICANT_API, // 'Applicant__c',
                    Id: this.ccEngagement.Fellow_Application__r.Applicant__c,
                    LinkedIn_Profile__c: linkedInUserName,
                    Twitter_Handle__c: twitterUserName,
                    Bio__c: 'test'
                }
            }
        };


        let finalDeliverable = this.finalDeliverableSelected != null ? this.finalDeliverableSelected.toString() : null;
        let goalSetting = this.goalSettingSelected != null ? this.goalSettingSelected.toString() : null;

        // Update CC Engagement record
        await updateEngagement({
            ccEngagementInput: Climate_Corps_Engagement,
            icItems: finalDeliverable,
            goalSettingItems: goalSetting,
            workPlanAttachment: this.workPlanFile,
            fellowshipRegion: this.fellowshipApplyingFor
        });
        // console.log('BACK AFTER SAVE');

        this.commonTasksAtSaveSuccessEnd();

        this.showSaveSuccessToast(this.label.PortalDeliverable_MessageLabel_SavedSuccessFillOtherSection);

        // Refresh Engagement Data after save.
        refreshApex(this.getFellowEnggResult);
    }


    //MEDIA RELATED
    //related to file
    myRecordId = null;
    get acceptedFormats() {
        return this.label.PortalDeliverable_AcceptedFileFormats.split(','); // ['.pdf', '.png', '.docx', '.xlsx','.xls', '.xlsm'];
    }

    get acceptedPhotoFormats() {
        return this.label.PortalDeliverable_AcceptedPhotoFormats.split(','); // ['.png', '.jpg', '.jpeg', '.gif'];
    }

    // Function not used.
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
    }


    /**
     * Post training 'Save' click handler
     * @param {*} event
     * @returns
     */
    onClickSavePostTraining(event) {

        let initialsEle = this.template.querySelector("[data-name='postTrainingInitials']");
        // console.log('onClickSavePostTraining :: initialsEle :: ${initialsEle}' + initialsEle);
        // console.log('onClickSavePostTraining :: initialsEle :: ${initialsEle == undefined} :: ' + (initialsEle == undefined));
        // console.log('onClickSavePostTraining :: initialsEle :: ${initialsEle === undefined} :: ' + (initialsEle === undefined));
        if (initialsEle  &&  !initialsEle.value) {
            this.showErrorToast(this.label.PortalDeliverable_MessageLabel_AddInitials);
            return false;
        }

        this.commonTasksAtSaveStart();
        // console.log('this.postTrainingSurveyInitials :: ' + this.postTrainingSurveyInitials);
        let engagementRecord = {
            Id: this.ccEngagement.Id,
            Fellow_Training_Confirmation__c: (initialsEle && initialsEle.value ? initialsEle.value : null),
            Fellow_Training_Survey_Confirmation__c: this.postTrainingSurveyInitials,
            Fellow_Application__r: {
                sObjectType: this.constants.SOBJ_FELLOW_APPLICATION_API, // 'Fellow_Application__c',
                Id: this.ccEngagement.Fellow_Application__c,
                Applicant__c: this.ccEngagement.Fellow_Application__r.Applicant__c
            }
        }
        // console.log('engagementRecord :: ' + JSON.stringify(engagementRecord));
        updateEngagement({
            ccEngagementInput: engagementRecord,
            fellowshipRegion: this.fellowshipApplyingFor
        })
        .then(result => {
            this.commonTasksAtSaveSuccessEnd();
            this.showSuccessToast(this.label.PortalDeliverable_MessageLabel_SavedSuccessFillOtherSection);
        })
        .catch(error => {
            this.commonTasksAtSaveErrorEnd();
            this.showErrorToast('error' + error.body?.message);
        });
    }


    /**
     * Media Profile 'Save' click handler
     * @param {*} event
     */
    async onClickSaveMedia(event) {
        let twitterUserName = ''; let linkedInUserName = '';
        var inputText = this.template.querySelectorAll("lightning-input");
        inputText.forEach(function (element) {
            if (element.name == "twitterUserName") {
                twitterUserName = element.value;

            } if (element.name == "linkedInUserName") {
                linkedInUserName = element.value;

            }

        }, this);

        this.commonTasksAtSaveStart();

        const Climate_Corps_Engagement = {
            Id: this.ccEngagement.Id,
            Fellow_Application__r: {
                sObjectType: this.constants.SOBJ_FELLOW_APPLICATION_API, // 'Fellow_Application__c',
                Id: this.ccEngagement.Fellow_Application__c,
                Applicant__c: this.ccEngagement.Fellow_Application__r.Applicant__c,
                Applicant__r: {
                    sObjectType: this.constants.SOBJ_APPLICANT_API, // 'Applicant__c',
                    Id: this.ccEngagement.Fellow_Application__r.Applicant__c,
                    LinkedIn_Profile__c: linkedInUserName,
                    Twitter_Handle__c: twitterUserName,
                    Bio__c: 'test'
                }
            }
        };

        let finalDeliverable = this.finalDeliverableSelected != null ? this.finalDeliverableSelected.toString() : null;
        let goalSetting = this.goalSettingSelected != null ? this.goalSettingSelected.toString() : null;
        await updateEngagement({
            ccEngagementInput: Climate_Corps_Engagement,
            icItems: finalDeliverable,
            goalSettingItems: goalSetting,
            workPlanAttachment: this.workPlanFile,
            photoAttachment: this.photoAttachmentFile,
            fellowshipRegion: this.fellowshipApplyingFor
        });

        this.commonTasksAtSaveSuccessEnd();
        this.showSaveSuccessToast(this.label.PortalDeliverable_MessageLabel_SavedSuccessFillOtherSection);
    }

    photoAttachmentFile;
    photoLoading;


    /**
     * Handler when Photo is uploaded
     * @param {*} event
     */
    handlePhotoUpload = async (event) => {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        let uploadedFileNames = ''; let uploadedContentFileIds = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            //uploadedFileNames += uploadedFiles[i].name + ', ';
            if (i < uploadedFiles.length - 1) {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId + ',';
                uploadedFileNames += uploadedFiles[i].name + ', ';
            } else {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId;
                uploadedFileNames += uploadedFiles[i].name;
            }
        }

        this.photoAttachmentFile = uploadedContentFileIds;
        this.showMediaFile = uploadedFileNames;
        this.renameAttachmentHelper(this.photoAttachmentFile, this.constants.CC_ENGAGEMENT_PHOTO_FILE_TITLE_PREFIX); // 'Photo'
    }

    photoReleaseFormFile;

    /**
     * Handler when Photo Release form is uploaded
     * @param {*} event
     */
    handlePhotoReleaseUpload = async (event) => {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        let uploadedFileNames = ''; let uploadedContentFileIds = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            //uploadedFileNames += uploadedFiles[i].name+' ';
            if (i < uploadedFiles.length - 1) {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId + ',';
                uploadedFileNames += uploadedFiles[i].name + ', ';
            } else {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId;
                uploadedFileNames += uploadedFiles[i].name;
            }
        }
        this.photoReleaseFormFile = uploadedContentFileIds;
        this.showMediaPhotoFile = uploadedFileNames;
        this.renameAttachmentHelper(this.photoReleaseFormFile, this.constants.CC_ENGAGEMENT_PHOTO_RELEASE_FILE_TITLE_PREFIX); // 'PhotoReleaseForm'
    }


    //MEDIA SECTION
    mediaProfileAccordIcon = this.constants.ICON_SECTION_OPEN;


    /**
     * Handler event when user clicks on Media Profile header to handle expand and collapse section
     * @param {*} event
     */
    mediaChangeIcon(event) {
        if (this.mediaProfileAccordIcon == this.constants.ICON_SECTION_OPEN) {
            this.mediaProfileAccordIcon = this.constants.ICON_SECTION_CLOSE;

            this.openMediaProfileSection = true;

            this.closeDateHelper(); //close date
            this.closeTrainingHelper();//close media
            this.closeRegTrainingHelper();//TRAINING REGISTRATION
            this.closeTrainingPreWorkAgendaHelper();//PREWORKAGENDA
            this.closeFinalDeliverableHelper();//FINAL DELIVERABLE
        } else {
            this.closeMediaHelper();
        }
    }
    closeMediaHelper() {
        this.mediaProfileAccordIcon = this.constants.ICON_SECTION_OPEN;
        this.openMediaProfileSection = false;
    }


    //TRAINING SECTION
    trainingAccordIcon = this.constants.ICON_SECTION_OPEN;

    /**
     * Handler event when user clicks on Training header to handle expand and collapse section
     * @param {*} event
     */
    trainingChangeIcon(event) {
        if (this.trainingAccordIcon == this.constants.ICON_SECTION_OPEN) {
            this.trainingAccordIcon = this.constants.ICON_SECTION_CLOSE;

            this.openTrainingSection = true;

            this.closeDateHelper();//close date
            this.closeMediaHelper();//close media
            this.closeRegTrainingHelper();
            this.closeTrainingPreWorkAgendaHelper();//PREWORKAGENDA
            this.closeFinalDeliverableHelper();//FINAL DELIVERABLE

        } else {
            this.closeTrainingHelper();
        }
    }
    closeTrainingHelper() {
        this.trainingAccordIcon = this.constants.ICON_SECTION_OPEN;
        this.openTrainingSection = false;
    }


    //REGISTER FOR TRAINING
    regTrainingAccordIcon = this.constants.ICON_SECTION_OPEN;
    openRegTrainingSection = false;

    /**
     * Handler event when user clicks on Training header to handle expand and collapse section
     * @param {*} event
     */
    regTrainingChangeIcon(event) {
        if (this.regTrainingAccordIcon == this.constants.ICON_SECTION_OPEN) {
            this.regTrainingAccordIcon = this.constants.ICON_SECTION_CLOSE;

            this.openRegTrainingSection = true;

            this.closeDateHelper();//close date
            this.closeMediaHelper();//close media
            this.closeTrainingHelper();//close training
            this.closeTrainingPreWorkAgendaHelper();
            this.closeFinalDeliverableHelper();//FINAL DELIVERABLE
        } else {
            this.closeRegTrainingHelper();
        }
    }
    closeRegTrainingHelper() {
        this.regTrainingAccordIcon = this.constants.ICON_SECTION_OPEN;
        this.openRegTrainingSection = false;
    }


    trainPreworkAccordIcon = this.constants.ICON_SECTION_OPEN;
    openTrainingPreWrkAgenda = false;


    /**
     * Handler event when user clicks on Pre-Training header to handle expand and collapse section
     * @param {*} event
     */
    trainingPreWorkAgendaChangeIcon(event) {
        if (this.trainPreworkAccordIcon == this.constants.ICON_SECTION_OPEN) {
            this.trainPreworkAccordIcon = this.constants.ICON_SECTION_CLOSE;

            this.openTrainingPreWrkAgenda = true;

            this.closeDateHelper();//close date
            this.closeMediaHelper();//close media
            this.closeTrainingHelper();//close training
            this.closeRegTrainingHelper();//close training registration
            this.closeFinalDeliverableHelper();//FINAL DELIVERABLE
        } else {
            this.closeTrainingPreWorkAgendaHelper();

        }
    }
    closeTrainingPreWorkAgendaHelper() {
        this.trainPreworkAccordIcon = this.constants.ICON_SECTION_OPEN;
        this.openTrainingPreWrkAgenda = false;
    }


    postTrainingAccordIcon = this.constants.ICON_SECTION_OPEN;
    openPostTrainingSection = false;


    /**
     * Handler event when user clicks on Post-Training header to handle expand and collapse section
     * @param {*} event
     */
    postTrainingChangeIcon(event) {

        if (this.postTrainingAccordIcon == this.constants.ICON_SECTION_OPEN) {
            this.postTrainingAccordIcon = this.constants.ICON_SECTION_CLOSE;

            this.openPostTrainingSection = true;

            this.closeDateHelper();//close date
            this.closeMediaHelper();//close media
            this.closeTrainingHelper();//close training
            this.closeRegTrainingHelper();//close training registration
            this.closeTrainingPreWorkAgendaHelper();
            this.closeFinalDeliverableHelper();//FINAL DELIVERABLE

        } else {
            this.closePostTrainingHelper();
        }
    }
    closePostTrainingHelper() {
        this.postTrainingAccordIcon = this.constants.ICON_SECTION_OPEN;
        this.openPostTrainingSection = false;
    }


    finalDeliverableAccordIcon = this.constants.ICON_SECTION_OPEN;
    openFinalDeliverablSection = false;


    /**
     * Handler event when user clicks on Final Deliverable header to handle expand and collapse section
     * @param {*} event
     */
    finalDeliverableChangeIcon(event) {
        if (this.finalDeliverableAccordIcon == this.constants.ICON_SECTION_OPEN) {
            this.finalDeliverableAccordIcon = this.constants.ICON_SECTION_CLOSE;

            this.openFinalDeliverablSection = true;

            this.closeDateHelper();//close date
            this.closeMediaHelper();//close media
            this.closeTrainingHelper();//close training
            this.closeRegTrainingHelper();//close training registration
            this.closeTrainingPreWorkAgendaHelper();
            this.closePostTrainingHelper();
        } else {
            this.closeFinalDeliverableHelper();
        }
    }
    closeFinalDeliverableHelper() {
        this.finalDeliverableAccordIcon = this.constants.ICON_SECTION_OPEN;
        this.openFinalDeliverablSection = false;
    }


    @track value = [];
    @track value2 = [];


    /**
     * Change handler for 'Initials' field in 'Post Training' and 'Final Deliverables' section
     * @param {*} event
     */
    handleFieldChange(event) {
        if (event.target.name === "FinalDelOtherArea") {
            this.finalDeliverablesOtherArea = event.target.value;
        } else if (event.target.name === 'postTrainingInitials') {
            this.postTrainingInitails = event.target.value;
        } else if (event.target.name === 'postTrainingSurveyInitials') {
            this.postTrainingSurveyInitials = event.target.value;
        }
    }

    finalDeliverableSelected;

    /**
     * Event handler for Project Area checkbox group
     * @param {*} e
     */
    handleFinalDelivrableChange(e) {
        this.finalDeliverableSelected = e.detail.value;
        this.showProjectOthers = e.detail.value.includes('Specify your own area') ? true : false;

    }

    goalSettingSelected;


    /**
     * Event handler for GHG Target Type checkbox group
     * @param {*} e
     */
    handleGoalSettingsChange(e) {
        this.goalSettingSelected = e.detail.value;

    }


    // THIS FUNCTION SEEMS NOT BEING USED.
    onClickPublicSummary(event) {
        var inputText = this.template.querySelectorAll("lightning-textarea");
        inputText.forEach(function (element) {
            if (element.name == "publicSummary") {
                console.log('publicSummary>>' + element.value);
            }
        }, this);
    }



    onSitePhotoFile = null;


    /**
     * Event handler when Onsite Photo files are uploaded
     * @param {*} event
     * @returns
     */
    handleOnSitePhotoUploadFinished = async (event) => {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        // console.log('uploadedFiles' + JSON.stringify(uploadedFiles));
        let uploadedFileNames = ''; let uploadedContentFileIds = '';
        if (uploadedFiles.length > 3) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.PortalDeliverable_MessageTitle_Error, // 'Error',
                    message: this.label.PortalDeliverable_MessageLabel_SelectOnly3Photos, // 'Select only up to 3 photos',
                    variant: 'error'
                })
            );

            // TODO: Ideally system should delete all uploaded files, if fellow uploaded more than 3 files.
            return false;
        }
        for (let i = 0; i < uploadedFiles.length; i++) {
            //uploadedFileNames += uploadedFiles[i].name + ', ';
            if (i < uploadedFiles.length - 1) {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId + ',';
                uploadedFileNames += uploadedFiles[i].name + ', ';
            } else {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId;
                uploadedFileNames += uploadedFiles[i].name;
            }
        }
        this.onSitePhotoFile = uploadedContentFileIds;
        this.showPublicSummnaryPhotos = uploadedFileNames;
        this.renameAttachmentHelper(this.onSitePhotoFile, this.constants.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX); // 'PhotoOnsite'
    }

    completedActivitiesFile = null;


    /**
     * Event handler when Completed Activities report is uploaded
     * @param {*} event
     */
    handleCompletedActivitiesUpload = async (event) => {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        //this.showFileName = event.detail.files;
        // console.log('uploadedFiles' + JSON.stringify(uploadedFiles));
        let uploadedFileNames = ''; let uploadedContentFileIds = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            //uploadedFileNames += uploadedFiles[i].name + ', ';
            if (i < uploadedFiles.length - 1) {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId + ',';
                uploadedFileNames += uploadedFiles[i].name + ', ';
            } else {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId;
                uploadedFileNames += uploadedFiles[i].name;
            }
        }
        this.completedActivitiesFile = uploadedContentFileIds;
        this.showCompletedActivitiesFile = uploadedFileNames;
        // updateFieldValue({updateRecordId:this.ccEngagement.Id,fieldName:'Project_Database_Submitted__c',fieldVal:'true',ObjectName:'Climate_Corps_Engagement__c',isFieldBoolean:true});
        this.renameAttachmentHelper(this.completedActivitiesFile, this.constants.CC_ENGAGEMENT_ACTIVITY_REPORT_FILE_TITLE_PREFIX); // 'Completed Activities Report'
    }

    finalDeliverableFile = null;


    /**
     * Event handler when File Deliverables files are uploaded
     * @param {*} event
     */
    handleFinalDeliverableUpload = async (event) => {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        //this.showFileName = event.detail.files;
        // console.log('uploadedFiles' + JSON.stringify(uploadedFiles));
        let uploadedFileNames = ''; let uploadedContentFileIds = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            //uploadedFileNames += uploadedFiles[i].name + ', ';
            if (i < uploadedFiles.length - 1) {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId + ',';
                uploadedFileNames += uploadedFiles[i].name + ', ';
            } else {
                uploadedContentFileIds += uploadedFiles[i].contentVersionId;
                uploadedFileNames += uploadedFiles[i].name;
            }
        }
        this.finalDeliverableFile = uploadedContentFileIds;
        this.showFinalDeliverableFile = uploadedFileNames;
        // updateFieldValue({updateRecordId:this.ccEngagement.Id,fieldName:'Remaining_Deliverables_Submitted__c',fieldVal:'true',ObjectName:'Climate_Corps_Engagement__c',isFieldBoolean:true});
        this.renameAttachmentHelper(this.finalDeliverableFile, this.constants.CC_ENGAGEMENT_FINAL_DELIVERABLES_FILE_TITLE_PREFIX); // 'RemainingDeliverables'
    }


    /**
     * Common tasks before and after save
     */
    commonTasksAtSaveStart() {
        this.showSpinner = true;
    }
    commonTasksAtSaveSuccessEnd() {
        this.showSpinner = false;
    }
    commonTasksAtSaveErrorEnd() {
        this.showSpinner = false;
    }


    /**
     * Final Deliverables Part1 & Part2 'Save' click handler
     * @param {*} event
     */
    onClickSubmitEDFDeliverable(event) {

        this.commonTasksAtSaveStart();

        let analyzeData = ''; let chainSupply = '';
        let zeroEmission = ''; let fellowInitials = '';
        let publicSummary = ''; let personalEmailAddr = '';
        var inputText = this.template.querySelectorAll("lightning-input");
        inputText.forEach(function (element) {
            if (element.name == "analyzeData") {
                analyzeData = element.value;
            }
            else if (element.name == "chainSupply") {
                chainSupply = element.value;
            }
            else if (element.name == "zeroEmission") {
                zeroEmission = element.value;
            }
            else if (element.name == "fellowInitials") {
                fellowInitials = element.value;
            }
            else if (element.name == "personalEmailAddress") {
                personalEmailAddr = element.value;
            }
        }, this);


        let commentOnFinalDeliverables = '';
        var inputTextArea = this.template.querySelectorAll("lightning-textarea");
        inputTextArea.forEach(function (element) {
            if (element.name == "commentOnFinalDel") {
                commentOnFinalDeliverables = element.value;
            }
            else if (element.name == "publicSummary") {
                publicSummary = element.value;
            }
        }, this);


        const Climate_Corps_Engagement = {
            Id: this.ccEngagement.Id,
            Fellow_Application__r: {
                sObjectType: this.constants.SOBJ_FELLOW_APPLICATION_API, // 'Fellow_Application__c',
                Id: this.ccEngagement.Fellow_Application__c,
                Applicant__c: this.ccEngagement.Fellow_Application__r.Applicant__c,

            },
            Public_Summary_Approval_Status__c: publicSummary,
            Number_of_Suppliers__c: chainSupply,
            Building_Data_Analyzed__c: analyzeData,
            Zero_Emission_vehicles_rectifications__c: zeroEmission,
            Comment_On_Final_Deliverables__c: commentOnFinalDeliverables,
            Fellow_Initials__c: fellowInitials,
            Final_Deliverables_Other_Area__c: this.finalDeliverablesOtherArea ? this.finalDeliverablesOtherArea : this.ccEngagement.Final_Deliverables_Other_Area__c,
            Fellow_Training_Confirmation__c: this.postTrainingInitails ? this.postTrainingInitails : this.ccEngagement.Fellow_Training_Confirmation__c,
            Fellow_Training_Survey_Confirmation__c: this.postTrainingSurveyInitials ? this.postTrainingSurveyInitials : this.ccEngagement.Fellow_Training_Survey_Confirmation__c
        };

        let finalDeliverable = this.finalDeliverableSelected != null ? this.finalDeliverableSelected.toString() : null;
        let goalSetting = this.goalSettingSelected != null ? this.goalSettingSelected.toString() : null;
        console.log(`Before updateEngagement ::: personalEmailAddr :: ${personalEmailAddr}`);
        updateEngagement({
            ccEngagementInput: Climate_Corps_Engagement,
            icItems: finalDeliverable,
            goalSettingItems: goalSetting,
            personalEmailAddress: personalEmailAddr,
            onsitePhotoAttachment: this.onSitePhotoFile,
            projectDataBaseAttachment: this.completedActivitiesFile,
            remainingDeliverablesAttachment: this.finalDeliverableFile,
            fellowshipRegion: this.fellowshipApplyingFor
        }).then(() => {
            this.commonTasksAtSaveSuccessEnd();
            this.showSaveSuccessToast(this.label.PortalDeliverable_MessageLabel_SavedSuccessFillOtherSection);

        }).catch(error => {
            this.commonTasksAtSaveErrorEnd();
            this.showSaveErrorToast(error.body?.message);

        })
    }


    /**
     * Handler of 'Dashboard' link click on breadcrumb
     */
    navigateToDashboard() {
        this[NavigationMixin.Navigate]({
            type: this.constants.NAVIGATION_PAGE_TYPE_NAMED_PAGE, // 'standard__namedPage',
            attributes: {
                pageName: this.constants.NAVIGATION_PAGE_HOME, // 'home'
            }
        });
    }


    /**
     * Handler of 'Deliverables Tracker' link click on breadcrumb
     */
    navigateToItems() {
        this[NavigationMixin.Navigate]({
            type: this.constants.NAVIGATION_PAGE_TYPE_NAMED_PAGE, // 'standard__namedPage',
            attributes: {
                pageName: this.previousPageName // 'edfitems'
            }
        });
    }

    // THIS METHOD IS NOT CURRENTLY USED.
    handleFileUploadClick(event) {
        this.showModel = true;
    }

    // THIS METHOD IS NOT CURRENTLY USED.
    handleModelClose() {
        this.showModel = false;
    }



    /**
     * Common code to show Toast
     * @param {*} title
     * @param {*} msg
     * @param {*} variant
     */
    showToast(title, msg, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: variant
            })
        );
    }
    showErrorToast(msg) {
        this.showToast(this.label.PortalDeliverable_MessageTitle_Error, msg, 'error');
    }
    showSuccessToast(msg) {
        this.showToast(this.label.PortalDeliverable_MessageTitle_Success, msg, 'success');
    }
    showSaveSuccessToast(msg) {
        this.showToast(this.label.PortalDeliverable_MessageTitle_SavedSuccessfully, msg, 'success');
    }
    showSaveErrorToast(msg) {
        this.showToast(this.label.PortalDeliverable_MessageLabel_ErrorWhileSaving, msg, 'error');
    }


    /**
     * Create file URL based on data from custom label.
     * If file name contains '/' return as is since it is
     * a complete URL in itself.
     * If file name does not contain '/' attach URL of
     * ItemsForEDF static resource so that file gets picked
     * from there.
     * @param {*} fileName
     * @returns
     */
    createFileURL(fileName) {
        if (fileName.indexOf('/') >= 0) {
            return fileName;
        }

        return ItemsForEDFDocs + `/${fileName}`;
    }


    /**
     * Creates a file URL for the complete JSON.
     * Calls createFileURL method internally.
     * @param {*} files
     * @returns
     */
    createFileURLForAll(files) {

        for (let key in files) {
            let value = files[key];
            files[key] = this.createFileURL(value);
        }
        return files;
    }
}