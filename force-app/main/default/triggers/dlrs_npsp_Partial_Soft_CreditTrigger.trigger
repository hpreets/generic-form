/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_npsp_Partial_Soft_CreditTrigger on npsp__Partial_Soft_Credit__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(npsp__Partial_Soft_Credit__c.SObjectType);
}