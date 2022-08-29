import { api, LightningElement } from 'lwc';
import { resolve } from 'c/cmsResourceResolver';


export default class CompareElement extends LightningElement {
    @api
    compareData

    get image() {
        return resolve(this.compareData.defaultImage.url) || {};
    }

    get fields() {
        return this.compareData.fields || {};
    }

    get price() {
        return this.compareData.prices || {};
    }

}