/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 2/27/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: Wrapper for Fellow Application Registration.
# Test Class............: Test_WrapperControllers
# Change Log:
#
############################################################################
*/
public class FellowAppWrapper {

    @AuraEnabled
    public String id {get; set;}

    @AuraEnabled
    public String fellowApplicationId {get; set;}

    @AuraEnabled
    public String contactId {get; set;}

    @AuraEnabled
    public String fellowshipApplyingFor {get; set;}

    @AuraEnabled
    public String firstName {get; set;}

    @AuraEnabled
    public String lastName {get; set;}

    @AuraEnabled
    public String email {get; set;}

    @AuraEnabled
    public String pronouns {get; set;}

    @AuraEnabled
    public String pronounsSelfDescribe {get; set;}

    @AuraEnabled
    public String phone {get; set;}

    @AuraEnabled
    public String mailingCountry {get; set;}

    @AuraEnabled
    public String mailingPostalCode {get; set;}

    @AuraEnabled
    public String mailingState {get; set;}

    @AuraEnabled
    public String mailingCity {get; set;}

    @AuraEnabled
    public String permanentStreetAddressLine1 {get; set;}

    @AuraEnabled
    public String permanentStreetAddressLine2 {get; set;}

    @AuraEnabled
    public String skypeID {get; set;}

    @AuraEnabled
    public String howDidYouFindUs {get; set;}

    @AuraEnabled
    public String howDidYouFindUsIfOther {get; set;}

    @AuraEnabled
    public String returnerFellow {get; set;}

    @AuraEnabled
    public String gender {get; set;}

    @AuraEnabled
    public String genderSelfDescribe {get; set;}

    @AuraEnabled
    public String race {get; set;}

    @AuraEnabled
    public String latinxOrHispanic {get; set;}

    @AuraEnabled
    public String veteranStatus {get; set;}

    @AuraEnabled
    public List<String> statePickListValues {get; set;}

    @AuraEnabled
    public List<String> countryPickListValues {get; set;}

    // EducationInformation
    @AuraEnabled
    public String graduateUniversity {get; set;}

    @AuraEnabled
    public String schoolWithinUniversity {get; set;}

    @AuraEnabled
    public String schoolUniversityOther {get; set;}

    @AuraEnabled
    public String dualGraduateUniversity {get; set;}

    @AuraEnabled
    public String schoolWithinDualUniversity {get; set;}

    @AuraEnabled
    public String schoolDualUniversityOther {get; set;}

    @AuraEnabled
    public String graduateDegree {get; set;}

    @AuraEnabled
    public String graduateDegreeOther {get; set;}

    @AuraEnabled
    public String graduateDegreeConcentration {get; set;}

    @AuraEnabled
    public String graduateDegreeStartDate {get; set;}

    @AuraEnabled
    public String expectedGraduationDate {get; set;}

    @AuraEnabled
    public String undergraduateUniversity {get; set;}

    @AuraEnabled
    public String undergraduateUniversityOther {get; set;}

    @AuraEnabled
    public String undergraduateDegreeEarned {get; set;}

    @AuraEnabled
    public String undergraduateDegreeEarnedOther {get; set;}

    @AuraEnabled
    public String undergradMajor {get; set;}

    @AuraEnabled
    public String otherCoursesCertifications {get; set;}

    //Background Information
    @AuraEnabled
    public String authorizedWorkUS {get; set;}

    @AuraEnabled
    public String  requireAuthorization {get; set;}

    @AuraEnabled
    public String  nativeEnglishSpeaker {get; set;}

    @AuraEnabled
    public String  photoIdentification {get; set;}

    @AuraEnabled
    public String  residencyInChina {get; set;}

    @AuraEnabled
    public String  ChinaFellowshipTests {get; set;}

    @AuraEnabled
    public Boolean  passportCheckboxVal {get; set;}

    @AuraEnabled
    public String  ChinaFellowshipTestScore {get; set;}

    @AuraEnabled
    public String yearsOfExperience {get; set;}

    @AuraEnabled
    public String financialAnalysis {get; set;}

    @AuraEnabled
    public String greenhouseGasAccounting {get; set;}

    @AuraEnabled
    public String dataAnalysis {get; set;}

    @AuraEnabled
    public String supplyChain {get; set;}

    @AuraEnabled
    public String energyEfficiencyRenewables {get; set;}

    //Match Preferences
    @AuraEnabled
    public Boolean applyIndia {get; set;}
    @AuraEnabled
    public Boolean applyChina {get; set;}
    @AuraEnabled
    public String regionsInIndia {get; set;}
    @AuraEnabled
    public String regionsInChina {get; set;}
    @AuraEnabled
    public String regionsInUS {get; set;}
    @AuraEnabled
    public String usRegionalPreferences {get; set;}
    @AuraEnabled
    public String validUSDriversLicense {get; set;}
    @AuraEnabled
    public String accessToVehicle {get; set;}
    @AuraEnabled
    public String sectorFirstChoice {get; set;}
    @AuraEnabled
    public String sectorSecondChoice {get; set;}
    @AuraEnabled
    public String sectorThirdChoice {get; set;}
    @AuraEnabled
    public String projectTypePreferenceOne {get; set;}
    @AuraEnabled
    public String projectTypePreferenceTwo {get; set;}
    @AuraEnabled
    public String projectTypePreferenceThree {get; set;}

    //Cover Letter
    @AuraEnabled
    public String coverLetter {get; set;}

    @AuraEnabled
    public String additionalInformation {get; set;}

    @AuraEnabled
    public String resumeName {get; set;}

    @AuraEnabled
    public String referenceEmail1 {get; set;}

    @AuraEnabled
    public String referenceEmail2 {get; set;}

    @AuraEnabled
    public String referenceEmail3 {get; set;}

    @AuraEnabled
    public String referenceName1 {get; set;}

    @AuraEnabled
    public String referenceName2 {get; set;}

    @AuraEnabled
    public String referenceName3 {get; set;}

    @AuraEnabled
    public String referencePhone1 {get; set;}

    @AuraEnabled
    public String referencePhone2 {get; set;}

    @AuraEnabled
    public String referencePhone3 {get; set;}

    @AuraEnabled
    public String referenceTitle1 {get; set;}

    @AuraEnabled
    public String referenceTitle2 {get; set;}

    @AuraEnabled
    public String referenceTitle3 {get; set;}

    @AuraEnabled
    public String referenceSpecialInstructions1 {get; set;}

    @AuraEnabled
    public String referenceSpecialInstructions2 {get; set;}

    @AuraEnabled
    public String referenceSpecialInstructions3 {get; set;}

    @AuraEnabled
    public Fellow_Application__c fellowApp {get; set;}

}