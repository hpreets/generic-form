/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 3/28/2022
# Last Modified by......:
# Last Modified Date....:
# Description...........: This Class contains EngagementLists functinality.
# Test Class............: EngagementListController_Test
# Change Log:
#
############################################################################
*/
public class EngagementListController {
    public Static List<Climate_Corps_Engagement__c> engagementList;
    public static List<EngagementComparatorWrapper> engagementWList;
    public static set<Id> engIdSet = new set<Id>();
    public static Integer engagementListSize;
    public String searchText;
    // Filters selected values
    public Climate_Corps_Engagement__c selectedFilters;
    public Host_Application__c selectedHAFilters;
    public String selectedAccessibleByPublicTransport;
    public String selectedAvailableNotAvailable;
    public String selectedConsiderMe;
    public String selectedDateEngagementAdded;
    public String selectedOrgId;
    public String selectedSupervisorTitle;
    public String selectedIndustry;
    private static String sortByInt = 'Date_Engagement_Added_to_Portal__c';
    private static String sortDirInt = 'desc';
    public static String sortDir {
        get {
            return sortDirInt;
        }
        set {
            sortDirInt = value;
        }
    }

    public static String sortBy {
        get {
            return sortByInt;
        }
        set{
            if (value == sortByInt)
                sortDir = (sortDir == 'desc') ? 'asc' : 'desc';
            else
                sortDir = 'asc';
            sortByInt = value;
        }
    }



    public EngagementListController(){
        getEnggList();
    }

    /*
    * Populate engagementWList
    */
    @AuraEnabled(cacheable=true)
    public Static List<EngagementComparatorWrapper> getEnggList() {
        System.debug('INSIDE getEnggList');
        return doGetEngagementList('');
        //return null;
    }

    /**
     *
     */
    //Pani - added below method to fetch the fellowship applying for from Fellow application
    @AUraEnabled(cacheable=true)
    public static String getFellowshipFor(){
        String fellowshipFor = '';
        User usrInfo = [SELECT ID,CONTACTID FROM USER WHERE ID=:UserInfo.getUserId()];
        Contact con = new Contact();
        if(usrInfo!=null && usrInfo.ContactId!=null){
            con = [select id, (select id, Fellowship_Applying_for__c from Applications__r limit 1) from contact where id=:usrInfo.ContactId];
            if(con!=null && !con.Applications__r.isEmpty()){
                fellowshipFor = con.Applications__r[0].Fellowship_Applying_for__c;
            }
        }
        return fellowshipFor;
    }

    /**
     *
     */
    @AUraEnabled(cacheable=true)
    public static String getFelloWAppId(){
        String fAppId = '';
        User usrInfo = [SELECT ID,CONTACTID FROM USER WHERE ID=:UserInfo.getUserId()];
        Contact con = new Contact();
        if(usrInfo!=null && usrInfo.ContactId!=null){
            con = [select id, (select id from Applications__r limit 1) from contact where id=:usrInfo.ContactId];
            if(con!=null && !con.Applications__r.isEmpty()){
                fAppId = con.Applications__r[0].Id;
            }
        }
        return fAppId;
    }

    /*
    * Method that fetches engagement data based on whereCondition along with pre-defined Engagement Stages and Fellowship year.
    */
    public static List<EngagementComparatorWrapper> doGetEngagementList(String whereCondition) {
        System.debug('INSIDE doGetEngagementList');
        String studentApplicationRecordId = getFelloWAppId();
        String studentFellowshipFor = getFellowshipFor();
        //if (pageRefreshedFromSorting == null  ||  pageRefreshedFromSorting == false  ||  engagementWList == null  ||  engagementWList.size() >= 1000) {
        String query
            = 'Select Id, '
                + ' Workplan_Focus__c, '
                + ' Supervisor_Title__c, '
                + ' Host_Application__r.Fellowship_State__c, '
                + ' Fellowship_State__c, '
                + ' Fellowship_Location_Preference__c, '
                + ' Host_Application__r.Fellowship_Location_Preference__c, '
                + ' Fellowship_Metro_Area__c, '
                + ' Fellowship_City__c,'
                + ' Date_Engagement_Added_to_Portal__c, '
                + ' Account__r.Name, '
                + ' Account__c, '
                + ' Stage__c, '
                + ' Accessible_by_public_transportation__c, '
                + ' Workplan_from_App__c,  '
                + ' Name, '
                + ' Supervisor2__c, '
                + ' Matching_Notes_from_EDF__c, '//Past_CC_Years__c
                + ' Competitive_Host_Location__c, '
                + ' High_Level_Sponsor_Title__c,'
                + ' Workplan_for_Student_Portal__c, '
                + ' Industry_Classification__c,' // 16-Jan-2015
                + ' Star__c, ' // FB-2133 HSingh
                + ' Project_Category__c,'
                + ' Fellowship_Program__c, ' // Added by HS 7/15/21
                + ' Competitive_Host_based_on_ConsiderMe__c, ' // 15-Dec-2015 - Changes by Harpreet
                + ' Prioritize_for_Consider_Mes__c, ' // 7/1/2021 - Changed by Harpreet
                + ' (Select Id, '
                    + ' Engagement__c, '
                    + ' How_Considered__c, '
                    + ' Student_Application__c, '
                    + ' Why__c,'
                    + ' Rank__c,'
                    + ' Bookmark__c, ' // 8-Dec-2015 - Changes by Sakshi
                    + ' Status__c ' // FB-1917 HSingh
                    + 'From Potential_Matching_From_Screeners__r '
                    + 'Where Student_Application__c = \'' + studentApplicationRecordId + '\' '
                        + ' AND Is_Deleted__c = false '
                        + ' AND How_Considered__c = \'Consider Me\' '
                        + ' AND Status__c != \'Archived\') ' // FB-1944
                    + 'Matching '
            + ' From Climate_Corps_Engagement__c '
            + ' Where ( '
                    + ' Stage__c = \'Confirmed Participation\' '
                    // Commenting all other stages - FB-2223
                    // + ' OR Stage__c = \'Match Conversation Complete\' '
                    // + ' OR Stage__c = \'Customized - Host Recruits Fellow(s)\' '
                    // + ' OR Stage__c = \'Offer Sent\'  '
                    // + ' OR Stage__c = \'Offer Accepted\' '
                    // + ' OR Stage__c = \'Onboarding Conversation In Progress\'  '
                    // + ' OR Stage__c = \'Onboarding Conversation Complete\' '
                    + ' OR Stage__c = \'Onboarding Conversation Not Accepted\' '
                    //+ ' OR Stage__c = \'Engagement Confirmed\'' //Sakshi: Commented on 03-31-2016 to remove Engagement Confirmed engagements from page
                    // + ' OR Stage__c = \'Final Deliverables Received\'  '
                    // + ' OR Stage__c = \'Complete\' '
                + ' )  '
                + ' AND Fellowship_Program__c = \'' + studentFellowshipFor + '\' ' // Pani: added this filter to show the engagements based on the fellowship (India, US, China)
                + ' AND CC_Year__c = \'' + CustomSettings_Helper.getEDFCCGlobalValue('CurrentFellowshipYear') + '\' ';
        // String queryEnd = ' order by ' + sortBy + ' ' + sortDir + ' limit 1000';
        String queryEnd = ' limit 1000';
        System.debug('QUERY >>>>' + query + whereCondition + queryEnd);
        engagementList = Database.Query(query + whereCondition + queryEnd);

        if (engagementList == null) engagementList = new List<Climate_Corps_Engagement__c>();
        System.debug('::::: engagementList ::::: ' + engagementList);
        //}
        /*Code Changes by Sakshi for ViewState error - Start */
        for(Climate_Corps_Engagement__c eng : engagementList)
            engIdSet.add(eng.Id);
        /*Code Changes by Sakshi for ViewState error - End */
        // Convert it to wrapper
        engagementWList = getEngagementWrapperList(engagementList);
        System.debug('engagementWList BEFORE SORT :::: ' + engagementWList);
        engagementWList.sort();

        System.debug('engagementWList AFTER SORT :::: ' + engagementWList);
        System.debug('Final Return engagementWList:::'+engagementWList.size());
        return engagementWList;

    }


    /*
    * Convert Engagement records to EngagementComparatorWrapper records.
    */
    private static List<EngagementComparatorWrapper> getEngagementWrapperList(List<Climate_Corps_Engagement__c> engList) {
        List<EngagementComparatorWrapper> engWList = new List<EngagementComparatorWrapper>();
        if (engList != null  &&  engList.size() > 0) {
            for (Climate_Corps_Engagement__c eng : engList) {

                // Filter for "Consider Me"
                Boolean addToList = true;

                if (addToList) {
                    System.debug('::::: sortBy preparing for Sorting :::::' + sortBy);
                    System.debug('::::: sortDir preparing for Sorting :::::' + sortDir);
                    EngagementComparatorWrapper engW = new EngagementComparatorWrapper(eng, sortBy, sortDir);
                    engWList.add(engW);
                }
            }
        }
        engagementListSize = engWList.size();
        System.debug('engagementListSize >>>>' + engagementListSize);
        return engWList;
    }


    /**
     *
     */
    public class SearchFilterWrapper{

        @AuraEnabled
        public String fellowshipcity {get; set;}
        @AuraEnabled
        public String fellowshipstate {get; set;}
        @AuraEnabled
        public String publicTransport {get; set;}
        @AuraEnabled
        public String industry {get; set;}
        @AuraEnabled
        public String availableNotAvailable {get; set;}
        @AuraEnabled
        public String projectType {get; set;}
        @AuraEnabled
        public String locationPreferance {get; set;}

        // Commented by HSingh FB-2139
        /*@AuraEnabled
        public String engagementProgram {get; set;} */
        @AuraEnabled
        public String searchText {get; set;}

    }


    /**
     *
     */
    @AuraEnabled
    public static List<EngagementComparatorWrapper> searchEngagements(SearchFilterWrapper searchFilterWrapper) {

        String whereCondition = '';
        Boolean nonSearchText = false;
        String fullSearchIDsCondition = '';
        Set<String> ccIds = new Set<String>();
        Boolean doFullTextSearch = true;

        //added
        String searchText = null;
        System.debug('****searchFilterWrapper****'+searchFilterWrapper);


        if (searchFilterWrapper.searchText != null) searchText = searchFilterWrapper.searchText.trim();
        if (searchText?.length() <= 1) doFullTextSearch = false;

        /*
        While testing search manually test for following conditions. With changes, the code has become quite complex.
        1. Only filters that return data
        2. Only filters that does not return data
        3. Only Search that return data
        4. Only Search that does not return data
        5. Combination of 1 & 3
        6. Combination of 1 & 4
        7. Combination of 2 & 3
        8. Combination of 2 & 4
        */

        if (searchFilterWrapper != null) {

            if (searchFilterWrapper.fellowshipcity != null  &&  searchFilterWrapper.fellowshipcity != '') whereCondition = whereCondition + ' AND Fellowship_City__c =\'' + String.escapeSingleQuotes(searchFilterWrapper.fellowshipcity) + '\'';
            if (searchFilterWrapper.fellowshipstate != null  &&  searchFilterWrapper.fellowshipstate != '') whereCondition = whereCondition + ' AND Fellowship_State__c =\'' + String.escapeSingleQuotes(searchFilterWrapper.fellowshipstate) + '\'';

            if (searchFilterWrapper.publicTransport != null  &&  searchFilterWrapper.publicTransport != '') {
                if (searchFilterWrapper.publicTransport == 'yes') whereCondition = whereCondition + ' AND Accessible_by_public_transportation__c = true ';
                else whereCondition = whereCondition + ' AND Accessible_by_public_transportation__c = false ';
            }

            if (searchFilterWrapper.industry != null) whereCondition = whereCondition + ' AND Industry_Classification__c = \'' + String.escapeSingleQuotes(searchFilterWrapper.industry) + '\'';

            if (searchFilterWrapper.availableNotAvailable != null  &&  searchFilterWrapper.availableNotAvailable == 'available') {
                whereCondition = whereCondition + ' AND (Stage__c = \'Confirmed Participation\'  OR  Stage__c = \'Match Conversation Complete\'  OR  Stage__c = \'Onboarding Conversation Not Accepted\')';
            }
            if (searchFilterWrapper.availableNotAvailable != null  &&  searchFilterWrapper.availableNotAvailable == 'notavailable') {
                whereCondition = whereCondition + ' AND (Stage__c = \'Customized - Host Recruits Fellow(s)\'  OR  Stage__c = \'Offer Letter Sent\'  OR  Stage__c = \'Offer Accepted\'  OR  Stage__c = \'Onboarding Conversation In Progress\'  OR  Stage__c = \'Onboarding Conversation Complete\'  OR  Stage__c = \'Engagement Confirmed\'  OR  Stage__c = \'Final Deliverables Received\' OR  Stage__c = \'Offer Sent\' OR  Stage__c = \'Complete\')';
            }

            // For using Project Category of Host Application
            if (searchFilterWrapper.projectType != null  &&  searchFilterWrapper.projectType != '') {
                whereCondition = whereCondition + ' AND Project_Category__c =\'' + String.escapeSingleQuotes(searchFilterWrapper.projectType) + '\'';
            }
            //Added by SaiTeja 26-OCT-2020
            if (searchFilterWrapper.locationPreferance != null  &&  searchFilterWrapper.locationPreferance != '') {
                whereCondition = whereCondition + ' AND Fellowship_Location_Preference__c =\'' + String.escapeSingleQuotes(searchFilterWrapper.locationPreferance) + '\'';
            }

            //
            //Added by Kranthi 18-Apr-2022
            // Commented by HSingh FB-2139
            /*if (searchFilterWrapper.engagementProgram != null  &&  searchFilterWrapper.engagementProgram != '') {
                whereCondition = whereCondition + ' AND Fellowship_Program__c =\'' + searchFilterWrapper.engagementProgram + '\'';
            }*/

            if (whereCondition.length() > 0) nonSearchText = true;
        }

        if (searchText != null  &&  searchText != ''  &&  doFullTextSearch) {

            String searchquery='FIND\'' + searchText + '*\'IN ALL FIELDS RETURNING Climate_Corps_Engagement__c '
                + '(Id WHERE CC_Year__c = \'' + CustomSettings_Helper.getEDFCCGlobalValue('CurrentFellowshipYear') + '\')'; // Added by HSingh FB-2151
            List<List<SObject>>searchList = search.query(searchquery);

            if (searchList != null  &&  searchList[0].size() > 0) {
                fullSearchIDsCondition = ' AND ID in ( ';
                for (SObject sObj : searchList[0]) {
                    ccIds.add(sObj.Id);
                    fullSearchIDsCondition = fullSearchIDsCondition + '\'' + sObj.Id + '\', ';
                }
                fullSearchIDsCondition = fullSearchIDsCondition.substring(0, fullSearchIDsCondition.length() - 2) + ' )';
            }
            else {
                // If no data found, it means that search result should be zero. Hence creating condition to return zero data.
                fullSearchIDsCondition = ' AND ID in ( \'123456789012345678\' )';
            }
        }
        System.debug('whereCondition ======' + whereCondition);

        // Search using Filters + Search Text
        if (whereCondition.length() > 4) {
            System.debug('whereCondition.substring(4) ======' + whereCondition.substring(4));
            System.debug('whereCondition.substring(4) + fullSearchIDsCondition ======' + whereCondition.substring(4) + fullSearchIDsCondition);
            List<Climate_Corps_Engagement__c> ccEngIds = Database.Query('SELECT ID FROM Climate_Corps_Engagement__c c WHERE ' + whereCondition.substring(4) + fullSearchIDsCondition);
            System.debug('::::::::: ccEngIds == null  ||  ccEngIds.size() <= 0 :::::' + (ccEngIds == null  ||  ccEngIds.size() <= 0));
            if (ccEngIds != null  &&  ccEngIds.size() > 0) {
                ccIds = new Set<String>();
                for (Climate_Corps_Engagement__c cc : ccEngIds) {
                    ccIds.add(cc.Id);
                }
            }
            else if (ccEngIds == null  ||  ccEngIds.size() <= 0) {
                ccIds = new Set<String>();
                whereCondition = '';
            }
            System.debug(':::: After Filters + SearchText ::::: whereCondition :::::' + whereCondition);
        }

        if (ccIds != null  &&  ccIds.size() > 0) {
            whereCondition = ' AND ID in ( ';
            for (String id : ccIds) {
                whereCondition = whereCondition + '\'' + id + '\', ';
            }
            whereCondition = whereCondition.substring(0, whereCondition.length() - 2) + ' )';
        }

        // FINAL - If there was search text or filters and it did not yield any results, set a condition explicitely that we know will return no results.
        if (whereCondition == ''  && (nonSearchText == true || (searchText != null && searchText != ''))) {
            whereCondition = ' AND CC_Year__c = \'1900\' ';
        }

        return doGetEngagementList(whereCondition);

    }


    /**
     * For Submission of Consider Me
     */
    @AuraEnabled
    public static Boolean submitConsiderMe(List<Potential_Matching_From_Screener__c> coniderMeRecords,String fellAppId){
        try {
            Boolean moveForward = true;
            List<Potential_Matching_From_Screener__c> pMatch = [
                SELECT Id, Engagement__c, How_Considered__c, Student_Application__c
                FROM Potential_Matching_From_Screener__c
                WHERE Student_Application__c = :fellAppId
                    AND How_Considered__c = 'Consider Me' AND Is_Deleted__c = false
                    AND Status__c != 'Archived']; // FB-1944 Harpreet
            if (pMatch != null  &&  pMatch.size() > 0) {
                // for(Potential_Matching_From_Screener__c pmscr : pMatch){
                //     pmscr.Is_Deleted__c = true;
                // }
                Database.DeleteResult[] drList = Database.Delete(pMatch, true);
                for (Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        return false;
                    }
                }
            }

            list<Potential_Matching_From_Screener__c> pMatchInsertList = new list<Potential_Matching_From_Screener__c>();
            for(Potential_Matching_From_Screener__c wrap : coniderMeRecords){
                Potential_Matching_From_Screener__c pMatchObj = new Potential_Matching_From_Screener__c();
                pMatchObj.Engagement__c = wrap.Engagement__c;
                pMatchObj.How_Considered__c = 'Consider Me';
                pMatchObj.Student_Application__c = fellAppId;
                pMatchObj.Why__c = wrap.Why__c;
                if(wrap.Rank__c!='0'){
                    pMatchObj.Rank__c = wrap.Rank__c;
                }
                pMatchObj.Bookmark__c = wrap.Bookmark__c;

                // FB-1917 Harpreet
                if (String.isBlank(pMatchObj.Why__c)  &&  pMatchObj.Bookmark__c) pMatchObj.Status__c = 'Bookmarked';
                else if (!String.isBlank(pMatchObj.Why__c)  &&  pMatchObj.Rank__c != null) pMatchObj.Status__c = 'Submitted';

                pMatchInsertList.add(pMatchObj);
            }
            if(!pMatchInsertList.isEmpty()){
                list<Database.SaveResult> srList = Database.insert(pMatchInsertList, true);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        return false;
                    }
                }
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * For Save (not Submit) of Consider Me
     */
    @AuraEnabled
    public static Boolean saveConsiderMe(List<Potential_Matching_From_Screener__c> coniderMeRecords, String fellAppId){
        try {
            Boolean moveForward = true;

            System.debug('coniderMeRecords ::' + coniderMeRecords);
            List<Potential_Matching_From_Screener__c> tbDel = new List<Potential_Matching_From_Screener__c>();
            Set<Id> tbDelIds = new Set<Id>();
            for(Potential_Matching_From_Screener__c wrap : coniderMeRecords) {
                System.debug(wrap.Id != null  &&  String.isBlank(wrap.Why__c)  &&  String.isNotBlank(wrap.Rank__c)  &&  wrap.Rank__c != '0'  &&  !wrap.Bookmark__c);
                System.debug('Id :: ' + wrap.Id + '; Why ::' + wrap.Why__c + '; Rank ::' + wrap.Rank__c + '; Bookmark ::' + wrap.Bookmark__c);

                if (wrap.Id != null  &&  String.isBlank(wrap.Why__c)  &&  (String.isBlank(wrap.Rank__c)  ||  wrap.Rank__c == '0')  &&  !wrap.Bookmark__c) {
                    System.debug('READY TO BE DELETED');
                    System.debug(wrap);
                    tbDel.add(new Potential_Matching_From_Screener__c(Id = wrap.Id));
                    tbDelIds.add(wrap.Id);
                }
            }
            if (tbDel.size() > 0) {
                Database.DeleteResult[] drList = Database.Delete(tbDel, true);
                System.debug(drList);
                for (Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        return false;
                    }
                }
            }

            /*List<Potential_Matching_From_Screener__c> pMatch = [
                SELECT Id, Engagement__c, How_Considered__c, Student_Application__c
                FROM Potential_Matching_From_Screener__c
                WHERE Student_Application__c = :fellAppId
                    AND How_Considered__c = 'Consider Me' AND Is_Deleted__c = false
                    AND Status__c != 'Archived']; // FB-1944 Harpreet
            if (pMatch != null  &&  pMatch.size() > 0) {
                Database.DeleteResult[] drList = Database.Delete(pMatch, true);
                for (Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        return false;
                    }
                }
            }*/
            list<Potential_Matching_From_Screener__c> pMatchInsertList = new list<Potential_Matching_From_Screener__c>();
            for(Potential_Matching_From_Screener__c wrap : coniderMeRecords) {
                if (!tbDelIds.contains(wrap.Id)) {
                    Potential_Matching_From_Screener__c pMatchObj = new Potential_Matching_From_Screener__c();
                    pMatchObj.Engagement__c = wrap.Engagement__c;
                    pMatchObj.How_Considered__c = 'Consider Me';
                    pMatchObj.Student_Application__c = fellAppId;
                    pMatchObj.Why__c = wrap.Why__c;
                    if (wrap.Id != null) pMatchObj.Id = wrap.Id;
                    if(wrap.Rank__c!='0'){
                        pMatchObj.Rank__c = wrap.Rank__c;
                    }
                    else {
                        pMatchObj.Rank__c = null;
                    }

                    pMatchObj.Bookmark__c = wrap.Bookmark__c;

                    // FB-1917 Harpreet
                    if (String.isBlank(pMatchObj.Why__c)  &&  pMatchObj.Bookmark__c) pMatchObj.Status__c = 'Bookmarked';
                    else if (String.isBlank(pMatchObj.Why__c)  &&  pMatchObj.Rank__c != null) pMatchObj.Status__c = 'Ranked';
                    else if (!String.isBlank(pMatchObj.Why__c)) pMatchObj.Status__c = 'Not Submitted';

                    pMatchInsertList.add(pMatchObj);
                }
            }

            System.debug('pMatchInsertList ::' + pMatchInsertList);

            if(!pMatchInsertList.isEmpty()) {
                List<Database.UpsertResult> urList = Database.upsert(pMatchInsertList, true);
                for (Database.UpsertResult ur : urList) {
                    if (!ur.isSuccess()) {
                        return false;
                    }
                }
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     *
     */
    @AuraEnabled(cacheable=true)
    public Static String getFellowshipApplyingFor() {
        String fellow = getFelloWAppId();
        if(fellow !=null){
            Fellow_Application__c fapp = [SELECT id,Fellowship_Applying_for__c FROM Fellow_Application__c WHERE id=:fellow LIMIT 1];
            System.debug('fapp:'+fapp);
            return fapp.Fellowship_Applying_for__c;
        }else{
            return 'Error';
        }

    }

    /**
     *
     */
    @AuraEnabled(Cacheable=true)
    public static settingsWrapper getEngagementListSettings(string fellowshipApplyingFor){
        System.debug('fellowshipApplyingFor:'+fellowshipApplyingFor);
        settingsWrapper wrap = new settingsWrapper();
        Fellow_Application_Engagement__mdt fae = [SELECT Id, Country__c, MinimumEngagements__c, MaximumEngagements__c FROM Fellow_Application_Engagement__mdt WHERE Country__c=:fellowshipApplyingFor LIMIt 1 ];
        if(fae!=null){
            wrap.minEngagements = fae.MinimumEngagements__c;
            wrap.maxEngagements = fae.MaximumEngagements__c;
            wrap.country = fae.Country__c;
        }
        return wrap;
    }

    /**
     *
     */
    public class settingsWrapper{
        @AuraEnabled
        public Decimal maxEngagements{get;Set;}
        @AuraEnabled
        public Decimal minEngagements{get;Set;}
        @AuraEnabled
        public String country{get;Set;}

        // public settingsWrapper(Integer maxEngagements,  Integer minEngagements){
        //     this.maxEngagements = maxEngagements;
        //     this.minEngagements = minEngagements;
        // }
    }

}