public with sharing class CacheController {

    /**
     * Session cache controller to store and retrieve data required for functionality of comparing
     */

    private Cache.SessionPartition easyDealsPartition = Cache.Session.getPartition('local.EasyDeals');

    public void putToCache(String retrivewdName, String retrievedId){
        System.debug('putToCache entered');
        System.debug('retrivewdName: ' + retrivewdName);
        System.debug('retrievedId: ' + retrievedId);
        easyDealsPartition.put(retrievedId, retrivewdName);
        
        System.debug('exiting putToCache');
    }

    public String getFromCache(String storedKey){
        System.debug('getFromCache entered');
        System.debug('storedKey: ' + storedKey);

        String valueFromCache = (String) easyDealsPartition.get(storedKey);
        System.debug('valueFromCache: ' + valueFromCache);
        return valueFromCache;
    }

}
