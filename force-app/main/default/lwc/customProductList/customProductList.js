import { LightningElement, api, wire } from 'lwc';
import getProducts from '@salesforce/apex/B2BGetInfo.getProducts';
import communityId from '@salesforce/community/Id';



const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'Name', fieldName: 'name' },
    { label: 'Website', fieldName: 'website', type: 'url' },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
    { label: 'Balance', fieldName: 'amount', type: 'currency' },
    { label: 'Close At', fieldName: 'closeAt', type: 'date' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class CustomProductList extends LightningElement {


    // @api
    // get effectiveAccountId() {
    //     return this.effectiveAccountId;
    // }

    // /**
    //  * Sets the effective account - if any - of the user viewing the product
    //  * and fetches updated cart information
    //  */
    // set effectiveAccountId(newId) {
    //     this.effectiveAccountId = newId;
    //     this.updateCartInformation();
    // }

    // @wire(getProducts, {
    //     communityId: communityId,
    //     // productId: '$recordId',
    //     effectiveAccountId: '$resolvedEffectiveAccountId'
    // })
    // products;

    @api products = [];
    // columns = columns;
    // record = {};
    @api effectiveAccountId;



    connectedCallback() {
        console.log('connectedfCallback runs');
        console.log('communityId: ' + communityId);
        console.log('effectiveAccountId: ' + this.effectiveAccountId);
        console.log('resolvedEffectiveAccountId: ' + this.resolvedEffectiveAccountId);

        getProducts({
            communityId : communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
        .then(result => {
            this.products = result
            console.log('result assigned to data: ' + this.products);
        })
        // this.data = generateData({ amountOfRecords: 100 }); z templatu z dokumentacji dla datatable
    }

    // get resolvedEffectiveAccountId() {
    //     const effectiveAccountId = this.effectiveAccountId || '';
    //     let resolved = null;

    //     if (
    //         effectiveAccountId.length > 0 &&
    //         effectiveAccountId !== '000000000000000'
    //     ) {
    //         resolved = effectiveAccountId;
    //     }
    //     return resolved;
    // }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }

    deleteRow(row) {
        const { id } = row;
        const index = this.findRowIndexById(id);
        if (index !== -1) {
            this.data = this.data
                .slice(0, index)
                .concat(this.data.slice(index + 1));
        }
    }

    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    showRowDetails(row) {
        this.record = row;
    }
}