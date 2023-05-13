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
import PROJECT_CATEGORY_FIELD from '@salesforce/schema/Host_Application__c.Project_Category__c';
import ENGAGEMENT_INDUSTRY_FIELD from '@salesforce/schema/Climate_Corps_Engagement__c.Fellowship_State__c';
import ENGAGEMENT_FELLOW_PROGRAM_FIELD from '@salesforce/schema/Climate_Corps_Engagement__c.Fellowship_Program__c';

//CUSTOM LABEL
// import EngagementListInstructionHighlight from '@salesforce/label/c.EngagementListInstructionHighlight';
// import EngagementListInstruction from '@salesforce/label/c.EngagementListInstruction';
// import EngagementListInstruction1Cont from '@salesforce/label/c.EngagementListInstruction1Cont';
// import EngagementListInstruction3 from '@salesforce/label/c.EngagementListInstruction3';
// import Engagement_Search_Tips_Header from '@salesforce/label/c.Engagement_Search_Tips_Header';
// import EngagementListInstruction2 from '@salesforce/label/c.EngagementListInstruction2';

// Apex classes
import saveConsiderMe from "@salesforce/apex/EngagementListController.saveConsiderMe";
import saveConsiderMeRecords from "@salesforce/apex/EngagementListController.SaveConsiderMeRecords";
import getEnggList from "@salesforce/apex/EngagementListController.getEnggList";
import searchEngagements from "@salesforce/apex/EngagementListController.searchEngagements";
import { refreshApex } from '@salesforce/apex';
import getFelloWAppId from "@salesforce/apex/EngagementListController.getFelloWAppId";
import getFellowshipApplyingFor from "@salesforce/apex/EngagementListController.getFellowshipApplyingFor";
import getEngagementListSettings from "@salesforce/apex/EngagementListController.getEngagementListSettings";
import ITEMS_FOR_EDF_Submitted_Final_Deliverables from '@salesforce/label/c.ITEMS_FOR_EDF_Submitted_Final_Deliverables';





export default class EDF07_Enagementcmp extends NavigationMixin(LightningElement) {

  @track navigateFromDashboard = true;
  @track isModalOpen = false;
  instructionsImageURL = BOOTSTRAPData + '/assets/img/instructions-icon.svg';
  infoImageURL = BOOTSTRAPData + '/assets/img/info-icon.svg';
  carbonsettingsImageURL = BOOTSTRAPData + '/assets/img/carbon-settings-icon.svg';
  filterImageURL = BOOTSTRAPData + '/assets/img/filter-icon.svg';
  starOrange = BOOTSTRAPData + '/assets/img/star-orange-icon.svg';
  starBlue = BOOTSTRAPData + '/assets/img/star-blue-icon';
  // to iterate the table
  @track engagementRecords;
  @track engagementRecordsError;
  @track showTips = false;
  @track fellowShipCityOptions = [{ label: '--All', value: '--All' }];
  @track fellowShipStateOptions = [{ label: '--All', value: '--All' }];
  publicTransportOptions = [{ label: '--All', value: '--All' }, { label: 'Yes', value: 'yes' }, { label: 'No', value: 'no' }];
  @track industryOptions = [{ label: '--All', value: '--All' }];
  availAndNotAvailableOptions = [{ label: '--All', value: '--All' }, { label: 'Available', value: 'available' }, { label: 'Not Available', value: 'notavailable' }];
  projectTypeOptions = [{ label: '--All', value: '--All' }];
  locationPreferanceOptions = [{ label: '--All', value: '--All' }]
  @api fellowshipcity = '--All';
  @api fellowshipstate = '--All';
  @api publicTransport = '--All';
  @api industry = '--All';
  @api availableNotAvailable = '--All';
  @api projectType = '--All';
  @api locationPreferance = '--All';
  @api engagementProgram = '--All';
  showMoreDetails = true;
  engagementListResults;
  isSearchCriteria = false;
  globalSearch;
  allEngagementItemsListHolder;
  engagementSettings;
  engagementProgramsOptions = [{ label: '--All', value: '--All' }];
  touchedEngagementlist=[];
  fellowshipApplyingFor;


  connectedCallback(){
    this.touchedEngagementlist=[];
  }

  // Get "Engagement programs" Picklist values.
  @wire(getPicklistValues, { recordTypeId: '$climateCorpsObjectInfo.data.defaultRecordTypeId', fieldApiName: ENGAGEMENT_FELLOW_PROGRAM_FIELD })
  wiredProgramPicklistValues(result) {
    if (result.data) {
      this.engagementProgramsOptions = [...this.engagementProgramsOptions, ...result.data.values];
      //this.projectTypeOptions.push({label:'--All', value:'--All'});
    } else if (result.error) {
      //this.projectTypeOptions.push({label:'--All', value:'--All'});
    }
  }

  // Get "Fellowship Location Preference" Picklist values.
  @wire(getPicklistValues, { recordTypeId: '$hostApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: PROJECT_CATEGORY_FIELD })
  wiredProjectPicklistValues(result) {
    if (result.data) {
      this.projectTypeOptions = [...this.projectTypeOptions, ...result.data.values];
      //this.projectTypeOptions.push({label:'--All', value:'--All'});
    } else if (result.error) {
      //this.projectTypeOptions.push({label:'--All', value:'--All'});
    }
  }

  // Get "Fellowship Location Preference" Picklist values.
  @wire(getPicklistValues, { recordTypeId: '$hostApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: FELLOWSHIP_LOCATION_PREFERENCE_FIELD })
  wiredLocationPreferancePicklistValues(result) {
    if (result.data) {
      this.locationPreferanceOptions = [...this.locationPreferanceOptions, ...result.data.values];
      //this.locationPreferanceOptions = [...this.locationPreferanceOptions , {label:'--All', value:'--All'}]
    } else if (result.error) {
      //this.locationPreferanceOptions.push();
    }
  }  

  @wire(getEnggList)
  wiredEnagegementList(result) {
    this.engagementListResults = result;
    if (result.data) {
      this.processEngagementData(result.data, false);
    } else if (result.error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'Error in Getting Engagement list',
          variant: 'error'
        })
      )
    }
  }

  @wire(getFelloWAppId)
  wiredgetFelloWAppId(result) {
    if (result.data) {
      this.fellowApplicantId = result.data;
    } else if (result.error) {
      this.fellowApplicantId = null;
      this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'Error in Getting Fellow App Details', variant: 'error' }));
    } else {
      this.fellowApplicantId = null;
    }
  }

  @wire(getFellowshipApplyingFor)
  wiredFellowshipApplyingFor(result) {
    if (result.data) {
      this.fellowshipApplyingFor = result.data;
      console.log('this.fellowshipApplyingFor:'+this.fellowshipApplyingFor);
    } else if (result.error) {
      console.log('error in getting fellowship Applying For');
    }
  }

  @wire(getEngagementListSettings, {fellowshipApplyingFor:'$fellowshipApplyingFor'})
  wiredEngagementSettings(result) {
    if (result.data) {
      this.engagementSettings = result.data;
      console.log('this.engagementSettings in method:'+this.engagementSettings.minEngagements);
      console.log('this.engagementSettings in method:'+this.engagementSettings.maxEngagements);
      console.log('this.engagementSettings in method:'+this.engagementSettings.country);
    } else if (result.error) {
      console.log('error in getting engagement settings');
    }
  }

  get isFellowAPpIdExist() {
    return this.fellowApplicantId;
  }
  processEngagementData(data, isSearchProcess) {
    //let result = this.engagementListResults;
    if (data && !isSearchProcess) {
      this.engagementRecords = data.map(item => {
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

        //return Engagement List record with an updated parameter

        return {
          ...item,
          showMoreDetails: false,
          bookmarked: item.considerMeMatch.Id ? item.considerMeMatch.Bookmark__c : false,
          ranking: item.considerMeMatch.Id && item.considerMeMatch.Rank__c ? parseInt(item.considerMeMatch.Rank__c) : 0,
          isRankingAvailable: item.considerMeMatch.Id && item.considerMeMatch.Rank__c,
          considerMeComments: item.considerMeMatch.Id ? item.considerMeMatch.Why__c : '',
          savedToSf: item.considerMeComments ? true : false,
          considerMeSave: item.considerMeMatch.Id && item.savedToSf ? 'Submitted' : 'Save',
          isSubmitted: item.considerMeMatch.Id ? true : false,
          considerMeChecked: item.considerMeMatch.Id ? true : false,
          Accessible_by_public_transportation: item.Accessible_by_public_transportation ? 'Yes' : 'No',
          isDraft: !item.considerMeMatch.Id ? true : false,
          isPending: false,
          isSubmitted: item.considerMeMatch.Id ? true : false
        }

      });
      this.industryOptions = [...this.industryOptions];
      this.fellowShipCityOptions = [...this.fellowShipCityOptions];
      this.fellowShipStateOptions = [...this.fellowShipStateOptions];
      //this.engagementRecords.forEach(item=>console.log('*********&&&'+item.Industry_Classification__c));
      //this.engagementRecords.forEach(item=>console.log('*****JSON****&&&'+JSON.stringify(item)));
    } else {
      var newEngagementList = data.map(item => {
        let existingRecord = this.touchedEngagementlist.find(innerItem => item.eId == innerItem.eId);
        if (existingRecord) return existingRecord;
        else {
          return {
            ...item,
            showMoreDetails: false,
            bookmarked: item.considerMeMatch.Id ? item.considerMeMatch.Bookmark__c : false,
            ranking: item.considerMeMatch.Id && item.considerMeMatch.Rank__c ? parseInt(item.considerMeMatch.Rank__c) : 0,
            isRankingAvailable: item.considerMeMatch.Id && item.considerMeMatch.Rank__c,
            considerMeComments: item.considerMeMatch.Id ? item.considerMeMatch.Why__c : '',
            savedToSf: item.considerMeComments ? true : false,
            considerMeSave: item.considerMeMatch.Id && item.savedToSf ? 'Submitted' : 'Save',
            isSubmitted: item.considerMeMatch.Id ? true : false,
            considerMeChecked: item.considerMeMatch.Id ? true : false,
            Accessible_by_public_transportation: item.Accessible_by_public_transportation ? 'Yes' : 'No',
            isDraft: !item.considerMeMatch.Id ? true : false,
            isPending: false,
            isSubmitted: item.considerMeMatch.Id ? true : false
          }
        }
      });
      this.engagementRecords = [...newEngagementList];
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
      this.engagementRecords = [...this.engagementRecords];
      //Add to touched items
      let itemIndex = this.touchedEngagementlist.findIndex(y => y.eId === recordIndex);
      if(itemIndex>=0){
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
    if (record) {
      if (butonName == 'uparraow') {
        record.ranking = record.ranking >= 6 ? 6 : record.ranking + 1;
        record.isRankingAvailable = record.ranking > 0;
      } else if (butonName == 'downarraow') {
        record.ranking = record.ranking <= 0 ? 0 : record.ranking - 1;
        record.isRankingAvailable = record.ranking > 0;
      }
      this.engagementRecords = [...this.engagementRecords];
      //Add to touched items
      let itemIndex = this.touchedEngagementlist.findIndex(y => y.eId === recordIndex);
      if(itemIndex>=0){
        this.touchedEngagementlist[itemIndex] = record;
      } else {
        this.touchedEngagementlist.push(record);
      }
    }
  }

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
  }

  handleConsiderMeChange(event) {
    let recordIndex = event.target.dataset.id;
    let record = this.engagementRecords.find(x => x.eId === recordIndex);
    if (record) {
      record.considerMeComments = event.target.value;
      this.engagementRecords = [...this.engagementRecords];
      //Add to touched items
      let itemIndex = this.touchedEngagementlist.findIndex(y => y.eId === recordIndex);
      if(itemIndex>=0){
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
      if(itemIndex>=0){
        this.touchedEngagementlist[itemIndex] = record;
      } else {
        this.touchedEngagementlist.push(record);
      }
    }
  }

  handleResetCriteria() {
    this.fellowshipcity = '--All';
    this.fellowshipstate = '--All';
    this.publicTransport = '--All';
    this.industry = '--All';
    this.availableNotAvailable = '--All';
    this.projectType = '--All';
    this.locationPreferance = '--All';
    this.engagementProgram = '--All';
    this.globalSearch = '';
    this.template.querySelectorAll('lightning-combobox[data-cname="filterCombo"]').forEach(each => {
      each.value = '--All';
    });
  }

  handlesearch() {
    this.isSearchCriteria = true;
    const searchcriteria = {
      fellowshipcity: this.fellowshipcity == '--All' ? null : this.fellowshipcity,
      fellowshipstate: this.fellowshipstate == '--All' ? null : this.fellowshipstate,
      publicTransport: this.publicTransport == '--All' ? null : this.publicTransport,
      industry: this.industry == '--All' ? null : this.industry,
      availableNotAvailable: this.availableNotAvailable == '--All' ? null : this.availableNotAvailable,
      projectType: this.projectType == '--All' ? null : this.projectType,
      locationPreferance: this.locationPreferance == '--All' ? null : this.locationPreferance,
      engagementProgram: this.engagementProgram == '--All' ? null : this.engagementProgram,
      searchText: this.globalSearch
    }

    searchEngagements({ searchFilterWrapper: searchcriteria })
      .then(result => {
        this.processEngagementData(result, true);
        this.isSearchCriteria = false;
      })
      .catch(error => {
        this.isSearchCriteria = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Error In Searching the Enagement Records',
            variant: 'error'
          })
        );
      })

  }

  handleFilterChange(event) {
    this[event.target.name] = event.target.value;
  }
  // to open modal set isModalOpen tarck value as true
  openModal() {
    alert('Im from open model');
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
    return [
      { label: "Show Ranked", value: "showranked" },
      { label: "Show Bookmarked", value: "showbookmarked" },
      { label: "Show Ranked & Bookmarked", value: "showrankedandbookmarked" },
      { label: "Show All", value: "showall" }

    ];
  }

  handleTableFilterChange(event) {

    if (event.target.value == 'showranked') {
      this.allEngagementItemsListHolder = !this.allEngagementItemsListHolder ? JSON.parse(JSON.stringify(this.engagementRecords)) : this.allEngagementItemsListHolder;
      let filteredList = this.allEngagementItemsListHolder.filter(item => item.ranking != 0);
      this.engagementRecords = filteredList;
    } else if (event.target.value == 'showbookmarked') {
      this.allEngagementItemsListHolder = !this.allEngagementItemsListHolder ? JSON.parse(JSON.stringify(this.engagementRecords)) : this.allEngagementItemsListHolder;
      let filteredList = this.allEngagementItemsListHolder.filter(item => item.bookmarked);
      this.engagementRecords = filteredList;
    } else if (event.target.value == 'showrankedandbookmarked') {
      this.allEngagementItemsListHolder = !this.allEngagementItemsListHolder ? JSON.parse(JSON.stringify(this.engagementRecords)) : this.allEngagementItemsListHolder;
      let filteredList = this.allEngagementItemsListHolder.filter(item => item.ranking != 0 || item.bookmarked);
      this.engagementRecords = filteredList;
    } else {
      this.engagementRecords = this.allEngagementItemsListHolder ? this.allEngagementItemsListHolder : this.engagementRecords;
    }
  }

  submitEngagements() {
    let selectedEngagementsList = this.engagementRecords.filter(item => item.considerMeChecked);
    if (selectedEngagementsList.length <= 0) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'Please select the Engagement records',
          variant: 'error'
        })
      );
      return;
    }

    let missingRankedRecords = selectedEngagementsList.find(item => item.ranking <= 0);
    if (missingRankedRecords) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'One or more engagements are not ranked',
          variant: 'error'
        })
      );
      return;
    }

    var missingRankingOrder = false;
    selectedEngagementsList.forEach((item, index, arr) => {
      let similarElements = arr.filter(innerItem => item.ranking == innerItem.ranking);
      if (similarElements.length > 1) missingRankingOrder = true;
    });
    if (missingRankingOrder) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'Multiple Engagement Records given same ranking , please select the ranking in the order as 1,2,3,...',
          variant: 'error'
        })
      );
      return;
    }

    let emptyComments = selectedEngagementsList.find(item => !item.considerMeComments);
    if (emptyComments) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'One or More Enagagements are not added comments',
          variant: 'error'
        })
      );
      return;
    }
    console.log(' this.engagementSettings:'+this.engagementSettings);
    let minEngts = this.engagementSettings.minEngagements;
    let maxEngts = this.engagementSettings.maxEngagements;
    console.log('minEngts:'+minEngts);
    console.log('maxEngts:'+maxEngts);
    //let chinaMaxEngts = this.engagementSettings ? this.engagementSettings.chinaMaxEngagements : 3;
    //let maxEngts = this.fellowshipApplyingFor == 'China Fellowship'? chinaMaxEngts:maxiEngts;
    if (selectedEngagementsList.length < minEngts || selectedEngagementsList.length > maxEngts) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: `Minimum of ${minEngts} and Maximum of ${maxEngts} Engagements allowed`,
          variant: 'error'
        })
      );
      return;
    }

    //Add logic to save enagement records to SFDC
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
      saveConsiderMe({ coniderMeRecords: recordsToBeInserted, fellAppId: this.fellowApplicantId })
        .then(result => {
          this.engagementRecords.forEach(item => {
            if (item.considerMeChecked) {
              item.isPending = false;
              item.isSubmitted = true;
              item.isDraft = false;
            }
          });
          if (result) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Success',
                message: 'Records have been saved successfully',
                variant: 'success'
              })
            );
          } else if (!result) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Error',
                message: 'Error in Saving Records',
                variant: 'error'
              })
            );
          }
        })
        .catch(result => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Error in Saving Records',
              variant: 'error'
            })
          );
        })
    } else {
      console.log('No Records Exist for Save')
    }
    console.log('Successfully Saved the enaggements records' + JSON.stringify(selectedEngagementsList));
  }

  saveEngagements(){
    console.log('saveEngagements: Inside');
    let selectedEngagementsList = this.engagementRecords.filter(item => item.considerMeChecked);
    console.log('selectedEngagementsList: Inside'+selectedEngagementsList);
    if (selectedEngagementsList.length <= 0) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'Please select the Engagement records to Save',
          variant: 'error'
        })
      );
      return;
    }
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
      saveConsiderMeRecords({ coniderMeRecords: recordsToBeInserted, fellAppId: this.fellowApplicantId })
        .then(result => {
          this.engagementRecords.forEach(item => {
            if (item.considerMeChecked) {
              item.isPending = true;
              item.isSubmitted = false;
              item.isDraft = false;
            }
          });
          if (result) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Success',
                message: 'Records have been saved successfully',
                variant: 'success'
              })
            );
          } else if (!result) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Error',
                message: 'Error in Saving Records',
                variant: 'error'
              })
            );
          }
        })
        .catch(result => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Error in Saving Records',
              variant: 'error'
            })
          );
        })
    }

  }

  // Get Object Info.
  @wire(getObjectInfo, { objectApiName: HOST_APPLICATION_OBJECT })
  hostApplicationObjectInfo;

  // Get Object Info.
  @wire(getObjectInfo, { objectApiName: CLIMATE_CORPS__OBJECT })
  climateCorpsObjectInfo;


  // Get "Fellowship State" Picklist values.
  @wire(getPicklistValues, { recordTypeId: '$hostApplicationObjectInfo.data.defaultRecordTypeId', fieldApiName: FELLOWSHIP_STATE_FIELD })
  fellowshipStatePickList;




  // label = {
  //   EngagementListInstructionHighlight, EngagementListInstruction,
  //   EngagementListInstruction1Cont, EngagementListInstruction3,
  //   Engagement_Search_Tips_Header, EngagementListInstruction2,
  // };

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
      console.log("All scripts and CSS are loaded.");
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

  // calling the controller

}