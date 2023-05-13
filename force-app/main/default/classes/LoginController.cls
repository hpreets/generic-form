/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 12/21/2021
# Last Modified by......:
# Last Modified Date....:
# Description...........: Login Functinality Controller.
# Test Class............: LoginController_Test
# Change Log:
#
############################################################################
*/
public without sharing class LoginController {

    @AuraEnabled
    public static boolean login(String strUsername,String strPassword){
        system.debug('strUsername'+strUsername);
        system.debug('strPassword'+strPassword);
        integer UserCount=[select count() from user where Username=:strUsername limit 1];
        if (UserCount>0){
            system.debug('in');
           // PageReference empRedirect = Site.login(strUsername, strPassword,'/loginRedirectPage');
            return true;
        }else{
            system.debug('out');
            return false;
        }

    }

    @AuraEnabled(cacheable=true)
    public static UserWrapper getUserDetails(){
        UserWrapper uw = new UserWrapper();
        string userName = '';
        String currUserId = Userinfo.getUserId();
        //String currUserId = '0051D000009L6tBQAS';
        User[] users = fetchCommunityUser(currUserId);
        if (users != null  &&  users.size() > 0){
            User user = users.get(0);
            uw.id = user.Id;
            uw.userName = user.Firstname + ' ' + user.LastName;
        }

        //userName = currUserId;
        return uw;

    }

    @AuraEnabled(cacheable=true)
    public static String getUserName(){
        string userName = '';
        String currUserId = Userinfo.getUserId();
        User[] users = fetchCommunityUser(currUserId);
        if (users != null  &&  users.size() > 0){
            User user = users.get(0);
            userName = 'Welcome, ' + user.Firstname + ' ' + user.LastName;
        }

        return userName;

    }

    @AuraEnabled(cacheable=true)
    public static String getApplicationStatusForLogin(){
        String applicationStatus = '';
        String currUserId = Userinfo.getUserId();
        User[] users = fetchCommunityUser(currUserId);
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        if (users != null  &&  users.size() > 0){
            User user = users.get(0);
            String contactId = user.ContactId;
			System.debug('contactId:'+contactId);
            List<Fellow_Application__c> fellowAppList = [SELECT Id,
                                    Applicant__c,
                                    Status__c
                                FROM
                                    Fellow_Application__c
                                WHERE
                                    Applicant__c  = :contactId AND CC_Year__c=:fellowshipYear LIMIT 1];
            System.debug('fellowAppList:'+fellowAppList);
            if(!fellowAppList.isEmpty()){
                //applicationStatus = getFellowApplicationStatusValue(fellowAppList[0].Status__c);
                applicationStatus = fellowAppList[0].Status__c;
            }
        }

        return applicationStatus;

    }

    @AuraEnabled(cacheable=true)
    public static String getApplicationStatus(){
        String applicationStatus = '';
        String currUserId = Userinfo.getUserId();
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        User[] users = fetchCommunityUser(currUserId);
        if (users != null  &&  users.size() > 0){
            User user = users.get(0);
            String contactId = user.ContactId;
			System.debug('contactId:'+contactId);
            List<Fellow_Application__c> fellowAppList = [SELECT Id,
                                    Applicant__c,
                                    Status__c
                                FROM
                                    Fellow_Application__c
                                WHERE
                                    Applicant__c  = :contactId AND CC_Year__c=:fellowshipYear LIMIT 1];
            System.debug('fellowAppList:'+fellowAppList);
            if(!fellowAppList.isEmpty()){
                applicationStatus = 'Application Status: ' + getFellowApplicationStatusValue(fellowAppList[0].Status__c);
            }
        }

        return applicationStatus;

    }

    @AuraEnabled(cacheable=true)
    public static String getApplicationStatusValue(){
        String applicationStatus = '';
        String currUserId = Userinfo.getUserId();
        User[] users = fetchCommunityUser(currUserId);
        String fellowshipYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        if (users != null  &&  users.size() > 0){
            User user = users.get(0);
            String contactId = user.ContactId;
			System.debug('contactId:'+contactId);
            List<Fellow_Application__c> fellowAppList = [SELECT Id,
                                    Applicant__c,
                                    Status__c
                                FROM
                                    Fellow_Application__c
                                WHERE
                                    Applicant__c  = :contactId AND CC_Year__c=:fellowshipYear LIMIT 1];
            System.debug('fellowAppList:'+fellowAppList);
            if(!fellowAppList.isEmpty()){
                applicationStatus = getFellowApplicationStatusValue(fellowAppList[0].Status__c);
            }
        }

        return applicationStatus;

    }

    public static String getFellowApplicationStatusValue(String key) {
        String retVal = '';
        System.debug('Key:::::::' + key);
        if (key == null  ||  key == ''){
            key = '--';
            retVal = key;
        }

        // These two are hard-coded since there is 38 character limit on Custom Settings name
        // https://sites.secure.force.com/success/issues_view?id=a1p30000000Rq4hAAC
        if (key == 'Engagement Confirmed + Email Sent to OCS') {
            retVal = 'Engagement Confirmed';
        }
        else if (key == 'Declined after Interview 1 and before Interview 2') {
            retVal = 'Application Withdrawn';
        }
        else if (FellowApplicationStatus__c.getAll().get(key) != null) {
            retVal = FellowApplicationStatus__c.getAll().get(key).StatusName__c;
            if (retVal == null  ||  retVal == ''){
                retVal = key;
            }
        }
        System.debug('retVal:::::::' + retVal);
        return retVal;
    }

    public static User[] fetchCommunityUser(String currUserId) {
        return [SELECT Id, FirstName, LastName, Contact.Name, username, ContactId, email, Contact.Salutation
                        FROM User WHERE Id = :currUserId and ContactId <> null];
        // return [SELECT Id, FirstName, LastName, Contact.Name, username, ContactId, email
        //                 FROM User WHERE Id = :currUserId];
    }

    // @AuraEnabled
    // public static boolean forgotPasswordByEmail(String email) {
    //     System.debug('email:'+email);
    //     User[] users = [SELECT Id, name, firstName, lastName, alias, Username, email, Profile.Name, IsActive FROM User WHERE email = :email and Profile.Name = 'Fellow Portal Community User' LIMIT 1];
    //     System.debug('users:'+users);

    //     if(users!= null && users.size()>0){
    //         User user = users[0];
    //         system.debug('Username:' + user.Username);
    //         boolean reset = Site.forgotPassword(user.Username);
    //         system.debug('reset:' + reset);

    //         return reset;
    //     }

    //     return false;
    // }

    @AuraEnabled
    public static String forgotPasswordByEmail(String email) {
        String response = '';

        //response = email;
        System.debug('email:'+email);
        User[] users = [SELECT Id, name, firstName, lastName, alias, Username, email, Profile.Name, IsActive FROM User WHERE email = :email];
        System.debug('users:'+users);

        if(users!= null && users.size()>0){
            User user = users[0];
            system.debug('Username:' + user.Username);
            boolean reset = Site.forgotPassword(user.Username);
            system.debug('reset:' + reset);

            if(reset){
                response = 'success';
            }
        }

        return response;
    }

    public static String getUsernameByEmail(String email) {
        String username = '';
        System.debug('email:'+email);
        User[] users = [SELECT  Username, email, Profile.Name, IsActive FROM User WHERE email = :email and Profile.Name = 'Fellow Portal Community User' and IsActive = true];
        System.debug('users:'+users);

        if(users!= null && users.size()>0){
            User user = users[0];
            system.debug('Username:' + user.Username);
            username = user.Username;
        }

        return username;
    }

    // FB-2039
    @AuraEnabled(cacheable=true)
    public static Boolean isDeadlinePassed() {
        return FellowAppController.isDeadlinePassed();
    }
}