/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 3/28/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: This Class contains EngagementList Wrapper.
# Test Class............: EngagementListController_Test
# Change Log:
#
############################################################################
*/
global class EngagementComparatorWrapper implements Comparable {
	@AuraEnabled
    public Id eId { get; set; }
    @AuraEnabled
    public String Workplan_Focus { get; set; }
    @AuraEnabled
    public String Supervisor_Title { get; set; }
    @AuraEnabled
    public String Fellowship_State { get; set; }
    @AuraEnabled
    public String Engagement_Program { get; set; }
    @AuraEnabled
    public String Fellowship_Metro_Area { get; set; }
    @AuraEnabled
    public String Fellowship_City { get; set; }
    @AuraEnabled
    public Date Date_Engagement_Added_to_Portal { get; set; }
    @AuraEnabled
    public Account acc { get; set; }
    @AuraEnabled
    public Id accId { get; set; }
    @AuraEnabled
    public String AccountName { get; set; }
    @AuraEnabled
    public String Stage { get; set; }
    @AuraEnabled
    public Boolean Accessible_by_public_transportation { get; set; }
    @AuraEnabled
    public String Available_NotAvailable { get; set; }
    @AuraEnabled
    public String Workplan_from_App { get; set; }
    @AuraEnabled
    public String Engagement_Type { get; set; }
    @AuraEnabled
    public Boolean considerMe { get; set; }
    @AuraEnabled
    public Climate_Corps_Engagement__c engagement { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String Past_CC_Years { get; set; }
    @AuraEnabled
    public String Workplan_Environment{ get; set; }
    @AuraEnabled
    public String Supervisor2{ get; set; }
    @AuraEnabled
    public String Matching_Notes_from_EDF{ get; set; }
    @AuraEnabled
    public String High_Level_Sponsor2{ get; set; }
    @AuraEnabled
    public String High_Level_Sponsor_Title{ get; set; }
    @AuraEnabled
    public String howConsidered { get; set; }
    @AuraEnabled
    public Boolean potentialMatch { get; set; }
    @AuraEnabled
    public String Industry { get; set; } // 16-Jan-2015
    @AuraEnabled
    public String Project_Type { get; set; } // 16-Jan-2015
    @AuraEnabled
    public String sortBy = 'Date_Engagement_Added_to_Portal__c';
    @AuraEnabled
    public String sortDir = 'desc';

    // public String reason { get; set; } // 8-Dec-2015 - Sakshi
    @AuraEnabled
    public boolean competitiveHost { get; set; } // 9-Dec-2015 - Sakshi
    @AuraEnabled
    public Potential_Matching_From_Screener__c considerMeMatch { get; set; } // 14-Dec-2015 - Harpreet
    @AuraEnabled
    public String Fellowship_Location_Preference {get; set;} // 26-OCT-2020 - SaiTeja
    @AuraEnabled
    public boolean prioritizeHost { get; set; } // 7/1/21 - Harpreet

    @AuraEnabled
    public String starColor { get; set; } // FB-2133 Harpreet

    public EngagementComparatorWrapper(Climate_Corps_Engagement__c engg, String sortBy, String sortDir) {
        setEngagementData(engg);
        if (sortBy != null  &&  sortBy != '') this.sortBy = sortBy;
        if (sortDir != null  &&  sortDir != '') this.sortDir = sortDir;
    }

    public EngagementComparatorWrapper(Potential_Matching_From_Screener__c pms, Boolean considerMe, Boolean fromEDF, String sortBy, String sortDir) {
        setEngagementDataFromPMS(pms, considerMe, fromEDF);
        if (sortBy != null  &&  sortBy != '') this.sortBy = sortBy;
        if (sortDir != null  &&  sortDir != '') this.sortDir = sortDir;
    }

    private void setEngagementData(Climate_Corps_Engagement__c eng) {
        eId = eng.Id;
        Workplan_Focus = eng.Workplan_Focus__c;
        Supervisor_Title = eng.Supervisor_Title__c;
        Fellowship_State = eng.Fellowship_State__c;
        Engagement_Program = eng.Fellowship_Program__c;
        //j/Fellowship_Metro_Area = eng.Fellowship_Metro_Area__c;
        Fellowship_City = eng.Fellowship_City__c;
        Date_Engagement_Added_to_Portal = eng.Date_Engagement_Added_to_Portal__c;
        // public Account acc { get; set; }
        accId = eng.Account__c;
        AccountName = eng.Account__r.Name;
        Stage = eng.Stage__c;
        Accessible_by_public_transportation = eng.Accessible_by_public_transportation__c;
        Workplan_from_App = eng.Workplan_for_Student_Portal__c;
        // Workplan_from_App = eng.Workplan_from_App__c;
        starColor = eng.Star__c; // FB-2133 Harpreet

        Industry = eng.Industry_Classification__c; // 16-Jan-2015
        // Project_Type = eng.Work_Scope_Bucket__c; // 16-Jan-2015
        Project_Type = eng.Project_Category__c; // For using Project Category of Host Application
        Fellowship_Location_Preference = eng.Fellowship_Location_Preference__c; //26-OCT-2020.
        Available_NotAvailable = 'Not Available';
        if (eng.Stage__c == 'Confirmed Participation'
                ||  eng.Stage__c == 'Match Conversation Complete'
                ||  eng.Stage__c == 'Onboarding Conversation Not Accepted') {
            Available_NotAvailable = 'Available';
        }
        else if(eng.Stage__c == 'Offer sent' || eng.Stage__c == 'Onboarding Conversation in Progress' || eng.Stage__c == 'Onboarding Conversation Complete'){
            Available_NotAvailable = 'Unavailable: Offer Pending';
        }

        considerMe = false;
        if (eng.Potential_Matching_From_Screeners__r != null  &&  eng.Potential_Matching_From_Screeners__r.size() > 0  &&  Available_NotAvailable == 'Available') {
            considerMe = true;
        }

        Name = eng.Name != null ? eng.Name : '';
        //j/Past_CC_Years = eng.Past_CC_Years__c != null ? eng.Past_CC_Years__c : '';
        Supervisor2 = eng.Supervisor2__c != null ? eng.Supervisor2__c : '';
        Matching_Notes_from_EDF = eng.Matching_Notes_from_EDF__c != null ? eng.Matching_Notes_from_EDF__c : '';
        //j/High_Level_Sponsor_Title = eng.High_Level_Sponsor_Title__c != null ? eng.High_Level_Sponsor_Title__c : '';
        howConsidered = '';
        potentialMatch = false;
        //Code changes by Sakshi on 9-Dec-2015 start
        competitiveHost = false;
        if ((eng.Competitive_Host_Location__c != null  &&  eng.Competitive_Host_Location__c == TRUE) || (eng.Competitive_Host_based_on_ConsiderMe__c == TRUE)) {
            competitiveHost = true;
        }
        //Code changes by Sakshi on 9-Dec-2015 end

        /**
         * Show blue icon next to Name if Engagement is prioritized
         * Added by Harpreet (OSI) on 7/1/21
         */
        prioritizeHost = false;
        if (eng.Prioritize_for_Consider_Mes__c != null  &&  eng.Prioritize_for_Consider_Mes__c == TRUE) {
            prioritizeHost = true;
        }

        // reason = ''; // 8-Dec-2015 - Sakshi
        considerMeMatch = new Potential_Matching_From_Screener__c();
        considerMeMatch.Engagement__c = eng.Id;
        if (eng.Potential_Matching_From_Screeners__r != null  &&  eng.Potential_Matching_From_Screeners__r.size() > 0) {
            Boolean[] matchType = new Boolean[] { false, false };
            for (Potential_Matching_From_Screener__c match : eng.Potential_Matching_From_Screeners__r) {
                if (match.How_Considered__c == 'EDF') {
                    matchType[0] = true;
                }
                else {
                    matchType[1] = true;
                }
                howConsidered = match.How_Considered__c;
                if (matchType[0] == true  &&  matchType[1] == true) {
                    howConsidered = 'Both';
                    break;
                }
                // 8-Dec-2015 - Sakshi
                if(String.isNotBlank(match.Why__c)){
                    // reason = match.Why__c;
                    considerMeMatch.Why__c = match.Why__c; // Harpreet - 14-Dec-2015
                }
                considerMeMatch.Bookmark__c = match.Bookmark__c;
                considerMeMatch.Rank__c = match.Rank__c;
                considerMeMatch.Status__c = match.Status__c; // FB-1917 Harpreet
                considerMeMatch.Id = match.Id;
                System.debug('considerMeMatch :::::' + considerMeMatch + '\r\n match ::::' + match);
            }
            potentialMatch = true;
        }
        engagement = eng;
    }

    private void setEngagementDataFromPMS(Potential_Matching_From_Screener__c pms, Boolean considerMe, Boolean fromEDF) {
        eId = pms.Engagement__c;
        Workplan_Focus = pms.Engagement__r.Workplan_Focus__c;
        Supervisor_Title = pms.Engagement__r.Supervisor_Title__c;
        Fellowship_State = pms.Engagement__r.Fellowship_State__c;
/*        Fellowship_Metro_Area = pms.Engagement__r.Host_application__r.Fellowship_Metro_Area__c;
*/      Fellowship_City = pms.Engagement__r.Fellowship_City__c;
        Date_Engagement_Added_to_Portal = pms.Engagement__r.Date_Engagement_Added_to_Portal__c;
        accId = pms.Engagement__r.Account__c;
        AccountName = pms.Engagement__r.Account__r.Name;
        Stage = pms.Engagement__r.Stage__c;
        Accessible_by_public_transportation = pms.Engagement__r.Accessible_by_public_transportation__c;
        Workplan_from_App = pms.Engagement__r.Workplan_from_App__c;
        name = pms.Engagement__r.Name;

        // Project_Type = pms.Engagement__r.Work_Scope_Bucket__c; // 16-Jan-2015
        Project_Type = pms.Engagement__r.Project_Category__c; // For using Project Category of Host Application
        Fellowship_Location_Preference = pms.Engagement__r.Fellowship_Location_Preference__c; //26-OCT-2020

        Available_NotAvailable = 'Not Available';
        Industry = pms.Engagement__r.Industry_Classification__c; // 16-Jan-2015
        if (pms.Engagement__r.Stage__c == 'Confirmed Participation'
                ||  pms.Engagement__r.Stage__c == 'Match Conversation Complete'
                ||  pms.Engagement__r.Stage__c == 'Onboarding Conversation Not Accepted') {
            Available_NotAvailable = 'Available';
        }

        this.considerMe = considerMe;

        if (considerMe == true  &&  fromEDF  == true)
            howConsidered = 'Both';
        else if (considerMe == true  &&  fromEDF  == false)
            howConsidered = 'Consider Me';
        else if (considerMe == false  &&  fromEDF  == true)
            howConsidered = 'Potential Match from EDF';
        else if (considerMe == false  &&  fromEDF  == false)
            howConsidered = '';

        if (howConsidered != '') potentialMatch = true; else potentialMatch = false;

        Name = pms.Engagement__r.Name != null ? pms.Engagement__r.Name : '';
        //j/Past_CC_Years = pms.Engagement__r.Past_CC_Years__c != null ? pms.Engagement__r.Past_CC_Years__c : '';
        Supervisor2 = pms.Engagement__r.Supervisor2__c != null ? pms.Engagement__r.Supervisor2__c : '';
        Matching_Notes_from_EDF = pms.Engagement__r.Matching_Notes_from_EDF__c != null ? pms.Engagement__r.Matching_Notes_from_EDF__c : '';
        //j/High_Level_Sponsor_Title = pms.Engagement__r.High_Level_Sponsor_Title__c != null ? pms.Engagement__r.High_Level_Sponsor_Title__c : '';
        starColor = pms.Engagement__r.Star__c; // FB-2133 Harpreet
    }


    global Integer compareTo(Object compareTo) {
        EngagementComparatorWrapper compareToEng = (EngagementComparatorWrapper)compareTo;

        String[] vals = getValue(this, compareToEng, sortBy);

        String currValue = vals[0];
        String compareToValue = vals[1];

        if (sortDir.toLowerCase() == 'asc') {
            if (currValue > compareToValue) {
                return 1;
            }
            else if (currValue < compareToValue) {
                return -1;
            }
        }
        else if (sortDir.toLowerCase() == 'desc') {
            if (currValue < compareToValue) {
                return 1;
            }
            else if (currValue > compareToValue) {
                return -1;
            }
        }
        return 0;
    }

    private String[] getValue(EngagementComparatorWrapper engg, EngagementComparatorWrapper compareToEngg, String sortBy) {
        System.debug('::::: sortBy in GetValue :::::' + sortBy);
        List<String> retVal = new List<String>();

        if (sortBy == 'Available_NotAvailable'  ||  sortBy == 'AccountName') {
            if (sortBy == 'AccountName') {
                retVal.add(engg.AccountName);
                retVal.add(compareToEngg.AccountName);
            }
            else if (sortBy == 'Available_NotAvailable') {
                retVal.add(engg.Available_NotAvailable);
                retVal.add(compareToEngg.Available_NotAvailable);
            }
        }
        else {
            retVal.add(String.valueOf(engg.engagement.get(sortBy)));
            retVal.add(String.valueOf(compareToEngg.engagement.get(sortBy)));
        }

        /*
        if (sortBy == 'AccountName') {
            retVal.add(engg.AccountName);
            retVal.add(compareToEngg.AccountName);
        }
        else if (sortBy == 'Engagement_Type') {
            retVal.add(engg.Engagement_Type);
            retVal.add(compareToEngg.Engagement_Type);
        }
        else if (sortBy == 'Supervisor_Title') {
            retVal.add(engg.Supervisor_Title);
            retVal.add(compareToEngg.Supervisor_Title);
        }
        else if (sortBy == 'Accessible_by_public_transportation') {
            retVal.add(String.valueOf(engg.Accessible_by_public_transportation));
            retVal.add(String.valueOf(compareToEngg.Accessible_by_public_transportation));
        }
        else if (sortBy == 'Fellowship_Metro_Area') {
            retVal.add(engg.Fellowship_Metro_Area);
            retVal.add(compareToEngg.Fellowship_Metro_Area);
        }
        else if (sortBy == 'Fellowship_City') {
            retVal.add(engg.Fellowship_City);
            retVal.add(compareToEngg.Fellowship_City);
        }
        else if (sortBy == 'Fellowship_State') {
            retVal.add(engg.Fellowship_State);
            retVal.add(compareToEngg.Fellowship_State);
        }
        else if (sortBy == 'Workplan_Focus') {
            retVal.add(engg.Workplan_Focus);
            retVal.add(compareToEngg.Workplan_Focus);
        }
        else if (sortBy == 'Date_Engagement_Added_to_Portal') {
            System.debug('::::: Inside Date Sorting :::::');
            System.debug('::::: engg.Date_Engagement_Added_to_Portal :::::' + engg.Date_Engagement_Added_to_Portal);
            System.debug('::::: compareToEngg.Date_Engagement_Added_to_Portal :::::' + compareToEngg.Date_Engagement_Added_to_Portal);
            System.debug('::::: engg.Date_Engagement_Added_to_Portal :::::' + String.valueOf(engg.Date_Engagement_Added_to_Portal));
            System.debug('::::: compareToEngg.Date_Engagement_Added_to_Portal :::::' + String.valueOf(compareToEngg.Date_Engagement_Added_to_Portal));
            retVal.add(String.valueOf(engg.Date_Engagement_Added_to_Portal));
            retVal.add(String.valueOf(compareToEngg.Date_Engagement_Added_to_Portal));
        }
        else if (sortBy == 'Available_NotAvailable') {
            retVal.add(engg.Available_NotAvailable);
            retVal.add(compareToEngg.Available_NotAvailable);
        }
        */
        System.debug('::::: retVal :::::' + retVal);
        return retVal;
    }
}