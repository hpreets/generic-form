/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 3/9/2022
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Test class for ContactWrapper,UserWrapper,AttachmentResource 
# Change Log:               
#
#
############################################################################
*/
@isTest
public class Test_WrapperControllers {
    
    static testMethod void myUserWrapper(){
        UserWrapper u = new UserWrapper();
        u.firstName='Test';
        u.lastName='Record';
        u.stage='abc';
        u.userName='abc';
        
    }
    static testMethod void myContactWrapper(){
        ContactWrapper cw = new ContactWrapper();
        cw.mailingStateDropdown ='TestState';
        cw.mailingStreet= 'Test Street';
        cw.fellowshipApplyingFor ='India Fellowship';
        cw.pronouns='He/Him/His';
        cw.howDidYouFindUs='Other (please specify)';
        cw.howDidYouFindUsIfOther='Test Other Way';
        cw.returnerFellow='No';
        cw.gender='Man';
        cw.genderSelfDescribe='other';
        cw.latinxOrHispanic='Yes';
        cw.veteranStatus='I am not a protected veteran	';
        
    }
    static testMethod void myAttachmentResource(){
        AttachmentResource ar = new AttachmentResource();
        ar.savedId='a148G000000RbWM';
        ar.attachmentName='resume';
        ar.displayName='';
        ar.objName='FellowApplication__c';
        ar.savedName='FellowName_Resume';
        ar.attachmentBody=Blob.valueof('Some random body');
        ar.extenstionName='.pdf';
        ar.existingContentVersion=true;
        Engagement_Controller.photoAttachment=ar;
        Engagement_Controller.workPlanAttachment=ar;
        Engagement_Controller.onsitePhotoAttachment=ar;
        Engagement_Controller.onsitePhotoAttachment2=ar;
        Engagement_Controller.onsitePhotoAttachment3=ar;
        Engagement_Controller.remainingDeliverablesAttachment=ar;
        Engagement_Controller.projectDataBaseAttachment=ar;
            
        
        
    }

}