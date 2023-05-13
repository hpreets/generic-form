import { LightningElement, wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import emailExistenceCheck from '@salesforce/apex/EDF28_RegisterController.isEmailExists';
import getCountries from '@salesforce/apex/EDF28_RegisterController.getCountries';
import getStatesByCountry from '@salesforce/apex/EDF28_RegisterController.getStatesByCountry';
import registerFellow from '@salesforce/apex/EDF28_RegisterController.registerFellow';
import sendExistingUserEmail from '@salesforce/apex/EDF28_RegisterController.SendExistingUserEmail';
import registratioResource from '@salesforce/resourceUrl/registrationResource';
import registrationTempPwd  from '@salesforce/label/c.EDF_RegistrationTemporaryPassword';


export default class EDF28_RegisterForm extends NavigationMixin(LightningElement) {

    emailAddressValue;
    emailExists=false;
    emailDoesNotExists=false;
    openRegistrationForm = false;
    fNameVal='';
    lNameVal='';
    postalCodeVal='';
    phoneVal='';
    cityVal='';
    addressLine1='';
    addressLine2='';
    selectedCountry='';
    selectedState ='';
    stateOptions=[];
    countryOptions=[];
    isSaving = false;
    greenTicker = '';
	isDropDownField = false;
    blockRegister = false;
    
    label = {
        registrationTempPwd
    };

    @wire(getCountries)
    myCountries({data, error}){
       
        if (data) {
             // set the default value
            this.selectedCountry = '--Select--';
            this.countryOptions = []; //Clear list
            for(const list of data){
                console.log(list)
                const option = {
                    label: list,
                    value: list
                };
                this.countryOptions = [ ...this.countryOptions, option ];
            
            }
        }
        else if (error) {
            console.error("wiredRecordTypeInfo Error Occured => " + JSON.stringify(error));
        }
    }
   

    renderedCallback() {
        Promise.all([
            loadStyle(this, registratioResource + '/assets/css/bootstrap-4.0.0.min.css'),
            loadStyle(this, registratioResource + '/assets/css/custom.css'),
            loadStyle(this, registratioResource + '/assets/css/header.css'),
            loadStyle(this, registratioResource + '/assets/css/registration.css'),
            loadScript(this, registratioResource + '/assets/js/jquery-3.2.1.slim.min.js')
            
        ]).then(() => {
                console.log("All scripts and CSS are loaded.");
                this.greenTicker = registratioResource+'/assets/img/circle-check-full.svg';
            })
            .catch(error => {
                console.log("Error page")
            });
    }
    closeModalAction() {    
        this.emailExists = false;
        this.emailDoesNotExists = false;
    }
    handleChange(event) {
        if(event.target.name === "fName"){
            this.fNameVal = event.detail.value;
        }
        if(event.target.name === "lName"){
            this.lNameVal = event.detail.value;
        }
        if(event.target.name === "phone"){
            this.phoneVal = event.detail.value;
			//this.handlePhoneValidation();
        }
        if(event.target.name === "country"){
            this.selectedCountry = event.detail.value;
            console.log('selected country-->'+this.selectedCountry)
            this.handleStates();
        }
        if(event.target.name === "postalCode"){
            this.postalCodeVal = event.detail.value;
        }
        if(event.target.name === "state"){
            this.selectedState = event.detail.value;
        }
        if(event.target.name === "city"){
            this.cityVal = event.detail.value;
        }
        if(event.target.name === "addressLine1"){
            this.addressLine1Val = event.detail.value;
        }
        if(event.target.name === "addressLine2"){
            this.addressLine2Val = event.detail.value;
        }
    }
    handleEmailChange(event){
        this.emailAddressValue = event.target.value;
    }
    handleClick(event) {
        console.log('Button Label'+event.target.label);
        this.emailAddressValue = this.template.querySelector("[data-name='registrationemail']").value;
        this.emailExists = false;
        this.emailDoesNotExists = false;
        if (this.emailAddressValue != undefined && this.emailAddressValue != '' && this.validateEmail(this.emailAddressValue)) {
            emailExistenceCheck({ email: this.emailAddressValue })
                .then(result => {
                    console.log('inside success'+JSON.stringify(result));
                    if(result){
                        this.emailExists = true;
                        this.sendEmailWithTempPswd();
                    }
                    else if(result==null){
                        this.emailDoesNotExists = true;
                    }

                })
                .catch(error => {
                    console.log('error==>'+JSON.stringify(result))
                });
            
        } else {
            const event = new ShowToastEvent({
                mode: 'sticky',
                variant: 'error',
                title: 'Enter Valid Email Address',
                message:
                    'Please Enter an Valid Email Address to move further',
            });
            this.dispatchEvent(event);
        }
    }
    
    validateEmail(str) {
        var lastAtPos = str.lastIndexOf('@');
        var lastDotPos = str.lastIndexOf('.');
        return (lastAtPos < lastDotPos && lastAtPos > 0 && str.indexOf('@@') == -1 && lastDotPos > 2 && (str.length - lastDotPos) > 2);
    }
    handleLogin(event){
        this.navigateToHome();
        /*var compDefinition = {
            componentDef: "c:eDF03_ccLoginpage"
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });*/
    }

    navigateToHome() {
        let urlstring = window.location.href;
        let startUrl = urlstring.substring(0,urlstring.indexOf("/s/"));
        let registerUrl = startUrl+'/s/login'
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
              url: registerUrl
            }
          });
        /*this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'login'
            }
        });*/
    }

    hanldeRegisteration(event){
        this.emailDoesNotExists = false;
        this.openRegistrationForm = true;
    }

    handleStates() {
				if(this.selectedCountry=="United States" || this.selectedCountry=="India" || this.selectedCountry=="China"){
						this.isDropDownField = true;
						getStatesByCountry({ countrySelected: this.selectedCountry })
            .then((result) => {
                console.log('result==>'+ JSON.stringify(result))
								this.stateOptions = []; //Empty list 
                 // set the default value
            this.selectedState = '--Select--';
            for(const list of result){
                console.log(list)
                const option = {
                    label: list,
                    value: list
                };
                // this.selectOptions.push(option);
                this.stateOptions = [ ...this.stateOptions, option ];
            
            }
                
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
               
            });
				} else{
                    this.isDropDownField = false;
                    this.selectedState = '';
                }
        
    }

    sendEmailWithTempPswd(){
        console.log('inside send email method')
        sendExistingUserEmail({email:this.emailAddressValue})
    }

    handleRegisterCreation(){
        this.isSaving = true;
        let allvalid = [...this.template.querySelectorAll("lightning-combobox,lightning-input")].reduce((validSoFar, inputCmp)=>{
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        },true);
        if(!allvalid){
            this.dispatchEvent(
                new ShowToastEvent({
                    title:"error",
                    message:"Please fill all mandatory Details",
                    variant:"error"
                })
            );
            this.isSaving = false;
            return false;
        }

        emailExistenceCheck({ email: this.emailAddressValue })
                .then(result => {
                    console.log('inside success'+JSON.stringify(result));
                    if(result){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title : 'Error',
                                message : 'Email has been already registered',
                                variant : 'error'
                            })
                        );
                        this.navigateToHome();
                    }
                    else {
                        const payloadData = {
                            firstName : this.fNameVal,
                            lastName : this.lNameVal,
                            email : this.emailAddressValue,
                            phone : this.phoneVal,
                            country : this.selectedCountry,
                            state : this.selectedState,
                            postalCode : this.postalCodeVal,
                            city : this.cityVal,
                            address1 : this.addressLine1Val,
                            address2 : this.addressLine2Val
                        }
                        registerFellow({payload : payloadData})
                        .then(result=>{
                            this.isSaving = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title : 'Success',
                                    message : 'Registration Successful, please check your email for login details',
                                    variant : 'success'
                                })
                            );
                            this.blockRegister = true;
                        })
                        .catch(error=>{
                            this.isSaving= false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title : 'error',
                                    message : 'Error in Registration',
                                    variant : 'error'
                                })
                            );
                        }); 
                       
                    } 

                })
                .catch(error => {
                    console.log('error==>'+JSON.stringify(result))
                });
    }
		handlePhoneValidation() {
		 let phoneCheck = this.template.querySelector('.phone');
     let phoneCheckVal = phoneCheck.value;
		 var numbers =/^\d{10}$/;
		  if(!phoneCheckVal.match(numbers)){
            phoneCheck.setCustomValidity('Please Enter Phone');
        }else{
            phoneCheck.setCustomValidity('');
        }
        phoneCheck.reportValidity();
		}
}