import { LightningElement, wire, track } from "lwc";
import MOMENT_JS from "@salesforce/resourceUrl/moment";
import fetchEDFItems from "@salesforce/apex/EDF02_CustomMetadata_Helper.fetchEDFItemsForFellowship";
import getContactForEDF from "@salesforce/apex/EdfContactController.getContactForEDF";
import getFellowEngagementEDF from "@salesforce/apex/Engagement_Controller.getFellowEngagementEDF";
import updateFellowEngagement from "@salesforce/apex/Engagement_Controller.updateFellowEngagement";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { updateRecord } from "lightning/uiRecordApi";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { refreshApex } from '@salesforce/apex';
import id from "@salesforce/user/Id";

import DeliverablesTracker_Label_DueDate from '@salesforce/label/c.DeliverablesTracker_Label_DueDate';
import DeliverablesTracker_Label_Done from '@salesforce/label/c.DeliverablesTracker_Label_Done';
import DeliverablesTracker_Label_NotDone from '@salesforce/label/c.DeliverablesTracker_Label_NotDone';
import DeliverablesTracker_Heading_Text from '@salesforce/label/c.DeliverablesTracker_Heading_Text';
import DeliverablesTracker_Heading_FellowGreetings from '@salesforce/label/c.DeliverablesTracker_Heading_FellowGreetings';
import DeliverablesTracker_MessageTitle_ErrorFetchingContact from '@salesforce/label/c.DeliverablesTracker_MessageTitle_ErrorFetchingContact';
import DeliverablesTracker_MessageTitle_ErrorFetchingEngagement from '@salesforce/label/c.DeliverablesTracker_MessageTitle_ErrorFetchingEngagement';

export default class EDF25_ItemsforEDF extends NavigationMixin(LightningElement) {

  DATE_FORMAT = "MM-DD-YYYY";

  label = {
    DeliverablesTracker_Label_DueDate,
    DeliverablesTracker_Label_Done,
    DeliverablesTracker_Label_NotDone,
    DeliverablesTracker_Heading_Text,
    DeliverablesTracker_Heading_FellowGreetings,

    DeliverablesTracker_MessageTitle_ErrorFetchingContact,
    DeliverablesTracker_MessageTitle_ErrorFetchingEngagement,

  };

  @track mapData = [];
  @track activeSections = [];
  showSections = true;
  @track navigateFromDashboard = true;
  clickedTile;
  contact;
  contactId;
  fellowEngagement;
  fellowEngagementRecId;
  contentLoaded = false;

  fellowshipApplyingFor;
  fellowEngagementResult;
  edfTilesResult;
  fellowContactResult;
  savingToSf = false;

  @wire(getContactForEDF)
  wiredContactforEdf(result) {
    this.fellowContactResult = result;
    this.localSetContact();
  }

  localSetContact() {
    if (this.fellowContactResult.data) {
      this.contact = this.fellowContactResult.data;
      this.contactId = this.fellowContactResult.data.id;
      // console.log('contact ::: ' + JSON.stringify(this.contact));
      // console.log('CONTACT DATA RETRIEVED :: this.contactId ::' + this.contactId);
      this.localFetchEDFItems();
    } else if (this.fellowContactResult.error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: this.label.DeliverablesTracker_MessageTitle_ErrorFetchingContact, // "ERROR In Contact",
          message: this.fellowContactResult.error.message,
          variant: "error"
        })
      );
    }
  }

  @wire(getFellowEngagementEDF)
  wiredgetFellowEngagementEDF(result) {
    // console.log('INSIDE wiredgetFellowEngagementEDF');
    this.fellowEngagementResult = result;
    this.localSetEngagement();
  }

  localSetEngagement() {
    if (this.fellowEngagementResult.data) {
      this.fellowEngagement = this.fellowEngagementResult.data;
      // console.log('ENGAGEMENT DATA RETRIEVED :: this.fellowEngagement :: ' + JSON.stringify(this.fellowEngagement));
      // console.log('fellowEngagement ::: ' + JSON.stringify(this.fellowEngagement));
      this.fellowEngagementRecId = this.fellowEngagementResult.data.Id;
      this.fellowshipApplyingFor = this.fellowEngagement.Fellow_Application__r.Fellowship_Applying_for__c;
      this.localFetchEDFItems();
    } else if (this.fellowEngagementResult.error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: this.label.DeliverablesTracker_MessageTitle_ErrorFetchingEngagement, // "ERROR In Engagement",
          message: this.fellowEngagementResult.error.message,
          variant: "error"
        })
      );
    }
  }

  localFetchEDFItems() {
    // console.log('INSIDE localFetchEDFItems');
    if (this.fellowEngagement  &&  this.contact) {
      // console.log('INSIDE localFetchEDFItems:: (this.fellowEngagement  &&  this.contact) IS TRUE');
      fetchEDFItems({fellowshipApplyingFor: this.fellowshipApplyingFor})
      .then((result) => {
        this.edfTilesResult = result;
        // console.log('localFetchEDFItems');
        // console.log(this.edfTilesResult);
        this.createMapData();
      })
      .catch((error) => {
          // this.error = error;
          // this.contacts = undefined;
      });
    }
  }

  // @wire(fetchEDFItems, {fellowshipApplyingFor: '$fellowshipApplyingFor'})
  // wiredfetchEDFItems(result) {
  //   this.edfTilesResult = result;
  //   this.createMapData();
  // }

  createMapData() {
    if (this.edfTilesResult) {
      var conts = this.edfTilesResult;
      const fellowEngagementRecord = this.fellowEngagement;
      const contactRecord = this.contact;
      const engagementEndDate = this.fellowEngagement.End_date__c;
      // console.log(contactRecord);
      if (this.mapData.length > 0) this.mapData = [];
      if (!contactRecord) console.log('Contact record not fetched. There seems to be a problem. Please contact EDF Climate Corps team.');
      else if (!fellowEngagementRecord) console.log('CC Engagement record not fetched. There seems to be a problem. Please contact EDF Climate Corps team.');
      else {
        for (var key in conts) {
          let tilesPending = true;
          let finalList = conts[key].map((item) => {
            let checkbox1;
            try {
              if (item.IsContactField__c) {
                checkbox1 = contactRecord[item.Mapping_Field__c];
              }
              else {
                checkbox1 = fellowEngagementRecord[item.Mapping_Field__c];
              }
              /* Button to be disable -- Not Working to be checked
              var ele = this.template.querySelector(`button[data-name='${item.Id}']`);
              if(checkbox1){
                ele.disabled = true;
              }
              else {
                ele.disabled = false;
              }*/
              tilesPending = tilesPending && checkbox1;

              // console.log('item ::' + JSON.stringify(item));
              let dueDate = moment(item.Due_Date__c).format(this.DATE_FORMAT);
              // item.Due_Date__c = moment(item.Due_Date__c).format(this.DATE_FORMAT);
              if (item.Due_Date_Field__c) {
                if (this.fellowEngagement[item.Due_Date_Field__c]) {
                  // console.log('Section_Name__c ::' + item.Section_Name__c);
                  // console.log('Tile_Body__c ::' + item.Tile_Body__c);
                  // console.log('Due_Date_Field__c ::' + item.Due_Date_Field__c);
                  // console.log('Due_Date_Field_Offset__c ::' + item.Due_Date_Field_Offset__c);
                  // console.log('this.fellowEngagement[item.Due_Date_Field__c] ::' + this.fellowEngagement[item.Due_Date_Field__c]);
                  // console.log('dueDate ::' + dueDate);
                  let daysOffset = 0;
                  if (item.Due_Date_Field_Offset__c) daysOffset = item.Due_Date_Field_Offset__c;
                  dueDate = moment(this.fellowEngagement[item.Due_Date_Field__c]).add(daysOffset, 'd').format(this.DATE_FORMAT);
                  // console.log('dueDate ::' + dueDate);
                }
                else dueDate = '';
              }

              return { ...item, checkBoxStatus: checkbox1, dueDate: dueDate  };
            }
            catch (err) {
              console.log(err);
            };
          });
          // console.log(key + '==' + tilesPending);
          if (!tilesPending) this.activeSections.push(key);
          this.mapData.push({ value: finalList, key: key });
        }
        // console.log("data in map after checkbox update" + JSON.stringify(this.mapData));
        if (this.mapData.length > 0) {
          this.contentLoaded = true;
        }
      }
    // } else if (this.edfTilesResult.error) {
    //   this.error = this.edfTilesResult.error;
    //   console.log("Error is " + this.edfTilesResult.error);
    }
  }

  renderedCallback() {
    this.loadJSFiles();
  }

  async loadJSFiles() {
    await loadScript(this, MOMENT_JS);
  }

  accordIcon = "utility:chevrondown";
  clickedIcon = true;
  isSubmissionOpen = true;
  changeIcon() {
    //this.clickedIcon = false;
    if (this.accordIcon == "utility:chevronright") {
      this.accordIcon = "utility:chevrondown";
      this.isSubmissionOpen = true;
      this.showSections = true;
    } else {
      this.accordIcon = "utility:chevronright";
      this.showSections = false;
      this.isSubmissionOpen = false;
    }
    //this.clickedIcon = true;
  }

  get options() {
    return [
      { label: "Show All", value: "all" },
      { label: "Hide All", value: "hide" }
    ];
  }

  handleToggleSection(event) {
    console.log(this.isDVisible);
    this.activeSectionMessage = "Open section name:  " + event.detail.openSections;
  }

  handleFilterChange(event) {
    if (event.target.value === "all") {
      this.activeSections = [];
      this.mapData.forEach((item) => {
        this.activeSections.push(item.key);
      });
    } else if (event.target.value === "hide") {
      this.activeSections = [];
    }
  }

  onClickSubmitButton(event) {
    const buttonName = event.target.name;
    this.clickedTile = null;
    loop1: for (var i = 0; i < this.mapData.length; i++) {
      loop2: for (var j = 0; j < this.mapData[i].value.length; j++) {
        if (this.mapData[i].value[j].Id === buttonName) {
          this.clickedTile = this.mapData[i].value[j];
          break loop1;
        }
      }
    }
    //Navigate Section 2 Items to Deliverables
    if (this.clickedTile.Button_URL__c.startsWith("LWC")) {
      this[NavigationMixin.Navigate]({
        type: "standard__namedPage",
        attributes: {
          pageName: "portaldeliverables"
        },
        state: {
          c__selectedOption: this.clickedTile.Button_URL__c.split(":")[1]
        }
      });
    } else {
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: this.clickedTile?.Button_URL__c
        }
      });
    }
  }

  handleToggleCheckbox(event) {
    // console.log('Inside handleToggleCheckbox');
    /* // console.log(event.target.checked);
    if (this.savingToSf) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "Other Save Operation in Progress , Please try after few Seconds",
          variant: "error"
        })
      );
      event.target.checked = !event.target.checked;
      return false;
    } */
    // event.target.checked = !event.target.checked;
    let updatedState = event.target.checked;
    console.log(updatedState);

    var eleName = event.target.name;
    var eleTileBody = event.target.dataset.name;
    console.log(event.target.dataset);
    console.log(event.target.dataset.name);
    console.log(event.target.dataset.mappingfield);
    console.log(event.target.dataset.iscontact);

    let mappingField = event.target.dataset.mappingfield;
    let isContact = event.target.dataset.iscontact;

    var ele = this.template.querySelector(`button[data-name='${eleName}']`);
    if (event.target.checked) {
      ele.disabled = true;
    } else {
      ele.disabled = false;
    }

    this.updateMapData(eleTileBody, 'checkBoxStatus', updatedState);
    this.savingToSf = true;
    console.log('this.fellowEngagementRecId ::' + this.fellowEngagementRecId);
    console.log('this.contactId ::' + this.contactId);
    // updateFellowEngagement({ tileBody: eleTileBody, engagementId: this.fellowEngagementRecId, contactId: this.contactId })
    updateFellowEngagement({ fieldAPIName: mappingField, isContactField: isContact, engagementId: this.fellowEngagementRecId, contactId: this.contactId })
      .then((response) => {
        // console.log('After update :: tileBody ::' + tileBody);
        let isContactField = this.fetchTileValue(eleTileBody, 'IsContactField__c');
        this.savingToSf = false;
        if (isContactField) refreshApex(this.fellowContactResult);
        else refreshApex(this.fellowEngagementResult);
      })
      .catch(error => {
        this.savingToSf = false;
        console.error('error in saving the data to engagement record' + JSON.stringify(error));
      });
  }

  navigateToDashboard() {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "home"
      }
    });
  }

  updateMapData(tileBody, key, value) {
    console.log(tileBody + '--' + key + '--' + value);
    if (this.mapData.length > 0) {
      // this.activeSections.push('After Training Access');

      let updatedMap = this.mapData.map((item) => {
        // this.activeSections.push(item.key);
        let updatedValueList = item.value.map((innerItem) => {
          // console.log(JSON.stringify(innerItem));
          if (innerItem.Tile_Body__c == tileBody) {
            innerItem[key] = value;
          }
          return innerItem;
        });
        // console.log(JSON.stringify(item));
        item.value = updatedValueList;
        return item;
      });
      // console.log('Before updating mapData');
      this.mapData = [...updatedMap];
      // console.log('Updated mapData');
    }
  }

  fetchTileValue(tileBody, key) {
    console.log(tileBody + '--' + key);
    let retVal;
    if (this.mapData.length > 0) {
      // this.activeSections.push('After Training Access');

      let updatedMap = this.mapData.map((item) => {
        // this.activeSections.push(item.key);
        let updatedValueList = item.value.map((innerItem) => {
          // console.log(JSON.stringify(innerItem));
          if (innerItem.Tile_Body__c == tileBody) {
            retVal = innerItem[key];
          }
        });
        // console.log(JSON.stringify(item));
      });
    }
    return retVal;
  }

  connectedCallback() {
    /*
     * FB-2575 - So that when fellow updates anything on Portal Deliverables,
     * Saves it, and open Deliverables Tracker, the tiles should show
     * updated Done / Not Done
     */
    refreshApex(this.fellowEngagementResult);
  }
}