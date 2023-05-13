global without sharing class ContactMerge_TDTM extends npsp.TDTM_RunnableMutable {
    global override void run(List<SObject> listNew, List<SObject> listOld,
            npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
            npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete && objResult.getSObjectType() == Contact.getSObjectType()) process(listOld);
    }
 
    private static void process(list<SObject> records) {
        for(Contact contact : (list<Contact>) records) {
            if(String.isNotBlank(contact.MasterRecordId)) callFlow(contact);
        }
    }

    @TestVisible
    private static void callFlow(Contact oldContact) {
        Map<String, Object> mergeFlowInputMap = new Map<String, Object>();
        mergeFlowInputMap.put('oldContact', oldContact);
        mergeFlowInputMap.put('MasterRecordId', oldContact.MasterRecordId);
        Flow.Interview.Contact_Merge_Duplicate_Merge_Audit_Trail mergeFlow = new Flow.Interview.Contact_Merge_Duplicate_Merge_Audit_Trail(mergeFlowInputMap);
        mergeFlow.start();
    }

}