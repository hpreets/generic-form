/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 1/31/2022
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Test class for LoginController 
# Change Log:               
#
#
############################################################################
*/

@isTest
public class LoginController_Test {
    
    @testsetup
    public static void createTestData() {
        createCustomSettingData();
    }
    
    static testMethod void testMethod1() {
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        Account a = new Account(Name='Test Account', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix', Phone='9876543210', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060'); insert c;
        System.debug('c:'+c);
        Profile p = [SELECT Id FROM Profile WHERE Name='Fellow Portal Community User'];
        Fellow_Application__c fa = new Fellow_Application__c(Applicant__c=c.Id,Status__c='Engagement Confirmed', CC_Year__c=fellowshipYear); insert fa;
        System.debug('fa:'+fa);
        System.debug('faContactID:'+fa.Applicant__c);
        User u = new User(Alias = 'standt', Email='someone@abc.bix', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='someone@abc.bix.edf', FirstName='TestFN', ContactId=c.Id);
        insert u;
        System.debug('inserted UserId:'+u.id);
        System.runAs(u){
        LoginController.login('someone@abc.bix.edf','****');
        LoginController.getUserDetails();
        LoginController.getUserName();
        LoginController.getApplicationStatus();
        LoginController.forgotPasswordByEmail('someone@abc.bix');
        LoginController.getApplicationStatusForLogin();
        LoginController.getApplicationStatusValue();
        LoginController.getUsernameByEmail('someone@abc.bix.edf');
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
    }

}