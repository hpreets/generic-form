/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 3/14/2022
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Test class for EDF28_RegisterController 
# Change Log:               
#
#
############################################################################
*/
@isTest
public class EDF28_RegisterController_Test {
    
@testsetup
    public static void createTestData() {
        createCustomSettingData();
    }
    
    static testMethod void testCreateContact() {
        Account a = new Account(Name='Test Account', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix', Phone='9876543210', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060' ); insert c; 
        Fellow_Application__c fa = new Fellow_Application__c(Applicant__c=c.Id,Status__c='Engagement Confirmed'); insert fa;
        Profile p = [SELECT Id FROM Profile WHERE Name='Fellow Portal Community User'];
        User u = new User(Alias = 'standt', Email='someone@abc.bix', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,isActive = false, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='someone@abc.bix.edf', FirstName='TestFN', ContactId=c.Id);
        insert u;
        EDF28_RegisterController.isEmailExists(c.Email);
        EDF28_RegisterController.getCountries();
        EDF28_RegisterController.getStatesByCountry(c.MailingCountry);
        EDF28_RegisterController.saveUser(c, c.Email);
        Contact_Wrapper cw=new Contact_Wrapper();
         Contact_Wrapper cwr=new Contact_Wrapper(String.valueOf(c.Id));
        	
        Contact_Email__c contactEmail=new Contact_Email__c(Donor__c=c.Id,Type__c='Personal',Email__c='someone@abc.bix',Status__c='Current');
        insert contactEmail;
        Contact_Phone__c contactPhone=new Contact_Phone__c(Donor__c=c.Id,Type__c='Home',Phone__c='9876543210',Status__c='Current');
        insert contactPhone;
        Contact_Wrapper cw2=new Contact_Wrapper(c,contactEmail,contactPhone);
        	cw2.getContact();
            cw2.getFirstName();
            cw2.getLastName();
            cw2.getEmail();
            cw2.getPhone();
            cw2.getContactPhone();
            cw2.getMailingStreet();
            cw2.getStreetAddressLine2();
            cw2.getStreetAddress();
            cw2.getId();
            cw2.getAccountId();
    }
    static testMethod void testWrapper() {
        Account a = new Account(Name='Test Account', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix', Phone='9876543210', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060'); insert c; 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someone@abc.bix', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,isActive = true, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='someone@abc.bix.edf', FirstName='TestFN');
        insert u;
        system.runAs(u){
            UserRole roleId = new UserRole(DeveloperName = 'Administrators',Name = 'Administrators');
        insert roleId;
            u.UserRoleId = roleId.Id;
            update u; 
        }
        
        EDF28_RegisterController.PayloadWrapper pw = new EDF28_RegisterController.PayloadWrapper();
        pw.firstName='test';
        pw.LastName='TestLN';
        pw.Email='someone@abc1.bix';
        pw.Phone='9876543210';
        pw.country = 'India';
        pw.state = 'Delhi';
        pw.City='New Delhi';
        pw.PostalCode='110060';
        pw.address1 = 'test';
        pw.address2 = 'test';
        try{
            EDF28_RegisterController.registerFellow(pw);
        }
        catch(Exception e){
            
        }
        EDF28_RegisterController.saveContact('sys');  
        EDF28_RegisterController.createUser(c.Id, c.email, c.firstName, c.lastName, c.email, '', c.LastName.substring(0, 3), true, a.Id);
    }
    
    static testMethod void testcheckUser() {
        Account a = new Account(Name='Test Account', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix', Phone='9876543210', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060'); insert c; 
        Contact_Email__c ce = new Contact_Email__c(Donor__c = c.Id,Email__c = c.Email,Created_from_Fellow_App__c = true, Primary__c = TRUE); insert ce;
        Fellow_Application__c fa = new Fellow_Application__c(Applicant__c=c.Id,Status__c='Engagement Confirmed',CC_Year__c  = '2022'); insert fa;
        Profile p = [SELECT Id FROM Profile WHERE Name='Fellow Portal Community User'];
        User u = new User(Alias = 'standt', Email=c.Email, 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,IsActive = true, 
                          TimeZoneSidKey='America/Los_Angeles', UserName=c.Email, FirstName='TestFN', ContactId=c.Id);
        insert u;
        EDF28_RegisterController.forgotPassword(u.Email) ;
        EDF28_RegisterController.isEmailExists(c.Email);
        EDF28_RegisterController.isFellowAppExist(c.Email, '2022', c.Id);
        EDF28_RegisterController.updateContactEmail(ce);
        EDF28_RegisterController.updateContactRecord(c);
        EDF28_RegisterController.futureUpdateActivateUser(u.id,u.Username,u.IsActive);
        
    }
    
    public static void createCustomSettingData() {
        List<RecordId__c> recordIdCustomSetting = new List<RecordId__c>();
        if(RecordId__c.getAll().get('DefaultOwnerId') == NULL){
            recordIdCustomSetting.add(new RecordId__c(name = 'DefaultOwnerId',IdValue__c = string.valueOf(UserInfo.getUserId())));
        }
        if(recordIdCustomSetting.size()>0){
            insert recordIdCustomSetting;
        } 
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