/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 1/31/2022
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Test class for EdfContactController 
# Change Log:               
#
#
############################################################################
*/

@isTest
public class EdfContactController_Test {
    
    @testsetup
    public static void createTestData() {
        createCustomSettingData();
    }
    
    static testMethod void testCreateContact() {
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        Account a = new Account(Name='Test Account', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix', Phone='9876543210', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060'); insert c; 
        Fellow_Application__c fa = new Fellow_Application__c(Applicant__c=c.Id,Status__c='Engagement Confirmed', CC_Year__c=fellowshipYear); insert fa;
        FellowAppWrapper fw = new FellowAppWrapper();
        fw.fellowApplicationId = String.valueOf(fa.id);
        fw.contactId = String.valueOf(c.id);
        fw.lastName = 'teja';
        Profile p = [SELECT Id FROM Profile WHERE Name='Fellow Portal Community User'];
        User u = new User(Alias = 'standt', Email='someone@abc.bix', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='someone@abc.bix.edf', FirstName='TestFN', ContactId=c.Id);
        insert u;
        System.runAs(u){
            EdfContactController.getContactForEDF();
            EdfContactController.getContact();
            EdfContactController.getfellowApplicationId(c.Id);
            EdfContactController.getContactInfo();
            EdfContactController.updateFellowApplication(fw);
        }
        
    }
    static testMethod void testUpdateContact() {
        Account a = new Account(Name='Test Account', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix', Phone='12389087', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060'); insert c; 
        Contact c1 = new Contact(id=c.id,LastName='TestLNupdate');
        test.startTest();
        update c1;
        ContactWrapper cw = new ContactWrapper();
        cw.id=c.id;
        cw.lastName=c.LastName;
        EdfContactController.updateContact(cw);
        EdfContactController.getFellowshipApplyingForPickListValues();
        EdfContactController.getHowDidYouFindUsPickListValues();
        EdfContactController.getReturnerFellowPickListValues();
        EdfContactController.getGenderPickListValues();
        EdfContactController.getDoYouIdentifyAsLatinxOrHispanicPickListValues();
        EdfContactController.getVeteranStatusPickListValues();   
        test.StopTest();
        
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