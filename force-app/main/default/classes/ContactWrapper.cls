/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 1/3/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: Wrapper for Fellow Registration/Edit Contcat info.
# Test Class............: Test_WrapperControllers
# Change Log:
#
############################################################################
*/
public class ContactWrapper {
    @AuraEnabled
    public String id {get; set;}
    @AuraEnabled
    public String firstName {get; set;}
    @AuraEnabled
    public String lastName {get; set;}
    @AuraEnabled
    public String email {get; set;}
    @AuraEnabled
    public String phone {get; set;}
    @AuraEnabled
    public String permanentStreetAddressLine1 {get; set;}
    @AuraEnabled
    public String permanentStreetAddressLine2 {get; set;}
    @AuraEnabled
    public String mailingState {get; set;}
    @AuraEnabled
    public String mailingCity {get; set;}
    @AuraEnabled
    public String mailingCountry {get; set;}
    @AuraEnabled
    public String mailingPostalCode {get; set;}
    @AuraEnabled
    public String mailingStateDropdown {get; set;}
    @AuraEnabled
    public String mailingStreet {get; set;}
    @AuraEnabled
    public List<String> statePickListValues {get; set;}
    @AuraEnabled
    public List<String> countryPickListValues {get; set;}
    @AuraEnabled
    public String fellowshipApplyingFor {get; set;}
    @AuraEnabled
    public String pronouns {get; set;}
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
    public String latinxOrHispanic {get; set;}
    @AuraEnabled
    public String veteranStatus {get; set;}
    @AuraEnabled
    public String resume {get; set;}
    /* @AuraEnabled
    public Boolean ccAlumniGrpMember {get; set;}
    @AuraEnabled
    public Boolean onEdfConnectPlat {get; set;} */
    @AuraEnabled
    public String fellowApplicationId {get; set;}

    @AuraEnabled
    public Boolean CC_Alumni_Group_Member {get; set;}

    @AuraEnabled
    public Boolean On_EDF_Connect_Platform {get; set;}
}