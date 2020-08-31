<?php
require_once __DIR__ . '/../../phpfastcache/lib/Phpfastcache/Autoload/Autoload.php';
$path = __DIR__ . '/../../../../dev/shared_docs/data_cache';

use Phpfastcache\CacheManager;
use Phpfastcache\Config\ConfigurationOption;
use Phpfastcache\Exceptions\PhpfastcacheInstanceNotFoundException;
use Phpfastcache\Exceptions\PhpfastcacheDriverConnectException;
use Phpfastcache\Exceptions\PhpfastcacheDriverCheckException;
//use Phpfastcache\Drivers\Couchdb\Config;
//use Phpfastcache\Drivers\Redis\Config;

CacheManager::setDefaultConfig(new ConfigurationOption([
    'path' => $path,
]));

class DataCache
{
    private $_cache_instance;
    private $_cache_server;
    private $_cache_server_port; 
    private $_expire_date;   
    private $_tag_name;  
    private $_app_user_name;
    private $_database_name;
    private $_cache_server_exists;

    function is_cache_server_exists() {
        return $this->_cache_server_exists;
    }

    public function __construct()
    {
        global $app_user_name, $database_name, $CACHE_SESSION_EXPIRY, $CACHE_DRIVER;

        $this->_app_user_name = $app_user_name;
        $this->_database_name = isset($database_name) ? strtolower($database_name) : 'trm';
        // Use 5days as max session expiry if not defined.
        $this->_expire_date = isset($CACHE_SESSION_EXPIRY) ? $CACHE_SESSION_EXPIRY : 432000;        
        $this->_tag_name = '';   

        $driver = isset($CACHE_DRIVER) ? $CACHE_DRIVER : 'Files';               
        $instance_id = $this->_database_name . $driver;
        $this->_cache_server_exists = $this->init_instance($driver, $instance_id);
    }

    /**
     * Get instance by ID or creates new instance.
     * @param  String   $driver         PHPfastcache driver
     * @param  String   $instance_id    PHPfastcache instance id
     * @return True if instance found otherwise return false.
     */
    private function init_instance($driver, $instance_id) {
        global $CACHE_SERVER, $CACHE_PORT;
        $cache_server = isset($CACHE_SERVER) ? $CACHE_SERVER : '127.0.0.1';
        $cache_server_port = isset($CACHE_PORT) ? $CACHE_PORT : 0;
        $config = null;
        if ($driver == 'redis' || $driver == 'couchdb') {
            $config = new Config([
                  'host' => $cache_server, 
                  'port' => $cache_server_port, 
                ]);
        }

        try {
            $this->_cache_instance = CacheManager::getInstanceById($instance_id);
            return true;            
        } catch(PhpfastcacheInstanceNotFoundException $e) {
            try {
                $this->_cache_instance = CacheManager::getInstance($driver, $config, $instance_id);
                return true;
            } catch (PhpfastcacheDriverCheckException|PhpfastcacheDriverConnectException $e) {
                //print_r($e);
                return false;
            }               
        }       
    }

    /**
     * Get Cached data.
     * @param  String $key Unique identifier to store cache data.
     * @return Returns cached data of given key.
     */
    public  function get_data($key) {
        $this->_cache_instance->detachAllItems();
        //TODO: add garbage clear code
        
        $cache_item = $this->_cache_instance->getItem($key);
        return $cache_item->get();      
    }

    /**
     * Save data in cache server.
     * @param String $key         Unique identifier to store cache data
     * @param String $value       Data to save in cache server.
     * @param String $expiry_time Expiry date of cached data.
     */
    public  function set_data($key, $value, $expiry_time = '') {
        $this->_cache_instance->detachAllItems();
        $cache_item = $this->_cache_instance->getItem($key);
        if (empty($expiry_time)) $expiry_time = $this->_expire_date;
        $cache_item->addtag($this->_tag_name);
        $cache_item->set($value);
        $cache_item->expiresAfter($expiry_time);
        $this->_cache_instance->save($cache_item);
    }

    /**
     * Delete all items by tag name.
     * @return String   All Keys deleted.
     */
    public function delete_all($tag = '') {
        if (empty($tag)) $tag = $this->_tag_name; 
        $this->_cache_instance->clear();
        return 'All Keys deleted.';     
    }

    /**
     * Delete key
     * @param  String $key  Key used to cache data
     */
    public function delete_key($key) {
        if (is_array($key))
            $this->_cache_instance->deleteItems($key);
        else {
            $this->_cache_instance->deleteItem($key);
        }           
    }

    /**
     * All keys with given prefix or matched keys are deleted. 
     * @param  Array   $prefixes   Array of key prefix.
     * @param  boolean $encode_key Encode given key.
     * @return Array of deleted keys.
     */
    public function delete_key_by_prefix($prefixes = array(), $encode_key = false) {
        if (!$this->_cache_server_exists) return 'Cache server connection failed.';
        
        if (is_array($prefixes)) {
            $prefixes = array_unique($prefixes);
        }

        //incase of session key should ne regenerated.
        if ($encode_key) {
        	$list = array();
	        if (is_array($prefixes)) {  
	            foreach ($prefixes as $prefix) {
	                $list[] = $this->get_key($prefix, '', true);
	            }
	        } else {
	            $list[] = $this->get_key($prefix, '', true);	                                                  
	        }
	        $prefixes = $list;
        }
        
        $this->_cache_instance->deleteItems($prefixes);
        return 'Key Deleted.';
    }

    /**
     * Generate key with database name as prefix. eg. dbname_$source_$app_user_name_keysuffix. md5 encoding is done for session key.
     * @param  String  $source           Main key string. It can be session id or source like MB for message caching, MM for left main menu list, PH for bookstructure.
     * @param  String  $key_suffix       String to add as suffix.
     * @param  boolean $encode_key       Encode source with MD5.
     * @param  boolean $append_user_name Append user name as key suffix.
     * @return [type]                    Generated cache key.
     */
    public function get_key($source='', $key_suffix='', $encode_key=false, $append_user_name=true) {         
        if ($encode_key) {
            $k = $this->_database_name . '_' . md5("session_" . $source);
        } else {
            $k = $this->_database_name . '_' .  $source;
            $k = $k . (($append_user_name && $this->_app_user_name) ? '_' . $this->_app_user_name : ''); 
            $k = $k . (!empty($key_suffix) ? '_' . $key_suffix : ''); 
        }        
        return  $k;
    }

    /**
     * Fetch all cached items. This method should be private as it returns implementation specific object (ExtendedCacheItemInterface[])
     * @param  String $tag [Tag name]
     * @return [Array of ExtendedCacheItemInterface.]
     */
    private function get_all_items($tag = '') { 
        if (empty($tag)) $tag = $this->_tag_name; 

        $items  = $this->_cache_instance->getItemsByTag($tag);
        return $items;
    }

    /**
     * Fetch all keys by tag. 
     * @param  String $tag [Tag name is used to categorize cached items.]
     * @return [Array of key of items]
     */
    public function list_key($tag = '') { 
        if (empty($tag)) $tag = $this->_tag_name; 
        
        $list = array();
        $keys   = $this->_cache_instance->getItemsByTag($tag);
        foreach ($keys as $key) {
            $list[] =  $key->getKey();
        }
        return $list;
    }

    /**
     * Get phpfastcache version.
     * @return String   Version of cache driver.
     */
    public function get_cache_version() { 
        $version = Phpfastcache\Api::getPhpFastCacheVersion();
        return $version;
    }

    /**
     * This function is not removed as it is called from other function. This function may be required if other than files cache driver is used.     
     */
     function close_conn() {
     	CacheManager::clearInstance($this->_cache_instance);
    }
}