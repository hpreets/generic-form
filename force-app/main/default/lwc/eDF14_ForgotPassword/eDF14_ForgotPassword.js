import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
// import forgotPassword from '@salesforce/apex/EDF01_RegisterController.forgotPassword';

export default class EDF14_ForgotPassword extends LightningElement {
    emailEntered;
    forgotPassword=false;
    forgotPasswordLink= true;
    renderedCallback() {
        Promise.all([
            loadScript(this, BOOTSTRAPData +'/assets/js/bootstrap.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/jquery-3.2.1.slim.min.js'),
            loadScript(this, BOOTSTRAPData + '/assets/js/popper-1.12.9.min.js'),
            loadStyle(this, BOOTSTRAPData + '/assets/css/bootstrap-4.0.0.min.css')
        ]).then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log("Error page")
            });
    }
    handleSubmit(){        
        const input = this.template.querySelector(".form-control");
        this.emailEntered = input.value;
        if(this.emailEntered != undefined && this.emailEntered!='' && this.validateEmail(this.emailEntered)){
            /*forgotPassword({ username: this.emailEntered })
            .then(result => {
                console.log('result:'+result);
                if(result === true){
                    const event = new ShowToastEvent({
                        mode: 'sticky',
                        variant:'Success',
                        title: 'We have sent you a password reset link to your email',
                        message:
                            'Please click on the link and follow the instructions to reset your password',                
                    });
                    this.dispatchEvent(event);

                }else{
                    const event = new ShowToastEvent({
                        mode: 'sticky',
                        variant:'error',
                        title: 'Enter Valid User Address',
                        message:
                            'Please Enter an Valid User Address to reset the password',                
                    });
                    this.dispatchEvent(event);
                    
                }
            })
            .catch(error => {

            });*/
        }else{
            const event = new ShowToastEvent({
                mode: 'sticky',
                variant:'error',
                title: 'Enter Valid Email Address',
                message:
                    'Please Enter an Valid Email Address to move further',                
            });
            this.dispatchEvent(event);
        }

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
}