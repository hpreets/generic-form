/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 2/4/2022
# Last Modified by......:
# Last Modified Date....: 
# Description...........: Login functinality for community User.
# Test Class............: CommunityAuthController_Test
# Change Log:
# 
############################################################################
*/
public with sharing class CommunityAuthController {
    /**
    * Description : This method is responsible for Login the community user in site.
    **/
    @AuraEnabled
    public static string doLogin(String email, String password){
        try { 

            //String startUrl = 'https://comosi-edfcommunities.cs68.force.com/EDFCCFellowPortal';

            String siteName = System.Label.SiteName;
            String startUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + siteName;
            System.debug('startUrl:' + startUrl);

            String username = LoginController.getUsernameByEmail(email);
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);

            if(pageRef != null) return pageRef.getUrl();

            //throw new CalloutException();

            return null;
            //return pageRef.getUrl();


        } catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            //throw new AuraHandledException(e.getMessage());

            return null;
        }
    }
}