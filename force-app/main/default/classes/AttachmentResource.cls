/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 12/21/2021
# Last Modified by......:
# Last Modified Date....: 
# Description...........: Wrapper for EngagementController(portal deliverables).
# Test Class............: Test_WrapperControllers
# Change Log:
# 
############################################################################
*/
public class AttachmentResource {
    public Id savedId { get;set; } 
    public String savedName { get;set; } 
    public transient Blob attachmentBody { get; set; }
    public transient String attachmentName { get; set; }
    public String extenstionName { get;set; }
    public String objName { get;set; }
    public ContentVersion cv { get; set; }
    public ContentDocumentLink cdl { get; set; }
    public Boolean existingContentVersion { get; set; }
    public String displayName {
        get {
            if (displayName == null  ||  displayName == '') return savedName; else return displayName;
        }
        set;
    } 

    public AttachmentResource() {
        cv = new ContentVersion();
        System.debug('Inside AttachmentResource constructor :: Created a new instance of cv ::' + cv);
    }

}