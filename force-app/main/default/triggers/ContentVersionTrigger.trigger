/*
###########################################################################
# Created by............: Harpreet Singh & Team (OSI)
# Created Date..........: 10/Mar/2023
# Last Modified by......:
# Last Modified Date....:
# Description...........: This trigger handles update events on Content Version records.
# Test Class............:
# Change Log:
#
############################################################################
*/
trigger ContentVersionTrigger on ContentVersion (after update) {

    if (Trigger.isAfter  &&  Trigger.isUpdate) {
        ContentVersionTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}