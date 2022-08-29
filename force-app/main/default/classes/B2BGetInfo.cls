public with sharing class B2BGetInfo {
  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductDetail getProduct(
    String communityId,
    String productId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
    return ConnectApi.CommerceCatalog.getProduct(
      webstoreId,
      productId,
      effectiveAccountID,
      null,
      false,
      null,
      false,
      true,
      false
    );
  }

//moja START
  @AuraEnabled
  public static ConnectApi.ProductOverviewCollection getProducts(String communityId, String effectiveAccountId) {

      // List<String> ids = [SELECT ID FROM Product2 WHERE ....]
      // List<String> ids = new List<String>();

      // ids.add('01t7Q000002b2EaQAI');
      // ids.add('01t7Q000002b2F4QAI');
      // ids.add('01t7Q000002b2EzQAI');
      // ids.add('01t7Q000002b2EpQAI');
      // ids.add('01t7Q000002b2EqQAI');
      // ids.add('01t7Q000002b2EuQAI');

      // List<String> fields = new List<String>();
      // fields.add('Name');
      
      List<String> ids = CacheController.getFromCache();

      System.debug('B2BGetInfo.getProducts entered');
      System.debug('communityId: ' + communityId);
      System.debug('effectiveAccountId: ' + effectiveAccountId);
    
      String webstoreIdGetProducts = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
      System.debug('webstoreIdGetProducts: ' + webstoreIdGetProducts);
    
      try {
        ConnectApi.ProductOverviewCollection result = ConnectApi.CommerceCatalog.getProducts(
          webstoreIdGetProducts,
          effectiveAccountId,
          ids, //ids
          null, //skus
          null, //fields
          false, //exclude fields
          false //exclude prices
        );

        ConnectApi.ProductOverview resultProducts = result.products[0];
        System.debug('resultProducts: ..........');
        System.debug('resultProducts: ' + resultProducts);
        System.debug('resultProducts.fields: ' + resultProducts.fields);
        System.debug('resultProducts.fields.get(\'Name\'): ' + resultProducts.fields.get('Name'));


        System.debug('B2BGetInfo.getProducts.try entered');
        System.debug('total: ' + result.total);
        
        System.debug('products: ' + result.products);

        return result;

        // return ConnectApi.CommerceCatalog.getProducts(
        //   webstoreIdGetProducts,
        //   effectiveAccountId,
        //   ids,
        //   null,
        //   fields,
        //   false,
        //   false
        // );
        
      } catch (Exception e) {
        System.debug('B2BGetInfo.getProducts.catch entered');

        throw new AuraHandledException(e.getMessage());
      }


    }

  @AuraEnabled(cacheable=true)
  public static List<Review__c> getReviews(String productId){

    System.debug('GETREVIEWS entered with parameter: ' + productId);

    try {
      List<Review__c> reviewsRecentFive= [SELECT Message__c, Product__c, CreatedDate, CreatedBy.Name  FROM Review__c WHERE Product__c =: productId ORDER BY CreatedDate desc LIMIT 5];

      System.debug('GETREVIEWS reviewsRecentFive: ' + reviewsRecentFive);
      
      return reviewsRecentFive;
      
      // return [SELECT Id, Message__c, Product__c, CreatedDate
      //         FROM Review__c
      //         WHERE Product__c =: productId
      //         ORDER BY CreatedDate desc
      //         LIMIT 5
      // ];
      
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }


//-------------------------moja END-------------------------

  @AuraEnabled(cacheable=true)
  public static Boolean checkProductIsInStock(String productId) {
    /*
     * The following is an example of calling an external API.
     * The example API provided is extremely simple: It takes in a product id
     * and returns a true or false value for inStock based on whether the 15th char is odd or even.
     *
     * To access this endpoint on your org, go to Remote Site Settings in Setup as an admin user
     * click "New Remote Site" and provide "https://inventorymanagerdemo.herokuapp.com" for the "Remote Site URL" field
     */
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String endpoint =
      'https://inventorymanagerdemo.herokuapp.com/api/inventory/' + productId;
    request.setEndpoint(endpoint);
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    // If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {
      // Deserialize the JSON string into collections of primitive data types.
      Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      return (boolean) results.get('inStock');
    } else {
      return false;
    }
  }

  @AuraEnabled
  public static ConnectApi.CartSummary getCartSummary(
    String communityId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
    //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
    String activeCartOrId = 'current';

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    return ConnectApi.CommerceCart.getCartSummary(
      webstoreId,
      effectiveAccountId,
      activeCartOrId
    );
  }

  @AuraEnabled
  public static ConnectApi.CartItem addToCart(
    String communityId,
    String productId,
    String quantity,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
    cartInput.productId = productId;
    cartInput.quantity = quantity;
    cartInput.type = ConnectApi.CartItemType.PRODUCT;

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
    return ConnectApi.CommerceCart.addItemToCart(
      webstoreId,
      effectiveAccountId,
      'active',
      cartInput
    );
  }

  @AuraEnabled
  public static ConnectApi.Wishlist createAndAddToList(
    String communityId,
    String productId,
    String wishlistName,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // Store the product in a WishlistItemInput to pass to the Wishlist
    ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
    wishlistItemInput.productId = productId;

    //Create a wishlistInput to be created
    ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
    wishlistInput.name = wishlistName;
    wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
      wishlistItemInput
    };

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
    return ConnectApi.CommerceWishlist.createWishlist(
      webstoreId,
      effectiveAccountId,
      wishlistInput
    );
  }

  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductPrice getProductPrice(
    String communityId,
    String productId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
    return ConnectApi.CommerceStorePricing.getProductPrice(
      webstoreId,
      productId,
      effectiveAccountId
    );
  }
}