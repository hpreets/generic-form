@isTest
public class EngagementListControllerTest {
    @testsetup
    public static void createTestData() {
        createCustomSettingData();
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

    static testMethod void getFellowshipForTest(){

        EngagementListController elc = new EngagementListController();
        EngagementListController.getFellowshipFor();
    }
    static testMethod void getFelloWAppIdTest(){
        Account a = new Account(Name='Test Account', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix', Phone='9876543210', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060'); insert c;
        Fellow_Application__c fa = new Fellow_Application__c(Applicant__c=c.Id,Status__c='Engagement Confirmed',Fellowship_Applying_for__c='U.S. Fellowship'); insert fa;
        FellowAppWrapper fw = new FellowAppWrapper();
        Profile p = [SELECT Id FROM Profile WHERE Name='Fellow Portal Community User'];
        User u = new User(Alias = 'standt', Email='someone@abc.bix',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='someone@abc.bix.edf', FirstName='TestFN', ContactId=c.Id);
        insert u;
        System.runAs(u){
            EngagementListController.getFelloWAppId();
            EngagementListController.getFellowshipApplyingFor();
            EngagementListController.getEngagementListSettings('U.S. Fellowship');
        }


    }



    static testMethod void searchEngagementsTest(){
        EngagementListController.SearchFilterWrapper sfw =new EngagementListController.SearchFilterWrapper();
        sfw.fellowshipcity = 'test';
            sfw.fellowshipstate = 'test';
            sfw.publicTransport = 'test';
            sfw.industry = 'test';
            sfw.availableNotAvailable = 'test';
            sfw.projectType = 'test';
            sfw.locationPreferance = 'test';
            // sfw.engagementProgram = 'test'; // Commented by HSingh FB-2139
            sfw.searchText = 'test';
        EngagementListController.searchEngagements(sfw);
    }

    static testMethod void saveConsiderMeTest(){
        Account a = new Account(Name='Test Account', OwnerId=CustomSettings_Helper.getRecordIdsValue('DefaultOwnerId')); insert a;
        Contact c = new Contact(FirstName='TestFN', LastName='TestLN', Email='someone@abc.bix', Phone='9876543210', MailingStreet='Street', MailingCity='New Delhi', MailingState='Delhi', MailingCountry='India', MailingPostalCode='110060'); insert c;
        Fellow_Application__c fa = new Fellow_Application__c(Applicant__c=c.Id,Status__c='Engagement Confirmed',Fellowship_Applying_for__c='U.S. Fellowship'); insert fa;
        FellowAppWrapper fw = new FellowAppWrapper();
        Profile p = [SELECT Id FROM Profile WHERE Name='Fellow Portal Community User'];
        User u = new User(Alias = 'standt', Email='someone@abc.bix',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='someone@abc.bix.edf', FirstName='TestFN', ContactId=c.Id);
        insert u;
        List<Potential_Matching_From_Screener__c> listPms =new List<Potential_Matching_From_Screener__c>();
        Potential_Matching_From_Screener__c pms=new Potential_Matching_From_Screener__c();
        pms.How_Considered__c = 'Consider Me';
        pms.Is_Deleted__c = false;
        pms.Student_Application__c =fa.Id;
        listPms.add(pms);
        System.runAs(u){
            EngagementListController.submitConsiderMe(listPms,fa.Id);
            EngagementListController.saveConsiderMe(listPms,fa.Id);
        }
    }

}