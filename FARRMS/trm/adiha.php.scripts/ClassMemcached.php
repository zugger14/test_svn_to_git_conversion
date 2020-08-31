<?php
class ClassMemcached {
    var $iTtl = 120; //Time To Live 0 for never expire.
    var $bEnabled = false; // Memcache enabled?
    var $oCache = null;
    // constructor
   function __construct() {
        if (class_exists('Memcache')) {
            $this->oCache = new Memcache();     /* Instead of this class we need to check for Memcached windows based dll file.*/
            $this->bEnabled = true;
            if (! $this->oCache->connect('localhost', 11211))  { // Instead 'localhost' here can be IP
                $this->oCache = null;
                $this->bEnabled = false;
            }

        } else {
            $this->oCache = null;
            $this->bEnabled = false;
        }
            
    }
    
    // get cache version
    function getVersion() {        
        if (!$this->bEnabled) return;     
        $vData = ($this->bEnabled) ? $this->oCache->getVersion() : ' Connection Failed.';
        return  $vData;
    }

    // get data from cache server
    function getData($sKey) {        
        if (!$this->bEnabled) return;  

        $vData = $this->oCache->get($sKey);
        return  $vData;
       // return false === $vData ? false : $vData;
    }

    // save data to cache server
    function setData($sKey, $vData, $expiry_time=0) {
        if (!$this->bEnabled) return;  

        //Use MEMCACHE_COMPRESSED to store the item compressed (uses zlib).   
        $compress = is_bool($vData) || is_int($vData) || is_float($vData) ? false : MEMCACHE_COMPRESSED;     
        return $this->oCache->set($sKey, $vData, 0, $expiry_time);
    }
    // DELETE data to cache server
    function delData($sKey) {        
        if (!$this->bEnabled) return;  

        return $this->oCache->delete($sKey);
    }
    
    // get unique key $k = md5($source); used to release session key.
    function getkey($source,$key_suffix='',$md5=false,$append_user_name=true) {  
        if (!$this->bEnabled) return;   
        
        global $app_user_name,$database_name;

        if ($md5) {
            $k = md5($source);
        } else {
            $k = $database_name . '_' .  $source;
            $k = $k . (($append_user_name) ? '_' . $app_user_name : ''); 
            $k = $k . (($key_suffix != '') ? '_' . $key_suffix : ''); 
        }
        
        return  $k;
    }

    function getMemcacheKeys() {
        if (!$this->bEnabled) return;  

        $list = array();
        $allSlabs = $this->oCache->getExtendedStats('slabs');
        //print_r($allSlabs);
        //$items = $this->oCache->getExtendedStats('items');
        foreach($allSlabs as $server => $slabs) {
            if (!is_array($slabs)) continue;
            foreach($slabs AS $slabId => $slabMeta) {
               $cdump = $this->oCache->getExtendedStats('cachedump',(int)$slabId);
               if (!is_array($cdump)) continue;
                foreach($cdump AS $keys => $arrVal) {
                    if (!is_array($arrVal)) continue;
                    foreach($arrVal AS $k => $v) {  
                         $list[] = $k;           
                        //echo $k .'<br>';
                    }
               }
            }
        }
        return $list;   
    }//EO getMemcacheKeys()

    function deleteAllKeys() {
        if (!$this->bEnabled) return;  
    
        $slabs = $this->oCache->getExtendedStats('slabs');
        foreach ($slabs as $serverSlabs) {
            if ($serverSlabs) {
                foreach ($serverSlabs as $slabId => $slabMeta) {
                    if (is_int($slabId)) {
                        try {
                            $cacheDump = $this->oCache->getExtendedStats('cachedump', (int) $slabId, 1000);
                        } catch (Exception $e) {
                            continue;
                        }

                        if (is_array($cacheDump)) {
                            foreach ($cacheDump as $dump) {
                                if (is_array($dump)) {
                                    foreach ($dump as $key => $value) {
                                        $this->oCache->delete($key);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function clearByPrefix($prefixes = array(),$md5_encode=false) {
        if (!$this->bEnabled) return;
        if (is_array($prefixes))
        $prefixes = array_unique($prefixes);

        $slabs = $this->oCache->getExtendedStats('slabs');
        foreach ($slabs as $serverSlabs) {
            if ($serverSlabs) {
                foreach ($serverSlabs as $slabId => $slabMeta) {
                    if (is_int($slabId)) {
                        try {
                            $cacheDump = $this->oCache->getExtendedStats('cachedump', (int) $slabId, 1000);
                        } catch (Exception $e) {
                            continue;
                        }

                        if (is_array($cacheDump)) {
                            foreach ($cacheDump as $dump) {
                                if (is_array($dump)) {
                                    foreach ($dump as $key => $value) {

                                        $clearFlag = false;
                                        // Check key has prefix or not
                                        if (is_array($prefixes)) {
                                            foreach ($prefixes as $prefix) {
                                                $prefix = ($md5_encode) ? md5($prefix) : trim($prefix);
                                                $clearFlag = $clearFlag || preg_match('/^' . preg_quote($prefix, '/') . '/', $key);
                                            }
                                        } else {
                                            $prefix = ($md5_encode) ? md5($prefix) : trim($prefix);
                                            $clearFlag = $clearFlag || preg_match('/^' . preg_quote($prefixes, '/') . '/', $key);                                        
                                        }
                                        
                                        // Clear cache
                                        if ($clearFlag) {
                                             $this->oCache->delete($key);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    function close_conn() {
       $this->oCache->close();
    }
}


?>