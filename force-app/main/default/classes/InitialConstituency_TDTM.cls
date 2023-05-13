/**
 * Created by robertwright on 1/13/22.
 */

global without sharing class InitialConstituency_TDTM extends npsp.TDTM_RunnableMutable {
    global override void run(List<SObject> listNew, List<SObject> listOld,
            npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
            npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {
        if (objResult.SobjectType == Contact.SobjectType && triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
            for(Contact con : (list<Contact>) listNew) process(con);
        }
    }

    @TestVisible
    private static void  process(Contact con) {
        list<String> constituencies = new List<String>();
        if(string.isNotBlank(con.Constituency__c)) constituencies = con.Constituency__c.split(';');
        constituencies.sort();
        if(!constituencies.isEmpty()) con.Initial_Constituency__c = constituencies[0];
    }
}