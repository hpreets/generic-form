import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import getNextSteps from '@salesforce/apex/DashboardController.getNextSteps';
import FellowPortalHomepage_HeadingLabel_NextSteps from '@salesforce/label/c.FellowPortalHomepage_HeadingLabel_NextSteps';

export default class EDF10_NextSteps extends LightningElement {

    label = {
        FellowPortalHomepage_HeadingLabel_NextSteps
    };
    nextStepTiles = [];
    hasNextStep = false;
    connectedCallback(){
        this.getNextStepTiles();

    }

    getNextStepTiles() {
        getNextSteps().then(response => {
            if (response) {
                this.nextStepTiles = response;
                this.nextStepTiles.forEach(item => {
                    item.image = BOOTSTRAPData + '/assets/img/' + item.image;
                });
                //console.log("nextStepTiles.length", this.nextStepTiles.length);
                if (this.nextStepTiles.length > 0) {
                    this.hasNextStep = true;
                }
                else {
                    this.hasNextStep = false;
                }
            }
        }).catch(error => {
            console.log('error:', error);
        });
    }
}