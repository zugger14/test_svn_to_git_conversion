<?php
# Local path to the FARRMS application files.
$farrms_root_dir = "E:\\FARRMS_APPLICATIONS\\TEST\\TRMTracker_TEST\\FARRMS\\";

# FARRMS server root directory.
$farrms_root = "trm";

# If you have Virtual Domain then define and make sure you have FORWARD SLASH.
# e.g. $farrms_virtual_domain="TRMTracker_Master_Branch";.
# If not Virtual domain then path up to FARRMS.
# e.g. $farrms_virtual_domain="TRMTracker_Master_Branch/FARRMS";.
$farrms_virtual_domain = "/TRMTracker_TEST/";

if (!isset($farrms_client_dir) && (!isset($_COOKIE['client_folder']) || ($_COOKIE['client_folder'] == ''))) {
    close_inactive_window();
}

# FARRMS client root directory.
$farrms_client_dir = isset($_COOKIE['client_folder']) && ($_COOKIE['client_folder'] != '') ? $_COOKIE['client_folder'] : $farrms_client_dir;

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
