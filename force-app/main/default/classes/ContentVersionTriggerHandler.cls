/*
###########################################################################
# Created by............: Harpreet Singh & Team (OSI)
# Created Date..........: 10/Mar/2023
# Last Modified by......:
# Last Modified Date....:
# Description...........: This class is the handler class for Content Version Trigger.
#                         It sets Workplan Approval to blank when Workplan file is deleted.
# Test Class............:
# Change Log:
#
############################################################################
*/
public with sharing class ContentVersionTriggerHandler {

    private static final Constants CONSTT = Constants.getAllConstants();

    /*
     * There may be times when I do not want to set Workplan Approval
     * to null on file deletion. For e.g. when I am replacing an existing file,
     * the older file is being deleted. But I would not like to set the
     * Workplan Approval to blank, since later I will be updating it to
     * Pending Approval. Hence this will save me 1 non-required DML operation.
     */
    public static Boolean updateWorkplanApprovalOnDelete = true;

    /**
     * After Update event handler
     */
    public static void afterUpdate(Map<Id, ContentVersion> newMap, Map<Id, ContentVersion> oldMap) {
        updateCCEngagement(newMap, oldMap);
    }


    /**
     * Handler of Update of Content Version related to CC Engagement
     */
    private static void updateCCEngagement(Map<Id, ContentVersion> newMap, Map<Id, ContentVersion> oldMap) {
        updateCCEngagementWorkplanApproval(newMap, oldMap);
    }

    /**
     * If CV being updated is related to Workplan and its Deleted_By_Fellow__c set to TRUE,
     * update the linked Engagement record and set Workplan Approval to null
     * FB-2565
     */
    private static void updateCCEngagementWorkplanApproval (Map<Id, ContentVersion> newMap, Map<Id, ContentVersion> oldMap) {

        // System.debug('ContentVersionTriggerHandler :: updateCCEngagementWorkplanApproval :: newMap :: ' + newMap);
        // System.debug('ContentVersionTriggerHandler :: updateCCEngagementWorkplanApproval :: oldMap :: ' + oldMap);
        Set<Id> cdForApprovalPendingIdSet = new Set<Id>();
        Set<Id> cdForApprovalNullIdSet = new Set<Id>();
        for (Id cvId : newMap.keySet()) {
            ContentVersion cvNew = newMap.get(cvId);
            ContentVersion cvOld = oldMap.get(cvId);

            if (cvNew.Title.startsWith(CONSTT.CC_ENGAGEMENT_WORKPLAN_FILE_TITLE_PREFIX + '_')) {
                if (cvNew.Deleted_By_Fellow__c  &&  !cvOld.Deleted_By_Fellow__c  &&  ContentVersionTriggerHandler.updateWorkplanApprovalOnDelete) {
                    cdForApprovalNullIdSet.add(cvNew.ContentDocumentId);
                }
                else if (cvNew.Title != cvOld.Title  &&  !cvNew.Deleted_By_Fellow__c) {
                    cdForApprovalPendingIdSet.add(cvNew.ContentDocumentId);
                }
            }
        }

        if (cdForApprovalNullIdSet.size() > 0) {
            // System.debug('ContentVersionTriggerHandler :: updateCCEngagementWorkplanApproval :: cdIdSet :: ' + cdIdSet);
            Set<Id> enggIdSet = getEngagementIdsFromContDocIds(cdForApprovalNullIdSet);

            if (enggIdSet.size() > 0) {
                updateEngagementsForWorkplanApproval(enggIdSet, null);

            }
        }
        else if (cdForApprovalPendingIdSet.size() > 0) {
            // System.debug('ContentVersionTriggerHandler :: updateCCEngagementWorkplanApproval :: cdIdSet :: ' + cdIdSet);
            Set<Id> enggIdSet = getEngagementIdsFromContDocIds(cdForApprovalPendingIdSet);

            if (enggIdSet.size() > 0) {
                updateEngagementsForWorkplanApproval(enggIdSet, CONSTT.CC_ENGAGEMENT_PICKLIST_VALUE_PENDING_APPROVAL);
            }
        }
    }


    private static Set<Id> getEngagementIdsFromContDocIds(Set<Id> contDocIdSet) {
        Set<Id> enggIdSet = new Set<Id>();
        for (ContentDocumentLink docLink : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :contDocIdSet]) {
            // System.debug('ContentVersionTriggerHandler :: updateCCEngagementWorkplanApproval :: docLink :: ' + docLink);
            if (((String)docLink.LinkedEntityId).startsWith(CONSTT.CC_ENGAGEMENT_RECORD_ID_PREFIX)) {
                enggIdSet.add(docLink.LinkedEntityId);
            }
        }
        return enggIdSet;
    }


    private static void updateEngagementsForWorkplanApproval(Set<Id> enggIdSet, String wpStatus) {
        List<Climate_Corps_Engagement__c> enggList = new List<Climate_Corps_Engagement__c>();
        for (Id enggId : enggIdSet) {
            enggList.add(new Climate_Corps_Engagement__c(Id = enggId, Workplan_Approval__c = wpStatus));
        }

        if (enggList.size() > 0) {
            update enggList;
        }
    }
}