/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 12/29/2021
# Last Modified by......:
# Last Modified Date....:
# Description...........: Helper methods for Fetching Custom Metadata types Data.
# Test Class............: EDF02CustomMetadataHelper_Test
# Change Log:
#
############################################################################
*/
public class EDF02_CustomMetadata_Helper {

    /**
    * Description : This method return the value based on key present in the 'EDF_CC_Global__mdt' custom Metadata.
    **/
    public static String getEDFCCGlobalValue(String key) {
        // System.debug('Key:'+key);
        // System.Debug('if key not null:'+EDF_CC_Global__mdt.getAll().get(key).Value__c);
        if(key != null && EDF_CC_Global__mdt.getAll().get(key) != null)
            return EDF_CC_Global__mdt.getAll().get(key).Value__c;
        return null;
    }


    /**
    * Description : This method return the value based on key.
    **/
    public static String getStudentMessage(String key) {
        System.debug('Key:'+key);
        return null;
    }


    /**
    * Description : This method return the value based on key based to the 'Record_Ids__mdt' custom Metadata.
    **/
    public static String getRecordIdsValue(String key) {
        if(key != null && Record_Ids__mdt.getAll().get(key) != null)
            return Record_Ids__mdt.getAll().get(key).IdValue__c;
        return null;
    }


    /**
    * Description : This method return the records of 'EDF_NextSteps__mdt' custom Metadata.
    **/
    @AuraEnabled( cacheable=true )
    public static List < EDF_NextSteps__mdt > fetchEDFNextSteps() {
        List < EDF_NextSteps__mdt > fetchMeta = [ SELECT Id, MasterLabel, Active__c, NextStepsBody__c, NextStepsDescription__c, NextStepsFotter__c, NextStepsHeading__c,Order_Number__c FROM EDF_NextSteps__mdt where Active__c = true ORDER BY Order_Number__c ASC];
        return fetchMeta;
    }


    /**
    * Description : This method return the records of 'EDF_Shortcuts__mdt' custom Metadata.
    **/
    @AuraEnabled( cacheable=true )
    public static List < EDF_Shortcuts__mdt > fetchEDFShortcuts() {
        List < EDF_Shortcuts__mdt > fetchMeta = [ SELECT Id, MasterLabel, Active__c, ShortcutsBody__c, ShortcutsDescription__c, ShortcutsFotter__c, ShortcutsLogo__c,Order_Number__c FROM EDF_Shortcuts__mdt where Active__c = true ORDER BY Order_Number__c ASC];
        return fetchMeta;
    }


    /**
    * Description : This method return the records of 'ItemsforEDF__mdt' custom Metadata.
    * @param fellowshipApplyingFor: Which region fellowship data to be fetched.
    **/
    @AuraEnabled( cacheable=true )
    public static Map <String, List<ItemsforEDF__mdt> > fetchEDFItemsForFellowship(String fellowshipApplyingFor) {
        Map <String, List<ItemsforEDF__mdt>> edfItems = new Map<String, List<ItemsforEDF__mdt>>();
        List < ItemsforEDF__mdt > edfItemsList
            = [SELECT Id,
                    MasterLabel, Button_Label__c, Button_URL__c, Due_Date__c, Header_Icon__c,
                    Section_Name__c, Tile_Body__c, Section_Order__c, Item_Order__c, Mapping_Field__c,
                    IsContactField__c,
                    Hide_Due_Date__c, Due_Date_Label__c, // FB-2768
                    Due_Date_Field__c, Due_Date_Field_Offset__c // FB-2569
                FROM ItemsforEDF__mdt
                WHERE Fellowship__c =:fellowshipApplyingFor
                ORDER BY Section_Order__c, Item_Order__c ASC];
        for(ItemsforEDF__mdt item : edfItemsList){
            if(edfItems.containsKey(item.Section_Name__c)){
                edfItems.get(item.Section_Name__c).add(item);
            } else {
                edfItems.put(item.Section_Name__c, new List<ItemsforEDF__mdt>{item});
            }
        }

        // System.debug('EDF02_CustomMetadata_Helper ::: fetchEDFItemsForFellowship :::' + fellowshipApplyingFor);
        // System.debug('EDF02_CustomMetadata_Helper ::: fetchEDFItemsForFellowship :::' + edfItems);
        return edfItems;
    }


    /**
    * Description : This method return the Deliverables Tracker Tile dates to be displayed on Portal Deliverables page
    * @param fellowshipApplyingFor: Which region fellowship data to be fetched.
    **/
    @AuraEnabled( cacheable=true )
    public static List <PortalDeliverablesAndTilesDateMapping__mdt> fetchPortalDeliverablesAndTilesDateMapping(String fellowshipApplyingFor) {

        List < PortalDeliverablesAndTilesDateMapping__mdt > dateMappingsList
            = [SELECT Id,
                    MasterLabel, DeveloperName, Fellowship__c, Deliverable_Tracker_Tile__c,
                    Portal_Deliverables_Field__c,
                    Deliverable_Tracker_Tile__r.Due_Date__c,
                    Deliverable_Tracker_Tile__r.Due_Date_Field__c,
                    Deliverable_Tracker_Tile__r.Due_Date_Field_Offset__c
                FROM PortalDeliverablesAndTilesDateMapping__mdt
                WHERE Fellowship__c = :fellowshipApplyingFor];

        return dateMappingsList;
    }


    /**
    * Description : This method returns details about each section of Portal Deliverables
    * @param fellowshipApplyingFor: Which region fellowship data to be fetched.
    **/
    @AuraEnabled( cacheable=true )
    public static List <Portal_Deliverables_Section__mdt> fetchPortalDeliverablesSection(String fellowshipApplyingFor) {

        List < Portal_Deliverables_Section__mdt > sectionList
            = [SELECT Id,
                    MasterLabel, DeveloperName, Fellowship__c, Is_Visible__c,
                    Section_Field__c
                FROM Portal_Deliverables_Section__mdt
                WHERE Fellowship__c = :fellowshipApplyingFor
                ORDER BY Section_Field__c];

        return sectionList;
    }

}