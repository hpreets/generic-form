/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 12/21/2021
# Last Modified by......:
# Last Modified Date....: 
# Description...........: Portal Registartion Congtroler.
# Test Class............: EDF28_RegisterController_Test
# Change Log:
# 
############################################################################
*/
public without sharing class EDF28_RegisterController {
    public static Boolean isUserActive;
    public static String sendRedirectMessage = '';
    public static Contact savedContact;
    public static Contact fAppContact;
    public static Contact_Email__c cEmailMatchingFellowEmail;
    public static Contact_Wrapper contWrapper ;
    
    @AuraEnabled
    public static Boolean isEmailExists(String email){
        System.debug('email:'+email);
        Boolean contactExists = false;
        Boolean fellowAlreadyExists = false;
        Boolean createNewRecords = true;
        Database.UpsertResult ur = null;
        String errMsg = ''; 
        String currFellowshipYear = getCurrentFellowshipYear();
        System.debug('currFellowshipYear:'+currFellowshipYear);
        
       /* 
        * Check if any contact with same email address exists. 
        * TODO: If contact exists, check the user. 
        * TODO: If user exists, activate the user and send a mail about his 
        * username and how to reset the password. 
        */
        //changing - email id paramter getEmail
        Contact existingContact = isContactExist(email); // (getContact().Email);
        if (existingContact != null) contactExists = true;
        System.debug('existingContact'+existingContact);
        System.debug('contactExists are not:'+contactExists);
        //System.debug('getContact().Email :::'+getContactWrapper().getEmail()); // getContact().Email);
        //
        Fellow_Application__c existingFellowApp 
            = isFellowAppExist(email, 
                               currFellowshipYear, 
                               // giving a fake Contact Id, otherwise it would 
                               // search for Fellow App record with null Contact.
                               existingContact==null?null:existingContact.Id);
        System.debug('existingFellowApp---'+existingFellowApp);
        System.debug('getContact().Email :::'+email);
        System.debug('existingFellowApp.Id:::'+existingFellowApp);
        if (existingFellowApp != null  /* &&  stdController.userDetails == null*/) {
            if (/*stdController.fApp.Id!=*/existingFellowApp.Id!=null) {
                /*ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.severity.ERROR, 
                        EDF02_CustomMetadata_Helper.getStudentMessage('APP_ALREADY_REG_CURR_YEAR')));*/
                SendExistingUserEmail(email);
                sendRedirectMessage = 'APP_ALREADY_REG_CURR_YEAR';
                // Display proper message on UI.
                return fellowAlreadyExists = true;
                //return null;
            }
        }
        /* 
* Handle scenario where Fellow comes back for a next year fellowship. 
* His Contact is already present but current year Fellow App record is 
* not present. This code-block creates a new Fellow App record and 
* sends a mail to fellow.
* 
* Another scenario specific to EDF org is that the Contact is already present
* but the email address is not the primary email address. For that case too
* the Fellow App should be created, User be created for the email address
* that Fellow mentioned (even though it is not the primary email address)
* and email be sent.
*/
        else if (existingContact != null /* &&  stdController.userDetails == null*/) {
            System.debug('getContactWrapper().getEmail() :::'+email);
            String userEnteredEmail = email;
            
            System.debug('Inside Loop existingContact != null  &&  stdController.userDetails == null');
            savedContact = existingContact;
            setFAppContact(existingContact);
            //ur = saveFellowApp(withSubmit);
            //System.debug('saveFellowApp ur:::' + ur);
            sendRedirectMessage = 'APP_ALREADY_REG_PREV_YEAR';
            
            Fellow_Application__c fApp = new Fellow_Application__c();
            fApp.Applicant__c = existingContact.Id;
            fApp.Status__c = 'Prospective Applicant';
            fApp.Fellow_Applicant_Email__c = email;
            fApp.CC_Year__c = getCurrentFellowshipYear();
            Database.insert(fApp);
            
            // Code changes by Harpreet on 8/27 to handle scenario specific to EDF Org. (Details mentioned above)
            System.debug('cEmailMatchingFellowEmail ::' + cEmailMatchingFellowEmail);
            if (cEmailMatchingFellowEmail != null) { // This var is set in isContactExist method
                Contact_Email__c ce
                    = new Contact_Email__c(
                        Id=cEmailMatchingFellowEmail.Id, 
                        Created_from_Fellow_App__c=TRUE);
                // update ce;
                updateContactEmail(ce);
                System.debug('ce ::' + ce);
            }
            
            Boolean emailSame = true;
            String originalEmail = existingContact.Email;
            System.debug('userEnteredEmail ::' + userEnteredEmail);
            System.debug('getContactWrapper().getEmail() ::' + email);
            System.debug('existingContact.Email ::' + existingContact.Email);
            if (userEnteredEmail != existingContact.Email) {
                emailSame = false;
                Contact tbu = new Contact(Id=existingContact.Id, Email=userEnteredEmail);
                // update tbu;
                updateContactRecord(tbu);
                System.debug('1. tbu ::' + tbu);
            }
            
            try {
                SendExistingUserEmail(userEnteredEmail);
                System.debug('SendExistingUserEmail DONE ::');
                System.debug('isUserActive:'+isUserActive);
                if (!isUserActive) saveUser(existingContact, userEnteredEmail);
            }
            catch (Exception e) {
                
            }
            
            if (!emailSame) {
                Contact tbu = new Contact(Id=existingContact.Id, Email=originalEmail);
                // update tbu;
                updateContactRecord(tbu);
                System.debug('2. tbu ::' + tbu);
            }
            // Display proper message on UI.
            System.debug('fellowAlreadyExists ::' + fellowAlreadyExists);
            return fellowAlreadyExists = true;
        }
        return null;
    }
    
    public static Contact isContactExist(String emailAdd) {
        System.debug('emailAdd ::'+emailAdd);
        
        List<Contact_Email__c> conEmailFound 
            = [SELECT Id, Name, Donor__c, Email__c, Created_from_Fellow_App__c, Primary__c 
               FROM Contact_Email__c 
               WHERE Email__c = :emailAdd LIMIT 1];
        List<Contact> contactList;
        System.debug('conEmailFound:'+conEmailFound);
        if(conEmailFound != NULL  &&  conEmailFound.size() > 0) {
            Contact_Email__c cEmailMatchingFellowEmail;
            cEmailMatchingFellowEmail = conEmailFound[0];
            contactList = 
                [SELECT Id, FirstName, LastName, Email, Phone, AccountId, /*RecordTypeId, */
                 Constituency__c, Sub_Constituency__c, 
                 (SELECT Id, Name, Donor__c, Email__c, Created_from_Fellow_App__c, Primary__c 
                  FROM Contact_Emails__r 
                  WHERE Email__c =: emailAdd),
                 (SELECT Id, Name, Donor__c, Phone__c, Primary__c, Created_from_Fellow_App__c 
                  FROM Contact_Phones__r 
                  WHERE Created_from_Fellow_App__c = true OR Primary__c = TRUE),
                 MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode, OwnerId 
                 FROM Contact 
                 WHERE Id = :cEmailMatchingFellowEmail.Donor__c];
        }
        else {
            System.debug('inside else');
            contactList = 
                [SELECT Id, FirstName, LastName, Email, Phone, AccountId, 
                 Constituency__c, Sub_Constituency__c, 
                 (SELECT Id, Name, Donor__c, Email__c,  Primary__c 
                  FROM Contact_Emails__r 
                  WHERE Primary__c = true),
                 (SELECT Id, Name, Donor__c, Phone__c, Primary__c, Created_from_Fellow_App__c 
                  FROM Contact_Phones__r 
                  WHERE Created_from_Fellow_App__c = true OR Primary__c = TRUE),
                 MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode, OwnerId 
                 FROM Contact 
                 WHERE Email = :emailAdd];
        }
        System.debug('contactList:'+contactList);
        if (contactList != null  &&  contactList.size() > 0  &&  contactList.get(0) != null) return contactList.get(0);
        return null;
        
    }
    
    
    
    public static String getCurrentFellowshipYear() {
        String fAppYear = EDF02_CustomMetadata_Helper.getEDFCCGlobalValue('CurrentFellowshipYear');
        if(fAppYear==null){
            return '2022';
        } else {
            return fAppYear;
        }
        // return '2022';
    }
    
    public static Fellow_Application__c isFellowAppExist(String emailAdd, String currFellowYear, Id contactId) {
        List<Fellow_Application__c> fellowAppList 
            = [SELECT Id, Applicant_Email__c, Applicant__c 
               FROM Fellow_Application__c 
               WHERE (Applicant_Email__c = :emailAdd OR Applicant__c = :contactId) 
               AND CC_Year__c = :currFellowYear];
        if (fellowAppList != null  
            &&  fellowAppList.size() > 0  
            &&  fellowAppList.get(0) != null  
            &&  (fellowAppList.get(0).Applicant_Email__c == emailAdd  
                 ||  (fellowAppList.get(0).Applicant__c == contactId  &&  contactId != null) )) {
                     return fellowAppList.get(0);
                 }
        return null;
    }

    @AuraEnabled
    public static Boolean SendExistingUserEmail(string email)
    {	
        User usr;
        isUserActive = false;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        User[] usrs = fetchUserFromUsername(email);
        System.debug('SendExistingUserEmail usrs :::' + usrs);
        System.debug('isUserActive isUserActive :::' + isUserActive+'======= '+ usrs.size());
        if (usrs != null  &&  usrs.size() > 0) {
            usr = usrs.get(0);
            if(usr.IsActive == true) {
                isUserActive = true;
            }
            List<EmailTemplate> etList = [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE developerName = 'Existing_User_Template'];
            System.debug('SendExistingUserEmail etList :::' + etList);
            if(etList!=null && etList.size()>0)
            {
                Id owaId = [select Id from OrgWideEmailAddress WHERE Address ='edfclimatecorps.apply@edf.org' LIMIT 1].Id;
                EmailTemplate et = etList[0];
                string emailBody = et.Body.replace('{UserName}', usr.Username).replace('{ContactFirstName}', usr.firstName);
                string htmlBody =  et.HtmlValue.replace('{UserName}', usr.Username).replace('{ContactFirstName}', usr.firstName);
                mail.setHtmlBody(htmlBody);
                //mail.setSenderDisplayName('edfclimatecorps.apply@edf.org');
                mail.setOrgWideEmailAddressId(owaId);
                mail.setToAddresses(new List<String>{email});
                mail.setPlainTextBody(emailBody);
                //mail.setReplyTo('edfclimatecorps.apply@edf.org');
                mail.setSubject(et.Subject);
                System.debug('SendExistingUserEmail mail :::' + mail);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            return isUserActive;
        }
        return null;
    }
    public static List<User> fetchUserFromUsername(String email) {
        // return [SELECT Id, name, firstName, lastName, alias, username, email, IsActive FROM User WHERE username = :email  + System.Label.DomainName LIMIT 1];
        return [SELECT Id, name, firstName, lastName, alias, username, email, IsActive FROM User WHERE username = :email LIMIT 1];
    }
    /*public static List<EmailTemplate> fetchEmailTemplateFromName(String templateName) {
        return [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE developerName = :templateName];
    }*/
    public static void saveUser(Contact cont, String contEmail) {
        system.debug('contEmail: '+contEmail);
        // Fetch User Profile from custom settings.
        String profileId = EDF02_CustomMetadata_Helper.getRecordIdsValue('CustomSitesUserProfile');
        //String profileId = '';//dummy
        // Prepare user alias value
        String alias = cont.FirstName.substring(0, 1);
        if (cont.LastName.length() >= 3)  alias = alias + cont.LastName.substring(0, 3);
        else alias = alias + cont.LastName;
        system.debug('%%%%alias$$$: '+alias);
        Contact retContact = getContactForUser(cont.Id); 
        
        // Call future method to create user.
        createUser(cont.Id, contEmail, cont.FirstName, cont.LastName, contEmail/*+ System.Label.DomainName*/, profileId, alias, true, retContact.AccountId);
    }
    public static Contact getContactForUser(Id contId) {
        return [SELECT Id, AccountId FROM Contact WHERE Id = :contId];
    }
    public static void createUser(String contactId, String email, String firstName, String lastName, String userName, String profileId, String alias, Boolean sendMail, Id contactAccId) {
        Boolean isNewUser = true;
        Boolean isInactiveUser = false;
        try {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.EmailHeader.triggerUserEmail = false;
            
            User usr;
            User[] usrs 
                = [SELECT Id, Name, FirstName, LastName, Alias, Username, IsActive, Email 
                   FROM User 
                   WHERE /*Email = :email */
                   /*AND ContactId != null */
                   ContactId = :contactId
                   LIMIT 1];
            if (usrs != null  &&  usrs.size() > 0) {
                usr = usrs.get(0);
                System.debug('Existing user found');
                isNewUser = false;
                if (!usr.IsActive) {
                    isInactiveUser = true;
                    usr.IsActive = true;
                    usr.Username = Username;
                    usr.Email = email;
                }
            }
            else {
                usr = new User(email=email, username=username,contactId = contactId, profileId = profileId, 
                               LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', 
                               timezonesidkey='America/Los_Angeles');
            }
            
            System.debug('usr===' + usr);
            usr.alias = alias;
            usr.communityNickname = alias + '1' + Math.random();
            usr.LastName = lastname;
            usr.FirstName = firstName;
            
            usr.setOptions(dmo);
            System.debug('Saving USER; isNewUser===' + isNewUser);
            System.debug('Saving USER; isInactiveUser===' + isInactiveUser);
            
            if (isNewUser == true && isInactiveUser == false)
            {
                // Database.insert(usr);
                System.debug('::>><<:: before the user creation::>><<::');
                Id  userId = Site.createExternalUser(usr, contactAccId, 'S!mp1eP@ssw0rd', false);                    
                System.debug('user id:'+userId);
                if(Test.isRunningTest()) {
                    Database.insert(usr);
                    List<User> usrTest = [select id,name from user where username =: usr.username];
                    system.debug('UsrTest: '+usrTest); 
                    userId = usrTest[0].id;
                }
                if (sendMail) {
                    
                    System.ResetPasswordResult result = System.resetPassword(userId, false);
                    System.debug('Password: ' + result.getPassword());
                    
                    // Site.forgotPassword(usr.Username,'Create New User Template');
                    
                    /*
                      Adding code to send new user creation email using a template.
                     */
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<EmailTemplate> etList = [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE developerName ='Create_New_User_Template'];
                    if(etList!=null && etList.size()>0)
                    {
                        Id owaId = [select Id from OrgWideEmailAddress WHERE Address ='edfclimatecorps.apply@edf.org' LIMIT 1].Id;
                        EmailTemplate et = etList[0];
                        String emailBody = et.Body.replace('{Password}', result.getPassword()).replace('{UserName}', usr.Username).replace('{ContactFirstName}', firstName);
                        String htmlBody =  et.HtmlValue.replace('{Password}', result.getPassword()).replace('{UserName}', usr.Username).replace('{ContactFirstName}', firstName);
                        // String emailBody = et.Body.replace('{Password}', 'Password@123').replace('{UserName}', usr.Username).replace('{ContactFirstName}', firstName);
                        // String htmlBody =  et.HtmlValue.replace('{Password}', 'Password@123').replace('{UserName}', usr.Username).replace('{ContactFirstName}', firstName);
                        mail.setHtmlBody(htmlBody);
                        //mail.setSenderDisplayName('edfclimatecorps.apply@edf.org');
                        mail.setOrgWideEmailAddressId(owaId);
                        mail.setToAddresses(new List<String>{usr.Email});
                        mail.setPlainTextBody(emailBody);
                        //mail.setReplyTo('edfclimatecorps.apply@edf.org');
                        mail.setSubject(et.Subject);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                    }
                }
            }
            else 
            {
                // Database.update(usr);
                if(!Test.isRunningTest()) {
                    futureUpdateActivateUser(usr.Id, userName, true);                    
                }
                
                /*
If a Contact record with same email address is found, the Account Name for the Contact is updated accordingly to have a name as First Name, 
Last Name and Household. The Account record type, Type and Subtype is also changed to Household. Contact record is updated and the User is checked. 
If a user exists but is inactive, it is activated.
*/
                if(sendMail  &&  isInactiveUser)
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<EmailTemplate> etList = [SELECT id, Body, HtmlValue, Subject FROM EmailTemplate WHERE developerName = 'Activate_User_Template'];
                    if(etList!=null && etList.size()>0)
                    {
                        Id owaId = [select Id from OrgWideEmailAddress WHERE Address ='edfclimatecorps.apply@edf.org' LIMIT 1].Id;
                        EmailTemplate et = etList[0];
                        string emailBody = et.Body.replace('{UserName}', usr.Username).replace('{ContactFirstName}', firstName);
                        string htmlBody =  et.HtmlValue.replace('{UserName}', usr.Username).replace('{ContactFirstName}', firstName);
                        mail.setHtmlBody(htmlBody);
                        //mail.setSenderDisplayName('edfclimatecorps.apply@edf.org');
                        mail.setOrgWideEmailAddressId(owaId);
                        mail.setToAddresses(new List<String>{email});
                        mail.setPlainTextBody(emailBody);
                        //mail.setReplyTo('edfclimatecorps.apply@edf.org');
                        mail.setSubject(et.Subject);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                    }
                }
            }
        }
        catch(exception ex)
        {
            System.debug('exception:'+ex.getStackTraceString());
            // Send an email to the Admin when there is an error while creating/updating a user.
            // Commented by sai Teja for time being
            User[] usrs = [select id, name, firstName, lastName, alias, username, Email from User where UserRole.Name = 'System Administrator' or UserRole.Name = 'Administrators'];
            //User[] usrs = [select id, name, firstName, lastName, alias, username, Email from User where id='00505000002FNvJ'];
            System.debug('usrs:'+usrs);
            if(usrs!=null && usrs.size() > 0)
            {
                List<string> toList = new List<String>();
                for(User usr: usrs)
                {
                    toList.add(usr.Email);  
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                string body = ' A User creation has failed due to following reason: <br/>';
                body += 'Contact Details: <br/>';
                body += 'Contact Id: ' + contactId + '<br/>';
                body += 'Contact Email: ' + email + '<br/>';
                body += 'Contact First Name: ' + firstName + '<br/>';
                body += 'Contact Last Name: ' + lastName + '<br/><br/><br/>';
                body += 'Exception: <br/>';
                body += ex + '<br/><br/>' ; 
                string emailBody = body.replace('<br/>', '\n');
                string htmlBody =  body;
                mail.setHtmlBody(htmlBody);
                mail.setSenderDisplayName('edfclimatecorps.apply@edf.org');
                mail.setToAddresses(toList);
                mail.setPlainTextBody(emailBody);
                mail.setReplyTo('edfclimatecorps.apply@edf.org');
                mail.setSubject('User Creation Failed for Portal');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }       
        }
    }
    @future
    public static void futureUpdateActivateUser(Id userId, String username, Boolean isActive) {
        User usr1 = new User(Id=userId, Username=username, IsActive=isActive);
        Database.update(usr1);
    }
    public static void setFAppContact(Contact cont) {
        fAppContact = cont;
        contWrapper = new Contact_Wrapper(fAppContact);
    }
    public static void updateContactEmail(Contact_Email__c ce) {
        update ce;
    }
    public static void updateContactRecord(Contact cont) {
        update cont;
    }
    @AuraEnabled
    public static String saveContact( String contactdata){
        try {
            System.debug('parms from lwc :: saveContact ::'+contactdata);
            return 'abc';  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static boolean forgotPassword(String username) {  
        System.debug('username:'+username);
        User[] usrs = fetchUserFromUsername(username);
        System.debug('usrs:'+usrs);
        if(usrs!= null && usrs.size()>0){
            try{
            boolean success = Site.forgotPassword(username); 
            }catch(Exception e){
               System.debug('error while resting:'+e.getMessage());
            }
             return true;
           
        }
        return false;
    }

    // get country custom settings 
    @AuraEnabled(cacheable=true) 
    public static List<String> getCountries(){
        Set<String> countrySet = Countries__c.getAll().keyset();
        List<String> countryList = new List<String>(countrySet);
        countryList.sort();
        return countryList;
    }

    // get state by country 
    @AuraEnabled(cacheable=true) 
    public static List<String> getStatesByCountry(string countrySelected){
    Map<String, States__c> stateListCS = States__c.getAll();
    Map<String, List<String>> countryStateListMap = new Map<String, List<String>>();
    List<String> statesList = new  List<String>();
    for (States__c stateCS : stateListCS.values()) {
        if (!countryStateListMap.containsKey(stateCS.Country__c)) {
            countryStateListMap.put(stateCS.Country__c, new List<String>());
        }

        countryStateListMap.get(stateCS.Country__c).add(stateCS.Name);
    }

    for (String country : countryStateListMap.keySet()) {
        countryStateListMap.get(country).sort();
    }
    System.debug('countrySelected=='+countrySelected);
    System.debug('countryStateListMap=='+countryStateListMap);
    System.debug('countryState&&&&&&&&ListMap=='+countryStateListMap.containsKey(countrySelected));
    if(countrySelected!=null && countryStateListMap!=null && countryStateListMap.containsKey(countrySelected)){
        System.debug('inside if countrySelected=='+countryStateListMap.containsKey(countrySelected));
        for(String str : countryStateListMap.get(countrySelected)){
            statesList.add(str);
            statesList.sort();
        }
    }

    if(statesList.size()>0 && !statesList.isEmpty()){
        System.debug('statesList=='+statesList);
        return statesList;
    }
    return null;
}

@AuraEnabled
public static string registerFellow(PayloadWrapper payload){
    try {
        Contact cont = new Contact();
        cont.FirstName = payload.firstName;
        cont.LastName = payload.lastName;
        cont.Email = payload.email;
        cont.MailingCountry = payload.country;
        cont.MailingState = payload.state;
        cont.MailingCity = payload.city;
        cont.Phone = payload.phone;
        cont.MailingPostalCode = payload.postalCode;
        String address2 = payload.address2 == null? '' :+','+payload.address2;
        cont.MailingStreet = payload.address1+address2;
        Database.SaveResult saveResult = Database.insert(cont);
        Database.SaveResult contactEmailSaveResult;
        Database.SaveResult contactPhonesaveResult;
        Database.SaveResult fAppsaveResult;
        if(saveResult.success){
            cont.Id = saveResult.getId();
            Contact_Email__c savedContactEmail = new Contact_Email__c();
            savedContactEmail.Donor__c = saveResult.getId();
            savedContactEmail.Email__c = payload.email;
            savedContactEmail.Type__c = 'Unknown';
            savedContactEmail.Start_Date__c = Date.today();
            savedContactEmail.Created_from_Fellow_App__c = true;
            contactEmailSaveResult = Database.insert(savedContactEmail);
        }
        if(saveResult.success){
            Fellow_Application__c fApp = new Fellow_Application__c();
            fApp.Applicant__c = saveResult.getId();
            fApp.Status__c = 'Prospective Applicant';
            fApp.Fellow_Applicant_Email__c = payload.email;
            fApp.CC_Year__c = getCurrentFellowshipYear();
            fAppsaveResult = Database.insert(fApp);
        }
        if(contactEmailSaveResult.success){
            Contact_Phone__c savedContactPhone = new Contact_Phone__c();
            savedContactPhone.Donor__c = saveResult.getId();
            savedContactPhone.Phone__c = payload.Phone;
            savedContactPhone.Type__c = 'Unknown';
            savedContactPhone.Start_Date__c = Date.today();
            savedContactPhone.Created_from_Fellow_App__c = true;
            savedContactPhone.Primary__c = true;
            contactPhonesaveResult = Database.insert(savedContactPhone);
        }

        if(saveResult.success){
            saveUser(cont,payload.email);
        }

      return saveResult.getId();  
    } catch (Exception e) {
        System.debug('exception sath : '+e.getStackTraceString());
        throw new AuraHandledException(e.getMessage());
     	
    }
}

public class PayloadWrapper{
    @AuraEnabled
    public String firstName{get; set;}
    @AuraEnabled
    public String lastName{get; set;}
    @AuraEnabled
    public String email{get; set;}
    @AuraEnabled
    public String phone{get; set;}
    @AuraEnabled
    public String country{get; set;}
    @AuraEnabled
    public String state{get; set;}
    @AuraEnabled
    public String postalCode{get; set;}
    @AuraEnabled
    public String city{get; set;}
    @AuraEnabled
    public String address1{get; set;}
    @AuraEnabled
    public String address2{get; set;}
}
}