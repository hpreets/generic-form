/*
###########################################################################
# Created by............: Harpreet Singh (OSI)
# Created Date..........:
# Last Modified by......: Harpreet Singh (OSI)
# Last Modified Date....: 27-Feb-2023
# Description...........: Common Test Utlity class for creating test records
#
# Change Log (Date Descending)
#
############################################################################
*/
@isTest
public with sharing class TestFactory {


    /*
    * @author: Harpreet Singh
    * @description: This method is for assigning Fields to objects
    * @param  fieldNameValueMapping: To Store Test Data
    * @param  SObject: Test data belongs to which object
    */
    public static SObject assignFields(Map<String, Object> fieldNameValueMapping, SObject obj) {
        if(fieldNameValueMapping != null && !fieldNameValueMapping.IsEmpty()) {
            for (String key : fieldNameValueMapping.keyset()) {
                obj.put(key, fieldNameValueMapping.get(key));
            }
        }
        return obj;
    }

    public static String getSelectFields(SObjectType sObjType, List<String> addlSelectFields) {
        Schema.DescribeSObjectResult describe = sObjType.getDescribe();
        //for the Account object, you can replace that with any object you have, standard or custom
        Map<String, Schema.SObjectField> fields = describe.fields.getMap();

        String retVal = '';
        for(Schema.sObjectField fld : fields.values()) {
            System.debug(fld);
            if (retVal != '') retVal += ', ';
            retVal += '' + fld;
        }

        if (addlSelectFields != null) {
            for(String fld : addlSelectFields) {
                System.debug(fld);
                if (retVal != '') retVal += ', ';
                retVal += fld;
            }
        }

        return retVal;
    }

    public static String getWhereConditions(Map<String, Object> fieldNameValueMapping) {
        String retVal = '';
        if(fieldNameValueMapping != null && !fieldNameValueMapping.IsEmpty()) {
            for (String key : fieldNameValueMapping.keyset()) {

                if (retVal != '') retVal += ' AND ';
                String comparator = '=';
                if ( (fieldNameValueMapping.get(key) instanceOf String)  &&  ((String)fieldNameValueMapping.get(key)).endsWith('%\'')) {
                    comparator = ' LIKE ';
                }
                retVal += key + comparator + fieldNameValueMapping.get(key);
            }
        }
        return retVal;
    }

    public static String getOrderBy(List<String> orderByFields) {
        String retVal = '';
        if(orderByFields != null && !orderByFields.IsEmpty()) {
            for (String field : orderByFields) {

                if (retVal != '') retVal += ', ';
                retVal += field;
            }
        }
        return retVal;
    }

    public static Account createAccount(String name, Map<String,Object> fldMap, Boolean doInsert) {
        Account acc = new Account(Name=name);
        if (fldMap != null) {
            acc = (Account) TestFactory.assignFields(fldMap, acc);
        }
        if (doInsert) insert acc;
        return acc;
    }

    public static Contact createContact(Id accId, String lastName, Map<String,Object> fldMap, Boolean doInsert) {
        Contact cont = new Contact(AccountId=accId, LastName=lastName);
        if (fldMap != null) {
            cont = (Contact) TestFactory.assignFields(fldMap, cont);
        }
        if (doInsert) insert cont;
        return cont;
    }
    public static Contact retrieveContact(Map<String,Object> fldMap, List<String> addlSelectFields, List<String> orderByFields) {
        String selFields = TestFactory.getSelectFields(Contact.sObjectType, addlSelectFields);
        String whereConditions = TestFactory.getWhereConditions(fldMap);
        String qry = ' SELECT ' + selFields + ' FROM Contact ';
        if (whereConditions != '') qry += ' WHERE ' + whereConditions;
        if (orderByFields != null) qry += ' ORDER BY ' + TestFactory.getOrderBy(orderByFields);
        qry += ' LIMIT 1 ';
        System.debug('retrieveContact :: qry ::' + qry);

        Contact cont = (Contact) Database.query(qry);
        return cont;
    }

    public static Fellow_Application__c createFellowApplication(Id contId, Map<String,Object> fldMap, Boolean doInsert) {
        Fellow_Application__c fApp = new Fellow_Application__c(Applicant__c=contId);
        fApp.CC_Year__c = '' + System.today().year();
        fApp.Fellowship_Applying_for__c='U.S. Fellowship';

        if (fldMap != null) {
            fApp = (Fellow_Application__c) TestFactory.assignFields(fldMap, fApp);
        }
        if (doInsert) insert fApp;
        return fApp;
    }


    public static Climate_Corps_Engagement__c createEngagement(String name, Map<String,Object> fldMap, Boolean doInsert) {
        Climate_Corps_Engagement__c engg = new Climate_Corps_Engagement__c(Name=name);
        engg.Start_Date__c = System.today();
        engg.End_date__c = system.today().addDays(60);
        engg.CC_Year__c = '' + System.today().year();

        if (fldMap != null) {
            engg = (Climate_Corps_Engagement__c) TestFactory.assignFields(fldMap, engg);
        }
        if (doInsert) insert engg;
        return engg;
    }

    public static Climate_Corps_Engagement__c retrieveEngagement(Map<String, Object> fldMap, List<String> addlSelectFields, List<String> orderByFields) {
        String selFields = TestFactory.getSelectFields(Climate_Corps_Engagement__c.sObjectType, addlSelectFields);
        String whereConditions = TestFactory.getWhereConditions(fldMap);
        String qry = ' SELECT ' + selFields + ' FROM Climate_Corps_Engagement__c ';
        if (whereConditions != '') qry += ' WHERE ' + whereConditions;
        if (orderByFields != null) qry += ' ORDER BY ' + TestFactory.getOrderBy(orderByFields);
        qry += ' LIMIT 1 ';
        System.debug('retrieveEngagement :: qry ::' + qry);

        Climate_Corps_Engagement__c engg = (Climate_Corps_Engagement__c) Database.query(qry);
        return engg;
    }


    public static Contact_Email__c createContactEmail(Id contId, Map<String,Object> fldMap, Boolean doInsert) {
        Contact_Email__c contEmail = new Contact_Email__c(Donor__c=contId);
        contEmail.Type__c = 'Personal';
        contEmail.Primary__c = false;

        if (fldMap != null) {
            contEmail = (Contact_Email__c) TestFactory.assignFields(fldMap, contEmail);
        }
        if (doInsert) insert contEmail;
        return contEmail;
    }


    public static ContentVersion createContentVersion(Map<String,Object> fldMap, Boolean doInsert) {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.Deleted_By_Fellow__c = false;

        if (fldMap != null) {
            cv = (ContentVersion) TestFactory.assignFields(fldMap, cv);
        }
        if (doInsert) insert cv;
        return cv;
    }
    public static List<ContentVersion> createMultipleContentVersions(Map<String,Object> fldMap, Integer recCount, Boolean doInsert) {
        List<ContentVersion> cvList = new List<ContentVersion>();
        for (Integer ctr = 0; ctr < recCount; ctr++) {
            cvList.add(TestFactory.createContentVersion(fldMap, false));
        }

        for (Integer ctr = 0; ctr < recCount; ctr++) {
            cvList[ctr].Title += '_' + (ctr + 1);
            cvList[ctr].PathOnClient += '_' + (ctr + 1);
        }

        if (doInsert) insert cvList;
        return cvList;
    }
    public static ContentVersion updateContentVersion(Id cvId, Map<String,Object> fldMap, Boolean doUpdate) {
        ContentVersion cv = new ContentVersion(Id = cvId);

        if (fldMap != null) {
            cv = (ContentVersion) TestFactory.assignFields(fldMap, cv);
        }
        if (doUpdate) update cv;
        return cv;
    }
    public static ContentVersion retrieveContentVersion(Map<String, Object> fldMap, List<String> addlSelectFields, List<String> orderByFields) {
        String selFields = TestFactory.getSelectFields(ContentVersion.sObjectType, addlSelectFields);
        String whereConditions = TestFactory.getWhereConditions(fldMap);
        String qry = ' SELECT ' + selFields + ' FROM ContentVersion ';
        if (whereConditions != '') qry += ' WHERE ' + whereConditions;
        if (orderByFields != null) qry += ' ORDER BY ' + TestFactory.getOrderBy(orderByFields);
        qry += ' LIMIT 1 ';
        System.debug('retrieveContentVersion :: qry ::' + qry);

        ContentVersion cv = (ContentVersion) Database.query(qry);
        return cv;
    }

    public static ContentDocument retrieveContentDocument(Map<String, Object> fldMap, List<String> addlSelectFields, List<String> orderByFields) {
        String selFields = TestFactory.getSelectFields(ContentDocument.sObjectType, addlSelectFields);
        String whereConditions = TestFactory.getWhereConditions(fldMap);
        String qry = ' SELECT ' + selFields + ' FROM ContentDocument ';
        if (whereConditions != '') qry += ' WHERE ' + whereConditions;
        if (orderByFields != null) qry += ' ORDER BY ' + TestFactory.getOrderBy(orderByFields);
        qry += ' LIMIT 1 ';
        System.debug('retrieveContentDocument :: qry ::' + qry);

        ContentDocument cv = (ContentDocument) Database.query(qry);
        return cv;
    }


    public static ContentDocumentLink createContentDocumentLink(ContentVersion cv, Id conDocId, Id parentId, Map<String,Object> fldMap, Boolean doInsert) {
        if (conDocId == null) conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = conDocId;
        cdl.ShareType = 'V';
        cdl.Visibility ='AllUsers';

        if (fldMap != null) {
            cdl = (ContentDocumentLink) TestFactory.assignFields(fldMap, cdl);
        }
        if (doInsert) insert cdl;
        return cdl;
    }


    /**
     * Create multiple records of ContentDocumentLink sObject
     */
    public static List<ContentDocumentLink> createMultipleContentDocumentLinks(List<ContentVersion> cvList, List<Id> conDocIdList, Id parentId, Map<String,Object> fldMap, Boolean doInsert) {
        if (conDocIdList == null) {
            conDocIdList = new List<Id>();
            List<ContentVersion> internalCVList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvList];
            for (ContentVersion internalCV : internalCVList) {
                conDocIdList.add(internalCV.ContentDocumentId);
            }
        }

        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for (Integer ctr = 0; ctr < cvList.size(); ctr++) {
            cdlList.add(TestFactory.createContentDocumentLink(cvList[ctr], conDocIdList[ctr], parentId, fldMap, false));
        }

        if (doInsert) insert cdlList;
        return cdlList;
    }

    public static ContentDocumentLink retrieveContentDocumentLink(Map<String,Object> fldMap, List<String> addlSelectFields, List<String> orderByFields) {
        String selFields = TestFactory.getSelectFields(ContentDocumentLink.sObjectType, addlSelectFields);
        String whereConditions = TestFactory.getWhereConditions(fldMap);
        String qry = ' SELECT ' + selFields + ' FROM ContentDocumentLink ';
        if (whereConditions != '') qry += ' WHERE ' + whereConditions;
        if (orderByFields != null) qry += ' ORDER BY ' + TestFactory.getOrderBy(orderByFields);
        qry += ' LIMIT 1 ';
        System.debug('retrieveContentDocumentLink :: qry ::' + qry);

        ContentDocumentLink cdl = (ContentDocumentLink) Database.query(qry);
        return cdl;
    }


    public static User createUser(String email, String profileName, String firstName, String lastName, Id contactId, Map<String,Object> fldMap, Boolean doInsert) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        User usr = new User();
        usr.Alias = email.split('@')[0];
        usr.Email = email;
        usr.EmailEncodingKey='UTF-8';
        usr.LastName = lastName;
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US';
        usr.ProfileId = p.Id;
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.UserName = email;
        usr.FirstName = firstName;
        usr.ContactId = contactId;

        if (fldMap != null) {
            usr = (User) TestFactory.assignFields(fldMap, usr);
        }
        if (doInsert) insert usr;
        return usr;
    }


    public static User retrieveUser(Map<String,Object> fldMap, List<String> addlSelectFields, List<String> orderByFields) {
        String selFields = TestFactory.getSelectFields(User.sObjectType, addlSelectFields);
        String whereConditions = TestFactory.getWhereConditions(fldMap);
        String qry = ' SELECT ' + selFields + ' FROM User ';
        if (whereConditions != '') qry += ' WHERE ' + whereConditions;
        if (orderByFields != null) qry += ' ORDER BY ' + TestFactory.getOrderBy(orderByFields);
        qry += ' LIMIT 1 ';
        System.debug('retrieveUser :: qry ::' + qry);

        User usr = (User) Database.query(qry);
        return usr;
    }

}