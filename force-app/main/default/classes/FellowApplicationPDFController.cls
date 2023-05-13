/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 2/27/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: Fellow Application Registration PDF Format Display.
# Test Class............: FellowApplicationPDFController_Test
# Change Log:
#
############################################################################
*/
public with sharing class FellowApplicationPDFController {

    public FellowAppWrapper fellowAppWrapper { get; set; }

    public FellowApplicationPDFController() {
        initialize();
    }

    public void initialize(){
        fellowAppWrapper = new FellowAppWrapper();
        fellowAppWrapper = getFellowApplication();
        // FellowApplicationPDFController.FellowApplicationObj obj = new FellowApplicationPDFController.FellowApplicationObj();
    }

    @AuraEnabled
    public static FellowAppWrapper getFellowApplication(){

        FellowAppWrapper fw = new FellowAppWrapper();
        String contactId = FellowAppController.getContactId();
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');

        Fellow_Application__c[]  fellowApps = [SELECT Id,  Applicant__c,
                                Applicant__r.Name,
                                Applicant__r.FirstName,
                                Applicant__r.LastName,
                                Applicant__r.Email,
                                Applicant__r.Phone,
                                Applicant__r.MailingStreet,
                                Applicant__r.Permanent_Street_Address_Line_2__c,
                                Applicant__r.MailingCity,
                                Applicant__r.MailingState,
                                Applicant__r.MailingCountry,
                                Applicant__r.MailingPostalCode,
                                Pronouns__c,
                                Pronouns_Self_Describe__c,
                                Fellowship_Applying_for__c,
                                Skype__c,
                                How_Did_You_Find_Us__c,
                                How_Campus_Presentation__c,
                                How_did_find_out_about_EDF_Other__c,
                                Returner_Fellow__c,
                                Sex__c,
                                Sex_Self_Describe__c,
                                Race__c,
                                Do_you_identify_as_Latinx_or_Hispanic__c,
                                Veteran_Status__c,
                                //EducationInformation
                                University_School_1__c, University_School_1__r.Name,
                                GRAD_School_within_University__c, GRAD_School_within_University__r.Name,
                                University_Other_1__c,
                                GRAD_University_Dual_Degree__c, GRAD_University_Dual_Degree__r.Name,
                                GRAD_Dual_Degree_School_in_University__c, GRAD_Dual_Degree_School_in_University__r.Name,
                                Dual_Degree_School_Name__c,
                                GRAD_Degree_s_pursuing__c,
                                GRAD_Degree_s_if_not_listed__c,
                                GRAD_Degree_Concentration__c,
                                Graduation_Start_Date__c,
                                Date_Expected_Graduated_1__c,
                                University_School_2__c, University_School_2__r.Name,
                                University_Other_2__c,
                                Degree_Earned_2__c,
                                UG_Degree_s_if_not_listed__c,
                                Undergrad_Major__c,
                                Other_courses_certifications__c,
                                //BackgroundInformation
                                US_Resident__c,
                                Are_you_eligible_to_work_in_U_S_in_summ__c,
                                Native_English_Speaker__c,
                                Residency_in_china__c,
                                ChinaPassport__c,
                                China_fellowship_tests__c,
                                China_fellowship_test_score__c,
                                Years_of_Experience_from_App__c,
                                ExperienceAdvancedFinancialAnalysis__c,
                                Experience_Greenhouse_Gas_Accounting__c,
                                ExperienceExtensiveExcelAataAnalysis__c,
                                Experience_Supply_Chain__c,
                                ExperienceRenewables__c,
                                //MatchPreferences
                                Apply_India_as_well__c,
                                Apply_for_China_Fellowship_as_well__c,
                                Geographic_Yes_Region__c,
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
                                //CoverLetter
                                Cover_Letter__c,
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
                                Reference_Special_Instructions_3__c
                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];
        System.debug('contactId:'+contactId);
        System.debug('fellowApps:'+fellowApps.size());
        if(Test.isRunningTest()){
            fellowApps = [SELECT Id, Applicant__c,
                                Applicant__r.Name,
                                Applicant__r.FirstName,
                                Applicant__r.LastName,
                                Applicant__r.Email,
                                Applicant__r.Phone,
                                Applicant__r.MailingStreet,
                                Applicant__r.Permanent_Street_Address_Line_2__c,
                                Applicant__r.MailingCity,
                                Applicant__r.MailingState,
                                Applicant__r.MailingCountry,
                                Applicant__r.MailingPostalCode,
                                Pronouns__c,
                                Pronouns_Self_Describe__c,
                                Fellowship_Applying_for__c,
                                Skype__c,
                                How_Did_You_Find_Us__c,
                                How_Campus_Presentation__c,
                                How_did_find_out_about_EDF_Other__c,
                                Returner_Fellow__c,
                                Sex__c,
                                Sex_Self_Describe__c,
                                Race__c,
                                Do_you_identify_as_Latinx_or_Hispanic__c,
                                Veteran_Status__c,
                                //EducationInformation
                                University_School_1__c, University_School_1__r.Name,
                                GRAD_School_within_University__c, GRAD_School_within_University__r.Name,
                                University_Other_1__c,
                                GRAD_University_Dual_Degree__c, GRAD_University_Dual_Degree__r.Name,
                                GRAD_Dual_Degree_School_in_University__c, GRAD_Dual_Degree_School_in_University__r.Name,
                                Dual_Degree_School_Name__c,
                                GRAD_Degree_s_pursuing__c,
                                GRAD_Degree_s_if_not_listed__c,
                                GRAD_Degree_Concentration__c,
                                Graduation_Start_Date__c,
                                Date_Expected_Graduated_1__c,
                                University_School_2__c, University_School_2__r.Name,
                                University_Other_2__c,
                                Degree_Earned_2__c,
                                UG_Degree_s_if_not_listed__c,
                                Undergrad_Major__c,
                                Other_courses_certifications__c,
                                //BackgroundInformation
                                US_Resident__c,
                                Are_you_eligible_to_work_in_U_S_in_summ__c,
                                Native_English_Speaker__c,
                                Residency_in_china__c,
                                ChinaPassport__c,
                                China_fellowship_tests__c,
                                China_fellowship_test_score__c,
                                Years_of_Experience_from_App__c,
                                ExperienceAdvancedFinancialAnalysis__c,
                                Experience_Greenhouse_Gas_Accounting__c,
                                ExperienceExtensiveExcelAataAnalysis__c,
                                Experience_Supply_Chain__c,
                                ExperienceRenewables__c,
                                //MatchPreferences
                                Apply_India_as_well__c,
                                Apply_for_China_Fellowship_as_well__c,
                                Geographic_Yes_Region__c,
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
                                //CoverLetter
                                Cover_Letter__c,
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
                                Reference_Special_Instructions_3__c FROM Fellow_Application__c LIMIT 1];
         }
        if (fellowApps != null  &&  fellowApps.size() > 0){

            Fellow_Application__c fellowApp = fellowApps.get(0);
            fw.id = fellowApp.Id;
            fw.fellowApplicationId = fellowApp.Id;
            fw.contactId = fellowApp.Applicant__c;
            fw.firstName = fellowApp.Applicant__r.FirstName;
            fw.lastName = fellowApp.Applicant__r.LastName;
            fw.email = fellowApp.Applicant__r.Email;
            fw.phone = fellowApp.Applicant__r.Phone;
            fw.permanentStreetAddressLine1 = fellowApp.Applicant__r.MailingStreet;
            fw.permanentStreetAddressLine2 = fellowApp.Applicant__r.Permanent_Street_Address_Line_2__c;
            fw.mailingState = fellowApp.Applicant__r.MailingState;
            fw.mailingCity = fellowApp.Applicant__r.MailingCity;
            fw.mailingCountry = fellowApp.Applicant__r.MailingCountry;
            fw.mailingPostalCode = fellowApp.Applicant__r.MailingPostalCode;
            fw.fellowshipApplyingFor = fellowApp.Fellowship_Applying_for__c;
            fw.pronouns = fellowApp.Pronouns__c;
            fw.howDidYouFindUs = fellowApp.How_Did_You_Find_Us__c;
            fw.howDidYouFindUsIfOther = fellowApp.How_did_find_out_about_EDF_Other__c;
            fw.returnerFellow = fellowApp.Returner_Fellow__c;
            fw.gender = fellowApp.Sex__c;
            fw.genderSelfDescribe = fellowApp.Sex_Self_Describe__c;
            fw.race = fellowApp.Race__c;
            fw.latinxOrHispanic = fellowApp.Do_you_identify_as_Latinx_or_Hispanic__c;
            fw.veteranStatus = fellowApp.Veteran_Status__c;
            fw.fellowApplicationId = fellowApp.Id;
            //EducationInformation
            fw.graduateUniversity = fellowApp.University_School_1__r.Name; // fellowApp.University_School_1__c;
            fw.schoolWithinUniversity = fellowApp.GRAD_School_within_University__r.Name; // GRAD_School_within_University__c;
            fw.schoolUniversityOther = fellowApp.University_Other_1__c;
            fw.graduateDegree = fellowApp.GRAD_Degree_s_pursuing__c;
            fw.graduateDegreeOther = fellowApp.GRAD_Degree_s_if_not_listed__c;
            fw.graduateDegreeConcentration = fellowApp.GRAD_Degree_Concentration__c;
            if(fellowApp.Graduation_Start_Date__c != null){
                datetime gradStartdate= Date.Valueof(fellowApp.Graduation_Start_Date__c);
                fw.graduateDegreeStartDate = gradStartdate.format('MM/dd/YYYY');
            }
            if(fellowApp.Date_Expected_Graduated_1__c != null){
                datetime dateExpected= Date.Valueof(fellowApp.Date_Expected_Graduated_1__c);
                fw.expectedGraduationDate = dateExpected.format('MM/dd/YYYY');
            }
            fw.undergraduateUniversity = fellowApp.University_School_2__r.Name; // University_School_2__c;
            fw.undergraduateUniversityOther = fellowApp.University_Other_2__c;
            fw.undergraduateDegreeEarned = fellowApp.Degree_Earned_2__c;
            fw.undergraduateDegreeEarnedOther = fellowApp.UG_Degree_s_if_not_listed__c;
            fw.undergradMajor = fellowApp.Undergrad_Major__c;
            fw.otherCoursesCertifications = fellowApp.Other_courses_certifications__c;
            //BackgroundInformation
            fw.authorizedWorkUS = fellowApp.US_Resident__c;
            fw.requireAuthorization = fellowApp.Are_you_eligible_to_work_in_U_S_in_summ__c;
            fw.yearsOfExperience = fellowApp.Years_of_Experience_from_App__c;
            fw.financialAnalysis = fellowApp.ExperienceAdvancedFinancialAnalysis__c;
            fw.greenhouseGasAccounting = fellowApp.Experience_Greenhouse_Gas_Accounting__c;
            fw.dataAnalysis = fellowApp.ExperienceExtensiveExcelAataAnalysis__c;
            fw.supplyChain = fellowApp.Experience_Supply_Chain__c;
            fw.energyEfficiencyRenewables = fellowApp.ExperienceRenewables__c;
            //MatchPreferences
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
            //CoverLetter
            fw.coverLetter = fellowApp.Cover_Letter__c;
            fw.additionalInformation = fellowApp.Additional_Information__c;
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

            fw.fellowApp = fellowApp;

            return fw;

         }

        return fw;
    }

    /* public class FellowApplicationObj {
        List<FellowApplicationPageRow> rows = new List<FellowApplicationPageRow>();
        String jsonStr = '{"Contact Information":[{"label":"First Name","value":"firstName"},{"label":"Last Name","value":"lastName"},{"label":"Email","value":"email"},{"label":"Pronouns","value":"pronouns"},{"label":"Pronouns Self Describe","value":"Pronouns_Self_Describe__c","render":[{"value":"pronouns","match":"Prefer to self-describe","compare":"eq"}]},{"label":"Pronouns","value":"pronouns"},{"label":"Pronouns","value":"pronouns"},{"label":"Pronouns","value":"pronouns"},{"label":"Pronouns","value":"pronouns"},{"label":"Pronouns","value":"pronouns"},{"value":"phone","label":"Phone"},{"value":"mailingCountry","label":"Country"},{"value":"permanentStreetAddressLine1","label":"Label__streetname1"},{"value":"permanentStreetAddressLine2","label":"Label__streetname2"},{"value":"mailingCity","label":"City"},{"value":"mailingState","label":"State"},{"value":"mailingPostalCode","label":"Postal Code"},{"value":"fellowshipApplyingFor","label":"Which Fellowship are you applying to?"},{"label":"Label__Skype_label","value":"Skype__c","render":[{"value":"fellowshipApplyingFor","match":"China Fellowship","compare":"eq"}],"renderCondition":"OR"},{"value":"howDidYouFindUs","label":"How did you find out about Climate Corps?"},{"value":"How_Campus_Presentation__c","label":"How did you learn about the Campus Presentation?","render":[{"value":"How_Did_You_Find_Us__c","match":"Campus Presentation with EDF staff","compare":"eq"},{"value":"How_Did_You_Find_Us__c","match":"Campus Presentation with former Fellow","compare":"eq"}],"renderCondition":"OR"},{"value":"howDidYouFindUsIfOther","label":"If other, please describe","render":[{"value":"howDidYouFindUs","match":"Other (please specify)","compare":"eq"}]},{"value":"returnerFellow","label":"Have you participated in the Climate Corps program in the past?"},{"value":"Label__Contact_Information_Disclaimer","heading":"hdngs"},{"value":"gender","label":"Gender Identity"},{"value":"genderSelfDescribe","label":"Gender, Self Describe","render":[{"value":"gender","match":"Prefer to self-describe","compare":"eq"}]},{"value":"race","label":"Race/Ethnicity","render":[{"value":"fellowshipApplyingFor","match":"India Fellowship","compare":"neq"}]},{"value":"latinxOrHispanic","label":"Do you identify as Latinx or Hispanic?","render":[{"value":"fellowshipApplyingFor","match":"India Fellowship","compare":"neq"}]},{"value":"veteranStatus","label":"Veteran Status","render":[{"value":"fellowshipApplyingFor","match":"India Fellowship","compare":"neq"}]}],"Education Information":[{"value":"graduateUniversity","label":"Graduate University"},{"value":"schoolWithinUniversity","label":"School within University"},{"value":"schoolUniversityOther","label":"School / University, if not listed above"},{"value":"fApp_GRAD_University_Dual_Degree","label":"Dual Degree University"},{"value":"GRAD_Dual_Degree_School_in_University__c","label":"School within University"},{"value":"Dual_Degree_School_Name__c","label":"School / University, if not listed above"},{"value":"graduateDegree","label":"Graduate Degree(s) you are Pursuing"},{"value":"graduateDegreeOther","label":"Graduate Degree(s), if not listed above"},{"value":"graduateDegreeConcentration","label":"Graduate Degree Concentration(s)"},{"value":"Graduation_Start_Date__c","label":"Graduate Degree Start Date","dtFormat":"MM/dd/yyyy"},{"value":"graduateDegreeStartDate","label":"Graduate Degree Start Date"},{"value":"Date_Expected_Graduated_1__c","label":"Expected Graduation Date","dtFormat":"MM/dd/yyyy"},{"value":"expectedGraduationDate","label":"Expected Graduation Date"},{"value":"&nbsp;","heading":"nohighlight"},{"value":"undergraduateUniversity","label":"Undergraduate University"},{"value":"undergraduateUniversityOther","label":"Undergraduate University, if not listed above"},{"value":"undergraduateDegreeEarned","label":"Undergraduate Degree(s) earned"},{"value":"undergraduateDegreeEarnedOther","label":"Undergraduate Degree(s) earned, if not listed above"},{"value":"undergradMajor","label":"Undergraduate Major(s)"},{"value":"otherCoursesCertifications","label":"Label__Reword_certifications_question}"}]}';

        public FellowApplicationObj() {
            // Parse entire JSON response.
            JSONParser parser = JSON.createParser(jsonStr);
            while (parser.nextToken() != null) {
                // Start at the array of invoices.
                System.debug(parser.getCurrentName());
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        // Advance to the start object marker to
                        //  find next invoice statement object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            // Read entire invoice object, including its array of line items.
                            FellowApplicationPDFController.FellowApplicationPageRow inv = (FellowApplicationPDFController.FellowApplicationPageRow)parser.readValueAs(FellowApplicationPDFController.FellowApplicationPageRow.class);
                            System.debug('Invoice number: ' + inv);
                            // For debugging purposes, serialize again to verify what was parsed.
                            // String s = JSON.serialize(inv);
                            // System.debug('Serialized invoice: ' + s);

                            // Skip the child start array and start object markers.
                            parser.skipChildren();
                        }
                    }
                }
            }
        }

        public void addRow(FellowApplicationPageRow row) {
            rows.add(row);
        }

    }

    public class FellowApplicationPageRow {
        public String label {get; set;}
        public String value {get; set;}
        public Boolean display {get; set;}
        public String heading {get; set;}
        public List<RenderRow> render {get; set;}
        public String renderCondition {get; set;}

        public FellowApplicationPageRow(String label, String value, String heading, String renderCondition, List<RenderRow> rnder) {
            this.label = label;
            this.value = value;
            this.heading = heading;
            this.renderCondition = renderCondition;
            this.render = rnder.clone();
        }
    }

    public class RenderRow {
        public String match {get; set;}
        public String value {get; set;}
        public String compare {get; set;}

    } */


}