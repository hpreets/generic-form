import { LightningElement, track, wire, api } from 'lwc';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import HOST_APPLICATION_OBJECT from '@salesforce/schema/Host_Application__c';
import CLIMATE_CORPS__OBJECT from '@salesforce/schema/Climate_Corps_Engagement__c';
import FELLOWSHIP_STATE_FIELD from '@salesforce/schema/Host_Application__c.Fellowship_State__c';
import FELLOWSHIP_LOCATION_PREFERENCE_FIELD from '@salesforce/schema/Host_Application__c.Fellowship_Location_Preference__c';
// import PROJECT_CATEGORY_FIELD from '@salesforce/schema/Host_Application__c.Project_Category__c';
// import ENGAGEMENT_INDUSTRY_FIELD from '@salesforce/schema/Climate_Corps_Engagement__c.Fellowship_State__c';
// import ENGAGEMENT_FELLOW_PROGRAM_FIELD from '@salesforce/schema/Climate_Corps_Engagement__c.Fellowship_Program__c';

//CUSTOM LABEL
import searchTip1 from '@salesforce/label/c.EngList_SearchTips_Tip1';
import searchTip2 from '@salesforce/label/c.EngList_SearchTips_Tip2';
import searchTip3 from '@salesforce/label/c.EngList_SearchTips_Tip3';
import searchTip4 from '@salesforce/label/c.EngList_SearchTips_Tip4';
import searchTip5 from '@salesforce/label/c.EngList_SearchTips_Tip5';
import instruction1 from '@salesforce/label/c.EngList_Instruction1';
import instruction2 from '@salesforce/label/c.EngList_Instruction2';
import instruction3 from '@salesforce/label/c.EngList_Instruction3';
import instruction4 from '@salesforce/label/c.EngList_Instruction4';

// Apex classes
import submitConsiderMe from "@salesforce/apex/EngagementListController.submitConsiderMe";
import saveConsiderMe from "@salesforce/apex/EngagementListController.saveConsiderMe";
import getEnggList from "@salesforce/apex/EngagementListController.getEnggList";
import searchEngagements from "@salesforce/apex/EngagementListController.searchEngagements";
import { refreshApex } from '@salesforce/apex';
import getFelloWAppId from "@salesforce/apex/EngagementListController.getFelloWAppId";
import getFellowshipApplyingFor from "@salesforce/apex/EngagementListController.getFellowshipApplyingFor";
import getEngagementListSettings from "@salesforce/apex/EngagementListController.getEngagementListSettings";
import getProjectTypes from "@salesforce/apex/EngagementListController.getProjectTypes";
import LightningConfirm from 'lightning/confirm';

export default class EDF92_EnggList_Filters extends LightningElement {
    Constant = {
        STATUS_BOOKMARKED: 'Bookmarked',
        STATUS_RANKED: 'Ranked',
        STATUS_NOT_SUBMITTED: 'Not Submitted',
        STATUS_SUBMITTED: 'Submitted',

        ICON_STAR_BLUE: '/assets/img/star-blue-icon.svg',
        ICON_STAR_GOLD: '/assets/img/star-orange-icon.svg',

        PICKLIST_ALL_VALUE: '--All',
        PICKLIST_ALL_LABEL: '-- All --',
        PICKLIST_YES_VALUE: 'yes',
        PICKLIST_YES_LABEL: 'Yes',
        PICKLIST_NO_VALUE: 'no',
        PICKLIST_NO_LABEL: 'No',
        PICKLIST_AVAILABLE_VALUE: 'available',
        PICKLIST_AVAILABLE_LABEL: 'Available',
        PICKLIST_NOT_AVAILABLE_VALUE: 'notavailable',
        PICKLIST_NOT_AVAILABLE_LABEL: 'Not Available',
      };

      // Expose the labels to use in the template.
      label = {
        searchTip1,
        searchTip2,
        searchTip3,
        searchTip4,
        searchTip5,
        instruction1,
        instruction2,
        instruction3,
        instruction4,
      };

      @track navigateFromDashboard = true;
      @track isModalOpen = false;
      instructionsImageURL = BOOTSTRAPData + '/assets/img/instructions-icon.svg';
      infoImageURL = BOOTSTRAPData + '/assets/img/info-icon.svg';
      carbonsettingsImageURL = BOOTSTRAPData + '/assets/img/carbon-settings-icon.svg';
      filterImageURL = BOOTSTRAPData + '/assets/img/filter-icon.svg';
      starOrange = BOOTSTRAPData + this.Constant.ICON_STAR_GOLD;
      starBlue = BOOTSTRAPData + this.Constant.ICON_STAR_BLUE; // FB-2133

      // to iterate the table
      @track engagementRecords;
      @track engagementRecordsError;
      @track showTips = false;
      @track isEngagementExist = false;

      // filter options
      @track fellowShipCityOptions = [{ label: this.Constant.PICKLIST_ALL_LABEL, value: this.Constant.PICKLIST_ALL_VALUE }];
      @track fellowShipStateOptions = [{ label: this.Constant.PICKLIST_ALL_LABEL, value: this.Constant.PICKLIST_ALL_VALUE }];
      publicTransportOptions = [
        { label: this.Constant.PICKLIST_ALL_LABEL, value: this.Constant.PICKLIST_ALL_VALUE },
        { label: this.Constant.PICKLIST_YES_LABEL, value: this.Constant.PICKLIST_YES_VALUE },
        { label: this.Constant.PICKLIST_NO_LABEL, value: this.Constant.PICKLIST_NO_VALUE }
      ];
      @track industryOptions = [{ label: this.Constant.PICKLIST_ALL_LABEL, value: this.Constant.PICKLIST_ALL_VALUE }];
      availAndNotAvailableOptions = [
        { label: this.Constant.PICKLIST_ALL_LABEL, value: this.Constant.PICKLIST_ALL_VALUE },
        { label: this.Constant.PICKLIST_AVAILABLE_LABEL, value: this.Constant.PICKLIST_AVAILABLE_VALUE },
        { label: this.Constant.PICKLIST_NOT_AVAILABLE_LABEL, value: this.Constant.PICKLIST_NOT_AVAILABLE_VALUE }
      ];
      projectTypeOptions = [{ label: this.Constant.PICKLIST_ALL_LABEL, value: this.Constant.PICKLIST_ALL_VALUE }];
      locationPreferanceOptions = [{ label: this.Constant.PICKLIST_ALL_LABEL, value: this.Constant.PICKLIST_ALL_VALUE }]

      // Filters selected values
      @api fellowshipcity = this.Constant.PICKLIST_ALL_VALUE;
      @api fellowshipstate = this.Constant.PICKLIST_ALL_VALUE;
      @api publicTransport = this.Constant.PICKLIST_ALL_VALUE;
      @api industry = this.Constant.PICKLIST_ALL_VALUE;
      @api availableNotAvailable = this.Constant.PICKLIST_ALL_VALUE;
      @api projectType = this.Constant.PICKLIST_ALL_VALUE;
      @api locationPreferance = this.Constant.PICKLIST_ALL_VALUE;
      // @api engagementProgram = '--All'; // Commented by HSingh FB-2139

      showMoreDetails = true;
      engagementListResults;
      isSearchCriteria = false;
      globalSearch;
      allEngagementItemsListHolder;
      engagementSettings;
      // engagementProgramsOptions = [{ label: '--All', value: '--All' }]; // Commented by HSingh FB-2139
      touchedEngagementlist = [];
      fellowshipApplyingFor;

      selTableFilter = 'showall';
      sortBy;
      sortOrder;
      isSubmitted = false; // FB-1991

      // Added by Harpreet - All Exposed properties for component
      @api placeholderSearchEngagementText; // FB-2151
      @api labelConsiderMeField; // FB-1970
      @api labelMaxCharLimitConsiderMe; // FB-2128
      @api maxCharConsiderMe;

      @api colorSubmitted;
      @api colorNotSubmitted;
      @api colorRanked;
      @api colorBookmarked;
      @api txtSubmitted;
      @api txtNotSubmitted;
      @api txtRanked;
      @api txtBookmarked;

      // @api minSubEngg = 5;
      // @api maxSubEngg = 5;
      @api msgMultiEnggSameRanking;
      @api msgNotAllRanked = 'One or more selected engagements are not ranked';
      @api msg5EnggNotSelected;
      @api msgNoCommentsOnEngg;
      @api labelSubmitBtn;
      @api labelSaveAllBtn;
      @api labelResetCriteriaBtn;
      @api labelSearchBtn;
      @api msgSaveSuccess;
      @api headingEngagementPage;
      @api headingEngagementList;
      @api msgNoEngagementRecords;

      @api headingInstruction;
      @api labelSearchTips;
      @api headingSearchTipsDialog;

      @api bookmarkRankFilterLabels;

      @api colHeadingHostOrganization;
      @api colHeadingIndustry;
      @api colHeadingAccToPublicTransport;
      @api colHeadingFellowshipCity;
      @api colHeadingFellowshipState;
      @api colHeadingProjectType;
      @api colHeadingFellowshipLocationPref;
      @api colHeadingSubmissionStatus;

      @api labelFellowshipCityFilter;
      @api labelFellowshipStateFilter;
      @api labelAccessibleToPublicTransportFilter;
      @api labelIndustryFilter;
      @api labelAvailableNotAvailableFilter = 'Available / Not Available';
      @api labelProjectTypeFilter;
      @api labelFellowshipLocationPreferenceFilter;

      @api showFellowshipCityFilter;
      @api showFellowshipStateFilter;
      @api showAccessibleToPublicTransportFilter;
      @api showIndustryFilter;
      @api showAvailableNotAvailableFilter = false;
      @api showProjectTypeFilter;
      @api showFellowshipLocationPreferenceFilter;

      @api msgSubmitConfirm;




      connectedCallback() {
        this.touchedEngagementlist = [];

       /*  getEnggList()
        .then(result => {
          this.processEngagementData(result, false);
        })
        .catch(error => {
          this.showToast('Error', 'error', 'Error In Searching the Enagement Records');
        }); */
        // console.log('EXITING connectedCallback');
      }

      // Commented by HSingh FB-2139
      // Get "Engagement programs" Picklist values.
      /* @wire(getPicklistValues, { recordTypeId: '$climateCorpsObjectInfo.data.defaultRecordTypeId', fieldApiName: ENGAGEMENT_FELLOW_PROGRAM_FIELD })
      wiredProgramPicklistValues(result) {
        if (result.data) {
          this.engagementProgramsOptions = [...this.engagementProgramsOptions, ...result.data.values];
          //this.projectTypeOptions.push({label:'--All', value:'--All'});
        } else if (result.error) {
          //this.projectTypeOptions.push({label:'--All', value:'--All'});
        }
      }*/

      // COMMENTED for FB-2388
      // Get "Project Type" Picklist values.
      /* @wire(getPicklistValues, { recordTypeId: '$hostApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: PROJECT_CATEGORY_FIELD })
      wiredProjectPicklistValues(result) {
        if (result.data) {
          this.projectTypeOptions = [...this.projectTypeOptions, ...result.data.values];
        } else if (result.error) {

        }
      } */

      // Get "Project Type" Picklist values - FB-2388
      @wire(getProjectTypes)
      wiredProjectTypes(result) {
        // console.log('INSIDE wiredProjectTypes');
        if (result.data) {
          // console.log(JSON.stringify(this.projectTypeOptions));
          // console.log(result.data);
          let projTypesSelOptions = [];
          result.data.forEach(function (projType, index, arr) {
            // console.log(`Index: ${index}, Name: ${projType}`);
            projTypesSelOptions.push({
              'label': projType,
              'value': projType
            });
          });
          // console.log(result.data.value);
          this.projectTypeOptions = [...this.projectTypeOptions, ...projTypesSelOptions];
        } else if (result.error) {
          console.log(JSON.stringify(result.error));
        }
      }

      // Get "Fellowship Location Preference" Picklist values.
      @wire(getPicklistValues, { recordTypeId: '$hostApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: FELLOWSHIP_LOCATION_PREFERENCE_FIELD })
      wiredLocationPreferancePicklistValues(result) {
        if (result.data) {
          this.locationPreferanceOptions = [...this.locationPreferanceOptions, ...result.data.values];
        } else if (result.error) {
          //this.locationPreferanceOptions.push();
        }
      }

      @wire(getEnggList)
      wiredEnagegementList(result) {
        // console.log('INSIDE wiredEnagegementList');
        // console.log(JSON.stringify(result));
        this.engagementListResults = result;
        if (result.data) {
          this.processEngagementData(result.data, false);
        } else if (result.error) {
          this.showToast('Error', 'error', 'Error in Getting Engagement list' + JSON.stringify(result.error));
        }
      }

      @wire(getFelloWAppId)
      wiredgetFelloWAppId(result) {
        if (result.data) {
          this.fellowApplicantId = result.data;
        } else if (result.error) {
          this.fellowApplicantId = null;
          this.showToast('Error', 'error', 'Error in Getting Fellow App Details');
          // this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'Error in Getting Fellow App Details', variant: 'error' }));
        } else {
          this.fellowApplicantId = null;
        }
      }

      @wire(getFellowshipApplyingFor)
      wiredFellowshipApplyingFor(result) {
        if (result.data) {
          this.fellowshipApplyingFor = result.data;
          // console.log('this.fellowshipApplyingFor:'+this.fellowshipApplyingFor);
        } else if (result.error) {
          console.log('error in getting fellowship Applying For');
        }
      }

      @wire(getEngagementListSettings, { fellowshipApplyingFor: '$fellowshipApplyingFor' })
      wiredEngagementSettings(result) {
        if (result.data) {
          this.engagementSettings = result.data;
          // console.log('this.engagementSettings in method:'+this.engagementSettings.minEngagements);
          // console.log('this.engagementSettings in method:'+this.engagementSettings.maxEngagements);
          // console.log('this.engagementSettings in method:'+this.engagementSettings.country);
        } else if (result.error) {
          console.log('error in getting engagement settings');
        }
      }

      // Commented by Harpreet - Not needed
      /* get isFellowAPpIdExist() {
        return this.fellowApplicantId;
      } */


      processEngagementData(data, isSearchProcess) {
        //let result = this.engagementListResults;
        // console.log('processEngagementData :: data length ::' + data.length);
        if (data.length > 0) this.isEngagementExist = true; else this.isEngagementExist = false; // FB-2388

        if (data && !isSearchProcess) {
          this.engagementRecords = data.map(item => {
            this.isEngagementExist = true;
            //Start Push cities/states/industries Into List
            if (item.Fellowship_City/* && (cities.length==0 || !cities.inlcudes(item.Fellowship_City))*/) {
              if (!this.fellowShipCityOptions.filter(x => x.label == item.Fellowship_City).length > 0) {
                this.fellowShipCityOptions.push({
                  label: item.Fellowship_City,
                  value: item.Fellowship_City
                });
              }
            }

            if (item.Fellowship_State /*&& (states.length==0 || !states.inlcudes(item.Fellowship_State))*/) {
              if (!this.fellowShipStateOptions.filter(x => x.label == item.Fellowship_State).length > 0) {
                this.fellowShipStateOptions.push({
                  label: item.Fellowship_State,
                  value: item.Fellowship_State
                });
              }
            }

            if (item.Industry /*&& (industries.length == 0 || !this.industries.inlcudes(item.Industry))*/) {
              if (!this.industryOptions.filter(x => x.label == item.Industry).length > 0) {
                this.industryOptions.push({
                  label: item.Industry,
                  value: item.Industry
                });
              }
            }

            //End Push cities/states/industries Into List

            let iconBgColor = 'background-color: '
              + (item.considerMeMatch.Status__c == this.Constant.STATUS_SUBMITTED ? this.colorSubmitted
                  : (item.considerMeMatch.Status__c == this.Constant.STATUS_BOOKMARKED ? this.colorBookmarked
                    : (item.considerMeMatch.Status__c == this.Constant.STATUS_RANKED ? this.colorRanked
                      : this.colorNotSubmitted)));
            let statusText = (item.considerMeMatch.Status__c == this.Constant.STATUS_SUBMITTED ? this.txtSubmitted
              : (item.considerMeMatch.Status__c == this.Constant.STATUS_BOOKMARKED ? this.txtBookmarked
                : (item.considerMeMatch.Status__c == this.Constant.STATUS_RANKED ? this.txtRanked
                  : this.txtNotSubmitted)));
            if (item.considerMeMatch.Status__c == this.Constant.STATUS_SUBMITTED) {
              this.isSubmitted = true;
            }

            //return Engagement List record with an updated parameter
            return {
              ...item,
              showMoreDetails: false,
              bookmarked: item.considerMeMatch.Id ? item.considerMeMatch.Bookmark__c : false,
              ranking: item.considerMeMatch.Id && item.considerMeMatch.Rank__c ? parseInt(item.considerMeMatch.Rank__c) : 0,
              isRankingAvailable: item.considerMeMatch.Id && item.considerMeMatch.Rank__c,
              considerMeComments: item.considerMeMatch.Id ? item.considerMeMatch.Why__c : '',
              // savedToSf: item.considerMeComments ? true : false, // Commented for FB-2136 Harpreet
              // considerMeSave: item.considerMeMatch.Id && item.savedToSf ? 'Submitted' : 'Save', // Commented for FB-2136 Harpreet
              // isSubmitted: item.considerMeMatch.Id ? true : false,
              considerMeChecked: item.considerMeMatch.Id ? true : false,
              Accessible_by_public_transportation: item.Accessible_by_public_transportation ? 'Yes' : 'No',
              // isDraft: !item.considerMeMatch.Id ? true : false,
              // isPending: false,
              // isSubmitted: item.considerMeMatch.Id ? true : false,
              isStarGold: item.starColor == 'GOLD' ? true : false, // FB-1962 Harpreet
              isStarBlue: item.starColor == 'BLUE' ? true : false, // FB-2133 Harpreet
              statusBgColor: iconBgColor, // FB-1917 Harpreet
              considerMeId: item.considerMeMatch.Id,
              statusText: statusText,
            }

          });
          this.industryOptions = [...this.industryOptions];
          this.fellowShipCityOptions = [...this.fellowShipCityOptions];
          this.fellowShipStateOptions = [...this.fellowShipStateOptions];
        } else {
          // console.log('INSIDE processEngagementData ELSE BLOCK');
          var newEngagementList = data.map(item => {

            // TODO: Commenting touchedEngagementlist for now. We will need to revisit it once all other issues are fixed, and we have time.
            let existingRecord = false; // this.touchedEngagementlist.find(innerItem => item.eId == innerItem.eId);
            if (existingRecord) return existingRecord;
            else {
              let iconBgColor = 'background-color: '
              + (item.considerMeMatch.Status__c == this.Constant.STATUS_SUBMITTED ? this.colorSubmitted
                  : (item.considerMeMatch.Status__c == this.Constant.STATUS_BOOKMARKED ? this.colorBookmarked
                    : (item.considerMeMatch.Status__c == this.Constant.STATUS_RANKED ? this.colorRanked
                      : this.colorNotSubmitted)));
              let statusText = (item.considerMeMatch.Status__c == this.Constant.STATUS_SUBMITTED ? this.txtSubmitted
                : (item.considerMeMatch.Status__c == this.Constant.STATUS_BOOKMARKED ? this.txtBookmarked
                  : (item.considerMeMatch.Status__c == this.Constant.STATUS_RANKED ? this.txtRanked
                    : this.txtNotSubmitted)));
              if (item.considerMeMatch.Status__c == this.Constant.STATUS_SUBMITTED) {
                this.isSubmitted = true;
              }
              return {
                ...item,
                showMoreDetails: false,
                bookmarked: item.considerMeMatch.Id ? item.considerMeMatch.Bookmark__c : false,
                ranking: item.considerMeMatch.Id && item.considerMeMatch.Rank__c ? parseInt(item.considerMeMatch.Rank__c) : 0,
                isRankingAvailable: item.considerMeMatch.Id && item.considerMeMatch.Rank__c,
                considerMeComments: item.considerMeMatch.Id ? item.considerMeMatch.Why__c : '',
                // savedToSf: item.considerMeComments ? true : false, // Commented for FB-2136 Harpreet
                // considerMeSave: item.considerMeMatch.Id && item.savedToSf ? 'Submitted' : 'Save', // Commented for FB-2136 Harpreet
                // isSubmitted: item.considerMeMatch.Id ? true : false,
                considerMeChecked: item.considerMeMatch.Id ? true : false,
                Accessible_by_public_transportation: item.Accessible_by_public_transportation ? 'Yes' : 'No',
                // isDraft: !item.considerMeMatch.Id ? true : false,
                // isPending: false,
                // isSubmitted: item.considerMeMatch.Id ? true : false,
                isStarGold: item.starColor == 'GOLD' ? true : false, // FB-1962 Harpreet
                isStarBlue: item.starColor == 'BLUE' ? true : false, // FB-2133 Harpreet
                statusBgColor: iconBgColor, // FB-1917 Harpreet
                considerMeId: item.considerMeMatch.Id,
                statusText: statusText,
              }
            }
          });
          this.engagementRecords = [...newEngagementList];
          this.allEngagementItemsListHolder = [...this.engagementRecords];
        }

      }

      handleCollapsebar(event) {
        let recordIndex = event.target.dataset.id;
        let record = this.engagementRecords.find(x => x.eId === recordIndex);
        if (record) {
          record.showMoreDetails = !record.showMoreDetails;
          this.engagementRecords = [...this.engagementRecords];
        }
      }

      handleBookmark(event) {
        let recordIndex = event.target.dataset.id;
        let record = this.engagementRecords.find(x => x.eId === recordIndex);
        if (record) {
          record.bookmarked = !record.bookmarked;
          this.checkCheckbox(record); // FB-2137
          this.engagementRecords = [...this.engagementRecords];
          //Add to touched items
          let itemIndex = this.touchedEngagementlist.findIndex(y => y.eId === recordIndex);
          if (itemIndex >= 0) {
            this.touchedEngagementlist[itemIndex] = record;
          } else {
            this.touchedEngagementlist.push(record);
          }
        }
      }

      handleRanking(event) {
        let recordIndex = event.target.dataset.id;
        let butonName = event.target.dataset.bname;
        let record = this.engagementRecords.find(x => x.eId === recordIndex);
        let maxRanking = (this.engagementSettings &&  this.engagementSettings.maxEngagements) ? this.engagementSettings.maxEngagements : 5;
        if (record) {
          if (butonName == 'uparraow') {
            if (record.ranking == 0) record.ranking = maxRanking; else if (record.ranking == 1) record.ranking = 1; else record.ranking -= 1; // FB-2383 Harpreet
            // record.ranking = record.ranking >= 5 ? 5 : record.ranking + 1; // FB-2127 Harpreet
            // record.isRankingAvailable = record.ranking > 0;
          } else if (butonName == 'downarraow') {
            if (record.ranking == maxRanking) record.ranking = 0; else if (record.ranking == 0) record.ranking = 0; else record.ranking += 1; // FB-2383 Harpreet
            // record.ranking = record.ranking <= 0 ? 0 : record.ranking - 1;
            // record.isRankingAvailable = record.ranking > 0;
          }
          record.isRankingAvailable = record.ranking > 0;
          this.checkCheckbox(record); // FB-2137
          this.engagementRecords = [...this.engagementRecords];
          //Add to touched items
          let itemIndex = this.touchedEngagementlist.findIndex(y => y.eId === recordIndex);
          if (itemIndex >= 0) {
            this.touchedEngagementlist[itemIndex] = record;
          } else {
            this.touchedEngagementlist.push(record);
          }
        }
      }


      // FB-2136 Harpreet
      /*
      handleConsiderMeSave(event) {
        let recordIndex = event.target.dataset.id;
        let record = this.engagementRecords.find(x => x.eId === recordIndex);
        let coniderCommentEle = this.template.querySelector(`lightning-textarea[data-id='${recordIndex}']`);
        let commentsAdded = coniderCommentEle?.value;
        if (!commentsAdded) {
          record.isPending = false;
          record.isDraft = true;
          record.isSubmitted = false;
        }
        if (record) {
          record.considerMeComments = commentsAdded;
          //Later add logic to save comments to SF
          record.savedToSf = true;
          record.isPending = true;
          record.isDraft = false;
          record.isSubmitted = false;
          record.considerMeSave = 'Saved Not Submitted';
          this.engagementRecords = [...this.engagementRecords];
        }
      }*/

      handleConsiderMeChange(event) {
        let recordIndex = event.target.dataset.id;
        let record = this.engagementRecords.find(x => x.eId === recordIndex);
        if (record) {
          record.considerMeComments = event.target.value;
          this.engagementRecords = [...this.engagementRecords];
          this.checkCheckbox(record); // FB-2137
          //Add to touched items
          let itemIndex = this.touchedEngagementlist.findIndex(y => y.eId === recordIndex);
          if (itemIndex >= 0) {
            this.touchedEngagementlist[itemIndex] = record;
          } else {
            this.touchedEngagementlist.push(record);
          }
        }
      }

      handleConsiderMeCheckBox(event) {
        let recordIndex = event.target.dataset.id;
        let record = this.engagementRecords.find(x => x.eId === recordIndex);
        if (record) {
          record.considerMeChecked = !record.considerMeChecked;
          this.engagementRecords = [...this.engagementRecords];
          //Add to touched items
          let itemIndex = this.touchedEngagementlist.findIndex(y => y.eId === recordIndex);
          if (itemIndex >= 0) {
            this.touchedEngagementlist[itemIndex] = record;
          } else {
            this.touchedEngagementlist.push(record);
          }
        }
      }

      checkCheckbox(record) {
        // FB-2137
        record.considerMeChecked = (record.isRankingAvailable || record.considerMeComments != null || record.bookmarked || record.considerMeId != null);
        return record;
      }

      handleResetCriteria() {
        this.fellowshipcity = this.Constant.PICKLIST_ALL_VALUE;
        this.fellowshipstate = this.Constant.PICKLIST_ALL_VALUE;
        this.publicTransport = this.Constant.PICKLIST_ALL_VALUE;
        this.industry = this.Constant.PICKLIST_ALL_VALUE;
        this.availableNotAvailable = this.Constant.PICKLIST_ALL_VALUE;
        this.projectType = this.Constant.PICKLIST_ALL_VALUE;
        this.locationPreferance = this.Constant.PICKLIST_ALL_VALUE;
        // this.engagementProgram = '--All'; // Commented by HSingh FB-2139
        this.globalSearch = '';
        // TODO: See if following will suffice or if we need to set each filter explicitely as above
        this.template.querySelectorAll('lightning-combobox[data-cname="filterCombo"]').forEach(each => {
          each.value = this.Constant.PICKLIST_ALL_VALUE;
        });
      }

      handlesearch() {
        this.isSearchCriteria = true;
        const searchcriteria = {
          fellowshipcity: this.fellowshipcity == this.Constant.PICKLIST_ALL_VALUE ? null : this.fellowshipcity,
          fellowshipstate: this.fellowshipstate == this.Constant.PICKLIST_ALL_VALUE ? null : this.fellowshipstate,
          publicTransport: this.publicTransport == this.Constant.PICKLIST_ALL_VALUE ? null : this.publicTransport,
          industry: this.industry == this.Constant.PICKLIST_ALL_VALUE ? null : this.industry,
          availableNotAvailable: this.availableNotAvailable == this.Constant.PICKLIST_ALL_VALUE ? null : this.availableNotAvailable,
          projectType: this.projectType == this.Constant.PICKLIST_ALL_VALUE ? null : this.projectType,
          locationPreferance: this.locationPreferance == this.Constant.PICKLIST_ALL_VALUE ? null : this.locationPreferance,
          // engagementProgram: this.engagementProgram == '--All' ? null : this.engagementProgram, // Commented by HSingh FB-2139
          searchText: this.globalSearch
        }

        searchEngagements({ searchFilterWrapper: searchcriteria })
          .then(result => {
            this.processEngagementData(result, true);
            this.isSearchCriteria = false;
          })
          .catch(error => {
            this.isSearchCriteria = false;
            this.showToast('Error', 'error', 'Error In Searching the Enagement Records');
          })

      }

      handleFilterChange(event) {
        this[event.target.name] = event.target.value;
      }
      // to open modal set isModalOpen tarck value as true
      openModal() {
        this.isModalOpen = true;
      }

      // to close modal set isModalOpen tarck value as false
      closeModal() {
        this.isModalOpen = false;
      }

      openTipsModel() {
        this.showTips = true;
      }

      closeModalAction() {
        this.showTips = false;
      }

      //  Filter Options
      get filterOptions() {
        // console.log(this.bookmarkRankFilterLabels);
        let labels = this.bookmarkRankFilterLabels.split(',');
        // console.log(labels);
        return [
          { label: labels[0], value: "showranked" },
          { label: labels[1], value: "showbookmarked" },
          { label: labels[2], value: "showrankedandbookmarked" },
          { label: labels[3], value: "showall" }

        ];

        /* return [ // bookmarkRankFilterLabels
          { label: "Show Ranked", value: "showranked" },
          { label: "Show Bookmarked", value: "showbookmarked" },
          { label: "Show Ranked & Bookmarked", value: "showrankedandbookmarked" },
          { label: "Show All", value: "showall" }

        ]; */
      }

      handleTableFilterChange(event) {
        this.selTableFilter = event.target.value;
        if (this.selTableFilter == 'showranked') {
          this.allEngagementItemsListHolder = !this.allEngagementItemsListHolder ? JSON.parse(JSON.stringify(this.engagementRecords)) : this.allEngagementItemsListHolder;
          let filteredList = this.allEngagementItemsListHolder.filter(item => item.ranking != 0);
          this.engagementRecords = filteredList;
        } else if (this.selTableFilter == 'showbookmarked') {
          this.allEngagementItemsListHolder = !this.allEngagementItemsListHolder ? JSON.parse(JSON.stringify(this.engagementRecords)) : this.allEngagementItemsListHolder;
          let filteredList = this.allEngagementItemsListHolder.filter(item => item.bookmarked);
          this.engagementRecords = filteredList;
        } else if (this.selTableFilter == 'showrankedandbookmarked') {
          this.allEngagementItemsListHolder = !this.allEngagementItemsListHolder ? JSON.parse(JSON.stringify(this.engagementRecords)) : this.allEngagementItemsListHolder;
          let filteredList = this.allEngagementItemsListHolder.filter(item => item.ranking != 0 || item.bookmarked);
          this.engagementRecords = filteredList;
        } else {
          this.engagementRecords = this.allEngagementItemsListHolder ? this.allEngagementItemsListHolder : this.engagementRecords;
        }
      }


      /**
       *
       * @returns
       */
      submitEngagements() {

        // Perform validations

        // Select Engagements that have a Rank and a Comment
        let selectedEngagementsList = this.engagementRecords.filter(item => item.considerMeChecked && item.ranking > 0 && item.considerMeComments != '');

        // Selected engagements should be more than 0
        if (selectedEngagementsList.length <= 0) {
          this.showToast('Error', 'error', this.msg5EnggNotSelected);
          return;
        }

        // All selected engagements should have a rank
        let missingRankedRecords = selectedEngagementsList.find(item => item.ranking <= 0);
        if (missingRankedRecords) {
          this.showToast('Error', 'error', this.msgNotAllRanked);
          return;
        }

        // All selected engagements should have a unique rank, no two engagements should have same rank.
        var missingRankingOrder = false;
        selectedEngagementsList.forEach((item, index, arr) => {
          console.log(item.ranking);
          let similarElements = arr.filter(innerItem => item.ranking == innerItem.ranking);
          if (similarElements.length > 1) missingRankingOrder = true;
        });
        if (missingRankingOrder) {
          this.showToast('Error', 'error', this.msgMultiEnggSameRanking);
          return;
        }

        // All selected engagements should have a comment.
        let emptyComments = selectedEngagementsList.find(item => !item.considerMeComments);
        if (emptyComments) {
          this.showToast('Error', 'error', this.msgNoCommentsOnEngg);
          return;
        }

        let minEngts = this.engagementSettings.minEngagements;
        let maxEngts = this.engagementSettings.maxEngagements;

        // Selected Engagements should have correct and ordered ranks and not like 1,3,4. It should be 1,2,3
        let cntRankedBelowMin = 0;
        selectedEngagementsList.forEach(item => {
          if (item.ranking <= minEngts) cntRankedBelowMin++;
          console.log(item.ranking);
        });
        let minRanked = selectedEngagementsList.find(item => (item.ranking <= minEngts));
        console.log(minRanked.length);
        console.log(minEngts);
        if (cntRankedBelowMin < minEngts) {
          this.showToast('Error', 'error', this.msg5EnggNotSelected);
          return;
        }

        // Count of selected engagements should be between min and max Consider Me count.
        if (selectedEngagementsList.length < minEngts || selectedEngagementsList.length > maxEngts) {
          this.showToast('Error', 'error', this.msg5EnggNotSelected);
          return;
        }

        // Once validation done, take confirmation on whether applicant wants to submit.
        LightningConfirm.open({
          message: this.msgSubmitConfirm,
          variant: 'headerless',
        })
        .then(result => {
          if (result) {
            // If applicant clicks OK, initiate Submit

            //Add logic to save enagement records to SFDC
            selectedEngagementsList = this.engagementRecords.filter(item => item.considerMeChecked && ((item.ranking > 0 && item.considerMeComments != '') || item.bookmarked)); // Includes
            let recordsToBeInserted = [];

            selectedEngagementsList.forEach(item => {
              let considerMeObj = {
                sobjectType: "Potential_Matching_From_Screener__c",
                Engagement__c: item.eId,
                Student_Application__c: this.fellowApplicantId,
                Why__c: item.considerMeComments,
                Rank__c: item.ranking.toString(),
                Bookmark__c: item.bookmarked
              }
              recordsToBeInserted.push(considerMeObj);
            });

            if (recordsToBeInserted.length > 0) {
              this.isSearchCriteria = true;
              submitConsiderMe({ coniderMeRecords: recordsToBeInserted, fellAppId: this.fellowApplicantId })
                .then(result => {
                  this.isSearchCriteria = false;
                  if (result) {
                    this.postSuccessfulSaveSubmit();

                  } else if (!result) {
                    this.showToast('Error', 'error', 'Error in Saving Records. Details:' + JSON.stringify(result));
                  }
                })
                .catch(result => {
                  this.isSearchCriteria = false;
                  this.showToast('Error', 'error', 'Error in Saving Records. Details:' + JSON.stringify(result));
                })
            } else {
              // console.log('No Records Exist for Save')
            }
          }
        });
      }


      /**
       *
       * @returns
       */
      saveEngagements() {
        this.isSearchCriteria = true;
        let selectedEngagementsList = this.engagementRecords.filter(item => item.considerMeChecked);
        // No checks during save - FB-2138
        /*if (selectedEngagementsList.length <= 0) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Please select the Engagement records to Save',
              variant: 'error'
            })
          );
          return;
        }*/
        let recordsToBeInserted = [];
        selectedEngagementsList.forEach(item => {
          let considerMeObj = {
            sobjectType: "Potential_Matching_From_Screener__c",
            Engagement__c: item.eId,
            Student_Application__c: this.fellowApplicantId,
            Why__c: item.considerMeComments,
            Rank__c: item.ranking.toString(),
            Bookmark__c: item.bookmarked,
            Id: item.considerMeId, // Harpreet
          }
          recordsToBeInserted.push(considerMeObj);
        });

        // if (recordsToBeInserted.length > 0) { // There may be Considers me just for deleting.
        saveConsiderMe({ coniderMeRecords: recordsToBeInserted, fellAppId: this.fellowApplicantId })
          .then(result => {
            this.isSearchCriteria = false;
            if (result) {
              this.postSuccessfulSaveSubmit();

            } else if (!result) {
              this.showToast('Error', 'error', 'Error in Saving Records. Details:' + JSON.stringify(result));
            }
          })
          .catch(result => {
            this.isSearchCriteria = false;
            this.showToast('Error', 'error', 'Error in saving Records. Details:' + JSON.stringify(result));
          })
        // }

      }

      postSuccessfulSaveSubmit() {
        this.showToast('Success', 'success', this.msgSaveSuccess);

        // To refresh data after Save
        // this.handlesearch();
        refreshApex(this.engagementListResults);
        /* .then(result => {
          console.log('refreshApex(this.wiredEnagegementList) called');
        })
        .catch(result => {
          console.log('ERROR :: refreshApex(this.wiredEnagegementList) called');
        }); */

        // Reset Ranked Bookmark filter
        this.selTableFilter = 'showall';
        this.template.querySelectorAll('lightning-combobox[data-cname="tableFilter"]').forEach(each => {
          each.value = 'showall';
        });
      }

      // TODO: Do we need this?
      // Get Object Info.
      @wire(getObjectInfo, { objectApiName: HOST_APPLICATION_OBJECT })
      hostApplicationObjectInfo;

      // TODO: Do we need this?
      // Get Object Info.
      @wire(getObjectInfo, { objectApiName: CLIMATE_CORPS__OBJECT })
      climateCorpsObjectInfo;


      // TODO: Do we need this?
      // Get "Fellowship State" Picklist values.
      @wire(getPicklistValues, { recordTypeId: '$hostApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: FELLOWSHIP_STATE_FIELD })
      fellowshipStatePickList;


      renderedCallback() {
        Promise.all([
          loadScript(this, BOOTSTRAPData + '/assets/js/bootstrap-4.0.0.min.js'),
          loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
          loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
          loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
          loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
          loadStyle(this, BOOTSTRAPData + '/assets/css/registration-application.css'),
          loadStyle(this, BOOTSTRAPData + '/assets/css/contact-information.css'),
          loadStyle(this, BOOTSTRAPData + '/assets/css/post-registration-form.css'),
          loadStyle(this, BOOTSTRAPData + '/assets/css/registration-application.css'),
          loadStyle(this, BOOTSTRAPData + '/assets/css/community-override.css')

        ]).then(() => {
          // console.log("All scripts and CSS are loaded.");
          this.instructionsImageURL
          //let modelPopup = this.template.querySelector('.engagements-search-tips-modal');

        })
          .catch(error => {
            console.log("Error page")
          });
      }

      navigateToDashboard() {
        this[NavigationMixin.Navigate]({
          type: 'standard__namedPage',
          attributes: {
            pageName: 'home'
          }
        });
      }

      showToast(titleTxt, variantType, msgTxt) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: titleTxt,
            message: msgTxt,
            variant: variantType
          })
        );
      }

      sortData(event) {
        let sortBy = event.target.dataset.id;

        if (this.sortBy != sortBy) this.sortOrder = 'asc';
        else if (this.sortOrder == 'asc') this.sortOrder = 'desc';
        else this.sortOrder = 'asc';

        this.sortBy = sortBy;
        this.engagementRecords.sort((a, b) => {
          let fa = a[sortBy].toLowerCase(),
            fb = b[sortBy].toLowerCase();

          if (this.sortOrder == 'desc') {
            if (fa > fb) return -1;
            else if (fa < fb) return 1;
            else return 0;
          }
          if (fa < fb) return -1;
          else if (fa > fb) return 1;
          else return 0;
        });
      }

    }