public with sharing class CustomMetadataHelper {



    @AuraEnabled( cacheable=true )
    public static List <PortalFellowAppField__mdt> fetchPortalPageFieldDetails(String sectionName) {

        List < PortalFellowAppField__mdt > fieldList
            = [SELECT Id,
                    MasterLabel, DeveloperName, Order__c, Row_Type__c,
                    Field_Type__c, Field_Label__c, Field_API_Name__c,
                    Object_API_Name__c, Is_Mandatory__c,
                    Picklist_Values__c, User_Defined_Picklist_Values__c,
                    Section__c, Editable__c,
                    Parent_Field__c, Show_On_Value__c
                FROM PortalFellowAppField__mdt
                WHERE Section__c = :sectionName
                ORDER BY Order__c ASC];

        System.debug('fetchPortalPageFieldDetails :: fieldList :: ' + fieldList);
        for (PortalFellowAppField__mdt field : fieldList) {
            if (field.Field_Type__c == 'Picklist'  ||  field.Field_Type__c == 'PicklistWithOther') {
                if (field.User_Defined_Picklist_Values__c == null) {
                    field.User_Defined_Picklist_Values__c = CustomMetadataHelper.getPicklistValues(field.Object_API_Name__c, field.Field_API_Name__c);
                }
            }
        }
        System.debug('fetchPortalPageFieldDetails :: fieldList :: ' + fieldList);
        return fieldList;
    }


    public static String getPicklistValues(String objAPIName, String fieldName) {

        // List<String> lstPickvals = new List<String>();
        String picklistValues = '';
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objAPIName);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            // lstPickvals.add(a.getValue());//add the value  to our final list
            picklistValues += a.getValue() + ' | ';
        }

        return picklistValues.left(picklistValues.length() - 2);
    }


    @AuraEnabled
    public static string updateFellowApplication(Fellow_Application__c fApp, Contact cont) {
        update fApp;
        update cont;
        return 'success';
    }

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

    @AuraEnabled
    public static Contact getContactInfo() {
        String contactId = getContactId();
        Contact[] contList = [SELECT Id, Name,
                                FirstName,
                                LastName,
                                Email,
                                Phone,
                                MailingStreet,
                                Permanent_Street_Address_Line_2__c,
                                MailingCity,
                                MailingState,
                                MailingCountry,
                                MailingPostalCode FROM Contact WHERE Id = :contactId];
        return contList.get(0);
    }

    @AuraEnabled
    public static Fellow_Application__c getFellowAppInfo() {
        String contactId = getContactId();
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
		List<string> mailingStreets = new List<string>();
        Fellow_Application__c[] fellowApps = [SELECT Id,
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

        return fellowApps.get(0);
    }

}