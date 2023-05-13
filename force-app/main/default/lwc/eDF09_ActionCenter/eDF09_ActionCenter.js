import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import getActionCenter from '@salesforce/apex/DashboardController.getActionCenter';
import FellowPortalHomepage_HeadingLabel_ActionCenter from '@salesforce/label/c.FellowPortalHomepage_HeadingLabel_ActionCenter';

export default class EDF09_ActionCenter extends NavigationMixin(LightningElement) {

    label = {
        FellowPortalHomepage_HeadingLabel_ActionCenter
    };
    actionCenterTiles = [];

    connectedCallback(){
        this.getActionCenterTiles();
    }

    getActionCenterTiles(){
        getActionCenter().then(response => {
            if (response) {
                this.actionCenterTiles = response;
                this.actionCenterTiles.forEach(item => {
                    item.image = BOOTSTRAPData + '/assets/img/' + item.image;
                });
            }
            console.log('actionCenterTiles:', this.actionCenterTiles);

        }).catch(error => {
            console.log('error:', error);
        });
    }

    navigate(event) {
        const pageType = event.target.dataset.pagetype;
        const pageName = event.target.dataset.pagename;
        const url = event.target.dataset.url;

        // console.log("pageType:", pageType);
        // console.log("pageName:", pageName);
        // console.log("url:", url);

        if (pageType === "Standard") {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: pageName
                }
            });
        }
        else if (pageType === "Web") {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
            });
        }

    }
}