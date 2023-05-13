/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 1/2/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: This Class contains Edit Contact Info Related functinality.
# Test Class............: EdfContactController_Test
# Change Log:
#
############################################################################
*/
public with sharing class EdfContactController {
	/**
    * Description : This method returns the Contact of the current loggin user associated record.
    **/
    @AuraEnabled (cacheable=true)
    public static ContactWrapper getContactForEDF(){
        return EdfContactController.getContact();
    }

    @AuraEnabled
    public static ContactWrapper getContact(){
        ContactWrapper cw = new ContactWrapper();
        String contactId = getContactId();
        Contact contact = [SELECT Id, Name, FirstName, LastName, Email,Phone, MailingStreet, Permanent_Street_Address_Line_2__c, MailingCity, MailingState, MailingCountry, MailingPostalCode, Resume__c, CC_Alumni_Group_Member__c, On_EDF_Connect_Platform__c FROM Contact WHERE Id =:contactId];

        // if(contact !=null)
        // {
            cw.id = contact.id;
            cw.firstName = contact.FirstName;
            cw.lastName = contact.LastName;
            cw.email = contact.Email;
            cw.phone = contact.Phone;
            cw.permanentStreetAddressLine1 = contact.MailingStreet;
            cw.permanentStreetAddressLine2 = contact.Permanent_Street_Address_Line_2__c;
            cw.mailingState = contact.MailingState;
            cw.mailingCity = contact.MailingCity;
            cw.mailingCountry = contact.MailingCountry;
            cw.mailingPostalCode = contact.MailingPostalCode;
            cw.countryPickListValues = getCountryPickListValues();
            if(!String.isBlank(contact.MailingCountry)){
                cw.statePickListValues = getStatePickListValuesByCountry(contact.MailingCountry);
            }
            else {
                cw.statePickListValues = getStatePickListValues();
            }
            cw.resume = contact.Resume__c;
            // cw.ccAlumniGrpMember = contact.CC_Alumni_Group_Member__c;
            // cw.onEdfConnectPlat = contact.On_EDF_Connect_Platform__c;
            cw.CC_Alumni_Group_Member = contact.CC_Alumni_Group_Member__c;
            cw.On_EDF_Connect_Platform = contact.On_EDF_Connect_Platform__c;
            cw.fellowApplicationId = getfellowApplicationId(contact.id);
        // }
        System.debug('EdfContactController getContact() :::' + cw);
        return cw;
    }
	/**
    * Description : This method returns the Contact of the current loggin user associated record.
    **/
    @AuraEnabled
    public static string updateContact(ContactWrapper contactWrapper){
        try {
            Id recordId = Id.valueOf(contactWrapper.id);
            Contact contact = [SELECT Id, Name, FirstName, LastName, Email,Phone, MailingStreet,Permanent_Street_Address_Line_2__c, MailingCity, MailingState, MailingCountry,MailingPostalCode,Resume__c FROM Contact WHERE Id =:recordId LIMIT 1];

             //if(contactList.size()>0){
                //for(Contact contact : contactList){
                    contact.FirstName = contactWrapper.firstName;
                    contact.LastName = contactWrapper.lastName;
                    contact.Email = contactWrapper.email;
                    contact.Phone = contactWrapper.phone;
                    contact.MailingStreet = contactWrapper.permanentStreetAddressLine1;
                    contact.Permanent_Street_Address_Line_2__c = contactWrapper.permanentStreetAddressLine2;
                    contact.MailingState = contactWrapper.mailingState;
                    contact.MailingCity = contactWrapper.mailingCity;
                    contact.MailingCountry = contactWrapper.mailingCountry;
                    contact.MailingPostalCode = contactWrapper.mailingPostalCode;
                    contact.Resume__c = contactWrapper.resume;
                 //}

                 upsert contact;
                 return 'contactWrapper.mailingCity:' + contactWrapper.mailingCity;
            //}

        }
        catch (Exception e) {
            //return 'Not updated';
            return e.getMessage();
        }
    }
	/**
    * Description : This method return the Fellow ApplicationId.
    **/

    @AuraEnabled
    public static string updateFellowApplication(FellowAppWrapper fellowAppWrapper){
        Boolean fellowAppSave = false;
        Boolean contactSave = false;
        // try {
            Id fellowAppId = Id.valueOf(fellowAppWrapper.fellowApplicationId);
            Id contactId = Id.valueOf(fellowAppWrapper.contactId);
            Fellow_Application__c[] fellowApps = [SELECT Id,
                                                Fellowship_Applying_for__c,
                                                Pronouns__c,
                                                Pronouns_Self_Describe__c,
                                                How_Did_You_Find_Us__c,
                                                How_did_find_out_about_EDF_Other__c,
                                                Returner_Fellow__c,
                                                Sex__c,
                                                Skype__c,
                                                Sex_Self_Describe__c,
                                                Race__c,
                                                Do_you_identify_as_Latinx_or_Hispanic__c,
                                                Veteran_Status__c,
                                                Applicant__c
                                            FROM
                                                Fellow_Application__c
                                            WHERE
                                                Id  =:fellowAppId];

            Contact[] contacts = [SELECT Id, Name, FirstName, LastName, Email,Phone, MailingStreet,Permanent_Street_Address_Line_2__c, MailingCity, MailingState, MailingCountry,MailingPostalCode FROM Contact WHERE Id =:contactId];

            if (fellowApps != null  &&  fellowApps.size() > 0){

                Fellow_Application__c fellowApp = fellowApps.get(0);

                fellowApp.Fellowship_Applying_for__c = fellowAppWrapper.fellowshipApplyingFor;
                fellowApp.Pronouns__c = fellowAppWrapper.pronouns;
                fellowApp.Pronouns_Self_Describe__c = fellowAppWrapper.pronounsSelfDescribe;
                fellowApp.How_Did_You_Find_Us__c = fellowAppWrapper.howDidYouFindUs;
                fellowApp.How_did_find_out_about_EDF_Other__c = fellowAppWrapper.howDidYouFindUsIfOther;
                fellowApp.Skype__c = fellowAppWrapper.skypeID;
                fellowApp.Returner_Fellow__c = fellowAppWrapper.returnerFellow;
                fellowApp.Sex__c = fellowAppWrapper.gender;
                fellowApp.Sex_Self_Describe__c = fellowAppWrapper.genderSelfDescribe;
                fellowApp.Race__c = fellowAppWrapper.race;
                fellowApp.Do_you_identify_as_Latinx_or_Hispanic__c = fellowAppWrapper.latinxOrHispanic;
                fellowApp.Veteran_Status__c = fellowAppWrapper.veteranStatus;

                update fellowApp;

                fellowAppSave = true;
            }

            if (contacts != null  &&  contacts.size() > 0){

                Contact contact = contacts.get(0);

                contact.FirstName = fellowAppWrapper.firstName;
                contact.LastName = fellowAppWrapper.lastName;
                contact.Email = fellowAppWrapper.email;
                contact.Phone = fellowAppWrapper.phone;
                contact.MailingCountry = fellowAppWrapper.mailingCountry;
                contact.MailingPostalCode = fellowAppWrapper.mailingPostalCode;
                contact.MailingState = fellowAppWrapper.mailingState;
                contact.MailingCity = fellowAppWrapper.mailingCity;
                contact.MailingStreet = fellowAppWrapper.permanentStreetAddressLine1;
                contact.Permanent_Street_Address_Line_2__c = fellowAppWrapper.permanentStreetAddressLine2;

                update contact;

                contactSave = true;
            }

            if(fellowAppSave && contactSave){
                return 'success';
            }

        // }
        // catch (Exception e) {
        //     //return 'Not updated';
        //     return e.getMessage();
        // }

        return 'fellowAppSave:' + fellowAppSave + '  contactSave: ' + contactSave + '  fellowAppId:' + fellowAppId;
    }
	/**
    * Description : This method returns the Countries in sorted order from 'Countries__c' custom settings.
    **/
    public static List<String> getCountryPickListValues(){
        // List<String> pickListValues= new List<String> {'USA', 'India', 'United Kingdom', 'Canada', 'China', 'Australia'};
        //  return pickListValues;

        List<String> pickListValues = new List<String>(Countries__c.getAll().keyset());
        pickListValues.sort();

        return pickListValues;
     }
    /**
    * Description : This method returns the states in sorted order from 'States__c' custom settings.
    **/
    public static List<String> getStatePickListValues(){
        // List<String> pickListValues= new List<String>{'Andhra Pradesh', 'Telangana','Tamil Nadu','Arunachal Pradesh', 'Maharashtra', 'Punjab'};
        // return pickListValues;

        List<String> pickListValues = new List<String>(States__c.getAll().keyset());
        pickListValues.sort();
        return pickListValues;
    }
	/**
    * Description : This method returns the states based on the country values selected.
    **/
    @AuraEnabled
    public static List<String> getStatePickListValuesByCountry(string country){
        List<String> pickListValues = new List<String>();
        if(!String.isBlank(country)){
            // Find all the states we have in custom settings.
            Map<String, States__c> allstates = States__c.getAll();
            // Filter states that belong to the selected country
            for(States__c state : allstates.values()) {
                if (state.Country__c == country) {
                    pickListValues.add(state.name);
                }
            }
        }

        if(pickListValues.size() > 0){
            pickListValues.sort();
        }

        return pickListValues;
    }
    /**
    * Description : This method returns the fellowapplication record in the form of FellowAppWrapper.
    **/
    @AuraEnabled
    public static FellowAppWrapper getContactInfo(){

        FellowAppWrapper fw = new FellowAppWrapper();
        String contactId = getContactId();
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
		List<string> mailingStreets = new List<string>();
        Fellow_Application__c[]  fellowApps = [SELECT Id,
                                Applicant__c,
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
                                Veteran_Status__c
                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  =:contactId AND CC_Year__c=:fellowshipYear];

        // if (fellowApps != null  &&  fellowApps.size() > 0){
        // {
            Fellow_Application__c fellowApp = fellowApps.get(0);
            fw.id = fellowApp.Id;
            fw.fellowApplicationId = fellowApp.Id;
            fw.contactId = fellowApp.Applicant__c;
            fw.firstName = fellowApp.Applicant__r.FirstName;
            fw.lastName = fellowApp.Applicant__r.LastName;
            fw.email = fellowApp.Applicant__r.Email;
            fw.phone = fellowApp.Applicant__r.Phone;
            if(fellowApp.Applicant__r.MailingStreet!=null && fellowApp.Applicant__r.MailingStreet.contains(',')){
                mailingStreets = fellowApp.Applicant__r.MailingStreet.split(',');
                System.debug('mailingStreets:'+mailingStreets);
                if(mailingStreets.size()>1){
                    fw.permanentStreetAddressLine1 = mailingStreets[0];
                    fw.permanentStreetAddressLine2 = mailingStreets[1]=='null'?'':mailingStreets[1];
                }
                else {
                    fw.permanentStreetAddressLine1 = fellowApp.Applicant__r.MailingStreet;
                }
            }
            else{
                fw.permanentStreetAddressLine1 = fellowApp.Applicant__r.MailingStreet;
            }
            fw.mailingState = fellowApp.Applicant__r.MailingState;
            fw.mailingCity = fellowApp.Applicant__r.MailingCity;
            fw.mailingCountry = fellowApp.Applicant__r.MailingCountry;
            fw.mailingPostalCode = fellowApp.Applicant__r.MailingPostalCode;
            fw.countryPickListValues = getCountryPickListValues();
            if(!String.isBlank(fellowApp.Applicant__r.MailingCountry)){
                fw.statePickListValues = getStatePickListValuesByCountry(fellowApp.Applicant__r.MailingCountry);
            }
            else {
                fw.statePickListValues = getStatePickListValues();
            }
            fw.fellowshipApplyingFor = fellowApp.Fellowship_Applying_for__c;
            fw.pronouns = fellowApp.Pronouns__c;
            fw.pronounsSelfDescribe = fellowApp.Pronouns_Self_Describe__c;
            fw.howDidYouFindUs = fellowApp.How_Did_You_Find_Us__c;
            fw.skypeID = fellowApp.Skype__c;
            fw.howDidYouFindUsIfOther = fellowApp.How_did_find_out_about_EDF_Other__c;
            fw.returnerFellow = fellowApp.Returner_Fellow__c;
            fw.gender = fellowApp.Sex__c;
            fw.genderSelfDescribe = fellowApp.Sex_Self_Describe__c;
            fw.race = fellowApp.Race__c;
            fw.latinxOrHispanic = fellowApp.Do_you_identify_as_Latinx_or_Hispanic__c;
            fw.veteranStatus = fellowApp.Veteran_Status__c;
            fw.fellowApplicationId = fellowApp.Id;

            return fw;

        //  }

        //return fw;
    }
	/**
    * Description : This method returns the fellowship appling for pick list values.
    **/
    public static List<String> getFellowshipApplyingForPickListValues(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Fellow_Application__c.Fellowship_Applying_for__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }
         return pickListValuesList;
     }
	/**
    * Description : This method returns the HowDidYouFindUs pick list values.
    **/
     public static List<String> getHowDidYouFindUsPickListValues(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Fellow_Application__c.How_Did_You_Find_Us__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }
         return pickListValuesList;

     }
	/**
    * Description : This method returns the ReturnerFellow pick list values.
    **/
     public static List<String> getReturnerFellowPickListValues(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Fellow_Application__c.Returner_Fellow__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }
         return pickListValuesList;

     }
	/**
    * Description : This method returns the Gender pick list values.
    **/
     public static List<String> getGenderPickListValues(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Fellow_Application__c.Sex__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }
         return pickListValuesList;

     }
	/**
    * Description : This method returns the DoYouIdentifyAsLatinxOrHispanic pick list values.
    **/
     public static List<String> getDoYouIdentifyAsLatinxOrHispanicPickListValues(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Fellow_Application__c.Do_you_identify_as_Latinx_or_Hispanic__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }
         return pickListValuesList;

     }
	/**
    * Description : This method returns the VeteranStatus pick list values.
    **/
     public static List<String> getVeteranStatusPickListValues(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Fellow_Application__c.Veteran_Status__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }
         return pickListValuesList;

     }
	/**
    * Description : This method returns the current logged in User Associated Contact ID.
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
	/**
    * Description : This method returns the Associated fellowApplication ID with respect to contactId.
    **/
    public static String getfellowApplicationId(String contactId) {
        String fellowApplicationId = '';
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        List<Fellow_Application__c> fellowAppList = [SELECT Id,
                                Applicant__c,
                                Status__c
                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  = :contactId AND CC_Year__c=:fellowshipYear LIMIT 1];
        if(!fellowAppList.isEmpty()){
            fellowApplicationId = fellowAppList[0].Id;
        }

        return fellowApplicationId;

    }
	/**
    * Description : This method returns the current logged in User Associated fellowApplication ID.
    **/
    @AuraEnabled(cacheable=true)
    public static String getfellowAppId() {
        String fellowApplicationId = '';
        String contactId = getContactId();
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        List<Fellow_Application__c> fellowAppList = [SELECT Id,
                                Applicant__c,
                                Status__c
                            FROM
                                Fellow_Application__c
                            WHERE
                                Applicant__c  = :contactId AND CC_Year__c=:fellowshipYear LIMIT 1];
        if(!fellowAppList.isEmpty()){
            fellowApplicationId = fellowAppList[0].Id;
        }

        return fellowApplicationId;

    }



}