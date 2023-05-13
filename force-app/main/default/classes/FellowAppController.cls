/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 2/27/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: Fellow Application Registration info.
# Test Class............: FellowAppController_Test
# Change Log:
#
############################################################################
*/
public with sharing class FellowAppController {
    /**
    * Description : This method returns the Fellow_Application__c record of the current loggin user associated record.
    **/
    @AuraEnabled
    public static FellowAppWrapper getEducationInformation(){

        FellowAppWrapper fw = new FellowAppWrapper();
        String contactId = getContactId();
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');

        Fellow_Application__c[]  fellowApps = [SELECT Id,
                                Applicant__c,
                                University_School_1__c,
                                GRAD_School_within_University__c,
                                University_Other_1__c,
                                GRAD_University_Dual_Degree__c,
                                GRAD_Dual_Degree_School_in_University__c,
                                Dual_Degree_School_Name__c,
                                GRAD_Degree_s_pursuing__c,
                                GRAD_Degree_s_if_not_listed__c,
                                GRAD_Degree_Concentration__c,
                                Graduation_Start_Date__c,
                                Date_Expected_Graduated_1__c,
                                University_School_2__c,
                                University_Other_2__c,
                                Degree_Earned_2__c,
                                UG_Degree_s_if_not_listed__c,
                                Undergrad_Major__c,
                                Other_courses_certifications__c,
                                               Fellowship_Applying_for__c
                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];

        // if (fellowApps != null  &&  fellowApps.size() > 0){
        // {
            Fellow_Application__c fellowApp = fellowApps.get(0);
            fw.id = fellowApp.Id;
            fw.fellowApplicationId = fellowApp.Id;
        	fw.fellowshipApplyingFor = fellowApp.Fellowship_Applying_for__c;
            fw.contactId = fellowApp.Applicant__c;
            fw.graduateUniversity = fellowApp.University_School_1__c;
            fw.schoolWithinUniversity = fellowApp.GRAD_School_within_University__c;
            fw.schoolUniversityOther = fellowApp.University_Other_1__c;
            fw.dualGraduateUniversity = fellowApp.GRAD_University_Dual_Degree__c;
            fw.schoolWithinDualUniversity = fellowApp.GRAD_Dual_Degree_School_in_University__c;
            fw.schoolDualUniversityOther = fellowApp.Dual_Degree_School_Name__c;
            fw.graduateDegree = fellowApp.GRAD_Degree_s_pursuing__c;
            fw.graduateDegreeOther = fellowApp.GRAD_Degree_s_if_not_listed__c;
            fw.graduateDegreeConcentration = fellowApp.GRAD_Degree_Concentration__c;
            if(fellowApp.Graduation_Start_Date__c != null){
                //datetime gradStartdate= Date.Valueof(fellowApp.Graduation_Start_Date__c);  //Commented as part of FB-0024
                //fw.graduateDegreeStartDate = gradStartdate.format('MM/dd/YYYY'); //Commented as part of FB-0024
                fw.graduateDegreeStartDate = string.valueOf(fellowApp.Graduation_Start_Date__c); //Added as part of FB-0024
            }
            if(fellowApp.Date_Expected_Graduated_1__c != null){
                //datetime dateExpected= Date.Valueof(fellowApp.Date_Expected_Graduated_1__c);  //Commented as part of FB-0024
                //fw.expectedGraduationDate = dateExpected.format('MM/dd/YYYY'); //Commented as part of FB-0024
                fw.expectedGraduationDate = string.valueOf(fellowApp.Date_Expected_Graduated_1__c); //Added as part of FB-0024
            }
            fw.undergraduateUniversity = fellowApp.University_School_2__c;
            fw.undergraduateUniversityOther = fellowApp.University_Other_2__c;
            fw.undergraduateDegreeEarned = fellowApp.Degree_Earned_2__c;
            fw.undergraduateDegreeEarnedOther = fellowApp.UG_Degree_s_if_not_listed__c;
            fw.undergradMajor = fellowApp.Undergrad_Major__c;
            fw.otherCoursesCertifications = fellowApp.Other_courses_certifications__c;



            return fw;

        //  }

        //return fw;
    }
	/**
    * Description : This method returns the Fellow_Application__c record of the current loggin user associated record.
    **/
    @AuraEnabled
    public static FellowAppWrapper getBackgroundInformation(){

        FellowAppWrapper fw = new FellowAppWrapper();
        String contactId = getContactId();
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');

        Fellow_Application__c[]  fellowApps = [SELECT Id,
                                Applicant__c,
                                Fellowship_Applying_for__c,
                                US_Resident__c,
                                Are_you_eligible_to_work_in_U_S_in_summ__c,
                                Years_of_Experience_from_App__c,
                                Native_English_Speaker__c,
                                Residency_in_china__c,
                                ChinaPassport__c,
                                Photo_Identification_Name__c,
                                China_fellowship_tests__c,
                                China_fellowship_test_score__c,
                                ExperienceAdvancedFinancialAnalysis__c,
                                Experience_Greenhouse_Gas_Accounting__c,
                                ExperienceExtensiveExcelAataAnalysis__c,
                                Experience_Supply_Chain__c,
                                ExperienceRenewables__c

                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];

            Fellow_Application__c fellowApp = fellowApps.get(0);
            fw.id = fellowApp.Id;
            fw.fellowApplicationId = fellowApp.Id;
            fw.contactId = fellowApp.Applicant__c;
            fw.fellowshipApplyingFor = fellowApp.Fellowship_Applying_for__c;
            fw.authorizedWorkUS = fellowApp.US_Resident__c;
            fw.nativeEnglishSpeaker = fellowApp.Native_English_Speaker__c;
            fw.residencyInChina = fellowApp.Residency_in_china__c;
            fw.photoIdentification = fellowApp.Photo_Identification_Name__c;
            fw.passportCheckboxVal = fellowApp.ChinaPassport__c;
            fw.ChinaFellowshipTests = fellowApp.China_fellowship_tests__c;
            fw.ChinaFellowshipTestScore = fellowApp.China_fellowship_test_score__c;
            fw.requireAuthorization = fellowApp.Are_you_eligible_to_work_in_U_S_in_summ__c;
            fw.yearsOfExperience = fellowApp.Years_of_Experience_from_App__c;
            fw.financialAnalysis = fellowApp.ExperienceAdvancedFinancialAnalysis__c;
            fw.greenhouseGasAccounting = fellowApp.Experience_Greenhouse_Gas_Accounting__c;
            fw.dataAnalysis = fellowApp.ExperienceExtensiveExcelAataAnalysis__c;
            fw.supplyChain = fellowApp.Experience_Supply_Chain__c;
            fw.energyEfficiencyRenewables = fellowApp.ExperienceRenewables__c;

            return fw;

    }
	/**
    * Description : This method returns the Fellow_Application__c record of the current loggin user associated record.
    **/
    @AuraEnabled
    public static FellowAppWrapper getMatchPreferences(){

        FellowAppWrapper fw = new FellowAppWrapper();
        String contactId = getContactId();
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');

        Fellow_Application__c[]  fellowApps = [SELECT Id,
                                Applicant__c,
                                Fellowship_Applying_for__c,
                                Apply_India_as_well__c,
                                Apply_for_China_Fellowship_as_well__c,
                                Regions_in_India__c,
                                Regions_in_China__c,
                                US_regional_preferences__c,
                                ValidUSDriversLicense__c,
                                AccessToAVehicleThisSummer__c,
                                Sector_first_choice__c,
                                Sector_second_choice__c,
                                Sector_third_choice__c,
                                Project_Type_Preference_One__c,
                                Project_Type_Preference_Two__c,
                                Project_Type_Preference_Three__c,
                                Geographic_Yes_Region__c

                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];

            Fellow_Application__c fellowApp = fellowApps.get(0);
            fw.id = fellowApp.Id;
            fw.fellowApplicationId = fellowApp.Id;
            fw.contactId = fellowApp.Applicant__c;
            fw.fellowshipApplyingFor = fellowApp.Fellowship_Applying_for__c;
            fw.applyIndia = fellowApp.Apply_India_as_well__c;
            fw.applyChina = fellowApp.Apply_for_China_Fellowship_as_well__c;
            fw.regionsInIndia = fellowApp.Regions_in_India__c;
            fw.regionsInChina = fellowApp.Regions_in_China__c;
            fw.usRegionalPreferences = fellowApp.US_regional_preferences__c;
            fw.validUSDriversLicense = fellowApp.ValidUSDriversLicense__c;
            fw.accessToVehicle = fellowApp.AccessToAVehicleThisSummer__c;
            fw.sectorFirstChoice = fellowApp.Sector_first_choice__c;
            fw.sectorSecondChoice = fellowApp.Sector_second_choice__c;
            fw.sectorThirdChoice = fellowApp.Sector_third_choice__c;
            fw.projectTypePreferenceOne = fellowApp.Project_Type_Preference_One__c;
            fw.projectTypePreferenceTwo = fellowApp.Project_Type_Preference_Two__c;
            fw.projectTypePreferenceThree = fellowApp.Project_Type_Preference_Three__c;
        	fw.regionsInUS = fellowApp.Geographic_Yes_Region__c;

            return fw;

    }
	/**
    * Description : This method returns the Fellow_Application__c record of the current loggin user associated record.
    **/
    @AuraEnabled
    public static FellowAppWrapper getCoverLetter(){

        FellowAppWrapper fw = new FellowAppWrapper();
        String contactId = getContactId();
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');

        Fellow_Application__c[]  fellowApps = [SELECT Id,
                                Applicant__c,
                                Cover_Letter__c,
                                Resume_Name__c,
                                Additional_Information__c,
                                Reference_Email_1__c,
                                Reference_Email_2__c,
                                Reference_Email_3__c,
                                Reference_Name_1__c,
                                Reference_Name_2__c,
                                Reference_Name_3__c,
                                Reference_Phone_1__c,
                                Reference_Phone_2__c,
                                Reference_Phone_3__c,
                                Reference_Title_1__c,
                                Reference_Title_2__c,
                                Reference_Title_3__c,
                                Reference_Special_Instructions_1__c,
                                Reference_Special_Instructions_2__c,
                                Reference_Special_Instructions_3__c,
                                Fellowship_Applying_for__c

                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];

            Fellow_Application__c fellowApp = fellowApps.get(0);
            fw.id = fellowApp.Id;
            fw.fellowApplicationId = fellowApp.Id;
            fw.contactId = fellowApp.Applicant__c;

            fw.coverLetter = fellowApp.Cover_Letter__c;
            fw.additionalInformation = fellowApp.Additional_Information__c;
            fw.resumeName = fellowApp.Resume_Name__c;
            fw.referenceEmail1 = fellowApp.Reference_Email_1__c;
            fw.referenceEmail2 = fellowApp.Reference_Email_2__c;
            fw.referenceEmail3 = fellowApp.Reference_Email_3__c;
            fw.referenceName1 = fellowApp.Reference_Name_1__c;
            fw.referenceName2 = fellowApp.Reference_Name_2__c;
            fw.referenceName3 = fellowApp.Reference_Name_3__c;
            fw.referencePhone1 = fellowApp.Reference_Phone_1__c;
            fw.referencePhone2 = fellowApp.Reference_Phone_2__c;
            fw.referencePhone3 = fellowApp.Reference_Phone_3__c;
            fw.referenceTitle1 = fellowApp.Reference_Title_1__c;
            fw.referenceTitle2 = fellowApp.Reference_Title_2__c;
            fw.referenceTitle3 = fellowApp.Reference_Title_3__c;
            fw.referenceSpecialInstructions1 = fellowApp.Reference_Special_Instructions_1__c;
            fw.referenceSpecialInstructions2 = fellowApp.Reference_Special_Instructions_2__c;
            fw.referenceSpecialInstructions3 = fellowApp.Reference_Special_Instructions_3__c;
            fw.fellowshipApplyingFor = fellowApp.Fellowship_Applying_for__c;

            return fw;

    }
    @AuraEnabled
    public static string  submitApplication(){

        String contactId = getContactId();
        string status;
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');

        Fellow_Application__c[]  fellowApps = [SELECT Id,
									   Status__c

                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];
        Fellow_Application__c fellowApp = fellowApps.get(0);
        if(fellowApp.Status__c == 'Prospective Applicant' && fellowApp.Status__c != 'Application Submitted'){
            fellowApp.Status__c = 'Application Submitted';
            update fellowApp;
        }

        status = fellowApp.Status__c;

        return status;
    }

    @AuraEnabled
    public static string getApplicationStatus(){
        String contactId = getContactId();
        string message;
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');

        Fellow_Application__c[]  fellowApps = [SELECT Id,
									   Status__c

                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];
        return  fellowApps[0].Status__c;
    }
    /**
    * Description : This method returns the Accounts whose record type is organization and parent equal to null.
    **/
    @AuraEnabled(cacheable=true)
    public static List<Account> retrieveUniversityAccounts() {
        List<Account> univList
            = [SELECT Name, Id
                FROM Account
                WHERE RecordType.DeveloperName = 'Organization'
                    AND Type = 'Organization'
                    AND Organization_Constituency__c INCLUDES ('EDFBIZ')
                    AND Organization_sub_constituency__c INCLUDES ('EDFBIZ - Climate Corps')
                    AND Sub_Type__c = 'School'
                    AND ParentId = null // Condition added by Harpreet 8/22/2020
                ORDER BY Name];
                System.debug('univList:'+univList);
        return univList;
    }
    /**
    * Description : This method returns the Accounts whose record type is organization and parent not equal to null.
    **/
    @AuraEnabled(cacheable=true)
    public static List<Account> retrieveUniversitySchoolAccounts(String parentId) {
        System.debug('parentId:'+parentId);
        List<Account> univList
            = [SELECT Name, Id
                FROM Account
                WHERE RecordType.DeveloperName = 'Organization'
                    AND Type = 'Organization'
                    AND Organization_Constituency__c INCLUDES ('EDFBIZ')
                    AND Organization_sub_constituency__c INCLUDES ('EDFBIZ - Climate Corps')
                    AND Sub_Type__c = 'School'
                    AND ParentId = :parentId
                ORDER BY Name];
                System.debug('univList:Child'+univList);
        return univList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> retrieveUniversitySchoolAccountsWithParents() {
        List<Account> univList
            = [SELECT Name, Id
                FROM Account
                WHERE RecordType.DeveloperName = 'Organization'
                    AND Type = 'Organization'
                    AND Organization_Constituency__c INCLUDES ('EDFBIZ')
                    AND Organization_sub_constituency__c INCLUDES ('EDFBIZ - Climate Corps')
                    AND Sub_Type__c = 'School'
                    AND ParentId != null
                ORDER BY Name];
        return univList;
    }

    /**
    * Description : This method returns the current loggin user associated contcat record ID.
    **/
    public static String getContactId() {
        String contactId = '';
        String currUserId = Userinfo.getUserId();
        User[] users = [SELECT Id, FirstName, LastName, Contact.Name, username, ContactId, email
                        FROM User WHERE Id = :currUserId and ContactId <> null];
        if (users != null  &&  users.size() > 0){
            User user = users.get(0);
            contactId = user.ContactId;
        }

        return contactId;

    }

    public static string getFellowshipApplyingFor(){
        String contactId = getContactId();
        String fellowshipApplyingFor = '';
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');

        Fellow_Application__c[]  fellowApps = [SELECT Id,
									   Fellowship_Applying_for__c

                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];
        if (fellowApps != null  &&  fellowApps.size() > 0){
            Fellow_Application__c fellowApp = fellowApps.get(0);
            fellowshipApplyingFor = fellowApp.Fellowship_Applying_for__c;
        }

        return fellowshipApplyingFor;
    }

    //@AuraEnabled(cacheable=true)
    @AuraEnabled()
    public static string validateReviewSubmit(){
        String contactId = getContactId();
        String validationMessage = '';
        String fellowshipApplyingFor = '';
        String lineBreak = ', ';
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');

        Fellow_Application__c[]  fellowApps = [SELECT Applicant__r.FirstName,
                                                Applicant__r.LastName,
                                                Applicant__r.Email,
                                                Fellowship_Applying_for__c,
                                                Pronouns__c,
                                                Applicant__r.Phone,
                                                Applicant__r.MailingStreet,
                                                Applicant__r.MailingCity,
                                                Applicant__r.MailingState,
                                                Applicant__r.MailingCountry,
                                                Applicant__r.MailingPostalCode,
                                                Skype__c,
                                                How_Did_You_Find_Us__c,
                                                Returner_Fellow__c,

                                                Graduation_Start_Date__c,
                                                Date_Expected_Graduated_1__c,
                                                Degree_Earned_2__c,

                                                US_Resident__c,
                                                Are_you_eligible_to_work_in_U_S_in_summ__c,
                                                Years_of_Experience_from_App__c,
                                                ExperienceAdvancedFinancialAnalysis__c,
                                                Experience_Greenhouse_Gas_Accounting__c,
                                                ExperienceExtensiveExcelAataAnalysis__c,
                                                Scale_Data_Analysis_Experience__c,
                                                Experience_Supply_Chain__c,
                                                ExperienceRenewables__c,
                                                Native_English_Speaker__c,
                                                Residency_in_china__c,
                                                China_fellowship_tests__c,
                                                China_fellowship_test_score__c,

                                                Geographic_Yes_Region__c,
                                                Sector_first_choice__c,
                                                Sector_second_choice__c,
                                                Sector_third_choice__c,
                                                Regions_in_China__c,
                                                Regions_in_India__c,

                                                Cover_Letter__c,
                                                Reference_Name_1__c,
                                                Reference_Name_2__c,
                                                Reference_Name_3__c,
                                                Reference_Title_1__c,
                                                Reference_Title_2__c,
                                                Reference_Title_3__c,
                                                Reference_Email_1__c,
                                                Reference_Email_2__c,
                                                Reference_Email_3__c

                                            FROM
                                                Fellow_Application__c
                                            WHERE
                                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];
        if (fellowApps != null  &&  fellowApps.size() > 0){
            Fellow_Application__c fa = fellowApps.get(0);
            fellowshipApplyingFor = fa.Fellowship_Applying_for__c;
            //Contact Information
            if(fellowshipApplyingFor == 'U.S. Fellowship' || fellowshipApplyingFor == 'India Fellowship'){
                if(String.isBlank(fa.Applicant__r.FirstName)
                    || String.isBlank(fa.Applicant__r.FirstName)
                    || String.isBlank(fa.Applicant__r.LastName)
                    || String.isBlank(fa.Applicant__r.Email)
                    || String.isBlank(fa.Fellowship_Applying_for__c)
                    || String.isBlank(fa.Pronouns__c)
                    || String.isBlank(fa.Applicant__r.Phone)
                    || String.isBlank(fa.Applicant__r.MailingStreet)
                    || String.isBlank(fa.Applicant__r.MailingCity)
                    || String.isBlank(fa.Applicant__r.MailingState)
                    || String.isBlank(fa.Applicant__r.MailingCountry)
                    || String.isBlank(fa.Applicant__r.MailingPostalCode)
                    || String.isBlank(fa.How_Did_You_Find_Us__c)
                    || String.isBlank(fa.Returner_Fellow__c)){
                        validationMessage = validationMessage + 'Contact Information' + lineBreak;
                }
            }
            else if(fellowshipApplyingFor == 'China Fellowship'){
                if(String.isBlank(fa.Applicant__r.FirstName)
                    || String.isBlank(fa.Applicant__r.FirstName)
                    || String.isBlank(fa.Applicant__r.LastName)
                    || String.isBlank(fa.Applicant__r.Email)
                    || String.isBlank(fa.Fellowship_Applying_for__c)
                    || String.isBlank(fa.Pronouns__c)
                    || String.isBlank(fa.Applicant__r.Phone)
                    || String.isBlank(fa.Applicant__r.MailingStreet)
                    || String.isBlank(fa.Applicant__r.MailingCity)
                    || String.isBlank(fa.Applicant__r.MailingState)
                    || String.isBlank(fa.Applicant__r.MailingCountry)
                    || String.isBlank(fa.Applicant__r.MailingPostalCode)
                    || String.isBlank(fa.Skype__c)
                    || String.isBlank(fa.How_Did_You_Find_Us__c)
                    || String.isBlank(fa.Returner_Fellow__c)){
                        validationMessage = validationMessage + 'Contact Information' + lineBreak;
                }
            }

            //Education Information
            if(fa.Graduation_Start_Date__c == null
                || fa.Date_Expected_Graduated_1__c == null
                || String.isBlank(fa.Degree_Earned_2__c)){
                validationMessage = validationMessage + 'Education Information' + lineBreak;
            }

            //Background Information
            if(fellowshipApplyingFor == 'U.S. Fellowship'){
                if(String.isBlank(fa.US_Resident__c)
                    || String.isBlank(fa.Are_you_eligible_to_work_in_U_S_in_summ__c)
                    || String.isBlank(fa.Years_of_Experience_from_App__c)
                    || String.isBlank(fa.ExperienceAdvancedFinancialAnalysis__c)
                    || String.isBlank(fa.Experience_Greenhouse_Gas_Accounting__c)
                    || String.isBlank(fa.ExperienceExtensiveExcelAataAnalysis__c)
                    // || String.isBlank(fa.Scale_Data_Analysis_Experience__c)
                    || String.isBlank(fa.Experience_Supply_Chain__c)
                    || String.isBlank(fa.ExperienceRenewables__c)){

                    validationMessage = validationMessage + 'Background Information' + lineBreak;
                }
            }
            else if(fellowshipApplyingFor == 'India Fellowship'){
                if(String.isBlank(fa.Native_English_Speaker__c)
                    //|| String.isBlank(fa.Are_you_eligible_to_work_in_U_S_in_summ__c)
                    || String.isBlank(fa.Years_of_Experience_from_App__c)
                    || String.isBlank(fa.ExperienceAdvancedFinancialAnalysis__c)
                    || String.isBlank(fa.Experience_Greenhouse_Gas_Accounting__c)
                    || String.isBlank(fa.ExperienceExtensiveExcelAataAnalysis__c)
                    // || String.isBlank(fa.Scale_Data_Analysis_Experience__c)
                    || String.isBlank(fa.Experience_Supply_Chain__c)
                    || String.isBlank(fa.ExperienceRenewables__c)){

                    validationMessage = validationMessage + 'Background Information' + lineBreak;
                }
            }
            else if(fellowshipApplyingFor == 'China Fellowship'){
                if(String.isBlank(fa.Native_English_Speaker__c)
                    || String.isBlank(fa.Residency_in_china__c)
                    || String.isBlank(fa.China_fellowship_tests__c)
                    || String.isBlank(fa.China_fellowship_test_score__c)
                    || String.isBlank(fa.Years_of_Experience_from_App__c)
                    || String.isBlank(fa.ExperienceAdvancedFinancialAnalysis__c)
                    || String.isBlank(fa.Experience_Greenhouse_Gas_Accounting__c)
                    || String.isBlank(fa.ExperienceExtensiveExcelAataAnalysis__c)
                    || String.isBlank(fa.Experience_Supply_Chain__c)
                    || String.isBlank(fa.ExperienceRenewables__c)){

                    validationMessage = validationMessage + 'Background Information' + lineBreak;
                }
            }

            //Match Preferences
            if(fellowshipApplyingFor == 'U.S. Fellowship'){
                if(String.isBlank(fa.Geographic_Yes_Region__c)
                    || String.isBlank(fa.Sector_first_choice__c)
                    || String.isBlank(fa.Sector_second_choice__c)
                    || String.isBlank(fa.Sector_third_choice__c)){

                    validationMessage = validationMessage + 'Match Preferences' + lineBreak;
                }
            }
            else if(fellowshipApplyingFor == 'India Fellowship'){
                if(String.isBlank(fa.Regions_in_India__c)){
                    validationMessage = validationMessage + 'Match Preferences' + lineBreak;
                }
            }
            else if(fellowshipApplyingFor == 'China Fellowship'){
                if(String.isBlank(fa.Regions_in_China__c)){
                    validationMessage = validationMessage + 'Match Preferences' + lineBreak;
                }
            }

            //Cover Letter
            if(fellowshipApplyingFor == 'U.S. Fellowship' || fellowshipApplyingFor == 'India Fellowship'){
                if(String.isBlank(fa.Cover_Letter__c)
                    || String.isBlank(fa.Reference_Name_1__c)
                    || String.isBlank(fa.Reference_Name_2__c)
                    || String.isBlank(fa.Reference_Name_3__c)
                    || String.isBlank(fa.Reference_Title_1__c)
                    || String.isBlank(fa.Reference_Title_2__c)
                    || String.isBlank(fa.Reference_Title_3__c)
                    || String.isBlank(fa.Reference_Email_1__c)
                    || String.isBlank(fa.Reference_Email_2__c)
                    || String.isBlank(fa.Reference_Email_3__c)
                    ){

                    validationMessage = validationMessage + 'Cover Letter & Resume' + lineBreak;
                }
            }
            else if(fellowshipApplyingFor == 'China Fellowship'){
                if(String.isBlank(fa.Cover_Letter__c)
                    || String.isBlank(fa.Reference_Name_1__c)
                    || String.isBlank(fa.Reference_Title_1__c)
                    || String.isBlank(fa.Reference_Email_1__c)){

                    validationMessage = validationMessage + 'Cover Letter & Resume' + lineBreak;
                }
            }
        }

        if(!String.isBlank(validationMessage)){
            validationMessage = validationMessage.trim().removeEnd(',');
        }

        return validationMessage;
    }

    /**
     * FB-2039
     * Checks if the deadline is passed for the applicant or not
     * Checks following two places
     * 1. EDF CC Global Custom Setting 'FellowAppDeadline' value
     * 2. If 1 is true, check if 'Allowed To Submit After Deadline' is true for current Fellow Application
     */
    @AuraEnabled
    public static Boolean isDeadlinePassed() {
        Boolean retVal = true;

        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        System.debug('fellowshipYear :: ' + fellowshipYear);

        String contactId = getContactId();
        System.debug('contactId :: ' + contactId);
        Fellow_Application__c[]  fellowApps;
        if (!String.isBlank(contactId)) {
            fellowApps
                = [SELECT Id, Allowed_To_Submit_After_Deadline__c, Status__c
                    FROM
                        Fellow_Application__c
                    WHERE
                        Applicant__c = :contactId AND CC_Year__c=:fellowshipYear];

            if (fellowApps.size() > 0  && fellowApps[0].Status__c == 'Prospective Applicant'  &&  retVal == true) {
                System.debug('fellowApps :: ' + fellowApps);
                // If FApp.Allowed_To_Submit_After_Deadline__c is NOT TRUE, isDeadlinePassed is TRUE
                retVal = (fellowApps.size() > 0 ? !fellowApps[0].Allowed_To_Submit_After_Deadline__c : true);
                System.debug('retVal :: ' + retVal);
            }
        }

        if ((fellowApps != null  &&  fellowApps.size() > 0  &&  fellowApps[0].Status__c == 'Prospective Applicant'  &&  retVal == true)  ||  (fellowApps == null  &&  retVal == true)) {
            DateTime deadline = DateTime.parse('01/11/2022, 00:00 AM');
            try {
                deadline = DateTime.parse(CustomSettings_Helper.getEDFCCGlobalValue('FellowAppDeadline') + ', 00:00 AM');
                deadline = deadline.addHours(27); // 24 hours (till end of day) + 3 hrs (users default timezone is EST, hence adding 3 hours for PST)
            }
            catch (Exception e) {
                System.debug('Exception ::' + e);
            }
            System.debug('deadline :: ' + deadline);

            // If deadline is LESS than today, isDeadlinePassed is TRUE
            retVal = (deadline < DateTime.now());
            System.debug('retVal :: ' + retVal);
        }

        /* DateTime deadline = DateTime.parse('01/11/2022, 00:00 AM');
        try {
            deadline = DateTime.parse(CustomSettings_Helper.getEDFCCGlobalValue('FellowAppDeadline') + ', 00:00 AM');
            deadline = deadline.addHours(27); // 24 hours (till end of day) + 3 hrs (users default timezone is EST, hence adding 3 hours for PST)
        }
        catch (Exception e) {
            System.debug('Exception ::' + e);
        }
        System.debug('deadline :: ' + deadline);

        // If deadline is LESS than today, isDeadlinePassed is TRUE
        Boolean retVal = (deadline < DateTime.now());
        System.debug('retVal :: ' + retVal);

        if (retVal) {
            String contactId = getContactId();
            System.debug('contactId :: ' + contactId);
            if (!String.isBlank(contactId)) {
                Fellow_Application__c[]  fellowApps
                    = [SELECT Id, Allowed_To_Submit_After_Deadline__c, Status__c
                        FROM
                            Fellow_Application__c
                        WHERE
                            Applicant__c = :contactId AND CC_Year__c=:fellowshipYear];

                System.debug('fellowApps :: ' + fellowApps);
                // If FApp.Allowed_To_Submit_After_Deadline__c is NOT TRUE, isDeadlinePassed is TRUE
                retVal = (fellowApps.size() > 0 ? !fellowApps[0].Allowed_To_Submit_After_Deadline__c : true);
                System.debug('retVal :: ' + retVal);
            }
        } */
        System.debug('retVal :: ' + retVal);
        return retVal;
    }
}