public without sharing class Constants {

    private static Constants cc;

    @AuraEnabled public final String CC_ENGAGEMENT_PICKLIST_VALUE_PENDING_APPROVAL = 'Pending Approval';
    @AuraEnabled public final String CC_ENGAGEMENT_PICKLIST_VALUE_APPROVED = 'Approved';

    @AuraEnabled public final String CC_ENGAGEMENT_RECORD_ID_PREFIX = 'a13';

    @AuraEnabled public final String CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX = 'Workplan';
    @AuraEnabled public final String CC_ENGAGEMENT_PHOTO_FILE_TITLE_PREFIX = 'Photo';
    @AuraEnabled public final String CC_ENGAGEMENT_PHOTO_RELEASE_FILE_TITLE_PREFIX = 'PhotoReleaseForm';
    @AuraEnabled public final String CC_ENGAGEMENT_ONSITE_PHOTO_FILE_TITLE_PREFIX = 'PhotoOnsite';
    @AuraEnabled public final String CC_ENGAGEMENT_ACTIVITY_REPORT_FILE_TITLE_PREFIX = 'Completed Activities Report';
    @AuraEnabled public final String CC_ENGAGEMENT_FINAL_DELIVERABLES_FILE_TITLE_PREFIX = 'RemainingDeliverables';

    @AuraEnabled public final String FELLOWSHIP_REGION_PICKLIST_US = 'U.S. Fellowship';
    @AuraEnabled public final String FELLOWSHIP_REGION_PICKLIST_CHINA = 'China Fellowship';
    @AuraEnabled public final String FELLOWSHIP_REGION_PICKLIST_INDIA = 'India Fellowship';

    @AuraEnabled public final Integer MAX_FILES_ONSITE_PHOTOS = 3;


    @AuraEnabled(cacheable=true)
    public static Constants getAllConstants() {
        if (cc == null) cc = new Constants();
        return cc;
    }

}
