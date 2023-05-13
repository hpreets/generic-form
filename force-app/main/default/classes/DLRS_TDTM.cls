global without sharing class DLRS_TDTM extends npsp.TDTM_RunnableMutable {
    global override void run(List<SObject> listNew, List<SObject> listOld,
            npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
            npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {
       dlrs.RollupService.triggerHandler(objResult.getSObjectType());
    }
}