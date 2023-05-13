import { LightningElement } from 'lwc';
import BOOTSTRAPData from '@salesforce/resourceUrl/bootstrapdata';   
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class EDF27_FellowResourceLibrary_Footer extends LightningElement {

    renderedCallback() {
        Promise.all([
            loadStyle(this, BOOTSTRAPData + '/assets/css/fellow-resource-library-override.css')
        ]).then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log("Error page")
            });
    }
    
}