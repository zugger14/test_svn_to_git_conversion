<?php
/**
 *
 * This file is part of phpFastCache.
 *
 * @license MIT License (MIT)
 *
 * For full copyright and license information, please see the docs/CREDITS.txt file.
 *
 * @author Khoa Bui (khoaofgod)  <khoaofgod@gmail.com> https://www.phpfastcache.com
 * @author Georges.L (Geolim4)  <contact@geolim4.com>
 *
 */
use Phpfastcache\CacheManager;

use Phpfastcache\Config\ConfigurationOption;

// Include composer autoloader
require __DIR__ . '/../../lib/Phpfastcache/Autoload/Autoload.php';

$path = __DIR__ . '/../../../../../dev/shared_docs/data_cache';
CacheManager::setDefaultConfig(new ConfigurationOption([
    'path' => $path, 
]));
$InstanceCache = CacheManager::getInstance('files',null,'trm_Files');
echo 'Cache Version ', Phpfastcache\Api::getPhpFastCacheVersion(), '</br>';
echo 'Path - ' . $InstanceCache->getPath();
$key = isset($_GET['cachekey']) ? $_GET['cachekey'] : 'trmtracker_release_MB_msingh_v'; 
echo '<br> Key - ',$key , '<br>';
$item = $InstanceCache->getItem($key);
$hit = true;
//$a = $item->addTag('');
//$a = $item->removeTag('');
//$InstanceCache->deleteItem($key);
//$InstanceCache->save($a);

if (!$InstanceCache->hasItem($key)) {
	$hit = false;
} 


if ($hit) {
	echo '<br>Time to live - ' , $item->getTtl();
	echo ' Key ' ,($item->isExpired()) ? 'expired' : 'not expired yet. <br>';
	$tagname = $item->getTags(); //empty($item->getTagsAsString($separator = ', ')) ? 'null' : 'blank';
	//$tagname = $item->getTagsAsString($separator = ', ');
	echo '<br>Tag - ';
	var_dump ($tagname);
	echo '<br>Cached Data - ';
	var_dump($item->get());
} {
	echo '<br> Key not found.';
}

if (isset($_GET['cachekey']) && isset($_GET['deletekey'])) {
	$InstanceCache->deleteItem($key);
	echo '<br> Key deleted.';
	$key_exists = $InstanceCache->hasItem($key);
	if (!$key_exists) echo '<br> ' .$key . ' Key not found.';
}

/**
 * Now get the items by a specific tag
 */
echo '<br><br>List of keys by tag.<br>';
$InstanceCache->detachAllItems();
gc_collect_cycles();
$keys = $InstanceCache->getItemsByTag("");
foreach ($keys as $key) {
	echo 'Tag:', $key->getTagsAsString($separator = ', ');
    //echo "Key: {$key->getKey()} =&gt; {$key->get()}<br />";
    echo " - Key: {$key->getKey()} <br>";
}

echo '<br /><br /><a href="/">Back to index</a>&nbsp;--&nbsp;<a href="./' . basename(__FILE__) . '">Reload</a>';
?>