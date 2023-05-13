/**
 * Created by robertwright on 1/13/22.
 */

@IsTest
private class DLRS_TDTM_TEST {
    @IsTest
    static void testBehavior() {
        try{
            DLRS_TDTM controller = new DLRS_TDTM();
            controller.run(
                    new list<Contact>(),
                    new List<Contact>(),
                    npsp.TDTM_Runnable.Action.BeforeInsert,
                    Contact.getSObjectType().getDescribe(),
                    new npsp.TDTM_Runnable.DmlWrapper()
            );
        } catch(Exception ex) {
            system.debug(ex.getMessage());
        }
    }
}