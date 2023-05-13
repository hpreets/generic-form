public without sharing class UniversityHelper {

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


    @AuraEnabled
    public static Fellow_Application__c updateEducationInformation(Fellow_Application__c fa) {
        System.debug('UniversityHelper :: updateEducationInformation :: fa ::' + fa);
        Fellow_Application__c fApp = new Fellow_Application__c();
        fApp.Id = fa.Id;
        fApp.University_School_1__c = fa.University_School_1__c;
        fApp.GRAD_School_within_University__c = fa.GRAD_School_within_University__c;
        fApp.University_Other_1__c = fa.University_Other_1__c;
        fApp.GRAD_University_Dual_Degree__c = fa.GRAD_University_Dual_Degree__c;
        fApp.GRAD_Dual_Degree_School_in_University__c = fa.GRAD_Dual_Degree_School_in_University__c;
        fApp.Dual_Degree_School_Name__c = fa.Dual_Degree_School_Name__c;
        fApp.GRAD_Degree_s_pursuing__c = fa.GRAD_Degree_s_pursuing__c;
        fApp.GRAD_Degree_s_if_not_listed__c = fa.GRAD_Degree_s_if_not_listed__c;
        fApp.GRAD_Degree_Concentration__c = fa.GRAD_Degree_Concentration__c;
        fApp.Graduation_Start_Date__c = fa.Graduation_Start_Date__c;
        fApp.Date_Expected_Graduated_1__c = fa.Date_Expected_Graduated_1__c;
        fApp.University_School_2__c = fa.University_School_2__c;
        fApp.University_Other_2__c = fa.University_Other_2__c;
        fApp.Degree_Earned_2__c = fa.Degree_Earned_2__c;
        fApp.UG_Degree_s_if_not_listed__c = fa.UG_Degree_s_if_not_listed__c;
        fApp.Undergrad_Major__c = fa.Undergrad_Major__c;
        fApp.Other_courses_certifications__c = fa.Other_courses_certifications__c;
        update fApp;
        return fApp;
    }
}