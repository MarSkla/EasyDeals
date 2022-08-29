import { LightningElement, api } from 'lwc';
import isGuest from '@salesforce/user/isGuest';
import putToCache from '@salesforce/apex/CacheController.putToCache';



/**
 * An organized display of a single product card.
 *
 * @fires SearchCard#calltoaction
 * @fires SearchCard#showdetail
 */
export default class SearchCard extends LightningElement {
    /**
     * Identify user type
     */
    @api
    get isGuestUser() {
        // console.log('isGuest: ' + isGuest);
        return isGuest
    }


    /**
     * An event fired when the user clicked on the action button. Here in this
     *  this is an add to cart button.
     *
     * Properties:
     *   - Bubbles: true
     *   - Composed: true
     *   - Cancelable: false
     *
     * @event SearchLayout#calltoaction
     * @type {CustomEvent}
     *
     * @property {String} detail.productId
     *   The unique identifier of the product.
     *
     * @export
     */

    /**
     * An event fired when the user indicates a desire to view the details of a product.
     *
     * Properties:
     *   - Bubbles: true
     *   - Composed: true
     *   - Cancelable: false
     *
     * @event SearchLayout#showdetail
     * @type {CustomEvent}
     *
     * @property {String} detail.productId
     *   The unique identifier of the product.
     *
     * @export
     */

    /**
     * A result set to be displayed in a layout.
     * @typedef {object} Product
     *
     * @property {string} id
     *  The id of the product
     *
     * @property {string} name
     *  Product name
     *
     * @property {Image} image
     *  Product Image Representation
     *
     * @property {object.<string, object>} fields
     *  Map containing field name as the key and it's field value inside an object.
     *
     * @property {Prices} prices
     *  Negotiated and listed price info
     */

    /**
     * A product image.
     * @typedef {object} Image
     *
     * @property {string} url
     *  The URL of an image.
     *
     * @property {string} title
     *  The title of the image.
     *
     * @property {string} alternativeText
     *  The alternative display text of the image.
     */

    /**
     * Prices associated to a product.
     *
     * @typedef {Object} Pricing
     *
     * @property {string} listingPrice
     *  Original price for a product.
     *
     * @property {string} negotiatedPrice
     *  Final price for a product after all discounts and/or entitlements are applied
     *  Format is a raw string without currency symbol
     *
     * @property {string} currencyIsoCode
     *  The ISO 4217 currency code for the product card prices listed
     */

    /**
     * Card layout configuration.
     * @typedef {object} CardConfig
     *
     * @property {Boolean} showImage
     *  Whether or not to show the product image.
     *
     * @property {string} resultsLayout
     *  Products layout. This is the same property available in it's parent
     *  {@see LayoutConfig}
     *
     * @property {Boolean} actionDisabled
     *  Whether or not to disable the action button.
     */

    /**
     * Gets or sets the display data for card.
     *
     * @type {Product}
     */
    @api
    displayData;

    /**
     * Gets or sets the card layout configurations.
     *
     * @type {CardConfig}
     */
    @api
    config;

    /**
     * Gets the product image.
     *
     * @type {Image}
     * @readonly
     * @private
     */
    get image() {
        return this.displayData.image || {};
    }

    /**
     * Gets the product fields.
     *
     * @type {object.<string, object>[]}
     * @readonly
     * @private
     */
    get fields() {
        return (this.displayData.fields || []).map(({ name, value }, id) => ({
            id: id + 1,
            tabIndex: id === 0 ? 0 : -1,
            // making the first field bit larger
            class: id
                ? 'slds-truncate slds-text-heading_small'
                : 'slds-truncate slds-text-heading_medium',
            // making Name and Description shows up without label
            // Note that these fields are showing with apiName. When builder
            // can save custom JSON, there we can save the display name.
            value:
                name === 'Name' || name === 'Description'
                    ? value
                    : `${name}: ${value}`
        }));
    }

    /**
     * Whether or not the product image to be shown on card.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get showImage() {
        return !!(this.config || {}).showImage;
    }

    /**
     * Whether or not disable the action button.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get actionDisabled() {
        return !!(this.config || {}).actionDisabled;
    }

    /**
     * Gets the product price.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get price() {
        const prices = this.displayData.prices;
        return prices.negotiatedPrice || prices.listingPrice;
    }

    /**
     * Whether or not the product has price.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasPrice() {
        return !!this.price;
    }

    /**
     * Gets the original price for a product, before any discounts or entitlements are applied.
     *
     * @type {string}
     */
    get listingPrice() {
        return this.displayData.prices.listingPrice;
    }

    /**
     * Gets whether or not the listing price can be shown
     * @returns {Boolean}
     * @private
     */
    get canShowListingPrice() {
        const prices = this.displayData.prices;

        return (
            prices.negotiatedPrice &&
            prices.listingPrice &&
            // don't show listing price if it's less than or equal to the negotiated price.
            Number(prices.listingPrice) > Number(prices.negotiatedPrice)
        );
    }

    /**
     * Gets the currency for the price to be displayed.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get currency() {
        return this.displayData.prices.currencyIsoCode;
    }

    /**
     * Gets the container class which decide the innter element styles.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get cardContainerClass() {
        return this.config.resultsLayout === 'grid'
            ? 'slds-box card-layout-grid'
            : 'card-layout-list';
    }

    /**
     * Emits a notification that the user wants to add the item to their cart.
     *
     * @fires SearchCard#calltoaction
     * @private
     */
    notifyAction() {
        this.dispatchEvent(
            new CustomEvent('calltoaction', {
                bubbles: true,
                composed: true,
                detail: {
                    productId: this.displayData.id,
                    productName: this.displayData.name
                }
            })
        );
    }

    /**
     * Emits a notification that the user indicates a desire to view the details of a product.
     *
     * @fires SearchCard#showdetail
     * @private
     */
    notifyShowDetail(evt) {
        evt.preventDefault();

        this.dispatchEvent(
            new CustomEvent('showdetail', {
                bubbles: true,
                composed: true,
                detail: { productId: this.displayData.id }
            })
        );
    }
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    _productIdsToCompare = [];
    // _test = ['test1', 'test2', 'test3']

    // _objectReceived;

    addToListToCompare(event) {
        // console.log('checked: ', event.target.checked);
        // console.log('passed Id: ', event.target.dataset.id);
        // console.log('passed Value: ', event.target.dataset.value);
        // this._objectReceived = event.target.dataset.value;
        // console.log('_objectReceived: ' + this._objectReceived);

        // console.log('before newId assignment');

        // putToCache(event.target.dataset.id, event.target.dataset.value)
        putToCache({
            retrievedId:event.target.dataset.id
            // productToCompare: event.target.dataset.value
        }) //test

        // console.log('after putToCache');
        
        // console.log('getFromCache: ', getFromCache(event.target.dataset.id));


        // let newId = event.target.dataset.id

        // // console.log('before if');

        // // if(this._productIdsToCompare.length < 3) {
        // //     console.log('if entered');
        // //     console.log('_productIdsToCompare.length before intended add: ' + this._productIdsToCompare.length);
            
        // //     this._productIdsToCompare = [this._productIdsToCompare, newId];
        // //     console.log('_productIdsToCompare.length after intended add: ' + this._productIdsToCompare.length);
        // //     console.log(this._productIdsToCompare.length);
        // // } else {
        // //     console.log('za dużo elementów');
        // // }
        
        // console.log('_productIdsToCompare.length before intended add: ', this._productIdsToCompare.length);
        //     this._productIdsToCompare.push(newId);
        //     console.log(this._productIdsToCompare);
        // // this._productIdsToCompare = [... this._productIdsToCompare, newId];
        // console.log('_productIdsToCompare.length after intended add: ', this._productIdsToCompare.length);


        // // this._productIdsToCompare.forEach(element => {
        // //     console.log('element in _productIdsToCompare: ', element);
        // //     console.log('same: ', (element === newId));
        // // })

        // // this._test = [...this._test, 'test4']
        // // this._test.push('test5')

        // // this._test.forEach(element => {
        // //     console.log('element in _test: ' + element);
        // // })

        // // this.productIdsToCompareLength(newId);
        // console.log('addToListToCompare END');
    }
    
    // productIdsToCompareLength(newElement) {
    //     console.log('_productIdsToCompare.length: ' + this._productIdsToCompare.length);
        
    //     if(this._productIdsToCompare.length > 0) {
    //         if(this._productIdsToCompare.length < 3) {
    //             console.log('if entered');
    //             console.log('_productIdsToCompare.length before intended add: ' + this._productIdsToCompare.length);
    //             // this._productIdsToCompare = [...this._productIdsToCompare, newElement];
    //             this._productIdsToCompare.push(newElement);

    //             console.log('_productIdsToCompare.length after intended add: ' + this._productIdsToCompare.length);
    //             // console.log(this._productIdsToCompare.length);
    //         } else {
    //             console.log('za dużo elementów');
    //         }
    //     } else {
    //         this._productIdsToCompare = [newElement]
    //     }

    //     this._productIdsToCompare.forEach(element => {
    //         console.log('Id already in array: ' + element);
    //     });
    // }

}