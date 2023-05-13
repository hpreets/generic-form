import { LightningElement,wire, track } from 'lwc';
import doLogin from '@salesforce/apex/CommunityAuthController.doLogin';
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import forgotPasswordByEmail from '@salesforce/apex/LoginController.forgotPasswordByEmail';
// import Salesforce_Images from '@salesforce/resourceUrl/npsp';
import checkDeadlinePassed from '@salesforce/apex/LoginController.isDeadlinePassed'; // Added by HSingh - FB-2039

export default class CcLoginpage extends NavigationMixin(LightningElement) {
    username;
    password;
    @track errorCheck;
    @track errorMessage;

    bgWelcomeImage = BOOTSTRAPData + '/assets/img/bg-welcome-img.jpg';

    cssClassForgotPasswordModel = 'modal fade forgot-password-modal';
    cssStyleForgotPasswordModel = 'display: none;';
    ariahiddenForgotPasswordModel = 'true';

    cssClassForgotPasswordMessageModel = 'modal fade forgot-password-modal forgot-password-messages-modal bd-example-modal-lg';
    cssStyleForgotPasswordMessageModel = 'display: none;';
    ariahiddenForgotPasswordMessageModel = 'true';

    cssClassInvalidEmailPasswordModel = 'modal fade forgot-password-modal';
    cssStyleInvalidEmailPasswordModel = 'display: none;';
    ariahiddenForgotPasswordModel = 'true';

    emailEntered;
    @track email = '';
    emailForLogin = '';
    forgotPassword=false;
    forgotPasswordLink = true;

    forgotPasswordMessage = '';
    cssStylePasswordReset = '#f22f2a';
    colorGreen = 'color: #00a34b;';
    colorRed = 'color: #f22f2a;';

    resetLink = false;

    cssStyleInvalidEmailPwd = 'display: none;';
    invalidEmailPwdMsg = '';

    _isDeadlinePassed = null; // FB-2039

    handleUserNameChange(event){
        this.username = event.target.value;
    }
    handleEmailChange(event){
        // this.emailForLogin = event.target.value;
        // this.cssStyleInvalidEmailPwd = 'display: none;';
        // this.invalidEmailPwdMsg = '';
    }

    handlePasswordChange(event){
        // this.password = event.target.value;
        // this.cssStyleInvalidEmailPwd = 'display: none;';
        // this.invalidEmailPwdMsg = '';
    }

    handleLogin(event) {
        //this.cssStyleInvalidEmailPwd = 'display: none;';
        this.closeInvalidEmailPasswordModal();
        //this.invalidEmailPwdMsg = '';
        this.emailForLogin = this.template.querySelector(".email-for-login").value;
        this.password = this.template.querySelector(".password-for-login").value;
        //console.log('emailForLogin:', this.emailForLogin);
        //console.log('emailForLogin:', this.password);

        if(this.emailForLogin && this.password){
            event.preventDefault();
            doLogin({ email: this.emailForLogin, password: this.password })
                .then((result) => {
                    console.log('result:', result);
                    if (result === null) {
                        console.log('Invalid Email or PasswordI');
                        this.invalidEmailPwdMsg = 'Invalid Email or Password!';
                        // this.cssStyleInvalidEmailPwd = 'color: #f22f2a;font-weight: 400;font-size: 18px;padding-left: 21px';
                        this.showInvalidEmailPasswordModal();
                    }
                    else {
                        window.location.href = result;
                    }

                })
                .catch((error) => {
                    //alert(error.body.message);
                    console.log('Error:', error.body.message);
                });
        }
        else {
            this.invalidEmailPwdMsg = 'Email and Password cannot be blank.';
            this.showInvalidEmailPasswordModal();
            //this.cssStyleInvalidEmailPwd = 'color: #f22f2a;font-weight: 400;font-size: 18px;padding-left: 21px';
        }
    }

    handleEnterToLogin(event) {
        if (event.keyCode === 13) {
            this.handleLogin(event);
        }
    }

    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadScript(this, BOOTSTRAPData +'/assets/js/bootstrap-4.0.0.min.js'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css'),
             loadStyle(this, BOOTSTRAPData + '/assets/css/header.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/custom.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/welcome.css'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/community-override.css')
        ]).then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log("Error page")
            });

    }

    handleClick(){
        alert('Hello I  am in submit');
    }

    navigateToDashboard1() {
        var compDefinition = {
            componentDef: "c:ccFellowDashboard",
            attributes: {
                propertyValue: "500"
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
                // url: 'http://salesforce.com'
            }
        });
    }

    navigateToDashboard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'dashboard'
            }
        });
    }
    navigateToRegister() {
       let urlstring = window.location.href;
        let startUrl = urlstring.substring(0,urlstring.indexOf("/s/"));
        let registerUrl = startUrl+'/s/registerpage'
        window.location.href = registerUrl;
         /*this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
              url: registerUrl
            }
          });

          this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
              pageName: "portaldeliverables"
            }
          }); */


        /*console.log('Register page');
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'registerpage'
            }
        });*/
    }

    showForgotPasswordModal() {
        this.cssClassForgotPasswordModel = 'modal fade forgot-password-modal show';
        this.cssStyleForgotPasswordModel = 'display: block; padding-right: 17px;';
        ariahiddenForgotPasswordModel = 'false';
    }
    closeForgotPasswordModal() {
        this.cssClassForgotPasswordModel = 'modal fade forgot-password-modal';
        this.cssStyleForgotPasswordModel = 'display: none;';
        this.ariahiddenForgotPasswordModel = 'true';
    }
    showForgotPasswordMessageModal() {
        this.cssClassForgotPasswordMessageModel = 'modal fade forgot-password-modal forgot-password-messages-modal bd-example-modal-lg show';
        this.cssStyleForgotPasswordMessageModel = 'display: block; padding-right: 17px;';
        this.ariahiddenForgotPasswordMessageModel = 'false';
    }
    closeForgotPasswordMessageModal() {
        this.cssClassForgotPasswordMessageModel = 'modal fade forgot-password-modal forgot-password-messages-modal bd-example-modal-lg';
        this.cssStyleForgotPasswordMessageModel = 'display: none;';
        this.ariahiddenForgotPasswordMessageModel = 'true';
    }
    closeForgotPasswordModals() {
        this.closeForgotPasswordMessageModal()
        this.closeForgotPasswordModal();
    }

    showInvalidEmailPasswordModal() {
        this.cssClassInvalidEmailPasswordModel = 'modal fade forgot-password-modal show';
        this.cssStyleInvalidEmailPasswordModel = 'display: block; padding-right: 17px;';
        ariahiddenForgotPasswordModel = 'false';
    }
    closeInvalidEmailPasswordModal() {
        this.cssClassInvalidEmailPasswordModel = 'modal fade forgot-password-modal';
        this.cssStyleInvalidEmailPasswordModel = 'display: none;';
        this.ariahiddenForgotPasswordModel = 'true';
    }

    forgotPasswordHandler() {
        const input = this.template.querySelector(".email");
        this.email = input.value;
        console.log('email:', this.email);
        if (this.email) {
            forgotPasswordByEmail({ email: this.email }).then(response => {
                console.log('response:', response);
                //if (response === true) {
                if (response === 'success') {
                    //this.cssStylePasswordReset = this.colorGreen;
                    this.resetLink = true;
                    this.forgotPasswordMessage = 'We have sent you a password reset link to your email';
                }
                else {
                    //this.cssStylePasswordReset = this.colorRed;
                    this.resetLink = false;
                    this.forgotPasswordMessage = 'Password reset was unsuccessful, please try again later';
                }

                this.showForgotPasswordMessageModal();
            }).error(error => {
                console.log('Error:', error);
                //this.cssStylePasswordReset = this.colorRed;
                this.resetLink = false;
                this.forgotPasswordMessage = 'Password reset was unsuccessful, please try again later';
                this.showForgotPasswordMessageModal();
            });
        }

    }

    handleForgotPassword(){
        //const input = this.template.querySelector(".email");
        //this.emailEntered = input.value;
        console.log('handleForgotPassword:email:', this.email);
        //if(this.emailEntered != undefined && this.emailEntered!='' && this.validateEmail(this.emailEntered)){
        if(this.email){
            forgotPasswordByEmail({ email: this.email })
            .then(result => {
                console.log('handleForgotPassword:result:' + result);
                this.showForgotPasswordMessageModal();
                //if(result === true){
                    // const event = new ShowToastEvent({
                    //     mode: 'sticky',
                    //     variant:'Success',
                    //     title: 'We have sent you a password reset link to your email',
                    //     message:
                    //         'Please click on the link and follow the instructions to reset your password',
                    // });
                    // this.dispatchEvent(event);



                //}
                // else {
                //     const event = new ShowToastEvent({
                //         mode: 'sticky',
                //         variant:'error',
                //         title: 'Enter Valid User Address',
                //         message:
                //             'Please Enter an Valid User Address to reset the password',
                //     });
                //     this.dispatchEvent(event);

                // }
            })
            .error(error => {
                //alert(error);
                console.log('handleForgotPassword:Error:', error);
            });
        }
        // else {
        //     const event = new ShowToastEvent({
        //         mode: 'sticky',
        //         variant:'error',
        //         title: 'Enter Valid Email Address',
        //         message:
        //             'Please Enter an Valid Email Address to move further',
        //     });
        //     this.dispatchEvent(event);
        // }

    }
    validateEmail(str){
        var lastAtPos = str.lastIndexOf('@');
        var lastDotPos = str.lastIndexOf('.');
        return (lastAtPos < lastDotPos && lastAtPos > 0 && str.indexOf('@@') == -1 && lastDotPos > 2 && (str.length - lastDotPos) > 2);
    }
    handleForgotPassword(){
        this.forgotPassword=true;
    }
    closeModel(){
        this.forgotPassword=false;
    }

    connectedCallback() {
        this.checkDeadline(); // FB-2039
    }

    // Added by HSingh - FB-2039
    checkDeadline() {
        if (this._isDeadlinePassed == null) {
            checkDeadlinePassed()
            .then(response => {
                this._isDeadlinePassed = response;
            })
            .catch(error => {
                this._isDeadlinePassed = true;
            });
        }
    }

    // Added by HSingh - FB-2039
    set isDeadlinePassed(value) {
        this._isDeadlinePassed = value;
    }
    get isDeadlinePassed() {
        return (this._isDeadlinePassed == null  ||  this._isDeadlinePassed == true) ? true : false;
    }

}