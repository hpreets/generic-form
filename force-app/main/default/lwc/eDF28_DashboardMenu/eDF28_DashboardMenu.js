import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import thankYouFillOutInformation from '@salesforce/label/c.EDF_DashBoard_ThankYouFillOutInformation';

export default class EDF28_DashboardMenu extends NavigationMixin(LightningElement) {
    label = {
        thankYouFillOutInformation
    };
    navigateToDashboard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
    navigateToContactInfo() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'contactinfo'
            }
        });
    }

    navigateToEducationInformation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'educationinformation'
            }
        });
    }

    navigateToBackgroundInformation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'backgroundinformation'
            }
        });
    }

    navigateToPreferences() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'preferences'
            }
        });
    }

    navigateToCoverLetter() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'coverletter'
            }
        });
    }
}