public with sharing class CacheController {

    /**
     * Session cache controller to store and retrieve data required for functionality of comparing
     */

    private Cache.SessionPartition easyDealsPartition = Cache.Session.getPartition('local.EasyDeals');

    public void putToCache(String retrivewdName, String retrievedId){
        easyDealsPartition.put(retrievedId, retrivewdName);
    }

    public String getFromCache(String storedKey){
        String valueFromCache = (String) easyDealsPartition.get(storedKey);
        return valueFromCache;
    }

}
