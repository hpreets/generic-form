import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class EDF53_BreadcrumbLevel3 extends NavigationMixin(LightningElement) {
    @api currentPageLabel;
    @api previousPageLabel;
    @api previousPageName;

    navigateToDashboard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }

    navigateToItems() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.previousPageName // 'edfitems'
            }
        });
    }
}