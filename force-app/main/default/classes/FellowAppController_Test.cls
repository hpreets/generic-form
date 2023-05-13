/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 3/25/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: Test class for FellowAppController
# Change Log:
#
#
############################################################################
*/

@isTest
public class FellowAppController_Test {

    @testsetup
    public static void createTestData() {
        createCustomSettingData();
    }
    static testMethod void testCreateContact() {
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        Account a = new Account(Name='Test Account', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix', Phone='9876543210', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060'); insert c;
        Fellow_Application__c fa = new Fellow_Application__c(Applicant__c=c.Id,Status__c='Engagement Confirmed',Fellowship_Applying_for__c='U.S. Fellowship', CC_Year__c=fellowshipYear); insert fa;
        FellowAppWrapper fw = new FellowAppWrapper();
        Profile p = [SELECT Id FROM Profile WHERE Name='Fellow Portal Community User'];
        User u = new User(Alias = 'standt', Email='someone@abc.bix',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='someone@abc.bix.edf', FirstName='TestFN', ContactId=c.Id);
        insert u;
        System.runAs(u){
            FellowAppController.getContactId();
			FellowAppController.getBackgroundInformation();
			FellowAppController.getEducationInformation();
			FellowAppController.getMatchPreferences();
			FellowAppController.getCoverLetter();
            FellowAppController.submitApplication();
            FellowAppController.getApplicationStatus();
            FellowAppController.retrieveUniversityAccounts();
            FellowAppController.validateReviewSubmit();
            FellowAppController.retrieveUniversitySchoolAccountsWithParents();
            UniversityHelper.updateEducationInformation(fa);
            UniversityHelper.retrieveUniversitySchoolAccountsWithParents();
            UniversityHelper.retrieveUniversityAccounts();
            UniversityHelper.retrieveUniversitySchoolAccounts(a.Id);
        }
    }

    static testMethod void validateReviewSubmitTest(){
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        Account a = new Account(Name='Test Account 2', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix2', Phone='9876543211', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060'); insert c;
        Fellow_Application__c fa = new Fellow_Application__c(Applicant__c=c.Id,Status__c='Engagement Confirmed',Fellowship_Applying_for__c='China Fellowship', CC_Year__c=fellowshipYear); insert fa;
        FellowAppWrapper fw = new FellowAppWrapper();
        Profile p = [SELECT Id FROM Profile WHERE Name='Fellow Portal Community User'];
        User u = new User(Alias = 'standt', Email='someone@abc.bix2',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='someone@abc.bix.edf2', FirstName='TestFN', ContactId=c.Id,Phone='1234512345');
        insert u;
        System.runAs(u){
            FellowAppController.getContactId();
			FellowAppController.getBackgroundInformation();
			FellowAppController.getEducationInformation();
			FellowAppController.getMatchPreferences();
			FellowAppController.getCoverLetter();
            FellowAppController.submitApplication();
            FellowAppController.getApplicationStatus();
            FellowAppController.retrieveUniversityAccounts();
            FellowAppController.validateReviewSubmit();

        }


    }

    static testMethod void fellowAppWrapperTest(){
        FellowAppWrapper faw = new FellowAppWrapper();
        	faw.firstName='hello';
        	faw.lastName = 'hello';
        	faw.email='hello';
            faw.pronouns='hello';
            faw.pronounsSelfDescribe='hello';
            faw.phone='hello';
            faw.mailingCountry='hello';
            faw.mailingPostalCode='hello';
            faw.mailingState='hello';
            faw.mailingCity='hello';
            faw.permanentStreetAddressLine1='hello';
            faw.permanentStreetAddressLine2='hello';
            faw.skypeID='hello';
            faw.howDidYouFindUs='hello';
            faw.howDidYouFindUsIfOther='hello';
        	faw.returnerFellow='hello';
            faw.gender='hello';
            faw.genderSelfDescribe='hello';
            faw.race='hello';
            faw.latinxOrHispanic='hello';
            faw.veteranStatus='hello';
        	faw.graduateDegreeStartDate='hello';
            faw.expectedGraduationDate='hello';
    }


    public static void createCustomSettingData() {
        List<RecordId__c> recordIdCustomSetting = new List<RecordId__c>();
        if(RecordId__c.getAll().get('DefaultOwnerId') == NULL){
            recordIdCustomSetting.add(new RecordId__c(name = 'DefaultOwnerId',IdValue__c = string.valueOf(UserInfo.getUserId())));
        }
        if(recordIdCustomSetting.size()>0){
            insert recordIdCustomSetting;
        }
    }

}