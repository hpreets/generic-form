/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 12/21/2021
# Last Modified by......:
# Last Modified Date....: 
# Description...........: Helper methods for Fetching Custom Settings Data.
# Test Class............: EDF02CustomMetadataHelper_Test
# Change Log:
# 
############################################################################
*/

public class CustomSettings_Helper {
    
    /**
    * Description : This method return the value based on key present in the 'EDFCCGlobal__c' custom setting.
    **/
    public static String getEDFCCGlobalValue(String key) {
        if(key != null && EDFCCGlobal__c.getAll().get(key) != null)
        return EDFCCGlobal__c.getAll().get(key).Value__c;
        return null;
    }
    
    /**
    * Description : This method return the value based on key present in the 'RecordId__c' custom setting.
    **/
    public static String getRecordIdsValue(String key) {
        return RecordId__c.getAll().get(key).IdValue__c;
    }    
    /**
    * Description : This method return the value based on key present in the 'FellowApplicationStatus' custom setting.
    **/
    public static String getFellowApplicationStatusValue(String key) {
        System.debug('Key:::::::' + key);
        if (key == null  ||  key == '') key = '--';
        String retVal = key;
        
        // These two are hard-coded since there is 38 character limit on Custom Settings name
        if (key == 'Engagement Confirmed + Email Sent to OCS') {
            retVal = 'Engagement Confirmed';
        }
        else if (key == 'Declined after Interview 1 and before Interview 2') {
            retVal = 'Application Withdrawn';
        }
        System.debug('retVal:::::::' + retVal);
        return retVal;
    }
    /**
    * Description : This method return the value based on key present in the 'StudentMessage' custom setting.
    **/
    public static String getStudentMessage(String key) {
        String retVal;
        if (retVal == null  ||  retVal == '') retVal = key;
        System.debug('getStudentMessage retVal:::::::' + retVal);
        return retVal;
    }
    /**
    * Description : This method return the value based on key present in the 'ValidExtension' custom setting.
    **/
    
    public static String getValidExtension(String key) {
        String retVal;
        System.debug('getValidExtension retVal:::::::' + retVal);
        return retVal;
    }
    /**
    * Description : This method return the value based on key present in the 'Trigger' custom setting.
    **/
    
    public static boolean getTriggers(String key) {
        boolean retVal;
        System.debug('getTriggers retVal:::::::' + retVal);
        return retVal;
    }

    /**
    * Description : This method return the All States present in the 'States__c' custom setting.
    **/
    public static Set<String> getAllStates() {
        Set<String> retVal = States__c.getAll().keyset();
        return retVal;
    }
    /**
    * Description : This method return the All Countries present in the 'Countries__c' custom setting.
    **/

    public static Set<String> getAllCountries() {
        Set<String> retVal = Countries__c.getAll().keyset();
        return retVal;
    }
	/**
    * Description : This method returns States in sorted order.
    **/
    public static List<String> getAllStatesSorted() {
        List<String> retVal = new List<String>(States__c.getAll().keyset());
        retVal.sort();
        return retVal;
    }
	/**
    * Description : This method returns Countries in sorted order.
    **/
    public static List<String> getAllCountriesSorted() {
        List<String> retVal = new List<String>(Countries__c.getAll().keyset());
        retVal.sort();
        return retVal;
    }

}