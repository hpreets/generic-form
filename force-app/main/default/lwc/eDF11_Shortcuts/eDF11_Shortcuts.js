import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';
import getShortcuts from '@salesforce/apex/DashboardController.getShortcuts';
import FellowPortalHomepage_HeadingLabel_Shortcuts from '@salesforce/label/c.FellowPortalHomepage_HeadingLabel_Shortcuts';

export default class EDF11_Shortcuts extends NavigationMixin(LightningElement) {

    label = {
        FellowPortalHomepage_HeadingLabel_Shortcuts
    };

    shortcutTiles = [];

    connectedCallback(){
        this.getShortcutTiles();
    }

    getShortcutTiles(){
        getShortcuts().then(response => {
            if (response) {
                this.shortcutTiles = response;
                this.shortcutTiles.forEach(item => {
                    item.image = BOOTSTRAPData + '/assets/img/' + item.image;
                });
            }
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