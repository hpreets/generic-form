/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 1/7/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: This class contains all Items For EDF functinality.
# Test Class............: EngagementController_Test
# Change Log:
#
############################################################################
*/
global without sharing class Engagement_Controller {

    @AuraEnabled
    public Fellow_Application__c fellowApp{get;set;}
    @AuraEnabled
    public Fellow_Application__c fApp ;
    @AuraEnabled
    public static Climate_Corps_Engagement__c ccEngagement{get;set;}
    @AuraEnabled
    public static Fellow_Application__c fellowApp{get;set;}
    @AuraEnabled
    public static String deadlineForPreFellowship {get;set;}

    @AuraEnabled
    public static String deadlineForDuringFellowship {get;set;}

    @AuraEnabled
    public static String deadlineForFellowshipClosure {get;set;}

    private static final Constants CONSTT = Constants.getAllConstants();

    /**
    * Description : This method returns the Populate Engagement object for corresponding Fellow Application ID.
    **/
    @AuraEnabled (cacheable=true)
    public static Climate_Corps_Engagement__c getFellowEngagementEDF(){
        return Engagement_Controller.getFellowEngagement(null);
    }

    @AuraEnabled
    public static Climate_Corps_Engagement__c getFellowEngagement(Id fAppId) {
        fAppId='a141D000001NYhLQAW';//application id

        System.debug('getFellowEngagement :: UserInfo.getUserId() ::' + UserInfo.getUserId());
        User usrInfo = [SELECT ID,CONTACTID FROM USER WHERE ID=:UserInfo.getUserId()];
        System.debug('getFellowEngagement :: usrInfo ::' + usrInfo);
        Contact con = new Contact();
        if(usrInfo!=null && usrInfo.ContactId!=null){
            String currentYear = CustomSettings_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
            con = [select id, (select id from Applications__r WHERE CC_Year__c = :currentYear ORDER BY CreatedDate DESC limit 1) from contact where id=:usrInfo.ContactId];
            System.debug('getFellowEngagement :: con ::' + con);
            if(con!=null){
                fAppId = con.Applications__r[0].Id;
            }
        }

        if(fAppId!=null) {
            fellowApp =
                [Select id, Sex__c, Race__c , Applicant__r.FirstName, Applicant__r.LastName,
                 Applicant__c
                 From Fellow_Application__c
                 Where id = :fAppId LIMIT 1];

            String fromFields = Engagement_Controller.getSelectFields(
                Climate_Corps_Engagement__c.sObjectType,
                new List<String> {
                    'Fellow_Application__r.Applicant__c',
                    'Fellow_Application__r.Applicant__r.Bio__c',
                    'Fellow_Application__r.Applicant__r.npe01__HomeEmail__c',
                    'Fellow_Application__r.Fellowship_Applying_for__c',
                    'Fellow_Application__r.Applicant__r.Twitter_Handle__c',
                    'Fellow_Application__r.Applicant__r.LinkedIn_Profile__c'
                });

            List<Climate_Corps_Engagement__c> lst
                = Database.query(
                    'SELECT ' + fromFields
                    + ' FROM Climate_Corps_Engagement__c'
                    + ' WHERE Fellow_Application__c = :fAppId'
                    + ' ORDER BY CreatedDate DESC LIMIT 1');
            /* List<Climate_Corps_Engagement__c> lst =
                [SELECT c.Id,//j/c.Story_worthy__c,
                    c.Start_Date__c,
                    c.Stage__c,
                    c.Photo__c,
                    c.Onsite_Photo_Submitted__c,
                    c.Remaining_Deliverables_Submitted__c,
                    c.Project_Database_Submitted__c,
                    c.LastModifiedDate,
                    c.LastModifiedById,
                    c.LastActivityDate,
                    c.Fellowship_State__c,
                    c.Engagement_Notes__c,
                    c.End_date__c,
                    Fellow_Application__r.Applicant__c,
                    Fellow_Application__r.Applicant__r.Bio__c,
                    Fellow_Application__r.Applicant__r.npe01__HomeEmail__c,
                    c.Disqualified_Reason__c,
                    Fellow_Application__r.Fellowship_Applying_for__c, // HS
                    c.CreatedDate,
                    c.CreatedById,
                    c.Contact__c,
                    c.CC_Year__c,
                    / *c.Approved_Blog_Online__c,* /
                    c.Additional_Contact__c,
                    c.Account__c,
                    c.Accessible_by_public_transportation__c,
                    c.Fellowship_City__c,
                    c.Fellow_School__c,
                    c.Fellow_Name__c,
                    c.Fellow_Application__c,
                    / *c.Fellow_Gmail_Address__c,* /
                    c.Deadline_for_Pre_Fellowship_Prep__c,
                    c.Workplan_Approval__c,
                    c.Start_Date_Approval__c,
                    c.End_Date_Approval__c,
                    Name,
                    Fellow_Application__r.Applicant__r.Twitter_Handle__c,
                    / *CompleteTrainingPreWork__c,* /
                    Public_Summary_Approval_Status__c,
                    ProjectSolutions__c,
                    SolutionsPotentialImpact__c,
                    Fellow_Application__r.Applicant__r.LinkedIn_Profile__c,
                    / *c.Net_Present_Value_USD__c,* /
                    Fellow_Initials__c,
                    c.Final_Deliverables_Project_Area__c, //Added By pranjal for the new Sections for Fellowship
                    c.Final_Deliverables_Other_Area__c,
                    c.Building_Data_Analyzed__c,
                    c.Number_of_Suppliers__c,
                    c.Comment_On_Final_Deliverables__c, // new field added by pranjal
                    c.GHG_Target_Type__c,
                    c.Orientation_Webinar__c,
                    c.Kilowatt_Signup__c,
                    c.Reviewed_Work_Authorization__c,
                    c.Reviewed_HR_Webinar__c,
                    c.Registered_for_Training__c,
                    c.CompleteTrainingPreWork__c,
                    c.Requested_Mentor__c,
                    c.Fellowship_Feedback_Survey__c,
                    c.Training_Info_Survey__c,
                    c.Submit_Start_End_dates__c,
                    c.Submit_Workplan__c,
                    c.Media_Profile__c,
                    c.Complete_Post_Training_Items__c,
                    c.Submit_Final_Deliverables__c,
                    c.Zero_Emission_vehicles_rectifications__c,
                    Fellow_Training_Confirmation__c,
                    Fellow_Training_Survey_Confirmation__c, // FB-2732
                    Date_Engagement_Confirmed__c // FB-2638
                FROM Climate_Corps_Engagement__c c
                WHERE c.Fellow_Application__c = :fAppId
                ORDER BY CreatedDate DESC LIMIT 1] ; */

            if (lst != null  &&  lst.size() > 0) ccEngagement = lst.get(0);
            System.debug('/n/n ITEMS FOR EDF Engagement ID' + ccEngagement);

        }
        if (ccEngagement != null) {
            if( ccEngagement.Start_Date__c!=null && ccEngagement.CC_Year__c!=null) {
                Date nDate = ccEngagement.Start_Date__c.addDays(14);
                deadlineForDuringFellowship = nDate.month() + '/' + nDate.day()+'/'+ccEngagement.CC_Year__c ;
                if(deadlineForDuringFellowship!=null && deadlineForDuringFellowship.length()>0) {
                    Date dtValue = Date.parse(deadlineForDuringFellowship);
                    DateTime dtVal = DateTime.newInstance( dtValue.year(),  dtValue.month(), dtValue.day());
                    deadlineForDuringFellowship = dtVal.format('MMM d, yyyy');
                }
            }

            if( ccEngagement.End_date__c!=null && ccEngagement.CC_Year__c!=null)  {
                //Changes made by Jayesh(OSI) start
                Date dtValue = ccEngagement.End_date__c;
                if(dtValue !=null) {
                    DateTime dtVal = DateTime.newInstance( dtValue.year(),  dtValue.month(), dtValue.day());
                    deadlineForFellowshipClosure = dtVal.format('MMM d, yyyy');
                }
            }

        }

        return ccEngagement;
    }
    /**
    * Description : This method returns the EngagementAttachments.
    **/
    //Added by Kranthi
    @AuraEnabled(cacheable=true)
    public static  Map<ID, String> getEngagementAttachments(Climate_Corps_Engagement__c ccEngagement) {

        // Get record file IDs
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ccEngagement.Id];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }

        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title
            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND Deleted_By_Fellow__c = false ORDER BY CreatedDate DESC];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }

	/**
    * Description : This method deletes the EngagementAttachments.
    **/
    /* @AuraEnabled
    public static void deleteDocument(String versionId, String documentId){

        System.debug('deleteDocument :: versionId ::' + versionId);
        System.debug('deleteDocument :: documentId ::' + documentId);

        try {
            ContentVersion cv;
            if(versionId!=null && versionId!='') {
                cv = [Select Id,Deleted_By_Fellow__c from ContentVersion WHERE Id =:versionId];
                System.debug('deleteDocument in CV loop :: cv ::' + [Select Id,Deleted_By_Fellow__c from ContentVersion WHERE Id =:documentId]);
            } else if(documentId!=null && documentId!=''){
                cv = [Select Id,Deleted_By_Fellow__c from ContentVersion WHERE ContentDocumentId =:documentId];
                System.debug('deleteDocument in DOC loop :: cv ::' + [Select Id,Deleted_By_Fellow__c from ContentVersion WHERE Id =:versionId]);
            }
            System.debug('deleteDocument outside of IF :: cv ::' + cv);

            if(cv!=null){
                cv.Deleted_By_Fellow__c = true;
                update cv;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } */

	/**
    * Description : This method deletes the EngagementAttachments.
    **/
    @AuraEnabled
    public static void deleteDocument(String versionId, String documentId, String fileName, String enggId, String fellowshipRegion) {

        try {
            if(versionId!=null && versionId!='') {
                deleteDocuments(new List<Id> { versionId }, null);
            }
            else if(documentId!=null && documentId!='') {
                deleteDocuments(null, new List<Id> { documentId });
            }
            updateEngagementForTilesOnSave(null, null, fileName, enggId, fellowshipRegion, true);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    public static void deleteDocuments(List<Id> versionIdList, List<Id> documentIdList) {

        List<ContentVersion> cvList;
        if (versionIdList != null && versionIdList.size() > 0) {
            cvList = [Select Id, Deleted_By_Fellow__c from ContentVersion WHERE Id =:versionIdList];
        }
        else if (documentIdList != null && documentIdList.size() > 0) {
            cvList = [Select Id, Deleted_By_Fellow__c from ContentVersion WHERE ContentDocumentId =:documentIdList];
        }

        if (cvList != null  &&  cvList.size() > 0) {
            for (ContentVersion cv : cvList) {
                cv.Deleted_By_Fellow__c = true;
            }
            update cvList;
        }
    }

	/**
    * Description : This method fetchFiles the EngagementAttachments.
    * Referring this method in edf26_UploadFilePage --Added by Kranthi
    **/

    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentWrapper> fetchFiles(String recordId){
        List<ContentDocumentWrapper> cdWrapperList = new List<ContentDocumentWrapper>();
        List<ContentDocumentLink> cdlList
            = [SELECT Id, LinkedEntityId, ContentDocument.CreatedDate,ContentDocument.LastModifiedDate,
                    ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileType,
                    ContentDocument.LatestPublishedVersion.Deleted_By_Fellow__c,
                    ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId  =:recordId
                    AND ContentDocument.LatestPublishedVersion.Deleted_By_Fellow__c=false
                ORDER BY ContentDocument.LastModifiedDate DESC];
        for(ContentDocumentLink cdl : cdlList){
        cdWrapperList.add(new Engagement_Controller.ContentDocumentWrapper(
                cdl.ContentDocument.LatestPublishedVersionId,
                cdl.Id,
                cdl.ContentDocument.Title,
                cdl.ContentDocument.FileType,
                cdl.ContentDocument.ContentSize,
                cdl.ContentDocument.Title.split(' -')[0],
                cdl.ContentDocument.LastModifiedDate.Date(),
                getTimeLapse(cdl.ContentDocument.LastModifiedDate)
                )
                );
        }
        return cdWrapperList;
    }

    public class ContentDocumentWrapper{
        @AuraEnabled public string versionId;
        @AuraEnabled public string fileId;
        @AuraEnabled public string fileName;
        @AuraEnabled public string fileType;
        @AuraEnabled public Integer contentSize;
        @AuraEnabled public string category;
        @AuraEnabled public Date lastModifiedDt;
        @AuraEnabled public string timeLapse;

         ContentDocumentWrapper(String versionId, string fileId, string fileName, String fileType, Integer contentSize, String category, Date lastModifiedDt, string timeLapse){
            this.versionId = versionId;
            this.fileId = fileId;
            this.fileName = fileName;
            this.fileType = fileType;
            this.contentSize = contentSize;
            this.category = category;
            this.lastModifiedDt = lastModifiedDt;
            this.timeLapse =  timeLapse;
        }

    }

    private static string getTimeLapse(DateTime lastModifiedDt){
        String timeLapse = '';
        Long dt1Long = lastModifiedDt.getTime();
        Long dt2Long = DateTime.now().getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;
        Long days = hours / 24;
        if(days!=0){
        timeLapse = days +' days Ago' ;
        } else if (hours !=0){
        timeLapse = hours +' hours Ago' ;
        } else if (minutes != 0){
        timeLapse = minutes +' minutes Ago' ;
        } else {
        timeLapse = ' < a minutes Ago' ;
        }
        return timeLapse;
    }
    // Declare all attachment variables
    @AuraEnabled
    public static AttachmentResource photoAttachment  {get;set;}
    @AuraEnabled
    public static AttachmentResource workPlanAttachment  {get;set;}
    @AuraEnabled
    public static AttachmentResource onsitePhotoAttachment  {get;set;}
    @AuraEnabled
    public static AttachmentResource onsitePhotoAttachment2  {get;set;}
    @AuraEnabled
    public static AttachmentResource onsitePhotoAttachment3  {get;set;}


    @AuraEnabled
    public static AttachmentResource remainingDeliverablesAttachment{get;set;}
    @AuraEnabled
    public static AttachmentResource projectDataBaseAttachment{get;set;}

    @AuraEnabled
    public static boolean flag{get;set;}
    /**
    * Description : This method updates the enaggement record.
   	**/
    @AuraEnabled
    public static void updateEngagement(Climate_Corps_Engagement__c ccEngagementInput,
            String icItems, String goalSettingItems, String workPlanAttachment, String photoAttachment,
            String personalEmailAddress, String onsitePhotoAttachment, String projectDataBaseAttachment,
            String remainingDeliverablesAttachment, String fellowshipRegion) {

        System.debug('INSIDE updateEngagement :: fellowshipRegion :: ' + fellowshipRegion);
        ccEngagement=ccEngagementInput;

        try {

            if(icItems!=null){
                String selectedCheckboxes = icItems.replace(',',';');
                // System.debug('select checkboxes for icItems--->'+ selectedCheckboxes);
                ccEngagement.Final_Deliverables_Project_Area__c = selectedCheckboxes;
            }

            if(goalSettingItems!=null){
                String goalSettingCheckboxes = goalSettingItems.replace(',',';');
                // System.debug('select checkboxes for icItems--->'+ goalSettingCheckboxes);
                ccEngagement.GHG_Target_Type__c = goalSettingCheckboxes;
            }


            //Change the status of Approval picklist for all fields which require approval from EDF User
            // Now managed using file upload.
            /* if(workPlanAttachment!=null ) {
                ccEngagement.Workplan_Approval__c = 'Pending Approval';
            } */

            String errMsg = validateCCEngagementForSave();
            // system.debug('errMsg'+errMsg);
            if (errMsg != '') {
                //need to add return msg to lwc
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
            }
            else {
                // Update Engagement
                //Code changes Aditi: 07/04/2017 : Check when photo is uploaded.
                if(photoAttachment!=null) {
                    ccEngagement.Photo__c = true;
                }
                // enter the data for checkboxes here
                if (onsitePhotoAttachment!=null) {
                    ccEngagement.Onsite_Photo_Submitted__c = true;
                }

                if (remainingDeliverablesAttachment!=null ) {
                    ccEngagement.Remaining_Deliverables_Submitted__c = true;
                }
                if (projectDataBaseAttachment!=null ) {
                    ccEngagement.Project_Database_Submitted__c= true;
                }
                //Changes Added by Jayesh---Start ----Saving Bio, Twitter Handle and Linkedin Profile on Contact
                // system.debug('ccEngagement.Fellow_Application__r.Applicant__c'+ccEngagement.Fellow_Application__r.Applicant__c);
                Contact fellowContact = new Contact (id = ccEngagement.Fellow_Application__r.Applicant__c);

                if(ccEngagement.Fellow_Application__r.Applicant__c!=null ){

                    if(ccEngagement.Fellow_Application__r.Applicant__r.Bio__c!=null)
                        fellowContact.Bio__c = ccEngagement.Fellow_Application__r.Applicant__r.Bio__c;

                    if(ccEngagement.Fellow_Application__r.Applicant__r.Twitter_Handle__c!=null && !String.isBlank(ccEngagement.Fellow_Application__r.Applicant__r.Twitter_Handle__c))
                        fellowContact.Twitter_Handle__c = ccEngagement.Fellow_Application__r.Applicant__r.Twitter_Handle__c;

                    if(ccEngagement.Fellow_Application__r.Applicant__r.LinkedIn_Profile__c!=null && !String.isBlank(ccEngagement.Fellow_Application__r.Applicant__r.LinkedIn_Profile__c))
                        fellowContact.LinkedIn_Profile__c = ccEngagement.Fellow_Application__r.Applicant__r.LinkedIn_Profile__c;
                }
                // system.debug('fellowContact'+fellowContact);

                // updateEngagementTilesOnSave(ccEngagement, fellowContact); // FB-2575
                updateEngagementForTilesOnSave(ccEngagement, fellowContact, null, null, fellowshipRegion, false);

                update fellowContact;
                System.debug('updateEngagement :: ccEngagement :: ' + ccEngagement);
                Database.Saveresult result = database.update(ccEngagement);
                System.debug('updateEngagement :: result :: ' + result);
                fellowApp =
                    [Select id, Sex__c, Race__c, Applicant__r.FirstName, Applicant__r.LastName,
                     Applicant__c
                     From Fellow_Application__c
                     Where id = :ccEngagement.Fellow_Application__r.Id LIMIT 1];
                // system.debug('fellowApp'+fellowApp);
                Database.Saveresult fellowResult = database.update(fellowApp);
                System.debug('updateEngagement :: fellowResult :: ' + fellowResult);
                System.debug('updateEngagement :: personalEmailAddress :: ' + personalEmailAddress);
                if(personalEmailAddress!=null && !String.isBlank(personalEmailAddress)){
                    savePersonalEmailAddress(fellowApp.Applicant__c,personalEmailAddress);
                }

            }

        }catch (System.DmlException e) {
            String exp ;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                exp = e.getDmlMessage(i);
                break;
            }
            throw new AuraHandledException(exp);
        }
        catch (Exception ex) {
            system.debug('LineNo::'+ex.getLineNumber()+'>>'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String flattenCheckboxData(List<String> checkboxItems) {
        String retVal = '';
        if (checkboxItems != NULL) {
            for (String s : checkboxItems) {
                if (retVal == '') {
                    retVal+=s;
                }
                else {
                    retVal+=';'+s;
                }
            }
        }
        return retVal;
    }
    /**
    * Description : This method thrown an error if required fields are not filled.
   	**/
    @AuraEnabled
    public static String validateCCEngagementForSave() {
        String errMsg = '';
        System.debug('validateCCEngagementForSave :: ccEngagement :: ' + ccEngagement);
        if (ccEngagement.Fellow_Application__c!=null && ccEngagement.Fellow_Application__r.Applicant__c!=null && ccEngagement.Fellow_Application__r.Applicant__r.Bio__c!=null  && ccEngagement.Fellow_Application__r.Applicant__r.Bio__c != null  &&  ccEngagement.Fellow_Application__r.Applicant__r.Bio__c.normalizeSpace().split(' ').size() > 101) {
            errMsg = CustomSettings_Helper.getStudentMessage('ITEMS_FOR_EDF_BIO_100');
        }
        return errMsg;
    }

/*
    private static void savePersonalEmailAddress(Id cId,String personalEmailAddress) {
        List<Contact_Email__c> conEmailList
            = [SELECT Id, Name, Donor__c, Primary__c
                FROM Contact_Email__c
                WHERE Donor__c =: cid
                    AND Type__c = 'Personal'
                    AND Primary__c = false];

        if (conEmailList.size() > 0  &&  !String.isBlank(personalEmailAddress)) {
            conEmailList[0].Email__c = personalEmailAddress;
            update conEmailList;
        }
        else if (!String.isBlank(personalEmailAddress)){
            Contact_Email__c conEmail = new Contact_Email__c();
            conEmail.Donor__c = cid;
            conEmail.Email__c = personalEmailAddress;
            conEmail.Start_Date__c = Date.today();
            conEmail.Primary__c = true; // FB-2268
            conEmail.Type__c = 'Personal';

            insert conEmail;
        }
    } */

    private static void savePersonalEmailAddress(Id cId, String personalEmailAddress) {

        if (!String.isEmpty(personalEmailAddress)) {

            List<Contact_Email__c> conEmailList
                = [SELECT Id, Name, Donor__c, Primary__c, Status__c
                    FROM Contact_Email__c
                    WHERE Donor__c =: cid
                        AND Type__c = 'Personal'
                        AND Email__c = :personalEmailAddress];

            System.debug('savePersonalEmailAddress :: conEmailList :: ' + conEmailList);
            if (conEmailList.size() > 0) {
                conEmailList[0].Primary__c = true;
                conEmailList[0].Status__c = 'Preferred';

                System.debug('savePersonalEmailAddress :: Before Update conEmailList :: ' + conEmailList);
                update conEmailList;
                System.debug('savePersonalEmailAddress :: After Update conEmailList :: ' + [SELECT Id, Name, Donor__c, Primary__c, Status__c
                    FROM Contact_Email__c
                    WHERE Donor__c =: cid
                        AND Type__c = 'Personal'
                        AND Email__c = :personalEmailAddress]);
            }
            else {
                Contact_Email__c conEmail = new Contact_Email__c();
                conEmail.Donor__c = cid;
                conEmail.Email__c = personalEmailAddress;
                // conEmail.Start_Date__c = Date.today();
                conEmail.Primary__c = true; // FB-2268
                conEmail.Type__c = 'Personal';
                conEmail.Status__c = 'Preferred';

                insert conEmail;
            }
        }
    }


    /**
    * Description : This method renames the attachements uploaded by felow.
   	**/
    @AuraEnabled
    public static void renameAttachments(String contVerIds, String fileName, String enggId, String fellowshipRegion) {

        List<Id> contentVersionIdSet =  contVerIds.split(',');
        String fAppYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        if(fAppYear == null || fAppYear == ''){
            fAppYear = '2022';
        }

        // SYSTEM.debug('contentVersionIdSet'+contentVersionIdSet);
        List<ContentVersion> contVerList = [SELECT ID,TITLE,CreatedDate FROM ContentVersion WHERE ID IN:contentVersionIdSet];
        List<ContentVersion> updateContentVersionList = new  List<ContentVersion>();
        for(ContentVersion contVer :contVerList){
            if(contVer.Id!=null){
                contVer.Title
                    = fileName+'_'+fAppYear
                        +'_'+UserInfo.getFirstName()+'_'+UserInfo.getLastName()
                        +'_'+contVer.CreatedDate.year()+'_'+contVer.CreatedDate.month()+'_'+contVer.CreatedDate.day()
                        +'_'+contVer.CreatedDate.hour()+'_'+contVer.CreatedDate.minute()+'_'+contVer.CreatedDate.second(); //fileName+' - '+contVer.Title;
                updateContentVersionList.add(contVer);
            }
        }

        if (!updateContentVersionList.isEmpty() && updateContentVersionList.size()>0){
            Database.update(updateContentVersionList);
        }


        postRenameAttachments(contVerIds, fileName, enggId);
        updateEngagementForTilesOnSave(null, null, fileName, enggId, fellowshipRegion, false);

        // Once document is updated, delete the older files
        ContentVersionTriggerHandler.updateWorkplanApprovalOnDelete = false;
        prepareListForFileDeletion(contentVersionIdSet, fileName, fAppYear, enggId);

    }


    private static void postRenameAttachments(String contVerIds, String fileName, String enggId) {
        updateEngagementOnFileUpload(fileName, enggId);
    }

    /**
     * Set additional fields for Deliverable Trackers to set based files uploaded to Engagement
     * FB-2575
     */
    private static void updateEngagementOnFileUpload(String fileName, String enggId) {

        // This method would be utilized later to update specific fields on Engagement based on when files are uploaded from Portal Deliverables page.
        /* if (fileName == CONSTT.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX) {
            Climate_Corps_Engagement__c ccEngagement = new Climate_Corps_Engagement__c(Id=enggId, Submit_Workplan__c = true);
            update ccEngagement;
        }
        else */ if (fileName == CONSTT.CC_ENGAGEMENT_PHOTO_FILE_TITLE_PREFIX) {
            Climate_Corps_Engagement__c ccEngagement = new Climate_Corps_Engagement__c(Id=enggId, Photo__c = true);
            update ccEngagement;
        }
        /* else if (fileName == CONSTT.CC_ENGAGEMENT_PHOTO_RELEASE_FILE_TITLE_PREFIX) {

            Climate_Corps_Engagement__c ccEngagement
                = [SELECT Id, Photo__c, Media_Profile__c
                    FROM Climate_Corps_Engagement__c
                    WHERE Id = :enggId];

            if (ccEngagement != null  &&  ccEngagement.Photo__c) {
                ccEngagement.Media_Profile__c = true;
                update ccEngagement;
            }
        }
        else if (fileName == CONSTT.CC_ENGAGEMENT_ACTIVITY_REPORT_FILE_TITLE_PREFIX
                ||  fileName == CONSTT.CC_ENGAGEMENT_FINAL_DELIVERABLES_FILE_TITLE_PREFIX) {

            Climate_Corps_Engagement__c ccEngagement
                = [SELECT Id, Photo__c, Fellow_Initials__c, Project_Database_Submitted__c,
                        Remaining_Deliverables_Submitted__c
                    FROM Climate_Corps_Engagement__c
                    WHERE Id = :enggId];

            if (ccEngagement != null
                    &&  ccEngagement.Fellow_Initials__c != null
                    &&  ccEngagement.Project_Database_Submitted__c != null
                    &&  ccEngagement.Remaining_Deliverables_Submitted__c != null) {
                ccEngagement.Submit_Final_Deliverables__c = true;
                update ccEngagement;
            }
        } */
        else if (fileName == CONSTT.CC_ENGAGEMENT_ACTIVITY_REPORT_FILE_TITLE_PREFIX) {
            Climate_Corps_Engagement__c ccEngagement = new Climate_Corps_Engagement__c(Id=enggId, Project_Database_Submitted__c = true);
            update ccEngagement;
        }
        else if (fileName == CONSTT.CC_ENGAGEMENT_FINAL_DELIVERABLES_FILE_TITLE_PREFIX) {
            Climate_Corps_Engagement__c ccEngagement = new Climate_Corps_Engagement__c(Id=enggId, Remaining_Deliverables_Submitted__c = true);
            update ccEngagement;
        }
    }

    /**
     * Set additional fields for Deliverable Trackers to set based on other fields set on Engagement
     * FB-2575
     */
    /* private static void updateEngagementTilesOnSave(Climate_Corps_Engagement__c ccEngagement, Contact cont) {

        if (ccEngagement.Start_Date__c != null  &&  ccEngagement.End_date__c != null) {
            ccEngagement.Submit_Start_End_dates__c = true;
        }
        if (ccEngagement.Fellow_Training_Confirmation__c != null  &&  ccEngagement.Fellow_Training_Survey_Confirmation__c != null) {
            ccEngagement.Complete_Post_Training_Items__c = true;
        }
        if (ccEngagement.Fellow_Initials__c != null  &&  ccEngagement.Project_Database_Submitted__c != null  &&  ccEngagement.Remaining_Deliverables_Submitted__c != null) {
            ccEngagement.Submit_Final_Deliverables__c = true;
        }

    } */


    private static void updateEngagementForTilesOnSave(Climate_Corps_Engagement__c ccEngagement, Contact cont, String fileName, String enggId, String fellowshipRegion, Boolean isFileDeleted) {
        System.debug('Inside updateEngagementForTilesOnSave :: fileName :: ' + fileName + ' --- enggId = ' + enggId);
        // String automation = 'FILE:Workplan';
        // String fieldToMark = 'Submit_Workplan__c';

        // String automation = 'FIELD:Start_Date__c AND FIELD:End_date__c';
        // String fieldToMark = 'Submit_Start_End_dates__c';

        // String automation = 'FIELD:Fellow_Initials__c AND FIELD:Project_Database_Submitted__c AND FIELD:Remaining_Deliverables_Submitted__c';
        // String fieldToMark = 'Submit_Final_Deliverables__c';

        // String automation = 'FILE:PhotoReleaseForm AND FIELD:Photo__c'; // TODO: Photo Needs to be set on Onsite Photo Upload only rather than on Saving
        // String fieldToMark = 'Media_Profile__c';

        // For fileName, fetch all ItemsForEDF Tiles where Automated contains 'FILE:${fileName}'

        // For other scenario, fetch all ItemsForEDF that has a value in Automated but contain only 'FIELD:'


        String itemsForEDFCondition = '%';
        if (fileName != null) {
            itemsForEDFCondition += fileName + '%';
        }
        System.debug('Inside updateEngagementForTilesOnSave :: itemsForEDFCondition :: ' + itemsForEDFCondition);

        Map<Id, ItemsforEDF__mdt> itemsMap
            = new Map<Id, ItemsforEDF__mdt>(
                [SELECT Id, Done_Condition__c, Undo_Done__c, Mapping_Field__c
                    FROM ItemsforEDF__mdt
                    WHERE Done_Condition__c LIKE :itemsForEDFCondition
                        AND Fellowship__c = :fellowshipRegion]);
        System.debug('Inside updateEngagementForTilesOnSave :: itemsMap :: ' + itemsMap);


        Climate_Corps_Engagement__c ccEngagementToCheck;
        Map<Id, Boolean> meetsCond = new Map<Id, Boolean>();
        Map<Id, List<String>> fieldsToFetchMap = new Map<Id, List<String>>();
        Set<String> uniqueFieldsToFetch = new Set<String>();

        for (ItemsforEDF__mdt item : itemsMap.values()) {

            String automation = item.Done_Condition__c;
            // String fieldToMark = item.Mapping_Field__c;

            List<String> fieldsToFetch = new List<String>();
            Boolean meetsCondition = true;

            List<String> fieldsToCheck = automation.split(' AND ');
            System.debug('Inside updateEngagementForTilesOnSave :: fieldsToCheck :: ' + fieldsToCheck);

            for (String fieldToChk : fieldsToCheck) {
                System.debug('Inside updateEngagementForTilesOnSave :: fieldToChk :: ' + fieldToChk);
                if (fieldToChk.startsWith('FILE:')  &&  fileName != null) {
                    if (fieldToChk.replace('FILE:', '') == fileName) meetsCondition = meetsCondition && true;
                    else meetsCondition = meetsCondition && false;
                }
                else if (fieldToChk.startsWith('FIELD:')) {
                    fieldsToFetch.add(fieldToChk.replace('FIELD:', ''));
                    uniqueFieldsToFetch.add(fieldToChk.replace('FIELD:', ''));
                }
                else meetsCondition = meetsCondition && false;
                System.debug('Inside updateEngagementForTilesOnSave :: meetsCondition :: ' + meetsCondition);
            }

            if (fieldsToFetch.size() > 0) fieldsToFetchMap.put(item.Id, fieldsToFetch);
            meetsCond.put(item.Id, meetsCondition);
        }

        if (uniqueFieldsToFetch.size() > 0) {
            if (enggId == null) enggId = ccEngagement.Id;
            String qry = 'SELECT Id, ' + String.join(new List<String>(uniqueFieldsToFetch), ', ') + ' FROM Climate_Corps_Engagement__c WHERE Id = :enggId';
            System.debug('Inside updateEngagementForTilesOnSave :: qry :: ' + qry);
            ccEngagementToCheck = ((Climate_Corps_Engagement__c) Database.query(qry));
            System.debug('Inside updateEngagementForTilesOnSave :: ccEngagementToCheck :: ' + ccEngagementToCheck);
        }

        if (meetsCond.size() > 0) {
            Climate_Corps_Engagement__c ccEngagementToUpdate = new Climate_Corps_Engagement__c(Id=enggId);
            Boolean anyFieldSet = false;

            for (Id itemId : meetsCond.keySet()) {
                Boolean meetsCondition = meetsCond.get(itemId);
                if (meetsCondition) {
                    List<String> fieldsToFetch = fieldsToFetchMap.get(itemId);
                    if (fieldsToFetch != null  &&  fieldsToFetch.size() > 0) {
                        System.debug('Inside updateEngagementForTilesOnSave :: fieldsToFetch :: ' + fieldsToFetch);
                        for (String fieldFetched : fieldsToFetch) {
                            System.debug('Inside updateEngagementForTilesOnSave :: ccEngagementToCheck.get(${fieldFetched}) :: ' + ccEngagementToCheck.get(fieldFetched));
                            meetsCondition = meetsCondition && checkEngagementValue(ccEngagementToCheck, ccEngagement, fieldFetched);
                            System.debug('Inside updateEngagementForTilesOnSave :: meetsCondition :: ' + meetsCondition);
                        }
                    }
                    String fieldToMark = itemsMap.get(ItemId).Mapping_Field__c;
                    System.debug('Inside updateEngagementForTilesOnSave :: fieldToMark :: ' + fieldToMark);
                    System.debug('Inside updateEngagementForTilesOnSave :: meetsCondition :: ' + meetsCondition);
                    if (meetsCondition  &&  !isFileDeleted) { // To handle all FIELD: and FILE: conditions meeting the criteria without the delete
                        ccEngagementToUpdate.put(fieldToMark, true);
                        anyFieldSet = true;
                    }
                    else if (meetsCondition  &&  isFileDeleted  &&  itemsMap.get(ItemId).Undo_Done__c) { // To handle FILE: delete conditions meeting the criteria
                        ccEngagementToUpdate.put(fieldToMark, false);
                        anyFieldSet = true;
                    }
                    else if (!meetsCondition  &&  itemsMap.get(ItemId).Undo_Done__c) { // To handle FIELD: conditions NOT meeting the criteria
                        ccEngagementToUpdate.put(fieldToMark, false);
                        anyFieldSet = true;
                    }
                }
            }
            System.debug('Inside updateEngagementForTilesOnSave :: BEFORE UPDATE :: ccEngagementToUpdate :: ' + ccEngagementToUpdate);
            if (anyFieldSet) update ccEngagementToUpdate;
            System.debug('Inside updateEngagementForTilesOnSave :: AFTER UPDATE :: ccEngagementToUpdate :: ' + ccEngagementToUpdate);
        }


    }

    private static Boolean checkEngagementValue(Climate_Corps_Engagement__c ccEngagementToCheck, Climate_Corps_Engagement__c ccEngagement, String fieldToCheck) {
        Schema.DisplayType fieldDataType = Schema.SObjectType.Climate_Corps_Engagement__c.fields.getMap().get(fieldToCheck).getDescribe().getType();

        Boolean hasValue = true;
        System.debug('Inside checkEngagementValue :: ccEngagementToCheck :: ' + ccEngagementToCheck);
        System.debug('Inside checkEngagementValue :: ccEngagement :: ' + ccEngagement);
        System.debug('Inside checkEngagementValue :: fieldToCheck :: ' + fieldToCheck);

        try {
            if (fieldDataType == Schema.DisplayType.BOOLEAN) {
                if ( ( ((Boolean)ccEngagement.get(fieldToCheck)) == true)  ||  (!ccEngagement.isSet(fieldToCheck)  &&  ccEngagementToCheck != null  &&  ((Boolean)ccEngagementToCheck.get(fieldToCheck)) == true)) hasValue = hasValue && true;
                else hasValue = hasValue && false;
            }
            else /* if (fieldDataType == Schema.DisplayType.STRING) */ {
                /* if (ccEngagementToCheck.get(fieldToCheck) != null) {
                    hasValue = hasValue && true;
                }
                else if (!ccEngagementToCheck.containsKey(fieldToCheck)  &&  ccEngagement != null  &&  ccEngagement.get(fieldToCheck) != null) {
                    hasValue = hasValue && true;
                }
                else {
                    hasValue = hasValue && false;
                } */

                System.debug('Inside checkEngagementValue :: ccEngagementToCheck.get(fieldToCheck) :: ' + ccEngagementToCheck.get(fieldToCheck));
                System.debug('Inside checkEngagementValue :: !ccEngagementToCheck.isSet(fieldToCheck) :: ' + !ccEngagementToCheck.isSet(fieldToCheck));
                System.debug('Inside checkEngagementValue :: ccEngagement.get(fieldToCheck) :: ' + ccEngagement.get(fieldToCheck));
                System.debug('Inside checkEngagementValue :: (ccEngagement.get(fieldToCheck) != null) :: ' + (ccEngagement.get(fieldToCheck) != null));
                System.debug('Inside checkEngagementValue :: ((ccEngagement.get(fieldToCheck) != null)  ||  (!ccEngagement.isSet(fieldToCheck)  &&  ccEngagementToCheck != null  &&  ccEngagementToCheck.get(fieldToCheck) != null)) :: ' + ((ccEngagement.get(fieldToCheck) != null)  ||  (!ccEngagement.isSet(fieldToCheck)  &&  ccEngagementToCheck != null  &&  ccEngagementToCheck.get(fieldToCheck) != null)));
                if (( String.isNotBlank((String)ccEngagement.get(fieldToCheck)) )  ||  (!ccEngagement.isSet(fieldToCheck)  &&  ccEngagementToCheck != null  &&  String.isNotBlank((String)ccEngagementToCheck.get(fieldToCheck)) ))  hasValue = hasValue && true;
                else hasValue = hasValue && false;
            }

        }
        catch (Exception e) {

        }


        /* try {
            if ( ((Boolean)ccEngagementToCheck.get(fieldToCheck)) == true) hasValue = hasValue && true;
            else hasValue = hasValue && false;
        }
        catch (Exception e) {

        } */
        System.debug('Inside checkEngagementValue :: hasValue :: ' + hasValue);
        return hasValue;
    }


    private static void prepareListForFileDeletion(List<Id> cvIdSetBeingSaved, String fileName, String fAppYear, String enggId) {

        // No file deletion for Final Deliverables
        if (fileName == CONSTT.CC_ENGAGEMENT_FINAL_DELIVERABLES_FILE_TITLE_PREFIX) return;

        // Get record file IDs
        List<ID> fileIDs = new List<ID>();
        Integer maxFilesForOnsitePhotos = 3;
        for (ContentDocumentLink docLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :enggId]) {
            fileIDs.add(docLink.ContentDocumentId);
        }

        List<ContentVersion> cvList
            = [SELECT ContentDocumentId, FileExtension, Title
                FROM ContentVersion
                WHERE ContentDocumentId IN : fileIDs
                    AND Id NOT IN :cvIdSetBeingSaved
                    AND Deleted_By_Fellow__c = false
                ORDER BY CreatedDate DESC];

        System.debug('prepareListForFileDeletion :: cvList.size() :: ' + cvList.size());
        System.debug('prepareListForFileDeletion :: cvIdSetBeingSaved.size() :: ' + cvIdSetBeingSaved.size());
        System.debug('prepareListForFileDeletion :: fileName :: ' + fileName);
        // Only delete files for Non-Onsite Photo.
        // Delete files for Non-Onsite photos only if number of non-deleted photos is more than 3, including photos just uploaded
        if ( (fileName != CONSTT.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX)
                ||  (fileName == CONSTT.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX
                    && cvList.size() + cvIdSetBeingSaved.size() > CONSTT.MAX_FILES_ONSITE_PHOTOS) ) {

            Set<Id> cDocToBeDeleted = new Set<Id>();
            Integer ctr = cvIdSetBeingSaved.size();
            for (ContentVersion cv : cvList) {

                /*
                * It is important to include CCYear as well so that we do not end up deleting previous year's files.
                */
                if (cv.Title.startsWith ( fileName+'_'+fAppYear+'_'+UserInfo.getFirstName()+'_'+UserInfo.getLastName()+'_' ) ) {

                    System.debug('prepareListForFileDeletion :: fileName :: ' + fileName);
                    System.debug('prepareListForFileDeletion :: CONSTT.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX :: ' + CONSTT.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX);
                    System.debug('prepareListForFileDeletion :: fileName == CONSTT.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX :: ' + (fileName == CONSTT.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX));
                    if (fileName == CONSTT.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX) {
                        System.debug('prepareListForFileDeletion :: ctr :: ' + ctr);
                        if (ctr >= CONSTT.MAX_FILES_ONSITE_PHOTOS) {
                            cDocToBeDeleted.add(cv.ContentDocumentId);
                        }
                        ctr++;
                    }
                    else {
                        System.debug('prepareListForFileDeletion :: adding to cDocToBeDeleted :: ');
                        cDocToBeDeleted.add(cv.ContentDocumentId);
                    }
                }
            }
            System.debug('prepareListForFileDeletion :: cDocToBeDeleted.size() :: ' + cDocToBeDeleted.size());
            if (cDocToBeDeleted.size() > 0) deleteDocuments(null, (new List<Id>(cDocToBeDeleted)));
        }
    }

    /**
    * Description : This method updates the engegment record from portal deliverbles page.
   	**/
    @AuraEnabled
    public static void updateFellowEngagement(String fieldAPIName, Boolean isContactField, String engagementId, String contactId) {
        System.debug('INSIDE updateFellowEngagement');
        if (isContactField) {
            fieldAPIName = fieldAPIName + '__c';
            System.debug('SELECT Id, ' + String.escapeSingleQuotes(fieldAPIName)
                    + ' FROM Contact '
                    + ' WHERE Id = \'' + String.escapeSingleQuotes(contactId) + '\'');
            Contact cont
                = (Contact) Database.query(
                    'SELECT Id, ' + String.escapeSingleQuotes(fieldAPIName)
                    + ' FROM Contact '
                    + ' WHERE Id = \'' + String.escapeSingleQuotes(contactId) + '\'');

            if (cont.get(fieldAPIName) == false) cont.put(fieldAPIName, true);
            else cont.put(fieldAPIName, false);
            update cont;
        }
        else {
            Climate_Corps_Engagement__c engg
                = (Climate_Corps_Engagement__c) Database.query(
                    'SELECT Id, ' + String.escapeSingleQuotes(fieldAPIName)
                    + ' FROM Climate_Corps_Engagement__c '
                    + ' WHERE Id = \'' + String.escapeSingleQuotes(engagementId) + '\'');

            if (engg.get(fieldAPIName) == false) engg.put(fieldAPIName, true);
            else engg.put(fieldAPIName, false);
            update engg;
        }
    }




    @AuraEnabled
    public static void updateFieldValue(
        string updateRecordId,
        string fieldName,
        string fieldVal,
        string ObjectName,
        boolean isFieldBoolean
    ) {
        boolean convertedBoolean;
        if (updateRecordId != null) {
            List<sObject> updateStatus = new List<sObject>();
            String sQuery = 'select ' + fieldName + ' from ' + ObjectName + ' Where Id =:updateRecordId';
            List<sObject> lstOfRecords = Database.query(sQuery);
            for (sObject obj : lstOfRecords) {
                if (isFieldBoolean) {
                    convertedBoolean = Boolean.valueOf(fieldVal);
                    obj.put(fieldName, convertedBoolean);
                } else {
                    obj.put(fieldName, fieldVal);
                }
                updateStatus.add(obj);
            }
            if (!updateStatus.isEmpty()) {
                update updateStatus;
            }
        }
    }


    /**
    * Description : This method return the Deliverables Tracker Tile dates to be displayed on Portal Deliverables page
    * @param fellowshipApplyingFor: Which region fellowship data to be fetched.
    * @param enggId: Engagement records for dynamic dates like Engagement Confirmation Date, Engagement End Date etc..
    **/
    @AuraEnabled( cacheable=true )
    public static Map<String, Date> fetchDeliverableDates(String fellowshipApplyingFor, String enggId) {

        List < PortalDeliverablesAndTilesDateMapping__mdt > dateMappingsList
            = EDF02_CustomMetadata_Helper.fetchPortalDeliverablesAndTilesDateMapping(fellowshipApplyingFor);
        System.debug('fetchPortalDeliverablesAndTilesDateMapping :: dateMappingsList :::' + dateMappingsList);

        // Key: Portal Deliverables field Identifier
        // Value: Actual Date
        Map<String, Date> datesMap = new Map<String, Date>();
        Climate_Corps_Engagement__c ccEngg = null;
        Set<String> dateFieldAPINames = new Set<String>();

        // Check if there are any Dynamic Dates
        for (PortalDeliverablesAndTilesDateMapping__mdt dateMapping : dateMappingsList) {
            if ((dateMapping.Deliverable_Tracker_Tile__c != null)  &&  (dateMapping.Deliverable_Tracker_Tile__r.Due_Date_Field__c != null)) {
                if (dateFieldAPINames == null) dateFieldAPINames = new Set<String>();
                dateFieldAPINames.add(dateMapping.Deliverable_Tracker_Tile__r.Due_Date_Field__c);
            }
        }

        // If there are Dynamic Dates, fetch data from CC Engagement records for those dates.
        if (dateFieldAPINames != null  &&  dateFieldAPINames.size() > 0) {
            String fieldsToQuery = '';
            for (String fieldAPIName : dateFieldAPINames) {
                if (fieldsToQuery != '') fieldsToQuery += ', ';
                fieldsToQuery += fieldAPIName;
            }
            String qry = 'SELECT ' + fieldsToQuery + ' FROM Climate_Corps_Engagement__c WHERE Id = \'' + enggId + '\'';
            List<Climate_Corps_Engagement__c> lstOfRecords = (List<Climate_Corps_Engagement__c>) Database.query(qry);
            if (lstOfRecords != null  &&  lstOfRecords.size() > 0) ccEngg = lstOfRecords[0];
        }

        // Iterate through the entries to populate 'datesMap'
        for (PortalDeliverablesAndTilesDateMapping__mdt dateMapping : dateMappingsList) {

            Date dt = null;

            if (dateMapping.Deliverable_Tracker_Tile__c != null) {
                // If it is Dynamic Date, pick data from CC Engagement record
                if (dateMapping.Deliverable_Tracker_Tile__r.Due_Date_Field__c != null) {
                    try {
                        dt = (Date) ccEngg.get(dateMapping.Deliverable_Tracker_Tile__r.Due_Date_Field__c);

                        // If there is a date offset, adjust the date
                        if (dateMapping.Deliverable_Tracker_Tile__r.Due_Date_Field_Offset__c != null) {
                            dt = dt.addDays((Integer) dateMapping.Deliverable_Tracker_Tile__r.Due_Date_Field_Offset__c);
                            System.debug(dt);
                        }
                    }
                    catch (Exception e) {
                        dt = null;
                    }
                }
                else {
                    // If no Dynamic date, pick up date from the Tile
                    dt = dateMapping.Deliverable_Tracker_Tile__r.Due_Date__c;
                }
            }
            datesMap.put(dateMapping.Portal_Deliverables_Field__c, dt);
        }
        System.debug('fetchPortalDeliverablesAndTilesDateMapping :: datesMap :::' + datesMap);

        // Return dates map
        return datesMap;
    }


    // TODO: Push this to a Utility class
    public static String getSelectFields(SObjectType sObjType, List<String> addlSelectFields) {
        Schema.DescribeSObjectResult describe = sObjType.getDescribe();
        Map<String, Schema.SObjectField> fields = describe.fields.getMap();

        String retVal = '';
        for(Schema.sObjectField fld : fields.values()) {
            System.debug(fld);
            if (retVal != '') retVal += ', ';
            retVal += '' + fld;
        }

        if (addlSelectFields != null) {
            for(String fld : addlSelectFields) {
                System.debug(fld);
                if (retVal != '') retVal += ', ';
                retVal += fld;
            }
        }

        return retVal;
    }

}