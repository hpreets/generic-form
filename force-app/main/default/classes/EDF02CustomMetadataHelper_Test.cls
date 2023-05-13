/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 2/11/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: Test class for EDF02_CustomMetadata_Helper,CustomSettings_Helper
# Change Log:
#
#
############################################################################
*/

@isTest
public class EDF02CustomMetadataHelper_Test {

    @testsetup
    public static void createTestData() {
        createCustomSettingData();
    }

    static testMethod void myCustomMetadata(){
        EDF02_CustomMetadata_Helper.fetchEDFNextSteps();
        EDF02_CustomMetadata_Helper.fetchEDFShortcuts();
        EDF02_CustomMetadata_Helper.fetchEDFItemsForFellowship('U.S. Fellowship');
        EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        EDF02_CustomMetadata_Helper.getStudentMessage('');
        EDF02_CustomMetadata_Helper.getRecordIdsValue('CustomSitesUserProfile');
        EDF02_CustomMetadata_Helper.fetchPortalDeliverablesAndTilesDateMapping('U.S. Fellowship');

        Boolean found = false;
        for (Portal_Deliverables_Section__mdt sections : EDF02_CustomMetadata_Helper.fetchPortalDeliverablesSection('U.S. Fellowship')) {
            if (sections.Section_Field__c == 'Field_StartDate') {
                found = true;
                break;
            }
        }
        System.assertEquals(found, true);
        System.assertEquals(EDF02_CustomMetadata_Helper.getEDFCCGlobalValue(null), null);
        System.assertEquals(EDF02_CustomMetadata_Helper.getRecordIdsValue(null), null);
    }
    static testMethod void myCustomSetting(){
        CustomSettings_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId');
        CustomSettings_Helper.getFellowApplicationStatusValue('Engagement Confirmed + Email Sent to OCS');
        CustomSettings_Helper.getStudentMessage('CurrentFellowshipYear');
        CustomSettings_Helper.getValidExtension('');
        CustomSettings_Helper.getTriggers('CustomSitesUserProfile');
        CustomSettings_Helper.getAllStates();
        CustomSettings_Helper.getAllCountries();
        CustomSettings_Helper.getAllStatesSorted();
        CustomSettings_Helper.getAllCountriesSorted();
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
            EDFCCglobalCustomSetting.add(new EDFCCGlobal__c(name = 'CurrentFellowshipYear',Value__c ='2019' ));
        }
        if(EDFCCglobalCustomSetting.size()>0){
             insert EDFCCglobalCustomSetting;
        }

        List<Countries__c> countryCSList = new List<Countries__c>();
        countryCSList.add(new Countries__c(Name='India'));
        countryCSList.add(new Countries__c(Name='China'));
        countryCSList.add(new Countries__c(Name='United States'));
        countryCSList.add(new Countries__c(Name='Canada'));
        countryCSList.add(new Countries__c(Name='Pakistan'));
        insert countryCSList;

        List<States__c> stateCSList = new List<States__c>();
        stateCSList.add(new States__c(Name='CA', Country__c='United States'));
        stateCSList.add(new States__c(Name='IL', Country__c='United States'));
        stateCSList.add(new States__c(Name='Haryana', Country__c='India'));
        stateCSList.add(new States__c(Name='Delhi', Country__c='India'));
        stateCSList.add(new States__c(Name='Beijing', Country__c='China'));
        stateCSList.add(new States__c(Name='Hongkong', Country__c='China'));
        insert stateCSList;
    }
}