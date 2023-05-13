/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 3/7/2022
# Last Modified by......:
# Last Modified Date....: 
# Description...........: ContactTriggerHandler is helper class.
# Test Class............: 
# Change Log:
# 
############################################################################
*/
trigger ContactTrigger on Contact (after insert,after update) {
    ContactTriggerHandler handler = new ContactTriggerHandler();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.afterInsert(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);
        }
        if (Trigger.isUpdate) {
            handler.afterUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);
        }
    }
}