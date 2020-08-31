<?php
require_once('ClassMemcached.php');
echo 'Memcache Server';

// $serverName = "PSDL09\INSTANCE2016";
// $connectionOptions = array("UID"=>"farrms_admin",  
//                          "PWD"=>"Admin2929",
//                          "Database"=>"TRMTracker_Trunk");

$memcache = new ClassMemcached();
//$memcache->connect('localhost', 11211) or die ("Could not connect");
if ($memcache->bEnabled) 	echo ' connected.'; 
else echo ' connection failed. ';

$version = $memcache->getVersion();
echo "<br>Server's version: ".$version."<br/>\n";

if (isset($_GET['del_key'])) {
	$a = $_GET['del_key'];//'-1787340386,68857905,-1111525593,-494406311,-185833818';
	$prefixes=explode(',',$a);

	$memcache->clearByPrefix($prefixes);
	echo 'Deleted keys with prefix ' . $a;
	die();

}


if (isset($_GET['flushall'])) {
	$memcache->deleteAllKeys();
	echo 'Deleted all keys ';
	die();
}

if (isset($_GET['get_key_value'])) {
	$get_result = $memcache->getData($_GET['get_key_value']);
	echo '<br> Value of key :- (' . $_GET['get_key_value'] . ') </br><br>';
	print_r($get_result);
	die();
}
//get all keys
echo '<br> List of all memcached keys.<br><br>';
$listkeys = $memcache->getMemcacheKeys();
print_r($listkeys);
die();

?> 
