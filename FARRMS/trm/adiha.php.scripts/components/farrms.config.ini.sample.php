<?php
# Local path to the FARRMS application files.
$farrms_root_dir = "D:\FARRMS\TRMTracker_Master_Branch\FARRMS";

# FARRMS server root directory.
$farrms_root = "trm";

# If you have Virtual Domain then set virtual domain name. 
# e.g. $farrms_virtual_domain = "TRMTracker_Master_Branch";.
# If you don't have Virtual Domain then set path up to FARRMS application files as shown in example. 
# e.g. $farrms_virtual_domain = "TRMTracker_Master_Branch/FARRMS";.
$farrms_virtual_domain = "TRMTracker_Master_Branch";

if (empty($farrms_client_dir) && (empty($_COOKIE['client_folder']) || ($_COOKIE['client_folder'] == ''))) {
	if (function_exists('close_inactive_window')) {
		close_inactive_window();
	} else {
		// This will ensure that message count process is halted if client_folder cannot be resolved
		header('HTTP/1.0 403 Forbidden');
    	die('Access Forbidden!');
	}
}

# FARRMS client root directory.
$farrms_client_dir = !empty($_COOKIE['client_folder']) ? $_COOKIE['client_folder'] : $farrms_client_dir;

# Type of the module.
$module_type = isset($_COOKIE['module_type']) ? $_COOKIE['module_type'] : (isset($module_type) ? $module_type : '');

# Your WEB SERVER name or if you don't have domain name then you could use.
# IP address of your Web Server.
$REQUEST_PROTOCOL = 'http';
if ((isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') || 
	((!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') || 
	(!empty($_SERVER['HTTP_X_FORWARDED_SSL']) && $_SERVER['HTTP_X_FORWARDED_SSL'] == 'on'))) {
    $REQUEST_PROTOCOL = 'https';
}
$webserver = $REQUEST_PROTOCOL . "://" . $_SERVER['SERVER_NAME'];
?>
