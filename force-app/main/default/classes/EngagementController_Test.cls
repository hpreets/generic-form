/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 1/31/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: Test class for Engagement_Controller
# Change Log:
#
#
############################################################################
*/


@isTest
public class EngagementController_Test {

    // public static String email = 'someone@abc.bix';
    // public static String fellowshipYear = '' + System.today().year();

    public static Constants constt = Constants.getAllConstants();
    public static String FELLOWSHIP_REGION = constt.FELLOWSHIP_REGION_PICKLIST_US;
    public static Map<String, String> staticTestData = new Map<String, String> {
                'email' => 'someone@abc.bix',
                'firstName' => 'Harpreet',
                'lastName' => 'Singh',
                'fellowshipYear' => ('' + System.today().year())
            };

    @testsetup
    public static void createTestData() {
        createCustomSettingData();
        createBusinessData();
    }
    static testMethod void testCreateContact() {

        Contact c = TestFactory.retrieveContact(null, null, null);

        // Climate_Corps_Engagement__c ce = TestFactory.retrieveEngagement(null, null, null);
        Climate_Corps_Engagement__c ceRecord = TestFactory.retrieveEngagement(
            null,
            new List<String> {
                'Fellow_Application__r.Applicant__c',
                'Fellow_Application__r.Applicant__r.Bio__c',
                'Fellow_Application__r.Applicant__r.Twitter_Handle__c',
                'Fellow_Application__r.Applicant__r.LinkedIn_Profile__c'
            },
            null);

        ContentVersion cv = TestFactory.retrieveContentVersion(null, null, null);
        Id conDocId = cv.ContentDocumentId;
        ContentDocumentLink cdl = TestFactory.retrieveContentDocumentLink(new Map<String, Object> {
                'LinkedEntityId' => '\'' + ceRecord.Id + '\'',
                'ContentDocument.LatestPublishedVersion.Deleted_By_Fellow__c' => false
            }, null, null);

        User u = TestFactory.retrieveUser(new Map<String, Object> {
                'Email' => '\'' + staticTestData.get('email') + '\''
            }, null, null);
        System.debug('User ::' + u);

        System.runAs(u){
            Test.startTest();
            Engagement_Controller.getFellowEngagementEDF();
            EDF02_CustomMetadata_Helper.fetchEDFItemsForFellowship(FELLOWSHIP_REGION);
            Engagement_Controller.getEngagementAttachments(ceRecord);
            Engagement_Controller.validateCCEngagementForSave();

            //Convert the id into string since the methods expecting id as string
            String ccId = Id.valueOf(ceRecord.Id); // climate corps Id
            // String ccIdafterQuery  = Id.valueOf(ceRecord.id);
            String conId = Id.valueOf(c.Id); // Contact Id
            String contentDocumnetLinkId = Id.valueOf(cdl.Id); // contentDocumnetLinkId
            String contentVersionId = Id.valueOf(cv.id); //contentVersionId
            Engagement_Controller.updateFellowEngagement('Orientation_Webinar__c', false, ccId, conId);
			Engagement_Controller.updateFellowEngagement('Kilowatt_Signup__c', false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Reviewed_Work_Authorization__c', false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Reviewed_HR_Webinar__c', false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Registered_for_Training__c', false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('CompleteTrainingPreWork__c',false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Requested_Mentor__c', false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Training_Info_Survey__c', false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Submit_Start_End_dates__c',false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Submit_Workplan__c',false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Submit_Workplan__c',false, ccId, conId); // To test value being set to False
            Engagement_Controller.updateFellowEngagement('Media_Profile__c',false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Submit_Final_Deliverables__c',false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('Complete_Post_Training_Items__c',false, ccId, conId);
            Engagement_Controller.updateFellowEngagement('CC_Alumni_Group_Member', true, ccId, conId);
            Engagement_Controller.updateFellowEngagement('CC_Alumni_Group_Member', true, ccId, conId); // To test value being set to False
            Engagement_Controller.updateFellowEngagement('On_EDF_Connect_Platform', true, ccId, conId);

           	Engagement_Controller.updateEngagement(ceRecord,'Solar and/or Wind','Absolute goals or targets','ced','def','someone@abc.bix','efg','fgh','ghi', FELLOWSHIP_REGION);
            Engagement_Controller.fetchFiles(ccId);
            Engagement_Controller.renameAttachments(contentVersionId, constt.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX, ccId, FELLOWSHIP_REGION);
            Engagement_Controller.deleteDocument(contentVersionId,conDocId, null, null, null);
            Engagement_Controller.deleteDocument(null,conDocId, null, null, null);
            Engagement_Controller.updateFieldValue(ccId, 'Project_Database_Submitted__c', 'true', 'Climate_Corps_Engagement__c', true);
            Engagement_Controller.updateFieldValue(ccId, 'Engagement_Notes__c', '123', 'Climate_Corps_Engagement__c', false);

            Test.stopTest();

            AttachmentResource ar;
            ar = Engagement_Controller.projectDataBaseAttachment;
            ar = Engagement_Controller.remainingDeliverablesAttachment;
            ar = Engagement_Controller.onsitePhotoAttachment3;
            ar = Engagement_Controller.onsitePhotoAttachment2;
            ar = Engagement_Controller.onsitePhotoAttachment;
            ar = Engagement_Controller.workPlanAttachment;
            ar = Engagement_Controller.photoAttachment;

            Boolean flag = Engagement_Controller.flag;
            Fellow_Application__c fa = Engagement_Controller.fellowApp;
            String deadline = Engagement_Controller.deadlineForPreFellowship;

            System.assertEquals(Engagement_Controller.flattenCheckboxData(new List<String> { 'Text1', 'Text2', 'Text3'}), 'Text1;Text2;Text3');

            Engagement_Controller.fetchDeliverableDates('U.S. Fellowship', ceRecord.id);
        }

        TestFactory.updateContentVersion(Id.valueOf(cv.id),
            new Map<String, Object> {
                'Title' => constt.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX + '_' + staticTestData.get('fellowshipYear') + '_' + staticTestData.get('firstName') + '_' + staticTestData.get('lastName') + '_' +System.today().year()+'_'+System.today().month()+'_'+System.today().day()+'_'+System.now().hour()+'_'+System.now().minute()+'_'+System.now().second()
            }, true);

    }


    static testMethod void testSavePersonalEmailAddress() {

        Contact c = TestFactory.retrieveContact(null, null, null);

        // Climate_Corps_Engagement__c ce = TestFactory.retrieveEngagement(null, null, null);
        Climate_Corps_Engagement__c ceRecord = TestFactory.retrieveEngagement(
            null,
            new List<String> {
                'Fellow_Application__r.Applicant__c',
                'Fellow_Application__r.Applicant__r.Bio__c',
                'Fellow_Application__r.Applicant__r.Twitter_Handle__c',
                'Fellow_Application__r.Applicant__r.LinkedIn_Profile__c'
            },
            null);

        User u = TestFactory.retrieveUser(new Map<String, Object> {
                'Email' => '\'' + staticTestData.get('email') + '\''
            }, null, null);
        System.debug('User ::' + u);

        System.runAs(u){
            Test.startTest();
            Engagement_Controller.getFellowEngagementEDF();

            // Test validateCCEngagementForSave
            Climate_Corps_Engagement__c ccEngagement = Engagement_Controller.ccEngagement;
            EDF02_CustomMetadata_Helper.fetchEDFItemsForFellowship('U.S. Fellowship');
            ccEngagement.Fellow_Application__r.Applicant__r.Bio__c = '';
            for (Integer ctr = 0; ctr < 150; ctr++) {
                ccEngagement.Fellow_Application__r.Applicant__r.Bio__c += 'Text ';
            }
            Engagement_Controller.validateCCEngagementForSave();
            ccEngagement.Fellow_Application__r.Applicant__r.Bio__c = 'Bio';

            // Test savePersonalEmailAddress
           	Engagement_Controller.updateEngagement(ceRecord,'Solar and/or Wind','Absolute goals or targets','ced','def','someone.1@abc.bix','efg','fgh','ghi', FELLOWSHIP_REGION);

            Test.stopTest();
        }
    }


    static testMethod void testOnsitePhotoAttachment() {

        Contact c = TestFactory.retrieveContact(null, null, null);

        // Climate_Corps_Engagement__c ce = TestFactory.retrieveEngagement(null, null, null);
        Climate_Corps_Engagement__c ceRecord = TestFactory.retrieveEngagement(
            null,
            new List<String> {
                'Fellow_Application__r.Applicant__c',
                'Fellow_Application__r.Applicant__r.Bio__c',
                'Fellow_Application__r.Applicant__r.Twitter_Handle__c',
                'Fellow_Application__r.Applicant__r.LinkedIn_Profile__c'
            },
            null);

        ContentVersion cv = TestFactory.retrieveContentVersion(new Map<String, Object> {
                'Title' => '\'' + constt.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX + '%\''
            }, null, null);
        Id conDocId = cv.ContentDocumentId;
        ContentDocumentLink cdl = TestFactory.retrieveContentDocumentLink(new Map<String, Object> {
                'LinkedEntityId' => '\'' + ceRecord.Id + '\'',
                'ContentDocument.LatestPublishedVersion.Deleted_By_Fellow__c' => false
            }, null, null);

        User u = TestFactory.retrieveUser(new Map<String, Object> {
                'Email' => '\'' + staticTestData.get('email') + '\''
            }, null, null);
        System.debug('User ::' + u);

        System.runAs(u){
            Test.startTest();
            Engagement_Controller.getFellowEngagementEDF();

            // Test validateCCEngagementForSave
            Engagement_Controller.renameAttachments(cv.Id, constt.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX, ceRecord.Id, FELLOWSHIP_REGION);

            Test.stopTest();
        }
    }

    public static void createCustomSettingData() {
        List<RecordId__c> recordIdCustomSetting = new List<RecordId__c>();
        if(RecordId__c.getAll().get('DefaultOwnerId') == NULL){
            recordIdCustomSetting.add(new RecordId__c(name = 'DefaultOwnerId',IdValue__c = string.valueOf(UserInfo.getUserId())));
        }
        if(recordIdCustomSetting.size()>0){
            insert recordIdCustomSetting;
        }

        List<EDFCCGlobal__c> EDFCCglobalCustomSetting = new List<EDFCCGlobal__c>();
        if(EDFCCGlobal__c.getAll().get('CurrentFellowshipYear') == NULL){
            EDFCCglobalCustomSetting.add(new EDFCCGlobal__c(name = 'CurrentFellowshipYear', Value__c = staticTestData.get('fellowshipYear') ));
        }
        if(EDFCCglobalCustomSetting.size()>0){
            insert EDFCCglobalCustomSetting;
        }
    }

    public static void createBusinessData() {
        Account a = TestFactory.createAccount('Test Account',
            new Map<String, Object> {
                'OwnerId' => CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')
            },
            true);
        Contact c = TestFactory.createContact(a.Id, 'TestLN',
            new Map<String, Object> {
                'FirstName' => 'TestFN',
                'Email' => 'someone@abc.bix',
                'Phone' => '9876543210',
                'MailingStreet' => 'Street',
                'MailingCity' => 'New Delhi',
                'MailingState' => 'Delhi',
                'MailingCountry' => 'India',
                'MailingPostalCode' => '110060',
                'Twitter_Handle__c' => '@twitter',
                'LinkedIn_Profile__c' => 'LinkedIn',
                'Bio__c' => 'test'
            },
            true );
        Contact_Email__c conEmail = TestFactory.createContactEmail(c.id,
            new Map<String, Object> {
                'Type__c' => 'personaal',
                'Primary__c' => false
            },
            true);

        Fellow_Application__c fa = TestFactory.createFellowApplication(c.Id,
            new Map<String, Object> {
                'Status__c' => 'Engagement Confirmed',
                'CC_Year__c' => staticTestData.get('fellowshipYear')
            },
            true);
        Climate_Corps_Engagement__c ce = TestFactory.createEngagement('OSI DEV, 2022',
            new Map<String, Object> {
                'Fellow_Application__c' => fa.id,
                'CC_Year__c' => staticTestData.get('fellowshipYear')
            },
            true);
        Climate_Corps_Engagement__c ceRecord = TestFactory.retrieveEngagement(null, null, null);



        ContentVersion cv = TestFactory.createContentVersion(
            new Map<String, Object> {
                'Title' => constt.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX + '_' + staticTestData.get('fellowshipYear') + '_' + staticTestData.get('firstName') + '_' + staticTestData.get('lastName') + '_'
            }, true);
        ContentDocumentLink cdl = TestFactory.createContentDocumentLink(cv, null, ce.Id, null, true);


        // Second file for testing Deletion scenario
        ContentVersion cv1 = TestFactory.createContentVersion(
            new Map<String, Object> {
                'Title' => constt.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX + '_' + staticTestData.get('fellowshipYear') + '_' + staticTestData.get('firstName') + '_' + staticTestData.get('lastName') + '_'
            }, true);
        ContentDocumentLink cdl1 = TestFactory.createContentDocumentLink(cv1, null, ce.Id, null, true);


        // PhotoOnsite test scenario
        List<ContentVersion> onsitePhotosCV = TestFactory.createMultipleContentVersions(
            new Map<String, Object> {
                'Title' => constt.CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX + '_' + staticTestData.get('fellowshipYear') + '_' + staticTestData.get('firstName') + '_' + staticTestData.get('lastName') + '_'
            },
            5, true);
        List<ContentDocumentLink> onsitePhotosCDL = TestFactory.createMultipleContentDocumentLinks(onsitePhotosCV, null, ce.Id, null, true);


        ContentDocumentLink cdlRetr = TestFactory.retrieveContentDocumentLink(
            new Map<String, Object> {
                'LinkedEntityId' => '\'' + ce.Id + '\'',
                'ContentDocument.LatestPublishedVersion.Deleted_By_Fellow__c' => false
            },
            new List<String> {
                'ContentDocument.CreatedDate',
                'ContentDocument.LastModifiedDate',
                'ContentDocument.Title',
                'ContentDocument.ContentSize',
                'ContentDocument.FileType',
                'ContentDocument.LatestPublishedVersion.Deleted_By_Fellow__c',
                'ContentDocument.LatestPublishedVersionId'
            },
            new List<String> {
                'ContentDocument.LastModifiedDate DESC'
            });
        System.debug('cdlList: in test class::'+cdlRetr);
        System.debug('record id in test class::'+ce.id);

        //need to delete later just for debuging
        User u = TestFactory.createUser(staticTestData.get('email'), 'Fellow Portal Community User', staticTestData.get('firstName'), staticTestData.get('lastName'), c.Id, null, true);
        User usr = TestFactory.retrieveUser(new Map<String, Object> {
                'Email' => '\'' + staticTestData.get('email') + '\''
            }, null, null);
        System.debug('User in TESTSETUP ::' + u);
        System.debug('User retrieved in TESTSETUP ::' + usr);
    }

}