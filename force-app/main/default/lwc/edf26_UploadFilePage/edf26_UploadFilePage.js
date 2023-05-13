import { LightningElement, wire, api, track } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import FELLOWAPPLICATION_OBJECT from "@salesforce/schema/Fellow_Application__c";
import CLIMATECORPSENGAGEMENT_OBJECT from "@salesforce/schema/Climate_Corps_Engagement__c";
import UPLOADCATEGORYA_FIELD from "@salesforce/schema/Fellow_Application__c.Upload_Category__c";
import UPLOADCATEGORYC_FIELD from "@salesforce/schema/Climate_Corps_Engagement__c.Upload_Category__c";
import getFellowEngagementEDF from "@salesforce/apex/Engagement_Controller.getFellowEngagementEDF";
import fetchFiles from "@salesforce/apex/Engagement_Controller.fetchFiles";
import fetchEngagementFiles from "@salesforce/apex/Engagement_Controller.fetchFiles";
import deleteDocument from "@salesforce/apex/Engagement_Controller.deleteDocument";
import renameAttachments from "@salesforce/apex/Engagement_Controller.renameAttachments";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";

export default class Edf26_UploadFilePage extends LightningElement {
  @api showModal = "show";
  tabContent = "";
  myRecordId;
  applicationId = "";
  engagementId = "";
  @track lstApplicationFiles;
  @track lstEngagementFiles;
  showEngagement = false;
  activeTab = "application";
  applicantFellowFilesResult;
  applicantEnagegementFilesResult;
  //uploadedFieldsList = [{ Id: "1", name: "pdf file", type: "doctype:pdf", timelapse: "2 min", modifiedDate: "12-02-2022", size: "500KB", category:"workplan" }, { Id: "2", name: "Excel File", type: "doctype:excel", timelapse: "2 min", modifiedDate: "12-02-2022", size: "500KB", category:"pathway Checklist" }, { Id: "3", name: "Word File", timelapse: "2 min", modifiedDate: "12-02-2022", type: "doctype:word", size: "500KB", category:"Final Delivarables" }, { Id: "4", name: "General File", timelapse: "2 min", modifiedDate: "12-02-2022", type: "doctype:attachment", size: "500KB" },{ Id: "1", name: "pdf file", type: "doctype:pdf", timelapse: "2 min", modifiedDate: "12-02-2022", size: "500KB", category:"workplan" }, { Id: "2", name: "Excel File", type: "doctype:excel", timelapse: "2 min", modifiedDate: "12-02-2022", size: "500KB", category:"pathway Checklist" }, { Id: "3", name: "Word File", timelapse: "2 min", modifiedDate: "12-02-2022", type: "doctype:word", size: "500KB", category:"Final Delivarables" }, { Id: "4", name: "General File", timelapse: "2 min", modifiedDate: "12-02-2022", type: "doctype:attachment", size: "500KB" }];

  get isModalOpen() {
    return this.showModal === "show" ? true : false;
  }
  @wire(getObjectInfo, { objectApiName: FELLOWAPPLICATION_OBJECT })
  applicationMetadata;

  @wire(getPicklistValues, {
    recordTypeId: "$applicationMetadata.data.defaultRecordTypeId",
    fieldApiName: UPLOADCATEGORYA_FIELD
  })
  applicationPicklistValues;

  @wire(getObjectInfo, { objectApiName: CLIMATECORPSENGAGEMENT_OBJECT })
  engagementMetadata;

  @wire(getPicklistValues, {
    recordTypeId: "$engagementMetadata.data.defaultRecordTypeId",
    fieldApiName: UPLOADCATEGORYC_FIELD
  })
  engagementPicklistValues;

  @wire(getFellowEngagementEDF)
  wiredGetFellowEnagement(result) {
    if (result.data) {
      this.ccEngagement = result.data;
      this.engagementId = this.ccEngagement.Id; //Setting engagement Id
      this.applicationId = this.ccEngagement.Fellow_Application__c; //Setting application Id
    } else if (result.error) {
      console.log(result.error);
    }
  }

  //For Rendering Application Existing Files
  @wire(fetchFiles, { recordId: "$applicationId" })
  wiredGetApplicationfetchFiles(result) {
    this.applicantFellowFilesResult = result;
    this.processApplicationFiles();
  }

  processApplicationFiles() {
    let result = this.applicantFellowFilesResult;
    if (result.data) {
      //const fetechedFiles = result.data;
      this.lstApplicationFiles = result.data.map((item) => {
        if (item.fileType == "PDF") {
          return { ...item, type: "doctype:pdf", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        } else if (item.fileType == "EXCEL") {
          return { ...item, type: "doctype:excel", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        } else if (item.fileType == "PNG" || item.fileType == "JPEG") {
          return { ...item, type: "utility:image", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        } else if (item.fileType == "DOCX") {
          return { ...item, type: "doctype:word", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        } else {
          return { ...item, type: "doctype:attachment", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        }
      });
      this.lstApplicationFiles = this.lstApplicationFiles.filter((item) => item && item.fileId);
      //console.log('applicationFiles===>'+  JSON.stringify(this.lstApplicatlstApplicationFilesionFiles));
    } else if (result.error) {
      console.log(result.error);
    }
  }

  //For Rendering Engagement Existing Files
  @wire(fetchEngagementFiles, { recordId: "$engagementId" })
  wiredGetEngagementfetchFiles(result) {
    this.applicantEnagegementFilesResult = result;
    this.processEngagementFiles();
  }

  processEngagementFiles() {
    let result = this.applicantEnagegementFilesResult;
    if (result.data) {
      console.log(JSON.stringify(result.data));
      this.lstEngagementFiles = result.data.map((item) => {
        console.log("&&&&&&&& " + item.fileType);
        if (item.fileType == "PDF") {
          return { ...item, type: "doctype:pdf", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        } else if (item.fileType == "EXCEL") {
          return { ...item, type: "doctype:excel", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        } else if (item.fileType == "PNG" || item.fileType == "JPEG") {
          return { ...item, type: "utility:image", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        } else if (item.fileType == "DOCX") {
          return { ...item, type: "doctype:word", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        } else {
          return { ...item, type: "doctype:attachment", contentSize: this.formatBytes(item.contentSize), deleteLabel: "del-" + item.fileId };
        }
      });
      this.lstEngagementFiles = this.lstEngagementFiles?.filter((item) => item && item.fileId);
    } else if (result.error) {
      console.log(result.error);
    }
  }

  //on tab change setting recordId
  handleActive(event) {
    this.activeTab = event.target.value;
    if (event.target.value === "application") {
      this.myRecordId = this.applicationId;
    }
    if (event.target.value === "fellowShip") {
      this.myRecordId = this.engagementId;
    }
    /*if(event.target.value==="applicationExistingFiles"){
            this.myRecordId = this.applicationId;
        }
        if(event.target.value==="engagementExistingFiles"){
            this.myRecordId = this.engagementId;
        }*/
    console.log("recordIds==>" + this.myRecordId);
  }

  handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    let uploadedFileNames = "";
    let uploadedContentFileIds = "";
    for (let i = 0; i < uploadedFiles.length; i++) {
      if (i < uploadedFiles.length - 1) {
        uploadedFileNames += uploadedFiles[i].name + ", ";
        uploadedContentFileIds += uploadedFiles[i].contentVersionId + ",";
      } else {
        uploadedContentFileIds += uploadedFiles[i].contentVersionId;
        uploadedFileNames += uploadedFiles[i].name;
      }
    }
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: uploadedFiles.length + " Files uploaded Successfully: " + uploadedFileNames,
        variant: "success"
      })
    );
    this.renameAttachmentHelper(uploadedContentFileIds, "WorkPlan");
  }

  renameAttachmentHelper(contVer, filePrefixName) {
    console.log("called");
    renameAttachments({ contVerIds: contVer, fileName: filePrefixName })
      .then((result) => {
        refreshApex(this.applicantEnagegementFilesResult)
          .then(() => this.processApplicationFiles())
          .catch((error) => console.log("error in updating the files"));
        refreshApex(this.applicantFellowFilesResult)
          .then(() => this.processEngagementFiles())
          .catch((error) => console.log("error in updating the files"));
      })
      .catch((error) => {
        console.log(error);
      });
  }

  closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.showModal = "hide";
    this.dispatchEvent(new CustomEvent("hidemodel"));
  }

  handleOnselect(event) {
    console.log("Selected value " + event.detail.value);
    let selectedArr = event.detail.value.split("-");
    if (selectedArr[0] == "del") {
      let elementSelected = selectedArr[1];
      //let docToBeDeleted = this.activeTab =="application"?{this.lstApplicationFiles.findIndex(item=>item.fileId==elementSelected)}:{this.lstEngagementFiles.findIndex(item=>item.fileId==elementSelected)};
      if (this.activeTab == "applicationExistingFiles") {
        let itemIndex = this.lstApplicationFiles.findIndex((item) => item.fileId == elementSelected);
        if (itemIndex >= 0) {
          let removedItem = this.lstApplicationFiles.splice(itemIndex, 1);
          if (removedItem.length) {
            deleteDocument({ versionId: removedItem[0].versionId })
              .then(() => {
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Success",
                    message: "Document Deleted Successfully",
                    variant: "success"
                  })
                );
              })
              .catch((error) => console.log("error in deleting the content documet"));
          }
        }
      } else {
        let itemIndex = this.lstEngagementFiles.findIndex((item) => item.fileId == elementSelected);
        if (itemIndex >= 0) {
          let removedItem = this.lstEngagementFiles.splice(itemIndex, 1);
          if (removedItem.length) {
            deleteDocument({ versionId: removedItem[0].versionId })
              .then(() => {
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Success",
                    message: "Document Deleted Successfully",
                    variant: "success"
                  })
                );
              })
              .catch((error) => console.log("error in deleting the content documet"));
          }
        }
      }
    }
  }

  formatBytes(bytes, decimals = 2) {
    if (bytes === 0) return "0 Bytes";

    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];

    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + " " + sizes[i];
  }
}