/**
 * Created by robertwright on 4/15/22.
 */

@IsTest
private class ContactMerge_TDTM_Test {
    @IsTest
    static void run() {
        ContactMerge_TDTM cls = new ContactMerge_TDTM();
        cls.run(new list<Contact>(),new list<Contact>{new Contact(Id='0035e00000EMQfzAAH')},npsp.TDTM_Runnable.Action.AfterDelete,Contact.getSObjectType().getDescribe(),new npsp.TDTM_Runnable.DmlWrapper());
        ContactMerge_TDTM.callFlow(new Contact(Id='0035e00000EMQfzAAH'));
    }
}