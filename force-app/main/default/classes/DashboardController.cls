/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 
# Last Modified by......:
# Last Modified Date....: 05/23/2022
# Description...........: Main Dashboard Controller.
# Test Class............: DashboardController_Test
# Change Log:
# 
############################################################################
*/
public with sharing class DashboardController {
    static List<String> stages = new List<String>();
    static String edfEngagementConfirmed = Label.EDF_Engagement_Confirmed;
    static String edfProspectiveApplicant = Label.EDF_Prospective_Applicant;

    
    public DashboardController(){
        stages = new List<String> {edfEngagementConfirmed, edfProspectiveApplicant};
    }

    @AuraEnabled
    public static List<TileWrapper> getActionCenter(){
        List<TileWrapper> listActionCenter = new List<TileWrapper>();
        List <EDF_Action_Center__mdt> acList = new List <EDF_Action_Center__mdt>();
        //Seshapani: added below line for fellowship
        String fellowshipFor = EngagementListController.getFellowshipFor();      
        String status = LoginController.getApplicationStatusValue();        
        string likeValue = '%' + status + '%';
        //Seshapani: added filter for fellowship
        acList = [Select Id, Active__c, Order_Number__c, Image__c, Title__c, Description__c, Page_Name__c, Page_Type__c, URL__c, Button_Text__c from EDF_Action_Center__mdt Where Active__c = true AND Stages__c LIKE :likeValue AND FellowshipApplyingFor__c =:fellowshipFor ORDER BY Order_Number__c ASC];
        
        if(!acList.isEmpty()){
            for(EDF_Action_Center__mdt ac : acList){
                TileWrapper tw = new TileWrapper();
                tw.id = ac.Id;
                tw.active = ac.Active__c;
                if(ac.Order_Number__c != null){
                    Decimal orderNumberValue = ac.Order_Number__c; 
                    tw.orderNumber = orderNumberValue.intValue();
                }
                tw.image = ac.Image__c;
                tw.title = ac.Title__c;
                tw.description = ac.Description__c;
                tw.pageType = ac.Page_Type__c;
                tw.pageName = ac.Page_Name__c;
                tw.url = ac.URL__c;
                tw.buttonText = ac.Button_Text__c;

                listActionCenter.add(tw);
            }
        }

        return listActionCenter;
    }

    @AuraEnabled
    public static List<TileWrapper> getShortcuts(){
        
        List<TileWrapper> listShortcuts = new List<TileWrapper>();
        List <EDF_Shortcuts__mdt> scList = new List <EDF_Shortcuts__mdt>();
        //Seshapani: added below line for fellowship
        String fellowshipFor = EngagementListController.getFellowshipFor();      
        String status = LoginController.getApplicationStatusValue();
        string likeValue = '%' + status + '%';
            
        if(!String.isBlank(status) && (status == edfEngagementConfirmed || status == edfProspectiveApplicant)){
            scList = [Select Id, Active__c, Order_Number__c, Image__c, Title__c, Description__c, Page_Name__c, Page_Type__c, URL__c, Button_Text__c from EDF_Shortcuts__mdt Where Active__c = true AND Stages__c LIKE :likeValue ORDER BY Order_Number__c ASC];
        }
        else if(!String.isBlank(status) && (status != edfEngagementConfirmed)){
            scList = [Select Id, Active__c, Order_Number__c, Image__c, Title__c, Description__c, Page_Name__c, Page_Type__c, URL__c, Button_Text__c from EDF_Shortcuts__mdt Where Active__c = true AND Stages__c LIKE :likeValue AND FellowshipApplyingFor__c =:fellowshipFor ORDER BY Order_Number__c ASC];
        }
        else {
            scList = [Select Id, Active__c, Order_Number__c, Image__c, Title__c, Description__c, Page_Name__c, Page_Type__c, URL__c, Button_Text__c from EDF_Shortcuts__mdt Where Active__c = true ORDER BY Order_Number__c ASC];
        }
        
        if(!scList.isEmpty()){
            for(EDF_Shortcuts__mdt sc : scList){
                TileWrapper tw = new TileWrapper();
                tw.id = sc.Id;
                tw.active = sc.Active__c;
                if(sc.Order_Number__c != null){
                    Decimal orderNumberValue = sc.Order_Number__c; 
                    tw.orderNumber = orderNumberValue.intValue();
                }
                tw.image = sc.Image__c;
                tw.title = sc.Title__c;
                tw.description = sc.Description__c;
                tw.pageType = sc.Page_Type__c;
                tw.pageName = sc.Page_Name__c;
                tw.url = sc.URL__c;
                tw.buttonText = sc.Button_Text__c;

                listShortcuts.add(tw);
            }
        }

        return listShortcuts;
    }

    @AuraEnabled
    public static List<TileWrapper> getNextSteps(){
        
        List<TileWrapper> listNextSteps = new List<TileWrapper>();
        List <EDF_NextSteps__mdt> nsList = new List <EDF_NextSteps__mdt>();
        //Seshapani: added below line for fellowship
        String fellowshipFor = EngagementListController.getFellowshipFor();      
        String status = LoginController.getApplicationStatusValue();   
        string likeValue = '%' + status + '%';
        nsList = [Select Id, Active__c, Order_Number__c, Image__c, Stages__c, Title__c, Sub_Title__c, Sub_Title_Link__c, Sub_Title_Link_Label__c, Description__c, Footer__c from EDF_NextSteps__mdt Where Active__c = true  AND Stages__c LIKE :likeValue AND FellowshipApplyingFor__c =:fellowshipFor ORDER BY Order_Number__c ASC];
        
        if(!nsList.isEmpty()){
            for(EDF_NextSteps__mdt ns : nsList){
                TileWrapper tw = new TileWrapper();
                tw.id = ns.Id;
                tw.active = ns.Active__c;
                if(ns.Order_Number__c != null){
                    Decimal orderNumberValue = ns.Order_Number__c; 
                    tw.orderNumber = orderNumberValue.intValue();
                }
                tw.image = ns.Image__c;
                tw.title = ns.Title__c;
                tw.description = ns.Description__c;
                tw.subTitle = ns.Sub_Title__c;
                tw.subTitleLink = ns.Sub_Title_Link__c;
                tw.subTitleLinkLabel = ns.Sub_Title_Link_Label__c;
                tw.footer = ns.Footer__c;

                listNextSteps.add(tw);
            }
        }

        return listNextSteps;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean isShortCutsTilesExist(){
        Boolean isExistShortCuts = false;
        //Seshapani: added below line for fellowship
        String fellowshipFor = EngagementListController.getFellowshipFor();      
        String status = LoginController.getApplicationStatusValue();
        string likeValue = '%' + status + '%';
        List <EDF_Shortcuts__mdt> shortCutsList = [Select Id, Active__c from EDF_Shortcuts__mdt Where Active__c = true AND Stages__c LIKE :likeValue AND FellowshipApplyingFor__c =:fellowshipFor];
        System.debug('shortCutsList:'+shortCutsList);
        System.debug('isExistShortCuts:'+isExistShortCuts);
        if(shortCutsList.size()>0){
            isExistShortCuts = true;
        }
        return isExistShortCuts;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isNextStepsTilesExist(){
        Boolean isExistNextSteps = false;
        //Seshapani: added below line for fellowship
        String fellowshipFor = EngagementListController.getFellowshipFor();      
        String status = LoginController.getApplicationStatusValue();
        string likeValue = '%' + status + '%';
        List <EDF_NextSteps__mdt> nextStepsList = [Select Id, Active__c from EDF_NextSteps__mdt Where Active__c = true AND Stages__c LIKE :likeValue AND FellowshipApplyingFor__c =:fellowshipFor];
        System.debug('nextStepsList:'+nextStepsList);
        System.debug('isExistNextSteps:'+isExistNextSteps);
        if(nextStepsList.size()>0){
            isExistNextSteps = true;
        }
        return isExistNextSteps;

    }

    public class TileWrapper {
        @AuraEnabled
        public String id {get; set;}

        @AuraEnabled
        public Boolean active {get; set;}

        @AuraEnabled
        public Integer orderNumber {get; set;}

        @AuraEnabled
        public String image {get; set;}

        @AuraEnabled
        public String title {get; set;}

        @AuraEnabled
        public String description {get; set;}

        @AuraEnabled
        public String pageType {get; set;}

        @AuraEnabled
        public String pageName {get; set;} 
            
        @AuraEnabled
        public String url {get; set;}

        @AuraEnabled
        public String subTitle {get; set;}

        @AuraEnabled
        public String subTitleLink {get; set;}

        @AuraEnabled
        public String subTitleLinkLabel {get; set;}

        @AuraEnabled
        public String footer {get; set;}

        @AuraEnabled
        public String buttonText {get; set;}
  
    }


}