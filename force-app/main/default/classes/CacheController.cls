public with sharing class CacheController {

    /**
     * Session cache controller to store and retrieve data required for functionality of comparing
     */
    
    @AuraEnabled(cacheable=true)
    public static void putToCache(String retrievedId){
        System.debug('PUT: parameter: ' + retrievedId);
        // System.debug('PUT: putToCache START');
        List<String> collectedId = new List<String>();
        // List<String> collectedId = getFromCache('ProductsToCompare'); //NullPointer
        // System.debug('PUT: collectedId size: ' + collectedId.size());
        
        Cache.SessionPartition easyDealsPartition = Cache.Session.getPartition('local.EasyDeals');

        if(getFromCache() == null){
            // System.debug('if START - in chache: ' + getFromCache());
            collectedId.add(retrievedId);
            // System.debug('if END - curent collectedId: ' + collectedId);
        } else {
            // System.debug('else START - in cache: ' + getFromCache());
            collectedId = getFromCache();
            collectedId.add(retrievedId);
            // System.debug('else END - curent collectedId: ' + collectedId);
        }

        easyDealsPartition.put('toCompare', collectedId);
        System.debug('PUT: getFromCache: ' + getFromCache());

        // System.debug('PUT: all keys: ' + easyDealsPartition.getKeys());
        // System.debug('PUT: value in cache: ' + easyDealsPartition.get('ProductsToCompare'));
        System.debug('PUT: putToCache END');

    }


    @AuraEnabled(cacheable=true)
    public static List<String> getFromCache(){
        Cache.SessionPartition easyDealsPartition = Cache.Session.getPartition('local.EasyDeals');
        System.debug('GET: getFromCache entered');
        // System.debug('GET: parameter: ' + storedKey);

        List<String> valueFromCache =(List<String>) easyDealsPartition.get('toCompare');
        // String valueFromCache = (String) Cache.Session.get(storedKey);
        // System.debug('GET: valueFromCache: ' + valueFromCache);
        return valueFromCache;
    }

    @AuraEnabled
    public static List<String> cleanCache(){
        Cache.SessionPartition easyDealsPartition = Cache.Session.getPartition('local.EasyDeals');
        List<String> emptyList = new List<String>();
        easyDealsPartition.put('toCompare', emptyList);

        // List<String> storedData = getFromCache();
        // System.debug('CLEAN: stored data: ' + storedData);
        // for (String storedId : storedData) {
        //     System.debug('CLEAN: storedId inside loop: ' + storedId);
        //     easyDealsPartition.remove(storedId);
        // }
        System.debug('EMPTY: ????' + getFromCache());
        return getFromCache();
    }

    // @AuraEnabled(cacheable=true)
    // public static void putToCache(String retrievedId, Object productToCompare){
    //     Cache.SessionPartition easyDealsPartition = Cache.Session.getPartition('local.EasyDeals');
    //     System.debug('putToCache entered');
    //     System.debug('retrievedId: ' + retrievedId);
    //     System.debug('productToCompare: ' + productToCompare);
    //     easyDealsPartition.put(retrievedId, productToCompare);
    //     // Cache.Session.put(retrievedId, productToCompare);
        
    //     System.debug('exiting putToCache');
    //     System.debug(easyDealsPartition);
    // }

    // @AuraEnabled(cacheable=true)
    // public static Object getFromCache(String storedKey){
    //     Cache.SessionPartition easyDealsPartition = Cache.Session.getPartition('local.EasyDeals');
    //     System.debug('getFromCache entered');
    //     System.debug('storedKey: ' + storedKey);

    //     Object valueFromCache = easyDealsPartition.get(storedKey);
    //     // String valueFromCache = (String) Cache.Session.get(storedKey);
    //     System.debug('valueFromCache: ' + valueFromCache);
    //     return valueFromCache;
    // }

}
