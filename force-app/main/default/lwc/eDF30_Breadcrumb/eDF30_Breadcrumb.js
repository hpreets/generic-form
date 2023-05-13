import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class EDF30_Breadcrumb extends NavigationMixin(LightningElement) {
    @api currentPageLabel;

    navigateToDashboard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
}