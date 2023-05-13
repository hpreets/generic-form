import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import EDF_Sharepoint_URL from '@salesforce/label/c.EDF_Sharepoint_URL';

export default class EDF12_ActionCenterPostReg extends NavigationMixin(LightningElement) {
    label = {
        EDF_Sharepoint_URL
    };

    navigateToContactInfo() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'contactinfo'
            }
        });
    }

    navigateToFellowApp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'reviewfellowapplication'
            }
        });
    }

    navigateToEngagementList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'engagementlist'
            }
        });
    }

    navigateToEDFItems() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'edfitems'
            }
        });
    }

    navigateToFellowResourceLibrary() {
        console.log('sharepointaccess');
        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'fellowresourcelibrary'
                }
            });
        }
        catch (error) {
            console.log('error:', error);
        }
        
    }
    navigateToTempSite() {
        const sharepointUrl = this.label.EDF_Sharepoint_URL;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: sharepointUrl 
            }
        });
    }

    navigateToSharepoint() {
        const sharepointUrl = this.label.EDF_Sharepoint_URL;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: sharepointUrl 
            }
        });
    }

    navigateToClimateCorpsConnect() {
        const sharepointUrl = this.label.EDF_Sharepoint_URL;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://edfclimatecorpsconnect.org/' 
            }
        });
    }
}