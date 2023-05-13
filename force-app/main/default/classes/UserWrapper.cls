/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 1/23/2022
# Last Modified by......:
# Last Modified Date....: 
# Description...........: Wrapper for Fellow Registration/Edit Contcat info and headercomponent.
# Test Class............: Test_WrapperControllers
# Change Log:
# 
############################################################################
*/
public with sharing class UserWrapper {
    @AuraEnabled
    public String id {get; set;}
    @AuraEnabled
    public String firstName {get; set;}
    @AuraEnabled
    public String lastName {get; set;}
    @AuraEnabled
    public String userName {get; set;}
    @AuraEnabled
    public String stage {get; set;}
}