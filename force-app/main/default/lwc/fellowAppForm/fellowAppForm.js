import { LightningElement, wire, api, track } from 'lwc';
import portalPageFieldDetails from '@salesforce/apex/CustomMetadataHelper.fetchPortalPageFieldDetails';
import getContactInfo from '@salesforce/apex/CustomMetadataHelper.getContactInfo';
import getFellowAppInfo from '@salesforce/apex/CustomMetadataHelper.getFellowAppInfo';

export default class FellowAppForm extends LightningElement {

    @api sectionName;
    showField = true;
    @track fieldsDetail = [];
    readOnly = false;
    isMandatory = true;
    textFieldValue = 'Harpreet';
    textFieldLabel = 'First Name';
    textFieldId = 'firstName';

    textFieldChangeHandler(event){
        console.log(event.target.value);
    }

    picklistOptions = [
        { label: 'PICKLIST_ALL_LABEL', value: 'PICKLIST_ALL_VALUE' },
        { label: 'PICKLIST_YES_LABEL', value: 'PICKLIST_YES_VALUE' },
        { label: 'PICKLIST_NO_LABEL', value: 'PICKLIST_NO_VALUE' }
    ];

    picklistFieldValue = 'Harpreet';
    picklistFieldLabel = 'First Name';
    picklistFieldId = 'fellowshipRegion';
    picklistFieldChangeHandler(event){
        console.log(event.target.value);
    }

    // Get Race Picklist values.
    @wire (portalPageFieldDetails, {sectionName: 'Contact'})
    fieldList(data, error) {
        console.log('Within fieldList wire method');
        console.log(JSON.stringify(data));
        if(data && data.data) {
            console.log(JSON.stringify(data.data));

            getContactInfo().then(contResponse => {
                console.log('getContactInfo response:', contResponse);
                getFellowAppInfo().then(fAppResponse => {
                    console.log('getFellowAppInfo response:', fAppResponse);

            console.log('data.data ::' + JSON.stringify(data.data));
            let firstNameItem = null;
            let lastNameItem = null;
            let parentPicklist = null;
            let dependentOther = null;
            data.data.forEach(item => {
                console.log(item.Field_Label__c);
                let otherItem = null;
                let currItem = {
                    ...item,
                    isHeading: (item.Row_Type__c == 'Heading') ? true : false,
                    isTextField: (item.Row_Type__c == 'Field' && item.Field_Type__c == 'Text') ? true : false,
                    isPicklistField: (item.Row_Type__c == 'Field' && item.Field_Type__c == 'Picklist') ? true : false,
                    isPicklistWithOtherField: (item.Row_Type__c == 'Field' && item.Field_Type__c == 'PicklistWithOther') ? true : false,
                    isMandatory: (item.Is_Mandatory__c == 'Yes') ? true : false,
                    picklistOptions : this.getPicklistOptions(item.User_Defined_Picklist_Values__c),
                    fieldValue : item.Object_API_Name__c ? (item.Object_API_Name__c == 'Contact' ? contResponse[item.Field_API_Name__c] : fAppResponse[item.Field_API_Name__c]) : '',
                  //   / * showMoreDetails: false,
                  //   bookmarked: item.considerMeMatch.Id ? item.considerMeMatch.Bookmark__c : false,
                  //   ranking: item.considerMeMatch.Id && item.considerMeMatch.Rank__c ? parseInt(item.considerMeMatch.Rank__c) : 0,
                  //   isRankingAvailable: item.considerMeMatch.Id && item.considerMeMatch.Rank__c,
                  //   considerMeComments: item.considerMeMatch.Id ? item.considerMeMatch.Why__c : '',
                  //   considerMeId: item.considerMeMatch.Id,
                  //   statusText: statusText, * /
                };
                if (item.Row_Type__c == 'Field' && item.Field_Type__c == 'Name') {
                    if (item.Field_API_Name__c == 'LastName') lastNameItem = currItem;
                    if (item.Field_API_Name__c == 'FirstName') firstNameItem = currItem;

                    if (firstNameItem  &&  lastNameItem) {
                        otherItem = { 'firstName': firstNameItem, 'lastName': lastNameItem, isNameField: true, Id:lastNameItem.Id };
                        firstNameItem = lastNameItem = null;
                    }
                }
                else if (item.Row_Type__c == 'Field' && item.Field_Type__c == 'PicklistWithOther') {
                    parentPicklist = currItem;
                }
                else if (item.Row_Type__c == 'Field' && item.Field_Type__c == 'DependentOther' && item.Parent_Field__c == parentPicklist.Id) {
                    dependentOther = currItem;
                    parentPicklist.other = dependentOther;
                    if (parentPicklist.fieldValue == dependentOther.Show_On_Value__c) parentPicklist.isShowOtherField = true;
                    otherItem = parentPicklist;
                    parentPicklist = dependentOther = null;
                }
                else {
                    otherItem = currItem;
                }

                //return Engagement List record with an updated parameter
                if (otherItem) this.fieldsDetail.push (otherItem);
                otherItem = null;

            });
            console.log(JSON.stringify(this.fieldsDetail));
                });
            });


        } else if(error){
            console.log(error);
        }

    };

    getPicklistOptions(picklistOptionStr) {
        let retVal = [];
        if (picklistOptionStr) {
            picklistOptionStr.split('|').forEach(option => {
                retVal.push({
                    label: option.trim(),
                    value: option.trim()
                });
            });
        }
        /* else {
            retVal = this.picklistOptions;
        } */
        return retVal;
    }

    picklistWithOtherFieldChangeHandler(event) {
        console.log('Inside picklistWithOtherFieldChangeHandler');
        console.log(event.target.dataset.parentfieldid);
        console.log(event.target.dataset.otherfieldid);
        this.fieldsDetail.forEach(item => {
            console.log(item.Id);
            if (item.other  &&  item.Id == event.target.dataset.parentfieldid  &&  item.other.Id == event.target.dataset.otherfieldid) {
                console.log('item.other.Show_On_Value__c ::' + item.other.Show_On_Value__c);
                console.log('event.target.value :: ' + event.target.value);
                if (event.target.value == item.other.Show_On_Value__c) item.isShowOtherField = true;
                else item.isShowOtherField = false;
                console.log('item.isShowOtherField ::' + item.isShowOtherField);
            }
        });
    }


}