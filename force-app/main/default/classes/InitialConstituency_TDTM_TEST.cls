/**
 * Created by robertwright on 1/13/22.
 */

@IsTest
private class InitialConstituency_TDTM_TEST {
    @IsTest
    static void testBehavior() {
        InitialConstituency_TDTM controller = new InitialConstituency_TDTM();
        controller.run(
                new list<Contact>(),
                new List<Contact>(),
                npsp.TDTM_Runnable.Action.BeforeInsert,
                Contact.getSObjectType().getDescribe(),
                new npsp.TDTM_Runnable.DmlWrapper()
        );
        InitialConstituency_TDTM.process(new Contact());
    }
}