import { LightningElement, track, api } from 'lwc';
import getContact from '@salesforce/apex/EdfContactController.getContact';
import updateContactDetails from '@salesforce/apex/EdfContactController.updateContact';
import getStatePickListValuesByCountry from '@salesforce/apex/EdfContactController.getStatePickListValuesByCountry';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import LastName from '@salesforce/schema/Contact.LastName';

export default class EDF08_editContactInfo extends NavigationMixin(LightningElement) {
    
    //@api recordId = '0031D00000gOijr';
    @track contacts;
    @track contact = {};
    // @track contactId = '0031D00000gOijr';
    @track contactId = '';
    @track fellowApplicationId = '';
    
    firstName = '';
    lastName = '';
    email = '';
    phone = '';
    permanentStreetAddressLine1 = '';
    permanentStreetAddressLine2 = '';
    state = '';
    city = '';
    country = '';
    postalCode = '';
    @track statePickListValues = [];
    @track countryPickListValues = [];
    @track navigateFromDashboard = true;
    resume = '';
    showUploaded = false;

    //@track contactWrapper = {};
    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg', '.docx', '.doc'];
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        for(let i = 0; i < uploadedFiles.length; i++) {
            //uploadedFileNames += uploadedFiles[i].name + ', ';
            this.resume = uploadedFiles[0].name;
            console.log('this.resume:',this.resume);
        }

    }
    connectedCallback(){
        this.getEdfContact();
    }
    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData +'/assets/js/bootstrap-4.0.0.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/community-override.css')
            
        ]).then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log("Error page")
            });
        //this.getEdfContact();
        this.setDefaultState();
        this.setDefaultCountry();
    }

    get responseReceived(){
        if(this.contacts){
            return true;
        }

        return false;
    }

    getEdfContact(){
        //getContact({contactId:this.contactId}).then(response => {
        getContact().then(response => {
            //this.contact = response;
            
            console.log('response:', response);
            //console.log('this.contact:', this.contact);
     
            // this.firstName = response.FirstName;
            // this.lastName = response.LastName;
            // this.email = response.Email;
            // this.phone = response.Phone;
            // this.email = response.Email;
            this.contactId = response.id;
            this.fellowApplicationId = response.fellowApplicationId;
            this.firstName = response.firstName ?? '';
            this.lastName = response.lastName ?? '';
            this.email = response.email ?? '';
            this.phone = response.phone ?? '';
            this.permanentStreetAddressLine1 = response.permanentStreetAddressLine1 ?? '';
            this.permanentStreetAddressLine2 = response.permanentStreetAddressLine2 ?? '';
            this.state = response.mailingState ?? '';
            this.city = response.mailingCity ?? '';
            this.country = response.mailingCountry ?? '';
            this.postalCode = response.mailingPostalCode ?? '';
            this.statePickListValues = response.statePickListValues ?? [];
            this.countryPickListValues = response.countryPickListValues ?? [];
            this.resume = response.resume ?? '';
            this.showUploaded = response.resume ? true : false;
            console.log('resume:', response.resume);
            console.log('showUploaded:', this.showUploaded);
            this.setDefaultState();
            this.setDefaultCountry();

            // const toastEvent = new ShowToastEvent({
            //     title:'Contact Received',
            //     message:'Contact received from Server',
            //     variant:'success'
            // });
            // this.dispatchEvent(toastEvent);
        }).catch(error => {
            alert(error);
            console.log('Error:', error);
            const toastEvent = new ShowToastEvent({
                title:'ERROR',
                message:error.message,
                variant:'error'
            });
            this.dispatchEvent(toastEvent);
        });
    }

    fetchStateByCountry() {
        console.log('fetchStateByCountry:country:', this.country);
        if (this.country) {
            getStatePickListValuesByCountry({ country: this.country }).then(response => {
                console.log('fetchStateByCountry:response:', response);
                this.statePickListValues = response ?? [];
            }).catch(error => {
                console.log('error:fetchStateByCountry:'.error);
            });
        }
        else {
            this.statePickListValues = [];
        }
    }

    saveContact() {
        //alert(this.resume);
        const contactDetails = {
            id:this.contactId,
            firstName: this.firstName,
            lastName: this.lastName,
            email:this.email,
            phone: this.phone,
            permanentStreetAddressLine1: this.permanentStreetAddressLine1,
            permanentStreetAddressLine2: this.permanentStreetAddressLine2,
            mailingState:this.state,
            mailingCity:this.city,
            mailingCountry:this.country,
            mailingPostalCode: this.postalCode,
            resume: this.resume

        }

        console.log('contactWrapper', contactDetails);

        updateContactDetails({contactWrapper:contactDetails}).then(response => {
            console.log('Records updated: ', response);
            //alert('Records updated: ' + response);
            const toastEvent = new ShowToastEvent({
                title:'Contact Saved',
                message:'Contact details saved successfully!',
                variant:'success'
            });
            this.dispatchEvent(toastEvent);
            this.connectedCallback();
        }).catch(error =>{
            //alert('Error:' + error.message);
            console.log('Error:', error);
        });
    }

    validateSave(event){
        let fieldErrorMsg="Please Enter the";
        this.template.querySelectorAll("input[required]").forEach(item => {
            let fieldValue=item.value;
            let fieldLabel=item.label;            
            if(!fieldValue){
                //item.setCustomValidity(fieldErrorMsg+' '+fieldLabel);
                item.classList.add('error-field');
                if(item.nextElementSibling.nodeName.toLowerCase() === 'span'){
                    item.nextElementSibling.hidden= false;
                }
            }
			else{
                //item.setCustomValidity("");
                item.classList.remove('error-field');
                if(item.nextElementSibling.nodeName.toLowerCase() === 'span'){
                    item.nextElementSibling.hidden= true;
                }
            }
           // item.reportValidity();
		});
    }

    requiredValidation(event) {
        //alert('Changed');
        if (event.target.value === '') {
            event.target.classList.add('error-field');
            if(event.target.nextElementSibling.nodeName.toLowerCase() === 'span'){
                event.target.nextElementSibling.hidden= false;
            }
        }
        else {
            event.target.classList.remove('error-field');
            if(event.target.nextElementSibling.nodeName.toLowerCase() === 'span'){
                event.target.nextElementSibling.hidden= true;
            }
        }

        return true;
    }
    
    firstNameChangeHandler(event){
        this.firstName = event.target.value;
    }
    lastNameChangeHandler(event){
        this.lastName = event.target.value;
    }
    emailChangeHandler(event){
        this.email = event.target.value;
    }
    phoneChangeHandler(event){
        this.phone = event.target.value;
    }
    permanentStreetAddressLine1ChangeHandler(event){
        this.permanentStreetAddressLine1 = event.target.value;
    }
    permanentStreetAddressLine2ChangeHandler(event){
        this.permanentStreetAddressLine2 = event.target.value;
    }
    stateChangeHandler(event){
        this.state = event.target.value;
    }
    cityChangeHandler(event){
        this.city = event.target.value;
    }
    countryChangeHandler(event){
        this.country = event.target.value;
        this.statePickListValues = [];
        this.fetchStateByCountry();
    }
    postalCodeChangeHandler(event){
        this.postalCode = event.target.value;
    }

    setDefaultState(){
        this.template.querySelector('.state').value = this.state;
    }
    setDefaultCountry(){
        this.template.querySelector('.country').value = this.country;
    }

    navigateToDashboard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
    
}