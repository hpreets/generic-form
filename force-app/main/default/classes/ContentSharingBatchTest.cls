@IsTest
public class ContentSharingBatchTest {


    @IsTest
    public static void testContentSharing(){


        CollaborationGroup testChatterGroup = new CollaborationGroup(
            Name =  'my group 12312312',
            CollaborationType = 'Public');
        insert testChatterGroup;

        ContentNote note = new ContentNote(Title = 'hello', Content = Blob.valueOf('Test Content'));
        insert note;

        Test.startTest();
                ContentSharingBatch  bj  = new ContentSharingBatch(testChatterGroup.Name, 'PVT');
                Database.executeBatch(bj);
        Test.stopTest();

        List<ContentDocument> contentDocuments = [SELECT ID,
        (SELECT ID, LinkedEntityId FROM ContentDocumentLinks) FROM ContentDocument LIMIT 10];

        System.assertEquals(1, contentDocuments.size());
        System.assertEquals(2, contentDocuments[0].ContentDocumentLinks.size());

        Set<Id> linkedEntityIDs = new Set<Id>();

        for (ContentDocumentLink cdl : contentDocuments[0].ContentDocumentLinks){
            linkedEntityIDs.add(cdl.LinkedEntityId);
        }

        System.assert(linkedEntityIDs.contains(testChatterGroup.Id));


    }

    @IsTest
    public static void testScheduler(){
        Test.startTest();
            System.schedule('Scheduled Job 1'  + Math.random(), '0 0 * * * ?', new ContentSharingBatch());
        Test.stopTest();
    }




//    @IsTest
//    public static void testContentSharingWithAdditionalLinks(){
//
//
//        CollaborationGroup testChatterGroup = new CollaborationGroup(
//            Name =  ContentSharingBatch.chatterGroupName,
//            CollaborationType = 'Public');
//        insert testChatterGroup;
//
//        Lead l = new Lead();
//
//        ContentVersion cv = setContentVersion('test title', true);
////        System.assertNotEquals(null, cv.ContentDocumentId);
//        ContentDocumentLink cdl = setContentDocumentLink(cv.ContentDocumentId, testChatterGroup.Id,true);
//
//        Test.startTest();
//                ContentSharingBatch  bj  = new ContentSharingBatch();
//                Database.executeBatch(bj);
//        Test.stopTest();
//
//        List<ContentDocument> contentDocuments = [SELECT ID,
//        (SELECT ID, LinkedEntityId FROM ContentDocumentLinks) FROM ContentDocument LIMIT 10];
//
//        System.assertEquals(1, contentDocuments.size());
//        System.assertEquals(2, contentDocuments[0].ContentDocumentLinks.size());
//
//        Set<Id> linkedEntityIDs = new Set<Id>();
//
//        for (ContentDocumentLink cdl : contentDocuments[0].ContentDocumentLinks){
//            linkedEntityIDs.add(cdl.LinkedEntityId);
//        }
//
//        System.assert(linkedEntityIDs.contains(testChatterGroup.Id));
//
//
//    }


    private static ContentVersion setContentVersion(String title, Boolean isInsert){
        ContentVersion cv =  new ContentVersion( Title = title,
                PathOnClient = title + '.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true);

        if (isInsert) insert cv;
        return cv;

    }

    private static ContentDocumentLink setContentDocumentLink(Id contentDocId, Id linkedEntId, Boolean isInsert){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = contentDocId,
                LinkedEntityId = linkedEntId,
                ShareType = 'V',
                Visibility = 'AllUsers');

        if (isInsert) insert contentDocumentLink;
        return contentDocumentLink;
    }

}