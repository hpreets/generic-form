global class ContentSharingBatch implements Database.Batchable<sObject>, Schedulable{
    private String chatterGroupName;
    private  String excludedKeyword;

    public ContentSharingBatch(String chatterGroupName, String excludedKeyword) {
        this.chatterGroupName = chatterGroupName;
        this.excludedKeyword = excludedKeyword;
    }

    public ContentSharingBatch() {
//        this.chatterGroupName = chatterGroupName;
//        this.excludedKeyword = excludedKeyword;
        // List<NoteSharingSetting__mdt> settings = [SELECT ID, ChatterGroupName__c, ExcludedKeyword__c FROM NoteSharingSetting__mdt LIMIT 1];
        List<NoteSharingSetting__mdt> settings = NoteSharingSetting__mdt.getAll().values();
        if (!settings.isEmpty() && String.isBlank(this.chatterGroupName) && String.isBlank(this.excludedKeyword)){
            this.chatterGroupName = settings[0].ChatterGroupName__c;
            this.excludedKeyword = settings[0].ExcludedKeyword__c;
        }
    }

    public void execute(System.SchedulableContext SC){
        ContentSharingBatch bac = new ContentSharingBatch();
        database.executeBatch(bac);
    }

    global Database.Querylocator start(Database.BatchableContext BC){


        if (String.isBlank(this.chatterGroupName) || String.isBlank(this.excludedKeyword)){
            List<NoteSharingSetting__mdt> settings = [SELECT ID, ChatterGroupName__c, ExcludedKeyword__c FROM NoteSharingSetting__mdt LIMIT 1];
            if (!settings.isEmpty() && String.isBlank(this.chatterGroupName) && String.isBlank(this.excludedKeyword)){
                this.chatterGroupName = settings[0].ChatterGroupName__c;
                this.excludedKeyword = settings[0].ExcludedKeyword__c;
            }
        }

        String dbQuery = 'select ID, CreatedBy.Id, (SELECT ID, LinkedEntity.Type FROM ContentDocumentLinks)\n' +
                '                        FROM ContentDocument WHERE CreatedById IN\n' +
                '                (SELECT MemberId FROM CollaborationGroupMember  WHERE\n' +
                '                        CollaborationGroup.Name = :chatterGroupName)\n' +
                '                AND (NOT Title LIKE \'%' + excludedKeyword + '%\') AND SharingPrivacy != \'P\' and CreatedDate = LAST_N_DAYS:1';

        return Database.getQueryLocator(dbQuery);
    }

    global void execute(Database.BatchableContext BC, List<ContentDocument> contentDocuments) {

    
        Map<Id, ContentDocument> contentDocByIDMap = new Map<Id, ContentDocument>(contentDocuments);
        // get only objects valid objects to work on
        cleanDocsList(contentDocByIDMap, contentDocuments);

        // find a chatter group
        List<CollaborationGroup> groups = [SELECT ID FROM CollaborationGroup WHERE Name = :chatterGroupName LIMIT 1];

        if (groups.size() == 0) return;

//        // then find a content note related to this
        List<ContentNote> contentNotes = [SELECT ID, Title FROM ContentNote
                                            WHERE ID IN :contentDocByIDMap.keySet() AND SharingPrivacy != 'P'];

            
        Set<Id> contentNoteIDs = new Set<Id>();    
        // update sharing
        for (ContentNote cn : contentNotes){
            cn.SharingPrivacy = 'P';
            contentNoteIDs.add(cn.Id);
        }

        update contentNotes;



        //also update files
        List<ContentDocument> contentDocs = [SELECT Id FROM ContentDocument WHERE ID IN :contentDocByIDMap.keySet()
                                             AND ID NOT IN :contentNoteIDs];

        for (ContentDocument cd : contentDocs){
            cd.SharingPrivacy = 'P';                                    
        }

        update contentDocs;
        

        // now share the notes
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

        for (ContentNote cn : contentNotes){
            contentDocumentLinks.add(
                    new ContentDocumentLink(
                            ContentDocumentId = cn.Id,
                            LinkedEntityId = groups[0].Id,
                            ShareType = 'V')
            );
        }

        for (ContentDocument cd : contentDocs){
            contentDocumentLinks.add(
                    new ContentDocumentLink(
                            ContentDocumentId = cd.Id,
                            LinkedEntityId = groups[0].Id,
                            ShareType = 'V')
            );
        }
        

        // insert contentDocumentLinks;
        Database.insert(contentDocumentLinks, false);

    }

    private static void cleanDocsList(Map<Id, ContentDocument> contentDocByIDMap, List<ContentDocument> contentDocuments){
        Set<String> rightList = new Set<String>{ 'Account','Contact', 'Task', 'Event', 'User', 'CollaborationGroup'};
        Set<String> wrongList = new Set<String>();

        for (AggregateResult aggr : [SELECT SObjectType FROM ObjectPermissions
                                    WHERE SobjectType NOT IN :rightList
                                    GROUP BY SObjectType ] ){
                                        wrongList.add(aggr.get('SObjectType').toString());
                                    }

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

        for (ContentDocument cdl : contentDocuments){
            contentDocumentLinks.addAll(cdl.ContentDocumentLinks);
        }

        Map<ID, ContentDocumentLink> allContLinksByIDs = new Map<Id, ContentDocumentLink>(contentDocumentLinks);

        List<AggregateResult> links = [SELECT ContentDocumentId, LinkedEntity.Type sObj
                                       FROM ContentDocumentLink
                                       WHERE ID IN :allContLinksByIDs.keySet() GROUP BY LinkedEntity.Type, ContentDocumentId];

        Map<Id, Set<String>> contentDocBySharedTypes = new Map<Id, Set<String>>();

        for (AggregateResult agr : links){
            Id contentDocID = (Id) agr.get('ContentDocumentId');
            String sobj = (String) agr.get('sObj');

            Set<String> types = contentDocBySharedTypes.get(contentDocID);
            if (types == null) types = new Set<String>();
            types.add(sobj);

            contentDocBySharedTypes.put(contentDocID, types);
        }

//        System.debug('contentDocBySharedTypes: ' +  JSON.serializePretty(contentDocBySharedTypes));

        // now go through the docs and remove those which are not valid
        for (Id contentDocID : contentDocBySharedTypes.keySet()){
            Set<String> contentDocSharedTypes = contentDocBySharedTypes.get(contentDocID);
//            System.debug('contentDocSharedTypes: before: ' + contentDocSharedTypes);
            Integer size = contentDocSharedTypes.size();
            contentDocSharedTypes.removeAll(wrongList);
//            System.debug('contentDocSharedTypes: after: ' + contentDocSharedTypes);
            Integer cleanedSize = contentDocSharedTypes.size();

            Boolean includesWrongObject = (size != cleanedSize);
//            System.debug('includesWrongObject: ' + includesWrongObject);
            if (includesWrongObject){
                contentDocByIDMap.remove(contentDocID);
            }
        }

    }

    global void finish(Database.BatchableContext BC){
        System.debug('ContentSharingBatch job finished');
    }


}