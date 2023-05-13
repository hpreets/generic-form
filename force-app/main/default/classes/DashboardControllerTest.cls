/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 08/19/2022
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Test class for DashboardController 
# Change Log:               
#
#
############################################################################
*/
@isTest
public class DashboardControllerTest {
    static testMethod void getActionCenterTest(){
        Test.startTest();
        DashboardController.getActionCenter();
        Test.stopTest();
        
    }
    static testMethod void getShortcutsTest(){
        Test.startTest();
        DashboardController.getShortcuts();
        Test.stopTest();
    }
    static testMethod void getNextStepsTest(){
        Test.startTest();
        DashboardController.getNextSteps();
        Test.stopTest();
    }
    static testMethod void isShortCutsTilesExistTest(){
        Test.startTest();
        DashboardController.isShortCutsTilesExist();
        Test.stopTest();
    }
    static testMethod void isNextStepsTilesExistTest(){
        Test.startTest();
        DashboardController.isNextStepsTilesExist();
        Test.stopTest();
    }

}