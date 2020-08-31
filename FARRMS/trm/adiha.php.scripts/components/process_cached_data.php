<?php 
//  ini_set('display_errors', 1);        
//  ini_set('display_startup_errors', 1);
//  error_reporting(E_ALL); 
// var_dump($_REQUEST);

if (isset($_REQUEST["farrms_client_dir"])) $farrms_client_dir = $_REQUEST["farrms_client_dir"];

if (!isset($farrms_client_dir)) {
	echo 'Could not resolve client directory.';
	die();
}

$client_config_file_path = __DIR__.'/../../../' . $farrms_client_dir . '/farrms.client.config.ini.php';
require_once($client_config_file_path);
require_once("lib/adiha_dhtmlx/AdihaClasses/DataCache.php");
//require_once 'lib/adiha_dhtmlx/adiha_php_functions.3.0.php';

ob_clean();

$data_caching = isset($data_caching) ? $data_caching : (isset($ENABLE_DATA_CACHING) ? $ENABLE_DATA_CACHING : 0);

if ($data_caching) {	
	$encode_key = (isset($_REQUEST["encode_key"]) && $_REQUEST["encode_key"] == 1) ? true : false;
	$prefix = (isset($_REQUEST["prefix"]) && !empty($_REQUEST["prefix"])) ? $_REQUEST["prefix"] : "";
	//$newid = (isset($_REQUEST["newid"]) && !empty($_REQUEST["newid"])) ? $_REQUEST["newid"] : "";


	if ($prefix != '') {
		$data_cache = new DataCache();
		if ($data_cache->is_cache_server_exists()) {
			if ($prefix == strtolower($database_name) . '_' || $prefix == strtolower($database_name) . '_PH_' ) {
				$deleted_status = $data_cache->delete_all();					
			} else {
				$prefixes = explode(',',$prefix);
				$deleted_status = $data_cache->delete_key_by_prefix($prefixes,$encode_key);
			}
			$data_cache->close_conn();
		} else {
				$deleted_status = 'Cache server connection failed.';
			}

		echo $deleted_status; //Do not remove this line. This value is used for debugging purpose.

	} else if (isset($_REQUEST['delete_all']) && $_REQUEST['delete_all']==1) {

		$data_cache = new DataCache();

		if ($data_cache->is_cache_server_exists()) {
			$result = $data_cache->delete_all();
			echo $result;
			$data_cache->close_conn();
		} else {
			echo 'Cache server connection failed.';
		}

	} else if(isset($_REQUEST['key']) && $_REQUEST['key'] != '') {		
		$data_cache = new DataCache();
		if ($data_cache->is_cache_server_exists()) {
			$get_result = $data_cache->get_data($_REQUEST['key']);
			$data_cache->close_conn();
			echo '<br> Value of key :- (' . $_REQUEST['key'] . ') </br><br>';
			print '<pre>';print_r($get_result);print '</pre>';die();
		}  else {
			echo 'Cache server connection failed.';
		}
	} 
} else {
	echo 'Data Cache disabled.';
}


?>

